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

fprintf('Progetto CR - esecuzione riproducibile\n');
fprintf('Root: %s\n', projectRoot);
fprintf(['Milestone implementata: M5 (specifiche, pesi e disturbo ' ...
    'fisico di coppia ai link; nessuna sintesi controller)\n\n']);

try
    fprintf(['--- Test automatici M0 + M1 + M2 + M3/M3.1 + ' ...
        'M4/M4.1 + M5 ---\n']);
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

    fprintf(['\n[PASS] RUN_ALL completato: regressioni M0-M4.1 e quality ' ...
        'gate M5 (governance, specifiche, W1/W2, Bd, disturbance path, ' ...
        'dataset e figure) superati; nessun controllore sintetizzato.\n']);
catch executionError
    fprintf(2, '\n[FAIL] RUN_ALL interrotto: %s\n', executionError.message);
    rethrow(executionError);
end
