%% 1 - Pulizia e dati: modello -> pesi -> Hinf 1 DoF -> Hinf 2 DoF -> PID
% Tre configurazioni del progetto, in uno script MATLAB con dati del repository.
% La sequenza segue lo stile didattico di progetto_lqg.m e progetto_lqgi.m:
% formule, segnali e verifiche sono accanto ai calcoli che li realizzano.
% Esecuzione: premere Run oppure scrivere progetto_hinf_tre_controllori.
clearvars; clc; close all;
ricalcolaSintesi=false; % true: esegue mixsyn, hinfsyn e la campagna hinfstruct
mostraFigure=true;      % false: calcoli e tabelle, senza aprire figure
% I rami di risintesi sono intenzionalmente inattivi nel default; le sole
% annotazioni UNRCH riguardano questi rami, verificati anche con true.

% Run dall'Editor: percorsi relativi al file, Workspace inizialmente vuoto.
% Dati originali della campagna finale; nessun artifact viene sovrascritto.
% Richiede Control System Toolbox e Robust Control Toolbox (R2025b).
cartellaScript=fileparts(mfilename('fullpath'));
radice=fileparts(cartellaScript);
addpath(fullfile(cartellaScript,'support'));
dati=fullfile(radice,'results','data','hinf_final_coherent');
fileRichiesti={'nominal_study.mat','selected_full_order.mat','fixed_PID.mat'};
for j=1:numel(fileRichiesti)
    file=fullfile(dati,fileRichiesti{j});
    assert(isfile(file),'HinfTre:FileMancante','Artifact necessario mancante: %s',file);
end
nominale=load(fullfile(dati,'nominal_study.mat'),'study');
selezionato=load(fullfile(dati,'selected_full_order.mat'),'selected');
pidArchivio=load(fullfile(dati,'fixed_PID.mat'),'f');
study=nominale.study; selezione2=selezionato.selected;
selezione1=study.one{study.selectedOne}; f=pidArchivio.f;
physical=study.physical;

% Configurazione e specifiche della stessa campagna, non nuovi valori.
c=study.config; specArchivio=study.spec;
cfg.profilo=selezione1.parameters;
cfg.alpha=c.alpha; cfg.omegaM=selezione2.omegaM; cfg.seedPID=f.seed;
cfg.tempo=c.time; cfg.omega=c.omega;
cfg.rAmp=specArchivio.referenceAmplitude; cfg.dAmp=specArchivio.disturbanceTorqueAmplitude;
cfg.uScale=specArchivio.uScale;
cfg.targetM5=[specArchivio.settlingTimeTarget,specArchivio.overshootTarget, ...
    specArchivio.steadyStateTrackingTarget,specArchivio.crossCouplingTarget];
cfg.tolMappe=c.mapTolerance; cfg.tolGamma=c.gammaTolerance;
cfg.tolStabilita=c.stabilityTolerance; cfg.solverRelTol=c.solverRelTol;
cfg.gamma1=selezione1.gamma; cfg.gamma2=selezione2.gamma;
cfg.auditMixsyn=struct('gammaMix',selezione1.gammaMix, ...
    'gammaError',selezione1.audit.gammaError,'plantError',selezione1.audit.plantError, ...
    'mapError',selezione1.audit.mapError,'mixMapError',selezione1.audit.mixMapError, ...
    'normError',selezione1.audit.normError);
origineSintesi="CONTROLLORI ARCHIVIATI DEL PROGETTO";
if ricalcolaSintesi, origineSintesi="NUOVA MIXSYN / HINFSYN / HINFSTRUCT"; end %#ok<UNRCH>
disp(origineSintesi);
tempo=cfg.tempo; omega=cfg.omega;

%% 2 - Modello linearizzato, in deviazione dall'equilibrio
% x=[dq;dqdot;dtheta;dthetadot;xa], 14 stati; qbar=[pi/2;0].
% Le sei coordinate xa appartengono alla realizzazione degli attuatori:
% secondo ordine con ritardo approssimato mediante Pade di ordine 1.
% q in rad, u e d in N m. d e una coppia fisica applicata lato link.
[A,Bfisico,Cq,Dfisico]=ssdata(physical);
B=Bfisico(:,1:2); Bd=Bfisico(:,3:4); n=size(A,1);
G=ss(A,B,Cq,zeros(2)); % pianta da comando u a posizione q
assert(n==14 && isequal(size(physical),[2 4]) && ~any(Dfisico,'all'));
disp('Poli della pianta nominale, prima del controllo:'); disp(eig(A));

%% 3 - Specifiche comuni e provenienza delle scelte
% Gradini separati di 5 deg; disturbo lato link 0.5 N m; stato iniziale nullo.
% Ts<=0.8 s, overshoot<=10%, errore DC<=5%, cross<=25% diagnostico.
% uScale=12 N m e una scala di confronto M5, NON una saturazione hardware.
% Le specifiche M5 restano quelle approvate. Il profilo dei pesi qui usato
% proviene dalla campagna Hinf finale, distinta dalla precedente baseline M5.
ampiezzaR=cfg.rAmp; ampiezzaD=cfg.dAmp; targetM5=cfg.targetM5;
spec=struct('riferimentoDeg',rad2deg(ampiezzaR),'disturboNm',ampiezzaD, ...
    'settlingTime',targetM5(1),'overshootPercent',targetM5(2), ...
    'erroreRelativoDC',targetM5(3),'crossCoupling',targetM5(4),'uScale',cfg.uScale);
disp('Specifiche del confronto:'); disp(spec);

% Obiettivo H-infinity e tre architetture da confrontare
% Hinf minimizza il massimo guadagno energetico della mappa pesata w->z.
% gamma<1 verifica il costo scelto, non tutti i target temporali o robusti.
% 1 DoF: u=Ke*(r-q), S=(I+G*Ke)^-1, T=I-S, KS=Ke*S.
% 2 DoF: u=Kr*r+Ky*q; Kr e Ky possono avere dinamiche diverse.
% PID: struttura diagonale filtrata a 2 DoF, ottimizzata con hinfstruct.
% mixsyn e hinfsyn risolvono lo STESSO problema 1 DoF: non sono due
% configurazioni aggiuntive. I nomi corretti sono mixsyn e hinfsyn.
nomi=["Hinf 1 DoF";"Hinf 2 DoF";"PID migliore (2 DoF)"];
disp(nomi);

%% 4 - W1: peso sull'errore, formula e significato dei parametri
% Profilo 12 selezionato nella campagna: [omegaW1 As Ms ku omegaU].
% W1(0)=1/As; W1(inf)=1/Ms; il profilo desiderato di S e 1/|W1|.
% Il corner omegaW1 non coincide automaticamente con la banda del loop.
profilo=cfg.profilo;
omegaW1=profilo(1); As=profilo(2); Ms=profilo(3);
s=tf('s');
W1s=(s/Ms+omegaW1)/(s+omegaW1*As);
W1=W1s*eye(2);
disp('Parametri W1 [omegaW1 As Ms]:'); disp([omegaW1 As Ms]);

% W2: penalizzazione diretta del comando fisico
% W2(0)=ku e W2(inf)=alpha*ku. Zero omegaU, polo alpha*omegaU.
% W3=[]: non viene aggiunto retroattivamente un peso su T.
ku=profilo(4); omegaU=profilo(5); alpha=cfg.alpha;
W2s=ku*(s+omegaU)/(s/alpha+omegaU);
W2=W2s*eye(2);
disp('Parametri W2 [ku omegaU alpha]:'); disp([ku omegaU alpha]);
fprintf('Guadagni DC W1/W2: %.8g / %.8g.\n',dcgain(W1s),dcgain(W2s));

% Verifica grafica dei pesi usati da tutte le configurazioni
if mostraFigure
    fPesi=figure('Name','Pesi e modello desiderato','Color','white','Theme','light', ...
        'Position',[100 100 1200 400]); pannelliPesi=tiledlayout(fPesi,1,3);
    nexttile(pannelliPesi,1); semilogx(omega,20*log10(squeeze(abs(freqresp(W1s,omega)))));
    grid on; xlabel('Frequenza [rad/s]'); ylabel('|W1| [dB]'); title('Peso sull''errore');
    nexttile(pannelliPesi,2); semilogx(omega,20*log10(squeeze(abs(freqresp(W2s,omega)))));
    grid on; xlabel('Frequenza [rad/s]'); ylabel('|W2| [dB]'); title('Peso sul comando');
end

%% 5 - Pianta generalizzata 1 DoF: segnali e segno del feedback
% w=r, z=[W1*e;W2*u], misura e=r-q, controllo u.
% Identita di trasferimento: P1=[W1,-W1*G;0,W2;I,-G].
% Il blocco P22=-G contiene gia il segno della retroazione negativa.
% connect condivide gli stati della pianta: concatenare direttamente copie
% di G puo introdurre modi instabili nascosti che impediscono hinfsyn.
Gn=G; Gn.InputName={'u(1)','u(2)'}; Gn.OutputName={'q(1)','q(2)'};
W1n=ss(W1); W1n.InputName={'e(1)','e(2)'}; W1n.OutputName={'z1(1)','z1(2)'};
W2n=ss(W2); W2n.InputName={'u(1)','u(2)'}; W2n.OutputName={'z2(1)','z2(2)'};
P1=connect(Gn,W1n,W2n,sumblk('e = r - q',2), ...
    {'r(1)','r(2)','u(1)','u(2)'}, ...
    {'z1(1)','z1(2)','z2(1)','z2(2)','e(1)','e(2)'});
erroreAugw=erroreMappe(P1,augw(G,W1,W2,[]),omega);
assert(erroreAugw<cfg.tolMappe,'HinfTre:Pianta1','P1 diverso da augw.');
audit=struct('erroreAugw',erroreAugw,'nuovaSintesi',ricalcolaSintesi);

%% 6 - mixsyn: sintesi mixed sensitivity a 1 DoF
% [KeMix,CLmix,gammaMix]=mixsyn(G,W1,W2,[],opts) minimizza
% ||[W1*S;W2*KeMix*S]||inf. CLmix e la mappa pesata, non q/r.
% In modalita congelata si espone l'audit realmente eseguito nella campagna.
opts=hinfsynOptions('RelTol',cfg.solverRelTol);
if ricalcolaSintesi
    [KeMix,CLmix,gammaMix]=mixsyn(G,W1,W2,[],opts); %#ok<UNRCH>
    assert(~isempty(KeMix) && isfinite(gammaMix),'HinfTre:Mixsyn','Sintesi senza soluzione.');
else
    gammaMix=cfg.auditMixsyn.gammaMix;
    audit.mixsynStorico=cfg.auditMixsyn;
end
fprintf('mixsyn 1 DoF: gamma=%.10g.\n',gammaMix);

% hinfsyn 1 DoF: stesso problema, pianta generalizzata esplicita
% Le ultime 2 uscite di P1 sono le misure e; gli ultimi 2 ingressi sono u.
% Per questo nmeas=2 e ncont=2. Non si cambia costo passando da mixsyn.
if ricalcolaSintesi
    [Ke,CL1,gamma1]=hinfsyn(P1,2,2,opts); %#ok<UNRCH>
    assert(~isempty(Ke) && isfinite(gamma1),'HinfTre:Sintesi1','Sintesi senza soluzione.');
    emix=valuta_avvio_hinf(physical,KeMix*[eye(2),-eye(2)], ...
        W1,W2,ss(eye(2)),cfg,"1DOF");
    audit.gammaMix=gammaMix;
    audit.scartoGammaMix=abs(gamma1-gammaMix)/gamma1;
    audit.erroreMix=erroreMappe(CLmix,emix.pesato,omega);
    assert(emix.stabile && audit.scartoGammaMix<cfg.tolGamma && ...
        audit.erroreMix<cfg.tolMappe,'HinfTre:Mixsyn','Equivalenza non verificata.');
else
    Ke=selezione1.Kfeedback; gamma1=cfg.gamma1; CL1=lft(P1,Ke);
end
K1=Ke*[eye(2),-eye(2)]; % u=K1*[r;q], con UN solo insieme di stati Ke
fprintf('hinfsyn 1 DoF: gamma=%.10g, ordine=%d.\n',gamma1,order(Ke));

% Realizzazione del controllore 1 DoF e stabilita interna
% xc_dot=Ak1*xc+Bk1*(r-Cq*x), u=Ck1*xc+Dk1*(r-Cq*x).
% La verifica usa tutti gli stati: nessuna cancellazione con minreal.
[Ak1,Bk1,Ck1,Dk1]=ssdata(Ke);
Acl1=[A-B*Dk1*Cq,B*Ck1;-Bk1*Cq,Ak1];
poli1=eig(Acl1);
assert(all(real(poli1)<-cfg.tolStabilita),'HinfTre:NS1','Chiusura 1 DoF instabile.');
fprintf('1 DoF: %d stati chiusi, max Re(poli)=%.9g.\n',size(Acl1,1),max(real(poli1)));

%% 7 - Mo: modello desiderato per il vero controllore 2 DoF
% Mo=omegaM^2/(s^2+2*omegaM*s+omegaM^2)*I2, smorzamento unitario.
% omegaM=4 rad/s e il candidato gia scelto fra 2/3/4 nella campagna finale.
% Mo entra nel COSTO q-Mo*r. Non e un prefiltro applicato dopo la sintesi.
omegaM=cfg.omegaM;
Mo=omegaM^2/(s^2+2*omegaM*s+omegaM^2)*eye(2);
disp('Modello desiderato Mo, guadagno DC:'); disp(dcgain(Mo));
if mostraFigure
    nexttile(pannelliPesi,3);
    semilogx(omega,20*log10(squeeze(abs(freqresp(Mo(1,1),omega)))));
    grid on; xlabel('Frequenza [rad/s]'); ylabel('|Mo| [dB]'); title('Modello desiderato 2 DoF');
end

%% 8 - Pianta generalizzata 2 DoF: riferimento e misura separati
% Ingressi [r;d;u], prestazioni [W1*(q-Mo*r);W2*u], misure [r;q].
% d e la stessa coppia fisica Bd usata nelle prove di reiezione.
% Costo 2 DoF: ||[W1*(T-Mo),W1*QD;W2*UR,W2*UD]||inf.
Pn=physical; Pn.InputName={'u(1)','u(2)','d(1)','d(2)'};
Pn.OutputName={'q(1)','q(2)'};
Mon=ss(Mo); Mon.InputName={'r(1)','r(2)'}; Mon.OutputName={'qm(1)','qm(2)'};
W1n=ss(W1); W1n.InputName={'em(1)','em(2)'}; W1n.OutputName={'ze(1)','ze(2)'};
W2n=ss(W2); W2n.InputName={'u(1)','u(2)'}; W2n.OutputName={'zu(1)','zu(2)'};
P2=connect(Pn,Mon,W1n,W2n,sumblk('em = q - qm',2), ...
    {'r(1)','r(2)','d(1)','d(2)','u(1)','u(2)'}, ...
    {'ze(1)','ze(2)','zu(1)','zu(2)','r(1)','r(2)','q(1)','q(2)'});

%% 9 - hinfsyn 2 DoF: quattro misure, due comandi
% nmeas=4 per [r1;r2;q1;q2], ncont=2 per [u1;u2].
% K2=[Kr Ky]: Ky incorpora il proprio segno di feedback.
if ricalcolaSintesi
    [K2,CL2,gamma2]=hinfsyn(P2,4,2,opts); %#ok<UNRCH>
    assert(~isempty(K2) && isfinite(gamma2),'HinfTre:Sintesi2','Sintesi senza soluzione.');
else
    K2=selezione2.K; gamma2=cfg.gamma2; CL2=lft(P2,K2);
end
Kr=K2(:,1:2); Ky=K2(:,3:4);
fprintf('hinfsyn 2 DoF: gamma=%.10g, ordine=%d.\n',gamma2,order(K2));

% Realizzazione 2 DoF: gli stati di Kr e Ky sono condivisi
% xc_dot=Ak2*xc+Br2*r+Bq2*q, u=Ck2*xc+Dr2*r+Dq2*q.
% Kr e Ky sopra servono a leggere i trasferimenti, non a duplicare il
% controllore nella chiusura. Acl2 usa una sola realizzazione ss(K2).
[Ak2,Bk2,Ck2,Dk2]=ssdata(K2);
Br2=Bk2(:,1:2); Bq2=Bk2(:,3:4); Dr2=Dk2(:,1:2); Dq2=Dk2(:,3:4);
Acl2=[A+B*Dq2*Cq,B*Ck2;Bq2*Cq,Ak2];
poli2=eig(Acl2);
assert(all(real(poli2)<-cfg.tolStabilita),'HinfTre:NS2','Chiusura 2 DoF instabile.');
fprintf('2 DoF: %d stati chiusi, max Re(poli)=%.9g.\n',size(Acl2,1),max(real(poli2)));

%% 10 - PID strutturato: formula, filtraggio e ordine dei segnali
% Per ogni giunto:
% u=Kp*(b*r-q)+Ki/s*(r-q)+Kd*s/(1+Tf*s)*(c*r-q).
% b e c pesano il setpoint; Tf filtra la derivata. Due PID diagonali a 2 DoF.
% Dopo blkdiag l'ordine e [r1 q1 r2 q2]: si riordina in [r1 r2 q1 q2].
% Il PID usa lo STESSO P2, W1, W2 e Mo del controllore Hinf 2 DoF.
if ricalcolaSintesi
    Kt=blkdiag(tunablePID2('joint1','PID'),tunablePID2('joint2','PID')); %#ok<UNRCH>
    Kt=Kt(:,[1 3 2 4]);
end

% hinfstruct: undici avvii e scelta del migliore PID valido
% Un avvio iniziale e dieci casuali; seed originale, 300 iterazioni richieste.
% Prima si verificano stabilita, identita LFT e accordo obiettivo/norma;
% poi si minimizza Objective fra i validi. Non e un minimo globale.
% Non si confrontano le norme di vecchie campagne con problemi diversi.
if ricalcolaSintesi
    statoRng=rng; rng(cfg.seedPID,'twister'); %#ok<UNRCH>
    optsPID=hinfstructOptions('Display','final','RandomStart',10, ...
        'MaxIter',300,'UseParallel',false);
    try
        [~,~,infoPID]=hinfstruct(lft(P2,Kt),optsPID);
    catch err
        rng(statoRng); rethrow(err);
    end
    rng(statoRng);
    [Kpid,provePID,parametriPID]=seleziona_pid_hinf(infoPID,Kt,physical,P2,W1,W2,Mo,cfg);
else
    % Stessa selezione fra gli undici avvii salvati: minimo fra i validi.
    avvii=numel(f.runs); obiettivo=inf(avvii,1); norma=obiettivo; valida=false(avvii,1);
    for j=1:avvii
        obiettivo(j)=f.runs{j}.objective; valida(j)=f.runs{j}.valid;
        if valida(j), norma(j)=f.runs{j}.e.norms(1); end
    end
    ammessi=find(valida); [~,indice]=min(obiettivo(ammessi)); migliore=ammessi(indice);
    selezionata=false(avvii,1); selezionata(migliore)=true;
    provePID=table((1:avvii)',obiettivo,norma,valida,selezionata, ...
        'VariableNames',{'Avvio','Obiettivo','Norma','Valida','Selezionata'});
    parametriPID=parametri_pid_hinf(f.info(migliore).TunedBlocks);
    % pid2 riproduce la realizzazione del precedente script senza variazioni
    % di arrotondamento della conversione tunablePID2 -> ss archiviata.
    p=table2array(parametriPID);
    pid1=pid2(p(1,1),p(1,2),p(1,3),p(1,4),p(1,5),p(1,6));
    pid2joint=pid2(p(2,1),p(2,2),p(2,3),p(2,4),p(2,5),p(2,6));
    Kpid=blkdiag(ss(pid1),ss(pid2joint)); Kpid=Kpid(:,[1 3 2 4]);
end
gammaPID=provePID.Obiettivo(provePID.Selezionata);
disp('Avvii PID: validita, obiettivo, norma ricostruita e selezione:'); disp(provePID);
disp('Coefficienti del PID selezionato:'); disp(parametriPID);

%% 11 - Chiusura comune dei tre controllori: riferimento e disturbo fisico
% Per K=[Kr Ky], z=[x;xc], q=Cq*x:
% Acl=[A+B*Dq*Cq B*Ck; Bq*Cq Ak], Brcl=[B*Dr;Br], Bdcl=[Bd;0].
% Uscite comuni [q;u]. Si usa l'intero stato, senza riduzioni o minreal.
controllori={K1,K2,Kpid}; gammaSintesi=[gamma1;gamma2;gammaPID];
valutazioni=cell(3,1);
for k=1:3
    [Ak,Bk,Ck,Dk]=ssdata(controllori{k}); nk=size(Ak,1);
    assert(isequal(size(controllori{k}),[2 4]));
    Brk=Bk(:,1:2); Bqk=Bk(:,3:4); Dr=Dk(:,1:2); Dq=Dk(:,3:4);
    Acl=[A+B*Dq*Cq,B*Ck;Bqk*Cq,Ak];
    Ccl=[Cq,zeros(2,nk);Dq*Cq,Ck];
    riferimento=ss(Acl,[B*Dr;Brk],Ccl,[zeros(2);Dr]);
    disturbo=ss(Acl,[Bd;zeros(nk,2)],Ccl,zeros(4,2));
    e=struct('Acl',Acl,'poli',eig(Acl),'riferimento',riferimento,'disturbo',disturbo);
    e.maxRePolo=max(real(e.poli)); e.stabile=e.maxRePolo<-cfg.tolStabilita;
    assert(e.stabile,'HinfTre:NS','Chiusura interna instabile: %s.',nomi(k));
    e.T=riferimento(1:2,:); e.UR=riferimento(3:4,:);
    e.QD=disturbo(1:2,:); e.UD=disturbo(3:4,:);
    % Iniezione fittizia all'errore di feedback, distinta dalla coppia Bd.
    feedbackReference=ss(Acl,[-B*Dq;-Bqk],Ccl,[zeros(2);-Dq]);
    e.S=eye(2)-feedbackReference(1:2,:); e.KS=feedbackReference(3:4,:);
    e.Tfeedback=eye(2)-e.S;
    valutazioni{k}=e;
end
assert(norm(Acl1-valutazioni{1}.Acl,'fro')<1e-10);
assert(norm(Acl2-valutazioni{2}.Acl,'fro')<1e-10);

% Gamma ricostruita e verifica indipendente delle mappe LFT
% 1 DoF: ||[W1*S;W2*UR]||inf. 2 DoF/PID: costo con [r;d] e Mo.
% Le norme 1-/2-DoF appartengono a problemi diversi: non si interpreta
% la loro differenza come miglioramento percentuale della stessa funzione.
mappeLft={CL1,CL2,lft(P2,Kpid)};
for k=1:3
    e=valutazioni{k};
    if k==1
        e.pesato=[W1*(eye(2)-e.T);W2*e.UR];
    else
        e.pesato=[W1*(e.T-Mo),W1*e.QD;W2*e.UR,W2*e.UD];
    end
    e.norma=norm(e.pesato,inf);
    audit.erroreLft(k,1)=erroreMappe(mappeLft{k},e.pesato,omega);
    assert(abs(e.norma/gammaSintesi(k)-1)<cfg.tolGamma, ...
        'HinfTre:Norma','Norma incoerente: %s.',nomi(k));
    assert(audit.erroreLft(k)<cfg.tolMappe,'HinfTre:LFT','Mappa LFT incoerente.');
    fprintf('%s: norma=%.10g, errore LFT=%.3g.\n',nomi(k),e.norma,audit.erroreLft(k));
    valutazioni{k}=e;
end

%% 12 - Tracking: due gradini separati e metriche temporali esplicite
% Ts: banda 2% dell'ampiezza richiesta attorno al valore DC.
% Overshoot rispetto al riferimento; errore statico rispetto al guadagno 1.
% Cross: picco giunto non comandato / picco giunto comandato.
% Picco e RMS: entrambi i comandi; RMS sull'intero intervallo 0:0.002:12 s.
for k=1:3
    e=valutazioni{k}; dc=dcgain(e.T);
    e.metriche=zeros(2,6); e.risposte=cell(2,1);
    for j=1:2
        r=zeros(numel(tempo),2); r(:,j)=ampiezzaR;
        y=lsim(e.riferimento,r,tempo); e.risposte{j}=y;
        finale=dc(j,j)*ampiezzaR;
        ultimo=find(abs(y(:,j)-finale)>.02*ampiezzaR,1,'last');
        ts=0;
        if ~isempty(ultimo)
            ts=inf;
            if ultimo<numel(tempo), ts=tempo(ultimo+1); end
        end
        e.metriche(j,:)=[ts,100*max(0,max(y(:,j))/ampiezzaR-1), ...
            abs(dc(j,j)-1),max(abs(y(:,3-j)))/max(max(abs(y(:,j))),eps), ...
            max(abs(y(:,3:4)),[],'all'),sqrt(mean(y(:,3:4).^2,'all'))];
    end
    v=max(e.metriche,[],1); e.fallimentiM5=sum(v(1:4)>targetM5);
    valutazioni{k}=e;
end

% Tracking e comando: stessi scenari per le tre configurazioni
colori=lines(3);
if mostraFigure
    figure('Name','Tracking e comando - tre configurazioni','Color','white', ...
        'Theme','light','Position',[100 100 1200 900]); tiledlayout(4,2,'TileSpacing','compact');
    for uscita=1:4
        for j=1:2
            nexttile; hold on;
            for k=1:3
                y=valutazioni{k}.risposte{j}(:,uscita);
                if uscita<=2, y=rad2deg(y); end
                plot(tempo,y,'Color',colori(k,:),'LineWidth',1.2);
            end
            if uscita<=2
                yline(rad2deg(ampiezzaR)*(uscita==j),'k--','HandleVisibility','off');
                ylabel(sprintf('Delta q_%d [deg]',uscita));
            else
                ylabel(sprintf('u_%d [N m]',uscita-2));
            end
            grid on; xlabel('Tempo [s]'); title(sprintf('Gradino r_%d = 5 deg',j));
            if uscita==1 && j==1, legend(nomi,'Location','best'); end
        end
    end
end

% Reiezione del disturbo: coppia applicata lato link, riferimento nullo
% Picco e residuo DC di q in rad, picco e RMS di u in N m.
% La prova usa Bd fisico: non viene sostituita da un disturbo additivo su q.
for k=1:3
    e=valutazioni{k}; e.risposteDisturbo=cell(2,1); e.metricheDisturbo=zeros(2,4);
    for j=1:2
        d=zeros(numel(tempo),2); d(:,j)=ampiezzaD;
        yd=lsim(e.disturbo,d,tempo); e.risposteDisturbo{j}=yd;
        e.metricheDisturbo(j,:)=[max(abs(yd(:,1:2)),[],'all'), ...
            max(abs(dcgain(e.QD(:,j))*ampiezzaD)), ...
            max(abs(yd(:,3:4)),[],'all'),sqrt(mean(yd(:,3:4).^2,'all'))];
    end
    valutazioni{k}=e;
end
if mostraFigure
    figure('Name','Coppia disturbante lato link','Color','white', ...
        'Theme','light','Position',[100 100 1000 650]); tiledlayout(2,2,'TileSpacing','compact');
    for uscita=1:2
        for j=1:2
            nexttile; hold on;
            for k=1:3
                plot(tempo,rad2deg(valutazioni{k}.risposteDisturbo{j}(:,uscita)), ...
                    'Color',colori(k,:),'LineWidth',1.2);
            end
            grid on; xlabel('Tempo [s]'); ylabel(sprintf('Delta q_%d [deg]',uscita));
            title(sprintf('d_%d = %.2f N m, r=0',j,ampiezzaD));
            if uscita==1 && j==1, legend(nomi,'Location','best'); end
        end
    end
end

%% 13 - Sensibilita del feedback e trasferimento di tracking
% S e KS descrivono il feedback; T qui e il trasferimento effettivo r->q.
% Nel 2 DoF T non coincide necessariamente con I-S: si conserva separatamente
% Tfeedback=I-S. Il grafico riporta sigma massima, non ogni canale MIMO.
if mostraFigure
    figure('Name','Sensibilita del feedback e tracking','Color','white', ...
        'Theme','light','Position',[100 100 1200 400]); tiledlayout(1,3);
    campi={'S','T','KS'}; titoli={'S feedback','T riferimento -> q','KS feedback'};
    for j=1:3
        nexttile; hold on;
        for k=1:3
            sv=sigma(valutazioni{k}.(campi{j}),omega);
            semilogx(omega,20*log10(max(sv(1,:),realmin)), ...
                'Color',colori(k,:),'LineWidth',1.2);
        end
        set(gca,'XScale','log'); grid on;
        xlabel('Frequenza [rad/s]'); ylabel('sigma max [dB]'); title(titoli{j});
        if j==1, legend(nomi,'Location','best'); end
    end
end

% Riepilogo: stabilita, costo Hinf e target M5 distinti
% Tutte le metriche sono il peggiore dei due gradini, a parita di scenario.
% PID e Hinf 2 DoF condividono il problema P2; il costo 1 DoF e distinto.
numeri=zeros(3,10);
for k=1:3
    e=valutazioni{k}; v=max(e.metriche,[],1);
    numeri(k,:)=[order(controllori{k}),e.maxRePolo,e.norma,v,e.fallimentiM5];
end
confronto=array2table(numeri,'VariableNames', ...
    {'Ordine','MaxRePolo','NormaPropria','Ts_s','Overshoot_pct', ...
    'ErroreRelativoDC','CrossCoupling','PiccoU_Nm','RmsU_Nm','TargetM5Falliti'});
confronto=addvars(confronto,nomi,'Before',1,'NewVariableNames','Controllore');
confronto.NS=cellfun(@(e) e.stabile,valutazioni);
confronto.NP=confronto.NS & confronto.NormaPropria<1;
confronto.TargetTemporaliM5=confronto.NS & confronto.TargetM5Falliti==0;
disp(confronto);
fprintf('Target M5: Ts<=%.3g s, OS<=%.3g%%, errore DC<=%.3g, cross<=%.3g.\n',targetM5);

% Risultati nel Workspace e limiti del confronto
% Come negli script LQG/LQGI, matrici e variabili rimangono ispezionabili.
% Il confronto e lineare nominale, continuo, senza saturazioni e da stato zero.
% Non aggiunge validazioni non lineari, RAS o certificati di robustezza.
% PASS implementativo non significa che tutti i target M5 siano soddisfatti.
risultati=struct('configurazione',cfg,'pianta',physical,'W1',W1,'W2',W2, ...
    'Mo',Mo,'K_1DoF',K1,'Ke_1DoF',Ke,'K_2DoF',K2,'K_PID',Kpid, ...
    'valutazioni',{valutazioni},'confronto',confronto,'provePID',provePID, ...
    'parametriPID',parametriPID,'audit',audit,'qualityGate',"PASS", ...
    'stato',"COMPLETE - confronto nominale");
fprintf('Confronto nominale completato; esiti M5 visibili nella tabella.\n');

function err=erroreMappe(prima,seconda,omega)
% Confronto dei trasferimenti, senza cambiare le basi di stato.
err=max(abs(freqresp(prima,omega)-freqresp(seconda,omega)),[],'all');
end
