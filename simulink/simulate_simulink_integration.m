function r=simulate_simulink_integration(kind,overrides)
%SIMULATE_SIMULINK_INTEGRATION Reproducible run; no base-workspace assumptions.
if nargin<2, overrides=struct; end
root=fileparts(fileparts(mfilename('fullpath')));
model=char("SEA_"+string(kind)+"_integrated");
load_system(fullfile(root,'simulink/models',[model '.slx']));
c=setup_simulink_integration(kind,model,overrides);
out=sim(model,'StopTime',num2str(c.horizon,17));
r=struct('kind',string(kind),'config',c);
r.time=(0:c.noiseStep:c.horizon)';
for k=1:out.logsout.numElements
 element=out.logsout.get(k); ts=element.Values;
 [t,ix]=unique(ts.Time,'last'); y=double(ts.Data);
 if size(y,1)~=numel(ts.Time), y=reshape(y,[],numel(ts.Time))'; end
 r.(element.Name)=interp1(t,y(ix,:),r.time,'linear','extrap');
end
r.completed=abs(out.tout(end)-c.horizon)<1e-8;
assert(r.completed && all(isfinite(r.q_abs),'all'),'Incomplete simulation');
close_system(model,0);
end
