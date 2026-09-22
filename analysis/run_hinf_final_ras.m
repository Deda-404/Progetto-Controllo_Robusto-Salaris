function results=run_hinf_final_ras
%RUN_HINF_FINAL_RAS Stessi punti, budget, criteri e orizzonti della M15.
root=fileparts(fileparts(mfilename('fullpath')));
[controllers,config]=hinf_final_nonlinear_setup(root,false);
config.simulatorFcn=@simulate_hinf_final_nonlinear;
assert(numel(controllers)==2,'HinfFinal:MissingMu','Occorre completare M13.');
folder=fullfile(root,'results','data','hinf_final_coherent'); results=cell(2,1);
for k=1:2
    controller=controllers(k); file=fullfile(folder,"ras_"+controller.id+".mat");
    if isfile(file)
        a=load(file); assert(isequaln(a.controller.K,controller.K)); search=a.search;
    else
        search=estimate_m15_robust_ras(controller,string(root),config);
        save(file,'search','controller','-v7');
    end
    results{k}=search;
end
save(fullfile(folder,'ras_study.mat'),'results','-v7');
end
