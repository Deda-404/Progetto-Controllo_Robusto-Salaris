%% Mixed-Sensitivity H-infinity Synthesis
%
% Plant:      G(s)  = 200 / ((10s+1)(0.05s+1)^2)
% Disturbance Gd(s) = 100 / (10s+1)
%
% Performance weights:
%   wP: shapes sensitivity S = (1+KG)^-1  -> tracking and disturbance rejection
%   wu: shapes control sensitivity KS     -> control effort limitation
%
% Design objective: minimize ||[wP*S; wu*K*S]||_inf < gamma

clear all; close all; clc;

%% =========================================================
%  PLANT AND DISTURBANCE MODEL
%% =========================================================
s  = tf('s');
G  = 200 / ((10*s+1) * (0.05*s+1)^2);   % plant
Gd = 100 / (10*s+1);                     % disturbance model

%% =========================================================
%  PERFORMANCE WEIGHTS
%
%  wP shapes the sensitivity function S = (1+KG)^-1:
%    - Low frequency: |S(jw)| < 1/|wP(jw)| ~ A  (disturbance rejection)
%    - Bandwidth:     crossover at wB             (tracking speed)
%    - High frequency: |S| < 1/|wP| ~ M          (peak bound)
%
%  Chosen as first-order weight: wP = (s/M + wB) / (s + wB*A)
%    - At w=0:   |wP| ~ wB/wB*A = 1/A  -> |S| < A  (good rejection)
%    - At w=wB:  |wP| ~ 1               -> |S| < 1  (crossover)
%    - At w=inf: |wP| ~ 1/M             -> |S| < M  (peak constraint)
%
%  wu shapes the control sensitivity KS:
%    - Here wu = 1 (no specific constraint on control effort)
%% =========================================================
M  = 1.5;    % maximum allowed peak of S (sensitivity peak)
wB = 10;     % desired bandwidth [rad/s]
A  = 1e-3;   % maximum allowed |S| at low frequency (steady-state error)

% --- First-order weight ---
wP1 = (s/M + wB) / (s + wB*A);

% --- Second-order weight ---
% wP2 = (s/sqrt(M) + wB)^2 / (s + wB*sqrt(A))^2;

% --- makeweight (first-order, equivalent to wP1) ---
% wP_mw = makeweight(1/A, [wB, 1], 1/M, 0, 1);

% Select weight to use
wP = wP1;   % change to wP2 or wP_mw to compare

wu = tf(1);  % control effort weight (unconstrained)

% Compare weights
figure('Name','Weight Comparison','Position',[50 50 700 400]);
bodemag(wP1, wP2, wP_mw);
legend('wP 1st order','wP 2nd order','wP makeweight');
title('Comparison of sensitivity weights w_P'); grid on;

%% =========================================================
%  GENERALIZED PLANT P(s) via connect()
%
%  Exogenous inputs:  w = [d; r]   (disturbance, reference)
%  Control input:     u
%  Regulated outputs: z = [z1; z2] (wP*e, wu*u)
%  Measured output:   e = r - y    (tracking error, fed to controller)
%
%  Signal flow:
%    y   = G*u + Gd*d
%    e   = r - y
%    z1  = wP * e
%    z2  = wu * u
%% =========================================================

% Assign signal names for connect()
G.u  = 'u';    G.y  = 'y_G';
Gd.u = 'd';    Gd.y = 'y_Gd';
wP.u = 'e';    wP.y = 'z1';
wu.u = 'u';    wu.y = 'z2';

S1 = sumblk('y = y_G + y_Gd');    % plant output: y = G*u + Gd*d
S2 = sumblk('e = r - y');         % tracking error: e = r - y

% Generalized plant: inputs [d; r; u], outputs [z1; z2; e]
P    = connect(G, Gd, wP, wu, S1, S2, {'d','r','u'}, {'z1','z2','e'});
Pzpk = minreal(zpk(P), 1e-4);     % minimal realization in zpk form

fprintf('Generalized plant order: %d\n', order(P));

%% =========================================================
%  H-INFINITY SYNTHESIS via mixsyn()
%
%  mixsyn() solves: min_K ||[wP*S; wu*K*S]||_inf
%  and returns:
%    K:     optimal H-inf controller
%    CL:    closed-loop system [wP*S; wu*K*S]
%    gamma: achieved H-inf norm (should be close to 1 for well-posed design)
%% =========================================================
[K, CL, gamma, info] = mixsyn(G, wP, wu, []);
K  = zpk(K);     % convert to zpk for readability
CL = zpk(CL); % Only between r and y

fprintf('Achieved H-inf norm gamma = %.4f\n', gamma);
fprintf('Controller order: %d\n', order(K));

% Verification via lft (should match CL)
CL_lft = lft(Pzpk, K, 1, 1); % both between r and y and between d to y

% Manual computation (should match CL_lft)
CL_sens = loopsens(G, K);

S_cl   = CL_sens.So;    % output sensitivity      1/(1+KG)
T_cl   = CL_sens.To;    % comp. sensitivity        KG/(1+KG)
KS_cl  = CL_sens.CSo;   % control sensitivity      K/(1+KG)
GS_cl  = CL_sens.PSi;   % plant input sensitivity  G/(1+KG)

CL_manual = zpk(minreal(...
    [-wP*S_cl*Gd,   wP*S_cl;
     -wu*KS_cl*Gd,  wu*KS_cl]));

%% =========================================================
%  CLOSED-LOOP TRANSFER FUNCTIONS
%% =========================================================
S_cl  = 1 / (1 + K*G);     % sensitivity:         e/r
T_cl  = K*G / (1+K*G);     % complementary sens.: y/r
KS_cl = K / (1+K*G);       % control sensitivity: u/r

% H-inf norms of weighted functions
[norm_wPS,  w_peak_S ] = hinfnorm(wP * S_cl);
[norm_wuKS, w_peak_KS] = hinfnorm(wu * KS_cl);

fprintf('\n||wP*S||_inf  = %.4f (peak at w = %.2f rad/s)\n', norm_wPS,  w_peak_S);
fprintf('||wu*KS||_inf = %.4f (peak at w = %.2f rad/s)\n', norm_wuKS, w_peak_KS);

%% =========================================================
%  PLOTS
%% =========================================================
t = 0:0.01:10;

% --- Step response to reference r ---
figure('Name','Step Response: Reference','Position',[50 50 700 350]);
step(T_cl, t);
title('Step Response (reference r \rightarrow output y)'); grid on;

% --- Step response to disturbance d ---
figure('Name','Step Response: Disturbance','Position',[50 50 700 350]);
step(Gd * S_cl, t);
title('Step Response (disturbance d \rightarrow output y)'); grid on;

% --- Control effort for step reference ---
figure('Name','Control Effort','Position',[50 50 700 350]);
step(KS_cl, t);
title('Control Effort (reference r \rightarrow input u)'); grid on;

% --- Sensitivity S vs 1/wP ---
figure('Name','Sensitivity','Position',[50 50 700 400]);
bodemag(S_cl, 1/wP);
legend('S = (1+KG)^{-1}', '1/w_P (upper bound)');
title('Sensitivity S vs performance bound 1/w_P'); grid on;

% --- Control sensitivity KS vs 1/wu ---
figure('Name','Control Sensitivity','Position',[50 50 700 400]);
bodemag(KS_cl, tf(1/wu));
legend('KS', '1/w_u (upper bound)');
title('Control sensitivity KS vs bound 1/w_u'); grid on;