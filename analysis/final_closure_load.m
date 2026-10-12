function data = final_closure_load
%FINAL_CLOSURE_LOAD Frozen final controllers and physical models, no synthesis.
root=fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(root,'src')),genpath(fullfile(root,'controllers')),genpath(fullfile(root,'analysis')));
folder=fullfile(root,'results/data'); robust=fullfile(folder,'hinf_final_coherent');
m3=load(fullfile(folder,'m3_nominal_actuated_plant.mat'));
m5=load(fullfile(folder,'m5_performance_specs.mat'));
m6=load(fullfile(folder,'m6_lqg_no_integrator.mat'));
m7=load(fullfile(folder,'m7_augmented_cost_feasibility.mat'));
a=load(fullfile(robust,'nominal_study.mat')); study=a.study;
a=load(fullfile(robust,'selected_full_order.mat')); selected=a.selected;
a=load(fullfile(robust,'m13.mat')); synthesis=a.synthesis;
a=load(fullfile(robust,'fixed_PID.mat')); f=a.f;
valid=find(cellfun(@(r)r.valid,f.runs));
[~,best]=min(cellfun(@(r)r.objective,f.runs(valid)));
pidK=f.runs{valid(best)}.K;
K={m6.Klqg,m7.evaluations{m7.config.illustrativeIndex}.Klqgi, ...
    study.one{study.selectedOne}.K,selected.K,pidK,synthesis.K};
names=["LQG","LQGI","Hinf1","Hinf2","PID","Kmu"];
items=struct([]);
for k=1:6
    [Ak,Bk,Ck,Dk]=ssdata(K{k});
    Cm=m3.CfullQ;
    if k<=2, Cm=m3.CfullMeas; end
    item=struct('name',names(k),'K',K{k},'A',Ak,'Br',Bk(:,1:2), ...
        'By',Bk(:,3:end),'C',Ck,'Dr',Dk(:,1:2),'Dy',Dk(:,3:end), ...
        'Cm',Cm,'order',size(Ak,1));
    if k==1
        items=item;
    else
        items(k)=item;
    end
end
data=struct('root',root,'m3',m3,'m5',m5,'controllers',items, ...
    'selected',selected,'physical',study.physical,'study',study, ...
    'seed',20261012,'sigmaY',0.05*pi/180,'sigmaProcess',0.1,'dt',0.002);
end
