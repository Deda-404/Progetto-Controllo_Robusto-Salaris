# Manifest dei deliverable finali

**Autori:** Alessio de Dato, Valerio Rebechi
**Progetto:** Controllo robusto di un manipolatore planare 2-DoF con SEA

## Relazione

- Source principale: `report/main.tex`, con 13 capitoli e 3 appendici modulari in `report/sections/`.
- PDF finale: `report/Progetto_CR_Relazione_finale.pdf`; conteggio corrente verificato in `report/generated/report_latex_audit.txt`.
- Macro: `report/generated/m18_values.tex` (78 valori storici riconciliati) e `revision_values.tex` (12 valori della revisione, con sorgenti in `revision_numeric_audit.csv`).
- Tabelle: 20 file tabellari: 11 in `report/tables/` e 9 in `report/generated/`, oltre alle macro e alla tabella sintetica Kalman delle slide.
- Figure: 32 asset selezionati, incluso il nuovo schema Lower LFT M10, registrati in `report/generated/figure_manifest.csv`.
- Compilazione: `powershell -ExecutionPolicy Bypass -File tools/build_m18_latex.ps1`.
- Revisione mirata: aggiungere `-ReportOnly` per non ricompilare le slide.

## Presentazione

- Source: `presentation/main.tex` (Beamer 16:9).
- PDF: `presentation/Progetto_CR_Presentazione.pdf` (19 slide 16:9).
- Timing: `presentation/OUTLINE_AND_TIMING.md`, stima totale 19:00.
- Note: `presentation/SPEAKER_NOTES.md`, incluse domande probabili.
- Compilazione: stesso comando PowerShell della relazione.

## Codice e dati

- Entry point: `run_all.m`, M1--M18.
- M6 nominal performance reference: `m6_lqg_no_integrator.mat`.
- Khinf comparator: `m10_hinfsyn_nominal.mat`.
- Kmu valutato, non selezionato come robusto finale: `m13_musyn_dk.mat`.
- Audit finale: `results/data/m18_final_deliverable_audit.mat`.
- LQRI con Kalman M6: `analysis/progetto_lqri.m`, `m7_disturbance_comparison.mat/.csv`.
- Studio H-infinity: `analysis/nominal/study_hinf_weights.m`,
  `hinf_weight_revision.mat/.csv`; il default ricarica i dati già prodotti.
- Figure/tabelle mirate: `analysis/nominal/plot_lqri_revision.m` e `plot_hinf_revision.m`.
- M18 censisce 23 sorgenti; gli artifact M9–M17 sono rigenerati sui pesi correnti. Il confronto aggiuntivo a due pesi è in `direct_weights_summary.mat`.
- Modelli: `simulink/SEA_LQG_nonlinear.slx` e `simulink/SEA_ROBUST_nonlinear.slx`.

## Riproducibilità

- Verifica corrente: unica suite globale 658/660 PASS; due aspettative
  storiche corrette e rieseguite con 2/2 PASS. Evidenze separate:
  `direct_weights_final_verification.mat/.csv` e
  `direct_weights_targeted_recheck.mat/.csv`. Nessuna seconda suite globale.
- Analisi statica: 177 file MATLAB, zero segnalazioni.

- MATLAB R2025b con Control System Toolbox, Robust Control Toolbox, Simulink e Symbolic Math Toolbox usati dalla pipeline storica.
- Seed M16: `20260826`, generatore `twister`.
- Generazione M18: `validate_m18_deliverables(true,true)`.
- Suite automatica: `r=runtests('tests'); assertSuccess(r)`.
- `run_all`: percorso circoscritto con `CR_RUN_SCOPE=lqri`; il percorso completo storico resta distinto e rilancia M9–M11.
- Nuove evidenze: `lyapunov_ras_nominal.mat`, `lyapunov_trajectories.mat/.csv`, `didactic_lqg_calculations.mat`, `didactic_hinf_calculations.mat` in `results/data/`.
- Derivazioni e confronto didattico: `docs/REVISIONE_TECNICA_LYAPUNOV.md`.
- Revisione mirata successiva: `docs/REVISIONE_MIRATA_LQI_HINF.md`.
- Regressione precedente del 10 settembre: `lqi_hinf_revision_verification.mat/.csv`,
  644/644 PASS in un'unica suite globale; i due test file esistenti sono
  stati estesi senza aggiungere nuovi file di test.

La revisione corrente è descritta in `RESOCONTO_REVISIONE_PESI_HINF_LQR_LQRI.txt`;
la sua verifica globale è registrata in `direct_weights_final_verification.mat/.csv`.
`RESOCONTO_REVISIONE_LQRI_R.txt` e `lqri_r_verification.mat/.csv` sono storici.

## Limiti noti

- M7 implementa LQRI (Kalman M6 + 2 integratori, chiusura a 30 stati), ma resta PARTIAL per il target di settling.
- Kmu fallisce RS, NP/RP e tracking; il ruolo robusto finale non è assegnato.
- M6 perde stabilità in tre campioni M16, conservati nel dataset.
- Khinf/Kmu non soddisfano il tracking M5.
- Nessuno dei 12 candidati H-infinity soddisfa tutti i target M5;
  il candidato ID 10 ha gamma=5.6903. I suoi W1/W2 sono adottati in M5;
  M10 a due pesi ha gamma=5.67722 e rimane non conforme.
- uScale non è una saturazione hardware.
- Lyapunov fornisce un limite interno nominale conservativo; il livello numerico campionato, le mappe M8/M15 e Monte Carlo restano empirici.
- Le incertezze non sono identificate sperimentalmente.
- Kmu ha ordine 70, senza riduzione.

## Dati da completare prima della consegna

- matricole di Alessio de Dato e Valerio Rebechi;
- data di consegna;
- eventuale logo e anno accademico, se richiesti dal formato del corso.
