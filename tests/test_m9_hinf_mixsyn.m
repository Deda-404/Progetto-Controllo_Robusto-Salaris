function tests = test_m9_hinf_mixsyn
%TEST_M9_HINF_MIXSYN Software and recorded-performance checks for M9.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(projectRoot, 'src')));
addpath(genpath(fullfile(projectRoot, 'controllers')));
addpath(genpath(fullfile(projectRoot, 'analysis')));
datasetPath = fullfile(projectRoot, 'results', 'data', ...
    'm9_hinf_mixsyn_nominal.mat');
if ~isfile(datasetPath)
    validate_m9_hinf_mixsyn;
end
testCase.TestData.projectRoot = projectRoot;
testCase.TestData.m9 = load(datasetPath);
testCase.TestData.m3 = load(fullfile(projectRoot, 'results', 'data', ...
    'm3_nominal_actuated_plant.mat'));
testCase.TestData.m5 = load(fullfile(projectRoot, 'results', 'data', ...
    'm5_performance_specs.mat'));
testCase.TestData.m6 = load(fullfile(projectRoot, 'results', 'data', ...
    'm6_lqg_no_integrator.mat'));
end

function testT01PlantIsTwoByTwo(testCase)
verifyEqual(testCase, size(testCase.TestData.m3.GfullQ), [2, 2]);
verifyEqual(testCase, testCase.TestData.m9.plantAudit.inputCount, 2);
verifyEqual(testCase, testCase.TestData.m9.plantAudit.outputCount, 2);
end

function testT02PlantOrderIsFourteen(testCase)
verifyEqual(testCase, order(testCase.TestData.m3.GfullQ), 14);
verifyEqual(testCase, testCase.TestData.m9.plantAudit.order, 14);
end

function testT03ControlPathMatchesM3(testCase)
m3 = testCase.TestData.m3;
m5 = testCase.TestData.m5;
errorSystem = m3.GfullQ - m5.disturbancePlant(1:2, 1:2);
verifyLessThanOrEqual(testCase, norm(errorSystem, inf), 1e-10);
verifyLessThanOrEqual(testCase, ...
    testCase.TestData.m9.plantAudit.controlPathMaximumError, 1e-10);
end

function testT04PhysicalDisturbancePathMatchesM5(testCase)
m3 = testCase.TestData.m3;
m5 = testCase.TestData.m5;
Gd = ss(m3.Afull, m5.BdFull, m3.CfullQ, zeros(2));
verifyLessThanOrEqual(testCase, ...
    norm(Gd - m5.disturbancePlant(1:2, 3:4), inf), 1e-10);
verifyEqual(testCase, m5.BdFull(9:14, :), zeros(6, 2));
end

function testT05WeightsAreExactlyTheM5Weights(testCase)
m5 = testCase.TestData.m5;
[~, W1, ~, W2] = build_m5_weights(m5.spec);
verifyLessThanOrEqual(testCase, norm(m5.W1 - W1, inf), 1e-12);
verifyLessThanOrEqual(testCase, norm(m5.W2 - W2, inf), 1e-12);
verifyLessThanOrEqual(testCase, ...
    testCase.TestData.m9.weightAudit.W1TransferError, 1e-12);
verifyLessThanOrEqual(testCase, ...
    testCase.TestData.m9.weightAudit.W2TransferError, 1e-12);
end

function testT06M5ParametersRemainFrozen(testCase)
artifactSpec = testCase.TestData.m5.spec;
sourceSpec = performance_specs_m5;
fields = {'omegaB', 'omegaW1', 'As', 'Ms', 'uScale', 'omegaU', ...
    'controlWeightGain', 'controlWeightAlpha'};
for index = 1:numel(fields)
    verifyEqual(testCase, artifactSpec.(fields{index}), ...
        sourceSpec.(fields{index}));
end
verifyFalse(testCase, sourceSpec.controllerSynthesisAllowed);
end

function testT07W3IsAbsent(testCase)
m9 = testCase.TestData.m9;
verifyEmpty(testCase, m9.config.W3);
verifyTrue(testCase, m9.weightAudit.W3Absent);
verifyFalse(testCase, m9.config.weightRetuningEnabled);
end

function testT08SynthesisIsNominalAndNumerical(testCase)
m9 = testCase.TestData.m9;
verifyTrue(testCase, m9.metadata.nominalOnly);
verifyTrue(testCase, m9.config.nominalSynthesis);
verifyFalse(testCase, m9.config.robustAnalysisEnabled);
verifyTrue(testCase, all(isfinite(m9.Kmix.A), 'all'));
end

function testT09ControllerExistsAndHasExpectedChannels(testCase)
Kmix = testCase.TestData.m9.Kmix;
verifyNotEmpty(testCase, Kmix);
verifyEqual(testCase, size(Kmix), [2, 2]);
verifyEqual(testCase, order(Kmix), 18);
end

function testT10GammaIsFiniteAndPositive(testCase)
gamma = testCase.TestData.m9.gamma;
verifyTrue(testCase, isfinite(gamma));
verifyGreaterThan(testCase, gamma, 0);
end

function testT11ClosedLoopIsInternallyStable(testCase)
m9 = testCase.TestData.m9;
verifyTrue(testCase, all(real(m9.closedLoopPoles) < ...
    -m9.config.stabilityTolerance));
verifyEqual(testCase, m9.qualityGate.nominalStability, "PASS");
verifyLessThan(testCase, m9.normMetrics.maximumClosedLoopRealPart, 0);
end

function testT12SensitivityReconstruction(testCase)
m9 = testCase.TestData.m9;
G = testCase.TestData.m3.GfullQ;
identity = ss(eye(2));
independentS = feedback(identity, G * m9.Kmix);
verifyLessThanOrEqual(testCase, norm(m9.S - independentS, inf), 1e-8);
end

function testT13ComplementarySensitivityIdentity(testCase)
m9 = testCase.TestData.m9;
identity = ss(eye(2));
verifyLessThanOrEqual(testCase, norm(m9.T - (identity - m9.S), inf), ...
    1e-8);
end

function testT14ControlSensitivityReconstruction(testCase)
m9 = testCase.TestData.m9;
verifyLessThanOrEqual(testCase, ...
    norm(m9.KS - m9.Kmix * m9.S, inf), 1e-8);
end

function testT15WeightedStackReconstruction(testCase)
m9 = testCase.TestData.m9;
m5 = testCase.TestData.m5;
independentStack = [m5.W1 * m9.S; m5.W2 * m9.KS];
verifyLessThanOrEqual(testCase, ...
    norm(m9.weightedClosedLoop - independentStack, inf), 1e-8);
end

function testT16WeightedNormMatchesGamma(testCase)
m9 = testCase.TestData.m9;
verifyLessThanOrEqual(testCase, m9.normMetrics.normRelativeError, ...
    m9.config.normRelativeTolerance);
verifyEqual(testCase, m9.normMetrics.gamma, m9.gamma);
end

function testT17CLmixMatchesIndependentStack(testCase)
m9 = testCase.TestData.m9;
verifyLessThanOrEqual(testCase, m9.normMetrics.clmixError, ...
    m9.config.closedLoopConsistencyTolerance);
verifyLessThanOrEqual(testCase, ...
    norm(m9.CLmix - m9.weightedClosedLoop, inf), ...
    m9.config.closedLoopConsistencyTolerance);
end

function testT18TrackingScenariosAreComplete(testCase)
tracking = testCase.TestData.m9.trackingMetrics;
verifyEqual(testCase, height(tracking), 6);
verifyEqual(testCase, unique(tracking.AmplitudeDeg), [2; 5; 8]);
verifyEqual(testCase, unique(tracking.Joint), [1; 2]);
verifyTrue(testCase, all(isfinite(tracking{:,:}), 'all'));
end

function testT19PerformanceOutcomeIsRecordedNotHidden(testCase)
m9 = testCase.TestData.m9;
m5 = testCase.TestData.m5;
trackingPass = all(m9.trackingMetrics.SettlingTime <= ...
    m5.spec.settlingTimeTarget & ...
    m9.trackingMetrics.OvershootPercent <= m5.spec.overshootTarget & ...
    m9.trackingMetrics.SteadyStateErrorRelative <= ...
        m5.spec.steadyStateTrackingTarget);
verifyEqual(testCase, m9.qualityGate.tracking, ...
    localPassFail(trackingPass));
verifyEqual(testCase, m9.qualityGate.weightedNominalPerformance, ...
    localPassFail(m9.gamma < 1));
end

function testT20DisturbanceScenariosAreComplete(testCase)
disturbance = testCase.TestData.m9.disturbanceMetrics;
verifyEqual(testCase, height(disturbance), 6);
verifyEqual(testCase, unique(disturbance.AmplitudeNm), [0.25; 0.5; 1]);
verifyEqual(testCase, unique(disturbance.Joint), [1; 2]);
verifyTrue(testCase, all(isfinite(disturbance{:,:}), 'all'));
verifyGreaterThan(testCase, ...
    min(abs(disturbance.SteadyStateOffsetRad)), 0);
end

function testT21ControlScaleIsNotSaturation(testCase)
m9 = testCase.TestData.m9;
m5 = testCase.TestData.m5;
verifyFalse(testCase, m9.config.saturationEnabled);
verifyFalse(testCase, m9.metadata.saturationEnabled);
verifyEqual(testCase, m9.controlEffortMetrics.uScaleNm, 12);
verifyEqual(testCase, m9.trackingMetrics.PeakControlNormalized, ...
    m9.trackingMetrics.PeakControlNm / m5.spec.uScale, ...
    'AbsTol', 1e-12);
verifyEqual(testCase, m9.disturbanceMetrics.PeakControlNormalized, ...
    m9.disturbanceMetrics.PeakControlNm / m5.spec.uScale, ...
    'AbsTol', 1e-12);
end

function testT22NoRobustOrMuAnalysisIsPresent(testCase)
projectRoot = testCase.TestData.projectRoot;
m9Files = { ...
    fullfile('controllers', 'hinf', 'build_m9_nominal_plant.m'), ...
    fullfile('controllers', 'hinf', 'reconstruct_m9_mixed_sensitivity.m'), ...
    fullfile('controllers', 'hinf', 'synthesize_m9_mixsyn.m'), ...
    fullfile('analysis', 'nominal', 'evaluate_m9_closed_loop.m'), ...
    fullfile('analysis', 'nominal', 'plot_m9_results.m'), ...
    fullfile('analysis', 'nominal', 'validate_m9_hinf_mixsyn.m')};
for index = 1:numel(m9Files)
    source = fileread(fullfile(projectRoot, m9Files{index}));
    verifyEmpty(testCase, regexp(source, ...
        '\<(mussv|robuststab|robgain|musyn|hinfsyn)\s*\(', 'once'));
end
end

function testT23NoRetuningOrMinrealInSynthesisPath(testCase)
projectRoot = testCase.TestData.projectRoot;
sourceFiles = {'synthesize_m9_mixsyn.m', ...
    'reconstruct_m9_mixed_sensitivity.m'};
combined = "";
for index = 1:numel(sourceFiles)
    combined = combined + newline + string(fileread(fullfile( ...
        projectRoot, 'controllers', 'hinf', sourceFiles{index})));
end
mixsynCalls = regexp(combined, ...
    '\[[^\n]+\]\s*=\s*mixsyn\s*\(', 'match');
verifyEqual(testCase, numel(mixsynCalls), 1);
verifyEmpty(testCase, regexp(combined, '\<minreal\s*\(', 'once'));
verifyFalse(testCase, testCase.TestData.m9.metadata.retuningPerformed);
end

function testT24ActuatorAndEquilibriumArePreserved(testCase)
audit = testCase.TestData.m9.plantAudit;
parameters = audit.actuatorParameters;
verifyEqual(testCase, parameters.wn, 40);
verifyEqual(testCase, parameters.zeta, 0.8);
verifyEqual(testCase, parameters.delay, 0.015);
verifyEqual(testCase, parameters.padeOrder, 1);
verifyEqual(testCase, audit.equilibrium, [pi / 2; 0], ...
    'AbsTol', 1e-14);
end

function testT25OpenLoopFeaturesAreRecorded(testCase)
audit = testCase.TestData.m9.plantAudit;
verifyEqual(testCase, audit.numberUnstablePoles, 2);
verifyEqual(testCase, numel(audit.rightHalfPlaneZeros), 2);
verifyGreaterThan(testCase, min(real(audit.rightHalfPlaneZeros)), 0);
verifyTrue(testCase, audit.stabilizable);
verifyTrue(testCase, audit.detectable);
end

function testT26M6ComparisonUsesFrozenArtifact(testCase)
comparison = testCase.TestData.m9.comparisonM6;
verifyEqual(testCase, height(comparison.tracking), 12);
verifyEqual(testCase, height(comparison.disturbance), 12);
verifyEqual(testCase, comparison.controllerOrder.Controller, ...
    ["M9 mixsyn"; "M6 LQG"]);
verifyEqual(testCase, comparison.controllerOrder.Order, ...
    [18; order(testCase.TestData.m6.Klqg)]);
end

function testT27OverallStatusReflectsFailedTargets(testCase)
m9 = testCase.TestData.m9;
allFundamentalPass = m9.qualityGate.nominalStability == "PASS" && ...
    m9.qualityGate.weightedNominalPerformance == "PASS" && ...
    m9.qualityGate.tracking == "PASS";
if allFundamentalPass
    expected = "COMPLETE";
else
    expected = "PARTIAL";
end
verifyEqual(testCase, m9.qualityGate.overallStatus, expected);
verifyEqual(testCase, m9.qualityGate.softwareCorrectness, "PASS");
end

function testT28WarningsAndConditioningAreRecorded(testCase)
m9 = testCase.TestData.m9;
verifyTrue(testCase, isfield(m9, 'stabilityDiagnostics'));
verifyTrue(testCase, isfinite( ...
    m9.stabilityDiagnostics.eigenvectorConditionNumber));
verifyEqual(testCase, m9.stabilityDiagnostics.explicitPoleCount, 32);
verifyFalse(testCase, m9.stabilityDiagnostics.minrealUsedForGate);
end

function testT29ArtifactsWereProduced(testCase)
projectRoot = testCase.TestData.projectRoot;
verifyTrue(testCase, isfile(fullfile(projectRoot, 'results', 'data', ...
    'm9_hinf_mixsyn_nominal.mat')));
paths = struct2cell(testCase.TestData.m9.figurePaths);
verifyEqual(testCase, numel(paths), 6);
verifyTrue(testCase, all(cellfun(@isfile, paths)));
end

function status = localPassFail(condition)
if condition
    status = "PASS";
else
    status = "FAIL";
end
end
