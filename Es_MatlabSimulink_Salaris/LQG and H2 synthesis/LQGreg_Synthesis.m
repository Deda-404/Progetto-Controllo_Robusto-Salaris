%% LQG regulator Controller: with and wothout integral action
%
% Plant: G(s) = 3*(-2s+1) / ((5s+1)(10s+1))
%
% Design steps:
%   1) State feedback regulator via LQR on augmented plant (with and without integrators)
%   2) Kalman filter on original plant (integrator states not estimated)
%   3) Controller realization

close all;
clear all;
clc;

%% =========================================================
%  PLANT MODEL AND DIMENSIONS
%% =========================================================
G = tf(3*[-2 1],conv([5 1],[10 1])); % original plant
[A,B,C,D] = ssdata(G); % plant realization is (a,b,c,d)
Plant = ss(A,B,C,D);
% Input, outpout and state dimensions:
p = size(C,1); % p: no. of outputs
[n,m] = size(B); % n: no. of states; m: no. of inputs
Znm = zeros(n,m); % n x m
Zmm = zeros(m,m); % m x m
Znn = zeros(n,n); % n x n
Zmn = zeros(m,n); % m x n
Znp = zeros(n,p); % n x p
Zpp = zeros(p,p); % p x p
Zpm = zeros(p,m); % p x m

%% LQG regulator 
WithIntegralAction = 1; % boolean to select WITH and WITHOUT integral action

if WithIntegralAction
%% =========================================================
%  CONTROLLER 1: LQG WITH INTEGRAL ACTION
%% =========================================================
%% State feedback regulator
Aa = [A Znp;C Zpp];         % augmented dynamic matrix Aa of the plant with integrators
Ba = [B;Zpm];               % augmented input matrix Ba of the plant with integrators
Q = [Znn Znm;Zmn eye(p)];   % weight only on integrated error
R = 0.01*eye(m);              % input weight
K_lqr = lqr(Aa,Ba,Q,R);     % optimal state-feedback regulator
Kr = K_lqr(:,1:n);          % m x n: extract state feedback
Kri = K_lqr(:,n+1:end);     % m x p extract integrator feedbacks

% LQR on augmented system via CARE
% [P2, ~, K_lqr] = care(Aa, Ba, Q, R);
% K_lqr = inv(R)*B'*P; % Explicitly
% Kr  = K_lqr(:, 1:n);
% Kri = K_lqr(:, n+1:end);

%% Kalman filter that doesn't estimate integrator states
% Bnoise = eye(n);         % process noise model (Gd)
% W = eye(size(Bnoise,2)); % process noise weight
% V = 1*eye(p);            % measurement noise weight
% Estss = ss(A,[B Bnoise],C,zeros(p,m+n));
% [kalmfss,Ke,P] = kalman(Estss,W,V); % Kalman filter gain

% Kalman via CARE (dual problem)
% [Sigma, ~, Kf1_T] = care(A', C', W, V);
% Ke = Kf1_T';    % n x p
% Ke = Sigma * C' / V; % Explicitly

Bnoise = B;                                 % actuation noise model (Gd)
W = 0.001*eye(m);                               % actuation noise weight
V = 0.001*eye(p);                               % measurement noise weight
Estss = ss(A,[B Bnoise],C,zeros(p,m+m));
[kalmfss,Ke,P] = kalman(Estss,W,V);           % Kalman filter gain

% Kalman via CARE (dual problem)
% [Sigma, ~, Kf1_T] = care(A', C', B*W*B', V);
% Ke = Kf1_T';    % n x p
% Ke = Sigma * C' / V; % Explicitly

%% IMPORTANT NOTE ON THE COMMAND LQG and H2SYN FOR THE AUGMENTED PLANT
% The lqg command requires the plant to be stabilizable and detectable.
% The augmented plant (with integrator on the output) has a pole at s=0
% which is not observable from Ca = [C, 0], hence not detectable.
% Therefore, lqg cannot be used directly on the augmented plant.
% The correct approach is to use lqi for the state and integral gains
% (Kr, Kri) and lqg on the original plant to extract the Kalman gain Kf,
% then build the controller realization manually with the integrator
% as an internal state of the controller, not estimated by the Kalman filter.

%% Form controller from y to u
Ac = [A - Ke*C - B*Kr,  -B*Kri;
      zeros(p,n),         Zpp  ];   % (n+p) x (n+p)
Bc = [Ke;                eye(p)];   % (n+p) x p
Cc = [-Kr,              -Kri   ];   % m x (n+p)
Dc = zeros(m,p);                    % m x p

K_lqg_int = ss(Ac, Bc, Cc, Dc);

%% =========================================================
%  CLOSED-LOOP SYSTEMS
%% =========================================================
CL = feedback(G,K_lqg_int,+1); % Feedback positivo perchè 
% il segno meno è già nel controllore K_lqg
% Stability check
ev = eig(CL.A);

%% =========================================================
%  SIMULATION: initial condition response
%% =========================================================
x0_plant = [1; 0];
t = 0:0.01:50;
initial(CL,[x0_plant; zeros(n,1); zeros(p,1)],t);
grid on

else
%% =========================================================
%  CONTROLLER 2: LQG WITHOUT INTEGRAL ACTION
%% =========================================================
%% Manual construction of the LQG regulator via LQR/KALMAN (or CARE)
%% State feedback regulator (uncomment this if you want to use LQR/KALMAN commands)
Q = eye(n);           % weight only on state error
R = 0.01*eye(m);        % input weight
K_lqr = lqr(A,B,Q,R); % optimal state-feedback regulator
Kr = K_lqr;

% LQR via CARE
% [P, ~, Kr] = care(A, B, Q, R);
% Kr = inv(R)*B'*P; % Explicitly

%% Kalman filter
% (uncomment this if you want to use process noise)
% Bnoise = eye(n);                         % process noise model (Gd)
% W = eye(size(Bnoise,2));                 % process noise weight
% V = 1*eye(p);                            % measurement noise weight
% Estss = ss(A,[B Bnoise],C,zeros(p,m+n));
% [kalmfss,Ke,P] = kalman(Estss,W,V);      % Kalman filter gain

% Kalman via CARE (dual problem)
% [Sigma, ~, Kf1_T] = care(A', C', W, V);  % Kalman gain via CARE
% Ke = Kf1_T';                             % n x p
% Ke = Sigma * C' / V;                     % Explicitly

% (uncomment this if you want to use actuation noise)
Bnoise = B;                              % actuation noise model (Gd)
W = 0.001*eye(m);                            % actuation noise weight
V = 0.001*eye(p);                            % measurement noise weight
Estss = ss(A,[B Bnoise],C,zeros(p,m+m));
[kalmfss,Ke,P] = kalman(Estss,W,V);      % Kalman filter gain

% Kalman via CARE (dual problem)
% [Sigma, ~, Kf1_T] = care(A', C', B*W*B', V); % Kalman gain via CARE
% Ke = Kf1_T';                             % n x p
% Ke = Sigma * C' / V;                     % Explicitly

%% Form controller from y to u
Ac = A - Ke*C - B*Kr; % n x n
Bc = Ke;   % n x p
Cc = -Kr;   % m x n
Dc = zeros(m,p);   % m x p

K_lqg = ss(Ac, Bc, Cc, Dc);

%% LQG controller via lqg command (uncomment this if you want to use LQG command)
% Q = eye(n);                 % weight only on state error
% R = 100*eye(m);             % input weight
% Bnoise = eye(n);            % process noise model (Gd)
% W = eye(size(Bnoise,2));    % process noise weight
% V = 1*eye(p);               % measurement noise weight
% 
% K_lqg = lqg(Plant, blkdiag(Q,R), blkdiag(W,V));

%% LQG controller via h2syn (uncomment this if you want to use h2syn command)
% Q = eye(n);              % weight only on state error
% R = 100*eye(m);          % input weight
% Bnoise = eye(n);         % process noise model (Gd)
% W = eye(size(Bnoise,2)); % process noise weight
% W = 1*eye(m);            % actuation noise weight
% V = 1*eye(p);            % measurement noise weight

% sqrtQ  = sqrtm(Q);
% sqrtR  = sqrtm(R);
% sqrtW = sqrtm(W);
% sqrtV = sqrtm(V);
% 
% %  Generalized plant P(s)
% B1  = [sqrtW,      zeros(n,p)];   % n x (n+p) - process noise
% % B1  = [B*sqrtW,      zeros(n,p)];   % n x (n+p) - actuation noise
% B2  = B;                            % n x m
% 
% C1  = [sqrtQ;      zeros(m,n)];    % (n+m) x n
% D11 = zeros(n+m,   n+p);           % (n+m) x (n+p) - process noise
% % D11 = zeros(n+m,   m+p);           % (n+m) x (n+p) - actuation noise
% D12 = [zeros(n,m); sqrtR      ];   % (n+m) x m
% 
% C2  = C;                            % p x n
% D21 = [zeros(p,n), sqrtV     ];   % p x (n+p) - process noise
% % D21 = [zeros(p,m), sqrtV     ];   % p x (n+p) - actuation noise
% D22 = zeros(p,m);                   % p x m
% 
% P = ss(A, [B1, B2], [C1; C2], [D11, D12; D21, D22]);
% 
% [K_lqg, ~, gamma] = h2syn(P, p, m);

%% =========================================================
%  CLOSED-LOOP SYSTEMS
%% =========================================================
CL = feedback(G,K_lqg,+1); % Feedback positivo perchè 
% il segno meno è già nel controllore K_lqg
% Stability check
ev = eig(CL.A);

%% =========================================================
%  SIMULATION: initial condition response
%% =========================================================
x0_plant = [1; 0];
t = 0:0.01:50;
initial(CL,[x0_plant; zeros(n,1)],t);
% initial(CL,[x0_plant; x0_plant],t); % uncomment this if you want
% xhat0_plant = x0_plant (The kalman filter is initialized with the actual state value)
grid on
end


