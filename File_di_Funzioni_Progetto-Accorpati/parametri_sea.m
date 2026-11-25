function p=parametri_sea
%PARAMETRI_SEA Unica configurazione del progetto (Capitoli 2, 4, 5 e 6).
%
% Restituisce la struttura p con tutti i parametri fisici, le incertezze,
% le specifiche, i pesi prestazionali, le griglie di frequenza/tempo e il
% seed. Ogni script chiama parametri_sea come prima istruzione: nessun
% numero del modello viene ripetuto altrove, quindi una modifica fatta qui
% si propaga in modo coerente a sintesi, analisi, simulazioni e Simulink.
%
% La funzione aggiunge anche al path la sottocartella supporto/, che
% contiene le poche funzioni condivise fra piu script (equazioni del
% manipolatore, pianta generalizzata, simulatore non lineare, ...).

%% Cartelle e modalita di esecuzione
p.cartella=fileparts(mfilename('fullpath'));
addpath(fullfile(p.cartella,'supporto'));
p.dati=fullfile(p.cartella,'dati');            % controllori di riferimento fissati
p.risultati=fullfile(p.cartella,'risultati');  % CSV, MAT e figure generati
if ~isfolder(p.risultati),mkdir(p.risultati);end
% run_all('rapida') o run_all('completa') comunica la modalita tramite una
% variabile d'ambiente: cosi gli script restano eseguibili anche da soli
% (in tal caso vale la modalita rapida).
p.modalita=string(getenv('SEA_MODALITA'));
if p.modalita=="",p.modalita="rapida";end
assert(ismember(p.modalita,["rapida","completa"]),'SEA:Modo','Usare rapida o completa.');
p.figure=~strcmp(getenv('SEA_FIGURE'),'off'); % SEA_FIGURE=off disattiva i grafici
p.seed=20261101;   % seed unico di tutte le procedure casuali (usample, rumore)
p.campioni=10;     % numero di impianti incerti comuni (punto 5 della traccia)

%% Meccanica del manipolatore 2R (Tabella 1 della traccia)
% Masse puntiformi all'estremita dei link. Solo m2 e incerta (+-10%):
% compare in tutti gli elementi di M(q), in C(q,qdot) e in G(q), quindi e il
% parametro meccanico con il maggior numero di occorrenze e rappresenta un
% carico trasportato variabile. m1, l1, l2, Jm, Bm e Ks sono considerati noti.
p.m1=1;      % [kg]  massa del primo link
p.m2=.8;     % [kg]  massa del secondo link (nominale)
p.rm2=.10;   % [-]   incertezza relativa di m2: intervallo [0.72, 0.88] kg
p.l1=.4;     % [m]   lunghezza del primo link
p.l2=.3;     % [m]   lunghezza del secondo link
p.g=9.81;    % [m/s^2]
p.Jm=.01*eye(2);     % [kg m^2]     inerzie dei rotori, diag(Jm1,Jm2)
p.Bm=.02*eye(2);     % [N m s/rad]  smorzamenti viscosi dei motori
p.Ks=diag([50 40]);  % [N m/rad]    rigidezze delle molle SEA, diag(k1,k2)
p.qbar=[pi/2;0];     % [rad]        equilibrio: braccio verticale disteso
p.masseCandidate=p.m2*[1-p.rm2 1 1+p.rm2]; % estremi e nominale di m2
p.ritardiCandidati=[.10 .20 .30];          % tolleranze di ritardo confrontate (Cap. 5)

%% Drive: secondo ordine con ritardo approssimato da Pade(1)
% Gm(s) = wn^2/(s^2+2*zeta*wn*s+wn^2) * exp(-td*s), uno per giunto.
% I valori e le tolleranze sono ipotesi progettuali ragionevoli richieste
% dalla traccia ("scelta arbitraria ragionevole"), non dati misurati.
p.wn=40;        % [rad/s] pulsazione naturale nominale
p.zeta=.8;      % [-]     smorzamento, considerato noto
p.ritardo=.015; % [s]     ritardo di trasporto nominale (15 ms)
p.rwn=.15; p.rritardo=.20; % incertezze relative: wn +-15%, td +-20%

%% Griglie di frequenza e di tempo
p.omega=logspace(-3,4,601);   % [rad/s] griglia per risposte in frequenza
p.omegaMu=logspace(-2,4,121); % [rad/s] griglia della D-K iteration
p.tempo=(0:.002:12)';         % [s] prove lineari e non lineari
p.rasTempo=(0:.02:15)';       % [s] orizzonte della RAS empirica
p.tempoRumore=(0:.002:4)';    % [s] prova di rumore, passo 2 ms

%% RAS empirica: 15 condizioni iniziali (3 raggi x 5 direzioni)
p.rasRaggi=deg2rad([5 15 30]);         % [rad] distanza dall'equilibrio
p.rasDirezioni=(0:4)'*2*pi/5;          % [rad] direzioni nel piano (dq1,dq2)
p.rasPosTol=deg2rad(.5); p.rasVelTol=deg2rad(.5); % tolleranze di convergenza
p.timeout=30;          % [s] tempo di calcolo massimo per singola simulazione
p.limiteNumerico=1e8;  % soglia oltre la quale lo stato e considerato non numerico
p.rasUTol=.05;         % [N m] comando residuo ammesso a convergenza
p.sogliaPosizione=4*pi; p.sogliaVelocita=1000; % [rad], [rad/s] divergenza osservata

%% Opzioni di sintesi
p.dkIterazioni=3;  % numero massimo di iterazioni D-K (musyn)
p.dkFit=[2 1];     % ordini di fit delle scalature D e G
p.pidAvvii=2;      % avvii casuali di hinfstruct
p.tolNominale=1e-8; p.marginePeso=1.02; p.eccessoPesoMax=1.6; % peso di incertezza B

%% Pesi prestazionali (Capitolo 6)
% We(s) = (s/Ms + omegaW1)/(s + omegaW1*As) = (s/3 + 2)/(s + 0.3)
%   We(0)=omegaW1/(omegaW1*As)=1/As=6.67: a bassa frequenza l'errore pesato
%   puo valere al piu 1/We(0)=0.15 = 15% del riferimento (vedi README).
%   We(inf)=1/Ms=1/3: ad alta frequenza si tollera un errore fino a 3 volte.
% Wu(s) = ku*(s + omegaU)/(s/alpha + omegaU) = 0.003(s+80)/(s/6+80)
%   Wu(0)=0.003, Wu(inf)=ku*alpha=0.018: penalizza di piu il comando ad alta
%   frequenza, cioe l'amplificazione del rumore di misura.
% Mo(s) = omegaM^2/(s^2+2*omegaM*s+omegaM^2) = 9/(s+3)^2 per giunto:
%   modello desiderato criticamente smorzato, assestamento al 2% ~ 1.94 s.
p.omegaW1=2; p.As=.15; p.Ms=3; p.ku=.003; p.omegaU=80; p.alpha=6; p.omegaM=3;
p.rAmp=deg2rad(5);      % [rad] ampiezza del gradino di riferimento (5 gradi)
p.dAmp=.5;              % [N m] ampiezza del disturbo di coppia sul link
p.sigmaY=deg2rad(.05);  % [rad] deviazione standard del rumore encoder (0.05 gradi)

%% Specifiche nominali (target scelti dagli studenti, Capitolo 6)
% A: NS/NP/RS/RP usano soglie unitarie imposte dalla matematica.
% B: i target temporali sono scelte progettuali; non modificano NS/NP/RS/RP.
p.Ts=5;      % [s] tempo di assestamento al 2%
p.Mp=15;     % [%] sovraelongazione
p.ess=.05;   % [-] errore statico relativo (5%)
p.cross=.25; % [-] accoppiamento fra i giunti (25% dell'ampiezza comandata)
p.specificheCandidate=[.8 10 .05 .25;1.5 15 .05 .25;2 15 .05 .25];
% C: coppia, picco/RMS del rumore e recupero sono diagnostici senza dati hardware.
p.recuperoTol=deg2rad(.5); % Diagnostica, non soglia di robustezza.

%% Firma della configurazione
% Vettore che identifica la configurazione numerica. Ogni MAT salvato porta
% la propria firma: se un parametro cambia, i risultati vecchi vengono
% rifiutati invece di essere riusati in silenzio.
% Posizione storica della soglia Ts nella firma v3. Il valore riservato
% conserva il formato delle cache validate. p.Ts si applica solo agli esiti.
slotTsFirmaV3=2;
p.firma=[3 p.m1 p.m2 p.rm2 p.l1 p.l2 p.g diag(p.Jm)' diag(p.Bm)' diag(p.Ks)' ...
    p.wn p.zeta p.ritardo p.rwn p.rritardo ...
    p.omegaW1 p.As p.Ms p.ku p.omegaU p.alpha p.omegaM p.seed ...
    p.campioni p.dkIterazioni p.dkFit p.pidAvvii slotTsFirmaV3 p.Mp p.ess p.cross ...
    p.rAmp p.dAmp p.sigmaY p.tempo(end) p.rasTempo(end) p.rasRaggi ...
    p.rasPosTol p.rasVelTol p.rasUTol p.timeout];
assert(license('test','Control_Toolbox'),'SEA:Toolbox','Manca Control System Toolbox.');
assert(license('test','Robust_Toolbox'),'SEA:Toolbox','Manca Robust Control Toolbox.');
end
