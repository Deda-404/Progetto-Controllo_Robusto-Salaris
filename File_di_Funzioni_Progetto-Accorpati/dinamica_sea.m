function dx=dinamica_sea(x,tau,disturbo,p)
%DINAMICA_SEA Equazioni della traccia, accorpate dalle funzioni M1 originali.
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
