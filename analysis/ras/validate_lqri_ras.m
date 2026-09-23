function search=validate_lqri_ras
%VALIDATE_LQRI_RAS Nominal empirical M7 RAS using unchanged M8 search/criteria.
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(genpath(fullfile(root,'src')),fullfile(root,'simulink'),fullfile(root,'analysis/ras'));
folder=fullfile(root,'results/data/simulink_completion');
if ~isfolder(folder), mkdir(folder); end
config=m8_specs;
config.integrationIdentity=setup_simulink_integration('LQRI');
search=estimate_lqg_ras(string(root),config,"zero-estimate", ...
    @simulate_integrated_ras,string(fullfile(folder,'lqri_ras_checkpoint.mat')));
search.controller='M7 illustrative LQRI';
search.initialConditionDefinition=search.initialConditionDefinition+"; xi0=0";
search.engine='SEA_LQRI_integrated, raw variable-step samples';
search.secondarySectionRun=false;
save(fullfile(folder,'lqri_ras.mat'),'search');
writetable(search.allPoints,fullfile(folder,'lqri_ras_points.csv'));
writetable(search.boundary,fullfile(folder,'lqri_ras_boundary.csv'));
f=fopen(fullfile(folder,'lqri_ras_summary.json'),'w');
fprintf(f,'%s',jsonencode(search.metrics,PrettyPrint=true)); fclose(f);
close_system('SEA_LQRI_integrated',0);
disp(search.metrics);
end
