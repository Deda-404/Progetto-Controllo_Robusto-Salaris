function evaluation = evaluate_m6_closed_loop(A, B, Cq, Ctheta, ...
    BdFull, K, Nr, springStiffness, m5Spec, config, ...
    includeDisturbance)
%EVALUATE_M6_CLOSED_LOOP Evaluate M6 full-state reference/disturbance cases.

arguments
    A double
    B double
    Cq double
    Ctheta double
    BdFull double
    K double
    Nr double
    springStiffness double
    m5Spec (1, 1) struct
    config (1, 1) struct
    includeDisturbance (1, 1) logical = true
end

Acl = A - B * K;
referenceInput = B * Nr;
inputMatrix = [referenceInput, BdFull];
outputMatrix = [Cq; Ctheta; -K];
feedthrough = [zeros(4, 4); Nr, zeros(2, 2)];
fullStateClosedLoop = ss(Acl, inputMatrix, outputMatrix, feedthrough, ...
    'InputName', {'r1', 'r2', 'd1', 'd2'}, ...
    'OutputName', {'q1', 'q2', 'theta1', 'theta2', 'u1', 'u2'});

referenceTime = (0:config.simulationTimeStep:config.referenceHorizon).';
numberReferenceSamples = numel(referenceTime);
referenceAmplitude = m5Spec.referenceAmplitude;
referenceJoint = (1:2).';
settlingTime = zeros(2, 1);
overshoot = zeros(2, 1);
steadyStateErrorRelative = zeros(2, 1);
crossCouplingPeakRatio = zeros(2, 1);
peakControl = zeros(2, 1);
peakDeformation = zeros(2, 2);
peakElasticTorque = zeros(2, 2);
referenceOutput = cell(2, 1);

referenceDcGain = dcgain(fullStateClosedLoop(1:2, 1:2));
for jointIndex = 1:2
    inputs = zeros(numberReferenceSamples, 4);
    inputs(:, jointIndex) = referenceAmplitude;
    output = lsim(fullStateClosedLoop, inputs, referenceTime);
    referenceOutput{jointIndex} = output;
    q = output(:, 1:2);
    u = output(:, 5:6);
    deformation = output(:, 3:4) - q;
    steadyValue = referenceDcGain(:, jointIndex) * referenceAmplitude;
    settlingTime(jointIndex) = localSettlingTime( ...
        q(:, jointIndex), steadyValue(jointIndex), referenceTime, ...
        config.settlingBandFraction * abs(referenceAmplitude));
    peakInCommandDirection = max(q(:, jointIndex));
    overshoot(jointIndex) = 100 * max(0, ...
        (peakInCommandDirection - referenceAmplitude) / ...
        abs(referenceAmplitude));
    steadyStateErrorRelative(jointIndex) = abs( ...
        steadyValue(jointIndex) - referenceAmplitude) / ...
        abs(referenceAmplitude);
    otherJoint = 3 - jointIndex;
    crossCouplingPeakRatio(jointIndex) = max(abs(q(:, otherJoint))) / ...
        max(max(abs(q(:, jointIndex))), eps);
    peakControl(jointIndex) = max(abs(u), [], 'all');
    peakDeformation(jointIndex, :) = max(abs(deformation), [], 1);
    peakElasticTorque(jointIndex, :) = max(abs( ...
        deformation * springStiffness.'), [], 1);
end

trackingMetrics = table(referenceJoint, settlingTime, overshoot, ...
    steadyStateErrorRelative, crossCouplingPeakRatio, peakControl, ...
    'VariableNames', {'ReferenceJoint', 'SettlingTime', 'Overshoot', ...
    'SteadyStateErrorRelative', 'CrossCouplingPeakRatio', ...
    'PeakControl'});

worstPeakDeformationByJoint = max(peakDeformation, [], 1).';
worstPeakElasticTorqueByJoint = max(peakElasticTorque, [], 1).';

disturbanceTime = zeros(0, 1);
disturbanceOutput = cell(0, 1);
disturbanceMetrics = table;
peakQ = NaN(2, 1);
steadyStateOffset = NaN(2, 1);
disturbanceSettlingTime = NaN(2, 1);
disturbancePeakControl = NaN(2, 1);
if includeDisturbance
    disturbanceTime = ...
        (0:config.simulationTimeStep:config.disturbanceHorizon).';
    numberDisturbanceSamples = numel(disturbanceTime);
    disturbanceAmplitude = m5Spec.disturbanceTorqueAmplitude;
    disturbanceJoint = (1:2).';
    peakQ = zeros(2, 1);
    steadyStateOffset = zeros(2, 1);
    disturbanceSettlingTime = zeros(2, 1);
    disturbanceCrossCouplingPeakRatio = zeros(2, 1);
    disturbancePeakControl = zeros(2, 1);
    disturbanceOutput = cell(2, 1);
    disturbanceDcGain = dcgain(fullStateClosedLoop(1:2, 3:4));
    for jointIndex = 1:2
        inputs = zeros(numberDisturbanceSamples, 4);
        inputs(:, jointIndex + 2) = disturbanceAmplitude;
        output = lsim(fullStateClosedLoop, inputs, disturbanceTime);
        disturbanceOutput{jointIndex} = output;
        q = output(:, 1:2);
        u = output(:, 5:6);
        steadyValue = disturbanceDcGain(:, jointIndex) * ...
            disturbanceAmplitude;
        affectedPeak = max(abs(q(:, jointIndex)));
        peakQ(jointIndex) = affectedPeak;
        steadyStateOffset(jointIndex) = steadyValue(jointIndex);
        settlingThreshold = config.settlingBandFraction * max( ...
            [affectedPeak, abs(steadyValue(jointIndex)), eps]);
        disturbanceSettlingTime(jointIndex) = localSettlingTime( ...
            q(:, jointIndex), steadyValue(jointIndex), ...
            disturbanceTime, settlingThreshold);
        otherJoint = 3 - jointIndex;
        disturbanceCrossCouplingPeakRatio(jointIndex) = ...
            max(abs(q(:, otherJoint))) / max(affectedPeak, eps);
        disturbancePeakControl(jointIndex) = max(abs(u), [], 'all');
    end
    disturbanceMetrics = table(disturbanceJoint, peakQ, ...
        steadyStateOffset, disturbanceSettlingTime, ...
        disturbanceCrossCouplingPeakRatio, disturbancePeakControl, ...
        'VariableNames', {'DisturbanceJoint', 'PeakQ', ...
        'SteadyStateOffset', 'SettlingTime', ...
        'CrossCouplingPeakRatio', 'PeakControl'});
end

evaluation.fullStateClosedLoop = fullStateClosedLoop;
evaluation.trackingMetrics = trackingMetrics;
evaluation.disturbanceMetrics = disturbanceMetrics;
evaluation.referenceTime = referenceTime;
evaluation.referenceOutput = referenceOutput;
evaluation.disturbanceTime = disturbanceTime;
evaluation.disturbanceOutput = disturbanceOutput;
evaluation.summary.stable = all(real(eig(Acl)) < ...
    -config.numericStabilityTolerance);
evaluation.summary.worstSettlingTime = max(settlingTime);
evaluation.summary.worstOvershoot = max(overshoot);
evaluation.summary.worstSteadyStateErrorRelative = ...
    max(steadyStateErrorRelative);
evaluation.summary.worstCrossCouplingPeakRatio = ...
    max(crossCouplingPeakRatio);
evaluation.summary.worstPeakControl = max(peakControl);
evaluation.summary.peakDeformationByJoint = ...
    worstPeakDeformationByJoint;
evaluation.summary.peakElasticTorqueByJoint = ...
    worstPeakElasticTorqueByJoint;
evaluation.summary.worstPeakDeformation = ...
    max(worstPeakDeformationByJoint);
deformationScale = m5Spec.disturbanceTorqueAmplitude / ...
    min(diag(springStiffness));
evaluation.summary.peakDeformationNormalized = ...
    evaluation.summary.worstPeakDeformation / ...
    deformationScale;
evaluation.summary.worstDisturbancePeakQ = max(peakQ);
evaluation.summary.worstDisturbanceSteadyStateOffset = ...
    max(abs(steadyStateOffset));
evaluation.summary.worstDisturbanceSettlingTime = ...
    max(disturbanceSettlingTime);
evaluation.summary.worstDisturbancePeakControl = ...
    max(disturbancePeakControl);
end

function settlingTime = localSettlingTime(signal, finalValue, time, threshold)
outsideBand = abs(signal - finalValue) > max(threshold, 100 * eps);
lastOutside = find(outsideBand, 1, 'last');
if isempty(lastOutside)
    settlingTime = 0;
elseif lastOutside == numel(time)
    settlingTime = inf;
else
    settlingTime = time(lastOutside + 1);
end
end
