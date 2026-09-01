function tests = test_m3_actuator_dynamics
%TEST_M3_ACTUATOR_DYNAMICS Public mathematical behavior of M3.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
root = fileparts(fileparts(mfilename('fullpath')));
m2 = load(fullfile(root, 'results', 'data', ...
    'm2_linearization_nominal.mat'));
params = actuator_params_nominal;
[Gactuator, info] = build_nominal_actuator(params);
[Gbank, bankInfo] = build_nominal_actuator_bank(params);
[Gmeas, Gq] = build_m3_full_plant(m2.A, m2.B, m2.Cmeas, ...
    m2.Dmeas, m2.Cq, m2.Dq, Gbank);
metrics = validate_m3_nominal_actuated_plant;
testCase.TestData = struct('root', root, 'm2', m2, 'params', params, ...
    'Gactuator', Gactuator, 'info', info, 'Gbank', Gbank, ...
    'bankInfo', bankInfo, 'Gmeas', Gmeas, 'Gq', Gq, ...
    'metrics', metrics);
end

function testNominalEngineeringChoice(testCase)
p = testCase.TestData.params;
verifyEqual(testCase, [p.wn, p.zeta, p.delay, p.padeOrder], ...
    [40, 0.8, 0.015, 1]);
row = testCase.TestData.metrics.actuatorComparisonTable;
row = row(row.Choice == "nominal", :);
verifyEqual(testCase, height(row), 1);
verifyTrue(testCase, row.VerificationPassed);
end

function testSecondOrderDynamics(testCase)
info = testCase.TestData.info;
verifyEqual(testCase, order(info.GsecondOrder), 2);
verifyEqual(testCase, info.secondOrderDcGain, 1, 'AbsTol', 1e-12);
verifyTrue(testCase, all(real(info.secondOrderPoles) < 0));
verifyEqual(testCase, abs(info.secondOrderPoles), 40 * ones(2, 1), ...
    'AbsTol', 1e-10);
end

function testFirstOrderPade(testCase)
p = testCase.TestData.params;
info = testCase.TestData.info;
verifyEqual(testCase, order(info.Gpade), 1);
verifyEqual(testCase, info.padePole, -2 / p.delay, 'AbsTol', 1e-10);
verifyEqual(testCase, info.padeZero, 2 / p.delay, 'AbsTol', 1e-10);
verifyEqual(testCase, info.padeDcGain, 1, 'AbsTol', 1e-12);
end

function testActuatorStepAndBandwidth(testCase)
info = testCase.TestData.info;
criteria = testCase.TestData.metrics.engineeringCriteria;
verifyLessThanOrEqual(testCase, info.actuatorStep.Overshoot, 10);
verifyGreaterThanOrEqual(testCase, info.actuatorBandwidth, ...
    criteria.bandwidthMinimum);
verifyLessThanOrEqual(testCase, info.actuatorBandwidth, ...
    criteria.bandwidthMaximum);
end

function testTwoIndependentChannels(testCase)
G = testCase.TestData.Gbank;
verifyEqual(testCase, size(G), [2, 2]);
verifyEqual(testCase, order(G), 6);
verifyEqual(testCase, dcgain(G), eye(2), 'AbsTol', 1e-12);
verifyTrue(testCase, testCase.TestData.bankInfo.nominallyIdenticalChannels);
end

function testCompletePlantDimensions(testCase)
verifyEqual(testCase, size(testCase.TestData.Gmeas), [4, 2]);
verifyEqual(testCase, size(testCase.TestData.Gq), [2, 2]);
verifyEqual(testCase, order(testCase.TestData.Gmeas), 14);
verifyEqual(testCase, order(testCase.TestData.Gq), 14);
end

function testCascadeEquivalence(testCase)
m2 = testCase.TestData.m2;
independent = series(testCase.TestData.Gbank, ...
    ss(m2.A, m2.B, m2.Cmeas, m2.Dmeas));
w = logspace(-2, 3, 301);
difference = freqresp(independent, w) - ...
    freqresp(testCase.TestData.Gmeas, w);
verifyLessThanOrEqual(testCase, max(abs(difference), [], 'all'), 1e-9);
end

function testStabilizableAndDetectable(testCase)
[A, B, C] = ssdata(testCase.TestData.Gmeas);
structure = analyze_m3_structure(A, B, C, 1e-8);
verifyTrue(testCase, structure.controllability.stabilizable);
verifyTrue(testCase, structure.observability.detectable);
verifyEqual(testCase, structure.scaledTime.controllability.rank, 14);
verifyEqual(testCase, structure.scaledTime.observability.rank, 14);
end

function testNoAutomaticSelectorRemains(testCase)
verifyFalse(testCase, isfile(fullfile(testCase.TestData.root, ...
    'analysis', 'nominal', 'select_nominal_actuator.m')));
verifyEqual(testCase, height( ...
    testCase.TestData.metrics.actuatorComparisonTable), 3);
end
