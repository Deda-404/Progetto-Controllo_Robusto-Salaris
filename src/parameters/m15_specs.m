function config = m15_specs
%M15_SPECS Frozen configuration for nonlinear robust-controller validation.

m8 = m8_specs;
config.milestone = "M15";
config.baselineCommit = "c51142e624adea610e72d16ddfd764008cb65371";
config.mergedPullRequest = 19;
config.mergedPullRequestState = "MERGED";
config.controllerIDs = ["Khinf"; "Kmu"];
config.controllerSources = [ ...
    "results/data/m10_hinfsyn_nominal.mat"; ...
    "results/data/m13_musyn_dk.mat"];
% Identita dei controllori correnti M10/M13 dopo la revisione dei pesi.
config.expectedControllerOrders = [18; 70];
config.solver = m8.solver;
config.simulation = m8.simulation;
config.tracking.referenceAmplitudesDeg = ...
    m8.tracking.referenceAmplitudesDeg;
config.disturbance.amplitudesNm = m8.disturbance.amplitudesNm;
config.noise.seed = m8.noise.seed;
config.equilibrium = m8.equilibrium;
config.ras = m8.ras;
config.ras.secondarySectionEnabled = false;
% Il tetto copre la griglia, i 36 estremi e tutte le bisezioni a 1 grado,
% inclusa al massimo una estensione temporale per punto. Le soglie M8
% restano identiche; 400 esecuzioni non coprivano questo caso peggiore.
maximumBisections = ceil(log2(sqrt(2) * config.ras.searchBoxDeg / ...
    config.ras.radialToleranceDeg));
config.ras.maximumSimulations = 2 * (numel(config.ras.coarseGridDeg)^2 + ...
    config.ras.numberDirections * (1 + maximumBisections));
config.agreement.numberDirections = 36;
config.agreement.maximumRadiusDeg = 8;
config.agreement.radialToleranceDeg = 0.25;
config.agreement.maximumQDiscrepancyDeg = 0.5;
config.agreement.horizon = 4.0;
config.agreement.maximumSimulations = 300;
config.saturationEnabled = false;
config.uScaleMeaning = ...
    "performance normalization; not a certified actuator saturation";
config.uncertaintySamplingEnabled = false;
config.monteCarloEnabled = false;
config.controllerReductionEnabled = false;
config.controllerTuningEnabled = false;
config.prefilterEnabled = false;
config.integralAugmentationEnabled = false;
config.m16Enabled = false;
config.analysisOnly = true;
end
