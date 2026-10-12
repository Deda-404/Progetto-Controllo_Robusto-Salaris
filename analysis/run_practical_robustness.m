function result = run_practical_robustness
%RUN_PRACTICAL_ROBUSTNESS Ten new common uncertain plants plus the nominal.
d=final_closure_load; folder=fullfile(d.root,'results/data/final_closure');
m4=load(fullfile(d.root,'results/data/m4_uncertain_plant.mat'));
physical=hinf_final_uncertain(m4,d.m5.BdFull);
names=sort(string(fieldnames(physical.Uncertainty)));
assert(isequal(names,sort(["Jm1";"k1";"k2";"Delta_act1";"Delta_act2"])));
uncertainty=physical.Uncertainty;
assert(isequal(uncertainty.k1.Range,[45 55]) && isequal(uncertainty.k2.Range,[36 44]));
assert(max(abs(uncertainty.Jm1.Range-[.009 .011]))<1e-12);
oldRng=rng; cleanup=onCleanup(@()rng(oldRng));
rng(d.seed,'twister'); [sampled,values]=usample(physical,10);
rng(d.seed,'twister'); [repeated,repeatedValues]=usample(physical,10);
assert(isequaln(values,repeatedValues) && isequaln(sampled,repeated),'PracticalRobustness:Replay','Non-deterministic sample replay.');
Ks=d.controllers([4 6]); trackingTime=(0:d.dt:4)'; disturbanceTime=(0:d.dt:8)';
rows=cell(0,14); plantRows=cell(0,9); runs=cell(11,2);
for j=1:11
    if j==1, plant=physical.NominalValue; else, plant=sampled(:,:,j-1); end
    [A,B,C,D]=ssdata(plant); assert(~any(D,'all'));
    if j>1
        val=values(j-1);
        plantRows(end+1,:)={j-1,val.k1,val.k2,val.Jm1,order(val.Delta_act1),order(val.Delta_act2), ...
            norm(val.Delta_act1,inf),norm(val.Delta_act2,inf),max(real(pole(plant)))}; %#ok<AGROW>
        assert(norm(val.Delta_act1,inf)<=1+1e-7 && norm(val.Delta_act2,inf)<=1+1e-7);
    end
    for k=1:2
        cc=Ks(k); cc.Cm=C;
        cl=final_closure_loop(A,B(:,1:2),B(:,3:4),C,cc);
        run=struct('stable',cl.stable,'poles',cl.poles,'maxRealPole',max(real(cl.poles)), ...
            'trackingTime',trackingTime,'disturbanceTime',disturbanceTime, ...
            'tracking',{cell(2,1)},'disturbance',{cell(2,1)});
        for joint=1:2
            ts=NaN; overshoot=NaN; offset=NaN; cross=NaN; peakQ=NaN; recovery=NaN; residual=NaN; peakU=NaN; rmsU=NaN;
            if cl.stable
                reference=zeros(numel(trackingTime),2); reference(:,joint)=d.m5.spec.referenceAmplitude;
                y=lsim(cl.reference,reference,trackingTime); run.tracking{joint}=y;
                final=dcgain(cl.reference(joint,joint))*d.m5.spec.referenceAmplitude;
                ts=settle(y(:,joint),final,.02*d.m5.spec.referenceAmplitude,trackingTime);
                overshoot=100*max(0,max(y(:,joint))/d.m5.spec.referenceAmplitude-1);
                offset=abs(final/d.m5.spec.referenceAmplitude-1);
                cross=max(abs(y(:,3-joint)))/max(max(abs(y(:,joint))),eps);
                disturbance=zeros(numel(disturbanceTime),2);
                disturbance(disturbanceTime>=1,joint)=d.m5.spec.disturbanceTorqueAmplitude;
                yd=lsim(cl.disturbance,disturbance,disturbanceTime); run.disturbance{joint}=yd;
                peakQ=max(abs(yd(:,1:2)),[],'all');
                recovery=max(arrayfun(@(i)settle(yd(disturbanceTime>=1,i),0,deg2rad(.5),disturbanceTime(disturbanceTime>=1)-1),1:2));
                residual=max(abs(yd(end,1:2)));
                peakU=max(abs(yd(:,3:4)),[],'all'); rmsU=sqrt(mean(yd(:,3:4).^2,'all'));
            end
            rows(end+1,:)={j-1,char(cc.name),joint,cl.stable,max(real(cl.poles)), ...
                ts,overshoot,offset,cross,peakQ,recovery,residual,peakU,rmsU}; %#ok<AGROW>
        end
        runs{j,k}=run;
    end
    fprintf('Practical plant %d/10: Hinf2 stable=%d; Kmu stable=%d\n',j-1,runs{j,1}.stable,runs{j,2}.stable);
end
metrics=cell2table(rows,'VariableNames',{'Plant','Controller','Joint','Stable','MaxRealPole','SettlingTime', ...
    'OvershootPercent','FinalErrorRelative','CrossCoupling','DisturbancePeakQ','RecoveryTime','DisturbanceResidualQ','DisturbancePeakU','DisturbanceRmsU'});
plantTable=cell2table(plantRows,'VariableNames',{'Plant','k1','k2','Jm1','Delta1Order','Delta2Order','Delta1HinfNorm','Delta2HinfNorm','PlantMaxRealPole'});
result=struct('seed',d.seed,'uncertainPhysical',physical,'sampledPlants',sampled,'sampledValues',values, ...
    'nominalPlant',physical.NominalValue,'controllers',Ks,'runs',{runs},'metrics',metrics,'plantTable',plantTable, ...
    'replayPassed',true,'engine','MATLAB lsim; not Simulink','recoveryBandRad',deg2rad(.5), ...
    'trackingSettlingConvention','2 percent of reference amplitude around analytical DC; horizon 4s');
save(fullfile(folder,'practical_robustness.mat'),'result','-v7');
writetable(metrics,fullfile(folder,'practical_metrics.csv')); writetable(plantTable,fullfile(folder,'practical_plants.csv'));
end
function ts=settle(y,final,band,t)
last=find(abs(y-final)>band,1,'last'); ts=0;
if ~isempty(last)
    ts=Inf;
    if last<numel(t),ts=t(last+1);end
end
end
