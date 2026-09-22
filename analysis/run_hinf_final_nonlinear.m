function campaign=run_hinf_final_nonlinear
%RUN_HINF_FINAL_NONLINEAR Stesse ampiezze, orizzonti e criteri fisici M15.
root=fileparts(fileparts(mfilename('fullpath')));
[controllers,config]=hinf_final_nonlinear_setup(root,false);
folder=fullfile(root,'results','data','hinf_final_coherent');
m3=load(fullfile(root,'results','data','m3_nominal_actuated_plant.mat'));
campaign=cell(numel(controllers),1);
for k=1:numel(controllers)
    cc=controllers(k); file=fullfile(folder,"nonlinear_"+cc.id+".mat");
    if isfile(file), a=load(file,'r'); r=a.r; assert(isequaln(r.K,cc.K)); campaign{k}=r; continue; end
    r=struct('K',cc.K,'id',cc.id,'config',config,'tracking',{{}},'disturbance',{{}});
    r.equilibrium=simulate_hinf_final_nonlinear(cc,struct,root,config);
    r.equilibriumError=max(abs(r.equilibrium.xMechanical-m3.xbar'),[],'all');
    assert(r.equilibriumError<config.equilibrium.positionTolerance);
    for j=1:2
        for amp=config.tracking.referenceAmplitudesDeg'
            s=struct('reference',[0 0],'horizon',config.simulation.trackingHorizon); s.reference(j)=deg2rad(amp);
            v=simulate_hinf_final_nonlinear(cc,s,root,config);
            t=(0:config.simulation.inputTimeStep:s.horizon)';
            y=interp1(v.time,v.xMechanical(:,1:2)-m3.xbar(1:2)',t);
            u=interp1(v.time,v.controlDelta,t);
            % Media sulla coda NL: non sostituire l'errore NL con dcgain LTI.
            final=mean(y(t>=.9*s.horizon,:),1); a=deg2rad(amp);
            ix=find(abs(y(:,j)-final(j))>.02*a,1,'last'); Ts=0;
            if ~isempty(ix), if ix==numel(t), Ts=inf; else, Ts=t(ix+1); end; end
            metrics=[Ts,100*max(0,max(y(:,j))/a-1),abs(final(j)-a)/a, ...
                max(abs(y(:,3-j)))/max(max(abs(y(:,j))),eps),max(abs(u),[],'all'),sqrt(mean(u.^2,'all'))];
            r.tracking{end+1}=struct('joint',j,'amplitudeDeg',amp,'simulation',v,'metrics',metrics,'tailMean',final);
            fprintf('%s NL joint %d amp %g: ',cc.id,j,amp); disp(metrics);
        end
        for amp=config.disturbance.amplitudesNm'
            s=struct('disturbance',[0 0],'horizon',config.simulation.disturbanceHorizon); s.disturbance(j)=amp;
            v=simulate_hinf_final_nonlinear(cc,s,root,config);
            r.disturbance{end+1}=struct('joint',j,'amplitudeNm',amp,'simulation',v, ...
                'peakQ',max(abs(v.xMechanical(:,1:2)-m3.xbar(1:2)'),[],'all'), ...
                'peakU',max(abs(v.controlDelta),[],'all'));
        end
    end
    save(file,'r','-v7'); campaign{k}=r;
end
save(fullfile(folder,'nonlinear_study.mat'),'campaign','-v7');
end
