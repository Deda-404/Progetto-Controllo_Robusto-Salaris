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
fprintf('Milestone implementata: M2 (equilibrio e linearizzazione SEA)\n\n');

try
    fprintf('--- Test automatici M0 + M1 + M2 ---\n');
    testResults = runtests(fullfile(projectRoot, 'tests'));
    assertSuccess(testResults);
    fprintf('Test automatici superati: %d/%d.\n', ...
        sum([testResults.Passed]), numel(testResults));

    fprintf('\n--- Validazione numerica M1 ---\n');
    m1Metrics = validate_m1_nonlinear_model;

    fprintf('\n--- Validazione, dataset e figura M2 ---\n');
    m2Metrics = validate_m2_equilibrium_linearization;

    fprintf(['\n[PASS] RUN_ALL completato: test M0/M1/M2, validazioni M1/M2, ' ...
        'dataset e figura M2 superati.\n']);
catch executionError
    fprintf(2, '\n[FAIL] RUN_ALL interrotto: %s\n', executionError.message);
    rethrow(executionError);
end
