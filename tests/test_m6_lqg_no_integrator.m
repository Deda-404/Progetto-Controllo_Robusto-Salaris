function tests = test_m6_lqg_no_integrator
%TEST_M6_LQG_NO_INTEGRATOR M6 tuning, estimator and governance checks.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(projectRoot, 'src')));
addpath(genpath(fullfile(projectRoot, 'controllers')));
addpath(genpath(fullfile(projectRoot, 'analysis')));
datasetPath = fullfile(projectRoot, 'results', 'data', ...
    'm6_lqg_no_integrator.mat');
if ~isfile(datasetPath)
    validate_m6_lqg_no_integrator;
end
m3 = load(fullfile(projectRoot, 'results', 'data', ...
    'm3_nominal_actuated_plant.mat'));
m5 = load(fullfile(projectRoot, 'results', 'data', ...
    'm5_performance_specs.mat'));
m6 = load(datasetPath);
config = lqg_specs_m6;
baseline = diagnose_m6_baseline_cost(m3, m5, config);
coarse = tune_lqr_cost_m6(m3, m5, config, "coarse", baseline);
kalmanSelection = select_kalman_filter(m3, m5, coarse, config);
realization = build_lqg_no_integrator( ...
    m3, m5, coarse, kalmanSelection, config);

testCase.TestData.projectRoot = projectRoot;
testCase.TestData.m3 = m3;
testCase.TestData.m5 = m5;
testCase.TestData.m6 = m6;
testCase.TestData.config = config;
testCase.TestData.baseline = baseline;
testCase.TestData.coarse = coarse;
testCase.TestData.kalman = kalmanSelection;
testCase.TestData.realization = realization;
end

function testT1UsesFullFourteenStatePlant(testCase)
m3 = testCase.TestData.m3;
verifySize(testCase, m3.Afull, [14, 14]);
verifySize(testCase, m3.Bfull, [14, 2]);
verifySize(testCase, m3.CfullMeas, [4, 14]);
verifyEqual(testCase, testCase.TestData.m6.validationMetrics.model.stateCount, 14);
end

function testT2CostIsPhysicalSymmetricAndPSD(testCase)
m6 = testCase.TestData.m6;
verifyEqual(testCase, m6.Q, m6.Q.', 'AbsTol', 1e-12);
verifyGreaterThanOrEqual(testCase, min(eig(m6.Q)), -1e-8);
verifyTrue(testCase, all(isfinite(m6.Q), 'all'));
verifyEqual(testCase, m6.Ccost(:, 9:14), zeros(8, 6));
scales = m6.validationMetrics.cost.scales;
verifyEqual(testCase, scales.q, deg2rad(5), 'AbsTol', 1e-12);
verifyEqual(testCase, scales.qdot, 12 * deg2rad(5), 'AbsTol', 1e-12);
verifyEqual(testCase, scales.delta, 0.0125, 'AbsTol', 1e-12);
end

function testT3RDerivedFromUScaleAndPositiveDefinite(testCase)
m6 = testCase.TestData.m6;
spec = testCase.TestData.m5.spec;
config = testCase.TestData.config;
verifyEqual(testCase, m6.R, ...
    config.selected.rhoU / spec.uScale^2 * eye(2), 'AbsTol', 1e-14);
verifyGreaterThan(testCase, min(eig(m6.R)), 0);
end

function testT4LQRStabilizesFullPlant(testCase)
m3 = testCase.TestData.m3;
K = testCase.TestData.m6.K;
verifySize(testCase, K, [2, 14]);
verifyLessThan(testCase, max(real(eig(m3.Afull - m3.Bfull * K))), 0);
end

function testT5LQRSelectionIsDeterministicAndFromGrid(testCase)
coarse = testCase.TestData.coarse;
row = coarse.lqrCandidateTable(coarse.selectedIndex, :);
verifyTrue(testCase, row.FundamentalPass);
verifyTrue(testCase, row.TechnicallySelectable);
verifyTrue(testCase, row.Selected);
verifyEqual(testCase, row.Ranking, 1);
verifyTrue(testCase, ismember(row.Wq, coarse.grid.wq));
verifyTrue(testCase, ismember(row.Wdelta, coarse.grid.wdelta));
verifyTrue(testCase, ismember(row.WVelocity, coarse.grid.wVelocity));
verifyTrue(testCase, ismember(row.RhoU, coarse.grid.rhoU));
bestCrossRow = coarse.lqrCandidateTable( ...
    coarse.bestCrossCouplingIndex, :);
verifyTrue(testCase, bestCrossRow.FundamentalPass);
verifyLessThanOrEqual(testCase, bestCrossRow.WorstCrossCouplingPeakRatio, ...
    row.WorstCrossCouplingPeakRatio);
end

function testT6PrefilterTracksAtDC(testCase)
m3 = testCase.TestData.m3;
m6 = testCase.TestData.m6;
Acl = m3.Afull - m3.Bfull * m6.K;
Gdc = -m3.CfullQ * (Acl \ m3.Bfull);
verifySize(testCase, m6.Nr, [2, 2]);
verifyTrue(testCase, all(isfinite(m6.Nr), 'all'));
verifyEqual(testCase, Gdc * m6.Nr, eye(2), 'AbsTol', 1e-10);
end

function testT7NoiseCovariancesUseSelectedStandardDeviations(testCase)
m6 = testCase.TestData.m6;
kalman = testCase.TestData.kalman;
expectedQn = diag([kalman.sigmaD^2, kalman.sigmaD^2, ...
    kalman.sigmaU^2, kalman.sigmaU^2]);
expectedRn = kalman.sigmaYRad^2 * eye(4);
verifyEqual(testCase, m6.Qn, expectedQn, 'AbsTol', 1e-15);
verifyEqual(testCase, m6.Rn, expectedRn, 'AbsTol', 1e-15);
verifyGreaterThanOrEqual(testCase, min(eig(m6.Qn)), 0);
verifyGreaterThan(testCase, min(eig(m6.Rn)), 0);
end

function testT8KalmanEstimatorIsStable(testCase)
m3 = testCase.TestData.m3;
L = testCase.TestData.m6.L;
verifySize(testCase, L, [14, 4]);
verifyLessThan(testCase, ...
    max(real(eig(m3.Afull - L * m3.CfullMeas))), 0);
end

function testT9KalmanSelectionIsDeterministicAndFromGrid(testCase)
selection = testCase.TestData.kalman;
row = selection.kalmanCandidateTable(selection.selectedIndex, :);
config = testCase.TestData.config;
verifyTrue(testCase, row.Admissible);
verifyTrue(testCase, row.Selected);
verifyEqual(testCase, row.Ranking, 1);
verifyTrue(testCase, ismember(row.SigmaD, ...
    config.processDisturbanceSigmas));
verifyTrue(testCase, ismember(row.SigmaU, config.processInputSigmas));
verifyTrue(testCase, ismember(row.SigmaYDeg, ...
    config.measurementNoiseSigmasDeg));
end

function testT10SeparationPrinciple(testCase)
verifyLessThanOrEqual(testCase, ...
    testCase.TestData.realization.separationError, 1e-4);
verifyEqual(testCase, numel(testCase.TestData.m6.combinedPoles), 28);
end

function testT11ControllerOrderAndNoIntegrator(testCase)
realization = testCase.TestData.realization;
verifyEqual(testCase, realization.controllerOrder, 14);
verifyEqual(testCase, realization.integratorStateCount, 0);
verifySize(testCase, realization.Klqg.B, [14, 6]);
verifySize(testCase, realization.Klqg.C, [2, 14]);
end

function testT12TrackingMetricsAreFiniteAndEvaluated(testCase)
metrics = testCase.TestData.m6.trackingMetrics.lqg;
spec = testCase.TestData.m5.spec;
verifyTrue(testCase, all(isfinite(metrics{:,:}), 'all'));
verifyLessThanOrEqual(testCase, max(metrics.SettlingTime), ...
    spec.settlingTimeTarget);
verifyLessThanOrEqual(testCase, max(metrics.Overshoot), ...
    spec.overshootTarget);
verifyLessThanOrEqual(testCase, ...
    max(metrics.SteadyStateErrorRelative), ...
    spec.steadyStateTrackingTarget);
end

function testT13DisturbanceOffsetWithoutIntegratorIsQuantified(testCase)
metrics = testCase.TestData.m6.disturbanceMetrics.lqg;
verifyTrue(testCase, all(isfinite(metrics{:,:}), 'all'));
verifyGreaterThan(testCase, max(abs(metrics.SteadyStateOffset)), 0);
end

function testT14NoiseMetricAndSeedAreReproducible(testCase)
m6 = testCase.TestData.m6;
verifyTrue(testCase, isfinite( ...
    testCase.TestData.kalman.h2NoiseAmplification));
verifyEqual(testCase, m6.noiseMetrics.seed, 20260826);
verifyEqual(testCase, m6.validationMetrics.noise.repeatError, 0);
verifyTrue(testCase, m6.validationMetrics.noise.repeatMetricsEqual);
verifyTrue(testCase, all(isfinite( ...
    m6.noiseMetrics.rmsTrackingErrorByJoint)));
verifyTrue(testCase, all(isfinite( ...
    m6.noiseMetrics.rmsEstimationErrorQByJoint)));
verifyTrue(testCase, all(isfinite( ...
    m6.noiseMetrics.rmsControlVariationByJoint)));
verifyTrue(testCase, isfinite(m6.noiseMetrics.rmsTrackingError));
verifyTrue(testCase, isfinite(m6.noiseMetrics.rmsEstimationErrorQ));
verifyTrue(testCase, isfinite(m6.noiseMetrics.rmsControlVariation));
end

function testT15NoVelocityIsDirectlyMeasured(testCase)
C = testCase.TestData.m3.CfullMeas;
verifyEqual(testCase, C(:, [3:4, 7:8]), zeros(4, 4));
verifyFalse(testCase, ...
    testCase.TestData.m6.validationMetrics.measurements.velocityMeasured);
end

function testT16SynthesisUsesNominalNumericPlantOnly(testCase)
m6 = testCase.TestData.m6;
verifyTrue(testCase, m6.validationMetrics.nominalSynthesisOnly);
files = { ...
    fullfile(testCase.TestData.projectRoot, 'controllers', 'lqg', ...
        'build_lqr_state_cost.m'), ...
    fullfile(testCase.TestData.projectRoot, 'controllers', 'lqg', ...
        'tune_lqr_cost_m6.m'), ...
    fullfile(testCase.TestData.projectRoot, 'controllers', 'lqg', ...
        'select_kalman_filter.m'), ...
    fullfile(testCase.TestData.projectRoot, 'controllers', 'lqg', ...
        'build_lqg_no_integrator.m')};
for fileIndex = 1:numel(files)
    source = fileread(files{fileIndex});
    verifyEmpty(testCase, regexp(source, ...
        '\<(ureal|ultidyn|uss|musyn|hinfsyn|mixsyn)\s*\(', 'once'));
end
end

function testT17RegressionM0ThroughM5(testCase)
testFiles = { ...
    'test_m0_workspace.m', 'test_m1_nonlinear_model.m', ...
    'test_m2_equilibrium_linearization.m', ...
    'test_m3_actuator_dynamics.m', ...
    'test_m4_uncertainty_model.m', ...
    'test_m5_performance_specs.m'};
testsDirectory = fullfile(testCase.TestData.projectRoot, 'tests');
suite = testsuite(fullfile(testsDirectory, testFiles{1}));
for fileIndex = 2:numel(testFiles)
    suite = [suite, testsuite(fullfile( ...
        testsDirectory, testFiles{fileIndex}))]; %#ok<AGROW>
end
results = run(suite);
verifyEqual(testCase, numel(results), 66);
verifyTrue(testCase, all([results.Passed]));
end

function testT18DocumentationGovernance(testCase)
diary = fileread(fullfile(testCase.TestData.projectRoot, 'docs', ...
    'DIARIO_DI_BORDO.md'));
verifyTrue(testCase, contains(diary, 'Responsabile:** Alessio'));
verifyEmpty(testCase, regexp(diary, '(?m)^\*\*Autore:', 'once'));
end

function testT19FailedRhoOnlyBaselineRemainsRecorded(testCase)
baseline = testCase.TestData.baseline;
verifyEqual(testCase, baseline.rhoU, 0.5);
verifyGreaterThan(testCase, ...
    max(real(baseline.regulatorPoles)), -5);
diary = fileread(fullfile(testCase.TestData.projectRoot, 'docs', ...
    'DIARIO_DI_BORDO.md'));
verifyTrue(testCase, contains(diary, ...
    'Arresto al quality gate LQR M6'));
verifyTrue(testCase, contains(diary, '1.222'));
end

function testT20RetuningChangesOnlyDimensionlessPriorities(testCase)
m3 = testCase.TestData.m3;
spec = testCase.TestData.m5.spec;
[~, ~, baselineScales] = build_lqr_state_cost(m3, spec);
[~, ~, selectedScales] = build_lqr_state_cost( ...
    m3, spec, testCase.TestData.coarse.selectedPriorities);
verifyEqual(testCase, selectedScales, baselineScales);
verifyEqual(testCase, spec.referenceAmplitude, deg2rad(5), ...
    'AbsTol', 1e-12);
verifyEqual(testCase, spec.omegaB, 12);
verifyEqual(testCase, spec.uScale, 12);
verifyEqual(testCase, spec.settlingTimeTarget, 0.8);
end

function testT21CoarseCandidateTableIsDeterministic(testCase)
repeat = tune_lqr_cost_m6(testCase.TestData.m3, ...
    testCase.TestData.m5, testCase.TestData.config, "coarse", ...
    testCase.TestData.baseline);
verifyEqual(testCase, repeat.lqrCandidateTable, ...
    testCase.TestData.coarse.lqrCandidateTable);
end

function testT22NoCandidateIsPreselected(testCase)
modifiedConfig = testCase.TestData.config;
modifiedConfig.selected.wq = 999;
modifiedConfig.selected.wdelta = 999;
modifiedConfig.selected.wqdot = 999;
modifiedConfig.selected.wthetaDot = 999;
modifiedConfig.selected.rhoU = 999;
repeat = tune_lqr_cost_m6(testCase.TestData.m3, ...
    testCase.TestData.m5, modifiedConfig, "coarse", ...
    testCase.TestData.baseline);
verifyEqual(testCase, repeat.lqrCandidateTable, ...
    testCase.TestData.coarse.lqrCandidateTable);
verifyEqual(testCase, repeat.selectedIndex, ...
    testCase.TestData.coarse.selectedIndex);
end

function testT23SelectedPrioritiesBelongToCoarseGrid(testCase)
selection = testCase.TestData.coarse;
priorities = selection.selectedPriorities;
verifyTrue(testCase, ismember(priorities.wq, selection.grid.wq));
verifyTrue(testCase, ismember(priorities.wdelta, ...
    selection.grid.wdelta));
verifyTrue(testCase, ismember(priorities.wqdot, ...
    selection.grid.wVelocity));
verifyEqual(testCase, priorities.wqdot, priorities.wthetaDot);
verifyTrue(testCase, ismember(selection.rhoU, selection.grid.rhoU));
end

function testT24M5TargetsRemainUnchanged(testCase)
spec = testCase.TestData.m5.spec;
verifyEqual(testCase, spec.settlingTimeTarget, 0.8);
verifyEqual(testCase, spec.omegaB, 12);
verifyEqual(testCase, spec.referenceAmplitude, deg2rad(5), ...
    'AbsTol', 1e-12);
verifyEqual(testCase, spec.uScale, 12);
end

function testT25ExtendedGridIsConditionalAndWasNotExecuted(testCase)
verifyFalse(testCase, testCase.TestData.m6.extendedGridExecuted);
verifyNotEmpty(testCase, testCase.TestData.coarse.selectedIndex);
verifyEqual(testCase, height(testCase.TestData.m6.extendedCandidateTable), 0);
end

function testT26KalmanCannotRunBeforeLQRSelection(testCase)
verifyError(testCase, @() select_kalman_filter( ...
    testCase.TestData.m3, testCase.TestData.m5, struct, ...
    testCase.TestData.config), 'M6Kalman:LQRNotSelected');
end
