# Manifest dei deliverable finali

**Autori:** Alessio de Dato, Valerio Rebechi
**Progetto:** Controllo robusto di un manipolatore planare 2-DoF con SEA

## Relazione

- Source principale: `report/main.tex`, con 13 capitoli e 3 appendici modulari in `report/sections/`.
- PDF finale: `report/Progetto_CR_Relazione_finale.pdf` (71 pagine; conteggio verificato in `report/generated/report_latex_audit.txt`).
- Macro: `report/generated/m18_values.tex` (78 valori storici riconciliati) e `revision_values.tex` (12 valori della revisione, con sorgenti in `revision_numeric_audit.csv`).
- Tabelle: 19 file tabellari: 11 in `report/tables/` e 8 in `report/generated/`, oltre alle macro e alla tabella sintetica Kalman delle slide.
- Figure: 30 asset selezionati, registrati in `report/generated/figure_manifest.csv`.
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
- Kmu final robust controller: `m13_musyn_dk.mat`.
- Audit finale: `results/data/m18_final_deliverable_audit.mat`.
- Studio LQI: `analysis/progetto_lqi.m`, `m7_disturbance_comparison.mat/.csv`.
- Studio H-infinity: `analysis/nominal/study_hinf_weights.m`,
  `hinf_weight_revision.mat/.csv`; il default ricarica i dati già prodotti.
- Figure/tabelle mirate: `analysis/nominal/plot_lqi_hinf_revision.m`.
- M18 censisce 23 sorgenti; i nuovi studi non sostituiscono M9–M16.
- Modelli: `simulink/SEA_LQG_nonlinear.slx` e `simulink/SEA_ROBUST_nonlinear.slx`.

## Riproducibilità

- MATLAB R2025b con Control System Toolbox, Robust Control Toolbox, Simulink e Symbolic Math Toolbox usati dalla pipeline storica.
- Seed M16: `20260826`, generatore `twister`.
- Generazione M18: `validate_m18_deliverables(true,true)`.
- Suite automatica: `r=runtests('tests'); assertSuccess(r)`.
- `run_all`: ricostruzione storica, NOT RUN nella revisione corrente perché rilancerebbe M9–M11.
- Nuove evidenze: `lyapunov_ras_nominal.mat`, `lyapunov_trajectories.mat/.csv`, `didactic_lqg_calculations.mat`, `didactic_hinf_calculations.mat` in `results/data/`.
- Derivazioni e confronto didattico: `docs/REVISIONE_TECNICA_LYAPUNOV.md`.
- Revisione mirata successiva: `docs/REVISIONE_MIRATA_LQI_HINF.md`.
- Regressione mirata conclusiva: `lqi_hinf_revision_verification.mat/.csv`,
  644/644 PASS in un'unica suite globale; i due test file esistenti sono
  stati estesi senza aggiungere nuovi file di test.

## Limiti noti

- M7 non produce un controllore integrale finale.
- Kmu ha RS certificata ma NP/RP e tracking falliti.
- M6 perde stabilità nei Sample 5 e 6 M16.
- Khinf/Kmu non soddisfano il tracking M5.
- Nessuno dei 13 nuovi candidati H-infinity soddisfa tutti i target M5;
  il minimo gamma è 2.8056. Il candidato illustrativo ID 10 non è adottato.
- uScale non è una saturazione hardware.
- Lyapunov fornisce un limite interno nominale conservativo; il livello numerico campionato, le mappe M8/M15 e Monte Carlo restano empirici.
- Le incertezze non sono identificate sperimentalmente.
- Kmu resta di ordine 52.

## Dati da completare prima della consegna

- matricole di Alessio de Dato e Valerio Rebechi;
- data di consegna;
- eventuale logo e anno accademico, se richiesti dal formato del corso.
