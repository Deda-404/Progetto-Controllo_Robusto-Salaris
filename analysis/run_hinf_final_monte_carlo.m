function result=run_hinf_final_monte_carlo
%RUN_HINF_FINAL_MONTE_CARLO Campioni M16 originali, controllori 2DoF correnti.
root=fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(root,'analysis')),genpath(fullfile(root,'controllers')),genpath(fullfile(root,'src')));
folder=fullfile(root,'results','data','hinf_final_coherent');
a=load(fullfile(folder,'selected_full_order.mat')); q=a.selected;
a=load(fullfile(folder,'m13.mat')); Ks={q.K,a.synthesis.K};
m4=load(fullfile(root,'results','data','m4_uncertain_plant.mat'));
m5=load(fullfile(root,'results','data','m5_performance_specs.mat'));
c=monte_carlo_specs_m16;
old=load(fullfile(root,c.artifactPath),'sampledValuesRaw');
replay=generate_m16_uncertainty_samples(m4,c);
assert(isequaln(old.sampledValuesRaw,replay.sampledValues),'HinfFinal:PairedSamples','Campioni diversi dalla baseline.');
result=struct('config',c,'controllers',{Ks},'sampledValues',old.sampledValuesRaw,'runs',{cell(40,2)},'stableCount',[0 0]);
for i=1:40
    physical=build_m16_sampled_physical_plant(m4,m5.Bd,old.sampledValuesRaw(i),c);
    plant=ss(physical.A,[physical.Bcontrol physical.Bdisturbance],physical.Cposition,zeros(2,4));
    for k=1:2
        cc=q.config; cc.time=(0:c.timeStep:c.trackingHorizon)';
        e=hinf_final_evaluate(plant,Ks{k},q.W1,q.W2,q.Mo,m5.spec,cc,q.architecture);
        cc.time=(0:c.timeStep:c.disturbanceHorizon)';
        d=hinf_final_evaluate(plant,Ks{k},q.W1,q.W2,q.Mo,m5.spec,cc,q.architecture);
        e.disturbanceResponses=d.disturbanceResponses; e.disturbanceMetrics=d.disturbanceMetrics;
        e.disturbanceTime=cc.time; e.trackingTime=(0:c.timeStep:c.trackingHorizon)';
        result.runs{i,k}=e; result.stableCount(k)=result.stableCount(k)+e.stable;
    end
    fprintf('M16 paired sample %d/40, stable counts [%d %d]\n',i,result.stableCount);
end
save(fullfile(folder,'monte_carlo_study.mat'),'result','-v7');
end
