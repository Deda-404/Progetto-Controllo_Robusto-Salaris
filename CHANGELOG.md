# Changelog

Tutte le modifiche tecniche rilevanti del progetto sono documentate in questo file.

## Unreleased

### Added

- Pipeline M14 di sola analisi per Kmu M13 congelato, derivata senza cambi di
  griglie/opzioni dalla pipeline M12 e con gate di identità Kmu/Punc/M4/M5.
- Verifica indipendente NS/NP/RS/RP, sostituzioni worst-case, confronto
  numerico A5/Kmu e classificazione deterministica del miglioramento RS senza
  uso del midpoint.
- Dataset `m14_final_mu_analysis_kmu.mat`, sei figure ingegneristiche,
  documento `MU_ANALYSIS_FINAL_KMU.md` e suite M14 T01–T56.

- Pipeline M13 per una singola campagna D–K full-order sul problema M4/M5
  congelato, con gate di identità Punc M12 e opzioni `musyn` persistenti.
- Estrazione completa della history R2025b, raw D/G scales, fit orders,
  controller Kmu e audit nominale esplicito di S/T/KS e poli interni.
- Dataset `m13_musyn_dk.mat`, sei figure tecniche, documento
  `MU_SYNTHESIS_DK.md` e suite M13 T01–T52.

- Pipeline M12 di sola analisi per il controllore strutturato A5 congelato,
  con audit M4/M5/M11, pianta generalizzata incerta condivisa e gate nominale.
- Decomposizione N–Δ mediante `lftdata`, verifica LFT nominale e non nominale,
  μ manuale su griglia fissa, `robstab`, `robgain` e `wcgain` con sostituzioni
  worst-case e diagnostica dei cinque blocchi M4.
- Dataset `m12_mu_analysis_a5.mat`, sei figure ingegneristiche, documento
  `MU_ANALYSIS_HINF_A5.md` e suite M12 T01–T54.

- Campagna M11 `hinfstruct` finita A0–A5 con guadagno statico MIMO, PI/PIDF
  decentralizzati e `tunableSS` full MIMO di ordine 2/4/6.
- Audit persistente di 30 partenze deterministiche, classificazione completa,
  stabilità interna senza `minreal`, ricostruzione `S/T/KS`, lower-bound M10,
  metriche di variabilità e selezione Pareto ordine/gamma.
- Dataset `m11_hinfstruct_structured.mat`, sei figure ingegneristiche,
  documento `HINFSTRUCT_IMPLEMENTABLE_STRUCTURES.md` e suite M11 T01–T48.

- Pianta generalizzata nominale M10 esplicita 1-DoF con ingressi `[r;u]`,
  uscite `[z1;z2;y]`, partizione documentata e audit indipendenti mediante
  forma analitica e `augw`.
- Gate obbligatorio pre-sintesi che richiude il controllore M9 congelato sulla
  nuova pianta e verifica mappe pesate, norma e coerenza dell'interconnessione.
- Pipeline `hinfsyn` nominale con una sola sintesi di default, ricostruzione
  indipendente di `S/T/KS`, valutazione comune M6/M9/M10 e classificazione
  esplicita della quasi-equivalenza M9/M10.
- Dataset `m10_hinfsyn_nominal.mat`, sei figure ingegneristiche, documento
  `HINF_HINFSYN_GENERALIZED_PLANT.md` e suite M10 T01–T40.

- Pipeline nominale M9 modulare per audit della pianta M3/M5, sintesi
  `mixsyn`, ricostruzione indipendente di `S/T/KS`, stabilità interna e
  valutazione tracking/disturbo/confronto M6.
- Dataset `m9_hinf_mixsyn_nominal.mat`, sei figure ingegneristiche, documento
  `HINF_MIXSYN_NOMINALE.md` e suite M9 T01–T29.

- Modello originale `SEA_LQG_nonlinear.slx` con 14 stati fisici, stimatore M6
  a 14 stati, coordinate assolute/incrementali esplicite e nessuna dipendenza
  dal base workspace.
- Pipeline M8 per equilibrio, tracking 2/5/8°, disturbi lato link, rumore
  seeded, confronto LTI/non lineare e metriche di sforzo/deformazione.
- Ricerca RAS empirica deterministica con griglia 5×5, 36 direzioni, bisezione,
  criterio di coda e seconda sezione a stima iniziale coerente.
- Dataset `m8_lqg_nonlinear_ras.mat`, cinque figure, documento
  `SIMULINK_RAS_LQG.md` e suite M8 T1–T18.

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

- Esteso `run_all.m` fino a M14 mantenendo M13 artifact-only: Kmu recupera
  Robust Stability (`PASS_CERTIFIED`) rispetto ad A5, mentre NP/RP restano
  fallite e M14 è `PARTIAL` senza retuning o avvio M15.
- Aggiornato lo stato Git per registrare PR #18 mergiata al commit
  `49f37c6e027aaa37db65f27530901965f897f11f`.

- Esteso `run_all.m` a M13 senza rilanciare la campagna congelata; l'artifact
  autorizzato viene ricaricato e sottoposto ai gate software/nominali.
- Registrata PR #17 come merged e M13 come milestone `COMPLETE`; M12 resta
  `PARTIAL` e M6 resta il controllore nominale con tracking conforme.

- Esteso `run_all.m` a M12 dopo M11, mantenendo congelati controllore A5,
  incertezza M4 e pesi M5 e distinguendo NS, NP, RS e RP nel messaggio finale.
- Aggiornati stato, README e checklist: PR #16 è mergiata, M11 `PARTIAL` è
  accettata e M12 resta `PARTIAL` per NP/RS/RP non conformi, senza M13.

- Esteso `run_all.m` a M11 mantenendo congelati pianta M10, pesi M5,
  architettura 1-DoF e scenari M9/M10; nessun retuning, W3, prefilter o M12.
- Portato lo stato corrente a M11 `PARTIAL`: A3/A4/A5 restano candidati
  Pareto per revisione del gruppo, senza score o selezione automatica.

- Esteso `run_all.m` a M10 mantenendo congelati pianta M3, pesi M5,
  architettura 1-DoF e scenari M9; M10 è classificata `PARTIAL` per
  `gamma>1` e tracking non conforme, pur con quality gate software `PASS`.
- Aggiornati stato, checklist e decisioni per distinguere la validazione
  dell'interconnessione nominale dalla soddisfazione delle prestazioni.

- Esteso `run_all.m` a M9 mantenendo M7 `PARTIAL` terminale e classificando
  separatamente correttezza software e fallimenti prestazionali M9.
- Corretto lo stato della PR #13 come mergiata; M8 resta `COMPLETE` e M9
  diventa il checkpoint corrente `PARTIAL` senza modifiche a M5.

- M7 è congelata come feasibility terminale `PARTIAL`; M8 usa il solo
  controllore M6 invariato e porta la milestone corrente a `COMPLETE`.
- Esteso `run_all.m` alla costruzione e al quality gate M8 completo.

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

- M13: 5/5 iterazioni, best iteration 3, objective `10.4032233618`, Kmu
  ordine 52, 66 stati interni, max Re `-0.731994726169` e norma nominale
  `10.3917314574`; nessun warning o lower-bound violation.
- Suite M13 52/52, suite completa e `run_all` 362/362 con exit code 0;
  Code Analyzer M13 senza messaggi. Nessuna analisi M14 è stata eseguita.

- M12: NS `PASS` con max Re `-0.736157095561`; NP `FAIL` con norma
  `10.2476411502`; RS `FAIL_CERTIFIED` con margin
  `[0.875899252687,0.882789198079]`; RP `FAIL_CERTIFIED` con margin `[0,0]`.
- μ manuale e `robstab` coerenti: margin manuale
  `[0.879212158739,0.883347347680]` e frequenze critiche 81.596/81.986 rad/s.
  `wcgain` è `[Inf,Inf]` e la sostituzione worst-case è vicina al limite di
  stabilità, con norma numerica `4.45231081353e14`.
- Suite M12 54/54, regressione M9–M12 171/171, suite completa e `run_all`
  310/310 con exit code 0; Code Analyzer M12 senza messaggi.

- M11 ha restituito 30/30 record e 15 chiusure stabili: A3/A4/A5 sono tutte
  stabili su 5/5 start, con best gamma 16.6418540, 11.6555347 e 10.2477452.
- Ricostruzione e lower-bound sanity `PASS`; target weighted, tracking e
  cross-coupling globale `FAIL`, quindi M11 resta `PARTIAL` con software
  correctness `PASS`.
- Suite M11 48/48, regressione M9/M10/M11 117/117, `run_all` 256/256 con
  exit code 0 e Code Analyzer senza messaggi sui file M11.

- Sintesi M9 con controllore ordine 18, `gamma=10.2071036477`, norma stacked
  ricostruita `10.2071033931`, errore relativo `2.495e-8`, errore `CLmix`
  `4.313e-12` e massima parte reale dei poli interni `-0.683828559884`.
- `||W1*S||inf=10.1276254519` e `||W2*KS||inf=10.1853081898`; target
  weighted, tracking e cross-coupling non soddisfatti, senza retuning o W3.
- `run_all.m` M9 con 168/168 test top-level ed exit code 0; suite M9
  29/29, Code Analyzer senza messaggi su otto file e `git diff --check` PASS.

- Equilibrio Simulink con errori massimi q/theta/u rispettivamente
  `4.086e-17`, `3.845e-17` e `1.686e-15`.
- Sei tracking e sei disturbi non lineari; scarto LTI/NL massimo
  `6.2015e-4 rad`; rumore seed 20260826 riproducibile.
- Entrambe le sezioni RAS con 57/57 punti convergenti nel box computazionale
  ±60°, 36 direzioni e area poligonale 14214 deg²; frontiera search-box
  limited, non certificato analitico.
- `run_all.m` M8 con 139/139 test top-level, exit code 0 e Code Analyzer senza
  messaggi sui nove file MATLAB M8 nuovi o modificati.

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
