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

% Last authorized feasibility expansion: structured co-tuning of the
% dimensionless augmented-cost priorities. The physical scales remain
% sourced from M5/M6 and are deliberately absent from these grids.
config.stageC1.wq = [1; 2; 4; 8; 16];
config.stageC1.wi = [2; 4; 8; 16; 32];
config.stageC1.rhoU = [2; 4; 8];
config.stageC1.wqdot = 0.5;
config.stageC1.wdelta = 0.1;
config.stageC1.wthetaDot = 0.5;
config.stageC2.wVelocity = [0.5; 1; 2; 4];
config.stageC3.wdelta = [0.025; 0.05; 0.10; 0.20];
config.maximumPromisingSeeds = 5;
config.promisingSettlingTime = 1.0;
config.promisingOvershoot = 15;
config.promisingSettlingWithLowOvershoot = 1.2;
config.diagnosticSettlingTarget = 0.8;
config.diagnosticOvershootTarget = 10;
config.controlEffortModerateThreshold = ...
    m6Config.controlEffortModerateThreshold;
config.controlEffortAggressiveThreshold = ...
    m6Config.controlEffortAggressiveThreshold;
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
