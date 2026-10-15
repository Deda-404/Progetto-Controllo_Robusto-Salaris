classdef noiseRedesignTest < matlab.unittest.TestCase
    properties
        Root
        Data
    end
    methods(TestClassSetup)
        function loadInputs(t)
            t.Root=fileparts(fileparts(mfilename('fullpath')));
            t.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(t.Root,'analysis/noise_redesign')));
            t.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(t.Root,'simulink')));
            t.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(t.Root,'analysis')));
            t.Data=final_closure_load;
        end
    end
    methods(Test)
        function independentClosedLoopMatchesNoisePorts(t)
            d=t.Data;a=load(fullfile(t.Root,'results/data/noise_redesign/hinf_noise_03.mat'));c=a.candidate;
            G=d.physical(:,1:2);Tuv=feedback(c.K(:,3:4),G,+1);
            expected=[c.W1*G*Tuv;c.W2*Tuv]*c.Wn;
            actual=lft(c.P,c.K);w=logspace(-3,7,301);
            t.verifyLessThan(max(abs(freqresp(actual(:,5:6),w)-freqresp(expected,w)),[],'all'),1e-7);
            t.verifyEqual(order(c.P),22);
        end
        function noiseCannotChangeThePhysicalPlant(t)
            d=t.Data;a=load(fullfile(t.Root,'results/data/noise_redesign/hinf_noise_03.mat'));c=a.candidate;
            w=[.01 1 10 100 1e4];
            t.verifyLessThan(max(abs(freqresp(c.P(7:8,7:8),w)-freqresp(d.physical(:,1:2),w)),[],'all'),1e-8);
            t.verifyEqual(c.W1,d.selected.W1);t.verifyEqual(c.W2,d.selected.W2);t.verifyEqual(c.Mo,d.selected.Mo);
        end
        function baselineAndCandidateSelectionRemainDistinct(t)
            d=t.Data;b=setup_student_originals('mu');c=setup_student_originals('mu','noise_mu1');
            t.verifyEqual(b.Kmu,d.controllers(6).K);t.verifyNotEqual(c.Kmu,b.Kmu);
            t.verifyError(@()validate_student_originals(false,"mu_linear_sim","noise_mu1", ...
                fullfile(t.Root,'results/data/final_simulink_validation')), ...
                'StudentValidation:CandidateOutput');
            t.verifyError(@()run_final_ras_lyapunov(d.controllers(6), ...
                fullfile(t.Root,'results/data/final_closure')), 'FinalRAS:CandidateOutput');
            h=setup_student_originals('Hinf','noise_hinf3');a=load(fullfile(t.Root,'results/data/noise_redesign/hinf_noise_03.mat'));
            [A,B,C,D]=ssdata(a.candidate.K);
            t.verifyEqual(h.Ak2,A);t.verifyEqual(h.Bk2,B);t.verifyEqual(h.Ck2,C);t.verifyEqual(h.Dk2,D);
            t.verifyError(@()setup_student_originals('Hinf','noise_mu1'),'StudentSetup:Selection');
        end
        function improvementsHoldForEveryDeclaredSeed(t)
            a=load(fullfile(t.Root,'results/data/noise_redesign/noise_validation.mat'));m=a.result.metrics;
            for seed=a.result.seeds
                for pair={ {"Hinf2","HinfN3"}, {"Kmu","MuN1"} }
                    names=pair{1};b=m(m.Seed==seed & strcmp(m.Controller,names{1}) & strcmp(m.Scenario,'independent'),:);
                    c=m(m.Seed==seed & strcmp(m.Controller,names{2}) & strcmp(m.Scenario,'independent'),:);
                    t.verifyLessThan(c.IntersamplePeakU,.1*b.IntersamplePeakU);
                    t.verifyLessThan(c.IntegratedRmsU,.1*b.IntegratedRmsU);
                end
            end
            t.verifyEqual(height(m),144);t.verifyLessThan(max(m.QuadratureError),.02);
        end
        function robustCertificatesBelongToTheNewMu(t)
            a=load(fullfile(t.Root,'results/data/noise_redesign/mu_noise_01_robust.mat'));r=a.audit;
            t.verifyTrue(r.new.NS && r.new.NP);t.verifyGreaterThan(r.new.RS.LowerBound,1);t.verifyGreaterThan(r.new.RP.LowerBound,1);
            t.verifyLessThan(r.new.muRSMax(1),1);t.verifyLessThan(r.new.muRPMax(1),1);
            t.verifyEqual(sort(fieldnames(r.new.CL.Uncertainty)),sort({'k1';'k2';'Jm1';'Delta_act1';'Delta_act2'}));
        end
        function pairedSimulinkUsesIdenticalSavedProtocol(t)
            folder=fullfile(t.Root,'results/data/noise_redesign/simulink');a=load(fullfile(folder,'paired_runs.mat'));
            for j=1:4
                b=a.evidence{j,1};c=a.evidence{j,2};
                t.verifyEqual(b.sha256_before,c.sha256_after);t.verifyEqual(b.sha256_before,b.sha256_after);
                t.verifyEqual(b.switches,c.switches);t.verifyEqual(b.solver_configuration,c.solver_configuration);
                t.verifyEqual(b.stop_time,c.stop_time);t.verifyEqual(c.simulation,'SIMULATION PASS');
                t.verifyEqual(c.dynamic_validation,'DYNAMIC VALIDATION PASS');
                t.verifyNotEqual(c.controller_identity.coefficient_hashes,b.controller_identity.coefficient_hashes);
                for item={b,c}
                    record=item{1};name=string(record.name);
                    kind=extractBefore(name,'_');data=setup_student_originals(kind,record.controller_identity.selection);
                    saved=load(fullfile(folder,record.controller_identity.selection,name+"_workspace.mat"),'coefficients');
                    if kind=="Hinf"
                        expected=struct('A',data.Ak2,'B',data.Bk2,'C',data.Ck2,'D',data.Dk2);
                    else
                        [A,B,C,D]=ssdata(data.Kmu);expected=struct('A',A,'B',B,'C',C,'D',D);
                    end
                    t.verifyEqual(saved.coefficients,expected);
                end
            end
        end
        function rasUsesNewFullStateAndPreservesUnknowns(t)
            folder=fullfile(t.Root,'results/data/noise_redesign');a=load(fullfile(folder,'ras/ras_lyapunov.mat'));
            t.verifyEqual(height(a.result.metrics),50);
            files={'hinf_noise_03','mu_noise_01'};
            for j=1:2
                b=load(fullfile(folder,[files{j} '.mat']));p=a.result.proofs{j};
                t.verifyEqual(p.n,14+order(b.candidate.K));
                t.verifyEqual(p.Acl,b.candidate.e.Acl);
                if p.gatePassed
                    t.verifyLessThan(p.residual+p.roundoffAllowance,1e-6);t.verifyGreaterThan(p.rhoCertified,0);
                else
                    t.verifyTrue(isnan(p.rhoCertified));
                end
            end
            unknown=contains(string(a.result.metrics.Status),'NUMERIC') | contains(string(a.result.metrics.Status),'SOLVER');
            t.verifyFalse(any(a.result.metrics.Converged(unknown)));
        end
    end
end
