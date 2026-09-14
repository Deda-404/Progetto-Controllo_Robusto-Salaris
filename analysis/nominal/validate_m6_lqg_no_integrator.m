function metrics = validate_m6_lqg_no_integrator
%VALIDATE_M6_LQG_NO_INTEGRATOR Build and verify one documented LQG design.

projectRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
dataDirectory = fullfile(projectRoot, 'results', 'data');
figureDirectory = fullfile(projectRoot, 'results', 'figures');
if ~isfolder(dataDirectory), mkdir(dataDirectory); end
if ~isfolder(figureDirectory), mkdir(figureDirectory); end

m3Path = fullfile(dataDirectory, 'm3_nominal_actuated_plant.mat');
m5Path = fullfile(dataDirectory, 'm5_performance_specs.mat');
if ~isfile(m3Path), validate_m3_nominal_actuated_plant; end
if ~isfile(m5Path), validate_m5_performance_specs; end
m3 = load(m3Path);
m5 = load(m5Path);
config = lqg_specs_m6;

%% LQR: compact parametric search and one approved cost
lqrDesign = design_lqr_m6(m3, m5, config);

%% Kalman filter: declared process and measurement covariances
kalmanDesign = design_kalman_m6(m3, m5, lqrDesign, config);
kalmanSensitivity = analyze_kalman_sensitivity_m6( ...
    m3, m5, lqrDesign, config);
realization = build_lqg_no_integrator( ...
    m3, m5, lqrDesign, kalmanDesign, config);

%% Closed-loop verification
[lqgTrackingTable, referenceTime, lqgReferenceOutput] = ...
    localEvaluateLqgTracking(realization.lqgClosedLoop, m5.spec, config);
[lqgDisturbanceTable, disturbanceTime, lqgDisturbanceOutput] = ...
    localEvaluateLqgDisturbance( ...
    realization.lqgClosedLoop, m5.spec, config);
[noiseMetrics, noiseTime, noisyOutput, deterministicNoiseOutput] = ...
    localEvaluateNoise(realization.lqgClosedLoop, ...
    kalmanDesign.sigmaYRad, m5.spec, config);
[repeatNoiseMetrics, ~, repeatNoisyOutput] = localEvaluateNoise( ...
    realization.lqgClosedLoop, kalmanDesign.sigmaYRad, m5.spec, config);
noiseRepeatError = max(abs(noisyOutput - repeatNoisyOutput), [], 'all');

fullStateEvaluation = lqrDesign.evaluation;
trackingMetrics.fullState = fullStateEvaluation.trackingMetrics;
trackingMetrics.lqg = lqgTrackingTable;
trackingMetrics.maximumQDifference = localMaximumResponseDifference( ...
    fullStateEvaluation.referenceOutput, lqgReferenceOutput, 1:2);
trackingMetrics.maximumControlDifference = localMaximumResponseDifference( ...
    fullStateEvaluation.referenceOutput, lqgReferenceOutput, 5:6);
trackingMetrics.estimationCostSettling = max( ...
    lqgTrackingTable.SettlingTime - ...
    fullStateEvaluation.trackingMetrics.SettlingTime);
disturbanceMetrics.fullState = fullStateEvaluation.disturbanceMetrics;
disturbanceMetrics.lqg = lqgDisturbanceTable;
disturbanceMetrics.maximumQDifference = localMaximumResponseDifference( ...
    fullStateEvaluation.disturbanceOutput, lqgDisturbanceOutput, 1:2);

Q = lqrDesign.Q;
R = lqrDesign.R;
K = lqrDesign.K;
Nr = lqrDesign.Nr;
Ccost = lqrDesign.Ccost;
processNoiseInputMatrix = kalmanDesign.processNoiseInputMatrix;
Qn = kalmanDesign.Qn;
Rn = kalmanDesign.Rn;
L = kalmanDesign.L;
Klqg = realization.Klqg;
fullStateClosedLoop = realization.fullStateClosedLoop;
lqgClosedLoop = realization.lqgClosedLoop;
regulatorPoles = realization.regulatorPoles;
estimatorPoles = realization.estimatorPoles;
combinedPoles = realization.combinedPoles;

validationMetrics.model = struct('stateCount', size(m3.Afull, 1), ...
    'inputCount', size(m3.Bfull, 2), ...
    'measurementCount', size(m3.CfullMeas, 1));
validationMetrics.cost.scales = lqrDesign.scales;
validationMetrics.cost.priorities = lqrDesign.priorities;
validationMetrics.cost.symmetricError = norm(Q - Q.', 'fro');
validationMetrics.cost.minimumEigenvalue = min(eig(Q));
validationMetrics.cost.rank = rank(Q);
validationMetrics.cost.actuatorDirectWeightNorm = ...
    norm(Ccost(:, 9:14), 'fro');
validationMetrics.lqr.method = lqrDesign.method;
% Metadato del peso diretto: R e il controllore restano invariati.
validationMetrics.lqr.ru = lqrDesign.ru;
validationMetrics.lqr.numberCandidates = lqrDesign.numberCandidates;
validationMetrics.lqr.numberAdmissible = lqrDesign.numberAdmissible;
validationMetrics.lqr.selectedIndex = lqrDesign.selectedIndex;
validationMetrics.lqr.compromiseScore = lqrDesign.selectedScore;
validationMetrics.lqr.peakUNormalized = ...
    fullStateEvaluation.summary.worstPeakControl / m5.spec.uScale;
validationMetrics.lqr.rmsUNormalized = ...
    fullStateEvaluation.summary.worstRmsControl / m5.spec.uScale;
validationMetrics.prefilter.condition = lqrDesign.prefilterCondition;
validationMetrics.prefilter.dcError = lqrDesign.prefilterResidual;
validationMetrics.kalman.method = kalmanDesign.method;
validationMetrics.kalman.sigmaD = kalmanDesign.sigmaD;
validationMetrics.kalman.sigmaU = kalmanDesign.sigmaU;
validationMetrics.kalman.sigmaYDeg = kalmanDesign.sigmaYDeg;
validationMetrics.kalman.estimatorSpeedRatio = ...
    kalmanDesign.estimatorSpeedRatio;
validationMetrics.kalman.h2NoiseAmplification = ...
    kalmanDesign.h2NoiseAmplification;
validationMetrics.kalman.sensitivityCases = ...
    height(kalmanSensitivity.table);
validationMetrics.separation.error = realization.separationError;
validationMetrics.controller.order = realization.controllerOrder;
validationMetrics.controller.integratorStateCount = ...
    realization.integratorStateCount;
validationMetrics.tracking.targetsPassed = all( ...
    lqgTrackingTable.SettlingTime <= m5.spec.settlingTimeTarget & ...
    lqgTrackingTable.Overshoot <= m5.spec.overshootTarget & ...
    lqgTrackingTable.SteadyStateErrorRelative <= ...
    m5.spec.steadyStateTrackingTarget);
validationMetrics.tracking.crossCouplingDiagnosticPassed = all( ...
    lqgTrackingTable.CrossCouplingPeakRatio <= m5.spec.crossCouplingTarget);
validationMetrics.noise.seed = config.noiseSeed;
validationMetrics.noise.repeatError = noiseRepeatError;
validationMetrics.noise.repeatMetricsEqual = ...
    isequaln(noiseMetrics, repeatNoiseMetrics);
validationMetrics.measurements.velocityMeasured = any(any( ...
    abs(m3.CfullMeas(:, [3:4, 7:8])) > 0));
validationMetrics.nominalSynthesisOnly = ...
    isnumeric(m3.Afull) && isnumeric(m3.Bfull) && ...
    isnumeric(Ccost) && isnumeric(K) && isnumeric(L);

localPlotCostDefinition(lqrDesign, fullfile( ...
    figureDirectory, 'm6_lqr_selected_weights.png'));
localPlotLqrSearch(lqrDesign, m5.spec, fullfile( ...
    figureDirectory, 'm6_lqr_candidate_tradeoff.png'));
localPlotKalmanSensitivity(kalmanSensitivity.table, fullfile( ...
    figureDirectory, 'm6_kalman_sensitivity.png'));
localPlotReference(referenceTime, lqgReferenceOutput, m5.spec, ...
    fullfile(figureDirectory, 'm6_lqg_reference_tracking.png'));
localPlotDisturbance(disturbanceTime, lqgDisturbanceOutput, ...
    fullfile(figureDirectory, 'm6_lqg_disturbance_response.png'));
localPlotEstimation(noiseTime, noisyOutput, deterministicNoiseOutput, ...
    fullfile(figureDirectory, 'm6_lqg_estimation.png'));
localPlotPoles(regulatorPoles, estimatorPoles, combinedPoles, fullfile( ...
    figureDirectory, 'm6_lqg_poles.png'));

datasetPath = fullfile(dataDirectory, 'm6_lqg_no_integrator.mat');
lqrCandidateTable = lqrDesign.candidateTable;
kalmanSensitivityTable = kalmanSensitivity.table;
save(datasetPath, 'Q', 'R', 'K', 'Nr', 'Ccost', ...
    'processNoiseInputMatrix', 'Qn', 'Rn', 'L', 'Klqg', ...
    'fullStateClosedLoop', 'lqgClosedLoop', 'regulatorPoles', ...
    'estimatorPoles', 'combinedPoles', 'trackingMetrics', ...
    'disturbanceMetrics', 'noiseMetrics', 'lqrCandidateTable', ...
    'kalmanSensitivityTable', 'validationMetrics', '-v7');

assert(isequal([size(m3.Afull), size(m3.Bfull), ...
    size(m3.CfullMeas)], [14, 14, 14, 2, 4, 14]), ...
    'M6:FullPlantDimensions', 'M6 must use the full M3 plant.');
assert(validationMetrics.cost.symmetricError <= 1e-10 && ...
    validationMetrics.cost.minimumEigenvalue >= -1e-8 && ...
    all(isfinite(Q), 'all'), 'M6:CostProperties', ...
    'The LQR state cost is not finite, symmetric and PSD.');
assert(validationMetrics.lqr.peakUNormalized <= ...
    config.controlEffortModerateThreshold, 'M6:LQRAggressiveness', ...
    'The approved LQR exceeds the diagnostic control scale.');
assert(lqrDesign.numberCandidates == config.lqr.expectedCandidateCount && ...
    lqrDesign.numberAdmissible > 0 && ...
    sum(lqrDesign.candidateTable.Selected) == 1, ...
    'M6:LQRSearch', 'The compact LQR search is not reproducible.');
assert(validationMetrics.prefilter.dcError <= 1e-10, ...
    'M6:Prefilter', 'The MIMO reference prefilter is inconsistent.');
assert(realization.separationError <= 1e-4, ...
    'M6:SeparationPrinciple', 'The separation principle check failed.');
assert(realization.controllerOrder == 14 && ...
    realization.integratorStateCount == 0, 'M6:ControllerOrder', ...
    'The M6 controller must have order 14 and no integrator.');
assert(validationMetrics.tracking.targetsPassed, 'M6:TrackingTargets', ...
    'The approved LQG violates a fundamental M5 tracking target.');
assert(all(isfinite(lqgDisturbanceTable.SteadyStateOffset)), ...
    'M6:DisturbanceOffset', 'Disturbance offsets were not quantified.');
assert(isfinite(kalmanDesign.h2NoiseAmplification) && ...
    noiseRepeatError == 0 && validationMetrics.noise.repeatMetricsEqual, ...
    'M6:NoiseValidation', 'The seeded noise check is not reproducible.');
assert(~validationMetrics.measurements.velocityMeasured && ...
    validationMetrics.nominalSynthesisOnly, 'M6:ModelScope', ...
    'M6 must use encoder positions and the nominal numeric model only.');

fprintf('\n=== M6: LQG nominale senza integratore ===\n');
fprintf(['Ricerca LQR: %d configurazioni, %d ammissibili; ' ...
    'selezionata %s con score=%.4g.\n'], ...
    lqrDesign.numberCandidates, lqrDesign.numberAdmissible, ...
    lqrDesign.candidateTable.Candidate(lqrDesign.selectedIndex), ...
    lqrDesign.selectedScore);
disp(lqrDesign.candidateTable);
fprintf(['Pesi scelti: wq=%.3g, wdelta=%.3g, wvel=%.3g, ru=%.6g; ' ...
    'worst settling=%.4g s, peakU/uScale=%.4g, rmsU/uScale=%.4g.\n'], ...
    lqrDesign.priorities.wq, lqrDesign.priorities.wdelta, ...
    lqrDesign.priorities.wqdot, lqrDesign.ru, ...
    max(lqgTrackingTable.SettlingTime), ...
    validationMetrics.lqr.peakUNormalized, ...
    validationMetrics.lqr.rmsUNormalized);
fprintf('Q selezionata:\n'); disp(Q);
fprintf('R selezionata:\n'); disp(R);
fprintf('K selezionato:\n'); disp(K);
fprintf('Poli LQR:\n'); disp(regulatorPoles);
fprintf(['Kalman diretto: sigmaD=%.3g, sigmaU=%.3g N m, ' ...
    'sigmaY=%.3g deg, estimator/regulator=%.4g.\n'], ...
    kalmanDesign.sigmaD, kalmanDesign.sigmaU, ...
    kalmanDesign.sigmaYDeg, kalmanDesign.estimatorSpeedRatio);
disp(kalmanSensitivity.table);
fprintf('[PASS] LQG verificato con ricerca LQR compatta e motivata.\n');

metrics.config = config;
metrics.lqrDesign = lqrDesign;
metrics.kalmanDesign = kalmanDesign;
metrics.kalmanSensitivity = kalmanSensitivity;
metrics.realization = realization;
metrics.trackingMetrics = trackingMetrics;
metrics.disturbanceMetrics = disturbanceMetrics;
metrics.noiseMetrics = noiseMetrics;
metrics.validationMetrics = validationMetrics;
metrics.datasetPath = datasetPath;
end

function [trackingTable, time, outputByJoint] = ...
    localEvaluateLqgTracking(system, spec, config)
time = (0:config.simulationTimeStep:config.referenceHorizon).';
numberSamples = numel(time);
referenceJoint = (1:2).';
settlingTime = zeros(2, 1);
overshoot = zeros(2, 1);
steadyStateErrorRelative = zeros(2, 1);
crossCouplingPeakRatio = zeros(2, 1);
peakControl = zeros(2, 1);
outputByJoint = cell(2, 1);
referenceDcGain = dcgain(system(1:2, 1:2));
for jointIndex = 1:2
    input = zeros(numberSamples, 8);
    input(:, jointIndex) = spec.referenceAmplitude;
    output = lsim(system, input, time);
    outputByJoint{jointIndex} = output;
    q = output(:, 1:2);
    u = output(:, 5:6);
    finalValue = referenceDcGain(:, jointIndex) * spec.referenceAmplitude;
    settlingTime(jointIndex) = localSettlingTime( ...
        q(:, jointIndex), finalValue(jointIndex), time, ...
        config.settlingBandFraction * abs(spec.referenceAmplitude));
    overshoot(jointIndex) = 100 * max(0, ...
        (max(q(:, jointIndex)) - spec.referenceAmplitude) / ...
        abs(spec.referenceAmplitude));
    steadyStateErrorRelative(jointIndex) = abs( ...
        finalValue(jointIndex) - spec.referenceAmplitude) / ...
        abs(spec.referenceAmplitude);
    otherJoint = 3 - jointIndex;
    crossCouplingPeakRatio(jointIndex) = max(abs(q(:, otherJoint))) / ...
        max(max(abs(q(:, jointIndex))), eps);
    peakControl(jointIndex) = max(abs(u), [], 'all');
end
trackingTable = table(referenceJoint, settlingTime, overshoot, ...
    steadyStateErrorRelative, crossCouplingPeakRatio, peakControl, ...
    'VariableNames', {'ReferenceJoint', 'SettlingTime', 'Overshoot', ...
    'SteadyStateErrorRelative', 'CrossCouplingPeakRatio', 'PeakControl'});
end

function [disturbanceTable, time, outputByJoint] = ...
    localEvaluateLqgDisturbance(system, spec, config)
time = (0:config.simulationTimeStep:config.disturbanceHorizon).';
numberSamples = numel(time);
disturbanceJoint = (1:2).';
peakQ = zeros(2, 1);
steadyStateOffset = zeros(2, 1);
settlingTime = zeros(2, 1);
crossCouplingPeakRatio = zeros(2, 1);
peakControl = zeros(2, 1);
outputByJoint = cell(2, 1);
disturbanceDcGain = dcgain(system(1:2, 3:4));
for jointIndex = 1:2
    input = zeros(numberSamples, 8);
    input(:, jointIndex + 2) = spec.disturbanceTorqueAmplitude;
    output = lsim(system, input, time);
    outputByJoint{jointIndex} = output;
    q = output(:, 1:2);
    u = output(:, 5:6);
    finalValue = disturbanceDcGain(:, jointIndex) * ...
        spec.disturbanceTorqueAmplitude;
    affectedPeak = max(abs(q(:, jointIndex)));
    peakQ(jointIndex) = affectedPeak;
    steadyStateOffset(jointIndex) = finalValue(jointIndex);
    threshold = config.settlingBandFraction * max( ...
        [affectedPeak, abs(finalValue(jointIndex)), eps]);
    settlingTime(jointIndex) = localSettlingTime( ...
        q(:, jointIndex), finalValue(jointIndex), time, threshold);
    otherJoint = 3 - jointIndex;
    crossCouplingPeakRatio(jointIndex) = ...
        max(abs(q(:, otherJoint))) / max(affectedPeak, eps);
    peakControl(jointIndex) = max(abs(u), [], 'all');
end
disturbanceTable = table(disturbanceJoint, peakQ, steadyStateOffset, ...
    settlingTime, crossCouplingPeakRatio, peakControl, ...
    'VariableNames', {'DisturbanceJoint', 'PeakQ', ...
    'SteadyStateOffset', 'SettlingTime', ...
    'CrossCouplingPeakRatio', 'PeakControl'});
end

function [noiseMetrics, time, noisyOutput, deterministicOutput] = ...
    localEvaluateNoise(system, sigmaYRad, spec, config)
rng(config.noiseSeed, 'twister');
time = (0:config.simulationTimeStep:config.noiseHorizon).';
numberSamples = numel(time);
input = zeros(numberSamples, 8);
input(:, 1) = spec.referenceAmplitude;
input(:, 5:8) = sigmaYRad * randn(numberSamples, 4);
noisyOutput = lsim(system, input, time);
input(:, 5:8) = 0;
deterministicOutput = lsim(system, input, time);
reference = [spec.referenceAmplitude * ones(numberSamples, 1), ...
    zeros(numberSamples, 1)];
trackingError = noisyOutput(:, 1:2) - reference;
estimationError = noisyOutput(:, 7:8);
controlVariation = noisyOutput(:, 5:6) - deterministicOutput(:, 5:6);
noiseMetrics.rmsTrackingErrorByJoint = sqrt(mean(trackingError.^2, 1)).';
noiseMetrics.rmsEstimationErrorQByJoint = ...
    sqrt(mean(estimationError.^2, 1)).';
noiseMetrics.rmsControlVariationByJoint = ...
    sqrt(mean(controlVariation.^2, 1)).';
noiseMetrics.rmsTrackingError = sqrt(mean(trackingError.^2, 'all'));
noiseMetrics.rmsEstimationErrorQ = sqrt(mean(estimationError.^2, 'all'));
noiseMetrics.rmsControlVariation = sqrt(mean(controlVariation.^2, 'all'));
noiseMetrics.seed = config.noiseSeed;
noiseMetrics.sigmaYRad = sigmaYRad;
end

function maximumDifference = localMaximumResponseDifference( ...
    firstResponses, secondResponses, outputIndices)
maximumDifference = 0;
for responseIndex = 1:numel(firstResponses)
    difference = firstResponses{responseIndex}(:, outputIndices) - ...
        secondResponses{responseIndex}(:, outputIndices);
    maximumDifference = max(maximumDifference, max(abs(difference), [], 'all'));
end
end

function settlingTime = localSettlingTime(signal, finalValue, time, threshold)
lastOutside = find(abs(signal - finalValue) > ...
    max(threshold, 100 * eps), 1, 'last');
if isempty(lastOutside)
    settlingTime = 0;
elseif lastOutside == numel(time)
    settlingTime = inf;
else
    settlingTime = time(lastOutside + 1);
end
end

function localPlotCostDefinition(design, filePath)
labels = categorical({'q', 'qdot', 'theta-q', 'thetadot'});
priorities = [design.priorities.wq, design.priorities.wqdot, ...
    design.priorities.wdelta, design.priorities.wthetaDot];
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 900, 560]);
bar(labels, priorities, 'FaceColor', [0.12, 0.48, 0.82]);
grid on; ylabel('Priorita adimensionale');
title('M6 - Fattori selezionati dalla ricerca LQR');
set_scientific_figure_style(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotLqrSearch(design, spec, filePath)
candidateTable = design.candidateTable;
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1000, 650]);
admissible = candidateTable.Admissible;
scatter(candidateTable.WorstSettlingTime(~admissible), ...
    candidateTable.WorstPeakControl(~admissible), 44, ...
    [0.70, 0.70, 0.70], 'filled', 'DisplayName', 'Non ammissibile');
hold on;
scatter(candidateTable.WorstSettlingTime(admissible), ...
    candidateTable.WorstPeakControl(admissible), 55, ...
    candidateTable.CompromiseScore(admissible), 'filled', ...
    'DisplayName', 'Ammissibile');
selected = candidateTable.Selected;
scatter(candidateTable.WorstSettlingTime(selected), ...
    candidateTable.WorstPeakControl(selected), 150, 'p', ...
    'MarkerFaceColor', [1, 0.75, 0.05], 'MarkerEdgeColor', 'black', ...
    'DisplayName', 'Selezionato');
xline(spec.settlingTimeTarget, '--', 'T_s target');
yline(spec.uScale, ':', 'u_{scale} (non saturazione)');
grid on; box on;
xlabel('Tempo di assestamento peggiore [s]');
ylabel('Picco di comando peggiore [N m]');
title('M6 - Compromesso prestazione/sforzo nei 36 candidati LQR');
legend('Location', 'best');
colorbar;
set_scientific_figure_style(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotKalmanSensitivity(caseTable, filePath)
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 980, 600]);
layout = tiledlayout(1, 2, 'TileSpacing', 'compact');
nexttile;
semilogx(caseTable.QOverRRelative, caseTable.EstimatorSpeedRatio, ...
    '-o', 'LineWidth', 1.6, 'MarkerFaceColor', [0.16, 0.52, 0.82]);
grid on; xlabel('Rapporto Q_n/R_n relativo');
ylabel('Rapporto velocita stimatore/regolatore');
title('Rapidita dell''osservatore');
nexttile;
semilogx(caseTable.QOverRRelative, caseTable.RmsControlFixedNoise, ...
    '-o', 'LineWidth', 1.6, 'MarkerFaceColor', [0.86, 0.42, 0.16]);
grid on; xlabel('Rapporto Q_n/R_n relativo');
ylabel('RMS variazione comando [N m]');
title('Stessa sequenza e ampiezza di rumore applicato');
title(layout, 'M6 - Tre ipotesi didattiche sulle covarianze Kalman');
set_scientific_figure_style(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotReference(time, outputs, spec, filePath)
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1000, 720]);
layout = tiledlayout(figureHandle, 2, 1, 'TileSpacing', 'compact');
title(layout, 'M6 - Tracking nominale LQG senza integratore');
for jointIndex = 1:2
    axesHandle = nexttile;
    plot(axesHandle, time, rad2deg(outputs{jointIndex}(:, 1:2)), ...
        'LineWidth', 1.7); hold(axesHandle, 'on');
    yline(axesHandle, rad2deg(spec.referenceAmplitude), '--k');
    grid(axesHandle, 'on'); ylabel(axesHandle, 'q [deg]');
    title(axesHandle, sprintf('Step r_%d = 5 deg', jointIndex));
    legend(axesHandle, {'q_1', 'q_2', 'r'}, 'Location', 'best');
end
xlabel(nexttile(layout, 2), 'Tempo [s]');
set_scientific_figure_style(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotDisturbance(time, outputs, filePath)
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1000, 720]);
layout = tiledlayout(figureHandle, 2, 1, 'TileSpacing', 'compact');
title(layout, 'M6 - Risposta LQG a coppia costante lato link');
for jointIndex = 1:2
    axesHandle = nexttile;
    plot(axesHandle, time, rad2deg(outputs{jointIndex}(:, 1:2)), ...
        'LineWidth', 1.7); grid(axesHandle, 'on');
    ylabel(axesHandle, 'Delta q [deg]');
    title(axesHandle, sprintf('Step d_%d = 0.5 N m', jointIndex));
    legend(axesHandle, {'q_1', 'q_2'}, 'Location', 'best');
end
xlabel(nexttile(layout, 2), 'Tempo [s]');
set_scientific_figure_style(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotEstimation(time, noisyOutput, deterministicOutput, filePath)
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1000, 720]);
layout = tiledlayout(figureHandle, 2, 1, 'TileSpacing', 'compact');
title(layout, 'M6 - Diagnostica seeded di stima e comando');
axesHandle = nexttile;
plot(axesHandle, time, rad2deg(noisyOutput(:, 7:8)), 'LineWidth', 1.1);
grid(axesHandle, 'on'); ylabel(axesHandle, 'q-qhat [deg]');
legend(axesHandle, {'e_{q1}', 'e_{q2}'}, 'Location', 'best');
axesHandle = nexttile;
plot(axesHandle, time, noisyOutput(:, 5:6) - ...
    deterministicOutput(:, 5:6), 'LineWidth', 1.1);
grid(axesHandle, 'on'); ylabel(axesHandle, 'Delta u [N m]');
xlabel(axesHandle, 'Tempo [s]');
legend(axesHandle, {'Delta u_1', 'Delta u_2'}, 'Location', 'best');
set_scientific_figure_style(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotPoles(regulatorPoles, estimatorPoles, combinedPoles, filePath)
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 950, 620]);
scatter(real(combinedPoles), imag(combinedPoles), 45, ...
    [0.65, 0.65, 0.65], 'filled', 'DisplayName', 'combined'); hold on;
scatter(real(regulatorPoles), imag(regulatorPoles), 70, ...
    [0.10, 0.40, 0.80], 'o', 'LineWidth', 1.5, ...
    'DisplayName', 'regolatore');
scatter(real(estimatorPoles), imag(estimatorPoles), 70, ...
    [0.85, 0.25, 0.12], 'x', 'LineWidth', 1.5, ...
    'DisplayName', 'stimatore');
xline(0, '--k', 'HandleVisibility', 'off'); grid on; box on;
xlabel('Parte reale [s^{-1}]'); ylabel('Parte immaginaria [s^{-1}]');
title('M6 - Poli e principio di separazione'); legend('Location', 'best');
set_scientific_figure_style(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end
