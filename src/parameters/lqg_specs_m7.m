function config = lqg_specs_m7
%LQG_SPECS_M7 Three manual LQI feasibility checks.
%   These points illustrate the integral-action trade-off. They are not a
%   search grid and no automatic ranking or controller selection is used.

m6 = lqg_specs_m6;
config.manualDesigns = table( ...
    ["weakIntegral"; "balanced"; "strongIntegral"], ...
    [0.1; 1; 4], [16; 8; 4], ...
    'VariableNames', {'Tuning', 'Wi', 'RhoU'});
config.statePriorities = rmfield(m6.lqr, {'rhoU', 'rationale'});
config.disturbanceSteadyStateTolerance = 1e-4;
config.referenceHorizon = m6.referenceHorizon;
config.disturbanceHorizon = 8;
config.simulationTimeStep = m6.simulationTimeStep;
config.settlingBandFraction = m6.settlingBandFraction;
config.numericStabilityTolerance = m6.numericStabilityTolerance;
config.feedforwardResidualTolerance = 1e-10;
config.feedforwardConditionWarning = 1e8;
config.antiWindupEnabled = false;
config.saturationEnabled = false;
config.status = ...
    "feasibility study only; M6 remains the approved nominal controller";
end
