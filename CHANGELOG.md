# Changelog

Tutte le modifiche tecniche rilevanti del progetto sono documentate in questo file.

## Unreleased

### Added

- Struttura iniziale del repository per modello, controllori, analisi, Simulink, test, risultati e relazione.
- Documentazione M0: analisi della traccia e del riferimento, inventario Drive, checklist, roadmap, decision log, diario e project status.
- `AGENTS.md` con le regole permanenti del progetto.
- `run_all.m` minimale e smoke test della workspace.
- Regola permanente di ricostruzione indipendente e consultazione reference-last in `AGENTS.md`.
- Parametri meccanici nominali centralizzati e funzioni modulari M1 per inerzia, Coriolis, gravità, elasticità SEA e dinamica completa a 8 stati.
- Suite automatica M1 con sette test matematici e strutturali, inclusa una verifica indipendente delle formule della traccia.
- Validazione deterministica M1 e documentazione originale del modello non lineare.
- `Resosconto_per_GPT.txt` con riepilogo autosufficiente di implementazione, test, metriche e stato Git M1.
- Funzioni M2 per equilibrio statico generale, linearizzazione simbolica e matrici di uscita.
- Verifica Jacobiana indipendente a differenze finite centrate e analisi strutturale SVD/PBH.
- Suite M2 con nove test, validazione locale LTI/non lineare e regressione integrale M1.
- Dataset nominale M2 e figura originale dei poli open-loop, entrambi rigenerabili.
- `docs/EQUILIBRIO_LINEARIZZAZIONE.md` con derivazioni, matrici, metriche e limiti M2.

### Changed

- Ampliato `README.md` con scopo, governance, struttura, prerequisiti, esecuzione e stato.
- Completato `.gitignore` per file temporanei MATLAB, Simulink, LaTeX, editor e sistema operativo.
- Esteso `run_all.m` per eseguire test M0/M1, validazione numerica e segnalazione esplicita PASS/FAIL.
- Aggiornati README, decision log, checklist, diario e project status alla chiusura di M1.
- Esteso `run_all.m` alla pipeline M2 completa con dataset, figura e quality gate.
- Promosse a decisioni approvate equilibrio verticale, misura `[q;theta]` e uscita prestazionale `q` sulla base dei risultati eseguiti.

### Fixed

- Verificata la precedente rinomina di `MeS.gitignore` nel corretto `.gitignore`; aggiunta la terminazione di riga mancante.

### Removed

- Rimossi i placeholder `.gitkeep` dalle cartelle ora popolate `src/model`, `src/parameters` e `analysis/nominal`.

### Validated

- Accesso in sola lettura alla cartella Google Drive e al progetto CR dei colleghi.
- Remote GitHub ufficiale e branch di lavoro M0.
- MATLAB R2025b Update 4, Simulink e toolbox richiesti.
- Struttura minima mediante test automatico M0.
- Modello M1 mediante 9 test complessivi e `run_all.m` reale in MATLAB R2025b Update 4.
- Positività campionata di \(M\) su 2001 configurazioni, con minimo autovalore 0.01904266522239113.
- Simmetria di \(M\) con errore massimo 0 e proprietà antisimmetrica di \(\dot M-2C\) con residuo massimo \(4.907\times10^{-18}\).
- Assenza di `NaN`/`Inf` e coerenza cinematica dell'RHS sui casi deterministici M1.
- Equilibrio M2 con residuo \(5.839\times10^{-14}\), inferiore alla tolleranza \(10^{-10}\).
- Jacobiani simbolici 8×8/8×2 contro differenze finite: errore massimo \(4.126\times10^{-8}\).
- Due poli open-loop instabili, controllabilità 8/8 e stabilizzabilità PBH positiva.
- Osservabilità 8/8 e rilevabilità PBH positiva sia per `[q;theta]` sia, a titolo informativo, per `q`.
- Riduzione monotona dell'errore locale LTI/non lineare su quattro ampiezze.
