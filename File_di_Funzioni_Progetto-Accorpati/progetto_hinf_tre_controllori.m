%% 1 - Modello e pesi della formulazione H-infinity gia sviluppata
cartella=fileparts(mfilename('fullpath')); addpath(cartella); p=parametri_sea;
if ~isfile(fullfile(p.risultati,'modello.mat')),run(fullfile(cartella,'modello_sea.m'));end
a=load(fullfile(p.risultati,'modello.mat')); modello=a.modello;
a=load(fullfile(p.dati,'banca_validata.mat')); banca=a.banca;
G=modello.P0(1:2,1:2); s=tf('s');
W1=(s/p.Ms+p.omegaW1)/(s+p.omegaW1*p.As)*eye(2);
W2=p.ku*(s+p.omegaU)/(s/p.alpha+p.omegaU)*eye(2);

%% 2 - Mixed sensitivity: medesimo problema risolto con due metodi
% 1 DoF: u=Ke*(r-q), costo [W1*S;W2*Ke*S]. W3 resta assente.
Gn=G; Gn.InputName={'u1','u2'}; Gn.OutputName={'q1','q2'};
We=ss(W1); We.InputName={'e1','e2'}; We.OutputName={'ze1','ze2'};
Wu=ss(W2); Wu.InputName={'u1','u2'}; Wu.OutputName={'zu1','zu2'};
P1=connect(Gn,We,Wu,sumblk('e1=r1-q1'),sumblk('e2=r2-q2'), ...
    {'r1','r2','u1','u2'},{'ze1','ze2','zu1','zu2','e1','e2'});
erroreAugw=max(abs(freqresp(P1,p.omega)-freqresp(augw(G,W1,W2,[]),p.omega)),[],'all');
assert(erroreAugw<1e-8);
P2=interconnessione_sea(modello.P0,p,2);
%% 3 - Rapida: risultati coerenti; completa: sintesi sul nominale corrente
if p.modalita=="completa"
    statoRng=rng; rng(p.seed,'twister');
    opt=hinfsynOptions('RelTol',banca.hinfConfig.solverRelTol);
    [KeMix,~,gammaMix]=mixsyn(G,W1,W2,[],opt);
    [Ke,CL1,gamma1]=hinfsyn(P1,2,2,opt);
    [K2,CL2,gamma2]=hinfsyn(P2,4,2,opt);
    assert(isfinite(gamma1) && isfinite(gamma2) && isstable(CL1) && isstable(CL2));
    scartoGamma=abs(gammaMix-gamma1)/max(gammaMix,gamma1);
    assert(scartoGamma<.02,'SEA:Mixsyn','Metodi non concordi sul medesimo costo.');
    K1=Ke*[eye(2) -eye(2)];
    Kt=blkdiag(tunablePID2('giunto1','PID'),tunablePID2('giunto2','PID'));
    Kt=Kt(:,[1 3 2 4]);
    [Ktuned,gammaPID,infoPID]=hinfstruct(lft(P2,Kt), ...
        hinfstructOptions('Display','final','RandomStart',p.pidAvvii,'MaxIter',300));
    b1=getBlockValue(Ktuned,'giunto1'); b2=getBlockValue(Ktuned,'giunto2');
    Kpid=blkdiag(ss(b1),ss(b2)); Kpid=Kpid(:,[1 3 2 4]); rng(statoRng);
    origine="NUOVE SINTESI, stessi pesi; candidati separati";
    sintesi=struct('K1',K1,'K2',K2,'Kpid',Kpid,'KeMix',KeMix, ...
        'gamma',[gammaMix gamma1 gamma2 gammaPID],'scartoGamma',scartoGamma, ...
        'infoPID',infoPID,'origine',origine,'seed',p.seed,'firma',p.firma);
    save(fullfile(p.risultati,'sintesi_hinf.mat'),'sintesi','-v7');
else
    fileH=fullfile(p.risultati,'sintesi_hinf.mat');
    if ~isfile(fileH),fileH=fullfile(p.dati,'sintesi_hinf.mat');end
    assert(isfile(fileH),'SEA:Cache','Sintesi assente: eseguire completa.');
    a=load(fileH); assert(isfield(a.sintesi,'firma') && isequal(a.sintesi.firma,p.firma),'SEA:Cache','Sintesi non coerente: eseguire completa.');
    origine="CARICATI DALLA CAMPAGNA COMPLETA, nessuna nuova sintesi";
    K1=a.sintesi.K1; K2=a.sintesi.K2; Kpid=a.sintesi.Kpid;
end
disp(origine);
%% 4 - Sensitivita, complementarita e comando rumoroso
controllori={K1,K2,Kpid}; nomi=["Hinf1";"Hinf2";"PID_nuovo"]; righe=cell(3,5);
colori=lines(3);
if p.figure,f=figure('Name','H-infinity: S e T','Color','w'); theme(f,'light'); tiledlayout(1,2);end
for j=1:3
    [~,chiuso]=interconnessione_sea(modello.P0,p,2,controllori{j});
    NS=isstable(chiuso); gammaComune=norm(chiuso(5:8,1:4),inf);
    S=eye(2)+chiuso(1:2,5:6); T=-chiuso(1:2,5:6);
    righe(j,:)={nomi(j),order(controllori{j}),NS,gammaComune,norm(chiuso(3:4,5:6),inf)};
    if p.figure
        nexttile(1); semilogx(p.omega,squeeze(sigma(S,p.omega)),'Color',colori(j,:),'LineWidth',1); hold on;
        nexttile(2); semilogx(p.omega,squeeze(sigma(T,p.omega)),'Color',colori(j,:),'LineWidth',1); hold on;
    end
end
tabella=cell2table(righe,'VariableNames',{'Controllore','Ordine','NS','NormaComune','GuadagnoRumoreComando'});
writetable(tabella,fullfile(p.risultati,'hinf.csv')); disp(tabella);
if p.figure
    nexttile(1); grid on; xlabel('rad/s'); ylabel('Valori singolari S'); legend('Hinf1','','Hinf2','','PID','');
    nexttile(2); grid on; xlabel('rad/s'); ylabel('Valori singolari T'); legend('Hinf1','','Hinf2','','PID','');
    exportgraphics(f,fullfile(p.risultati,'sensibilita_hinf.png'),'Resolution',170);
end
