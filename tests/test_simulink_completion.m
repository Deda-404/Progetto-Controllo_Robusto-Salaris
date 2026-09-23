classdef test_simulink_completion < matlab.unittest.TestCase
    % Additional evidence only: the seven original tests remain unchanged.
    properties
        Root
        Linear
        Ras
    end
    properties(TestParameter)
        kind={'LQG','LQRI','Hinf','Kmu'}
    end
    methods(TestClassSetup)
        function loadEvidence(t)
            t.Root=fileparts(fileparts(mfilename('fullpath')));
            addpath(genpath(fullfile(t.Root,'src')),fullfile(t.Root,'simulink'));
            a=load(fullfile(t.Root,'results/data/simulink_completion/linear_validation.mat'));
            t.Linear=a.summary;
            b=load(fullfile(t.Root,'results/data/simulink_completion/lqri_ras.mat'));
            t.Ras=b.search;
        end
    end
    methods(Test)
        function linearMatlabEquivalence(t,kind)
            i=find(string({t.Linear.controllers.kind})==string(kind));
            t.verifyLessThan(t.Linear.controllers(i).linearErrorsQU(:,1),2e-7);
            t.verifyLessThan(t.Linear.controllers(i).linearErrorsQU(:,2),2e-4);
        end
        function nonlinearSmallSignal(t,kind)
            i=find(string({t.Linear.controllers.kind})==string(kind));
            t.verifyLessThan(t.Linear.controllers(i).nonlinearErrorsQU,[2e-7 2e-4]);
        end
        function actualM3Diagram(t,kind)
            model='SEA_linear_common';
            load_system(fullfile(t.Root,'simulink/models',[model '.slx']));
            t.addTeardown(@() close_system(model,0));
            c=setup_linear_common(kind,model);
            w=get_param(model,'ModelWorkspace');
            plant=[model '/M3_full_14_states'];
            t.verifyEqual(evalin(w,get_param(plant,'A')),c.A);
            t.verifyEqual(evalin(w,get_param(plant,'B')),[c.B c.Bd]);
            t.verifyEqual(evalin(w,get_param(plant,'C')),eye(14));
            t.verifyEqual(evalin(w,get_param([model '/CfullMeas'],'Gain')),c.C);
            t.verifyEqual(evalin(w,get_param([model '/CfullQ'],'Gain')),c.Cq);
            t.verifyEqual(evalin(w,get_param([model '/Frozen_controller'],'A')),c.Ak);
            t.verifyEqual(evalin(w,get_param([model '/Frozen_controller'],'B')),c.Bk);
            t.verifyEqual(evalin(w,get_param([model '/Frozen_controller'],'C')),c.Ck);
            t.verifyEqual(evalin(w,get_param([model '/Frozen_controller'],'D')),c.Dk);
            [A,~,~,~]=linmod(model);
            t.verifySize(A,[14+size(c.Ak,1) 14+size(c.Ak,1)]);
        end
        function rasProtocolUnchanged(t)
            config=m8_specs;
            old=load(fullfile(t.Root,'results/data/m8_lqg_nonlinear_ras.mat'));
            t.verifyEqual(t.Ras.config,config.ras);
            t.verifyEqual(t.Ras.config,old.rasSearchConfig);
            t.verifyEqual(height(t.Ras.boundary),36);
            t.verifyFalse(t.Ras.certifiedRegion);
        end
        function rasNoHiddenExecutionFailure(t)
            t.verifyTrue(all(t.Ras.allPoints.Completed));
            t.verifyTrue(all(t.Ras.allPoints.Finite));
            t.verifyEqual(t.Ras.allPoints.ErrorIdentifier,repmat("",height(t.Ras.allPoints),1));
            t.verifyLessThanOrEqual(t.Ras.metrics.numberSimulations,400);
        end
        function historicalLqgIdentity(t)
            old=load(fullfile(t.Root,'results/data/m8_lqg_nonlinear_ras.mat'));
            c=setup_simulink_integration('LQG');
            t.verifyEqual(old.controllerMetadata.K,c.K);
            t.verifyEqual(old.controllerMetadata.L,c.L);
            t.verifyEqual(old.controllerMetadata.Nr,c.Nr);
        end
    end
end
