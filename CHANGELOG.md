# Changelog

Tutte le modifiche tecniche rilevanti del progetto sono documentate in questo file.

## Unreleased

### Pesi diretti H-infinity, LQR e LQRI — 2026-09-16

- Spostati i pesi mixed-sensitivity dal Capitolo 6 al §8.2; nuova figura
  Lower LFT M10, senza W3 inesistente nella pianta di produzione.
- Rimossa la trasformazione di coordinate H-infinity; ricerca deterministica
  di 12 candidati fisici, tutti non conformi. Nuovi pesi M5 attivi,
  omegaW1 distinto da omegaB per preservare Q del LQR.
- R M6 diretto su {0.01,0.05,0.10}; Qi M7 diretto su {20,200,800},
  senza xiScale. R=0.10 I2 selezionato dai criteri esistenti.
- Rigenerate le sintesi dipendenti M9–M13 e M14. Il nuovo Kmu di ordine 70
  fallisce RS: rimosso il trasferimento improprio del certificato precedente.
- Corretto il controllo wcgain: il worst-case restituito realizza il lower
  bound; un upper bound infinito, da solo, non ne implica instabilità.
- Adeguato il solo budget RAS M15 al massimo deterministico di 626 chiamate,
  senza cambiare criteri di convergenza; aggiunto checkpoint con identità sorgenti.
- Rigenerate M8/M15/M16/M17, Lyapunov e 48 traiettorie; M6 stabile in
  37/40 campioni, Khinf/Kmu in 40/40, senza attribuire garanzie robuste.
- Test mirati M6/M7 36/36 PASS; unica suite globale 658/660 PASS.
  Due aspettative storiche aggiornate (avvio A5=4; instabili M6=5,6,35):
  riesecuzione mirata 2/2 PASS, senza una seconda suite globale.
- Code Analyzer: 177 file, zero segnalazioni. PDF auditati e controllati
  visivamente: relazione 70 pagine e presentazione 19 slide.


### LQRI con Kalman M6 e peso R diretto — 2026-09-14

- Sostituita la retroazione ideale M7 con `u=-Kx*xhat-Ki*xi`, integrando
  l'errore degli encoder; Kalman M6 invariato e nessun prefiltro M7.
- Costruite e verificate la CARE aumentata, la realizzazione del controllore
  a 16 stati e la chiusura reale a 30 stati con principio di separazione.
- Parametrizzata R direttamente con ru={1/36,1/18,1/9}, senza cambiare
  le matrici R o la selezione M6. Tre wi a Q/R fissi, senza nuova ricerca.
- Sostituiti gli asset attivi M7, aggiunto tracking LQG/LQRI con comandi
  e integratori; mantenuti gli esiti negativi sul target di settling.
- Adeguati test M6/M7, generatori M18, §7.2.4 e §7.6 della relazione.
- Aggiunto percorso `CR_RUN_SCOPE=lqri` per verificare le sole dipendenze
  coinvolte senza rilanciare H-infinity o analisi robuste/non lineari.

### Revisione mirata LQI / H-infinity — 2026-09-10

- Approfondita localmente la sola §7.6; preservate le precedenti sezioni
  Q/R, CARE, Kalman e Lyapunov. Aggiunto confronto di disturbo LQG/LQI.
- Audit dei pesi originali e campagna deterministica separata a tre pesi:
  13 candidati e 2 sintesi diagnostiche, cache MATLAB, nessuna musyn.
- Conservati gli esiti negativi e la baseline M9–M16; ID 10 illustrativo,
  non nuovo controllore finale. Cinque campioni M4 sono soltanto empirici.
- Quattro figure H-infinity, due LQI e due tabelle generate; inventario M18
  esteso a 23 sorgenti, 19 file tabellari e 30 asset.
- Estese verifiche in test già presenti, senza nuovi file di test.
- Compilazione della sola relazione tramite opzione ReportOnly, senza
  modificare la presentazione.
- Registrata la successiva richiesta di pubblicazione del branch e PR
  verso main; nessuna ulteriore modifica tecnica o merge automatico.

### Pubblicazione Git — 2026-09-09

- Conservato il MAT delle traiettorie Lyapunov mediante Git LFS: il push
  ordinario è stato rifiutato dal limite GitHub di 100 MiB per file.
- Aggiornate le istruzioni di clone; nessuna modifica a codice, risultati,
  figure o PDF. Adeguato soltanto il commit locale non ancora pubblicato.

### Revisione tecnica Lyapunov — 2026-09-08

- Riscritti i percorsi didattici LQG e H-infinity: scale, Q/R, CARE, Kalman,
  sensibilità a rumore identico, generalized plant e simulazioni esplicite.
- Aggiunto Lyapunov nominale aumentato per LQG/Khinf/Kmu con bound cubico
  analitico e livello campionato separato; salvate 48 traiettorie di controllo.
- Rigenerate figure a sfondo bianco con assi/testi neri; ampliate le sezioni
  7.2–7.4 e 10 della relazione, aggiunte slide Q/R, Kalman e Lyapunov.
- Esportate automaticamente matrici e tabelle; aggiornate tracciabilità,
  note orali e timing (19 slide, 19:00).
- L'audit LaTeX ora fallisce anche per overfull; il generatore M18 non
  dichiara più autonomamente PASS la suite che non esegue.
- Nessuna modifica ai controllori congelati, ai pesi M5 o alle conclusioni
  negative; nessuna nuova sintesi robusta o retuning.

### Added

- Script didattico `analysis/modellazione_linearizzazione_controllo.m`, che
  riunisce M0–M5 in una macrofase eseguibile per sezioni.
- Ricerca LQR compatta M6 da 36 combinazioni leggibili, filtro preliminare
  sui gate M5 e selezione LQR30 fra 9 candidati ammissibili.
- Sensibilità Kalman su tre livelli di rumore encoder e tre script didattici
  separati per M0–M5, M6–M8 e M9–M12.
- Resoconto conclusivo `docs/RESOCONTO_REVISIONE_LQR_LQG_HINF_RAS.md` e
  versione TXT trasferibile a un'altra chat.

- Audit editoriale conclusivo in `docs/FINAL_EDITORIAL_AUDIT.md`, con
  classificazione delle occorrenze operative residue e verifica degli
  invarianti tecnici.
- Motivazioni ingegneristiche estese nella relazione: modello, equilibrio,
  attuatori, incertezze, pesi, LQG, esito negativo M7, sintesi H-infinity,
  analisi mu, validazione non lineare, RAS e Monte Carlo.
- Relazione editoriale finale di 47 pagine e presentazione di 17 slide,
  entrambe compilate e ispezionate integralmente.

- Pipeline M18 artifact-only per caricare gli artifact congelati M1–M17,
  riconciliare 78 valori e generare macro, 11 tabelle, manifest di 18 figure,
  13 asset di presentazione e audit finale.
- Relazione finale modulare in LaTeX (13 capitoli, 3 appendici, PDF di 27
  pagine) e presentazione Beamer 16:9 (17 slide, timing stimato 17:30), con
  note oratore, manifest, matrice di tracciabilità e suite M18 T01–T60.

- Pipeline M17 artifact-only per audit identità M6/Khinf/Kmu, separazione
  delle quattro classi di evidenza, tabelle di stabilità/performance/RAS/
  comando/complessità e selezione gerarchica per ruolo senza score globale.
- Dataset `m17_final_controller_comparison.mat`, sette figure per la
  relazione, documento `FINAL_CONTROLLER_COMPARISON.md` e suite class-based
  M17 T01–T42.

- Pipeline modulare M16 per una singola sequenza comune di 40 campioni M4,
  ricostruzione fisica a stato condiviso, chiusure M6/Khinf/Kmu, metriche
  temporali/frequenziali, statistiche, pass rate e confronti paired.
- Dataset `m16_monte_carlo_uncertain_linear.mat`, nove figure ingegneristiche,
  documento `MONTE_CARLO_UNCERTAIN_PLANTS.md` e suite class-based T01–T69.

- Modello dedicato `SEA_ROBUST_nonlinear.slx` per Khinf M10 e Kmu M13
  congelati, feedback q-only, attuatori M3 e meccanica non lineare M1.
- Pipeline M15 modulare per equilibrio, 12 tracking, 12 disturbi, rumore
  comune seeded, confronti LTI/NL, due RAS empiriche e due regioni di accordo.
- Dataset `m15_nonlinear_robust_validation.mat`, otto figure ingegneristiche,
  documento `NONLINEAR_VALIDATION_HINF_MU.md` e suite M15 T01–T60.

### Changed

- Unificato M4 in un solo insieme incerto: `Jm1`, `k1`, `k2`, `wn` e
  `zeta` a ±10%, ritardo a ±20%, con copertura WI di ordine 1 verificata.
- Sostituite le ricerche automatiche non necessarie con scelte
  ingegneristiche dichiarate; resta soltanto la ricerca LQR compatta M6
  richiesta. M5, Khinf e Kmu restano congelati.
- Rieseguite M12, M14, M16 e M17 sull'M4 corrente senza nuova `musyn`: A5
  fallisce RS con margine `[0.849720,0.859945]`, Kmu conserva RS certificata
  con `[1.069561,1.212875]`; con LQR30 M16 vale 38/40, 40/40, 40/40.

### Removed

- Selettori, screening, griglie e ranking obsoleti di attuatori, specifiche,
  Kalman e LQI, insieme ai relativi dataset e grafici non più prodotti.

- Inseriti Alessio de Dato e Valerio Rebechi come autori di relazione,
  presentazione, README e manifest; restano da completare matricole e data.
- Separati nella presentazione il ruolo di M13, che produce Kmu, e quello
  di M14, che certifica la Robust Stability.
- Corretta la tabella Monte Carlo: numero di casi instabili e Sample ID
  instabile sono ora colonne distinte; la percentuale è denominata frazione
  empirica.
- Uniformate in italiano le tabelle di ruoli e limiti e aggiornate le
  percentuali di incertezza con il segno più/meno.
- Resi più naturali i commenti MATLAB e i messaggi della pipeline M17/M18,
  senza modificare logica o dati.
- Aggiornati i test M3–M8 e M15–M18 per la ricerca LQR, la sensibilità
  Kalman, il modello Simulink didattico e il confronto RAS comune.
- Gate finale: 599/599 test PASS, `run_all` M0–M18 PASS, Code Analyzer
  pulito su 162 file, relazione di 47 pagine e presentazione di 17 slide.

- Esteso run_all.m fino a M18. La fase M18 genera e verifica soltanto i
  deliverable, mantenendo congelati M4, M5 e i controllori Khinf/Kmu dopo
  l'aggiornamento autorizzato di M6.
- Documentati senza promozione gli esiti PARTIAL/FAIL: M7 senza controllore
  finale, NP/RP e tracking falliti, Sample 5 e 6 M6 instabili, RAS/Monte Carlo
  empiriche e assenza di saturazioni hardware certificate.

- Esteso `run_all.m` fino a M17: M17 carica gli artifact congelati e non
  esegue nuova sintesi, tuning, Monte Carlo, Simulink o riduzione.
- Registrata D-0044: Kmu final robust controller, M6 nominal performance
  reference e Khinf H-infinity comparator; nessuna conformità globale M5 o
  Robust Performance Kmu dichiarata.

- Esteso `run_all.m` fino a M16 senza rilanciare `musyn`, ritunare M5,
  ridurre controllori o avviare M17; aggiornati status, checklist e README.
- Registrato il percorso A D-0043: specifiche e controllori congelati,
  risultati negativi conservati e Monte Carlo distinta dalla garanzia mu.

- Esteso `run_all.m` fino a M15, mantenendo M13 come artifact congelato e
  separando la RS lineare-incerta M14 dalla validazione nominale non lineare.
- Aggiornati status, checklist e README: M15 è `PARTIAL` perché entrambi i
  controllori falliscono i target tracking M5 senza retuning.

### Fixed

- Rimossa la dipendenza del test M7 dai resoconti intermedi; il controllo
  usa ora diario, stato del progetto e documento tecnico M7.

- La risposta LTI al disturbo usa una realizzazione a stato fisico condiviso,
  equivalente a `S*Gd`/`-KS*Gd`, evitando cancellazioni numeriche di copie
  duplicate dei modi instabili della pianta.

### Removed

- Rimossi dal ramo corrente i resoconti operativi intermedi non necessari
  alla riproduzione. La cronologia Git ne conserva l'evoluzione.

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

- M16: 40/40 campioni M4 validi e riproducibili con seed `20260826`; errori
  massimi della pianta fisica condivisa `5.274e-16` assoluto e `2.895e-12`
  relativo verso q; gate nominali M6/Khinf/Kmu `PASS`.
- Stabilità empirica M6/Khinf/Kmu `39/40`, `40/40`, `40/40`; il Sample 5 M6
  è conservato come instabile con max Re `+1.80447`. Kmu è coerente con la
  RS M14 senza attribuire valore certificante alla Monte Carlo.
- Tracking core pass rate totale M6/Khinf/Kmu `30%/0%/0%`; banda, disturbi,
  cross-coupling e comando quantificati senza saturazione o score globale.
- Suite dedicata M16 69/69 `PASS`, regressione M14–M16 185/185 `PASS`, suite
  completa standalone e `run_all` 547/547 `PASS`; Code Analyzer senza
  messaggi sui file M16 e `run_all.m`.

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

## 2026-09-17 — Revisione H-infinity isolata

Aggiunta campagna separata M9--M11 con filtro lower bound e unico ampliamento:
21 candidati, 1 escluso prima della sintesi, 20 confronti mixsyn/hinfsyn.
Full-order gamma=0.866036; 66 avvii fixed-order, ordine minimo trovato 6,
objective=0.879311. Tracking 1-DoF ancora FAIL; estensione con prefiltro
2-DoF conforme ai target temporali rivisti, non alla nuova norma pesata.
Capitolo 8 e dieci figure aggiornati; baseline integrale conservata.
Test mirati 7/7 PASS, Code Analyzer senza segnalazioni. Nessuna mu-analysis.
Resoconto e riproducibilità: docs/RESOCONTO_HINF_TARGETED_RETUNING.md.
