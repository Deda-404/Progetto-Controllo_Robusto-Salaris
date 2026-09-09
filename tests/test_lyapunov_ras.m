classdef test_lyapunov_ras < matlab.unittest.TestCase
    %TEST_LYAPUNOV_RAS Verifiche matematiche sul nominale aumentato.
    properties
        Risultati
        M3
    end
    properties (TestParameter)
        controllore = struct('LQG',1,'Hinf',2,'Kmu',3)
    end
    methods (TestClassSetup)
        function carica(testCase)
            root=fileparts(fileparts(mfilename('fullpath')));
            addpath(genpath(fullfile(root,'src')),genpath(fullfile(root,'analysis')));
            d=load(fullfile(root,'results','data','lyapunov_ras_nominal.mat'));
            testCase.Risultati=d.risultati;
            testCase.M3=load(fullfile(root,'results','data','m3_nominal_actuated_plant.mat'));
        end
    end
    methods (Test)
        function ordineCompleto(testCase,controllore)
            r=testCase.Risultati{controllore}; ordini=[28 32 66];
            testCase.verifySize(r.Acl,[ordini(controllore) ordini(controllore)]);
        end
        function stabilitaLineare(testCase,controllore)
            r=testCase.Risultati{controllore};
            testCase.verifyLessThan(max(real(eig(r.Acl))),0);
        end
        function positivaDefinita(testCase,controllore)
            r=testCase.Risultati{controllore};
            testCase.verifyGreaterThan(min(eig(r.P)),0);
            testCase.verifyEqual(r.P,r.P','AbsTol',1e-12);
        end
        function convenzioneLyap(testCase,controllore)
            r=testCase.Risultati{controllore};
            testCase.verifyLessThan(norm(r.Acl'*r.P+r.P*r.Acl+r.QL,2),1e-6);
        end
        function equilibrioNullo(testCase,controllore)
            r=testCase.Risultati{controllore}; z=zeros(size(r.Acl,1),1);
            testCase.verifyEqual(sea_closed_loop_rhs(z,r.model),z,'AbsTol',1e-12);
        end
        function jacobianoCoerente(testCase,controllore)
            r=testCase.Risultati{controllore};
            jac=jacobianoNumerico(r);
            testCase.verifyLessThan(norm(jac-r.Acl,'fro')/norm(r.Acl,'fro'),1e-8);
        end
        function maggiorazioneCubica(testCase,controllore)
            r=testCase.Risultati{controllore};
            rapporto=verificaResto(r);
            testCase.verifyLessThanOrEqual(max(rapporto),r.bound.c);
        end
        function certificatoPositivo(testCase,controllore)
            r=testCase.Risultati{controllore};
            testCase.verifyGreaterThan(r.bound.rhoCertified,0);
            testCase.verifyEqual(r.bound.rhoCertified, ...
                r.bound.lambdaMinP*r.bound.stateRadius^2,'RelTol',1e-12);
        end
        function margineAnalitico(testCase,controllore)
            r=testCase.Risultati{controllore}; b=r.bound;
            crescita=2*b.normPE*b.c*b.rhoCertified/b.lambdaMinP;
            testCase.verifyLessThanOrEqual(crescita,0.501*(1-b.residualNorm));
        end
        function sezioneCoerente(testCase,controllore)
            r=testCase.Risultati{controllore}; q=[0.12;-0.2]; z=r.J*q;
            testCase.verifyEqual(z(1:2),z(5:6),'AbsTol',1e-14);
            testCase.verifyEqual(z'*r.P*z,q'*r.sectionP*q,'AbsTol',1e-10);
            testCase.verifyEqual(z([3:4,7:end]),zeros(numel(z)-4,1),'AbsTol',1e-14);
        end
        function campionamentoNonCertificato(testCase,controllore)
            r=testCase.Risultati{controllore};
            testCase.verifyEqual(r.samplingScope,"FINITE_POINTS_NOT_A_CERTIFICATE");
            testCase.verifyGreaterThan(r.rhoNumerical,r.bound.rhoCertified);
            testCase.verifyLessThan(r.maxSearchRatio,-r.config.negativeMargin);
        end
        function validazioneIndipendenteRegistrata(testCase,controllore)
            r=testCase.Risultati{controllore};
            testCase.verifyEqual(r.validationPointCount,8192);
            testCase.verifyEqual(r.validationPassed,r.maxValidationRatio < -r.config.negativeMargin);
        end
        function rigettaEquilibrioDifferente(testCase)
            r=testCase.Risultati{1}; m3=testCase.M3; m3.qbar=[0;0];
            testCase.verifyError(@() lyapunov_cubic_bound(r.Acl,r.P,m3),'Lyapunov:Equilibrium');
        end
        function rigettaRhoInfinito(testCase)
            r=testCase.Risultati{1}; d=eye(size(r.P,1),1);
            testCase.verifyError(@() lyapunov_sample_ratios(Inf,d,1,r.P,r.model), ...
                'MATLAB:validators:mustBeFinite');
        end
        function rigettaDirezioneNulla(testCase)
            r=testCase.Risultati{1}; d=zeros(size(r.P,1),1);
            testCase.verifyError(@() lyapunov_sample_ratios(1,d,1,r.P,r.model), ...
                'Lyapunov:Directions');
        end
        function rigettaNaN(testCase)
            r=testCase.Risultati{1}; d=NaN(size(r.P,1),1);
            testCase.verifyError(@() lyapunov_sample_ratios(1,d,1,r.P,r.model), ...
                'MATLAB:validators:mustBeFinite');
        end
    end
end

function jac=jacobianoNumerico(r)
n=size(r.Acl,1); jac=zeros(n); h=1e-6;
for j=1:n
    z=zeros(n,1); z(j)=h;
    jac(:,j)=(sea_closed_loop_rhs(z,r.model)-sea_closed_loop_rhs(-z,r.model))/(2*h);
end
end

function rapporto=verificaResto(r)
stato=rng; ripristina=onCleanup(@() rng(stato)); rng(901,'twister');
n=size(r.Acl,1); direzioni=randn(n,120); direzioni=direzioni./vecnorm(direzioni);
raggi=logspace(-3,0,120); rapporto=zeros(120,1);
for j=1:120
    z=raggi(j)*direzioni(:,j);
    resto=sea_closed_loop_rhs(z,r.model)-r.Acl*z;
    rapporto(j)=norm(resto)/norm(z)^3;
end
end
