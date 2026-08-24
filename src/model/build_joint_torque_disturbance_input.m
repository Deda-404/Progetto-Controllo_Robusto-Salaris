function [Bd, info] = build_joint_torque_disturbance_input(qbar, p)
%BUILD_JOINT_TORQUE_DISTURBANCE_INPUT Linear link-torque input matrix.
%   D enters M(q)qddot + C(q,qdot)qdot + G(q) = Ks(theta-q) + D.

if nargin < 2 || isempty(p)
    p = sea_params_nominal;
end
assert(numel(qbar) == 2, ...
    'M5Disturbance:InvalidEquilibrium', ...
    'qbar must contain the two link angles.');
qbar = reshape(qbar, 2, 1);

Mbar = sea_link_inertia(qbar, p);
linkAccelerationBlock = Mbar \ eye(2);
Bd = [zeros(2); linkAccelerationBlock; zeros(4, 2)];

info.Mbar = Mbar;
info.linkAccelerationBlock = linkAccelerationBlock;
info.stateConvention = "[q; qdot; theta; thetadot]";
info.disturbanceMeaning = "external link-side joint torque [N m]";
info.nonzeroRows = [3; 4];
end
