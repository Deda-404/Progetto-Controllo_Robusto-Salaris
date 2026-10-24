function run_salaris_revision(stage)
%RUN_SALARIS_REVISION Revisione sequenziale con output separati dagli storici.
arguments
    stage (1,1) string {mustBeMember(stage,["models","analysis","synthesis","simulations","secondary","all"])}="models"
end
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
assert(strcmp(pwd,root),'Salaris:Root','Eseguire dalla radice del repository.');
addpath(genpath('src'),genpath('controllers'),genpath('analysis'));
folder=fullfile(root,'results/data/salaris_revision');
if ~isfolder(folder),mkdir(folder);end
if stage=="models" || stage=="all"
    models=build_salaris_models;
    tests=runtests('tests/salarisModelsTest.m'); assertSuccess(tests);
    writetable(table(tests),fullfile(folder,'model_tests.csv'));
    save(fullfile(folder,'models.mat'),'models','-v7');
    writetable(models.coverage,fullfile(folder,'coverage.csv'));
    writetable(models.family,fullfile(folder,'actuator_samples.csv'));
    fprintf('MODELLI: PASS, LFT manuali verificate.\n');
end
if stage=="analysis" || stage=="all"
    a=load(fullfile(folder,'models.mat')); models=a.models;
    d=final_closure_load; q=d.selected; rows=cell(0,15);
    for k=1:numel(d.controllers)
        for j=1:3
            file=fullfile(folder,d.controllers(k).name+"_"+models.names(j)+".mat");
            cl=salaris_closed_loop(models.plants{j},d.controllers(k).K,q.W1,q.W2,q.Mo);
            if isfile(file)
                a=load(file,'audit'); audit=a.audit;
            else
                rng(20261024,'twister'); audit=salaris_audit_loop(cl);
                audit.K=d.controllers(k).K; audit.CL=cl;
                save(file,'audit','-v7');
            end
            r=audit;
            rows(end+1,:)={d.controllers(k).name,models.names(j),r.NS,r.NP,r.nominalNorm, ...
                r.RS.LowerBound,r.RS.UpperBound,r.RS.CriticalFrequency,r.RSOutcome, ...
                r.RP.LowerBound,r.RP.UpperBound,r.RPOutcome,min(r.bandwidth), ...
                r.disturbanceNorm,r.commandNorm}; %#ok<AGROW>
            fprintf('%s %s: NS=%d NP=%d RS=[%.4g %.4g] RP=[%.4g %.4g]\n', ...
                d.controllers(k).name,models.names(j),r.NS,r.NP, ...
                r.RS.LowerBound,r.RS.UpperBound,r.RP.LowerBound,r.RP.UpperBound);
            summary=cell2table(rows,'VariableNames',{'Controller','Model','NS','NP','NominalNorm', ...
                'RSLower','RSUpper','RSFrequency','RSOutcome','RPLower','RPUpper','RPOutcome', ...
                'MinimumBandwidth','DisturbanceNorm','CommandNorm'});
            writetable(summary,fullfile(folder,'comparison.csv'));
        end
    end
    salaris_check_comparison;
end
if stage=="synthesis" || stage=="all", salaris_synthesis; end
if stage=="simulations" || stage=="all", salaris_simulations; end
if stage=="secondary" || stage=="all", salaris_secondary; end
end
