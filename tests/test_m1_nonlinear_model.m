function tests = test_m1_nonlinear_model
%TEST_M1_NONLINEAR_MODEL Independent checks of the nonlinear SEA model.
tests = functiontests(localfunctions);
end

function testT1NominalParameters(testCase)
p = sea_params_nominal;
expectedFields = {'m1'; 'm2'; 'l1'; 'l2'; 'Jm'; 'Bm'; 'Ks'; 'g'};

verifyEqual(testCase, sort(fieldnames(p)), sort(expectedFields));
verifyEqual(testCase, [p.m1, p.m2, p.l1, p.l2, p.g], ...
    [1.0, 0.8, 0.4, 0.3, 9.81], 'AbsTol', 1e-14);
verifyEqual(testCase, p.Jm, diag([0.01, 0.01]), 'AbsTol', 1e-14);
verifyEqual(testCase, p.Bm, diag([0.02, 0.02]), 'AbsTol', 1e-14);
verifyEqual(testCase, p.Ks, diag([50, 40]), 'AbsTol', 1e-14);
verifySize(testCase, p.Jm, [2, 2]);
verifySize(testCase, p.Bm, [2, 2]);
verifySize(testCase, p.Ks, [2, 2]);
verifyGreaterThan(testCase, [p.m1, p.m2, p.l1, p.l2, diag(p.Jm).', ...
    diag(p.Bm).', diag(p.Ks).', p.g], zeros(1, 11));
end

function testT2InertiaMatrix(testCase)
p = sea_params_nominal;
q2Samples = linspace(-pi, pi, 2001);
minimumEigenvalue = inf;
maximumSymmetryError = 0;

for index = 1:numel(q2Samples)
    M = sea_link_inertia([0; q2Samples(index)], p);
    verifySize(testCase, M, [2, 2]);
    maximumSymmetryError = max(maximumSymmetryError, norm(M - M.', 'fro'));
    minimumEigenvalue = min(minimumEigenvalue, min(eig((M + M.') / 2)));

    m11LowerBound = p.m1 * p.l1^2 + p.m2 * (p.l1 - p.l2)^2;
    determinantFormula = p.m2 * p.l1^2 * p.l2^2 * ...
        (p.m1 + p.m2 * sin(q2Samples(index))^2);
    verifyGreaterThan(testCase, m11LowerBound, 0);
    verifyGreaterThan(testCase, determinantFormula, 0);
    verifyEqual(testCase, det(M), determinantFormula, 'AbsTol', 1e-14);
end

verifyLessThanOrEqual(testCase, maximumSymmetryError, 1e-12);
verifyGreaterThan(testCase, minimumEigenvalue, 1e-12);
end

function testT3CoriolisStructure(testCase)
p = sea_params_nominal;
cases = [ ...
     0.00,  0.00,  0.00,  0.00; ...
     0.20, -0.70,  0.40, -0.30; ...
    -0.60,  1.10, -0.80,  0.25; ...
     1.20, -2.20,  1.50, -1.10; ...
    -1.00,  pi/2,  0.00,  2.00; ...
     0.50, -pi/2, -1.20,  0.00; ...
     pi/3,  pi,    0.75, -0.65];

for index = 1:size(cases, 1)
    q = cases(index, 1:2).';
    qdot = cases(index, 3:4).';
    C = sea_coriolis(q, qdot, p);
    verifySize(testCase, C, [2, 2]);

    scale = -p.m2 * p.l1 * p.l2 * sin(q(2));
    independentlyDerivedMdot = [2 * scale, scale; scale, 0] * qdot(2);
    candidate = independentlyDerivedMdot - 2 * C;
    verifyLessThanOrEqual(testCase, norm(candidate + candidate.', 'fro'), 1e-12);
end
end

function testT4GravityVector(testCase)
p = sea_params_nominal;
Gzero = sea_gravity([0; 0], p);
GhorizontalVertical = sea_gravity([pi/2; 0], p);
Gfolded = sea_gravity([0; pi], p);

verifySize(testCase, Gzero, [2, 1]);
verifyEqual(testCase, Gzero, [ ...
    (p.m1 + p.m2) * p.g * p.l1 + p.m2 * p.g * p.l2; ...
    p.m2 * p.g * p.l2], 'AbsTol', 1e-12);
verifyEqual(testCase, GhorizontalVertical, zeros(2, 1), 'AbsTol', 1e-12);
verifyEqual(testCase, Gfolded, [ ...
    (p.m1 + p.m2) * p.g * p.l1 - p.m2 * p.g * p.l2; ...
    -p.m2 * p.g * p.l2], 'AbsTol', 1e-12);
verifyGreaterThan(testCase, Gzero, zeros(2, 1));
verifyLessThan(testCase, sea_gravity([pi; 0], p), zeros(2, 1));
end

function testT5SeaElasticity(testCase)
p = sea_params_nominal;
q = [0.2; -0.4];

[zeroTorque, zeroDeformation] = sea_elastic_torque(q, q, p);
verifyEqual(testCase, zeroDeformation, zeros(2, 1), 'AbsTol', 1e-14);
verifyEqual(testCase, zeroTorque, zeros(2, 1), 'AbsTol', 1e-14);

[mixedTorque, mixedDeformation] = sea_elastic_torque(q, [0.3; -0.5], p);
verifyEqual(testCase, mixedDeformation, [0.1; -0.1], 'AbsTol', 1e-14);
verifyEqual(testCase, mixedTorque, [5; -4], 'AbsTol', 1e-12);
verifyGreaterThan(testCase, mixedTorque(1), 0);
verifyLessThan(testCase, mixedTorque(2), 0);
end

function testT6CompleteRhs(testCase)
p = sea_params_nominal;
states = [ ...
     0.00,  0.00,  0.00,  0.00,  0.00,  0.00,  0.00,  0.00; ...
     0.30, -0.50,  0.20, -0.40,  0.35, -0.58,  0.10, -0.20; ...
    -0.80,  0.90, -0.60,  0.30, -0.72,  0.84, -0.25,  0.50; ...
     1.10, -1.20,  0.70,  0.80,  1.04, -1.08,  0.40, -0.35];
torques = [0.0, 0.0; 1.2, -0.8; -2.0, 1.5; 0.6, -1.1];

for index = 1:size(states, 1)
    x = states(index, :).';
    xdot = sea_nonlinear_rhs(x, torques(index, :).', p);
    verifySize(testCase, xdot, [8, 1]);
    verifyTrue(testCase, all(isfinite(xdot)));
    verifyEqual(testCase, xdot(1:2), x(3:4), 'AbsTol', 1e-14);
    verifyEqual(testCase, xdot(5:6), x(7:8), 'AbsTol', 1e-14);
end
end

function testT7IndependentTraceFormulas(testCase)
p = sea_params_nominal;
x = [0.37; -0.61; 0.42; -0.28; 0.44; -0.55; 0.18; -0.31];
tau = [1.35; -0.72];
q = x(1:2);
qdot = x(3:4);
theta = x(5:6);
thetadot = x(7:8);

directM = [ ...
    (p.m1 + p.m2) * p.l1^2 + p.m2 * p.l2^2 + ...
        2 * p.m2 * p.l1 * p.l2 * cos(q(2)), ...
    p.m2 * p.l2^2 + p.m2 * p.l1 * p.l2 * cos(q(2)); ...
    p.m2 * p.l2^2 + p.m2 * p.l1 * p.l2 * cos(q(2)), ...
    p.m2 * p.l2^2];
h = p.m2 * p.l1 * p.l2 * sin(q(2));
directC = [ ...
    -h * qdot(2), -h * (qdot(1) + qdot(2)); ...
     h * qdot(1), 0];
directG = [ ...
    (p.m1 + p.m2) * p.g * p.l1 * cos(q(1)) + ...
        p.m2 * p.g * p.l2 * cos(q(1) + q(2)); ...
    p.m2 * p.g * p.l2 * cos(q(1) + q(2))];
directElasticTorque = p.Ks * (theta - q);
directQddot = directM \ (directElasticTorque - directC * qdot - directG);
directThetaDdot = p.Jm \ (tau - p.Bm * thetadot - directElasticTorque);
directXdot = [qdot; directQddot; thetadot; directThetaDdot];

verifyEqual(testCase, sea_link_inertia(q, p), directM, 'AbsTol', 1e-13);
verifyEqual(testCase, sea_coriolis(q, qdot, p), directC, 'AbsTol', 1e-13);
verifyEqual(testCase, sea_gravity(q, p), directG, 'AbsTol', 1e-13);
verifyEqual(testCase, sea_elastic_torque(q, theta, p), ...
    directElasticTorque, 'AbsTol', 1e-13);
verifyEqual(testCase, sea_nonlinear_rhs(x, tau, p), directXdot, 'AbsTol', 1e-12);
end
