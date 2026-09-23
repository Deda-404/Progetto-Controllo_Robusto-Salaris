function build_simulink_integration
%BUILD_SIMULINK_INTEGRATION Repair preserved Valerio models through public APIs.
root=fileparts(fileparts(mfilename('fullpath'))); addpath(fullfile(root,'simulink'));
load_system('simulink');
oldPreference=get_param(0,'ErrorIfLoadNewModel');
restorePreference=onCleanup(@() set_param(0,'ErrorIfLoadNewModel',oldPreference));
set_param(0,'ErrorIfLoadNewModel','off');
for kind=["LQG","LQRI","Hinf","Kmu"]
 if kind=="LQG", original='Progetto_LQR_simulink';
 elseif kind=="LQRI", original='Progetto_LQRI_simulink';
 else, original='Progetto_Hinf_simulink'; end
 source=fullfile(root,'simulink/legacy/valerio',[original '.slx']);
 model=char("SEA_"+kind+"_integrated"); target=fullfile(root,'simulink/models',[model '.slx']);
 if bdIsLoaded(model), close_system(model,0); end
 load_system(source); save_system(original,target); if bdIsLoaded(original), close_system(original,0); end; load_system(target);
 c=setup_simulink_integration(kind,model);
 set_param(model,'Solver','ode23t','RelTol','1e-7','AbsTol','1e-9','MaxStep','0.002', ...
  'StopTime','cfg.horizon','ReturnWorkspaceOutputs','on','SignalLogging','on', ...
  'SignalLoggingName','logsout','SaveTime','on','SaveOutput','off', ...
  'InitFcn',"addpath(genpath(fullfile(fileparts(fileparts(fileparts(get_param(bdroot,'FileName')))),'src')));");
 % Keep root layout, selectors, gains, estimator and scopes from the original.
 if kind=="LQG" || kind=="LQRI", ctrl='Sum'; else, ctrl='Controller H-inf'; end
 disconnect(model,'Actuators',1); disconnect(model,'Non linear plant',2);
 disconnect(model,'Sum1',1); disconnect(model,'Sum1',2); disconnect(model,'Sum1',3);
 set_param([model '/Sum1'],'Inputs','+++');
 wire(model,[ctrl '/1'],'Sum1/1'); wire(model,'Constant/1','Sum1/2');

 % One absolute actuator realization, including equilibrium state and logging.
 act=[model '/Actuators']; Simulink.SubSystem.deleteContents(act);
 add_block('simulink/Sources/In1',[act '/u'],'Position',[25 70 55 90]);
 add_block('simulink/Continuous/State-Space',[act '/M3 actuator dynamics'], ...
  'A','cfg.Aa','B','cfg.Ba','C','[cfg.Ca;eye(6)]','D','[cfg.Da;zeros(6,2)]', ...
  'InitialCondition','cfg.xActuator0','Position',[100 60 240 100]);
 add_block('simulink/Signal Routing/Demux',[act '/Torque and states'],'Outputs','[2 6]','Position',[280 60 285 110]);
 add_block('simulink/Sinks/Out1',[act '/tau'],'Position',[345 55 375 75]);
 add_block('simulink/Sinks/Out1',[act '/xact'],'Port','2','Position',[345 105 375 125]);
 wire(act,'u/1','M3 actuator dynamics/1'); wire(act,'M3 actuator dynamics/1','Torque and states/1');
 wire(act,'Torque and states/1','tau/1'); wire(act,'Torque and states/2','xact/1');
 wire(model,'Sum1/1','Actuators/1'); wire(model,'Actuators/1','Non linear plant/2');
 % Preserve the 8-state MATLAB Function; call the existing shared physics.
 plant=[model '/Non linear plant']; charts=sfroot;
 ch=charts.find('-isa','Stateflow.EMChart','Path',[plant '/MATLAB Function']);
 ch.Script=sprintf('function xdot = rhs(x,tau,p,d)\n%%#codegen\ns.m1=p(1);s.m2=p(2);s.l1=p(3);s.l2=p(4);s.g=p(5);\ns.Jm=reshape(p(6:9),2,2);s.Bm=reshape(p(10:13),2,2);s.Ks=reshape(p(14:17),2,2);\nxdot=sea_nonlinear_rhs_with_link_disturbance(x,tau,d,s);\nend\n');
 par=charts.find('-isa','Stateflow.EMChart','Path',[plant '/MATLAB Function1']);
 par.Script=sprintf('function p = parameters\n%%#codegen\np=mechanicalVector;\nend\n');
 data=Stateflow.Data(par); data.Name='mechanicalVector'; data.Scope='Parameter';
 pd=[ch.find('-isa','Stateflow.Data','Name','p');par.find('-isa','Stateflow.Data','Name','p')];
 for jj=1:numel(pd), pd(jj).DataType='double'; pd(jj).Props.Array.Size='[17 1]'; end
 add_block('simulink/Sources/In1',[plant '/d_link'],'Port','3','Position',[25 180 55 200]);
 wire(plant,'d_link/1','MATLAB Function/4');
 disconnect(model,'Integrator',1); delete_block([model '/Sum4']);
 wire(model,'Non linear plant/1','Integrator/1');
 set_param([model '/Integrator'],'InitialCondition','cfg.xMechanical0');
 % Existing measurement selector and subtraction retain [q;theta] ordering.
 set_param([model '/Rumore di misura'],'Mean','zeros(4,1)', ...
  'Variance','diag(cfg.Rn)*double(cfg.enableMeasurementNoise)', ...
  'Seed','cfg.measurementSeeds','SampleTime','cfg.noiseStep');
 if kind=="LQRI", proc='Rumore di proceso'; else
  proc='Rumore di processo'; add_block('simulink/Sources/Random Number',[model '/' proc], ...
   'Position',get_param([model '/Rumore di misura'],'Position')+[0 100 0 100]);
 end
 set_param([model '/' proc],'Mean','zeros(4,1)', ...
  'Variance','diag(cfg.Qn)*double(cfg.enableProcessNoise)', ...
  'Seed','cfg.processSeeds','SampleTime','cfg.noiseStep');
 add_block('simulink/Signal Routing/Demux',[model '/Process channels'], ...
  'Outputs','[2 2]','Position',[750 730 755 790]);
 add_block('simulink/Math Operations/Sum',[model '/Link disturbance'], ...
  'Inputs','++','Position',[810 710 840 740]);
 add_block('simulink/Sources/In1',[model '/Process verification input'],'Port','1','PortDimensions','4','Position',[570 740 600 760]);
 add_block('simulink/Math Operations/Sum',[model '/Process excitation'],'Inputs','++','Position',[680 740 710 770]);
 wire(model,[proc '/1'],'Process excitation/1'); wire(model,'Process verification input/1','Process excitation/2');
 wire(model,'Process excitation/1','Process channels/1'); wire(model,'Process channels/2','Sum1/3');
 wire(model,'Process channels/1','Link disturbance/2');
 wire(model,'Mux1/1','Link disturbance/1'); wire(model,'Link disturbance/1','Non linear plant/3');
 for j=1:2
  if kind=="LQRI", ref=sprintf('r%d (q%d)',j,j); else, ref=sprintf('r%d',j); end
  set_param([model '/' ref],'Time','cfg.referenceTime','Before','0', ...
   'After',sprintf('cfg.reference(%d)',j));
  set_param([model sprintf('/tau_d%d',j)],'Time','cfg.disturbanceTime','Before','0', ...
   'After',sprintf('cfg.disturbance(%d)*double(cfg.enableLinkDisturbance)',j));
 end
 if kind=="LQG" || kind=="LQRI"
  set_param([model '/Kalman filter/Integrator'],'InitialCondition','cfg.xhat0');
  gains=find_system([model '/Kalman filter'],'BlockType','Gain');
  for j=1:numel(gains), set_param(gains{j},'Multiplication','Matrix(K*u)'); end
  set_param([model '/Gain'],'Multiplication','Matrix(K*u)');
  set_param([model '/Gain1'],'Multiplication','Matrix(K*u)');
  logsignal(model,'Kalman filter',1,'xhat');
  if kind=="LQRI"
   disconnect(model,'Selettore1',1); wire(model,'Sum3/1','Selettore1/1');
   set_param([model '/Integrator1'],'InitialCondition','cfg.xi0');
   logsignal(model,'Integrator1',1,'xi');
   add_block('simulink/Sinks/Scope',[model '/Stati integrali'],'Position',[530 200 590 235]);
   wire(model,'Integrator1/1','Stati integrali/1');
  end
 else
  pos=get_param([model '/Sum'],'Position');
  disconnect(model,'Sum',1); disconnect(model,'Sum',2); disconnect(model,'Controller H-inf',1);
  delete_block([model '/Sum']);
  add_block('simulink/Signal Routing/Mux',[model '/Sum'],'Inputs','2','Position',pos);
  wire(model,'Mux/1','Sum/1'); wire(model,'Selettore1/1','Sum/2');
  wire(model,'Sum/1','Controller H-inf/1');
  set_param([model '/Controller H-inf'],'A','cfg.Ak','B','cfg.Bk','C','cfg.Ck','D','cfg.Dk','InitialCondition','cfg.xController0');
  logsignal(model,'Sum',1,'controllerInput');
 end
 % Programmatic signals independent of the educational scopes.
 logsignal(model,'Mux',1,'r'); logsignal(model,ctrl,1,'u');
 logsignal(model,'Sum1',1,'u_abs'); logsignal(model,'Actuators',1,'tau');
 logsignal(model,'Integrator',1,'x_mech'); logsignal(model,'Sum2',1,'delta_x_mech');
 logsignal(model,'Selettore',1,'y_ideal'); logsignal(model,'Sum3',1,'y_mis');
 logsignal(model,'Mux1',1,'d_ext'); logsignal(model,'Link disturbance',1,'d_link_total');
 logsignal(model,proc,1,'w_process'); logsignal(model,'Rumore di misura',1,'v');
 add_block('simulink/Sinks/Terminator',[model '/Actuator state logging'],'Position',[700 280 720 300]);
 wire(model,'Actuators/2','Actuator state logging/1'); logsignal(model,'Actuators',2,'xact');
 selectors={'q_abs','Integrator','[1 2]';'theta_abs','Integrator','[5 6]'; ...
  'dq','Sum2','[1 2]';'dtheta','Sum2','[5 6]'};
 for j=1:size(selectors,1)
  nm=selectors{j,1}; add_block('simulink/Signal Routing/Selector',[model '/' nm], ...
   'InputPortWidth','8','Indices',selectors{j,3},'Position',[1100 700+60*j 1140 730+60*j]);
  add_block('simulink/Sinks/Terminator',[model '/' nm '_log'],'Position',[1200 700+60*j 1220 720+60*j]);
  wire(model,[selectors{j,2} '/1'],[nm '/1']); wire(model,[nm '/1'],[nm '_log/1']); logsignal(model,nm,1,nm);
 end
 if any(kind==["LQG","LQRI"])
  add_block('simulink/Signal Routing/Selector',[model '/Estimated q'], ...
   'InputPortWidth','14','Indices','[1 2]','Position',[360 900 400 935]);
  wire(model,'Kalman filter/1','Estimated q/1');
  add_block('simulink/Sinks/Scope',[model '/Kalman q vs plant q'], ...
   'NumInputPorts','2','Position',[470 910 540 960]);
  wire(model,'Estimated q/1','Kalman q vs plant q/1'); wire(model,'dq/1','Kalman q vs plant q/2');
 end
 add_block('simulink/Sinks/Scope',[model '/Link disturbances'], ...
  'NumInputPorts','2','Position',[930 710 1000 760]);
 wire(model,'Mux1/1','Link disturbances/1'); wire(model,'Link disturbance/1','Link disturbances/2');
 add_block('simulink/Math Operations/Bias',[model '/Actuator deviations'],'Bias','-cfg.xactbar','Position',[760 290 820 320]);
 wire(model,'Actuators/2','Actuator deviations/1');
 add_block('simulink/Signal Routing/Mux',[model '/Full incremental state'],'Inputs','2','Position',[1280 670 1285 730]);
 wire(model,'Sum2/1','Full incremental state/1'); wire(model,'Actuator deviations/1','Full incremental state/2');
 add_block('simulink/Sinks/Out1',[model '/Physical state output'],'Position',[1350 680 1380 700]);
 wire(model,'Full incremental state/1','Physical state output/1'); logsignal(model,'Full incremental state',1,'x_full');
 tidy_simulink_integration(model);
 set_param(model,'SimulationCommand','update');
 save_system(model); fprintf('BUILD PASS %s\n',model); close_system(model,0);
end
end
function disconnect(m,b,p)
h=get_param([m '/' b],'PortHandles'); l=get_param(h.Inport(p),'Line');
if l~=-1, src=get_param(l,'SrcPortHandle'); delete_line(m,src,h.Inport(p)); end
end
function wire(m,s,d)
add_line(m,s,d,'autorouting','on');
end
function logsignal(m,b,p,name)
h=get_param([m '/' b],'PortHandles'); l=get_param(h.Outport(p),'Line');
set_param(l,'Name',name);
set_param(h.Outport(p),'DataLogging','on','DataLoggingNameMode','Custom','DataLoggingName',name);
end







