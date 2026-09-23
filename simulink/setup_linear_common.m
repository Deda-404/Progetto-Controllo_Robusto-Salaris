function c=setup_linear_common(kind,model,overrides)
%SETUP_LINEAR_COMMON Configure the common linear plant in incremental units.
if nargin<2, model='SEA_linear_common'; end
if nargin<3, overrides=struct; end
c=setup_simulink_integration(kind,"",overrides);
assert(~c.enableMeasurementNoise && ~c.enableProcessNoise, ...
    'LinearCommon:Deterministic','This comparison model is deterministic.');
ny=size(c.Bk,2)-2;
controllerInitial=c.xController0;
if string(kind)=="LQG", controllerInitial=c.xhat0; end
if string(kind)=="LQRI", controllerInitial=[c.xhat0;c.xi0]; end
w=get_param(model,'ModelWorkspace');
assignin(w,'cfg',c);
assignin(w,'plantInitial',[c.xMechanical0-c.xbar;c.xActuator0-c.xactbar]);
assignin(w,'controllerInitial',controllerInitial);
assignin(w,'measurementSelection',[eye(ny) zeros(ny,4-ny)]);
end
