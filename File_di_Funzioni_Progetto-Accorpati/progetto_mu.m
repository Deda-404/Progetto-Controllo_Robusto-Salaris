%% 1 - Due modelli, stessi pesi e controllori fissati della banca originale
cartella=fileparts(mfilename('fullpath')); addpath(cartella); p=parametri_sea;
if ~isfile(fullfile(p.risultati,'incertezze.mat')),run(fullfile(cartella,'incertezze_attuatori.m'));end
a=load(fullfile(p.risultati,'incertezze.mat')); modelli=a.modelli;
a=load(fullfile(p.dati,'banca_validata.mat')); banca=a.banca;
piante={modelli.PA,modelli.PB}; nomiModello=["A_parametrico","B_concentrato"];
firma=p.firma;
fileSintesi=fullfile(p.risultati,'sintesi_mu.mat');

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
%% 3 - Post-analisi a controllore fissato sulla mappa del riferimento
confronto=postanalisi_sea(p.modalita=="completa");
nomi=unique(confronto.Controllore,'stable');

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
    nexttile; margini=reshape(confronto.RS_lower,2,[])'; bar(margini); yline(1,'--k');
    set(gca,'XTick',1:numel(nomi),'XTickLabel',nomi); xtickangle(45); grid on;
    ylabel('Limite inferiore RS'); legend('A parametrico','B concentrato');
    nexttile; plot(storia{1}.Iterazione,storia{1}.PeakMu,'o-',storia{2}.Iterazione,storia{2}.PeakMu,'s-');
    yline(1,'--k'); grid on; xlabel('Iterazione'); ylabel('Picco mu'); legend('Sintesi A','Sintesi B');
    exportgraphics(f,fullfile(p.risultati,'robustezza.png'),'Resolution',170);
end

%% Riesame dei candidati gia prodotti, senza nuove sintesi
righe={};
for j=1:2
 for k=1:numel(candidati{j}.info)
 K=candidati{j}.info(k).K;[~,CL]=interconnessione_sea(modelli.PA.NominalValue,p,2,K);
 ns=isstable(CL);g=Inf;e=Inf;nu=Inf;
 if ns,g=norm(CL(5:8,1:4),inf);e=max(abs(dcgain(CL(1:2,1:2))-eye(2)),[],'all');nu=norm(CL(3:4,5:6),inf);end
 righe(end+1,:)={j,k,order(K),ns,g,e,nu};
 end
end
T=cell2table(righe,'VariableNames',{'Modello','Iterazione','Ordine','NS','NormaComune','ErroreDC','GuadagnoRumore'});disp(T);writetable(T,fullfile(p.risultati,'riesame_mu.csv'));

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
