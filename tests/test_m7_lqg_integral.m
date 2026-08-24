function tests = test_m7_lqg_integral
%TEST_M7_LQG_INTEGRAL M7 partial-gate tests for the prescribed LQI grid.
%   Full controller tests T8-T18 remain gated because no fundamental-
%   admissible candidate exists; these tests verify the evidence that
%   triggers the required PARTIAL stop without publishing a controller.
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
design = testCase.TestData.metrics.diagnosticDesign;
verifySize(testCase, design.Aaug, [16, 16]);
verifySize(testCase, design.Baug, [16, 2]);
end

function testT2ExactlyTwoJointPositionIntegrators(testCase)
design = testCase.TestData.metrics.diagnosticDesign;
m3 = testCase.TestData.m3;
verifySize(testCase, design.Aaug(15:16, :), [2, 16]);
verifyEqual(testCase, design.Aaug(15:16, 1:14), -m3.CfullQ);
verifyEqual(testCase, design.Aaug(15:16, 15:16), zeros(2));
verifyEqual(testCase, design.Baug(15:16, :), zeros(2));
end

function testT3AugmentedPlantIsStabilizable(testCase)
structure = testCase.TestData.metrics.diagnosticDesign.structural;
verifyTrue(testCase, structure.controllablePbh);
verifyTrue(testCase, structure.isStabilizable);
verifyEqual(testCase, structure.zeroPbhRank, 16);
verifyEqual(testCase, structure.zeroRosenbrockRank, 16);
verifyTrue(testCase, structure.noInvariantZeroObstructionAtZero);
end

function testT4AugmentedCostsHaveRequiredProperties(testCase)
design = testCase.TestData.metrics.diagnosticDesign;
verifyGreaterThanOrEqual(testCase, min(eig(design.Qaug)), -1e-8);
verifyGreaterThan(testCase, min(eig(design.R)), 0);
verifyEqual(testCase, design.Qaug, design.Qaug.', 'AbsTol', 1e-12);
verifyEqual(testCase, design.R, design.R.', 'AbsTol', 1e-12);
end

function testT5GridIsCompleteIndependentAndDeterministic(testCase)
metrics = testCase.TestData.metrics;
tableOne = metrics.selection.lqiCandidateTable;
config = lqg_specs_m7;
verifyEqual(testCase, height(tableOne), 28);
verifyEqual(testCase, unique(tableOne.Wi), config.wiCandidates);
verifyEqual(testCase, unique(tableOne.RhoU), config.rhoUCandidates);
repeat = select_lqi_integral(testCase.TestData.m3, ...
    testCase.TestData.m5, testCase.TestData.m6, config);
verifyEqual(testCase, repeat.lqiCandidateTable, tableOne);
verifyEqual(testCase, repeat.selectedIndex, metrics.selection.selectedIndex);
end

function testT6EveryCandidateGainIsTwoBySixteen(testCase)
designs = testCase.TestData.metrics.selection.designs;
for candidateIndex = 1:numel(designs)
    verifySize(testCase, designs{candidateIndex}.Kaug, [2, 16]);
end
end

function testT7PhysicalAndIntegralGainPartitionsAreCorrect(testCase)
designs = testCase.TestData.metrics.selection.designs;
for candidateIndex = 1:numel(designs)
    verifySize(testCase, designs{candidateIndex}.Kx, [2, 14]);
    verifySize(testCase, designs{candidateIndex}.Ki, [2, 2]);
    verifyEqual(testCase, designs{candidateIndex}.Kaug, ...
        [designs{candidateIndex}.Kx, designs{candidateIndex}.Ki]);
end
end

function testT8SelectionGateStopsWithoutAdmissibleCandidate(testCase)
selection = testCase.TestData.metrics.selection;
verifyEmpty(testCase, selection.selectedIndex);
verifyFalse(testCase, any(selection.lqiCandidateTable.Selected));
verifyFalse(testCase, any(selection.lqiCandidateTable.FundamentalPass));
verifyEqual(testCase, ...
    testCase.TestData.metrics.validationMetrics.status, "PARTIAL");
end

function testT9M6PhysicalStateCostIsReusedExactly(testCase)
designs = testCase.TestData.metrics.selection.designs;
m6 = testCase.TestData.m6;
for candidateIndex = 1:numel(designs)
    verifyEqual(testCase, ...
        designs{candidateIndex}.Qaug(1:14, 1:14), m6.Q);
end
end

function testT10TrackingTargetsAreEvaluatedAndExposeTradeoff(testCase)
tableData = testCase.TestData.metrics.selection.lqiCandidateTable;
spec = testCase.TestData.m5.spec;
verifyTrue(testCase, all(isfinite(tableData.WorstOvershoot)));
verifyGreaterThan(testCase, min(tableData.WorstSettlingTime), ...
    spec.settlingTimeTarget);
verifyFalse(testCase, any(tableData.TrackingPass));
end

function testT11PrimaryLqiGridDoesNotUseM6Prefilter(testCase)
source = fileread(fullfile(testCase.TestData.projectRoot, ...
    'controllers', 'lqg', 'select_lqi_integral.m'));
verifyEmpty(testCase, regexp(source, '\<Nr\>', 'once'));
end

function testT13AndT14ConstantDisturbanceOffsetsReachZero(testCase)
evaluation = testCase.TestData.metrics.diagnosticEvaluation;
config = lqg_specs_m7;
tolerance = config.disturbanceSteadyStateTolerance;
verifyLessThanOrEqual(testCase, abs( ...
    evaluation.disturbanceMetrics.SteadyStateOffset(1)), tolerance);
verifyLessThanOrEqual(testCase, abs( ...
    evaluation.disturbanceMetrics.SteadyStateOffset(2)), tolerance);
verifyLessThanOrEqual(testCase, abs( ...
    evaluation.disturbanceOutput{1}(end, 1)), tolerance);
verifyLessThanOrEqual(testCase, abs( ...
    evaluation.disturbanceOutput{2}(end, 2)), tolerance);
end

function testT19NoSaturationOrAntiWindupIsInvented(testCase)
config = testCase.TestData.metrics.config;
verifyFalse(testCase, config.saturationEnabled);
verifyFalse(testCase, config.antiWindupEnabled);
files = {fullfile(testCase.TestData.projectRoot, 'controllers', 'lqg', ...
    'build_lqi_augmented_cost.m'), fullfile( ...
    testCase.TestData.projectRoot, 'controllers', 'lqg', ...
    'select_lqi_integral.m')};
for fileIndex = 1:numel(files)
    source = fileread(files{fileIndex});
    verifyEmpty(testCase, regexp(source, ...
        '\<(sat|saturation|antiwindup|anti-windup)\s*\(', 'once'));
end
end

function testT20ApprovedM6BaselineRemainsAvailable(testCase)
m6 = testCase.TestData.m6;
verifySize(testCase, m6.Klqg.A, [14, 14]);
verifySize(testCase, m6.L, [14, 4]);
verifyTrue(testCase, m6.validationMetrics.tracking.targetsPassed);
end

function testT21GovernanceRecordsResponsibleAlessio(testCase)
files = {fullfile(testCase.TestData.projectRoot, 'docs', ...
    'DIARIO_DI_BORDO.md'), fullfile(testCase.TestData.projectRoot, ...
    'docs', 'PROJECT_STATUS.md'), fullfile( ...
    testCase.TestData.projectRoot, 'docs', 'handoff', ...
    'Resoconto_M7_per_GPT.txt')};
for fileIndex = 1:numel(files)
    verifyTrue(testCase, isfile(files{fileIndex}));
    verifyNotEmpty(testCase, regexp(fileread(files{fileIndex}), ...
        'Responsabile:\s*Alessio', 'once'));
end
end
