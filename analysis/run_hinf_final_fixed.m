function campaign=run_hinf_final_fixed
%RUN_HINF_FINAL_FIXED Strutture 2DoF, undici partenze per famiglia.
root=fileparts(fileparts(mfilename('fullpath'))); addpath(genpath(fullfile(root,'controllers')),genpath(fullfile(root,'src')));
folder=fullfile(root,'results','data','hinf_final_coherent');
a=load(fullfile(folder,'selected_full_order.mat')); q=a.selected;
a=load(fullfile(folder,'nominal_study.mat')); physical=a.study.physical; spec=a.study.spec;
c=hinf_final_config; families=["STATIC","PI","PID","SS2","SS4","SS6","SS8"];
campaign=struct('source',q,'families',{{}},'minimumObservedOrder',inf);
for j=1:numel(families)
    if j==7 && isfinite(campaign.minimumObservedOrder), break; end
    name=families(j); file=fullfile(folder,"fixed_"+name+".mat");
    if isfile(file)
        a=load(file,'f'); f=a.f; assert(isequaln(f.sourceK,q.K));
    else
        if name=="STATIC"
            Kt=genss(tunableGain('Kstatic',2,4));
        elseif name=="PI" || name=="PID"
            Kt=blkdiag(tunablePID2('joint1',char(name)),tunablePID2('joint2',char(name)));
            Kt=Kt(:,[1 3 2 4]);
        else
            Kt=genss(tunableSS('Kmimo',str2double(extractAfter(name,2)),2,4));
        end
        f=struct('name',name,'seed',c.seed+j,'sourceK',q.K,'runs',{{}},'error',"");
        rng(f.seed,'twister');
        opts=hinfstructOptions('Display','final','RandomStart',10,'MaxIter',300,'UseParallel',false);
        try
            [~,f.bestObjective,f.info]=hinfstruct(lft(q.P,Kt),opts);
            for k=1:numel(f.info)
                r=struct('objective',f.info(k).Objective,'error',"");
                try
                    Kg=Kt; names=fieldnames(f.info(k).TunedBlocks);
                    for b=1:numel(names)
                        Kg=setBlockValue(Kg,names{b},getValue(f.info(k).TunedBlocks.(names{b})));
                    end
                    r.K=ss(getValue(Kg));
                    r.e=hinf_final_evaluate(physical,r.K,q.W1,q.W2,q.Mo,spec,c,q.architecture);
                    r.mapError=max(abs(freqresp(lft(q.P,r.K),c.omega)-freqresp(r.e.weighted,c.omega)),[],'all');
                    r.valid=r.e.stable && r.mapError<c.mapTolerance && abs(r.objective-r.e.norms(1))<.01*max(1,r.objective);
                catch err
                    r.error=string(getReport(err,'extended','hyperlinks','off')); r.valid=false;
                end
                f.runs{k}=r;
            end
        catch err
            f.error=string(getReport(err,'extended','hyperlinks','off'));
        end
        save(file,'f','-v7');
    end
    for k=1:numel(f.runs)
        r=f.runs{k};
        if r.valid && r.e.NP, campaign.minimumObservedOrder=min(campaign.minimumObservedOrder,r.e.order); end
    end
    campaign.families{j}=f;
    fprintf('FAMILY %s completed, minimum observed NP order %g\n',name,campaign.minimumObservedOrder);
    if strlength(f.error)>0, disp(f.error); end
    save(fullfile(folder,'fixed_study.mat'),'campaign','-v7');
end
end
