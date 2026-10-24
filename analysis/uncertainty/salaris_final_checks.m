function salaris_final_checks
%SALARIS_FINAL_CHECKS Ultimo export, diagnostica del codice e gate dei dati.
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(genpath(fullfile(root,'src')),genpath(fullfile(root,'controllers')),genpath(fullfile(root,'analysis')));
folder=fullfile(root,'results/data/salaris_revision');
if ~isfile(fullfile(folder,'synthesis_temporal_metrics.csv')),salaris_synthesis_temporal;end
if ~isfile(fullfile(folder,'legacy_reduction.csv')),salaris_legacy_reduction;end
salaris_export;
files=[dir(fullfile(root,'analysis/uncertainty/salaris*.m')); ...
    dir(fullfile(root,'analysis/uncertainty/build_salaris_models.m')); ...
    dir(fullfile(root,'analysis/uncertainty/run_salaris_revision.m')); ...
    dir(fullfile(root,'src/actuators/build_manual_parametric_actuator.m')); ...
    dir(fullfile(root,'src/uncertainty/build_manual_mechanical_lft.m')); ...
    dir(fullfile(root,'tests/salarisModelsTest.m'))];
diagnostics=cell(numel(files),1);
for k=1:numel(files)
    diagnostics{k}=struct('file',files(k).name,'messages',checkcode(fullfile(files(k).folder,files(k).name),'-id'));
end
folder=fullfile(root,'results/data/salaris_revision');
fid=fopen(fullfile(folder,'code_analyzer.json'),'w');
cleanup=onCleanup(@()fclose(fid));
fprintf(fid,'%s',jsonencode(diagnostics,'PrettyPrint',true));
tests=readtable(fullfile(folder,'final_tests.csv'));
assert(all(tests.Passed) && ~any(tests.Failed|tests.Incomplete),'Salaris:Tests','Gate test fallito.');
fprintf('GATE finale: %d/%d test PASS; diagnostica di %d file salvata.\n',sum(tests.Passed),height(tests),numel(files));
end
