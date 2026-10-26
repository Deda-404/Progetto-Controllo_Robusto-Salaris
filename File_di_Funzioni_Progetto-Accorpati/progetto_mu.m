%% 1 - Mu: modello incerto -> analisi Hinf -> sintesi D-K -> verifica Kmu
% Script con dati del repository, nello stile di progetto_lqg, progetto_lqgi e progetto_hinf.
% Esecuzione: premere Run oppure scrivere progetto_mu nel Command Window.
clearvars; clc; close all;
ricalcolaAnalisi=true;  % robstab, robgain e mussv: puo richiedere alcuni minuti
ricalcolaSintesi=false; % true: nuova musyn, con le 5 iterazioni del progetto
mostraFigure=true;
esportaControlloriRumore=true; % false: salta soltanto la nuova sezione 14
confrontaIncertezze=false; % true: sezione 15, nuovi modelli e analisi separate
analizzaConfrontoIncertezze=true; % false: sole verifiche dei nuovi modelli
% UNRCH annota soltanto rami disattivati dai flag iniziali;
% le modalita alternativa e di risintesi sono verificate separatamente.
% Default: analisi effettiva dei due controllori gia ottenuti nel progetto.
% Con ricalcolaAnalisi=false si leggono i margini archiviati, esplicitamente
% indicati come tali. Una nuova sintesi forza sempre una nuova analisi.
% Run dall'Editor: i percorsi dipendono dalla posizione di questo file.
% Richiede Control System Toolbox e Robust Control Toolbox (R2025b).
% Si usano gli artifact della campagna finale 2 DoF, senza sovrascriverli.
cartellaScript=fileparts(mfilename('fullpath')); radice=fileparts(cartellaScript);
dati=fullfile(radice,'results','data','hinf_final_coherent');
fileRichiesti={fullfile(dati,'selected_full_order.mat'),fullfile(dati,'m13.mat'), ...
    fullfile(dati,'m12.mat'),fullfile(dati,'m14.mat'), ...
    fullfile(dati,'robust_study.mat'),fullfile(radice,'results','data','m4_uncertain_plant.mat')};
for j=1:numel(fileRichiesti)
    assert(isfile(fileRichiesti{j}),'MuProgetto:FileMancante', ...
        'Artifact necessario mancante: %s',fileRichiesti{j});
end
selezionato=load(fileRichiesti{1},'selected');
sintesi=load(fileRichiesti{2},'synthesis');
auditHinf=load(fileRichiesti{3},'audit'); auditMu=load(fileRichiesti{4},'audit');
robusto=load(fileRichiesti{5},'result'); m4=load(fileRichiesti{6});
omega=logspace(-3,4,1201); tempo=(0:.002:12)'; seed=sintesi.synthesis.seed;

% Solo risultati archiviati: non vengono presentati come nuovi calcoli.
storico.obiettivoMu=sintesi.synthesis.objective;
storico.normeNominali=[auditHinf.audit.nominalNorm;auditMu.audit.nominalNorm];
storico.storiaDK=tabellaDK(sintesi.synthesis.info);
auditSalvati={auditHinf.audit,auditMu.audit};
for j=1:2
    v=auditSalvati{j}; a=struct('RS',v.RS,'RP',v.RP,'normaWorstRP',v.rpWorstActualNorm);
    if isfield(v,'rpInitial'), a.RPiniziale=v.rpInitial.margin; end
    storico.analisi{j}=a;
end

% Parametri fisici ed equilibrio del sistema SEA a due giunti
% Stato meccanico x=[dq;dqdot;dtheta;dthetadot], 8 coordinate.
% Si lavora in deviazione da qbar=[pi/2;0]; q in rad, coppie in N m.
m1=1; m2=.8; l1=.4; l2=.3; g=9.81;
qbar=[pi/2;0]; Bm=diag([.02 .02]);
coupling=m2*l1*l2*cos(qbar(2)); distal=m2*l2^2;
Mbar=[(m1+m2)*l1^2+distal+2*coupling,distal+coupling; ...
    distal+coupling,distal];
dg=-m2*g*l2*sin(sum(qbar));
Kg=[-(m1+m2)*g*l1*sin(qbar(1))+dg,dg;dg,dg];
assert(all(eig(Mbar)>0),'MuProgetto:Massa','Mbar non definita positiva.');

%% 2 - Incertezze parametriche reali, con identita condivisa
% k1 e k2 +/-10%, Jm1 +/-10%. Gli altri parametri rimangono nominali.
% Ogni nome rappresenta UN parametro: le sue occorrenze sono correlate.
% Non sostituire un parametro ripetuto con piu blocchi indipendenti.
k1=ureal('k1',50,'Percentage',10);
k2=ureal('k2',40,'Percentage',10);
Jm1=ureal('Jm1',.01,'Percentage',10);
Ks=diag([k1 k2]); Jm=diag([Jm1 .01]);
intervalli=table(["k1";"k2";"Jm1"],[50;40;.01],[45;36;.009], ...
    [55;44;.011],'VariableNames',{'Parametro','Nominale','Minimo','Massimo'});
disp('Incertezze fisiche dichiarate M4:'); disp(intervalli);

%% 3 - Linearizzazione analitica e disturbo applicato lato link
% Mbar*qdd = -(Ks+Kg)*q + Ks*theta + d.
% Jm*thetadd = Ks*q - Ks*theta - Bm*thetadot + tau.
% d e una coppia sui link: entra attraverso Mbar^-1, non attraverso Jm^-1.
Z=zeros(2); I=eye(2);
Amech=[Z,I,Z,Z;-(Mbar\(Ks+Kg)),Z,Mbar\Ks,Z; ...
    Z,Z,Z,I;Jm\Ks,Z,-(Jm\Ks),-(Jm\Bm)];
Btau=[Z;Z;Z;Jm\I]; Bd=[Z;Mbar\I;zeros(4,2)];
Cq=[I,zeros(2,6)];
Gmech=uss(Amech,[Btau Bd],Cq,zeros(2,4));
Gmech.InputName={'tau1','tau2','d1','d2'}; Gmech.OutputName={'q1','q2'};

% Attuatore nominale: secondo ordine e ritardo Pade di ordine 1
% Ga(s)=wn^2/(s^2+2*zeta*wn*s+wn^2)*(1-Td*s/2)/(1+Td*s/2).
% wn=40 rad/s, zeta=.8, Td=.015 s. Tre stati per attuatore.
s=tf('s'); wn=40; zeta=.8; Td=.015;
GaFormula=wn^2/(s^2+2*zeta*wn*s+wn^2)*(1-Td*s/2)/(1+Td*s/2);
Ga=ss(m4.uncertainPlantInfo.GactuatorNominal);
Ga.InputName={''}; Ga.OutputName={''}; % nomi della precedente variabile Ga
assert(erroreMappe(Ga,GaFormula,omega)<1e-10);

% Incertezza dinamica moltiplicativa degli attuatori
% Ga_unc,i=Ga*(1+WI*Delta_act_i), ||Delta_act_i||inf<=1.
% Delta_act1 e Delta_act2 sono dinamiche complesse indipendenti.
% WI e il peso gia adattato in M4, non un nuovo peso prestazionale.
% Copre la famiglia wn/zeta +/-10%, ritardo +/-20%, safety factor 1.08.
WI=m4.WI;
Delta_act1=ultidyn('Delta_act1',[1 1],'Type','GainBounded','Bound',1);
Delta_act2=ultidyn('Delta_act2',[1 1],'Type','GainBounded','Bound',1);
Gact=append(Ga*(1+WI*Delta_act1),Ga*(1+WI*Delta_act2));
Gact.InputName={'u1','u2'}; Gact.OutputName={'tau1','tau2'};
% Mantenere Gact come uss: ssdata o ss(Gact) eliminerebbero l'incertezza.

% Pianta fisica incerta, e verifica del caso nominale
physical=connect(Gmech,Gact,{'u1','u2','d1','d2'},{'q1','q2'});
nomiIncertezza=string(fieldnames(physical.Uncertainty));
assert(isequal(sort(nomiIncertezza),sort(["Delta_act1";"Delta_act2";"Jm1";"k1";"k2"])));
physicalNom=physical.NominalValue;
% I 16 stati qui includono due stati stabili di WI, inattivi nel nominale;
% la pianta Hinf fisica senza WI aveva 14 stati. Nessuna riduzione di K.
erroreNominale=erroreMappe(physicalNom,robusto.result.physical.NominalValue,omega);
assert(erroreNominale<1e-8,'MuProgetto:Nominale','Pianta nominale differente.');
fprintf('Pianta: %d stati nominali, cinque blocchi incerti; scarto %.3g.\n', ...
    order(physicalNom),erroreNominale);

%% 4 - Pesi prestazionali e modello desiderato della campagna finale
% Profilo selezionato [omegaW1 As Ms ku omegaU]=[2 .15 3 .003 80].
% W1 pesa q-Mo*r; W2 pesa il comando fisico. W3 e assente.
% Mo e parte del costo 2 DoF, non un prefiltro aggiunto al controllore.
omegaW1=2; As=.15; Ms=3; ku=.003; omegaU=80; alpha=6; omegaM=4;
W1=(s/Ms+omegaW1)/(s+omegaW1*As)*I;
W2=ku*(s+omegaU)/(s/alpha+omegaU)*I;
Mo=omegaM^2/(s^2+2*omegaM*s+omegaM^2)*I;

%% 5 - Pianta generalizzata incerta P: ingressi, uscite e segni
% w=[r1;r2;d1;d2], z=[W1*(q-Mo*r);W2*u], y=[r1;r2;q1;q2].
% P: [w;u] -> [z;y]. Il controllore e u=Kr*r+Ky*q.
% Ky contiene il proprio segno. Non aggiungere una negazione esterna.
Pn=physical; Pn.InputName={'u(1)','u(2)','d(1)','d(2)'};
Pn.OutputName={'q(1)','q(2)'};
Mon=ss(Mo); Mon.InputName={'r(1)','r(2)'}; Mon.OutputName={'qm(1)','qm(2)'};
W1n=ss(W1); W1n.InputName={'em(1)','em(2)'}; W1n.OutputName={'ze(1)','ze(2)'};
W2n=ss(W2); W2n.InputName={'u(1)','u(2)'}; W2n.OutputName={'zu(1)','zu(2)'};
P=connect(Pn,Mon,W1n,W2n,sumblk('em = q - qm',2), ...
    {'r(1)','r(2)','d(1)','d(2)','u(1)','u(2)'}, ...
    {'ze(1)','ze(2)','zu(1)','zu(2)','r(1)','r(2)','q(1)','q(2)'});
nmeas=4; ncont=2; nw=4; nz=4;
assert(isequal(size(P),[8 6]));
% connect condivide gli stati: nessuna duplicazione di modi instabili.

%% 6 - Controllore Hinf 2 DoF da cui parte l'analisi
% E il K di selected_full_order.mat: ordine 22, quattro ingressi/due uscite.
% La sua sintesi hinfsyn e documentata nello script Hinf precedente.
Khinf=selezionato.selected.K;
CLhinf=lft(P,Khinf); % lft inferiore: chiude gli ultimi nmeas/ncont segnali
assert(isequal(size(Khinf),[2 4]) && order(Khinf)==22);
assert(isequal(size(CLhinf),[nz nw]));

%% 7 - NS e NP: verifiche nominali distinte dalle verifiche robuste
% NS: stabilita della chiusura nominale. NP: NS e ||Tzw_nom||inf<1.
% gamma Hinf piccolo non garantisce la robustezza rispetto a Delta.
NS_hinf=isstable(CLhinf.NominalValue);
normaHinf=norm(CLhinf.NominalValue,inf);
NP_hinf=NS_hinf && normaHinf<1;
assert(NS_hinf && NP_hinf,'MuProgetto:NominalHinf','Gate nominale Hinf fallito.');
fprintf('Hinf: NS=%d, NP=%d, norma nominale %.10g.\n',NS_hinf,NP_hinf,normaHinf);

%% 8 - Decomposizione N-Delta e normalizzazione dei blocchi
% [N,Delta,BlkStruct,NormUnc]=lftdata(CLhinf), CLhinf=lft(Delta,N).
% Delta contiene i blocchi normalizzati: ureal in [-1,1], ultidyn a norma<=1.
% N=[N11 N12;N21 N22], con N11 la mappa verso/dai soli canali incerti.
% Il nome N evita di confondere la decomposizione con la massa Mbar.
[N_hinf,Delta_hinf,BlkStruct,NormUnc]=lftdata(CLhinf);
ndOut=size(Delta_hinf,2); ndIn=size(Delta_hinf,1);
N11_hinf=N_hinf(1:ndOut,1:ndIn);
ricostruita=lft(Delta_hinf,N_hinf);
erroreLFT=erroreMappe(ricostruita.NominalValue,CLhinf.NominalValue,omega);
assert(erroreLFT<1e-8);
struttura=table(string({BlkStruct.Name})',string({BlkStruct.Type})', ...
    [BlkStruct.Occurrences]','VariableNames',{'Blocco','Tipo','Occorrenze'});
disp('Struttura normalizzata:'); disp(struttura);

% Definizione di mu e significato dei due limiti
% mu_Delta(N11)=1/min{||Delta||:det(I-N11*Delta)=0}, oppure 0 se
% nessun Delta della struttura dichiarata rende singolare la matrice.
% mussv stima lower<=mu<=upper. Non e una semplice norma o sigma massima.
% RS richiede nominale stabile e sup_omega mu_Delta(N11(jw))<1.
% Un upper<1 certifica; un lower>1 esclude; limiti a cavallo sono inconclusivi.
% Una griglia finita puo perdere il picco: robstab usa ricerca adattiva.

% RP: estensione con un blocco fittizio di prestazione
% Per RP si aggiunge Delta_perf: z -> w, pieno complesso nw x nz.
% La struttura e diag(Delta,Delta_perf); si analizza l'intera matrice N.
% Il teorema vale per la mappa pesata Tzw e il target gamma=1.
% Qui robgain(CL,1) calcola direttamente il margine robusto di guadagno.
% Non confondere questo margine con wcgain o con l'obiettivo restituito
% dalla sintesi musyn. Nel seguito RP viene verificata dopo la sintesi.
dimensioneBloccoPrestazione=[nw nz];

% Mu-analysis Hinf sulla griglia, prima di progettare Kmu.
% mussv restituisce [upper,lower]; non sostituisce la ricerca adattiva RS.
muGriglia=cell(2,1);
if ricalcolaAnalisi || ricalcolaSintesi
    statoRngGriglia=rng; rng(seed,'twister');
    try
        bounds=mussv(frd(N11_hinf,omega),BlkStruct,'s');
        upper=squeeze(bounds.ResponseData(1,1,:)); lower=squeeze(bounds.ResponseData(1,2,:));
        assert(all(isfinite(upper)) && all(isfinite(lower)) && all(upper+1e-8>=lower));
        muGriglia{1}=struct('upper',upper,'lower',lower, ...
            'margineGriglia',[1/max(upper),1/max(lower)]);
        % Continuita della stessa sequenza casuale per la successiva analisi Mu.
        statoRngDopoHinf=rng;
    catch erroreMu
        rng(statoRngGriglia); rethrow(erroreMu);
    end
    rng(statoRngGriglia);
end

%% 9 - Sintesi mu: iterazione D-K e opzioni congelate
% D-step: bounds di mu e scaling D/G sulla struttura mista reale/complessa.
% Fit: approssimazione razionale degli scaling, con FitOrder=[5 2].
% K-step: nuovo problema Hinf scalato; si ripete fino all'arresto.
% Procedura non convessa: il risultato non e un minimo globale garantito.
% L'ordine cresce per le dinamiche degli scaling. Nessuna riduzione qui.
% musyn(P,nmeas,ncont) usa hinfsyn nel K-step. La variante con blocchi
% tunable usa hinfstruct; non e la sintassi full-order adottata qui.
% Documentazione: https://www.mathworks.com/help/robust/ref/uss.musyn.html
optsMu=musynOptions('Display','short','MaxIter',5,'TargetPerf',0, ...
    'TolPerf',.01,'MixedMU','on','FullDG',[true true],'FitOrder',[5 2], ...
    'FrequencyGrid',omega,'AutoScale','on','Regularize','on','LimitGain','on', ...
    'RandomStart',0,'UseParallel',false,'MinDecay',1e-7,'MaxFrequency',Inf);

%% 10 - musyn: quattro misure, due comandi, medesimo problema P
% La configurazione storica M13 a 1 DoF aveva nmeas=2. Qui y=[r;q],
% quindi nmeas=4: si conserva la chiamata effettiva della pipeline finale.
% Si mantiene il seed del progetto e si ripristina lo stato RNG precedente.
% D-K e i lower bound numerici possono produrre un nuovo K diverso da quello
% archiviato, anche sullo stesso problema: si riportano i nuovi esiti reali.
if ricalcolaSintesi
    statoRng=rng; rng(seed,'twister'); %#ok<UNRCH>
    try
        [Kmu,obiettivoMu,infoDK]=musyn(P,nmeas,ncont,optsMu);
    catch erroreSintesi
        rng(statoRng); rethrow(erroreSintesi);
    end
    rng(statoRng); ricalcolaAnalisi=true;
    storiaDK=tabellaDK(infoDK); origineSintesi="NUOVA MUSYN";
else
    Kmu=sintesi.synthesis.K; % stessa realizzazione originale, ordine 78
    obiettivoMu=storico.obiettivoMu; storiaDK=storico.storiaDK;
    infoDK=[]; origineSintesi="MUSYN ARCHIVIATA DEL PROGETTO";
end
assert(~isempty(Kmu) && isfinite(obiettivoMu) && isequal(size(Kmu),[2 4]));
fprintf('%s: ordine %d, obiettivo %.10g.\n',origineSintesi,order(Kmu),obiettivoMu);

% Storia D-K completa, senza eliminare iterazioni sfavorevoli
% PeakMu, gamma scalata e PeakMuFit descrivono quantita diverse.
% Cinque iterazioni sono il limite scelto, non una prova di ottimalita.
disp(storiaDK);
[migliorUpper,iterazioneMigliore]=min(storiaDK.PeakMu);
fprintf('Migliore PeakMu %.10g, iterazione %d su %d.\n', ...
    migliorUpper,iterazioneMigliore,height(storiaDK));

%% 11 - Chiusura Kmu e nuova decomposizione LFT
CLmu=lft(P,Kmu);
[N_mu,Delta_mu,BlkStructMu,NormUncMu]=lftdata(CLmu);
N11_mu=N_mu(1:size(Delta_mu,2),1:size(Delta_mu,1));
assert(isequal(BlkStructMu,BlkStruct),'MuProgetto:Blocchi','Struttura incerta cambiata.');
NS_mu=isstable(CLmu.NominalValue); normaMu=norm(CLmu.NominalValue,inf);
NP_mu=NS_mu && normaMu<1;
assert(NS_mu && NP_mu,'MuProgetto:NominalMu','Gate nominale Kmu fallito.');

% RS e RP adattive: robstab e robgain sui due controllori
% Margine rho: moltiplicatore del raggio delle incertezze normalizzate.
% Lower>1: PASS sull'insieme dichiarato. Upper<1: FAIL. Altrimenti incerto.
% Per Hinf il progetto ha osservato un intervallo RP invertito: si conserva,
% si ripete con opzioni m9 e non si riordinano artificialmente gli estremi.
chiusure={CLhinf,CLmu}; nomi=["Hinf 2 DoF";"Mu 2 DoF"];
analisi=cell(2,1); statoRngAnalisi=rng;
rng(seed,'twister');
try
    for j=1:2
        if ricalcolaAnalisi
            fprintf('Analisi adattiva %s...\n',nomi(j));
            a=struct;
            [a.RS,a.rsWorst,a.rsInfo]=robstab(chiusure{j});
            [a.RP,a.rpWorst,a.rpInfo]=robgain(chiusure{j},1);
            if a.RP.LowerBound>a.RP.UpperBound
                a.RPiniziale=a.RP;
                rng(seed,'twister');
                [a.RP,a.rpWorst,a.rpInfo]=robgain(chiusure{j},1, ...
                    robOptions('MussvOptions','m9','Sensitivity','on'));
            end
            a.origine="RICALCOLATA";
            a.normaWorstRP=norm(usubs(chiusure{j},a.rpWorst),inf);
        else
            a=storico.analisi{j}; a.origine="ARCHIVIATA DEL PROGETTO"; %#ok<UNRCH>
        end
        assert(a.RS.LowerBound<=a.RS.UpperBound,'MuProgetto:RS','Intervallo RS invertito.');
        a.esitoRS=esitoMargine(a.RS);
        if a.RP.LowerBound>a.RP.UpperBound
            a.esitoRP="NON VALIDATO: INTERVALLO INVERTITO";
            if a.esitoRS=="FAIL", a.esitoRP="FAIL DA RS; MARGINE RP NON VALIDATO"; end
        else
            a.esitoRP=esitoMargine(a.RP);
        end
        analisi{j}=a;
    end
catch erroreAnalisi
    rng(statoRngAnalisi); rethrow(erroreAnalisi);
end
rng(statoRngAnalisi);

% mussv su N11: bounds RS sulla griglia dichiarata
% L'uscita mussv ha ordine [upper,lower], non [lower,upper].
% Documentazione: https://www.mathworks.com/help/robust/ref/mussv.html
% rho_RS circa [1/max(upper),1/max(lower)]: stima su GRIGLIA FINITA.
% Non sostituisce il margine adattivo robstab della sezione precedente.
N11={N11_hinf,N11_mu};
if ricalcolaAnalisi
    statoRngGriglia=rng;
    rng(statoRngDopoHinf);
    try
        for j=2
            fprintf('mussv su %d frequenze: %s...\n',numel(omega),nomi(j));
            bounds=mussv(frd(N11{j},omega),BlkStruct,'s');
            upper=squeeze(bounds.ResponseData(1,1,:));
            lower=squeeze(bounds.ResponseData(1,2,:));
            assert(all(isfinite(upper)) && all(isfinite(lower)) && all(upper+1e-8>=lower));
            muGriglia{j}=struct('upper',upper,'lower',lower, ...
                'margineGriglia',[1/max(upper),1/max(lower)]);
        end
    catch erroreMu
        rng(statoRngGriglia); rethrow(erroreMu);
    end
    rng(statoRngGriglia);
end

%% 12 - Quadro NS / NP / RS / RP e confronto con i risultati archiviati
RS_lower=cellfun(@(a) a.RS.LowerBound,analisi);
RS_upper=cellfun(@(a) a.RS.UpperBound,analisi);
RP_lower=cellfun(@(a) a.RP.LowerBound,analisi);
RP_upper=cellfun(@(a) a.RP.UpperBound,analisi);
confronto=table(nomi,[order(Khinf);order(Kmu)],[NS_hinf;NS_mu], ...
    [normaHinf;normaMu],[NP_hinf;NP_mu],RS_lower,RS_upper, ...
    string(cellfun(@(a) a.esitoRS,analisi,'UniformOutput',false)), ...
    RP_lower,RP_upper,string(cellfun(@(a) a.esitoRP,analisi,'UniformOutput',false)), ...
    string(cellfun(@(a) a.origine,analisi,'UniformOutput',false)), ...
    'VariableNames',{'Controllore','Ordine','NS','NormaNominale','NP', ...
    'RS_lower','RS_upper','RS','RP_lower','RP_upper','RP','OrigineAnalisi'});
disp(confronto);
% Risultati del progetto: Hinf NS/NP PASS, RS FAIL; RP numerica non validata
% ed esclusa da RS. Kmu NS/NP/RS/RP PASS nel modello di incertezza dichiarato.
% Una nuova sintesi o analisi va letta nella tabella corrente, non assume
% automaticamente gli esiti della campagna archiviata.

%% 13 - Grafici: bounds di mu e andamento delle iterazioni D-K
if mostraFigure
    fMu=figure('Name','Mu e iterazioni D-K','Theme','light','Color','white', ...
        'Position',[80 80 1200 720]); tl=tiledlayout(fMu,2,2);
    for j=1:2
        nexttile(tl,j);
        if ricalcolaAnalisi
            semilogx(omega,muGriglia{j}.upper,'-',omega,muGriglia{j}.lower,'--');
            yline(1,':'); legend('upper','lower','soglia 1','Location','best');
            ylabel('Mu RS'); xlabel('Frequenza [rad/s]'); grid on;
        else
            axis off; text(.05,.5,'mussv non ricalcolata: attivare ricalcolaAnalisi'); %#ok<UNRCH>
        end
        title(nomi(j));
    end
    nexttile(tl,3); plot(storiaDK.Iterazione,storiaDK.PeakMu,'o-', ...
        storiaDK.Iterazione,storiaDK.GammaScalata,'s-', ...
        storiaDK.Iterazione,storiaDK.PeakMuFit,'d-');
    yline(1,':'); grid on; xlabel('Iterazione'); ylabel('Obiettivo');
    legend('PeakMu','gamma scalata','PeakMuFit','Location','best'); title(origineSintesi);
    nexttile(tl,4); plot(storiaDK.Iterazione,storiaDK.OrdineK,'o-', ...
        storiaDK.Iterazione,storiaDK.OrdineFitMassimo,'s-');
    grid on; xlabel('Iterazione'); ylabel('Ordine'); legend('K','fit massimo','Location','best');
    title('Crescita della complessita');
end

% Margini e norma pesata nominale: cosa migliora con Kmu
if mostraFigure
    fConfronto=figure('Name','Margini robusti e prestazioni nominali','Theme','light', ...
        'Color','white','Position',[100 100 1200 400]); tl=tiledlayout(fConfronto,1,3);
    nexttile(tl,1); bar([RS_lower RS_upper]); yline(1,':');
    xticks(1:2); xticklabels(nomi); grid on; ylabel('Raggio normalizzato');
    legend('lower','upper','Location','best'); title('Margine RS');
    nexttile(tl,2);
    if RP_lower(1)>RP_upper(1)
        bar(2,[RP_lower(2) RP_upper(2)]); xlim([.5 2.5]);
        text(1,.35,'RP Hinf non validata','HorizontalAlignment','center');
    else
        bar([RP_lower RP_upper]);
    end
    xticks(1:2); xticklabels(nomi); yline(1,':'); grid on;
    ylabel('Raggio normalizzato'); title('Margine RP, target 1');
    nexttile(tl,3); sigmaH=zeros(numel(omega),1); sigmaMu=sigmaH;
    rispostaH=freqresp(CLhinf.NominalValue,omega); rispostaMu=freqresp(CLmu.NominalValue,omega);
    for k=1:numel(omega)
        sigmaH(k)=norm(rispostaH(:,:,k),2); sigmaMu(k)=norm(rispostaMu(:,:,k),2);
    end
    semilogx(omega,sigmaH,omega,sigmaMu); yline(1,':'); grid on;
    xlabel('Frequenza [rad/s]'); ylabel('Sigma massima Tzw nominale');
    legend(nomi,'Location','best'); title('Costo nominale');
end

% Tracking nominale sullo stesso sistema fisico
% Due gradini separati di 5 deg; x(0)=0. La RP pesata non certifica Ts<=.8 s.
% Il progetto conserva fallimenti temporali M5 anche per Kmu.
tracking=cell(2,1); comandi=cell(2,1); mappeFisiche=cell(2,1);
for j=1:2
    if j==1, K=Khinf; else, K=Kmu; end
    Kn=K; Kn.InputName={'r(1)','r(2)','q(1)','q(2)'}; Kn.OutputName={'u(1)','u(2)'};
    Gnom=Pn.NominalValue;
    CLfis=connect(Gnom,Kn,{'r(1)','r(2)','d(1)','d(2)'}, ...
        {'q(1)','q(2)','u(1)','u(2)'});
    assert(isstable(CLfis)); mappeFisiche{j}=CLfis;
    risposte=step(CLfis(:,1:2),tempo)*deg2rad(5);
    tracking{j}=risposte(:,1:2,:); comandi{j}=risposte(:,3:4,:);
end
if mostraFigure
    fTracking=figure('Name','Tracking nominale: Hinf e Mu','Theme','light', ...
        'Color','white','Position',[120 120 1100 700]); tl=tiledlayout(fTracking,2,2);
    desiderata=step(Mo,tempo)*5;
    for input=1:2
        for output=1:2
            nexttile(tl,(output-1)*2+input);
            plot(tempo,rad2deg(tracking{1}(:,output,input)), ...
                tempo,rad2deg(tracking{2}(:,output,input)), ...
                tempo,desiderata(:,output,input),'--');
            grid on; xlabel('Tempo [s]'); ylabel('Posizione [deg]');
            title(sprintf('r%d -> q%d',input,output));
            legend('Hinf','Mu','Mo','Location','best');
        end
    end
end

% Risultati nel Workspace e limiti della verifica
% Monte Carlo non viene scambiata per una garanzia mu. Questo script analizza
% il modello lineare incerto dichiarato, non la regione di attrazione SEA.
% Gli artifact del progetto non vengono sovrascritti e non si esporta nulla.
risultati=struct('pianta',physical,'P',P,'Khinf',Khinf,'Kmu',Kmu, ...
    'CLhinf',CLhinf,'CLmu',CLmu,'confronto',confronto,'analisi',{analisi}, ...
    'muGriglia',{muGriglia},'storiaDK',storiaDK,'obiettivoMu',obiettivoMu, ...
    'origineSintesi',origineSintesi,'storico',storico,'erroreNominale',erroreNominale, ...
    'erroreLFT',erroreLFT,'tracking',{tracking},'comandi',{comandi}, ...
    'mappeFisiche',{mappeFisiche},'ricalcolaAnalisi',ricalcolaAnalisi, ...
    'ricalcolaSintesi',ricalcolaSintesi);
disp('Percorso completo nel Workspace: physical, P, N_hinf, Delta_hinf, Kmu, risultati.');

%% 14 - Controllore Mu con attenuazione del rumore di misura: esportazione Simulink
% Solo lettura di MuN1 gia sintetizzato: Kmu rimane il precedente controllore.
% MuN1 ha margini RS/RP sopra 1 negli audit archiviati, ma peggiora parte
% del tracking: non soddisfa automaticamente tutte le specifiche originali.
% Ingressi [r1;r2;qmis1;qmis2] in rad; uscite [u1;u2] in N m.
% Il feedback e gia in K: nessuna negazione, conversione, scala, saturazione,
% filtro o riduzione d'ordine viene aggiunta alla realizzazione originale.
% Run lascia le variabili nel Base Workspace; clearvars iniziale cancella
% quelle di progetto_hinf_tre_controllori. Prima di questo Run salvare con
% save('controllori_Hinf.mat','*_Hinf_rumore','*_Hinf_precedente');
% dopo questo Run, load('controllori_Hinf.mat') riunisce le due famiglie.
% Per conservare Mu prima di eseguire Hinf usare analogamente
% save('controllori_Mu.mat','*_Mu_rumore','*_Mu_precedente'); poi load.
% La sola sezione richiede radice, Kmu ed esportaControlloriRumore gia definiti;
% puo essere rieseguita senza musyn o una nuova iterazione D-K.
if esportaControlloriRumore
    fileRumoreMu=fullfile(radice,'results','data','noise_redesign','mu_noise_01.mat');
    assert(isfile(fileRumoreMu),'MuProgetto:RumoreFile', ...
        'File del controllore MuN1 mancante: %s',fileRumoreMu);
    archivioRumoreMu=load(fileRumoreMu,'candidate');
    assert(isfield(archivioRumoreMu,'candidate') && ...
        isstruct(archivioRumoreMu.candidate) && isscalar(archivioRumoreMu.candidate), ...
        'MuProgetto:RumoreCandidate','Struttura candidate mancante o non valida in %s.',fileRumoreMu);
    assert(all(isfield(archivioRumoreMu.candidate,{'name','status','K'})), ...
        'MuProgetto:RumoreCampi','Campi candidate.name, status o K mancanti in %s.',fileRumoreMu);
    assert(isequal(archivioRumoreMu.candidate.name,"MuN1") || ...
        isequal(archivioRumoreMu.candidate.name,'MuN1'), ...
        'MuProgetto:RumoreNome','candidate.name deve essere MuN1 in %s.',fileRumoreMu);
    assert(isequal(archivioRumoreMu.candidate.status,"SYNTHESIZED") || ...
        isequal(archivioRumoreMu.candidate.status,'SYNTHESIZED'), ...
        'MuProgetto:RumoreStato','candidate.status deve essere SYNTHESIZED in %s.',fileRumoreMu);
    assert(isa(archivioRumoreMu.candidate.K,'ss') && ...
        isequal(size(archivioRumoreMu.candidate.K),[2 4]), ...
        'MuProgetto:RumoreSistema','candidate.K deve essere un singolo sistema ss 2x4 in %s.',fileRumoreMu);
    assert(archivioRumoreMu.candidate.K.Ts==0 && ...
        isempty(archivioRumoreMu.candidate.K.E) && ...
        ~hasdelay(archivioRumoreMu.candidate.K) && isproper(archivioRumoreMu.candidate.K), ...
        'MuProgetto:RumoreRealizzazione', ...
        'candidate.K deve essere continuo, proprio, senza ritardi o matrice E in %s.',fileRumoreMu);

    K_Mu_rumore=archivioRumoreMu.candidate.K;
    [A_Mu_rumore,B_Mu_rumore,C_Mu_rumore,D_Mu_rumore]=ssdata(K_Mu_rumore);
    assert(isreal([A_Mu_rumore(:);B_Mu_rumore(:);C_Mu_rumore(:);D_Mu_rumore(:)]) && ...
        all(isfinite([A_Mu_rumore(:);B_Mu_rumore(:);C_Mu_rumore(:);D_Mu_rumore(:)])), ...
        'MuProgetto:RumoreValori','Matrici di candidate.K complesse o non finite in %s.',fileRumoreMu);
    assert(order(K_Mu_rumore)==82, ...
        'MuProgetto:RumoreOrdine','candidate.K deve avere ordine 82 in %s.',fileRumoreMu);
    assert(isequal(size(A_Mu_rumore),[82 82]) && ...
        isequal(size(B_Mu_rumore),[82 4]) && isequal(size(C_Mu_rumore),[2 82]) && ...
        isequal(size(D_Mu_rumore),[2 4]),'MuProgetto:RumoreMatrici', ...
        'Dimensioni A, B, C, D incoerenti con MuN1 in %s.',fileRumoreMu);
    x0_Mu_rumore=zeros(size(A_Mu_rumore,1),1);

    assert(exist('Kmu','var')==1 && isa(Kmu,'ss') && isequal(size(Kmu),[2 4]), ...
        'MuProgetto:PrecedenteSistema','Kmu precedente deve essere gia disponibile come sistema ss 2x4.');
    assert(Kmu.Ts==0 && isempty(Kmu.E) && ~hasdelay(Kmu) && isproper(Kmu), ...
        'MuProgetto:PrecedenteRealizzazione','Kmu deve essere continuo, proprio, senza ritardi o matrice E.');
    K_Mu_precedente=Kmu;
    [A_Mu_precedente,B_Mu_precedente,C_Mu_precedente,D_Mu_precedente]=ssdata(K_Mu_precedente);
    nPrecedenteMu=order(K_Mu_precedente); % 78 nel MAT archiviato; ricalcolaSintesi resta opzionale
    assert(isequal(size(A_Mu_precedente),[nPrecedenteMu nPrecedenteMu]) && ...
        isequal(size(B_Mu_precedente),[nPrecedenteMu 4]) && ...
        isequal(size(C_Mu_precedente),[2 nPrecedenteMu]) && ...
        isequal(size(D_Mu_precedente),[2 4]),'MuProgetto:PrecedenteMatrici', ...
        'Dimensioni A, B, C, D incoerenti con l''ordine di Kmu precedente.');
    assert(isreal([A_Mu_precedente(:);B_Mu_precedente(:);C_Mu_precedente(:);D_Mu_precedente(:)]) && ...
        all(isfinite([A_Mu_precedente(:);B_Mu_precedente(:);C_Mu_precedente(:);D_Mu_precedente(:)])), ...
        'MuProgetto:PrecedenteValori','Matrici del Kmu precedente complesse o non finite.');
    x0_Mu_precedente=zeros(nPrecedenteMu,1);

    fprintf('\nSimulink: Mu precedente (Kmu), ordine %d; MuN1, ordine %d.\n', ...
        nPrecedenteMu,size(A_Mu_rumore,1));
    fprintf('Precedente: A %dx%d, B %dx4, C 2x%d, D 2x4, x0 %dx1.\n', ...
        nPrecedenteMu,nPrecedenteMu,nPrecedenteMu,nPrecedenteMu,nPrecedenteMu);
    fprintf('MuN1: A 82x82, B 82x4, C 2x82, D 2x4, x0 82x1.\n');
    fprintf('State-Space precedente: A_Mu_precedente, B_Mu_precedente, C_Mu_precedente, D_Mu_precedente; IC x0_Mu_precedente.\n');
    fprintf('State-Space MuN1: A_Mu_rumore, B_Mu_rumore, C_Mu_rumore, D_Mu_rumore; IC x0_Mu_rumore.\n');
    fprintf('Ingressi [r1;r2;qmis1;qmis2] (rad), uscite [u1;u2] (N m); feedback gia incluso.\n');
    fprintf('MuN1: margini RS/RP archiviati >1; compromessi di tracking e target M5 parziali.\n');
end

%% 15 - Confronto conservativo concentrato/parametrico (opzionale)
% Le sezioni precedenti e i loro risultati restano la baseline moltiplicativa.
% Nessuna sintesi: si leggono Khinf, Kmu e MuN1 gia archiviati.
% I nuovi MAT/CSV sono separati; il default non costruisce i nuovi modelli.
if confrontaIncertezze
    risultatiConfrontoIncertezze=confrontoIncertezzeSEA(radice,Gmech, ... %#ok<UNRCH>
        Khinf,Kmu,W1,W2,Mo,analizzaConfrontoIncertezze);
end

%% Funzioni locali: verifiche ausiliarie e tabella delle iterazioni
function errore=erroreMappe(a,b,w)
errore=max(abs(freqresp(a,w)-freqresp(b,w)),[],'all');
end

function esito=esitoMargine(m)
if m.LowerBound>1, esito="PASS";
elseif m.UpperBound<1, esito="FAIL";
else, esito="INCONCLUSIVE";
end
end

function storia=tabellaDK(info)
% Usata dal ramo di risintesi opzionale; dati delle iterazioni reali musyn.
n=numel(info); dati=zeros(n,6);
for k=1:n
    peak=info(k).PeakMu; fit=info(k).PeakMuFit;
    if isstruct(peak), peak=peak.UpperBound; end
    if isstruct(fit), fit=fit.UpperBound; end
    dati(k,:)=[k,peak,info(k).gamma,fit,order(info(k).K),max(info(k).FitOrder(:))];
end
storia=array2table(dati,'VariableNames', ...
    {'Iterazione','PeakMu','GammaScalata','PeakMuFit','OrdineK','OrdineFitMassimo'});
end

function r=confrontoIncertezzeSEA(root,Gmech,Kh,Km,W1,W2,Mo,runAnalysis) %#ok<DEFNU>
% Independent manual LFTs and common physical box. No historical MAT writes.
oldPath=path; pathCleanup=onCleanup(@()path(oldPath));
addpath(genpath(fullfile(root,'src')),fullfile(root,'analysis/uncertainty'), ...
    fullfile(root,'controllers/hinf'),fullfile(root,'analysis/noise_redesign'));
oldRng=rng; rngCleanup=onCleanup(@()rng(oldRng)); seed=20261026; rng(seed,'twister');
u=uncertainty_params_m4; weights=fit_actuator_uncertainty_weight([],u,"additiveComparison");
w=logspace(-4,5,1601);
[Mm,Dm,Gmanual]=meccanicaManualeSEA(Gmech);
[M1,D1,B1,auto1]=attuatoreManualeSEA(1,weights);
[M2,D2,B2,auto2]=attuatoreManualeSEA(2,weights);
GA=append(weights.H0*ss(tf([-weights.nominal(3)/2 1],[weights.nominal(3)/2 1])) ...
    +weights.WA*ultidyn('Delta_A1',[1 1]), ...
    weights.H0*ss(tf([-weights.nominal(3)/2 1],[weights.nominal(3)/2 1])) ...
    +weights.WA*ultidyn('Delta_A2',[1 1]));
GB=append(B1,B2); plants=cell(2,1);
for j=1:2
    if j==1, act=GA; else, act=GB; end
    act.InputName={'u1','u2'}; act.OutputName={'tau1','tau2'};
    plants{j}=connect(Gmech,act,{'u1','u2','d1','d2'},{'q1','q2'});
end
% Both views retain the original disturbance location and common nominal.
P={hinf_final_2dof_plant(plants{1},W1,W2,Mo), ...
   hinf_final_2dof_plant(plants{2},W1,W2,Mo)};
checks=struct('mechanicalNominal',erroreRelativoSEA(Gmanual.NominalValue,Gmech.NominalValue,w), ...
    'actuatorNominal',erroreRelativoSEA(B1.NominalValue,auto1.NominalValue,w), ...
    'commonNominal',erroreRelativoSEA(P{1}.NominalValue,P{2}.NominalValue,w), ...
    'mechanicalSize',size(Mm),'actuatorSize',size(M1),'factorRelativeError',weights.factorRelativeError);
% Corners plus common seeded physical probes; no comparison of realization entries.
mechProbes=[2*(dec2bin(0:7,3)-'0')-1;2*rand(24,3)-1]; mechError=zeros(size(mechProbes,1),1);
for j=1:size(mechProbes,1)
    v=mechProbes(j,:);
    a=usubs(Gmanual,'dk1',v(1),'dk2',v(2),'dJ',v(3));
    b=usubs(Gmech,'k1',50*(1+.1*v(1)),'k2',40*(1+.1*v(2)),'Jm1',.01*(1+.1*v(3)));
    mechError(j)=erroreRelativoSEA(a,b,w);
end
actProbes=[2*(dec2bin(0:7,3)-'0')-1;2*rand(24,3)-1]; actError=zeros(size(actProbes,1),2);
residualRatio=zeros(size(actProbes,1),1); concentratedRatio=residualRatio;
for j=1:size(actProbes,1)
    v=actProbes(j,:); pp=weights.nominal.*(1+[.1 .1 .2].*v);
    % Same physical parameters in the independently constructed state equations.
    for i=1:2
        if i==1, manual=B1; automatic=auto1; else, manual=B2; automatic=auto2; end
        probe=struct; probe.(sprintf('dw%d',i))=v(1); probe.(sprintf('dz%d',i))=v(2);
        probe.(sprintf('dT%d',i))=v(3); probe.(sprintf('Delta_R%d',i))=tf(.4,[.02 1]);
        physicalProbe=struct; physicalProbe.(sprintf('wn%d',i))=pp(1);
        physicalProbe.(sprintf('zeta%d',i))=pp(2); physicalProbe.(sprintf('Td%d',i))=pp(3);
        physicalProbe.(sprintf('Delta_R%d',i))=probe.(sprintf('Delta_R%d',i));
        actError(j,i)=erroreRelativoSEA(usubs(manual,probe),usubs(automatic,physicalProbe),w);
    end
    z=1i*w; H=pp(1)^2./(z.^2+2*pp(2)*pp(1)*z+pp(1)^2);
    delay=exp(-pp(3)*z); pade=(1-pp(3)*z/2)./(1+pp(3)*z/2);
    wr=reshape(freqresp(weights.WR,w),1,[]); wa=reshape(freqresp(weights.WA,w),1,[]);
    nominal=reshape(freqresp(GA.NominalValue(1,1),w),1,[]);
    % Below 1e-2 rad/s the exact cubic limit avoids subtractive cancellation.
    good=w>=1e-2;
    residualRatio(j)=max(abs((delay(good)-pade(good))./wr(good)));
    concentratedRatio(j)=max(abs((H.*delay-nominal)./wa));
end
checks.mechanicalMax=max(mechError); checks.actuatorMax=max(actError,[],'all');
checks.sampledResidualRatio=max(residualRatio); checks.sampledConcentratedRatio=max(concentratedRatio);
checks.mechanicalWellPosedMinimum=.9; checks.delayWellPosedMinimum=.8;
checks.padeRHPZero=2/weights.nominal(3);
checks.multiplicativeResidue=-2*checks.padeRHPZero*exp(-2);
assert(max([checks.mechanicalNominal checks.actuatorNominal checks.commonNominal ...
    checks.mechanicalMax checks.actuatorMax])<1e-8,'SEACompare:Equivalence','LFT equivalence failed.');
assert(checks.sampledResidualRatio<=1+1e-8 && checks.sampledConcentratedRatio<=1+1e-8);
assert(isequal(size(Mm),[5 7]) && isequal(size(M1),[6 6]) && isequal(size(M2),[6 6]));
[~,DA,blocksA]=lftdata(P{1}); [~,DB,blocksB]=lftdata(P{2});
checks.blocksA=blocksA; checks.blocksB=blocksB; checks.deltaSizes={size(DA),size(DB)};
assert(sum(string({blocksB.Type})=="ureal")==9 && sum(string({blocksB.Type})=="ultidyn")==2);
r=struct('seed',seed,'release',version('-release'),'weights',weights,'checks',checks, ...
    'mechanicalLFT',Mm,'mechanicalDelta',Dm,'actuatorLFTs',{{M1,M2}}, ...
    'actuatorDeltas',{{D1,D2}},'plants',{plants},'P',{P}, ...
    'mechanicalProbes',mechProbes,'actuatorProbes',actProbes, ...
    'mechanicalErrors',mechError,'actuatorErrors',actError,'audits',{{}}, ...
    'scope','Fixed controllers, common nominal and performance maps; no synthesis; constant delays');
if ~runAnalysis, disp(checks); return; end
folder=fullfile(root,'results/data/sea_incertezze_conservativa');
if ~isfolder(folder),mkdir(folder);end
noise=load(fullfile(root,'results/data/noise_redesign/mu_noise_01.mat'),'candidate');
controllers={Kh,Km,noise.candidate.K}; names=["Hinf22","Mu78","MuN1_82"];
forms=["A_concentrato","B_parametrico"]; rows=cell(0,15); audits=cell(3,2);
for k=1:3
    for j=1:2
        problem=P{j}; protocol="r,d -> ze,zu";
        if k==3
            problem=noise_generalized_plant(plants{j},W1,W2,Mo,noise.candidate.Wn);
            protocol="r,d,nu -> ze,zu";
        end
        file=fullfile(folder,names(k)+"_"+forms(j)+".mat");
        if isfile(file)
            saved=load(file,'audit'); audit=saved.audit;
            assert(isequaln(audit.K,controllers{k}) && isequaln(audit.P,problem) ...
                && audit.seed==seed && strcmp(audit.release,version('-release')), ...
                'SEACompare:Checkpoint','Checkpoint differs; do not overwrite.');
        else
            fprintf('SEA comparison %s / %s: starting adaptive analysis.\n',names(k),forms(j));
            audit=analisiFissataSEA(problem,controllers{k},seed);
            save(file,'audit','-v7');
        end
        audit.RPBoundsOutcome=esitoVerificatoSEA(audit.RP);
        if audit.RPBoundsOutcome=="INCONCLUSIVE_NUMERICAL"
            audit.RPOutcome="INCONCLUSIVE_NUMERICAL";
            if audit.RSOutcome=="FAIL",audit.RPOutcome="FAIL_FROM_RS; MARGIN_INVALID";end
        end
        audits{k,j}=audit;
        % Same nominal map for both models; -3dB relative to each DC diagonal gain.
        nominal=plants{j}.NominalValue; nominal.InputName={'u1','u2','d1','d2'};
        K=controllers{k}; K.InputName={'r1','r2','q1','q2'}; K.OutputName={'u1','u2'};
        T=connect(nominal,K,{'r1','r2','d1','d2'},{'q1','q2'});
        T=T(:,1:2);
        bw=[bandwidth(T(1,1)) bandwidth(T(2,2))];
        rows(end+1,:)={char(names(k)),char(forms(j)),char(protocol),order(controllers{k}), ...
            audit.NS,audit.nominalNorm,audit.NP,audit.RS.LowerBound,audit.RS.UpperBound, ...
            char(audit.RSOutcome),audit.RP.LowerBound,audit.RP.UpperBound,char(audit.RPOutcome),bw(1),bw(2)}; %#ok<AGROW>
        fprintf('RS [%g,%g] %s; RP [%g,%g] %s\n',audit.RS.LowerBound,audit.RS.UpperBound, ...
            audit.RSOutcome,audit.RP.LowerBound,audit.RP.UpperBound,audit.RPOutcome);
    end
end
r.audits=audits;
r.comparison=cell2table(rows,'VariableNames',{'Controller','Model','Protocol','Order','NS','NominalNorm','NP', ...
    'RS_lower','RS_upper','RS','RP_lower','RP_upper','RP','Bandwidth1','Bandwidth2'});
assert(max(abs(r.comparison.NominalNorm(1:2:end)-r.comparison.NominalNorm(2:2:end)))<1e-6);
assert(max(abs(r.comparison.Bandwidth1(1:2:end)-r.comparison.Bandwidth1(2:2:end)))<1e-6);
assert(max(abs(r.comparison.Bandwidth2(1:2:end)-r.comparison.Bandwidth2(2:2:end)))<1e-6);
save(fullfile(folder,'comparison.mat'),'r','-v7');
writetable(r.comparison,fullfile(folder,'comparison.csv'));
summary=struct('seed',seed,'release',r.release,'checks',checks,'comparison',table2struct(r.comparison));
fid=fopen(fullfile(folder,'validation.json'),'w'); cleanup=onCleanup(@()fclose(fid));
fprintf(fid,'%s',jsonencode(summary,PrettyPrint=true)); disp(r.comparison);
end

function [M,Delta,G]=meccanicaManualeSEA(reference)
p=sea_params_nominal; nominal=reference.NominalValue;
A=nominal.A; B=nominal.B; C=nominal.C;
qbar=[pi/2;0]; coupling=p.m2*p.l1*p.l2*cos(qbar(2)); distal=p.m2*p.l2^2;
Mass=[(p.m1+p.m2)*p.l1^2+distal+2*coupling,distal+coupling;distal+coupling,distal];
Kr=.1*p.Ks; Jr=.1*p.Jm(1,1)*[1;0];
Bw=[zeros(2,3);Mass\[Kr zeros(2,1)];zeros(2,3);-p.Jm\[Kr Jr]];
Cv=[-eye(2),zeros(2),eye(2),zeros(2);A(7,:)];
Dvw=[zeros(2,3);Bw(7,:)]; Dvu=[zeros(2,4);B(7,:)];
M=ss(A,[Bw B],[Cv;C],[Dvw Dvu;zeros(2,7)]);
Delta=blkdiag(ureal('dk1',0,'Range',[-1 1]),ureal('dk2',0,'Range',[-1 1]),ureal('dJ',0,'Range',[-1 1]));
G=lft(Delta,M);
end

function [M,Delta,G,automatic]=attuatoreManualeSEA(i,f)
w0=f.nominal(1); z0=f.nominal(2); T0=f.nominal(3);
% Row coordinates [x_a,v_a,h,w_w1,w_w2,w_z,w_T,u].
E=eye(8); x=E(1,:); v=E(2,:); h=E(3,:); u=E(8,:);
a=w0*(u-x+.1*E(4,:)); b=a-2*z0*(v+.1*E(6,:));
vdot=w0*(b+.1*E(5,:)); hdot=2/T0*(x-h)-.2*E(7,:);
dx=[v;vdot;hdot]; outputs=[u-x;b;v;hdot;x;2*h-x];
core=ss(dx(:,1:3),dx(:,4:8),outputs(:,1:3),outputs(:,4:8));
core.InputName={'ww1','ww2','wz','wT','u'};
core.OutputName={'vw1','vw2','vz','vT','vR','yp'};
res=f.WR;res.InputName={'wR'};res.OutputName={'er'};
M=connect(core,res,sumblk('y = yp + er'),{'ww1','ww2','wz','wT','wR','u'}, ...
    {'vw1','vw2','vz','vT','vR','y'});
dw=ureal(sprintf('dw%d',i),0,'Range',[-1 1]);
dz=ureal(sprintf('dz%d',i),0,'Range',[-1 1]);
dT=ureal(sprintf('dT%d',i),0,'Range',[-1 1]);
dR=ultidyn(sprintf('Delta_R%d',i),[1 1]);
Delta=blkdiag(dw,dw,dz,dT,dR); G=lft(Delta,M);
wn=ureal(sprintf('wn%d',i),w0,'Percentage',10);
zeta=ureal(sprintf('zeta%d',i),z0,'Percentage',10);
Td=ureal(sprintf('Td%d',i),T0,'Percentage',20);
H=uss([0 1;-wn^2 -2*zeta*wn],[0;wn^2],[1 0],0);
Pade=uss(-2/Td,2/Td,2,-1);
automatic=H*(Pade+f.WR*dR);
end

function e=erroreRelativoSEA(a,b,w)
x=freqresp(a,w); y=freqresp(b,w);
e=max(abs(x-y),[],'all')/max(1,max(abs(y),[],'all'));
end

function a=analisiFissataSEA(P,K,seed)
a=struct('P',P,'K',K,'seed',seed,'release',version('-release'));
a.CL=lft(P,K); a.NS=isstable(a.CL.NominalValue);
a.nominalNorm=norm(a.CL.NominalValue,inf); a.NP=a.NS && a.nominalNorm<1;
rng(seed,'twister'); timer=tic;
[a.RS,a.rsWorst,a.rsInfo]=robstab(a.CL);
a.rsSeconds=toc(timer); timer=tic;
[a.RP,a.rpWorst,a.rpInfo]=robgain(a.CL,1);
if a.RP.LowerBound>a.RP.UpperBound
    a.rpInitial=a.RP; rng(seed,'twister');
    [a.RP,a.rpWorst,a.rpInfo]=robgain(a.CL,1,robOptions('MussvOptions','m9'));
end
a.rpSeconds=toc(timer);
a.RSOutcome=esitoVerificatoSEA(a.RS); a.RPOutcome=esitoVerificatoSEA(a.RP);
if a.RSOutcome=="FAIL",a.RPOutcome="FAIL_FROM_RS";end
[M,D,blocks]=lftdata(a.CL); a.blocks=blocks; a.deltaSize=size(D);
a.nominalLFTError=erroreRelativoSEA(lft(D,M).NominalValue,a.CL.NominalValue,logspace(-4,5,801));
a.rsWitnessStable=isstable(usubs(a.CL,a.rsWorst));
a.rpWitnessNorm=norm(usubs(a.CL,a.rpWorst),inf);
end

function s=esitoVerificatoSEA(m)
if ~isfinite(m.LowerBound) || isnan(m.UpperBound) || m.LowerBound>m.UpperBound
    s="INCONCLUSIVE_NUMERICAL";
else
    s=esitoMargine(m);
end
end
