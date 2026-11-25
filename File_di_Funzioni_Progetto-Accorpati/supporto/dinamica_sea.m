function dx=dinamica_sea(x,tau,disturbo,p)
%DINAMICA_SEA Equazioni non lineari del manipolatore con SEA (traccia, eq. 1-2).
%
% dx = f(x, tau, d) con x=[q; qd; theta; thetad] (8 stati, rad e rad/s),
% tau coppie motore [N m], d disturbi di coppia sui link [N m]:
%   qdd     = M(q)^-1 [ Ks(theta-q) - C(q,qd) qd - G(q) + d ]
%   thetadd = Jm^-1   [ tau - Bm thetad - Ks(theta-q) ]
% Usata per verificare equilibrio e Jacobiano e dal simulatore simula_sea.
arguments
    x (8,1) double
    tau (2,1) double
    disturbo (2,1) double
    p (1,1) struct
end
q=x(1:2); v=x(3:4); theta=x(5:6); vt=x(7:8);
[M,C,G]=matrici_sea(q,v,p);
elastica=p.Ks*(theta-q);
dx=[v;M\(elastica-C*v-G+disturbo);vt;p.Jm\(tau-p.Bm*vt-elastica)];
end
