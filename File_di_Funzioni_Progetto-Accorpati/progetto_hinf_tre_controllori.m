%% PROGETTO_HINF_TRE_CONTROLLORI - mixsyn, hinfsyn e hinfstruct (Capitolo 8)
%
% Obiettivo (punto 2 della traccia): tre controllori H-infinito con gli
% stessi pesi We e Wu, per confrontare comandi e architetture.
%
%   Hinf1: 1-DoF, mixed sensitivity. Il controllore vede solo l'errore
%          e=r-q e minimizza || [We*S ; Wu*K*S] ||_inf, con S=(I+GK)^-1.
%          Si risolve lo stesso problema con mixsyn e con hinfsyn: i due
%          gamma devono coincidere (verifica di coerenza fra i comandi).
%   Hinf2: 2-DoF, hinfsyn sulla pianta generalizzata comune
%          (interconnessione_sea): il controllore riceve r e q separatamente
%          e insegue il modello desiderato Mo, con disturbo d in ingresso.
%   PID:   hinfstruct sulla stessa pianta di Hinf2, ma con struttura fissata
%          a due PID 2-DoF indipendenti (uno per giunto). Il problema non e
%          convesso: si usano avvii casuali e il risultato e un ottimo locale.
%
% gamma = valore ottimo della norma H-infinito del canale pesato: gamma<1
% significa che tutti i requisiti pesati sono soddisfatti sul nominale.
%
% Modalita rapida: carica i controllori salvati (con controllo di firma).
% Modalita completa: rifa le tre sintesi.
% Salva: risultati/sintesi_hinf.mat, hinf.csv, sensibilita_hinf.png.

%% 1 - Modello nominale e pesi
cartella=fileparts(mfilename('fullpath')); addpath(cartella); p=parametri_sea;
if ~isfile(fullfile(p.risultati,'modello.mat')),run(fullfile(cartella,'modello_sea.m'));end
a=load(fullfile(p.risultati,'modello.mat')); modello=a.modello;
a=load(fullfile(p.dati,'banca_validata.mat')); banca=a.banca;
G=modello.P0(1:2,1:2); s=tf('s');  % da [u1 u2] a [q1 q2], 14 stati
% W1=We: peso sull'errore, grande a bassa frequenza (precisione statica).
% W2=Wu: peso sul comando, cresce ad alta frequenza (limita banda e rumore).
W1=(s/p.Ms+p.omegaW1)/(s+p.omegaW1*p.As)*eye(2);
W2=p.ku*(s+p.omegaU)/(s/p.alpha+p.omegaU)*eye(2);

%% 2 - Pianta generalizzata del problema 1-DoF e del problema 2-DoF
% 1 DoF: u=Ke*(r-q), costo [W1*S;W2*Ke*S]. W3 (peso su T) resta assente.
% connect collega i blocchi per nome di segnale; sumblk definisce i nodi
% sommatori. P1 ha ingressi [r;u] e uscite [ze;zu;e].
Gn=G; Gn.InputName={'u1','u2'}; Gn.OutputName={'q1','q2'};
We=ss(W1); We.InputName={'e1','e2'}; We.OutputName={'ze1','ze2'};
Wu=ss(W2); Wu.InputName={'u1','u2'}; Wu.OutputName={'zu1','zu2'};
P1=connect(Gn,We,Wu,sumblk('e1=r1-q1'),sumblk('e2=r2-q2'), ...
    {'r1','r2','u1','u2'},{'ze1','ze2','zu1','zu2','e1','e2'});
% augw costruisce la stessa pianta della mixed sensitivity: verifica.
erroreAugw=max(abs(freqresp(P1,p.omega)-freqresp(augw(G,W1,W2,[]),p.omega)),[],'all');
assert(erroreAugw<1e-8);
% 2 DoF: [r;d;u] -> [We*(q-Mo*r); Wu*u; r; q]  (vedi interconnessione_sea).
P2=interconnessione_sea(modello.P0,p,2);

%% 3 - Sintesi (completa) oppure caricamento dei controllori salvati (rapida)
if p.modalita=="completa"
    statoRng=rng; rng(p.seed,'twister');
    opt=hinfsynOptions('RelTol',banca.hinfConfig.solverRelTol);
    % mixsyn(G,W1,W2,W3): sintesi mixed sensitivity diretta, restituisce
    % il controllore sull'errore e il gamma ottenuto.
    [KeMix,~,gammaMix]=mixsyn(G,W1,W2,[],opt);
    % hinfsyn(P,ny,nu): sintesi H-infinito su una pianta generalizzata con
    % ny misure e nu comandi (le ultime uscite/ingressi di P). Restituisce
    % il controllore, il chiuso pesato CL e gamma = ||CL||_inf.
    [Ke,CL1,gamma1]=hinfsyn(P1,2,2,opt);
    [K2,CL2,gamma2]=hinfsyn(P2,4,2,opt);
    assert(isfinite(gamma1) && isfinite(gamma2) && isstable(CL1) && isstable(CL2));
    scartoGamma=abs(gammaMix-gamma1)/max(gammaMix,gamma1);
    assert(scartoGamma<.02,'SEA:Mixsyn','Metodi non concordi sul medesimo costo.');
    % Il controllore 1-DoF viene riscritto nella forma comune a ingressi
    % [r;q]: u = Ke*(r - q) = [Ke  -Ke]*[r; q].
    K1=Ke*[eye(2) -eye(2)];
    % tunablePID2: PID a due gradi di liberta con parametri da ottimizzare,
    %   u = Kp(b r - y) + Ki/s (r - y) + Kd s/(Tf s+1) (c r - y).
    % hinfstruct minimizza la norma H-infinito del chiuso lft(P2,Kt)
    % rispetto ai soli parametri dei due PID.
    Kt=blkdiag(tunablePID2('giunto1','PID'),tunablePID2('giunto2','PID'));
    Kt=Kt(:,[1 3 2 4]);  % riordino ingressi in [r1 r2 q1 q2]
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

%% 4 - Confronto comune: stabilita, norma pesata, S, T e rumore -> comando
% Tutti e tre i controllori vengono chiusi sulla stessa pianta 2-DoF e
% valutati con la stessa mappa [r;d] -> [ze;zu] (NormaComune), cosi il
% confronto non dipende dal problema usato per la sintesi.
% Canali del chiuso CL: ingressi [r1 r2 d1 d2 v1 v2], uscite
% [q1 q2 u1 u2 ze1 ze2 zu1 zu2]; v e il rumore sulle misure di posizione.
controllori={K1,K2,Kpid}; nomi=["Hinf1";"Hinf2";"PID_nuovo"]; righe=cell(3,5);
colori=lines(3);
if p.figure,f=figure('Name','H-infinity: S e T','Color','w'); theme(f,'light'); tiledlayout(1,2);end
for j=1:3
    [~,chiuso]=interconnessione_sea(modello.P0,p,2,controllori{j});
    NS=isstable(chiuso); gammaComune=norm(chiuso(5:8,1:4),inf);
    % Il rumore v entra come la misura: q_misurata = q + v. Quindi la
    % mappa v -> q vale -T e S = I + (v -> q).
    S=eye(2)+chiuso(1:2,5:6); T=-chiuso(1:2,5:6);
    % ||v -> u||_inf: quanto il comando amplifica il rumore di misura.
    righe(j,:)={nomi(j),order(controllori{j}),NS,gammaComune,norm(chiuso(3:4,5:6),inf)};
    if p.figure
        % sigma: valori singolari in frequenza (guadagni MIMO).
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
