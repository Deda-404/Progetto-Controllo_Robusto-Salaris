function tests = test_m2_equilibrium_linearization
%TEST_M2_EQUILIBRIUM_LINEARIZATION M2 equilibrium and LTI model checks.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
p = sea_params_nominal;
qbar = [pi/2; 0];
[xbar, taubar, equilibriumInfo] = sea_static_equilibrium(qbar, p);
[A, B] = sea_linearize_symbolic(xbar, taubar, p);
[Anumeric, Bnumeric, finiteDifferenceInfo] = finite_difference_jacobian( ...
    @(x, tau) sea_nonlinear_rhs(x, tau, p), xbar, taubar, 3e-6);
[Cq, Dq, Cmeas, Dmeas] = sea_output_matrices;

testCase.TestData.p = p;
testCase.TestData.qbar = qbar;
testCase.TestData.xbar = xbar;
testCase.TestData.taubar = taubar;
testCase.TestData.equilibriumInfo = equilibriumInfo;
testCase.TestData.A = A;
testCase.TestData.B = B;
testCase.TestData.Anumeric = Anumeric;
testCase.TestData.Bnumeric = Bnumeric;
testCase.TestData.finiteDifferenceInfo = finiteDifferenceInfo;
testCase.TestData.Cq = Cq;
testCase.TestData.Dq = Dq;
testCase.TestData.Cmeas = Cmeas;
testCase.TestData.Dmeas = Dmeas;
end

function testT1GeneralEquilibrium(testCase)
p = testCase.TestData.p;
qbar = [0.35; -0.60];
[xbar, taubar, info] = sea_static_equilibrium(qbar, p);

expectedGravity = [ ...
    (p.m1 + p.m2) * p.g * p.l1 * cos(qbar(1)) + ...
        p.m2 * p.g * p.l2 * cos(qbar(1) + qbar(2)); ...
    p.m2 * p.g * p.l2 * cos(qbar(1) + qbar(2))];
expectedTheta = qbar + p.Ks \ expectedGravity;

verifySize(testCase, xbar, [8, 1]);
verifySize(testCase, taubar, [2, 1]);
verifyEqual(testCase, info.Gbar, expectedGravity, 'AbsTol', 1e-12);
verifyEqual(testCase, info.thetabar, expectedTheta, 'AbsTol', 1e-12);
verifyEqual(testCase, taubar, expectedGravity, 'AbsTol', 1e-12);
verifyEqual(testCase, xbar, [qbar; zeros(2, 1); expectedTheta; zeros(2, 1)], ...
    'AbsTol', 1e-12);
verifyLessThanOrEqual(testCase, norm(info.staticLinkResidual, inf), 1e-12);
verifyLessThanOrEqual(testCase, norm(info.staticMotorResidual, inf), 1e-12);
verifyLessThanOrEqual(testCase, info.residualNorm, 1e-10);
end

function testT2SelectedEquilibrium(testCase)
qbar = testCase.TestData.qbar;
xbar = testCase.TestData.xbar;
taubar = testCase.TestData.taubar;
info = testCase.TestData.equilibriumInfo;

verifyEqual(testCase, qbar, [pi/2; 0], 'AbsTol', 1e-14);
verifyLessThanOrEqual(testCase, norm(info.Gbar, inf), 1e-12);
verifyLessThanOrEqual(testCase, norm(info.thetabar - qbar, inf), 1e-12);
verifyLessThanOrEqual(testCase, norm(taubar, inf), 1e-12);
verifyEqual(testCase, xbar(1:2), qbar, 'AbsTol', 1e-14);
verifyEqual(testCase, xbar(3:4), zeros(2, 1), 'AbsTol', 1e-14);
verifyEqual(testCase, xbar(5:6), info.thetabar, 'AbsTol', 1e-14);
verifyEqual(testCase, xbar(7:8), zeros(2, 1), 'AbsTol', 1e-14);
verifyLessThanOrEqual(testCase, info.residualNorm, 1e-10);
end

function testT3SymbolicJacobianDimensions(testCase)
A = testCase.TestData.A;
B = testCase.TestData.B;

verifySize(testCase, A, [8, 8]);
verifySize(testCase, B, [8, 2]);
verifyTrue(testCase, all(isfinite(A), 'all'));
verifyTrue(testCase, all(isfinite(B), 'all'));
verifyEqual(testCase, A(1:2, 3:4), eye(2), 'AbsTol', 1e-13);
verifyEqual(testCase, A(5:6, 7:8), eye(2), 'AbsTol', 1e-13);
end

function testT4SymbolicVersusNumericalJacobians(testCase)
A = testCase.TestData.A;
B = testCase.TestData.B;
deltaA = A - testCase.TestData.Anumeric;
deltaB = B - testCase.TestData.Bnumeric;

verifyEqual(testCase, testCase.TestData.finiteDifferenceInfo.step, 3e-6);
verifyLessThanOrEqual(testCase, max(abs(deltaA), [], 'all'), 1e-6);
verifyLessThanOrEqual(testCase, max(abs(deltaB), [], 'all'), 1e-10);
verifyLessThanOrEqual(testCase, norm(deltaA, 'fro'), 1e-6);
verifyLessThanOrEqual(testCase, norm(deltaB, 'fro'), 1e-10);
verifyLessThanOrEqual(testCase, norm(deltaA, 'fro') / norm(A, 'fro'), 1e-9);
end

function testT5LocalLinearization(testCase)
p = testCase.TestData.p;
xbar = testCase.TestData.xbar;
taubar = testCase.TestData.taubar;
A = testCase.TestData.A;
B = testCase.TestData.B;
amplitudes = [1e-2, 1e-3, 1e-4, 1e-5];
stateDirection = [0.35; -0.25; 0.20; -0.15; -0.30; 0.40; 0.10; -0.20];
inputDirection = [0.50; -0.35];
errors = zeros(size(amplitudes));

for index = 1:numel(amplitudes)
    deltaX = amplitudes(index) * stateDirection;
    deltaTau = amplitudes(index) * inputDirection;
    nonlinearDerivative = sea_nonlinear_rhs( ...
        xbar + deltaX, taubar + deltaTau, p);
    linearDerivative = A * deltaX + B * deltaTau;
    errors(index) = norm(nonlinearDerivative - linearDerivative, 2);
end
orders = log(errors(1:end-1) ./ errors(2:end)) ./ ...
    log(amplitudes(1:end-1) ./ amplitudes(2:end));

verifyTrue(testCase, all(diff(errors) < 0));
verifyGreaterThan(testCase, orders, 1.5 * ones(size(orders)));
end

function testT6ControllabilityAndStabilizability(testCase)
metrics = analyze_m2_structure(testCase.TestData.A, testCase.TestData.B, ...
    testCase.TestData.Cmeas, 1e-8);

verifyEqual(testCase, metrics.controllability.rank, 8);
verifyGreaterThan(testCase, metrics.controllability.singularValues(end), ...
    metrics.controllability.tolerance);
verifyTrue(testCase, isfinite(metrics.controllability.conditionNumber));
verifyGreaterThan(testCase, metrics.numberUnstable, 0);
verifyTrue(testCase, metrics.controllability.stabilizable);
verifyEqual(testCase, metrics.controllability.pbhRanks, ...
    8 * ones(size(metrics.controllability.pbhRanks)));
verifyGreaterThan(testCase, ...
    metrics.controllability.pbhMinimumSingularValues, ...
    metrics.controllability.pbhTolerances);
end

function testT7ObservabilityAndDetectability(testCase)
A = testCase.TestData.A;
B = testCase.TestData.B;
metricsMeas = analyze_m2_structure(A, B, testCase.TestData.Cmeas, 1e-8);
metricsQ = analyze_m2_structure(A, B, testCase.TestData.Cq, 1e-8);

verifyEqual(testCase, metricsMeas.observability.rank, 8);
verifyTrue(testCase, metricsMeas.observability.detectable);
verifyEqual(testCase, metricsMeas.observability.pbhRanks, ...
    8 * ones(size(metricsMeas.observability.pbhRanks)));
verifyGreaterThan(testCase, ...
    metricsMeas.observability.pbhMinimumSingularValues, ...
    metricsMeas.observability.pbhTolerances);
verifyEqual(testCase, metricsQ.observability.rank, 8);
verifyTrue(testCase, metricsQ.observability.detectable);
end

function testT8OutputMatrices(testCase)
CqExpected = [eye(2), zeros(2, 6)];
CmeasExpected = [ ...
    eye(2), zeros(2, 6); ...
    zeros(2, 4), eye(2), zeros(2, 2)];

verifySize(testCase, testCase.TestData.Cq, [2, 8]);
verifySize(testCase, testCase.TestData.Dq, [2, 2]);
verifySize(testCase, testCase.TestData.Cmeas, [4, 8]);
verifySize(testCase, testCase.TestData.Dmeas, [4, 2]);
verifyEqual(testCase, testCase.TestData.Cq, CqExpected, 'AbsTol', 0);
verifyEqual(testCase, testCase.TestData.Cmeas, CmeasExpected, 'AbsTol', 0);
verifyEqual(testCase, testCase.TestData.Dq, zeros(2, 2), 'AbsTol', 0);
verifyEqual(testCase, testCase.TestData.Dmeas, zeros(4, 2), 'AbsTol', 0);
end

function testT9M1Regression(testCase)
projectRoot = fileparts(fileparts(mfilename('fullpath')));
m1Results = runtests(fullfile(projectRoot, 'tests', ...
    'test_m1_nonlinear_model.m'));

verifyEqual(testCase, numel(m1Results), 7);
verifyTrue(testCase, all([m1Results.Passed]));
end
