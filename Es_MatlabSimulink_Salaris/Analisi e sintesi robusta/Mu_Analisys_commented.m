%% =========================================================================
%  Mu-analysis for the distillation process
%  Regulation problem with output disturbance
%
%  Script outline:
%    1.  Nominal model G(s)
%    2.  Uncertainty weight WI (multiplicative input uncertainty)
%    3.  Performance weight Wp (weighted sensitivity)
%    4.  Generalized plant P (via connect)
%    5.  Controller K (inverse-based)
%    6.  N-Delta structure (lower LFT) and perturbed model Np
%    7.  Nominal Stability   (NS)
%    8.  Nominal Performance (NP)
%    9.  Robust Stability    (RS)
%   10.  Robust Performance  (RP)
%   11.  Summary and plot
%
%  Required toolbox: Robust Control Toolbox
% =========================================================================
clear all
close all
clc

%% =========================================================================
%  1. NOMINAL MODEL
% =========================================================================
% Wood-Berry distillation column: 2x2 MIMO system.
% G0 is the DC gain matrix (static gains).
% The pole at 1/tau captures the first-order dynamics common to all channels.
% Time unit: minutes [min].

tau = 75;                       % process time constant [min]
G0  = [87.8  -86.4;             % DC gain: channels (1,1) and (1,2)
       108.2 -109.6];           % DC gain: channels (2,1) and (2,2)

G = tf(1,[tau 1]) * G0;         % nominal model: G(s) = G0 / (tau*s + 1)
% G is 2x2: 2 outputs (compositions), 2 inputs (reflux/vapour flow rates)

%% =========================================================================
%  2. INPUT UNCERTAINTY WEIGHT WI
% =========================================================================
% Uncertainty is modelled as multiplicative input uncertainty:
%   G_pert(s) = G(s) * (I + WI(s) * Delta_I)
% where Delta_I is a diagonal block with ||Delta_i||_inf <= 1.
%
% WI(s) = (s + 0.2) / (0.5*s + 1) * I_2:
%   - low frequency:  |WI(0)|   = 0.2  ->  20% uncertainty at DC
%   - high frequency: |WI(inf)| = 2    -> 200% uncertainty
% This models frequency-growing uncertainty, typical of unmodelled dynamics
% (actuators, neglected delays, etc.).
%
% The uncertainty is STRUCTURED (diagonal): Delta = diag(Delta_1, Delta_2),
% which is more realistic than a full block Delta_I in C^{2x2}.

WI = tf([1 0.2],[0.5 1]) * eye(2);  % uncertainty weight (same on both inputs)

%% =========================================================================
%  3. PERFORMANCE WEIGHT Wp
% =========================================================================
% Weight on the weighted sensitivity: z = Wp * e, where e = w - y is the error.
% Nominal performance objective: ||Wp * S||_inf < 1.
%
% Wp(s) = 0.5 * (10*s + 1) / (10*s + 1e-5) * I_2:
%   - low frequency:  |Wp(0)| >> 1  -> high disturbance attenuation at DC
%     (the pole at 1e-5 approximates a pure integrator)
%   - high frequency: |Wp(inf)| = 0.5 -> relaxed requirement
%
% The factor 0.5 means: ||Wp*S||_inf < 1  <=>  ||S||_inf < 2 (unweighted).

Wp = 0.5 * tf([10 1],[10 1e-5]) * eye(2);  % performance weight

%% =========================================================================
%  4. GENERALIZED PLANT P
% =========================================================================
% P embeds the nominal model, the uncertainty weight, and the performance weight.
%
% Signals:
%   ud : perturbation from Delta at the input of G   (channel to Delta)
%   w  : output disturbance (reference / regulation disturbance)
%   u  : control input
%   yd : output to Delta  (= WI * u)
%   z  : regulated output (= Wp * error), to be minimised
%   v  : measurement at controller (= -error = -(w + yG))
%
% Block diagram:
%        ud (from Delta)
%         |
%   w --> [Sum1] --> z1 --> [Wp] --> z
%           ^--- yG <---[G]<--[Sum2]<-- u
%           |                      |
%           v (measurement for K) [WI]--> yd (to Delta)

G.u  = 'uG';    G.y  = 'yG';
Wp.u = 'z1';    Wp.y = 'z';
WI.u = 'u';     WI.y = 'yd';

Sum1 = sumblk('z1 = w + yG', 2);   % error: disturbance + plant output
Sum2 = sumblk('uG = u + ud', 2);   % plant input: control + Delta perturbation
Sum3 = sumblk('v = -z1', 2);       % controller measurement: negative of error

% P inputs: {ud, w, u}    P outputs: {yd, z, v}
P = connect(G, Wp, WI, Sum1, Sum2, Sum3, ...
    {'ud','w','u'}, {'yd','z','v'});
% P is 6x6: [yd(2); z(2); v(2)] x [ud(2); w(2); u(2)]

%% =========================================================================
%  5. CONTROLLER
% =========================================================================
% Inverse-based controller: K(s) = 0.7 * (tau*s+1)/(eps*s) * G0^{-1}
%
%   - G0^{-1}: static decoupling (cancels the DC gain of G0)
%   - (tau*s+1)/(eps*s): approximate integral action (pole near 0)
%     plus cancellation of the plant pole at s = -1/tau
%   - gain 0.7: trade-off between performance and robustness
%
% The resulting loop transfer function is approximately K*G ≈ 0.7/s * I:
% two decoupled integrating loops.

Kinv = 0.7 * tf([tau 1],[1 1e-5]) * inv(G0);

%% =========================================================================
%  6. N-DELTA STRUCTURE AND PERTURBED MODEL
% =========================================================================
% N = F_l(P, K): lower LFT, closes the controller on the generalized plant.
%
% Partition of N consistent with the Delta structure:
%
%   N = [ N_11  N_12 ]  =  [ WI*Ti    WI*KS ]
%       [ N_21  N_22 ]     [ Wp*S_i   Wp*S  ]
%
%   S   = (I+GK)^{-1}         output sensitivity
%   T   = GK(I+GK)^{-1}       complementary sensitivity
%   S_i = (I+KG)^{-1}         input sensitivity
%   Ti  = KG(I+KG)^{-1}       input complementary sensitivity
%   KS  = K(I+GK)^{-1}        disturbance-to-control transfer function
%
%   N_11 = WI*Ti  : loop through Delta -> used for RS
%   N_22 = Wp*S   : from w to z with Delta=0 -> used for NP
%   N (full)      :                           -> used for RP

N     = lft(P, Kinv);           % lower LFT: N = F_l(P, Kinv)
omega = logspace(-3, 3, 61);    % frequency grid [rad/min]
Nfr   = frd(N, omega);          % frequency response of N

% Perturbed model Np = F_u(N, Delta): upper LFT.
% Delta is diagonal with independent SISO blocks (structured uncertainty):
%   Delta = diag(Delta_1, Delta_2),   ||Delta_i||_inf <= 1
% Np is an uncertain system (uss) required by robstab, robgain, wcgain.

Delta = [ultidyn('Delta_1',[1 1])  0; ...
         0                          ultidyn('Delta_2',[1 1])];
Np = lft(Delta, N);             % perturbed model: w -> z for all admissible Delta

%% =========================================================================
%  7. NOMINAL STABILITY (NS)
% =========================================================================
% Nominal Stability checks that the closed-loop system with the nominal model
% (Delta = 0) is stable, i.e. all poles of N = F_l(P,K) have negative real part.
%
% This is the most basic condition and is necessary for all subsequent analyses.

poles_N = pole(N);
fprintf('=== 7. NOMINAL STABILITY (NS) ===\n');
fprintf('Closed-loop poles (Delta = 0):\n');
fprintf('  max Re(p) = %.6f\n', max(real(poles_N)));
if all(real(poles_N) < 0)
    fprintf('  -> NS satisfied: all poles have negative real part.\n\n');
else
    fprintf('  -> NS NOT satisfied: unstable poles detected!\n\n');
end

%% =========================================================================
%  8. NOMINAL PERFORMANCE (NP)
% =========================================================================
% Nominal Performance checks that the performance requirement is met with
% the nominal model (Delta = 0):
%   ||Wp * S||_inf < 1
%
% Since N_22 = Wp*S is the transfer function from w to z with Delta = 0,
% the NP condition reduces to:
%   ||N_22||_inf < 1   i.e.   max_omega sigma_max(N_22(jw)) < 1
%
% The maximum singular value of N_22 is computed directly; no mu or
% uncertainty structure is involved here.

N22    = Nfr(3:4, 3:4);          % N_22 = Wp*S: from disturbance w to regulated output z
sv_N22 = sigma(N22, omega);      % singular values of N_22 over the frequency grid
muNP   = frd(max(sv_N22), omega);% sigma_max(N_22(jw)): frequency profile for plotting

[muNPinf, muNPw] = norm(muNP, inf);
fprintf('=== 8. NOMINAL PERFORMANCE (NP) ===\n');
fprintf('||Wp*S||_inf  =  peak sigma_max: %.4f  at omega = %.4f rad/min\n', muNPinf, muNPw);
if muNPinf < 1
    fprintf('  -> NP satisfied.\n\n');
else
    fprintf('  -> NP NOT satisfied (peak >= 1).\n\n');
end

%% =========================================================================
%  9. ROBUST STABILITY (RS)
% =========================================================================
% Robust Stability requires the closed-loop system to remain stable for ALL
% admissible uncertainties ||Delta_i||_inf <= 1.
%
% Equivalent condition via the structured singular value (small-gain theorem):
%   mu_Delta(N_11(jw)) < 1   for all omega
%
% where N_11 = WI*Ti is the block of N that closes the loop through Delta.
% Using mu (rather than the H_inf norm of N_11) accounts for the diagonal
% structure of Delta, yielding a less conservative condition than the
% unstructured small-gain theorem.
%
% --- 9a. mu_RS via mussv ---
% blk_RS specifies the Delta structure: 2 independent complex 1x1 blocks.

% Block structure for mussv (see mussv documentation):
%   [r  0] -> r-by-r repeated diagonal complex scalar block
%   [r  c] -> r-by-c full complex block
% Delta_1, Delta_2 are 1x1 complex scalar blocks -> [1 0]
blk_RS = [1 0; ...   % Delta_1: 1x1 complex scalar block
          1 0];      % Delta_2: 1x1 complex scalar block

N11 = Nfr(1:2, 1:2);              % N_11 = WI*Ti
[mubnds, ~] = mussv(N11, blk_RS); % upper and lower bounds of mu_RS
muRS = mubnds(:,1);                % upper bound of mu_RS

[muRSinf, muRSw] = norm(muRS, inf);
fprintf('=== 9. ROBUST STABILITY (RS) ===\n');
fprintf('mu_RS (peak upper bound): %.4f  at omega = %.4f rad/min\n', muRSinf, muRSw);
if muRSinf < 1
    fprintf('  -> RS guaranteed (mu_RS < 1).\n\n');
else
    fprintf('  -> RS NOT guaranteed (mu_RS >= 1).\n\n');
end

% --- 9b. RS via robstab ---
% robstab computes the robust stability margin: the smallest scaling factor f
% such that the system becomes unstable for ||Delta_i||_inf = f.
% stabmarg.LowerBound > 1 guarantees RS.
%
% With Sensitivity='On', robstab also returns the sensitivity of the stability
% margin with respect to each uncertainty block. A high value means that block
% is the bottleneck for robustness (e.g. Delta_1 with sensitivity 0.8 means
% that increasing the size of Delta_1 by 10% reduces the margin by ~8%).
% Useful to identify which uncertainty most limits RS and where it is worth
% investing in better modelling or physical uncertainty reduction.

opts_rob = robOptions('Sensitivity','On');
[stabmarg, wcu_RS, info_RS] = robstab(Np, opts_rob);
fprintf('robstab RS: stability margin  Lower = %.4f,  Upper = %.4f\n', ...
    stabmarg.LowerBound, stabmarg.UpperBound);
fprintf('  -> RS guaranteed if stability margin > 1\n');
fprintf('  Sensitivity of the margin w.r.t. each uncertainty block:\n');
disp(info_RS.Sensitivity)
fprintf('  (high values indicate the most critical block for RS)\n\n');

% Worst-case analysis: uncertainty that drives the system to the stability boundary
Npwc_RS = usubs(Np, wcu_RS);
fprintf('Poles of Np at the RS worst-case uncertainty:\n');
disp(pole(Npwc_RS));
fprintf('  (poles with zero real part mark the stability boundary)\n\n');

%% =========================================================================
%  10. ROBUST PERFORMANCE (RP)
% =========================================================================
% Robust Performance requires ||Wp*S_pert||_inf < 1 for ALL admissible
% uncertainties, i.e. the performance objective must hold simultaneously
% with robust stability.
%
% Equivalent mu condition on the full N with the augmented block structure:
%   Delta_RP = diag(Delta_1, Delta_2, Delta_p)
% where Delta_p in C^{2x2} is a full fictitious block representing the
% performance channel w -> z.
%
%   mu_{Delta_RP}(N(jw)) < 1   for all omega
%
% Hierarchy: mu_RP(jw) >= max(sigma_max(N_22(jw)), mu_RS(jw)),
% so RP is the most demanding condition and implies NS, NP, and RS.
%
% --- 10a. mu_RP via mussv ---
% blk_RP specifies the augmented Delta_RP structure:
%   [1 0] -> Delta_1, Delta_2: 1x1 complex scalar blocks
%   [2 2] -> Delta_p: full 2x2 complex block (performance)
blk_RP = [1 0; ...   % Delta_1: 1x1 complex scalar block
          1 0; ...   % Delta_2: 1x1 complex scalar block
          2 2];      % Delta_p: full 2x2 complex block (performance)

[mubnds, ~] = mussv(Nfr, blk_RP);
muRP = mubnds(:,1);               % upper bound of mu_RP

[muRPinf, muRPw] = norm(muRP, inf);
fprintf('=== 10. ROBUST PERFORMANCE (RP) ===\n');
fprintf('mu_RP (peak upper bound): %.4f  at omega = %.4f rad/min\n', muRPinf, muRPw);
if muRPinf < 1
    fprintf('  -> RP guaranteed (mu_RP < 1).\n\n');
else
    fprintf('  -> RP NOT guaranteed (mu_RP >= 1).\n\n');
end

% --- 10b. RP via wcgain ---
% wcgain computes the worst-case H_inf gain of Np over all admissible Delta.
% If maxgain.UpperBound < 1, RP is satisfied.

opt = wcgainOptions('MaxOverFrequency','on','RelTol',0.1);
[maxgain, ~, ~] = wcgain(Np, opt);
fprintf('wcgain: worst-case gain  Lower = %.4f,  Upper = %.4f\n', ...
    maxgain.LowerBound, maxgain.UpperBound);
fprintf('  -> RP satisfied if worst-case gain < 1\n\n');

% --- 10c. RP via robstab on the augmented Delta_RP system ---
% Robust stability of F_u(N, Delta_RP) is equivalent to RP of N:
% it verifies that the w->z channel does not exceed unit gain for any
% admissible uncertainty.
%
% With Sensitivity='On', the sensitivity is computed for all three blocks.
%   - Sensitivity of Delta_1, Delta_2: how much each physical uncertainty
%     block contributes to the RP limit (same interpretation as in RS).
%   - Sensitivity of Delta_p: how tight the performance requirement is
%     relative to the uncertainty. A high value on Delta_p means it is the
%     performance channel (not the physical uncertainty) that limits RP,
%     suggesting that relaxing Wp would be more effective than reducing
%     the uncertainty.
% Note: to quantify exactly how much Wp needs to be relaxed, use robgain
% with a varying gamma (section 10d) — the two approaches are equivalent.

Delta_RP = [ultidyn('Delta_1',[1 1])  0                        zeros(1,2); ...
            0                          ultidyn('Delta_2',[1 1])  zeros(1,2); ...
            zeros(2,1)                 zeros(2,1)                ultidyn('Delta_p',[2 2])];
Np_RP = lft(Delta_RP, N);

[stabmarg_RP, wcu_RP, info_RP] = robstab(Np_RP, opts_rob);
fprintf('robstab RP (Delta_RP): stability margin  Lower = %.4f,  Upper = %.4f\n', ...
    stabmarg_RP.LowerBound, stabmarg_RP.UpperBound);
fprintf('  -> RP guaranteed if stability margin > 1\n');
fprintf('  Sensitivity of the margin w.r.t. each block (uncertainty + performance):\n');
disp(info_RP.Sensitivity)
fprintf('  (high sensitivity on Delta_p -> performance requirement is the limiting factor)\n\n');

Npwc_RP = usubs(Np, wcu_RP);
fprintf('Poles of Np at the RP worst-case uncertainty:\n');
disp(pole(Npwc_RP));
fprintf('  (poles on the imaginary axis mark the robust performance boundary)\n\n');

% --- 10d. RP via robgain ---
% gamma is the gain threshold to be verified: robgain answers the question
% "Is the H_inf gain of Np less than gamma for ALL admissible uncertainties?"
%
% Since Np: w -> z = Wp*S_pert, having ||Np||_inf < gamma for all Delta means
% that the peak of the weighted sensitivity does not exceed gamma in the
% worst case. With gamma = 1 this is exactly the standard RP condition.
%
% robgain returns lower and upper bounds on the performance margin.
% From these, bounds on the worst-case H_inf gain of Np follow directly:
%   gamma_min in [ gamma/perfmarg.UpperBound,  gamma/perfmarg.LowerBound ]

gamma = 1;
[perfmarg, wcu_pg] = robgain(Np, gamma);
gamma_min_lo = gamma / perfmarg.UpperBound;  % lower bound on worst-case H_inf gain
gamma_min_hi = gamma / perfmarg.LowerBound;  % upper bound on worst-case H_inf gain
fprintf('robgain (gamma = %.1f):  perf margin  Lower = %.4f,  Upper = %.4f\n', ...
    gamma, perfmarg.LowerBound, perfmarg.UpperBound);
fprintf('  Worst-case H_inf gain of Np in [ %.4f,  %.4f ]\n', ...
    gamma_min_lo, gamma_min_hi);
if perfmarg.LowerBound >= 1
    fprintf('  -> RP satisfied with margin.\n\n');
else
    fprintf('  -> RP not satisfied: scale Wp down by a factor in [ %.4f,  %.4f ] to achieve RP.\n\n', ...
        gamma_min_lo, gamma_min_hi);
end

Npmax = usubs(Np, wcu_pg);
pk = getPeakGain(Npmax, 1e-6);
fprintf('Peak gain of Np at worst-case Delta (robgain): %.4f\n\n', pk);

%% =========================================================================
%  11. SUMMARY AND PLOT
% =========================================================================
% Condition hierarchy:
%   NS  necessary condition for everything else
%   NP  performance with nominal model (Delta = 0)
%   RS  stability for all admissible uncertainties
%   RP  performance for all admissible uncertainties (implies NS + NP + RS)
%
% In general: mu_RP(jw) >= max( sigma_max(N_22(jw)),  mu_RS(jw) )

fprintf('=== SUMMARY ===\n');
fprintf('NS : %s\n',       ternary(all(real(poles_N)<0), 'OK', 'NOT satisfied'));
fprintf('NP : peak sigma_max(Wp*S) = %.4f  ->  %s\n', ...
    muNPinf, ternary(muNPinf<1,'OK','NOT satisfied'));
fprintf('RS : peak mu_RS           = %.4f  ->  %s\n', ...
    muRSinf, ternary(muRSinf<1,'OK','NOT satisfied'));
fprintf('RP : peak mu_RP           = %.4f  ->  %s\n', ...
    muRPinf, ternary(muRPinf<1,'OK','NOT satisfied'));

figure('Name','Mu-analysis: NS, NP, RS, RP','NumberTitle','off')
bodemag(muRP,'', muRS,'--', muNP,'-.', omega)
hold on
yline(0,'k:','LineWidth',1.2)
hold off
legend('\mu_{RP}','\mu_{RS}','\sigma_{max}(W_p S)','0 dB (\mu = 1)','Location','best')
title('Mu-analysis: NP, RS, RP')
xlabel('\omega  [rad/min]')
ylabel('magnitude')
grid on

% ── helper function ───────────────────────────────────────────────────────
function s = ternary(cond, a, b)
% Returns a if cond is true, b otherwise.
    if cond; s = a; else; s = b; end
end