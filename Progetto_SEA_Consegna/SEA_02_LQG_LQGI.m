%% 1 - Ipotesi: quattro encoder, Q/R e intensita gaussiane consolidate
cartella=fileparts(mfilename('fullpath')); addpath(cartella); p=parametri_sea;
a=load(fullfile(cartella,'dati/banca_consolidata.mat'),'banca'); banca=a.banca;
A=banca.plant.A; B=banca.plant.Bu; Bd=banca.plant.Bd;
C=banca.plant.C; Cq=banca.plant.Cq; n=size(A,1);
Q=banca.lqg.Q; R=banca.lqg.R; Qn=banca.lqg.Qn; Rn=banca.lqg.Rn;
disp('Q e R del costo x''Qx+u''Ru; Qn/Rn del modello bianco continuo:');
disp(Q); disp(R); disp(Qn); disp(Rn);

%% 2 - LQR e Kalman: sintesi esplicite, nessuna misura di velocita
[K,Pcare]=lqr(A,B,Q,R); Nr=-(Cq*((A-B*K)\B))\eye(2);
Gw=[Bd B]; [L,Pkalman]=lqe(A,Gw,C,Qn,Rn);
resCare=norm(A'*Pcare+Pcare*A-Pcare*B*(R\B')*Pcare+Q,'fro')/norm(Q,'fro');
assert(resCare<1e-8 && norm(K-banca.lqg.K,'fro')<1e-6);
assert(norm(L-banca.lqg.L,'fro')<1e-6 && max(real(eig(A-L*C)))<0);
% xc=xhat, ingressi [r;ymis], u=-K*xhat+Nr*r.
Klqg=ss(A-B*K-L*C,[B*Nr L],-K,[Nr zeros(2,4)]);

%% 3 - LQGI: due integrali dell'errore MISURATO, stesso Kalman
Aa=[A zeros(n,2);-Cq zeros(2)]; Ba=[B;zeros(2)];
Qi=banca.lqgi.wbarI*eye(2); Qa=blkdiag(Q,Qi); Ri=banca.lqgi.ru*eye(2);
[Kaug,Pi]=lqr(Aa,Ba,Qa,Ri); Kx=Kaug(:,1:n); Ki=Kaug(:,n+1:end);
Ak=[A-L*C-B*Kx -B*Ki;zeros(2,n+2)];
Bk=[zeros(n,2) L;eye(2) -eye(2) zeros(2)];
Klqgi=ss(Ak,Bk,[-Kx -Ki],zeros(2,6));
assert(norm(Kx-banca.lqgi.Kx,'fro')<1e-6 && norm(Ki-banca.lqgi.Ki,'fro')<1e-6);
resI=norm(Aa'*Pi+Pi*Aa-Pi*Ba*(Ri\Ba')*Pi+Qa,'fro')/norm(Qa,'fro');
assert(resI<1e-8);
e1=max(abs(freqresp(Klqg,p.omega)-freqresp(banca.lqg.Kss,p.omega)),[],'all');
e2=max(abs(freqresp(Klqgi,p.omega)-freqresp(banca.lqgi.Kss,p.omega)),[],'all');
assert(max(e1,e2)<1e-5,'SEA:IdentitaLQG','Realizzazioni diverse dalla banca.');

%% 4 - Cinque prove mirate: tarature alternative, senza cambiare la selezione
% Si varia un solo moltiplicatore, conservando come scelta il punto 1.
fattori=[.5;.75;1;1.5;2]; prove=zeros(5,5);
for j=1:5
    Kj=lqr(A,B,fattori(j)*Q,R); Nrj=-(Cq*((A-B*Kj)\B))\eye(2);
    chiuso=ss(A-B*Kj,B*Nrj,[Cq;-Kj],[zeros(2);Nrj]);
    u=zeros(numel(p.time),2); u(:,1)=p.reference; y=lsim(chiuso,u,p.time);
    Lj=lqe(A,Gw,C,Qn,fattori(j)*Rn);
    % Stessa intensita fisica Rn; cambia soltanto quella assunta dal filtro.
    Perr=lyap(A-Lj*C,Gw*Qn*Gw'+Lj*Rn*Lj');
    prove(j,:)=[fattori(j),min(-real(eig(A-B*Kj))), ...
        max(abs(y(:,3:4)),[],'all'),sqrt(trace(Perr(1:2,1:2))), ...
        min(-real(eig(A-Lj*C)))];
end
scelte=array2table(prove,'VariableNames',{'Fattore','DecadimentoLQR', ...
    'PiccoComandoNm','ErroreStimatoreRMSrad','DecadimentoKalman'});
disp(scelte); writetable(scelte,fullfile(cartella,'dati/scelte_lqg.csv'));
% Le colonne LQR e Kalman sono due sweep distinti, non una taratura congiunta.
lq=struct('Klqg',Klqg,'Klqgi',Klqgi,'Q',Q,'R',R,'Qi',Qi,'Qn',Qn, ...
    'Rn',Rn,'L',L,'K',K,'Nr',Nr,'Kx',Kx,'Ki',Ki,'resCare',resCare, ...
    'resIntegral',resI,'identityError',[e1 e2],'scelte',scelte);
save(fullfile(cartella,'dati/lqg_lqgi.mat'),'lq','-v7');
fprintf('Riccati: %.3g / %.3g; identita LQG/LQGI %.3g / %.3g.\n',resCare,resI,e1,e2);
% Tracking, disturbi, non lineare e RAS sono confrontati per tutti in SEA_05.
