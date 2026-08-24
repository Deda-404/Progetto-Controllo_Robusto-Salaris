function metrics = analyze_m3_structure(A, B, C, stabilityTolerance)
%ANALYZE_M3_STRUCTURE SVD and PBH diagnostics for the full M3 model.

metrics = analyze_m2_structure(A, B, C, stabilityTolerance);
poles = metrics.poles;
n = size(A, 1);
numberPoles = numel(poles);
controllabilityRanks = zeros(numberPoles, 1);
observabilityRanks = zeros(numberPoles, 1);
controllabilityMinSvd = zeros(numberPoles, 1);
observabilityMinSvd = zeros(numberPoles, 1);
controllabilityTolerances = zeros(numberPoles, 1);
observabilityTolerances = zeros(numberPoles, 1);

for index = 1:numberPoles
    lambda = poles(index);
    controllabilityPbh = [lambda * eye(n) - A, B];
    observabilityPbh = [lambda * eye(n) - A; C];
    singularControllability = svd(controllabilityPbh);
    singularObservability = svd(observabilityPbh);
    toleranceControllability = max(size(controllabilityPbh)) * ...
        eps(singularControllability(1));
    toleranceObservability = max(size(observabilityPbh)) * ...
        eps(singularObservability(1));

    controllabilityRanks(index) = sum( ...
        singularControllability > toleranceControllability);
    observabilityRanks(index) = sum( ...
        singularObservability > toleranceObservability);
    controllabilityMinSvd(index) = singularControllability(end);
    observabilityMinSvd(index) = singularObservability(end);
    controllabilityTolerances(index) = toleranceControllability;
    observabilityTolerances(index) = toleranceObservability;
end

metrics.controllability.allModePbhRanks = controllabilityRanks;
metrics.controllability.allModePbhMinimumSingularValues = controllabilityMinSvd;
metrics.controllability.allModePbhTolerances = controllabilityTolerances;
metrics.controllability.controllablePbh = all(controllabilityRanks == n);
metrics.observability.allModePbhRanks = observabilityRanks;
metrics.observability.allModePbhMinimumSingularValues = observabilityMinSvd;
metrics.observability.allModePbhTolerances = observabilityTolerances;
metrics.observability.observablePbh = all(observabilityRanks == n);

frequencyScale = max(abs(poles));
normalizedA = A / frequencyScale;
normalizedB = B / frequencyScale;
scaledControllabilityMatrix = ctrb(normalizedA, normalizedB);
scaledObservabilityMatrix = obsv(normalizedA, C);
scaledControllabilitySvd = svd(scaledControllabilityMatrix);
scaledObservabilitySvd = svd(scaledObservabilityMatrix);
scaledControllabilityTolerance = max(size(scaledControllabilityMatrix)) * ...
    eps(scaledControllabilitySvd(1));
scaledObservabilityTolerance = max(size(scaledObservabilityMatrix)) * ...
    eps(scaledObservabilitySvd(1));

metrics.scaledTime.frequencyScale = frequencyScale;
metrics.scaledTime.controllability.rank = sum( ...
    scaledControllabilitySvd > scaledControllabilityTolerance);
metrics.scaledTime.controllability.tolerance = ...
    scaledControllabilityTolerance;
metrics.scaledTime.controllability.singularValues = ...
    scaledControllabilitySvd;
metrics.scaledTime.controllability.conditionNumber = ...
    scaledControllabilitySvd(1) / scaledControllabilitySvd(end);
metrics.scaledTime.observability.rank = sum( ...
    scaledObservabilitySvd > scaledObservabilityTolerance);
metrics.scaledTime.observability.tolerance = scaledObservabilityTolerance;
metrics.scaledTime.observability.singularValues = scaledObservabilitySvd;
metrics.scaledTime.observability.conditionNumber = ...
    scaledObservabilitySvd(1) / scaledObservabilitySvd(end);
end
