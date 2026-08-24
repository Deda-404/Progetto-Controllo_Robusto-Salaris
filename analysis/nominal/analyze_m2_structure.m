function metrics = analyze_m2_structure(A, B, C, stabilityTolerance)
%ANALYZE_M2_STRUCTURE Pole, SVD-rank and PBH diagnostics for an LTI model.

n = size(A, 1);
assert(isequal(size(A), [n, n]), 'analyze_m2_structure:InvalidA', ...
    'A must be square.');
assert(size(B, 1) == n && size(C, 2) == n, ...
    'analyze_m2_structure:InvalidDimensions', ...
    'B and C must be compatible with A.');

poles = eig(A);
stableMask = real(poles) < -stabilityTolerance;
unstableMask = real(poles) > stabilityTolerance;
marginalMask = ~(stableMask | unstableMask);
criticalMask = unstableMask | marginalMask;

controllabilityMatrix = ctrb(A, B);
observabilityMatrix = obsv(A, C);
controllabilitySvd = svd(controllabilityMatrix);
observabilitySvd = svd(observabilityMatrix);

controllabilityTolerance = localSvdTolerance( ...
    controllabilityMatrix, controllabilitySvd);
observabilityTolerance = localSvdTolerance( ...
    observabilityMatrix, observabilitySvd);

criticalPoles = poles(criticalMask);
numberCritical = numel(criticalPoles);
controllabilityPbhRanks = zeros(numberCritical, 1);
observabilityPbhRanks = zeros(numberCritical, 1);
controllabilityPbhMinSvd = zeros(numberCritical, 1);
observabilityPbhMinSvd = zeros(numberCritical, 1);
controllabilityPbhTolerances = zeros(numberCritical, 1);
observabilityPbhTolerances = zeros(numberCritical, 1);

for index = 1:numberCritical
    lambda = criticalPoles(index);
    controllabilityPbh = [lambda * eye(n) - A, B];
    observabilityPbh = [lambda * eye(n) - A; C];
    singularControllabilityPbh = svd(controllabilityPbh);
    singularObservabilityPbh = svd(observabilityPbh);
    toleranceControllabilityPbh = localSvdTolerance( ...
        controllabilityPbh, singularControllabilityPbh);
    toleranceObservabilityPbh = localSvdTolerance( ...
        observabilityPbh, singularObservabilityPbh);

    controllabilityPbhRanks(index) = sum( ...
        singularControllabilityPbh > toleranceControllabilityPbh);
    observabilityPbhRanks(index) = sum( ...
        singularObservabilityPbh > toleranceObservabilityPbh);
    controllabilityPbhMinSvd(index) = singularControllabilityPbh(end);
    observabilityPbhMinSvd(index) = singularObservabilityPbh(end);
    controllabilityPbhTolerances(index) = toleranceControllabilityPbh;
    observabilityPbhTolerances(index) = toleranceObservabilityPbh;
end

metrics.poles = poles;
metrics.stabilityTolerance = stabilityTolerance;
metrics.numberStable = sum(stableMask);
metrics.numberUnstable = sum(unstableMask);
metrics.numberMarginal = sum(marginalMask);
metrics.maximumRealPart = max(real(poles));
metrics.criticalPoles = criticalPoles;

metrics.controllability.matrix = controllabilityMatrix;
metrics.controllability.singularValues = controllabilitySvd;
metrics.controllability.tolerance = controllabilityTolerance;
metrics.controllability.rank = sum( ...
    controllabilitySvd > controllabilityTolerance);
metrics.controllability.conditionNumber = localCondition(controllabilitySvd);
metrics.controllability.pbhRanks = controllabilityPbhRanks;
metrics.controllability.pbhMinimumSingularValues = controllabilityPbhMinSvd;
metrics.controllability.pbhTolerances = controllabilityPbhTolerances;
metrics.controllability.stabilizable = ...
    all(controllabilityPbhRanks == n);

metrics.observability.matrix = observabilityMatrix;
metrics.observability.singularValues = observabilitySvd;
metrics.observability.tolerance = observabilityTolerance;
metrics.observability.rank = sum(observabilitySvd > observabilityTolerance);
metrics.observability.conditionNumber = localCondition(observabilitySvd);
metrics.observability.pbhRanks = observabilityPbhRanks;
metrics.observability.pbhMinimumSingularValues = observabilityPbhMinSvd;
metrics.observability.pbhTolerances = observabilityPbhTolerances;
metrics.observability.detectable = all(observabilityPbhRanks == n);
end

function tolerance = localSvdTolerance(matrix, singularValues)
if isempty(singularValues) || singularValues(1) == 0
    tolerance = 0;
else
    tolerance = max(size(matrix)) * eps(singularValues(1));
end
end

function conditionNumber = localCondition(singularValues)
if isempty(singularValues) || singularValues(end) == 0
    conditionNumber = inf;
else
    conditionNumber = singularValues(1) / singularValues(end);
end
end
