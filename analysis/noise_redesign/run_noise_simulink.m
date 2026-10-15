function evidence = run_noise_simulink
% Originali immutati; ogni baseline/candidato ha dati e identita separati.
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(fullfile(root,'simulink')); folder=fullfile(root,'results/data/noise_redesign/simulink');
models=["Hinf_linear_sim","Hinf_nonlinear_sim","mu_linear_sim","mu_nonlinear_sim"];
evidence=cell(4,2);
for j=1:4
    candidate="noise_hinf3";if startsWith(models(j),"mu"),candidate="noise_mu1";end
    choices=["baseline",candidate];
    for k=1:2
        target=fullfile(folder,choices(k));if ~isfolder(target),mkdir(target);end
        file=fullfile(target,models(j)+"_audit.json");
        if isfile(file)
            item=jsondecode(fileread(file));
            assert(strcmp(item.simulation,'SIMULATION PASS') && strcmp(item.dynamic_validation,'DYNAMIC VALIDATION PASS'));
        else
            r=validate_student_originals(true,models(j),choices(k),target); item=r{1};
        end
        assert(strcmp(item.compile,'COMPILE PASS') && strcmp(item.simulation,'SIMULATION PASS') && ...
            strcmp(item.dynamic_validation,'DYNAMIC VALIDATION PASS'),'NoiseSimulink:Run','Run incompleto: %s %s',models(j),choices(k));
        assert(strcmp(item.controller_identity.selection,choices(k)));
        kind=extractBefore(models(j),'_');data=setup_student_originals(kind,choices(k));
        if kind=="Hinf"
            expected=struct('A',data.Ak2,'B',data.Bk2,'C',data.Ck2,'D',data.Dk2);
        else
            [A,B,C,D]=ssdata(data.Kmu);expected=struct('A',A,'B',B,'C',C,'D',D);
        end
        saved=load(fullfile(target,models(j)+"_workspace.mat"),'coefficients');
        assert(isequaln(saved.coefficients,expected),'NoiseSimulink:ControllerIdentity', ...
            'Il checkpoint appartiene a un controllore diverso: %s %s',models(j),choices(k));
        evidence{j,k}=item;
    end
end
save(fullfile(folder,'paired_runs.mat'),'evidence','-v7');
end
