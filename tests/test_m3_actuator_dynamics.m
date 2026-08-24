function tests = test_m3_actuator_dynamics
%TEST_M3_ACTUATOR_DYNAMICS Nominal actuators and 14-state plant checks.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
projectRoot = fileparts(fileparts(mfilename('fullpath')));
m2 = load(fullfile(projectRoot, 'results', 'data', ...
    'm2_linearization_nominal.mat'));
params = actuator_params_nominal;
[Gactuator, actuatorInfo] = build_nominal_actuator(params);
[Gactuators, actuatorBankInfo] = build_nominal_actuator_bank(params);
[GfullMeas, GfullQ, fullInfo] = build_m3_full_plant( ...
    m2.A, m2.B, m2.Cmeas, m2.Dmeas, m2.Cq, m2.Dq, Gactuators);

testCase.TestData.projectRoot = projectRoot;
testCase.TestData.m2 = m2;
testCase.TestData.params = params;
testCase.TestData.Gactuator = Gactuator;
testCase.TestData.actuatorInfo = actuatorInfo;
testCase.TestData.Gactuators = Gactuators;
testCase.TestData.actuatorBankInfo = actuatorBankInfo;
testCase.TestData.GfullMeas = GfullMeas;
testCase.TestData.GfullQ = GfullQ;
testCase.TestData.fullInfo = fullInfo;
end

function testT1Parameters(testCase)
params = testCase.TestData.params;

verifyEqual(testCase, sort(fieldnames(params)), ...
    sort({'wn'; 'zeta'; 'delay'; 'padeOrder'}));
verifyGreaterThan(testCase, params.wn, 0);
verifyGreaterThan(testCase, params.zeta, 0);
verifyLessThanOrEqual(testCase, params.zeta, 2);
verifyGreaterThan(testCase, params.delay, 0);
verifyLessThan(testCase, params.delay, 0.1);
verifyEqual(testCase, params.padeOrder, 1);
end

function testT2SecondOrder(testCase)
info = testCase.TestData.actuatorInfo;

verifyEqual(testCase, order(info.GsecondOrder), 2);
verifyEqual(testCase, info.secondOrderDcGain, 1, 'AbsTol', 1e-12);
verifyTrue(testCase, all(real(info.secondOrderPoles) < 0));
verifyEqual(testCase, abs(info.secondOrderPoles), ...
    testCase.TestData.params.wn * ones(2, 1), 'AbsTol', 1e-10);
end

function testT3FirstOrderPade(testCase)
params = testCase.TestData.params;
info = testCase.TestData.actuatorInfo;
expectedLocation = 2 / params.delay;

verifyEqual(testCase, order(info.Gpade), 1);
verifyEqual(testCase, info.padeDcGain, 1, 'AbsTol', 1e-12);
verifyEqual(testCase, info.padePole, -expectedLocation, 'AbsTol', 1e-10);
verifyEqual(testCase, info.padeZero, expectedLocation, 'AbsTol', 1e-10);
verifyLessThan(testCase, info.padePole, 0);
verifyGreaterThan(testCase, info.padeZero, 0);
end

function testT4SisoActuator(testCase)
Gactuator = testCase.TestData.Gactuator;
info = testCase.TestData.actuatorInfo;

verifyEqual(testCase, order(Gactuator), 3);
verifyEqual(testCase, info.actuatorDcGain, 1, 'AbsTol', 1e-12);
verifyTrue(testCase, all(real(info.actuatorPoles) < 0));
verifyTrue(testCase, any(info.actuatorZeros > 0));
verifyEqual(testCase, numel(info.actuatorPoles), 3);
verifyEqual(testCase, numel(info.actuatorZeros), 1);
end

function testT5TwoActuators(testCase)
Gactuators = testCase.TestData.Gactuators;
frequencies = logspace(-2, 3, 101);

verifyEqual(testCase, order(Gactuators), 6);
verifyEqual(testCase, size(Gactuators), [2, 2]);
verifyEqual(testCase, dcgain(Gactuators), eye(2), 'AbsTol', 1e-12);
verifyEqual(testCase, squeeze(freqresp(Gactuators(1, 2), frequencies)), ...
    zeros(numel(frequencies), 1), 'AbsTol', 1e-14);
verifyEqual(testCase, squeeze(freqresp(Gactuators(2, 1), frequencies)), ...
    zeros(numel(frequencies), 1), 'AbsTol', 1e-14);
verifyTrue(testCase, testCase.TestData.actuatorBankInfo.nominallyIdenticalChannels);
end

function testT6CompletePlant(testCase)
GfullMeas = testCase.TestData.GfullMeas;
GfullQ = testCase.TestData.GfullQ;
fullInfo = testCase.TestData.fullInfo;

verifyEqual(testCase, order(GfullMeas), 14);
verifyEqual(testCase, order(GfullQ), 14);
verifyEqual(testCase, size(GfullMeas), [4, 2]);
verifyEqual(testCase, size(GfullQ), [2, 2]);
verifySize(testCase, fullInfo.Afull, [14, 14]);
verifySize(testCase, fullInfo.Bfull, [14, 2]);
verifySize(testCase, fullInfo.CfullMeas, [4, 14]);
verifyEqual(testCase, fullInfo.mechanicalStateCount, 8);
verifyEqual(testCase, fullInfo.actuatorStateCount, 6);
verifyEqual(testCase, GfullMeas.StateName(1:8), ...
    {'q1'; 'q2'; 'q1dot'; 'q2dot'; 'theta1'; 'theta2'; ...
    'theta1dot'; 'theta2dot'});
end

function testT7IndependentInterconnection(testCase)
m2 = testCase.TestData.m2;
Gmechanical = ss(m2.A, m2.B, m2.Cmeas, m2.Dmeas);
independentPlant = series(testCase.TestData.Gactuators, Gmechanical);
frequencies = logspace(-2, 3, 401);
explicitResponse = freqresp(testCase.TestData.GfullMeas, frequencies);
independentResponse = freqresp(independentPlant, frequencies);
absoluteErrors = zeros(size(frequencies));
relativeErrors = zeros(size(frequencies));

for index = 1:numel(frequencies)
    difference = explicitResponse(:, :, index) - ...
        independentResponse(:, :, index);
    absoluteErrors(index) = norm(difference, 'fro');
    relativeErrors(index) = absoluteErrors(index) / ...
        max(norm(independentResponse(:, :, index), 'fro'), eps);
end

verifyLessThanOrEqual(testCase, max(absoluteErrors), 1e-9);
verifyLessThanOrEqual(testCase, max(relativeErrors), 1e-9);
end

function testT8FullPlantPoles(testCase)
fullPoles = pole(testCase.TestData.GfullMeas);
mechanicalPoles = testCase.TestData.m2.poles;
actuatorPoles = pole(testCase.TestData.Gactuators);

verifyEqual(testCase, numel(fullPoles), 14);
verifyEqual(testCase, sum(real(fullPoles) > 1e-8), ...
    sum(real(mechanicalPoles) > 1e-8));
verifyEqual(testCase, sum(abs(real(fullPoles)) <= 1e-8), 0);
verifyTrue(testCase, all(real(actuatorPoles) < -1e-8));
for index = 1:numel(actuatorPoles)
    verifyLessThanOrEqual(testCase, min(abs(fullPoles - actuatorPoles(index))), ...
        1e-8);
end
end

function testT9ControllabilityAndStabilizability(testCase)
[Afull, Bfull, Cfull] = ssdata(testCase.TestData.GfullMeas);
metrics = analyze_m3_structure(Afull, Bfull, Cfull, 1e-8);

verifyEqual(testCase, metrics.scaledTime.controllability.rank, 14);
verifyTrue(testCase, metrics.controllability.controllablePbh);
verifyTrue(testCase, metrics.controllability.stabilizable);
verifyEqual(testCase, metrics.controllability.pbhRanks, ...
    14 * ones(size(metrics.controllability.pbhRanks)));
verifyGreaterThan(testCase, ...
    metrics.controllability.pbhMinimumSingularValues, ...
    metrics.controllability.pbhTolerances);
end

function testT10ObservabilityAndDetectability(testCase)
[Afull, Bfull, CfullMeas] = ssdata(testCase.TestData.GfullMeas);
[~, ~, CfullQ] = ssdata(testCase.TestData.GfullQ);
metricsMeas = analyze_m3_structure(Afull, Bfull, CfullMeas, 1e-8);
metricsQ = analyze_m3_structure(Afull, Bfull, CfullQ, 1e-8);

verifyEqual(testCase, metricsMeas.scaledTime.observability.rank, 14);
verifyTrue(testCase, metricsMeas.observability.observablePbh);
verifyTrue(testCase, metricsMeas.observability.detectable);
verifyEqual(testCase, metricsMeas.observability.pbhRanks, ...
    14 * ones(size(metricsMeas.observability.pbhRanks)));
verifyGreaterThan(testCase, ...
    metricsMeas.observability.pbhMinimumSingularValues, ...
    metricsMeas.observability.pbhTolerances);
verifyEqual(testCase, metricsQ.scaledTime.observability.rank, 14);
verifyTrue(testCase, metricsQ.observability.detectable);
end

function testT11M0M1M2Regression(testCase)
testsDirectory = fullfile(testCase.TestData.projectRoot, 'tests');
m0Results = runtests(fullfile(testsDirectory, 'test_m0_workspace.m'));
m1Results = runtests(fullfile(testsDirectory, 'test_m1_nonlinear_model.m'));
m2Results = runtests(fullfile(testsDirectory, ...
    'test_m2_equilibrium_linearization.m'));
allResults = [m0Results(:); m1Results(:); m2Results(:)];

verifyEqual(testCase, numel(allResults), 18);
verifyTrue(testCase, all([allResults.Passed]));
end
