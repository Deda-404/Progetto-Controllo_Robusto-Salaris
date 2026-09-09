function metrics = validate_m2_equilibrium_linearization
%VALIDATE_M2_EQUILIBRIUM_LINEARIZATION Rebuild and validate M2 artifacts.

projectRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
dataDirectory = fullfile(projectRoot, 'results', 'data');
figureDirectory = fullfile(projectRoot, 'results', 'figures');
if ~isfolder(dataDirectory)
    mkdir(dataDirectory);
end
if ~isfolder(figureDirectory)
    mkdir(figureDirectory);
end

equilibriumTolerance = 1e-10;
finiteDifferenceStep = 3e-6;
jacobianAbsoluteTolerance = 1e-6;
jacobianRelativeTolerance = 1e-9;
stabilityTolerance = 1e-8;

p = sea_params_nominal;
qbar = [pi/2; 0];
[xbar, taubar, equilibriumInfo] = sea_static_equilibrium(qbar, p);
thetabar = equilibriumInfo.thetabar;

fprintf('\n=== Validazione M2: equilibrio e linearizzazione ===\n');
fprintf('qbar       = [% .16g; % .16g] rad\n', qbar);
fprintf('thetabar   = [% .16g; % .16g] rad\n', thetabar);
fprintf('taubar     = [% .16g; % .16g] N*m\n', taubar);
fprintf('||fbar||_2 = %.3e\n', equilibriumInfo.residualNorm);

[A, B] = sea_linearize_symbolic(xbar, taubar, p);
rhsFunction = @(x, tau) sea_nonlinear_rhs(x, tau, p);
[Anumeric, Bnumeric, finiteDifferenceInfo] = finite_difference_jacobian( ...
    rhsFunction, xbar, taubar, finiteDifferenceStep);

deltaA = A - Anumeric;
deltaB = B - Bnumeric;
jacobian.maxAbsoluteErrorA = max(abs(deltaA), [], 'all');
jacobian.maxAbsoluteErrorB = max(abs(deltaB), [], 'all');
jacobian.frobeniusErrorA = norm(deltaA, 'fro');
jacobian.frobeniusErrorB = norm(deltaB, 'fro');
jacobian.relativeErrorA = jacobian.frobeniusErrorA / max(norm(A, 'fro'), eps);
jacobian.relativeErrorB = jacobian.frobeniusErrorB / max(norm(B, 'fro'), eps);
jacobian.finiteDifferenceStep = finiteDifferenceInfo.step;

fprintf('Jacobiano A: max abs %.3e, Fro %.3e, relativo %.3e\n', ...
    jacobian.maxAbsoluteErrorA, jacobian.frobeniusErrorA, ...
    jacobian.relativeErrorA);
fprintf('Jacobiano B: max abs %.3e, Fro %.3e, relativo %.3e\n', ...
    jacobian.maxAbsoluteErrorB, jacobian.frobeniusErrorB, ...
    jacobian.relativeErrorB);

[Cq, Dq, Cmeas, Dmeas] = sea_output_matrices;
stateNames = {'q1', 'q2', 'q1dot', 'q2dot', ...
    'theta1', 'theta2', 'theta1dot', 'theta2dot'};
inputNames = {'tau1', 'tau2'};

Gmech_state = ss(A, B, Cmeas, Dmeas, ...
    'StateName', stateNames, 'InputName', inputNames, ...
    'OutputName', {'q1', 'q2', 'theta1', 'theta2'});
Gmech_q = ss(A, B, Cq, Dq, ...
    'StateName', stateNames, 'InputName', inputNames, ...
    'OutputName', {'q1', 'q2'});

structureMeas = analyze_m2_structure(A, B, Cmeas, stabilityTolerance);
structureQ = analyze_m2_structure(A, B, Cq, stabilityTolerance);
poles = structureMeas.poles;

fprintf('Poli open-loop:\n');
for index = 1:numel(poles)
    fprintf('  %2d: % .12g %+.12gi\n', index, real(poles(index)), imag(poles(index)));
end
fprintf('Classificazione: stabili=%d, instabili=%d, marginali=%d, max Re=%.12g\n', ...
    structureMeas.numberStable, structureMeas.numberUnstable, ...
    structureMeas.numberMarginal, structureMeas.maximumRealPart);
fprintf('Controllabilita: rank=%d/8, tol=%.3e, sigma_min=%.3e, cond=%.3e, PBH stabilizzabile=%d\n', ...
    structureMeas.controllability.rank, ...
    structureMeas.controllability.tolerance, ...
    structureMeas.controllability.singularValues(end), ...
    structureMeas.controllability.conditionNumber, ...
    structureMeas.controllability.stabilizable);
fprintf('Osservabilita [q;theta]: rank=%d/8, tol=%.3e, sigma_min=%.3e, cond=%.3e, PBH rilevabile=%d\n', ...
    structureMeas.observability.rank, ...
    structureMeas.observability.tolerance, ...
    structureMeas.observability.singularValues(end), ...
    structureMeas.observability.conditionNumber, ...
    structureMeas.observability.detectable);
fprintf('Osservabilita q: rank=%d/8, tol=%.3e, sigma_min=%.3e, cond=%.3e, PBH rilevabile=%d\n', ...
    structureQ.observability.rank, structureQ.observability.tolerance, ...
    structureQ.observability.singularValues(end), ...
    structureQ.observability.conditionNumber, ...
    structureQ.observability.detectable);

amplitudes = [1e-2, 1e-3, 1e-4, 1e-5];
stateDirection = [0.35; -0.25; 0.20; -0.15; -0.30; 0.40; 0.10; -0.20];
inputDirection = [0.50; -0.35];
absoluteErrors = zeros(size(amplitudes));
relativeErrors = zeros(size(amplitudes));
for index = 1:numel(amplitudes)
    deltaX = amplitudes(index) * stateDirection;
    deltaTau = amplitudes(index) * inputDirection;
    nonlinearDerivative = sea_nonlinear_rhs( ...
        xbar + deltaX, taubar + deltaTau, p);
    linearDerivative = A * deltaX + B * deltaTau;
    absoluteErrors(index) = norm(nonlinearDerivative - linearDerivative, 2);
    relativeErrors(index) = absoluteErrors(index) / ...
        max(norm(nonlinearDerivative, 2), eps);
end
observedOrders = log(absoluteErrors(1:end-1) ./ absoluteErrors(2:end)) ./ ...
    log(amplitudes(1:end-1) ./ amplitudes(2:end));

fprintf('Validazione locale LTI/NL:\n');
for index = 1:numel(amplitudes)
    fprintf('  amp=%.1e: errore abs=%.3e, relativo=%.3e\n', ...
        amplitudes(index), absoluteErrors(index), relativeErrors(index));
end
fprintf('  ordini osservati:');
fprintf(' %.3f', observedOrders);
fprintf('\n');

controllabilityMetrics = structureMeas.controllability;
observabilityMetrics = structureMeas.observability;
observabilityQMetrics = structureQ.observability;
poleMetrics = rmfield(structureMeas, {'controllability', 'observability'});
localValidation.amplitudes = amplitudes;
localValidation.absoluteErrors = absoluteErrors;
localValidation.relativeErrors = relativeErrors;
localValidation.observedOrders = observedOrders;

datasetPath = fullfile(dataDirectory, 'm2_linearization_nominal.mat');
save(datasetPath, 'p', 'qbar', 'thetabar', 'xbar', 'taubar', ...
    'A', 'B', 'Cq', 'Dq', 'Cmeas', 'Dmeas', 'poles', ...
    'Gmech_state', 'Gmech_q', 'equilibriumInfo', 'jacobian', ...
    'poleMetrics', 'controllabilityMetrics', 'observabilityMetrics', ...
    'observabilityQMetrics', 'localValidation', '-v7');

figurePath = fullfile(figureDirectory, 'm2_open_loop_poles.png');
poleFigure = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1100, 700]);
poleAxes = axes(poleFigure, 'Color', 'white', ...
    'XColor', [0.15, 0.15, 0.15], 'YColor', [0.15, 0.15, 0.15], ...
    'GridColor', [0.72, 0.72, 0.72]);
hold(poleAxes, 'on');
stablePoleMask = real(poles) < -stabilityTolerance;
unstablePoleMask = real(poles) > stabilityTolerance;
marginalPoleMask = ~(stablePoleMask | unstablePoleMask);
plot(poleAxes, real(poles(stablePoleMask)), imag(poles(stablePoleMask)), ...
    'x', 'LineWidth', 2, 'MarkerSize', 10, 'Color', [0.00, 0.35, 0.70], ...
    'DisplayName', 'Stabili');
plot(poleAxes, real(poles(unstablePoleMask)), imag(poles(unstablePoleMask)), ...
    'x', 'LineWidth', 2, 'MarkerSize', 10, 'Color', [0.80, 0.15, 0.15], ...
    'DisplayName', 'Instabili');
if any(marginalPoleMask)
    plot(poleAxes, real(poles(marginalPoleMask)), imag(poles(marginalPoleMask)), ...
        'o', 'LineWidth', 1.8, 'MarkerSize', 8, ...
        'Color', [0.55, 0.35, 0.05], 'DisplayName', 'Marginali');
end
xline(poleAxes, 0, '--', 'Re(s)=0', 'Color', [0.65, 0.10, 0.10], ...
    'LabelVerticalAlignment', 'bottom', 'HandleVisibility', 'off');
yline(poleAxes, 0, ':', 'Im(s)=0', 'Color', [0.30, 0.30, 0.30], ...
    'LabelHorizontalAlignment', 'left', 'HandleVisibility', 'off');
grid(poleAxes, 'on');
xlabel(poleAxes, 'Parte reale [s^{-1}]', 'Color', [0.10, 0.10, 0.10]);
ylabel(poleAxes, 'Parte immaginaria [rad/s]', 'Color', [0.10, 0.10, 0.10]);
title(poleAxes, 'M2 — Poli open-loop del modello meccanico SEA a 8 stati', ...
    'Color', [0.10, 0.10, 0.10]);
legend(poleAxes, 'Location', 'best', 'TextColor', [0.10, 0.10, 0.10], ...
    'Color', 'white');
set_scientific_figure_style(poleFigure);
exportgraphics(poleFigure, figurePath, 'Resolution', 180);
close(poleFigure);

assert(equilibriumInfo.residualNorm <= equilibriumTolerance, ...
    'M2:EquilibriumResidual', 'Residuo di equilibrio oltre tolleranza.');
assert(norm(equilibriumInfo.Gbar, inf) <= equilibriumTolerance, ...
    'M2:CandidateGravity', 'La gravita del candidato non e prossima a zero.');
assert(isequal(size(A), [8, 8]) && isequal(size(B), [8, 2]) && ...
    all(isfinite(A), 'all') && all(isfinite(B), 'all'), ...
    'M2:Jacobians', 'Jacobiani non validi.');
assert(max(jacobian.maxAbsoluteErrorA, jacobian.maxAbsoluteErrorB) <= ...
    jacobianAbsoluteTolerance, 'M2:JacobianAbsoluteError', ...
    'Errore assoluto Jacobiano oltre tolleranza.');
assert(max(jacobian.relativeErrorA, jacobian.relativeErrorB) <= ...
    jacobianRelativeTolerance, 'M2:JacobianRelativeError', ...
    'Errore relativo Jacobiano oltre tolleranza.');
assert(structureMeas.numberUnstable > 0, 'M2:ExpectedInstability', ...
    'Nessun polo instabile: verificare segni e convenzioni.');
assert(structureMeas.controllability.stabilizable, ...
    'M2:NotStabilizable', 'Il modello non supera il PBH di stabilizzabilita.');
assert(structureMeas.observability.detectable, ...
    'M2:NotDetectable', 'Cmeas non supera il PBH di rilevabilita.');
assert(all(diff(absoluteErrors) < 0) && all(observedOrders > 1.5), ...
    'M2:LocalValidation', ...
    'L''errore locale non mostra la riduzione di ordine attesa.');
assert(isfile(datasetPath) && isfile(figurePath), ...
    'M2:Artifacts', 'Dataset o figura M2 non generati.');

metrics.equilibrium = equilibriumInfo;
metrics.jacobian = jacobian;
metrics.structureMeas = structureMeas;
metrics.structureQ = structureQ;
metrics.localValidation = localValidation;
metrics.datasetPath = datasetPath;
metrics.figurePath = figurePath;
metrics.A = A;
metrics.B = B;
metrics.xbar = xbar;
metrics.taubar = taubar;
metrics.Cq = Cq;
metrics.Cmeas = Cmeas;

fprintf('Dataset: %s\n', datasetPath);
fprintf('Figura:  %s\n', figurePath);
fprintf('[PASS] Quality gate numerico M2 superato.\n');
end
