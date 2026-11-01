function dx=dinamica_sea(x,tau,disturbo,p)
%DINAMICA_SEA Equazioni della traccia, accorpate dalle funzioni M1 originali.
arguments
    x (8,1) double
    tau (2,1) double
    disturbo (2,1) double
    p (1,1) struct
end
q=x(1:2); v=x(3:4); theta=x(5:6); vt=x(7:8);
c=p.m2*p.l1*p.l2*cos(q(2)); h=p.m2*p.l1*p.l2*sin(q(2)); b=p.m2*p.l2^2;
M=[(p.m1+p.m2)*p.l1^2+b+2*c,b+c;b+c,b];
C=[-h*v(2),-h*sum(v);h*v(1),0];
g2=p.m2*p.g*p.l2*cos(sum(q));
G=[(p.m1+p.m2)*p.g*p.l1*cos(q(1))+g2;g2];
elastica=p.Ks*(theta-q);
dx=[v;M\(elastica-C*v-G+disturbo);vt;p.Jm\(tau-p.Bm*vt-elastica)];
end
