function analysis = analyze_m12_robust_stability( ...
    TzwUnc, GuncQ, K, W1, W2, manualMu, config)
%ANALYZE_M12_ROBUST_STABILITY Run robstab and audit its perturbation.

arguments
    TzwUnc uss
    GuncQ uss
    K {mustBeA(K, {'ss', 'tf', 'zpk'})}
    W1 {mustBeA(W1, {'ss', 'tf', 'zpk'})}
    W2 {mustBeA(W2, {'ss', 'tf', 'zpk'})}
    manualMu (1, 1) struct
    config (1, 1) struct = mu_analysis_specs_m12
end

options = robOptions('Display', config.robustDisplay, ...
    'Sensitivity', config.robustSensitivity, ...
    'MussvOptions', config.robustMussvOptions);
[stabilityMargin, worstUncertainty, info] = robstab(TzwUnc, options);
assert(stabilityMargin.LowerBound <= ...
    stabilityMargin.UpperBound + config.boundTolerance, ...
    'M12RS:InvalidBounds', ...
    'robstab returned reversed robustness-margin bounds.');
outcome = localClassifyMargin(stabilityMargin);

worstWeightedLoop = usubs(TzwUnc, worstUncertainty);
worstPoles = pole(worstWeightedLoop);
worstPlant = usubs(GuncQ, worstUncertainty);
worstPhysical = localPhysicalLoop(worstPlant, K, W1, W2);
diagnostics = localWorstCaseDiagnostics(GuncQ.Uncertainty, ...
    worstUncertainty, stabilityMargin.CriticalFrequency, "RS");

marginScale = max(1, abs(stabilityMargin.UpperBound));
lowerError = abs(manualMu.marginLowerApproximation - ...
    stabilityMargin.LowerBound) / marginScale;
upperError = abs(manualMu.marginUpperApproximation - ...
    stabilityMargin.UpperBound) / marginScale;
frequencyError = abs(manualMu.upperCriticalFrequency - ...
    stabilityMargin.CriticalFrequency) / ...
    max(stabilityMargin.CriticalFrequency, eps);
classificationConsistent = localManualOutcome(manualMu) == outcome;
if classificationConsistent && ...
        lowerError <= config.muMarginRelativeTolerance && ...
        upperError <= config.muMarginRelativeTolerance && ...
        frequencyError <= config.muCriticalFrequencyRelativeTolerance
    muConsistency = "PASS";
elseif classificationConsistent
    muConsistency = "DIAGNOSTIC";
else
    muConsistency = "FAIL_METHODOLOGICAL";
end
assert(muConsistency ~= "FAIL_METHODOLOGICAL", ...
    'M12RS:ManualMuMismatch', ...
    'Manual mussv and robstab give inconsistent classifications.');

analysis.options = options;
analysis.margin = stabilityMargin;
analysis.worstUncertainty = worstUncertainty;
analysis.info = info;
analysis.sensitivity = info.Sensitivity;
analysis.worstWeightedLoop = worstWeightedLoop;
analysis.worstWeightedPoles = worstPoles;
analysis.worstWeightedMaximumRealPart = max(real(worstPoles));
analysis.worstPhysicalLoop = worstPhysical;
analysis.worstCaseDiagnostics = diagnostics;
analysis.outcome = outcome;
analysis.manualMuConsistency = struct( ...
    'outcome', muConsistency, ...
    'classificationConsistent', classificationConsistent, ...
    'lowerMarginRelativeError', lowerError, ...
    'upperMarginRelativeError', upperError, ...
    'criticalFrequencyRelativeError', frequencyError);
end

function loop = localPhysicalLoop(G, K, W1, W2)
G = localClearNames(ss(G));
K = localClearNames(ss(K));
W1 = localClearNames(ss(W1));
W2 = localClearNames(ss(W2));
identity = ss(eye(2));
S = feedback(identity, G * K);
KS = K * S;
weighted = [W1 * S; W2 * KS];
[Ag, Bg, Cg, Dg] = ssdata(G);
[Ak, Bk, Ck, Dk] = ssdata(K);
assert(norm(Dg, 'fro') == 0, 'M12RS:PlantFeedthrough', ...
    'Worst-case physical loop requires D_G=0.');
Ainternal = [Ag - Bg * Dk * Cg, Bg * Ck; -Bk * Cg, Ak];
internalPoles = eig(Ainternal);
loop.S = S;
loop.KS = KS;
loop.weighted = weighted;
loop.Ainternal = Ainternal;
loop.internalPoles = internalPoles;
loop.maximumRealPart = max(real(internalPoles));
loop.stable = all(real(internalPoles) < 0);
end

function tableData = localWorstCaseDiagnostics( ...
    blocks, values, criticalFrequency, prefix)
names = string(fieldnames(blocks));
numberBlocks = numel(names);
BlockName = names;
Type = strings(numberBlocks, 1);
ActualValue = nan(numberBlocks, 1);
NominalValue = nan(numberBlocks, 1);
Deviation = nan(numberBlocks, 1);
NormalizedMagnitude = nan(numberBlocks, 1);
PeakGain = nan(numberBlocks, 1);
MagnitudeAtCritical = nan(numberBlocks, 1);
PhaseAtCriticalDeg = nan(numberBlocks, 1);
for index = 1:numberBlocks
    name = char(names(index));
    block = blocks.(name);
    value = values.(name);
    Type(index) = string(class(block));
    if isa(block, 'ureal')
        ActualValue(index) = value;
        NominalValue(index) = block.NominalValue;
        Deviation(index) = value - block.NominalValue;
        NormalizedMagnitude(index) = abs( ...
            actual2normalized(block, value));
    elseif isa(block, 'ultidyn')
        [PeakGain(index), ~] = norm(value, inf);
        NormalizedMagnitude(index) = PeakGain(index) / block.Bound;
        response = freqresp(value, criticalFrequency);
        MagnitudeAtCritical(index) = abs(response);
        PhaseAtCriticalDeg(index) = rad2deg(angle(response));
    end
end
tableData = table(BlockName, Type, ActualValue, NominalValue, ...
    Deviation, NormalizedMagnitude, PeakGain, MagnitudeAtCritical, ...
    PhaseAtCriticalDeg);
tableData.Properties.Description = prefix + " worst perturbation";
end

function outcome = localClassifyMargin(margin)
if margin.LowerBound > 1
    outcome = "PASS_CERTIFIED";
elseif margin.UpperBound < 1
    outcome = "FAIL_CERTIFIED";
else
    outcome = "INCONCLUSIVE";
end
end

function outcome = localManualOutcome(manualMu)
if manualMu.marginLowerApproximation > 1
    outcome = "PASS_CERTIFIED";
elseif manualMu.marginUpperApproximation < 1
    outcome = "FAIL_CERTIFIED";
else
    outcome = "INCONCLUSIVE";
end
end

function system = localClearNames(system)
system.InputName = repmat({''}, size(system, 2), 1);
system.OutputName = repmat({''}, size(system, 1), 1);
end
