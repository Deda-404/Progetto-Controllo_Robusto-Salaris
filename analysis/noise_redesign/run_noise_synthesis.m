function candidates = run_noise_synthesis(stage)
% Sintesi separate; nessuna modifica ai MAT consolidati o agli SLX.
arguments
    stage (1,1) string {mustBeMember(stage,["hinf","mu"])} = "hinf"
end
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(genpath(fullfile(root,'src')),genpath(fullfile(root,'controllers')), ...
    genpath(fullfile(root,'analysis')));
d=final_closure_load; q=d.selected;
folder=fullfile(root,'results/data/noise_redesign'); if ~isfolder(folder),mkdir(folder);end
options=hinfsynOptions('RelTol',q.config.solverRelTol);
% Wn e una scala deterministica in rad, non una densita spettrale gaussiana.
% Tre livelli ordinati: protezione al rumore con W1, W2 e Mo invariati.
scales=[1 5 20]; candidates=cell(numel(scales),1);
for j=1:numel(scales)
    file=fullfile(folder,sprintf('hinf_noise_%02d.mat',j));
    if isfile(file)
        a=load(file,'candidate'); candidate=a.candidate;
        assert(candidate.noiseScale==scales(j) && isequaln(candidate.W1,q.W1) && ...
            isequaln(candidate.W2,q.W2) && isequaln(candidate.Mo,q.Mo) && ...
            isequal(candidate.Wn,scales(j)*d.sigmaY*eye(2)));
    else
        candidate=struct('name',"HinfN"+j,'release',version('-release'), ...
            'noiseScale',scales(j),'sigmaY',d.sigmaY,'Wn',scales(j)*d.sigmaY*eye(2), ...
            'W1',q.W1,'W2',q.W2,'Mo',q.Mo,'status',"ERROR",'error',"");
        try
            candidate.P=noise_generalized_plant(d.physical,q.W1,q.W2,q.Mo,candidate.Wn);
            clock=tic;
            [candidate.K,candidate.CL,candidate.gamma,candidate.info]=hinfsyn(candidate.P,4,2,options);
            candidate.seconds=toc(clock);
            assert(isequal(size(candidate.K),[2 4]) && isproper(candidate.K));
            candidate.e=hinf_final_evaluate(d.physical,candidate.K,q.W1,q.W2,q.Mo,d.m5.spec,q.config,"2DOF");
            assert(candidate.e.stable,'NoiseSynthesis:Stability','Chiusura interna instabile.');
            candidate.newNorm=norm(candidate.CL,inf);
            assert(abs(candidate.newNorm-candidate.gamma)/candidate.gamma<.003);
            Ky=candidate.K(:,3:4); G=d.physical(:,1:2);
            candidate.Tuv=feedback(Ky,G,+1);
            candidate.noiseGain=norm(candidate.Tuv,inf);
            candidate.status="SYNTHESIZED";
        catch err
            candidate.error=string(getReport(err,'extended','hyperlinks','off'));
        end
        save(file,'candidate','-v7');
    end
    candidates{j}=candidate;
    fprintf('%s: %s, Wn/sigma=%g\n',candidate.name,candidate.status,candidate.noiseScale);
    if isfield(candidate,'e')
        fprintf('gamma=%g oldNorm=%g Tuv=%g order=%d maxRe=%g\n', ...
            candidate.gamma,candidate.e.norms(1),candidate.noiseGain,order(candidate.K),candidate.e.maxRealPole);
        disp(candidate.e.metrics);
    else
        fprintf('%s\n',candidate.error);
    end
end
if stage=="mu"
    m4=load(fullfile(root,'results/data/m4_uncertain_plant.mat'));
    physical=hinf_final_uncertain(m4,d.m5.BdFull);
    r=q.config.robust;
    opts=musynOptions('Display','short','MaxIter',r.maxIterations, ...
        'TargetPerf',r.targetPerformance,'TolPerf',r.performanceTolerance, ...
        'MixedMU',r.mixedMu,'FullDG',r.fullDG,'FitOrder',r.fitOrder, ...
        'FrequencyGrid',r.frequencyGrid,'AutoScale',r.autoScale,'Regularize',r.regularize, ...
        'LimitGain',r.limitGain,'RandomStart',r.randomStart,'UseParallel',false, ...
        'MinDecay',r.minimumDecay,'MaxFrequency',r.maximumFrequency);
    % Una D-K sul primo profilo: massima continuita con i pesi consolidati.
    base=candidates{1}; assert(base.status=="SYNTHESIZED");
    file=fullfile(folder,'mu_noise_01.mat');
    if isfile(file)
        a=load(file,'candidate'); candidate=a.candidate;
    else
        candidate=rmfield(base,{'K','CL','gamma','info','e','Tuv','noiseGain','newNorm','seconds'});
        candidate.name="MuN1"; candidate.status="ERROR";
        candidate.P=noise_generalized_plant(physical,q.W1,q.W2,q.Mo,base.Wn);
        candidate.options=opts; candidate.seed=20261013; rng(candidate.seed,'twister');
        clock=tic;
        try
            [candidate.K,candidate.objective,candidate.dkInfo]=musyn(candidate.P,4,2,opts);
            candidate.seconds=toc(clock);
            candidate.CL=lft(candidate.P,candidate.K);
            candidate.newNorm=norm(candidate.CL.NominalValue,inf);
            candidate.e=hinf_final_evaluate(d.physical,candidate.K,q.W1,q.W2,q.Mo,d.m5.spec,q.config,"2DOF");
            assert(candidate.e.stable && isequal(size(candidate.K),[2 4]) && isproper(candidate.K));
            candidate.Tuv=feedback(candidate.K(:,3:4),d.physical(:,1:2),+1);
            candidate.noiseGain=norm(candidate.Tuv,inf); candidate.status="SYNTHESIZED";
        catch err
            candidate.error=string(getReport(err,'extended','hyperlinks','off'));
        end
        save(file,'candidate','-v7');
    end
    fprintf('%s: %s\n',candidate.name,candidate.status);
    if candidate.status=="SYNTHESIZED"
        fprintf('objective=%g norm=%g Tuv=%g order=%d\n',candidate.objective,candidate.newNorm,candidate.noiseGain,order(candidate.K));
        disp(candidate.e.metrics);
    else
        fprintf('%s\n',candidate.error);
    end
    candidates{end+1}=candidate;
end
end
