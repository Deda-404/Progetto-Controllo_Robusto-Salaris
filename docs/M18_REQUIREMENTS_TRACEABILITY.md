# M18 - Matrice finale di tracciabilità

La tabella distingue il completamento del deliverable dall'esito tecnico. Un risultato eseguito ma non conforme resta `FAIL` o `PARTIAL`.

| Requisito | Milestone sorgente | Artifact/documento | Sezione relazione | Stato |
| --- | --- | --- | --- | --- |
| Modello non lineare SEA | M1 | `docs/MODELLO_NON_LINEARE.md`, `src/model/` | cap. 2 | PASS |
| Equilibrio e linearizzazione | M2 | `m2_linearization_nominal.mat` | cap. 3 | PASS |
| Attuatori con ritardo Padé | M3 | `m3_nominal_actuated_plant.mat` | cap. 4 | PASS |
| Incertezze parametriche/dinamiche | M4 | `m4_uncertain_plant.mat` | cap. 5 | PASS |
| Specifiche e pesi | M5 | `m5_performance_specs.mat` | cap. 6 | PASS |
| LQG senza integratore | M6/M8 | artifact M6/M8 | cap. 7 | PASS |
| LQG con integratore finale | M7 | artifact delle tre verifiche manuali | cap. 7 | FAIL - nessuna verifica conforme |
| mixsyn | M9 | `m9_hinf_mixsyn_nominal.mat` | cap. 8 | PARTIAL - gamma > 1, tracking FAIL |
| hinfsyn | M10 | `m10_hinfsyn_nominal.mat` | cap. 8 | PARTIAL - gamma > 1, tracking FAIL |
| hinfstruct | M11 | `m11_hinfstruct_structured.mat` | cap. 8 | PARTIAL - campagna completa, prestazione FAIL |
| mu-analysis A5 | M12 | `m12_mu_analysis_a5.mat` | cap. 9 | PARTIAL - RS/RP FAIL certificati |
| mu-synthesis D-K | M13 | `m13_musyn_dk.mat` | cap. 9 | PASS esecuzione - objective quantificato |
| Post-analisi Kmu | M14 | `m14_final_mu_analysis_kmu.mat` | cap. 9 | PARTIAL - RS PASS, NP/RP FAIL |
| Non lineare Khinf/Kmu | M15 | `m15_nonlinear_robust_validation.mat` | cap. 10 | PARTIAL - tracking FAIL |
| RAS nominale | Lyapunov + M8/M15 | lyapunov_ras_nominal.mat; lyapunov_trajectories.mat; artifact M8/M15 | cap. 7/10 | limite interno analitico sufficiente; livello numerico e mappe empiriche non certificati |
| Monte Carlo incerta lineare | M16 | `m16_monte_carlo_uncertain_linear.mat` | cap. 11 | PASS esecuzione - evidenza empirica |
| Confronto e ruoli finali | M17 | `m17_final_controller_comparison.mat` | cap. 12 | PASS |
| Saturazioni hardware reali | nessuna | non disponibili | cap. 6/13 | NOT RUN |
| Limiti fisici di coppia certificati | nessuna | non disponibili | cap. 13 | NOT RUN |
| Riduzione di Kmu | nessuna | non autorizzata | cap. 9/13 | NOT RUN |
| Relazione tecnica finale | M18 | `report/main.tex`, PDF | intero documento | PASS deliverable |
| Presentazione entro 20 minuti | M18 | sorgente, PDF, outline | presentazione | PASS deliverable - timing stimato 19:00 |
| Audit numerico finale | M18 | `m18_final_deliverable_audit.mat` | appendice B | PASS |

## Classificazione finale

- **Deliverable completed:** relazione, presentazione, manifest, tracciabilità e pipeline M18.
- **Technical requirement passed:** modellistica, linearizzazione, attuatori, M4/M5, LQG nominale, D-K execution, RS Kmu, Monte Carlo eseguita, confronto finale.
- **Technical requirement investigated but failed/partial:** LQG-I, prestazioni H-infinity, NP/RP, tracking robusti, RAS empiriche.
- **Requirement not executed:** saturazioni/limiti hardware reali e riduzione Kmu.
