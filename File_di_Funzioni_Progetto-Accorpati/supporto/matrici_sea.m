function [M,C,G,Kg]=matrici_sea(q,v,p)
%MATRICI_SEA Matrici dinamiche del manipolatore 2R della traccia (Capitolo 2).
%
% Ingressi: q=[q1;q2] [rad] (q2 relativo al primo link), v=dq/dt [rad/s],
% p struttura con m1, m2, l1, l2, g (m2 puo essere un ureal).
% Uscite:
%   M  [kg m^2]  inerzia dei link, simmetrica e definita positiva;
%   C  [kg m^2/s] Coriolis/centrifughe, con C*v coppia [N m];
%   G  [N m]     coppie gravitazionali;
%   Kg [N m/rad] Jacobiano dG/dq, usato nella linearizzazione
%                ("rigidezza gravitazionale": non nulla anche in qbar).
% Lo stesso m2 compare in inerzia, Coriolis e gravita, anche quando e ureal:
% le occorrenze restano correlate.
m=p.m2;
c=m*p.l1*p.l2*cos(q(2)); h=m*p.l1*p.l2*sin(q(2)); b=m*p.l2^2;
M=[(p.m1+m)*p.l1^2+b+2*c,b+c;b+c,b];
C=[-h*v(2),-h*sum(v);h*v(1),0];
g2=m*p.g*p.l2*cos(sum(q));
G=[(p.m1+m)*p.g*p.l1*cos(q(1))+g2;g2];
g12=-m*p.g*p.l2*sin(sum(q));
Kg=[-(p.m1+m)*p.g*p.l1*sin(q(1))+g12,g12;g12,g12];
end
