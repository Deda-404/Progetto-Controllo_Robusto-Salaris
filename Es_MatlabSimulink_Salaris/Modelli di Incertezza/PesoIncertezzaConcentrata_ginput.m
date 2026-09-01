close all
clear all
clc

s = tf('s');
%% Parametri incerti (non necessario)
k = ureal('k',2.5,'Range',[2, 3]);
tau = ureal('tau',2.5,'Percentage',[-20, 20]);
theta = ureal('theta',2.5,'Range',[2, 3]);

%% Modello nominale centrale (ritardo trascurato)
Gnom = k.NominalValue/(tau.NominalValue*s+1);
Gnom_frd = frd(Gnom,omega);

%% Campionamento manuale (k, tau, theta variabili)
rng('default');
N          = 200;
k_vals     = 2 + rand(N,1);
tau_vals   = 2 + rand(N,1);
theta_vals = 2 + rand(N,1);

omega = logspace(-3,3,200);

%% Costruzione array frd
Gu_array = frd(zeros(1,1,N), omega);
for i = 1:N
    Gp = tf(k_vals(i), [tau_vals(i) 1], 'InputDelay', theta_vals(i));
    Gu_array(:,:,i) = frd(Gp, omega);
end

%% Differenza assoluta o relativa
% If additive uncertainty structure
% AbsDiff = Gu_array - Gnom_frd; 
% If moltiplicative uncertainty structure
RelDiff = (Gu_array - Gnom_frd)/Gnom_frd;
% If inverse moltiplicative uncertainty structure
% RelDiffInv = (Gu_array - Gnom_frd)/Gu_array;

RelDiff_mag = 20*log10(abs(squeeze(RelDiff.ResponseData)));

figure;
semilogx(omega, RelDiff_mag, 'b--');
hold on;
grid on;

%% Comando ginput
[freq, resp_db] = ginput(20); 
% Senza passare numero intero, possiamo 
% selezionare un numero arbitrario di punti e poi INVIO
% Attenzione a selezionarli in ordine crescente di omega, 
% altrimenti poi dobbiamo riordinarli con il comando sort

for i=1:20
    resp(i) = 10^(resp_db(i)/20);
end

%% Fitting dei punti selezionati per determinare il W
sys = frd(resp,freq);
ord = 2;
W = fitmagfrd(sys,ord);
Wtf = tf(W);

%% Verifica della correttezza del peso scelto
Wtf_frd = frd(Wtf,omega);
semilogx(omega,20*log10(abs(...
            squeeze(Wtf_frd.ResponseData))),'r-');

%% Modello incertezza moltiplicativa
Delta_I = ultidyn('Delta',[1 1]);
Gu = Gnom*(1+Wtf*Delta_I);
