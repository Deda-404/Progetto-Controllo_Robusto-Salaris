function C = sea_coriolis(q, qdot, p)
%SEA_CORIOLIS Coriolis/centrifugal matrix C(q,qdot).
%   Q is in rad and QDOT is in rad/s. The product C*QDOT is a torque.

q2 = q(2);
q1dot = qdot(1);
q2dot = qdot(2);
velocityCoupling = p.m2 * p.l1 * p.l2 * sin(q2);

C = [ ...
    -velocityCoupling * q2dot, ...
    -velocityCoupling * (q1dot + q2dot); ...
     velocityCoupling * q1dot, 0];
end
