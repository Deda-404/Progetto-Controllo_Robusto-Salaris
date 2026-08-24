function config = m8_specs
%M8_SPECS Reproducibility and quality-gate settings for M8.
%   Physical/controller data are deliberately loaded from M2/M3/M5/M6.

config.modelName = "SEA_LQG_nonlinear";
config.modelRelativePath = fullfile('simulink', ...
    'SEA_LQG_nonlinear.slx');

config.solver.candidates = ["ode45"; "ode23t"];
config.solver.selected = "ode23t";
config.solver.relativeTolerance = 1e-5;
config.solver.absoluteTolerance = 1e-7;
config.solver.maximumStep = 0.005;

config.simulation.equilibriumHorizon = 4.0;
config.simulation.trackingHorizon = 4.0;
config.simulation.disturbanceHorizon = 8.0;
config.simulation.noiseHorizon = 4.0;
config.simulation.inputTimeStep = 0.002;
config.simulation.settlingBandFraction = 0.02;

config.tracking.referenceAmplitudesDeg = [2; 5; 8];
config.disturbance.amplitudesNm = [0.25; 0.50; 1.00];
config.noise.seed = 20260826;

config.equilibrium.positionTolerance = 1e-8;
config.equilibrium.controlTolerance = 1e-8;

config.ras.coarseGridDeg = [-60; -30; 0; 30; 60];
config.ras.numberDirections = 36;
config.ras.searchBoxDeg = 60;
config.ras.radialToleranceDeg = 1.0;
config.ras.horizon = 8.0;
config.ras.extendedHorizon = 12.0;
config.ras.tailFraction = 0.10;
config.ras.positionToleranceDeg = 0.5;
config.ras.linkVelocityTolerance = 0.02;
config.ras.motorPositionToleranceDeg = 0.5;
config.ras.motorVelocityTolerance = 0.05;
config.ras.numericMagnitudeLimit = 1e6;
config.ras.maximumSimulations = 400;
config.ras.finalTrendGrowthFraction = 0.05;
config.ras.secondarySectionEnabled = true;
config.ras.secondaryEstimatorInitialization = ...
    "coherent physical-state estimate";

config.saturationEnabled = false;
config.integralBenchmarkEnabled = false;
config.integralBenchmarkLabel = "representative integral benchmark";
end
