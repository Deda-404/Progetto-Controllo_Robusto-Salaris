function fit = fit_actuator_uncertainty_weight(family, uncertainty)
%FIT_ACTUATOR_UNCERTAINTY_WEIGHT Minimum-order input-multiplicative cover.

orders = (1:4).';
numberOrders = numel(orders);
stable = false(numberOrders, 1);
proper = false(numberOrders, 1);
worstRatio = inf(numberOrders, 1);
minimumMargin = -inf(numberOrders, 1);
criticalFrequency = nan(numberOrders, 1);
criticalSample = strings(numberOrders, 1);
candidateWeights = cell(numberOrders, 1);
candidateInfo = cell(numberOrders, 1);

for index = 1:numberOrders
    [~, coverInfo] = ucover(family.models, family.nominalPadeFrd, ...
        orders(index), [], 'InputMult');
    candidateWeight = uncertainty.weightSafetyFactor * coverInfo.W1;
    weightMagnitude = squeeze(abs(freqresp( ...
        candidateWeight, family.frequencies))).';
    ratioMatrix = abs(family.multiplicativeErrors) ./ weightMagnitude;
    marginMatrix = weightMagnitude - abs(family.multiplicativeErrors);
    [worstRatio(index), worstLinearIndex] = max(ratioMatrix(:));
    [worstSampleIndex, worstFrequencyIndex] = ind2sub( ...
        size(ratioMatrix), worstLinearIndex);
    minimumMargin(index) = min(marginMatrix(:));
    criticalFrequency(index) = family.frequencies(worstFrequencyIndex);
    criticalSample(index) = family.metadata.SampleId(worstSampleIndex);
    stable(index) = isstable(candidateWeight);
    proper(index) = isproper(candidateWeight);
    candidateWeights{index} = candidateWeight;
    candidateInfo{index} = coverInfo;
end

coverageTolerance = 1e-9;
acceptable = stable & proper & worstRatio <= 1 + coverageTolerance & ...
    minimumMargin >= -coverageTolerance;
selectedIndex = find(acceptable, 1, 'first');
assert(~isempty(selectedIndex), 'M4Weight:NoCover', ...
    'No tested WI order provides a stable proper cover.');

WI = candidateWeights{selectedIndex};
weightMagnitude = squeeze(abs(freqresp(WI, family.frequencies))).';
ratioMatrix = abs(family.multiplicativeErrors) ./ weightMagnitude;
marginMatrix = weightMagnitude - abs(family.multiplicativeErrors);
[selectedWorstRatio, selectedWorstLinearIndex] = max(ratioMatrix(:));
[selectedCriticalSampleIndex, selectedCriticalFrequencyIndex] = ind2sub( ...
    size(ratioMatrix), selectedWorstLinearIndex);

fitCandidateTable = table(orders, stable, proper, worstRatio, ...
    minimumMargin, criticalFrequency, criticalSample, acceptable, ...
    'VariableNames', {'Order', 'Stable', 'Proper', 'WorstRatio', ...
    'MinimumMargin', 'CriticalFrequency', 'CriticalSample', 'Acceptable'});

fit.WI = WI;
fit.selectedOrder = orders(selectedIndex);
fit.fitCandidateTable = fitCandidateTable;
fit.weightMagnitude = weightMagnitude;
fit.worstRatio = selectedWorstRatio;
fit.minimumCoverageMargin = min(marginMatrix(:));
fit.criticalFrequency = ...
    family.frequencies(selectedCriticalFrequencyIndex);
fit.criticalSampleIndex = selectedCriticalSampleIndex;
fit.criticalSample = ...
    family.metadata.SampleId(selectedCriticalSampleIndex);
fit.criticalSampleParameters = ...
    family.metadata(selectedCriticalSampleIndex, :);
fit.coverageTolerance = coverageTolerance;
fit.safetyFactor = uncertainty.weightSafetyFactor;
fit.poles = pole(WI);
fit.zeros = zero(WI);
fit.stable = isstable(WI);
fit.proper = isproper(WI);
fit.coverInfo = candidateInfo{selectedIndex};
fit.convention = ...
    "Ga_var = Ga_nom * (1 + WI * Delta), ||Delta||_inf <= 1";
end
