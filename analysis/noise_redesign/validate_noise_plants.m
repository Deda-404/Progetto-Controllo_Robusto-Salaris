function result = validate_noise_plants
% Dieci impianti gia congelati: stessi parametri e blocchi dinamici.
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(genpath(fullfile(root,'analysis'))); d=final_closure_load;
folder=fullfile(root,'results/data/noise_redesign');
a=load(fullfile(root,'results/data/final_closure/practical_robustness.mat'),'result');
plants=a.result; cc=d.controllers([4 6]);
files=["hinf_noise_03","mu_noise_01"];
for j=1:2
    a=load(fullfile(folder,files(j)+".mat"),'candidate'); item=cc(j);item.K=a.candidate.K;item.name=a.candidate.name;
    [item.A,B,item.C,D]=ssdata(item.K);item.Br=B(:,1:2);item.By=B(:,3:4);
    item.Dr=D(:,1:2);item.Dy=D(:,3:4);item.order=order(item.K);cc(end+1)=item; %#ok<AGROW>
end
t=(0:d.dt:4)';td=(0:d.dt:8)';rows=cell(0,11);runs=cell(11,4,2);
for j=1:11
    if j==1,plant=plants.nominalPlant;else,plant=plants.sampledPlants(:,:,j-1);end
    [A,B,C,D]=ssdata(plant);assert(~any(D,'all'));
    for k=1:4
        item=cc(k);item.Cm=C;cl=final_closure_loop(A,B(:,1:2),B(:,3:4),C,item);
        for joint=1:2
            values=nan(1,6);
            if cl.stable
                r=zeros(numel(t),2);r(:,joint)=d.m5.spec.referenceAmplitude;
                y=lsim(cl.reference,r,t);final=dcgain(cl.reference(joint,joint))*d.m5.spec.referenceAmplitude;
                last=find(abs(y(:,joint)-final)>.02*d.m5.spec.referenceAmplitude,1,'last');ts=0;
                if ~isempty(last),ts=Inf;if last<numel(t),ts=t(last+1);end,end
                dist=zeros(numel(td),2);dist(td>=1,joint)=d.m5.spec.disturbanceTorqueAmplitude;
                yd=lsim(cl.disturbance,dist,td);
                values=[ts,100*max(0,max(y(:,joint))/d.m5.spec.referenceAmplitude-1), ...
                    abs(final/d.m5.spec.referenceAmplitude-1),max(abs(yd(:,1:2)),[],'all'), ...
                    max(abs(yd(:,3:4)),[],'all'),sqrt(mean(yd(:,3:4).^2,'all'))];
                runs{j,k,joint}=struct('tracking',y,'disturbance',yd);
            end
            rows(end+1,:)=[{j-1,char(item.name),joint,cl.stable,max(real(cl.poles))},num2cell(values)]; %#ok<AGROW>
        end
    end
    fprintf('PLANTS DONE %d/10\n',j-1);
end
metrics=cell2table(rows,'VariableNames',{'Plant','Controller','Joint','Stable','MaxRealPole', ...
    'SettlingTime','Overshoot','FinalError','DisturbancePeakQ','DisturbancePeakU','DisturbanceRmsU'});
result=struct('sampleSource','results/data/final_closure/practical_robustness.mat', ...
    'seed',plants.seed,'controllers',cc,'metrics',metrics,'runs',{runs},'time',t,'disturbanceTime',td);
save(fullfile(folder,'plants_validation.mat'),'result','-v7');writetable(metrics,fullfile(folder,'plants_metrics.csv'));
end
