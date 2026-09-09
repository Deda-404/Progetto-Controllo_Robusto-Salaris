function regenerate_document_figures
%REGENERATE_DOCUMENT_FIGURES Rigenera i grafici senza nuove sintesi robuste.
% I plot M10-M17 riusano i controllori e le campagne congelate, non musyn,
% hinfsyn, hinfstruct o una nuova sequenza Monte Carlo ufficiale M16.
root=string(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(genpath(fullfile(root,'src')),genpath(fullfile(root,'controllers')), ...
    genpath(fullfile(root,'analysis')));
validate_m2_equilibrium_linearization;
validate_m3_nominal_actuated_plant;
validate_m4_uncertainty_model;
validate_m5_performance_specs;
validate_m6_lqg_no_integrator;
validate_m7_lqg_integral;
validate_m8_simulink_ras(false,true);
e=load_m18_validated_artifacts;
fig=char(fullfile(root,'results','figures'));
plant=build_m9_nominal_plant(e.m3,e.m5,hinf_specs_m10);
sintesi=e.m10; sintesi.controllerOrder=order(e.m10.Khinf);
ricostruzione=reconstruct_m10_closed_loop(plant.G,plant.Gd, ...
    e.m5.W1,e.m5.W2,sintesi,hinf_specs_m10);
valutazione=evaluate_m10_closed_loop(ricostruzione,sintesi,plant, ...
    e.m5,e.m6,e.m9,hinf_specs_m10);
plot_m10_results(ricostruzione,valutazione,e.m5,e.m9,fig);
scelta=select_m11_pareto_candidates(e.m11.campaign,e.m11.config);
audit=evaluate_m11_candidate(e.m10.Khinf,e.m10.gammaHinf,e.m10.P, ...
    plant.G,plant.Gd,e.m5.W1,e.m5.W2,e.m10.gammaHinf,e.m11.config);
alias=struct('controllerOrder',order(e.m10.Khinf));
valutazioneM10=evaluate_m9_closed_loop(audit,e.m5,e.m6,alias,e.m11.config);
plot_m11_results(e.m11.campaign,scelta,e.m11.representativeResults, ...
    e.m10,valutazioneM10,e.m11.comparisonM6M9M10M11,fig,e.m11.config);
plot_m14_results(e.m12,e.m14.manualMuRS,e.m14.nominalReconstruction, ...
    e.m14.robustStability,e.m14.robustPerformance,e.m14.criticalBlockTable, ...
    e.m14.summaryNSNPRSRP,fig,e.m14.config);
plot_m15_results(e.m15.trackingResults,e.m15.disturbanceResults, ...
    e.m15.rasResults,e.m15.agreementResults,e.m15.controllerComparison, ...
    e.m15.m6FrozenRasReference,fig);
build_common_ras_comparison(root,true);
riassunto=summarize_m16_monte_carlo(e.m16.stabilityTable,e.m16.bandwidthTable, ...
    e.m16.trackingTable,e.m16.disturbanceTable,e.m5.spec,e.m16.config);
plot_m16_results(riassunto,e.m16.stabilityTable,e.m16.trackingTable, ...
    e.m16.disturbanceTable,e.m16.m14Consistency,root,e.m16.config);
validate_m17_final_comparison(true);
lyap=load(fullfile(root,'results','data','lyapunov_ras_nominal.mat'));
plot_lyapunov_ras(lyap.risultati,char(root));
build_technical_revision_tables(root);
fprintf('Figure documentali rigenerate con sfondo bianco e testi neri.\n');
end
