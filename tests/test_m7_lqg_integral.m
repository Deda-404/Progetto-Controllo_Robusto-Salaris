function tests = test_m7_lqg_integral
%TEST_M7_LQG_INTEGRAL Public behavior of the manual LQI feasibility study.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
root = fileparts(fileparts(mfilename('fullpath')));
metrics = validate_m7_lqg_integral;
m6 = load(fullfile(root, 'results', 'data', ...
    'm6_lqg_no_integrator.mat'));
testCase.TestData = struct('root', root, 'metrics', metrics, 'm6', m6);
end

function testThreeNamedManualDesigns(testCase)
tableData = testCase.TestData.metrics.manualComparisonTable;
verifyEqual(testCase, height(tableData), 3);
verifyEqual(testCase, tableData.Tuning, ...
    ["weakIntegral"; "balanced"; "strongIntegral"]);
verifyEqual(testCase, tableData.Wi, [0.1; 1; 4]);
verifyEqual(testCase, tableData.RhoU, [16; 8; 4]);
end

function testAugmentedPlantHasTwoIntegrators(testCase)
for index = 1:3
    design = testCase.TestData.metrics.designs{index};
    verifySize(testCase, design.Aaug, [16, 16]);
    verifySize(testCase, design.Baug, [16, 2]);
    verifySize(testCase, design.Ki, [2, 2]);
    verifyTrue(testCase, design.structural.isStabilizable);
    verifyTrue(testCase, design.structural.noInvariantZeroObstructionAtZero);
end
end

function testM6PhysicalCostIsPreserved(testCase)
m6 = testCase.TestData.m6;
for index = 1:3
    design = testCase.TestData.metrics.designs{index};
    verifyEqual(testCase, design.Qaug(1:14, 1:14), m6.Q, ...
        'AbsTol', 1e-12);
    verifyEqual(testCase, design.physicalScales, ...
        m6.validationMetrics.cost.scales);
end
end

function testAllDesignsAreStableAndRejectConstantDisturbance(testCase)
tableData = testCase.TestData.metrics.manualComparisonTable;
verifyTrue(testCase, all(tableData.Stable));
verifyTrue(testCase, all(tableData.DisturbancePass));
verifyLessThanOrEqual(testCase, tableData.DisturbanceOffset, 1e-4);
end

function testNegativePerformanceIsRecorded(testCase)
tableData = testCase.TestData.metrics.manualComparisonTable;
validation = testCase.TestData.metrics.validationMetrics;
verifyFalse(testCase, any(tableData.FundamentalPass));
verifyEqual(testCase, validation.status, "PARTIAL");
verifyEqual(testCase, validation.admissibleCount, 0);
verifyTrue(testCase, validation.noControllerPublished);
end

function testNoAutomaticLqiSearchRemains(testCase)
oldFiles = { ...
    fullfile('controllers', 'lqg', 'select_lqi_integral.m'), ...
    fullfile('controllers', 'lqg', 'retune_lqi_augmented_cost_m7.m'), ...
    fullfile('analysis', 'nominal', ...
    'validate_m7_augmented_cost_feasibility.m')};
for index = 1:numel(oldFiles)
    verifyFalse(testCase, isfile(fullfile( ...
        testCase.TestData.root, oldFiles{index})));
end
end

function testFinalArtifactsExist(testCase)
root = testCase.TestData.root;
verifyTrue(testCase, isfile(fullfile(root, 'results', 'data', ...
    'm7_augmented_cost_feasibility.mat')));
verifyTrue(testCase, isfile(fullfile(root, 'results', 'figures', ...
    'm7_augmented_cost_tradeoff.png')));
end
