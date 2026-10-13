# Controllo robusto di un manipolatore SEA a due giunti

Alessio de Dato (635256) e Valerio Rebechi (722224), 13.10.2026. Collaudo locale **COMPLETE / PASS** in MATLAB/Simulink R2026b 26.2.0.3386108: **141/141 test**, quattro script eseguiti e **otto originali SLX caricati, compilati, simulati e verificati**. SHA-256 degli otto file e 80 artifact congelati invariati. Branch `codex/validazione-finale-matlab-simulink`, base main `14359392`; revisione e merge a cura degli studenti.

[PR #40 — collaudo conclusivo](https://github.com/Deda-404/Progetto_CR/pull/40) aperta per revisione; ramo pubblicato, nessun merge.

## Elaborati

- [Relazione PDF](report/Progetto_CR_Relazione_finale.pdf), 100 pagine; sorgenti in report/.
- [Presentazione PDF](presentation/Progetto_CR_Presentazione.pdf), 22 slide; durata stimata 18:45.
- [Note orali](presentation/SPEAKER_NOTES.md) e [scaletta](presentation/OUTLINE_AND_TIMING.md).
- [Istruzioni e manifest di consegna](delivery/README.md).
- [Collaudo modello per modello](docs/REPORT_VERIFICA_SIMULINK.md), [rumore](docs/ANALISI_RUMORE_MISURA.md), [chiusura](docs/CHIUSURA_FINALE_PROGETTO.md) e [checklist](docs/CHECKLIST_CONSEGNA_STUDENTI.md).

Il modello ha 8 stati meccanici e 14 con attuatori. I controllori sono LQG (14 stati), LQGI (16), H∞ 1-DoF (18), H∞ 2-DoF (22), PID (4) e Kμ (78). I quattro script didattici sono in `File_di_Funzioni_Progetto-Accorpati/`. Il collaudo conserva guadagni, costi, pesi, incertezze, parametri fisici e configurazioni SLX.

**Il successo del collaudo non equivale al rispetto di tutti i target.** LQG conserva offset sotto disturbo, LQGI lo riduce con tracking lento. H∞ 2-DoF conserva NS/NP ma fallisce RS; RP numerica non validata. In R2026b RS è circa [0.026154,0.026207], con estremi differenti da R2025b. Kμ conserva RS≈1.80 e RP≈1.68, ordine 78 e target temporali parziali. I dieci impianti incerti comuni del Capitolo 11, seed 20261012, danno H∞ 0/10 stabili e Kμ 10/10; il campione non è un certificato.

Il rumore encoder resta critico. Gli Scope H∞ non lineari registrano 733230 N m nel ramo 2-DoF; μ circa 108/109 N m nei due modelli. Sono richieste senza saturazioni, non coppie hardware validate. H∞ lineare usa misure ideali e non è una prova encoder; H∞ non lineare e μ usano misure rumorose. I canali encoder degli originali sono correlati, a differenza della prova MATLAB isolata. Picchi Scope e RMS da quadratura non certificano il massimo o l'integrale continuo. La RAS empirica, gli arresti numerici e gli insiemi interni Lyapunov restano distinti.

## Esecuzione

Dalla radice, con MATLAB, Simulink, Control System, Robust Control e Symbolic Math Toolbox R2026b:

```matlab
addpath('tools','simulink');
run_final_student_validation;              % regressioni, quattro script, otto run e figure
run_final_student_validation(false);       % soltanto collaudo degli otto originali
run_final_student_validation(false,true);  % rilegge dati registrati e hash; non esegue nuove simulazioni
```

Il lettore dei buffer Scope usa una API interna R2026b in sola lettura; su altra release può richiedere l'esportazione manuale Print to Figure. Il runner restituisce errore se manca una verifica obbligatoria. Solver, logging, switch, rumori e collegamenti interni non vengono modificati; i modelli sono chiusi senza salvare.

```text
python tools/build_final_simulink_tables.py
python report/build_matlab_appendix.py
powershell -File tools/build_m18_latex.ps1
python tools/build_delivery_manifest.py --check
```

`results/data/final_simulink_validation/` contiene i dati Scope, gli esiti runtime e le verifiche numeriche locali. I dataset `hinf_final_coherent/`, `final_closure/` e `lqgi_validation/` supportano robustezza, rumore isolato, RAS e prove sugli impianti incerti. Le figure Simulink e i diagrammi autentici sono in `report/figures/final_simulink/` e `student_exports/`.

Drive è in sola lettura. Per consegnare i modelli usare esclusivamente `simulink/student_originals/` e il suo manifest. La cartella delivery seleziona materiali riproducibili, escludendo diari, documenti interni, cache e duplicati. Le 141 regressioni richiedono il checkout integrale GitHub. Restano la prova orale cronometrata e la revisione della PR.
