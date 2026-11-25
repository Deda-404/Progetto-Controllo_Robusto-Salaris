%% PROGETTO_MU - mu-synthesis (D-K), mu-analysis e riesame (Capitoli 9 e 12)
%
% Obiettivo (punti 2, 3 e 4 della traccia):
%   1) sintesi robusta con D-K iteration (musyn) sulle famiglie A e B;
%   2) mu-analysis a posteriori di TUTTI i controllori (NS, NP, RS, RP)
%      sulle due famiglie e sulle due mappe prestazionali;
%   3) riesame dei passi intermedi della D-K, da cui proviene MuN1.
%
% Idea della D-K iteration. Il valore singolare strutturato mu(M) e il
% piu piccolo "ingrandimento" di una perturbazione strutturata Delta che
% rende singolare I-M*Delta. Calcolarlo esattamente e difficile, quindi si
% minimizza il limite superiore  min_K min_D ||D M(K) D^-1||_inf
% alternando due passi: K-step (hinfsyn con le scalature D fissate) e
% D-step (fit delle scalature D, G con K fissato). Il picco di mu
% diminuisce iterazione dopo iterazione, ma l'ordine del controllore cresce
% (ordine impianto + ordine dei pesi + ordine delle scalature).
% Picco di mu < 1 sul canale pesato significa RP garantita per l'insieme
% di incertezza scalato a 1.
%
% Modalita rapida: carica le D-K e le analisi robuste salvate e ricontrolla
% le norme nominali; la RP sulla mappa completa viene caricata se presente.
% Modalita completa: rifa D-K, analisi robuste e riesame.
%
% Salva: sintesi_mu.mat, confronto_robusto_r.{mat,csv}, dk_1.csv, dk_2.csv,
% riesame_mu.csv, robustezza.png, studio_mu_riferimento/*,
% confronto_robusto_rd.{mat,csv}, mappa_completa_nominale.csv.

%% 1 - Due modelli incerti, stessi pesi; controllore iniziale MuN1
cartella=fileparts(mfilename('fullpath')); addpath(cartella); p=parametri_sea;
if ~isfile(fullfile(p.risultati,'incertezze.mat')),run(fullfile(cartella,'incertezze_attuatori.m'));end
a=load(fullfile(p.risultati,'incertezze.mat')); modelli=a.modelli;
a=load(fullfile(p.dati,'banca_validata.mat')); banca=a.banca;
piante={modelli.PA,modelli.PB}; nomiModello=["A_parametrico","B_concentrato"];
firma=p.firma;
fileSintesi=fullfile(p.risultati,'sintesi_mu.mat');

%% 2 - D-K iteration dedicata ad A e a B
% musyn(P,nmeas,ncont,K0,opts): P e la pianta generalizzata incerta
% (interconnessione_sea con l'impianto A o B), 4 misure [r;q] e 2 comandi.
% K0=banca.muRumore e il controllore iniziale comune ai due percorsi (MuN1):
% musyn parte da K0 invece che da una sintesi H-infinito nominale.
% Opzioni: MaxIter iterazioni, FitOrder = ordini delle scalature D e G,
% MixedMU='on' sfrutta il fatto che i blocchi di m2, wn, td sono reali.
if p.modalita=="completa"
    candidati=cell(1,2);
    for modello=1:2
        P=interconnessione_sea(piante{modello},p,2);
        statoRng=rng; rng(p.seed,'twister');
        opts=musynOptions('Display','short','MaxIter',p.dkIterazioni, ...
            'FitOrder',p.dkFit,'FullDG',false,'MixedMU','on', ...
            'FrequencyGrid',p.omegaMu,'UseParallel',false);
        fprintf('D-K dedicata %s, massimo %d iterazioni.\n',nomiModello(modello),p.dkIterazioni);
        % info(i) contiene, per ogni iterazione, il controllore K, il picco
        % di mu (PeakMu) e il gamma scalato del K-step.
        [Knuovo,obiettivo,info]=musyn(P,4,2,banca.muRumore,opts); rng(statoRng);
        assert(~isempty(Knuovo),'SEA:Sintesi','musyn non ha restituito un controllore.');
        candidati{modello}=struct('K',Knuovo,'obiettivo',obiettivo,'info',info, ...
            'origine',nomiModello(modello),'seed',p.seed,'inizializzazione',"MuN1 fissato, comune ad A/B");
    end
    inizializzazione="MuN1";
    save(fileSintesi,'candidati','firma','inizializzazione','-v7');
else
    if ~isfile(fileSintesi),fileSintesi=fullfile(p.dati,'sintesi_mu.mat');end
    assert(isfile(fileSintesi),'SEA:Cache','Eseguire run_all(''completa'') per rigenerare le D-K.');
    a=load(fileSintesi); assert(isfield(a,'inizializzazione') && a.inizializzazione=="MuN1" && isequal(a.firma,firma),'SEA:Cache','Configurazione cache diversa.');
    candidati=a.candidati; disp('D-K A/B CARICATE da esecuzione validata; non risintetizzate.');
end

%% 3 - mu-analysis dei sette controllori ufficiali sulla mappa del riferimento
% Vedi postanalisi_sea per le definizioni di NS, NP, RS, RP e degli esiti.
confronto=postanalisi_sea(p.modalita=="completa");
nomi=unique(confronto.Controllore,'stable');

%% 4 - Storia D-K e margini RS
% Gli insiemi oltre raggio uno sono differenti: un margine 2 in A e un
% margine 2 in B non descrivono la stessa perturbazione fisica.
storia=cell(1,2);
for modello=1:2
    info=candidati{modello}.info; dati=zeros(numel(info),4);
    for j=1:numel(info),dati(j,:)=[j info(j).PeakMu info(j).gamma order(info(j).K)];end
    storia{modello}=array2table(dati,'VariableNames',{'Iterazione','PeakMu','GammaScalata','Ordine'});
    writetable(storia{modello},fullfile(p.risultati,"dk_"+modello+".csv"));
end
if p.figure
    f=figure('Name','Robustezza A/B e D-K','Color','w'); theme(f,'light'); tiledlayout(1,2);
    nexttile; margini=reshape(confronto.RS_lower,2,[])'; bar(margini); yline(1,'--k');
    set(gca,'XTick',1:numel(nomi),'XTickLabel',nomi); xtickangle(45); grid on;
    ylabel('Limite inferiore RS'); legend('A parametrico','B concentrato');
    nexttile; plot(storia{1}.Iterazione,storia{1}.PeakMu,'o-',storia{2}.Iterazione,storia{2}.PeakMu,'s-');
    yline(1,'--k'); grid on; xlabel('Iterazione'); ylabel('Picco mu'); legend('Sintesi A','Sintesi B');
    exportgraphics(f,fullfile(p.risultati,'robustezza.png'),'Resolution',170);
end

%% 5 - Prestazioni nominali dei controllori intermedi della D-K
% Il picco di mu misura il caso peggiore sull'insieme incerto: ridurlo non
% migliora necessariamente ogni prestazione nominale (errore statico,
% rumore). Per questo ogni passo viene rivalutato sul nominale.
righe={};
for j=1:2
    for k=1:numel(candidati{j}.info)
        K=candidati{j}.info(k).K;[~,CL]=interconnessione_sea(modelli.PA.NominalValue,p,2,K);
        ns=isstable(CL);g=Inf;e=Inf;nu=Inf;
        if ns
            g=norm(CL(5:8,1:4),inf);                       % norma pesata [r;d]
            e=max(abs(dcgain(CL(1:2,1:2))-eye(2)),[],'all'); % errore statico
            nu=norm(CL(3:4,5:6),inf);                      % rumore -> comando
        end
        righe(end+1,:)={j,k,order(K),ns,g,e,nu}; %#ok<SAGROW>
    end
end
T=cell2table(righe,'VariableNames',{'Modello','Iterazione','Ordine','NS','NormaComune','ErroreDC','GuadagnoRumore'});disp(T);writetable(T,fullfile(p.risultati,'riesame_mu.csv'));

%% 6 - Riesame D-K sulla mappa del riferimento (diagnosi di Mu_B, MuN1)
% In rapida riusa l'analisi robusta dei passi intermedi gia salvata.
studio_mu_riferimento(p,p.modalita=="completa");

%% 7 - Mappa completa [r;d]: sette controllori ufficiali e MuN1
% Stessi pesi, stesse incertezze, stessa soglia unitaria della mappa Tzr,
% ma con il disturbo di coppia d fra gli ingressi prestazionali.
[nomiTutti,Ktutti,origineTutti]=controllori_sea(p,true);
sel=[find(nomiTutti=="MuN1_fisso"),find(~endsWith(nomiTutti,"_fisso"))];
nomiRD=nomiTutti(sel); nomiRD(1)="MuN1"; Krd=Ktutti(sel);
origineRD=origineTutti(sel); origineRD(1)="D-K, passo iniziale comune ad A/B";
% Parte nominale (sempre calcolata, poco costosa): norme sulle due mappe e
% direzione del caso peggiore. Al picco omega di ||Tz[r;d]||, la SVD
% M = U S V' fornisce il vettore d'ingresso v che produce la massima uscita:
% |v_r| e |v_d| dicono se il picco e dovuto al riferimento o al disturbo,
% |z_e| e |z_u| se a pesare e l'errore o il comando.
nominale=cell(numel(Krd),11);
for k=1:numel(Krd)
    [~,CL]=interconnessione_sea(modelli.PA.NominalValue,p,size(Krd{k},2)-2,Krd{k});
    valori=nan(1,9);
    if isstable(CL)
        [gRD,w]=norm(CL(5:8,1:4),inf);
        if isinf(w),M=CL.D(5:8,1:4);else,M=evalfr(CL(5:8,1:4),1i*w);end
        [~,~,V]=svd(M); v=V(:,1); z=M*v;
        valori=[norm(CL(5:8,1:2),inf),gRD,w,norm(v(1:2)),norm(v(3:4)), ...
            norm(z(1:2)),norm(z(3:4)),max(abs(dcgain(CL(1:2,1:2))-eye(2)),[],'all'),gRD<1];
    end
    nominale(k,:)=[{nomiRD(k),order(Krd{k})},num2cell(valori)];
end
nominale=cell2table(nominale,'VariableNames',{'Controllore','Ordine','NormaR','NormaRD', ...
    'OmegaPiccoRD','PesoIngressoR','PesoIngressoD','Ze','Zu','ErroreDC','NP_RD'});
writetable(nominale,fullfile(p.risultati,'mappa_completa_nominale.csv')); disp(nominale);
% Parte robusta: robstab/robgain sulla mappa [r;d] (solo in completa).
fileRD=fullfile(p.risultati,'confronto_robusto_rd.mat');
if p.modalita=="completa"
    bancaRD=struct('nomi',nomiRD,'K',{Krd},'origine',origineRD);
    [tabRD,analisiRD]=postanalisi_sea(true,bancaRD,"Tzrd_v1");
    tabRD=renamevars(tabRD,["NormaNominaleR","NP_r","RP_r_lower","RP_r_upper","RP_r"], ...
        ["NormaNominaleMappa","NP_mappa","RP_mappa_lower","RP_mappa_upper","RP_mappa"]);
    save(fileRD,'tabRD','analisiRD','nomiRD','Krd','firma','-v7');
    writetable(tabRD,fullfile(p.risultati,'confronto_robusto_rd.csv'));
elseif isfile(fileRD)
    a=load(fileRD);
    assert(isequal(a.firma,firma) && isequal(a.nomiRD,nomiRD) && stessi_controllori(a.Krd,Krd,p.omega), ...
        'SEA:CacheRD','RP sulla mappa completa calcolata con altri controllori.');
    tabRD=a.tabRD; disp('RP sulla mappa completa [r;d] CARICATA dalla campagna completa.');
else
    tabRD=table();
    disp('RP sulla mappa completa [r;d]: NOT RUN in questa cartella; eseguire run_all(''completa'').');
end
if ~isempty(tabRD),disp(tabRD);end

%% Funzioni locali
function studio_mu_riferimento(p,ricalcolaIterazioni)
% Riesame dei controllori D-K gia prodotti sulla mappa Tzr, senza nuove
% sintesi: diagnosi del caso peggiore di Mu_B, analisi robusta dei passi
% intermedi e prove nominali dei candidati che passano RP in A e B.
[originali,Koriginali]=controllori_sea(p);
storico=load(fullfile(p.risultati,'sintesi_mu.mat'));
base=load(fullfile(p.risultati,'confronto_robusto_r.mat'));
a=load(fullfile(p.risultati,'incertezze.mat'),'modelli');
b=load(fullfile(p.dati,'banca_validata.mat'),'banca');
P={a.modelli.PA,a.modelli.PB};
assert(isequal(storico.firma,base.firma,p.firma,a.modelli.firma) && base.mappa=="Tzr_v1" && ...
    isequal(base.nomi,originali) && stessi_controllori(base.K,Koriginali,p.omega));
out=fullfile(p.risultati,'studio_mu_riferimento');
if ~isfolder(out),mkdir(out);end
stato=rng; ripristina=onCleanup(@()rng(stato));

% 6a - Diagnosi del picco e contributo di ciascun blocco incerto
% Per Mu_B (7o controllore) si sostituisce la perturbazione critica
% restituita da robgain (wcu) e si valuta, alla frequenza critica, la
% norma di Tzr con un solo blocco perturbato oppure con tutti tranne uno:
% cosi si individua quale incertezza (m2 o un drive) domina la perdita.
righe=cell(3,12); blocchi=cell(0,10);
for j=1:3
    if j==1
        [~,CL]=interconnessione_sea(P{1}.NominalValue,p,2,Koriginali{6});
        nome="Mu_A"; famiglia="Nominale"; f=NaN;
    else
        [~,CL]=interconnessione_sea(P{j-1},p,2,Koriginali{7});
        wcu=base.analisi{7,j-1}.worstRP;
        f=base.analisi{7,j-1}.RP.CriticalFrequency;
        famiglia=string(char('A'+j-2));
        T=CL(5:8,1:2);
        Mcrit=evalfr(usubs(T,wcu),1i*f);
        campi=fieldnames(wcu);
        for i=1:numel(campi)
            tag=campi{i}; block=CL.Uncertainty.(tag); val=wcu.(tag);
            solo=usubs(T,tag,val); complementare=usubs(T,rmfield(wcu,tag));
            solo=norm(evalfr(solo.NominalValue,1i*f),2);
            complementare=norm(evalfr(complementare.NominalValue,1i*f),2);
            if isa(block,'ureal')
                % Scostamento normalizzato: -1 e +1 sono gli estremi dell'intervallo.
                scarto=val-block.NominalValue;
                if scarto>=0,ampiezza=block.Range(2)-block.NominalValue;
                else,ampiezza=block.NominalValue-block.Range(1);end
                blocchi(end+1,:)={famiglia,string(tag),"reale",block.NominalValue,val,scarto/ampiezza,NaN,solo,complementare,norm(Mcrit,2)}; %#ok<AGROW>
            else
                blocchi(end+1,:)={famiglia,string(tag),"dinamico",NaN,NaN,norm(val,inf),abs(evalfr(val,1i*f)),solo,complementare,norm(Mcrit,2)}; %#ok<AGROW>
            end
        end
        CL=usubs(CL,wcu);
        nome="Mu_B";
    end
    assert(isstable(CL));
    T=CL(5:8,1:2);
    [guadagno,omega]=norm(T,inf);
    if isinf(omega),M=T.D; else,M=evalfr(T,1i*omega);end
    % Direzione peggiore: primo vettore singolare destro.
    [~,~,V]=svd(M,'econ');
    r=V(:,1); z=M*r;
    assert(abs(norm(z)-guadagno)<1e-4);
    righe(j,:)={nome,famiglia,guadagno,omega,f,norm(z(1:2)),norm(z(3:4)),abs(z(1)),abs(z(2)),abs(r(1)),abs(r(2)), ...
        max(abs(dcgain(CL(1:2,1:2))-eye(2)),[],'all')};
end
diagnosi=cell2table(righe,'VariableNames',{'Controllore','Famiglia','Norma','OmegaPicco','OmegaRobgain', ...
    'Ze','Zu','Ze1','Ze2','PesoR1','PesoR2','ErroreDC'});
perturbazioni=cell2table(blocchi,'VariableNames',{'FamigliaAB','Blocco','Tipo','Nominale', ...
    'ValoreCritico','ScostamentoNormalizzato','ModuloAllaFrequenzaRP','NormaSoloBlocco','NormaSenzaBlocco','NormaCasoCompleto'});
writetable(diagnosi,fullfile(out,'diagnosi.csv'));
writetable(perturbazioni,fullfile(out,'perturbazioni_mu_b.csv'));
disp(diagnosi); disp(perturbazioni);

% 6b - Passi intermedi delle due D-K, valutati sulle due famiglie
% DK_A_1 e DK_B_1 coincidono: e il controllore iniziale MuN1.
nomi=strings(1,6); K=cell(1,6);
for j=1:2
    info=storico.candidati{j}.info;
    assert(numel(info)==3 && all(arrayfun(@(x)~isempty(x.K),info)));
    for i=1:3
        k=3*(j-1)+i;
        nomi(k)="DK_"+string(char('A'+j-1))+"_"+i;
        K{k}=info(i).K;
        assert(isequal(size(K{k}),[2 4]));
    end
end
assert(isequaln(K{1},K{4},b.banca.muRumore),'SEA:Iterazioni','Inizializzazione inattesa.');
indici=[1 2 3 5 6];
firma=p.firma; mappa=base.mappa;
fileIterazioni=fullfile(out,'iterazioni.mat');
if ricalcolaIterazioni
    banca=struct('nomi',nomi(indici),'K',{K(indici)},'origine',repmat("D-K originale",1,5));
    [tabella,analisi]=postanalisi_sea(true,banca);
    % Il passo 1 e lo stesso controllore in entrambe le storie.
    duplicato=tabella(tabella.Controllore==nomi(1),:); duplicato.Controllore(:)=nomi(4);
    iterazioni=[tabella(1:6,:);duplicato;tabella(7:end,:)];
    erroreDC=zeros(6,1);
    for k=1:6
        [~,CL]=interconnessione_sea(P{1}.NominalValue,p,2,K{k});
        erroreDC(k)=max(abs(dcgain(CL(1:2,1:2))-eye(2)),[],'all');
    end
    iterazioni.ErroreDC=repelem(erroreDC,2);
    save(fileIterazioni,'nomi','K','iterazioni','analisi','indici','firma','mappa','-v7');
else
    d=load(fileIterazioni);
    assert(isfield(d,'mappa') && isequal(d.mappa,mappa) && isequal(d.firma,firma) && ...
        isequal(d.nomi,nomi) && isequaln(d.K,K),'SEA:CacheStudio','Riesame incoerente.');
    iterazioni=d.iterazioni;
    assert(height(iterazioni)==12 && all(iterazioni.Mappa==mappa));
end
writetable(iterazioni,fullfile(out,'iterazioni.csv'));
disp(iterazioni);

% 6c - Stesse prove nominali per LQG e per i candidati con RP su A e B
nomiProva=originali(1); Kprova=Koriginali(1);
for k=indici
    esiti=iterazioni.RP_r(iterazioni.Controllore==nomi(k));
    if numel(esiti)==2 && all(esiti=="PASS")
        nome=nomi(k);
        if k==1,nome="MuN1";end
        nomiProva(end+1)=nome; %#ok<AGROW>
        Kprova{end+1}=K{k}; %#ok<AGROW>
    end
end
prove=proveNominali(P{1}.NominalValue,p,nomiProva,Kprova);
writetable(prove,fullfile(out,'prove_nominali.csv'));
disp(prove);
end

function prove=proveNominali(P,p,nomi,K)
% Quattro specifiche nominali e metriche di comando, disturbo e rumore.
% Assestamento: stepinfo con valore finale = guadagno statico effettivo
% (banda 2% attorno al valore raggiunto). L'errore statico rispetto al
% riferimento e verificato separatamente (ErroreDC <= 5%), quindi un
% assestamento rapido su un valore sbagliato non viene promosso.
% Sovraelongazione e cross-coupling sono riferiti all'ampiezza richiesta.
rng(p.seed,'twister');
v=p.sigmaY*randn(numel(p.tempoRumore),4);
righe=cell(numel(K),16);
for k=1:numel(K)
    fprintf('Prove lineari e di rumore %s\n',nomi(k));
    ny=size(K{k},2)-2;
    [~,CL]=interconnessione_sea(P,p,ny,K{k});
    assert(isstable(CL),'SEA:Stabilita','Prove nominali su una chiusura instabile.');
    guadagno=dcgain(CL(1:2,1:2));
    y=step(CL(1:4,1:2)*p.rAmp,p.tempo);
    d=step(CL(1:4,3:4)*p.dAmp,p.tempo);
    ts=zeros(1,2); mp=zeros(1,2); recupero=zeros(1,2);
    for j=1:2
        info=stepinfo(y(:,j,j),p.tempo,p.rAmp*guadagno(j,j));
        ts(j)=info.SettlingTime;
        if ~isfinite(ts(j)),ts(j)=Inf;end
        mp(j)=max(0,100*(max(y(:,j,j))/p.rAmp-1));
        ultimo=find(max(abs(d(:,1:2,j)),[],2)>p.recuperoTol,1,'last');
        if ultimo==numel(p.tempo),recupero(j)=Inf;
        elseif ~isempty(ultimo),recupero(j)=p.tempo(ultimo+1);end
    end
    errore=max(abs(guadagno-eye(2)),[],'all');
    cross=max(abs([y(:,1,2);y(:,2,1)]))/p.rAmp;
    rmsTrack=sqrt(max(trapz(p.tempo,sum(y(:,3:4,:).^2,2),1),[],'all')/(2*p.tempo(end)));
    rmsDist=sqrt(max(trapz(p.tempo,sum(d(:,3:4,:).^2,2),1),[],'all')/(2*p.tempo(end)));
    rumore=rumore_continuo_sea(CL(1:4,5:4+ny),v(:,1:ny),p.tempoRumore);
    limite=max(ts)<=p.Ts && max(mp)<=p.Mp && errore<=p.ess && cross<=p.cross;
    righe(k,:)={nomi(k),max(ts),max(mp),errore,cross,limite,max(abs(y(:,3:4,:)),[],'all'),rmsTrack, ...
        max(abs(d(:,1:2,:)),[],'all'),max(recupero),max(abs(d(:,3:4,:)),[],'all'),rmsDist, ...
        norm(CL(3:4,5:4+ny),inf),rumore(3),rumore(4),rumore(5)};
end
prove=cell2table(righe,'VariableNames',{'Controllore','Assestamento','OvershootPercent','ErroreDC','Cross','TargetNominali', ...
    'PiccoComandoTracking','RMSComandoTracking','PiccoDisturboRad','RecuperoDisturbo','PiccoComandoDisturbo','RMSComandoDisturbo', ...
    'GuadagnoRumore','PiccoRumore','RMSRumore','ErroreQuadraturaRumore'});
end
