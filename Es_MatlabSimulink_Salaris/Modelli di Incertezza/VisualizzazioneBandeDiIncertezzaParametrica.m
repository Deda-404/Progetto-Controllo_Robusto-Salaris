% =========================================================
% Piano di Nyquist - aree di incertezza parametrica
% G_p(s) = k/(tau*s+1) * exp(-theta*s)
% con k, tau, theta in [2, 3]  (incertezza bounded)
% =========================================================

clear; clc; close all;   % pulisce workspace, command window e figure aperte

%% --- Parametri nominali ---
k0 = 2.5; tau0 = 2.5; theta0 = 2.5;  % centro dell'ipercubo parametrico

%% --- Campionamento Monte Carlo ---
N = 2000;   % numero di realizzazioni casuali dei parametri
rng(42);    % fissa il seme del generatore casuale (risultati riproducibili)

% Valori di omega per cui si vuole tracciare l'area di incertezza
omega_plot = [0.01, 0.05, 0.1, 0.2, 0.3, 0.5, 1.0, 3.0, 10.0];  % [rad/s]

% Colori distinti per ogni valore di omega (una riga = un colore RGB)
cmap = lines(length(omega_plot));

% Campiona N triple (k, tau, theta) uniformemente in [2,3]^3
% rand(N,1) genera N numeri in [0,1]; moltiplicare per 1 e sommare 2
% mappa l'intervallo [0,1] -> [2,3]
K_vec     = 2 + rand(N,1);   % guadagni casuali
tau_vec   = 2 + rand(N,1);   % costanti di tempo casuali
theta_vec = 2 + rand(N,1);   % ritardi casuali

%% --- Funzione di trasferimento in frequenza ---
% Geval calcola G(j*omega) per scalari o vettori di parametri
% Il simbolo @ definisce una funzione anonima (lambda)
% Operatori ./ e .* operano elemento per elemento su vettori/matrici
Geval = @(k, tau, theta, w) ...
    (k ./ (1 + 1j*w.*tau)) .* exp(-1j*w.*theta);
%   \_____primo ordine_____/   \____ritardo puro____/
%   modulo: k/sqrt(1+(w*tau)^2)
%   fase:   -atan(w*tau) - w*theta

%% --- Figura ---
figure('Color','w', 'Position',[100 100 800 650]);
hold on;    % sovrappone i plot successivi senza cancellare i precedenti
grid on;    % griglia di sfondo
axis equal; % stessa scala su asse reale e immaginario (cerchi restano cerchi)

%% --- Curva nominale (tratto continuo) ---
omega_fine = logspace(-2, 2, 500);  % 500 punti da 0.01 a 100 rad/s (scala log)

% Calcola G_nom(j*omega) per tutti i 500 valori di frequenza
G_nom_curve = Geval(k0, tau0, theta0, omega_fine);

% Traccia la curva nominale in nero
% real() e imag() estraggono parte reale e immaginaria punto per punto
plot(real(G_nom_curve), imag(G_nom_curve), 'k-', 'LineWidth', 1.5, ...
     'DisplayName', 'Curva nominale');

%% --- Aree di incertezza per ogni omega fissato ---
for i = 1:length(omega_plot)
    w = omega_plot(i);   % frequenza corrente [rad/s]

    % Calcola G(j*w) per tutti gli N campioni parametrici
    % K_vec, tau_vec, theta_vec sono vettori Nx1 -> G_all è un vettore Nx1 complesso
    G_all = Geval(K_vec, tau_vec, theta_vec, w);

    % Separa parte reale e immaginaria: ogni coppia (re,im) è un punto nel piano di Nyquist
    re = real(G_all);
    im = imag(G_all);

    % convhull trova gli indici dei punti che formano l'inviluppo convesso
    % della nuvola di N punti nel piano (re, im).
    % L'inviluppo convesso è il poligono più piccolo che contiene tutti i punti.
    idx = convhull(re, im);

    % patch disegna il poligono dell'inviluppo convesso come area colorata
    % re(idx), im(idx): vertici del poligono nell'ordine restituito da convhull
    % FaceAlpha: trasparenza del riempimento (0=trasparente, 1=opaco)
    % EdgeColor: colore del bordo del poligono
    patch(re(idx), im(idx), cmap(i,:), ...
          'FaceAlpha', 0.25, 'EdgeColor', cmap(i,:), 'LineWidth', 1.2, ...
          'DisplayName', sprintf('\\omega = %.1f rad/s', w));

    % Calcola e traccia il punto nominale G_nom(j*w)
    g0 = Geval(k0, tau0, theta0, w);
    plot(real(g0), imag(g0), 'o', ...
         'MarkerFaceColor', cmap(i,:), ...  % cerchio pieno del colore dell'area
         'MarkerEdgeColor', 'k', ...        % bordo nero per visibilità
         'MarkerSize', 7, ...
         'HandleVisibility', 'off');        % non compare in legenda

    % Etichetta testuale accanto al punto nominale
    text(real(g0), imag(g0), sprintf('  \\omega=%.1f', w), ...
         'FontSize', 9, 'Color', cmap(i,:)*0.7, ...  % colore leggermente più scuro
         'HandleVisibility', 'off');
end

%% --- Punto critico (-1, 0) ---
% Il punto (-1,0) è critico per la stabilità (criterio di Nyquist):
% se la curva lo circonda, il sistema in anello chiuso è instabile
plot(-1, 0, 'rx', 'MarkerSize', 12, 'LineWidth', 2.5, ...
     'DisplayName', 'Punto critico (-1,0)');

%% --- Assi di riferimento ---
xline(0, 'k:', 'LineWidth', 0.5, 'HandleVisibility', 'off');  % asse immaginario
yline(0, 'k:', 'LineWidth', 0.5, 'HandleVisibility', 'off');  % asse reale

%% --- Etichette e legenda ---
xlabel('Re[G_p(j\omega)]');
ylabel('Im[G_p(j\omega)]');
title('Bande di incertezza - Piano di Nyquist');
legend('Location', 'best');  % posiziona la legenda automaticamente