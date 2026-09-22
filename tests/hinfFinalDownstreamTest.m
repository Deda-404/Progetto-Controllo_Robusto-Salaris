classdef hinfFinalDownstreamTest < matlab.unittest.TestCase
    properties
        Root
        Controllers
        Config
    end
    methods(TestClassSetup)
        function setup(t)
            t.Root=fileparts(fileparts(mfilename('fullpath')));
            t.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(t.Root,'analysis'),'IncludingSubfolders',true));
            [t.Controllers,t.Config]=hinf_final_nonlinear_setup(t.Root,false);
        end
    end
    methods(Test)
        function localNonlinearMatchesLinearHinf(t)
            t.verifyLocalMap(1);
        end
        function localNonlinearMatchesLinearMu(t)
            t.verifyLocalMap(2);
        end
        function pairedMonteCarloIdentity(t)
            a=t.loadResult('monte_carlo_study.mat');
            old=load(fullfile(t.Root,'results','data','m16_monte_carlo_uncertain_linear.mat'),'sampledValuesRaw');
            t.verifyEqual(a.result.sampledValues,old.sampledValuesRaw);
            t.verifyEqual(a.result.controllers,{t.Controllers(1).K,t.Controllers(2).K});
            t.verifyEqual(a.result.stableCount,[0 40]);
        end
        function nonlinearSourceIdentity(t)
            a=t.loadResult('nonlinear_study.mat');
            t.verifyEqual(a.campaign{1}.K,t.Controllers(1).K);
            t.verifyEqual(a.campaign{2}.K,t.Controllers(2).K);
            t.verifyLessThan(a.campaign{1}.equilibriumError,1e-8);
            t.verifyLessThan(a.campaign{2}.equilibriumError,1e-8);
            t.verifyEqual(numel(a.campaign{1}.tracking),6);
            t.verifyEqual(numel(a.campaign{2}.disturbance),6);
        end
        function lyapunovDoesNotPromoteNumericalFailure(t)
            a=t.loadResult('lyapunov_study.mat');
            t.verifyFalse(a.risultati{1}.validationPassed);
            t.verifyGreaterThan(a.risultati{1}.bound.residualNorm,.1);
            t.verifyTrue(a.risultati{2}.validationPassed);
            t.verifyLessThan(a.risultati{2}.bound.residualNorm,.1);
        end
    end
    methods(Access=private)
        function a=loadResult(t,name)
            a=load(fullfile(t.Root,'results','data','hinf_final_coherent',name));
        end
        function verifyLocalMap(t,k)
            cc=t.Controllers(k); s=struct('reference',[1e-3 0],'horizon',4);
            r=simulate_hinf_final_nonlinear(cc,s,t.Root,t.Config);
            m3=load(fullfile(t.Root,'results','data','m3_nominal_actuated_plant.mat'));
            q=r.xMechanical(:,1:2)-m3.xbar(1:2)';
            expected=lsim(cc.T,repmat(s.reference,numel(r.time),1),r.time);
            t.verifyLessThan(max(abs(q-expected),[],'all'),1e-6);
        end
    end
end
