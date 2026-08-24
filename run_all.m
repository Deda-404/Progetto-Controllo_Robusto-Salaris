%% RUN_ALL Rebuild entry point for the robust-control project

projectRoot = fileparts(mfilename('fullpath'));
originalDirectory = pwd;
cleanupDirectory = onCleanup(@() cd(originalDirectory));
cd(projectRoot);

rng(42, 'twister');

addpath(fullfile(projectRoot, 'src'));
addpath(genpath(fullfile(projectRoot, 'controllers')));
addpath(genpath(fullfile(projectRoot, 'analysis')));

fprintf('Progetto CR - esecuzione riproducibile\n');
fprintf('Root: %s\n', projectRoot);
fprintf('Milestone implementata: M0 (solo verifica workspace)\n');

testResults = runtests(fullfile(projectRoot, 'tests'));
assertSuccess(testResults);

fprintf('M0 smoke test completato con successo.\n');
fprintf('Nessuna pipeline di modellazione o controllo e'' ancora implementata.\n');
