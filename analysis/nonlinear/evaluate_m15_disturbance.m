function evaluation = evaluate_m15_disturbance(controller, projectRoot, config)
%EVALUATE_M15_DISTURBANCE Evaluate six frozen link-disturbance scenarios.

arguments
    controller (1, 1) struct
    projectRoot (1, 1) string
    config (1, 1) struct = m15_specs
end

m3 = load(fullfile(projectRoot, 'results', 'data', ...
    'm3_nominal_actuated_plant.mat'));
m5 = load(fullfile(projectRoot, 'results', 'data', ...
    'm5_performance_specs.mat'));
amplitudes = config.disturbance.amplitudesNm(:);
rows = zeros(numel(amplitudes) * 2, 11);
comparisonRows = zeros(numel(amplitudes) * 2, 6);
responses = cell(numel(amplitudes), 2);
qDisturbance = controller.disturbanceQ;
uDisturbance = controller.disturbanceU;
dcGainQ = dcgain(qDisturbance);
rowIndex = 0;
for amplitudeIndex = 1:numel(amplitudes)
    amplitude = amplitudes(amplitudeIndex);
    for jointIndex = 1:2
        scenario.disturbance = zeros(1, 2);
        scenario.disturbance(jointIndex) = amplitude;
        scenario.horizon = config.simulation.disturbanceHorizon;
        nonlinear = simulate_m15_nonlinear(controller, scenario, ...
            projectRoot, config);
        time = (0:config.simulation.inputTimeStep:scenario.horizon).';
        input = zeros(numel(time), 2); input(:, jointIndex) = amplitude;
        qLti = lsim(qDisturbance, input, time);
        uLti = lsim(uDisturbance, input, time);
        q = nonlinear.xMechanical(:, 1:2) - m3.xbar(1:2).';
        qLtiAtNl = interp1(time, qLti, nonlinear.time, 'linear');
        uLtiAtNl = interp1(time, uLti, nonlinear.time, 'linear');
        qDifference = q - qLtiAtNl;
        uDifference = nonlinear.controlDelta - uLtiAtNl;
        finalVector = dcGainQ(:, jointIndex) * amplitude;
        finalValue = finalVector(jointIndex);
        affectedPeak = max(abs(q(:, jointIndex)));
        threshold = config.simulation.settlingBandFraction * ...
            max([affectedPeak, abs(finalValue), eps]);
        settling = localSettlingTime(q(:, jointIndex), finalValue, ...
            nonlinear.time, threshold);
        otherJoint = 3 - jointIndex;
        crossCoupling = max(abs(q(:, otherJoint))) / max(affectedPeak, eps);
        deformation = nonlinear.xMechanical(:, 5:6) - ...
            nonlinear.xMechanical(:, 1:2);
        elasticTorque = deformation * m3.mechanicalParams.Ks.';
        rowIndex = rowIndex + 1;
        peakDeltaU = max(abs(nonlinear.controlDelta), [], 'all');
        rows(rowIndex, :) = [amplitude, jointIndex, affectedPeak, ...
            finalValue, settling, crossCoupling, peakDeltaU, ...
            max(abs(nonlinear.controlAbsolute), [], 'all'), ...
            peakDeltaU / m5.spec.uScale, ...
            max(abs(deformation), [], 'all'), ...
            max(abs(elasticTorque), [], 'all')];
        comparisonRows(rowIndex, :) = [amplitude, jointIndex, ...
            max(abs(qDifference), [], 'all'), ...
            sqrt(mean(qDifference.^2, 'all')), ...
            max(abs(uDifference), [], 'all'), ...
            sqrt(mean(uDifference.^2, 'all'))];
        responses{amplitudeIndex, jointIndex} = struct( ...
            'amplitudeNm', amplitude, 'joint', jointIndex, ...
            'time', nonlinear.time, 'q', q, ...
            'controlDelta', nonlinear.controlDelta, ...
            'controlAbsolute', nonlinear.controlAbsolute, ...
            'qLti', qLtiAtNl, 'uLti', uLtiAtNl);
    end
end
evaluation.controllerID = controller.id;
evaluation.metrics = array2table(rows, 'VariableNames', ...
    {'AmplitudeNm', 'Joint', 'PeakQRad', 'SteadyStateOffsetRad', ...
    'SettlingTime', 'CrossCouplingPeakRatio', 'PeakDeltaUNm', ...
    'PeakAbsoluteUNm', 'PeakUNormalized', 'PeakSeaDeformationRad', ...
    'PeakElasticTorqueNm'});
evaluation.ltiNonlinearMetrics = array2table(comparisonRows, ...
    'VariableNames', {'AmplitudeNm', 'Joint', 'MaxQDifferenceRad', ...
    'RmsQDifferenceRad', 'MaxUDifferenceNm', 'RmsUDifferenceNm'});
evaluation.responses = responses;
end

function settlingTime = localSettlingTime(signal, finalValue, time, threshold)
outside = abs(signal - finalValue) > max(threshold, 100 * eps);
lastOutside = find(outside, 1, 'last');
if isempty(lastOutside), settlingTime = 0;
elseif lastOutside == numel(time), settlingTime = inf;
else, settlingTime = time(lastOutside + 1);
end
end
