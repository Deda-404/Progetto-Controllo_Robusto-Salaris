classdef finalClosureTest < matlab.unittest.TestCase
    %FINALCLOSURETEST Scientific boundaries and immutable student artifacts.
    properties
        Data
    end
    properties(TestParameter)
        controllerIndex=struct('LQG',1,'LQGI',2,'Hinf1',3,'Hinf2',4,'PID',5,'Kmu',6)
        modelName=struct('LQGlinear',"LQG_linear_sim.slx",'LQGnonlinear',"LQG_nonlinear_sim.slx", ...
            'LQGIlinear',"LQGI_linear_sim.slx",'LQGInonlinear',"LQGI_nonlinear_sim.slx", ...
            'Hinflinear',"Hinf_linear_sim.slx",'Hinfnonlinear',"Hinf_nonlinear_sim.slx", ...
            'Mulinear',"mu_linear_sim.slx",'Munonlinear',"mu_nonlinear_sim.slx")
        setupKind=struct('LQG',"LQG",'LQGI',"LQGI",'Hinf',"Hinf",'mu',"mu")
    end
    methods(TestClassSetup)
        function loadData(t)
            root=fileparts(fileparts(mfilename('fullpath')));
            t.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(root,'analysis')));
            t.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(root,'simulink')));
            t.Data=final_closure_load;
        end
    end
    methods(Test)
        function immutableModels(t,modelName)
            manifest=jsondecode(fileread(fullfile(t.Data.root,'simulink/student_originals_manifest.json')));
            record=manifest.models(strcmp({manifest.models.name},modelName));
            f=fopen(fullfile(t.Data.root,record.relative_path),'rb');cleanup=onCleanup(@()fclose(f));
            bytes=fread(f,Inf,'*uint8');digest=java.security.MessageDigest.getInstance('SHA-256');digest.update(bytes);
            hash=lower(reshape(dec2hex(typecast(digest.digest(),'uint8'),2).',1,[]));
            t.verifyEqual(hash,record.sha256_source);
            t.verifyEqual(hash,record.sha256_imported);
            t.verifyEqual(hash,record.sha256_post_validation);
        end
        function nominalInternalStability(t,controllerIndex)
            d=t.Data;cl=final_closure_loop(d.m3.Afull,d.m3.Bfull,d.m5.BdFull,d.m3.CfullQ,d.controllers(controllerIndex));
            t.verifyLessThan(max(real(cl.poles)),-1e-8);
            t.verifyEqual(size(cl.A,1),14+d.controllers(controllerIndex).order);
        end
        function independentNoiseFeedbackSign(t,controllerIndex)
            d=t.Data;cc=d.controllers(controllerIndex);
            cl=final_closure_loop(d.m3.Afull,d.m3.Bfull,d.m5.BdFull,d.m3.CfullQ,cc);
            G=ss(d.m3.Afull,d.m3.Bfull,cc.Cm,zeros(size(cc.Cm,1),2));
            formula=feedback(cc.K(:,3:end),G,+1); w=[.1 1 10 100];
            expected=freqresp(formula,w);actual=freqresp(cl.noise(3:4,:),w);
            t.verifyLessThan(max(abs(expected-actual),[],'all')/max(1,max(abs(expected),[],'all')),1e-6);
        end
        function isolatedNoiseHasNoReference(t)
            a=load(fullfile(t.Data.root,'results/data/final_closure/noise_diagnostics.mat'));
            inputs=a.result.runs{4,2}.inputs;
            t.verifyEqual(inputs(:,1:4),zeros(size(inputs,1),4));
            t.verifyEqual(inputs(:,7:end),zeros(size(inputs,1),4));
        end
        function rapidPulsesAreNotHiddenBySampling(t)
            a=load(fullfile(t.Data.root,'results/data/final_closure/noise_diagnostics.mat'));
            diagnostic=a.result.diagnostic(4);samples=a.result.runs{4,2}.output(:,3:4);
            t.verifyGreaterThan(diagnostic.intersamplePeakU,1000*max(abs(samples),[],'all'));
            t.verifyLessThan(diagnostic.intersampleRealizationAgreement,1e-4);
            t.verifyLessThan(diagnostic.intersampleRmsRefinementRelative,.02);
        end
        function practicalEvidenceExcludesUnstablePerformance(t)
            a=load(fullfile(t.Data.root,'results/data/final_closure/practical_robustness.mat'));
            metrics=a.result.metrics;unstable=~metrics.Stable;
            t.verifyTrue(all(isnan(metrics.SettlingTime(unstable))));
            t.verifyTrue(a.result.replayPassed);
            t.verifyEqual(size(a.result.sampledPlants,1),2);
            t.verifyEqual(size(a.result.sampledPlants,2),4);
            t.verifyEqual(size(a.result.sampledPlants,3),10);
        end
        function externalSetupHasPhysicalBus(t,setupKind)
            workspace=setup_student_originals(setupKind);
            t.verifySize(workspace.Bplant,[14 8]);
            t.verifyClass(workspace.slBus1,'Simulink.Bus');
            t.verifyEqual({workspace.slBus1.Elements.Name}',fieldnames(sea_params_nominal));
            t.verifyEqual(workspace.Aplant,t.Data.m3.Afull);
        end
        function commonRasPreservesUnknownOutcomes(t)
            a=load(fullfile(t.Data.root,'results/data/final_closure/ras_lyapunov.mat'));
            t.verifyEqual(height(a.result.metrics),150);
            for k=1:6
                m=a.result.metrics(string(a.result.metrics.Controller)==t.Data.controllers(k).name,:);
                t.verifyEqual(height(m),25);
                t.verifyEqual(sortrows([m.Q1deg,m.Q2deg]),sortrows(rad2deg(a.result.pointsRad)));
                unknown=contains(string(m.Status),'SOLVER') | contains(string(m.Status),'NUMERIC');
                t.verifyFalse(any(m.Converged(unknown)));
            end
        end
        function lyapunovLevelsRequireNumericalGate(t)
            a=load(fullfile(t.Data.root,'results/data/final_closure/ras_lyapunov.mat'));
            for k=1:6
                proof=a.result.proofs{k};
                t.verifyEqual(proof.n,14+t.Data.controllers(k).order);
                if proof.gatePassed
                    t.verifyGreaterThan(proof.rhoCertified,0);
                    t.verifyLessThan(proof.residual+proof.roundoffAllowance,1e-6);
                    t.verifyGreaterThan(proof.positiveMinimumEigenvalue,0);
                else
                    t.verifyTrue(isnan(proof.rhoCertified));
                end
            end
        end
    end
end
