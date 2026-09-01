close all
clear all
clc

s = tf('s');

%% Modello nominale (senza ritardo)
k0   = 2.5;
tau0 = 2.5;
Gnom = tf(k0, [tau0 1]);

%% Campionamento manuale (k, tau, theta variabili)
rng('default');
N          = 200;
k_vals     = 2 + rand(N,1);
tau_vals   = 2 + rand(N,1);
theta_vals = 2 + rand(N,1);

omega = logspace(-3, 3, N);

%% Costruzione array frd
Gu_array = frd(zeros(1,1,N), omega);
for i = 1:N
    Gp = tf(k_vals(i), [tau_vals(i) 1], 'InputDelay', theta_vals(i));
    Gu_array(:,:,i) = frd(Gp, omega);
end

%% ucover
OrderWt = 2;
[usys, info] = ucover(Gu_array, Gnom, OrderWt, 'InputMult');
WI = tf(info.W1);

%% Errore relativo e peso
Gnom_frd    = frd(Gnom, omega);
RelDiff     = (Gu_array - Gnom_frd) / Gnom_frd;
RelDiff_mag = 20*log10(abs(squeeze(RelDiff.ResponseData)));

WI_frd = frd(WI, omega);
WI_mag = 20*log10(abs(squeeze(WI_frd.ResponseData)));

figure;
semilogx(omega, RelDiff_mag, 'b--');
hold on;
semilogx(omega, WI_mag, 'r-', 'LineWidth', 2);
grid on;
xlabel('\omega [rad/s]'); ylabel('[dB]');
legend('Errore relativo impianti', 'W_I(s)');

%% Modello incertezza moltiplicativa
Delta_I   = ultidyn('Delta', [1 1]);
Gu_Lumped = Gnom * (1 + WI * Delta_I);