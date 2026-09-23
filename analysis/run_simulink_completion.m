function run_simulink_completion
%RUN_SIMULINK_COMPLETION Bounded PR33 additions; no controller synthesis.
root=fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(root,'src')),genpath(fullfile(root,'simulink')), ...
    genpath(fullfile(root,'analysis')));
build_linear_common;
validate_linear_common;
validate_lqri_ras;
results=runtests({fullfile(root,'tests/test_simulink_integration.m'), ...
    fullfile(root,'tests/test_simulink_completion.m')});
verification=table(results);
save(fullfile(root,'results/data/simulink_completion/unit_tests.mat'),'verification');
writetable(verification(:,1:5),fullfile(root,'results/data/simulink_completion/unit_tests.csv'));
assertSuccess(results);
export_simulink_completion;
end
