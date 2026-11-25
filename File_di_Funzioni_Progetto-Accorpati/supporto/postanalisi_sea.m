function [confronto,analisi]=postanalisi_sea(ricalcola,banca,mappa)
%POSTANALISI_SEA NS, NP, RS e RP a controllore fissato sulle famiglie A e B (Cap. 9, 12).
%
%   postanalisi_sea(false)  carica l'analisi ufficiale sul riferimento e ne
%                           ricontrolla le norme nominali (modalita rapida);
%   postanalisi_sea(true)   ricalcola tutto con robstab/robgain;
%   postanalisi_sea(true,banca,mappa)  stessa analisi su un elenco esplicito
%                           di controllori, senza scrivere i file ufficiali.
%
% Due mappe prestazionali, con gli stessi pesi e la stessa soglia unitaria:
%   "Tzr_v1"  : Tzr     r     -> z=[We*e; Wu*u]   (d=0, rumore=0)
%   "Tzrd_v1" : Tz[r;d] [r;d] -> z=[We*e; Wu*u]   (rumore=0)
% con e = q - Mo*r. Un PASS sulla prima NON implica un PASS sulla seconda.
%
% Definizioni (identiche per tutti i controllori):
%   NS: chiuso nominale internamente stabile (tutti i canali, non solo Tz).
%   NP: NS e ||Tz nominale||_inf < 1.
%   RS: robstab sul chiuso completo incerto. Il margine indica di quanto si
%       puo scalare l'insieme di incertezza prima di perdere la stabilita:
%       limite inferiore > 1 -> stabilita garantita per tutto l'insieme
%       (PASS); limite superiore < 1 -> esiste una perturbazione ammessa
%       che destabilizza (FAIL); altrimenti INCONCLUDENTE.
%   RP: robgain(Tz,1) calcola il margine di prestazione robusta, cioe di
%       quanto si puo scalare l'incertezza mantenendo ||Tz||_inf < 1.
%       Stessa lettura dei limiti di RS. Se NP fallisce, RP fallisce per
%       esclusione logica (metodo NP_FAIL, nessun margine calcolato); se RS
%       fallisce, il margine RP e limitato da quello RS (LIMITE_DA_RS).
arguments
    ricalcola (1,1) logical = false
    banca (1,1) struct = struct()
    mappa (1,1) string {mustBeMember(mappa,["Tzr_v1","Tzrd_v1"])} = "Tzr_v1"
end
p=parametri_sea;
firma=p.firma;
ufficiale=isempty(fieldnames(banca));
assert(~ufficiale || mappa=="Tzr_v1",'SEA:Mappa','La tabella ufficiale riguarda Tzr_v1.');
if mappa=="Tzr_v1",ingressiZ=1:2;else,ingressiZ=1:4;end
if ufficiale
    [nomi,K,origine]=controllori_sea(p);
else
    assert(ricalcola,'SEA:Banca','Per una banca esplicita occorre ricalcolare.');
    nomi=banca.nomi; K=banca.K; origine=banca.origine;
    assert(numel(nomi)==numel(K) && numel(nomi)==numel(origine));
end
a=load(fullfile(p.risultati,'incertezze.mat'),'modelli'); u=a.modelli;
assert(isequal(u.firma,firma),'SEA:Cache','Modelli incerti incoerenti.');
piante={u.PA,u.PB}; famiglie=["A_parametrico","B_concentrato"];
file=fullfile(p.risultati,'confronto_robusto_r.mat');
if ~ricalcola && ~isfile(file)
    file=fullfile(p.dati,'confronto_robusto_r.mat');
end
if ~ricalcola
    assert(isfile(file),'SEA:CacheRP','Analisi sul riferimento assente: eseguire postanalisi_sea(true).');
    a=load(file);
    % Controllo di provenienza: stessa mappa, stessa configurazione e stessi
    % controllori (a tolleranza, vedi stessi_controllori).
    assert(isfield(a,'mappa') && isequal(a.mappa,mappa) && isequal(a.firma,firma) && ...
        isequal(a.nomi,nomi) && stessi_controllori(a.K,K,p.omega),'SEA:CacheRP', ...
        'Mappa o controllori incoerenti: eseguire postanalisi_sea(true).');
    analisi=a.analisi;
    confronto=a.confronto;
    assert(height(confronto)==2*numel(K) && all(confronto.Mappa==mappa),'SEA:CacheRP','Tabella riferita a una mappa diversa.');
    disp('Analisi A/B sul solo riferimento caricata. Verifica nominale in corso.');
else
    analisi=cell(numel(K),2); righe=cell(2*numel(K),17);
end
statoRng=rng; ripristina=onCleanup(@()rng(statoRng));
for k=1:numel(K)
    norme=zeros(2,2);
    for j=1:2
        fprintf('Post-analisi %s / %s / %s\n',nomi(k),famiglie(j),mappa);
        ny=size(K{k},2)-2;
        % Chiuso incerto completo: ingressi [r1 r2 d1 d2 v...], uscite
        % [q1 q2 u1 u2 ze1 ze2 zu1 zu2].
        [~,CL]=interconnessione_sea(piante{j},p,ny,K{k});
        assert(isequal(string(CL.InputName(:))',["r1","r2","d1","d2","v"+(1:ny)]) && ...
            isequal(string(CL.OutputName(:))',["q1","q2","u1","u2","ze1","ze2","zu1","zu2"]), ...
            'SEA:Porte','Porte della chiusura incoerenti.');
        Tz=CL(5:8,ingressiZ);  % mappa prestazionale scelta
        assert(order(CL.NominalValue)==order(Tz.NominalValue));
        nominale=CL.NominalValue;
        NS=isstable(nominale);  % stabilita interna del chiuso completo
        norma=Inf; normaRD=Inf;
        if NS
            norma=norm(Tz.NominalValue,inf);
            normaRD=norm(nominale(5:8,1:4),inf);
            assert(norma<=normaRD+1e-6*max(1,normaRD),'SEA:Norma','Norma r superiore alla norma [r;d].');
        end
        NP=NS && norma<1;
        norme(j,:)=[norma,normaRD];
        if ~ricalcola
            old=analisi{k,j};
            assert(NS==old.NS && NP==old.NP && vicine(norma,old.norma) && vicine(normaRD,old.normaRD), ...
                'SEA:CacheRP','Risultati nominali non coerenti con la mappa salvata.');
            continue
        end
        % robstab/robgain usano algoritmi con componenti casuali: seed fisso.
        rng(p.seed,'twister');
        [RS,worstRS]=robstab(CL);
        rpIniziale=[];
        if ~NP
            RP=struct('LowerBound',0,'UpperBound',0); metodo="NP_FAIL";
        elseif RS.UpperBound<1
            RP=struct('LowerBound',0,'UpperBound',RS.UpperBound); metodo="LIMITE_DA_RS";
        else
            rng(p.seed,'twister');
            [RP,worstRP]=robgain(Tz,1);
            metodo="robgain";
            % Se i limiti risultano invertiti (problema numerico del
            % calcolo di mu), si ripete con l'opzione 'm9' di mussvi.
            if RP.LowerBound>RP.UpperBound
                rpIniziale=RP;
                rng(p.seed,'twister');
                [RP,worstRP]=robgain(Tz,1,robOptions('MussvOptions','m9'));
                metodo="robgain_retry_m9";
            end
        end
        % RP richiede anche la stabilita interna per tutta la famiglia.
        esitoRS=esitoMargine(RS); esitoRP=esitoMargine(RP);
        if esitoRP=="PASS" && esitoRS~="PASS",esitoRP="INCONCLUDENTE";end
        analisi{k,j}=struct('NS',NS,'NP',NP,'norma',norma,'normaRD',normaRD,'RS',RS,'RP',RP, ...
            'RPiniziale',rpIniziale,'worstRS',worstRS,'metodoRP',metodo);
        if startsWith(metodo,"robgain"),analisi{k,j}.worstRP=worstRP;end
        righe(2*(k-1)+j,:)={nomi(k),origine(k),famiglie(j),order(K{k}),NS,norma,NP, ...
            RS.LowerBound,RS.UpperBound,esitoRS,RP.LowerBound,RP.UpperBound,esitoRP,metodo,RS.CriticalFrequency,normaRD,mappa};
        fprintf('  norma %s %.8g / [r;d] %.8g, RS [%g, %g], RP [%g, %g] %s (%s)\n', ...
            mappa,norma,normaRD,RS.LowerBound,RS.UpperBound,RP.LowerBound,RP.UpperBound,esitoRP,metodo);
    end
    % A e B hanno lo stesso nominale: le norme devono coincidere.
    assert(vicine(norme(1,1),norme(2,1)) && vicine(norme(1,2),norme(2,2)), ...
        'SEA:Nominale','Norme nominali A/B incoerenti.');
end
if ricalcola
    % Per la mappa Tzr_v1 le colonne con suffisso _r si riferiscono a r->z;
    % per Tzrd_v1 le stesse colonne si riferiscono a [r;d]->z (colonna Mappa).
    confronto=cell2table(righe,'VariableNames',{'Controllore','Sintesi','Analisi','Ordine','NS', ...
        'NormaNominaleR','NP_r','RS_lower','RS_upper','RS','RP_r_lower','RP_r_upper','RP_r', ...
        'MetodoRP','FrequenzaCritica','NormaNominaleRD','Mappa'});
    if ufficiale
        save(file,'analisi','confronto','nomi','K','origine','firma','mappa','-v7');
    end
end
if ufficiale
    writetable(confronto,fullfile(p.risultati,'confronto_robusto_r.csv'));
end
disp(confronto);
end

function ok=vicine(a,b)
ok=a==b || (isfinite(a) && isfinite(b) && abs(a-b)<=1e-6*max([1,abs(a),abs(b)]));
end

function stato=esitoMargine(m)
% Classificazione sui valori numerici completi, senza arrotondamenti.
% Un intervallo invertito o non valido resta inconcludente.
if isnan(m.LowerBound) || isnan(m.UpperBound) || m.LowerBound>m.UpperBound
    stato="INCONCLUDENTE";
elseif m.LowerBound>1
    stato="PASS";
elseif m.UpperBound<1
    stato="FAIL";
else
    stato="INCONCLUDENTE";
end
end
