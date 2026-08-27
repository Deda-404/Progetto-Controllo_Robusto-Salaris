# Manifest dei deliverable finali

## Relazione

- Source principale: `report/main.tex`, con 13 capitoli e 3 appendici modulari in `report/sections/`.
- PDF finale: `report/Progetto_CR_Relazione_finale.pdf`.
- Macro: `report/generated/m18_values.tex`.
- Tabelle: 11 file generati in `report/tables/`.
- Figure: 15 asset selezionati, registrati in `report/generated/figure_manifest.csv`.
- Compilazione: `powershell -ExecutionPolicy Bypass -File tools/build_m18_latex.ps1`.

## Presentazione

- Source: `presentation/main.tex` (Beamer 16:9).
- PDF: `presentation/Progetto_CR_Presentazione.pdf`.
- Timing: `presentation/OUTLINE_AND_TIMING.md`, stima totale 17:30.
- Note: `presentation/SPEAKER_NOTES.md`, incluse domande probabili.
- Compilazione: stesso comando PowerShell della relazione.

## Codice e dati

- Entry point: `run_all.m`, M1--M18.
- M6 nominal performance reference: `m6_lqg_no_integrator.mat`.
- Khinf comparator: `m10_hinfsyn_nominal.mat`.
- Kmu final robust controller: `m13_musyn_dk.mat`.
- Audit finale: `results/data/m18_final_deliverable_audit.mat`.
- Modelli: `simulink/SEA_LQG_nonlinear.slx` e `simulink/SEA_ROBUST_nonlinear.slx`.

## Riproducibilità

- MATLAB R2025b con Control System Toolbox, Robust Control Toolbox, Simulink e Symbolic Math Toolbox usati dalla pipeline storica.
- Seed M16: `20260826`, generatore `twister`.
- Generazione M18: `validate_m18_deliverables(true,true)`.
- Regressione completa: `run_all`.

## Known limitations

- M7 non produce un controllore integrale finale.
- Kmu ha RS certificata ma NP/RP e tracking falliti.
- M6 perde stabilità nel Sample 5 M16.
- Khinf/Kmu non soddisfano il tracking M5.
- uScale non è una saturazione hardware.
- RAS e Monte Carlo hanno semantica empirica.
- Le incertezze non sono identificate sperimentalmente.
- Kmu resta di ordine 52.

## User input required

- `USER INPUT REQUIRED BEFORE SUBMISSION`: autori, matricole, eventuale logo, data d'esame e anno accademico.
