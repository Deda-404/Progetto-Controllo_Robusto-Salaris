function tests = test_m5_performance_specs
%TEST_M5_PERFORMANCE_SPECS Public behavior of targets and weights.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
root = fileparts(fileparts(mfilename('fullpath')));
metrics = validate_m5_performance_specs;
m2 = load(fullfile(root, 'results', 'data', ...
    'm2_linearization_nominal.mat'));
m3 = load(fullfile(root, 'results', 'data', ...
    'm3_nominal_actuated_plant.mat'));
m5 = load(fullfile(root, 'results', 'data', ...
    'm5_performance_specs.mat'));
testCase.TestData = struct('root', root, 'metrics', metrics, ...
    'm2', m2, 'm3', m3, 'm5', m5);
end

function testSingleSpecificationSet(testCase)
spec = testCase.TestData.m5.spec;
verifyEqual(testCase, [spec.omegaB, spec.omegaW1, spec.As, spec.Ms, ...
    spec.uScale, spec.controlWeightGain, spec.omegaU, spec.controlWeightAlpha], ...
    [12, 8, 0.15, 2.5, 12, 0.05, 60, 6]);
candidateFields = fieldnames(spec);
verifyFalse(testCase, any(contains(candidateFields, 'Candidates')));
end

function testBandwidthIsPhysicallySeparated(testCase)
criteria = testCase.TestData.m5.frequencyCriteria;
spec = testCase.TestData.m5.spec;
verifyTrue(testCase, criteria.bandwidthVerified);
verifyGreaterThanOrEqual(testCase, spec.omegaB, ...
    criteria.bandwidthMinimum);
verifyLessThanOrEqual(testCase, spec.omegaB, ...
    criteria.bandwidthMaximum);
verifyLessThan(testCase, spec.omegaB, criteria.omegaElasticMin);
verifyLessThan(testCase, spec.omegaB, criteria.omegaActuator);
end

function testW1MeaningAndAsymptotes(testCase)
spec = testCase.TestData.m5.spec;
info = testCase.TestData.m5.validationMetrics.weights.W1;
verifyTrue(testCase, info.stable);
verifyTrue(testCase, info.proper);
verifyEqual(testCase, info.dcMeasured, 1 / spec.As, 'AbsTol', 1e-12);
verifyEqual(testCase, info.hfMeasured, 1 / spec.Ms, 'AbsTol', 1e-7);
end

function testW2MeaningAndAsymptotes(testCase)
spec = testCase.TestData.m5.spec;
info = testCase.TestData.m5.validationMetrics.weights.W2;
verifyTrue(testCase, info.stable);
verifyTrue(testCase, info.proper);
verifyEqual(testCase, info.dcMeasured, spec.controlWeightGain, 'AbsTol', 1e-12);
verifyEqual(testCase, info.hfMeasured, ...
    spec.controlWeightAlpha * spec.controlWeightGain, 'AbsTol', 1e-7);
verifyTrue(testCase, contains(spec.controlEffortScaleMeaning, ...
    "not a certified actuator saturation"));
end

function testMimoWeightsAreDiagonal(testCase)
m5 = testCase.TestData.m5;
verifyEqual(testCase, size(m5.W1), [2, 2]);
verifyEqual(testCase, size(m5.W2), [2, 2]);
verifyEqual(testCase, dcgain(m5.W1(1, 2)), 0, 'AbsTol', 1e-14);
verifyEqual(testCase, dcgain(m5.W2(2, 1)), 0, 'AbsTol', 1e-14);
end

function testLinkDisturbancePath(testCase)
m2 = testCase.TestData.m2;
m3 = testCase.TestData.m3;
m5 = testCase.TestData.m5;
verifySize(testCase, m5.Bd, [8, 2]);
verifyEqual(testCase, m5.Bd(3:4, :), ...
    sea_link_inertia(m2.qbar, m2.p) \ eye(2), 'AbsTol', 1e-12);
verifyEqual(testCase, m5.disturbancePlant.B(:, 1:2), m3.Bfull);
verifyEqual(testCase, m5.disturbancePlant.B(:, 3:4), m5.BdFull);
end

function testNoSynthesisInSpecificationPhase(testCase)
spec = testCase.TestData.m5.spec;
verifyFalse(testCase, spec.controllerSynthesisAllowed);
verifyFalse(testCase, spec.useW3);
end

function testAutomaticSelectorWasRemoved(testCase)
verifyFalse(testCase, isfile(fullfile(testCase.TestData.root, ...
    'analysis', 'nominal', 'select_m5_performance_specs.m')));
verifyTrue(testCase, isfile(fullfile(testCase.TestData.root, ...
    'analysis', 'modellazione_linearizzazione_controllo.m')));
end
