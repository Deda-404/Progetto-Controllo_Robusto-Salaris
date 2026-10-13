function evidence = run_final_student_validation(runRegression,reuseRecordedRuns)
%RUN_FINAL_STUDENT_VALIDATION Fail on incomplete required validation.
arguments
    runRegression (1,1) logical = true
    reuseRecordedRuns (1,1) logical = false
end
root=fileparts(fileparts(mfilename('fullpath')));
addpath(root,fullfile(root,'tools'),fullfile(root,'simulink'));
evidence=probe_final_environment;
required={'load_system','sim','ss','lqr','hinfsyn','musyn'};
available=all(cellfun(@(name)~isempty(evidence.functions.(name)),required));
assert(available,'FinalValidation:Environment','Required products are not installed. See environment JSON.');
assert(~verLessThan('simulink','26.1'),'FinalValidation:Release','Original models require R2026a or newer.');
if runRegression
    setenv('CR_RUN_SCOPE','verify');run_all;
    verify_four_final_scripts;
end
if reuseRecordedRuns
    evidence=finalize_student_validation;
    return
end
results=validate_student_originals(true);
evidence.models=[results{:}];
export_student_schemes;
folder=fullfile(root,'results/data/final_simulink_validation');
f=fopen(fullfile(folder,'final_runner.json'),'w');cleanup=onCleanup(@()fclose(f));
fprintf(f,'%s',jsonencode(evidence,PrettyPrint=true));
assert(all(strcmp({evidence.models.compile},'COMPILE PASS')) && ...
    all(strcmp({evidence.models.simulation},'SIMULATION PASS')), ...
    'FinalValidation:Runtime','One or more required model runs failed; see individual audits.');
assert(all(strcmp({evidence.models.dynamic_validation},'DYNAMIC VALIDATION PASS')), ...
    'FinalValidation:Signals','Dynamic review of recorded positions, commands and references is incomplete.');
end
