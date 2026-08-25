function config = mu_analysis_specs_m12
%MU_ANALYSIS_SPECS_M12 Frozen configuration for A5 robust analysis.

config.milestone = "M12";
config.baselineCommit = ...
    "c5b14e5332279e8e98b89d4c5b7a180102646fde";
config.selectedArchitecture = "A5";
config.gammaTarget = 1;
config.muFrequencyGrid = logspace(-3, 4, 1201);
config.auditFrequencyGrid = logspace(-3, 4, 1001);
config.nominalFrequencyTolerance = 1e-9;
config.nominalNormRelativeTolerance = 1e-5;
config.nominalPoleTolerance = 1e-8;
config.lftEquivalenceTolerance = 1e-9;
config.stabilityTolerance = 1e-8;
config.boundTolerance = 1e-10;
config.muMarginRelativeTolerance = 0.05;
config.muCriticalFrequencyRelativeTolerance = 0.10;
config.worstCaseBoundaryPoleTolerance = 1e-6;
config.robustDisplay = 'off';
config.robustSensitivity = 'on';
config.robustMussvOptions = '';
config.worstCaseUncertaintyLevel = 1;

config.expectedUncertaintyNames = [ ...
    "Delta_act1"; "Delta_act2"; "Jm1"; "k1"; "k2"];
config.weightRetuningEnabled = false;
config.W3 = [];
config.controllerTuningEnabled = false;
config.monteCarloEnabled = false;
config.nonlinearValidationEnabled = false;
config.musynEnabled = false;
config.dkIterationEnabled = false;
config.m13Enabled = false;
end
