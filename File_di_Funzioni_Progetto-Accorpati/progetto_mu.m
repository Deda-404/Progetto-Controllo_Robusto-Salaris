%% 1 - Due modelli, stessi pesi e controllori fissati della banca originale
cartella=fileparts(mfilename('fullpath')); addpath(cartella); p=parametri_sea;
if ~isfile(fullfile(p.risultati,'incertezze.mat')),run(fullfile(cartella,'incertezze_attuatori.m'));end
a=load(fullfile(p.risultati,'incertezze.mat')); modelli=a.modelli;
a=load(fullfile(p.dati,'banca_validata.mat')); banca=a.banca;
piante={modelli.PA,modelli.PB}; nomiModello=["A_parametrico","B_concentrato"];
firma=[p.wn p.zeta p.ritardo p.rwn p.rzeta p.omegaW1 p.As p.Ms p.ku p.omegaU p.alpha p.omegaM p.seed];
fileSintesi=fullfile(p.risultati,'sintesi_mu.mat');
fileAnalisi=fullfile(p.risultati,'confronto_robusto.mat');

%% 2 - D-K dedicata A/B: nessuna sostituzione dei controllori storici
if p.modalita=="completa"
    candidati=cell(1,2);
    for modello=1:2
        P=interconnessione_sea(piante{modello},p,2);
        statoRng=rng; rng(p.seed,'twister');
        opts=musynOptions('Display','short','MaxIter',p.dkIterazioni, ...
            'FitOrder',p.dkFit,'FullDG',false,'MixedMU','on', ...
            'FrequencyGrid',p.omegaMu,'UseParallel',false);
        fprintf('D-K dedicata %s, massimo %d iterazioni.\n',nomiModello(modello),p.dkIterazioni);
        [Knuovo,obiettivo,info]=musyn(P,4,2,opts); rng(statoRng);
        assert(~isempty(Knuovo),'SEA:Sintesi','musyn non ha restituito un controllore.');
        candidati{modello}=struct('K',Knuovo,'obiettivo',obiettivo,'info',info, ...
            'origine',nomiModello(modello),'seed',p.seed);
    end
    save(fileSintesi,'candidati','firma','-v7');
else
    if ~isfile(fileSintesi),fileSintesi=fullfile(p.dati,'sintesi_mu.mat');end
    assert(isfile(fileSintesi),'SEA:Cache','Eseguire run_all(''completa'') per rigenerare le D-K.');
    a=load(fileSintesi); assert(isequal(a.firma,firma),'SEA:Cache','Configurazione cache diversa.');
    candidati=a.candidati; disp('D-K A/B CARICATE da esecuzione validata; non risintetizzate.');
end
nomi=[string({banca.controllers.name}),"MuN1","Mu_A","Mu_B"];
K=[{banca.controllers.K},{banca.muRumore,candidati{1}.K,candidati{2}.K}];
origine=[repmat("main / modello storico",1,7),nomiModello];
fileH=fullfile(p.risultati,'sintesi_hinf.mat');
if ~isfile(fileH),fileH=fullfile(p.dati,'sintesi_hinf.mat');end
a=load(fileH); K=[K,{a.sintesi.Kpid}]; nomi=[nomi,"PID_nuovo"];
origine=[origine,"hinfstruct nominale, stessi pesi"];

%% 3 - Stesso K su A e B: NS, NP, RS e RP sono proprieta distinte
if p.modalita=="completa"
    analisi=cell(numel(K),2); righe=cell(2*numel(K),15); riga=0;
    for k=1:numel(K)
        for modello=1:2
            fprintf('Analisi %s / %s...\n',nomi(k),nomiModello(modello));
            [~,CL]=interconnessione_sea(piante{modello},p,size(K{k},2)-2,K{k});
            CL=CL(:,1:4); NS=isstable(CL.NominalValue);
            norma=norm(CL.NominalValue(5:8,:),inf); NP=NS && norma<1;
            statoRng=rng; rng(p.seed,'twister');
            [RS,worstRS]=robstab(CL);
            RPiniziale=[]; metodo="robgain";
            if ~NP
                RP=struct('LowerBound',0,'UpperBound',0); metodo="NP_FAIL";
            elseif RS.UpperBound<1
                RP=struct('LowerBound',0,'UpperBound',RS.UpperBound); metodo="LIMITE_DA_RS";
            else
                RP=robgain(CL(5:8,:),1);
                if RP.LowerBound>RP.UpperBound
                    RPiniziale=RP;
                    RP=robgain(CL(5:8,:),1,robOptions('MussvOptions','m9'));
                    metodo="robgain_retry_m9";
                end
            end
            muGriglia=struct;
            if ismember(k,[4 6 8 9])
                [N,Delta,struttura]=lftdata(CL(5:8,:));
                nd=size(Delta,1); N11=N(1:nd,1:nd);
                bounds=mussv(frd(N11,p.omegaMu),struttura,'s');
                muGriglia=struct('omega',p.omegaMu,'upper',squeeze(bounds.ResponseData(1,1,:)), ...
                    'lower',squeeze(bounds.ResponseData(1,2,:)));
            end
            rng(statoRng);
            esitoRS=esito(RS); esitoRP=esito(RP);
            analisi{k,modello}=struct('NS',NS,'NP',NP,'norma',norma,'RS',RS,'RP',RP, ...
                'RPiniziale',RPiniziale,'worstRS',worstRS,'muGriglia',muGriglia,'metodoRP',metodo);
            riga=riga+1;
            righe(riga,:)={nomi(k),origine(k),nomiModello(modello),order(K{k}),NS,norma,NP, ...
                RS.LowerBound,RS.UpperBound,esitoRS,RP.LowerBound,RP.UpperBound,esitoRP,metodo,RS.CriticalFrequency};
        end
    end
    confronto=cell2table(righe,'VariableNames',{'Controllore','Sintesi','Analisi','Ordine','NS', ...
        'NormaNominale','NP','RS_lower','RS_upper','RS','RP_lower','RP_upper','RP','MetodoRP','FrequenzaCritica'});
    save(fileAnalisi,'analisi','confronto','nomi','K','origine','firma','-v7');
else
    if ~isfile(fileAnalisi),fileAnalisi=fullfile(p.dati,'confronto_robusto.mat');end
    assert(isfile(fileAnalisi),'SEA:Cache','Manca analisi A/B validata: eseguire completa.');
    a=load(fileAnalisi); assert(isequal(a.firma,firma),'SEA:Cache','Firma analisi diversa.');
    analisi=a.analisi; confronto=a.confronto;
    disp('RS/RP CARICATE dalla campagna completa; nuove verifiche nominali qui sotto.');
    for k=1:numel(K)
        for modello=1:2
            [~,CL]=interconnessione_sea(piante{modello},p,size(K{k},2)-2,K{k});
            assert(isstable(CL.NominalValue)==analisi{k,modello}.NS);
            assert(abs(norm(CL.NominalValue(5:8,1:4),inf)-analisi{k,modello}.norma)<1e-6);
        end
    end
end
% Non trasferire PASS fra A e B: il fit certifica solo i campioni esplicitati.
writetable(confronto,fullfile(p.risultati,'confronto_robusto.csv')); disp(confronto);

%% 4 - Storia D-K e margini: gli insiemi oltre raggio uno sono differenti
storia=cell(1,2);
for modello=1:2
    info=candidati{modello}.info; dati=zeros(numel(info),4);
    for j=1:numel(info),dati(j,:)=[j info(j).PeakMu info(j).gamma order(info(j).K)];end
    storia{modello}=array2table(dati,'VariableNames',{'Iterazione','PeakMu','GammaScalata','Ordine'});
    writetable(storia{modello},fullfile(p.risultati,"dk_"+modello+".csv"));
end
if p.figure
    f=figure('Name','Robustezza A/B e D-K','Color','w'); theme(f,'light'); tiledlayout(1,2);
    nexttile; bar(reshape(confronto.RS_lower,2,[])'); yline(1,'--k');
    set(gca,'XTick',1:numel(nomi),'XTickLabel',nomi); xtickangle(45); grid on;
    ylabel('Limite inferiore RS'); legend('A parametrico','B concentrato');
    nexttile; plot(storia{1}.Iterazione,storia{1}.PeakMu,'o-',storia{2}.Iterazione,storia{2}.PeakMu,'s-');
    yline(1,'--k'); grid on; xlabel('Iterazione'); ylabel('Picco mu'); legend('Sintesi A','Sintesi B');
    exportgraphics(f,fullfile(p.risultati,'robustezza.png'),'Resolution',170);
end

function stato=esito(m)
% Un intervallo numericamente invertito non viene mai riordinato.
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
