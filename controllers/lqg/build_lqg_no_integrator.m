function realization = build_lqg_no_integrator( ...
    m3Data, m5Data, lqrSelection, kalmanSelection, config)
%BUILD_LQG_NO_INTEGRATOR Build controller and nominal augmented M6 loop.

arguments
    m3Data (1, 1) struct
    m5Data (1, 1) struct
    lqrSelection (1, 1) struct
    kalmanSelection (1, 1) struct
    config (1, 1) struct = lqg_specs_m6
end

assert(isfield(lqrSelection, 'K') && isfield(kalmanSelection, 'L'), ...
    'M6LQG:SelectionsRequired', ...
    'Selected LQR and Kalman designs are required.');

A = m3Data.Afull;
B = m3Data.Bfull;
C = m3Data.CfullMeas;
Cq = m3Data.CfullQ;
Ctheta = C(3:4, :);
Bd = m5Data.BdFull;
K = lqrSelection.K;
Nr = lqrSelection.Nr;
L = kalmanSelection.L;
numberStates = size(A, 1);

controllerA = A - B * K - L * C;
controllerB = [B * Nr, L];
controllerC = -K;
controllerD = [Nr, zeros(2, 4)];
Klqg = ss(controllerA, controllerB, controllerC, controllerD, ...
    'StateName', compose("xhat_%02d", (1:numberStates).'), ...
    'InputName', {'r1', 'r2', 'q1', 'q2', 'theta1', 'theta2'}, ...
    'OutputName', {'u1', 'u2'});

Aaugmented = [A, -B * K; L * C, A - B * K - L * C];
referenceInput = [B * Nr; B * Nr];
disturbanceInput = [Bd; zeros(numberStates, 2)];
measurementNoiseInput = [zeros(numberStates, 4); L];
Baugmented = [referenceInput, disturbanceInput, ...
    measurementNoiseInput];
Caugmented = [ ...
    Cq, zeros(2, numberStates); ...
    Ctheta, zeros(2, numberStates); ...
    zeros(2, numberStates), -K; ...
    Cq, -Cq];
Daugmented = [ ...
    zeros(4, 8); ...
    Nr, zeros(2, 6); ...
    zeros(2, 8)];
lqgClosedLoop = ss(Aaugmented, Baugmented, Caugmented, Daugmented, ...
    'InputName', {'r1', 'r2', 'd1', 'd2', 'v_q1', 'v_q2', ...
    'v_theta1', 'v_theta2'}, ...
    'OutputName', {'q1', 'q2', 'theta1', 'theta2', ...
    'u1', 'u2', 'eq1', 'eq2'});

fullStateEvaluation = evaluate_m6_closed_loop(A, B, Cq, Ctheta, ...
    Bd, K, Nr, m3Data.mechanicalParams.Ks, m5Data.spec, config, true);
fullStateClosedLoop = fullStateEvaluation.fullStateClosedLoop;

regulatorPoles = eig(A - B * K);
estimatorPoles = eig(A - L * C);
combinedPoles = eig(Aaugmented);
expectedCombinedPoles = [regulatorPoles; estimatorPoles];
poleDistances = abs(combinedPoles - expectedCombinedPoles.');
separationError = max([max(min(poleDistances, [], 1)), ...
    max(min(poleDistances, [], 2))]);

realization.Klqg = Klqg;
realization.fullStateClosedLoop = fullStateClosedLoop;
realization.fullStateEvaluation = fullStateEvaluation;
realization.lqgClosedLoop = lqgClosedLoop;
realization.regulatorPoles = regulatorPoles;
realization.estimatorPoles = estimatorPoles;
realization.combinedPoles = combinedPoles;
realization.expectedCombinedPoles = expectedCombinedPoles;
realization.separationError = separationError;
realization.controllerOrder = size(Klqg.A, 1);
realization.integratorStateCount = sum(abs(eig(Klqg.A)) <= ...
    config.numericStabilityTolerance);
end
