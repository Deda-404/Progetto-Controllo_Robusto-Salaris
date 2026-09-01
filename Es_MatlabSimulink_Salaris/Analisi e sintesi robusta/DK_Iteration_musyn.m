clear all
close all
clc

%% Mu-analysis
%% Regulation problem with output disturbance
%% Nominal model of the distillation process
tau = 75; % min
G0 = [87.8 -86.4;108.2 -109.6];
G = tf(1,[tau 1])*G0;
% G = minreal(ss(G));

%% Uncertainty weight 
% Independent (structured) input uncertainty,
% modeled as multiplicative input uncertainty.
WI = tf([1 0.2],[0.5 1])*eye(2);

%% Performance weight
% The same required performance on both system outputs
Wp = 0.5*tf([10 1],[10 1e-5])*eye(2);

%% Generalized plant P by using 
% Use of connect to find P with the control loop 
% with multiplicative input uncertainty
G.u = 'uG';
G.y = 'yG';

Wp.u = 'z1';
Wp.y = 'z';

WI.u = 'u';
WI.y = 'yd';

Sum1 = sumblk('z1=w+yG',2);
Sum2 = sumblk('uG=u+ud',2);
Sum3 = sumblk('v=-z1',2);

P = connect(G,Wp,WI,Sum1,Sum2,Sum3,...
    {'ud','w','u'},{'yd','z','v'});

%% D-K iteration (hand made)
% Initialization
omega = logspace(-3,3,61);
blk = [1 1;1 1;2 2];
nmeas = 2; nu = 2; d0 = 1;
D = append(d0,d0,tf(eye(2)),tf(eye(2)));

for k = 1:3
%
% STEP 1: find H-inf optimal controller with a given scaling.
%
[K,Nsc,gamma,info] = hinfsyn(D*P*inv(D),nmeas,nu,'method','lmi','Tolgam',1e-3);

Nf = frd(lft(P,K),omega);

%
% STEP 2: compute mu using upper bound.
%
[mubnds,Info] = mussv(Nf,blk);
bodemag(mubnds(1,1),omega);
murp = norm(mubnds(1,1),inf,1e-6);

%
% STEP 3: fit resulting D-scales.
%
% [dsysl,dsysr] = mussvunwrap(Info);
[VDelta,VSigma] = mussvextract(Info);
VSigma.DLeft = VSigma.DLeft/VSigma.DLeft(3,3);
% dsysl = dsysl/dsysl(3,3);
% d1 = fitfrd(genphase(VSigma.DLeft(1,1)),4); % choose 4th order
d1 = fitmagfrd(VSigma.DLeft(1,1),4); % fitting 4th order minimum phase tf
hold on
grid on
% 
% GO TO STEP 1 (unless satisfactory with murp)
% 
D = append(d1,d1,tf(eye(2)),tf(eye(2)));

% % Plot of d scale factor and its fitting
% bodemag(VSigma.DLeft(1,1),omega,'.')
% hold on
% grid on
% bodemag(d1,omega)
end

%% Alternatively use automatic software
Delta = [ultidyn('Delta_1',[1 1]) 0;...
    0 ultidyn('Delta_2',[1 1])];
Punc = lft(Delta,P); % perturbed model
opts = musynOptions('Display','short','MixedMU','on','MaxIter',20);
[K,CLperf,info] = musyn(Punc,nmeas,nu,opts);