function result=run_lqgi_validation
%RUN_LQGI_VALIDATION Ricalcolo lineare, NL e rumore del servo realmente stimato.
root=fileparts(fileparts(mfilename('fullpath')));
config=lqgi_validation_specs;
m3=load(fullfile(root,'results/data/m3_nominal_actuated_plant.mat'));
m5=load(fullfile(root,'results/data/m5_performance_specs.mat'));
m6=load(fullfile(root,'results/data/m6_lqg_no_integrator.mat'));
m7=load(fullfile(root,'results/data/m7_augmented_cost_feasibility.mat'));
design=m7.designs{m7.config.illustrativeIndex};
evaluation=evaluate_lqgi_candidate(m3,m5,m6,design,m7.config);
assert(isequal(evaluation.L,m6.L) && isequal(evaluation.Qn,m6.Qn) && isequal(evaluation.Rn,m6.Rn));
[A,B,C,D]=ssdata(evaluation.Klqgi);
controller=struct('id',"LQGI",'K',evaluation.Klqgi,'order',16,'A',A,'B',B,'C',C,'D',D);
folder=fullfile(root,'results/data/lqgi_validation'); if ~isfolder(folder),mkdir(folder);end
result=struct('config',config,'controller',controller,'design',design, ...
    'linear',evaluation,'tracking',{{}},'disturbance',{{}},'noise',{{}});
result.equilibrium=simulate_lqgi_nonlinear(controller,struct,root,config);
result.equilibriumError=max(abs(result.equilibrium.xMechanical-m3.xbar'),[],'all');
assert(result.equilibriumError<config.equilibrium.positionTolerance,'LQGI:Equilibrium','Equilibrio non conservato.');
rows=zeros(12,10); row=0;
for j=1:2
    for amp=config.tracking.referenceAmplitudesDeg'
        s=struct('reference',[0 0],'horizon',config.simulation.trackingHorizon);
        s.reference(j)=deg2rad(amp);
        v=simulate_lqgi_nonlinear(controller,s,root,config);
        q=v.xMechanical(:,1:2)-m3.xbar(1:2)'; u=v.controlDelta;
        tail=mean(q(v.time>=.9*s.horizon,:),1);
        ix=find(abs(q(:,j)-tail(j))>.02*deg2rad(amp),1,'last'); Ts=0;
        if ~isempty(ix), if ix==numel(v.time),Ts=inf;else,Ts=v.time(ix+1);end;end
        metrics=[Ts,100*max(0,max(q(:,j))/deg2rad(amp)-1), ...
            abs(tail(j)-deg2rad(amp))/deg2rad(amp),max(abs(q(:,3-j)))/max(max(abs(q(:,j))),eps), ...
            max(abs(u),[],'all'),sqrt(mean(u.^2,'all'))];
        result.tracking{end+1}=struct('joint',j,'amplitudeDeg',amp,'simulation',v,'metrics',metrics,'tailMean',tail);
        row=row+1; rows(row,:)=[1,j,amp,metrics,max(abs(q(end,:)-s.reference))];
        fprintf('LQGI NL tracking j%d %g deg: ',j,amp);disp(metrics);
    end
    for amp=config.disturbance.amplitudesNm'
        s=struct('disturbance',[0 0],'horizon',config.simulation.disturbanceHorizon);s.disturbance(j)=amp;
        v=simulate_lqgi_nonlinear(controller,s,root,config);
        q=v.xMechanical(:,1:2)-m3.xbar(1:2)';u=v.controlDelta;
        metrics=[max(abs(q),[],'all'),max(abs(mean(q(v.time>=.9*s.horizon,:),1))), ...
            max(abs(u),[],'all'),sqrt(mean(u.^2,'all')),max(abs(q(end,:))),max(abs(v.xController(:,15:16)),[],'all')];
        result.disturbance{end+1}=struct('joint',j,'amplitudeNm',amp,'simulation',v,'metrics',metrics);
        row=row+1;rows(row,:)=[2,j,amp,metrics,max(abs(q(end,:)))];
        fprintf('LQGI NL disturbo j%d %g Nm: ',j,amp);disp(metrics);
    end
end
rng(config.noise.seed,'twister'); t=(0:config.simulation.inputTimeStep:config.simulation.noiseHorizon)';
encoder=config.noise.sampleStdMeasurementRad*randn(numel(t),4);
process=randn(numel(t),4).*config.noise.sampleStdProcessNm;
% Sono campioni ZOH finiti, distinti dalle intensita del progetto lqe continuo.
for experiment=1:3
    s=struct('reference',[m5.spec.referenceAmplitude,0],'horizon',t(end));
    if experiment>=2,s.measurementNoise=encoder;end
    if experiment==3,s.processNoise=process;end
    v=simulate_lqgi_nonlinear(controller,s,root,config);
    errorTrue=v.reference-(v.xMechanical(:,1:2)-m3.xbar(1:2)');
    result.noise{experiment}=struct('experiment',experiment,'simulation',v, ...
        'peakU',max(abs(v.controlDelta),[],'all'),'rmsU',sqrt(mean(v.controlDelta.^2,'all')), ...
        'rmsErrorTrue',sqrt(mean(errorTrue.^2,'all')),'rmsErrorMeasured',sqrt(mean(v.error.^2,'all')));
end
repeat=simulate_lqgi_nonlinear(controller,result.noise{2}.simulation.scenario,root,config);
result.noiseRepeatError=max(abs(repeat.controlDelta-result.noise{2}.simulation.controlDelta),[],'all');
assert(result.noiseRepeatError<1e-10,'LQGI:NoiseRepeat','Esperimento rumoroso non riproducibile.');
result.experimentRows=rows;
result.noiseSeed=config.noise.seed;result.noiseSampleTime=config.simulation.inputTimeStep;
result.measurementSampleStdRad=config.noise.sampleStdMeasurementRad;
result.processSampleStdNm=config.noise.sampleStdProcessNm;
result.Qn=m6.Qn;result.Rn=m6.Rn;result.L=m6.L;
result.linearNoise=evaluate_lqgi_noise(result,m3,m5);
save(fullfile(folder,'validation.mat'),'result','-v7');
writematrix(rows,fullfile(folder,'nonlinear_metrics.csv'));
export_lqgi_validation(result,root);
end
