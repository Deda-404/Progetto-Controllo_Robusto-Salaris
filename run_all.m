%% RUN_ALL Rebuild entry point for the robust-control project

clearvars;
close all force;
clc;

projectRoot = fileparts(mfilename('fullpath'));
originalDirectory = pwd;
cleanupDirectory = onCleanup(@() cd(originalDirectory));
cd(projectRoot);

rng(42, 'twister');
addpath(genpath(fullfile(projectRoot, 'src')));
addpath(genpath(fullfile(projectRoot, 'controllers')));
addpath(genpath(fullfile(projectRoot, 'analysis')));
addpath(genpath(fullfile(projectRoot, 'simulink')));

fprintf('Progetto CR - esecuzione riproducibile\n');
fprintf('Root: %s\n', projectRoot);
fprintf(['Milestone corrente: M8 COMPLETE — Simulink non lineare e ' ...
    'RAS empirica del LQG M6; M7 resta PARTIAL e congelata\n\n']);

try
    fprintf(['--- Test automatici M0 + M1 + M2 + M3/M3.1 + ' ...
        'M4/M4.1 + M5 + M6 + M7 + M8 ---\n']);
    testResults = runtests(fullfile(projectRoot, 'tests'));
    assertSuccess(testResults);
    fprintf('Test automatici superati: %d/%d.\n', ...
        sum([testResults.Passed]), numel(testResults));

    fprintf('\n--- Validazione numerica M1 ---\n');
    m1Metrics = validate_m1_nonlinear_model;

    fprintf('\n--- Validazione, dataset e figura M2 ---\n');
    m2Metrics = validate_m2_equilibrium_linearization;

    fprintf('\n--- Selezione attuatori, validazione e artifact M3 ---\n');
    m3Metrics = validate_m3_nominal_actuated_plant;

    fprintf(['\n--- Screening, fit WI, pianta incerta, dataset e ' ...
        'figure M4 ---\n']);
    m4Metrics = validate_m4_uncertainty_model;

    fprintf('\n--- Selezione autonoma delle specifiche M5 ---\n');
    m5Spec = performance_specs_m5;
    m5Selection = select_m5_performance_specs([], [], m5Spec);
    fprintf(['omegaB=%.6g rad/s, As=%.6g, Ms=%.6g, ' ...
        'uScale=%.6g N m, omegaU=%.6g rad/s, alpha=%.6g\n'], ...
        m5Selection.selected.omegaB, m5Selection.selected.As, ...
        m5Selection.selected.Ms, m5Selection.selected.uScale, ...
        m5Selection.selected.omegaU, ...
        m5Selection.selected.controlWeightAlpha);

    fprintf(['\n--- Validazione pesi, disturbance path, dataset e ' ...
        'figure M5 ---\n']);
    m5Metrics = validate_m5_performance_specs;

    fprintf(['\n--- Diagnosi baseline, tuning LQR, Kalman, LQG, ' ...
        'dataset e figure M6 ---\n']);
    m6Metrics = validate_m6_lqg_no_integrator;

    fprintf(['\n--- M7: checkpoint 1-DoF, Nff candidato-specifico, ' ...
        'Stage A/B e feasibility gate ---\n']);
    m7Metrics = validate_m7_lqg_integral;

    fprintf(['\n--- M7: ultima feasibility, co-tuning strutturato ' ...
        'del costo augmentato ---\n']);
    m7FinalFeasibilityMetrics = ...
        validate_m7_augmented_cost_feasibility;

    fprintf(['\n--- M8: Simulink non lineare, LTI/NL, disturbi, ' ...
        'rumore e RAS empirica ---\n']);
    m8Metrics = validate_m8_simulink_ras(true);

    fprintf(['\n[PASS] RUN_ALL completato senza errori: regressioni ' ...
        'M0-M7, modello Simulink M8, equilibrio, tracking, disturbi, ' ...
        'rumore, confronto LTI/NL, due sezioni RAS, dataset, figure e ' ...
        'quality gate superati. M7 resta PARTIAL come risultato ' ...
        'terminale; nessun tuning ulteriore e'' stato eseguito.\n']);
catch executionError
    fprintf(2, '\n[FAIL] RUN_ALL interrotto: %s\n', executionError.message);
    rethrow(executionError);
end
