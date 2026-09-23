function c=setup_simulink_integration(kind,model,overrides)
%SETUP_SIMULINK_INTEGRATION Load frozen artifacts; never synthesize controllers.
root=fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(root,'src')),fullfile(root,'simulink'),fullfile(root,'simulink','models'));
if nargin<2, model=""; end
if nargin<3, overrides=struct; end
m3=load(fullfile(root,'results/data/m3_nominal_actuated_plant.mat'));
m5=load(fullfile(root,'results/data/m5_performance_specs.mat'));
m6=load(fullfile(root,'results/data/m6_lqg_no_integrator.mat'));
m7=load(fullfile(root,'results/data/m7_augmented_cost_feasibility.mat'));
d=m7.designs{m7.config.illustrativeIndex};
c=struct('kind',string(kind),'root',root,'p',m3.mechanicalParams, ...
 'xbar',m3.xbar,'taubar',m3.taubar,'A',m3.Afull,'B',m3.Bfull, ...
 'C',m3.CfullMeas,'Cq',m3.CfullQ,'Bd',m5.BdFull, ...
 'Gw',m6.processNoiseInputMatrix,'Qn',m6.Qn,'Rn',m6.Rn, ...
 'K',m6.K,'Nr',m6.Nr,'L',m6.L,'Kx',d.Kx,'Ki',d.Ki, ...
 'reference',[5*pi/180;0],'referenceTime',0,'disturbance',[.5;0], ...
 'disturbanceTime',1,'enableLinkDisturbance',false, ...
 'enableMeasurementNoise',false,'enableProcessNoise',false, ...
 'noiseStep',.002,'measurementSeeds',[101;211;307;401], ...
 'processSeeds',[503;601;701;809],'horizon',4, ...
 'xMechanical0',m3.xbar,'xhat0',zeros(14,1),'xi0',zeros(2,1));
[c.Aa,c.Ba,c.Ca,c.Da]=ssdata(m3.GactuatorsMimo);
c.xactbar=-c.Aa\(c.Ba*c.taubar); c.xActuator0=c.xactbar;
switch string(kind)
 case "LQG", c.controller=m6.Klqg;
 case "LQRI", c.controller=m7.evaluations{m7.config.illustrativeIndex}.Klqri;
 case "Hinf"
  s=load(fullfile(root,'results/data/hinf_final_coherent/selected_full_order.mat'));
  c.controller=s.selected.K;
 case "Kmu"
  s=load(fullfile(root,'results/data/hinf_final_coherent/m13.mat'));
  c.controller=s.synthesis.K;
 otherwise, error('SimulinkIntegration:Kind','Unknown controller.');
end
[c.Ak,c.Bk,c.Ck,c.Dk]=ssdata(c.controller);
c.xController0=zeros(size(c.Ak,1),1);
f=fieldnames(overrides); for k=1:numel(f), assert(isfield(c,f{k}),'Unknown scenario field'); c.(f{k})=overrides.(f{k}); end
assert(isequal(c.Gw,[c.Bd c.B]));
assert(isequal(size(c.A),[14 14]) && isequal(size(c.C),[4 14]));
if strlength(model)>0
 w=get_param(model,'ModelWorkspace'); assignin(w,'cfg',c);
 for name=["A","B","C","L","K","Nr","Kx","Ki"]
  assignin(w,char(name),c.(name));
 end
 assignin(w,'xbar',c.xbar); assignin(w,'taubar',c.taubar);
 assignin(w,'mechanicalVector',[c.p.m1;c.p.m2;c.p.l1;c.p.l2;c.p.g;c.p.Jm(:);c.p.Bm(:);c.p.Ks(:)]);
end
end
