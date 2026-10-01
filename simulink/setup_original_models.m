function data = setup_original_models(kind)
%SETUP_ORIGINAL_MODELS Dati MATLAB per i modelli originali, senza modificarli.
% Le variabili sono restituite in una struttura: nessun assegnamento implicito
% al base workspace e nessun salvataggio o ricostruzione di file SLX.
arguments
    kind (1,1) string {mustBeMember(kind,["LQG","LQRI","Hinf"])}
end
root=fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(root,'src')));
m3=load(fullfile(root,'results/data/m3_nominal_actuated_plant.mat'));
m6=load(fullfile(root,'results/data/m6_lqg_no_integrator.mat'));
data=struct('A',m3.Afull,'B',m3.Bfull,'C',m3.CfullMeas, ...
    'L',m6.L,'xbar',m3.xbar,'taubar',m3.taubar,'Gact',m3.GactuatorSiso);
% Il bus e gia dichiarato nei chart originali; qui si fornisce il tipo
% corrispondente alla struttura dei parametri, senza cambiare gli algoritmi.
p=sea_params_nominal; names=fieldnames(p);
elements=repmat(Simulink.BusElement,numel(names),1);
for k=1:numel(names)
    elements(k).Name=names{k}; elements(k).Dimensions=size(p.(names{k}));
    elements(k).DataType='double';
end
data.slBus1=Simulink.Bus; data.slBus1.Elements=elements;
if kind=="LQG"
    data.K=m6.K; data.Nr=m6.Nr;
elseif kind=="LQRI"
    m7=load(fullfile(root,'results/data/m7_augmented_cost_feasibility.mat'));
    design=m7.designs{m7.config.illustrativeIndex};
    data.Kx=design.Kx; data.Ki=design.Ki;
else
    error('OriginalModels:ControllerInterface', ...
        ['Il modello Hinf originale riceve due errori; il controllore ' ...
         'validato riceve [r;q] (quattro ingressi). Occorre intervento manuale.']);
end
assert(isequal(size(data.A),[14 14]) && numel(data.xbar)==8);
end
