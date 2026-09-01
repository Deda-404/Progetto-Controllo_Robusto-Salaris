function tests = test_m4_uncertainty_model
%TEST_M4_UNCERTAINTY_MODEL Public behavior of the single uncertainty set.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
root = fileparts(fileparts(mfilename('fullpath')));
m2 = load(fullfile(root, 'results', 'data', ...
    'm2_linearization_nominal.mat'));
m3 = load(fullfile(root, 'results', 'data', ...
    'm3_nominal_actuated_plant.mat'));
uncertainty = uncertainty_params_m4;
family = build_actuator_family(uncertainty);
fit = fit_actuator_uncertainty_weight(family, uncertainty);
[GmechMeas, GmechQ] = build_uncertain_mechanical_plant( ...
    uncertainty.selectedMechanicalRanges, m2.qbar);
[GuncMeas, GuncQ] = build_m4_uncertain_plant( ...
    GmechMeas, GmechQ, fit.WI);
testCase.TestData = struct('root', root, 'm2', m2, 'm3', m3, ...
    'uncertainty', uncertainty, 'family', family, 'fit', fit, ...
    'GmechMeas', GmechMeas, 'GmechQ', GmechQ, ...
    'GuncMeas', GuncMeas, 'GuncQ', GuncQ);
end

function testSingleDeclaredRangeTable(testCase)
u = testCase.TestData.uncertainty;
verifyEqual(testCase, u.selectedMechanicalRanges.Parameter, ...
    ["k1"; "k2"; "Jm1"]);
verifyEqual(testCase, u.selectedMechanicalRanges.Percentage, [10; 10; 10]);
verifyEqual(testCase, u.selectedActuatorRanges.Percentage, [10; 10; 20]);
verifyEqual(testCase, u.selectedMechanicalRanges.Properties.VariableNames, ...
    {'Parameter', 'NominalValue', 'Percentage', 'Rationale'});
end

function testMechanicalBlocksAreUreal(testCase)
ranges = testCase.TestData.uncertainty.selectedMechanicalRanges;
blocks = testCase.TestData.GmechMeas.Uncertainty;
for index = 1:height(ranges)
    name = char(ranges.Parameter(index));
    verifyClass(testCase, blocks.(name), 'ureal');
    verifyEqual(testCase, blocks.(name).NominalValue, ...
        ranges.NominalValue(index), 'AbsTol', 10 * eps);
    verifyEqual(testCase, blocks.(name).Percentage, ...
        [-ranges.Percentage(index), ranges.Percentage(index)], ...
        'AbsTol', 1e-12);
end
end

function testActuatorFamilyIsReproducible(testCase)
family = testCase.TestData.family;
repeat = build_actuator_family(testCase.TestData.uncertainty);
verifyEqual(testCase, family.numberCornerSamples, 8);
verifyEqual(testCase, family.numberSingleVariationSamples, 6);
verifyGreaterThan(testCase, family.numberRandomSamples, 0);
verifyEqual(testCase, repeat.metadata, family.metadata);
verifyEqual(testCase, repeat.responses, family.responses);
end

function testFirstOrderWeightCoversFamily(testCase)
fit = testCase.TestData.fit;
verifyEqual(testCase, fit.selectedOrder, 1);
verifyTrue(testCase, fit.stable);
verifyTrue(testCase, fit.proper);
verifyLessThanOrEqual(testCase, fit.worstRatio, 1 + fit.coverageTolerance);
verifyGreaterThanOrEqual(testCase, fit.minimumCoverageMargin, ...
    -fit.coverageTolerance);
end

function testIndependentDynamicBlocks(testCase)
blocks = testCase.TestData.GuncMeas.Uncertainty;
verifyClass(testCase, blocks.Delta_act1, 'ultidyn');
verifyClass(testCase, blocks.Delta_act2, 'ultidyn');
verifyNotEqual(testCase, blocks.Delta_act1.Name, blocks.Delta_act2.Name);
verifyEqual(testCase, blocks.Delta_act1.Bound, 1);
verifyEqual(testCase, blocks.Delta_act2.Bound, 1);
end

function testUncertainPlantDimensions(testCase)
verifyEqual(testCase, size(testCase.TestData.GuncMeas), [4, 2]);
verifyEqual(testCase, size(testCase.TestData.GuncQ), [2, 2]);
[~, ~, blocks] = lftdata(testCase.TestData.GuncMeas);
verifyEqual(testCase, numel(blocks), 5);
verifyEqual(testCase, sum(string({blocks.Type}) == "ureal"), 3);
verifyEqual(testCase, sum(string({blocks.Type}) == "ultidyn"), 2);
end

function testNominalValueReproducesM3(testCase)
w = logspace(-1, 3, 301);
errorMeas = freqresp(testCase.TestData.GuncMeas.NominalValue, w) - ...
    freqresp(testCase.TestData.m3.GfullMeas, w);
errorQ = freqresp(testCase.TestData.GuncQ.NominalValue, w) - ...
    freqresp(testCase.TestData.m3.GfullQ, w);
verifyLessThan(testCase, max(abs(errorMeas), [], 'all'), 1e-8);
verifyLessThan(testCase, max(abs(errorQ), [], 'all'), 1e-8);
end

function testUsampleRespectsRanges(testCase)
u = testCase.TestData.uncertainty;
rng(u.plantSamplingSeed, 'twister');
[plants, values] = usample(testCase.TestData.GuncMeas, 6);
verifyEqual(testCase, size(plants, 3), 6);
for sample = 1:6
    verifyTrue(testCase, all(isfinite(pole(plants(:, :, sample)))));
    for row = 1:height(u.selectedMechanicalRanges)
        range = u.selectedMechanicalRanges(row, :);
        fraction = range.Percentage / 100;
        actual = values(sample).(char(range.Parameter));
        verifyGreaterThanOrEqual(testCase, actual, ...
            range.NominalValue * (1 - fraction));
        verifyLessThanOrEqual(testCase, actual, ...
            range.NominalValue * (1 + fraction));
    end
end
end

function testScenarioEnginesWereRemoved(testCase)
verifyFalse(testCase, isfile(fullfile(testCase.TestData.root, ...
    'analysis', 'uncertainty', 'screen_parameter_sensitivity.m')));
verifyFalse(testCase, isfile(fullfile(testCase.TestData.root, ...
    'analysis', 'uncertainty', 'evaluate_uncertainty_scenarios.m')));
end
