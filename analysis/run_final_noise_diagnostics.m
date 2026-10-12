function result = run_final_noise_diagnostics
%RUN_FINAL_NOISE_DIAGNOSTICS Exact ZOH linear tests; original SLX untouched.
d=final_closure_load; m3=d.m3; folder=fullfile(d.root,'results/data/final_closure');
if ~isfolder(folder),mkdir(folder);end
oldRng=rng; cleanup=onCleanup(@()rng(oldRng));
rng(d.seed,'twister'); t=(0:d.dt:4)'; n=numel(t);
v=d.sigmaY*randn(n,4); w=d.sigmaProcess*randn(n,4);
omegaMax=max(cellfun(@(K)max(abs(pole(K))),{d.controllers.K}));
omega=logspace(-2,max(8,ceil(log10(omegaMax))+2),1600);
cases=["clean","measurement","q1","q2","torque","process","all"];
rows=cell(0,9); diagnostic=cell(6,1); runs=cell(6,7);
for k=1:6
    cc=d.controllers(k); ny=size(cc.Cm,1);
    cl=final_closure_loop(m3.Afull,m3.Bfull,d.m5.BdFull,m3.CfullQ,cc);
    assert(cl.stable,'FinalNoise:InternalStability','Nominal loop must be stable.');
    Tuv=cl.noise(3:4,:); Tqv=cl.noise(1:2,:);
    singular=zeros(numel(omega),1);
    response=freqresp(Tuv,omega);
    for j=1:numel(omega), singular(j)=norm(response(:,:,j),2); end
    Dky=cc.Dy; directRmsPerJoint=d.sigmaY*sqrt(sum(Dky.^2,2));
    item=struct('name',cc.name,'order',cc.order,'Dky',Dky, ...
        'directRmsPerJoint',directRmsPerJoint,'directRmsCombined',norm(directRmsPerJoint)/sqrt(2), ...
        'DkyNorm',norm(Dky,2),'controllerMaxRealPole',max(real(eig(cc.A))), ...
        'loopMaxRealPole',max(real(cl.poles)),'controllerPoles',eig(cc.A), ...
        'closedLoopPoles',cl.poles,'AclCondition',cond(cl.A), ...
        'AclNorm',norm(cl.A,2),'omega',omega,'sigmaMaxTuv',singular, ...
        'peakSigma',max(singular),'highFrequencyGain',singular(end), ...
        'controllerFastestPoleMagnitude',max(abs(eig(cc.A))), ...
        'Tuv',Tuv,'Tqv',Tqv,'Kr',cc.K(:,1:2),'Ky',cc.K(:,3:end));
    if ny==2
        % u=Ky(q+v), q=Gu; positive feedback sign is already in Ky.
        G=ss(m3.Afull,m3.Bfull,m3.CfullQ,zeros(2));
        formula=feedback(cc.K(:,3:4),G,+1);
        item.formulaRelativeError=max(abs(freqresp(formula,omega)-response),[],'all')/max(1,max(abs(response),[],'all'));
        assert(item.formulaRelativeError<1e-6,'FinalNoise:Sign','Noise transfer mismatch.');
    else
        item.formulaRelativeError=NaN;
    end
    discrete=c2d(cl.sys,d.dt,'zoh');
    [Tb,Ab]=balance(cl.A);
    balanced=c2d(ss(Ab,Tb\cl.sys.B,cl.sys.C*Tb,cl.sys.D),d.dt,'zoh');
    item.discreteSpectralRadius=max(abs(eig(discrete.A)));
    item.balancedDiscreteSpectralRadius=max(abs(eig(balanced.A)));
    item.zohRelativeAgreement=0;
    for j=1:7
        inputs=zeros(n,8+ny);
        if j==1 || j==7,inputs(t>=0.2,1)=d.m5.spec.referenceAmplitude;end
        if j==2 || j==7, inputs(:,5:4+ny)=v(:,1:ny); end
        if j==3, inputs(:,5)=v(:,1); end
        if j==4, inputs(:,6)=v(:,2); end
        if j==5 || j==7, inputs(t>=1,3)=d.m5.spec.disturbanceTorqueAmplitude; end
        if j==6 || j==7, inputs(:,5+ny:end)=w; end
        [y,~,directState]=lsim(discrete,inputs,t);
        [independent,~,balancedState]=lsim(balanced,inputs,t);
        agreement=max(abs(y-independent),[],'all')/max(1,max(abs(y),[],'all'));
        item.zohRelativeAgreement=max(item.zohRelativeAgreement,agreement);
        assert(agreement<1e-4,'FinalNoise:ZohNumerics','Original/balanced ZOH disagree.');
        runs{k,j}=struct('time',t,'output',y,'inputs',inputs,'scenario',cases(j));
        if j==2
            % A ZOH step contains high frequencies: grid endpoints can miss fast pulses.
            tau=unique([0,logspace(-14,log10(d.dt),440),linspace(0,d.dt,160)]);
            energy=zeros(numel(tau),1); peaks=zeros(numel(tau),1); peakPerInterval=zeros(n-1,1);
            for h=1:numel(tau)
                if tau(h)==0
                    yy=balancedState(1:end-1,:)*balanced.C'+inputs(1:end-1,:)*balanced.D';
                else
                    sub=c2d(ss(Ab,Tb\cl.sys.B,cl.sys.C*Tb,cl.sys.D),tau(h),'zoh');
                    yy=(balancedState(1:end-1,:)*sub.A'+inputs(1:end-1,:)*sub.B')*sub.C'+inputs(1:end-1,:)*sub.D';
                end
                uu=yy(:,3:4); energy(h)=sum(uu.^2,'all'); peaks(h)=max(abs(uu),[],'all');
                peakPerInterval=max(peakPerInterval,max(abs(uu),[],2));
            end
            item.intersampleTau=tau; item.intersamplePeaks=peaks;
            item.intersamplePeakU=max(peaks);
            item.intersampleRmsU=sqrt(trapz(tau,energy)/(2*t(end)));
            coarse=unique([1:2:numel(tau),numel(tau)]);
            coarseRms=sqrt(trapz(tau(coarse),energy(coarse))/(2*t(end)));
            item.intersampleRmsRefinementRelative=abs(coarseRms-item.intersampleRmsU)/max(item.intersampleRmsU,eps);
            assert(item.intersampleRmsRefinementRelative<.02,'FinalNoise:RmsQuadrature','RMS integration has not converged.');
            [~,peakIndex]=max(peaks); item.intersamplePeakDelay=tau(peakIndex);
            if tau(peakIndex)==0
                originalAtPeak=directState(1:end-1,:)*discrete.C'+inputs(1:end-1,:)*discrete.D';
                balancedAtPeak=balancedState(1:end-1,:)*balanced.C'+inputs(1:end-1,:)*balanced.D';
            else
                subOriginal=c2d(cl.sys,tau(peakIndex),'zoh');
                originalAtPeak=(directState(1:end-1,:)*subOriginal.A'+inputs(1:end-1,:)*subOriginal.B')*subOriginal.C'+inputs(1:end-1,:)*subOriginal.D';
                subBalanced=c2d(ss(Ab,Tb\cl.sys.B,cl.sys.C*Tb,cl.sys.D),tau(peakIndex),'zoh');
                balancedAtPeak=(balancedState(1:end-1,:)*subBalanced.A'+inputs(1:end-1,:)*subBalanced.B')*subBalanced.C'+inputs(1:end-1,:)*subBalanced.D';
            end
            item.intersampleRealizationAgreement=max(abs(originalAtPeak-balancedAtPeak),[],'all')/max(1,item.intersamplePeakU);
            assert(item.intersampleRealizationAgreement<1e-4,'FinalNoise:IntersampleNumerics','Coordinate realizations disagree at peak.');
            item.intersamplePeakPerInterval=peakPerInterval;
            item.intersampleScope='Finite logarithmic+uniform scan using exact ZOH state propagation; not rigorous global maximum';
        end
        u=y(:,3:4); tail=t>=2;
        rows(end+1,:)={char(cc.name),char(cases(j)),max(abs(u),[],'all'), ...
            sqrt(mean(u.^2,'all')),sqrt(mean(u(tail,:).^2,'all')), ...
            max(abs(y(:,1:2)),[],'all'),item.directRmsCombined,cc.order,item.loopMaxRealPole}; %#ok<AGROW>
    end
    diagnostic{k}=item;
    fprintf('%s order=%d Dky norm=%g, direct RMS=%g, peak Tuv=%g, intersample peak=%g RMS=%g\n',cc.name,cc.order,item.DkyNorm,item.directRmsCombined,item.peakSigma,item.intersamplePeakU,item.intersampleRmsU);
end
metrics=cell2table(rows,'VariableNames',{'Controller','Scenario','PeakU','RmsU','TailRmsU','PeakQ','DirectRms','Order','MaxRealPole'});
% Hold independent sample variance fixed: sampling changes bandwidth, not sigma.
dtStudy=[0.001;0.002;0.005;0.01]; sampling=cell(0,4);
for k=[4 6]
    cl=final_closure_loop(m3.Afull,m3.Bfull,d.m5.BdFull,m3.CfullQ,d.controllers(k));
    for dt=dtStudy'
        rng(d.seed,'twister'); tt=(0:dt:4)'; nn=d.sigmaY*randn(numel(tt),2);
        yy=lsim(c2d(cl.noise,dt,'zoh'),nn,tt);
        sampling(end+1,:)={char(d.controllers(k).name),dt,max(abs(yy(:,3:4)),[],'all'),sqrt(mean(yy(:,3:4).^2,'all'))}; %#ok<AGROW>
    end
end
samplingTable=cell2table(sampling,'VariableNames',{'Controller','SampleTime','PeakU','RmsU'});
result=struct('diagnostic',[diagnostic{:}],'metrics',metrics,'runs',{runs}, ...
    'seed',d.seed,'sampleTime',d.dt,'sigmaY',d.sigmaY,'sigmaProcess',d.sigmaProcess, ...
    'sampling',samplingTable,'engine','MATLAB exact discrete ZOH; not Simulink');
save(fullfile(folder,'noise_diagnostics.mat'),'result','-v7');
writetable(metrics,fullfile(folder,'noise_metrics.csv'));
writetable(samplingTable,fullfile(folder,'noise_sampling.csv'));
end
