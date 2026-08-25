function manualMu = analyze_m12_manual_mu( ...
    M11mu, blockStructure, config)
%ANALYZE_M12_MANUAL_MU Compute fixed-grid robust-stability mu bounds.

arguments
    M11mu {mustBeA(M11mu, {'ss', 'frd'})}
    blockStructure (:, 1) struct
    config (1, 1) struct = mu_analysis_specs_m12
end

omega = config.muFrequencyGrid;
M11frd = frd(M11mu, omega);
muBoundsRS = mussv(M11frd, blockStructure, 's');
upper = squeeze(muBoundsRS.ResponseData(1, 1, :));
lower = squeeze(muBoundsRS.ResponseData(1, 2, :));
[maximumUpper, upperIndex] = max(upper);
[maximumLower, lowerIndex] = max(lower);
assert(all(isfinite(upper)) && all(isfinite(lower)) && ...
    all(upper + config.boundTolerance >= lower) && ...
    maximumUpper > 0 && maximumLower > 0, ...
    'M12Mu:InvalidBounds', ...
    'Manual mussv returned invalid robust-stability bounds.');

manualMu.frequencyGrid = omega;
manualMu.M11frd = M11frd;
manualMu.bounds = muBoundsRS;
manualMu.upperBound = upper;
manualMu.lowerBound = lower;
manualMu.maximumUpperBound = maximumUpper;
manualMu.maximumLowerBound = maximumLower;
manualMu.upperCriticalFrequency = omega(upperIndex);
manualMu.lowerCriticalFrequency = omega(lowerIndex);
manualMu.marginLowerApproximation = 1 / maximumUpper;
manualMu.marginUpperApproximation = 1 / maximumLower;
manualMu.mussvOption = "s";
manualMu.finite = true;
end
