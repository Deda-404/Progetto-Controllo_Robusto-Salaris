# Changelog

Tutte le modifiche tecniche rilevanti del progetto sono documentate in questo file.

## Unreleased

### Added

- Co-tuning M7 finale delle sole priorità adimensionali del costo augmentato, con Stage C1 completa da 75 candidati e gate vincolanti verso C2/C3.
- Dataset `m7_augmented_cost_feasibility.mat`, frontiera di Pareto, figura trade-off e confronto M6/I25/E16/finale.
- Funzioni riusabili per `Nff` candidato-specifico e valutazione del servo 2-DoF, più test M7 estesi per scale, stadi, target, offset e stop.
- Handoff `Resoconto_M7_final_feasibility_per_GPT.txt` per la revisione formale successiva.
- Servo LQI 2-DoF M7 con `Nff` derivato separatamente da ogni `Kx`, verifica DC, confronto 1-DoF/2-DoF e Stage A completa da 28 candidati.
- Unica Stage B autorizzata da 25 candidati, feasibility table con guadagni/poli e dataset `m7_lqi_2dof_feasibility.mat`.
- Figura dell’effetto feedforward e suite M7 completion T1–T20 per sequenza Stage A/B, derivazione `Nff`, indipendenza del rigetto e stop prestazionale.
- Augmentazione LQI M7 a 16 stati con due integratori di posizione, controlli PBH/Rosenbrock a zero e riuso esatto del costo fisico M6.
- Griglia M7 completa da 28 combinazioni `wi/rhoU`, metriche riproducibili di tracking e disturbo, dataset di checkpoint PARTIAL e figura originale del trade-off.
- Test M7 del checkpoint per dimensioni, struttura, costi, determinismo, offset, assenza di selezione impropria e governance.
- Documento `LQG_CON_INTEGRATORE.md` e handoff M7 che registrano lo stop prima della costruzione del controllore finale.
- Screening LQR M6 sul modello nominale completo a 14 stati, con costo fisicamente normalizzato, precompensatore statico per ciascun candidato e metriche di tracking/disturbo riproducibili.
- Coarse grid M6 da 240 costi LQR adimensionali, diagnosi modale del baseline, selezione C193 e tabella dedicata all'effetto di `wdelta`.
- Griglia Kalman da 27 covarianze fisicamente motivate, controllore LQG nominale di ordine 14, dataset M6 e sette figure riproducibili.
- Suite M6 T1–T26 per modello, costo, selezioni, prefilter, separazione, rumore, retuning, regressioni e governance.

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
- Test M4.1 T15–T18 per source of truth attuatore, dipendenza obbligatoria dallo screening, preservazione delle decisioni e regressione M0–M4.
- Source of truth M5 per scenari, banda, target sensitivity, scala di sforzo, pesi e obiettivi temporali.
- Selezione M5 riproducibile con tabelle candidate per `omegaB`, `W1` e `W2`, derivata dai dataset validati M2/M3.
- Modello non lineare del disturbo di coppia ai link, matrice `Bd` analitica e pianta nominale a ingressi separati `[u1,u2,d1,d2]`.
- Pesi `W1/W2` SISO e MIMO, dataset `m5_performance_specs.mat`, tre figure originali e documento `SPECIFICHE_PRESTAZIONE.md`.
- Suite M5 T1–T14 per centralizzazione, derivazione della banda, pesi, asintoti, disturbance path, regressione M0–M4.1 e governance documentale.

### Changed

- M7 resta `PARTIAL` dopo l'ultima feasibility: C1 produce 0/75 candidati ammissibili e 0/75 promettenti; C2/C3 non vengono eseguite e il prossimo passo è una revisione formale M5.
- Il costo LQI può variare coefficienti adimensionali mantenendo esattamente le scale M6/M7 e la costruzione `Qaug=CaugCost'*CaugCost`.
- M7 resta `PARTIAL` dopo il completamento 2-DoF: Stage A produce 0/28 candidati ammissibili e Stage B 0/25; M5 resta invariata.
- Stato corrente portato a M7 `PARTIAL`: tutti i candidati annullano l’offset costante, ma il miglior settling è 1.964 s contro il target M5 di 0.8 s; nessuna modifica automatica di M5.
- Corretta la classificazione epistemica M5: equilibrio D-0003 come decisione approvata e coppia ai link D-0014 come scelta di modellazione coerente con la traccia, senza variazioni numeriche.
- Esteso il costo LQR con priorità adimensionali mantenendo inalterate le scale fisiche M5; centralizzati i valori selezionati da metriche.
- Esteso `run_all.m` al tuning LQR, selezione Kalman, costruzione e quality gate LQG M6.

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
- Centralizzati i nominali attuatore M4 in `actuator_params_nominal.m`; rimossa la copia numerica da `uncertainty_params_m4.m`.
- Reso obbligatorio l'input `selectedMechanicalParameters` prodotto dallo screening, eliminando la preselezione silenziosa.
- Riformulate D-0007/D-0008/D-0009/D-0011 e la configurazione dei range con motivazioni esclusivamente tecniche.
- Normalizzati i metadati storici del diario in `Responsabile: Alessio` senza modificare attività, risultati, problemi, date o cronologia tecnica.
- Aggiunta in `AGENTS.md` la regola permanente sulla voce impersonale/plurale della documentazione di progetto.
- Esteso `run_all.m` al quality gate M5 con selezione delle specifiche, validazione dei pesi, verifica di `Bd`, disturbance path, dataset e figure, senza sintesi di controllori.

### Fixed

- Verificata la precedente rinomina di `MeS.gitignore` nel corretto `.gitignore`; aggiunta la terminazione di riga mancante.

### Removed

- Rimossi i placeholder `.gitkeep` dalle cartelle ora popolate `src/model`, `src/parameters` e `analysis/nominal`.

### Validated

- I cinque candidati LQR M6 sono stabilizzanti e rispettano overshoot, tracking statico e cross-coupling preliminare, ma falliscono tutti il target di settling 0.8 s con worst case 1.222–1.232 s; M6 arrestata come `PARTIAL` prima del Kalman.
- Il retuning autorizzato produce 139/240 candidati LQR ammissibili; C193 raggiunge settling 0.776 s con picco comando 0.3908 della scala prestazionale.
- KF03 rispetta il ratio stimatore/regolatore 1.6928; controllore LQG ordine 14, separation error 2.43e-6 e simulazione seeded riproducibile.
- `run_all.m` M6 con 92/92 test top-level, Code Analyzer senza messaggi, dataset e sette figure rigenerati.

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
- M5 con finestra di banda 10.8141–13.9133 rad/s, selezione `omegaB=12` rad/s, `W1(0)=20`, `W1(inf)=0.5`, `W2(0)=1/12` e `W2(inf)=0.5`.
- `Bd` contro differenze finite con errore nullo alla precisione numerica e sottosistema da `u` invariato rispetto a M3.
- `run_all.m` M5 con 66/66 test top-level, Code Analyzer senza messaggi, dataset e figure rigenerati e nessuna sintesi di controllo.
