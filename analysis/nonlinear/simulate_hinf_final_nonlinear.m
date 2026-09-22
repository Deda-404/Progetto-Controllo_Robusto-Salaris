function result=simulate_hinf_final_nonlinear(controller,scenario,root,config)
%SIMULATE_HINF_FINAL_NONLINEAR Integrazione MATLAB delle equazioni SEA M1.
% Stati assoluti per meccanica/attuatori; stati incrementali del K 2DoF.
% Stesso ode23t, tolleranze, passo massimo, ingressi ZOH della M15.
persistent savedRoot m3 Aa Ba Ca Da
if isempty(savedRoot) || ~strcmp(savedRoot,root)
    m3=load(fullfile(root,'results','data','m3_nominal_actuated_plant.mat'));
    [Aa,Ba,Ca,Da]=ssdata(m3.GactuatorsMimo); savedRoot=root;
end
defaults=struct('reference',[0 0],'disturbance',[0 0],'measurementNoise',[0 0], ...
    'xMechanical0',m3.xbar,'xActuator0',-Aa\(Ba*m3.taubar), ...
    'xController0',zeros(controller.order,1),'horizon',config.simulation.equilibriumHorizon);
names=fieldnames(defaults);
for j=1:numel(names), if ~isfield(scenario,names{j}), scenario.(names{j})=defaults.(names{j}); end; end
t=(0:config.simulation.inputTimeStep:scenario.horizon)';
opts=odeset('RelTol',config.solver.relativeTolerance,'AbsTol',config.solver.absoluteTolerance, ...
    'MaxStep',config.solver.maximumStep,'Events',@numericLimit);
z0=[scenario.xMechanical0(:);scenario.xActuator0(:);scenario.xController0(:)];
timer=tic; [t,z]=ode23t(@rhs,t,z0,opts);
n=numel(t); r=zeros(n,2); d=r; noise=r; u=r; tau=r;
for j=1:n
    [r(j,:),d(j,:),noise(j,:)]=signals(t(j));
    y=[r(j,:)';z(j,1:2)'-m3.xbar(1:2)+noise(j,:)'];
    u(j,:)=(controller.C*z(j,15:end)'+controller.D*y)';
    tau(j,:)=(Ca*z(j,9:14)'+Da*(m3.taubar+u(j,:)'))';
end
result=struct('completed',t(end)>=scenario.horizon,'time',t,'xMechanical',z(:,1:8), ...
    'xActuator',z(:,9:14),'xController',z(:,15:end),'reference',r,'disturbance',d, ...
    'measurementNoise',noise,'controlDelta',u,'controlAbsolute',u+m3.taubar', ...
    'motorTorque',tau,'error',r-(z(:,1:2)-m3.xbar(1:2)')-noise, ...
    'measurementQ',z(:,1:2)-m3.xbar(1:2)'+noise,'scenario',scenario, ...
    'elapsedWallTime',toc(timer),'solver',"MATLAB ode23t",'controllerID',controller.id);
    function dz=rhs(time,state)
        [ref,dist,nn]=signals(time);
        y=[ref';state(1:2)-m3.xbar(1:2)+nn'];
        du=controller.C*state(15:end)+controller.D*y;
        ua=m3.taubar+du; torque=Ca*state(9:14)+Da*ua;
        dm=sea_nonlinear_rhs_with_link_disturbance(state(1:8),torque,dist',m3.mechanicalParams);
        dz=[dm;Aa*state(9:14)+Ba*ua;controller.A*state(15:end)+controller.B*y];
    end
    function [ref,dist,nn]=signals(time)
        ix=min(floor(time/config.simulation.inputTimeStep)+1,numel(t));
        ref=localRow(scenario.reference,ix); dist=localRow(scenario.disturbance,ix); nn=localRow(scenario.measurementNoise,ix);
    end
    function [value,terminal,direction]=numericLimit(time,state)
        [ref,~,nn]=signals(time);
        du=controller.C*state(15:end)+controller.D*[ref';state(1:2)-m3.xbar(1:2)+nn'];
        ua=m3.taubar+du; torque=Ca*state(9:14)+Da*ua;
        value=config.ras.numericMagnitudeLimit-max(abs([state;du;ua;torque]));
        terminal=1; direction=-1;
    end
end
function value=localRow(data,ix)
if numel(data)==2, value=reshape(data,1,2); else, value=data(min(ix,size(data,1)),:); end
end
