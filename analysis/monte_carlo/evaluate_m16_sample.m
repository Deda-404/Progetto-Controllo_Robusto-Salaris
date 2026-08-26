function evaluation = evaluate_m16_sample(closedLoop, sampleID, spec, config)
%EVALUATE_M16_SAMPLE Linear tracking/disturbance metrics for one sample.

arguments
    closedLoop (1, 1) struct
    sampleID (1, 1) double
    spec (1, 1) struct
    config (1, 1) struct = monte_carlo_specs_m16
end

evaluation.sampleID = sampleID;
evaluation.controllerID = closedLoop.controllerID;
evaluation.performanceEligible = closedLoop.stable;
evaluation.bandwidth = localBandwidth(closedLoop, sampleID);
if closedLoop.stable
    evaluation.tracking = localTracking(closedLoop, sampleID, spec, config);
    evaluation.disturbance = localDisturbance( ...
        closedLoop, sampleID, spec, config);
else
    evaluation.tracking = localEmptyTracking( ...
        sampleID, closedLoop.controllerID, config);
    evaluation.disturbance = localEmptyDisturbance( ...
        sampleID, closedLoop.controllerID, config);
end
end

function bandwidthTable = localBandwidth(closedLoop, sampleID)
BandwidthJ1 = NaN;
BandwidthJ2 = NaN;
BandwidthReasonJ1 = "NOT_ELIGIBLE_UNSTABLE";
BandwidthReasonJ2 = "NOT_ELIGIBLE_UNSTABLE";
if closedLoop.stable
    [BandwidthJ1, BandwidthReasonJ1] = ...
        localSisoBandwidth(closedLoop.trackingQ(1, 1));
    [BandwidthJ2, BandwidthReasonJ2] = ...
        localSisoBandwidth(closedLoop.trackingQ(2, 2));
end
Sample = sampleID;
Controller = closedLoop.controllerID;
Stable = closedLoop.stable;
bandwidthTable = table(Sample, Controller, Stable, BandwidthJ1, ...
    BandwidthJ2, BandwidthReasonJ1, BandwidthReasonJ2);
end

function [value, reason] = localSisoBandwidth(system)
value = NaN;
try
    candidate = bandwidth(system);
    if isscalar(candidate) && isfinite(candidate) && candidate >= 0
        value = candidate;
        reason = "OK";
    else
        reason = "NONFINITE_OR_NONSCALAR";
    end
catch bandwidthError
    reason = "ERROR:" + string(bandwidthError.identifier);
end
end

function metrics = localTracking(closedLoop, sampleID, spec, config)
time = (0:config.timeStep:config.trackingHorizon).';
amplitude = deg2rad(config.trackingAmplitudeDeg);
dcGainQ = dcgain(closedLoop.trackingQ);
rows = nan(2, 11);
for jointIndex = 1:2
    input = zeros(numel(time), 2);
    input(:, jointIndex) = amplitude;
    output = lsim(closedLoop.trackingMap, input, time);
    q = output(:, 1:2);
    u = output(:, 3:4);
    finalVector = dcGainQ(:, jointIndex) * amplitude;
    finalValue = finalVector(jointIndex);
    settling = localSettlingTime(q(:, jointIndex), finalValue, time, ...
        config.settlingBandFraction * abs(amplitude));
    overshoot = 100 * max(0, ...
        (max(q(:, jointIndex)) - amplitude) / abs(amplitude));
    steadyAbsolute = abs(finalValue - amplitude);
    steadyRelative = steadyAbsolute / abs(amplitude);
    otherJoint = 3 - jointIndex;
    crossCoupling = max(abs(q(:, otherJoint))) / ...
        max(max(abs(q(:, jointIndex))), eps);
    peakControl = max(abs(u), [], 'all');
    rows(jointIndex, :) = [sampleID, jointIndex, settling, overshoot, ...
        steadyAbsolute, steadyRelative, crossCoupling, peakControl, ...
        peakControl / spec.uScale, amplitude, config.trackingAmplitudeDeg];
end
Controller = repmat(closedLoop.controllerID, 2, 1);
Stable = true(2, 1);
PerformanceEligible = true(2, 1);
metrics = [table(Controller, Stable, PerformanceEligible), ...
    array2table(rows, 'VariableNames', {'Sample', 'TrackingJoint', ...
    'TrackingTs', 'TrackingOS', 'TrackingSteadyErrorAbs', ...
    'TrackingSteadyErrorRelative', 'TrackingCrossCoupling', ...
    'TrackingPeakU', 'TrackingPeakUNormalized', ...
    'TrackingAmplitudeRad', 'TrackingAmplitudeDeg'})];
end

function metrics = localDisturbance(closedLoop, sampleID, spec, config)
time = (0:config.timeStep:config.disturbanceHorizon).';
amplitude = config.disturbanceAmplitudeNm;
dcGainQ = dcgain(closedLoop.disturbanceQ);
rows = nan(2, 10);
for jointIndex = 1:2
    input = zeros(numel(time), 2);
    input(:, jointIndex) = amplitude;
    output = lsim(closedLoop.disturbanceMap, input, time);
    q = output(:, 1:2);
    u = output(:, 3:4);
    finalVector = dcGainQ(:, jointIndex) * amplitude;
    finalValue = finalVector(jointIndex);
    affectedPeak = max(abs(q(:, jointIndex)));
    threshold = config.settlingBandFraction * ...
        max([affectedPeak, abs(finalValue), eps]);
    settling = localSettlingTime(q(:, jointIndex), finalValue, time, ...
        threshold);
    otherJoint = 3 - jointIndex;
    crossCoupling = max(abs(q(:, otherJoint))) / max(affectedPeak, eps);
    peakControl = max(abs(u), [], 'all');
    rows(jointIndex, :) = [sampleID, jointIndex, affectedPeak, ...
        finalValue, settling, crossCoupling, peakControl, ...
        peakControl / spec.uScale, amplitude, abs(finalValue)];
end
Controller = repmat(closedLoop.controllerID, 2, 1);
Stable = true(2, 1);
PerformanceEligible = true(2, 1);
metrics = [table(Controller, Stable, PerformanceEligible), ...
    array2table(rows, 'VariableNames', {'Sample', 'DisturbanceJoint', ...
    'DisturbancePeakQ', 'DisturbanceOffset', ...
    'DisturbanceSettlingTime', 'DisturbanceCrossCoupling', ...
    'DisturbancePeakU', 'DisturbancePeakUNormalized', ...
    'DisturbanceAmplitudeNm', 'DisturbanceAbsOffset'})];
end

function metrics = localEmptyTracking(sampleID, controllerID, config)
Controller = repmat(controllerID, 2, 1);
Stable = false(2, 1);
PerformanceEligible = false(2, 1);
Sample = repmat(sampleID, 2, 1);
TrackingJoint = (1:2).';
nanColumn = nan(2, 1);
TrackingAmplitudeRad = repmat(deg2rad(config.trackingAmplitudeDeg), 2, 1);
TrackingAmplitudeDeg = repmat(config.trackingAmplitudeDeg, 2, 1);
metrics = table(Controller, Stable, PerformanceEligible, Sample, ...
    TrackingJoint, nanColumn, nanColumn, nanColumn, nanColumn, ...
    nanColumn, nanColumn, nanColumn, TrackingAmplitudeRad, ...
    TrackingAmplitudeDeg, 'VariableNames', {'Controller', 'Stable', ...
    'PerformanceEligible', 'Sample', 'TrackingJoint', 'TrackingTs', ...
    'TrackingOS', 'TrackingSteadyErrorAbs', ...
    'TrackingSteadyErrorRelative', 'TrackingCrossCoupling', ...
    'TrackingPeakU', 'TrackingPeakUNormalized', ...
    'TrackingAmplitudeRad', 'TrackingAmplitudeDeg'});
end

function metrics = localEmptyDisturbance(sampleID, controllerID, config)
Controller = repmat(controllerID, 2, 1);
Stable = false(2, 1);
PerformanceEligible = false(2, 1);
Sample = repmat(sampleID, 2, 1);
DisturbanceJoint = (1:2).';
nanColumn = nan(2, 1);
DisturbanceAmplitudeNm = repmat(config.disturbanceAmplitudeNm, 2, 1);
metrics = table(Controller, Stable, PerformanceEligible, Sample, ...
    DisturbanceJoint, nanColumn, nanColumn, nanColumn, nanColumn, ...
    nanColumn, nanColumn, DisturbanceAmplitudeNm, nanColumn, ...
    'VariableNames', {'Controller', 'Stable', ...
    'PerformanceEligible', 'Sample', 'DisturbanceJoint', ...
    'DisturbancePeakQ', 'DisturbanceOffset', ...
    'DisturbanceSettlingTime', 'DisturbanceCrossCoupling', ...
    'DisturbancePeakU', 'DisturbancePeakUNormalized', ...
    'DisturbanceAmplitudeNm', 'DisturbanceAbsOffset'});
end

function settlingTime = localSettlingTime(signal, finalValue, time, threshold)
outside = abs(signal - finalValue) > max(threshold, 100 * eps);
lastOutside = find(outside, 1, 'last');
if isempty(lastOutside)
    settlingTime = 0;
elseif lastOutside == numel(time)
    settlingTime = inf;
else
    settlingTime = time(lastOutside + 1);
end
end
