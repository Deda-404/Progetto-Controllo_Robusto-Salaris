function salaris_simulations
%SALARIS_SIMULATIONS Dieci impianti fisici e dieci condizioni iniziali.
d=final_closure_load; q=d.selected; folder=fullfile(d.root,'results/data/salaris_revision');
a=load(fullfile(folder,'models.mat')); models=a.models;
rng(20261024,'twister'); samples=2*rand(10,9)-1;
rows=cell(0,8); traces=cell(10,6); time=(0:.005:12)';
for j=1:10
    v=samples(j,:); plant=models.plants{3}; p=sea_params_nominal;
    plant=usubs(plant,'k1',p.Ks(1,1)*(1+.1*v(1)), ...
        'k2',p.Ks(2,2)*(1+.1*v(2)),'Jm1',p.Jm(1,1)*(1+.1*v(3)), ...
        'dwn1',v(4),'dzeta1',v(5),'dtau1',v(6),'Dres1',0, ...
        'dwn2',v(7),'dzeta2',v(8),'dtau2',v(9),'Dres2',0);
    for k=1:6
        cl=salaris_closed_loop(plant,d.controllers(k).K,q.W1,q.W2,q.Mo);
        stable=isstable(cl); ts=NaN; peakQ=NaN; peakU=NaN; dcError=NaN;
        if stable
            u=zeros(numel(time),4); u(:,1)=d.m5.spec.referenceAmplitude;
            y=lsim(cl,u,time); traces{j,k}=y(:,1:4);
            target=dcgain(cl(1,1))*d.m5.spec.referenceAmplitude;
            bad=find(abs(y(:,1)-target)>.02*d.m5.spec.referenceAmplitude,1,'last');
            ts=0; if ~isempty(bad),ts=Inf;if bad<numel(time),ts=time(bad+1);end,end
            dcError=abs(target/d.m5.spec.referenceAmplitude-1);
            u=zeros(numel(time),4); u(time>=1,3)=d.m5.spec.disturbanceTorqueAmplitude;
            yd=lsim(cl,u,time); peakQ=max(abs(yd(:,1:2)),[],'all');
            peakU=max(abs(yd(:,3:4)),[],'all');
        end
        rows(end+1,:)={j,d.controllers(k).name,stable,ts,dcError,peakQ,peakU,max(real(pole(cl)))}; %#ok<AGROW>
    end
end
metrics=cell2table(rows,'VariableNames',{'Plant','Controller','Stable','SettlingTime','RelativeDCError', ...
    'DisturbancePeakRad','DisturbancePeakTorque','MaxRealPole'});
writetable(metrics,fullfile(folder,'physical_samples_metrics.csv'));
writematrix(samples,fullfile(folder,'physical_normalized_samples.csv'));
save(fullfile(folder,'physical_samples.mat'),'samples','metrics','traces','time','-v7');
% Sezione: Delta theta = Delta q, velocita nulle. Coordinate assolute = xbar+x.
points=deg2rad([0 0;5 0;15 0;30 0;0 5;0 15;0 30;15 15;-15 -15;30 -30]);
epsilon=deg2rad(.5); rows=cell(0,8); trajectories=cell(6,10);
[Aa,Ba,Ca,Da]=ssdata(d.m3.GactuatorsMimo);
for k=1:6
    cc=d.controllers(k); cl=final_closure_loop(d.m3.Afull,d.m3.Bfull,d.m5.BdFull,d.m3.CfullQ,cc);
    [T,Ab]=balance(cl.A); pointClock=tic;
    for j=1:10
        z0=zeros(size(cl.A,1),1); z0([1 2 5 6])=repmat(points(j,:)',2,1);
        status="COMPLETED"; converged=false; J=NaN; peakU=NaN;
        pointClock=tic;
        try
            options=odeset('RelTol',1e-6,'AbsTol',1e-9./max(sum(abs(T),1)',eps),'MaxStep',.02);
            [tt,yy]=ode15s(@rhs,time,T\z0,options); zz=yy*T';
            assert(tt(end)==time(end),'Salaris:IncompleteIntegration','Integrazione incompleta: convergenza ignota.');
            linear=initial(ss(Ab,zeros(size(Ab,1),1),[d.m3.CfullQ zeros(2,cc.order)]*T,zeros(2,1)),T\z0,tt);
            J=max(abs(zz(:,1:2)-linear),[],'all');
            tail=tt>=11;
            converged=tt(end)==12 && max(abs(zz(tail,[1 2 5 6])),[],'all')<=epsilon && ...
                max(abs(zz(tail,[3 4 7 8])),[],'all')<=.02;
            uu=zz(:,15:end)*cc.C'+zz(:,1:14)*cc.Cm'*cc.Dy'; peakU=max(abs(uu),[],'all');
            trajectories{k,j}=struct('time',tt,'qNL',zz(:,1:2),'qLIN',linear,'u',uu);
        catch err
            status=string(err.identifier); trajectories{k,j}=struct('error',getReport(err));
        end
        rows(end+1,:)={cc.name,rad2deg(points(j,1)),rad2deg(points(j,2)),converged,J,J<=epsilon,peakU,status}; %#ok<AGROW>
        fprintf('RAS %s %d/10: %s convergenza=%d J=%g\n',cc.name,j,status,converged,J);
    end
end
metrics=cell2table(rows,'VariableNames',{'Controller','Q1deg','Q2deg','Converged','Jrad','WithinEpsilon','PeakTorque','Status'});
writetable(metrics,fullfile(folder,'ras_metrics.csv'));
save(fullfile(folder,'ras.mat'),'metrics','trajectories','points','epsilon','time','-v7');
    function dy=rhs(~,y)
        if toc(pointClock)>45,error('Salaris:SolverTimeout','Convergenza ignota: limite numerico 45 s.');end
        z=T*y; x=z(1:14); xc=z(15:end);
        command=cc.C*xc+cc.Dy*cc.Cm*x;
        torque=Ca*x(9:14)+Da*command;
        dm=sea_nonlinear_rhs(d.m3.xbar+x(1:8),d.m3.taubar+torque,d.m3.mechanicalParams);
        dy=T\[dm;Aa*x(9:14)+Ba*command;cc.A*xc+cc.By*cc.Cm*x];
    end
end
