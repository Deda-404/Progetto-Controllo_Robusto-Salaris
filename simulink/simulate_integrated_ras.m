function result=simulate_integrated_ras(scenario,root,config)
%SIMULATE_INTEGRATED_RAS Raw solver samples, exactly the M8 numerical protocol.
% Controller identity is included in the checkpoint by the caller.
kind=config.integrationIdentity.kind;
model=char("SEA_"+kind+"_integrated");
if ~bdIsLoaded(model)
    load_system(fullfile(root,'simulink/models',[model '.slx']));
end
scenario.reference=[0;0]; scenario.xi0=zeros(2,1);
c=setup_simulink_integration(kind,model,scenario);
out=sim(model,'StopTime',num2str(c.horizon,17), ...
    'Solver',char(config.solver.selected), ...
    'RelTol',num2str(config.solver.relativeTolerance,17), ...
    'AbsTol',num2str(config.solver.absoluteTolerance,17), ...
    'MaxStep',num2str(config.solver.maximumStep,17));
names={'x_mech','xact','xhat','u','tau'};
fields={'xMechanical','xActuator','xhat','control','motorTorque'};
for k=1:numel(names)
    ts=out.logsout.get(names{k}).Values;
    values=double(ts.Data);
    if size(values,1)~=numel(ts.Time), values=reshape(values,[],numel(ts.Time))'; end
    result.(fields{k})=values;
end
result.time=ts.Time;
result.completed=abs(result.time(end)-c.horizon)<1e-8;
if kind=="LQRI"
    signal=out.logsout.get('xi').Values;
    xi=reshape(double(signal.Data),2,[])';
    result.xi=xi;
    % Include the extra integrator in the finite/bounded acceptance gate.
    result.completed=result.completed && all(isfinite(xi),'all') && ...
        max(abs(xi),[],'all')<=config.ras.numericMagnitudeLimit;
end
end
