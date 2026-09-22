function run_hinf_final_pipeline
%RUN_HINF_FINAL_PIPELINE Catena corrente; non sovrascrive i risultati storici.
root=fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(root,'analysis')),genpath(fullfile(root,'controllers')),genpath(fullfile(root,'src')));
folder=fullfile(root,'results','data','hinf_final_coherent');
r=runtests(fullfile(root,'tests','hinfLowerBoundTest.m'));
assert(all([r.Passed]),'HinfFinal:BoundGate','Test lower bound falliti.');
save(fullfile(folder,'lower_bound_tests.mat'),'r');
run_hinf_final_nominal;
run_hinf_final_fixed;
run_hinf_final_robust;
run_hinf_final_nonlinear;
run_hinf_final_noise;
run_hinf_final_ras;
run_hinf_final_lyapunov;
run_hinf_final_monte_carlo;
export_hinf_final_results;
r=runtests({fullfile(root,'tests','hinfFinalCoherenceTest.m'),fullfile(root,'tests','hinfFinalDownstreamTest.m')});
save(fullfile(folder,'coherence_tests.mat'),'r');
assert(all([r.Passed]),'HinfFinal:CoherenceGate','Coerenza della catena fallita.');
end
