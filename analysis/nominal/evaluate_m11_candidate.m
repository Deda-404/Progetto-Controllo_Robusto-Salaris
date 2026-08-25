function audit = evaluate_m11_candidate( ...
    controller, solverObjective, P, G, Gd, W1, W2, gammaFull, config)
%EVALUATE_M11_CANDIDATE Independently audit one structured solution.

arguments
    controller {mustBeA(controller, {'ss', 'tf', 'zpk'})}
    solverObjective (1, 1) double
    P {mustBeA(P, {'ss', 'tf', 'zpk'})}
    G {mustBeA(G, {'ss', 'tf', 'zpk'})}
    Gd {mustBeA(Gd, {'ss', 'tf', 'zpk'})}
    W1 {mustBeA(W1, {'ss', 'tf', 'zpk'})}
    W2 {mustBeA(W2, {'ss', 'tf', 'zpk'})}
    gammaFull (1, 1) double {mustBePositive}
    config (1, 1) struct = hinfstruct_specs_m11
end

controller = localClearNames(ss(controller));
G = localClearNames(ss(G));
Gd = localClearNames(ss(Gd));
W1 = localClearNames(ss(W1));
W2 = localClearNames(ss(W2));
P = localClearNames(ss(P));

identity = ss(eye(2));
S = feedback(identity, G * controller);
T = identity - S;
KS = controller * S;
weightedW1S = W1 * S;
weightedW2KS = W2 * KS;
weightedClosedLoop = [weightedW1S; weightedW2KS];
closedLoopFromP = lft(P, controller);

[weightedNorm, weightedPeakFrequency] = localSafeNorm( ...
    weightedClosedLoop);
[W1SNorm, W1SPeakFrequency] = localSafeNorm(weightedW1S);
[W2KSNorm, W2KSPeakFrequency] = localSafeNorm(weightedW2KS);
[closedLoopError, closedLoopErrorPeakFrequency] = localSafeNorm( ...
    closedLoopFromP - weightedClosedLoop);

[Ag, Bg, Cg, Dg] = ssdata(G);
[Ak, Bk, Ck, Dk] = ssdata(controller);
assert(norm(Dg, 'fro') == 0, 'M11Candidate:PlantFeedthrough', ...
    'The explicit internal construction assumes D_G=0.');
Ainternal = [Ag - Bg * Dk * Cg, Bg * Ck; -Bk * Cg, Ak];
Br = [Bg * Dk; Bk];
Bd = [Gd.B; zeros(size(Ak, 1), size(Gd.B, 2))];
Cq = [Cg, zeros(size(Cg, 1), size(Ak, 1))];
Cu = [-Dk * Cg, Ck];
closedLoopReference = ss(Ainternal, Br, [Cq; Cu], ...
    [zeros(2); Dk]);
closedLoopDisturbance = ss(Ainternal, Bd, [Cq; Cu], zeros(4, 2));
internalPoles = eig(Ainternal);

objectiveAbsoluteError = abs(weightedNorm - solverObjective);
objectiveRelativeError = objectiveAbsoluteError / ...
    max(abs(solverObjective), eps);
lowerBoundAbsoluteGap = weightedNorm - gammaFull;
lowerBoundRelativeGap = lowerBoundAbsoluteGap / gammaFull;
lowerBoundPassed = isfinite(weightedNorm) && ...
    weightedNorm >= gammaFull * ...
        (1 - config.lowerBoundRelativeTolerance);
internallyStable = all(real(internalPoles) < ...
    -config.stabilityTolerance) && isstable(S) && isstable(T) && ...
    isstable(KS) && isstable(closedLoopFromP);
objectiveConsistent = isfinite(objectiveRelativeError) && ...
    objectiveRelativeError <= config.objectiveRelativeTolerance && ...
    closedLoopError <= config.closedLoopConsistencyTolerance;

if ~isfinite(solverObjective)
    classification = "SOLVER_FAILED";
elseif ~internallyStable
    classification = "INVALID_UNSTABLE";
elseif ~isfinite(weightedNorm)
    classification = "SOLVER_FAILED";
elseif ~lowerBoundPassed || ~objectiveConsistent
    classification = "NUMERICALLY_SUSPECT";
else
    classification = "VALID_STABLE";
end

audit.controller = controller;
audit.S = S;
audit.T = T;
audit.KS = KS;
audit.weightedW1S = weightedW1S;
audit.weightedW2KS = weightedW2KS;
audit.weightedClosedLoop = weightedClosedLoop;
audit.closedLoopFromP = closedLoopFromP;
audit.closedLoopReference = closedLoopReference;
audit.closedLoopDisturbance = closedLoopDisturbance;
audit.Ainternal = Ainternal;
audit.internalPoles = internalPoles;
audit.metrics = struct( ...
    'controllerOrder', order(controller), ...
    'internalStateCount', numel(internalPoles), ...
    'maximumClosedLoopRealPart', max(real(internalPoles)), ...
    'internallyStable', internallyStable, ...
    'sensitivityStable', isstable(S), ...
    'complementarySensitivityStable', isstable(T), ...
    'controlSensitivityStable', isstable(KS), ...
    'W1SNorm', W1SNorm, ...
    'W1SPeakFrequency', W1SPeakFrequency, ...
    'W2KSNorm', W2KSNorm, ...
    'W2KSPeakFrequency', W2KSPeakFrequency, ...
    'weightedNorm', weightedNorm, ...
    'weightedPeakFrequency', weightedPeakFrequency, ...
    'solverObjective', solverObjective, ...
    'objectiveAbsoluteError', objectiveAbsoluteError, ...
    'objectiveRelativeError', objectiveRelativeError, ...
    'closedLoopError', closedLoopError, ...
    'closedLoopErrorPeakFrequency', closedLoopErrorPeakFrequency, ...
    'gammaFullM10', gammaFull, ...
    'lowerBoundAbsoluteGap', lowerBoundAbsoluteGap, ...
    'lowerBoundRelativeGap', lowerBoundRelativeGap, ...
    'lowerBoundPassed', lowerBoundPassed, ...
    'objectiveConsistent', objectiveConsistent, ...
    'minrealUsedForGate', false);
audit.classification = classification;
end

function [value, frequency] = localSafeNorm(system)
try
    [value, frequency] = norm(system, inf);
catch
    value = inf;
    frequency = NaN;
end
end

function system = localClearNames(system)
system.InputName = repmat({''}, size(system, 2), 1);
system.OutputName = repmat({''}, size(system, 1), 1);
end
