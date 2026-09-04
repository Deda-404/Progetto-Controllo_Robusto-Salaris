%% MODELLAZIONE, LINEARIZZAZIONE E DEFINIZIONE DEL PROBLEMA DI CONTROLLO
% Entry point didattico M0-M5. Lo script ricostruisce il filo logico dalla
% fisica del manipolatore fino ai pesi della mixed sensitivity. Le funzioni
% modulari restano la sorgente dei calcoli; qui vengono resi visibili dati,
% motivazioni e verifiche che servono per discutere il progetto all'esame.

%% 0. Introduzione e setup
clearvars;
clc;
close all;

projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(projectRoot, 'src')));
addpath(genpath(fullfile(projectRoot, 'analysis')));
fprintf('\n=== Percorso didattico M0-M5: manipolatore SEA 2R ===\n');
fprintf('Root del progetto: %s\n', projectRoot);

%% 1. Parametri fisici nominali
p = sea_params_nominal;
parameter = ["m1"; "m2"; "l1"; "l2"; "Jm1"; "Jm2"; ...
    "Bm1"; "Bm2"; "k1"; "k2"; "g"];
value = [p.m1; p.m2; p.l1; p.l2; diag(p.Jm); diag(p.Bm); ...
    diag(p.Ks); p.g];
unit = ["kg"; "kg"; "m"; "m"; "kg m^2"; "kg m^2"; ...
    "N m s/rad"; "N m s/rad"; "N m/rad"; "N m/rad"; "m/s^2"];
nominalParameterTable = table(parameter, value, unit, ...
    'VariableNames', {'Parameter', 'Value', 'Unit'});
disp(nominalParameterTable);

%% 2. Modello dinamico non lineare
% Lo stato meccanico assoluto e x=[q; qdot; theta; thetadot]. La coppia
% elastica Ks(theta-q) scambia energia fra link e motori, mentre M(q),
% C(q,qdot) e g(q) mantengono la dipendenza non lineare dalla configurazione.
xExample = [pi / 2; 0; 0; 0; pi / 2; 0; 0; 0];
xdotExample = sea_nonlinear_rhs(xExample, zeros(2, 1), p);
fprintf('Stato di esempio x=[q;qDot;theta;thetaDot] (8 stati).\n');
fprintf('Norma della derivata senza coppia: %.6g\n', norm(xdotExample));

%% 3. Punto di equilibrio
qbar = [pi / 2; 0];
[xbar, taubar, equilibriumInfo] = sea_static_equilibrium(qbar, p);
equilibriumTable = table((1:2).', rad2deg(qbar), taubar, ...
    'VariableNames', {'Joint', 'QbarDeg', 'TauBarNm'});
disp(equilibriumTable);
fprintf('Residuo delle equazioni di equilibrio: %.3e\n', ...
    equilibriumInfo.residualNorm);

%% 4. Linearizzazione analitica
[A, B, equilibrium, linearizationInfo] = ...
    sea_linearize_static_equilibrium_analytic(qbar, p);
[Cq, Dq, Cmeas, Dmeas] = sea_output_matrices;
fprintf('A meccanica (%dx%d):\n', size(A)); disp(A);
fprintf('B meccanica (%dx%d):\n', size(B)); disp(B);
fprintf('Cq (%dx%d), Dq (%dx%d).\n', size(Cq), size(Dq));
fprintf('Cmis (%dx%d), Dmis (%dx%d).\n', size(Cmeas), size(Dmeas));
fprintf('Norma della matrice di massa all''equilibrio: %.4g.\n', ...
    norm(linearizationInfo.Mbar, 2));

%% 5. Analisi del modello linearizzato
mechanicalPoles = eig(A);
controllabilityRank = rank(ctrb(A, B));
observabilityRank = rank(obsv(A, Cmeas));
unstablePoles = mechanicalPoles(real(mechanicalPoles) > 1e-8);
elasticModes = mechanicalPoles(imag(mechanicalPoles) > 1e-8);
fprintf('Poli meccanici:\n'); disp(mechanicalPoles);
fprintf('Stabilita in anello aperto: %s (%d poli RHP).\n', ...
    localYesNo(isempty(unstablePoles)), numel(unstablePoles));
fprintf('Controllabilita: rank %d/%d. Osservabilita: rank %d/%d.\n', ...
    controllabilityRank, size(A, 1), observabilityRank, size(A, 1));
fprintf('Scala instabile dominante: %.4g rad/s. Primo modo elastico: %.4g rad/s.\n', ...
    max(real(unstablePoles)), min(abs(elasticModes)));

figure('Name', 'M0-M5 - poli meccanici', 'Color', 'white');
plot(real(mechanicalPoles), imag(mechanicalPoles), 'x', ...
    'LineWidth', 1.8, 'MarkerSize', 9);
xline(0, '--k'); grid on; box on;
xlabel('Parte reale [rad/s]'); ylabel('Parte immaginaria [rad/s]');
title('Poli del modello meccanico linearizzato');

%% 6. Modello nominale degli attuatori
% wn=40 rad/s resta sopra la dinamica instabile ma sotto il primo modo
% elastico. zeta=0.8 limita la risonanza; il ritardo di 15 ms sottrae fase.
% Il Pade di ordine uno conserva un modello razionale di ordine contenuto.
actuator = actuator_params_nominal;
[Gactuator, actuatorInfo] = build_nominal_actuator(actuator);
actuatorTable = table(actuator.wn, actuator.zeta, actuator.delay, ...
    actuator.padeOrder, actuatorInfo.actuatorBandwidth, ...
    actuatorInfo.actuatorStep.Overshoot, 'VariableNames', ...
    {'WnRadS', 'Zeta', 'DelayS', 'PadeOrder', 'BandwidthRadS', ...
    'OvershootPercent'});
disp(actuatorTable);
fprintf('Poli attuatore:'); disp(pole(Gactuator).');
fprintf('Zero RHP introdotto dal Pade: %.4g rad/s.\n', ...
    actuatorInfo.padeZero);

figure('Name', 'M0-M5 - attuatore nominale', 'Color', 'white');
layoutActuator = tiledlayout(1, 2, 'TileSpacing', 'compact');
nexttile; step(Gactuator, 0:0.002:0.4); grid on;
xlabel('Tempo [s]'); ylabel('Coppia normalizzata [-]');
title('Risposta al gradino');
nexttile; bodemag(Gactuator, {1e-1, 1e3}); grid on;
xlabel('Frequenza [rad/s]'); title('Modulo dell''attuatore');
title(layoutActuator, 'Dinamica attuativa nominale');

%% 7. Modello nominale completo
[GactuatorBank, ~] = build_nominal_actuator_bank(actuator);
[GfullMeas, GfullQ] = build_m3_full_plant( ...
    A, B, Cmeas, Dmeas, Cq, Dq, GactuatorBank);
[Afull, Bfull, CfullMeas, DfullMeas] = ssdata(GfullMeas);
fullStructure = analyze_m3_structure(Afull, Bfull, CfullMeas, 1e-8);
fprintf('Pianta completa: %d stati, %d ingressi, %d uscite encoder.\n', ...
    order(GfullMeas), size(GfullMeas, 2), size(GfullMeas, 1));
fprintf('Controllabilita PBH=%s, stabilizzabilita=%s.\n', ...
    localYesNo(fullStructure.controllability.controllablePbh), ...
    localYesNo(fullStructure.controllability.stabilizable));
fprintf('Osservabilita PBH=%s, rilevabilita=%s.\n', ...
    localYesNo(fullStructure.observability.observablePbh), ...
    localYesNo(fullStructure.observability.detectable));
fprintf('D completa (%dx%d), norma=%.3e.\n', ...
    size(DfullMeas), norm(DfullMeas, 'fro'));

%% 8. Incertezze parametriche reali
% k1, k2 e Jm1 sono ureal indipendenti con dispersione +/-10%. Questi
% intervalli sono ipotesi ingegneristiche di progetto, non tolleranze
% identificate. Gli altri parametri principali restano nominali e sono
% elencati esplicitamente per evitare che "fisso" significhi "dimenticato".
uncertainty = uncertainty_params_m4;
disp(uncertainty.selectedMechanicalRanges);
disp(uncertainty.fixedModelParameters);
[GmechUncMeas, GmechUncQ] = build_uncertain_mechanical_plant( ...
    uncertainty.selectedMechanicalRanges, qbar);
fprintf('Blocchi ureal meccanici:\n'); disp(GmechUncMeas.Uncertainty);

%% 9. Incertezza dinamica degli attuatori e peso WI
% wn e zeta variano del 10%, il delay del 20% per rappresentare anche la
% maggiore variabilita di latenza/jitter. La famiglia con ritardo esatto
% viene coperta da Ga=Ga0(1+WI*Delta), ||Delta||inf<=1.
disp(uncertainty.selectedActuatorRanges);
actuatorFamily = build_actuator_family(uncertainty);
actuatorCover = fit_actuator_uncertainty_weight( ...
    actuatorFamily, uncertainty);
[GuncMeas, GuncQ] = build_m4_uncertain_plant( ...
    GmechUncMeas, GmechUncQ, actuatorCover.WI);
fprintf(['Famiglia attuatori: %d elementi (%d random); WI ordine %d; ' ...
    'max |E|/|WI|=%.5f.\n'], actuatorFamily.numberSamples, ...
    actuatorFamily.numberRandomSamples, actuatorCover.selectedOrder, ...
    actuatorCover.worstRatio);
fprintf('Blocchi incerti complessivi M4:\n'); disp(GuncMeas.Uncertainty);

figure('Name', 'M0-M5 - copertura incertezza attuatore', 'Color', 'white');
shown = round(linspace(1, actuatorFamily.numberSamples, 15));
semilogx(actuatorFamily.frequencies, ...
    abs(actuatorFamily.multiplicativeErrors(shown, :)).', ...
    'Color', [0.75, 0.80, 0.88], 'HandleVisibility', 'off');
hold on;
semilogx(actuatorFamily.frequencies, actuatorFamily.errorEnvelope, ...
    'k-', 'LineWidth', 2, 'DisplayName', 'Inviluppo');
semilogx(actuatorFamily.frequencies, actuatorCover.weightMagnitude, ...
    'r--', 'LineWidth', 2, 'DisplayName', '|W_I|');
grid on; box on; xlabel('Frequenza [rad/s]'); ylabel('Modulo [-]');
title('Errore moltiplicativo e copertura dinamica W_I');
legend('Location', 'best');

%% 10. Specifiche di progetto
spec = performance_specs_m5;
specification = ["T_s"; "M_p"; "e_ss"; "cross coupling"; ...
    "omega_B"; "u_scale"; "omega_U"];
target = [spec.settlingTimeTarget; spec.overshootTarget; ...
    100 * spec.steadyStateTrackingTarget; ...
    100 * spec.crossCouplingTarget; spec.omegaB; spec.uScale; spec.omegaU];
unitSpec = ["s"; "%"; "%"; "%"; "rad/s"; "N m"; "rad/s"];
disp(table(specification, target, unitSpec, ...
    'VariableNames', {'Specification', 'Target', 'Unit'}));
fprintf(['Riferimento nominale %.3g deg; disturbo nominale %.3g N m. ' ...
    'uScale non e una saturazione hardware.\n'], ...
    rad2deg(spec.referenceAmplitude), spec.disturbanceTorqueAmplitude);

%% 11. Pesi sulla sensibilita e sul comando
% W1 impone S piccolo alle basse frequenze: W1(0)=1/As=20 e il limite
% equivalente e 1/|W1|. W2 pesa KS; cresce da 1/uScale a alpha/uScale
% prima dei modi elastici, rendendo costosi i comandi troppo rapidi.
[W1siso, W1, W2siso, W2, weightInfo] = build_m5_weights(spec);
weightTable = table(["W1"; "W2"], ...
    [weightInfo.W1.dcMeasured; weightInfo.W2.dcMeasured], ...
    [weightInfo.W1.hfMeasured; weightInfo.W2.hfMeasured], ...
    [spec.omegaB; spec.omegaU], ...
    'VariableNames', {'Weight', 'DcGain', 'HighFrequencyGain', ...
    'TransitionRadS'});
disp(weightTable);

figure('Name', 'M0-M5 - pesi prestazionali', 'Color', 'white');
layoutWeights = tiledlayout(1, 2, 'TileSpacing', 'compact');
nexttile; bodemag(W1siso, 1 / W1siso, {1e-2, 1e3}); grid on;
legend('|W_1|', '1/|W_1|', 'Location', 'best');
xlabel('Frequenza [rad/s]'); title('Sensibilita: peso e limite');
nexttile; bodemag(W2siso, 1 / W2siso, {1e-2, 1e3}); grid on;
legend('|W_2|', '1/|W_2|', 'Location', 'best');
xlabel('Frequenza [rad/s]'); title('Comando: peso e limite');
title(layoutWeights, 'Pesi mixed-sensitivity M5');

%% 12. Riepilogo M0-M5
phase = ["M0-M1"; "M2"; "M3"; "M4"; "M5"];
result = ["modello non lineare a 8 stati"; ...
    "equilibrio e linearizzazione analitica"; ...
    "pianta nominale completa a 14 stati"; ...
    "3 ureal + 2 blocchi dinamici WI*Delta"; ...
    "specifiche, W1 e W2 congelati"];
disp(table(phase, result, 'VariableNames', {'Phase', 'Result'}));
fprintf(['Conclusione: il problema nominale e incerto e ora definito; ' ...
    'nessun controllore e stato sintetizzato in M0-M5.\n']);

function text = localYesNo(condition)
if condition
    text = 'SI';
else
    text = 'NO';
end
end
