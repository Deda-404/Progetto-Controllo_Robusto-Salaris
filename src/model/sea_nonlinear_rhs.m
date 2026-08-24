function xdot = sea_nonlinear_rhs(x, tau, p)
%SEA_NONLINEAR_RHS Full eight-state nonlinear dynamics of the 2R SEA robot.
%   X = [q; qdot; theta; thetadot] is an 8-by-1 state vector and TAU is
%   the 2-by-1 motor torque in N*m. The output follows the same state order.

assert(numel(x) == 8, 'sea_nonlinear_rhs:InvalidState', ...
    'The state must contain exactly eight elements.');
assert(numel(tau) == 2, 'sea_nonlinear_rhs:InvalidInput', ...
    'The motor torque must contain exactly two elements.');

x = reshape(x, 8, 1);
tau = reshape(tau, 2, 1);

q = x(1:2);
qdot = x(3:4);
theta = x(5:6);
thetadot = x(7:8);

M = sea_link_inertia(q, p);
C = sea_coriolis(q, qdot, p);
G = sea_gravity(q, p);
tauElastic = sea_elastic_torque(q, theta, p);

qddot = M \ (tauElastic - C * qdot - G);
thetaddot = p.Jm \ (tau - p.Bm * thetadot - tauElastic);

xdot = [qdot; qddot; thetadot; thetaddot];
end
