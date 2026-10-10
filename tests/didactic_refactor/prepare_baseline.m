function prepare_baseline
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(fullfile(root,'tests','didactic_refactor'));
folder=fullfile(root,'results/data/hinf_final_coherent');
names={'nominal_study','selected_full_order','fixed_PID','m13','m14','robust_study','m12', ...
    'nominal_1dof_12','nominal_2dof_03'};
artifacts=struct;
for k=1:numel(names)
    file=fullfile(folder,[names{k},'.mat']);
    disp(whos('-file',file)); data=load(file);
    artifacts.(names{k})=data;
    disp(['FILE ',names{k}]); disp(fieldnames(data));
    fields=fieldnames(data);
    for j=1:numel(fields)
        if isstruct(data.(fields{j})), disp(fieldnames(data.(fields{j}))); end
    end
end
save(fullfile(root,'tmp/refactor_didactic/artifacts_audit.mat'),'artifacts','-v7');
oldPath=path; cleanup=onCleanup(@() path(oldPath)); restoredefaultpath;
addpath(fullfile(root,'tests','didactic_refactor'));
before=rng;
hinf=run_capture(fullfile(root,'tmp/refactor_didactic/before/progetto_hinf_tre_controllori.m'));
assert(isequal(before,rng));
figures=findall(groot,'Type','figure'); assert(numel(figures)==4);
for k=1:numel(figures)
    exportgraphics(figures(k),fullfile(root,'tmp/refactor_didactic',sprintf('before_hinf_%d.png',k)),'Resolution',100);
end
close all;
mu=run_capture(fullfile(root,'tmp/refactor_didactic/before/progetto_mu.m'));
assert(isequal(before,rng));
figures=findall(groot,'Type','figure'); assert(numel(figures)==3);
for k=1:numel(figures)
    exportgraphics(figures(k),fullfile(root,'tmp/refactor_didactic',sprintf('before_mu_%d.png',k)),'Resolution',100);
end
close all;
save(fullfile(root,'tmp/refactor_didactic/baseline.mat'),'hinf','mu','-v7');
fprintf('DEFAULT BASELINES PASS: HINF 4 FIGURES, MU 3 FIGURES, RNG RESTORED\n');
end
