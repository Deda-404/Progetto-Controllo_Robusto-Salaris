classdef hinfFinalCoherenceTest < matlab.unittest.TestCase
    properties
        Root
        Study
        Robust
    end
    methods(TestClassSetup)
        function loadSources(t)
            t.Root=fileparts(fileparts(mfilename('fullpath')));
            t.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(t.Root,'controllers'),'IncludingSubfolders',true));
            t.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(t.Root,'src'),'IncludingSubfolders',true));
            a=load(fullfile(t.Root,'results','data','hinf_final_coherent','nominal_study.mat')); t.Study=a.study;
            a=load(fullfile(t.Root,'results','data','hinf_final_coherent','robust_study.mat')); t.Robust=a.result;
        end
    end
    methods(Test)
        function oneDofIndependentIdentity(t)
            r=t.Study.one{1};
            t.verifyLessThan(r.audit.plantError,1e-5);
            t.verifyLessThan(r.audit.mapError,1e-5);
            t.verifyLessThan(r.audit.gammaError,.002);
            t.verifyEqual(r.e.norms(1),r.gamma,'RelTol',.002);
        end
        function realTwoDofMaps(t)
            q=t.Study.selected;
            t.verifySize(q.K,[2 4]); t.verifySize(q.P,[8 6]);
            e=hinf_final_evaluate(t.Study.physical,q.K,q.W1,q.W2,q.Mo,t.Study.spec,q.config,q.architecture);
            t.verifyLessThan(max(real(eig(e.Acl))),-1e-8);
            t.verifyEqual(freqresp(lft(q.P,q.K),q.config.omega),freqresp(e.weighted,q.config.omega),'AbsTol',1e-5);
            t.verifyEqual(norm(e.weighted,inf),q.gamma,'RelTol',.002);
        end
        function physicalDisturbanceAndUncertainty(t)
            m4=load(fullfile(t.Root,'results','data','m4_uncertain_plant.mat'));
            m5=load(fullfile(t.Root,'results','data','m5_performance_specs.mat'));
            p=hinf_final_uncertain(m4,m5.BdFull); w=t.Study.config.omega;
            t.verifyEqual(sort(string(fieldnames(p.Uncertainty))),sort(["Delta_act1";"Delta_act2";"Jm1";"k1";"k2"]));
            t.verifyEqual(freqresp(p.NominalValue,w),freqresp(t.Study.physical,w),'AbsTol',1e-7);
            t.verifyEqual(freqresp(p(:,1:2).NominalValue,w),freqresp(m4.GuncQ.NominalValue,w),'AbsTol',1e-7);
        end
        function sameControllerThroughM14(t)
            t.verifyEqual(t.Robust.m12.K,t.Study.selected.K);
            t.verifyEqual(t.Robust.m14.K,t.Robust.m13.K);
            t.verifyEqual(t.Robust.m13.P,t.Robust.P);
            t.verifyEqual(norm(lft(t.Robust.P.NominalValue,t.Robust.m13.K),inf),t.Robust.muEvaluation.norms(1),'RelTol',1e-5);
        end
        function fixedOrderIndependentNorm(t)
            a=load(fullfile(t.Root,'results','data','hinf_final_coherent','fixed_SS2.mat'));
            valid=cellfun(@(r) r.valid && r.e.NP,a.f.runs);
            t.verifyTrue(any(valid)); indices=find(valid); r=a.f.runs{indices(1)};
            t.verifyEqual(order(r.K),2);
            t.verifyLessThan(norm(lft(t.Study.selected.P,r.K),inf),1);
            t.verifyEqual(a.f.sourceK,t.Study.selected.K);
        end
        function originalTargetsRemainFail(t)
            t.verifyFalse(t.Study.selected.e.m5Temporal);
            t.verifyTrue(t.Study.selected.e.revisedTemporal);
            t.verifyEqual(t.Study.spec.settlingTimeTarget,.8);
        end
    end
end
