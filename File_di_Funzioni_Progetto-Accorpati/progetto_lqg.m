%% 1 - LQG: modello originale e coefficienti consolidati
cartella=fileparts(mfilename('fullpath')); addpath(cartella); p=parametri_sea;
a=load(fullfile(p.dati,'banca_validata.mat'),'banca'); banca=a.banca;
A=banca.plant.Afull; B=banca.plant.Bfull; C=banca.plant.CfullMeas;
Cq=banca.plant.CfullQ; Bd=banca.Bd; n=size(A,1);
disp('LQG: coefficienti da main; verifiche CARE eseguite ora.');
%% 2 - Q e R: le scale e i pesi della ricerca storica LQR30
qs=p.rAmp; qds=banca.spec.omegaB*qs; ds=p.dAmp/min(diag(banca.plant.mechanicalParams.Ks));
F=zeros(8,n); F(1:4,1:4)=eye(4); F(5:6,1:2)=-eye(2);
F(5:6,5:6)=eye(2); F(7:8,7:8)=eye(2);
Sx=diag([qs qs qds qds ds ds qds qds]);
Q=F'*(Sx'\diag([2 2 1 1 .1 .1 1 1])/Sx)*F; R=.1*eye(2);
assert(norm(Q-banca.lqg.Q,'fro')<1e-8 && norm(R-banca.lqg.R,'fro')<1e-12);
%% 3 - Riccati e Kalman, con rumori di processo e misura distinti
Gw=[Bd B]; Qn=banca.lqg.Qn; Rn=banca.lqg.Rn;
% Qn/Rn sono intensita continue; randn campionato non e lo stesso rumore.
[K,Plqr,poliLqr]=lqr(A,B,Q,R); [L,~,poliKalman]=lqe(A,Gw,C,Qn,Rn);
Nr=(-Cq*((A-B*K)\B))\eye(2);
residuoCARE=norm(A'*Plqr+Plqr*A-Plqr*B*(R\B')*Plqr+Q,'fro')/norm(Q,'fro');
assert(residuoCARE<1e-8 && max(real(poliLqr))<0 && max(real(poliKalman))<0);
assert(norm(K-banca.lqg.K,'fro')<1e-6 && norm(L-banca.lqg.L,'fro')<1e-6);
%% 4 - Feedback sullo stato stimato; ingressi [r;q;theta]
Klqg=ss(A-B*K-L*C,[B*Nr L],-K,[Nr zeros(2,4)]);
Acl=[A -B*K;L*C A-B*K-L*C];
T=[eye(n) zeros(n);eye(n) -eye(n)];
erroreSeparazione=norm(T*Acl/T-[A-B*K B*K;zeros(n) A-L*C],'fro');
assert(erroreSeparazione<1e-8 && all(real(eig(Acl))<0));
lqg=struct('K',Klqg,'Q',Q,'R',R,'Qn',Qn,'Rn',Rn,'L',L,'Nr',Nr, ...
    'residuoCARE',residuoCARE,'erroreSeparazione',erroreSeparazione);
save(fullfile(p.risultati,'lqg.mat'),'lqg','-v7');
fprintf('CARE %.3g; separazione %.3g.\n',residuoCARE,erroreSeparazione);
%% 5 - Sensibilita Kalman: cinque covarianze, stessa sequenza fisica
fattori=[.5 .75 1 1.5 2]'; metriche=zeros(5,3);
rngPrima=rng; rng(p.seed,'twister'); t=(0:.002:4)';
v=p.sigmaY*randn(numel(t),4); rng(rngPrima);
for j=1:5
    Lj=lqe(A,Gw,C,Qn,fattori(j)^2*Rn);
    Aj=[A -B*K;Lj*C A-B*K-Lj*C];
    sys=ss(Aj,[zeros(n,4);Lj],[Cq -Cq;zeros(2,n) -K],zeros(4));
    y=lsim(sys,v,t);
    metriche(j,:)=[max(real(eig(A-Lj*C))),sqrt(mean(y(:,1:2).^2,'all')),sqrt(mean(y(:,3:4).^2,'all'))];
end
sensibilita=table(fattori,metriche(:,1),metriche(:,2),metriche(:,3), ...
    'VariableNames',{'FattoreSigmaAssunta','PoloOsservatore','ErroreStimaRMS','ComandoRMS'});
writetable(sensibilita,fullfile(p.risultati,'kalman.csv')); disp(sensibilita);
