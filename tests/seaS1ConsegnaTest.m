classdef seaS1ConsegnaTest < matlab.unittest.TestCase
    % Proprietà fisiche e confini delle evidenze della consegna autonoma.
    properties
        Root
        P
        Bank
        Models
        Robust
        Results
    end
    properties(TestParameter)
        corner=struct('nominal',[0 0],'low',[-1 -1],'high',[1 1], ...
            'mixed1',[-1 1],'mixed2',[1 -1],'inside',[.3 -.7])
        controller=struct('LQG',1,'LQGI',2,'Hinf1',3,'Hinf2',4, ...
            'PID',5,'Kmu',6,'MuA',7,'MuB',8)
    end
    methods(TestClassSetup)
        function setup(t)
            t.Root=fullfile(fileparts(fileparts(mfilename('fullpath'))),'Progetto_SEA_Consegna');
            isolated=getenv('SEA_TEST_ROOT');
            if ~isempty(isolated),t.Root=isolated;end
            t.applyFixture(matlab.unittest.fixtures.PathFixture(t.Root));
            t.P=parametri_sea;
            a=load(fullfile(t.Root,'dati/banca_consolidata.mat'));t.Bank=a.banca;
            a=load(fullfile(t.Root,'dati/modelli_S1.mat'));t.Models=a.modelli;
            t.Robust=load(fullfile(t.Root,'dati/robustezza_S1.mat'));
            a=load(fullfile(t.Root,'dati/confronto_finale.mat'));t.Results=a.confronto;
        end
    end
    methods(Test)
        function equilibrium(t)
            f=dinamica_sea(t.Bank.plant.xbar,t.Bank.plant.taubar,zeros(2,1),t.P);
            t.verifyLessThan(norm(f),1e-10);
        end
        function jacobian(t)
            J=seaS1ConsegnaTest.jacobianAt(@(x)dinamica_sea(x,t.Bank.plant.taubar,zeros(2,1),t.P),t.Bank.plant.xbar);
            t.verifyLessThan(norm(J-t.Models.mechanicalA,'fro')/norm(J,'fro'),1e-8);
        end
        function physicalDisturbanceChannel(t)
            J=seaS1ConsegnaTest.jacobianAt(@(d)dinamica_sea(t.Bank.plant.xbar,t.Bank.plant.taubar,d,t.P),zeros(2,1));
            t.verifyEqual(J,t.Bank.plant.Bd(1:8,:),'AbsTol',1e-8);
        end
        function nominalAB(t)
            a=freqresp(t.Models.PA.NominalValue,[.3 7 39 101]);
            b=freqresp(t.Models.PB.NominalValue,[.3 7 39 101]);
            ref=freqresp(t.Models.P0,[.3 7 39 101]);
            t.verifyLessThan(max(abs(a-ref),[],'all'),1e-8);
            t.verifyLessThan(max(abs(b-ref),[],'all'),1e-8);
        end
        function manualLftMatchesPhysics(t,corner)
            s=tf('s');p=t.P;wn=p.wn*(1+p.rwn*corner(1));z=p.zeta*(1+p.rzeta*corner(2));
            expected=wn^2/(s^2+2*z*wn*s+wn^2)*(1-p.tau*s/2)/(1+p.tau*s/2);
            actual=usubs(t.Models.GaA(1,1),'dwn1',corner(1),'dzeta1',corner(2));
            t.verifyLessThan(max(abs(freqresp(actual,p.omega)-freqresp(expected,p.omega)),[],'all'),1e-9);
        end
        function globalEnvelopeAssumptions(t)
            p=t.P;
            t.verifyGreaterThan(p.zmin,0);t.verifyLessThanOrEqual(p.zmax,1);
            t.verifyEqual(p.cWI,hypot(.21,14.08/36)/.72,'AbsTol',1e-12);
            t.verifyLessThanOrEqual(t.Models.coverMax,1);
        end
        function normalizedUncertaintyStructure(t)
            t.verifyEqual(sort(string(fieldnames(t.Models.PA.Uncertainty))),sort(["dwn1";"dzeta1";"dwn2";"dzeta2"]));
            t.verifyEqual(size(t.Models.DeltaA),[6 6]);
            t.verifyEqual(sort(string(fieldnames(t.Models.PB.Uncertainty))),["Dact1";"Dact2"]);
        end
        function nominalInternalStability(t,controller)
            m=t.Results.nominali{controller};
            t.verifyTrue(m.stable);
            t.verifySize(t.Robust.K{controller},[2 size(t.Robust.K{controller},2)]);
        end
        function commonCostNominalEquivalence(t,controller)
            a=t.Robust.risultati{controller,1};b=t.Robust.risultati{controller,2};
            t.verifyLessThan(abs(a.nominalNorm-b.nominalNorm)/max(1,a.nominalNorm),1e-4);
        end
        function independentSameProblemHinf(t)
            a=load(fullfile(t.Root,'dati/sintesi_hinf.mat'));h=a.hinf;
            G=t.Models.P0(1:2,1:2);W1=t.Bank.hinf.W1;W2=t.Bank.hinf.W2;
            S=feedback(eye(2),G*h.KeMix);v=norm([W1*S;W2*h.KeMix*S],inf);
            t.verifyLessThan(abs(v/h.gammaMix-1),.05);
            t.verifyLessThan(abs(h.gammaMix/h.gammaHin-1),.05);
        end
        function integralRejectsConstantLinkDisturbance(t)
            rows=t.Results.campioni;
            r=rows(rows.Impianto==1 & rows.Controllore=="LQGI",:);
            t.verifyLessThan(r.ResiduoDisturboDC_rad,1e-8);
        end
        function twoDedicatedSyntheses(t)
            a=load(fullfile(t.Root,'dati/mu_sintesi_S1.mat'));
            t.verifyEqual(a.candidati{1}.designModel,"A_parametrico");
            t.verifyEqual(a.candidati{2}.designModel,"B_concentrato");
            t.verifyLessThanOrEqual(numel(a.candidati{1}.info),t.P.dkIterations);
            t.verifyLessThanOrEqual(numel(a.candidati{2}.info),t.P.dkIterations);
        end
        function robustSynthesisUnitProperties(t)
            r=t.Robust.confrontoRobusto;
            q=r(ismember(r.Controllore,["Mu_A","Mu_B"]),:);
            t.verifyTrue(all(q.RS_lower>1));t.verifyTrue(all(q.RP_lower>1));
        end
        function invalidDirectRPIsPreserved(t)
            r=t.Robust.risultati{6,1};
            t.verifyGreaterThan(r.RPdirect.LowerBound,r.RPdirect.UpperBound);
            t.verifyEqual(r.RPmethod,"INCLUSIONE_B_E_LIMITE_RS_A");
            t.verifyEqual(r.RP.LowerBound,1,'AbsTol',1e-14);
        end
        function samplesAreCommon(t,controller)
            r=t.Results.campioni;r=r(r.Controllore==t.Robust.nomi(controller),:);
            t.verifyEqual(r.Impianto,(1:10)');t.verifyEqual(t.P.samples(1,:),zeros(1,4),'AbsTol',1e-14);
            t.verifyGreaterThanOrEqual(t.P.samples,-ones(10,4));
            t.verifyLessThanOrEqual(t.P.samples,ones(10,4));
        end
        function rasUsesCommonSection(t,controller)
            r=t.Results.rasTable;r=r(r.Controllore==t.Robust.nomi(controller),:);
            t.verifyEqual([r.Q1deg r.Q2deg],t.P.rasPointsDeg,'AbsTol',1e-12);
            t.verifyFalse(any(r.Converge & ~r.Completa));
            t.verifyTrue(all(r.Esito(~r.Completa)=="NUMERICAMENTE_INCONCLUDENTE"));
        end
        function noExternalMatlabDependency(t)
            entry=fullfile(t.Root,'SEA_00_AVVIO_PROGETTO.m');
            [files,~]=matlab.codetools.requiredFilesAndProducts(entry);
            t.verifyTrue(all(startsWith(string(files),string(t.Root)+filesep)));
        end
    end
    methods(Static,Access=private)
        function J=jacobianAt(fun,x)
            step=3e-6; J=zeros(8,numel(x));
            for j=1:numel(x)
                d=zeros(size(x));d(j)=step;
                J(:,j)=(fun(x+d)-fun(x-d))/(2*step);
            end
        end
    end
end
