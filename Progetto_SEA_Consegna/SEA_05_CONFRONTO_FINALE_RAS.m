%% 1 - Stessi dieci impianti e quindici condizioni iniziali per tutti i K
cartella=fileparts(mfilename('fullpath')); addpath(cartella); p=parametri_sea;
a=load(fullfile(cartella,'dati/banca_consolidata.mat'),'banca'); banca=a.banca;
a=load(fullfile(cartella,'dati/modelli_S1.mat'),'modelli'); modelli=a.modelli;
a=load(fullfile(cartella,'dati/robustezza_S1.mat')); nomi=a.nomi; K=a.K;
confrontoRobusto=a.confrontoRobusto; nK=numel(K);
disp('Campioni [dwn1,dzeta1,dwn2,dzeta2], comuni per tutti:'); disp(p.samples);
if p.modalita=="completa"
    %% 2 - Nominale e dieci impianti fisici: stabilita prima delle prestazioni
    righe=cell(10*nK,12); tracce=cell(10,nK); nominali=cell(nK,1); riga=0;
    for campione=1:10
        v=p.samples(campione,:);
        Pianta=usubs(modelli.PA,'dwn1',v(1),'dzeta1',v(2),'dwn2',v(3),'dzeta2',v(4));
        for k=1:nK
            m=metriche_lineari(Pianta,K{k},p); tracce{campione,k}=m;
            if campione==1, nominali{k}=m; end
            riga=riga+1;
            righe(riga,:)={campione,nomi(k),m.stable,m.Ts,m.overshoot,m.dcError, ...
                m.peakU,m.rmsU,m.disturbancePeak,m.disturbanceControl,m.disturbanceDC,m.noiseGain};
        end
    end
    campioni=cell2table(righe,'VariableNames',{'Impianto','Controllore','Stabile', ...
        'Ts_s','Overshoot_percent','ErroreDC_rel','PiccoTracking_Nm','RMSTracking_Nm', ...
        'PiccoDisturbo_rad','ComandoDisturbo_Nm','ResiduoDisturboDC_rad','GuadagnoRumoreComando'});
    writetable(campioni,fullfile(cartella,'dati/dieci_impianti.csv'));

    %% 3 - Tracking/disturbo nominali non lineari: entrambi i giunti
    nonlineari=cell(nK,4); righe=cell(4*nK,7); riga=0;
    for k=1:nK
        for prova=1:4
            r=zeros(2,1); d=r;
            if prova<=2, r(prova)=p.reference; else, d(prova-2)=p.disturbance; end
            z0=zeros(14+order(K{k}),1);
            nl=simula_sea(p,banca.plant,K{k},z0,r,d);
            err=NaN; peak=NaN;
            if nl.completed
                if prova<=2, linear=nominali{k}.tracking{prova}; else, linear=nominali{k}.disturbance{prova-2}; end
                err=max(abs(nl.q-linear(:,1:2)),[],'all'); peak=max(abs(nl.u),[],'all');
            end
            nl.states=[]; % per questi grafici bastano q/u; tutti gli stati sono stati integrati
            nonlineari{k,prova}=nl;
            riga=riga+1; righe(riga,:)={nomi(k),prova,nl.completed,err,peak,nl.status,nl.message};
            fprintf('NL %s prova %d: %s\n',nomi(k),prova,nl.status);
        end
    end
    confrontoNL=cell2table(righe,'VariableNames',{'Controllore','Prova','Completa', ...
        'ScartoMaxLIN_NL_rad','PiccoU_Nm','Stato','Dettaglio'});
    writetable(confrontoNL,fullfile(cartella,'dati/lineare_nonlineare.csv'));

    %% 4 - RAS empirica: stato completo; tre esiti distinti, nessun bordo interpolato
    nP=size(p.rasPointsDeg,1); ras=cell(nK,nP); righe=cell(nK*nP,8); riga=0;
    for k=1:nK
        for punto=1:nP
            dq=deg2rad(p.rasPointsDeg(punto,:)'); z0=zeros(14+order(K{k}),1);
            z0([1 2 5 6])=[dq;dq]; % velocita, drive, controller nulli
            nl=simula_sea(p,banca.plant,K{k},z0,zeros(2,1),zeros(2,1));
            convergente=false; esito="NUMERICAMENTE_INCONCLUDENTE";
            if nl.completed
                coda=nl.time>=p.time(end)-1; z=nl.states;
                convergente=max(abs(z(coda,[1 2 5 6])),[],'all')<=p.rasPositionTol && ...
                    max(abs(z(coda,[3 4 7 8])),[],'all')<=p.rasVelocityTol;
                esito="NON_CONVERGENTE_ENTRO_T";
                if convergente,esito="CONVERGENTE";end
                nl.tailPositionRad=max(abs(z(coda,[1 2 5 6])),[],'all');
                nl.tailVelocityRadS=max(abs(z(coda,[3 4 7 8])),[],'all');
            end
            nl.states=[]; % conservati q/u e indicatori della coda, senza MAT enormi
            ras{k,punto}=nl; riga=riga+1;
            righe(riga,:)={nomi(k),p.rasPointsDeg(punto,1),p.rasPointsDeg(punto,2), ...
                convergente,nl.completed,esito,nl.seconds,nl.message};
            fprintf('RAS %s %d/%d: %s\n',nomi(k),punto,nP,esito);
        end
    end
    rasTable=cell2table(righe,'VariableNames',{'Controllore','Q1deg','Q2deg', ...
        'Converge','Completa','Esito','SecondiCalcolo','Dettaglio'});
    writetable(rasTable,fullfile(cartella,'dati/ras_empirica.csv'));
    confronto=struct('campioni',campioni,'tracce',{tracce},'nominali',{nominali}, ...
        'nonlineari',{nonlineari},'confrontoNL',confrontoNL,'ras',{ras},'rasTable',rasTable);
    save(fullfile(cartella,'dati/confronto_finale.mat'),'confronto','-v7');
else
    a=load(fullfile(cartella,'dati/confronto_finale.mat'),'confronto'); confronto=a.confronto;
    fprintf('Dieci impianti, non lineare e RAS CARICATI dal run verificato.\n');
end

%% 5 - Quadro finale: nominale, margini A/B, ordini ed evidenza empirica
righe=cell(nK,14);
for k=1:nK
    ix=confrontoRobusto.Controllore==nomi(k);
    Arow=confrontoRobusto(ix & confrontoRobusto.Modello=="A_parametrico",:);
    Brow=confrontoRobusto(ix & confrontoRobusto.Modello=="B_concentrato",:);
    m=confronto.nominali{k}; camp=confronto.campioni.Controllore==nomi(k);
    punti=confronto.rasTable.Controllore==nomi(k);
    righe(k,:)={nomi(k),order(K{k}),m.Ts,m.overshoot,m.dcError,Arow.RS_lower,Brow.RS_lower, ...
        Arow.RP_lower,Brow.RP_lower,Arow.RS_lower-Brow.RS_upper, ...
        Arow.RS_upper-Brow.RS_lower,sum(confronto.campioni.Stabile(camp)), ...
        sum(confronto.rasTable.Converge(punti)),sum(~confronto.rasTable.Completa(punti))};
end
quadro=cell2table(righe,'VariableNames',{'Controllore','Ordine','Ts_s','Overshoot_percent', ...
    'ErroreDC_rel','RS_A_lower','RS_B_lower','RP_A_lower','RP_B_lower', ...
    'DifferenzaRS_min','DifferenzaRS_max','StabiliSu10','RasConvergentiSu15','RasInconcludenti'});
disp(quadro); writetable(quadro,fullfile(cartella,'dati/quadro_finale.csv'));

% Interfacce numeriche per i futuri SLX degli studenti; nessun modello modificato.
interfacce=struct([]); impianto=banca.plant;
tuttiIngressi=["r1","r2","q1_mis","q2_mis","theta1_mis","theta2_mis"];
for k=1:nK
    [Ak,Bk,Ck,Dk]=ssdata(K{k});
    ingressi=tuttiIngressi(1:size(K{k},2));
    interfacce(k).nome=nomi(k);interfacce(k).Ak=Ak;interfacce(k).Bk=Bk;
    interfacce(k).Ck=Ck;interfacce(k).Dk=Dk;interfacce(k).ingressi=ingressi;
    interfacce(k).uscite=["u1_Nm","u2_Nm"];interfacce(k).x0=zeros(size(Ak,1),1);
end
save(fullfile(cartella,'dati/interfacce_simulink.mat'),'interfacce','impianto','-v7');

%% 6 - Poche figure: tracking, disturbi, dieci impianti e sezione RAS
if p.figure
    for tipo=1:2
        f=figure('Name','Lineare e non lineare','Color','white','Theme','light','Position',[50 50 1400 700]);
        tiledlayout(2,4,'TileSpacing','compact');
        for k=1:nK
            nexttile; nl=confronto.nonlineari{k,1+2*(tipo-1)};
            if tipo==1,lin=confronto.nominali{k}.tracking{1};else,lin=confronto.nominali{k}.disturbance{1};end
            colororder([0 .45 .74;.85 .33 .10]);
            plot(p.time,rad2deg(lin(:,1:2)),'--'); hold on;
            set(gca,'ColorOrderIndex',1);
            if nl.completed,plot(nl.time,rad2deg(nl.q));end
            if k==1,legend('LIN q1','LIN q2','NL q1','NL q2','Location','best');end
            title(nomi(k),'Interpreter','none'); grid on; xlabel('Tempo [s]'); ylabel('Delta q [deg]');
        end
        exportgraphics(f,fullfile(cartella,'figure',"05_lin_nl_"+tipo+".png"),'Resolution',170);
    end
    f=figure('Name','Dieci impianti fisici','Color','white','Theme','light','Position',[50 50 1400 700]);
    tiledlayout(2,4,'TileSpacing','compact');
    for k=1:nK
        nexttile; hold on;
        for j=1:10
            m=confronto.tracce{j,k};
            if m.stable
                if j==1
                    plot(p.time,rad2deg(m.tracking{1}(:,1)),'Color','k','LineWidth',1.2);
                else
                    plot(p.time,rad2deg(m.tracking{1}(:,1)),'Color',[.5 .65 .8]);
                end
            end
        end
        yline(5,'--k'); grid on; title(nomi(k),'Interpreter','none'); xlabel('Tempo [s]'); ylabel('Delta q1 [deg]');
    end
    exportgraphics(f,fullfile(cartella,'figure/05_dieci_impianti.png'),'Resolution',170);
    f=figure('Name','Sezione empirica di attrazione','Color','white','Theme','light','Position',[50 50 1400 700]);
    tiledlayout(2,4,'TileSpacing','compact');
    for k=1:nK
        nexttile; t=confronto.rasTable(confronto.rasTable.Controllore==nomi(k),:); hold on;
        plot(t.Q1deg(t.Converge),t.Q2deg(t.Converge),'o','MarkerFaceColor',[.1 .6 .3],'Color',[.1 .6 .3]);
        nc=t.Completa & ~t.Converge; plot(t.Q1deg(nc),t.Q2deg(nc),'rx','LineWidth',1.5);
        u=~t.Completa; plot(t.Q1deg(u),t.Q2deg(u),'s','Color',[.5 .5 .5],'MarkerFaceColor',[.7 .7 .7]);
        grid on; axis equal; xlim([-50 50]); ylim([-50 50]);
        title(nomi(k),'Interpreter','none'); xlabel('Delta q1 [deg]'); ylabel('Delta q2 [deg]');
    end
    exportgraphics(f,fullfile(cartella,'figure/05_ras.png'),'Resolution',170);
end

function m=metriche_lineari(P,K,p)
% Una sola realizzazione di K, anche se riferimento e feedback sono distinti.
[A,B,C,D]=ssdata(P); assert(norm(D,'fro')<1e-12);
[Ak,Bk,Ck,Dk]=ssdata(K); nk=size(Ak,1); ny=size(K,2)-2;
Cy=C(1:ny,:); Cq=C(1:2,:); Bu=B(:,1:2); Bd=B(:,3:4);
Br=Bk(:,1:2); By=Bk(:,3:end); Dr=Dk(:,1:2); Dy=Dk(:,3:end);
Acl=[A+Bu*Dy*Cy Bu*Ck;By*Cy Ak];
Ccl=[Cq zeros(2,nk);Dy*Cy Ck];
Rsys=ss(Acl,[Bu*Dr;Br],Ccl,[zeros(2);Dr]);
Dsys=ss(Acl,[Bd;zeros(nk,2)],Ccl,zeros(4,2));
Nsys=ss(Acl,[Bu*Dy;By],[Dy*Cy Ck],Dy);
m=struct('stable',max(real(eig(Acl)))<-1e-8,'Ts',NaN,'overshoot',NaN, ...
    'dcError',NaN,'peakU',NaN,'rmsU',NaN,'disturbancePeak',NaN, ...
    'disturbanceControl',NaN,'disturbanceDC',NaN,'noiseGain',NaN, ...
    'tracking',{{}},'disturbance',{{}});
if ~m.stable,return;end
tracking=cell(1,2); disturbance=cell(1,2); metrics=zeros(2,8);
for j=1:2
    u=zeros(numel(p.time),2); u(:,j)=p.reference; y=lsim(Rsys,u,p.time); tracking{j}=y;
    target=dcgain(Rsys(j,j))*p.reference;
    bad=find(abs(y(:,j)-target)>.02*p.reference,1,'last'); ts=0;
    if ~isempty(bad),ts=Inf;if bad<numel(p.time),ts=p.time(bad+1);end,end
    u=zeros(numel(p.time),2); u(p.time>=1,j)=p.disturbance;
    yd=lsim(Dsys,u,p.time); disturbance{j}=yd;
    metrics(j,:)=[ts,max(0,(max(y(:,j))/p.reference-1)*100), ...
        abs(target/p.reference-1),max(abs(y(:,3:4)),[],'all'), ...
        max(sqrt(trapz(p.time,y(:,3:4).^2)/(p.time(end)-p.time(1)))), ...
        max(abs(yd(:,1:2)),[],'all'),max(abs(yd(:,3:4)),[],'all'), ...
        max(abs(dcgain(Dsys(1:2,j))*p.disturbance))];
end
m.Ts=max(metrics(:,1));m.overshoot=max(metrics(:,2));m.dcError=max(metrics(:,3));
m.peakU=max(metrics(:,4));m.rmsU=max(metrics(:,5));m.disturbancePeak=max(metrics(:,6));
m.disturbanceControl=max(metrics(:,7));m.disturbanceDC=max(metrics(:,8));m.noiseGain=norm(Nsys,inf);
m.tracking=tracking;m.disturbance=disturbance;
end
