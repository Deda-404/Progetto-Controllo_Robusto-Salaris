function metrics = validate_m1_nonlinear_model
%VALIDATE_M1_NONLINEAR_MODEL Deterministic numerical quality gate for M1.

p = sea_params_nominal;

symmetryTolerance = 1e-12;
positivityTolerance = 1e-12;
skewTolerance = 1e-12;
formulaTolerance = 1e-12;

fprintf('\n=== Validazione M1: modello non lineare SEA ===\n');
fprintf(['Parametri: m1=%.3g kg, m2=%.3g kg, l1=%.3g m, l2=%.3g m, ' ...
    'Jm=diag([%.3g %.3g]) kg*m^2, Bm=diag([%.3g %.3g]) N*m*s/rad, ' ...
    'Ks=diag([%.3g %.3g]) N*m/rad, g=%.3g m/s^2\n'], ...
    p.m1, p.m2, p.l1, p.l2, p.Jm(1,1), p.Jm(2,2), ...
    p.Bm(1,1), p.Bm(2,2), p.Ks(1,1), p.Ks(2,2), p.g);

q2Samples = linspace(-pi, pi, 2001);
minimumEigenvalue = inf;
minimumQ2 = NaN;
maximumSymmetryError = 0;
for index = 1:numel(q2Samples)
    q = [0; q2Samples(index)];
    M = sea_link_inertia(q, p);
    eigenvalues = eig((M + M.') / 2);
    [localMinimum, ~] = min(eigenvalues);
    if localMinimum < minimumEigenvalue
        minimumEigenvalue = localMinimum;
        minimumQ2 = q2Samples(index);
    end
    maximumSymmetryError = max(maximumSymmetryError, norm(M - M.', 'fro'));
end

coriolisCases = [ ...
     0.00,  0.00,  0.00,  0.00; ...
     0.20, -0.70,  0.40, -0.30; ...
    -0.60,  1.10, -0.80,  0.25; ...
     1.20, -2.20,  1.50, -1.10; ...
    -1.00,  pi/2,  0.00,  2.00; ...
     0.50, -pi/2, -1.20,  0.00; ...
     pi/3,  pi,    0.75, -0.65];
maximumSkewResidual = 0;
for index = 1:size(coriolisCases, 1)
    q = coriolisCases(index, 1:2).';
    qdot = coriolisCases(index, 3:4).';
    derivativeScale = -p.m2 * p.l1 * p.l2 * sin(q(2));
    dMdq2 = [2 * derivativeScale, derivativeScale; derivativeScale, 0];
    Mdot = dMdq2 * qdot(2);
    skewCandidate = Mdot - 2 * sea_coriolis(q, qdot, p);
    maximumSkewResidual = max(maximumSkewResidual, ...
        norm(skewCandidate + skewCandidate.', 'fro'));
end

gravityCases = [0, 0; pi/2, 0; 0, pi];
maximumGravityError = 0;
for index = 1:size(gravityCases, 1)
    q = gravityCases(index, :).';
    expectedGravity = [ ...
        (p.m1 + p.m2) * p.g * p.l1 * cos(q(1)) + ...
            p.m2 * p.g * p.l2 * cos(q(1) + q(2)); ...
        p.m2 * p.g * p.l2 * cos(q(1) + q(2))];
    maximumGravityError = max(maximumGravityError, ...
        norm(sea_gravity(q, p) - expectedGravity, inf));
end

elasticCases = [ ...
    0.0,  0.0,  0.0,  0.0; ...
    0.2, -0.4,  0.3, -0.5; ...
   -0.3,  0.6, -0.5,  0.9];
maximumElasticError = 0;
for index = 1:size(elasticCases, 1)
    q = elasticCases(index, 1:2).';
    theta = elasticCases(index, 3:4).';
    expectedTorque = p.Ks * (theta - q);
    actualTorque = sea_elastic_torque(q, theta, p);
    maximumElasticError = max(maximumElasticError, ...
        norm(actualTorque - expectedTorque, inf));
end

stateCases = [ ...
     0.00,  0.00,  0.00,  0.00,  0.00,  0.00,  0.00,  0.00; ...
     0.30, -0.50,  0.20, -0.40,  0.35, -0.58,  0.10, -0.20; ...
    -0.80,  0.90, -0.60,  0.30, -0.72,  0.84, -0.25,  0.50; ...
     1.10, -1.20,  0.70,  0.80,  1.04, -1.08,  0.40, -0.35];
torqueCases = [0.0, 0.0; 1.2, -0.8; -2.0, 1.5; 0.6, -1.1];
maximumKinematicError = 0;
allFinite = true;
for index = 1:size(stateCases, 1)
    x = stateCases(index, :).';
    tau = torqueCases(index, :).';
    xdot = sea_nonlinear_rhs(x, tau, p);
    allFinite = allFinite && all(isfinite(xdot));
    maximumKinematicError = max(maximumKinematicError, ...
        norm([xdot(1:2) - x(3:4); xdot(5:6) - x(7:8)], inf));
end

metrics.minimumInertiaEigenvalue = minimumEigenvalue;
metrics.minimumInertiaQ2 = minimumQ2;
metrics.maximumInertiaSymmetryError = maximumSymmetryError;
metrics.maximumCoriolisSkewResidual = maximumSkewResidual;
metrics.maximumGravityFormulaError = maximumGravityError;
metrics.maximumElasticFormulaError = maximumElasticError;
metrics.maximumKinematicError = maximumKinematicError;
metrics.allRhsFinite = allFinite;
metrics.inertiaConfigurations = numel(q2Samples);
metrics.coriolisConfigurations = size(coriolisCases, 1);
metrics.gravityConfigurations = size(gravityCases, 1);
metrics.elasticConfigurations = size(elasticCases, 1);
metrics.rhsConfigurations = size(stateCases, 1);
metrics.totalConfigurations = metrics.inertiaConfigurations + ...
    metrics.coriolisConfigurations + metrics.gravityConfigurations + ...
    metrics.elasticConfigurations + metrics.rhsConfigurations;
metrics.symmetryTolerance = symmetryTolerance;
metrics.positivityTolerance = positivityTolerance;
metrics.skewTolerance = skewTolerance;
metrics.formulaTolerance = formulaTolerance;

fprintf('Inerzia: min eig = %.16g a q2 = %.16g rad; max simmetria = %.3e\n', ...
    minimumEigenvalue, minimumQ2, maximumSymmetryError);
fprintf('Coriolis: max residuo antisimmetria = %.3e\n', maximumSkewResidual);
fprintf('Gravita: max errore formula = %.3e\n', maximumGravityError);
fprintf('Elasticita: max errore formula = %.3e\n', maximumElasticError);
fprintf('RHS: finito = %d; max errore cinematico = %.3e\n', ...
    allFinite, maximumKinematicError);
fprintf('Configurazioni deterministiche valutate = %d\n', metrics.totalConfigurations);

assert(minimumEigenvalue > positivityTolerance, ...
    'M1:InertiaNotPositive', 'La matrice di inerzia non supera la tolleranza.');
assert(maximumSymmetryError <= symmetryTolerance, ...
    'M1:InertiaNotSymmetric', 'Errore di simmetria oltre tolleranza.');
assert(maximumSkewResidual <= skewTolerance, ...
    'M1:CoriolisStructure', 'Residuo antisimmetria oltre tolleranza.');
assert(maximumGravityError <= formulaTolerance, ...
    'M1:GravityFormula', 'Errore della gravita oltre tolleranza.');
assert(maximumElasticError <= formulaTolerance, ...
    'M1:ElasticFormula', 'Errore della coppia elastica oltre tolleranza.');
assert(maximumKinematicError <= formulaTolerance && allFinite, ...
    'M1:Rhs', 'RHS non finito o cinematicamente incoerente.');

fprintf('[PASS] Quality gate numerico M1 superato.\n');
end
