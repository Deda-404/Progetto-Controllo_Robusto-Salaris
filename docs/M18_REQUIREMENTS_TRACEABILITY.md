# Tracciabilità dei requisiti della traccia

| Requisito | Fonte adottata | Esito |
|---|---|---|
| Modello non lineare, equilibrio, linearizzazione | src/model; m2_linearization_nominal.mat | Verificati |
| Attuatori e modello completo | m3_nominal_actuated_plant.mat | Verificati, 14 stati |
| Incertezze strutturate | m4_uncertain_plant.mat | Verificate, cinque blocchi |
| LQG e LQRI | m6_lqg_no_integrator; m7_augmented_cost_feasibility | Stabili; LQRI non soddisfa tutti i target |
| mixsyn/hinfsyn | hinf_final_coherent/nominal_study | Stesso problema 1-DoF verificato |
| Hinf 2-DoF | selected_full_order.mat | NS/NP PASS; tracking parziale |
| hinfstruct | fixed_study.mat | 66 avvii; minimo ordine osservato 2 |
| mu-analysis e mu-synthesis | m12/m13/m14 nella cartella adottata | Hinf RS FAIL; Kmu RS/RP PASS |
| Non lineare MATLAB e RAS robusti | nonlinear/ras/lyapunov_study | Calcolati con limiti espliciti |
| Monte Carlo comune | monte_carlo_study | LQG 37/40, Hinf 0/40, Kmu 40/40 |
| Simulink originale lineare/non lineare | simulink/originals | PARTIAL: compatibilità e interventi manuali |
| RAS LQG/LQRI sugli originali | non disponibile | Da completare manualmente |
| Esposizione <=20 minuti | OUTLINE_AND_TIMING | Stima 17:15, prova orale da effettuare |

Il completamento della revisione documentale non equivale a conformità completa del progetto.
