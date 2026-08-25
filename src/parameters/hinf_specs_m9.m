function config = hinf_specs_m9
%HINF_SPECS_M9 Numerical settings for the frozen-weight M9 validation.
%   Performance targets and physical scales remain sourced from M5.

config.stabilityTolerance = 1e-7;
config.pathConsistencyTolerance = 1e-10;
config.weightConsistencyTolerance = 1e-12;
config.normRelativeTolerance = 1e-5;
config.closedLoopConsistencyTolerance = 1e-8;

config.frequencyGrid = logspace(-3, 3, 1201);
config.trackingHorizon = 12;
config.disturbanceHorizon = 12;
config.timeStep = 0.002;
config.settlingBandFraction = 0.02;
config.steadyStateTailFraction = 0.10;

config.nominalSynthesis = true;
config.W3 = [];
config.saturationEnabled = false;
config.weightRetuningEnabled = false;
config.robustAnalysisEnabled = false;
end
