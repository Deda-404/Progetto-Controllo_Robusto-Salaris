function tests = test_m6_lqg_no_integrator
%TEST_M6_LQG_NO_INTEGRATOR Public behavior of the approved LQG design.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
root = fileparts(fileparts(mfilename('fullpath')));
metrics = validate_m6_lqg_no_integrator;
m3 = load(fullfile(root, 'results', 'data', ...
    'm3_nominal_actuated_plant.mat'));
m5 = load(fullfile(root, 'results', 'data', ...
    'm5_performance_specs.mat'));
m6 = load(fullfile(root, 'results', 'data', ...
    'm6_lqg_no_integrator.mat'));
testCase.TestData = struct('root', root, 'metrics', metrics, ...
    'm3', m3, 'm5', m5, 'm6', m6);
end

function testUsesFullNominalPlant(testCase)
m3 = testCase.TestData.m3;
verifySize(testCase, m3.Afull, [14, 14]);
verifySize(testCase, m3.Bfull, [14, 2]);
verifySize(testCase, m3.CfullMeas, [4, 14]);
verifyTrue(testCase, ...
    testCase.TestData.m6.validationMetrics.nominalSynthesisOnly);
end

function testBrysonNormalizedStateCost(testCase)
m6 = testCase.TestData.m6;
verifyEqual(testCase, m6.Q, m6.Q.', 'AbsTol', 1e-12);
verifyGreaterThanOrEqual(testCase, min(eig(m6.Q)), -1e-8);
verifyEqual(testCase, m6.Ccost(:, 9:14), zeros(8, 6));
scales = m6.validationMetrics.cost.scales;
verifyGreaterThan(testCase, [scales.q; scales.qdot; ...
    scales.delta; scales.thetadot], zeros(4, 1));
end

function testControlCostComesFromUScale(testCase)
m5 = testCase.TestData.m5;
m6 = testCase.TestData.m6;
config = lqg_specs_m6;
verifyEqual(testCase, m6.R, ...
    config.lqr.rhoU / m5.spec.uScale^2 * eye(2), 'AbsTol', 1e-15);
verifyGreaterThan(testCase, min(eig(m6.R)), 0);
end

function testLqrStabilizesAndTracksAtDc(testCase)
m3 = testCase.TestData.m3;
m6 = testCase.TestData.m6;
Acl = m3.Afull - m3.Bfull * m6.K;
verifyTrue(testCase, all(real(eig(Acl)) < -1e-8));
Gdc = -m3.CfullQ * (Acl \ m3.Bfull);
verifyEqual(testCase, Gdc * m6.Nr, eye(2), 'AbsTol', 1e-10);
end

function testDeclaredKalmanCovariances(testCase)
m6 = testCase.TestData.m6;
config = lqg_specs_m6;
sigmaY = deg2rad(config.kalman.sigmaMeasurementDeg);
verifyEqual(testCase, m6.Qn, 0.1^2 * eye(4), 'AbsTol', 1e-15);
verifyEqual(testCase, m6.Rn, sigmaY^2 * eye(4), 'AbsTol', 1e-15);
verifyGreaterThan(testCase, min(eig(m6.Rn)), 0);
end

function testEstimatorAndSeparationPrinciple(testCase)
m3 = testCase.TestData.m3;
m6 = testCase.TestData.m6;
verifyTrue(testCase, all(real(eig(m3.Afull - ...
    m6.L * m3.CfullMeas)) < -1e-8));
verifyLessThanOrEqual(testCase, ...
    m6.validationMetrics.separation.error, 1e-4);
verifyEqual(testCase, numel(m6.combinedPoles), 28);
end

function testControllerOrderAndNoIntegrator(testCase)
m6 = testCase.TestData.m6;
verifyEqual(testCase, order(m6.Klqg), 14);
verifyEqual(testCase, ...
    m6.validationMetrics.controller.integratorStateCount, 0);
end

function testMainTrackingPerformance(testCase)
m6 = testCase.TestData.m6;
m5 = testCase.TestData.m5;
tracking = m6.trackingMetrics.lqg;
verifyLessThanOrEqual(testCase, tracking.SettlingTime, ...
    m5.spec.settlingTimeTarget);
verifyLessThanOrEqual(testCase, tracking.Overshoot, ...
    m5.spec.overshootTarget);
verifyLessThanOrEqual(testCase, tracking.SteadyStateErrorRelative, ...
    m5.spec.steadyStateTrackingTarget);
end

function testDisturbanceAndSeededNoiseAreQuantified(testCase)
m6 = testCase.TestData.m6;
verifyTrue(testCase, all(isfinite( ...
    m6.disturbanceMetrics.lqg.SteadyStateOffset)));
verifyEqual(testCase, m6.noiseMetrics.seed, 20260826);
verifyEqual(testCase, m6.validationMetrics.noise.repeatError, 0);
verifyTrue(testCase, isfinite(m6.noiseMetrics.rmsTrackingError));
end

function testDirectDesignReproducesDataset(testCase)
config = lqg_specs_m6;
lqrDesign = design_lqr_m6( ...
    testCase.TestData.m3, testCase.TestData.m5, config);
kalmanDesign = design_kalman_m6(testCase.TestData.m3, ...
    testCase.TestData.m5, lqrDesign, config);
verifyEqual(testCase, lqrDesign.K, testCase.TestData.m6.K, ...
    'AbsTol', 1e-12);
verifyEqual(testCase, kalmanDesign.L, testCase.TestData.m6.L, ...
    'AbsTol', 1e-12);
end

function testGridSearchFilesWereRemoved(testCase)
oldFiles = { ...
    fullfile('controllers', 'lqg', 'tune_lqr_cost_m6.m'), ...
    fullfile('controllers', 'lqg', 'select_kalman_filter.m'), ...
    fullfile('controllers', 'lqg', 'select_lqr_no_integrator.m')};
for index = 1:numel(oldFiles)
    verifyFalse(testCase, isfile(fullfile( ...
        testCase.TestData.root, oldFiles{index})));
end
end
