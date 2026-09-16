function config = monte_carlo_specs_m16
%MONTE_CARLO_SPECS_M16 Frozen settings for the M4 linear Monte Carlo.

config.milestone = "M16";
config.responsible = "Alessio";
config.baselineCommit = ...
    "8e1c8437c786a252a380ce6b4452d32bebf9c2c6";
config.mergedPullRequest = 20;
config.mergedPullRequestState = "MERGED";
config.mergedPullRequestCommit = config.baselineCommit;

config.seed = 20260826;
config.rngAlgorithm = "twister";
config.numberSamples = 40;
config.trackingAmplitudeDeg = 5;
config.disturbanceAmplitudeNm = 0.50;
config.trackingHorizon = 4;
config.disturbanceHorizon = 8;
config.timeStep = 0.002;
config.settlingBandFraction = 0.02;

config.expectedUncertaintyBlocks = ...
    ["Delta_act1"; "Delta_act2"; "Jm1"; "k1"; "k2"];
config.expectedMechanicalRanges = table( ...
    ["Jm1"; "k1"; "k2"], [0.01; 50; 40], [10; 10; 10], ...
    'VariableNames', {'Parameter', 'NominalValue', 'Percentage'});
% Ordini verificati degli artifact M6/M10/M13 correnti.
config.expectedControllerOrders = [14; 18; 70];
config.controllerIDs = ["M6"; "Khinf"; "Kmu"];
config.controllerSources = [ ...
    "results/data/m6_lqg_no_integrator.mat"; ...
    "results/data/m10_hinfsyn_nominal.mat"; ...
    "results/data/m13_musyn_dk.mat"];

config.auditFrequencyGrid = logspace(-2, 3, 161);
config.deltaFrequencyGrid = logspace(-3, 4, 241);
config.frequencyAbsoluteTolerance = 1e-7;
config.frequencyRelativeTolerance = 1e-7;
config.poleSetTolerance = 1e-5;
config.replayTolerance = 1e-12;
config.uncertaintyBoundTolerance = 1e-8;
config.rangeTolerance = 1e-12;
config.stabilityTolerance = 1e-8;
config.pairedTieTolerance = 1e-10;

config.m4Source = "results/data/m4_uncertain_plant.mat";
config.m5Source = "results/data/m5_performance_specs.mat";
config.m14Source = "results/data/m14_final_mu_analysis_kmu.mat";
config.m15Source = ...
    "results/data/m15_nonlinear_robust_validation.mat";
config.artifactPath = ...
    "results/data/m16_monte_carlo_uncertain_linear.mat";
config.figureDirectory = "results/figures";

config.synthesisPerformed = false;
config.controllerTuningPerformed = false;
config.controllerReductionPerformed = false;
config.weightRetuningPerformed = false;
config.prefilterEnabled = false;
config.twoDegreeOfFreedomEnabled = false;
config.saturationEnabled = false;
config.simulinkUsed = false;
config.nonlinearSimulationPerformed = false;
config.m17Started = false;
config.weightedNormDiagnosticEnabled = false;
config.monteCarloInterpretation = ...
    "EMPIRICAL_LINEAR_M4_NOT_A_ROBUSTNESS_CERTIFICATE";
end
