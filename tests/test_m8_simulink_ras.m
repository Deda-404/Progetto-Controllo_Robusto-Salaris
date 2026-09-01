function tests = test_m8_simulink_ras
%TEST_M8_SIMULINK_RAS M8 nonlinear Simulink and empirical-RAS gate.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(projectRoot, 'src')));
addpath(genpath(fullfile(projectRoot, 'controllers')));
addpath(genpath(fullfile(projectRoot, 'analysis')));
addpath(genpath(fullfile(projectRoot, 'simulink')));
datasetPath = fullfile(projectRoot, 'results', 'data', ...
    'm8_lqg_nonlinear_ras.mat');
if ~isfile(datasetPath)
    validate_m8_simulink_ras(true);
end
testCase.TestData.projectRoot = projectRoot;
testCase.TestData.m8 = load(datasetPath);
testCase.TestData.m6 = load(fullfile(projectRoot, 'results', 'data', ...
    'm6_lqg_no_integrator.mat'));
end

function teardownOnce(~)
if bdIsLoaded('SEA_LQG_nonlinear')
    close_system('SEA_LQG_nonlinear', 0);
end
end

function testT1ModelLoadsWithoutErrors(testCase)
modelPath = fullfile(testCase.TestData.projectRoot, 'simulink', ...
    'SEA_LQG_nonlinear.slx');
verifyTrue(testCase, isfile(modelPath));
load_system(modelPath);
verifyTrue(testCase, bdIsLoaded('SEA_LQG_nonlinear'));
end

function testT2NoBaseWorkspaceDependency(testCase)
load_system(fullfile(testCase.TestData.projectRoot, 'simulink', ...
    'SEA_LQG_nonlinear.slx'));
variables = Simulink.findVars('SEA_LQG_nonlinear');
verifyEmpty(testCase, variables);
verifyFalse(testCase, ...
    testCase.TestData.m8.modelMetadata.baseWorkspaceDependency);
end

function testT3PlantUsesValidatedNonlinearEquations(testCase)
source = fileread(fullfile(testCase.TestData.projectRoot, 'simulink', ...
    'm8_nonlinear_sea_sfun.m'));
verifyTrue(testCase, contains(source, ...
    'sea_nonlinear_rhs_with_link_disturbance'));
verifyFalse(testCase, contains(source, 'Afull'));
verifyEqual(testCase, testCase.TestData.m8.modelMetadata.nonlinearPlantSource, ...
    "sea_nonlinear_rhs_with_link_disturbance");
end

function testT4CompletePhysicalPlantHasFourteenStates(testCase)
metadata = testCase.TestData.m8.modelMetadata;
verifyEqual(testCase, metadata.mechanicalStateCount, 8);
verifyEqual(testCase, metadata.actuatorStateCount, 6);
verifyEqual(testCase, metadata.physicalPlantStateCount, 14);
verifyEqual(testCase, metadata.totalContinuousStateCount, 28);
end

function testT5ControllerIsExactlyM6(testCase)
m8 = testCase.TestData.m8;
m6 = testCase.TestData.m6;
verifyEqual(testCase, m8.controllerMetadata.K, m6.K);
verifyEqual(testCase, m8.controllerMetadata.L, m6.L);
verifyEqual(testCase, m8.controllerMetadata.Nr, m6.Nr);
verifyEqual(testCase, m8.controllerMetadata.controllerOrder, 14);
verifyFalse(testCase, m8.controllerMetadata.retunedInM8);
end

function testT6NonlinearEquilibriumRemainsStationary(testCase)
validation = testCase.TestData.m8.equilibriumValidation;
config = testCase.TestData.m8.simulationConfig;
verifyTrue(testCase, validation.passed);
verifyLessThanOrEqual(testCase, validation.maxQError, ...
    config.equilibrium.positionTolerance);
verifyLessThanOrEqual(testCase, validation.maxThetaError, ...
    config.equilibrium.positionTolerance);
verifyLessThanOrEqual(testCase, validation.maxControlError, ...
    config.equilibrium.controlTolerance);
end

function testT7TwoDegreeStepsAreFiniteAndStable(testCase)
metrics = testCase.TestData.m8.tracking2deg.metrics;
verifyTrue(testCase, all(isfinite(metrics{:,:}), 'all'));
verifyLessThan(testCase, max(metrics.SteadyStateErrorRelative), 0.05);
end

function testT8FiveDegreeStepsAreFiniteAndStable(testCase)
metrics = testCase.TestData.m8.tracking5deg.metrics;
verifyTrue(testCase, all(isfinite(metrics{:,:}), 'all'));
verifyLessThan(testCase, max(metrics.SteadyStateErrorRelative), 0.05);
end

function testT9LtiNonlinearComparisonWasGenerated(testCase)
comparison = testCase.TestData.m8.ltiVsNonlinearMetrics;
verifyEqual(testCase, height(comparison), 6);
verifyTrue(testCase, all(isfinite(comparison{:,:}), 'all'));
verifyGreaterThanOrEqual(testCase, ...
    min(comparison.MaxQDifference), 0);
end

function testT10PhysicalLinkDisturbanceIsApplied(testCase)
metrics = testCase.TestData.m8.disturbanceMetrics;
verifyEqual(testCase, unique(metrics.AmplitudeNm), [0.25; 0.5; 1]);
verifyEqual(testCase, unique(metrics.Joint), [1; 2]);
verifyGreaterThan(testCase, ...
    min(abs(metrics.SteadyStateOffsetRad)), 0);
source = fileread(fullfile(testCase.TestData.projectRoot, 'simulink', ...
    'm8_nonlinear_sea_sfun.m'));
verifyTrue(testCase, contains(source, 'InputPort(2).Data'));
end

function testT11NoiseIsSeededAndReproducible(testCase)
noise = testCase.TestData.m8.noiseMetrics;
verifyEqual(testCase, noise.seed, 20260826);
verifyEqual(testCase, noise.repeatError, 0);
verifyTrue(testCase, all(isfinite([noise.rmsTrackingError; ...
    noise.rmsEstimationErrorQ; noise.rmsControlVariation])));
end

function testT12RasCriterionIsDeterministic(testCase)
config = testCase.TestData.m8.simulationConfig.ras;
verifyEqual(testCase, config.tailFraction, 0.10);
verifyEqual(testCase, config.positionToleranceDeg, 0.5);
verifyEqual(testCase, config.linkVelocityTolerance, 0.02);
verifyEqual(testCase, config.motorPositionToleranceDeg, 0.5);
verifyEqual(testCase, config.motorVelocityTolerance, 0.05);
source = fileread(fullfile(testCase.TestData.projectRoot, 'analysis', ...
    'ras', 'estimate_lqg_ras.m'));
verifyEmpty(testCase, regexp(source, '\<rng\s*\(', 'once'));
end

function testT13ConvergenceDivergenceOrWholeBoxDocumented(testCase)
m8 = testCase.TestData.m8;
bothClasses = m8.rasMetrics.numberConvergent > 0 && ...
    m8.rasMetrics.numberDivergent > 0;
wholeBox = m8.rasMetrics.allRadialEndpointsConvergent;
verifyTrue(testCase, bothClasses || wholeBox);
if wholeBox
    verifyTrue(testCase, all(m8.rasBoundary.SearchBoxLimited));
end
end

function testT14RasBoundaryIsRegenerable(testCase)
m8 = testCase.TestData.m8;
verifyEqual(testCase, height(m8.rasBoundary), ...
    m8.simulationConfig.ras.numberDirections);
verifyTrue(testCase, all(isfinite(m8.rasBoundary{:,:}), 'all'));
verifyEqual(testCase, m8.rasBoundary.DirectionDeg, ...
    (0:10:350).', 'AbsTol', 1e-12);
end

function testT15NoInventedSaturation(testCase)
verifyFalse(testCase, testCase.TestData.m8.simulationConfig.saturationEnabled);
verifyFalse(testCase, testCase.TestData.m8.modelMetadata.saturationEnabled);
verifyEqual(testCase, ...
    testCase.TestData.m8.rasInitialConditions.searchBoxMeaning, ...
    "computational boundary, not a saturation or physical limit");
end

function testT16NoM6OrM7TuningInM8(testCase)
metadata = testCase.TestData.m8.controllerMetadata;
verifyFalse(testCase, metadata.retunedInM8);
verifyEqual(testCase, metadata.m7Status, ...
    "PARTIAL - frozen; no further tuning");
files = {fullfile(testCase.TestData.projectRoot, 'analysis', 'ras', ...
    'validate_m8_simulink_ras.m'), fullfile( ...
    testCase.TestData.projectRoot, 'simulink', ...
    'build_m8_simulink_model.m')};
for index = 1:numel(files)
    source = fileread(files{index});
    verifyEmpty(testCase, regexp(source, ...
        '\<(lqr|lqi|kalman|care|lqe|tune_lqr_cost_m6)\s*\(', 'once'));
end
end

function testT17M0ThroughM7RegressionStateIsPreserved(testCase)
required = {'m2_linearization_nominal.mat', ...
    'm3_nominal_actuated_plant.mat', ...
    'm4_uncertain_plant.mat', 'm5_performance_specs.mat', ...
    'm6_lqg_no_integrator.mat', 'm7_lqg_integral.mat', ...
    'm7_augmented_cost_feasibility.mat'};
dataDirectory = fullfile(testCase.TestData.projectRoot, 'results', 'data');
for index = 1:numel(required)
    verifyTrue(testCase, isfile(fullfile(dataDirectory, required{index})));
end
status = fileread(fullfile(testCase.TestData.projectRoot, 'docs', ...
    'PROJECT_STATUS.md'));
verifyTrue(testCase, contains(status, 'M7'));
verifyTrue(testCase, contains(status, 'PARTIAL'));
end

function testT18DocumentationGovernance(testCase)
diary = fileread(fullfile(testCase.TestData.projectRoot, 'docs', ...
    'DIARIO_DI_BORDO.md'));
verifyTrue(testCase, contains(diary, 'Responsabile:** Alessio'));
verifyEmpty(testCase, regexp(diary, '(?m)^\*\*Autore:', 'once'));
end
