function result = validate_noise_candidates
% 1 - Confronti comuni, tre seed, otto scenari, propagazione ZOH esatta.
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(genpath(fullfile(root,'analysis'))); d=final_closure_load;
folder=fullfile(root,'results/data/noise_redesign');
cc=d.controllers([4 6]);
files=["hinf_noise_01","hinf_noise_02","hinf_noise_03","mu_noise_01"];
for j=1:numel(files)
    file=fullfile(folder,files(j)+".mat");
    if ~isfile(file),continue;end
    a=load(file,'candidate'); assert(a.candidate.status=="SYNTHESIZED");
    item=cc(1); item.name=a.candidate.name; item.K=a.candidate.K;
    [item.A,B,item.C,D]=ssdata(item.K); item.Br=B(:,1:2);item.By=B(:,3:4);
    item.Dr=D(:,1:2);item.Dy=D(:,3:4);item.order=order(item.K);
    cc(end+1)=item; %#ok<AGROW>
end
seeds=[20261012 20261013 20261014]; t=(0:d.dt:4)'; n=numel(t);
cases=["clean","q1","q2","independent","correlated","torque","process","all"];
rows=cell(0,10); diagnostics=cell(numel(cc),1); runs=cell(numel(cc),3,8);
for k=1:numel(cc)
    cl=final_closure_loop(d.m3.Afull,d.m3.Bfull,d.m5.BdFull,d.m3.CfullQ,cc(k));
    assert(cl.stable); [Tb,Ab]=balance(cl.A);
    sys=ss(Ab,Tb\cl.sys.B,cl.sys.C*Tb,cl.sys.D); discrete=c2d(sys,d.dt,'zoh');
    omega=logspace(-3,8,2001); response=freqresp(cl.noise(3:4,:),omega);
    gain=arrayfun(@(j)norm(response(:,:,j),2),1:numel(omega));
    formula=feedback(cc(k).K(:,3:4),d.physical(:,1:2),+1);
    agreement=max(abs(freqresp(formula,omega)-response),[],'all')/max(1,max(abs(response),[],'all'));
    assert(agreement<1e-6);
    diag=struct('name',cc(k).name,'order',cc(k).order,'maxRealPole',max(real(cl.poles)), ...
        'DkyNorm',norm(cc(k).Dy),'fastestPole',max(abs(pole(cc(k).K))), ...
        'AclCondition',cond(cl.A),'balancedCondition',cond(Ab),'formulaError',agreement, ...
        'omega',omega,'singular',gain,'noiseHinfNorm',norm(cl.noise(3:4,:),inf), ...
        'highFrequencyGain',gain(end),'quadratureRefinement',0,'coordinateAgreement',0);
    tau=unique([0,logspace(-14,log10(d.dt),440),linspace(0,d.dt,160)]);
    H=cell(numel(tau),1); J=H;
    for h=1:numel(tau)
        if tau(h)==0
            H{h}=sys.C(3:4,:); J{h}=sys.D(3:4,:); continue
        end
        sub=c2d(sys,tau(h),'zoh');
        H{h}=sub.C(3:4,:)*sub.A; J{h}=sub.C(3:4,:)*sub.B+sub.D(3:4,:);
    end
    for seedIndex=1:numel(seeds)
        rng(seeds(seedIndex),'twister'); v=d.sigmaY*randn(n,2); w=d.sigmaProcess*randn(n,4);
        for j=1:numel(cases)
            inputs=zeros(n,10);
            if j==1 || j==8,inputs(t>=.2,1)=d.m5.spec.referenceAmplitude;end
            if j==2,inputs(:,5)=v(:,1);end
            if j==3,inputs(:,6)=v(:,2);end
            if j==4 || j==8,inputs(:,5:6)=v;end
            if j==5,inputs(:,5:6)=v(:,1)*ones(1,2);end
            if j==6 || j==8,inputs(t>=1,3)=d.m5.spec.disturbanceTorqueAmplitude;end
            if j==7 || j==8,inputs(:,7:10)=w;end
            [y,~,x]=lsim(discrete,inputs,t); energy=zeros(numel(tau),1); peaks=energy;
            for h=1:numel(tau)
                u=x(1:end-1,:)*H{h}'+inputs(1:end-1,:)*J{h}';
                energy(h)=sum(u.^2,'all'); peaks(h)=max(abs(u),[],'all');
            end
            rmsIntegrated=sqrt(trapz(tau,energy)/(2*t(end)));
            ix=unique([1:2:numel(tau),numel(tau)]);
            coarse=sqrt(trapz(tau(ix),energy(ix))/(2*t(end)));
            refine=abs(coarse-rmsIntegrated)/max(rmsIntegrated,eps);
            assert(refine<.02); diag.quadratureRefinement=max(diag.quadratureRefinement,refine);
            if j==4 && seedIndex==1
                [~,~,xOriginal]=lsim(c2d(cl.sys,d.dt,'zoh'),inputs,t);
                [~,h]=max(peaks);
                if tau(h)==0, sub=ss(eye(size(cl.A)),zeros(size(cl.sys.B)),cl.sys.C,cl.sys.D,d.dt);
                else, sub=c2d(cl.sys,tau(h),'zoh'); end
                uOriginal=xOriginal(1:end-1,:)*(sub.C(3:4,:)*sub.A)'+inputs(1:end-1,:)*(sub.C(3:4,:)*sub.B+sub.D(3:4,:))';
                uBalanced=x(1:end-1,:)*H{h}'+inputs(1:end-1,:)*J{h}';
                diag.coordinateAgreement=max(abs(uOriginal-uBalanced),[],'all')/max(1,peaks(h));
                assert(diag.coordinateAgreement<1e-4);
            end
            rows(end+1,:)={char(cc(k).name),seeds(seedIndex),char(cases(j)), ...
                max(abs(y(:,3:4)),[],'all'),sqrt(mean(y(:,3:4).^2,'all')), ...
                max(peaks),rmsIntegrated,max(abs(y(:,1:2)),[],'all'),refine,max(real(cl.poles))}; %#ok<AGROW>
            runs{k,seedIndex,j}=struct('t',t,'y',y,'tau',tau,'peaks',peaks,'energy',energy);
        end
    end
    diagnostics{k}=diag;
    fprintf('NOISE DONE %s: norm Tuv=%g, maxRe=%g\n',cc(k).name,diag.noiseHinfNorm,diag.maxRealPole);
end
metrics=cell2table(rows,'VariableNames',{'Controller','Seed','Scenario','SampledPeakU','SampledRmsU', ...
    'IntersamplePeakU','IntegratedRmsU','PeakQ','QuadratureError','MaxRealPole'});
result=struct('controllers',cc,'metrics',metrics,'diagnostics',[diagnostics{:}], ...
    'runs',{runs},'seeds',seeds,'Ts',d.dt,'sigmaY',d.sigmaY,'duration',4, ...
    'peakMeaning','maximum on finite internal-delay scan, not a universal continuous peak', ...
    'rmsMeaning','ZOH quadrature, mean of two commands over 4 s');
save(fullfile(folder,'noise_validation.mat'),'result','-v7');
writetable(metrics,fullfile(folder,'noise_metrics.csv'));
disp(metrics(metrics.Seed==seeds(1) & strcmp(metrics.Scenario,'independent'),:));
end
