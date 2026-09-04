%% PROGETTO LQG: DAL FEEDBACK DI STATO ALLA RAS EMPIRICA (M6-M8)
% Entry point didattico dedicato esclusivamente al percorso LQR/Kalman/LQG.
% I calcoli restano nelle funzioni validate; questo script espone in ordine
% le ipotesi, le matrici, i risultati e la verifica non lineare.

%% 0. Introduzione e setup
clearvars;
clc;
close all;
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(projectRoot, 'src')));
addpath(genpath(fullfile(projectRoot, 'controllers')));
addpath(genpath(fullfile(projectRoot, 'analysis')));
addpath(genpath(fullfile(projectRoot, 'simulink')));
dataDirectory = fullfile(projectRoot, 'results', 'data');
fprintf('\n=== Percorso didattico LQG M6-M8 ===\n');

%% 1. Modello nominale e specifiche
m3Path = fullfile(dataDirectory, 'm3_nominal_actuated_plant.mat');
m5Path = fullfile(dataDirectory, 'm5_performance_specs.mat');
if ~isfile(m3Path), validate_m3_nominal_actuated_plant; end
if ~isfile(m5Path), validate_m5_performance_specs; end
m3 = load(m3Path);
m5 = load(m5Path);
fprintf('Pianta M3: %d stati, %d ingressi, %d misure.\n', ...
    size(m3.Afull, 1), size(m3.Bfull, 2), size(m3.CfullMeas, 1));
specificationTable = table( ...
    ["settling"; "overshoot"; "steady error"; "cross coupling"; ...
    "control scale"], ...
    [m5.spec.settlingTimeTarget; m5.spec.overshootTarget; ...
    100 * m5.spec.steadyStateTrackingTarget; ...
    100 * m5.spec.crossCouplingTarget; m5.spec.uScale], ...
    ["s"; "%"; "%"; "%"; "N m"], ...
    'VariableNames', {'Requirement', 'Value', 'Unit'});
disp(specificationTable);

%% 2. Impostazione del problema LQR
% La scala di posizione deriva dal gradino di progetto; le scale di
% velocita dalla banda; la deformazione dalla coppia lato link divisa per
% la rigidezza SEA. Queste scale rendono confrontabili le unita ma non
% selezionano il controllore. La selezione avviene sui risultati simulati.
config = lqg_specs_m6;
disp(config.lqr.rationale);
fprintf('Valori candidati per posizione:'); disp(config.lqr.candidates.position.');
fprintf('Valori candidati per velocita:'); disp(config.lqr.candidates.velocity.');
fprintf('Valori candidati per deformazione:'); disp(config.lqr.candidates.deformation.');
fprintf('Valori candidati per comando:'); disp(config.lqr.candidates.control.');

%% 3. Ricerca parametrica, ammissibilita e compromesso
% Fase A: stabilita e target obbligatori M5. Fase B: media pesata di indici
% normalizzati per rapidita, smorzamento, accuratezza, accoppiamento e
% comando. Il cross coupling resta diagnostico, come dichiarato in M5.
m6Metrics = validate_m6_lqg_no_integrator;
lqr = m6Metrics.lqrDesign;
fprintf('%d configurazioni testate, %d ammissibili.\n', ...
    lqr.numberCandidates, lqr.numberAdmissible);
disp(lqr.candidateTable);
fprintf('Candidato selezionato: %s; score normalizzato %.6g.\n', ...
    lqr.candidateTable.Candidate(lqr.selectedIndex), lqr.selectedScore);
disp(lqr.scoreDefinition);

%% 4. Matrici Q, R, guadagno K e poli del regolatore
fprintf('Fattori adimensionali selezionati:\n'); disp(lqr.priorities);
fprintf('Q =\n'); disp(lqr.Q);
fprintf('R =\n'); disp(lqr.R);
fprintf('K =\n'); disp(lqr.K);
fprintf('Nr =\n'); disp(lqr.Nr);
fprintf('Poli di A-BK =\n'); disp(lqr.regulatorPoles);
fprintf(['Metriche full-state: Ts=%.4g s, Mp=%.4g %%, peakU=%.4g N m, ' ...
    'rmsU=%.4g N m, energiaU=%.4g N^2 m^2 s.\n'], ...
    lqr.evaluation.summary.worstSettlingTime, ...
    lqr.evaluation.summary.worstOvershoot, ...
    lqr.evaluation.summary.worstPeakControl, ...
    lqr.evaluation.summary.worstRmsControl, ...
    lqr.evaluation.summary.worstControlEnergy);

%% 5. Modello di rumore e covarianze Kalman
% w raccoglie coppie di disturbo lato link e incertezze equivalenti di
% ingresso. v rappresenta il rumore dei quattro encoder di posizione.
% Le sigma sono ipotesi progettuali; Qn e Rn contengono le varianze sigma^2.
kalman = m6Metrics.kalmanDesign;
fprintf('sigma_d=%.4g N m, sigma_u=%.4g N m, sigma_y=%.4g deg = %.4g rad.\n', ...
    kalman.sigmaD, kalman.sigmaU, kalman.sigmaYDeg, kalman.sigmaYRad);
fprintf('Qn =\n'); disp(kalman.Qn);
fprintf('Rn =\n'); disp(kalman.Rn);
fprintf('L =\n'); disp(kalman.L);
fprintf('Poli di A-LC =\n'); disp(kalman.estimatorPoles);

%% 6. Sensibilita delle ipotesi di covarianza
% Dimezzare sigma_y divide Rn per quattro: le misure vengono considerate
% piu affidabili. Raddoppiarla moltiplica Rn per quattro e filtra di piu.
% Nel caso MIMO la conseguenza dipende anche dalle direzioni di G e C.
disp(m6Metrics.kalmanSensitivity.table);

%% 7. Costruzione LQG e principio di separazione
realization = m6Metrics.realization;
fprintf('Ordine controllore LQG: %d; integratori: %d.\n', ...
    realization.controllerOrder, realization.integratorStateCount);
fprintf('Errore numerico del principio di separazione: %.3e.\n', ...
    realization.separationError);
fprintf(['Legge di controllo: u=-K*xhat+Nr*r. Lo stimatore usa u e ' ...
    'l''innovazione y-C*xhat.\n']);

%% 8. Tracking, stima e azione di controllo M6
disp(m6Metrics.trackingMetrics.lqg);
disp(m6Metrics.disturbanceMetrics.lqg);
disp(m6Metrics.noiseMetrics);

%% 9. Analisi M7: perche l'integratore non viene adottato
m7Metrics = validate_m7_lqg_integral;
disp(m7Metrics.manualComparisonTable(:, {'Tuning', 'Wi', 'RhoU', ...
    'WorstSettlingTime', 'WorstOvershoot', 'DisturbanceOffset', ...
    'FundamentalPass'}));
fprintf('M7=%s: nessun LQI viene promosso a controllore finale.\n', ...
    m7Metrics.validationMetrics.status);

%% 10. Validazione non lineare M8
% Se l'artifact validato esiste viene riutilizzato; la campagna completa si
% rigenera con validate_m8_simulink_ras(true), come nella validazione finale.
m8Metrics = validate_m8_simulink_ras(false);
disp(m8Metrics.ltiVsNonlinearMetrics);
fprintf('Equilibrio Simulink: %s. RAS deterministica: %s.\n', ...
    localPassFail(m8Metrics.qualityGate.equilibriumPassed), ...
    localPassFail(m8Metrics.qualityGate.rasDeterministic));

%% 11. RAS empirica del controllore LQG
% Piano: delta q1(0), delta q2(0). Le velocita partono da zero, theta e
% spostato insieme a q, gli attuatori sono all'equilibrio e xhat(0)=0.
% Il risultato e una classificazione numerica su punti finiti, non una
% regione certificata con una funzione di Lyapunov.
m8 = load(fullfile(dataDirectory, 'm8_lqg_nonlinear_ras.mat'));
fprintf(['RAS LQG: %d punti unici, %d convergenti, %d non convergenti, ' ...
    'frazione %.4f.\n'], m8.rasMetrics.numberUniquePoints, ...
    m8.rasMetrics.numberConvergent, m8.rasMetrics.numberDivergent, ...
    m8.rasMetrics.empiricalConvergenceFraction);
fprintf(['Box +/-%.4g deg; orizzonte %.4g/%.4g s; rmin=%.4g deg; ' ...
    'area poligonale=%.4g deg^2; %s.\n'], ...
    m8.simulationConfig.ras.searchBoxDeg, ...
    m8.simulationConfig.ras.horizon, ...
    m8.simulationConfig.ras.extendedHorizon, ...
    m8.rasMetrics.minimumRadiusDeg, ...
    m8.rasMetrics.approximateAreaDeg2, m8.rasMetrics.classification);

%% 12. Confronto RAS comune e riepilogo finale LQG
rasComparison = build_common_ras_comparison(string(projectRoot), true);
disp(rasComparison.table);
fprintf(['Conclusione LQG: M6 soddisfa i target nominali; M7 resta ' ...
    'PARTIAL; M8 quantifica il comportamento non lineare e la RAS ' ...
    'empirica senza fornire una certificazione robusta.\n']);

function status = localPassFail(condition)
if condition
    status = 'PASS';
else
    status = 'FAIL';
end
end
