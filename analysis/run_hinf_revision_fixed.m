function campaign = run_hinf_revision_fixed
%RUN_HINF_REVISION_FIXED Dieci RandomStart oltre alla partenza nominale.
root=fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(root,'controllers')),genpath(fullfile(root,'src')));
folder=fullfile(root,'results','data','hinf_targeted_revision');
loaded=load(fullfile(folder,'study.mat')); study=loaded.study; c=study.config;
assert(~isempty(study.selected),'HinfRevision:FullOrderGate','Full-order non conforme.');
r=study.cases{study.selected};
assert(r.gammaHinf<1 && r.hinf.nominalPerformance,'HinfRevision:FullOrderGate','Gamma >= 1.');
m3=load(fullfile(root,'results','data','m3_nominal_actuated_plant.mat'));
m5=load(fullfile(root,'results','data','m5_performance_specs.mat'));
G=ss(m3.Afull,m3.Bfull,m3.CfullQ,zeros(2));
cfg=hinfstruct_specs_m11;
campaign=struct('config',c,'fullOrderGamma',r.gammaHinf,'families',{{}});
for i=1:7
    if i==7 && any(cellfun(@(x) x.performancePass,campaign.families)), break; end
    path=fullfile(folder,sprintf('fixed_%02d.mat',i));
    if isfile(path)
        saved=load(path,'family'); family=saved.family;
        assert(isequal(family.config,c) && family.fullOrderGamma==r.gammaHinf, ...
            'HinfRevision:CacheMismatch','Cache fixed-order non coerente.');
    else
        if i<=6
            structure=build_m11_structured_controller(cfg.architectures.ID(i),cfg);
        else
            structure=struct('id',"A6",'controller',tunableSS('K_A6',8,2,2), ...
                'blockNames',"K_A6",'definition',table(false,'VariableNames',{'Diagonal'}));
        end
        rng(c.seed+i-1,'twister');
        family=struct('id',structure.id,'seed',c.seed+i-1,'config',c, ...
            'fullOrderGamma',r.gammaHinf,'runs',{{}},'performancePass',false, ...
            'bestRun',[],'error',"");
        fprintf('Fixed %s, seed %d, RandomStart=%d\n',structure.id,family.seed,c.randomStart);
        options=hinfstructOptions('Display','off','RandomStart',c.randomStart, ...
            'MaxIter',c.maxIter,'UseParallel',false,'TolGain',1e-3,'TargetGain',0);
        try
            [~,family.objective,family.info]=hinfstruct(lft(r.P,structure.controller),options);
            for j=1:numel(family.info)
                run=struct('objective',family.info(j).Objective,'error',"",'stable',false, ...
                    'performancePass',false,'relativeGap',inf,'order',nan);
                try
                    extracted=extract_m11_tuned_controller(family.info(j).TunedBlocks,structure);
                    run.K=extracted.controller; run.order=order(run.K);
                    run.evaluation=hinf_revision_evaluate(G,m5.BdFull,run.K,r.W1,r.W2,m5.spec,c);
                    run.stable=run.evaluation.stable;
                    run.relativeGap=(run.evaluation.norms(1)-r.gammaHinf)/r.gammaHinf;
                    run.objectiveRelativeError=abs(run.evaluation.norms(1)-run.objective)/max(1,run.objective);
                    run.performancePass=run.evaluation.nominalPerformance && ...
                        run.objective<1 && run.objectiveRelativeError<5e-3;
                catch err
                    run.error=string(getReport(err,'extended','hyperlinks','off'));
                end
                family.runs{j}=run;
            end
            stable=find(cellfun(@(x) x.stable && isfinite(x.objective),family.runs));
            if ~isempty(stable)
                [~,best]=min(cellfun(@(x) x.evaluation.norms(1),family.runs(stable)));
                family.bestRun=stable(best);
                family.performancePass=family.runs{family.bestRun}.performancePass;
            end
        catch err
            family.error=string(getReport(err,'extended','hyperlinks','off'));
        end
        save(path,'family','-v7');
    end
    campaign.families{i}=family;
    if ~isempty(family.bestRun)
        best=family.runs{family.bestRun};
        fprintf('%s: order=%d objective=%.9g norm=%.9g stable=%d NP=%d\n', ...
            family.id,best.order,best.objective,best.evaluation.norms(1),best.stable,best.performancePass);
    else
        fprintf('%s: nessun risultato stabile. %s\n',family.id,family.error);
    end
    save(fullfile(folder,'fixed_campaign.mat'),'campaign','-v7');
end
end
