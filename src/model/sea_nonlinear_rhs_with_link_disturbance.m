function xdot = sea_nonlinear_rhs_with_link_disturbance(x, tau, d, p)
%SEA_NONLINEAR_RHS_WITH_LINK_DISTURBANCE SEA dynamics with link torque D.
%   TAU remains the motor-side input; D is an external link-side joint
%   torque entering with positive sign in the link equation.

assert(numel(x) == 8, ...
    'sea_nonlinear_rhs_with_link_disturbance:InvalidState', ...
    'The state must contain exactly eight elements.');
assert(numel(tau) == 2 && numel(d) == 2, ...
    'sea_nonlinear_rhs_with_link_disturbance:InvalidInput', ...
    'Both tau and d must contain exactly two elements.');
x = reshape(x, 8, 1);
tau = reshape(tau, 2, 1);
d = reshape(d, 2, 1);

q = x(1:2);
qdot = x(3:4);
theta = x(5:6);
thetadot = x(7:8);
M = sea_link_inertia(q, p);
C = sea_coriolis(q, qdot, p);
G = sea_gravity(q, p);
tauElastic = sea_elastic_torque(q, theta, p);

qddot = M \ (tauElastic + d - C * qdot - G);
thetaddot = p.Jm \ (tau - p.Bm * thetadot - tauElastic);
xdot = [qdot; qddot; thetadot; thetaddot];
end
