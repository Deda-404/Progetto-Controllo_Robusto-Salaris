function config = lqg_specs_m6
%LQG_SPECS_M6 Central candidate grids and reproducibility settings for M6.
%   Physical normalization scales are intentionally derived from the M3/M5
%   sources of truth by BUILD_LQR_STATE_COST and are not duplicated here.

config.rhoUCandidates = [0.5; 1; 2; 4; 8];

config.coarse.wq = [1; 2; 4; 8];
config.coarse.wdelta = [0.10; 0.25; 0.50; 1.00];
config.coarse.wVelocity = [0.5; 1; 2];
config.coarse.rhoU = [0.5; 1; 2; 4; 8];
config.extended.wq = [8; 12; 16];
config.extended.wdelta = [0.025; 0.05; 0.10];
config.extended.wVelocity = [0.25; 0.5; 1];
config.extended.rhoU = [0.1; 0.25; 0.5; 1];

config.processDisturbanceSigmas = [0.025; 0.050; 0.100];
config.processInputSigmas = [0.10; 0.25; 0.50];
config.measurementNoiseSigmasDeg = [0.05; 0.10; 0.25];
config.estimatorSpeedRatioMinimum = 1.5;
config.estimatorSpeedRatioMaximum = 5.0;

config.noiseSeed = 20260826;
config.referenceHorizon = 3.0;
config.disturbanceHorizon = 4.0;
config.noiseHorizon = 4.0;
config.simulationTimeStep = 0.002;
config.settlingBandFraction = 0.02;
config.numericStabilityTolerance = 1e-8;
config.rankingTieTolerance = 1e-10;
config.controlEffortModerateThreshold = 1;
config.controlEffortAggressiveThreshold = 2;
config.extendedDeltaBaselineMultiplier = 2;
config.extendedGainBaselineMultiplier = 10;
config.prefilterConditionWarning = 1e8;

% Approved result of the metric-based coarse-grid selection. The tuning
% routine does not read these fields while constructing or ranking grids.
config.selected.wq = 1;
config.selected.wqdot = 0.5;
config.selected.wdelta = 0.10;
config.selected.wthetaDot = 0.5;
config.selected.rhoU = 8;
end
