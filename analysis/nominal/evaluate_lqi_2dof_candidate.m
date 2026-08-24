function evaluation = evaluate_lqi_2dof_candidate( ...
    m3Data, m5Data, design, Nff, config)
%EVALUATE_LQI_2DOF_CANDIDATE Evaluate one full-state M7 servo candidate.
%   Reference and constant link-torque cases are simulated separately for
%   both joints. Normalized quantities use only the approved M5/M6 scales.

arguments
    m3Data (1, 1) struct
    m5Data (1, 1) struct
    design (1, 1) struct
    Nff (2, 2) double
    config (1, 1) struct = lqg_specs_m7
end

A = m3Data.Afull;
B = m3Data.Bfull;
Cq = m3Data.CfullQ;
Ctheta = m3Data.CfullMeas(3:4, :);
Bd = m5Data.BdFull;
Ks = m3Data.mechanicalParams.Ks;
n = size(A, 1);
Kx = design.Kx;
Ki = design.Ki;

Acl = [A - B * Kx, -B * Ki; -Cq, zeros(2)];
Bcl = [B * Nff, Bd; eye(2), zeros(2)];
Ccl = [Cq, zeros(2); Ctheta, zeros(2); ...
    -Kx, -Ki; zeros(2, n), eye(2)];
Dcl = [zeros(4, 4); Nff, zeros(2); zeros(2, 4)];
closedLoop = ss(Acl, Bcl, Ccl, Dcl, ...
    'InputName', {'r1', 'r2', 'd1', 'd2'}, ...
    'OutputName', {'q1', 'q2', 'theta1', 'theta2', ...
    'u1', 'u2', 'xi1', 'xi2'});

spec = m5Data.spec;
referenceTime = (0:config.simulationTimeStep:config.referenceHorizon).';
disturbanceTime = ...
    (0:config.simulationTimeStep:config.disturbanceHorizon).';
tracking = zeros(2, 6);
disturbance = zeros(2, 6);
referenceOutput = cell(2, 1);
disturbanceOutput = cell(2, 1);
peakDelta = zeros(2, 1);
peakElasticTorque = zeros(2, 1);
trackingDc = dcgain(closedLoop(1:2, 1:2));
disturbanceDc = dcgain(closedLoop(1:2, 3:4));

for jointIndex = 1:2
    input = zeros(numel(referenceTime), 4);
    input(:, jointIndex) = spec.referenceAmplitude;
    output = lsim(closedLoop, input, referenceTime);
    referenceOutput{jointIndex} = output;
    q = output(:, 1:2);
    theta = output(:, 3:4);
    u = output(:, 5:6);
    xi = output(:, 7:8);
    finalQ = trackingDc(:, jointIndex) * spec.referenceAmplitude;
    tracking(jointIndex, 1) = localSettlingTime( ...
        q(:, jointIndex), finalQ(jointIndex), referenceTime, ...
        config.settlingBandFraction * abs(spec.referenceAmplitude));
    tracking(jointIndex, 2) = 100 * max(0, ...
        (max(q(:, jointIndex)) - spec.referenceAmplitude) / ...
        spec.referenceAmplitude);
    tracking(jointIndex, 3) = abs( ...
        finalQ(jointIndex) - spec.referenceAmplitude) / ...
        spec.referenceAmplitude;
    otherJoint = 3 - jointIndex;
    tracking(jointIndex, 4) = max(abs(q(:, otherJoint))) / ...
        max(max(abs(q(:, jointIndex))), eps);
    tracking(jointIndex, 5) = max(abs(u), [], 'all');
    tracking(jointIndex, 6) = max(abs(xi), [], 'all');
    deformation = theta - q;
    peakDelta(jointIndex) = max(abs(deformation), [], 'all');
    peakElasticTorque(jointIndex) = max(abs( ...
        deformation * Ks.'), [], 'all');

    input = zeros(numel(disturbanceTime), 4);
    input(:, jointIndex + 2) = spec.disturbanceTorqueAmplitude;
    output = lsim(closedLoop, input, disturbanceTime);
    disturbanceOutput{jointIndex} = output;
    q = output(:, 1:2);
    u = output(:, 5:6);
    xi = output(:, 7:8);
    finalQ = disturbanceDc(:, jointIndex) * ...
        spec.disturbanceTorqueAmplitude;
    affectedPeak = max(abs(q(:, jointIndex)));
    disturbance(jointIndex, 1) = affectedPeak;
    disturbance(jointIndex, 2) = finalQ(jointIndex);
    disturbance(jointIndex, 3) = localSettlingTime( ...
        q(:, jointIndex), finalQ(jointIndex), disturbanceTime, ...
        config.settlingBandFraction * max(affectedPeak, eps));
    otherJoint = 3 - jointIndex;
    disturbance(jointIndex, 4) = max(abs(q(:, otherJoint))) / ...
        max(affectedPeak, eps);
    disturbance(jointIndex, 5) = max(abs(u), [], 'all');
    disturbance(jointIndex, 6) = max(abs(xi), [], 'all');
end

trackingMetrics = array2table([(1:2).', tracking], ...
    'VariableNames', {'ReferenceJoint', 'SettlingTime', 'Overshoot', ...
    'SteadyStateErrorRelative', 'CrossCouplingPeakRatio', ...
    'PeakControl', 'PeakXi'});
disturbanceMetrics = array2table([(1:2).', disturbance], ...
    'VariableNames', {'DisturbanceJoint', 'PeakQ', ...
    'SteadyStateOffset', 'SettlingTime', ...
    'CrossCouplingPeakRatio', 'PeakControl', 'PeakXi'});

stable = all(real(eig(Acl)) < -config.numericStabilityTolerance);
trackingPass = stable && all( ...
    trackingMetrics.SettlingTime <= spec.settlingTimeTarget) && ...
    all(trackingMetrics.Overshoot <= spec.overshootTarget) && ...
    all(trackingMetrics.SteadyStateErrorRelative <= ...
        spec.steadyStateTrackingTarget);
disturbancePass = stable && all(abs( ...
    disturbanceMetrics.SteadyStateOffset) <= ...
    config.disturbanceSteadyStateTolerance);
deformationScale = design.physicalScales.delta;
worstPeakXi = max([trackingMetrics.PeakXi; disturbanceMetrics.PeakXi]);

evaluation.Nff = Nff;
evaluation.closedLoop = closedLoop;
evaluation.trackingMetrics = trackingMetrics;
evaluation.disturbanceMetrics = disturbanceMetrics;
evaluation.referenceTime = referenceTime;
evaluation.referenceOutput = referenceOutput;
evaluation.disturbanceTime = disturbanceTime;
evaluation.disturbanceOutput = disturbanceOutput;
evaluation.summary.stable = stable;
evaluation.summary.trackingPass = trackingPass;
evaluation.summary.disturbancePass = disturbancePass;
evaluation.summary.fundamentalPass = trackingPass && disturbancePass;
evaluation.summary.worstSettlingTime = max(trackingMetrics.SettlingTime);
evaluation.summary.worstOvershoot = max(trackingMetrics.Overshoot);
evaluation.summary.worstSteadyStateErrorRelative = ...
    max(trackingMetrics.SteadyStateErrorRelative);
evaluation.summary.worstCrossCouplingPeakRatio = ...
    max(trackingMetrics.CrossCouplingPeakRatio);
evaluation.summary.worstPeakControl = max(trackingMetrics.PeakControl);
evaluation.summary.peakControlNormalized = ...
    evaluation.summary.worstPeakControl / spec.uScale;
evaluation.summary.worstPeakDeformation = max(peakDelta);
evaluation.summary.peakDeformationNormalized = ...
    max(peakDelta) / deformationScale;
evaluation.summary.worstPeakElasticTorque = max(peakElasticTorque);
evaluation.summary.worstPeakXi = worstPeakXi;
evaluation.summary.worstDisturbancePeakQ = ...
    max(disturbanceMetrics.PeakQ);
evaluation.summary.worstDisturbanceSettlingTime = ...
    max(disturbanceMetrics.SettlingTime);
evaluation.summary.worstDisturbanceSteadyStateOffset = ...
    max(abs(disturbanceMetrics.SteadyStateOffset));
evaluation.summary.worstDisturbanceCrossCouplingPeakRatio = ...
    max(disturbanceMetrics.CrossCouplingPeakRatio);
evaluation.summary.worstDisturbancePeakControl = ...
    max(disturbanceMetrics.PeakControl);
evaluation.summary.windupIndicator = worstPeakXi / design.xiScale;
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
