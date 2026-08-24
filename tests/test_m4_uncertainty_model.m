function tests = test_m4_uncertainty_model
%TEST_M4_UNCERTAINTY_MODEL M4 uncertainty construction quality gates.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(projectRoot, 'src')));
addpath(genpath(fullfile(projectRoot, 'analysis')));
testCase.TestData.projectRoot = projectRoot;
testCase.TestData.m2 = load(fullfile(projectRoot, 'results', 'data', ...
    'm2_linearization_nominal.mat'));
testCase.TestData.m3 = load(fullfile(projectRoot, 'results', 'data', ...
    'm3_nominal_actuated_plant.mat'));
testCase.TestData.screening = screen_parameter_sensitivity;
testCase.TestData.uncertainty = uncertainty_params_m4( ...
    testCase.TestData.screening.selectedMechanicalParameters);
testCase.TestData.family = build_actuator_family( ...
    testCase.TestData.uncertainty);
testCase.TestData.fit = fit_actuator_uncertainty_weight( ...
    testCase.TestData.family, testCase.TestData.uncertainty);
[testCase.TestData.GmechMeas, testCase.TestData.GmechQ] = ...
    build_uncertain_mechanical_plant( ...
    testCase.TestData.uncertainty.selectedMechanicalRanges, ...
    testCase.TestData.m2.qbar);
[testCase.TestData.GuncMeas, testCase.TestData.GuncQ] = ...
    build_m4_uncertain_plant(testCase.TestData.GmechMeas, ...
    testCase.TestData.GmechQ, testCase.TestData.fit.WI);
end

function testT1SensitivityScreenReproducible(testCase)
secondScreening = screen_parameter_sensitivity;
verifyEqual(testCase, secondScreening.parameterSensitivityTable, ...
    testCase.TestData.screening.parameterSensitivityTable);
verifyEqual(testCase, secondScreening.selectedMechanicalParameters, ...
    testCase.TestData.screening.selectedMechanicalParameters);
end

function testT2LimitedMechanicalSelection(testCase)
selected = testCase.TestData.screening.selectedMechanicalParameters;
verifyEqual(testCase, numel(selected), 3);
verifyEqual(testCase, selected, ["k2"; "k1"; "Jm1"]);
verifyLessThanOrEqual(testCase, numel(selected), 4);
end

function testT3RangesFinitePositiveAndContainNominal(testCase)
tables = {testCase.TestData.uncertainty.mechanicalScenarios, ...
    testCase.TestData.uncertainty.actuatorScenarios};
for tableIndex = 1:numel(tables)
    ranges = tables{tableIndex};
    values = [ranges.NominalValue, ranges.MildPercent, ...
        ranges.BaselinePercent, ranges.ConservativePercent];
    verifyTrue(testCase, all(isfinite(values), 'all'));
    verifyTrue(testCase, all(values > 0, 'all'));
    verifyTrue(testCase, all(ranges.MildPercent < ...
        ranges.BaselinePercent));
    verifyTrue(testCase, all(ranges.BaselinePercent < ...
        ranges.ConservativePercent));
    lowerBound = ranges.NominalValue .* ...
        (1 - ranges.BaselinePercent / 100);
    upperBound = ranges.NominalValue .* ...
        (1 + ranges.BaselinePercent / 100);
    verifyTrue(testCase, all(lowerBound < ranges.NominalValue));
    verifyTrue(testCase, all(upperBound > ranges.NominalValue));
end
end

function testT4UrealNominalValuesCorrect(testCase)
ranges = testCase.TestData.uncertainty.selectedMechanicalRanges;
blocks = testCase.TestData.GmechMeas.Uncertainty;
for index = 1:height(ranges)
    name = char(ranges.Parameter(index));
    verifyClass(testCase, blocks.(name), 'ureal');
    verifyEqual(testCase, blocks.(name).NominalValue, ...
        ranges.NominalValue(index), 'AbsTol', 10 * eps);
end
end

function testT5RealBlockStructurePreserved(testCase)
names = string(fieldnames(testCase.TestData.GmechMeas.Uncertainty));
verifyEqual(testCase, sort(names), sort( ...
    testCase.TestData.screening.selectedMechanicalParameters));
[~, ~, blockStructure] = lftdata(testCase.TestData.GmechMeas);
verifyEqual(testCase, numel(blockStructure), 3);
verifyTrue(testCase, all(string({blockStructure.Type}).' == "ureal"));
verifyTrue(testCase, all([blockStructure.Occurrences].' >= 1));
end

function testT6ActuatorFamilyHasCornersAndSamples(testCase)
family = testCase.TestData.family;
verifyGreaterThanOrEqual(testCase, family.numberSamples, 100);
verifyEqual(testCase, family.numberCornerSamples, 8);
verifyEqual(testCase, family.numberSingleVariationSamples, 6);
verifyEqual(testCase, sum(family.metadata.Kind == "nominal-exact"), 1);
verifyGreaterThan(testCase, family.numberRandomSamples, 0);
secondFamily = build_actuator_family(testCase.TestData.uncertainty);
verifyEqual(testCase, secondFamily.metadata, family.metadata);
verifyEqual(testCase, secondFamily.responses, family.responses);
end

function testT7WeightStableProperAndMinimumOrder(testCase)
fit = testCase.TestData.fit;
verifyTrue(testCase, fit.stable);
verifyTrue(testCase, fit.proper);
acceptableOrders = fit.fitCandidateTable.Order( ...
    fit.fitCandidateTable.Acceptable);
verifyEqual(testCase, fit.selectedOrder, min(acceptableOrders));
verifyEqual(testCase, fit.selectedOrder, 1);
end

function testT8WeightCoversCompleteFamily(testCase)
fit = testCase.TestData.fit;
verifyLessThanOrEqual(testCase, fit.worstRatio, ...
    1 + fit.coverageTolerance);
verifyGreaterThanOrEqual(testCase, fit.minimumCoverageMargin, ...
    -fit.coverageTolerance);
verifyEqual(testCase, size(testCase.TestData.family.multiplicativeErrors), ...
    [testCase.TestData.family.numberSamples, ...
    numel(testCase.TestData.family.frequencies)]);
end

function testT9IndependentActuatorDeltas(testCase)
blocks = testCase.TestData.GuncMeas.Uncertainty;
verifyTrue(testCase, isfield(blocks, 'Delta_act1'));
verifyTrue(testCase, isfield(blocks, 'Delta_act2'));
verifyClass(testCase, blocks.Delta_act1, 'ultidyn');
verifyClass(testCase, blocks.Delta_act2, 'ultidyn');
verifyNotEqual(testCase, blocks.Delta_act1.Name, blocks.Delta_act2.Name);
verifyEqual(testCase, blocks.Delta_act1.Bound, 1);
verifyEqual(testCase, blocks.Delta_act2.Bound, 1);
end

function testT10UncertainPlantDimensions(testCase)
verifyEqual(testCase, size(testCase.TestData.GuncMeas), [4, 2]);
verifyEqual(testCase, size(testCase.TestData.GuncQ), [2, 2]);
verifyEqual(testCase, string(testCase.TestData.GuncMeas.InputName), ...
    ["u1"; "u2"]);
verifyEqual(testCase, string(testCase.TestData.GuncMeas.OutputName), ...
    ["q1"; "q2"; "theta1"; "theta2"]);
end

function testT11NominalPlantEqualsM3(testCase)
frequencies = logspace(-1, 3, 401);
measError = freqresp(testCase.TestData.GuncMeas.NominalValue, ...
    frequencies) - freqresp(testCase.TestData.m3.GfullMeas, frequencies);
qError = freqresp(testCase.TestData.GuncQ.NominalValue, frequencies) - ...
    freqresp(testCase.TestData.m3.GfullQ, frequencies);
verifyLessThan(testCase, max(abs(measError(:))), 1e-8);
verifyLessThan(testCase, max(abs(qError(:))), 1e-8);
verifyLessThan(testCase, norm( ...
    testCase.TestData.GmechMeas.NominalValue.A - ...
    testCase.TestData.m2.A, 'fro'), 1e-8);
end

function testT12LftdataStructureCoherent(testCase)
[M, Delta, blockStructure] = lftdata(testCase.TestData.GuncMeas);
verifyFalse(testCase, isempty(M));
verifyFalse(testCase, isempty(Delta));
verifyEqual(testCase, numel(blockStructure), 5);
names = string({blockStructure.Name}).';
expectedNames = [testCase.TestData.screening.selectedMechanicalParameters; ...
    "Delta_act1"; "Delta_act2"];
verifyTrue(testCase, all(ismember(expectedNames, names)));
verifyEqual(testCase, sum(string({blockStructure.Type}) == "ureal"), 3);
verifyEqual(testCase, sum(string({blockStructure.Type}) == "ultidyn"), 2);
verifyTrue(testCase, all([blockStructure.Occurrences] >= 1));
end

function testT13UsampleProducesValidPlants(testCase)
numberSamples = 8;
rng(testCase.TestData.uncertainty.plantSamplingSeed, 'twister');
[sampledPlants, sampledValues] = usample( ...
    testCase.TestData.GuncMeas, numberSamples);
frequencies = logspace(-1, 3, 101);
ranges = testCase.TestData.uncertainty.selectedMechanicalRanges;
for sampleIndex = 1:numberSamples
    samplePlant = sampledPlants(:, :, sampleIndex);
    verifyEqual(testCase, size(samplePlant), [4, 2]);
    response = freqresp(samplePlant, frequencies);
    verifyTrue(testCase, all(isfinite(response), 'all'));
    verifyTrue(testCase, all(isfinite(pole(samplePlant))));
    for parameterIndex = 1:height(ranges)
        name = char(ranges.Parameter(parameterIndex));
        nominal = ranges.NominalValue(parameterIndex);
        fraction = ranges.BaselinePercent(parameterIndex) / 100;
        verifyGreaterThanOrEqual(testCase, ...
            sampledValues(sampleIndex).(name), nominal * (1 - fraction));
        verifyLessThanOrEqual(testCase, ...
            sampledValues(sampleIndex).(name), nominal * (1 + fraction));
    end
end
end

function testT14RegressionsM0ThroughM31(testCase)
testFiles = { ...
    fullfile(testCase.TestData.projectRoot, 'tests', 'test_m0_workspace.m'), ...
    fullfile(testCase.TestData.projectRoot, 'tests', ...
    'test_m1_nonlinear_model.m'), ...
    fullfile(testCase.TestData.projectRoot, 'tests', ...
    'test_m2_equilibrium_linearization.m'), ...
    fullfile(testCase.TestData.projectRoot, 'tests', ...
    'test_m3_actuator_dynamics.m')};
suite = testsuite(testFiles{1});
for fileIndex = 2:numel(testFiles)
    suite = [suite, testsuite(testFiles{fileIndex})]; %#ok<AGROW>
end
priorResults = run(suite);
verifyEqual(testCase, numel(priorResults), 34);
verifyTrue(testCase, all([priorResults.Passed]));
end
