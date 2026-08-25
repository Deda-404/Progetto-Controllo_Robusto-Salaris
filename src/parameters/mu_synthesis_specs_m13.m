function config = mu_synthesis_specs_m13
%MU_SYNTHESIS_SPECS_M13 Frozen configuration for the single M13 D-K run.

m12 = mu_analysis_specs_m12;

config.milestone = "M13";
config.baselineCommit = ...
    "9b69caa02c7f8dbca9cc2b936067f67c25904f1a";
config.mergedPullRequest = 17;
config.nmeas = 2;
config.ncont = 2;
config.maxIterations = 5;
config.display = 'short';
config.targetPerformance = 0;
config.performanceTolerance = 0.01;
config.mixedMu = 'on';
config.fullDG = [true, true];
config.fitOrder = [5, 2];
config.frequencyGrid = m12.muFrequencyGrid;
config.autoScale = 'on';
config.regularize = 'on';
config.limitGain = 'on';
config.randomStart = 0;
config.useParallel = false;
config.minimumDecay = 1e-7;
config.maximumFrequency = Inf;

config.gammaTarget = 1;
config.expectedUncertaintyNames = m12.expectedUncertaintyNames;
config.auditFrequencyGrid = m12.auditFrequencyGrid;
config.identityFrequencyTolerance = 1e-9;
config.identityPoleTolerance = 1e-8;
config.weightTolerance = 1e-9;
config.stabilityTolerance = 1e-8;
config.closedLoopMapTolerance = 1e-7;
config.nominalNormRelativeTolerance = 1e-5;
config.m10LowerBoundRelativeTolerance = 5e-3;

config.PuncSource = "results/data/m12_mu_analysis_a5.mat";
config.uncertaintySource = "results/data/m4_uncertain_plant.mat";
config.weightSource = "results/data/m5_performance_specs.mat";
config.m10Source = "results/data/m10_hinfsyn_nominal.mat";
config.m11Source = "results/data/m11_hinfstruct_structured.mat";
config.W3 = [];
config.weightRetuningEnabled = false;
config.uncertaintyRetuningEnabled = false;
config.controllerReductionEnabled = false;
config.secondSynthesisEnabled = false;
config.twoDegreeOfFreedomEnabled = false;
config.prefilterEnabled = false;
config.monteCarloEnabled = false;
config.nonlinearValidationEnabled = false;
config.formalM14AnalysisEnabled = false;
config.singleCandidate = true;
config.singleCallSite = true;
config.seedUsedBySynthesis = false;
end
