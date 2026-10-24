function salaris_nominal_summary
%SALARIS_NOMINAL_SUMMARY Risultati nominali essenziali, senza nuove sintesi.
d=final_closure_load; folder=fullfile(d.root,'results/data/salaris_revision');
time=(0:.005:12)'; rows=cell(0,7);
for k=1:6
    cc=d.controllers(k);
    loop=final_closure_loop(d.m3.Afull,d.m3.Bfull,d.m5.BdFull,d.m3.CfullQ,cc);
    metrics=zeros(2,5);
    for joint=1:2
        r=zeros(numel(time),2); r(:,joint)=d.m5.spec.referenceAmplitude;
        response=lsim(loop.reference,r,time);
        final=dcgain(loop.reference(joint,joint))*d.m5.spec.referenceAmplitude;
        last=find(abs(response(:,joint)-final)>.02*d.m5.spec.referenceAmplitude,1,'last');
        ts=0;
        if ~isempty(last),ts=Inf;if last<numel(time),ts=time(last+1);end,end
        metrics(joint,:)=[ts,100*max(0,max(response(:,joint))/d.m5.spec.referenceAmplitude-1), ...
            abs(final/d.m5.spec.referenceAmplitude-1), ...
            max(abs(response(:,3-joint)))/max(max(abs(response(:,joint))),eps), ...
            max(abs(response(:,3:4)),[],'all')];
    end
    worst=max(metrics,[],1);
    rows(end+1,:)={cc.name,cc.order,worst(1),worst(2),worst(3),worst(4),worst(5)}; %#ok<AGROW>
end
tab=cell2table(rows,'VariableNames',{'Controller','Order','SettlingTime','OvershootPercent', ...
    'RelativeDCError','CrossCoupling','PeakTorque'});
writetable(tab,fullfile(folder,'nominal_metrics.csv'));
a=load(fullfile(folder,'models.mat')); m=a.models;
baseline=load(fullfile(d.root,'results/data/m4_uncertain_plant.mat'));
systems={baseline.GmechUncMeas,m.manualMechanical.G,m.actuator1.automatic,m.actuator1.G};
names=["Meccanica automatica","Meccanica manuale","Attuatore automatico","Attuatore manuale"];
rows=cell(0,5);
for j=1:4
    [~,~,blocks]=lftdata(systems{j});
    for k=1:numel(blocks)
        rows(end+1,:)={names(j),string(blocks(k).Name),string(blocks(k).Type), ...
            blocks(k).Size(1),blocks(k).Occurrences}; %#ok<AGROW>
    end
end
tab=cell2table(rows,'VariableNames',{'Model','Block','Type','ElementarySize','Occurrences'});
writetable(tab,fullfile(folder,'lft_blocks.csv'));
end
