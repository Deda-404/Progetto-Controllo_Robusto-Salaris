function [xbar, taubar, info] = sea_static_equilibrium(qbar, p)
%SEA_STATIC_EQUILIBRIUM Static equilibrium for an assigned link posture.
%   [XBAR, TAUBAR, INFO] = SEA_STATIC_EQUILIBRIUM(QBAR,P) solves the
%   nominal static SEA relations without assuming a particular posture.

assert(numel(qbar) == 2, 'sea_static_equilibrium:InvalidConfiguration', ...
    'The link configuration must contain exactly two elements.');
qbar = reshape(qbar, 2, 1);

Gbar = sea_gravity(qbar, p);
thetabar = qbar + p.Ks \ Gbar;
taubar = Gbar;
xbar = [qbar; zeros(2, 1); thetabar; zeros(2, 1)];

[tauElastic, deformation] = sea_elastic_torque(qbar, thetabar, p);
rhsResidual = sea_nonlinear_rhs(xbar, taubar, p);

info.Gbar = Gbar;
info.thetabar = thetabar;
info.deformation = deformation;
info.tauElastic = tauElastic;
info.staticLinkResidual = tauElastic - Gbar;
info.staticMotorResidual = taubar - tauElastic;
info.rhsResidual = rhsResidual;
info.residualNorm = norm(rhsResidual, 2);
end
