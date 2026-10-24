classdef salarisModelsTest < matlab.unittest.TestCase
    % Confronti ingresso-uscita indipendenti dalle matrici della LFT.
    methods(TestClassSetup)
        function setupPaths(t)
            root=fileparts(fileparts(mfilename('fullpath')));
            t.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(root,'src'),'IncludingSubfolders',true));
            t.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(root,'analysis'),'IncludingSubfolders',true));
        end
    end
    methods(Test)
        function mechanicalReconstruction(t)
            m=build_manual_mechanical_lft; u=uncertainty_params_m4;
            [automatic,~,~]=build_uncertain_mechanical_plant(u.selectedMechanicalRanges);
            values=[0 0 0;-1 -1 -1;1 1 1;-.7 .4 .6];
            w=logspace(-2,4,121); errorMax=0;
            for j=1:size(values,1)
                v=values(j,:); p=sea_params_nominal;
                a=usubs(m.G,'dk1',v(1),'dk2',v(2),'dJm1',v(3));
                b=usubs(automatic,'k1',p.Ks(1,1)*(1+.1*v(1)), ...
                    'k2',p.Ks(2,2)*(1+.1*v(2)),'Jm1',p.Jm(1,1)*(1+.1*v(3)));
                errorMax=max(errorMax,max(abs(freqresp(a,w)-freqresp(b,w)),[],'all'));
            end
            t.verifyLessThan(errorMax,1e-7);
        end
        function actuatorReconstruction(t)
            p=actuator_params_nominal; s=tf('s'); W=2.16*(.018*s/(.5+.018*s))^3;
            m=build_manual_parametric_actuator(1,W); w=logspace(-2,5,201);
            values=[0 0 0;-1 -1 -1;1 1 1;-.7 .4 .6]; errorMax=0;
            residual=.3/(s+1);
            for j=1:size(values,1)
                v=values(j,:);
                a=usubs(m.G,'dwn1',v(1),'dzeta1',v(2),'dtau1',v(3),'Dres1',residual);
                b=usubs(m.automatic,'wn1',p.wn*(1+.1*v(1)), ...
                    'zeta1',p.zeta*(1+.1*v(2)),'tau1',p.delay*(1+.2*v(3)),'Dres1',residual);
                errorMax=max(errorMax,max(abs(freqresp(a,w)-freqresp(b,w)),[],'all'));
            end
            t.verifyLessThan(errorMax,1e-8);
        end
        function automaticLftRoundTrip(t)
            s=tf('s'); m=build_manual_parametric_actuator(1,2.16*(.018*s/(.5+.018*s))^3);
            [M,D]=lftdata(m.automatic); recovered=lft(D,M);
            t.verifyLessThan(max(abs(freqresp(recovered.NominalValue,logspace(-2,4,81))- ...
                freqresp(m.automatic.NominalValue,logspace(-2,4,81))),[],'all'),1e-10);
        end
        function nominalAndStructures(t)
            m=build_salaris_models; nominal=m.plants{1}.NominalValue; err=0;
            for j=2:3
                err=max(err,max(abs(freqresp(nominal,logspace(-2,4,101))- ...
                    freqresp(m.plants{j}.NominalValue,logspace(-2,4,101))),[],'all'));
            end
            t.verifyLessThan(err,1e-7);
            t.verifySize(m.actuators{1}.Uncertainty.Dact_full,[2 2]);
            t.verifyNumElements(fieldnames(m.actuators{3}.Uncertainty),8);
            t.verifyGreaterThanOrEqual(min(m.coverage.WeightA-m.coverage.EnvelopeB),0);
        end
        function delayResidualBound(t)
            % |exp(-jx)-Dp(jx)| <= min(2,x^3/12), x >= 0.
            x=logspace(-5,7,10001); bound=min(2,x.^3/12);
            weight=2.16*(x./sqrt(.25+x.^2)).^3;
            t.verifyLessThanOrEqual(max(bound./weight),1);
            % Il polo dell'inverso Pade e nel semipiano destro.
            p=actuator_params_nominal;
            t.verifyGreaterThan(2/p.delay,0);
        end
    end
end
