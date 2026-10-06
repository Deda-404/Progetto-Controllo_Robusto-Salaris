function ras=run_lqgi_ras
%RUN_LQGI_RAS Sezione empirica M8, stato stimatore/integratori inizialmente nullo.
root=fileparts(fileparts(mfilename('fullpath')));
data=load(fullfile(root,'results/data/lqgi_validation/validation.mat'));
ras=estimate_m15_robust_ras(data.result.controller,string(root),lqgi_validation_specs);
assert(all(strlength(ras.allPoints.ErrorIdentifier)==0),'LQGI:RASExecution','La ricerca contiene errori di esecuzione.');
save(fullfile(root,'results/data/lqgi_validation/ras.mat'),'ras','-v7');
writetable(ras.allPoints,fullfile(root,'results/data/lqgi_validation/ras_points.csv'));
writetable(ras.boundary,fullfile(root,'results/data/lqgi_validation/ras_boundary.csv'));
disp(ras.metrics);
export_lqgi_validation(data.result,root,ras);
end
