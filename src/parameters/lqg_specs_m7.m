function config = lqg_specs_m7
%LQG_SPECS_M7 Parametri dichiarati del servo LQRI con Kalman M6.
%   Tre valori di wi isolano il costo integrale a Q e R fissi.
%   wi=1 e illustrativo, non selezionato mediante ottimizzazione.

m6 = lqg_specs_m6;
config.manualDesigns = table( ...
    ["weakIntegral"; "balanced"; "strongIntegral"], ...
    [0.1; 1; 4], repmat(1/9,3,1), ...
    'VariableNames', {'Tuning', 'Wi', 'Ru'});
config.illustrativeIndex = 2;
config.statePrioritiesSource = ...
    "M6 validated artifact: validationMetrics.cost.priorities";
% Tolleranza sull'equilibrio DC; il residuo a 8 s e riportato separatamente.
config.disturbanceSteadyStateTolerance = 1e-9;
config.referenceHorizon = 8;
config.disturbanceHorizon = 8;
config.simulationTimeStep = m6.simulationTimeStep;
config.settlingBandFraction = m6.settlingBandFraction;
config.numericStabilityTolerance = m6.numericStabilityTolerance;
config.antiWindupEnabled = false;
config.saturationEnabled = false;
config.status = ...
    "LQRI nominale: 14 stati stimati e 2 integratori misurati";
end
