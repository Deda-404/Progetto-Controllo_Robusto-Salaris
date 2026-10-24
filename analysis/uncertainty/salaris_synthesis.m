function salaris_synthesis
%SALARIS_SYNTHESIS Pochi confronti: Hinf nominale comune e D-K A/B.
d=final_closure_load; q=d.selected;
folder=fullfile(d.root,'results/data/salaris_revision');
a=load(fullfile(folder,'models.mat')); models=a.models;
rows=cell(0,12);
% Fattori espliciti: stessa tolleranza DC, dinamica richiesta piu lenta.
for factor=[1 .3 .1]
    W1=slow(q.W1,factor); Mo=slow(q.Mo,factor);
    nominal=hinf_final_2dof_plant(models.plants{1}.NominalValue(1:2,:),W1,q.W2,Mo);
    file=fullfile(folder,sprintf('hinf_band_%g.mat',factor));
    if isfile(file)
        a=load(file,'candidate'); candidate=a.candidate;
    else
        [K,~,gamma]=hinfsyn(nominal,4,2,hinfsynOptions('Display','off'));
        candidate=struct('K',K,'gamma',gamma,'factor',factor,'method',"Hinf_common_nominal");
        save(file,'candidate','-v7');
    end
    controllers={candidate}; names="Hinf_common";
    for j=[1 3]
        file=fullfile(folder,sprintf('musyn_%s_band_%g.mat',models.names(j),factor));
        if isfile(file)
            a=load(file,'candidate'); candidate=a.candidate;
        else
            P=hinf_final_2dof_plant(models.plants{j}(1:2,:),W1,q.W2,Mo);
            rng(20261024,'twister');
            opts=musynOptions('Display','short','MaxIter',4,'FitOrder',[2 1],'FullDG',false, ...
                'MixedMU','on','FrequencyGrid',logspace(-2,4,121),'UseParallel',false);
            [K,perf,info]=musyn(P,4,2,opts);
            candidate=struct('K',K,'gamma',perf,'factor',factor, ...
                'method',"musyn_"+models.names(j),'info',info,'options',opts);
            save(file,'candidate','-v7');
        end
        controllers{end+1}=candidate; names(end+1)=candidate.method; %#ok<AGROW>
    end
    for k=1:3
        cc=controllers{k};
        for j=[1 3]
            auditFile=fullfile(folder,sprintf('synthesis_%s_%s_band_%g.mat',names(k),models.names(j),factor));
            if isfile(auditFile)
                a=load(auditFile,'audit'); audit=a.audit;
            else
                cl=salaris_closed_loop(models.plants{j},cc.K,W1,q.W2,Mo);
                audit=salaris_audit_loop(cl); audit.K=cc.K; audit.CL=cl;
                save(auditFile,'audit','-v7');
            end
            r=audit;
            rows(end+1,:)={names(k),models.names(j),factor,order(cc.K),cc.gamma, ...
                r.nominalNorm,r.RS.LowerBound,r.RS.UpperBound,r.RP.LowerBound, ...
                r.RP.UpperBound,min(r.bandwidth),r.disturbanceNorm}; %#ok<AGROW>
            summary=cell2table(rows,'VariableNames',{'Design','AnalysisModel','BandwidthFactor', ...
                'Order','SynthesisBound','NominalNorm','RSLower','RSUpper','RPLower', ...
                'RPUpper','MinimumBandwidth','DisturbanceNorm'});
            writetable(summary,fullfile(folder,'synthesis.csv'));
            fprintf('SINTESI %s modello %s fattore %g: RS=%g RP=%g banda=%g\n', ...
                names(k),models.names(j),factor,r.RS.LowerBound,r.RP.LowerBound,min(r.bandwidth));
        end
    end
    % La campagna termina se entrambe le sintesi raggiungono RS/RP.
    salaris_relax_performance(factor);
    ownA=summary.Design=="musyn_A_full" & summary.AnalysisModel=="A_full" & summary.BandwidthFactor==factor;
    ownB=summary.Design=="musyn_B_parametric" & summary.AnalysisModel=="B_parametric" & summary.BandwidthFactor==factor;
    if all(summary.RSLower(ownA|ownB)>1 & summary.RPLower(ownA|ownB)>1),break;end
end
end
function system=slow(system,factor)
[A,B,C,D]=ssdata(ss(system)); system=ss(factor*A,factor*B,C,D);
end
