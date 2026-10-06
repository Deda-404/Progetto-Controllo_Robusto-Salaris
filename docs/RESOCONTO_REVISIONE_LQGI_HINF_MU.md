# Resoconto della revisione LQGI / H∞ / µ — 6 ottobre 2026

Base Git: 283193e, con PR #34 integrata. Ramo: `codex/revisione-lqgi-hinf-mu`. La revisione MATLAB, risultati, relazione e slide supera il gate **PASS**; la conformità complessiva resta **PARTIAL** per gli originali Simulink e i target prestazionali dichiarati. Non è stata ripetuta alcuna sintesi robusta.

## 1. File modificati

L'elenco completo, incluse aggiunte, rinomine, risultati binari e PDF, è riportato in fondo. Fonti principali: nuovi validatori/simulatore LQGI, esportatori, sette test, capitoli 7–10 e conclusioni, appendici, presentazione, manifest degli originali e documentazione. Cache, download dei colleghi, rendering e file temporanei restano esclusi dal commit.

## 2. Correzione LQGI

La denominazione precedente era imprecisa, ma la chiusura MATLAB M7 già usava **lo stato stimato**, non il vero stato della pianta. Non è stato sostituito un LQR con un nuovo regolatore né alterato il costo per migliorarne le metriche. Rinominati sorgenti, funzioni, campi correnti `Klqgi`, tabelle e figure; adeguati consumatori e test. Conservati nomi SLX e archivi storici come provenienza.

Architettura finale: pianta con 14 stati; quattro misure `[Δq;Δθ]+v`; Kalman M6 con 14 stime; due integratori `xi_dot=r-q_measured`; comando `u=-Kx*xhat-Ki*xi`. Controllore 16 stati, chiusura 30. `L`, `Qn`, `Rn`, `Kx`, `Ki`, Q/R/Qi e tre pesi integrali 20/200/800 invariati. La verifica numerica di identità dei guadagni e quella byte per byte delle fonti protette sono passate.

Il nuovo simulatore integra le equazioni SEA, gli attuatori e lo stesso controllore. Il comando fisico è coppia di equilibrio più incremento. Rumore encoder presente sia nell'innovazione sia nell'integratore; quattro rumori di processo su link e ingresso degli attuatori, ignoti direttamente al Kalman. Nessuna saturazione, anti-windup o retuning.

Ricalcolati M7 lineare, sei tracking non lineari (2/5/8 gradi, due giunti), sei disturbi (0.25/0.5/1 N m, due link), equilibrio, tre prove di rumore e ripetizione, chiusure lineari ZOH equivalenti e RAS empirica. Tracking lineare peggiore 5.046 s; offset DC dei disturbi nullo; polo dominante −0.8214368 s⁻¹. Per 0.5 N m, deviazione non lineare massima 0.127079 rad, comando massimo 1.298471 N m, RMS massimo 0.447078 N m, residuo massimo a 8 s 0.000170906 rad. Il residuo finito non è il guadagno DC.

Rumore: 4 s, riferimento 5 gradi, seed 20260826, campioni indipendenti ZOH a 2 ms; encoder 0.05 gradi, processo 0.1 N m. Le intensità continue lqe non vengono confuse con le varianze dei campioni. Con soli encoder il picco è 0.894511 N m e RMS 0.438260 N m. Integrando separatamente gli intervalli ZOH, massimo scarto lineare/non lineare 4.6870e-5 rad; ripetizione identica. RAS: 57/57 punti convergenti, raggi 60–78.3244 gradi, picco 240.2349 N m, dominio esplorato esaurito; nessuna frontiera fisica o certificazione hardware identificata.

## 3. Scelta di omega_M = 4

Trovati tre controllori 2-DoF già sintetizzati in `results/data/hinf_final_coherent/nominal_study.mat`; tutti di ordine 22. `export_hinf_readable_figures.m` li rivaluta sullo stesso modello, con due gradini da 5 gradi e prove separate di disturbo. Metriche ricalcolate corrispondenti alle salvate entro 1e-9. Nessuna nuova hinfsyn.

| omega_M [rad/s] | Norma pesata | Ts [s] | OS [%] | Errore statico [%] | Cross [rad] | Picco u [N m] | RMS u [N m] |
|---:|---:|---:|---:|---:|---:|---:|---:|
| 2 | 0.0305405 | 2.918 | 0 | 0.0505994 | 0.00689344 | 0.821684 | 0.567073 |
| 3 | 0.0312036 | 1.944 | 0 | 0.106121 | 0.00855447 | 0.820992 | 0.580049 |
| 4 | 0.0474606 | 1.460 | 0 | 0.516895 | 0.0142464 | 0.868257 | 0.584953 |

Il criterio reale in `run_hinf_final_nominal.m` ammette candidati stabili/propri con norma <1 e picco entro 1.25 volte la baseline; ordina prima numero e severità delle violazioni M5, poi gli altri indicatori. I tre candidati violano soltanto Ts: rapporti rispetto a 0.8 s = 3.6475/2.43/1.825. Quindi 4 è selezionato per minore violazione; non per minima gamma, che appartiene a 2. Rapidità maggiore con aumento di errore, comando, accoppiamento e norma. La deviazione massima da disturbo cresce da circa 0.0366 a 0.0457 rad fra 2 e 4.

Mo è il modello desiderato criticamente smorzato del costo; non è il controllore né la risposta reale. Banda −3 dB del modello = omega_M·sqrt(sqrt(2)−1); aumentare omega_M rende più rapida la traiettoria richiesta senza garantire robustezza o target temporali. CSV/MAT e tabella LaTeX registrano il confronto completo.

## 4. Modifiche al Capitolo 8

- **8.4.1:** risposta e banda di Mo, confronto reale 2/3/4, ordinamento effettivo dei candidati e compromessi; distinta banda desiderata da quella chiusa.
- **8.5:** gamma è limite della norma nominale pesata, non percentuale di overshoot. Pesi e libertà 2-DoF possono favorire il transitorio, ma le garanzie robuste richiedono post-analisi.
- **8.6.1:** Figura 8.2 spostata subito dopo il paragrafo che termina con «controllandone l’interconnessione.», conservando numero e due pannelli.
- **8.6.2:** spiegazione verbale prima delle formule; Kr/Ky condividono lo stato. `r=0` annulla soltanto il ramo del riferimento: disturbo, stato iniziale e feedback possono produrre comando non nullo.
- **8.6.3:** prima segnali e obiettivo, poi pianta/chiamata; `[r;d]` e `[ze;zu]`, quattro ingressi del controller, disturbo non misurato, dimensioni e segni reali.
- **8.7:** distinzione hinfsyn precedente e hinfstruct sullo stesso problema 2-DoF; strutture, avvii e minimi osservati, senza promettere ottimo globale.
- **8.9.2:** riferimento nullo, disturbo link costante 0.5 N m, condizioni iniziali e orizzonte 12 s; interpretazione di spostamento, compensazione e offset.
- **Figura 8.4:** tre pannelli verticali con massimi valori singolari: sensibilità, comando per deviazione e mappa pesata completa con righe errore/comando. Assi e unità espliciti; righe singole non sostituiscono la norma completa.
- **Figura 8.6:** quattro pannelli: posizioni sopra, comandi sotto, una colonna per ciascun disturbo, interi 12 s e livelli DC.
- **Tabella 8.4:** ordine richiesto deviazione q, residuo DC, picco u, RMS u; lettura breve coerente coi numeri. Massimi di prove distinte chiaramente dichiarati; offset nullo del PID non interpretato come superiorità globale.

## 5. Modifiche al Capitolo 9

Progressione: incertezze fisiche → normalizzazione/struttura Delta → schema N–Delta → valore singolare strutturato → NS/NP/RS/RP → D–K → post-analisi. Ogni formula segue la domanda fisica che affronta.

Definizione: `mu_D(H)=1/min{sigma_max(Delta): det(I-H*Delta)=0, Delta appartiene a D}`, con mu=0 quando nessuna perturbazione strutturata rende singolare il ritorno. Qui **H=N11(jω), 5×5**, mentre N completa è 9×9. Due blocchi dinamici complessi indipendenti e tre scalari reali: la struttura è indispensabile, non si sostituisce con perturbazioni arbitrarie. Il dominio operativo normalizzato unitario è distinto dalla ricerca della distanza critica, che può superare 1.

`robstab(a.CL)` usa l'interconnessione USS completa `lft(P,K)`: il margine scala uniformemente gli scostamenti fisici, non A o le coppie. LowerBound>1 certifica RS nel modello; UpperBound<1 esclude RS; intervallo a cavallo di 1 inconclusivo. Il secondo output è un'istanza critica, non un campione casuale.

`robgain(a.CL,1)` verifica la mappa pesata `[r;d]→[ze;zu]` con soglia unitaria e restituisce il margine di scala delle incertezze fisiche. Non è un errore percentuale, un overshoot o gamma di sintesi. Istanza critica di prestazione distinta da quella di stabilità; verifica salvata con usubs/norma. Per RS, reciproco del picco mu nella medesima struttura/scalatura, con inversione dei bound. Per RP, il margine che scala soltanto i blocchi fisici non viene identificato automaticamente col reciproco della mu aumentata che scala anche il blocco di prestazione.

Numeri robusti conservati: H∞ RS circa 0.018, FAIL; intervallo RP invertito non validato, mai riordinato. Kµ RS circa 1.80 e RP circa 1.68, PASS nel modello dichiarato. Nessuna conclusione probabilistica o hardware.

## 6. Simulink

Controllati i sei originali del gruppo:

- Progetto_LQR_simulink.slx, Progetto_LQRI_simulink.slx, Progetto_Hinf_simulink.slx;
- LQR_linear_sim.slx, LQRI_linear_sim.slx, Hinf_linear_sim.slx.

I primi tre erano già presenti; gli ultimi tre acquisiti dal Drive. Tutti **invariati nei byte**, hash nel manifest. Nessuna modifica strutturale o rinomina definitiva SLX; aggiornati audit e setup MATLAB. Tutti i load_system falliscono con Simulink:Commands:LoadingNewerModel, R2026a su R2025b: sei FAIL di compatibilità, compilazione/simulazione NOT RUN.

Differenze verificate staticamente: il feedback del servo già moltiplica xhat; l'integratore invece riceve q ideale. Nel lineare, collegare Selector SID50 al Sum rumoroso SID54 anziché allo State-Space SID64; nel non lineare, collegarlo al Sum SID40 anziché al Selector SID36. Disturbo non lineare attualmente lato motore, da portare all'equazione link. Rumore encoder scalare condiviso da rendere quattro canali indipendenti; processi/porte libere da completare. H∞ originale a due ingressi da adattare a `[r;q]` con singola realizzazione a stati condivisi; originale Kµ assente. Istruzioni per porte, segni, inizializzazione e prove in **docs/CORREZIONI_SIMULINK_LQGI.md**. Nessun progetto dei colleghi usato come sostituto.

## 7. Presentazione

Modificate slide **6, 7, 8, 9, 12, 15, 16, 17, 18, 19**: definizioni LQG/LQGI, legge e disturbo non lineare, gamma/overshoot, confronto Mo, definizione mu e comandi, ruolo LQGI, nuove verifiche non lineari, rumore/RAS, sei originali e conclusioni. Aggiornate note orali e tempi; 19 slide, **17:45**, margine 2:15. Macro numeriche LQGI generate dalla summary.json corrente. Nei confronti rumorosi sono esplicitati quattro encoder LQGI e due canali dei robusti: nessuna graduatoria ottenuta ignorando protocolli diversi.

## 8. Risultati rigenerati

- M7: tre costi/guadagni verificati invarianti, chiusure complete, poli, residui, tracking/DC/disturbo; tre PNG LQGI rinominati e grafico del compromesso integrale; CSV e tabella lqgi_revision_results.tex.
- LQGI corrente: validation.mat, nonlinear_metrics.csv, summary.json; rumore/linearNoise e ripetizione; ras.mat, ras_points.csv e ras_boundary.csv. Figure tracking_linear_nonlinear, disturbance_nonlinear, encoder_noise, ras_empirical e disturbance_for_slides, nelle cartelle report/results.
- H∞: omegaM_comparison.csv/.mat e tabella LaTeX, frequenza e disturbo leggibili dai controllori salvati; norme/metriche ricontrollate. Tabella didattica del disturbo riordinata dai dati reali.
- Audit sei originali, CSV/MAT test, inventario baseline, occorrenze classificate e dipendenze/asset SHA-256.
- Appendice MATLAB: 29 estratti letterali / 228 righe; macro delle slide; due PDF di consegna e relativi audit.

Non rigenerate sintesi robusta, mu-analysis, Monte Carlo, RAS H∞/Kµ o Lyapunov storico; relativi artifact adottati invariati.

## 9. Verifiche eseguite

Eseguiti checkcode del baseline, validate_m7_lqg_integral, plot_lqgi_revision, run_lqgi_validation, confronto lineare ZOH evaluate_lqgi_noise, run_lqgi_ras, export_hinf_readable_figures e audit_original_models. Nuova RAS eseguita dopo l'aggiornamento dell'identità del simulatore: 57 simulazioni senza errori. Eseguito run_all con CR_RUN_SCOPE=verify: **112/112 PASS**, sette nuovi test non riducibili al semplice controllo di stringhe.

Test nuovi: assenza di vero stato nel comando iniziale, errore rumoroso nell'integratore, accordo locale lineare/non lineare, processo ignoto al filtro, Kalman invariato/equilibrio/ripetibilità, selezione Mo reale e corretto hold del rumore. Dieci sorgenti LQGI: zero segnalazioni Code Analyzer. Due warning preesistenti nel baseline: crescita array in analysis/export_hinf_final_results.m e analysis/ras/estimate_lqg_ras.m, conservati perché estranei alla correzione.

Controllo automatico: 85 artifact protetti invariati, sei hash SLX esatti, nessuna nomenclatura attiva incoerente, nessun input/asset LaTeX mancante; 114 dipendenze e 36 inclusioni di figure. Riferimenti storici classificati, non cancellati. Due PDF compilati con latexmk; relazione 83 pagine, slide 19; zero errori/riferimenti irrisolti/overflow/destinazioni duplicate. Revisione visiva delle parti modificate e di tutte le slide.

Esiti intermedi registrati e corretti: scarto rumoroso iniziale fino a 0.0071 rad, integrazione ZOH/hold corrette prima dei valori finali; prima build slide senza figura ancora in esportazione; etichetta schema LQGI sovrapposta rimossa dopo rendering. Rimangono sei errori di versione Simulink e warning launcher Perl sulla locale C.UTF-8, con fallback Windows italiano; nessun errore LaTeX finale. L'incompatibilità non è stata aggirata per accreditare simulazioni.

## 10. Attività non risolvibili automaticamente

Aprire i sei originali in **R2026a** oppure, da R2026a, esportare copie verso R2025b con Export Model to Previous Version. Conservare gli originali. Applicare le correzioni per SID del documento dedicato; verificare dimensioni, feedthrough, condizioni iniziali, stessa sequenza From Workspace e segni. Compilare e confrontare il modello lineare con i 30 stati MATLAB e il non lineare con le traiettorie salvate. Solo dopo quelle prove rinominare le copie definitive LQGI e ricalcolare/registrare le prove Simulink richieste.

Per Kµ manca un originale del gruppo: resta necessaria una realizzazione manuale del controllore salvato, senza prendere quello dei colleghi. Target di assestamento non soddisfatti e vincoli reali di coppia non vengono risolti con cambi arbitrari di pesi o saturazioni. Frontespizio: confermare data di consegna ed eventuali dati mancanti. Effettuare una prova orale cronometrata. Queste attività residue sono dichiarate coerentemente in codice di setup, audit, relazione, slide e stato del progetto.

<!-- FILE_LIST -->

## Elenco completo dei file della revisione

118 voci del diff rispetto al baseline. M = modificato, A = aggiunto, D = rimosso dal nome precedente, R = rinomina riconosciuta da Git. Le coppie A/D dei PNG M7 sono rinomine con titolo aggiornato.

| Stato | File |
|---|---|
| M | `CHANGELOG.md` |
| M | `README.md` |
| M | `analysis/audit_original_models.m` |
| A | `analysis/export_hinf_readable_figures.m` |
| A | `analysis/export_lqgi_validation.m` |
| M | `analysis/finalization/build_direct_weights_summary.m` |
| M | `analysis/finalization/build_m18_figure_manifest.m` |
| M | `analysis/finalization/build_m18_report_tables.m` |
| M | `analysis/finalization/load_m18_validated_artifacts.m` |
| M | `analysis/finalization/validate_m18_deliverables.m` |
| R | `analysis/nominal/evaluate_lqri_candidate.m → analysis/nominal/evaluate_lqgi_candidate.m` |
| A | `analysis/nominal/evaluate_lqgi_noise.m` |
| R | `analysis/nominal/plot_lqri_revision.m → analysis/nominal/plot_lqgi_revision.m` |
| M | `analysis/nominal/validate_m7_lqg_integral.m` |
| A | `analysis/nonlinear/simulate_lqgi_nonlinear.m` |
| M | `analysis/progetto_lqg.m` |
| R | `analysis/progetto_lqri.m → analysis/progetto_lqgi.m` |
| A | `analysis/run_lqgi_ras.m` |
| A | `analysis/run_lqgi_validation.m` |
| R | `controllers/lqg/build_lqri_augmented_cost.m → controllers/lqg/build_lqgi_augmented_cost.m` |
| A | `docs/CORREZIONI_SIMULINK_LQGI.md` |
| M | `docs/DECISION_LOG.md` |
| M | `docs/DIARIO_DI_BORDO.md` |
| M | `docs/PROJECT_STATUS.md` |
| A | `docs/RESOCONTO_REVISIONE_LQGI_HINF_MU.md` |
| A | `docs/coherent_review/READ_ME.md` |
| A | `docs/coherent_review/baseline_inventory.json` |
| A | `docs/coherent_review/coherence_audit.json` |
| A | `docs/coherent_review/m7_gain_identity.json` |
| A | `docs/coherent_review/nomenclature_occurrences.csv` |
| M | `presentation/OUTLINE_AND_TIMING.md` |
| M | `presentation/Progetto_CR_Presentazione.pdf` |
| M | `presentation/SPEAKER_NOTES.md` |
| A | `presentation/build_review_values.py` |
| A | `presentation/generated/coherent_review_values.tex` |
| M | `presentation/main.tex` |
| M | `report/Progetto_CR_Relazione_finale.pdf` |
| M | `report/build_didactic_tables.py` |
| M | `report/build_matlab_appendix.py` |
| A | `report/figures/hinf_final/disturbance_positions_commands.png` |
| A | `report/figures/hinf_final/frequency_diagnostics.png` |
| A | `report/figures/lqgi/disturbance_for_slides.png` |
| A | `report/figures/lqgi/disturbance_nonlinear.png` |
| A | `report/figures/lqgi/encoder_noise.png` |
| A | `report/figures/lqgi/ras_empirical.png` |
| A | `report/figures/lqgi/tracking_linear_nonlinear.png` |
| M | `report/figures/m7_augmented_cost_tradeoff.png` |
| A | `report/figures/m7_lqg_lqgi_constant_disturbance.png` |
| A | `report/figures/m7_lqg_lqgi_disturbance_control.png` |
| D | `report/figures/m7_lqg_lqri_constant_disturbance.png` |
| D | `report/figures/m7_lqg_lqri_disturbance_control.png` |
| A | `report/figures/m7_lqgi_reference_tracking.png` |
| D | `report/figures/m7_lqri_reference_tracking.png` |
| A | `report/figures/schemes/lqgi_architecture.tex` |
| M | `report/generated/didactic_hinf_disturbance.tex` |
| M | `report/generated/figure_manifest.csv` |
| M | `report/generated/figure_manifest.tex` |
| R | `report/generated/lqri_revision_results.tex → report/generated/lqgi_revision_results.tex` |
| A | `report/generated/lqgi_validation_results.tex` |
| M | `report/generated/matlab_appendix_sources.json` |
| A | `report/generated/omegaM_comparison.tex` |
| M | `report/generated/report_latex_audit.txt` |
| M | `report/main.tex` |
| M | `report/sections/07_lqg.tex` |
| M | `report/sections/08_hinf.tex` |
| M | `report/sections/09_mu.tex` |
| M | `report/sections/10_originali_simulink.tex` |
| M | `report/sections/10_validazione_nonlineare.tex` |
| M | `report/sections/12_confronto_finale.tex` |
| M | `report/sections/13_conclusioni_limiti.tex` |
| M | `report/sections/B_artifact_traceability.tex` |
| M | `report/sections/C_riproducibilita.tex` |
| M | `report/sections/D_codici_matlab.tex` |
| M | `report/tables/lqg_m6_m7.tex` |
| A | `results/data/coherent_review/matlab_tests.csv` |
| A | `results/data/coherent_review/matlab_tests.mat` |
| A | `results/data/coherent_review/omegaM_comparison.csv` |
| A | `results/data/coherent_review/omegaM_comparison.mat` |
| A | `results/data/coherent_review/original_models_audit.json` |
| A | `results/data/coherent_review/original_models_audit.mat` |
| A | `results/data/lqgi_validation/nonlinear_metrics.csv` |
| A | `results/data/lqgi_validation/ras.mat` |
| A | `results/data/lqgi_validation/ras_boundary.csv` |
| A | `results/data/lqgi_validation/ras_points.csv` |
| A | `results/data/lqgi_validation/summary.json` |
| A | `results/data/lqgi_validation/validation.mat` |
| M | `results/data/m7_augmented_cost_feasibility.mat` |
| M | `results/data/m7_disturbance_comparison.mat` |
| M | `results/data/m7_lqg_integral.mat` |
| R | `results/data/m7_lqri_tracking_comparison.csv → results/data/m7_lqgi_tracking_comparison.csv` |
| A | `results/figures/hinf_readable/disturbance_positions_commands.png` |
| A | `results/figures/hinf_readable/frequency_diagnostics.png` |
| A | `results/figures/lqgi/disturbance_for_slides.png` |
| A | `results/figures/lqgi/disturbance_nonlinear.png` |
| A | `results/figures/lqgi/encoder_noise.png` |
| A | `results/figures/lqgi/ras_empirical.png` |
| A | `results/figures/lqgi/tracking_linear_nonlinear.png` |
| M | `results/figures/m7_augmented_cost_tradeoff.png` |
| A | `results/figures/m7_lqg_lqgi_constant_disturbance.png` |
| A | `results/figures/m7_lqg_lqgi_disturbance_control.png` |
| D | `results/figures/m7_lqg_lqri_constant_disturbance.png` |
| D | `results/figures/m7_lqg_lqri_disturbance_control.png` |
| A | `results/figures/m7_lqgi_reference_tracking.png` |
| D | `results/figures/m7_lqri_reference_tracking.png` |
| M | `run_all.m` |
| A | `simulink/originals/Hinf_linear_sim.slx` |
| A | `simulink/originals/LQRI_linear_sim.slx` |
| A | `simulink/originals/LQR_linear_sim.slx` |
| M | `simulink/originals/manifest.json` |
| M | `simulink/setup_original_models.m` |
| M | `src/parameters/lqg_specs_m7.m` |
| A | `src/parameters/lqgi_validation_specs.m` |
| A | `tests/lqgiValidationTest.m` |
| M | `tests/organicReviewTest.m` |
| M | `tests/test_m18_final_deliverables.m` |
| M | `tests/test_m7_lqg_integral.m` |
| A | `tools/audit_coherent_revision.py` |
| M | `tools/build_hinf_revision_report.py` |
