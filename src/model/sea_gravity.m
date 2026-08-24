function G = sea_gravity(q, p)
%SEA_GRAVITY Gravity torque vector G(q) in N*m.
%   Q is [q1; q2] in rad, with q2 relative to the first link.

q1 = q(1);
q2 = q(2);
distalGravity = p.m2 * p.g * p.l2 * cos(q1 + q2);

G = [ ...
    (p.m1 + p.m2) * p.g * p.l1 * cos(q1) + distalGravity; ...
    distalGravity];
end
