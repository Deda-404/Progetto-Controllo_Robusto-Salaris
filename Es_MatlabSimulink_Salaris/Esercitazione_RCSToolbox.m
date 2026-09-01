clear all
close all
clc

m = ureal('m',3,'Percentage',[-40,40]);
c = ureal('c',1,'Range',[0.8,1.2]);
k = ureal('k',2,'PlusMinus',[-0.6,0.6]);

A = [0 1;-k/m -c/m];
B = [0 1/m]';
C = [1 0];
D = 0;

uss1 = ss(A,B,C,D);

simplify(uss1,'full')

uss2 = tf(1,[m,c,k]);

sys_unc1 = usubs(uss2,'m',3,'c',1,'k',2); % sistema certo

usample(uss2,20); % 20 impianti possibili in ss
tf(usample(uss2,20)); % 20 impianti possibili in tf

figure(1)
hold on
w = logspace(-1,1,200);
bode(uss1,w)
grid on
hold off

figure(2)
hold on
step(uss1)
grid on
hold off

figure(3)
hold on
frres = ufrd(uss1,w);
nyquist(frres)
grid on
hold off

figure(4)
hold on
step(gridureal(uss2,20))
grid on
hold off




