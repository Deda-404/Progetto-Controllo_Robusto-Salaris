function result=run_hinf_final_robust
%RUN_HINF_FINAL_ROBUST M12, D-K M13 e post-analisi M14 sul medesimo 2DoF.
root=fileparts(fileparts(mfilename('fullpath'))); addpath(genpath(fullfile(root,'controllers')),genpath(fullfile(root,'src')));
folder=fullfile(root,'results','data','hinf_final_coherent');
a=load(fullfile(folder,'selected_full_order.mat')); q=a.selected; c=q.config;
a=load(fullfile(folder,'nominal_study.mat')); physical=a.study.physical; spec=a.study.spec;
m4=load(fullfile(root,'results','data','m4_uncertain_plant.mat'));
m5=load(fullfile(root,'results','data','m5_performance_specs.mat'));
unc=hinf_final_uncertain(m4,m5.BdFull);
P=hinf_final_2dof_plant(unc,q.W1,q.W2,q.Mo);
plantError=max(abs(freqresp(P.NominalValue,c.omega)-freqresp(q.P,c.omega)),[],'all');
assert(plantError<1e-7,'HinfFinal:UncertainNominal','Problema nominale differente.');
result=struct('source',q,'physical',unc,'P',P,'plantError',plantError);
file=fullfile(folder,'m12.mat');
if isfile(file), a=load(file,'audit'); audit=localValidateMargins(a.audit); assert(isequaln(audit.K,q.K)); save(file,'audit','-v7');
else, audit=localAudit(P,q.K); save(file,'audit','-v7'); end
result.m12=audit;
fprintf('M12 RS [%g %g], RP [%g %g]\n',audit.RS.LowerBound,audit.RS.UpperBound,audit.RP.LowerBound,audit.RP.UpperBound);
file=fullfile(folder,'m13.mat');
if isfile(file)
    a=load(file,'synthesis'); synthesis=a.synthesis; assert(isequaln(synthesis.P,P));
else
    r=c.robust;
    opts=musynOptions('Display','short','MaxIter',r.maxIterations,'TargetPerf',r.targetPerformance, ...
        'TolPerf',r.performanceTolerance,'MixedMU',r.mixedMu,'FullDG',r.fullDG,'FitOrder',r.fitOrder, ...
        'FrequencyGrid',r.frequencyGrid,'AutoScale',r.autoScale,'Regularize',r.regularize, ...
        'LimitGain',r.limitGain,'RandomStart',r.randomStart,'UseParallel',false, ...
        'MinDecay',r.minimumDecay,'MaxFrequency',r.maximumFrequency);
    rng(c.seed,'twister');
    [K,objective,info]=musyn(P,4,2,opts);
    synthesis=struct('K',K,'objective',objective,'info',info,'P',P,'options',opts,'seed',c.seed);
    save(file,'synthesis','-v7');
end
result.m13=synthesis;
file=fullfile(folder,'m14.mat');
if isfile(file), a=load(file,'audit'); audit=localValidateMargins(a.audit); assert(isequaln(audit.K,synthesis.K)); save(file,'audit','-v7');
else, audit=localAudit(P,synthesis.K); save(file,'audit','-v7'); end
result.m14=audit;
result.muEvaluation=hinf_final_evaluate(physical,synthesis.K,q.W1,q.W2,q.Mo,spec,c,q.architecture);
fprintf('M14 RS [%g %g], RP [%g %g], nominal norm %g\n',audit.RS.LowerBound,audit.RS.UpperBound,audit.RP.LowerBound,audit.RP.UpperBound,result.muEvaluation.norms(1));
disp(result.muEvaluation.metrics);
save(fullfile(folder,'robust_study.mat'),'result','-v7');
end

function a=localAudit(P,K)
% Ogni chiamata ricalcola i margini: nessun objective di sintesi certifica RP.
a.K=K; a.CL=lft(P,K); a.NS=isstable(a.CL.NominalValue);
a.nominalNorm=norm(a.CL.NominalValue,inf); a.NP=a.NS && a.nominalNorm<1;
[a.M,a.Delta,a.BlkStruct,a.NormUnc]=lftdata(a.CL);
[a.RS,a.rsWorst,a.rsInfo]=robstab(a.CL);
[a.RP,a.rpWorst,a.rpInfo]=robgain(a.CL,1);
a=localValidateMargins(a);
end
function a=localValidateMargins(a)
% Conservare un eventuale intervallo invertito e ripetere l'analisi,
% senza scambiare artificialmente lower e upper.
if a.RP.LowerBound>a.RP.UpperBound && ~isfield(a,'rpInitial')
    a.rpInitial=struct('margin',a.RP,'worst',a.rpWorst,'info',a.rpInfo);
    rng(20260918,'twister');
    opts=robOptions('MussvOptions','m9','Sensitivity','on');
    [a.RP,a.rpWorst,a.rpInfo]=robgain(a.CL,1,opts);
end
assert(a.RS.LowerBound<=a.RS.UpperBound,'HinfFinal:RSBounds','Intervallo RS invertito.');
a.RSOutcome=localOutcome(a.RS);
if a.RP.LowerBound>a.RP.UpperBound
    a.RPOutcome="NUMERICAL_INCONSISTENCY";
    if a.RSOutcome=="FAIL", a.RPOutcome="FAIL_FROM_RS_MARGIN_NOT_VALIDATED"; end
else
    a.RPOutcome=localOutcome(a.RP);
end
a.rpWorstActualNorm=norm(usubs(a.CL,a.rpWorst),inf);
end
function outcome=localOutcome(m)
if m.LowerBound>1, outcome="PASS"; elseif m.UpperBound<1, outcome="FAIL"; else, outcome="INCONCLUSIVE"; end
end
