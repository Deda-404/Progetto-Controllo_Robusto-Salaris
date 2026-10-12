function summary = export_final_closure_summary
%EXPORT_FINAL_CLOSURE_SUMMARY Plain numeric evidence for final tables/reports.
d=final_closure_load; folder=fullfile(d.root,'results/data/final_closure');
a=load(fullfile(folder,'noise_diagnostics.mat')); noise=a.result;
numeric=rmfield(noise.diagnostic,{'Tuv','Tqv','Kr','Ky','controllerPoles','closedLoopPoles','omega','sigmaMaxTuv'});
a=load(fullfile(folder,'practical_robustness.mat')); practical=a.result;
a=load(fullfile(folder,'ras_lyapunov.mat')); ras=a.result;
proofs=cellfun(@(p)rmfield(p,{'Acl','balanceTransform','Ab','Pb'}),ras.proofs,'UniformOutput',false);
orders=arrayfun(@(c)c.order,d.controllers);
summary=struct('date','2026-10-12','matlab',version,'orders',orders, ...
    'noise',{numeric},'noiseMetrics',table2struct(noise.metrics), ...
    'noiseSampling',table2struct(noise.sampling),'practicalMetrics',table2struct(practical.metrics), ...
    'practicalPlants',table2struct(practical.plantTable),'lyapunov',{proofs}, ...
    'rasMetrics',table2struct(ras.metrics),'rasHorizon',ras.horizon, ...
    'generalizedOrder',order(d.selected.P),'weightsOrder',[order(d.selected.W1),order(d.selected.W2),order(d.selected.Mo)]);
f=fopen(fullfile(folder,'summary.json'),'w');cleanup=onCleanup(@()fclose(f));
fprintf(f,'%s',jsonencode(summary,PrettyPrint=true));
end
