function risultati=collaudo_simulink
%COLLAUDO_SIMULINK Originali invariati, parametri espliciti con SimulationInput.
cartella=fileparts(mfilename('fullpath')); addpath(cartella); p=parametri_sea;
radice=fileparts(cartella); modelliDir=fullfile(radice,'simulink','student_originals');
support=fullfile(radice,'src','model');
if ~isfolder(modelliDir)
    modelliDir=fullfile(cartella,'simulink'); support=fullfile(modelliDir,'support');
end
addpath(modelliDir,support);
assert(license('test','Simulink'),'SEA:Simulink','Simulink non disponibile.');
a=load(fullfile(p.dati,'banca_validata.mat')); b=a.banca;
a=load(fullfile(p.risultati,'incertezze.mat')); inc=a.modelli;
a=load(fullfile(p.risultati,'modello.mat')); modello=a.modello;
data=struct('A',b.plant.Afull,'B',b.plant.Bfull,'C',b.plant.CfullMeas,'D',zeros(4,2), ...
    'x0plant',zeros(14,1),'K',b.lqg.K,'Nr',b.lqg.Nr,'L',b.lqg.L, ...
    'Kx',b.lqgi.Kx,'Ki',b.lqgi.Ki,'xbar',b.plant.xbar,'taubar',b.plant.taubar);
[data.Ak1,data.Bk1,data.Ck1,data.Dk1]=ssdata(b.hinf1.Kfeedback);
[data.Ak2,data.Bk2,data.Ck2,data.Dk2]=ssdata(b.controllers(4).K);
data.Kpid=b.controllers(5).K; data.Kmu=b.controllers(6).K;
fileMu=fullfile(p.risultati,'sintesi_mu.mat');
if ~isfile(fileMu),fileMu=fullfile(p.dati,'sintesi_mu.mat');end
a=load(fileMu); candidati=a.candidati;
fisica=modello.fisica; nomi=fieldnames(fisica);
elementi=repmat(Simulink.BusElement,numel(nomi),1);
for j=1:numel(nomi)
    elementi(j).Name=nomi{j}; elementi(j).Dimensions=size(fisica.(nomi{j})); elementi(j).DataType='double';
end
data.slBus1=Simulink.Bus; data.slBus1.Elements=elementi;
files=dir(fullfile(modelliDir,'*.slx')); risultati=cell(28,1); tracce=cell(28,1); riga=0;
for k=1:numel(files)
    [~,nome]=fileparts(files(k).name); file=fullfile(files(k).folder,files(k).name);
    % Apertura in memoria per ispezionare SID e parametri, senza salvataggio.
    load_system(file); cleanup=onCleanup(@()close_system(nome,0));
    scope=find_system(nome,'BlockType','Scope');
    att=find_system(nome,'LookUnderMasks','all','MaskType','LTI Block');
    if isempty(att),att=find_system(nome,'LookUnderMasks','all','ReferenceBlock','cstblocks_lti/LTI System');end
    att=att(cellfun(@(blocco)strcmp(get_param(blocco,'sys'),'Gact'),att));
    scelte="originale";
    if startsWith(nome,'mu_'),scelte=["originale","MuN1","Mu_A","Mu_B"];end
    for scelta=scelte
        if scelta=="originale",data.Kmu=b.controllers(6).K;
        elseif scelta=="MuN1",data.Kmu=b.muRumore;
        elseif scelta=="Mu_A",data.Kmu=candidati{1}.K;
        else,data.Kmu=candidati{2}.K;
        end
    for campione=[0 1]
        if campione==0,Ga=modello.attuatori;else,Ga=inc.campioniAtt(:,:,campione);end
        [Aa,Ba,Ca,Da]=ssdata(Ga);
        data.Aplant=[modello.Am modello.Btau*Ca;zeros(6,8) Aa];
        Bu=[modello.Btau*Da;Ba]; Bd=[modello.Bd;zeros(6,2)];
        data.Bplant=[Bu Bd Bd Bu]; data.Cplant=[modello.Cm zeros(4,6)]; data.Dplant=zeros(4,8);
        % Ogni maschera SISO riceve solo i propri tre stati, come l'originale.
        if campione==0,parametri=[p.wn p.zeta p.wn p.zeta];
        else,parametri=inc.parametri(campione,:);end
        data.Gact1=tf(parametri(1)^2,[1 2*parametri(1)*parametri(2) parametri(1)^2])*modello.Dp;
        data.Gact2=tf(parametri(3)^2,[1 2*parametri(3)*parametri(4) parametri(3)^2])*modello.Dp;
        data.Gact=data.Gact1;
        ws=get_param(nome,'ModelWorkspace');
        for campo=string(fieldnames(data))'
            if campo~="slBus1",assignin(ws,char(campo),data.(campo));end
        end
        for j=1:numel(att)
            etichetta=get_param(att{j},'Name');
            if contains(etichetta,'1'),sistema='Gact1';else,sistema='Gact2';end
            set_param(att{j},'sys',sistema);
        end
        in=Simulink.SimulationInput(nome);
        in=in.setModelParameter('InitFcn','','StopTime','2','SaveState','on', ...
            'StateSaveName','xout','SaveFormat','Dataset','ReturnWorkspaceOutputs','on');
        for campo=string(fieldnames(data))'
            if campo=="slBus1"
                in=in.setVariable(char(campo),data.(campo));
            end
        end
        for j=1:numel(att)
            etichetta=get_param(att{j},'Name');
            if contains(etichetta,'1'),sistema='Gact1';else,sistema='Gact2';end
            in=in.setBlockParameter(att{j},'sys',sistema);
        end
        % Il logger dello Scope e un override della prova, non una modifica SLX.
        for j=1:numel(scope)
            in=in.setBlockParameter(scope{j},'DataLogging','on');
            in=in.setBlockParameter(scope{j},'DataLoggingVariableName',char("scope"+j));
        end
        fprintf('Simulink %s, %s, campione %d...\n',nome,scelta,campione);
        in=in.setModelParameter('SimulationMode','normal');
        out=sim(in);
        segnali=who(out);
        fine=out.tout(end); assert(abs(fine-2)<1e-8);
        stato=out.xout; finiti=true;
        for j=1:stato.numElements
            valori=stato.get(j).Values;
            if isa(valori,'timeseries'),finiti=finiti && all(isfinite(valori.Data),'all');end
        end
        assert(finiti,'SEA:Simulink','Stati non finiti.');
        acquisizione=struct; massimo=0;
        for j=1:numel(scope)
            campo=char("scope"+j); segnale=out.(campo);
            massimo=max(massimo,picco(segnale));
            acquisizione.(campo)=compatta(segnale);
        end
        assert(isfinite(massimo) && ~isempty(scope),'SEA:Scope','Scope non acquisiti o non finiti.');
        riga=riga+1; risultati{riga}=struct('modello',nome,'campione',campione, ...
            'stato',"PASS",'tempoFinale',fine,'controllore',scelta,'massimoScope',massimo, ...
            'segnali',{segnali},'overrideInit',true,'attuatori',numel(att));
        tracce{riga}=struct('scope',acquisizione,'parametri',parametri,'dati',data);
    end
    end
    clear cleanup
end
risultati=struct2table([risultati{1:riga}]);
writetable(risultati(:,1:6),fullfile(p.risultati,'simulink.csv'));
tracce=tracce(1:riga);
save(fullfile(p.risultati,'simulink.mat'),'risultati','tracce','-v7');
end
function valore=picco(segnale)
if isa(segnale,'Simulink.SimulationData.Dataset')
    valore=0;for j=1:segnale.numElements,valore=max(valore,picco(segnale.get(j).Values));end
elseif isa(segnale,'timeseries')
    assert(all(isfinite(segnale.Data),'all'),'SEA:Scope','Segnale non finito.');
    valore=max(abs(segnale.Data),[],'all');
elseif isstruct(segnale) && isfield(segnale,'signals')
    valore=0;
    for j=1:numel(segnale.signals)
        assert(all(isfinite(segnale.signals(j).values),'all'),'SEA:Scope','Segnale non finito.');
        valore=max(valore,max(abs(segnale.signals(j).values),[],'all'));
    end
else
    error('SEA:Scope','Formato Scope inatteso: %s.',class(segnale));
end
end
function risultato=compatta(segnale)
% Estratto per grafici; picco e controllo di finitezza usano tutti i campioni.
if isa(segnale,'Simulink.SimulationData.Dataset')
    risultato=cell(segnale.numElements,1);
    for j=1:segnale.numElements
        elemento=segnale.get(j); risultato{j}=struct('nome',elemento.Name,'valori',compatta(elemento.Values));
    end
elseif isa(segnale,'timeseries')
    n=numel(segnale.Time); indici=unique(round(linspace(1,n,min(n,2000))));
    risultato=struct('tempo',segnale.Time(indici),'dati',getdatasamples(segnale,indici), ...
        'campioniOriginali',n,'piccoOriginale',picco(segnale),'estratto',n>2000);
else
    n=numel(segnale.time); indici=unique(round(linspace(1,n,min(n,2000))));
    risultato=segnale; risultato.time=segnale.time(indici);
    for j=1:numel(segnale.signals)
        risultato.signals(j).values=segnale.signals(j).values(indici,:);
    end
    risultato.campioniOriginali=n; risultato.piccoOriginale=picco(segnale); risultato.estratto=n>2000;
end
end
