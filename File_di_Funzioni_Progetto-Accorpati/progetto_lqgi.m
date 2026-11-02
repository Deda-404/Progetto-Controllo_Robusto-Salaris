%% 1 - LQGI: sintesi con carico e pesi conservati
cartella=fileparts(mfilename('fullpath')); addpath(cartella); p=parametri_sea;
a=load(fullfile(p.dati,'banca_validata.mat'),'banca'); banca=a.banca;
a=load(fullfile(p.risultati,'modello.mat')); modello=a.modello;
a=load(fullfile(p.risultati,'lqg.mat')); lqg=a.lqg;
A=modello.Afull; B=modello.Bfull; C=modello.Cfull;
Cq=C(1:2,:); d=banca.lqgi; L=lqg.L;
%% 2 - Stato aumentato [x;xi], xi_dot=r-q_misurata
Aa=[A,zeros(14,2);-Cq,zeros(2)]; Ba=[B;zeros(2)];
Qi=d.wbarI*eye(2); Qa=blkdiag(banca.lqg.Q,Qi); R=d.ru*eye(2);
[Kaug,P,poli]=lqr(Aa,Ba,Qa,R);
Kx=Kaug(:,1:14); Ki=Kaug(:,15:16);
residuo=norm(Aa'*P+P*Aa-P*Ba*(R\Ba')*P+Qa,'fro')/norm(Qa,'fro');
assert(residuo<1e-8 && all(real(poli)<0));
%% 3 - Controllore a 16 stati: osservatore alimentato dal comando effettivo
E=[eye(2) zeros(2)];
Ak=[A-L*C-B*Kx,-B*Ki;zeros(2,16)];
Bk=[zeros(14,2),L;eye(2),-E]; Ck=[-Kx,-Ki]; Dk=zeros(2,6);
Klqgi=ss(Ak,Bk,Ck,Dk);
Acl=[A,-B*Ki,-B*Kx;-Cq,zeros(2,16);L*C,-B*Ki,A-B*Kx-L*C];
assert(all(real(eig(Acl))<0));

lqgi=struct('K',Klqgi,'Q',Qa,'R',R,'Kx',Kx,'Ki',Ki,'residuoCARE',residuo,'firma',p.firma);
save(fullfile(p.risultati,'lqgi.mat'),'lqgi','-v7');
fprintf('LQGI: 30 poli stabili; CARE %.3g.\n',residuo);
%% 4 - Prove su disturbi e attuatori incerti nel confronto comune
% Integratore, osservatore, comando e quattro encoder restano nel chiuso.
% La CARE nominale non certifica robustezza o prestazioni temporali.
