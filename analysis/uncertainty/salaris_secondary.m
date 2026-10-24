function salaris_secondary
%SALARIS_SECONDARY Tre prove Q/R, covarianze omogenee, due riduzioni mu.
d=final_closure_load; folder=fullfile(d.root,'results/data/salaris_revision');
salaris_nominal_summary;
for factor=[1 .3 .1]
    if isfile(fullfile(folder,sprintf('synthesis_musyn_B_parametric_B_parametric_band_%g.mat',factor)))
        salaris_relax_performance(factor);
    end
end
m=load(fullfile(d.root,'results/data/m6_lqg_no_integrator.mat'));
A=d.m3.Afull; B=d.m3.Bfull; C=d.m3.CfullMeas; Cq=d.m3.CfullQ;
time=(0:.002:4)'; responses=cell(3,1); rows=zeros(3,4); factors=[.5 1 2];
for j=1:3
    K=lqr(A,B,factors(j)*m.Q,m.R);
    Nr=-(Cq*((A-B*K)\B))\eye(2);
    sys=ss(A-B*K,B*Nr,[Cq;-K],[zeros(2);Nr]);
    reference=zeros(numel(time),2); reference(:,1)=d.m5.spec.referenceAmplitude;
    y=lsim(sys,reference,time); responses{j}=y;
    rows(j,:)=[factors(j),min(-real(eig(A-B*K))),max(abs(y(:,3:4)),[],'all'),sqrt(mean(y(:,3:4).^2,'all'))];
end
qr=struct('time',time,'responses',{responses},'factors',factors,'rows',rows);
save(fullfile(folder,'qr.mat'),'qr','-v7');
writetable(array2table(rows,'VariableNames',{'QMultiplier','MinimumDecay','PeakU','RmsU'}),fullfile(folder,'qr.csv'));
% Modello bianco CONTINUO: campionamento esatto della covarianza, non randn ZOH.
G=m.processNoiseInputMatrix; L=m.L; K=m.K; n=size(A,1);
Aaug=[A -B*K;L*C A-B*K-L*C];
Gaug=blkdiag(G,L); Qaug=Gaug*blkdiag(m.Qn,m.Rn)*Gaug';
[T,Ab]=balance(Aaug); Qb=(T\Qaug)/T'; Pb=lyap(Ab,Qb); Pb=(Pb+Pb')/2;
dt=.01; Phi=expm(Ab*dt); Qd=Pb-Phi*Pb*Phi'; Qd=(Qd+Qd')/2;
[V,D]=eig(Qd); eigenvalues=diag(D);
assert(min(eigenvalues)>-1e-10*norm(Qd),'Salaris:Covariance','Covarianza discreta non positiva.');
noiseFactor=V*diag(sqrt(max(eigenvalues,0)));
rng(20261024,'twister'); count=60001; zb=zeros(2*n,count);
noise=noiseFactor*randn(2*n,count-1);
for j=2:count,zb(:,j)=Phi*zb(:,j-1)+noise(:,j-1);end
tail=(0:count-1)*dt>=60; E=[eye(n) -eye(n)]; Y=[Cq zeros(2,n)];
errors=E*T*zb(:,tail); outputs=Y*T*zb(:,tail);
[~,Pkalman]=lqe(A,G,C,m.Qn,m.Rn);
theoryError=E*T*Pb*T'*E'; empiricalError=cov(errors');
theoryOutput=Y*T*Pb*T'*Y'; empiricalOutput=cov(outputs');
kalman=struct('duration',600,'burnIn',60,'dt',dt,'seed',20261024, ...
    'theoryError',theoryError,'empiricalError',empiricalError, ...
    'theoryOutput',theoryOutput,'empiricalOutput',empiricalOutput, ...
    'riccatiCovariance',Pkalman,'covarianceIdentityError',norm(theoryError-Pkalman,'fro')/norm(Pkalman,'fro'));
assert(kalman.covarianceIdentityError<1e-7,'Salaris:KalmanIdentity','Covarianze teoriche incompatibili.');
save(fullfile(folder,'kalman.mat'),'kalman','-v7');
tab=table(["q1";"q2"],diag(theoryOutput),diag(empiricalOutput), ...
    diag(theoryError(1:2,1:2)),diag(empiricalError(1:2,1:2)), ...
    'VariableNames',{'Coordinate','OutputVarianceTheory','OutputVarianceEmpirical','ErrorVarianceTheory','ErrorVarianceEmpirical'});
writetable(tab,fullfile(folder,'kalman.csv'));
% Controllore a 82 stati del precedente studio sul rumore, mai sovrascritto.
a=load(fullfile(d.root,'results/data/noise_redesign/mu_noise_01.mat'),'candidate'); original=a.candidate.K;
minimal=minreal(original,1e-8);
cancel=table(order(original),order(minimal),norm(original-minimal,inf)/max(norm(original,inf),eps), ...
    'VariableNames',{'OriginalOrder','MinimalOrder','RelativeHinfError'});
writetable(cancel,fullfile(folder,'mu_cancellations.csv'));
a=load(fullfile(folder,'models.mat')); models=a.models; q=d.selected; rows=cell(0,10);
for target=[order(original),70,60]
    if target==order(original),K=original;else,K=balred(original,target);end
    relativeError=norm(original-K,inf)/max(norm(original,inf),eps);
    for j=[1 3]
        file=fullfile(folder,sprintf('mu_reduction_%d_%s.mat',target,models.names(j)));
        if isfile(file)
            a=load(file,'audit'); audit=a.audit;
        else
            cl=salaris_closed_loop(models.plants{j},K,q.W1,q.W2,q.Mo);
            audit=salaris_audit_loop(cl); audit.K=K; audit.CL=cl;
            Gnom=models.plants{j}.NominalValue(1:2,1:2);
            audit.noiseNorm=norm(feedback(K(:,3:4),Gnom,+1),inf);
            save(file,'audit','-v7');
        end
        rows(end+1,:)={target,models.names(j),relativeError,audit.NS,audit.nominalNorm, ...
            audit.RS.LowerBound,audit.RP.LowerBound,min(audit.bandwidth),audit.disturbanceNorm,audit.noiseNorm}; %#ok<AGROW>
        summary=cell2table(rows,'VariableNames',{'Order','Model','RelativeHinfError','NS','NominalNorm', ...
            'RSLower','RPLower','MinimumBandwidth','DisturbanceNorm','NoiseCommandNorm'});
        writetable(summary,fullfile(folder,'mu_reduction.csv'));
    end
end
salaris_check_comparison;
salaris_synthesis_temporal;
salaris_legacy_reduction;
salaris_export;
% Collaudo proporzionato: nuove LFT e regressioni della fisica/attuatori.
protected=preserve_validation_outputs(d.root); %#ok<NASGU> ripristino anche su errore
tests=runtests(fullfile(d.root,'tests',{'salarisModelsTest.m','test_m1_nonlinear_model.m', ...
    'test_m2_equilibrium_linearization.m','test_m3_actuator_dynamics.m','test_m4_uncertainty_model.m'}));
clear protected
writetable(table(tests),fullfile(folder,'final_tests.csv')); assertSuccess(tests);
end
