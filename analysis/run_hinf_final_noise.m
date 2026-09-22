function results=run_hinf_final_noise
%RUN_HINF_FINAL_NOISE Stessa sequenza a quattro canali della M15 storica.
root=fileparts(fileparts(mfilename('fullpath')));
[controllers,config]=hinf_final_nonlinear_setup(root,false);
folder=fullfile(root,'results','data','hinf_final_coherent');
old=load(fullfile(root,'results','data','m15_nonlinear_robust_validation.mat'),'noiseFourChannels');
assert(size(old.noiseFourChannels,2)==4);
results=cell(2,1);
for k=1:2
    s=struct('reference',[deg2rad(5) 0],'measurementNoise',old.noiseFourChannels(:,1:2), ...
        'horizon',config.simulation.noiseHorizon);
    cc=controllers(k); r=simulate_hinf_final_nonlinear(cc,s,root,config);
    repeated=simulate_hinf_final_nonlinear(cc,s,root,config);
    results{k}=struct('id',cc.id,'K',cc.K,'seed',config.noise.seed,'noise',s.measurementNoise, ...
        'simulation',r,'peakU',max(abs(r.controlDelta),[],'all'),'rmsU',sqrt(mean(r.controlDelta.^2,'all')), ...
        'repeatError',max(abs(r.controlDelta-repeated.controlDelta),[],'all'));
    fprintf('%s noise peak=%g RMS=%g repeat=%g\n',cc.id,results{k}.peakU,results{k}.rmsU,results{k}.repeatError);
end
save(fullfile(folder,'noise_study.mat'),'results','-v7');
end
