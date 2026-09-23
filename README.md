# Progetto CR — manipolatore SEA

Modellistica e controllo di un manipolatore planare a due giunti, con MATLAB R2025b, Simulink, Control System Toolbox e Robust Control Toolbox.

## Stato corrente

PR #32 integrata in main889c0eb. Branch codex/simulink-integration: 67/67 controlli e7/7 test PASS su R2025b. Artifact precedenti invariati.
Vero H∞2-DoF: norma0.04746 e tracking migliorato, ma RS FAIL e0/40 campioni stabili.
Nuovo Kμ: norma nominale0.63468, RS/RP PASS (margini1.80/1.68),40/40 campioni stabili.
M5 resta FAIL per entrambi. LQG conserva il ruolo di riferimento nominale.
Rumore e RAS mostrano limiti di comando; nessuna validazione hardware.

- [Integrazione Simulink](docs/RESOCONTO_SIMULINK_INTEGRATION.md)
- [Presentazione](presentation/Progetto_CR_Presentazione.pdf)
- [Revisione H∞](docs/RESOCONTO_HINF_FINAL_COHERENT_REVISION.md)
- [Relazione](report/Progetto_CR_Relazione_finale.pdf)
- [Stato e limiti](docs/PROJECT_STATUS.md)

## Esecuzione

Dalla radice MATLAB: `run_all` avvia la catena corrente, con checkpoint di sintesi.
Per il percorso precedente: `setenv('CR_RUN_SCOPE','legacy'); run_all`.
Per i soli test: `runtests({'tests/hinfLowerBoundTest.m','tests/hinfFinalCoherenceTest.m','tests/hinfFinalDownstreamTest.m'})`.
La rigenerazione completa è costosa; i risultati validati sono già salvati.
Esportazione: `export_hinf_final_results`, poi `python report/build_hinf_final_text.py` e LaTeX dalla cartella `report`.

I nuovi risultati sono in `results/data/hinf_final_coherent/`; quelli precedenti rimangono nei percorsi originali.
`src` contiene la fisica, `controllers` le sintesi, `analysis` le verifiche, `tests` i controlli.
Modelli correnti: `simulink/models`; originali: `simulink/legacy/valerio`. Per la sola integrazione: `setenv('CR_RUN_SCOPE','simulink'); run_all`. Per aprire: `addpath('simulink'); setup_lqg_simulink` (analoghi lqri, hinf, kmu). Nessuna sintesi rilanciata.
Il branch è destinato alla revisione manuale: il merge rimane al gruppo.
