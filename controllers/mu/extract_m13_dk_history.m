function history = extract_m13_dk_history(rawInfo, musynObjective, config)
%EXTRACT_M13_DK_HISTORY Normalize the real R2025b D-K iteration output.

arguments
    rawInfo (1, :) struct
    musynObjective (1, 1) double {mustBeFinite, mustBePositive}
    config (1, 1) struct = mu_synthesis_specs_m13
end

numberIterations = numel(rawInfo);
Iteration = (1:numberIterations).';
PeakMuLower = nan(numberIterations, 1);
PeakMuUpper = nan(numberIterations, 1);
CriticalFrequency = nan(numberIterations, 1);
ScaledHinfGamma = nan(numberIterations, 1);
PeakMuFitLower = nan(numberIterations, 1);
PeakMuFitUpper = nan(numberIterations, 1);
DScaleFitGap = nan(numberIterations, 1);
ControllerOrder = nan(numberIterations, 1);
DScaleOrder = nan(numberIterations, 1);
FitOrderSummary = strings(numberIterations, 1);

for index = 1:numberIterations
    item = rawInfo(index);
    [PeakMuLower(index), PeakMuUpper(index), ...
        CriticalFrequency(index)] = localBound(item.PeakMu);
    ScaledHinfGamma(index) = localScalar(item.gamma);
    [PeakMuFitLower(index), PeakMuFitUpper(index)] = ...
        localBound(item.PeakMuFit);
    if isfinite(PeakMuFitUpper(index)) && isfinite(PeakMuUpper(index))
        DScaleFitGap(index) = abs( ...
            PeakMuFitUpper(index) - PeakMuUpper(index));
    end
    ControllerOrder(index) = order(item.K);
    [DScaleOrder(index), FitOrderSummary(index)] = ...
        localFitOrder(item.FitOrder);
end

historyTable = table(Iteration, PeakMuLower, PeakMuUpper, ...
    CriticalFrequency, ScaledHinfGamma, PeakMuFitLower, ...
    PeakMuFitUpper, DScaleFitGap, ControllerOrder, DScaleOrder, ...
    FitOrderSummary);

formalTerminationStatusAvailable = false;
relativeLastImprovement = NaN;
if numberIterations >= 2 && isfinite(PeakMuUpper(end - 1)) && ...
        isfinite(PeakMuUpper(end)) && PeakMuUpper(end - 1) > 0
    relativeLastImprovement = ...
        (PeakMuUpper(end - 1) - PeakMuUpper(end)) / ...
        PeakMuUpper(end - 1);
end
if numberIterations >= config.maxIterations
    terminationClassification = "MAX_ITER_REACHED";
    terminationReason = ...
        "project interpretation: info length reached frozen MaxIter";
elseif config.targetPerformance > 0 && ...
        musynObjective <= config.targetPerformance
    terminationClassification = "TARGET_REACHED";
    terminationReason = ...
        "project interpretation: frozen TargetPerf was achieved";
elseif isfinite(relativeLastImprovement) && ...
        relativeLastImprovement <= config.performanceTolerance
    terminationClassification = "STALLED";
    terminationReason = ...
        "project interpretation: final relative improvement is within TolPerf";
else
    terminationClassification = "TERMINATED_BY_MUSYN";
    terminationReason = ...
        "MATLAB returned before MaxIter; no formal status field is exposed";
end

history.table = historyTable;
history.iterationCount = numberIterations;
history.finalReportedObjective = musynObjective;
history.finalPeakMuUpper = PeakMuUpper(end);
history.bestPeakMuUpper = min(PeakMuUpper, [], 'omitnan');
history.bestIteration = localBestIteration(PeakMuUpper);
history.relativeLastImprovement = relativeLastImprovement;
history.terminationClassification = terminationClassification;
history.terminationReason = terminationReason;
history.formalTerminationStatusAvailable = ...
    formalTerminationStatusAvailable;
history.availableInfoFields = string(fieldnames(rawInfo));
history.DScalesSavedInRawInfo = isfield(rawInfo, 'DG');
history.fitOrdersSaved = isfield(rawInfo, 'FitOrder');
history.fitGapDefinition = ...
    "absolute gap between PeakMuFit upper and PeakMu upper";
history.completeUnfilteredHistory = true;
end

function [lower, upper, frequency] = localBound(value)
lower = NaN;
upper = NaN;
frequency = NaN;
if isstruct(value)
    if isfield(value, 'LowerBound'), lower = localScalar(value.LowerBound); end
    if isfield(value, 'UpperBound'), upper = localScalar(value.UpperBound); end
    if isfield(value, 'CriticalFrequency')
        frequency = localScalar(value.CriticalFrequency);
    end
elseif isnumeric(value)
    upper = localScalar(value);
end
end

function value = localScalar(input)
if isempty(input)
    value = NaN;
elseif isnumeric(input)
    finiteValues = input(isfinite(input));
    if isempty(finiteValues)
        value = NaN;
    else
        value = max(finiteValues(:));
    end
else
    value = NaN;
end
end

function [fitOrder, summary] = localFitOrder(value)
if isnumeric(value) && ~isempty(value)
    finiteValues = value(isfinite(value));
    if isempty(finiteValues)
        fitOrder = NaN;
    else
        fitOrder = max(finiteValues(:));
    end
    summary = string(mat2str(value));
else
    fitOrder = NaN;
    summary = "unavailable";
end
end

function index = localBestIteration(values)
[~, index] = min(values, [], 'omitnan');
if isempty(index), index = NaN; end
end
