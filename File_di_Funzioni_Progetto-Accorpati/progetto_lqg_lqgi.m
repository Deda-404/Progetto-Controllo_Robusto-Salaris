%% PROGETTO_LQG_LQGI - Controllo LQG senza e con integratore (Capitolo 7)
%
% Obiettivo (punto 1 della traccia): sintesi LQG sul modello lineare a 14
% stati, nella versione senza integratore (LQG, con prefiltro statico) e
% con azione integrale sull'errore di posizione (LQGI).
%
% Struttura LQG = regolatore LQR + filtro di Kalman (principio di
% separazione): il guadagno K si calcola come se lo stato fosse misurato,
% il guadagno L dell'osservatore come se il controllo fosse noto; il
% chiuso ha come autovalori l'unione di eig(A-BK) ed eig(A-LC).
%
% Convenzioni: stato x a 14 componenti (vedi modello_sea), misure
% y=[q1 q2 theta1 theta2], comando u=[u1 u2] in ingresso ai drive.
% Ingressi del controllore: [r1 r2 y1 y2 y3 y4] (riferimento e misure).
%
% Salva: risultati/lqg.mat, lqgi.mat (letti anche dai modelli Simulink) e
% kalman.csv. Pesi e covarianze sono quelli approvati e memorizzati in
% dati/banca_validata.mat: lo script li ricostruisce e controlla che
% coincidano, poi ripete realmente la sintesi.

%% 1 - Dati: modello nominale e pesi approvati
cartella=fileparts(mfilename('fullpath')); addpath(cartella); p=parametri_sea;
a=load(fullfile(p.dati,'banca_validata.mat'),'banca'); banca=a.banca;
a=load(fullfile(p.risultati,'modello.mat')); modello=a.modello;
A=modello.Afull; B=modello.Bfull; C=modello.Cfull;
Cq=C(1:2,:); Bd=modello.Bdfull; n=size(A,1);
disp('LQG: nuova sintesi nominale; pesi e covarianze conservati.');

%% 2 - LQR: matrici Q e R costruite da scale fisiche (regola di Bryson)
% Costo J = integrale di (x'Qx + u'Ru). Ogni grandezza viene divisa per una
% scala "accettabile": qs=5 gradi per le posizioni, qds=omegaB*qs per le
% velocita, ds=deformazione prodotta da 0.5 N m sulla molla piu rigida.
% F trasforma lo stato in grandezze fisicamente interpretabili: posizioni,
% velocita dei link, deformazioni theta-q e velocita dei motori.
qs=p.rAmp; qds=banca.spec.omegaB*qs; ds=p.dAmp/min(diag(banca.plant.mechanicalParams.Ks));
F=zeros(8,n); F(1:4,1:4)=eye(4); F(5:6,1:2)=-eye(2);
F(5:6,5:6)=eye(2); F(7:8,7:8)=eye(2);
Sx=diag([qs qs qds qds ds ds qds qds]);
% Pesi relativi: 2 sulle posizioni (priorita al tracking), 1 sulle
% velocita, 0.1 sulle deformazioni (si lascia lavorare la molla).
Q=F'*(Sx'\diag([2 2 1 1 .1 .1 1 1])/Sx)*F; R=.1*eye(2);
assert(norm(Q-banca.lqg.Q,'fro')<1e-8 && norm(R-banca.lqg.R,'fro')<1e-12);

%% 3 - Riccati (lqr) e filtro di Kalman (lqe)
% lqr risolve l'equazione algebrica di Riccati A'P+PA-PBR^-1B'P+Q=0 e
% restituisce K=R^-1 B'P (u=-Kx), la soluzione P e i poli di A-BK.
% lqe calcola il guadagno di Kalman L per il modello
%   xdot = A x + Gw w,  y = C x + v,  E[ww']=Qn, E[vv']=Rn,
% dove w raccoglie disturbi di coppia sui link e rumore sul comando
% (Gw=[Bd B]) e v e il rumore degli encoder.
Gw=[Bd B]; Qn=banca.lqg.Qn; Rn=banca.lqg.Rn;
% Qn/Rn sono intensita continue; randn campionato non e lo stesso rumore.
[K,Plqr,poliLqr]=lqr(A,B,Q,R); [L,~,poliKalman]=lqe(A,Gw,C,Qn,Rn);
% Prefiltro statico Nr: rende unitario il guadagno in continua da r a q
% sul nominale. Non elimina l'errore se l'impianto cambia (a differenza
% dell'integratore).
Nr=(-Cq*((A-B*K)\B))\eye(2);
residuoCARE=norm(A'*Plqr+Plqr*A-Plqr*B*(R\B')*Plqr+Q,'fro')/norm(Q,'fro');
assert(residuoCARE<1e-8 && max(real(poliLqr))<0 && max(real(poliKalman))<0);

%% 4 - Controllore LQG: feedback sullo stato stimato
%   xhat_dot = (A-BK-LC) xhat + B Nr r + L y,   u = -K xhat + Nr r
Klqg=ss(A-B*K-L*C,[B*Nr L],-K,[Nr zeros(2,4)]);
% Verifica del principio di separazione: con il cambio di variabili
% [x; x-xhat] la matrice del chiuso diventa triangolare a blocchi.
Acl=[A -B*K;L*C A-B*K-L*C];
T=[eye(n) zeros(n);eye(n) -eye(n)];
erroreSeparazione=norm(T*Acl/T-[A-B*K B*K;zeros(n) A-L*C],'fro');
assert(erroreSeparazione<1e-8 && all(real(eig(Acl))<0));
lqg=struct('K',Klqg,'Q',Q,'R',R,'Qn',Qn,'Rn',Rn,'L',L,'Nr',Nr, ...
    'residuoCARE',residuoCARE,'erroreSeparazione',erroreSeparazione,'Kstato',K,'firma',p.firma);
save(fullfile(p.risultati,'lqg.mat'),'lqg','-v7');
fprintf('CARE %.3g; separazione %.3g.\n',residuoCARE,erroreSeparazione);

%% 5 - Sensibilita del filtro di Kalman alla covarianza di misura assunta
% Si scala Rn di un fattore^2 (cioe la sigma assunta) e, a parita della
% stessa sequenza di rumore encoder (sigma=0.05 gradi, campioni ogni 2 ms
% mantenuti costanti da lsim), si misurano:
%   - il polo piu lento dell'osservatore, max Re eig(A-LC);
%   - l'RMS dell'errore di stima delle posizioni q - qhat;
%   - l'RMS del comando u.
% Nota: si confronta l'errore di stima, non la varianza del segnale
% stimato; le due grandezze sono diverse (vedi Capitolo 7).
fattori=[.5 .75 1 1.5 2]'; metriche=zeros(5,3);
rngPrima=rng; rng(p.seed,'twister'); t=(0:.002:4)';
v=p.sigmaY*randn(numel(t),4); rng(rngPrima);
for j=1:5
    Lj=lqe(A,Gw,C,Qn,fattori(j)^2*Rn);
    Aj=[A -B*K;Lj*C A-B*K-Lj*C];
    sys=ss(Aj,[zeros(n,4);Lj],[Cq -Cq;zeros(2,n) -K],zeros(4));
    % lsim simula la risposta di un sistema LTI a un ingresso campionato.
    y=lsim(sys,v,t);
    metriche(j,:)=[max(real(eig(A-Lj*C))),sqrt(mean(y(:,1:2).^2,'all')),sqrt(mean(y(:,3:4).^2,'all'))];
end
sensibilita=table(fattori,metriche(:,1),metriche(:,2),metriche(:,3), ...
    'VariableNames',{'FattoreSigmaAssunta','PoloOsservatore','ErroreStimaRMS','ComandoRMS'});
writetable(sensibilita,fullfile(p.risultati,'kalman.csv')); disp(sensibilita);

%% 6 - LQGI: stato aumentato con l'integrale dell'errore
% xi_dot = r - q_misurata. Se il chiuso e stabile e r, d sono costanti,
% a regime xi_dot=0, quindi q=r: l'errore statico si annulla anche con
% impianto perturbato o disturbo di coppia costante. Prezzo: due poli in
% piu e, di norma, una risposta piu lenta o con sovraelongazione.
d=banca.lqgi;
Aa=[A,zeros(14,2);-Cq,zeros(2)]; Ba=[B;zeros(2)];
% Qi pesa l'integrale dell'errore; il resto di Q e quello dell'LQG.
Qi=d.wbarI*eye(2); Qa=blkdiag(banca.lqg.Q,Qi); Ri=d.ru*eye(2);
[Kaug,Pi,poliI]=lqr(Aa,Ba,Qa,Ri);
Kx=Kaug(:,1:14); Ki=Kaug(:,15:16);
residuoI=norm(Aa'*Pi+Pi*Aa-Pi*Ba*(Ri\Ba')*Pi+Qa,'fro')/norm(Qa,'fro');
assert(residuoI<1e-8 && all(real(poliI)<0));

%% 7 - Controllore LQGI a 16 stati
% Stato del controllore [xhat (14); xi (2)]. L'osservatore riusa lo stesso
% L dell'LQG ed e alimentato dal comando effettivamente applicato.
E=[eye(2) zeros(2)];
Ak=[A-L*C-B*Kx,-B*Ki;zeros(2,16)];
Bk=[zeros(14,2),L;eye(2),-E]; Ck=[-Kx,-Ki]; Dk=zeros(2,6);
Klqgi=ss(Ak,Bk,Ck,Dk);
% Chiuso nominale a 30 stati: impianto (14), integratori (2), stima (14).
AclI=[A,-B*Ki,-B*Kx;-Cq,zeros(2,16);L*C,-B*Ki,A-B*Kx-L*C];
assert(all(real(eig(AclI))<0));
lqgi=struct('K',Klqgi,'Q',Qa,'R',Ri,'Kx',Kx,'Ki',Ki,'residuoCARE',residuoI,'firma',p.firma);
save(fullfile(p.risultati,'lqgi.mat'),'lqgi','-v7');
fprintf('LQGI: 30 poli stabili; CARE %.3g.\n',residuoI);
% Le prove su disturbi, rumore e impianti incerti sono nel confronto comune
% (progetto_mu e confronto_ras): la CARE nominale non certifica robustezza
% o prestazioni temporali.
