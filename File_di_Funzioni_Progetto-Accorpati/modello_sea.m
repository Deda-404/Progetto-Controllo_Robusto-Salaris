%% 1 - Meccanica assegnata: due sole masse puntiformi
cartella=fileparts(mfilename('fullpath')); addpath(cartella); p=parametri_sea;
a=load(fullfile(p.dati,'banca_validata.mat'),'banca'); banca=a.banca;
fisica=struct('m1',p.m1,'m2',p.m2,'l1',p.l1,'l2',p.l2, ...
    'Jm',p.Jm,'Bm',p.Bm,'Ks',p.Ks,'g',p.g); qbar=p.qbar;
Ks=fisica.Ks; Jm=fisica.Jm; Bm=fisica.Bm; I=eye(2); Z=zeros(2);

%% 2 - Un solo parametro reale per inerzia, gravita e Coriolis
incerta=fisica; incerta.m2=ureal('m2',p.m2,'Percentage',100*p.rm2);
[Mu,~,Gu,Kgu]=matrici_sea(qbar,zeros(2,1),incerta);
Au=[Z I Z Z;-Mu\(Ks+Kgu) Z Mu\Ks Z;Z Z Z I;Jm\Ks Z -Jm\Ks -Jm\Bm];
Btau=[zeros(6,2);Jm\I]; Bdu=[Z;Mu\I;zeros(4,2)];
Cm=[I zeros(2,6);zeros(2,4) I Z];
meccanicaIncerta=ss(Au,[Btau Bdu],Cm,zeros(4));
meccanica=meccanicaIncerta.NominalValue; Am=meccanica.A; Bd=meccanica.B(:,3:4);
[Mbar,~,Gbar,Kg]=matrici_sea(qbar,zeros(2,1),fisica);
thetabar=qbar+Ks\Gbar; xbar=[qbar;zeros(2,1);thetabar;zeros(2,1)]; taubar=Gbar;
assert(all(eig(Mbar)>0));
assert(norm(dinamica_sea(xbar,taubar,zeros(2,1),fisica))<1e-10);
% qbar=[pi/2;0]: gravita nulla per ogni massa, rigidezza gravitazionale non nulla.
assert(norm(usubs(Gu,'m2',p.m2*(1+p.rm2)))<1e-12);

%% 3 - Due drive a tre stati; modello fisico con ordine degli stati esplicito
s=tf('s'); Dp=(1-p.ritardo*s/2)/(1+p.ritardo*s/2);
H0=p.wn^2/(s^2+2*p.zeta*p.wn*s+p.wn^2); G0=H0*Dp;
attuatori=append(ss(G0),ss(G0));
[Aa,Ba,Ca,Da]=ssdata(attuatori);
Afull=[Am Btau*Ca;zeros(6,8) Aa]; Bfull=[Btau*Da;Ba];
Bdfull=[Bd;zeros(6,2)]; Cfull=[Cm zeros(4,6)];
P0=ss(Afull,[Bfull Bdfull],Cfull,zeros(4));
erroreNominale=max(abs(freqresp(P0,p.omega)-freqresp(meccanica*blkdiag(attuatori,I),p.omega)),[],'all');
assert(erroreNominale<p.tolNominale);
% Confronto limitato di variazioni della massa m2, prima di interpretare il nominale.
righe=zeros(numel(p.masseCandidate),5);
for j=1:numel(p.masseCandidate)
    fp=fisica; fp.m2=p.masseCandidate(j);
    [Mj,~,~,Kgj]=matrici_sea(qbar,zeros(2,1),fp);
    Pj=usubs(meccanicaIncerta,'m2',fp.m2)*blkdiag(attuatori,I);
    [~,cl]=interconnessione_sea(Pj,p,4,banca.controllers(1).K);
    righe(j,:)=[fp.m2,fp.m2/fisica.m2,Mj(1,1),norm(Kgj,2),max(real(pole(cl)))];
end
candidati=array2table(righe,'VariableNames',{'Massa2kg','RapportoNominale','M11','NormaKg','PoloLQGFissato'});
writetable(candidati,fullfile(p.risultati,'candidati_massa.csv')); disp(candidati);
modello=struct('fisica',fisica,'xbar',xbar,'taubar',taubar,'Am',Am,'Btau',Btau, ...
    'Bd',Bd,'Cm',Cm,'meccanica',meccanica,'meccanicaIncerta',meccanicaIncerta, ...
    'G0',G0,'H0',H0,'Dp',Dp,'Mbar',Mbar,'Kg',Kg, ...
    'Afull',Afull,'Bfull',Bfull,'Bdfull',Bdfull,'Cfull',Cfull, ...
    'attuatori',attuatori,'P0',P0,'erroreNominale',erroreNominale,'firma',p.firma);
save(fullfile(p.risultati,'modello.mat'),'modello','-v7');
fprintf('Nominale: %d stati; m2 %.1f kg; errore interconnessione %.3g.\n',order(P0),p.m2,erroreNominale);

%% 4 - Scale dinamiche e sensibilita: cinque valori, un parametro alla volta
valori=linspace(-1,1,5); righe=cell(10,5); curva=0; curveSensibilita=cell(10,1);
for tipo=1:2
    for valore=valori
        wn=p.wn; zeta=p.zeta; ritardo=p.ritardo;
        if tipo==1,wn=wn*(1+p.rwn*valore);end
        if tipo==2,ritardo=ritardo*(1+p.rritardo*valore);end
        Ga=wn^2/(s^2+2*zeta*wn*s+wn^2)*(1-ritardo*s/2)/(1+ritardo*s/2);
        curva=curva+1; curveSensibilita{curva}=Ga; risposta=stepinfo(Ga);
        scarto=max(abs(freqresp(Ga,p.omega)./freqresp(G0,p.omega)-1),[],'all');
        righe(curva,:)={tipo,valore,bandwidth(Ga),risposta.Overshoot,scarto};
    end
end
sensibilita=cell2table(righe,'VariableNames',{'Tipo_wn_ritardo','Delta','Banda','Overshoot','MaxErroreRelativo'});
writetable(sensibilita,fullfile(p.risultati,'sensibilita_attuatori.csv'));
disp(sensibilita);
% Il ritardo varia in A e nella famiglia che costruisce il peso B.
% L'errore rispetto al ritardo esatto resta distinto dalla sua variabilita.
if p.figure
    f=figure('Name','Due parametri attuativi','Color','w','Position',[20 20 1100 800]); theme(f,'light'); tiledlayout(2,2);
    etichette=["Frequenza naturale","Ritardo"];
    for tipo=1:2
        for j=1:5
            risposta=squeeze(freqresp(curveSensibilita{5*(tipo-1)+j},p.omega));
            nexttile(2*tipo-1); semilogx(p.omega,20*log10(abs(risposta))); hold on;
            nexttile(2*tipo); semilogx(p.omega,unwrap(angle(risposta))*180/pi); hold on;
        end
        nexttile(2*tipo-1); grid on; xlim([1 1000]); ylabel('Modulo [dB]'); title(etichette(tipo));
        nexttile(2*tipo); grid on; xlim([1 1000]); ylabel('Fase [gradi]'); xlabel('rad/s');
    end
    exportgraphics(f,fullfile(p.risultati,'sensibilita_singoli_parametri.png'),'Resolution',170);
    f=figure('Name','Attuatore nominale e ritardo','Color','w'); theme(f,'light'); tiledlayout(1,2);
    nexttile; step(G0); grid on; title('Risposta nominale, coppia unitaria');
    nexttile; semilogx(p.omega,(-p.ritardo*p.omega+2*atan(p.ritardo*p.omega/2))*180/pi);
    grid on; xlabel('Frequenza [rad/s]'); ylabel('Fase esatto - Pade [gradi]');
    exportgraphics(f,fullfile(p.risultati,'nominale.png'),'Resolution',160);
end
