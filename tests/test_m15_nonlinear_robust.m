function tests = test_m15_nonlinear_robust
%TEST_M15_NONLINEAR_ROBUST Sixty dedicated M15 governance/numerical tests.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
root = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(root, 'src')));
addpath(genpath(fullfile(root, 'controllers')));
addpath(genpath(fullfile(root, 'analysis')));
addpath(genpath(fullfile(root, 'simulink')));
path = fullfile(root, 'results', 'data', ...
    'm15_nonlinear_robust_validation.mat');
if ~isfile(path), validate_m15_nonlinear_robust(false); end
testCase.TestData.root = root;
testCase.TestData.path = path;
testCase.TestData.m15 = load(path);
testCase.TestData.m8 = load(fullfile(root, 'results', 'data', ...
    'm8_lqg_nonlinear_ras.mat'));
testCase.TestData.m10 = load(fullfile(root, 'results', 'data', ...
    'm10_hinfsyn_nominal.mat'));
testCase.TestData.m13 = load(fullfile(root, 'results', 'data', ...
    'm13_musyn_dk.mat'));
end

function teardownOnce(~)
if bdIsLoaded('SEA_ROBUST_nonlinear')
    close_system('SEA_ROBUST_nonlinear', 0);
end
end

function testT01BaselineIsM14Merge(testCase)
verifyEqual(testCase, testCase.TestData.m15.config.baselineCommit, ...
    "c51142e624adea610e72d16ddfd764008cb65371");
end
function testT02Pr19RecordedMerged(testCase)
c = testCase.TestData.m15.config;
verifyEqual(testCase, c.mergedPullRequest, 19);
verifyEqual(testCase, c.mergedPullRequestState, "MERGED");
end
function testT03KhinfLoadedFromM10(testCase)
a = testCase.TestData.m15.controllerAudits(1);
verifyEqual(testCase, a.sourceArtifact, ...
    "results/data/m10_hinfsyn_nominal.mat");
verifyTrue(testCase, a.sourceIdentity);
end
function testT04KhinfOrderMatchesArtifact(testCase)
a = testCase.TestData.m15.controllerAudits(1);
verifyEqual(testCase, a.order, order(testCase.TestData.m10.Khinf));
verifyEqual(testCase, a.order, 18);
end
function testT05KmuLoadedFromM13(testCase)
a = testCase.TestData.m15.controllerAudits(2);
verifyEqual(testCase, a.sourceArtifact, ...
    "results/data/m13_musyn_dk.mat");
verifyTrue(testCase, a.sourceIdentity);
verifyTrue(testCase, a.bestIterationIdentity);
end
function testT06KmuOrderMatchesArtifact(testCase)
a = testCase.TestData.m15.controllerAudits(2);
verifyEqual(testCase, a.order, order(testCase.TestData.m13.Kmu));
verifyEqual(testCase, a.order, 52);
end
function testT07ControllerMatricesUnchanged(testCase)
sources = {testCase.TestData.m10.Khinf, testCase.TestData.m13.Kmu};
for index = 1:2
    [A, B, C, D] = ssdata(sources{index});
    audit = testCase.TestData.m15.controllerAudits(index);
    verifyEqual(testCase, audit.A, A);
    verifyEqual(testCase, audit.B, B);
    verifyEqual(testCase, audit.C, C);
    verifyEqual(testCase, audit.D, D);
end
end
function testT08NoSynthesisPerformed(testCase)
verifyFalse(testCase, testCase.TestData.m15.metadata.synthesisPerformed);
verifyFalse(testCase, ...
    testCase.TestData.m15.metadata.controllerTuningPerformed);
end
function testT09M1NonlinearFunctionReused(testCase)
verifyTrue(testCase, testCase.TestData.m15.plantAudit.m1FunctionReused);
verifyEqual(testCase, testCase.TestData.m15.modelMetadata.nonlinearPlantSource, ...
    "sea_nonlinear_rhs_with_link_disturbance");
end
function testT10M3ActuatorsReused(testCase)
verifyTrue(testCase, testCase.TestData.m15.plantAudit.m3ActuatorSourceReused);
verifyEqual(testCase, testCase.TestData.m15.modelMetadata.actuatorStateCount, 6);
end
function testT11M3EquilibriumReused(testCase)
verifyTrue(testCase, testCase.TestData.m15.plantAudit.xbarIdentity);
verifyTrue(testCase, testCase.TestData.m15.plantAudit.taubarIdentity);
verifyTrue(testCase, ...
    testCase.TestData.m15.plantAudit.actuatorEquilibriumIdentity);
end
function testT12M8SolverReused(testCase)
verifyTrue(testCase, testCase.TestData.m15.solverMetadata.identical);
verifyTrue(testCase, ...
    testCase.TestData.m15.solverMetadata.inputTimeStepIdentical);
end
function testT13NoBaseWorkspaceDependency(testCase)
root = testCase.TestData.root;
load_system(fullfile(root, 'simulink', 'SEA_ROBUST_nonlinear.slx'));
verifyEmpty(testCase, Simulink.findVars('SEA_ROBUST_nonlinear'));
verifyFalse(testCase, ...
    testCase.TestData.m15.modelMetadata.baseWorkspaceDependency);
end
function testT14QOnlyRobustMeasurements(testCase)
verifyTrue(testCase, testCase.TestData.m15.modelMetadata.qOnlyMeasurements);
end
function testT15ErrorConvention(testCase)
verifyEqual(testCase, testCase.TestData.m15.modelMetadata.errorConvention, ...
    "e=r-q");
end
function testT16EquilibriumTorqueAdded(testCase)
verifyTrue(testCase, ...
    testCase.TestData.m15.modelMetadata.equilibriumTorqueAdded);
end
function testT17NoPrefilter(testCase)
verifyFalse(testCase, testCase.TestData.m15.metadata.prefilterUsed);
verifyFalse(testCase, testCase.TestData.m15.config.prefilterEnabled);
end
function testT18NoIntegralAugmentation(testCase)
verifyFalse(testCase, ...
    testCase.TestData.m15.metadata.integralAugmentationUsed);
verifyFalse(testCase, ...
    testCase.TestData.m15.config.integralAugmentationEnabled);
end
function testT19NoSaturationClipping(testCase)
verifyFalse(testCase, testCase.TestData.m15.metadata.saturationEnabled);
verifyFalse(testCase, testCase.TestData.m15.modelMetadata.saturationEnabled);
end
function testT20UScaleOnlyNormalization(testCase)
verifyEqual(testCase, testCase.TestData.m15.config.uScaleMeaning, ...
    "performance normalization; not a certified actuator saturation");
end
function testT21EquilibriumKhinf(testCase)
verifyTrue(testCase, testCase.TestData.m15.equilibriumResults(1).passed);
verifyEqual(testCase, ...
    testCase.TestData.m15.qualityGate.equilibriumKhinf, "PASS");
end
function testT22EquilibriumKmu(testCase)
verifyTrue(testCase, testCase.TestData.m15.equilibriumResults(2).passed);
verifyEqual(testCase, ...
    testCase.TestData.m15.qualityGate.equilibriumKmu, "PASS");
end
function testT23SixTrackingScenariosKhinf(testCase)
localVerifyScenarioTable(testCase, ...
    testCase.TestData.m15.trackingResults(1).metrics, 'AmplitudeDeg');
end
function testT24SixTrackingScenariosKmu(testCase)
localVerifyScenarioTable(testCase, ...
    testCase.TestData.m15.trackingResults(2).metrics, 'AmplitudeDeg');
end
function testT25TrackingMetricConventionPreserved(testCase)
expected = {'SettlingTime', 'OvershootPercent', ...
    'SteadyStateErrorAbsRad', 'SteadyStateErrorRelative', ...
    'CrossCouplingPeakRatio'};
verifyTrue(testCase, all(ismember(expected, ...
    testCase.TestData.m15.trackingResults(1).metrics.Properties.VariableNames)));
end
function testT26LtiNlTrackingKhinf(testCase)
t = testCase.TestData.m15.trackingResults(1).ltiNonlinearMetrics;
verifyEqual(testCase, height(t), 6);
verifyTrue(testCase, all(isfinite(t{:, 3:end}), 'all'));
end
function testT27LtiNlTrackingKmu(testCase)
t = testCase.TestData.m15.trackingResults(2).ltiNonlinearMetrics;
verifyEqual(testCase, height(t), 6);
verifyTrue(testCase, all(isfinite(t{:, 3:end}), 'all'));
end
function testT28SixDisturbanceScenariosKhinf(testCase)
localVerifyScenarioTable(testCase, ...
    testCase.TestData.m15.disturbanceResults(1).metrics, 'AmplitudeNm');
end
function testT29SixDisturbanceScenariosKmu(testCase)
localVerifyScenarioTable(testCase, ...
    testCase.TestData.m15.disturbanceResults(2).metrics, 'AmplitudeNm');
end
function testT30PhysicalLinkDisturbance(testCase)
source = fileread(fullfile(testCase.TestData.root, 'simulink', ...
    'm8_nonlinear_sea_sfun.m'));
verifyTrue(testCase, contains(source, 'InputPort(2).Data'));
verifyTrue(testCase, testCase.TestData.m15.plantAudit.m8SFunctionReused);
end
function testT31LtiNlDisturbanceComparison(testCase)
verifyEqual(testCase, height( ...
    testCase.TestData.m15.disturbanceLtiNlMetrics), 12);
verifyTrue(testCase, all(isfinite( ...
    testCase.TestData.m15.disturbanceLtiNlMetrics{:, 4:end}), 'all'));
end
function testT32FixedNoiseSeed(testCase)
verifyEqual(testCase, testCase.TestData.m15.config.noise.seed, 20260826);
verifyEqual(testCase, [testCase.TestData.m15.noiseResults.seed], ...
    [20260826, 20260826]);
end
function testT33IdenticalNoiseRealization(testCase)
verifyTrue(testCase, testCase.TestData.m15.noiseIdentity);
verifyEqual(testCase, ...
    testCase.TestData.m15.noiseResults(1).noiseFourChannelIdentity, ...
    testCase.TestData.m15.noiseResults(2).noiseFourChannelIdentity);
end
function testT34RepeatabilityKhinf(testCase)
verifyLessThanOrEqual(testCase, ...
    testCase.TestData.m15.noiseResults(1).repeatError, 1e-12);
end
function testT35RepeatabilityKmu(testCase)
verifyLessThanOrEqual(testCase, ...
    testCase.TestData.m15.noiseResults(2).repeatError, 1e-12);
end
function testT36RasConfigIdenticalM8(testCase)
first = rmfield(testCase.TestData.m15.config.ras, ...
    'secondarySectionEnabled');
second = rmfield(testCase.TestData.m8.simulationConfig.ras, ...
    'secondarySectionEnabled');
verifyEqual(testCase, first, second);
end
function testT37RasControllerStateStartsZero(testCase)
verifyTrue(testCase, all([testCase.TestData.m15.rasResults. ...
    controllerStateStartsZero]));
end
function testT38RasKhinfProduced(testCase)
localVerifyBoundary(testCase, testCase.TestData.m15.rasResults(1).boundary);
end
function testT39RasKmuProduced(testCase)
localVerifyBoundary(testCase, testCase.TestData.m15.rasResults(2).boundary);
end
function testT40NoCertifiedRoaClaim(testCase)
verifyFalse(testCase, any([testCase.TestData.m15.rasResults.certifiedRegion]));
for index = 1:2
    metrics = testCase.TestData.m15.rasResults(index).metrics;
    verifyFalse(testCase, metrics.certifiedRegion);
    verifyEqual(testCase, metrics.empiricalConvergenceFraction, ...
        metrics.numberConvergent / metrics.numberUniquePoints, ...
        'AbsTol', 1e-12);
    verifyTrue(testCase, isfinite(metrics.maximumConvergentControlNm));
end
end
function testT41M6RasLoadedFrozen(testCase)
r = testCase.TestData.m15.m6FrozenRasReference;
verifyTrue(testCase, r.loadedWithoutRerun);
verifyEqual(testCase, r.rasBoundary, testCase.TestData.m8.rasBoundary);
end
function testT42AgreementHas36Directions(testCase)
metrics = [testCase.TestData.m15.agreementResults.metrics];
verifyEqual(testCase, [metrics.directions], [36, 36]);
end
function testT43AgreementMaximumRadiusEightDegrees(testCase)
verifyEqual(testCase, ...
    testCase.TestData.m15.config.agreement.maximumRadiusDeg, 8);
end
function testT44AgreementToleranceHalfDegree(testCase)
verifyEqual(testCase, ...
    testCase.TestData.m15.config.agreement.maximumQDiscrepancyDeg, 0.5);
end
function testT45AgreementRadialToleranceQuarterDegree(testCase)
verifyEqual(testCase, ...
    testCase.TestData.m15.config.agreement.radialToleranceDeg, 0.25);
end
function testT46AgreementKhinfProduced(testCase)
localVerifyBoundary(testCase, ...
    testCase.TestData.m15.agreementResults(1).boundary);
end
function testT47AgreementKmuProduced(testCase)
localVerifyBoundary(testCase, ...
    testCase.TestData.m15.agreementResults(2).boundary);
end
function testT48NoM4UncertaintySampling(testCase)
verifyFalse(testCase, ...
    testCase.TestData.m15.metadata.uncertaintySamplingPerformed);
verifyFalse(testCase, ...
    testCase.TestData.m15.config.uncertaintySamplingEnabled);
end
function testT49NoUncertaintySamplingApi(testCase)
verifyNoCall(testCase, 'usample');
end
function testT50NoMonteCarlo(testCase)
verifyFalse(testCase, testCase.TestData.m15.metadata.monteCarloPerformed);
verifyFalse(testCase, testCase.TestData.m15.config.monteCarloEnabled);
end
function testT51NoControllerReduction(testCase)
verifyFalse(testCase, ...
    testCase.TestData.m15.metadata.controllerReductionPerformed);
verifyFalse(testCase, ...
    testCase.TestData.m15.config.controllerReductionEnabled);
end
function testT52NoMuSynthesisCall(testCase)
verifyNoCall(testCase, 'musyn');
end
function testT53NoHinfSynthesisCall(testCase)
verifyNoCall(testCase, 'hinfsyn');
end
function testT54NoMixedSensitivitySynthesisCall(testCase)
verifyNoCall(testCase, 'mixsyn');
end
function testT55NoStructuredSynthesisCall(testCase)
verifyNoCall(testCase, 'hinfstruct');
end
function testT56NoM16(testCase)
verifyFalse(testCase, testCase.TestData.m15.metadata.m16Started);
verifyFalse(testCase, testCase.TestData.m15.config.m16Enabled);
end
function testT57ArtifactProduced(testCase)
verifyTrue(testCase, isfile(testCase.TestData.path));
end
function testT58FiguresProduced(testCase)
verifyTrue(testCase, all(structfun(@isfile, ...
    testCase.TestData.m15.figurePaths)));
verifyEqual(testCase, numel(fieldnames(testCase.TestData.m15.figurePaths)), 8);
end
function testT59QualityGateCoherent(testCase)
q = testCase.TestData.m15.qualityGate;
verifyEqual(testCase, q.frozenControllers, "PASS");
verifyEqual(testCase, q.frozenNonlinearPlant, "PASS");
verifyEqual(testCase, q.solverConfigIdentityM8, "PASS");
verifyEqual(testCase, q.softwareCorrectness, "PASS");
end
function testT60OverallStatusCoherent(testCase)
q = testCase.TestData.m15.qualityGate;
if q.trackingKhinf == "PASS" && q.trackingKmu == "PASS"
    verifyEqual(testCase, q.overallStatus, "COMPLETE");
else
    verifyEqual(testCase, q.overallStatus, "PARTIAL");
end
end

function localVerifyScenarioTable(testCase, tableIn, amplitudeName)
verifyEqual(testCase, height(tableIn), 6);
verifyEqual(testCase, unique(tableIn.Joint), [1; 2]);
if strcmp(amplitudeName, 'AmplitudeDeg')
    verifyEqual(testCase, unique(tableIn.(amplitudeName)), [2; 5; 8]);
else
    verifyEqual(testCase, unique(tableIn.(amplitudeName)), [0.25; 0.5; 1]);
end
end
function localVerifyBoundary(testCase, boundary)
verifyEqual(testCase, height(boundary), 36);
verifyTrue(testCase, all(isfinite(boundary{:, 1:4}), 'all'));
end
function verifyNoCall(testCase, functionName)
root = testCase.TestData.root;
files = [dir(fullfile(root, 'analysis', 'nonlinear', '*.m')); ...
    dir(fullfile(root, 'analysis', 'ras', '*m15*.m')); ...
    dir(fullfile(root, 'simulink', '*m15*.m')); ...
    dir(fullfile(root, 'src', 'parameters', 'm15_specs.m'))];
expression = ['\<' functionName '\s*\('];
for index = 1:numel(files)
    source = fileread(fullfile(files(index).folder, files(index).name));
    verifyEmpty(testCase, regexp(source, expression, 'once'));
end
end
