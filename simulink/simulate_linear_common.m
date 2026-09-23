function r=simulate_linear_common(kind,overrides)
%SIMULATE_LINEAR_COMMON Simulate the explicit M3 diagram without synthesis.
if nargin<2, overrides=struct; end
root=fileparts(fileparts(mfilename('fullpath')));
model='SEA_linear_common';
load_system(fullfile(root,'simulink/models',[model '.slx']));
cleanup=onCleanup(@() close_system(model,0));
c=setup_linear_common(kind,model,overrides);
out=sim(model,'StopTime',num2str(c.horizon,17));
r=struct('kind',string(kind),'config',c,'time',(0:c.noiseStep:c.horizon)');
for k=1:out.logsout.numElements
    e=out.logsout.get(k); ts=e.Values;
    [t,ix]=unique(ts.Time,'last');
    r.(e.Name)=interp1(t,ts.Data(ix,:),r.time,'linear');
end
r.completed=abs(out.tout(end)-c.horizon)<1e-8 && all(isfinite(r.x_full),'all');
end
