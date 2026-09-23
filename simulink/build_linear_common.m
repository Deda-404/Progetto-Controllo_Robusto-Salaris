function build_linear_common
%BUILD_LINEAR_COMMON One explicit M3 plant, with the four frozen controllers.
root=fileparts(fileparts(mfilename('fullpath')));
model='SEA_linear_common';
if bdIsLoaded(model), close_system(model,0); end
new_system(model);
setup_linear_common('LQG',model);
set_param(model,'Solver','ode23t','RelTol','1e-9','AbsTol','1e-11', ...
    'MaxStep','0.002','StopTime','cfg.horizon','SignalLogging','on');
add_block('simulink/Sources/Step',[model '/Reference'], ...
    'Time','cfg.referenceTime','Before','[0;0]','After','cfg.reference','Position',[30 40 65 70]);
add_block('simulink/Sources/Step',[model '/Link_disturbance'], ...
    'Time','cfg.disturbanceTime','Before','[0;0]', ...
    'After','double(cfg.enableLinkDisturbance)*cfg.disturbance','Position',[270 175 305 205]);
add_block('simulink/Signal Routing/Mux',[model '/Reference_and_measurements'], ...
    'Inputs','2','Position',[135 40 140 130]);
add_block('simulink/Continuous/State-Space',[model '/Frozen_controller'], ...
    'A','cfg.Ak','B','cfg.Bk','C','cfg.Ck','D','cfg.Dk', ...
    'InitialCondition','controllerInitial','Position',[190 40 290 100]);
add_block('simulink/Signal Routing/Mux',[model '/Command_and_link_disturbance'], ...
    'Inputs','2','Position',[350 55 355 195]);
add_block('simulink/Continuous/State-Space',[model '/M3_full_14_states'], ...
    'A','cfg.A','B','[cfg.B cfg.Bd]','C','eye(14)','D','zeros(14,4)', ...
    'InitialCondition','plantInitial','Position',[405 65 520 125]);
add_block('simulink/Math Operations/Gain',[model '/CfullMeas'], ...
    'Gain','cfg.C','Multiplication','Matrix(K*u)','Position',[565 160 650 200]);
add_block('simulink/Math Operations/Gain',[model '/CfullQ'], ...
    'Gain','cfg.Cq','Multiplication','Matrix(K*u)','Position',[565 60 650 100]);
add_block('simulink/Math Operations/Gain',[model '/Controller_measurements'], ...
    'Gain','measurementSelection','Multiplication','Matrix(K*u)', ...
    'Position',[295 255 410 295]);
add_block('simulink/Sinks/Out1',[model '/q'], 'Position',[700 70 730 90]);
add_line(model,'Reference/1','Reference_and_measurements/1');
add_line(model,'Controller_measurements/1','Reference_and_measurements/2','autorouting','on');
add_line(model,'Reference_and_measurements/1','Frozen_controller/1');
add_line(model,'Frozen_controller/1','Command_and_link_disturbance/1');
add_line(model,'Link_disturbance/1','Command_and_link_disturbance/2');
add_line(model,'Command_and_link_disturbance/1','M3_full_14_states/1');
add_line(model,'M3_full_14_states/1','CfullQ/1');
add_line(model,'M3_full_14_states/1','CfullMeas/1','autorouting','on');
add_line(model,'CfullMeas/1','Controller_measurements/1','autorouting','on');
add_line(model,'CfullQ/1','q/1');
blocks={'Reference','Link_disturbance','Frozen_controller','M3_full_14_states','CfullMeas','CfullQ'};
names={'r','d_ext','u','x_full','y_ideal','dq'};
for k=1:numel(blocks)
    p=get_param([model '/' blocks{k}],'PortHandles');
    set_param(p.Outport(1),'DataLogging','on','DataLoggingNameMode','Custom','DataLoggingName',names{k});
end
note=Simulink.Annotation(model,sprintf(['M3: xdot=Afull*x+Bfull*u+BdFull*d\n' ...
    'x = [8 mechanical; 6 actuator] deviations from equilibrium\n' ...
    'y=CfullMeas*x (4), q=CfullQ*x (2)\n' ...
    'setup_linear_common selects LQG / LQRI / Hinf / Kmu; no synthesis.']));
note.Position=[30 340 730 420];
set_param(model,'SimulationCommand','update');
save_system(model,fullfile(root,'simulink/models',[model '.slx']));
close_system(model,0);
end
