function studio = study_hinf_weights(eseguiSintesi)
%STUDY_HINF_WEIGHTS Ricerca limitata di pesi nelle coordinate fisiche M3.
%   Stage A: otto W1, con W2 e W3 fissi. Stage B: al massimo quattro
%   sintesi, solo senza PASS e con W2*KS dominante. Nessuna scala di pianta.
%   W3 resta quello dello studio precedente; M9/M10 mantengono due pesi.
arguments
    eseguiSintesi (1,1) logical = false
end
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
data=fullfile(root,'results','data');
archive=fullfile(data,'hinf_weight_revision.mat');
if isfile(archive)
    cached=load(archive,'studio');
    current=isfield(cached.studio,'coordinateSystem') && ...
        cached.studio.coordinateSystem=="physical";
    if current
        studio=cached.studio;
        assert(~eseguiSintesi,'DirectHinf:ExistingCampaign', ...
            'Campagna gia completata: usare la cache, senza nuove sintesi.');
        return
    end
end
assert(eseguiSintesi,'DirectHinf:MissingCampaign', ...
    'Eseguire una sola volta study_hinf_weights(true).');
baseline=load(fullfile(data,'direct_weights_baseline.mat'));
m3=load(fullfile(data,'m3_nominal_actuated_plant.mat'));
m5=load(fullfile(data,'m5_performance_specs.mat'));
G=ss(m3.Afull,m3.Bfull,m3.CfullQ,zeros(2));
spec=m5.spec; omega=logspace(-3,3,1201); tempo=(0:0.002:12)';
% Preallocazione: baseline ricaricata + non oltre 14 sintesi di studio.
% Le due sintesi di produzione M9/M10 restano entro il limite totale 16.
rows=nan(15,19); controllers=cell(15,1); maps=cell(15,1);
weights=cell(15,1); stages=strings(15,1); errors=strings(15,1);
count=1; synthesisCount=0; stageBExecuted=false; w3Alternatives=0;
b=baseline.baselineM5.spec;
initialParameters=[b.omegaB,b.As,b.Ms,1/b.uScale,b.omegaU,0];
controllers{1}=baseline.baselineM10.Khinf;
weights{1}=struct('W1',baseline.baselineM5.W1, ...
    'W2',baseline.baselineM5.W2,'W3',ss(zeros(2)), ...
    'parametri',initialParameters);
maps{1}=localValuta(G,m5.BdFull,controllers{1},weights{1},spec,tempo);
rows(1,:)=[0,initialParameters,baseline.baselineM10.gammaHinf,maps{1}.metriche];
stages(1)="BASELINE_2_WEIGHTS";
fixedOmegaT=baseline.w3Parameters(1);
assert(isequal(baseline.w3Parameters,[40,0.1,5]), ...
    'DirectHinf:W3Baseline','Il W3 congelato dello studio deve essere auditato.');

%% Stage A: si modifica soltanto W1, interrompendo a due PASS reali.
% L'ordine e deterministico; nessuna selezione di seed o ricerca casuale.
[ow,aa,mm]=ndgrid([6,8],[0.10,0.15],[2.5,3.0]);
for index=1:numel(ow)
    evaluateOne([ow(index),aa(index),mm(index), ...
        initialParameters(4:5),fixedOmegaT],"A");
    t=currentTable();
    if sum(t.Pass(t.Stage=="A"))>=2, break; end
end
t=currentTable(); order=rankCandidates(t);
bestA=order(t.Stage(order)=="A"); bestA=bestA(1:min(2,numel(bestA)));
dominantW2=any(t.W2KSNorm(bestA)>=t.W1SNorm(bestA) & ...
    t.W2KSNorm(bestA)>=t.W3TNorm(bestA));
stageBReason="NOT RUN: almeno un PASS oppure W2*KS non dominante.";
if ~any(t.Pass(t.Stage=="A")) && dominantW2
    stageBExecuted=true;
    stageBReason="Nessun PASS Stage A; W2*KS domina in almeno uno dei due migliori W1.";
    stop=false;
    for index=bestA(:)'
        for ku=[0.07,0.05]
            % 60 rad/s e il valore esplicito autorizzato per Stage B;
            % la baseline attiva e Stage A usano invece 30 rad/s.
            evaluateOne([t.OmegaW1(index),t.As(index),t.Ms(index),ku,60,fixedOmegaT],"B");
            current=currentTable();
            if current.Pass(end), stop=true; break; end
        end
        if stop, break; end
    end
end
%% W3: solo se e quantitativamente il collo di bottiglia del compromesso.
% 80 rad/s = 2*wn; 40 rad/s = wn. La seconda alternativa riduce il solo
% guadagno HF da 5 a 3, mantenendo DC=0.1. Nessun campionamento denso.
t=currentTable(); order=rankCandidates(t); best=order(1);
dominantW3=t.W3TNorm(best)>max(t.W1SNorm(best),t.W2KSNorm(best));
if ~any(t.Pass(2:end)) && dominantW3
    for wt=[80,40]
        if synthesisCount>=14, break; end
        parameters=t{best,{'OmegaW1','As','Ms','Ku','OmegaU','OmegaT'}};
        parameters(6)=wt;
        w3Alternatives=w3Alternatives+1;
        evaluateOne(parameters,"W3");
        current=currentTable();
        if current.Pass(end), break; end
    end
end
t=currentTable(); order=rankCandidates(t); selected=order(1);
w=weights{selected}; K=controllers{selected};
assert(~isempty(K),'DirectHinf:NoStableCandidate','Nessun compromesso stabile disponibile.');

%% Lower LFT fisica: confronti indipendenti, senza seconda sintesi di studio.
Gn=G; Gn.InputName={'u(1)','u(2)'}; Gn.OutputName={'q(1)','q(2)'};
W1n=ss(w.W1); W1n.InputName={'e(1)','e(2)'}; W1n.OutputName={'z1(1)','z1(2)'};
W2n=ss(w.W2); W2n.InputName={'u(1)','u(2)'}; W2n.OutputName={'z2(1)','z2(2)'};
W3n=ss(w.W3); W3n.InputName={'q(1)','q(2)'}; W3n.OutputName={'z3(1)','z3(2)'};
P=connect(Gn,W1n,W2n,W3n,sumblk('e = r - q',2), ...
    {'r(1)','r(2)','u(1)','u(2)'}, ...
    {'z1(1)','z1(2)','z2(1)','z2(2)','z3(1)','z3(2)','e(1)','e(2)'});
Pformula=[w.W1,-w.W1*G;ss(zeros(2)),w.W2; ...
    ss(zeros(2)),w.W3*G;ss(eye(2)),-G];
errorP=max(abs(freqresp(P,omega)-freqresp(Pformula,omega)),[],'all');
errorAugw=max(abs(freqresp(P,omega)-freqresp(augw(G,w.W1,w.W2,w.W3),omega)),[],'all');
errorLFT=norm(lft(P,K)-maps{selected}.pesato,inf);
assert(errorP<1e-8 && errorAugw<1e-8 && errorLFT<1e-7, ...
    'DirectHinf:Reconstruction','Interconnessione fisica o norma non coerenti.');

% Diagnostica dei pesi iniziali: limite puntuale necessario, non sufficiente.
sv=sigma(G,omega); a=squeeze(abs(freqresp(weights{1}.W1(1,1),omega)))';
bb=squeeze(abs(freqresp(weights{1}.W2(1,1),omega)))';
bound=a.*bb./sqrt(bb.^2+(a.*sv(end,:)).^2);
[boundMax,iBound]=max(bound);
selectedSpec=spec; selectedSpec.omegaW1=t.OmegaW1(selected);
selectedSpec.As=t.As(selected); selectedSpec.Ms=t.Ms(selected);
selectedSpec.controlWeightGain=t.Ku(selected); selectedSpec.omegaU=t.OmegaU(selected);
studio=struct('coordinateSystem',"physical",'baselineCommit',baseline.baselineCommit, ...
    'tabella',t,'controllori',{controllers(1:count)},'mappe',{maps(1:count)}, ...
    'pesi',{weights(1:count)},'selezionato',selected,'Knuovo',K, ...
    'P',P,'Pformula',Pformula,'erroreP',errorP,'erroreAugw',errorAugw, ...
    'erroreLFT',errorLFT,'tempo',tempo,'omega',omega,'spec',spec, ...
    'selectedSpec',selectedSpec,'synthesisCount',synthesisCount, ...
    'stageBExecuted',stageBExecuted,'stageBReason',stageBReason, ...
    'w3Alternatives',w3Alternatives,'fixedW3Parameters',baseline.w3Parameters, ...
    'diagnosi',struct('omega',omega,'limitePuntuale',bound, ...
    'limiteMassimo',boundMax,'frequenzaLimite',omega(iBound)), ...
    'productionUsesW3',false,'selectionOrder',order);
save(archive,'studio','-v7');
writetable(t,fullfile(data,'hinf_weight_revision.csv'));
disp(t);
fprintf('Sintesi studio=%d; ID selezionato=%d; PASS=%d. %s\n', ...
    synthesisCount,t.Id(selected),sum(t.Pass(2:end)),stageBReason);

    function evaluateOne(parameters,stage)
        % Ogni esecuzione e contata anche se fallisce: budget non aggirabile.
        assert(synthesisCount<14,'DirectHinf:Budget','Limite di sintesi raggiunto.');
        synthesisCount=synthesisCount+1; count=count+1; stages(count)=stage;
        candidateSpec=spec; candidateSpec.omegaW1=parameters(1);
        candidateSpec.As=parameters(2); candidateSpec.Ms=parameters(3);
        candidateSpec.controlWeightGain=parameters(4); candidateSpec.omegaU=parameters(5);
        [~,W1,~,W2]=build_m5_weights(candidateSpec);
        s=tf('s'); hf=5;
        if stage=="W3" && w3Alternatives==2, hf=3; end
        W3=((s/parameters(6)+0.1)/(s/(hf*parameters(6))+1))*eye(2);
        weights{count}=struct('W1',W1,'W2',W2,'W3',W3,'parametri',parameters,'W3HighGain',hf);
        fprintf('HINF %d stage=%s: omegaW1=%g As=%g Ms=%g ku=%g omegaU=%g W3omega=%g\n', ...
            synthesisCount,stage,parameters);
        try
            % Checkpoint per sintesi: una ripresa non deve ripetere i solver.
            checkpointDir=fullfile(root,'results','tmp','direct_weights_revision');
            if ~isfolder(checkpointDir), mkdir(checkpointDir); end
            checkpointPath=fullfile(checkpointDir,sprintf('hinf_case_%02d.mat',synthesisCount));
            if isfile(checkpointPath)
                saved=load(checkpointPath);
                assert(isequal(saved.parameters,parameters), ...
                    'DirectHinf:CheckpointMismatch','Parametri del checkpoint diversi.');
                controller=saved.controller; closed=saved.closed; gamma=saved.gamma;
            else
                [controller,closed,gamma]=mixsyn(G,W1,W2,W3);
                save(checkpointPath,'controller','closed','gamma','parameters','-v7');
            end
            controllers{count}=controller;
            result=localValuta(G,m5.BdFull,controller,weights{count},spec,tempo);
            result.synthesisClosedLoop=closed;
            result.gammaRelativeError=abs(result.metriche(2)/gamma-1);
            assert(result.gammaRelativeError<1e-4,'DirectHinf:GammaMismatch', ...
                'La norma fisica ricostruita non coincide con gamma.');
            maps{count}=result;
            rows(count,:)=[count-1,parameters,gamma,result.metriche];
        catch err
            errors(count)=string(err.identifier)+": "+string(err.message);
            rows(count,:)=[count-1,parameters,inf,0,inf(1,10)];
            fprintf('FAIL conservato: %s\n',errors(count));
        end
    end
    function t=currentTable()
        t=array2table(rows(1:count,:),'VariableNames', ...
            {'Id','OmegaW1','As','Ms','Ku','OmegaU','OmegaT','Gamma', ...
            'Stable','WeightedNorm','W1SNorm','W2KSNorm','W3TNorm', ...
            'SettlingTime','OvershootPercent','SteadyErrorRelative', ...
            'CrossCoupling','PeakControlNm','RmsControlNm'});
        t.Stage=stages(1:count); t.Error=errors(1:count);
        t.Ordine=cellfun(@(x) size(x.A,1),controllers(1:count),'ErrorHandler',@(~,~) 0);
        % Target temporali e classificazione sono quelli gia utilizzati.
        t.M5Pass=t.Stable==1 & t.SettlingTime<=spec.settlingTimeTarget & ...
            t.OvershootPercent<=spec.overshootTarget & ...
            t.SteadyErrorRelative<=spec.steadyStateTrackingTarget;
        t.WeightedPass=t.Stable==1 & t.Gamma<1;
        t.Pass=t.M5Pass & t.WeightedPass;
    end
end

function order=rankCandidates(t)
% Ordinamento lessicografico preesistente: gamma, violazioni temporali,
% massimo rapporto ai target, comando e cross-coupling. Nessun target cambia.
spec=performance_specs_m5;
ratios=[t.SettlingTime/spec.settlingTimeTarget, ...
    t.OvershootPercent/spec.overshootTarget, ...
    t.SteadyErrorRelative/spec.steadyStateTrackingTarget];
eligible=find(t.Id>0 & t.Stable==1);
assert(~isempty(eligible),'DirectHinf:NoStableCandidate','Nessun candidato stabile.');
criteria=[t.Gamma>=1,sum(ratios>1,2),max(ratios,[],2), ...
    t.PeakControlNm/spec.uScale,t.CrossCoupling,t.Gamma];
[~,indices]=sortrows(criteria(eligible,:),1:6);
order=eligible(indices);
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
