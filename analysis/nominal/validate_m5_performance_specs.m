function metrics = validate_m5_performance_specs
%VALIDATE_M5_PERFORMANCE_SPECS Verify the declared targets and weights.

projectRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
dataDirectory = fullfile(projectRoot, 'results', 'data');
figureDirectory = fullfile(projectRoot, 'results', 'figures');
if ~isfolder(dataDirectory), mkdir(dataDirectory); end
if ~isfolder(figureDirectory), mkdir(figureDirectory); end

m2Path = fullfile(dataDirectory, 'm2_linearization_nominal.mat');
m3Path = fullfile(dataDirectory, 'm3_nominal_actuated_plant.mat');
if ~isfile(m2Path), validate_m2_equilibrium_linearization; end
if ~isfile(m3Path), validate_m3_nominal_actuated_plant; end
m2 = load(m2Path);
m3 = load(m3Path);

spec = performance_specs_m5;
frequencyCriteria = localFrequencyCriteria(m2, m3, spec);
[W1siso, W1, W2siso, W2, weightInfo] = build_m5_weights(spec);

%% Link-side disturbance path
[Bd, disturbanceInputInfo] = ...
    build_joint_torque_disturbance_input(m2.qbar, m2.p);
finiteDifferenceStep = 1e-6;
BdFiniteDifference = zeros(8, 2);
for inputIndex = 1:2
    direction = zeros(2, 1);
    direction(inputIndex) = finiteDifferenceStep;
    plusDerivative = sea_nonlinear_rhs_with_link_disturbance( ...
        m2.xbar, m2.taubar, direction, m2.p);
    minusDerivative = sea_nonlinear_rhs_with_link_disturbance( ...
        m2.xbar, m2.taubar, -direction, m2.p);
    BdFiniteDifference(:, inputIndex) = ...
        (plusDerivative - minusDerivative) / (2 * finiteDifferenceStep);
end
bdAbsoluteError = max(abs(Bd - BdFiniteDifference), [], 'all');
bdRelativeError = norm(Bd - BdFiniteDifference, 'fro') / ...
    max(norm(Bd, 'fro'), eps);

numberActuatorStates = size(m3.Afull, 1) - size(Bd, 1);
BdFull = [Bd; zeros(numberActuatorStates, 2)];
disturbancePlant = ss(m3.Afull, [m3.Bfull, BdFull], ...
    m3.CfullMeas, zeros(4, 4), ...
    'StateName', m3.GfullMeas.StateName, ...
    'InputName', {'u1', 'u2', 'd1', 'd2'}, ...
    'OutputName', {'q1', 'q2', 'theta1', 'theta2'});
pathFrequencies = logspace(-2, 3, 301);
uPathDifference = freqresp(disturbancePlant(:, 1:2), ...
    pathFrequencies) - freqresp(m3.GfullMeas, pathFrequencies);
uPathMaximumError = max(abs(uPathDifference), [], 'all');

%% Small validation scenarios (not specification candidates)
[~, ~, ~, linearizationInfo] = ...
    sea_linearize_static_equilibrium_analytic(m2.qbar, m2.p);
referenceDegrees = spec.referenceAmplitudeScenariosDeg(:);
referenceRadians = deg2rad(referenceDegrees);
gravityAtEquilibrium = sea_gravity(m2.qbar, m2.p);
maximumGravityLinearizationRelativeError = zeros(size(referenceDegrees));
maximumGravityTorque = zeros(size(referenceDegrees));
directions = [1, 0; 0, 1; 1, 1; 1, -1].';
directions = directions ./ vecnorm(directions, 2, 1);
for amplitudeIndex = 1:numel(referenceRadians)
    for directionIndex = 1:size(directions, 2)
        for signValue = [-1, 1]
            deltaQ = signValue * referenceRadians(amplitudeIndex) * ...
                directions(:, directionIndex);
            exactDelta = sea_gravity(m2.qbar + deltaQ, m2.p) - ...
                gravityAtEquilibrium;
            linearDelta = linearizationInfo.gravityJacobian * deltaQ;
            relativeError = norm(exactDelta - linearDelta) / ...
                max(norm(exactDelta), eps);
            maximumGravityLinearizationRelativeError(amplitudeIndex) = ...
                max(maximumGravityLinearizationRelativeError(amplitudeIndex), ...
                relativeError);
            maximumGravityTorque(amplitudeIndex) = max( ...
                maximumGravityTorque(amplitudeIndex), norm(exactDelta, inf));
        end
    end
end
referenceNominalScenario = abs(referenceRadians - ...
    spec.referenceAmplitude) <= 10 * eps;
referenceScenarioTable = table(referenceDegrees, referenceRadians, ...
    maximumGravityLinearizationRelativeError, maximumGravityTorque, ...
    referenceNominalScenario, 'VariableNames', {'Degrees', 'Radians', ...
    'MaxGravityLinearizationRelativeError', 'MaxGravityTorque', ...
    'NominalScenario'});

disturbanceTorque = spec.disturbanceTorqueScenarios(:);
seaDeformationJoint1 = disturbanceTorque / m2.p.Ks(1, 1);
seaDeformationJoint2 = disturbanceTorque / m2.p.Ks(2, 2);
disturbanceNominalScenario = abs(disturbanceTorque - ...
    spec.disturbanceTorqueAmplitude) <= 10 * eps;
disturbanceScenarioTable = table(disturbanceTorque, ...
    seaDeformationJoint1, seaDeformationJoint2, ...
    disturbanceNominalScenario, 'VariableNames', {'Torque', ...
    'SEADeformationJoint1', 'SEADeformationJoint2', 'NominalScenario'});

nominalReferenceIndex = find(referenceNominalScenario, 1);
nominalDisturbanceIndex = find(disturbanceNominalScenario, 1);
validationMetrics.dynamic = frequencyCriteria;
validationMetrics.weights = weightInfo;
validationMetrics.disturbance.BdFiniteDifference = BdFiniteDifference;
validationMetrics.disturbance.maximumAbsoluteError = bdAbsoluteError;
validationMetrics.disturbance.relativeError = bdRelativeError;
validationMetrics.disturbance.uPathMaximumError = uPathMaximumError;
validationMetrics.scenarios.nominalReferenceLocalError = ...
    maximumGravityLinearizationRelativeError(nominalReferenceIndex);
validationMetrics.scenarios.nominalReferenceGravityTorque = ...
    maximumGravityTorque(nominalReferenceIndex);
validationMetrics.scenarios.nominalSEADeformation = [ ...
    seaDeformationJoint1(nominalDisturbanceIndex); ...
    seaDeformationJoint2(nominalDisturbanceIndex)];
validationMetrics.noControllerSynthesis = ...
    ~spec.controllerSynthesisAllowed && ~spec.useW3;

%% Figures and dataset
w1FigurePath = fullfile(figureDirectory, 'm5_weight_W1.png');
w2FigurePath = fullfile(figureDirectory, 'm5_weight_W2.png');
frequencyMapPath = fullfile(figureDirectory, 'm5_spec_frequency_map.png');
localPlotWeight(W1siso, spec.omegaB, 1 / spec.As, 1 / spec.Ms, ...
    'W_1: sensibilita e banda', w1FigurePath);
localPlotWeight(W2siso, spec.omegaU, 1 / spec.uScale, ...
    spec.controlWeightAlpha / spec.uScale, ...
    'W_2: normalizzazione del comando', w2FigurePath);
localPlotFrequencyMap(frequencyCriteria, m2.poles, spec, frequencyMapPath);

datasetPath = fullfile(dataDirectory, 'm5_performance_specs.mat');
save(datasetPath, 'spec', 'W1siso', 'W1', 'W2siso', 'W2', ...
    'frequencyCriteria', 'Bd', 'BdFull', 'disturbanceInputInfo', ...
    'disturbancePlant', 'referenceScenarioTable', ...
    'disturbanceScenarioTable', 'validationMetrics', '-v7');

asymptoteTolerance = 1e-7;
assert(frequencyCriteria.bandwidthVerified, 'M5:BandwidthChoice', ...
    'The declared omegaB is outside the M2/M3 frequency window.');
assert(weightInfo.W1.stable && weightInfo.W1.proper && ...
    weightInfo.W2.stable && weightInfo.W2.proper && weightInfo.finite, ...
    'M5:WeightProperties', 'M5 weights must be stable and proper.');
measuredAsymptotes = [weightInfo.W1.dcMeasured, ...
    weightInfo.W1.hfMeasured, weightInfo.W2.dcMeasured, ...
    weightInfo.W2.hfMeasured];
expectedAsymptotes = [weightInfo.W1.dcExpected, ...
    weightInfo.W1.hfExpected, weightInfo.W2.dcExpected, ...
    weightInfo.W2.hfExpected];
assert(max(abs(measuredAsymptotes - expectedAsymptotes)) <= ...
    asymptoteTolerance, 'M5:WeightAsymptotes', ...
    'A weight asymptote is inconsistent.');
assert(isequal(size(W1), [2, 2]) && isequal(size(W2), [2, 2]), ...
    'M5:MimoWeights', 'MIMO weights must be diagonal 2-by-2 systems.');
assert(bdAbsoluteError <= 1e-8 && bdRelativeError <= 1e-9 && ...
    uPathMaximumError <= 1e-10, 'M5:DisturbancePath', ...
    'The link disturbance path is inconsistent with the nonlinear model.');
assert(validationMetrics.noControllerSynthesis, ...
    'M5:ControllerOutOfScope', 'M5 must not synthesize a controller.');

fprintf('\n=== M5: specifiche e pesi dichiarati ===\n');
fprintf(['lambda_u,max=%.4g, omega_el,min=%.4g, BW_act=%.4g rad/s; ' ...
    'finestra omegaB=[%.4g, %.4g], scelta=%.4g rad/s.\n'], ...
    frequencyCriteria.lambdaUMax, frequencyCriteria.omegaElasticMin, ...
    frequencyCriteria.omegaActuator, frequencyCriteria.bandwidthMinimum, ...
    frequencyCriteria.bandwidthMaximum, spec.omegaB);
fprintf('W1(0)=1/As=%.4g; W1(inf)=1/Ms=%.4g.\n', ...
    weightInfo.W1.dcMeasured, weightInfo.W1.hfMeasured);
fprintf('W2(0)=1/uScale=%.4g; W2(inf)=alpha/uScale=%.4g.\n', ...
    weightInfo.W2.dcMeasured, weightInfo.W2.hfMeasured);
fprintf('[PASS] Scelte M5 verificate senza candidate grid o ranking.\n');

metrics.spec = spec;
metrics.frequencyCriteria = frequencyCriteria;
metrics.weightInfo = weightInfo;
metrics.Bd = Bd;
metrics.BdFull = BdFull;
metrics.disturbancePlant = disturbancePlant;
metrics.validation = validationMetrics;
metrics.referenceScenarioTable = referenceScenarioTable;
metrics.disturbanceScenarioTable = disturbanceScenarioTable;
metrics.datasetPath = datasetPath;
metrics.figurePaths = {w1FigurePath; w2FigurePath; frequencyMapPath};
end

function criteria = localFrequencyCriteria(m2, m3, spec)
unstablePoles = m2.poles(real(m2.poles) > 1e-8);
elasticPoles = m2.poles(imag(m2.poles) > 1e-8);
criteria.lambdaUMax = max(real(unstablePoles));
criteria.omegaElasticMin = min(abs(elasticPoles));
criteria.omegaActuator = m3.actuatorInfo.actuatorBandwidth;
criteria.bandwidthMinimum = ...
    spec.bandwidthUnstableMultiplier * criteria.lambdaUMax;
criteria.bandwidthMaximum = min( ...
    spec.bandwidthActuatorFraction * criteria.omegaActuator, ...
    spec.bandwidthElasticFraction * criteria.omegaElasticMin);
criteria.bandwidthVerified = spec.omegaB >= criteria.bandwidthMinimum && ...
    spec.omegaB <= criteria.bandwidthMaximum;
criteria.explanation = ...
    "omegaB is above the unstable scale and below actuator/elastic limits";
end

function localPlotWeight(weight, cornerFrequency, lowGain, highGain, ...
    plotTitle, filePath)
frequencies = logspace(-2, 3, 701);
magnitude = squeeze(abs(freqresp(weight, frequencies)));
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1000, 620]);
semilogx(frequencies, 20 * log10(magnitude), 'LineWidth', 2.2);
hold on;
yline(20 * log10(lowGain), '--', 'guadagno a bassa frequenza');
yline(20 * log10(highGain), ':', 'guadagno ad alta frequenza');
xline(cornerFrequency, '-.', 'frequenza di transizione');
grid on; box on;
xlabel('Frequenza [rad/s]'); ylabel('Modulo [dB]'); title(plotTitle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotFrequencyMap(criteria, m2Poles, spec, filePath)
elasticFrequencies = sort(abs(m2Poles(imag(m2Poles) > 1e-8)));
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1100, 560]);
axesHandle = axes(figureHandle);
hold(axesHandle, 'on'); set(axesHandle, 'XScale', 'log');
bandX = [criteria.bandwidthMinimum, criteria.bandwidthMaximum, ...
    criteria.bandwidthMaximum, criteria.bandwidthMinimum];
patch(axesHandle, bandX, [0.5, 0.5, 4.5, 4.5], ...
    [0.84, 0.92, 1.00], 'EdgeColor', 'none', 'FaceAlpha', 0.45);
localMapMarker(axesHandle, criteria.lambdaUMax, 4, 'poli instabili');
localMapMarker(axesHandle, spec.omegaB, 3, 'omega_B');
localMapMarker(axesHandle, spec.omegaU, 2, 'omega_U');
localMapMarker(axesHandle, criteria.omegaActuator, 1, 'banda attuatore');
for index = 1:numel(elasticFrequencies)
    localMapMarker(axesHandle, elasticFrequencies(index), 0, ...
        sprintf('modo elastico %d', index));
end
set(axesHandle, 'YTick', 0:4, 'YTickLabel', ...
    {'modi elastici', 'attuatore', 'W_2', 'W_1', 'instabilita'});
xlim(axesHandle, [4, 120]); ylim(axesHandle, [-0.5, 4.5]);
grid(axesHandle, 'on'); box(axesHandle, 'on');
xlabel(axesHandle, 'Frequenza [rad/s]');
title(axesHandle, 'Separazione delle scale di progetto');
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localMapMarker(axesHandle, frequency, level, label)
plot(axesHandle, frequency, level, 'o', 'MarkerSize', 8, ...
    'MarkerFaceColor', [0.1, 0.4, 0.75], ...
    'DisplayName', sprintf('%s: %.2f', label, frequency));
xline(axesHandle, frequency, ':', 'HandleVisibility', 'off');
end
