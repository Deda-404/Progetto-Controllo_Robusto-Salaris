% Sistema MIMO 2 ingressi, 2 uscite
% Fisicamente: sistema meccanico accoppiato

A = [-1   0.5   0    0;
     -0.5 -1    0    0;
      0    0   -2    1;
      0    0   -1   -3];

B = [1  0;
     0  1;
     1  1;
     0  1];

C = [1  0  1  0;
     0  1  0  1];

D = zeros(2,2);  % strettamente proprio -> H2 finita

sys = ss(A, B, C, D);

% Dimensioni
[p, m] = size(D);  % p=2 uscite, m=2 ingressi
n = size(A, 1);    % n=4 stati

fprintf('Sistema MIMO: %d ingressi, %d uscite, %d stati\n', m, p, n);

%% NORMA H2
%% Calcolo con MATLAB
% Norma H2 diretta
n2 = norm(sys, 2);
fprintf('Norma H2 = %.6f\n', n2);


%% Calcolo manuale via Gramiano di osservabilità
% Lyapunov per Wo
Wo = lyap(A', C'*C);

n2_manual = sqrt(trace(B' * Wo * B));
fprintf('Norma H2 (Gramiano Wo) = %.6f\n', n2_manual);
fprintf('Differenza             = %.2e\n', abs(n2 - n2_manual));

%% Calcolo manuale via Gramiano di raggiungibilità
Wc = lyap(A, B*B');

n2_manual2 = sqrt(trace(C * Wc * C'));
fprintf('Norma H2 (Gramiano Wc) = %.6f\n', n2_manual2);

%% Contributo per canale
fprintf('\nNorma H2 per singolo canale i/o:\n');
for i = 1:p
    for j = 1:m
        sys_ij = ss(A, B(:,j), C(i,:), D(i,j));
        fprintf('  G(%d,%d): H2 = %.4f\n', i, j, norm(sys_ij, 2));
    end
end

% Verifica: norma totale vs somma quadratica dei canali
n2_check = 0;
for i = 1:p
    for j = 1:m
        sys_ij = ss(A, B(:,j), C(i,:), D(i,j));
        n2_check = n2_check + norm(sys_ij, 2)^2;
    end
end
fprintf('\n||G||_2^2 totale      = %.6f\n', n2^2);
fprintf('Somma ||G_ij||_2^2    = %.6f\n', n2_check);
fprintf('Coerenza              = %.2e\n', abs(n2^2 - n2_check));

%% NORMA Hinf

%% Calcolo con MATLAB
% Norma Hinf diretta
ninf = norm(sys, inf);
fprintf('Norma Hinf = %.6f\n', ninf);

%% Calcolo manuale via sigma plot
omega = logspace(-3, 3, 10000);

% Valori singolari della risposta in frequenza
sv = sigma(sys, omega);  % sv(k,:) = k-esimo valore singolare

% Norma Hinf = massimo del valore singolare massimo
ninf_manual = max(sv(1,:));
fprintf('Norma Hinf (sigma)  = %.6f\n', ninf_manual);
fprintf('Differenza          = %.2e\n', abs(ninf - ninf_manual));

%% Calcolo via Hamiltoniana MIMO
% Bisezione su gamma
gamma_low  = 0;
gamma_high = 100;
tol        = 1e-6;

while (gamma_high - gamma_low) > tol
    gamma = (gamma_low + gamma_high) / 2;

    % Hamiltoniana MIMO
    H_mat = [A,      (1/gamma^2)*(B*B');
            -C'*C,   -A'               ];

    % Autovalori
    eig_H = eig(H_mat);

    % Autovalori su j*R?
    on_axis = any(abs(real(eig_H)) < 1e-8);

    if on_axis
        gamma_low  = gamma;
    else
        gamma_high = gamma;
    end
end

fprintf('Norma Hinf (Hamiltoniana) = %.6f\n', gamma_high);


%% Visualizzazione MIMO
figure;

% Sigma plot con norma Hinf
subplot(2,1,1);
sigma(sys, omega);
hold on;
yline(20*log10(ninf), 'r--', ...
    sprintf('||G||_{\\infty} = %.3f dB', 20*log10(ninf)), ...
    'LineWidth', 2);
title('Sigma plot — valori singolari di G(j\omega)');
legend(arrayfun(@(k) sprintf('\\sigma_%d', k), ...
    1:min(p,m), 'UniformOutput', false));
grid on;

% Autovalori Hamiltoniana al variare di gamma
subplot(2,1,2);
gammas = linspace(0.5*ninf, 2*ninf, 300);
min_real_part = zeros(size(gammas));

for k = 1:length(gammas)
    g = gammas(k);
    H_mat = [A, (1/g^2)*(B*B'); -C'*C, -A'];
    ev = eig(H_mat);
    min_real_part(k) = min(abs(real(ev)));
end

plot(gammas, min_real_part, 'b', 'LineWidth', 1.5);
xline(ninf, 'r--', ...
    sprintf('||G||_\\infty = %.3f', ninf), ...
    'LineWidth', 1.5);
xlabel('\gamma');
ylabel('min_i |Re(\lambda_i(H))|');
title('Hamiltoniana: il minimo tocca zero per \gamma = ||G||_\infty');
grid on;

%% Confronto SISO vs MIMO
% A differenza della norma H2H_2
% H2​, la norma H∞H_\infty H∞​ MIMO
% non è la somma dei contributi dei canali. 
% Il massimo valore singolare cattura le 
% interazioni tra canali — un effetto puramente 
% MIMO che non si vede guardando i canali 
% separatamente.
fprintf('\n--- Confronto canali singoli vs sistema MIMO ---\n');
fprintf('\nNorma Hinf per singolo canale i/o:\n');

ninf_max_channel = 0;
for i = 1:p
    for j = 1:m
        sys_ij  = ss(A, B(:,j), C(i,:), D(i,j));
        ninf_ij = norm(sys_ij, inf);
        fprintf('  G(%d,%d): Hinf = %.4f\n', i, j, ninf_ij);
        ninf_max_channel = max(ninf_max_channel, ninf_ij);
    end
end

fprintf('\n||G||_inf MIMO                = %.6f\n', ninf);
fprintf('max_ij ||G_ij||_inf           = %.6f\n', ninf_max_channel);
fprintf('\nNota: ||G||_inf >= max_ij ||G_ij||_inf sempre\n');