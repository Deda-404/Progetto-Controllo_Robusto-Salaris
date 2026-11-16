function studio_mu_riferimento(ricalcolaIterazioni)
%STUDIO_MU_RIFERIMENTO Riesame e sintesi esplorative a configurazione fissata.
% Con false riusa il riesame salvato dopo averne controllato la provenienza.
arguments
    ricalcolaIterazioni (1,1) logical = true
end
p=parametri_sea;
[originali,Koriginali]=controllori_sea(p);
storico=load(fullfile(p.risultati,'sintesi_mu.mat'));
base=load(fullfile(p.risultati,'confronto_robusto_r.mat'));
a=load(fullfile(p.risultati,'incertezze.mat'),'modelli');
b=load(fullfile(p.dati,'banca_validata.mat'),'banca');
P={a.modelli.PA,a.modelli.PB};
assert(isequal(storico.firma,base.firma,p.firma,a.modelli.firma) && base.mappa=="Tzr_v1" && ...
    isequal(base.nomi,originali) && isequaln(base.K,Koriginali));
out=fullfile(p.risultati,'studio_mu_riferimento');
if ~isfolder(out),mkdir(out);end
stato=rng; ripristina=onCleanup(@()rng(stato));

%% 1 - Diagnosi del picco e delle perturbazioni critiche gia salvate
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
                scarto=val-block.NominalValue;
                if scarto>=0,ampiezza=block.Range(2)-block.NominalValue;
                else,ampiezza=block.NominalValue-block.Range(1);end
                blocchi(end+1,:)={famiglia,string(tag),"reale",block.NominalValue,val,scarto/ampiezza,NaN,solo,complementare,norm(Mcrit,2)};
            else
                blocchi(end+1,:)={famiglia,string(tag),"dinamico",NaN,NaN,norm(val,inf),abs(evalfr(val,1i*f)),solo,complementare,norm(Mcrit,2)};
            end
        end
        CL=usubs(CL,wcu);
        nome="Mu_B";
    end
    assert(isstable(CL));
    T=CL(5:8,1:2);
    [guadagno,omega]=norm(T,inf);
    if isinf(omega),M=T.D; else,M=evalfr(T,1i*omega);end
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

%% 2 - Candidati intermedi originali, valutati tutti sulle due famiglie
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

%% 3 - Stesse prove nominali per LQG e per i candidati con RP su A e B
nomiProva=originali(1); Kprova=Koriginali(1);
for k=indici
    esiti=iterazioni.RP_r(iterazioni.Controllore==nomi(k));
    if numel(esiti)==2 && all(esiti=="PASS")
        nome=nomi(k);
        if k==1,nome="MuN1";end
        nomiProva(end+1)=nome;
        Kprova{end+1}=K{k};
    end
end
prove=proveNominali(P{1}.NominalValue,p,nomiProva,Kprova);
writetable(prove,fullfile(out,'prove_nominali.csv'));
disp(prove);
end

function prove=proveNominali(P,p,nomi,K)
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
