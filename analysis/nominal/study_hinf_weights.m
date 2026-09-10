function studio = study_hinf_weights(eseguiSintesi)
%STUDY_HINF_WEIGHTS Campagna deterministica separata dalla baseline M9-M16.
%   Il default ricarica la campagna. true esegue 13 candidati programmati,
%   una verifica equivalente hinfsyn e un diagnostico sul solo comando.
arguments
    eseguiSintesi (1,1) logical = false
end
radice=fileparts(fileparts(fileparts(mfilename('fullpath'))));
dati=fullfile(radice,'results','data');
archivio=fullfile(dati,'hinf_weight_revision.mat');
if ~eseguiSintesi
    assert(isfile(archivio),'HinfStudy:MissingCache', ...
        'Eseguire study_hinf_weights(true) una sola volta per creare la campagna.');
    caricato=load(archivio,'studio'); studio=caricato.studio; return
end
assert(~isfile(archivio),'HinfStudy:ExistingCache', ...
    'La campagna esiste: ricaricarla senza ripetere le sintesi.');
m3=load(fullfile(dati,'m3_nominal_actuated_plant.mat'));
m4=load(fullfile(dati,'m4_uncertain_plant.mat'));
m5=load(fullfile(dati,'m5_performance_specs.mat'));
m10=load(fullfile(dati,'m10_hinfsyn_nominal.mat'));
A=m3.Afull; B=m3.Bfull; Cq=m3.CfullQ; spec=m5.spec;
G=ss(A,B,Cq,zeros(2)); qs=spec.referenceAmplitude; us=spec.uScale;
% rN=r/qs, qN=q/qs, uN=u/us: plant e controllore normalizzati.
Gn=(1/qs)*G*us;
omega=logspace(-3,3,1201); tempo=(0:0.002:12)';
s=tf('s'); formaU=(s/spec.omegaU+1)/(s/(spec.controlWeightAlpha*spec.omegaU)+1);
% Non si cambiano As=0.05, Ms=2, il gradino 5 deg o i target temporali M5.
% omegaB: meno aggressivo, originale, piu aggressivo (wn/5, 0.3wn, 0.4wn).
% beta: uScale=12 o una penalita doppia (scala equivalente 6 N m).
% W3: roll-off presso wn oppure 2wn, DC=0.1 e HF=5, scelta progettuale.
% WI e incertezza INPUT: WI*T_output NON sarebbe un certificato M4.
bande=[8 12 16]; penalita=[1 2]; rolloff=[40 80];
parametri=zeros(13,3);
parametri(1,:)=[12 1 0]; % diagnostico: nuova scala W2, W3 assente
indiceParametro=1;
for wb=bande
    for beta=penalita
        for wt=rolloff
            indiceParametro=indiceParametro+1;
            parametri(indiceParametro,:)=[wb beta wt];
        end
    end
end
numero=size(parametri,1);
assert(numero==13);
controllori=cell(numero+1,1); mappe=cell(numero+1,1); pesi=cell(numero+1,1);
righe=nan(numero+1,16); errori=strings(numero+1,1);

% Baseline originale: ricaricata, non sovrascritta o cancellata.
controllori{1}=m10.Khinf;
pesi{1}=struct('W1',m5.W1,'W2',m5.W2,'W3',ss(zeros(2)), ...
    'W1n',m5.W1,'W2n',formaU/qs*eye(2),'W3n',[],'parametri',[12 1/qs 0]);
mappe{1}=localValuta(G,m5.BdFull,m10.Khinf,pesi{1},spec,tempo);
righe(1,:)=[0 12 1/qs 0 m10.gammaHinf mappe{1}.metriche];

for k=1:numero
    wb=parametri(k,1); beta=parametri(k,2); wt=parametri(k,3);
    W1n=((s/spec.Ms+wb)/(s+wb*spec.As))*eye(2);
    W2n=beta*formaU*eye(2);
    if wt==0, W3n=[];
    else, W3n=((s/wt+0.1)/(s/(5*wt)+1))*eye(2); end
    if isempty(W3n), W3fisico=ss(zeros(2)); else, W3fisico=W3n; end
    pesi{k+1}=struct('W1',W1n,'W2',(qs/us)*W2n,'W3',W3fisico, ...
        'W1n',W1n,'W2n',W2n,'W3n',W3n,'parametri',parametri(k,:));
    fprintf('Sintesi deterministica %d/%d: omegaB=%g beta=%g omegaT=%g\n', ...
        k,numero,wb,beta,wt);
    try
        [Kn,CLn,gamma]=mixsyn(Gn,W1n,W2n,W3n);
        assert(~isempty(Kn) && isfinite(gamma),'HinfStudy:SynthesisFailed', ...
            'Sintesi senza controllore o gamma finito.');
        K=us*Kn*(1/qs);
        valutazione=localValuta(G,m5.BdFull,K,pesi{k+1},spec,tempo);
        valutazione.CLnorm=CLn;
        valutazione.Knorm=Kn;
        valutazione.erroreGamma=abs(valutazione.metriche(2)/gamma-1);
        assert(valutazione.erroreGamma<1e-4,'HinfStudy:GammaMismatch', ...
            'La norma fisica ricostruita non coincide con la sintesi normalizzata.');
        controllori{k+1}=K; mappe{k+1}=valutazione;
        righe(k+1,:)=[k wb beta wt gamma valutazione.metriche];
    catch errore
        errori(k+1)=string(errore.identifier)+": "+string(errore.message);
        righe(k+1,:)=[k wb beta wt inf 0 inf inf inf inf inf inf inf inf inf inf];
        fprintf('FAIL conservato: %s\n',errori(k+1));
    end
end
tabella=array2table(righe,'VariableNames',{'Id','OmegaB','BetaU','OmegaT', ...
    'Gamma','Stable','WeightedNorm','W1SNorm','W2KSNorm','W3TNorm', ...
    'SettlingTime','OvershootPercent','SteadyErrorRelative','CrossCoupling', ...
    'PeakControlNm','RmsControlNm'});
tabella.Error=errori;
tabella.Ordine=zeros(height(tabella),1);
for k=1:height(tabella)
    if ~isempty(controllori{k}), tabella.Ordine(k)=order(controllori{k}); end
end
tabella.M5Pass=tabella.Stable==1 & tabella.SettlingTime<=spec.settlingTimeTarget ...
    & tabella.OvershootPercent<=spec.overshootTarget ...
    & tabella.SteadyErrorRelative<=spec.steadyStateTrackingTarget;

% Selezione: soltanto nuovi candidati a tre pesi, stabili e verificati.
ammissibili=find(tabella.Id>0 & tabella.OmegaT>0 & tabella.Stable==1);
assert(~isempty(ammissibili),'HinfStudy:NoStableCandidate', ...
    'Nessun nuovo candidato stabile: nessuna selezione possibile.');
rapporti=[tabella.SettlingTime/spec.settlingTimeTarget, ...
    tabella.OvershootPercent/spec.overshootTarget, ...
    tabella.SteadyErrorRelative/spec.steadyStateTrackingTarget];
violazioni=sum(rapporti>1,2);
% Ordinamento lessicografico dichiarato, non uno score con pesi nascosti.
criteri=[tabella.Gamma>=1,violazioni,max(rapporti,[],2), ...
    tabella.PeakControlNm/spec.uScale,tabella.CrossCoupling,tabella.Gamma];
[~,ordine]=sortrows(criteri(ammissibili,:),1:6);
selezionato=ammissibili(ordine(1));
Knuovo=controllori{selezionato}; w=pesi{selezionato};

% Pianta generalizzata esplicita: una sola istanza del modello nominale.
Gnome=Gn; Gnome.InputName={'uN(1)','uN(2)'}; Gnome.OutputName={'qN(1)','qN(2)'};
W1nome=ss(w.W1n); W1nome.InputName={'eN(1)','eN(2)'}; W1nome.OutputName={'z1(1)','z1(2)'};
W2nome=ss(w.W2n); W2nome.InputName={'uN(1)','uN(2)'}; W2nome.OutputName={'z2(1)','z2(2)'};
W3nome=ss(w.W3n); W3nome.InputName={'qN(1)','qN(2)'}; W3nome.OutputName={'z3(1)','z3(2)'};
P=connect(Gnome,W1nome,W2nome,W3nome,sumblk('eN = rN - qN',2), ...
    {'rN(1)','rN(2)','uN(1)','uN(2)'}, ...
    {'z1(1)','z1(2)','z2(1)','z2(2)','z3(1)','z3(2)','eN(1)','eN(2)'});
Pformula=[w.W1n -w.W1n*Gn;ss(zeros(2)) w.W2n; ...
    ss(zeros(2)) w.W3n*Gn;ss(eye(2)) -Gn];
erroreP=max(abs(freqresp(P,omega)-freqresp(Pformula,omega)),[],'all');
erroreAugw=max(abs(freqresp(P,omega)-freqresp(augw(Gn,w.W1n,w.W2n,w.W3n),omega)),[],'all');
erroreLFT=norm(lft(P,mappe{selezionato}.Knorm)-mappe{selezionato}.pesato,inf);
assert(erroreP<1e-8 && erroreAugw<1e-8 && erroreLFT<1e-7);
% Unica risintesi finale equivalente M10: non apre una seconda ricerca.
[Kh,CLh,gammaH]=hinfsyn(P,2,2);
verificaH=localValuta(G,m5.BdFull,us*Kh/qs,w,spec,tempo);
assert(abs(gammaH/tabella.Gamma(selezionato)-1)<1e-3);
assert(verificaH.metriche(1)==1);

% Diagnosi necessaria (non sufficiente): rilassamento puntuale del problema.
singolari=sigma(G,omega); a=squeeze(abs(freqresp(m5.W1(1,1),omega)))';
b=squeeze(abs(freqresp(m5.W2(1,1),omega)))';
limitePuntuale=a.*b./sqrt(b.^2+(a.*singolari(end,:)).^2);
[limiteMassimo,iLimite]=max(limitePuntuale);
diagnosi=struct('omega',omega,'sigmaMinG',singolari(end,:), ...
    'limitePuntuale',limitePuntuale,'limiteMassimo',limiteMassimo, ...
    'frequenzaLimite',omega(iLimite),'poliPianta',eig(A),'zeriPianta',tzero(G), ...
    'WIdc',dcgain(m4.WI),'WIhf',abs(evalfr(m4.WI,1i*1e8)), ...
    'baselinePeakFrequencies',m10.normMetrics, ...
    'scalingEquivalentNorm',norm([m5.W1*mappe{1}.S; ...
    (formaU/qs*eye(2))*(qs/us)*mappe{1}.KS],inf));

% Togliere W1 e W3 isola il costo minimo numerico della stabilizzazione.
% Non e un candidato di tracking: manca volutamente il requisito d'errore.
[Kc,CLc,gc]=mixsyn(Gn,[],formaU*eye(2),[]);
controlOnly=struct('Knorm',Kc,'CLnorm',CLc,'gamma',gc, ...
    'W2norm',formaU*eye(2),'interpretation', ...
    'diagnostic optimum for stability and normalized control effort only; not a robust certificate');

% Cinque campioni comuni per tutti: controllo empirico, non certificazione.
statoRng=rng; ripristinaRng=onCleanup(@() rng(statoRng));
rng(20260910,'twister'); campioni=usample(m4.GuncQ,5);
stabilitaCampioni=false(height(tabella),5);
sampleMaxRealPoles=nan(height(tabella),5);
for k=1:height(tabella)
    if ~isempty(controllori{k})
        for j=1:5
            [Ap,Bp,Cp,Dp]=ssdata(campioni(:,:,j));
            [Ak,Bk,Ck,Dk]=ssdata(controllori{k});
            assert(norm(Dp,'fro')==0);
            Ac=[Ap-Bp*Dk*Cp Bp*Ck;-Bk*Cp Ak];
            sampleMaxRealPoles(k,j)=max(real(eig(Ac)));
            stabilitaCampioni(k,j)=sampleMaxRealPoles(k,j)<-1e-8;
        end
    end
end
tabella.StableSamples=sum(stabilitaCampioni,2);
studio=struct('tabella',tabella,'parametri',parametri,'controllori',{controllori}, ...
    'mappe',{mappe},'pesi',{pesi},'selezionato',selezionato,'Knuovo',Knuovo, ...
    'P',P,'Pformula',Pformula,'erroreP',erroreP,'erroreAugw',erroreAugw, ...
    'erroreLFT',erroreLFT,'Kh',Kh,'CLh',CLh,'gammaH',gammaH,'verificaH',verificaH, ...
    'diagnosi',diagnosi,'tempo',tempo,'qs',qs,'us',us,'spec',spec, ...
    'stabilitaCampioni',stabilitaCampioni,'sampleSeed',20260910, ...
    'samplePlants',campioni,'sampleMaxRealPoles',sampleMaxRealPoles, ...
    'criteriSelezione',criteri,'baselinePreserved',true, ...
    'controlOnly',controlOnly,'synthesisCount',numero+2);
save(archivio,'studio','-v7');
writetable(tabella,fullfile(dati,'hinf_weight_revision.csv'));
disp(tabella); fprintf('Selezionato per lo studio: id=%d. Sintesi totali=%d.\n', ...
    tabella.Id(selezionato),studio.synthesisCount);
end

function risultato=localValuta(G,Bd,K,w,spec,tempo)
% Matrice completa: nessuna cancellazione per verificare stabilita interna.
[A,B,Cq,~]=ssdata(G); [Ak,Bk,Ck,Dk]=ssdata(K); nk=size(Ak,1);
Acl=[A-B*Dk*Cq B*Ck;-Bk*Cq Ak];
Br=[B*Dk;Bk]; Bdist=[Bd;zeros(nk,2)];
Cuscite=[Cq zeros(2,nk);-Dk*Cq Ck];
riferimento=ss(Acl,Br,Cuscite,[zeros(2);Dk]);
disturbo=ss(Acl,Bdist,Cuscite,zeros(4,2));
stabile=all(real(eig(Acl))<-1e-8);
assert(stabile,'HinfStudy:InternalInstability','Chiusura completa instabile.');
T=riferimento(1:2,:); KS=riferimento(3:4,:); S=ss(eye(2))-T;
pesato=[w.W1*S;w.W2*KS;w.W3*T];
norme=[norm(pesato,inf) norm(w.W1*S,inf) norm(w.W2*KS,inf) norm(w.W3*T,inf)];
dc=dcgain(T); risposte=cell(2,1); metricheTempo=zeros(2,6);
for j=1:2
    ingresso=zeros(numel(tempo),2); ingresso(:,j)=spec.referenceAmplitude;
    y=lsim(riferimento,ingresso,tempo); risposte{j}=y;
    finale=dc(j,j)*spec.referenceAmplitude;
    fuori=abs(y(:,j)-finale)>0.02*spec.referenceAmplitude;
    ultimo=find(fuori,1,'last');
    if isempty(ultimo)
        ts=0;
    elseif ultimo==numel(tempo)
        ts=inf;
    else
        ts=tempo(ultimo+1);
    end
    os=100*max(0,max(y(:,j))/spec.referenceAmplitude-1);
    ess=abs(finale/spec.referenceAmplitude-1);
    cross=max(abs(y(:,3-j)))/max(max(abs(y(:,j))),eps);
    metricheTempo(j,:)=[ts os ess cross max(abs(y(:,3:4)),[],'all') ...
        sqrt(mean(y(:,3:4).^2,'all'))];
end
risultato=struct('S',S,'T',T,'KS',KS,'pesato',pesato,'Acl',Acl, ...
    'riferimento',riferimento,'disturbo',disturbo,'risposte',{risposte}, ...
    'metricheTempo',metricheTempo,'metriche',[stabile norme max(metricheTempo,[],1)], ...
    'maxRealPole',max(real(eig(Acl))));
end
