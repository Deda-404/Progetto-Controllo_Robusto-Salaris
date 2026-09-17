function extension = extend_hinf_revision_2dof
% Studio opzionale: prefiltro stabile, nessuna risintesi o garanzia 2-DoF.
% Implementazione condivisa u=K*(F*r-y), evitando duplicati di stati di K.
root=fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(root,'controllers')));
folder=fullfile(root,'results','data','hinf_targeted_revision');
loaded=load(fullfile(folder,'study.mat')); study=loaded.study;
assert(~isempty(study.selected),'Full-order conforme necessario.');
r=study.cases{study.selected}; c=study.config;
m5=load(fullfile(root,'results','data','m5_performance_specs.mat'));
s=tf('s'); omegaReference=r.parameters(1);
Mo=(omegaReference/(s+omegaReference))^2*eye(2);
N=dcgain(r.hinf.T)\eye(2); F=ss(N*Mo);
extension=struct('Mo',Mo,'N',N,'F',F,'Ky',r.Khinf,'Kr',r.Khinf*F, ...
    'omegaReference',omegaReference,'reference',r.hinf.reference*F, ...
    'disturbance',r.hinf.disturbance,'config',c);
extension.internalPoles=[eig(r.hinf.Acl);pole(F)];
extension.stable=all(real(extension.internalPoles)<-c.stabilityTolerance);
[extension.metrics,extension.responses]=hinf_revision_tracking(extension.reference,m5.spec,c);
extension.trackingWeighted=[r.W1*(eye(2)-extension.reference(1:2,:)); ...
    r.W2*extension.reference(3:4,:)];
extension.trackingNorm=norm(extension.trackingWeighted,inf);
extension.modelErrorNorm=norm(extension.reference(1:2,:)-Mo,inf);
extension.feedbackGamma=r.gammaHinf;
v=max(extension.metrics,[],1);
extension.m5Temporal=extension.stable && all(v(1:4)<=[m5.spec.settlingTimeTarget, ...
    m5.spec.overshootTarget,m5.spec.steadyStateTrackingTarget,m5.spec.crossCouplingTarget]);
extension.revisedTemporal=extension.stable && all(v(1:4)<=[c.revised.settlingTime, ...
    c.revised.overshootPercent,c.revised.steadyErrorRelative,c.revised.crossCoupling]);
save(fullfile(folder,'extension_2dof.mat'),'extension','-v7');
disp(extension.metrics);
fprintf('2-DoF tracking norm %.9g; feedback gamma %.9g\n',extension.trackingNorm,extension.feedbackGamma);
end
