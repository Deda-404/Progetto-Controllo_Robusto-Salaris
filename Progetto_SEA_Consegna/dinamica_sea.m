function dx = dinamica_sea(x,tau,d,p)
%DINAMICA_SEA Equazioni fisiche: x=[q;qdot;theta;thetadot], rad e rad/s.
% tau: coppia motore; d: coppia esterna sui link, entrambe in N m.
q=x(1:2); v=x(3:4); theta=x(5:6); vm=x(7:8);
h=p.m2*p.l1*p.l2; a=p.m2*p.l2^2;
M=[(p.m1+p.m2)*p.l1^2+a+2*h*cos(q(2)),a+h*cos(q(2)); ...
    a+h*cos(q(2)),a];
C=h*sin(q(2))*[-v(2),-v(1)-v(2);v(1),0];
G=[(p.m1+p.m2)*p.g*p.l1*cos(q(1))+p.m2*p.g*p.l2*cos(sum(q)); ...
    p.m2*p.g*p.l2*cos(sum(q))];
elastica=p.Ks*(theta-q);
dx=[v;M\(elastica-C*v-G+d);vm;p.Jm\(tau-p.Bm*vm-elastica)];
end
