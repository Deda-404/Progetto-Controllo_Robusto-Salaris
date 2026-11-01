classdef seaFinaleTest < matlab.unittest.TestCase
    methods (TestClassSetup)
        function percorso(t)
            root=fileparts(fileparts(mfilename('fullpath')));
            t.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(root,'File_di_Funzioni_Progetto-Accorpati')));
        end
    end
    methods (Test)
        function equilibrioEJacobiano(t)
            p=parametri_sea; a=load(fullfile(p.risultati,'modello.mat')); m=a.modello;
            t.verifyLessThan(norm(dinamica_sea(m.xbar,m.taubar,zeros(2,1),m.fisica)),1e-10);
            J=jacobiano(m);
            t.verifyLessThan(norm(J-m.Am,'fro')/norm(m.Am,'fro'),1e-8);
        end
        function contributoPuntiforme(t)
            p=parametri_sea; a=load(fullfile(p.risultati,'modello.mat')); f=a.modello.fisica;
            q=[.4;-.3]; v=[.7;-.2]; [M,C,G]=matrici_sea(q,v,f);
            senza=f; senza.mEE=0; [M0,C0,G0]=matrici_sea(q,v,senza);
            J=[-f.l1*sin(q(1))-f.l2*sin(sum(q)),-f.l2*sin(sum(q)); ...
                f.l1*cos(q(1))+f.l2*cos(sum(q)),f.l2*cos(sum(q))];
            t.verifyEqual(M-M0,f.mEE*(J'*J),'AbsTol',1e-12);
            t.verifyEqual(G-G0,f.mEE*f.g*J(2,:)','AbsTol',1e-12);
            t.verifyGreaterThan(norm((C-C0)*v),0);
            t.verifyGreaterThan(min(eig(M)),0);
        end
        function energiaCoriolis(t)
            p=parametri_sea; a=load(fullfile(p.risultati,'modello.mat')); f=a.modello.fisica;
            q=[.4;-.3]; v=[.7;-.2]; h=1e-6;
            [~,C]=matrici_sea(q,v,f);
            Md=(matrici_sea(q+h*v,v,f)-matrici_sea(q-h*v,v,f))/(2*h);
            t.verifyLessThan(norm(Md-2*C+(Md-2*C)','fro'),1e-9);
        end
    end
end
function J=jacobiano(m)
J=zeros(8); h=1e-6;
for j=1:8
    v=zeros(8,1); v(j)=h;
    J(:,j)=(dinamica_sea(m.xbar+v,m.taubar,zeros(2,1),m.fisica)- ...
        dinamica_sea(m.xbar-v,m.taubar,zeros(2,1),m.fisica))/(2*h);
end
end
