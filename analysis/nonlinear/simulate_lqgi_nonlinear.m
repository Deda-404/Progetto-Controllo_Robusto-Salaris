function result=simulate_lqgi_nonlinear(controller,scenario,root,config)
%SIMULATE_LQGI_NONLINEAR SEA originali M1 e servo [xhat(14);xi(2)] M7.
% Feedback esclusivamente stimato; xi integra r-q misurata. Equilibrio
% meccanico/attuativo assoluto, stimatore in deviazione, ingressi ZOH.
persistent savedRoot m3 Aa Ba Ca Da
if isempty(savedRoot) || ~strcmp(savedRoot,root)
    m3=load(fullfile(root,'results/data/m3_nominal_actuated_plant.mat'));
    [Aa,Ba,Ca,Da]=ssdata(m3.GactuatorsMimo); savedRoot=root;
end
assert(controller.order==16 && isequal(size(controller.B),[16,6]), ...
    'LQGI:Interface','Occorrono 14 stati stimati, 2 integrali e ingressi [r;y4].');
defaults=struct('reference',[0 0],'disturbance',[0 0], ...
    'measurementNoise',zeros(1,4),'processNoise',zeros(1,4), ...
    'xMechanical0',m3.xbar,'xActuator0',-Aa\(Ba*m3.taubar), ...
    'xController0',zeros(16,1),'horizon',config.simulation.equilibriumHorizon);
names=fieldnames(defaults);
for j=1:numel(names)
    if ~isfield(scenario,names{j}), scenario.(names{j})=defaults.(names{j}); end
end
inputTime=(0:config.simulation.inputTimeStep:scenario.horizon)';
opts=odeset('RelTol',config.solver.relativeTolerance, ...
    'AbsTol',config.solver.absoluteTolerance,'MaxStep',config.solver.maximumStep, ...
    'Events',@numericLimit);
z0=[scenario.xMechanical0(:);scenario.xActuator0(:);scenario.xController0(:)];
heldIndex=[]; timer=tic;
piecewise=any([size(scenario.reference,1),size(scenario.disturbance,1), ...
    size(scenario.measurementNoise,1),size(scenario.processNoise,1)]>1);
if piecewise
    % La griglia di output non impone al solver di rispettare i salti ZOH.
    % Ogni campione resta costante per tutto il suo intervallo.
    t=inputTime; z=zeros(numel(t),numel(z0));z(1,:)=z0';
    for interval=1:numel(t)-1
        heldIndex=interval;
        [localTime,localState]=ode23t(@rhs,t(interval:interval+1),z(interval,:)',opts);
        z(interval+1,:)=localState(end,:);
        if localTime(end)<t(interval+1)
            t(interval+1)=localTime(end);t=t(1:interval+1);z=z(1:interval+1,:);break
        end
    end
    heldIndex=[];
else
    [t,z]=ode23t(@rhs,inputTime,z0,opts);
end
n=numel(t); r=zeros(n,2); d=r; noise=zeros(n,4); process=noise; u=r; tau=r;
for j=1:n
    [r(j,:),d(j,:),noise(j,:),process(j,:)]=signals(t(j));
    measured=[z(j,1:2)'-m3.xbar(1:2);z(j,5:6)'-m3.xbar(5:6)]+noise(j,:)';
    u(j,:)=(controller.C*z(j,15:end)'+controller.D*[r(j,:)';measured])';
    tau(j,:)=(Ca*z(j,9:14)'+Da*(m3.taubar+u(j,:)'+process(j,3:4)'))';
end
result=struct('completed',t(end)>=scenario.horizon,'time',t, ...
    'xMechanical',z(:,1:8),'xActuator',z(:,9:14),'xController',z(:,15:end), ...
    'reference',r,'disturbance',d,'measurementNoise',noise,'processNoise',process, ...
    'controlDelta',u,'controlAbsolute',u+m3.taubar','motorTorque',tau, ...
    'error',r-(z(:,1:2)-m3.xbar(1:2)')-noise(:,1:2), ...
    'measurementQ',z(:,1:2)-m3.xbar(1:2)'+noise(:,1:2), ...
    'scenario',scenario,'elapsedWallTime',toc(timer),'solver',"MATLAB ode23t", ...
    'controllerID',controller.id,'saturationEnabled',false);
    function dz=rhs(time,state)
        [ref,dist,v,w]=signals(time);
        measured=[state(1:2)-m3.xbar(1:2);state(5:6)-m3.xbar(5:6)]+v';
        input=[ref';measured]; du=controller.C*state(15:end)+controller.D*input;
        % Il rumore di processo non viene fornito allo stimatore come comando.
        ua=m3.taubar+du+w(3:4)'; torque=Ca*state(9:14)+Da*ua;
        dm=sea_nonlinear_rhs_with_link_disturbance(state(1:8),torque,dist'+w(1:2)',m3.mechanicalParams);
        dz=[dm;Aa*state(9:14)+Ba*ua;controller.A*state(15:end)+controller.B*input];
    end
    function [ref,dist,v,w]=signals(time)
        if isempty(heldIndex)
            ix=min(floor((time+10*eps(max(1,time)))/config.simulation.inputTimeStep)+1,numel(inputTime));
        else
            ix=heldIndex;
        end
        ref=localRow(scenario.reference,ix,2); dist=localRow(scenario.disturbance,ix,2);
        v=localRow(scenario.measurementNoise,ix,4); w=localRow(scenario.processNoise,ix,4);
    end
    function [value,terminal,direction]=numericLimit(time,state)
        [ref,~,v,w]=signals(time);
        measured=[state(1:2)-m3.xbar(1:2);state(5:6)-m3.xbar(5:6)]+v';
        du=controller.C*state(15:end)+controller.D*[ref';measured];
        ua=m3.taubar+du+w(3:4)'; torque=Ca*state(9:14)+Da*ua;
        value=config.ras.numericMagnitudeLimit-max(abs([state;du;ua;torque]));
        terminal=1; direction=-1;
    end
end
function value=localRow(data,ix,width)
assert(size(data,2)==width,'LQGI:SignalWidth','Dimensione del segnale esogeno errata.');
value=data(min(ix,size(data,1)),:);
end
