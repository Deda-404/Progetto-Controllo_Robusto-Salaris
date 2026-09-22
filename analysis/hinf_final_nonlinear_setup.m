function [controllers,config]=hinf_final_nonlinear_setup(root,buildModel)
%HINF_FINAL_NONLINEAR_SETUP Controllori correnti e criteri M15, ingressi [r;q].
if nargin<2, buildModel=false; end
addpath(genpath(fullfile(root,'controllers')),genpath(fullfile(root,'src')),genpath(fullfile(root,'analysis')),fullfile(root,'simulink'));
folder=fullfile(root,'results','data','hinf_final_coherent');
a=load(fullfile(folder,'selected_full_order.mat')); q=a.selected;
a=load(fullfile(folder,'nominal_study.mat')); study=a.study;
Ks={q.K}; ids="HinfFinal";
if isfile(fullfile(folder,'m13.mat'))
    a=load(fullfile(folder,'m13.mat')); Ks{2}=a.synthesis.K; ids(2)="MuFinal";
end
controllers=struct([]);
for k=1:numel(Ks)
    K=Ks{k}; [A,B,C,D]=ssdata(K);
    e=hinf_final_evaluate(study.physical,K,q.W1,q.W2,q.Mo,study.spec,q.config,q.architecture);
    item=struct('id',ids(k),'K',K,'A',A,'B',B,'C',C,'D',D,'order',order(K), ...
        'T',e.T,'KS',e.UR,'disturbanceQ',e.QD,'disturbanceU',e.UD,'evaluation',e);
    if k==1, controllers=item; else, controllers(k)=item; end
end
config=m15_specs; config.simulationEngine="MATLAB ode23t";
assert(~buildModel,'Questa revisione usa integrazione MATLAB.');
end
