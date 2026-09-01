%% Mixed-Sensitivity H-infinity Synthesis: MIMO System
%
% Plant: G(s) = 1/((0.2s+1)(s+1)) * [1,    1   ]
%                                     [1+2s, 2   ]
%
% Design objective: minimize ||[WP*S; Wu*KS]||_inf < gamma
%
% Three designs compared (different bandwidths wB1, wB2):
%   Design 1: wB1 = wB2 = wB        (symmetric)
%   Design 2: wB1 = wB,  wB2 = 100*wB  (channel 2 faster)
%   Design 3: wB1 = 100*wB, wB2 = wB   (channel 1 faster)

clear all; close all; clc;

s = tf('s');

%% =========================================================
%  MIMO PLANT
%% =========================================================
G = 1/(0.2*s+1)/(s+1) * [1,     1;
                           1+2*s, 2];

% Transmission poles and zeros
Poles_MIMO = pole(G);
Zeros_MIMO = tzero(G);
z_nmp      = Zeros_MIMO(real(Zeros_MIMO) > 0);   % NMP zero (real part > 0)
z_nmp      = z_nmp(1);                            % take first NMP zero

fprintf('Transmission poles:\n'); disp(Poles_MIMO);
fprintf('Transmission zeros:\n'); disp(Zeros_MIMO);
fprintf('NMP zero: %.4f\n', z_nmp);

%% =========================================================
%  PLANT DIRECTIONALITY ANALYSIS
%
%  For MIMO systems, the step response depends on the
%  input direction. We analyze:
%    1) Canonical input directions [1;0] and [0;1]
%    2) The direction of the non-minimum phase zero
%
%  The SVD of G(z) at the transmission zero z = 0.5 gives:
%    G(z) = U * S * V'
%  The right singular vector V(:,end) associated with the
%  smallest singular value is the input direction most
%  affected by the NMP zero -> worst-case direction.
%% =========================================================

% Step response along canonical input directions
figure('Name','Step Response: Canonical Directions','Position',[50 50 900 400]);
subplot(1,2,1);
step(G * [1; 0]); title('Input direction [1; 0]'); grid on;
subplot(1,2,2);
step(G * [0; 1]); title('Input direction [0; 1]'); grid on;

% SVD at the NMP transmission zero
Gzero         = evalfr(G, z_nmp);       % evaluate G at NMP zero
[U, S_svd, V] = svd(Gzero);

fprintf('SVD of G at NMP zero z = %.4f:\n', z_nmp);
fprintf('Singular values: %.4f, %.4f\n', S_svd(1,1), S_svd(2,2));
fprintf('Worst-case input direction V(:,2):\n'); disp(V(:,2));

% Step response along worst-case (NMP) direction
figure('Name','Step Response: NMP Direction','Position',[50 50 700 400]);
step(G * V(:,2));
title(sprintf('Step along NMP zero direction (z = %.4f)', z_nmp));
grid on;

%% =========================================================
%  PERFORMANCE AND CONTROL WEIGHTS
%
%  WP = blkdiag(wP1, wP2): diagonal weight matrix on S
%    wPi = (s/M + wBi) / (s + wBi*A)
%    - A:   max |S| at low frequency  (steady-state tracking)
%    - M:   max |S| peak              (robustness)
%    - wBi: desired bandwidth of channel i
%
%  Wu = blkdiag(wu, wu): diagonal weight matrix on KS
%    wu = 1 (no specific constraint on control effort)
%
%  Different wB1, wB2 allow asymmetric bandwidth design:
%    Design 1: symmetric        (wB1 = wB2 = wB)
%    Design 2: channel 2 faster (wB2 = 100*wB)
%    Design 3: channel 1 faster (wB1 = 100*wB)
%
%  Bandwidth wB chosen as half the NMP zero frequency
%  to avoid exciting the non-minimum phase dynamics.
%% =========================================================
A  = 1e-4;               % low-frequency bound on S
M  = 1.5;                % sensitivity peak bound
wB = real(z_nmp) / 2;   % bandwidth: half of NMP zero frequency

wu = 1;
Wu = blkdiag(wu, wu);   % control effort weight matrix (2x2)

% --- Select design (uncomment one) ---

% Design 1: symmetric bandwidth
% wB1 = wB;  wB2 = wB;

% Design 2: channel 2 faster than channel 1
wB1 = wB;   wB2 = 100*wB;

% Design 3: channel 1 faster than channel 2
% wB1 = 100*wB;  wB2 = wB;

% Sensitivity weights
wP1 = (s/M + wB1) / (s + wB1*A);   % weight for channel 1
wP2 = (s/M + wB2) / (s + wB2*A);   % weight for channel 2
WP  = blkdiag(wP1, wP2);           % diagonal weight matrix

fprintf('Design bandwidths: wB1 = %.2f, wB2 = %.2f rad/s\n', wB1, wB2);

%% =========================================================
%  H-INFINITY SYNTHESIS via mixsyn()
%
%  Solves: min_K ||[WP*S; Wu*KS]||_inf
%  where:
%    S  = (I + G*K)^-1    output sensitivity matrix
%    KS = K*(I + G*K)^-1  control sensitivity matrix
%% =========================================================
[K, CL, gamma, ~] = mixsyn(G, WP, Wu, []);
K  = zpk(K);

fprintf('\nAchieved H-inf norm gamma = %.4f\n', gamma);
fprintf('Controller order: %d\n', order(K));

% Closed-loop sensitivity functions
S_cl  = inv(eye(2) + G*K);     % output sensitivity   (I+GK)^-1
KS_cl = K * inv(eye(2) + G*K); % control sensitivity  K*(I+GK)^-1
T_cl  = G*K * inv(eye(2)+G*K); % comp. sensitivity    GK*(I+GK)^-1

%% =========================================================
%  PERFORMANCE VERIFICATION: Singular Value Plots
%
%  Design is satisfied if:
%    sigma_max(S)  < sigma_min(1/WP)  for all w
%    sigma_max(KS) < sigma_min(1/Wu)  for all w
%% =========================================================

% Sensitivity S vs bound 1/WP
figure('Name','Sensitivity vs Bound','Position',[50 50 700 450]);
sigmaplot(zpk(inv(WP)), zpk(minreal(S_cl)));
legend('1/W_P (performance bound)', '\sigma(S) (achieved)');
title('Sensitivity S: achieved vs bound 1/W_P'); grid on;

% Control sensitivity KS vs bound 1/Wu
figure('Name','Control Sensitivity vs Bound','Position',[50 50 700 450]);
sigmaplot(zpk(inv(Wu)), zpk(minreal(KS_cl)));
legend('1/W_u (control bound)', '\sigma(KS) (achieved)');
title('Control sensitivity KS: achieved vs bound 1/W_u'); grid on;

%% =========================================================
%  PERFORMANCE VERIFICATION: H-infinity norms
%
%  Design requirements satisfied if:
%    ||WP * S||_inf  < 1   (sensitivity performance)
%    ||Wu * KS||_inf < 1   (control effort performance)
%
%  Individual channel norms also computed to identify
%  which channel is most critical.
%% =========================================================

%% =========================================================
%  PERFORMANCE VERIFICATION: H-infinity norms
%
%  Design requirements satisfied if:
%    ||WP * S||_inf  < 1   (sensitivity performance)
%    ||Wu * KS||_inf < 1   (control effort performance)
%
%  Individual channel norms also computed to identify
%  which channel is most critical.
%% =========================================================

% --- Global H-inf norms (MIMO) ---
[norm_WPS,  w_peak_WPS ] = hinfnorm(minreal(WP  * S_cl));
[norm_WuKS, w_peak_WuKS] = hinfnorm(minreal(Wu  * KS_cl));

fprintf('\n=== H-infinity Performance Norms ===\n');
fprintf('||WP*S||_inf   = %.4f  (peak at w = %.2f rad/s)  %s\n', ...
        norm_WPS,  w_peak_WPS,  check(norm_WPS));
fprintf('||Wu*KS||_inf  = %.4f  (peak at w = %.2f rad/s)  %s\n', ...
        norm_WuKS, w_peak_WuKS, check(norm_WuKS));
fprintf('gamma (mixsyn) = %.4f\n', gamma);

% --- Individual channel norms ---
fprintf('\n=== Individual Channel Norms ===\n');
for i = 1:2
    for j = 1:2
        [n_wps,  ~] = hinfnorm(minreal(WP(i,i)  * S_cl(i,j)));
        [n_wuks, ~] = hinfnorm(minreal(Wu(i,i)  * KS_cl(i,j)));
        fprintf('||wP%d*S(%d,%d)||_inf  = %.4f   ||wu%d*KS(%d,%d)||_inf = %.4f\n', ...
                i,i,j, n_wps, i,i,j, n_wuks);
    end
end

%% =========================================================
%  CLOSED-LOOP STEP RESPONSE (NMP direction)
%
%  We evaluate the closed-loop response along the worst-case
%  input direction V(:,2) identified by the SVD analysis.
%% =========================================================
v_nmp = V(:,2);   % worst-case input direction

t = 0:0.01:30;
r_nmp = ones(length(t),1) * v_nmp';    % N x 2 input along NMP direction

[y_out, t_out] = lsim(minreal(zpk(T_cl)),  r_nmp, t);   % output y
[u_out, ~    ] = lsim(minreal(zpk(KS_cl)), r_nmp, t);   % control u

figure('Name','Closed-Loop Response: NMP Direction','Position',[50 50 900 600]);

subplot(2,1,1);
plot(t_out, y_out, 'LineWidth', 1.5); hold on;
yline(v_nmp(1), 'k--'); yline(v_nmp(2), 'b--');
xlabel('t [s]'); ylabel('y(t)');
legend('y_1','y_2','r_1 ref','r_2 ref');
title(sprintf('Output y: step along NMP direction (z = %.4f)', z_nmp));
grid on;

subplot(2,1,2);
plot(t_out, u_out, 'LineWidth', 1.5);
yline(0,'k--','LineWidth',1);
xlabel('t [s]'); ylabel('u(t)');
legend('u_1','u_2');
title('Control effort u');
grid on;

sgtitle('Closed-Loop Step Response: NMP Direction','FontSize',13);

%% =========================================================
%  HELPER FUNCTION
%% =========================================================
%  HELPER FUNCTION
%% =========================================================
function s = check(n)
    if n < 1
        s = '<-- OK (< 1)';
    else
        s = '<-- VIOLATED (> 1)';
    end
end

% % Output y: r -> y along NMP direction
% figure('Name','CL Step: Output','Position',[50 50 700 400]);
% step(minreal(zpk(T_cl)) * v_nmp);
% title('Closed-loop step response: r \rightarrow y (NMP direction)');
% grid on;
% 
% % Control effort u: r -> u along NMP direction
% figure('Name','CL Step: Control','Position',[50 50 700 400]);
% step(minreal(zpk(KS_cl)) * v_nmp);
% title('Closed-loop control effort: r \rightarrow u (NMP direction)');
% grid on;