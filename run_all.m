function run_all
%RUN_ALL Verifica degli artifact senza sintesi o ricostruzione dei modelli.
projectRoot=fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(projectRoot,'src')), ...
    genpath(fullfile(projectRoot,'controllers')), ...
    genpath(fullfile(projectRoot,'analysis')),fullfile(projectRoot,'simulink'));
scope=getenv('CR_RUN_SCOPE');
if isempty(scope) || strcmp(scope,'verify')
    names={'test_m1_nonlinear_model.m','test_m2_equilibrium_linearization.m', ...
        'test_m3_actuator_dynamics.m','test_m4_uncertainty_model.m', ...
        'test_m5_performance_specs.m','test_m6_lqg_no_integrator.m', ...
        'test_m7_lqg_integral.m','hinfLowerBoundTest.m', ...
        'hinfFinalCoherenceTest.m','hinfFinalDownstreamTest.m', ...
        'organicReviewTest.m','lqgiValidationTest.m','finalClosureTest.m'};
    preserveOutputs=preserve_validation_outputs(projectRoot); %#ok<NASGU> cleanup su errore
    testResults=runtests(fullfile(projectRoot,'tests',names));
    clear preserveOutputs
    verification=table(testResults);
    folder=fullfile(projectRoot,'results/data/coherent_review');
    if ~isfolder(folder),mkdir(folder);end
    save(fullfile(folder,'matlab_tests.mat'),'verification');
    writetable(verification(:,1:5),fullfile(folder,'matlab_tests.csv'));
    assertSuccess(testResults);
elseif strcmp(scope,'salaris')
    run_salaris_revision('all');
elseif strcmp(scope,'originals')
    validate_student_originals(false);
elseif strcmp(scope,'closure')
    run_final_noise_diagnostics;
    run_practical_robustness;
    run_final_ras_lyapunov;
    export_final_closure_summary;
    export_final_closure_figures;
elseif strcmp(scope,'closure_export')
    export_final_closure_summary;
    export_final_closure_figures;
elseif strcmp(scope,'export')
    export_organic_audit;
    export_hinf_readable_figures;
    data=load(fullfile(projectRoot,'results/data/lqgi_validation/validation.mat'));
    savedRas=load(fullfile(projectRoot,'results/data/lqgi_validation/ras.mat'));
    export_lqgi_validation(data.result,projectRoot,savedRas.ras);
else
    error('RunAll:Scope','Usare verify, salaris, originals, closure, closure_export oppure export.');
end
end
