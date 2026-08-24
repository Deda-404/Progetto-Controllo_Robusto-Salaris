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
- `docs/handoff/Resoconto_M2_per_GPT.txt` con handoff autosufficiente M2 e riferimenti Git/PR.
- Parametri nominali attuatori centralizzati, modello SISO secondo ordine più Padé e blocco MIMO diagonale a sei stati.
- Costruzione esplicita della pianta completa M3 a 14 stati e verifica indipendente mediante `series`.
- Analisi deterministica di 27 candidati e diagnostica strutturale SVD/PBH con normalizzazione temporale.
- Suite M3 con undici test, dataset nominale e tre figure frequenziali originali e rigenerabili.
- `docs/DINAMICA_ATTUATORI.md` con modello, scelta, Padé, interconnessione, poli, proprietà strutturali e limiti.
- Cinque test M3.1 per indipendenza della selezione, appartenenza alla griglia, vincoli, esclusione dei non ammissibili e determinismo.
- Screening M4 di dieci parametri con perturbazioni ±1%, quattro metriche dinamiche e regola di priorità esplicita; selezionati `k2`, `k1`, `Jm1`.
- Scenari MILD/BASELINE/CONSERVATIVE per meccanica e attuatori, centralizzati come assunzioni ingegneristiche.
- Linearizzazione analitica compatibile con `ureal`, pianta meccanica incerta e pianta completa `GuncMeas/GuncQ` con cinque blocchi strutturati.
- Famiglia FRD di 120 attuatori con ritardo esatto, corner obbligatori e seed 20260824.
- Fit `ucover` degli ordini 1–4 e selezione del minimo `WI` stabile/proprio coprente, con due `ultidyn` indipendenti.
- Dataset `m4_uncertain_plant.mat`, tre figure M4 originali, documentazione `MODELLO_INCERTEZZE.md` e handoff dedicato.
- Quattordici test M4 per screening, range, `ureal`, famiglia, copertura, Delta, coerenza nominale, `lftdata`, `usample` e regressioni.

### Changed

- Ampliato `README.md` con scopo, governance, struttura, prerequisiti, esecuzione e stato.
- Completato `.gitignore` per file temporanei MATLAB, Simulink, LaTeX, editor e sistema operativo.
- Esteso `run_all.m` per eseguire test M0/M1, validazione numerica e segnalazione esplicita PASS/FAIL.
- Aggiornati README, decision log, checklist, diario e project status alla chiusura di M1.
- Esteso `run_all.m` alla pipeline M2 completa con dataset, figura e quality gate.
- Promosse a decisioni approvate equilibrio verticale, misura `[q;theta]` e uscita prestazionale `q` sulla base dei risultati eseguiti.
- Esteso `run_all.m` alla pipeline M3 completa con selezione attuatori, regressioni M0–M2, validazione, dati e figure.
- Approvata la decisione D-0006: \(\omega_n=40\) rad/s, \(\zeta=0.8\), \(\tau_d=15\) ms, Padé ordine 1 e canali nominalmente identici.
- Rifattorizzato `select_nominal_actuator.m`: la funzione seleziona dai 27 candidati usando poli M2, vincoli espliciti e tie-break deterministici, senza leggere i parametri nominali dichiarati.
- Esteso il dataset M3 con criteri M3.1, candidati ammissibili, regola di selezione e verifica separata di coerenza col nominale.
- Aggiornate motivazione D-0006 e documentazione per distinguere `candidate comparison` da `candidate selection`.
- Esteso `run_all.m` al quality gate M4 completo: 48 test top-level, screening, fit, copertura, costruzione `Gunc`, coerenza nominale, 40 campioni, dataset e figure.
- Aggiornati README, checklist, diario, decision log e project status alla chiusura M4.

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
- Attuatore SISO ordine 3, DC gain 1, poli stabili e zero Padé RHP a 133.3333 s⁻¹.
- Blocco attuatori ordine 6 e pianta completa ordine 14 con dimensioni 4×2 per `[q;theta]`.
- Equivalenza frequenziale esatta fra augmentation esplicita e cascata indipendente sulla griglia 0.01–1000 rad/s.
- Pianta completa con 12 poli stabili, 2 instabili e nessun marginale o nuovo polo attuativo instabile.
- Controllabilità/osservabilità 14/14 sul tempo normalizzato e PBH a rango pieno su tutti i modi.
- Confronto Padé: errori fase 0.001063°/0.006028° sui modi instabili e 4.76162°/6.82742° a 70/80 rad/s.
- `run_all.m` M3 con 29/29 test top-level e quality gate M1–M3 PASS.
- M3.1 con finestra 28.8377–41.9726 rad/s, overshoot massimo 2% ed errore fase Padé massimo 10° a 80 rad/s.
- Candidati ammissibili C13, C14, C25 e C26; selezione da metriche C14, coincidente con 40 rad/s, 0.8 e 15 ms già dichiarati.
- `run_all.m` M3.1 con 34/34 test top-level, Code Analyzer senza messaggi e regressioni M0–M3 PASS.
- M4 con tre parametri meccanici su dieci, range baseline `k1/k2` ±7% e `Jm1` ±9%, più range attuatore ±8%/±7.5%/±20%.
- `WI` ordine 1 con polo -207.3533, zero -1.32753, worst ratio 0.9259259 e margine minimo 0.0130725 su 120 modelli.
- Coerenza nominale `Gunc`/M3 con errore assoluto massimo 6.328e-15 e 40/40 campioni `usample` validi con seed 20260825.
