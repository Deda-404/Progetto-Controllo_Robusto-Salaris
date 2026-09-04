%% PROGETTO H-INFINITY: SINTESI, ANALISI ROBUSTA E RAS (M9-M12)
% Entry point didattico dedicato al percorso H-infinity. Il progetto LQG
% non viene ripetuto; compare soltanto nei confronti gia previsti dalle
% singole fasi. Khinf e i pesi M5 restano quelli congelati del progetto.

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
fprintf('\n=== Percorso didattico H-infinity M9-M12 ===\n');

%% 1. Modello nominale, specifiche e motivazione
m3 = load(fullfile(dataDirectory, 'm3_nominal_actuated_plant.mat'));
m5 = load(fullfile(dataDirectory, 'm5_performance_specs.mat'));
fprintf('Pianta nominale: %d stati, %d ingressi e %d uscite q.\n', ...
    order(m3.GfullQ), size(m3.GfullQ, 2), size(m3.GfullQ, 1));
fprintf(['H-infinity tratta in frequenza il compromesso fra errore e ' ...
    'comando, mantenendo visibili le prestazioni non soddisfatte.\n']);

%% 2. Sensibilita, sensibilita complementare e comando
% S=(I+GK)^-1 trasferisce il riferimento nell'errore; T=I-S trasferisce
% il riferimento nell'uscita; KS e la mappa verso il comando. Rendere S
% piccolo ovunque non e possibile: alle alte frequenze crescerebbero
% comando, rumore e sensibilita alle dinamiche non modellate.
fprintf('S=(I+GK)^-1, T=GK(I+GK)^-1=I-S, KS=K(I+GK)^-1.\n');

%% 3. Pesi W1 e W2 congelati in M5
[W1siso, W1, W2siso, W2, weightInfo] = build_m5_weights(m5.spec);
weightTable = table(["W1"; "W2"], ...
    [weightInfo.W1.dcMeasured; weightInfo.W2.dcMeasured], ...
    [weightInfo.W1.hfMeasured; weightInfo.W2.hfMeasured], ...
    [m5.spec.omegaB; m5.spec.omegaU], ...
    'VariableNames', {'Weight', 'DcGain', 'HighFrequencyGain', ...
    'TransitionRadS'});
disp(weightTable);
fprintf(['W1: As=%.4g, Ms=%.4g, omegaB=%.4g rad/s. ' ...
    'W2: uScale=%.4g N m, alpha=%.4g, omegaU=%.4g rad/s.\n'], ...
    m5.spec.As, m5.spec.Ms, m5.spec.omegaB, m5.spec.uScale, ...
    m5.spec.controlWeightAlpha, m5.spec.omegaU);

figure('Name', 'Hinf - pesi e limiti', 'Color', 'white');
layoutWeights = tiledlayout(1, 2, 'TileSpacing', 'compact');
nexttile; bodemag(W1siso, 1 / W1siso, {1e-2, 1e3}); grid on;
legend('|W_1|', '1/|W_1|'); title('Limite sulla sensibilita');
xlabel('Frequenza [rad/s]');
nexttile; bodemag(W2siso, 1 / W2siso, {1e-2, 1e3}); grid on;
legend('|W_2|', '1/|W_2|'); title('Limite sul comando');
xlabel('Frequenza [rad/s]');
title(layoutWeights, 'Pesi mixed-sensitivity M5');

%% 4. M9: mixed sensitivity con mixsyn
m9Metrics = validate_m9_hinf_mixsyn;
fprintf('M9: ordine Kmix=%d, gamma=%.8g, stato=%s.\n', ...
    m9Metrics.synthesis.controllerOrder, m9Metrics.synthesis.gamma, ...
    m9Metrics.qualityGate.overallStatus);
fprintf('||W1*S||inf=%.6g, ||W2*KS||inf=%.6g.\n', ...
    m9Metrics.reconstruction.metrics.W1SNorm, ...
    m9Metrics.reconstruction.metrics.W2KSNorm);

%% 5. M10: generalized plant esplicita e hinfsyn
% Con e=r-q, gli ingressi di P sono [r;u], le uscite regolate [W1*e;W2*u]
% e le misure fornite al controllore coincidono con e. Il blocco -G in
% P22 incorpora il segno della retroazione prima della lower LFT.
m10Metrics = validate_m10_hinfsyn;
P = m10Metrics.generalized.P;
fprintf('P: ordine %d, %d ingressi, %d uscite; nmeas=%d, ncont=%d.\n', ...
    order(P), size(P, 2), size(P, 1), ...
    m10Metrics.generalized.partition.nmeas, ...
    m10Metrics.generalized.partition.ncont);
fprintf('Khinf: ordine %d, gamma=%.8g, stato=%s.\n', ...
    m10Metrics.synthesis.controllerOrder, m10Metrics.synthesis.gammaHinf, ...
    m10Metrics.qualityGate.overallStatus);
fprintf('Poli Khinf:\n'); disp(pole(m10Metrics.synthesis.Khinf));

figure('Name', 'Hinf - funzioni pesate', 'Color', 'white');
layoutHinf = tiledlayout(1, 2, 'TileSpacing', 'compact');
nexttile; sigma(m10Metrics.reconstruction.S, inv(m5.W1), ...
    {1e-2, 1e3}); grid on;
legend('S', 'W_1^{-1}'); title('Sensibilita e limite');
nexttile; sigma(m10Metrics.reconstruction.KS, inv(m5.W2), ...
    {1e-2, 1e3}); grid on;
legend('KS', 'W_2^{-1}'); title('Comando e limite');
title(layoutHinf, 'Verifica frequenziale Khinf M10');

%% 6. M11: controllori strutturati e compromesso ordine/prestazione
m11Path = fullfile(dataDirectory, 'm11_hinfstruct_structured.mat');
if ~isfile(m11Path), validate_m11_hinfstruct; end
m11 = load(m11Path);
disp(m11.variabilityTable);
disp(m11.representativeTable);
fprintf(['M11 resta uno studio strutturato: A5 e il candidato di ordine ' ...
    'ridotto per M12, non sostituisce Khinf M10.\n']);

%% 7. M12: analisi mu del controllore strutturato A5
% M12 verifica NS/NP/RS/RP sull'insieme incerto M4. Non viene eseguita
% alcuna nuova D-K iteration e nessun FAIL viene trasformato in PASS.
m12Metrics = validate_m12_mu_analysis;
disp(m12Metrics.summary);
fprintf('M12: NS=%s, NP=%s, RS=%s, RP=%s; stato=%s.\n', ...
    m12Metrics.qualityGate.nominalStability, ...
    m12Metrics.qualityGate.nominalPerformance, ...
    m12Metrics.qualityGate.robustStability, ...
    m12Metrics.qualityGate.robustPerformance, ...
    m12Metrics.qualityGate.overallStatus);

%% 8. Validazione non lineare del controllore H-infinity Khinf
m15Path = fullfile(dataDirectory, 'm15_nonlinear_robust_validation.mat');
if isfile(m15Path)
    m15Metrics = validate_m15_nonlinear_robust(false);
else
    m15Metrics = validate_m15_nonlinear_robust(true);
end
khinfTracking = m15Metrics.controllerComparison(1, :);
disp(khinfTracking);
fprintf(['Il tracking non lineare resta un risultato distinto dalla ' ...
    'stabilita robusta del modello lineare incerto.\n']);

%% 9. RAS empirica del controllore H-infinity
% Il piano, il box, il solver e le soglie coincidono con M8 e con Kmu.
% Lo stato interno di Khinf parte da zero, come lo stato incrementale
% dell'osservatore LQG. La mappa e numerica, non certificata.
rasComparison = build_common_ras_comparison(string(projectRoot), true);
disp(rasComparison.table);
khinfRas = rasComparison.table(rasComparison.table.Controller == ...
    "Khinf M10", :);
fprintf(['RAS Khinf: %d/%d punti convergenti (%.4f), rmin %.4g deg, ' ...
    'area %.4g deg^2, %s.\n'], khinfRas.NumberConvergent, ...
    khinfRas.NumberUniquePoints, khinfRas.EmpiricalFraction, ...
    khinfRas.MinimumRadiusDeg, khinfRas.ApproximateAreaDeg2, ...
    khinfRas.Classification);

%% 10. Riepilogo H-infinity
fprintf(['Conclusione: M9 e M10 sono internamente stabili ma non ' ...
    'soddisfano il profilo pesato; M11 documenta il compromesso di ' ...
    'ordine; M12 conserva gli esiti mu; la RAS Khinf e un''ulteriore ' ...
    'evidenza empirica non sostitutiva.\n']);
