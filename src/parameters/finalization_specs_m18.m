function config = finalization_specs_m18
%FINALIZATION_SPECS_M18 Validated settings for final document generation.

config.milestone = "M18";
config.responsible = "Alessio";
% Provenienza storica M18: non identifica la revisione tecnica corrente.
config.baselineCommit = "75d194d49a96b67309b1853f154bdd22a168ca4f";
config.mergedPullRequest = 22;
config.mergedPullRequestState = "MERGED";
config.mergedPullRequestCommit = config.baselineCommit;
config.matlabRelease = "R2025b";
config.reportSource = "report/main.tex";
config.reportPdf = "report/Progetto_CR_Relazione_finale.pdf";
config.presentationSource = "presentation/main.tex";
config.presentationPdf = "presentation/Progetto_CR_Presentazione.pdf";
config.numericAuditArtifact = "results/data/m18_final_deliverable_audit.mat";
config.randomSeedM16 = 20260826;
% I flag seguenti descrivono SOLO il generatore documentale M18.
% Le nuove simulazioni Lyapunov/sensibilita sono eseguite a monte.
config.synthesisPerformed = false;
config.musynPerformed = false;
config.hinfsynPerformed = false;
config.mixsynPerformed = false;
config.hinfstructPerformed = false;
config.controllerRetuningPerformed = false;
config.controllerReductionPerformed = false;
config.weightRetuningPerformed = false;
config.uncertaintyRetuningPerformed = false;
config.monteCarloPerformed = false;
config.usampleSequenceGenerated = false;
config.dynamicSimulationPerformed = false;
config.simulinkUsed = false;
config.technicalResultsModified = false;
config.uScaleInterpretation = "PERFORMANCE_NORMALIZATION_NOT_CERTIFIED_SATURATION";
config.rasInterpretation = "ANALYTIC_NOMINAL_INNER_BOUND_AND_SEPARATE_EMPIRICAL_MAPS";
config.monteCarloInterpretation = "EMPIRICAL_LINEAR_M4_NOT_A_ROBUSTNESS_CERTIFICATE";
config.overallStatus = "COMPLETE";
end
