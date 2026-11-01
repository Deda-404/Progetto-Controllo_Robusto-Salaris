%% 1 - Banca comune: dieci impianti fisici e quindici condizioni RAS separate
cartella=fileparts(mfilename('fullpath')); addpath(cartella); p=parametri_sea;
if ~isfile(fullfile(p.risultati,'incertezze.mat')),run(fullfile(cartella,'incertezze_attuatori.m'));end
a=load(fullfile(p.risultati,'modello.mat')); modello=a.modello;
a=load(fullfile(p.risultati,'incertezze.mat')); modelli=a.modelli;
a=load(fullfile(p.dati,'banca_validata.mat')); banca=a.banca;
nomi=[string({banca.controllers.name}),"MuN1"]; controllori=[{banca.controllers.K},{banca.muRumore}];
fileMu=fullfile(p.risultati,'sintesi_mu.mat');
if ~isfile(fileMu),fileMu=fullfile(p.dati,'sintesi_mu.mat');end
if isfile(fileMu)
    a=load(fileMu); controllori=[controllori,{a.candidati{1}.K,a.candidati{2}.K}]; nomi=[nomi,"Mu_A","Mu_B"];
end
fileH=fullfile(p.risultati,'sintesi_hinf.mat');
if ~isfile(fileH),fileH=fullfile(p.dati,'sintesi_hinf.mat');end
if isfile(fileH)
    a=load(fileH); controllori=[controllori,{a.sintesi.Kpid}];
    nomi=[nomi,"PID_nuovo"];
    % Le risintesi Hinf1/Hinf2 riproducono i comparatori: niente prove duplicate.
end

%% 2 - Dieci realizzazioni comuni, piu nominale: stessa fisica per tutti
% A e B sono descrizioni: a K e pianta fisica fissati la risposta e unica.
righe=cell(numel(nomi)*(p.campioni+1),9); riga=0; risposte=cell(numel(nomi),p.campioni+1);
for k=1:numel(nomi)
    for j=0:p.campioni
        if j==0,pianta=modello.P0;
        else,pianta=modello.meccanica*blkdiag(modelli.campioniAtt(:,:,j),eye(2));end
        [~,CL]=interconnessione_sea(pianta,p,size(controllori{k},2)-2,controllori{k});
        stabile=isstable(CL); polo=max(real(pole(CL)));
        erroreDC=NaN; picco=NaN; disturbo=NaN; ts=NaN; overshoot=NaN;
        if stabile
            risposta=step(CL(1:4,1:2)*p.rAmp,p.tempo); risposte{k,j+1}=risposta;
            erroreDC=max(abs(dcgain(CL(1:2,1:2))-eye(2)),[],'all');
            picco=max(abs(risposta(:,3:4,:)),[],'all');
            yd=step(CL(1:2,3:4)*p.dAmp,p.tempo);
            disturbo=max(abs(yd),[],'all'); ts=0; overshoot=0;
            for asse=1:2
                info=stepinfo(risposta(:,asse,asse),p.tempo,p.rAmp*dcgain(CL(asse,asse)));
                ts=max(ts,info.SettlingTime);
                overshoot=max(overshoot,max(0,100*(max(risposta(:,asse,asse))/p.rAmp-1)));
            end
        end
        riga=riga+1; righe(riga,:)={nomi(k),j,stabile,polo,erroreDC,picco,disturbo,ts,overshoot};
    end
end
impianti=cell2table(righe,'VariableNames',{'Controllore','Impianto','Stabile','PoloDominante', ...
    'ErroreDC','PiccoComando','PiccoDisturboRad','Assestamento','OvershootPercent'});
writetable(impianti,fullfile(p.risultati,'dieci_impianti.csv'));

%% 3 - Rumore encoder comune, ZOH esplicito e comando non saturato
statoRng=rng; rng(p.seed,'twister'); v=p.sigmaY*randn(numel(p.tempoRumore),4); rng(statoRng);
righe=cell(numel(nomi),7);
for k=1:numel(nomi)
    ny=size(controllori{k},2)-2;
    [~,CL]=interconnessione_sea(modello.P0,p,ny,controllori{k});
    fprintf('Rumore ZOH e picchi intercampione: %s\n',nomi(k));
    metriche=rumoreContinuo(CL(1:4,5:4+ny),v(:,1:ny),p.tempoRumore);
    righe(k,:)=[{nomi(k)},num2cell(metriche)];
end
rumore=cell2table(righe,'VariableNames',{'Controllore','PiccoCampioni','RMSCampioni', ...
    'PiccoTraCampioni','RMSIntegrato','ErroreQuadratura','PiccoPosizioneRad'});
writetable(rumore,fullfile(p.risultati,'rumore.csv'));

%% 4 - Non lineare nominale: tracking e disturbo distinti
fileRas=fullfile(p.risultati,'ras.mat');
if p.modalita=="completa"
    righe=cell(2*numel(nomi),6); traiettorie=cell(numel(nomi),2);
    for k=1:numel(nomi)
        for prova=1:2
            scenario=struct('r',[p.rAmp;0]*(prova==1),'d',[p.dAmp;0]*(prova==2),'tempo',p.tempo);
            out=simula_sea(controllori{k},modello,p,scenario); traiettorie{k,prova}=out;
            righe(2*k-2+prova,:)={nomi(k),prova,out.completato,out.esito,max(abs(out.u),[],'all'),max(abs(out.q),[],'all')};
        end
    end
    nonlineare=cell2table(righe,'VariableNames',{'Controllore','ProvaTrackingDisturbo','Completato','Esito','PiccoU','PiccoQ'});
    writetable(nonlineare,fullfile(p.risultati,'nonlineare.csv'));
    %% 5 - RAS: cinque direzioni per tre distanze, nessuna frontiera dedotta
    punti=zeros(numel(p.rasRaggi)*numel(p.rasDirezioni),2);
    for j=1:numel(p.rasRaggi)
        indici=(j-1)*numel(p.rasDirezioni)+(1:numel(p.rasDirezioni));
        punti(indici,:)=p.rasRaggi(j)*[cos(p.rasDirezioni),sin(p.rasDirezioni)];
    end
    righe=cell(numel(nomi)*size(punti,1),6); percorsi=cell(numel(nomi),size(punti,1));
    for k=1:numel(nomi)
        for j=1:size(punti,1)
            fprintf('RAS %s, punto %d/%d\n',nomi(k),j,size(punti,1));
            out=simula_sea(controllori{k},modello,p,struct('dq',punti(j,:)')); percorsi{k,j}=out;
            righe((k-1)*size(punti,1)+j,:)={nomi(k),rad2deg(punti(j,1)),rad2deg(punti(j,2)),out.esito,out.tempo(end),out.secondi};
        end
    end
    ras=cell2table(righe,'VariableNames',{'Controllore','DeltaQ1deg','DeltaQ2deg','Esito','TempoFinale','SecondiCalcolo'});
    save(fileRas,'ras','percorsi','punti','nonlineare','traiettorie','nomi','controllori','-v7');
else
    if ~isfile(fileRas),fileRas=fullfile(p.dati,'ras.mat');end
    assert(isfile(fileRas),'SEA:Cache','RAS assente: eseguire modalita completa.');
    a=load(fileRas); ras=a.ras; percorsi=a.percorsi; punti=a.punti;
    assert(isequal(nomi,a.nomi) && isequaln(controllori,a.controllori), ...
        'SEA:CacheRAS','Controllori diversi dalla campagna RAS salvata.');
    nonlineare=a.nonlineare; traiettorie=a.traiettorie;
    disp('RAS CARICATA dalla campagna completa. Verifica locale LQG eseguita ora.');
    locale=simula_sea(controllori{1},modello,p,struct('dq',deg2rad([5;0])));
    assert(locale.convergenza,'SEA:RASLocale','Verifica locale non convergente.');
end
writetable(ras,fullfile(p.risultati,'ras.csv'));
save(fullfile(p.risultati,'confronto.mat'),'impianti','rumore','risposte','nomi','-v7');

%% 6 - Grafici: origine all'equilibrio, traiettorie e classificazioni separate
if p.figure
    f=figure('Name','Dieci impianti fisici comuni','Color','w','Position',[20 20 1400 950]); theme(f,'light'); tiledlayout(3,4);
    for k=1:numel(nomi)
        nexttile;
        for j=1:p.campioni+1
            if ~isempty(risposte{k,j}),plot(p.tempo,rad2deg(risposte{k,j}(:,1,1)));hold on;end
        end
        yline(5,'--k'); title(nomi(k),'Interpreter','none'); grid on; xlabel('s'); ylabel('delta q1 [deg]');
    end
    exportgraphics(f,fullfile(p.risultati,'dieci_impianti.png'),'Resolution',170);
    f=figure('Name','RAS empirica','Color','w','Position',[20 20 1400 950]); theme(f,'light'); tiledlayout(3,4);
    for k=1:numel(nomi)
        nexttile; hold on;
        for j=1:size(punti,1)
            out=percorsi{k,j}; plot(rad2deg(out.q(:,1)),rad2deg(out.q(:,2)),'Color',[.75 .8 .85]);
            if out.esito=="CONVERGENZA",simbolo='go';
            elseif out.esito=="MANCATA_CONVERGENZA",simbolo='rs';
            elseif out.esito=="DIVERGENZA_OSSERVATA",simbolo='rx';
            elseif out.esito=="TIMEOUT",simbolo='md';
            else,simbolo='k+';
            end
            plot(rad2deg(punti(j,1)),rad2deg(punti(j,2)),simbolo,'LineWidth',1.5);
        end
        plot(0,0,'k.'); title(nomi(k),'Interpreter','none'); grid on;
        xlim([-40 40]); ylim([-40 40]); xlabel('delta q1 [deg]'); ylabel('delta q2 [deg]');
    end
    exportgraphics(f,fullfile(p.risultati,'ras.png'),'Resolution',170);
end

function metriche=rumoreContinuo(sys,v,t)
% Propagazione ZOH esatta, ripresa dalla diagnostica originale del progetto.
% La scansione temporale verifica picchi osservati; non un massimo rigoroso.
dt=t(2)-t(1); [T,A]=balance(sys.A); modello=ss(A,T\sys.B,sys.C*T,sys.D);
[y,~,x]=lsim(c2d(modello,dt,'zoh'),v,t);
ultimo=NaN; errore=Inf; picco=0;
for risoluzione=[80 160 320]
    tau=unique([0 logspace(-14,log10(dt),risoluzione) linspace(0,dt,40)]);
    energia=zeros(numel(tau),1);
    for h=1:numel(tau)
        if tau(h)==0
            yy=x(1:end-1,:)*modello.C'+v(1:end-1,:)*modello.D';
        else
            sub=c2d(modello,tau(h),'zoh');
            yy=(x(1:end-1,:)*sub.A'+v(1:end-1,:)*sub.B')*sub.C'+v(1:end-1,:)*sub.D';
        end
        uu=yy(:,3:4); energia(h)=sum(uu.^2,'all'); picco=max(picco,max(abs(uu),[],'all'));
    end
    rmsIntegrato=sqrt(trapz(tau,energia)/(2*t(end)));
    errore=abs(rmsIntegrato-ultimo)/max(rmsIntegrato,eps);
    if errore<.02,break;end
    ultimo=rmsIntegrato;
end
assert(errore<.02,'SEA:Rumore','Quadratura RMS non convergente.');
metriche=[max(abs(y(:,3:4)),[],'all'),sqrt(mean(y(:,3:4).^2,'all')), ...
    picco,rmsIntegrato,errore,max(abs(y(:,1:2)),[],'all')];
end
