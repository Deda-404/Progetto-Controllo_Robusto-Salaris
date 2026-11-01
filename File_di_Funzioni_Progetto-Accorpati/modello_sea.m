%% 1 - Parametri della traccia e punto di equilibrio conservati da main
cartella=fileparts(mfilename('fullpath')); addpath(cartella); p=parametri_sea;
a=load(fullfile(p.dati,'banca_validata.mat'),'banca'); banca=a.banca;
fisica=banca.plant.mechanicalParams; qbar=banca.plant.xbar(1:2);
m1=fisica.m1; m2=fisica.m2; l1=fisica.l1; l2=fisica.l2; g=fisica.g;
Ks=fisica.Ks; Jm=fisica.Jm; Bm=fisica.Bm; I=eye(2); Z=zeros(2);

%% 2 - Equilibrio e linearizzazione delle equazioni SEA originali
% x=[delta q;delta qdot;delta theta;delta thetadot]. Coppie in N m.
Gbar=[(m1+m2)*g*l1*cos(qbar(1))+m2*g*l2*cos(sum(qbar));m2*g*l2*cos(sum(qbar))];
thetabar=qbar+Ks\Gbar; xbar=[qbar;zeros(2,1);thetabar;zeros(2,1)]; taubar=Gbar;
accoppiamento=m2*l1*l2*cos(qbar(2)); distale=m2*l2^2;
Mbar=[(m1+m2)*l1^2+distale+2*accoppiamento,distale+accoppiamento;distale+accoppiamento,distale];
g12=-m2*g*l2*sin(sum(qbar));
Kg=[-(m1+m2)*g*l1*sin(qbar(1))+g12,g12;g12,g12];
Am=[Z I Z Z;-Mbar\(Ks+Kg) Z Mbar\Ks Z;Z Z Z I;Jm\Ks Z -Jm\Ks -Jm\Bm];
Btau=[zeros(6,2);Jm\I]; Bd=[Z;Mbar\I;zeros(4,2)];
Cm=[I zeros(2,6);zeros(2,4) I Z];
meccanica=ss(Am,[Btau Bd],Cm,zeros(4));
assert(all(eig(Mbar)>0) && norm(xbar-banca.plant.xbar)<1e-12);

%% 3 - Due attuatori SISO, senza duplicare le inerzie o il ritardo
s=tf('s'); Dp=(1-p.ritardo*s/2)/(1+p.ritardo*s/2);
H0=p.wn^2/(s^2+2*p.zeta*p.wn*s+p.wn^2); G0=H0*Dp;
attuatori=append(ss(G0),ss(G0));
P0=meccanica*blkdiag(attuatori,I); % [u1 u2 d1 d2] -> [q1 q2 theta1 theta2]
originale=ss(banca.plant.Afull,[banca.plant.Bfull banca.Bd],banca.plant.CfullMeas,zeros(4));
erroreNominale=max(abs(freqresp(P0,p.omega)-freqresp(originale,p.omega)),[],'all');
assert(erroreNominale<p.tolNominale,'SEA:Nominale','Nominale diverso da main.');
modello=struct('fisica',fisica,'xbar',xbar,'taubar',taubar,'Am',Am,'Btau',Btau, ...
    'Bd',Bd,'Cm',Cm,'meccanica',meccanica,'G0',G0,'H0',H0,'Dp',Dp, ...
    'attuatori',attuatori,'P0',P0,'erroreNominale',erroreNominale);
save(fullfile(p.risultati,'modello.mat'),'modello','-v7');
fprintf('Nominale: %d stati; errore rispetto a main %.3g.\n',order(P0),erroreNominale);

%% 4 - Scale dinamiche e sensibilita: cinque valori, un parametro alla volta
valori=linspace(-1,1,5); righe=cell(15,5); curva=0;
for tipo=1:3
    for valore=valori
        wn=p.wn; zeta=p.zeta; ritardo=p.ritardo;
        if tipo==1,wn=wn*(1+p.rwn*valore);end
        if tipo==2,zeta=zeta*(1+p.rzeta*valore);end
        if tipo==3,ritardo=ritardo*(1+.2*valore);end
        Ga=wn^2/(s^2+2*zeta*wn*s+wn^2)*(1-ritardo*s/2)/(1+ritardo*s/2);
        curva=curva+1; risposta=stepinfo(Ga);
        scarto=max(abs(freqresp(Ga,p.omega)./freqresp(G0,p.omega)-1),[],'all');
        righe(curva,:)={tipo,valore,bandwidth(Ga),risposta.Overshoot,scarto};
    end
end
sensibilita=cell2table(righe,'VariableNames',{'Tipo_wn_zeta_ritardo','Delta','Banda','Overshoot','MaxErroreRelativo'});
writetable(sensibilita,fullfile(p.risultati,'sensibilita_attuatori.csv'));
disp(sensibilita);
% Il ritardo resta noto nel confronto A/B: e una restrizione dichiarata.
% Il suo errore di approssimazione non e coperto implicitamente dal peso.
if p.figure
    f=figure('Name','Attuatore nominale e ritardo','Color','w'); theme(f,'light'); tiledlayout(1,2);
    nexttile; step(G0); grid on; title('Risposta nominale, coppia unitaria');
    nexttile; semilogx(p.omega,(-p.ritardo*p.omega+2*atan(p.ritardo*p.omega/2))*180/pi);
    grid on; xlabel('Frequenza [rad/s]'); ylabel('Fase esatto - Pade [gradi]');
    exportgraphics(f,fullfile(p.risultati,'nominale.png'),'Resolution',160);
end
