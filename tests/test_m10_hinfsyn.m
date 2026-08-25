function tests = test_m10_hinfsyn
%TEST_M10_HINFSYN Generalized-plant and nominal hinfsyn checks for M10.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(projectRoot, 'src')));
addpath(genpath(fullfile(projectRoot, 'controllers')));
addpath(genpath(fullfile(projectRoot, 'analysis')));
datasetPath = fullfile(projectRoot, 'results', 'data', ...
    'm10_hinfsyn_nominal.mat');
if ~isfile(datasetPath)
    validate_m10_hinfsyn;
end
testCase.TestData.projectRoot = projectRoot;
testCase.TestData.m10 = load(datasetPath);
testCase.TestData.m9 = load(fullfile(projectRoot, 'results', 'data', ...
    'm9_hinf_mixsyn_nominal.mat'));
testCase.TestData.m6 = load(fullfile(projectRoot, 'results', 'data', ...
    'm6_lqg_no_integrator.mat'));
testCase.TestData.m5 = load(fullfile(projectRoot, 'results', 'data', ...
    'm5_performance_specs.mat'));
testCase.TestData.m3 = load(fullfile(projectRoot, 'results', 'data', ...
    'm3_nominal_actuated_plant.mat'));
end

function testT01PlantMatchesM3AndM9(testCase)
m10 = testCase.TestData.m10;
m3 = testCase.TestData.m3;
verifyLessThanOrEqual(testCase, ...
    localFrequencyError(-m10.P(5:6, 3:4), m3.GfullQ), 1e-10);
verifyEqual(testCase, m10.plantAudit.order, ...
    testCase.TestData.m9.plantAudit.order);
end

function testT02WeightsAreFrozenM5Artifacts(testCase)
m10 = testCase.TestData.m10;
verifyLessThanOrEqual(testCase, m10.weightAudit.W1TransferError, 1e-12);
verifyLessThanOrEqual(testCase, m10.weightAudit.W2TransferError, 1e-12);
[~, W1, ~, W2] = build_m5_weights(testCase.TestData.m5.spec);
verifyLessThanOrEqual(testCase, ...
    norm(W1 - testCase.TestData.m5.W1, inf), 1e-12);
verifyLessThanOrEqual(testCase, ...
    norm(W2 - testCase.TestData.m5.W2, inf), 1e-12);
end

function testT03W3IsAbsent(testCase)
m10 = testCase.TestData.m10;
verifyEmpty(testCase, m10.config.W3);
verifyTrue(testCase, m10.weightAudit.W3Absent);
end

function testT04GeneralizedPlantIsSixByFour(testCase)
verifyEqual(testCase, size(testCase.TestData.m10.P), [6, 4]);
verifyEqual(testCase, testCase.TestData.m10.generalizedPlantAudit.size, ...
    [6, 4]);
end

function testT05NmeasIsTwo(testCase)
verifyEqual(testCase, testCase.TestData.m10.partition.nmeas, 2);
verifyEqual(testCase, testCase.TestData.m10.config.nmeas, 2);
end

function testT06NcontIsTwo(testCase)
verifyEqual(testCase, testCase.TestData.m10.partition.ncont, 2);
verifyEqual(testCase, testCase.TestData.m10.config.ncont, 2);
end

function testT07SignalOrderIsExplicit(testCase)
partition = testCase.TestData.m10.partition;
verifyEqual(testCase, partition.inputNames, ...
    ["r(1)"; "r(2)"; "u(1)"; "u(2)"]);
verifyEqual(testCase, partition.outputNames, ...
    ["z1(1)"; "z1(2)"; "z2(1)"; "z2(2)"; "e(1)"; "e(2)"]);
end

function testT08PartitionDimensionsAreCorrect(testCase)
partition = testCase.TestData.m10.partition;
verifyEqual(testCase, partition.P11Size, [4, 2]);
verifyEqual(testCase, partition.P12Size, [4, 2]);
verifyEqual(testCase, partition.P21Size, [2, 2]);
verifyEqual(testCase, partition.P22Size, [2, 2]);
end

function testT09ErrorUsesPositiveReference(testCase)
P21 = testCase.TestData.m10.P(5:6, 1:2);
verifyLessThanOrEqual(testCase, ...
    localFrequencyError(P21, ss(eye(2))), 1e-10);
end

function testT10P22IsNegativePlant(testCase)
m10 = testCase.TestData.m10;
verifyLessThanOrEqual(testCase, ...
    localFrequencyError(m10.P(5:6, 3:4), ...
        -testCase.TestData.m3.GfullQ), 1e-10);
verifyLessThanOrEqual(testCase, ...
    m10.generalizedPlantAudit.P22MaximumFrequencyError, 1e-10);
end

function testT11KmixClosureReproducesM9CLmix(testCase)
gate = testCase.TestData.m10.equivalenceGateM9;
verifyLessThanOrEqual(testCase, gate.metrics.clmixError, ...
    testCase.TestData.m10.config.m9EquivalenceTolerance);
verifyTrue(testCase, gate.passed);
end

function testT12KmixClosureReproducesM9Norm(testCase)
m10 = testCase.TestData.m10;
m9 = testCase.TestData.m9;
verifyLessThanOrEqual(testCase, ...
    abs(m10.equivalenceGateM9.metrics.closedLoopNorm - ...
        m9.normMetrics.weightedNorm) / m9.normMetrics.weightedNorm, ...
    m10.config.normRelativeTolerance);
verifyEqual(testCase, m10.equivalenceGateM9.metrics.m9Gamma, m9.gamma);
end

function testT13ConnectPlantMatchesAnalyticFormula(testCase)
verifyLessThanOrEqual(testCase, ...
    testCase.TestData.m10.generalizedPlantAudit. ...
        analyticMaximumFrequencyError, ...
    testCase.TestData.m10.config.generalizedPlantTolerance);
verifyTrue(testCase, testCase.TestData.m10.generalizedPlantAudit. ...
    constructedWithConnectAndSumblk);
end

function testT14AugwIsReferenceLastCrossCheck(testCase)
m10 = testCase.TestData.m10;
verifyLessThanOrEqual(testCase, ...
    m10.generalizedPlantAudit.augwMaximumFrequencyError, ...
    m10.config.augwCrossCheckTolerance);
verifyTrue(testCase, m10.generalizedPlantAudit. ...
    augwUsedOnlyAfterIndependentConstruction);
end

function testT15HinfsynReturnsController(testCase)
Khinf = testCase.TestData.m10.Khinf;
verifyNotEmpty(testCase, Khinf);
verifyEqual(testCase, size(Khinf), [2, 2]);
verifyEqual(testCase, order(Khinf), 18);
end

function testT16GammaIsFinite(testCase)
gamma = testCase.TestData.m10.gammaHinf;
verifyTrue(testCase, isfinite(gamma));
verifyGreaterThan(testCase, gamma, 0);
end

function testT17InternalClosedLoopIsStable(testCase)
m10 = testCase.TestData.m10;
verifyTrue(testCase, all(real(m10.closedLoopPoles10) < ...
    -m10.config.stabilityTolerance));
verifyEqual(testCase, m10.qualityGate.nominalStability, "PASS");
end

function testT18SensitivityIsReconstructed(testCase)
m10 = testCase.TestData.m10;
independent = feedback(ss(eye(2)), ...
    testCase.TestData.m3.GfullQ * m10.Khinf);
verifyLessThanOrEqual(testCase, ...
    localFrequencyError(m10.S10, independent), 1e-8);
end

function testT19ComplementarySensitivityIsReconstructed(testCase)
m10 = testCase.TestData.m10;
verifyLessThanOrEqual(testCase, ...
    localFrequencyError(m10.T10, ss(eye(2)) - m10.S10), 1e-8);
end

function testT20ControlSensitivityIsReconstructed(testCase)
m10 = testCase.TestData.m10;
verifyLessThanOrEqual(testCase, ...
    localFrequencyError(m10.KS10, m10.Khinf * m10.S10), 1e-8);
end

function testT21WeightedStackIsReconstructed(testCase)
m10 = testCase.TestData.m10;
m5 = testCase.TestData.m5;
independent = [m5.W1 * m10.S10; m5.W2 * m10.KS10];
verifyLessThanOrEqual(testCase, ...
    localFrequencyError(m10.weightedClosedLoop10, independent), 1e-8);
end

function testT22WeightedNormMatchesGamma(testCase)
m10 = testCase.TestData.m10;
verifyLessThanOrEqual(testCase, m10.normMetrics.normRelativeError, ...
    m10.config.normRelativeTolerance);
verifyEqual(testCase, m10.normMetrics.gamma, m10.gammaHinf);
end

function testT23CLhinfMatchesWeightedStack(testCase)
m10 = testCase.TestData.m10;
verifyLessThanOrEqual(testCase, m10.normMetrics.clmixError, ...
    m10.config.closedLoopConsistencyTolerance);
verifyLessThanOrEqual(testCase, ...
    localFrequencyError(m10.CLhinf, m10.weightedClosedLoop10), 1e-8);
end

function testT24TrackingScenariosAreComplete(testCase)
tracking = testCase.TestData.m10.trackingMetrics;
verifyEqual(testCase, height(tracking), 6);
verifyEqual(testCase, unique(tracking.AmplitudeDeg), [2; 5; 8]);
verifyEqual(testCase, unique(tracking.Joint), [1; 2]);
verifyTrue(testCase, all(isfinite(tracking{:,:}), 'all'));
end

function testT25DisturbanceScenariosAreComplete(testCase)
disturbance = testCase.TestData.m10.disturbanceMetrics;
verifyEqual(testCase, height(disturbance), 6);
verifyEqual(testCase, unique(disturbance.AmplitudeNm), [0.25; 0.5; 1]);
verifyEqual(testCase, unique(disturbance.Joint), [1; 2]);
verifyTrue(testCase, all(isfinite(disturbance{:,:}), 'all'));
end

function testT26UscaleIsNormalizationOnly(testCase)
m10 = testCase.TestData.m10;
m5 = testCase.TestData.m5;
verifyFalse(testCase, m10.config.saturationEnabled);
verifyFalse(testCase, m10.metadata.saturationEnabled);
verifyEqual(testCase, m10.trackingMetrics.PeakControlNormalized, ...
    m10.trackingMetrics.PeakControlNm / m5.spec.uScale, ...
    'AbsTol', 1e-12);
end

function testT27M9ComparisonUsesFrozenArtifact(testCase)
m10 = testCase.TestData.m10;
m9 = testCase.TestData.m9;
comparison = m10.comparisonM6M9M10.tracking;
m9Rows = comparison(comparison.Controller == "M9 mixsyn", 2:end);
verifyEqual(testCase, m9Rows{:,:}, m9.trackingMetrics{:,:}, ...
    'AbsTol', 1e-12);
verifyEqual(testCase, m10.metadata.m9Source, ...
    "results/data/m9_hinf_mixsyn_nominal.mat");
end

function testT28M6ComparisonUsesFrozenArtifact(testCase)
m10 = testCase.TestData.m10;
m6 = testCase.TestData.m6;
summary = m10.comparisonM6M9M10.summary;
m6Row = summary(summary.controller == "M6 LQG", :);
verifyEqual(testCase, m6Row.controllerOrder, order(m6.Klqg));
verifyEqual(testCase, m10.metadata.m6Source, ...
    "results/data/m6_lqg_no_integrator.mat");
end

function testT29NoM5Retuning(testCase)
m10 = testCase.TestData.m10;
spec = performance_specs_m5;
verifyFalse(testCase, m10.metadata.retuningPerformed);
verifyFalse(testCase, m10.weightAudit.retuningPerformed);
verifyFalse(testCase, spec.controllerSynthesisAllowed);
end

function testT30NoHinfstruct(testCase)
source = localM10Source(testCase.TestData.projectRoot);
verifyEmpty(testCase, regexp(source, '\<hinfstruct\s*\(', 'once'));
verifyFalse(testCase, testCase.TestData.m10.config.hinfstructEnabled);
end

function testT31NoMuOrRobustAnalysis(testCase)
source = localM10Source(testCase.TestData.projectRoot);
verifyEmpty(testCase, regexp(source, ...
    '\<(mussv|robuststab|robgain|musyn)\s*\(', 'once'));
verifyFalse(testCase, testCase.TestData.m10.metadata. ...
    robustAnalysisPerformed);
end

function testT32NoMinrealHidesInstability(testCase)
source = localM10Source(testCase.TestData.projectRoot);
verifyEmpty(testCase, regexp(source, '\<minreal\s*\(', 'once'));
verifyFalse(testCase, testCase.TestData.m10.stabilityDiagnostics. ...
    minrealUsedForGate);
verifyEqual(testCase, ...
    testCase.TestData.m10.stabilityDiagnostics.internalStateCount, 32);
end

function testT33ArtifactsWereProduced(testCase)
projectRoot = testCase.TestData.projectRoot;
verifyTrue(testCase, isfile(fullfile(projectRoot, 'results', 'data', ...
    'm10_hinfsyn_nominal.mat')));
paths = struct2cell(testCase.TestData.m10.figurePaths);
verifyEqual(testCase, numel(paths), 6);
verifyTrue(testCase, all(cellfun(@isfile, paths)));
end

function testT34QualityGateMatchesOutcome(testCase)
m10 = testCase.TestData.m10;
verifyEqual(testCase, m10.qualityGate.weightedNominalPerformance, ...
    localPassFail(m10.gammaHinf < 1));
targetsPassed = all(m10.trackingMetrics.SettlingTime <= ...
    testCase.TestData.m5.spec.settlingTimeTarget & ...
    m10.trackingMetrics.OvershootPercent <= ...
        testCase.TestData.m5.spec.overshootTarget & ...
    m10.trackingMetrics.SteadyStateErrorRelative <= ...
        testCase.TestData.m5.spec.steadyStateTrackingTarget);
verifyEqual(testCase, m10.qualityGate.tracking, ...
    localPassFail(targetsPassed));
end

function testT35SingleDefaultHinfsynCall(testCase)
source = fileread(fullfile(testCase.TestData.projectRoot, 'controllers', ...
    'hinf', 'synthesize_m10_hinfsyn.m'));
calls = regexp(source, ...
    '\[[^\n]+\]\s*=\s*hinfsyn\s*\(', 'match');
verifyEqual(testCase, numel(calls), 1);
verifyTrue(testCase, testCase.TestData.m10.synthesisDiagnostics. ...
    defaultOptionsUsed);
end

function testT36NoTwoDofOrDisturbanceInObjective(testCase)
m10 = testCase.TestData.m10;
verifyFalse(testCase, m10.config.twoDegreeOfFreedomEnabled);
verifyFalse(testCase, m10.metadata.twoDegreeOfFreedomUsed);
verifyFalse(testCase, m10.metadata.disturbanceInSynthesisObjective);
verifyEqual(testCase, m10.partition.exogenousInputIndices, 1:2);
end

function testT37ActuatorAndEquilibriumArePreserved(testCase)
audit = testCase.TestData.m10.plantAudit;
verifyEqual(testCase, audit.actuatorParameters.wn, 40);
verifyEqual(testCase, audit.actuatorParameters.zeta, 0.8);
verifyEqual(testCase, audit.actuatorParameters.delay, 0.015);
verifyEqual(testCase, audit.actuatorParameters.padeOrder, 1);
verifyEqual(testCase, audit.equilibrium, [pi / 2; 0], ...
    'AbsTol', 1e-14);
end

function testT38GeneralizedPlantOrderIsEighteen(testCase)
verifyEqual(testCase, order(testCase.TestData.m10.P), 18);
verifyEqual(testCase, testCase.TestData.m10.generalizedPlantAudit.order, 18);
end

function testT39M9M10ConsistencyIsQuantified(testCase)
m10 = testCase.TestData.m10;
consistency = m10.consistencyM9M10;
verifyLessThanOrEqual(testCase, consistency.gammaRelativeDifference, ...
    consistency.diagnosticRelativeGammaTolerance);
verifyLessThanOrEqual(testCase, consistency.weightedMapError, ...
    m10.config.m9EquivalenceTolerance);
verifyEqual(testCase, consistency.interpretation, "quasi-equivalent");
verifyEqual(testCase, m10.qualityGate.m9M10Consistency, "PASS");
end

function testT40OverallStatusSeparatesSoftwareAndPerformance(testCase)
m10 = testCase.TestData.m10;
verifyEqual(testCase, m10.qualityGate.generalizedPlantCorrectness, "PASS");
verifyEqual(testCase, m10.qualityGate.hinfReconstruction, "PASS");
verifyEqual(testCase, m10.qualityGate.softwareCorrectness, "PASS");
fundamentalPass = m10.qualityGate.weightedNominalPerformance == "PASS" && ...
    m10.qualityGate.tracking == "PASS";
if fundamentalPass
    expected = "COMPLETE";
else
    expected = "PARTIAL";
end
verifyEqual(testCase, m10.qualityGate.overallStatus, expected);
end

function error = localFrequencyError(first, second)
frequencies = logspace(-3, 3, 401);
difference = freqresp(first, frequencies) - freqresp(second, frequencies);
error = max(abs(difference), [], 'all');
end

function source = localM10Source(projectRoot)
files = [dir(fullfile(projectRoot, 'controllers', 'hinf', '*m10*.m')); ...
    dir(fullfile(projectRoot, 'analysis', 'nominal', '*m10*.m')); ...
    dir(fullfile(projectRoot, 'src', 'parameters', '*m10*.m'))];
source = "";
for index = 1:numel(files)
    source = source + newline + string(fileread(fullfile( ...
        files(index).folder, files(index).name)));
end
end

function status = localPassFail(condition)
if condition
    status = "PASS";
else
    status = "FAIL";
end
end
