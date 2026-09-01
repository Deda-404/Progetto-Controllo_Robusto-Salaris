%% MODELLAZIONE, LINEARIZZAZIONE E DEFINIZIONE DEL PROBLEMA DI CONTROLLO
% Percorso didattico unitario per le precedenti fasi M0-M5. Le funzioni
% matematiche restano separate; questo script rende visibile la sequenza
% scelta ingegneristica -> motivazione -> verifica MATLAB.

clear;
clc;
close all;

projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(projectRoot, 'src')));
addpath(genpath(fullfile(projectRoot, 'analysis')));

%% 1. Parametri nominali
p = sea_params_nominal;
disp(p);

%% 2. Modello dinamico non lineare SEA
% Stato: x=[q; qdot; theta; thetadot]. La coppia elastica Ks(theta-q)
% collega il lato motore al lato link.
qExample = [pi / 2; 0];
xExample = [qExample; zeros(2, 1); qExample; zeros(2, 1)];
tauExample = zeros(2, 1);
xdotExample = sea_nonlinear_rhs(xExample, tauExample, p);

%% 3. Equilibrio statico scelto
qbar = [pi / 2; 0];
[xbar, taubar, equilibriumInfo] = sea_static_equilibrium(qbar, p);
fprintf('Residuo di equilibrio: %.3e\n', equilibriumInfo.residualNorm);

%% 4. Linearizzazione analitica
[A, B, equilibrium, linearizationInfo] = ...
    sea_linearize_static_equilibrium_analytic(qbar, p);
[Cq, Dq, Cmeas, Dmeas] = sea_output_matrices;

%% 5. Poli e modi principali
mechanicalPoles = eig(A);
unstablePoles = mechanicalPoles(real(mechanicalPoles) > 0);
elasticModes = mechanicalPoles(imag(mechanicalPoles) > 0);
fprintf('Massimo polo instabile: %.4g rad/s\n', max(real(unstablePoles)));
fprintf('Primo modo elastico: %.4g rad/s\n', min(abs(elasticModes)));

%% 6. Attuatore nominale e confronto manuale
% wn controlla la rapidita, zeta lo smorzamento e il ritardo sottrae fase.
% Il Padé di ordine 1 mantiene un modello razionale di ordine contenuto.
actuator = actuator_params_nominal;
[Gactuator, actuatorInfo] = build_nominal_actuator(actuator);
disp(actuatorInfo.actuatorStep);
fprintf('Banda attuatore nominale: %.4g rad/s\n', ...
    actuatorInfo.actuatorBandwidth);
step(Gactuator); grid on; title('Attuatore nominale');

%% 7. Unico insieme di incertezze di progetto
% k1, k2 e Jm1 sono ureal. La dispersione attuatore viene rappresentata
% mediante una copertura moltiplicativa WI*Delta per ciascun canale.
uncertainty = uncertainty_params_m4;
disp(uncertainty.selectedMechanicalRanges);
[GmechUncMeas, GmechUncQ] = build_uncertain_mechanical_plant( ...
    uncertainty.selectedMechanicalRanges, qbar);
actuatorFamily = build_actuator_family(uncertainty);
actuatorCover = fit_actuator_uncertainty_weight( ...
    actuatorFamily, uncertainty);
[GuncMeas, GuncQ] = build_m4_uncertain_plant( ...
    GmechUncMeas, GmechUncQ, actuatorCover.WI);

%% 8. Specifiche di prestazione
spec = performance_specs_m5;
fprintf(['omegaB=%g rad/s, As=%g, Ms=%g, uScale=%g N m, ' ...
    'omegaU=%g rad/s, alpha=%g\n'], spec.omegaB, spec.As, spec.Ms, ...
    spec.uScale, spec.omegaU, spec.controlWeightAlpha);

%% 9. Pesi mixed-sensitivity
% W1(0)=1/As e W1(inf)=1/Ms. W2 passa da 1/uScale ad
% alpha/uScale, aumentando la penalizzazione del comando in alta frequenza.
[W1siso, W1, W2siso, W2, weightInfo] = build_m5_weights(spec);
fprintf('W1(0)=%.4g, W1(inf)=%.4g\n', ...
    weightInfo.W1.dcMeasured, weightInfo.W1.hfMeasured);
fprintf('W2(0)=%.4g, W2(inf)=%.4g\n', ...
    weightInfo.W2.dcMeasured, weightInfo.W2.hfMeasured);

figure;
bode(W1siso, W2siso); grid on;
legend('W_1', 'W_2');
title('Pesi del problema di controllo');
