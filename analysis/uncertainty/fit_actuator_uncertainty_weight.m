function fit = fit_actuator_uncertainty_weight(family, uncertainty)
%FIT_ACTUATOR_UNCERTAINTY_WEIGHT Verify a first-order multiplicative cover.
%   A first-order weight is chosen a priori because the actuator family has
%   one low-frequency-to-high-frequency transition. UCOVER identifies its
%   coefficients; MATLAB then verifies that it covers every declared sample.

chosenOrder = 1;
[~, coverInfo] = ucover(family.models, family.nominalPadeFrd, ...
    chosenOrder, [], 'InputMult');
WI = uncertainty.weightSafetyFactor * coverInfo.W1;

weightMagnitude = squeeze(abs(freqresp(WI, family.frequencies))).';
errorMagnitude = abs(family.multiplicativeErrors);
ratioMatrix = errorMagnitude ./ weightMagnitude;
marginMatrix = weightMagnitude - errorMagnitude;
[worstRatio, linearIndex] = max(ratioMatrix(:));
[criticalSampleIndex, criticalFrequencyIndex] = ind2sub( ...
    size(ratioMatrix), linearIndex);
coverageTolerance = 1e-9;

assert(isstable(WI) && isproper(WI), 'M4Weight:InvalidWeight', ...
    'The declared first-order WI must be stable and proper.');
assert(worstRatio <= 1 + coverageTolerance && ...
    min(marginMatrix(:)) >= -coverageTolerance, 'M4Weight:NoCover', ...
    'The declared first-order WI does not cover the actuator family.');

fit.WI = WI;
fit.selectedOrder = chosenOrder;
fit.weightMagnitude = weightMagnitude;
fit.worstRatio = worstRatio;
fit.minimumCoverageMargin = min(marginMatrix(:));
fit.criticalFrequency = family.frequencies(criticalFrequencyIndex);
fit.criticalSampleIndex = criticalSampleIndex;
fit.criticalSample = family.metadata.SampleId(criticalSampleIndex);
fit.criticalSampleParameters = family.metadata(criticalSampleIndex, :);
fit.coverageTolerance = coverageTolerance;
fit.safetyFactor = uncertainty.weightSafetyFactor;
fit.poles = pole(WI);
fit.zeros = zero(WI);
fit.stable = isstable(WI);
fit.proper = isproper(WI);
fit.coverInfo = coverInfo;
fit.designChoice = ...
    "first order chosen from the single-transition shape; coverage verified";
fit.convention = ...
    "Ga_var = Ga_nom * (1 + WI * Delta), ||Delta||_inf <= 1";
end
