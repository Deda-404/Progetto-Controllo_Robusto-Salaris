function evidence = verify_four_final_scripts
%VERIFY_FOUR_FINAL_SCRIPTS Execute the four delivered scripts unchanged.
root=fileparts(fileparts(mfilename('fullpath')));
protected=[dir(fullfile(root,'results/data/m3_nominal_actuated_plant.mat')); ...
    dir(fullfile(root,'results/data/m4_uncertain_plant.mat'));dir(fullfile(root,'results/data/m5_performance_specs.mat')); ...
    dir(fullfile(root,'results/data/m6_lqg_no_integrator.mat'));dir(fullfile(root,'results/data/m7_augmented_cost_feasibility.mat')); ...
    dir(fullfile(root,'results/data/hinf_final_coherent/**/*.mat'))];
before=arrayfun(@(f)hashFile(fullfile(f.folder,f.name)),protected,'UniformOutput',false);
names={'progetto_lqg.m','progetto_lqgi.m','progetto_hinf_tre_controllori.m','progetto_mu.m'};
evidence=struct('matlab',version,'scripts',[],'protectedCount',numel(protected));
records=cell(4,1);
for j=1:4
    file=fullfile(root,'File_di_Funzioni_Progetto-Accorpati',names{j});clock=tic;
    fprintf('START delivered script %s\n',names{j});
    executeScript(file);
    records{j}=struct('name',names{j},'status','EXECUTED PASS','seconds',toc(clock), ...
        'sourceHash',hashFile(file),'codeAnalyzer',checkcode(file,'-id'));
    fprintf('PASS delivered script %s\n',names{j});
end
after=arrayfun(@(f)hashFile(fullfile(f.folder,f.name)),protected,'UniformOutput',false);
assert(isequal(before,after),'FinalScripts:ArtifactChanged','A physical model or frozen controller artifact changed.');
evidence.scripts=[records{:}];evidence.protectedHashesUnchanged=true;
save(fullfile(root,'results/data/final_closure/four_scripts_execution.mat'),'evidence');
f=fopen(fullfile(root,'results/data/final_closure/four_scripts_execution.json'),'w');cleanup=onCleanup(@()fclose(f));
fprintf(f,'%s',jsonencode(evidence,PrettyPrint=true));
end
function executeScript(file)
set(groot,'defaultFigureVisible','off');
run(file);
close all;
end
function hash=hashFile(file)
f=fopen(file,'rb');cleanup=onCleanup(@()fclose(f));
bytes=fread(f,Inf,'*uint8');digest=java.security.MessageDigest.getInstance('SHA-256');digest.update(bytes);
hash=lower(reshape(dec2hex(typecast(digest.digest(),'uint8'),2).',1,[]));
end
