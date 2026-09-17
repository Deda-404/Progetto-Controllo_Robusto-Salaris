function study = run_hinf_revision
%RUN_HINF_REVISION Revisione isolata M9-M11; non esegue run_all o M12-M18.
root=fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(root,'controllers')),genpath(fullfile(root,'src')));
folder=fullfile(root,'results','data','hinf_targeted_revision');
if ~isfolder(folder), mkdir(folder); end
c=hinf_revision_config;
m3=load(fullfile(root,'results','data','m3_nominal_actuated_plant.mat'));
m5=load(fullfile(root,'results','data','m5_performance_specs.mat'));
m10=load(fullfile(root,'results','data','m10_hinfsyn_nominal.mat'));
G=ss(m3.Afull,m3.Bfull,m3.CfullQ,zeros(2));
study=struct('config',c,'baseline',struct,'cases',{{}},'selected',[]);
study.baseline.parameters=[m5.spec.omegaW1,m5.spec.As,m5.spec.Ms, ...
    m5.spec.controlWeightGain,m5.spec.omegaU];
study.baseline.bound=hinf_revision_lower_bound(G,m5.W1,m5.W2,c.omega);
study.baseline.gamma=m10.gammaHinf;
study.baseline.evaluation=hinf_revision_evaluate(G,m5.BdFull,m10.Khinf,m5.W1,m5.W2,m5.spec,c);
study.plantPoles=eig(m3.Afull); study.actuator=m3.actuatorParams;
for stage=1:2
    if stage==1, profiles=c.initialW1; efforts=c.initialW2;
    else, profiles=c.extendedW1; efforts=c.extendedW2;
    end
    for i=1:size(profiles,1)
        for j=1:size(efforts,1)
            p=[profiles(i,:) efforts(j,:)]; id=numel(study.cases)+1;
            path=fullfile(folder,sprintf('full_%02d.mat',id));
            if isfile(path)
                loaded=load(path,'result'); result=loaded.result;
                assert(isequal(result.parameters,p) && isequal(result.config,c), ...
                    'HinfRevision:CacheMismatch','Cache non coerente.');
            else
                [W1,W2]=hinf_revision_weights(p,c);
                result=struct('id',id,'stage',stage,'parameters',p,'config',c, ...
                    'bound',hinf_revision_lower_bound(G,W1,W2,c.omega), ...
                    'gammaMix',nan,'gammaHinf',nan,'status',"LOWER_BOUND_REJECTED", ...
                    'error',"",'W1',W1,'W2',W2);
                if ~result.bound.reject
                    try
                        [result.Kmix,result.CLmix,result.gammaMix]=mixsyn(G,W1,W2,[]);
                        result.P=hinf_revision_plant(G,W1,W2);
                        [result.Khinf,result.CLhinf,result.gammaHinf]=hinfsyn(result.P,2,2);
                        result.mix=hinf_revision_evaluate(G,m5.BdFull,result.Kmix,W1,W2,m5.spec,c);
                        result.hinf=hinf_revision_evaluate(G,m5.BdFull,result.Khinf,W1,W2,m5.spec,c);
                        result.gammaRelativeError=abs(result.gammaMix-result.gammaHinf)/result.gammaMix;
                        % Identita di mappe per lo STESSO K, non fra due ottimi non unici.
                        result.mapError=max(abs(freqresp(lft(result.P,result.Kmix),c.omega) ...
                            -freqresp(result.mix.weighted,c.omega)),[],'all');
                        result.plantError=max(abs(freqresp(result.P,c.omega) ...
                            -freqresp(augw(G,W1,W2,[]),c.omega)),[],'all');
                        result.normRelativeError=max(abs([result.mix.norms(1)/result.gammaMix, ...
                            result.hinf.norms(1)/result.gammaHinf]-1));
                        assert(result.gammaRelativeError<c.gammaTolerance && ...
                            result.mapError<c.mapTolerance && result.plantError<c.mapTolerance && ...
                            result.normRelativeError<c.gammaTolerance, ...
                            'HinfRevision:Equivalence','Verifica indipendente fallita.');
                        result.status="SYNTHESIZED";
                    catch err
                        result.status="ERROR"; result.error=string(getReport(err,'extended','hyperlinks','off'));
                    end
                end
                save(path,'result','-v7');
            end
            study.cases{id}=result;
            fprintf('Caso %02d stage %d: LB %.6g, gamma %.8g / %.8g, %s\n', ...
                id,stage,result.bound.value,result.gammaMix,result.gammaHinf,result.status);
            if result.status=="ERROR", fprintf('%s\n',result.error); end
        end
    end
    feasible=find(cellfun(@(r) r.status=="SYNTHESIZED" && ...
        r.gammaMix<1 && r.gammaHinf<1 && r.mix.nominalPerformance && ...
        r.hinf.nominalPerformance,study.cases));
    if ~isempty(feasible), break; end
end
if ~isempty(feasible)
    % Ordine fissato: target rivisti, target M5, picco comando, gamma, ID.
    criteria=zeros(numel(feasible),5);
    for i=1:numel(feasible)
        r=study.cases{feasible(i)};
        criteria(i,:)=[~r.hinf.revisedTemporal,~r.hinf.m5Temporal, ...
            max(r.hinf.metrics(:,5)),r.gammaHinf,r.id];
    end
    [~,ix]=sortrows(criteria,1:5); study.selected=feasible(ix(1));
    study.status="FULL_ORDER_PASS";
else
    study.status="FULL_ORDER_FAIL_FIXED_ORDER_NOT_RUN";
end
save(fullfile(folder,'study.mat'),'study','-v7');
disp(study.status); disp(study.selected);
end
