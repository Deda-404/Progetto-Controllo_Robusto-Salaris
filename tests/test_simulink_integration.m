classdef test_simulink_integration < matlab.unittest.TestCase
    % Frozen controller identities and saved numerical integration evidence.
    properties
        Root
        Summary
    end
    methods(TestClassSetup)
        function loadEvidence(t)
            t.Root=fileparts(fileparts(mfilename('fullpath')));
            addpath(fullfile(t.Root,'simulink'));
            d=load(fullfile(t.Root,'results/data/simulink_integration/validation.mat'));
            t.Summary=d.summary;
        end
    end
    methods(Test)
        function allNumericalChecks(t)
            t.verifyTrue(t.Summary.passed);
            t.verifyTrue(all([t.Summary.checks.pass]));
        end
        function allFourControllers(t)
            t.verifyEqual(string({t.Summary.controllers.kind}),["LQG","LQRI","Hinf","Kmu"]);
        end
        function lqgArtifactIdentity(t)
            c=setup_simulink_integration('LQG');
            d=load(fullfile(t.Root,'results/data/m6_lqg_no_integrator.mat'));
            t.verifyEqual(c.K,d.K); t.verifyEqual(c.Nr,d.Nr);
            t.verifyEqual(c.L,d.L); t.verifyEqual(c.Qn,d.Qn); t.verifyEqual(c.Rn,d.Rn);
            t.verifyEqual(c.Gw,d.processNoiseInputMatrix);
        end
        function lqriArtifactIdentity(t)
            c=setup_simulink_integration('LQRI');
            d=load(fullfile(t.Root,'results/data/m7_augmented_cost_feasibility.mat'));
            k=d.designs{d.config.illustrativeIndex};
            t.verifyEqual(c.Kx,k.Kx); t.verifyEqual(c.Ki,k.Ki);
            t.verifySize(c.Kx,[2 14]); t.verifySize(c.Ki,[2 2]);
        end
        function hinfArtifactIdentity(t)
            c=setup_simulink_integration('Hinf');
            d=load(fullfile(t.Root,'results/data/hinf_final_coherent/selected_full_order.mat'));
            n=load(fullfile(t.Root,'results/data/hinf_final_coherent/nominal_study.mat'));
            t.verifyEqual(c.controller,d.selected.K);
            t.verifyEqual(c.controller,n.study.selected.K);
            t.verifySize(c.Bk,[22 4]); t.verifySize(c.Ck,[2 22]);
        end
        function muArtifactIdentity(t)
            c=setup_simulink_integration('Kmu');
            d=load(fullfile(t.Root,'results/data/hinf_final_coherent/m13.mat'));
            t.verifyEqual(c.controller,d.synthesis.K);
            t.verifySize(c.Bk,[78 4]); t.verifySize(c.Ck,[2 78]);
        end
        function independentNoiseChannels(t)
            c=setup_simulink_integration('LQG');
            t.verifyEqual(numel(unique([c.measurementSeeds;c.processSeeds])),8);
            t.verifySize(c.Rn,[4 4]); t.verifySize(c.Gw,[14 4]);
        end
    end
end
