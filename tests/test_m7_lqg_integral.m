classdef test_m7_lqg_integral < matlab.unittest.TestCase
    %TEST_M7_LQG_INTEGRAL Verifiche indipendenti del servo con Kalman M6.
    properties
        Root
        M3
        M5
        M6
        M7
    end
    properties (TestParameter)
        Index = {1,2,3}
    end
    methods (TestClassSetup)
        function loadEvidence(testCase)
            % Si leggono gli artifact prodotti dalla pipeline: i test
            % ricostruiscono equazioni e mappe senza rieseguire la campagna.
            testCase.Root=fileparts(fileparts(mfilename('fullpath')));
            data=fullfile(testCase.Root,'results','data');
            testCase.M3=load(fullfile(data,'m3_nominal_actuated_plant.mat'));
            testCase.M5=load(fullfile(data,'m5_performance_specs.mat'));
            testCase.M6=load(fullfile(data,'m6_lqg_no_integrator.mat'));
            testCase.M7=load(fullfile(data,'m7_augmented_cost_feasibility.mat'));
        end
    end
    methods (Test)
        function dimensionsAndNoFeedforward(testCase,Index)
            d=testCase.M7.designs{Index}; e=testCase.M7.evaluations{Index};
            testCase.verifySize(d.Aaug,[16,16]);
            testCase.verifySize(d.Kx,[2,14]); testCase.verifySize(d.Ki,[2,2]);
            testCase.verifySize(e.L,[14,4]); testCase.verifySize(e.closedLoop.A,[30,30]);
            testCase.verifyEqual(order(e.Klqri),16);
            testCase.verifyEqual(e.Klqri.D,zeros(2,6),'AbsTol',0);
            testCase.verifyFalse(isfield(e,'Nff'));
            % Il peso integrale e diretto e non conserva una scala implicita.
            testCase.verifyEqual(d.Qi,d.wbarI*eye(2),'AbsTol',0);
            testCase.verifyFalse(isfield(d,'xiScale'));
            testCase.verifyFalse(isfield(e.summary,'windupIndicator'));
        end
        function augmentedRiccatiAndGain(testCase,Index)
            % Ricostruzione dalle matrici fisiche e dal peso dichiarato,
            % non confronto fra una variabile e la sua copia nell'artifact.
            d=testCase.M7.designs{Index}; a=testCase.M3;
            Aa=[a.Afull,zeros(14,2);-a.CfullQ,zeros(2)];
            Ba=[a.Bfull;zeros(2)]; Qa=blkdiag(testCase.M6.Q,d.Qi);
            residual=Aa'*d.P+d.P*Aa-d.P*Ba*(d.R\Ba')*d.P+Qa;
            testCase.verifyLessThan(norm(residual,'fro')/norm(Qa,'fro'),1e-8);
            testCase.verifyEqual([d.Kx,d.Ki],d.R\(Ba'*d.P),'AbsTol',1e-7);
            testCase.verifyEqual(d.Aaug,Aa,'AbsTol',0);
            testCase.verifyEqual(rank([a.Afull,a.Bfull;a.CfullQ,zeros(2)]),16);
        end
        function measuredIntegratorAndPhysicalEquations(testCase,Index)
            % Un campione non nullo distingue x da xhat e comprende rumore
            % encoder. La derivata attesa e calcolata dalla legge fisica.
            d=testCase.M7.designs{Index}; e=testCase.M7.evaluations{Index};
            a=testCase.M3; z=sin((1:30)')/10; w=cos((1:8)')/20;
            x=z(1:14); xi=z(15:16); xhat=z(17:30);
            y=a.CfullMeas*x+w(5:8); u=-d.Kx*xhat-d.Ki*xi;
            expected=[a.Afull*x+a.Bfull*u+testCase.M5.BdFull*w(3:4); ...
                w(1:2)-y(1:2);a.Afull*xhat+a.Bfull*u+testCase.M6.L*(y-a.CfullMeas*xhat)];
            actual=e.closedLoop.A*z+e.closedLoop.B*w;
            testCase.verifyEqual(actual,expected,'AbsTol',1e-10);
            testCase.verifyEqual(e.closedLoop.C(5:6,:)*z,u,'AbsTol',1e-12);
        end
        function fullInternalStabilityAndSeparation(testCase,Index)
            d=testCase.M7.designs{Index}; e=testCase.M7.evaluations{Index}; a=testCase.M3;
            expected=[eig(d.Aaug-d.Baug*d.Kaug);eig(a.Afull-testCase.M6.L*a.CfullMeas)];
            actual=eig(e.closedLoop.A);
            % Il polo attuativo ripetuto vicino a -133.333 e sensibile:
            % cond(V) raggiunge 9.4e9. Il solo scarto assoluto fra eig
            % non e un criterio affidabile. Si verifica invece il residuo
            % spettrale normalizzato, insieme alla similarita e a tutti
            % i 30 poli della matrice naturale, senza alterare il sistema.
            spectralResidual=arrayfun(@(p) min(svd(e.closedLoop.A-p*eye(30)))/ ...
                max(1,norm(e.closedLoop.A,2)+abs(p)),expected);
            testCase.verifyLessThan(max(real(actual)),-1e-8);
            testCase.verifyLessThan(max(real(eig(a.Afull-testCase.M6.L*a.CfullMeas))),-1e-8);
            testCase.verifyLessThan(max(spectralResidual),1e-12);
            testCase.verifyLessThan(norm(e.transformation*e.closedLoop.A/ ...
                e.transformation-e.Aseparated,'fro'),1e-9);
        end
        function kalmanAndPhysicalCostUnchanged(testCase,Index)
            d=testCase.M7.designs{Index}; e=testCase.M7.evaluations{Index};
            testCase.verifyEqual(e.L,testCase.M6.L,'AbsTol',0);
            testCase.verifyEqual(e.Qn,testCase.M6.Qn,'AbsTol',0);
            testCase.verifyEqual(e.Rn,testCase.M6.Rn,'AbsTol',0);
            testCase.verifyEqual(d.Qaug(1:14,1:14),testCase.M6.Q,'AbsTol',0);
            testCase.verifyEqual(d.R,testCase.M6.R,'AbsTol',1e-15);
        end
        function constantReferenceAndDisturbanceEquilibria(testCase,Index)
            % L'equilibrio e ricostruito risolvendo Acl*z+Bcl*w=0.
            e=testCase.M7.evaluations{Index};
            equilibria=-e.closedLoop.A\e.closedLoop.B(:,1:4);
            q=testCase.M3.CfullQ*equilibria(1:14,:);
            testCase.verifyEqual(q(:,1:2),eye(2),'AbsTol',1e-9);
            testCase.verifyEqual(q(:,3:4),zeros(2),'AbsTol',1e-9);
            testCase.verifyLessThan(norm(e.closedLoop.A*equilibria+ ...
                e.closedLoop.B(:,1:4),'fro'),1e-8);
        end
        function finiteTimeRejectionAgreesWithMatrixExponential(testCase)
            % Verifica a 20 s del punto intermedio wbarI=200, distinta
            % dal residuo sul grafico a 8 s e dalla soluzione asintotica.
            e=testCase.M7.evaluations{2};
            equilibrium=-e.closedLoop.A\(e.closedLoop.B(:,3:4)*0.5);
            stateAt20=equilibrium-expm(e.closedLoop.A*20)*equilibrium;
            testCase.verifyLessThan(max(abs(testCase.M3.CfullQ*stateAt20(1:14,:)),[],'all'),1e-7);
            input=zeros(numel(e.disturbanceTime),8); input(:,3)=0.5;
            response=lsim(e.closedLoop,input,e.disturbanceTime);
            expected=equilibrium(:,1)-expm(e.closedLoop.A*8)*equilibrium(:,1);
            testCase.verifyEqual(response(end,1:2)',testCase.M3.CfullQ*expected(1:14),'AbsTol',1e-9);
        end
        function m6OffsetRemainsAndM7RejectsIt(testCase)
            % Il valore M6 e verificato sulla propria chiusura congelata.
            dc=-testCase.M6.lqgClosedLoop.C(1:2,:)* ...
                (testCase.M6.lqgClosedLoop.A\testCase.M6.lqgClosedLoop.B(:,3:4))*0.5;
            testCase.verifyGreaterThan(max(abs(dc),[],'all'),1e-2);
            c=load(fullfile(testCase.Root,'results','data','m7_disturbance_comparison.mat'));
            testCase.verifyEqual(c.metriche{1:2,3:4},dc','AbsTol',1e-9);
            testCase.verifyLessThan(max(abs(c.metriche{3:4,3:4}),[],'all'),1e-9);
        end
        function directIntegralStudyKeepsQAndRFixed(testCase)
            t=testCase.M7.manualComparisonTable;
            testCase.verifyEqual(t.WbarI,[20;200;800],'AbsTol',0);
            testCase.verifyEqual(t.Ru,repmat(testCase.M6.R(1,1),3,1),'AbsTol',1e-15);
            testCase.verifyEqual(testCase.M7.config.illustrativeIndex,2);
        end
        function unmetPerformanceIsNotHidden(testCase)
            t=testCase.M7.manualComparisonTable; spec=testCase.M5.spec;
            expected=t.Stable & t.WorstSettlingTime<=spec.settlingTimeTarget & ...
                t.WorstOvershoot<=spec.overshootTarget & t.DisturbancePass;
            testCase.verifyEqual(t.FundamentalPass,expected);
            testCase.verifyEqual(testCase.M7.validationMetrics.admissibleCount,sum(expected));
            testCase.verifyFalse(any(expected));
            testCase.verifyEqual(testCase.M7.validationMetrics.status,"PARTIAL");
        end
        function obsoleteImplementationIsAbsent(testCase)
            paths=["analysis/progetto_lqi.m","controllers/lqg/build_lqi_reference_feedforward.m", ...
                "controllers/lqg/build_lqi_augmented_cost.m","analysis/nominal/evaluate_lqi_2dof_candidate.m"];
            testCase.verifyFalse(any(isfile(fullfile(testCase.Root,paths))));
            testCase.verifyTrue(isfile(fullfile(testCase.Root,'analysis','progetto_lqri.m')));
        end
    end
end
