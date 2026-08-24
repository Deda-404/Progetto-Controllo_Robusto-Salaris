function [A, B, equilibrium, info] = ...
    sea_linearize_static_equilibrium_analytic(qbar, p)
%SEA_LINEARIZE_STATIC_EQUILIBRIUM_ANALYTIC Exact static Jacobian blocks.
%   Supports both numeric parameters and ureal-valued parameter structures.

assert(numel(qbar) == 2, ...
    'sea_linearize_static_equilibrium_analytic:InvalidConfiguration', ...
    'The equilibrium configuration must contain two elements.');
qbar = reshape(qbar, 2, 1);

Mbar = sea_link_inertia(qbar, p);
Gbar = sea_gravity(qbar, p);
thetabar = qbar + p.Ks \ Gbar;
taubar = Gbar;

q1 = qbar(1);
q2 = qbar(2);
distalDerivative = -p.m2 * p.g * p.l2 * sin(q1 + q2);
gravityJacobian = [ ...
    -(p.m1 + p.m2) * p.g * p.l1 * sin(q1) + distalDerivative, ...
    distalDerivative; ...
    distalDerivative, distalDerivative];

qPositionBlock = -(Mbar \ (p.Ks + gravityJacobian));
qThetaBlock = Mbar \ p.Ks;
thetaPositionBlock = p.Jm \ p.Ks;
thetaThetaBlock = -(p.Jm \ p.Ks);
thetaVelocityBlock = -(p.Jm \ p.Bm);
motorInputBlock = p.Jm \ eye(2);

zeroBlock = zeros(2);
identityBlock = eye(2);
A = [ ...
    zeroBlock, identityBlock, zeroBlock, zeroBlock; ...
    qPositionBlock, zeroBlock, qThetaBlock, zeroBlock; ...
    zeroBlock, zeroBlock, zeroBlock, identityBlock; ...
    thetaPositionBlock, zeroBlock, thetaThetaBlock, thetaVelocityBlock];
B = [zeroBlock; zeroBlock; zeroBlock; motorInputBlock];

equilibrium.qbar = qbar;
equilibrium.thetabar = thetabar;
equilibrium.xbar = [qbar; zeros(2, 1); thetabar; zeros(2, 1)];
equilibrium.taubar = taubar;
info.Mbar = Mbar;
info.Gbar = Gbar;
info.gravityJacobian = gravityJacobian;
info.stateConvention = "[q; qdot; theta; thetadot]";
end
