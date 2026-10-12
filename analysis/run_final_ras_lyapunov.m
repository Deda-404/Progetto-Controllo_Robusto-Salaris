function result = run_final_ras_lyapunov
%RUN_FINAL_RAS_LYAPUNOV Full-state Lyapunov gates and paired nonlinear section.
d=final_closure_load; folder=fullfile(d.root,'results/data/final_closure'); m3=d.m3;
[Aa,Ba,Ca,Da]=ssdata(m3.GactuatorsMimo);
% Same physical initial conditions for every controller, no persistent inputs.
[q1,q2]=ndgrid(deg2rad([-60 -30 0 30 60])); points=[q1(:),q2(:)];
rows=cell(0,14); proofs=cell(6,1); trajectories=cell(6,25); start=1;
checkpoint=fullfile(folder,'ras_lyapunov.mat');
if isfile(checkpoint)
    saved=load(checkpoint,'result');
    if ~isfield(saved.result,'metrics')
        assert(isequal(saved.result.pointsRad,points) && saved.result.horizon==12 && saved.result.tailStart==11, ...
            'FinalRAS:CheckpointProtocol','Checkpoint protocol differs.');
        proofs=saved.result.proofs;trajectories=saved.result.trajectories;rows=saved.result.rows;
        for existing=find(~cellfun(@isempty,proofs))'
            current=final_closure_loop(m3.Afull,m3.Bfull,d.m5.BdFull,m3.CfullQ,d.controllers(existing));
            assert(isequal(proofs{existing}.Acl,current.A),'FinalRAS:CheckpointController','Checkpoint closed-loop matrix differs.');
        end
        start=find(cellfun(@isempty,proofs),1);
        if isempty(start),start=6;end
    end
end
for k=start:6
    cc=d.controllers(k); cl=final_closure_loop(m3.Afull,m3.Bfull,d.m5.BdFull,m3.CfullQ,cc);
    n=size(cl.A,1); [T,Ab]=balance(cl.A); E=zeros(n,2); E(3:4,:)=eye(2);
    Pb=lyap(Ab',eye(n)); Pb=(Pb+Pb')/2;
    residual=norm(Ab'*Pb+Pb*Ab+eye(n),2);
    roundoff=20*n*eps*(2*norm(Ab,2)*norm(Pb,2)+1);
    eigenvalues=eig(Pb); mineig=min(eigenvalues);
    gate=cl.stable && mineig>100*n*eps*norm(Pb,2) && residual+roundoff<1e-6;
    rawP=lyap(cl.A',eye(n)); rawResidual=norm(cl.A'*rawP+rawP*cl.A+eye(n),2);
    % Analytical physical bound is independent of controller gains and coordinates.
    p=m3.mechanicalParams; b=p.m2*p.l1*p.l2;
    inverseM=((p.m1+p.m2)*p.l1^2+2*p.m2*p.l2^2+2*b)/(p.m1*p.m2*p.l1^2*p.l2^2);
    c=inverseM*(b*(1+sqrt(2))/2*norm(m3.Amechanical(3:4,:),2)+sqrt(3)*b+((p.m1+p.m2)*p.g*p.l1+4*p.m2*p.g*p.l2)/6);
    rho=NaN;
    if gate
        radiusSquared=(1-residual-roundoff)/(4*norm(Pb*(T\E),2)*c*norm(T,2)^3);
        rho=mineig*radiusSquared;
    end
    J=zeros(n,2); J(1:2,:)=eye(2); J(5:6,:)=eye(2); Jb=T\J;
    proof=struct('name',cc.name,'n',n,'Acl',cl.A,'balanceTransform',T,'Ab',Ab,'Pb',Pb, ...
        'positiveMinimumEigenvalue',mineig,'conditionP',cond(Pb),'residual',residual, ...
        'roundoffAllowance',roundoff,'rawResidual',rawResidual,'gatePassed',gate, ...
        'rhoCertified',rho,'cPhysical',c,'sectionMatrix',Jb'*Pb*Jb, ...
        'scope','Nominal deterministic SEA with Pade1, unconstrained torque; double precision analytical sufficient bound');
    proofs{k}=proof;
    fprintf('%s Lyapunov n=%d raw residual=%g balanced=%g allowance=%g gate=%d rho=%g\n',cc.name,n,rawResidual,residual,roundoff,gate,rho);
    for j=1:size(points,1)
        z0=J*points(j,:)';
        pointClock=tic;
        options=odeset('RelTol',1e-6,'AbsTol',1e-8,'MaxStep',.01,'Events',@limit);
        status="FINITE_HORIZON_NONCONVERGENT"; converged=false; peakU=NaN; tailQ=NaN; tailTheta=NaN; tailV=NaN; tailVtheta=NaN;
        try
            solver="ode23t";
            if k==5
                solver="ode15s balanced coordinates";
                options=odeset(options,'Jacobian',@balancedJacobian, ...
                    'AbsTol',1e-8./sum(abs(T),1)', 'Events',@balancedLimit);
                [tt,yy]=ode15s(@balancedRhs,(0:.01:12)',T\z0,options);
                zz=yy*T';
            else
                [tt,zz]=ode23t(@rhs,(0:.01:12)',z0,options);
            end
            uu=zz(:,15:end)*cc.C'+(zz(:,1:14)*cc.Cm')*cc.Dy';
            peakU=max(abs(uu),[],'all'); tail=tt>=11;
            if tt(end)<12
                status="NUMERIC_LIMIT_TERMINATION";
            else
                tailQ=max(abs(zz(tail,1:2)),[],'all'); tailTheta=max(abs(zz(tail,5:6)),[],'all');
                tailV=max(abs(zz(tail,3:4)),[],'all'); tailVtheta=max(abs(zz(tail,7:8)),[],'all');
                converged=tailQ<=deg2rad(.5) && tailTheta<=deg2rad(.5) && tailV<=.02 && tailVtheta<=.05;
                if converged,status="CONVERGENT_BY_TAIL_CRITERIA";end
            end
            trajectories{k,j}=struct('time',tt,'state',zz,'control',uu,'status',status,'solver',solver);
        catch err
            status="SOLVER_ERROR";
            if strcmp(err.identifier,'FinalRAS:WallTimeLimit'),status="SOLVER_WALL_TIME_LIMIT";end
            trajectories{k,j}=struct('error',getReport(err,'extended','hyperlinks','off'),'status',status);
        end
        inCertificate=gate && points(j,:)*proof.sectionMatrix*points(j,:)'<=rho;
        rows(end+1,:)={char(cc.name),rad2deg(points(j,1)),rad2deg(points(j,2)),converged,char(status), ...
            peakU,tailQ,tailTheta,tailV,tailVtheta,gate,inCertificate,n,rho}; %#ok<AGROW>
        fprintf('%s common-grid point %d/25: %s\n',cc.name,j,status);
    end
    result=struct('proofs',{proofs},'trajectories',{trajectories},'pointsRad',points,'rows',{rows}, ...
        'horizon',12,'tailStart',11,'wallTimeBudgetPerPoint',60, ...
        'engine','MATLAB ode23t; PID balanced ode15s with mechanical Jacobian; not Simulink');
    save(fullfile(folder,'ras_lyapunov.mat'),'result','-v7');
end
result.metrics=cell2table(rows,'VariableNames',{'Controller','Q1deg','Q2deg','Converged','Status','PeakU', ...
    'TailQ','TailTheta','TailQdot','TailThetadot','LyapunovGate','InsideCertificate','AugmentedStates','RhoCertified'});
writetable(result.metrics,fullfile(folder,'ras_metrics.csv'));
save(fullfile(folder,'ras_lyapunov.mat'),'result','-v7');
    function dz=rhs(~,z)
        if toc(pointClock)>60
            error('FinalRAS:WallTimeLimit','Solver exceeded the 60 s wall time budget; physical convergence remains unknown.');
        end
        x=z(1:14); xc=z(15:end); measurement=cc.Cm*x;
        u=cc.C*xc+cc.Dy*measurement;
        tau=Ca*x(9:14)+Da*u;
        dm=sea_nonlinear_rhs(m3.xbar+x(1:8),m3.taubar+tau,m3.mechanicalParams);
        dz=[dm;Aa*x(9:14)+Ba*u;cc.A*xc+cc.By*measurement];
    end
    function dy=balancedRhs(time,y)
        dy=T\rhs(time,T*y);
    end
    function [value,terminal,direction]=balancedLimit(time,y)
        [value,terminal,direction]=limit(time,T*y);
    end
    function Jac=balancedJacobian(time,y)
        Jac=T\jacobian(time,T*y)*T;
    end
    function [value,terminal,direction]=limit(~,z)
        u=cc.C*z(15:end)+cc.Dy*cc.Cm*z(1:14);
        value=1e6-max(abs([z;u])); terminal=1; direction=-1;
    end
    function Jac=jacobian(time,z)
        Jac=cl.A;
        for coordinate=1:8
            h=1e-6*max(1,abs(z(coordinate)));shift=zeros(n,1);shift(coordinate)=h;
            plus=rhs(time,z+shift);minus=rhs(time,z-shift);
            Jac(1:8,coordinate)=(plus(1:8)-minus(1:8))/(2*h);
        end
    end
end
