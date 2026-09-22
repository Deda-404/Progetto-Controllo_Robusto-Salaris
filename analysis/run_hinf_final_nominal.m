function study = run_hinf_final_nominal
%RUN_HINF_FINAL_NOMINAL Audit bound -> nuova baseline -> 21 casi -> vero 2DoF.
root=fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(root,'controllers')),genpath(fullfile(root,'src')));
folder=fullfile(root,'results','data','hinf_final_coherent');
gate=load(fullfile(folder,'lower_bound_tests.mat'));
assert(all([gate.r.Passed]),'HinfFinal:BoundGate','Audit bound non completato.');
c=hinf_final_config;
options=hinfsynOptions('RelTol',c.solverRelTol);
m3=load(fullfile(root,'results','data','m3_nominal_actuated_plant.mat'));
m5=load(fullfile(root,'results','data','m5_performance_specs.mat'));
G=ss(m3.Afull,m3.Bfull,m3.CfullQ,zeros(2));
physical=ss(m3.Afull,[m3.Bfull,m5.BdFull],m3.CfullQ,zeros(2,4));
study=struct('config',c,'one',{{}},'two',{{}},'physical',physical,'spec',m5.spec);
for i=1:size(c.profiles,1)
    p=c.profiles(i,:); file=fullfile(folder,sprintf('nominal_1dof_%02d.mat',i));
    if isfile(file)
        a=load(file,'r'); r=a.r; assert(isequal(r.config,c),'Cache config diversa.');
    else
        [W1,W2]=hinf_revision_weights(p,c);
        r=struct('id',i,'parameters',p,'config',c,'architecture',"1DOF", ...
            'W1',W1,'W2',W2,'Mo',ss(eye(2)), ...
            'bound',hinf_revision_lower_bound(G,W1,W2,c.omega), ...
            'status',"BOUND_REJECTED",'error',"",'gammaMix',nan,'gamma',nan);
        if ~r.bound.reject
            try
                [Kmix,CLmix,r.gammaMix]=mixsyn(G,W1,W2,[],options);
                r.P=hinf_revision_plant(G,W1,W2);
                [r.Kfeedback,r.CL,r.gamma]=hinfsyn(r.P,2,2,options);
                r.K=r.Kfeedback*[eye(2),-eye(2)];
                r.e=hinf_final_evaluate(physical,r.K,W1,W2,r.Mo,m5.spec,c,r.architecture);
                r.mix=hinf_final_evaluate(physical,Kmix*[eye(2),-eye(2)],W1,W2,r.Mo,m5.spec,c,r.architecture);
                r.audit.gammaError=abs(r.gamma-r.gammaMix)/r.gamma;
                r.audit.plantError=max(abs(freqresp(r.P,c.omega)-freqresp(augw(G,W1,W2,[]),c.omega)),[],'all');
                r.audit.mapError=max(abs(freqresp(r.CL,c.omega)-freqresp(r.e.weighted,c.omega)),[],'all');
                r.audit.mixMapError=max(abs(freqresp(CLmix,c.omega)-freqresp(r.mix.weighted,c.omega)),[],'all');
                r.audit.normError=abs(r.gamma-r.e.norms(1))/r.gamma;
                assert(r.audit.gammaError<c.gammaTolerance && r.audit.normError<c.gammaTolerance && ...
                    max([r.audit.plantError,r.audit.mapError,r.audit.mixMapError])<c.mapTolerance, ...
                    'HinfFinal:Identity','Mappe o norme incoerenti.');
                r.status="VALIDATED";
            catch err
                r.status="ERROR"; r.error=string(getReport(err,'extended','hyperlinks','off'));
            end
        end
        save(file,'r','-v7');
    end
    study.one{i}=r;
    fprintf('1DOF %02d LB %.5g gamma %.8g %s',i,r.bound.value,r.gamma,r.status);
    if isfield(r,'e'), fprintf(' OS %.5g ess %.5g\n',max(r.e.metrics(:,2)),max(r.e.metrics(:,3))); else, fprintf('\n%s\n',r.error); end
end
valid=find(cellfun(@(r) r.status=="VALIDATED" && r.e.NP,study.one));
assert(~isempty(valid),'Nessun 1DOF nominalmente conforme.');
ranking=zeros(numel(valid),8);
for i=1:numel(valid)
    q=study.one{valid(i)}; v=max(q.e.metrics,[],1);
    ranking(i,:)=[v(2),v(3),v(1),v(4:6),q.gamma,q.id];
end
[~,ix]=sortrows(ranking,1:8); study.selectedOne=valid(ix(1));
best=study.one{study.selectedOne};
for i=1:numel(c.referenceFrequencies)
    file=fullfile(folder,sprintf('nominal_2dof_%02d.mat',i));
    if isfile(file)
        a=load(file,'r'); r=a.r; assert(isequal(r.config,c),'Cache config diversa.');
    else
        w=c.referenceFrequencies(i); s=tf('s');
        Mo=w^2/(s^2+2*c.referenceDamping*w*s+w^2)*eye(2);
        r=struct('id',i,'config',c,'architecture',"2DOF",'parameters',best.parameters, ...
            'omegaM',w,'Mo',Mo,'W1',best.W1,'W2',best.W2,'status',"ERROR",'error',"",'gamma',nan);
        try
            r.P=hinf_final_2dof_plant(physical,r.W1,r.W2,Mo);
            [r.K,r.CL,r.gamma,r.info]=hinfsyn(r.P,4,2,options);
            r.e=hinf_final_evaluate(physical,r.K,r.W1,r.W2,Mo,m5.spec,c,r.architecture);
            r.audit.mapError=max(abs(freqresp(r.CL,c.omega)-freqresp(r.e.weighted,c.omega)),[],'all');
            r.audit.normError=abs(r.gamma-r.e.norms(1))/r.gamma;
            assert(r.audit.mapError<c.mapTolerance && r.audit.normError<c.gammaTolerance, ...
                'HinfFinal:TwoDofIdentity','2DOF mappe o norma incoerenti.');
            r.status="VALIDATED";
        catch err
            r.error=string(getReport(err,'extended','hyperlinks','off'));
        end
        save(file,'r','-v7');
    end
    study.two{i}=r;
    fprintf('2DOF omegaM=%g gamma=%.8g %s\n',r.omegaM,r.gamma,r.status);
    if isfield(r,'e'), disp(r.e.metrics); end
    if r.status=="ERROR", fprintf('%s\n',r.error); end
end
% Selezione fra problemi diversi: norma propria <1, non graduatoria dei gamma.
candidates=[study.one,study.two]; ranking=inf(numel(candidates),10);
baselinePeak=max(study.one{1}.e.metrics(:,5));
for i=1:numel(candidates)
    q=candidates{i};
    if q.status=="VALIDATED" && q.e.NP
        v=max(q.e.metrics,[],1);
        if v(5)<=c.commandComparisonFactor*baselinePeak
            ranking(i,:)=[q.e.m5Failures,max(1,max(q.e.m5Ratios)),v(2),v(3),v(1),v(4:6),q.gamma,i];
        end
    end
end
[~,ix]=sortrows(ranking,1:10); study.selected=candidates{ix(1)};
study.selectionRanking=ranking; study.selectionIndex=ix(1);
save(fullfile(folder,'nominal_study.mat'),'study','-v7');
selected=study.selected; save(fullfile(folder,'selected_full_order.mat'),'selected','-v7');
fprintf('SELEZIONATO %s id %d gamma %.9g\n',selected.architecture,selected.id,selected.gamma);
end
