function config = lqg_specs_m7
%LQG_SPECS_M7 Candidate grid and reproducibility settings for M7.
%   M6 state priorities, Kalman covariances and M5 physical amplitudes are
%   deliberately not repeated here. They are loaded from the approved M6
%   and M5 sources of truth by the M7 synthesis routines.

m6Config = lqg_specs_m6;

config.wiCandidates = [0.05; 0.10; 0.25; 0.50; 1; 2; 4];
config.rhoUCandidates = [4; 8; 12; 16];
config.stageBWiCandidates = [4; 8; 16; 32; 64];
config.stageBRhoUCandidates = [1; 2; 4; 8; 12];
config.disturbanceSteadyStateTolerance = 1e-4;
config.integratorArchitecture = "measured joint-position error";
config.diagnosticIntegratorArchitecture = ...
    "estimated joint-position error";
config.noiseSeed = m6Config.noiseSeed;

config.referenceHorizon = m6Config.referenceHorizon;
config.disturbanceHorizon = 8.0;
config.noiseHorizon = m6Config.noiseHorizon;
config.simulationTimeStep = m6Config.simulationTimeStep;
config.settlingBandFraction = m6Config.settlingBandFraction;
config.numericStabilityTolerance = m6Config.numericStabilityTolerance;
config.separationTolerance = 1e-4;
config.rankingTieTolerance = m6Config.rankingTieTolerance;
config.feedforwardResidualTolerance = 1e-10;
config.feedforwardConditionWarning = 1e8;
config.antiWindupEnabled = false;
config.saturationEnabled = false;
end
