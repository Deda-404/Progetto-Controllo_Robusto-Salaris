function tests = test_m7_lqg_integral
%TEST_M7_LQG_INTEGRAL Tests for the authorized M7 2-DoF feasibility gate.
%   Both approved tuning stages are infeasible. The suite validates the
%   feedforward method and the required stop without publishing a controller.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(projectRoot, 'src')));
addpath(genpath(fullfile(projectRoot, 'controllers')));
addpath(genpath(fullfile(projectRoot, 'analysis')));
metrics = validate_m7_lqg_integral;
m3 = load(fullfile(projectRoot, 'results', 'data', ...
    'm3_nominal_actuated_plant.mat'));
m5 = load(fullfile(projectRoot, 'results', 'data', ...
    'm5_performance_specs.mat'));
m6 = load(fullfile(projectRoot, 'results', 'data', ...
    'm6_lqg_no_integrator.mat'));
testCase.TestData.projectRoot = projectRoot;
testCase.TestData.metrics = metrics;
testCase.TestData.m3 = m3;
testCase.TestData.m5 = m5;
testCase.TestData.m6 = m6;
end

function testT1AugmentedModelIsSixteenState(testCase)
design = testCase.TestData.metrics.selection.stageA.designs{1};
verifySize(testCase, design.Aaug, [16, 16]);
verifySize(testCase, design.Baug, [16, 2]);
end

function testT2ExactlyTwoJointPositionIntegrators(testCase)
design = testCase.TestData.metrics.selection.stageA.designs{1};
m3 = testCase.TestData.m3;
verifyEqual(testCase, design.Aaug(15:16, 1:14), -m3.CfullQ);
verifyEqual(testCase, design.Aaug(15:16, 15:16), zeros(2));
verifyEqual(testCase, design.Baug(15:16, :), zeros(2));
end

function testT3AugmentedPlantIsStabilizable(testCase)
structure = testCase.TestData.metrics.selection.stageA. ...
    designs{1}.structural;
verifyTrue(testCase, structure.controllablePbh);
verifyTrue(testCase, structure.isStabilizable);
verifyEqual(testCase, structure.zeroPbhRank, 16);
verifyEqual(testCase, structure.zeroRosenbrockRank, 16);
end

function testT4AugmentedCostsReuseM6AndHaveRequiredProperties(testCase)
metrics = testCase.TestData.metrics;
m6 = testCase.TestData.m6;
for designIndex = 1:numel(metrics.selection.designs)
    design = metrics.selection.designs{designIndex};
    verifyEqual(testCase, design.Qaug(1:14, 1:14), m6.Q);
    verifyGreaterThanOrEqual(testCase, min(eig(design.Qaug)), -1e-8);
    verifyGreaterThan(testCase, min(eig(design.R)), 0);
end
end

function testT5StageAAndConditionalStageBAreCompleteAndDeterministic(testCase)
metrics = testCase.TestData.metrics;
config = metrics.config;
stageA = metrics.selection.stageA.candidateTable;
stageB = metrics.selection.stageB.candidateTable;
verifyEqual(testCase, height(stageA), 28);
verifyEqual(testCase, unique(stageA.Wi), config.wiCandidates);
verifyEqual(testCase, unique(stageA.RhoU), config.rhoUCandidates);
verifyTrue(testCase, metrics.selection.stageBExecuted);
verifyEqual(testCase, height(stageB), 25);
verifyEqual(testCase, unique(stageB.Wi), config.stageBWiCandidates);
verifyEqual(testCase, unique(stageB.RhoU), ...
    config.stageBRhoUCandidates);
repeat = select_lqi_integral(testCase.TestData.m3, ...
    testCase.TestData.m5, testCase.TestData.m6, config);
verifyEqual(testCase, repeat.lqiCandidateTable, ...
    metrics.selection.lqiCandidateTable);
verifyEqual(testCase, repeat.stageBExecuted, ...
    metrics.selection.stageBExecuted);
end

function testT6AndT7GainDimensionsAndPartitions(testCase)
designs = testCase.TestData.metrics.selection.designs;
for designIndex = 1:numel(designs)
    verifySize(testCase, designs{designIndex}.Kaug, [2, 16]);
    verifySize(testCase, designs{designIndex}.Kx, [2, 14]);
    verifySize(testCase, designs{designIndex}.Ki, [2, 2]);
    verifyEqual(testCase, designs{designIndex}.Kaug, ...
        [designs{designIndex}.Kx, designs{designIndex}.Ki]);
end
end

function testT8NoInadmissibleCandidateIsSelected(testCase)
selection = testCase.TestData.metrics.selection;
verifyEmpty(testCase, selection.selectedIndex);
verifyFalse(testCase, any(selection.lqiCandidateTable.Selected));
verifyFalse(testCase, any(selection.lqiCandidateTable.FundamentalPass));
verifyEqual(testCase, ...
    testCase.TestData.metrics.validationMetrics.status, "PARTIAL");
end

function testT9NffIsDerivedFromEachCandidateKxAndNotM6Nr(testCase)
selection = testCase.TestData.metrics.selection;
m3 = testCase.TestData.m3;
m6 = testCase.TestData.m6;
indices = [1, 25, numel(selection.designs)];
for designIndex = indices
    Kx = selection.designs{designIndex}.Kx;
    GdcX = dcgain(ss(m3.Afull - m3.Bfull * Kx, m3.Bfull, ...
        m3.CfullQ, zeros(2)));
    expectedNff = GdcX \ eye(2);
    actualNff = selection.evaluations{designIndex}.Nff;
    verifyEqual(testCase, actualNff, expectedNff, 'AbsTol', 1e-12);
end
verifyGreaterThan(testCase, norm( ...
    selection.stageA.nff{25} - m6.Nr, 'fro'), 1e-6);
end

function testT10FeedforwardDcResidualIsSmall(testCase)
tableData = testCase.TestData.metrics.selection.lqiCandidateTable;
config = testCase.TestData.metrics.config;
verifyTrue(testCase, all(tableData.FeedforwardWellConditioned));
verifyLessThanOrEqual(testCase, max(tableData.FeedforwardResidual), ...
    config.feedforwardResidualTolerance);
verifyLessThan(testCase, max(tableData.GdcCondition), ...
    config.feedforwardConditionWarning);
end

function testT11NffDoesNotChangeDisturbanceRejection(testCase)
selection = testCase.TestData.metrics.selection;
config = testCase.TestData.metrics.config;
verifyLessThanOrEqual(testCase, max(selection.lqiCandidateTable. ...
    DisturbanceOffsetNffDifference), 10 * eps);
for candidateIndex = [1, 25, numel(selection.evaluations)]
    withNff = selection.evaluations{candidateIndex}.disturbanceMetrics;
    withoutNff = selection.oneDofEvaluations{candidateIndex}. ...
        disturbanceMetrics;
    verifyEqual(testCase, withNff.SteadyStateOffset, ...
        withoutNff.SteadyStateOffset, 'AbsTol', 10 * eps);
    verifyLessThanOrEqual(testCase, max(abs( ...
        withNff.SteadyStateOffset)), ...
        config.disturbanceSteadyStateTolerance);
end
end

function testT12OneDofVersusTwoDofComparisonIsGenerated(testCase)
comparison = testCase.TestData.metrics.feedforwardComparison;
verifyEqual(testCase, height(comparison), 28);
verifyTrue(testCase, any(comparison.OneDofWorstSettlingTime ~= ...
    comparison.WorstSettlingTime));
verifyTrue(testCase, any(comparison.OneDofPeakU ~= comparison.PeakU));
verifyTrue(testCase, any(comparison.OneDofPeakXi ~= comparison.PeakXi));
verifyEqual(testCase, comparison.DisturbanceOffsetNffDifference, ...
    zeros(28, 1), 'AbsTol', 10 * eps);
end

function testT13StageBExecutesOnlyAfterStageAFailure(testCase)
selection = testCase.TestData.metrics.selection;
verifyFalse(testCase, any(selection.stageA.candidateTable. ...
    FundamentalPass));
verifyTrue(testCase, selection.stageBExecuted);
verifyEqual(testCase, selection.stageB.name, "Stage B");
end

function testT14TrackingGateIsEvaluatedAndFailsBothStages(testCase)
metrics = testCase.TestData.metrics;
spec = testCase.TestData.m5.spec;
verifyGreaterThan(testCase, min( ...
    metrics.stageACandidateTable.WorstSettlingTime), ...
    spec.settlingTimeTarget);
verifyGreaterThan(testCase, min( ...
    metrics.stageBCandidateTable.WorstSettlingTime), ...
    spec.settlingTimeTarget);
verifyFalse(testCase, any(metrics.stageACandidateTable.TrackingPass));
verifyFalse(testCase, any(metrics.stageBCandidateTable.TrackingPass));
end

function testT15AllDisturbanceOffsetsMeetTolerance(testCase)
tableData = testCase.TestData.metrics.selection.lqiCandidateTable;
tolerance = testCase.TestData.metrics.config. ...
    disturbanceSteadyStateTolerance;
verifyLessThanOrEqual(testCase, ...
    max(tableData.WorstDisturbanceSteadyStateOffset), tolerance);
end

function testT16M5SourceRemainsUnchanged(testCase)
verifyTrue(testCase, testCase.TestData.metrics.validationMetrics. ...
    m5SourceUnchanged);
verifyEqual(testCase, testCase.TestData.m5.spec, ...
    performance_specs_m5);
end

function testT17NoFinalControllerIsPublishedAfterStageBFailure(testCase)
metrics = testCase.TestData.metrics;
verifyFalse(testCase, metrics.validationMetrics.finalControllerBuilt);
verifyFalse(testCase, metrics.validationMetrics.selectedCandidateExists);
verifyFalse(testCase, isfile(fullfile(testCase.TestData.projectRoot, ...
    'results', 'data', 'm7_lqg_integral.mat')));
end

function testT18NoSaturationOrAntiWindupIsInvented(testCase)
config = testCase.TestData.metrics.config;
verifyFalse(testCase, config.saturationEnabled);
verifyFalse(testCase, config.antiWindupEnabled);
end

function testT19ApprovedM6BaselineRemainsAvailable(testCase)
m6 = testCase.TestData.m6;
verifySize(testCase, m6.Klqg.A, [14, 14]);
verifySize(testCase, m6.L, [14, 4]);
verifyTrue(testCase, m6.validationMetrics.tracking.targetsPassed);
end

function testT20GovernanceRecordsResponsibleAlessio(testCase)
files = {fullfile(testCase.TestData.projectRoot, 'docs', ...
    'DIARIO_DI_BORDO.md'), fullfile(testCase.TestData.projectRoot, ...
    'docs', 'PROJECT_STATUS.md'), fullfile( ...
    testCase.TestData.projectRoot, 'docs', 'handoff', ...
    'Resoconto_M7_per_GPT.txt')};
for fileIndex = 1:numel(files)
    verifyNotEmpty(testCase, regexp(fileread(files{fileIndex}), ...
        'Responsabile:\s*Alessio', 'once'));
end
end
