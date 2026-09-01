close all
clear all
clc

%% Modello nominale (senza ritardo)
k0   = 2.5;
tau0 = 2.5;

%% Campionamento manuale (k, tau, theta variabili)
rng('default');
N          = 200;
k_vals     = 2 + rand(N,1);
tau_vals   = 2 + rand(N,1);
theta_vals = 2 + rand(N,1);

N_omega = 300;
omega   = logspace(-3, 3, N_omega);

%% Calcolo risposta in frequenza esplicita
Gp_data = zeros(N_omega, N);
for i = 1:N
    Gp_data(:,i) = (k_vals(i) ./ (1 + 1j*omega'*tau_vals(i))) .* exp(-1j*omega'*theta_vals(i));
end
G0_data = k0 ./ (1 + 1j*omega'*tau0);

%% Calcolo errori
Err_add     = abs(Gp_data - G0_data);
Err_mult    = abs((Gp_data - G0_data) ./ G0_data);
Err_inv     = abs((Gp_data - G0_data) ./ Gp_data);

Err_add_env  = max(Err_add,  [], 2);
Err_mult_env = max(Err_mult, [], 2);
Err_inv_env  = max(Err_inv,  [], 2);

%% Fit con fitfrd
OrderWt = 2;
WI_add  = fitfrd(frd(Err_add_env,  omega), OrderWt);
WI_mult = fitfrd(frd(Err_mult_env, omega), OrderWt);
WI_inv  = fitfrd(frd(Err_inv_env,  omega), OrderWt);

%% Magnitudini pesi
WI_add_mag  = 20*log10(abs(squeeze(frd(WI_add,  omega).ResponseData)));
WI_mult_mag = 20*log10(abs(squeeze(frd(WI_mult, omega).ResponseData)));
WI_inv_mag  = 20*log10(abs(squeeze(frd(WI_inv,  omega).ResponseData)));

%% Plot confronto
figure;

subplot(3,1,1);
semilogx(omega, 20*log10(Err_add),  'b--'); hold on;
semilogx(omega, WI_add_mag, 'r-', 'LineWidth', 2);
grid on; ylabel('[dB]');
title('Additivo: |G_p - G_0|');
legend('Errore impianti', 'W_I(s)');

subplot(3,1,2);
semilogx(omega, 20*log10(Err_mult), 'b--'); hold on;
semilogx(omega, WI_mult_mag, 'r-', 'LineWidth', 2);
grid on; ylabel('[dB]');
title('Moltiplicativo: |G_p - G_0| / |G_0|');
legend('Errore relativo impianti', 'W_I(s)');

subplot(3,1,3);
semilogx(omega, 20*log10(Err_inv),  'b--'); hold on;
semilogx(omega, WI_inv_mag, 'r-', 'LineWidth', 2);
grid on; ylabel('[dB]'); xlabel('\omega [rad/s]');
title('Moltiplicativo inverso: |G_p - G_0| / |G_p|');
legend('Errore relativo impianti', 'W_I(s)');

%% Modelli di incertezza
s    = tf('s');
Gnom = tf(k0, [tau0 1]);
Delta_I = ultidyn('Delta', [1 1]);

Gu_add  = Gnom + WI_add * Delta_I;
Gu_mult = Gnom * (1 + WI_mult * Delta_I);
Gu_inv  = Gnom / (1 - WI_inv * Delta_I);