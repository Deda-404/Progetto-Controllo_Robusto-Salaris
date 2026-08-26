function summary = summarize_m16_monte_carlo( ...
    stabilityTable, bandwidthTable, trackingTable, disturbanceTable, ...
    spec, config)
%SUMMARIZE_M16_MONTE_CARLO Statistics, pass rates and paired differences.

arguments
    stabilityTable table
    bandwidthTable table
    trackingTable table
    disturbanceTable table
    spec (1, 1) struct
    config (1, 1) struct = monte_carlo_specs_m16
end

sampleSummary = localBuildSampleSummary(stabilityTable, bandwidthTable, ...
    trackingTable, disturbanceTable, spec, config);
statistics = localStatistics(sampleSummary, config);
stabilitySummary = localStabilitySummary(sampleSummary, config);
passRates = localPassRates(sampleSummary, config);
pairedComparisons = localPairedComparisons(sampleSummary, config);
sampleLevelTable = localBuildLongTable(stabilityTable, bandwidthTable, ...
    trackingTable, disturbanceTable);

summary = struct( ...
    'sampleControllerSummaryTable', sampleSummary, ...
    'sampleLevelTable', sampleLevelTable, ...
    'statisticsTable', statistics, ...
    'stabilitySummaryTable', stabilitySummary, ...
    'empiricalPassRatesTable', passRates, ...
    'pairedComparisonTable', pairedComparisons, ...
    'summaryUsesStableSamplesOnly', true, ...
    'sampleZeroExcluded', all(sampleSummary.Sample >= 1), ...
    'globalScoreCreated', false);
end

function output = localBuildSampleSummary(stability, bandwidths, ...
    tracking, disturbance, spec, config)
numberRows = height(stability);
Sample = stability.Sample;
Controller = stability.Controller;
Stable = stability.Stable;
PerformanceEligible = stability.Stable;
MaxRealPole = stability.MaxRealPole;
InternalStateCount = stability.InternalStateCount;
NumberRhpPoles = stability.NumberRhpPoles;
Classification = stability.Classification;
BandwidthJ1 = nan(numberRows, 1);
BandwidthJ2 = nan(numberRows, 1);
WorstTrackingTs = nan(numberRows, 1);
WorstTrackingOS = nan(numberRows, 1);
WorstTrackingSteadyError = nan(numberRows, 1);
WorstTrackingCrossCoupling = nan(numberRows, 1);
WorstTrackingPeakU = nan(numberRows, 1);
WorstTrackingPeakUNormalized = nan(numberRows, 1);
WorstDisturbancePeakQ = nan(numberRows, 1);
WorstDisturbanceAbsOffset = nan(numberRows, 1);
WorstDisturbanceCrossCoupling = nan(numberRows, 1);
WorstDisturbancePeakU = nan(numberRows, 1);
WorstDisturbancePeakUNormalized = nan(numberRows, 1);
SettlingPass = false(numberRows, 1);
OvershootPass = false(numberRows, 1);
SteadyErrorPass = false(numberRows, 1);
CrossCouplingPass = false(numberRows, 1);
AllCoreTrackingPass = false(numberRows, 1);
AllTrackingIncludingCrossPass = false(numberRows, 1);

for row = 1:numberRows
    selectorBandwidth = bandwidths.Sample == Sample(row) & ...
        bandwidths.Controller == Controller(row);
    BandwidthJ1(row) = bandwidths.BandwidthJ1(selectorBandwidth);
    BandwidthJ2(row) = bandwidths.BandwidthJ2(selectorBandwidth);
    if Stable(row)
        selectorTracking = tracking.Sample == Sample(row) & ...
            tracking.Controller == Controller(row);
        selectorDisturbance = disturbance.Sample == Sample(row) & ...
            disturbance.Controller == Controller(row);
        currentTracking = tracking(selectorTracking, :);
        currentDisturbance = disturbance(selectorDisturbance, :);
        WorstTrackingTs(row) = max(currentTracking.TrackingTs);
        WorstTrackingOS(row) = max(currentTracking.TrackingOS);
        WorstTrackingSteadyError(row) = ...
            max(currentTracking.TrackingSteadyErrorRelative);
        WorstTrackingCrossCoupling(row) = ...
            max(currentTracking.TrackingCrossCoupling);
        WorstTrackingPeakU(row) = max(currentTracking.TrackingPeakU);
        WorstTrackingPeakUNormalized(row) = ...
            max(currentTracking.TrackingPeakUNormalized);
        WorstDisturbancePeakQ(row) = ...
            max(currentDisturbance.DisturbancePeakQ);
        WorstDisturbanceAbsOffset(row) = ...
            max(currentDisturbance.DisturbanceAbsOffset);
        WorstDisturbanceCrossCoupling(row) = ...
            max(currentDisturbance.DisturbanceCrossCoupling);
        WorstDisturbancePeakU(row) = ...
            max(currentDisturbance.DisturbancePeakU);
        WorstDisturbancePeakUNormalized(row) = ...
            max(currentDisturbance.DisturbancePeakUNormalized);
        SettlingPass(row) = WorstTrackingTs(row) <= ...
            spec.settlingTimeTarget;
        OvershootPass(row) = WorstTrackingOS(row) <= spec.overshootTarget;
        SteadyErrorPass(row) = WorstTrackingSteadyError(row) <= ...
            spec.steadyStateTrackingTarget;
        CrossCouplingPass(row) = WorstTrackingCrossCoupling(row) <= ...
            spec.crossCouplingTarget;
        AllCoreTrackingPass(row) = SettlingPass(row) && ...
            OvershootPass(row) && SteadyErrorPass(row);
        AllTrackingIncludingCrossPass(row) = ...
            AllCoreTrackingPass(row) && CrossCouplingPass(row);
    end
end

output = table(Sample, Controller, Stable, PerformanceEligible, ...
    Classification, InternalStateCount, NumberRhpPoles, MaxRealPole, ...
    BandwidthJ1, BandwidthJ2, WorstTrackingTs, WorstTrackingOS, ...
    WorstTrackingSteadyError, WorstTrackingCrossCoupling, ...
    WorstTrackingPeakU, WorstTrackingPeakUNormalized, ...
    WorstDisturbancePeakQ, WorstDisturbanceAbsOffset, ...
    WorstDisturbanceCrossCoupling, WorstDisturbancePeakU, ...
    WorstDisturbancePeakUNormalized, SettlingPass, OvershootPass, ...
    SteadyErrorPass, CrossCouplingPass, AllCoreTrackingPass, ...
    AllTrackingIncludingCrossPass);
assert(height(output) == config.numberSamples * ...
    numel(config.controllerIDs), 'M16:SampleSummarySize', ...
    'The sample/controller summary has an unexpected row count.');
end

function statistics = localStatistics(sampleSummary, config)
metricNames = [ ...
    "MaxRealPole"; "BandwidthJ1"; "BandwidthJ2"; ...
    "WorstTrackingTs"; "WorstTrackingOS"; ...
    "WorstTrackingSteadyError"; "WorstTrackingCrossCoupling"; ...
    "WorstTrackingPeakU"; "WorstDisturbancePeakQ"; ...
    "WorstDisturbanceAbsOffset"; ...
    "WorstDisturbanceCrossCoupling"; "WorstDisturbancePeakU"];
numberRows = numel(config.controllerIDs) * numel(metricNames);
Controller = strings(numberRows, 1);
Metric = strings(numberRows, 1);
Count = zeros(numberRows, 1);
Minimum = nan(numberRows, 1);
Percentile05 = nan(numberRows, 1);
Median = nan(numberRows, 1);
Mean = nan(numberRows, 1);
Percentile95 = nan(numberRows, 1);
Maximum = nan(numberRows, 1);
row = 0;
for controllerIndex = 1:numel(config.controllerIDs)
    controllerID = config.controllerIDs(controllerIndex);
    stableRows = sampleSummary.Controller == controllerID & ...
        sampleSummary.Stable;
    for metricIndex = 1:numel(metricNames)
        row = row + 1;
        values = sampleSummary.(metricNames(metricIndex))(stableRows);
        values = values(~isnan(values));
        Controller(row) = controllerID;
        Metric(row) = metricNames(metricIndex);
        Count(row) = numel(values);
        if ~isempty(values)
            Minimum(row) = min(values);
            Percentile05(row) = localPercentile(values, 5);
            Median(row) = median(values);
            Mean(row) = mean(values);
            Percentile95(row) = localPercentile(values, 95);
            Maximum(row) = max(values);
        end
    end
end
statistics = table(Controller, Metric, Count, Minimum, Percentile05, ...
    Median, Mean, Percentile95, Maximum);
end

function output = localStabilitySummary(sampleSummary, config)
numberControllers = numel(config.controllerIDs);
Controller = config.controllerIDs;
NTotal = zeros(numberControllers, 1);
NStable = zeros(numberControllers, 1);
NPerformanceEligible = zeros(numberControllers, 1);
EmpiricalStabilityRate = zeros(numberControllers, 1);
WorstMaxRealPole = nan(numberControllers, 1);
MedianMaxRealPole = nan(numberControllers, 1);
Percentile05MaxRealPole = nan(numberControllers, 1);
Percentile95MaxRealPole = nan(numberControllers, 1);
for index = 1:numberControllers
    rows = sampleSummary.Controller == Controller(index);
    stableRows = rows & sampleSummary.Stable;
    values = sampleSummary.MaxRealPole(rows);
    values = values(isfinite(values));
    NTotal(index) = sum(rows);
    NStable(index) = sum(stableRows);
    NPerformanceEligible(index) = ...
        sum(rows & sampleSummary.PerformanceEligible);
    EmpiricalStabilityRate(index) = NStable(index) / NTotal(index);
    if ~isempty(values)
        WorstMaxRealPole(index) = max(values);
        MedianMaxRealPole(index) = median(values);
        Percentile05MaxRealPole(index) = localPercentile(values, 5);
        Percentile95MaxRealPole(index) = localPercentile(values, 95);
    end
end
output = table(Controller, NTotal, NStable, NPerformanceEligible, ...
    EmpiricalStabilityRate, WorstMaxRealPole, MedianMaxRealPole, ...
    Percentile05MaxRealPole, Percentile95MaxRealPole);
end

function output = localPassRates(sampleSummary, config)
numberControllers = numel(config.controllerIDs);
Controller = config.controllerIDs;
NTotal = zeros(numberControllers, 1);
NStable = zeros(numberControllers, 1);
StableFractionTotal = zeros(numberControllers, 1);
SettlingPassFractionTotal = zeros(numberControllers, 1);
SettlingPassFractionStable = nan(numberControllers, 1);
OvershootPassFractionTotal = zeros(numberControllers, 1);
OvershootPassFractionStable = nan(numberControllers, 1);
SteadyErrorPassFractionTotal = zeros(numberControllers, 1);
SteadyErrorPassFractionStable = nan(numberControllers, 1);
CrossCouplingPassFractionTotal = zeros(numberControllers, 1);
CrossCouplingPassFractionStable = nan(numberControllers, 1);
AllCorePassFractionTotal = zeros(numberControllers, 1);
AllCorePassFractionStable = nan(numberControllers, 1);
AllIncludingCrossPassFractionTotal = zeros(numberControllers, 1);
AllIncludingCrossPassFractionStable = nan(numberControllers, 1);
for index = 1:numberControllers
    rows = sampleSummary.Controller == Controller(index);
    stableRows = rows & sampleSummary.Stable;
    NTotal(index) = sum(rows);
    NStable(index) = sum(stableRows);
    StableFractionTotal(index) = NStable(index) / NTotal(index);
    SettlingPassFractionTotal(index) = ...
        sum(rows & sampleSummary.SettlingPass) / NTotal(index);
    OvershootPassFractionTotal(index) = ...
        sum(rows & sampleSummary.OvershootPass) / NTotal(index);
    SteadyErrorPassFractionTotal(index) = ...
        sum(rows & sampleSummary.SteadyErrorPass) / NTotal(index);
    CrossCouplingPassFractionTotal(index) = ...
        sum(rows & sampleSummary.CrossCouplingPass) / NTotal(index);
    AllCorePassFractionTotal(index) = ...
        sum(rows & sampleSummary.AllCoreTrackingPass) / NTotal(index);
    AllIncludingCrossPassFractionTotal(index) = sum(rows & ...
        sampleSummary.AllTrackingIncludingCrossPass) / NTotal(index);
    if NStable(index) > 0
        SettlingPassFractionStable(index) = ...
            sum(stableRows & sampleSummary.SettlingPass) / NStable(index);
        OvershootPassFractionStable(index) = ...
            sum(stableRows & sampleSummary.OvershootPass) / NStable(index);
        SteadyErrorPassFractionStable(index) = ...
            sum(stableRows & sampleSummary.SteadyErrorPass) / NStable(index);
        CrossCouplingPassFractionStable(index) = sum(stableRows & ...
            sampleSummary.CrossCouplingPass) / NStable(index);
        AllCorePassFractionStable(index) = sum(stableRows & ...
            sampleSummary.AllCoreTrackingPass) / NStable(index);
        AllIncludingCrossPassFractionStable(index) = sum(stableRows & ...
            sampleSummary.AllTrackingIncludingCrossPass) / NStable(index);
    end
end
output = table(Controller, NTotal, NStable, StableFractionTotal, ...
    SettlingPassFractionTotal, SettlingPassFractionStable, ...
    OvershootPassFractionTotal, OvershootPassFractionStable, ...
    SteadyErrorPassFractionTotal, SteadyErrorPassFractionStable, ...
    CrossCouplingPassFractionTotal, CrossCouplingPassFractionStable, ...
    AllCorePassFractionTotal, AllCorePassFractionStable, ...
    AllIncludingCrossPassFractionTotal, ...
    AllIncludingCrossPassFractionStable);
end

function output = localPairedComparisons(sampleSummary, config)
pairs = ["Kmu", "Khinf"; "Kmu", "M6"; "Khinf", "M6"];
metrics = ["MaxRealPole"; "WorstTrackingTs"; ...
    "WorstTrackingSteadyError"; "WorstTrackingCrossCoupling"; ...
    "WorstTrackingPeakU"; "WorstDisturbancePeakQ"];
numberRows = size(pairs, 1) * numel(metrics);
Pair = strings(numberRows, 1);
ControllerA = strings(numberRows, 1);
ControllerB = strings(numberRows, 1);
Metric = strings(numberRows, 1);
CommonStableCount = zeros(numberRows, 1);
ComparableCount = zeros(numberRows, 1);
MedianDifferenceAminusB = nan(numberRows, 1);
MinimumDifferenceAminusB = nan(numberRows, 1);
MaximumDifferenceAminusB = nan(numberRows, 1);
ABetterCount = zeros(numberRows, 1);
BBetterCount = zeros(numberRows, 1);
TieCount = zeros(numberRows, 1);
row = 0;
for pairIndex = 1:size(pairs, 1)
    first = sampleSummary(sampleSummary.Controller == pairs(pairIndex, 1), :);
    second = sampleSummary(sampleSummary.Controller == pairs(pairIndex, 2), :);
    [~, firstOrder] = sort(first.Sample);
    [~, secondOrder] = sort(second.Sample);
    first = first(firstOrder, :);
    second = second(secondOrder, :);
    commonStable = first.Stable & second.Stable;
    for metricIndex = 1:numel(metrics)
        row = row + 1;
        firstValues = first.(metrics(metricIndex))(commonStable);
        secondValues = second.(metrics(metricIndex))(commonStable);
        comparable = ~isnan(firstValues) & ~isnan(secondValues);
        bothPositiveInf = isinf(firstValues) & firstValues > 0 & ...
            isinf(secondValues) & secondValues > 0;
        difference = firstValues(comparable) - secondValues(comparable);
        difference(bothPositiveInf(comparable)) = 0;
        Pair(row) = pairs(pairIndex, 1) + " - " + pairs(pairIndex, 2);
        ControllerA(row) = pairs(pairIndex, 1);
        ControllerB(row) = pairs(pairIndex, 2);
        Metric(row) = metrics(metricIndex);
        CommonStableCount(row) = sum(commonStable);
        ComparableCount(row) = numel(difference);
        if ~isempty(difference)
            MedianDifferenceAminusB(row) = median(difference);
            MinimumDifferenceAminusB(row) = min(difference);
            MaximumDifferenceAminusB(row) = max(difference);
            ABetterCount(row) = sum(difference < -config.pairedTieTolerance);
            BBetterCount(row) = sum(difference > config.pairedTieTolerance);
            TieCount(row) = sum(abs(difference) <= ...
                config.pairedTieTolerance);
        end
    end
end
output = table(Pair, ControllerA, ControllerB, Metric, ...
    CommonStableCount, ComparableCount, MedianDifferenceAminusB, ...
    MinimumDifferenceAminusB, MaximumDifferenceAminusB, ...
    ABetterCount, BBetterCount, TieCount);
end

function output = localBuildLongTable(stability, bandwidths, tracking, ...
    disturbance)
tracking = sortrows(tracking, {'Sample', 'Controller', 'TrackingJoint'});
disturbance = sortrows(disturbance, ...
    {'Sample', 'Controller', 'DisturbanceJoint'});
assert(isequal(tracking.Sample, disturbance.Sample) && ...
    isequal(tracking.Controller, disturbance.Controller), ...
    'M16:LongTablePairing', ...
    'Tracking and disturbance records cannot be paired by sample.');
numberRows = height(tracking);
Stable = tracking.Stable;
MaxRealPole = nan(numberRows, 1);
BandwidthJ1 = nan(numberRows, 1);
BandwidthJ2 = nan(numberRows, 1);
for row = 1:numberRows
    stabilityRow = stability.Sample == tracking.Sample(row) & ...
        stability.Controller == tracking.Controller(row);
    bandwidthRow = bandwidths.Sample == tracking.Sample(row) & ...
        bandwidths.Controller == tracking.Controller(row);
    MaxRealPole(row) = stability.MaxRealPole(stabilityRow);
    BandwidthJ1(row) = bandwidths.BandwidthJ1(bandwidthRow);
    BandwidthJ2(row) = bandwidths.BandwidthJ2(bandwidthRow);
end
output = table(tracking.Sample, tracking.Controller, Stable, ...
    MaxRealPole, BandwidthJ1, BandwidthJ2, tracking.TrackingJoint, ...
    tracking.TrackingTs, tracking.TrackingOS, ...
    tracking.TrackingSteadyErrorAbs, ...
    tracking.TrackingSteadyErrorRelative, ...
    tracking.TrackingCrossCoupling, tracking.TrackingPeakU, ...
    tracking.TrackingPeakUNormalized, disturbance.DisturbanceJoint, ...
    disturbance.DisturbancePeakQ, disturbance.DisturbanceOffset, ...
    disturbance.DisturbanceSettlingTime, ...
    disturbance.DisturbanceCrossCoupling, ...
    disturbance.DisturbancePeakU, ...
    disturbance.DisturbancePeakUNormalized, ...
    'VariableNames', {'Sample', 'Controller', 'Stable', ...
    'MaxRealPole', 'BandwidthJ1', 'BandwidthJ2', 'TrackingJoint', ...
    'TrackingTs', 'TrackingOS', 'TrackingSteadyErrorAbs', ...
    'TrackingSteadyErrorRelative', 'TrackingCrossCoupling', ...
    'TrackingPeakU', 'TrackingPeakUNormalized', 'DisturbanceJoint', ...
    'DisturbancePeakQ', 'DisturbanceOffset', ...
    'DisturbanceSettlingTime', 'DisturbanceCrossCoupling', ...
    'DisturbancePeakU', 'DisturbancePeakUNormalized'});
end

function percentile = localPercentile(values, probabilityPercent)
values = sort(values(:));
if isscalar(values)
    percentile = values;
    return
end
position = 1 + (numel(values) - 1) * probabilityPercent / 100;
lowerIndex = floor(position);
upperIndex = ceil(position);
fraction = position - lowerIndex;
if lowerIndex == upperIndex || fraction == 0
    percentile = values(lowerIndex);
    return
end
if isinf(values(upperIndex)) && values(upperIndex) > 0
    percentile = Inf;
    return
end
percentile = values(lowerIndex) + fraction * ...
    (values(upperIndex) - values(lowerIndex));
end
