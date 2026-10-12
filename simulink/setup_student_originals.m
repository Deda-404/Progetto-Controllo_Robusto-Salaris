function data = setup_student_originals(kind)
%SETUP_STUDENT_ORIGINALS External workspace data for unchanged student models.
arguments
    kind (1,1) string {mustBeMember(kind,["LQG","LQGI","Hinf","mu"])}
end
root=fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root,'analysis'),fullfile(root,'File_di_Funzioni_Progetto-Accorpati'),'-begin');
d=final_closure_load; m3=d.m3;
m6=load(fullfile(root,'results/data/m6_lqg_no_integrator.mat'));
m7=load(fullfile(root,'results/data/m7_augmented_cost_feasibility.mat'));
servo=m7.designs{m7.config.illustrativeIndex};
data=struct('A',m3.Afull,'B',m3.Bfull,'C',m3.CfullMeas,'D',zeros(4,2), ...
    'Aplant',m3.Afull,'Bplant',[m3.Bfull,d.m5.BdFull,d.m5.BdFull,m3.Bfull], ...
    'Cplant',m3.CfullMeas,'Dplant',zeros(4,8),'x0plant',zeros(14,1), ...
    'K',m6.K,'Nr',m6.Nr,'L',m6.L,'Kx',servo.Kx,'Ki',servo.Ki, ...
    'xbar',m3.xbar,'taubar',m3.taubar,'Gact',m3.GactuatorSiso);
one=d.study.one{d.study.selectedOne}.Kfeedback;
[data.Ak1,data.Bk1,data.Ck1,data.Dk1]=ssdata(one);
[data.Ak2,data.Bk2,data.Ck2,data.Dk2]=ssdata(d.controllers(4).K);
data.Kpid=d.controllers(5).K; data.Kmu=d.controllers(6).K;
% Explicit bus type for the embedded nominal-parameter function; no model edit.
p=sea_params_nominal; fields=fieldnames(p);
elements=repmat(Simulink.BusElement,numel(fields),1);
for k=1:numel(fields)
    elements(k).Name=fields{k}; elements(k).Dimensions=size(p.(fields{k})); elements(k).DataType='double';
end
data.slBus1=Simulink.Bus; data.slBus1.Elements=elements;
assert(isequal(size(data.Aplant),[14 14]) && isequal(size(data.Bplant),[14 8]));
assert(isequal(size(data.Bk1,2),2) && isequal(size(data.Bk2,2),4));
switch kind
    case "LQG"
        assert(isequal(size(data.K),[2 14]) && isequal(size(data.L),[14 4]));
    case "LQGI"
        assert(isequal(size(data.Kx),[2 14]) && isequal(size(data.Ki),[2 2]));
    case "Hinf"
        assert(isequal(size(data.Kpid),[2 4]));
    case "mu"
        assert(isequal(size(data.Kmu),[2 4]));
end
end
