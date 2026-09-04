function sensitivity = analyze_kalman_sensitivity_m6( ...
    m3Data, m5Data, lqrDesign, config)
%ANALYZE_KALMAN_SENSITIVITY_M6 Compare three transparent noise hypotheses.
%   The final covariance is not retuned. The two neighboring cases show
%   how halving or doubling the assumed encoder standard deviation changes
%   observer speed, estimation error and control-noise amplification.

arguments
    m3Data (1, 1) struct
    m5Data (1, 1) struct
    lqrDesign (1, 1) struct
    config (1, 1) struct = lqg_specs_m6
end

sigmaYDeg = config.kalman.sensitivityMeasurementDeg(:);
numberCases = numel(sigmaYDeg);
caseName = strings(numberCases, 1);
qOverRRelative = zeros(numberCases, 1);
estimatorSpeedRatio = zeros(numberCases, 1);
gainFrobeniusNorm = zeros(numberCases, 1);
h2NoiseAmplification = zeros(numberCases, 1);
rmsEstimationErrorQ = zeros(numberCases, 1);
rmsControlVariation = zeros(numberCases, 1);
selected = false(numberCases, 1);

for index = 1:numberCases
    caseConfig = config;
    caseConfig.kalman.sigmaMeasurementDeg = sigmaYDeg(index);
    kalmanDesign = design_kalman_m6( ...
        m3Data, m5Data, lqrDesign, caseConfig);
    realization = build_lqg_no_integrator( ...
        m3Data, m5Data, lqrDesign, kalmanDesign, caseConfig);
    [rmsEstimationErrorQ(index), rmsControlVariation(index)] = ...
        localNoiseMetrics(realization.lqgClosedLoop, ...
        kalmanDesign.sigmaYRad, m5Data.spec, caseConfig);
    qOverRRelative(index) = ...
        (config.kalman.sigmaMeasurementDeg / sigmaYDeg(index))^2;
    estimatorSpeedRatio(index) = kalmanDesign.estimatorSpeedRatio;
    gainFrobeniusNorm(index) = kalmanDesign.gainFrobeniusNorm;
    h2NoiseAmplification(index) = kalmanDesign.h2NoiseAmplification;
    selected(index) = abs(sigmaYDeg(index) - ...
        config.kalman.sigmaMeasurementDeg) <= eps;
    if sigmaYDeg(index) < config.kalman.sigmaMeasurementDeg
        caseName(index) = "misura-piu-affidabile";
    elseif selected(index)
        caseName(index) = "nominale";
    else
        caseName(index) = "misura-piu-rumorosa";
    end
end

sensitivity.table = table(caseName, sigmaYDeg, qOverRRelative, ...
    estimatorSpeedRatio, gainFrobeniusNorm, h2NoiseAmplification, ...
    rmsEstimationErrorQ, rmsControlVariation, selected, ...
    'VariableNames', {'Case', 'SigmaYDeg', 'QOverRRelative', ...
    'EstimatorSpeedRatio', 'GainFrobeniusNorm', ...
    'H2NoiseAmplification', 'RmsEstimationErrorQ', ...
    'RmsControlVariation', 'Selected'});
sensitivity.interpretation = [ ...
    "smaller Rn relative to Qn trusts measurements more and speeds the observer"; ...
    "larger Rn relative to Qn filters measurements more strongly"; ...
    "the multivariable effect also depends on G, C and the Riccati solution"];
end

function [rmsEstimationErrorQ, rmsControlVariation] = ...
    localNoiseMetrics(system, sigmaYRad, spec, config)
rng(config.noiseSeed, 'twister');
time = (0:config.simulationTimeStep:config.noiseHorizon).';
input = zeros(numel(time), 8);
input(:, 1) = spec.referenceAmplitude;
input(:, 5:8) = sigmaYRad * randn(numel(time), 4);
noisyOutput = lsim(system, input, time);
input(:, 5:8) = 0;
deterministicOutput = lsim(system, input, time);
rmsEstimationErrorQ = sqrt(mean(noisyOutput(:, 7:8).^2, 'all'));
rmsControlVariation = sqrt(mean((noisyOutput(:, 5:6) - ...
    deterministicOutput(:, 5:6)).^2, 'all'));
end
