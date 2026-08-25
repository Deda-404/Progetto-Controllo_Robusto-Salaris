function config = mu_analysis_specs_m14
%MU_ANALYSIS_SPECS_M14 Frozen configuration for final Kmu mu-analysis.

config = mu_analysis_specs_m12;
config.milestone = "M14";
config.baselineCommit = ...
    "49f37c6e027aaa37db65f27530901965f897f11f";
config.mergedPullRequest = 18;
config.mergedPullRequestCommit = config.baselineCommit;
config.mergedPullRequestState = "MERGED";
config.pipelineSourceMilestone = "M12";
config.controllerSource = "results/data/m13_musyn_dk.mat";
config.PuncSource = "results/data/m12_mu_analysis_a5.mat";
config.uncertaintySource = "results/data/m4_uncertain_plant.mat";
config.weightSource = "results/data/m5_performance_specs.mat";
config.m12Source = "results/data/m12_mu_analysis_a5.mat";
config.m13Source = "results/data/m13_musyn_dk.mat";
config.expectedControllerOrder = 52;
config.identityFrequencyTolerance = ...
    config.nominalFrequencyTolerance;
config.identityPoleTolerance = config.nominalPoleTolerance;
config.weightTolerance = config.nominalFrequencyTolerance;
config.closedLoopMapTolerance = 1e-7;
config.rsComparisonRelativeTolerance = 1e-6;

config.uncertaintyRetuningEnabled = false;
config.controllerReductionEnabled = false;
config.controllerTuningEnabled = false;
config.weightRetuningEnabled = false;
config.musynEnabled = false;
config.hinfsynEnabled = false;
config.mixsynEnabled = false;
config.hinfstructEnabled = false;
config.dkIterationEnabled = false;
config.prefilterEnabled = false;
config.twoDegreeOfFreedomEnabled = false;
config.monteCarloEnabled = false;
config.nonlinearValidationEnabled = false;
config.m15Enabled = false;
config.analysisOnly = true;
end
