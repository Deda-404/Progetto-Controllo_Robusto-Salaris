# Progetto CR — manipolatore SEA

Modellistica e controllo di un manipolatore planare a due giunti, con MATLAB R2025b, Simulink, Control System Toolbox e Robust Control Toolbox.

## Stato corrente

Revisione `codex/hinf-final-coherent-revision`, base `693e316`. M0–M8 congelati.
Vero H∞2-DoF: norma0.04746 e tracking migliorato, ma RS FAIL e0/40 campioni stabili.
Nuovo Kμ: norma nominale0.63468, RS/RP PASS (margini1.80/1.68),40/40 campioni stabili.
M5 resta FAIL per entrambi. LQG conserva il ruolo di riferimento nominale.
Rumore e RAS mostrano limiti di comando; nessuna validazione hardware.

- [Resoconto completo](docs/RESOCONTO_HINF_FINAL_COHERENT_REVISION.md)
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
Le nuove simulazioni non lineari integrano le equazioni SEA direttamente in MATLAB; i modelli Simulink storici restano disponibili.
Il branch è destinato alla revisione manuale: il merge rimane al gruppo.
