function [confronto,analisi]=postanalisi_sea(ricalcola,banca)
%POSTANALISI_SEA Valuta NP/RP sul riferimento con i controllori salvati.
% POSTANALISI_SEA(true) aggiorna l'analisi senza eseguire sintesi.
% Una banca esplicita usa lo stesso calcolo senza scrivere i risultati ufficiali.
arguments
    ricalcola (1,1) logical = false
    banca (1,1) struct = struct()
end
p=parametri_sea;
mappa="Tzr_v1";
firma=p.firma;
ufficiale=isempty(fieldnames(banca));
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
    assert(isfield(a,'mappa') && isequal(a.mappa,mappa) && isequal(a.firma,firma) && ...
        isequal(a.nomi,nomi) && isequaln(a.K,K),'SEA:CacheRP', ...
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
        fprintf('Post-analisi %s / %s\n',nomi(k),famiglie(j));
        ny=size(K{k},2)-2;
        [~,CL]=interconnessione_sea(piante{j},p,ny,K{k});
        assert(isequal(string(CL.InputName(:))',["r1","r2","d1","d2","v"+(1:ny)]) && ...
            isequal(string(CL.OutputName(:))',["q1","q2","u1","u2","ze1","ze2","zu1","zu2"]), ...
            'SEA:Porte','Porte della chiusura incoerenti.');
        Tzr=CL(5:8,1:2);
        assert(isequal(size(Tzr),[4 2]) && order(CL.NominalValue)==order(Tzr.NominalValue));
        nominale=CL.NominalValue;
        NS=isstable(nominale);
        norma=Inf; normaRD=Inf;
        if NS
            norma=norm(Tzr.NominalValue,inf);
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
        rng(p.seed,'twister');
        [RS,worstRS]=robstab(CL);
        rpIniziale=[];
        if ~NP
            RP=struct('LowerBound',0,'UpperBound',0); metodo="NP_FAIL";
        elseif RS.UpperBound<1
            RP=struct('LowerBound',0,'UpperBound',RS.UpperBound); metodo="LIMITE_DA_RS";
        else
            rng(p.seed,'twister');
            [RP,worstRP]=robgain(Tzr,1);
            metodo="robgain";
            if RP.LowerBound>RP.UpperBound
                rpIniziale=RP;
                rng(p.seed,'twister');
                [RP,worstRP]=robgain(Tzr,1,robOptions('MussvOptions','m9'));
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
        fprintf('  norma r %.8g / [r;d] %.8g, RS [%g, %g], RP [%g, %g] %s (%s)\n', ...
            norma,normaRD,RS.LowerBound,RS.UpperBound,RP.LowerBound,RP.UpperBound,esitoRP,metodo);
    end
    assert(vicine(norme(1,1),norme(2,1)) && vicine(norme(1,2),norme(2,2)), ...
        'SEA:Nominale','Norme nominali A/B incoerenti.');
end
if ricalcola
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
