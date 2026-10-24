function salaris_synthesis_temporal
%SALARIS_SYNTHESIS_TEMPORAL Rapidita e disturbo dei soli nuovi candidati.
d=final_closure_load; q=d.selected; folder=fullfile(d.root,'results/data/salaris_revision');
a=load(fullfile(folder,'models.mat')); model=a.models.plants{1};
files=[dir(fullfile(folder,'musyn_*_band_*.mat'));dir(fullfile(folder,'hinf_band_*.mat'))];
time=(0:.005:12)'; rows=cell(0,8);
for k=1:numel(files)
    a=load(fullfile(files(k).folder,files(k).name),'candidate'); c=a.candidate;
    cl=salaris_closed_loop(model,c.K,q.W1,q.W2,q.Mo); cl=cl.NominalValue(1:4,:);
    worst=zeros(1,6);
    for joint=1:2
        signal=zeros(numel(time),4); signal(:,joint)=d.m5.spec.referenceAmplitude;
        y=lsim(cl,signal,time); final=dcgain(cl(joint,joint))*d.m5.spec.referenceAmplitude;
        last=find(abs(y(:,joint)-final)>.02*d.m5.spec.referenceAmplitude,1,'last');
        ts=0;if ~isempty(last),ts=Inf;if last<numel(time),ts=time(last+1);end,end
        metrics=[ts,100*max(0,max(y(:,joint))/d.m5.spec.referenceAmplitude-1), ...
            abs(final/d.m5.spec.referenceAmplitude-1),max(abs(y(:,3:4)),[],'all'),0,0];
        signal=zeros(numel(time),4); signal(time>=1,2+joint)=d.m5.spec.disturbanceTorqueAmplitude;
        yd=lsim(cl,signal,time); metrics(5:6)=[max(abs(yd(:,1:2)),[],'all'),max(abs(yd(:,3:4)),[],'all')];
        worst=max(worst,metrics);
    end
    rows(end+1,:)=[{c.method,c.factor},num2cell(worst)]; %#ok<AGROW>
end
tab=cell2table(rows,'VariableNames',{'Design','BandwidthFactor','SettlingTime','OvershootPercent', ...
    'RelativeDCError','TrackingPeakTorque','DisturbancePeakRad','DisturbancePeakTorque'});
writetable(tab,fullfile(folder,'synthesis_temporal_metrics.csv'));
end
