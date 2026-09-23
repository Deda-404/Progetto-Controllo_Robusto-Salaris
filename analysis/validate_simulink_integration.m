function summary=validate_simulink_integration
%VALIDATE_SIMULINK_INTEGRATION Bounded implementation checks; no synthesis.
root=fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root,'simulink'));
folder=fullfile(root,'results/data/simulink_integration');
summary=struct('baseCommit','889c0eb46580767d8e6a958fda1af17f0c64658e', ...
 'matlab',version,'date',char(datetime('now')),'checks',struct([]),'controllers',struct([]));
for kind=["LQG","LQRI","Hinf","Kmu"]
 fprintf('VALIDATE %s\n',kind);
 model=char("SEA_"+kind+"_integrated");
 load_system(fullfile(root,'simulink/models',[model '.slx']));
 c=setup_simulink_integration(kind,model,struct('reference',[0;0]));
 set_param(model,'SimulationCommand','update');
 check(kind+" compile",true,0,0);
 % Numerical linearization of the actual Simulink diagram: C*B is the
 % derivative of all physical coordinates under the four process inputs.
 [Al,Bl,Cl,Dl]=linmod(model);
 check(kind+" state count",size(Al,1)==14+size(c.Ak,1),size(Al,1),14+size(c.Ak,1));
 check(kind+" full state output",isequal(size(Cl),[14 size(Al,1)]),size(Cl,1),14);
 if any(kind==["LQG","LQRI"])
  ph=get_param([model '/Gain'],'PortHandles'); line=get_param(ph.Inport(1),'Line');
  source=get_param(get_param(line,'SrcPortHandle'),'Parent');
  check(kind+" estimated feedback",strcmp(source,[model '/Kalman filter']),1,1);
  if kind=="LQRI"
   ph=get_param([model '/Selettore1'],'PortHandles'); line=get_param(ph.Inport(1),'Line');
   source=get_param(get_param(line,'SrcPortHandle'),'Parent');
   check(kind+" measured integral input",strcmp(source,[model '/Sum3']),1,1);
   check(kind+" no Nr block",isempty(find_system(model,'BlockType','Gain','Gain','Nr')),0,0);
  end
 end
 ge=max(abs(Cl*Bl-c.Gw),[],'all');
 check(kind+" Gw physical channels",ge<1e-5 && norm(Dl,'fro')<1e-12,ge,1e-5);
 close_system(model,0);
 eq=simulate_simulink_integration(kind,struct('reference',[0;0],'horizon',.5));
 equilibriumError=max(abs(eq.x_full),[],'all');
 check(kind+" equilibrium",equilibriumError<1e-8,equilibriumError,1e-8);
 small=simulate_simulink_integration(kind,struct('reference',[1e-4;-7e-5],'horizon',3));
 G=simulink_integration_linear_map(c);
 expected=lsim(G,[small.r small.d_ext],small.time);
 eqQ=max(abs(small.dq-expected(:,1:2)),[],'all');
 rmsQ=sqrt(mean((small.dq-expected(:,1:2)).^2,'all'));
 eqU=max(abs(small.u-expected(:,3:4)),[],'all');
 % 1e-4 rad gives negligible nonlinear terms. q tolerance is 0.2% of
 % excitation; u tolerance accounts for stiff direct-feedthrough transients.
 check(kind+" MATLAB Simulink q",eqQ<2e-7,eqQ,2e-7);
 check(kind+" MATLAB Simulink u",eqU<2e-4,eqU,2e-4);
 act=ss(c.Aa,c.Ba,c.Ca,c.Da);
 expectedTau=lsim(act,small.u_abs,small.time,c.xactbar);
 actError=max(abs(small.tau-expectedTau),[],'all');
 check(kind+" actuators M3",actError<2e-4,actError,2e-4);
 item=struct('kind',kind,'equilibriumError',equilibriumError,'GwError',ge, ...
  'maxAbsErrorQ',eqQ,'rmsErrorQ',rmsQ,'maxAbsErrorU',eqU,'actuatorError',actError, ...
  'tracking',[],'noise',[],'kalman',[],'disturbance',[]);
 tracking=cell(2,1);
 for joint=1:2
  ref=zeros(2,1); ref(joint)=5*pi/180;
  tr=simulate_simulink_integration(kind,struct('reference',ref,'horizon',4));
  tracking{joint}=tr;
  final=mean(tr.dq(end-99:end,joint));
  outside=find(abs(tr.dq(:,joint)-final)>.02*ref(joint),1,'last');
  ts=0; if ~isempty(outside), ts=inf; if outside<numel(tr.time), ts=tr.time(outside+1); end; end
  item.tracking(joint,:)=[ts,100*max(0,max(tr.dq(:,joint))/ref(joint)-1), ...
   abs(final/ref(joint)-1),max(abs(tr.dq(:,3-joint)))/max(max(abs(tr.dq(:,joint))),eps), ...
   max(abs(tr.u),[],'all'),sqrt(mean(tr.u.^2,'all'))];
  check(kind+" tracking finite j"+joint,tr.completed,1,1);
 end
 noise=cell(3,1);
 for scenario=1:3
  ov=struct('reference',[0;0],'horizon',.5,'enableMeasurementNoise',scenario~=2, ...
   'enableProcessNoise',scenario~=1);
  noise{scenario}=simulate_simulink_integration(kind,ov);
  check(kind+" noise scenario "+scenario,noise{scenario}.completed,1,1);
 end
 rep=simulate_simulink_integration(kind,noise{3}.config);
 repeatError=max(abs(rep.u-noise{3}.u),[],'all');
 check(kind+" noise repeatability",repeatError==0,repeatError,0);
 item.noise=struct('repeatError',repeatError,'peakU',max(abs(noise{3}.u),[],'all'), ...
  'rmsU',sqrt(mean(noise{3}.u.^2,'all')),'noiseCovariance',cov(noise{3}.v), ...
  'processCovariance',cov(noise{3}.w_process));
 if any(kind==["LQG","LQRI"])
  hat=zeros(14,1); hat(1)=1e-4;
  obs=simulate_simulink_integration(kind,struct('reference',[0;0],'horizon',3,'xhat0',hat));
  err=obs.xhat-obs.x_full;
  item.kalman=struct('initialError',norm(err(1,:)),'finalError',norm(err(end,:)), ...
   'noiselessRMS',sqrt(mean(err.^2,'all')), ...
   'noisyRMS',sqrt(mean((noise{3}.xhat-noise{3}.x_full).^2,'all')));
  check(kind+" Kalman convergence",item.kalman.finalError<1e-6,item.kalman.finalError,1e-6);
  dist=simulate_simulink_integration(kind,struct('reference',[0;0],'horizon',20, ...
   'enableLinkDisturbance',true));
  item.disturbance=struct('errorBefore',mean(dist.dq(dist.time<1,:),1), ...
   'errorAfter',mean(dist.dq(dist.time>=1 & dist.time<2,:),1), ...
   'errorFinal',mean(dist.dq(end-249:end,:),1));
  save(fullfile(folder,char(kind+"_disturbance.mat")),'dist','-v7');
  combo=simulate_simulink_integration(kind,struct('reference',[0;0],'horizon',1.5, ...
   'enableLinkDisturbance',true,'enableMeasurementNoise',true,'enableProcessNoise',true));
  check(kind+" disturbance with noise",combo.completed,1,1);
 end
 if any(kind==["Hinf","Kmu"])
  dist=simulate_simulink_integration(kind,struct('reference',[0;0],'horizon',3, ...
   'enableLinkDisturbance',true));
  item.disturbance=struct('errorBefore',mean(dist.dq(dist.time<1,:),1), ...
   'errorAfter',mean(dist.dq(dist.time>=1 & dist.time<2,:),1), ...
   'errorFinal',mean(dist.dq(end-149:end,:),1));
  check(kind+" link disturbance",dist.completed,1,1);
  save(fullfile(folder,char(kind+"_disturbance.mat")),'dist','-v7');
 end
 if isempty(summary.controllers), summary.controllers=item; else, summary.controllers(end+1)=item; end
 save(fullfile(folder,char(kind+"_runs.mat")),'eq','small','tracking','noise','-v7');
 save(fullfile(folder,'validation.mat'),'summary','-v7');
end
x=summary.controllers;
ratio=norm(x(2).disturbance.errorFinal)/norm(x(1).disturbance.errorFinal);
check("LQRI constant disturbance rejection",ratio<.1,ratio,.1);
summary.passed=all([summary.checks.pass]);
save(fullfile(folder,'validation.mat'),'summary','-v7');
f=fopen(fullfile(folder,'summary.json'),'w'); fprintf(f,'%s',jsonencode(summary,PrettyPrint=true)); fclose(f);
fprintf('SIMULINK: %d/%d checks PASS\n',sum([summary.checks.pass]),numel(summary.checks));
assert(summary.passed,'SimulinkIntegration:Validation','See saved check failures.');
 function check(name,pass,value,tolerance)
  row=struct('name',string(name),'pass',logical(pass),'value',value,'tolerance',tolerance);
  if isempty(summary.checks), summary.checks=row; else, summary.checks(end+1)=row; end; fprintf('%s %s: %.6g (tol %.6g)\n',string(pass),name,value,tolerance);
 end
end


