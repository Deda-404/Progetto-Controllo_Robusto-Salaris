# Revisione tecnica completa: Q/R, Kalman e Lyapunov nominale

Data: 8–9 settembre 2026.
Progetto: Controllo robusto di un manipolatore SEA, Alessio de Dato e Valerio Rebechi.
Repository: https://github.com/Deda-404/Progetto_CR
Branch: codex/lyapunov-technical-coherence-review.
Baseline: ec93ddfe5e926f02c0373e7cee86236c3460f2eb, merge della PR 26.

La revisione non è un nuovo progetto dei controllori. M5, M6, Khinf e Kmu rimangono congelati. È stato ricostruito il contesto delle decisioni precedenti e verificato lo stato remoto prima delle modifiche. La richiesta corrente supera la sola revisione editoriale: richiede calcoli didattici espliciti e una vera analisi nominale di Lyapunov. Le precedenti istruzioni di sola pubblicazione riguardavano una revisione già integrata e non autorizzano il merge di questa nuova revisione.

Il riferimento metodologico è la traccia e il materiale del corso in Es_MatlabSimulink_Salaris: LQGreg_Synthesis.m per LQR/Kalman/separazione, MixedSensitivity_MIMO_RHZEffects.m per pesi e interconnessioni, ConfrontoModelliIncertezza.m e Mu_Analisys_commented.m per l'incertezza e l'analisi robusta. Non sono state attribuite al docente le sigma del nostro Kalman. Il Drive di riferimento non è stato modificato.

## A. File modificati

L'inventario completo rispetto alla baseline è riportato qui sotto, inclusi sorgenti, risultati generati, copie documentali e i due formati del presente resoconto. I file temporanei in results/tmp sono esclusi dalla consegna. Non sono stati eliminati ulteriori moduli: le rimozioni del refactoring precedente sono già nella baseline.

- `.gitattributes`
- `CHANGELOG.md`
- `README.md`
- `analysis/comparison/plot_m17_final_comparison.m`
- `analysis/finalization/build_m18_figure_manifest.m`
- `analysis/finalization/build_m18_report_tables.m`
- `analysis/finalization/build_technical_revision_tables.m`
- `analysis/finalization/load_m18_validated_artifacts.m`
- `analysis/finalization/validate_m18_deliverables.m`
- `analysis/monte_carlo/plot_m16_results.m`
- `analysis/nominal/plot_m10_results.m`
- `analysis/nominal/plot_m11_results.m`
- `analysis/nominal/plot_m9_results.m`
- `analysis/nominal/regenerate_document_figures.m`
- `analysis/nominal/set_scientific_figure_style.m`
- `analysis/nominal/validate_m2_equilibrium_linearization.m`
- `analysis/nominal/validate_m3_nominal_actuated_plant.m`
- `analysis/nominal/validate_m5_performance_specs.m`
- `analysis/nominal/validate_m6_lqg_no_integrator.m`
- `analysis/nominal/validate_m7_lqg_integral.m`
- `analysis/nonlinear/plot_m15_results.m`
- `analysis/progetto_hinf.m`
- `analysis/progetto_lqg.m`
- `analysis/ras/build_common_ras_comparison.m`
- `analysis/ras/lyapunov_cubic_bound.m`
- `analysis/ras/lyapunov_sample_ratios.m`
- `analysis/ras/plot_lyapunov_ras.m`
- `analysis/ras/sea_closed_loop_rhs.m`
- `analysis/ras/validate_lyapunov_ras.m`
- `analysis/ras/validate_lyapunov_trajectories.m`
- `analysis/ras/validate_m8_simulink_ras.m`
- `analysis/robust/plot_m12_results.m`
- `analysis/robust/plot_m13_results.m`
- `analysis/robust/plot_m14_results.m`
- `analysis/uncertainty/validate_m4_uncertainty_model.m`
- `controllers/lqg/analyze_kalman_sensitivity_m6.m`
- `controllers/lqg/design_kalman_m6.m`
- `docs/DECISION_LOG.md`
- `docs/DIARIO_DI_BORDO.md`
- `docs/FINAL_DELIVERABLE_MANIFEST.md`
- `docs/FINAL_EDITORIAL_AUDIT.md`
- `docs/M18_REQUIREMENTS_TRACEABILITY.md`
- `docs/PROJECT_STATUS.md`
- `docs/REQUIREMENTS_CHECKLIST.md`
- `docs/REVISIONE_TECNICA_LYAPUNOV.md`
- `docs/REVISIONE_TECNICA_LYAPUNOV.txt`
- `presentation/OUTLINE_AND_TIMING.md`
- `presentation/Progetto_CR_Presentazione.pdf`
- `presentation/SPEAKER_NOTES.md`
- `presentation/assets/lyapunov_lqg_section_slide.png`
- `presentation/assets/m10_weighted_comparison_m9.png`
- `presentation/assets/m14_ns_np_rs_rp_summary.png`
- `presentation/assets/m15_tracking_khinf_vs_kmu.png`
- `presentation/assets/m16_empirical_stability_summary.png`
- `presentation/assets/m17_final_tradeoff_summary.png`
- `presentation/assets/m17_m16_stability_tracking.png`
- `presentation/assets/m2_open_loop_poles.png`
- `presentation/assets/m3_delay_pade_comparison.png`
- `presentation/assets/m4_actuator_uncertainty_cover.png`
- `presentation/assets/m5_spec_frequency_map.png`
- `presentation/assets/m6_lqg_reference_tracking.png`
- `presentation/assets/m8_lqg_ras_q_plane.png`
- `presentation/assets/ras_common_comparison.png`
- `presentation/generated/presentation_latex_audit.txt`
- `presentation/main.tex`
- `report/Progetto_CR_Relazione_finale.pdf`
- `report/figures/lyapunov_lqg_section_slide.png`
- `report/figures/lyapunov_ras_certified_sections.png`
- `report/figures/lyapunov_ras_comparison.png`
- `report/figures/m10_weighted_comparison_m9.png`
- `report/figures/m11_gamma_vs_order.png`
- `report/figures/m14_ns_np_rs_rp_summary.png`
- `report/figures/m15_tracking_khinf_vs_kmu.png`
- `report/figures/m16_empirical_stability_summary.png`
- `report/figures/m17_final_tradeoff_summary.png`
- `report/figures/m17_m16_stability_tracking.png`
- `report/figures/m2_open_loop_poles.png`
- `report/figures/m3_delay_pade_comparison.png`
- `report/figures/m4_actuator_uncertainty_cover.png`
- `report/figures/m5_spec_frequency_map.png`
- `report/figures/m6_kalman_sensitivity.png`
- `report/figures/m6_lqg_disturbance_response.png`
- `report/figures/m6_lqg_estimation.png`
- `report/figures/m6_lqg_poles.png`
- `report/figures/m6_lqg_reference_tracking.png`
- `report/figures/m6_lqr_candidate_tradeoff.png`
- `report/figures/m6_lqr_selected_weights.png`
- `report/figures/m7_augmented_cost_tradeoff.png`
- `report/figures/m8_lqg_ras_q_plane.png`
- `report/figures/ras_common_comparison.png`
- `report/generated/figure_manifest.csv`
- `report/generated/figure_manifest.mat`
- `report/generated/figure_manifest.tex`
- `report/generated/kalman_matrices.tex`
- `report/generated/kalman_sensitivity_fixed.tex`
- `report/generated/kalman_slide.tex`
- `report/generated/lqg_poles.tex`
- `report/generated/lqr_matrices.tex`
- `report/generated/lyapunov_sections.tex`
- `report/generated/lyapunov_summary.tex`
- `report/generated/report_latex_audit.txt`
- `report/generated/revision_numeric_audit.csv`
- `report/generated/revision_values.tex`
- `report/main.tex`
- `report/sections/01_introduzione.tex`
- `report/sections/06_specifiche_pesi.tex`
- `report/sections/07_lqg.tex`
- `report/sections/08_hinf.tex`
- `report/sections/10_validazione_nonlineare.tex`
- `report/sections/12_confronto_finale.tex`
- `report/sections/13_conclusioni_limiti.tex`
- `report/sections/B_artifact_traceability.tex`
- `report/sections/C_riproducibilita.tex`
- `report/tables/limitations.tex`
- `results/data/didactic_hinf_calculations.mat`
- `results/data/didactic_lqg_calculations.mat`
- `results/data/lyapunov_ras_nominal.mat`
- `results/data/lyapunov_trajectories.csv`
- `results/data/lyapunov_trajectories.mat`
- `results/data/m17_final_controller_comparison.mat`
- `results/data/m18_final_deliverable_audit.mat`
- `results/data/m2_linearization_nominal.mat`
- `results/data/m3_nominal_actuated_plant.mat`
- `results/data/m4_uncertain_plant.mat`
- `results/data/m5_performance_specs.mat`
- `results/data/m6_lqg_no_integrator.mat`
- `results/data/m7_augmented_cost_feasibility.mat`
- `results/data/m7_lqg_integral.mat`
- `results/data/ras_common_comparison.mat`
- `results/data/revision_code_analyzer.csv`
- `results/data/revision_test_results.csv`
- `results/data/revision_test_results.mat`
- `results/data/revision_test_results_io_failure.csv`
- `results/data/revision_test_results_io_failure.mat`
- `results/figures/lyapunov_lqg_section_slide.png`
- `results/figures/lyapunov_ras_certified_sections.png`
- `results/figures/lyapunov_ras_comparison.png`
- `results/figures/m10_closed_loop_poles_comparison.png`
- `results/figures/m10_control_effort_comparison.png`
- `results/figures/m10_disturbance_comparison_m6_m9.png`
- `results/figures/m10_hinfsyn_frequency_domain.png`
- `results/figures/m10_tracking_comparison_m6_m9.png`
- `results/figures/m10_weighted_comparison_m9.png`
- `results/figures/m11_effort_disturbance_comparison.png`
- `results/figures/m11_gamma_start_dispersion.png`
- `results/figures/m11_gamma_vs_order.png`
- `results/figures/m11_pareto_gamma_order.png`
- `results/figures/m11_tracking_pareto_comparison.png`
- `results/figures/m11_weighted_pareto_vs_m10.png`
- `results/figures/m14_mu_rs_bounds_kmu_vs_a5.png`
- `results/figures/m14_nominal_weighted_a5_vs_kmu.png`
- `results/figures/m14_ns_np_rs_rp_summary.png`
- `results/figures/m14_rs_margins_a5_vs_kmu.png`
- `results/figures/m14_rs_sensitivity_a5_vs_kmu.png`
- `results/figures/m14_worst_case_weighted_kmu.png`
- `results/figures/m15_control_effort_khinf_vs_kmu.png`
- `results/figures/m15_disturbance_khinf_vs_kmu.png`
- `results/figures/m15_lti_nl_agreement_regions.png`
- `results/figures/m15_lti_nl_tracking_khinf.png`
- `results/figures/m15_lti_nl_tracking_kmu.png`
- `results/figures/m15_nonlinear_summary_metrics.png`
- `results/figures/m15_ras_m6_khinf_kmu.png`
- `results/figures/m15_tracking_khinf_vs_kmu.png`
- `results/figures/m16_control_effort_distribution.png`
- `results/figures/m16_cross_coupling_distribution.png`
- `results/figures/m16_diagonal_bandwidth_distribution.png`
- `results/figures/m16_disturbance_distribution.png`
- `results/figures/m16_empirical_stability_summary.png`
- `results/figures/m16_m14_certificate_empirical_consistency.png`
- `results/figures/m16_max_real_closed_loop_pole.png`
- `results/figures/m16_paired_controller_differences.png`
- `results/figures/m16_tracking_distribution.png`
- `results/figures/m17_control_effort_comparison.png`
- `results/figures/m17_controller_complexity.png`
- `results/figures/m17_final_tradeoff_summary.png`
- `results/figures/m17_m16_stability_tracking.png`
- `results/figures/m17_nominal_nonlinear_tracking.png`
- `results/figures/m17_ras_comparison.png`
- `results/figures/m17_stability_evidence_summary.png`
- `results/figures/m2_open_loop_poles.png`
- `results/figures/m3_actuator_bode.png`
- `results/figures/m3_delay_pade_comparison.png`
- `results/figures/m3_full_plant_sigma.png`
- `results/figures/m4_actuator_uncertainty_cover.png`
- `results/figures/m4_uncertain_plant_samples.png`
- `results/figures/m5_spec_frequency_map.png`
- `results/figures/m5_weight_W1.png`
- `results/figures/m5_weight_W2.png`
- `results/figures/m6_kalman_sensitivity.png`
- `results/figures/m6_lqg_disturbance_response.png`
- `results/figures/m6_lqg_estimation.png`
- `results/figures/m6_lqg_poles.png`
- `results/figures/m6_lqg_reference_tracking.png`
- `results/figures/m6_lqr_candidate_tradeoff.png`
- `results/figures/m6_lqr_selected_weights.png`
- `results/figures/m7_augmented_cost_tradeoff.png`
- `results/figures/m8_lqg_ras_q_plane.png`
- `results/figures/ras_common_comparison.png`
- `results/figures/ras_khinf_common.png`
- `results/figures/ras_kmu_common.png`
- `results/figures/ras_lqg_common.png`
- `src/parameters/finalization_specs_m18.m`
- `tests/test_didactic_entry_points.m`
- `tests/test_lyapunov_ras.m`
- `tests/test_m18_final_deliverables.m`
- `tools/build_m18_latex.ps1`

## B. Q e R

Lo stato M3 è x=[dq;dqdot;dtheta;dthetadot;xa], con 8 stati meccanici e 6 stati della realizzazione attuativa. I sei xa non sono posizioni fisiche e non ricevono una scala meccanica inventata.

Le uscite del costo sono v=F x=[dq;dqdot;dtheta-dq;dthetadot]. Si usa Sx=diag(qs I2,qds I2,ds I2,tds I2), con:

- qs=5*pi/180=0.0872664626 rad: scala dell'ampiezza di riferimento M5, NON peso di tuning;
- qds=omegaB*qs=1.04719755 rad/s;
- ds=disturbanceTorqueAmplitude/min(diag(Ks))=0.5/40=0.0125 rad;
- tds=qds: stessa scala cinematica adottata per i motori;
- Su=12 I2 N m: scala prestazionale M5, non saturazione o limite nominale certificato.

Le scale dipendono da parametri della traccia e da scelte progettuali M5; non sono tutti dati imposti dal docente. I pesi adimensionali sono invece Wq=diag(wq I2,wv I2,wdelta I2,wv I2) e Wu=rhoU I2.

Il costo normalizzato è J=integrale(x'Qx+u'Ru)dt, con
Q=F' Sx^(-T) Wq Sx^(-1) F e R=Su^(-T) Wu Su^(-1).

È riprodotta la ricerca approvata:
wq=[0.5,1,2], wv=[0.5,1], wdelta=[0.1,0.5], rhoU=[4,8,16].
Sono 36 combinazioni. Per ogni candidato si calcolano LQR e prefiltro, stabilità e due risposte a gradino nominali da stato nullo su 0:0.002:3 s. Sono obbligatori poli<-1e-8, Ts<=0.8 s, overshoot<=10%, errore statico relativo<=0.05 e residuo del prefiltro finito.

Lo score già esistente è:
0.30 Ts/0.8 + 0.20 OS/10 + 0.10 ess/0.05 + 0.10 cross/0.25
+ 0.15 peakU/12 + 0.15 rmsU/12.
Cross-coupling e comando contribuiscono al compromesso ma non diventano nuovi vincoli hard.

Risultato invariato: 9/36 ammissibili, LQR30, wq=2, wv=1, wdelta=0.1, rhoU=16; score 0.394292252. Q=blkdiag(Q8,zeros(6)), con diagonale Q8 circa
[902.6245,902.6245,0.91189,0.91189,640,640,0.91189,0.91189].
Gli elementi simmetrici (1,5),(5,1),(2,6),(6,2) sono -640; gli altri fuori diagonale sono nulli. Q NON è diagonale, perché viene pesata la deformazione theta-q. R=I2/9.

MATLAB risolve A'Plqr+Plqr A-Plqr B R^(-1) B'Plqr+Q=0, K=R^(-1)B'Plqr. Il residuo CARE è 2.912849e-10, il massimo reale dei poli A-BK è -6.171691 s^-1. K completo, Q, R e Nr sono generati in report/generated/lqr_matrices.tex e stampati nella relazione; la doppia precisione resta nell'artifact didactic_lqg_calculations.mat. Il prefiltro Nr ha righe circa [51.688,-1.1626] e [3.2384,49.052].

## C. Kalman

LQR richiede lo stato; gli encoder forniscono soltanto y=[dq;dtheta]. Il modello è
xdot=Ax+Bu+Gw w, y=Cx+v, Gw=[Bd B].
L'osservatore è xhatdot=A xhat+Bu+L(y-C xhat); l'innovazione confronta previsione e misura.

sigmaD=sigmaU=0.1 N m, sigmaY=0.05 gradi sono IPOTESI PROGETTUALI, non dati del docente o misure sperimentali. I rapporti con M5 (20% del disturbo, 0.83% della scala di comando, 1% del riferimento) contestualizzano le scelte già esistenti, senza inventarne una derivazione fisica univoca.

Qn=diag(sigmaD²,sigmaD²,sigmaU²,sigmaU²)=0.01 I4.
Rn=(0.05*pi/180)² I4=7.615435e-7 I4.
La varianza è sigma²; Qn agisce sui quattro canali di processo, non direttamente sui 14 stati. Sono assunte indipendenza e correlazione processo-misura nulla.

Nel filtro continuo lqe questi valori sono intensità, non varianze istantanee di rumore bianco ideale. Le sigma sono scale equivalenti nella convenzione di riferimento temporale 1 s. La prova randn campionata a 2 ms non è presentata come identificazione di tali intensità.

L=lqe(A,Gw,C,Qn,Rn) ha dimensione 14x4; è stampata integralmente in report/generated/kalman_matrices.tex. Tutti i poli A-LC sono stabili; velocità dominante 9.318740 s^-1, rapporto rispetto al regolatore 1.5099. Poli completi in lqg_poles.tex.

Sensibilità: si varia la sigmaY ASSUNTA, mantenendo lo stesso rumore applicato, stesso riferimento di 5 gradi sul primo giunto, stato nullo, nessun disturbo di coppia, 4 s a 2 ms, seed 20260826.

| Fattore sigmaY assunto | Velocità stimatore/regolatore | RMS errore q [rad] | RMS variazione u [N m] | Norma H2 della mappa di rumore |
| ---: | ---: | ---: | ---: | ---: |
| 0.5 | 2.1121 | 0.00029595 | 0.14321 | 1065.8 |
| 1 | 1.5099 | 0.00023377 | 0.078352 | 718.29 |
| 2 | 1.1922 | 0.00018109 | 0.040973 | 486.49 |

Maggiore fiducia nelle misure produce qui uno stimatore più rapido ma più rumore sul comando. Non si afferma monotonia universale di ogni polo MIMO. Le colonne storiche che variavano anche l'ampiezza applicata sono conservate e distinte dalle nuove colonne FixedNoise.

La legge LQG è u=-K xhat+Nr r. Nelle coordinate [x;e=x-xhat] la chiusura è triangolare con blocchi A-BK e A-LC; residuo della trasformazione 2.094409e-13. K e L non sono stati ritoccati.

## D. RAS Lyapunov

Il modello è nominale non lineare SEA, in deviazione dall'equilibrio superiore [pi/2;0], con attuatori M3 Padé 1, r=d=v=0 e senza saturazione.

Per LQG:
Acl=[A,-BK;LC,A-BK-LC], n=28.
Per il controllore dinamico K con matrici Ak,Bk,Ck,Dk:
Acl=[A-BDkCq,BCk;-BkCq,Ak], n=32 per Khinf e 66 per Kmu.
Non sono omessi gli stati interni e non si usano cancellazioni per dimostrare stabilità.

Si pone QL=I, P=lyap(Acl',QL), si simmetrizza P e si controllano positività e residuo. La convenzione MATLAB è documentata: lyap(A,Q) risolve A P+P A'=-Q.
V=z'Pz; nel non lineare Vdot=2 z'P fcl(z).

All'equilibrio superiore il resto non lineare agisce solo sulle accelerazioni dei link:
fcl(z)=Acl z+E r(z), E=I(:,3:4).
Dalle disuguaglianze su M^-1, 1-cos(q2), Coriolis e sin(t)-t si ricava analiticamente ||r(z)||<=c||z||³, c circa 18893. Non è un fit su dati simulati.

Definiti epsilon=||Acl'P+P Acl+I|| e delta²=(1-epsilon)/(4||PE||c),
rhoA=lambdaMin(P)*delta² garantisce per V<=rhoA:
Vdot<=-(1-epsilon)/2 ||z||²<0 fuori dall'origine.
È una regione interna sufficiente positivamente invariante, non la RAS massima.

| Controllore | n | lambdaMin(P) | lambdaMax(P) | residuo | rhoA analitico | rhoS campionato |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| LQG | 28 | 0.0017341 | 746.82 | 5.20e-10 | 6.0044e-9 | 1.1919 |
| Khinf | 32 | 0.00047344 | 4578.2 | 3.04e-9 | 3.5414e-10 | 3.7315 |
| Kmu | 66 | 4.0188e-5 | 5638.3 | 1.98e-8 | 2.9332e-11 | 3.9944 |

Le matrici complete Acl, QL, P e il modello non lineare sono in results/data/lyapunov_ras_nominal.mat. P è anche definita univocamente dall'integrale exp(Acl't) exp(Acl t) dt riportato in relazione; sono stampate le matrici 2x2 H=J'PJ per le sezioni.

La ricerca numerica usa 512 direzioni gaussiane, ±assi e 72 direzioni del piano q; quattro raggi [0.25,0.5,0.75,1]; 49 livelli logaritmici, margine Vdot/||z||²<-0.05, 12 bisezioni geometriche e fattore finale 0.8. Si scarta ogni valore non finito. Il tetto rhoMax mantiene gli angoli nell'ellissoide entro ±60 gradi. Seed ricerca 20260908+k; verifica indipendente 20261008+k, k=1,2,3.

I punti della verifica indipendente sono 8192 per controllore. Massimi di Vdot/||z||²: -0.98976, -0.80522, -0.99636. Questi successi NON certificano rhoS. Solo rhoA beneficia della maggiorazione analitica.

La sezione usa z=J*dq, dtheta=dq, velocità e stati attuativi/controllore nulli. Non è una proiezione, né un piano invariante. I semiassi analitici sono:
LQG [2.2644e-4,3.3199e-4] gradi;
Khinf [6.1077e-5,8.2851e-5] gradi;
Kmu [1.6173e-5,2.0849e-5] gradi.

Sono state integrate 48 traiettorie: 3 controllori x 2 livelli x 8 direzioni, ode23t per 8 s, RelTol=1e-8, AbsTol=1e-13, MaxStep=0.005. Il massimo V(8)/V(0) è 7.155528e-7; massimo incremento relativo 7.369284e-22, vicino al roundoff. I test usano margine numerico 1e-8 e diagnostica finale V(8)/V(0)<1e-3. Questi criteri finiti non sono la dimostrazione analitica.

Portata: modello nominale esatto assunto, con numeri valutati in double e residui controllati. Non è una verifica intervallare degli arrotondamenti, un certificato del ritardo esatto, del modello non lineare incerto M4, dell'hardware o della RAS globale. I valori rho dipendono dalle coordinate e non sono uno score fra controllori.

## E. progetto_lqg.m

Riscrittura in 22 sezioni, leggibile dall'alto al basso:
caricamento → stato e PBH/ranghi → M5 → scale → F/Sx/Wq/Q → ricerca approvata → Su/Wu/R → lqr/CARE/K → stabilità → modello dei rumori → Qn/Rn → lqe/L/poli → sensibilità identica → LQG/separazione → tracking/stima/comando → non lineare → Lyapunov analitico → ricerca numerica esplicita → sezioni → limiti.

I parametri della ricerca sono visibili nello script; le funzioni riutilizzate hanno compiti matematici circoscritti (modello non lineare, maggiorazione del resto, valutazione di Vdot). Non si richiede di inseguire una catena di sintesi opache. L'output completo dei calcoli è salvato in didactic_lqg_calculations.mat. Script eseguito anche dopo le ultime correzioni.

## F. progetto_hinf.m

Riscrittura in 19 sezioni:
modello e M4 → obiettivo energetico → segnali → W1/W2 → formule/asintoti/crossover → generalized plant connect e formula indipendente → comando storico hinfsyn visibile ma non eseguito → Khinf congelato → matrice completa e norma pesata → tracking → tre campioni illustrativi → S/T/KS → comando → non lineare → Lyapunov → ricerca rho → sezione e conclusioni.

Crossover |W1|=1: 13.839075 rad/s; polo/zero W1 0.6/24. W2 ha zero/polo 30/180 e guadagno fra 1/12 e 1/2, quindi NESSUN crossover unitario. Il bound 1/|W2| riguarda KS e non un picco assoluto di coppia.

Gamma congelato 10.20710365; norma indipendente 10.20710339; ||W1S||inf=10.127625 e ||W2KS||inf=10.184692. Chiusa completa stabile, max Re=-0.68382856, prestazione pesata FAIL. Le tre realizzazioni usample sono solo didattiche e non modificano M16. Script eseguito; nessuna nuova hinfsyn, mixsyn, hinfstruct o musyn.

## G. Figure

Tutti i generatori che producono figure usate dai documenti applicano esplicitamente sfondo bianco e assi, etichette, titoli, legende e colorbar neri. Dati, curve e scala scientifica non sono modificati per ottenere un esito migliore. Le figure robuste e Monte Carlo sono rigenerate dai dati congelati.

Il manifest finale contiene 24 asset selezionati, con uso nelle slide derivato dal sorgente. Include 22 figure effettivamente richiamate nei capitoli, una figura Lyapunov specifica per le slide e il vecchio asset M8 disponibile per consultazione. Le copie in report/figures e presentation/assets derivano dalle sorgenti in results/figures.

Le 67 immagini sorgenti nuove o rigenerate sono:

- `results/figures/lyapunov_lqg_section_slide.png`
- `results/figures/lyapunov_ras_certified_sections.png`
- `results/figures/lyapunov_ras_comparison.png`
- `results/figures/m10_closed_loop_poles_comparison.png`
- `results/figures/m10_control_effort_comparison.png`
- `results/figures/m10_disturbance_comparison_m6_m9.png`
- `results/figures/m10_hinfsyn_frequency_domain.png`
- `results/figures/m10_tracking_comparison_m6_m9.png`
- `results/figures/m10_weighted_comparison_m9.png`
- `results/figures/m11_effort_disturbance_comparison.png`
- `results/figures/m11_gamma_start_dispersion.png`
- `results/figures/m11_gamma_vs_order.png`
- `results/figures/m11_pareto_gamma_order.png`
- `results/figures/m11_tracking_pareto_comparison.png`
- `results/figures/m11_weighted_pareto_vs_m10.png`
- `results/figures/m14_mu_rs_bounds_kmu_vs_a5.png`
- `results/figures/m14_nominal_weighted_a5_vs_kmu.png`
- `results/figures/m14_ns_np_rs_rp_summary.png`
- `results/figures/m14_rs_margins_a5_vs_kmu.png`
- `results/figures/m14_rs_sensitivity_a5_vs_kmu.png`
- `results/figures/m14_worst_case_weighted_kmu.png`
- `results/figures/m15_control_effort_khinf_vs_kmu.png`
- `results/figures/m15_disturbance_khinf_vs_kmu.png`
- `results/figures/m15_lti_nl_agreement_regions.png`
- `results/figures/m15_lti_nl_tracking_khinf.png`
- `results/figures/m15_lti_nl_tracking_kmu.png`
- `results/figures/m15_nonlinear_summary_metrics.png`
- `results/figures/m15_ras_m6_khinf_kmu.png`
- `results/figures/m15_tracking_khinf_vs_kmu.png`
- `results/figures/m16_control_effort_distribution.png`
- `results/figures/m16_cross_coupling_distribution.png`
- `results/figures/m16_diagonal_bandwidth_distribution.png`
- `results/figures/m16_disturbance_distribution.png`
- `results/figures/m16_empirical_stability_summary.png`
- `results/figures/m16_m14_certificate_empirical_consistency.png`
- `results/figures/m16_max_real_closed_loop_pole.png`
- `results/figures/m16_paired_controller_differences.png`
- `results/figures/m16_tracking_distribution.png`
- `results/figures/m17_control_effort_comparison.png`
- `results/figures/m17_controller_complexity.png`
- `results/figures/m17_final_tradeoff_summary.png`
- `results/figures/m17_m16_stability_tracking.png`
- `results/figures/m17_nominal_nonlinear_tracking.png`
- `results/figures/m17_ras_comparison.png`
- `results/figures/m17_stability_evidence_summary.png`
- `results/figures/m2_open_loop_poles.png`
- `results/figures/m3_actuator_bode.png`
- `results/figures/m3_delay_pade_comparison.png`
- `results/figures/m3_full_plant_sigma.png`
- `results/figures/m4_actuator_uncertainty_cover.png`
- `results/figures/m4_uncertain_plant_samples.png`
- `results/figures/m5_spec_frequency_map.png`
- `results/figures/m5_weight_W1.png`
- `results/figures/m5_weight_W2.png`
- `results/figures/m6_kalman_sensitivity.png`
- `results/figures/m6_lqg_disturbance_response.png`
- `results/figures/m6_lqg_estimation.png`
- `results/figures/m6_lqg_poles.png`
- `results/figures/m6_lqg_reference_tracking.png`
- `results/figures/m6_lqr_candidate_tradeoff.png`
- `results/figures/m6_lqr_selected_weights.png`
- `results/figures/m7_augmented_cost_tradeoff.png`
- `results/figures/m8_lqg_ras_q_plane.png`
- `results/figures/ras_common_comparison.png`
- `results/figures/ras_khinf_common.png`
- `results/figures/ras_kmu_common.png`
- `results/figures/ras_lqg_common.png`

## H. Relazione

PDF: report/Progetto_CR_Relazione_finale.pdf, 63 pagine. Sorgenti modificati:

- Sommario: aggiunta la portata della verifica Lyapunov nominale.
- 1.3: nuova classe di evidenza nominale analitica, distinta da simulazione e mu.
- 6.3: formula del crossover W1; 6.4: zero/polo W2 e interpretazione corretta del bound sul guadagno KS.
- 7.1: stato misurato e architettura effettiva.
- 7.2.1–7.2.6: costo, unità, scale/provenienza di qs, F/Sx/Wq, Q non diagonale, Su/Wu/R, ricerca/criteri, matrici complete e CARE.
- 7.3.1–7.3.4: osservatore, ipotesi stocastiche e sigma², intensità continue, L/poli, sensibilità a rumore identico, separazione.
- 7.4.1–7.4.4: tracking, disturbo, errore di stima/comando, poli; ogni figura esplicita assi, ingressi, condizioni iniziali, curve e interpretazione.
- 8.4: percorso didattico e distinzione fra la sintesi storica e la verifica attuale di Khinf.
- 10.3: matrici aumentate, lyap, P, V e Vdot; 10.4: maggiorazione analitica e rhoA; 10.5: ricerca numerica e limiti; 10.6: sezioni, grafici e 48 traiettorie.
- 10.7–10.11: conservate e coordinate le evidenze empiriche preesistenti, senza trasformarle in certificati.
- 12.4: regioni analitiche non classificabili mediante rho e confronto empirico M17 distinto.
- 13.2–13.4: conseguenze, limiti e sviluppi della verifica nominale.
- Appendice B: nuovi dati/macro e manifest effettivo; Appendice C.2–C.4: sequenza congelata e stato NOT RUN di run_all nella revisione.
- 6 nuove tabelle/matrici, 12 macro della revisione e tabella Kalman sintetica per le slide, tutte generate da MATLAB.

Compilazione e audit: zero errori, riferimenti irrisolti, overfull hbox/vbox e destinazioni duplicate. Ispezionate tutte le pagine con rendering e poi in dettaglio le pagine modificate.

## I. Presentazione

PDF: presentation/Progetto_CR_Presentazione.pdf, 19 slide 16:9; timing stimato 19:00, non durata cronometrata.

- Slide 6: cross-coupling qualificato come diagnostico, pesi congelati e uScale non saturazione.
- Nuova slide 7: scale fisiche contro pesi, Q/R e Riccati.
- Nuova slide 8: ipotesi Kalman, Qn/Rn, stessa sequenza di rumore e separazione.
- Slide 9: risultato LQG congelato; slide 10: M7 negativo preservato.
- Slide 11: H-infinity con gamma>1 conservato.
- Slide 13: titolo accorciato e distinzione RS/NP/RP leggibile.
- Slide 15: Lyapunov completo, QL=I, P>0, V/Vdot/Omega, sezione analitica LQG e limiti.
- Slide 16: conteggi M16 e casi instabili preservati; titolo accorciato.
- Slide 19: Lyapunov nominale conservativo e Monte Carlo empirica.
- Altre slide: ordine aggiornato e figure rigenerate, senza nuove conclusioni numeriche.
- Note orali e outline: 19 voci coerenti, nuove spiegazioni e FAQ Lyapunov; 19:00.

## J. Test e coerenza

- Test mirati nuovi/aggiornati: 50/50 PASS.
- Prima suite completa: 644/644 PASS, 0 falliti e 0 incompleti; risultati per test in results/data/revision_test_results.csv/.mat.
- Ultima riesecuzione isolata dopo tutte le correzioni: 644/644 PASS, 0 falliti e 0 incompleti, 68.4859 s di tempo test.
- Ultima verifica dedicata M18: 60/60 PASS, 0 falliti e 0 incompleti, 11.0632 s; eseguita dopo la regressione completa per riallineare gli asset documentali.
- Confronto SHA-256: 24 figure del manifest nella relazione e 10 selezionate nelle slide identiche alle sorgenti validate. Entrambi i PDF sono stati ricompilati dopo questa sincronizzazione, con audit PASS.
- MATLAB Code Analyzer: 172 file di progetto, 0 segnalazioni dopo correzione; dettaglio per file in results/data/revision_code_analyzer.csv.
- Script didattici LQG/H-infinity: eseguiti e rieseguiti con successo; validate_lyapunov_ras e validate_lyapunov_trajectories eseguiti.
- Jacobiano completo, P positiva, equazione di Lyapunov, bound del resto, margine analitico, sezione, campionamento, input non validi e traiettorie: controlli reali inclusi nei test.
- Figure: rigenerazione eseguita; test dello stile idempotente senza modifica dei dati.
- M5 confrontata con l'artifact della baseline Git: specifiche e pesi identici; Q/R/K/L M6 identici entro le tolleranze dichiarate.
- M10, M13, M14 e M16: artifact identici byte per byte alla baseline.
- PDF: audit LaTeX PASS per entrambi e controllo visivo completo/mirato.
- git diff --check: PASS.
- run_all: NOT RUN deliberatamente, perché il percorso integrale rilancerebbe le sintesi M9–M11. La suite e le verifiche mirate non sono spacciate per un'esecuzione integrale di run_all.
- Il generatore M18 marca fullRegression=NOT RUN perché non esegue la suite: l'esito reale viene registrato separatamente.
- Nessuna nuova ottimizzazione robusta; nessuna riduzione, modifica di equilibrio, pesi o architetture.

Una riesecuzione intermedia ha restituito 631 PASS e 13 failed/incomplete: il setup M6 non riusciva ad aprire il PNG m6_lqr_selected_weights.png (MATLAB:imagesci:png:libraryFailure). Il file era successivamente accessibile anche in modalità esclusiva. L'errore I/O, di causa specifica non dimostrata, è conservato in revision_test_results_io_failure.csv/.mat; non viene confuso con il fallimento di un criterio di controllo. È stata disposta una nuova esecuzione senza altre letture o scritture sulle figure.

Gli errori iniziali di esportazione char/string, escaping LaTeX, una riga fuori margine e i tre avvisi statici sono registrati nel diario. Non sono occultati: le correzioni sono state rieseguite. La prima suite PASS non è stata usata per nascondere il successivo FAIL del controllo statico.

Hash Git invariati degli artifact:
M10 8ca076e5d07b88594db3c87984710571e13c2813;
M13 b9dd02500c7ce70e401f149830746ba4de4a8b30;
M14 f49b13189eb18af77836fa8f6a378205e471b8d2;
M16 90b656a5c13c5ddafd7cf6498d4d551918557733.

## K. Criticità residue e consegna

1. La regione Lyapunov analitica è sufficiente e molto conservativa; il livello campionato non è certificato e la RAS massima non è nota.
2. Il calcolo usa doppia precisione e residui, non aritmetica intervallare. La garanzia matematica è relativa al modello nominale specificato, non una prova formale degli errori di arrotondamento.
3. Nessuna certificazione non lineare incerta M4, del ritardo esatto o dell'hardware; nessun limite attuativo inventato.
4. QL=I e rho dipendono dalle coordinate della realizzazione; rho non misura quale controllore sia migliore.
5. Le sigma Kalman sono assunzioni non identificate sperimentalmente. La sensibilità non determina la covarianza fisica vera.
6. M7 resta PARTIAL, Khinf e Kmu falliscono tracking M5; Kmu passa RS ma fallisce NP/RP.
7. M16 resta empirica: M6 38/40, due casi instabili, Khinf/Kmu 40/40 non sono probabilità o nuovi certificati.
8. Kmu resta ordine 52; non è stata autorizzata una riduzione.
9. Matricole degli autori e data di consegna devono ancora essere inserite manualmente.
10. Alla chiusura tecnica locale non era stato eseguito push, aperta una nuova PR o effettuato merge. La successiva richiesta del gruppo autorizza la pubblicazione del branch, non il merge. Dopo il rifiuto del primo push per il MAT da 248 MiB, le traiettorie vengono conservate integralmente tramite Git LFS; vedere README e decisione D-0047. Codice, risultati e PDF restano invariati.

Per riprodurre la revisione usare la sequenza congelata nel README, non rilanciare le sintesi storiche. La convenzione di lyap è verificabile anche nella documentazione ufficiale MathWorks: https://www.mathworks.com/help/control/ref/lyap.html
