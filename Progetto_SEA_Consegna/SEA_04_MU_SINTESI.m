%% 1 - Stessi pesi prestazionali, due famiglie S1 e banca originale conservata
cartella=fileparts(mfilename('fullpath')); addpath(cartella); p=parametri_sea;
a=load(fullfile(cartella,'dati/banca_consolidata.mat'),'banca'); banca=a.banca;
a=load(fullfile(cartella,'dati/modelli_S1.mat'),'modelli'); modelli=a.modelli;
W1=banca.hinf.W1; W2=banca.hinf.W2; Mo=banca.hinf.Mo;
piante={modelli.PA,modelli.PB}; nomiModello=["A_parametrico","B_concentrato"];
fprintf('D-K: massimo %d iterazioni, fit [%d %d], stessi pesi A/B.\n', ...
    p.dkIterations,p.dkFitOrder(1),p.dkFitOrder(2));

%% 2 - Due sintesi dedicate: una per famiglia; i sei K originali non cambiano
if p.modalita=="completa"
    candidati=cell(1,2);
    for modello=1:2
        % Pianta generalizzata: [r;d;u] -> [W1*(q-Mo*r);W2*u;r;q].
        Pn=piante{modello}(1:2,:); Pn.InputName={'u1','u2','d1','d2'};
        Pn.OutputName={'q1','q2'};
        Mn=ss(Mo); Mn.InputName={'r1','r2'}; Mn.OutputName={'qm1','qm2'};
        We=ss(W1); We.InputName={'e1','e2'}; We.OutputName={'ze1','ze2'};
        Wu=ss(W2); Wu.InputName={'u1','u2'}; Wu.OutputName={'zu1','zu2'};
        Pgen=connect(Pn,Mn,We,Wu,sumblk('e1=q1-qm1'),sumblk('e2=q2-qm2'), ...
            {'r1','r2','d1','d2','u1','u2'}, ...
            {'ze1','ze2','zu1','zu2','r1','r2','q1','q2'});
        rng(p.seed,'twister');
        opzioni=musynOptions('Display','short','MaxIter',p.dkIterations, ...
            'FitOrder',p.dkFitOrder,'FullDG',false,'MixedMU','on', ...
            'FrequencyGrid',logspace(-2,4,121),'UseParallel',false);
        [Knuovo,obiettivo,info]=musyn(Pgen,4,2,opzioni);
        candidati{modello}=struct('K',Knuovo,'objective',obiettivo,'info',info, ...
            'designModel',nomiModello(modello),'origin','D-K S1 ESEGUITA');
        save(fullfile(cartella,'dati/mu_sintesi_S1.mat'),'candidati','-v7');
    end
else
    a=load(fullfile(cartella,'dati/mu_sintesi_S1.mat'),'candidati'); candidati=a.candidati;
    fprintf('D-K A/B CARICATE dal run completo verificato.\n');
end
nomi=[string({banca.controllers.name}),"Mu_A","Mu_B"];
K=[{banca.controllers.K}, {candidati{1}.K,candidati{2}.K}];

%% 3 - Post-analisi: stesso controllore fisso applicato ad A e B
if p.modalita=="completa"
    risultati=cell(numel(K),2); righe=cell(2*numel(K),14); riga=0;
    for k=1:numel(K)
        for modello=1:2
            fprintf('Post-analisi %s su %s...\n',nomi(k),nomiModello(modello));
            ny=size(K{k},2)-2; Pn=piante{modello}(1:ny,:);
            uscite={'q1','q2','theta1','theta2'}; Pn.OutputName=uscite(1:ny);
            Pn.InputName={'u1','u2','d1','d2'};
            Kn=K{k}; Kn.InputName=[{'r1','r2'},uscite(1:ny)]; Kn.OutputName={'u1','u2'};
            Mn=ss(Mo); Mn.InputName={'r1','r2'}; Mn.OutputName={'qm1','qm2'};
            We=ss(W1); We.InputName={'e1','e2'}; We.OutputName={'ze1','ze2'};
            Wu=ss(W2); Wu.InputName={'u1','u2'}; Wu.OutputName={'zu1','zu2'};
            CL=connect(Pn,Kn,Mn,We,Wu,sumblk('e1=q1-qm1'),sumblk('e2=q2-qm2'), ...
                {'r1','r2','d1','d2'},{'q1','q2','u1','u2','ze1','ze2','zu1','zu2'}, ...
                connectOptions('Simplify',false));
            NS=isstable(CL.NominalValue); norma=norm(CL.NominalValue(5:8,:),inf);
            NP=NS && norma<1; rng(p.seed,'twister');
            [RS,worstRS]=robstab(CL);
            assert(RS.LowerBound<=RS.UpperBound,'SEA:RS','Intervallo RS invertito.');
            metodoRP="robgain";
            if ~NP
                RP=struct('LowerBound',0,'UpperBound',0); metodoRP="ZERO_PER_NP";
            elseif RS.UpperBound<1
                RP=struct('LowerBound',0,'UpperBound',RS.UpperBound); metodoRP="LIMITE_DA_RS";
            else
                [RP,~]=robgain(CL(5:8,:),1);
                if RP.LowerBound>RP.UpperBound
                    % Conservare il primo esito; ripetere soltanto il bound incoerente.
                    RPinitial=RP;
                    [RP,~]=robgain(CL(5:8,:),1,robOptions('MussvOptions','m9'));
                    metodoRP="robgain_m9_DOPO_INTERVALLO_INVERTITO";
                else
                    RPinitial=struct;
                end
            end
            esitoRS=esito(RS); esitoRP=esito(RP);
            muGrid=struct;
            if k==4 || k==6
                % LFT superiore: wD=Delta*zD; N11 collega le sole porte incerte.
                [N,Delta,blocchi]=lftdata(CL(5:8,:)); nd=size(Delta,1);
                N11=N(1:nd,1:nd); wMu=logspace(-2,4,121);
                bounds=mussv(frd(N11,wMu),blocchi,'s');
                muGrid=struct('omega',wMu,'upper',squeeze(bounds.ResponseData(1,1,:)), ...
                    'lower',squeeze(bounds.ResponseData(1,2,:)));
            end
            risultati{k,modello}=struct('RS',RS,'RP',RP,'NS',NS,'NP',NP, ...
                'nominalNorm',norma,'worstRS',worstRS,'RPmethod',metodoRP, ...
                'RSoutcome',esitoRS,'RPoutcome',esitoRP,'muGrid',muGrid);
            if metodoRP=="robgain_m9_DOPO_INTERVALLO_INVERTITO"
                risultati{k,modello}.RPinitial=RPinitial;
            end
            riga=riga+1;
            righe(riga,:)={nomi(k),nomiModello(modello),order(K{k}),NS,norma,NP, ...
                RS.LowerBound,RS.UpperBound,esitoRS,RP.LowerBound,RP.UpperBound, ...
                esitoRP,metodoRP,RS.CriticalFrequency};
            confrontoRobusto=cell2table(righe(1:riga,:),'VariableNames', ...
                {'Controllore','Modello','Ordine','NS','NormaNominaleComune','NP', ...
                'RS_lower','RS_upper','RS','RP_lower','RP_upper','RP','MetodoRP','FrequenzaCritica'});
            writetable(confrontoRobusto,fullfile(cartella,'dati/confronto_robusto.csv'));
            save(fullfile(cartella,'dati/robustezza_S1.mat'),'risultati','confrontoRobusto','nomi','K','-v7');
        end
    end
    % Inclusione dimostrata per il box UNITARIO: confrontare le proprieta a raggio 1.
    % Le espansioni oltre il box sono diverse: non imporre un ordine globale dei margini.
    for k=1:numel(K)
        if risultati{k,2}.RS.LowerBound>1 && risultati{k,1}.RS.UpperBound<1
            confrontoRobusto.RS(2*k-1:2*k)="INCONCLUDENTE_INCLUSIONE";
        end
        if risultati{k,1}.RPoutcome=="INCONCLUDENTE" && risultati{k,2}.RPoutcome=="PASS"
            % Non riordinare l'intervallo invertito: conservarlo e usare un ALTRO bound.
            % RP su B unitario implica RP su A unitario; non quantifica RP_A oltre 1.
            risultati{k,1}.RPdirect=risultati{k,1}.RP;
            inferito=struct('LowerBound',1, ...
                'UpperBound',risultati{k,1}.RS.UpperBound);
            risultati{k,1}.RP=inferito; risultati{k,1}.RPoutcome="PASS_DA_INCLUSIONE_B";
            risultati{k,1}.RPmethod="INCLUSIONE_B_E_LIMITE_RS_A";
            confrontoRobusto.RP_lower(2*k-1)=inferito.LowerBound;
            confrontoRobusto.RP_upper(2*k-1)=inferito.UpperBound;
            confrontoRobusto.RP(2*k-1)="PASS_DA_INCLUSIONE_B";
            confrontoRobusto.MetodoRP(2*k-1)="INCLUSIONE_B_E_LIMITE_RS_A";
        end
    end
    writetable(confrontoRobusto,fullfile(cartella,'dati/confronto_robusto.csv'));
    save(fullfile(cartella,'dati/robustezza_S1.mat'),'risultati','confrontoRobusto','nomi','K','-v7');
else
    a=load(fullfile(cartella,'dati/robustezza_S1.mat')); risultati=a.risultati;
    confrontoRobusto=a.confrontoRobusto;
    fprintf('NS/NP/RS/RP CARICATE; nessuna nuova mu-analysis nel rapido.\n');
end
disp(confrontoRobusto);

%% 4 - Storia delle D-K e grafico dei margini dei controllori fissi
storia=cell(1,2);
for modello=1:2
    info=candidati{modello}.info; nIter=numel(info); vals=zeros(nIter,4);
    for j=1:nIter
        vals(j,:)=[j,info(j).PeakMu,info(j).gamma,order(info(j).K)];
    end
    storia{modello}=array2table(vals,'VariableNames',{'Iterazione','PeakMu','GammaScalata','Ordine'});
    writetable(storia{modello},fullfile(cartella,'dati',"dk_"+modello+".csv"));
end
if p.figure
    f=figure('Name','Confronto robusto A/B','Color','white','Theme','light'); tiledlayout(1,2);
    nexttile; margini=reshape(confrontoRobusto.RS_lower,2,[])'; bar(margini);
    yline(1,'--k'); set(gca,'XTick',1:numel(nomi),'XTickLabel',nomi); xtickangle(35);
    ylabel('Limite inferiore margine RS'); legend('A parametrico','B concentrato'); grid on;
    nexttile; plot(storia{1}.Iterazione,storia{1}.PeakMu,'o-', ...
        storia{2}.Iterazione,storia{2}.PeakMu,'s-');
    yline(1,'--k'); xlabel('Iterazione D-K'); ylabel('Picco mu riportato'); legend('Sintesi A','Sintesi B'); grid on;
    exportgraphics(f,fullfile(cartella,'figure/04_robustezza.png'),'Resolution',170);
end

function valore=esito(m)
if any(isnan([m.LowerBound m.UpperBound])) || m.LowerBound>m.UpperBound
    valore="INCONCLUDENTE";
elseif m.LowerBound>1
    valore="PASS";
elseif m.UpperBound<1
    valore="FAIL";
else
    valore="INCONCLUDENTE";
end
end
