function config = lqg_specs_m7
%LQG_SPECS_M7 Parametri dichiarati del servo LQGI con Kalman M6.
%   Tre valori diretti di wbarI isolano il costo integrale a Q e R M6 fissi.
%   wbarI=200 e illustrativo, non selezionato mediante ottimizzazione.

m6 = lqg_specs_m6;
config.manualDesigns = table( ...
    ["weakIntegral"; "balanced"; "strongIntegral"], ...
    [20; 200; 800], ...
    'VariableNames', {'Tuning', 'WbarI'});
% Il validatore legge R dal candidato M6 selezionato, senza fissare ru a mano.
config.controlCostSource = "M6 validated artifact: R";
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
    "LQGI nominale: 14 stati stimati e 2 integratori misurati";
end
