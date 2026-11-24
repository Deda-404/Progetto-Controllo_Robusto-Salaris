function M = sea_link_inertia(q, p)
%SEA_LINK_INERTIA Link-side inertia matrix M(q) in kg*m^2.
%   Q is [q1; q2] in rad. P is returned by SEA_PARAMS_NOMINAL.

q2 = q(2);
coupling = p.m2 * p.l1 * p.l2 * cos(q2);
distalInertia = p.m2 * p.l2^2;

m11 = (p.m1 + p.m2) * p.l1^2 + distalInertia + 2 * coupling;
m12 = distalInertia + coupling;
m22 = distalInertia;

M = [m11, m12; m12, m22];
end
