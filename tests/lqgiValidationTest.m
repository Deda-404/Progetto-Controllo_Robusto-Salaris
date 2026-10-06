classdef lqgiValidationTest < matlab.unittest.TestCase
    %LQGIVALIDATIONTEST Segnali reali/stimati, rumore integrato, accordo locale NL.
    properties
        Root
        M3
        Controller
        Config
    end
    methods(TestClassSetup)
        function setup(t)
            t.Root=fileparts(fileparts(mfilename('fullpath')));
            t.applyFixture(matlab.unittest.fixtures.PathFixture(t.Root,'IncludingSubfolders',true));
            t.M3=load(fullfile(t.Root,'results/data/m3_nominal_actuated_plant.mat'));
            data=load(fullfile(t.Root,'results/data/lqgi_validation/validation.mat'));
            t.Controller=data.result.controller; t.Config=lqgi_validation_specs;
        end
    end
    methods(Test)
        function truePlantStateDoesNotLeakIntoInitialCommand(t)
            s=struct('xMechanical0',t.M3.xbar+[.01;-.02;0;0;.01;-.02;0;0], ...
                'xController0',zeros(16,1),'horizon',.02);
            v=simulate_lqgi_nonlinear(t.Controller,s,t.Root,t.Config);
            t.verifyEqual(v.controlDelta(1,:),[0 0],'AbsTol',1e-12);
            t.verifyGreaterThan(max(abs(v.controlDelta(2:end,:)),[],'all'),1e-6);
        end
        function encoderNoiseActuallyEntersIntegral(t)
            s=struct('measurementNoise',[.003,-.004,.001,-.002],'horizon',.002);
            v=simulate_lqgi_nonlinear(t.Controller,s,t.Root,t.Config);
            expected=trapz(v.time,v.error,1);
            t.verifyEqual(v.xController(end,15:16),expected,'AbsTol',1e-8);
            t.verifyGreaterThan(norm(v.xController(end,15:16)),1e-6);
        end
        function nonlinearSmallSignalAgreesWithFullLinearClosure(t)
            s=struct('reference',[deg2rad(.02),0],'horizon',.4);
            v=simulate_lqgi_nonlinear(t.Controller,s,t.Root,t.Config);
            data=load(fullfile(t.Root,'results/data/lqgi_validation/validation.mat'));
            input=zeros(numel(v.time),8); input(:,1)=s.reference(1);
            linear=lsim(data.result.linear.closedLoop,input,v.time);
            discrepancy=v.xMechanical(:,1:2)-t.M3.xbar(1:2)'-linear(:,1:2);
            t.verifyLessThan(max(abs(discrepancy),[],'all'),2e-7);
        end
        function processNoiseIsUnmeasuredPlantInput(t)
            s=struct('processNoise',[.02,-.01,.03,-.02],'horizon',.02);
            v=simulate_lqgi_nonlinear(t.Controller,s,t.Root,t.Config);
            t.verifyEqual(v.controlDelta(1,:),[0 0],'AbsTol',1e-12);
            t.verifyEqual(v.measurementNoise,zeros(numel(v.time),4));
            t.verifyGreaterThan(norm(v.xMechanical(end,:)-t.M3.xbar'),1e-7);
            t.verifyEqual(v.xController(1,:),zeros(1,16));
        end
        function savedValidationPreservesKalmanAndRepeatability(t)
            a=load(fullfile(t.Root,'results/data/lqgi_validation/validation.mat'));
            b=load(fullfile(t.Root,'results/data/m6_lqg_no_integrator.mat'));
            t.verifyEqual(a.result.L,b.L);t.verifyEqual(a.result.Qn,b.Qn);t.verifyEqual(a.result.Rn,b.Rn);
            t.verifyLessThan(a.result.noiseRepeatError,1e-10);
            t.verifyLessThan(a.result.equilibriumError,1e-8);
            t.verifyEqual(numel(a.result.tracking),6);t.verifyEqual(numel(a.result.disturbance),6);
            t.verifyTrue(all(cellfun(@(x)x.simulation.completed,a.result.tracking)));
        end
        function omegaSelectionReproducesActualRanking(t)
            a=load(fullfile(t.Root,'results/data/coherent_review/omegaM_comparison.mat'));
            tab=a.audit.metrics;
            t.verifyEqual(tab.OmegaMRadSec,[2;3;4]);t.verifyEqual(tab.M5Failures,[1;1;1]);
            [~,i]=min(tab.MaximumNormalizedViolation);
            t.verifyEqual(tab.OmegaMRadSec(i),a.audit.selectedOmegaM);
            t.verifyLessThan(tab.WeightedNorm,ones(3,1));t.verifyFalse(a.audit.synthesisRepeated);
        end
        function noisyZohIntegrationAgreesLocallyWithExactLinearHold(t)
            a=load(fullfile(t.Root,'results/data/lqgi_validation/validation.mat'));
            differences=cellfun(@(x)x.maximumQDifferenceNonlinear,a.result.linearNoise);
            % Soglia locale: molto inferiore al gradino di 5 gradi; include
            % non linearita fisica e tolleranze, non richiede identita dei due modelli.
            t.verifyLessThan(max(differences),5e-4);
            for k=2:3
                v=a.result.noise{k}.simulation;
                t.verifyEqual(v.measurementNoise,v.scenario.measurementNoise);
                if k==3,t.verifyEqual(v.processNoise,v.scenario.processNoise);end
            end
        end
    end
end
