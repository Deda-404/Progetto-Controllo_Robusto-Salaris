classdef organicReviewTest < matlab.unittest.TestCase
    %ORGAnICREVIEWTEST Coerenza dei dati e confine degli originali Simulink.
    properties
        Root
    end
    methods(TestClassSetup)
        function paths(t)
            t.Root=fileparts(fileparts(mfilename('fullpath')));
            t.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(t.Root,'simulink')));
        end
    end
    methods(Test)
        function originalFilesUnchanged(t)
            folder=fullfile(t.Root,'simulink/originals');
            m=jsondecode(fileread(fullfile(folder,'manifest.json')));
            files=dir(fullfile(folder,'*.slx'));
            t.verifyEqual(numel(files),6);
            for k=1:numel(m)
                f=fopen(fullfile(folder,m(k).file),'rb');
                bytes=fread(f,inf,'*uint8');fclose(f);
                digest=java.security.MessageDigest.getInstance('SHA-256');
                digest.update(bytes);
                hash=lower(reshape(dec2hex(typecast(digest.digest(),'uint8'),2).',1,[]));
                t.verifyEqual(hash,m(k).sha256);
            end
        end
        function lqgDataSeparateEightAndFourteenStates(t)
            data=setup_original_models("LQG");
            m3=load(fullfile(t.Root,'results/data/m3_nominal_actuated_plant.mat'));
            m6=load(fullfile(t.Root,'results/data/m6_lqg_no_integrator.mat'));
            t.verifySize(data.A,[14 14]);t.verifySize(data.C,[4 14]);
            t.verifySize(data.xbar,[8 1]);t.verifyEqual(data.A,m3.Afull);
            t.verifyEqual(data.K,m6.K);t.verifyEqual(data.L,m6.L);
            t.verifyEqual(data.Nr,m6.Nr);
        end
        function lqgiGainsFromValidatedDesign(t)
            data=setup_original_models("LQGI");
            a=load(fullfile(t.Root,'results/data/m7_augmented_cost_feasibility.mat'));
            d=a.designs{a.config.illustrativeIndex};
            t.verifyEqual(data.Kx,d.Kx);t.verifyEqual(data.Ki,d.Ki);
            t.verifySize(data.Kx,[2 14]);t.verifySize(data.Ki,[2 2]);
        end
        function incompatibleHinfInterfaceIsRejected(t)
            t.verifyError(@()setup_original_models("Hinf"), ...
                'OriginalModels:ControllerInterface');
        end
        function actualNormalizedUncertaintyStructure(t)
            a=load(fullfile(t.Root,'results/data/hinf_final_coherent/m12.mat'));
            t.verifySize(a.audit.Delta,[5 5]);t.verifySize(a.audit.M,[9 9]);
            t.verifyEqual([a.audit.BlkStruct.Occurrences],ones(1,5));
            t.verifyEqual(string({a.audit.BlkStruct.Type}), ...
                ["ultidyn","ultidyn","ureal","ureal","ureal"]);
        end
        function upperLftReconstructsSavedClosedLoop(t)
            a=load(fullfile(t.Root,'results/data/hinf_final_coherent/m12.mat'));
            h=a.audit;reconstructed=lft(h.Delta,h.M);
            w=logspace(-3,4,121);
            t.verifyEqual(freqresp(reconstructed.NominalValue,w), ...
                freqresp(h.CL.NominalValue,w),'AbsTol',1e-8);
        end
        function plottedDkDataAreSavedSolverResults(t)
            a=load(fullfile(t.Root,'results/data/hinf_final_coherent/m13.mat'));
            b=load(fullfile(t.Root,'results/data/organic_review/numeric_audit.mat'));
            t.verifyEqual(b.audit.dk(:,3),[a.synthesis.info.PeakMu]');
            t.verifyEqual(b.audit.dk(:,4),[a.synthesis.info.PeakMuFit]');
            t.verifyEqual(numel(a.synthesis.options.FrequencyGrid),1201);
            t.verifyEqual(a.synthesis.options.MixedMU,'on');
        end
        function failedPerformanceIntervalIsNotReordered(t)
            a=load(fullfile(t.Root,'results/data/hinf_final_coherent/m12.mat'));
            t.verifyGreaterThan(a.audit.RP.LowerBound,a.audit.RP.UpperBound);
            t.verifyLessThan(a.audit.RS.UpperBound,1);
        end
        function validationOutputsRestoredAfterError(t)
            fixture=t.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture);
            names=["results/data/m3_nominal_actuated_plant.mat", ...
                "results/data/m5_performance_specs.mat", ...
                "results/figures/m3_actuator_bode.png", ...
                "results/figures/m3_delay_pade_comparison.png", ...
                "results/figures/m3_full_plant_sigma.png", ...
                "results/figures/m5_spec_frequency_map.png", ...
                "results/figures/m5_weight_W1.png","results/figures/m5_weight_W2.png"];
            for k=1:numel(names)
                file=fullfile(fixture.Folder,names(k));
                folder=fileparts(file);if ~isfolder(folder),mkdir(folder);end
                f=fopen(file,'w');fprintf(f,'originale %d',k);fclose(f);
            end
            t.verifyError(@()localInterruptedValidation(fixture.Folder), ...
                'OrganicReview:ExpectedInterruption');
            for k=1:numel(names)
                t.verifyEqual(fileread(fullfile(fixture.Folder,names(k))), ...
                    sprintf('originale %d',k));
            end
        end
    end
end

function localInterruptedValidation(root)
cleanup=preserve_validation_outputs(root); %#ok<NASGU>
f=fopen(fullfile(root,'results/data/m3_nominal_actuated_plant.mat'),'w');
fprintf(f,'risultato transitorio');fclose(f);
error('OrganicReview:ExpectedInterruption','Interruzione controllata del test.');
end
