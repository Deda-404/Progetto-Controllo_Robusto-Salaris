# Changelog

Tutte le modifiche tecniche rilevanti del progetto sono documentate in questo file.

## Unreleased

## 2026-11-01 — Collaudo e consegna definitiva

- Percorso unico completo eseguito, A/B confrontati a controllore fissato e dopo le sintesi dedicate; risultati negativi preservati.
- 150 prove RAS, venti prove non lineari, 110 chiusure fisiche e 28 run Simulink; otto SLX invariati.
- Copia estratta autonoma verificata con rapida e tutti i run SLX; sorgenti/ingressi identici per hash.
- Relazione conservata e aggiornata a 120 pagine, 23 slide con stessi titoli, discorso stimato 17:42; grafici e schemi verificati visivamente.
- Pubblicati branch e PR #46 per revisione, senza merge; consegna ZIP e manifest SHA-256 inclusi.

## 2026-10-31 — Revisione definitiva A/B, primo consolidamento

- Modellazione attuativa parametrica e concentrata nello stesso percorso accorpato, nominale e controllori originali conservati.
- Campioni comuni, LFT esplicita, fitting e copertura dinamica continua dei casi provati; nessuna inclusione globale presunta.
- Sintesi e confronti separati dai risultati storici; limiti e fallimenti registrati in docs/REVISIONE_DEFINITIVA.md.
- Relazione, collaudo integrato e consegna in completamento sul medesimo branch.

## 2026-10-13 — Sintesi con rumore e orale finale

- Nuova pianta nominata con encoder esogeni, tre H∞ e una μ separati; W1/W2/Mo, fisica e cinque incertezze conservati.
- Rumore su tre seed/otto scenari, picchi fra campioni e RMS integrato; nuovi robstab/robgain/mussv sui problemi nuovo e precedente.
- Otto run Simulink abbinati con identità dei coefficienti salvata; nessuna modifica degli originali. MuN1: picco non lineare ridotto 48.21 volte e RMS 9.446 volte, con RS/RP mantenute e offset q1 peggiore. H∞ respinti come soluzioni robuste.
- Stessi dieci impianti, RAS completa dei candidati e fallimento numerico Lyapunov μ esplicito; baseline e 197 MAT/SLX preesistenti invariati.
- Quattro script rieseguiti, 141 regressioni e sette test dedicati PASS. Audit Code Analyzer senza segnalazioni.
- Relazione 108 pagine, 23 slide, tre nuovi grafici e schemi autentici; audit LaTeX e controllo visivo. Discorso di 2237 parole, 18:47 stimati, appendice di 25 risposte.
- Due TXT completi, accettazione e consegna con preparazione studenti distinta. Pubblicazione del branch per revisione; adozione e merge riservati agli studenti.
- Branch pubblicato con otto nuovi oggetti LFS (232 MB); [PR #41](https://github.com/Deda-404/Progetto_CR/pull/41) aperta in bozza per revisione, senza merge.

## 2026-10-13 — Collaudo finale MATLAB/Simulink

- Esecuzione locale R2026b degli otto SLX originali, compilazione e acquisizione Scope in sola lettura; 12 combinazioni validate, SHA-256 invariati.
- 141 regressioni e quattro script PASS in R2025b/R2026b; solo tolleranza K/L del test portata a 1e−10. Primo fallimento conservato; 80 artifact congelati invariati.
- Decoder vettoriale Scope, runner con errore su verifiche incomplete, schemi autentici e dati completi con Git LFS; selettori/rumori correlati documentati.
- Margini robusti R2026b, differenza quantitativa H∞ tra release esplicita, rumore critico e target negativi preservati.
- Relazione 100 pagine e presentazione 22 slide/18:45, autori/matricole/data completi, grafici descrittivi senza cronologia, audit e controllo visivo PASS.
- Manifest, dipendenze, istruzioni, pacchetto/ZIP di 327 file con verifica esatta dei file copiati e quattro default PASS da copia isolata; dati e cronologia del repository preservati. Pubblicazione per revisione senza merge.
- Gate G PASS: branch e otto oggetti LFS pubblicati, [PR #40](https://github.com/Deda-404/Progetto_CR/pull/40) aperta per revisione, senza merge.


### Importazione dei modelli Simulink dal Drive del progetto — 2026-10-10

- Aggiunta `simulink/drive_project/` con i cinque SLX della cartella condivisa
  e tutti i 32 componenti del suo `Hinf_nonlinear_sim.slx/` estratto.
- Nuove versioni LQG/LQGI lineari e non lineari; H∞ lineare identico alla copia
  esistente, contenuto H∞ non lineare identico a `Progetto_Hinf_simulink.slx`.
- Manifest di provenienza e SHA-256 per 37 file; dimensioni e cinque CRC ZIP
  verificati. Sei originali precedenti invariati; terminazioni di riga preservate.
- Importazione COMPLETE / PASS; simulazioni NOT RUN. Pacchetti R2026a Update 4,
  nessuna conversione di release, rigenerazione o modifica dei diagrammi.

### Raccolta dei quattro script MATLAB accorpati — 2026-10-10

- Aggiunta `File_di_Funzioni_Progetto-Accorpati/` con LQG, LQGI, H∞ a tre
  configurazioni e µ analisi/sintesi, più istruzioni di esecuzione.
- Copie identiche alle versioni consegnate, con gli originali in `analysis/`
  conservati; nessuna modifica a contenuto scientifico o artifact esistenti.
- Branch dedicato da main 8e8de25 e revisione in bozza, senza merge automatico.
- Gate organizzativo PASS: SHA-256 delle quattro copie e percorsi LQG/LQGI
  verificati; nessuna nuova sintesi, simulazione o campagna numerica.


### Revisione LQGI/H∞/µ — 2026-10-06

- Nomi attivi LQGI e architettura verificata con xhat e integratore dell'errore misurato; guadagni M7 e Kalman M6 invariati.
- Nuove prove lineari/non lineari, rumore ZOH e RAS LQGI; 57/57 punti, box esaurito, nessuna saturazione. Sette nuovi test, 112/112 PASS.
- Confronto Mo 2/3/4 dai controllori salvati, motivazione basata sul criterio effettivo. Figure 8.4/8.6 rigenerate, 8.2 riposizionata, Tabella 8.4 riordinata.
- Capitolo 9 chiarito con definizione strutturata di µ e significato distinto dei margini robstab/robgain; preservati tutti gli esiti negativi.
- Tre originali lineari acquisiti dal Drive; sei file invariati, audit di versione fallito, istruzioni manuali per SID senza sostituti automatici.
- Relazione 83 pagine, 29 estratti MATLAB; presentazione 19 slide, 17:45. Audit PDF PASS e revisione visiva completata.
- Audit automatico di fonti, asset, nomenclatura e 85 artifact protetti invariati; cronologia preservata e vecchio generatore Hinf disabilitato nella CLI.


### Semplificazione H∞/µ e appendice MATLAB — 2026-10-02

- Riscritti i capitoli 8–9 con spiegazione progressiva di pesi, pianta
  generalizzata, Mo, sintesi 1-/2-DoF, strutture e robustezza.
- Aggiunti due schemi TikZ, tre tabelle dai dati salvati e appendice D:
  27 estratti letterali, 210 righe MATLAB, provenienza registrata.
- Conservati capitoli 1–7, controllori, sorgenti MATLAB, dati, SLX e
  presentazione; distinti risultati correnti e campagne precedenti.
- Relazione di 74 pagine: tre passaggi pdflatex, audit PASS senza warning
  LaTeX finali; controllo visivo delle parti modificate e degli indici.
- 20/20 controlli MATLAB esistenti PASS (sottoinsieme della suite precedente),
  senza nuove sintesi, analisi robuste, campagne Monte Carlo o RAS.
- Base origin/main 8ca8e7e con PR #33 già integrata; nuova branch dedicata,
  nessun merge automatico. Resoconto ed evidenze in docs/didactic_review.

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

## 2026-09-22 — Catena H-infinity 2-DoF coerente

Base693e316. Lower bound sigma_min confermato (7 test);21 profili1-DoF,3 veri2-DoF,
66 avvii hinfstruct. Hinf selezionato22stati,norma.04746,tracking migliore ma RS.0181,
0/40 MonteCarlo e forte amplificazione del rumore. D-K corrente produce Kmu78stati;
post-analisi RS[1.7998,1.8044],RP[1.6772,1.6807],40/40 stabili.
NL/rumore/RAS/Lyapunov ricalcolati in MATLAB. Hinf Lyapunov e intervallo RP numerico
non validati; nessun risultato negativo nascosto.18 test MATLAB PASS.
Relazione e resoconto aggiornati,baseline conservate. Nessun merge.

Chiusura editoriale: relazione compilata senza riferimenti indefiniti o overflow, figure correnti su fondo bianco con assi neri; macro confrontate con summary MATLAB e hash verificati. Commit tecnico e04ec4d. Nessuna nuova sintesi per la verifica editoriale.


## 2026-09-23 — Integrazione Simulink

Integrati4modelli Simulink da Valerio con setup artifact, canali fisici corretti, rumori separati, Kalman, integratore misurato e vera2-DoF Hinf/Kmu. Aggiunti validatore e scope di esecuzione;67/67 controlli+7/7 test PASS. Relazione e presentazione aggiornate.

## 2026-09-23 — Completamento circoscritto PR #33

- Aggiunto SEA_linear_common: plant M3 a 14 stati, quattro controllori da artifact.
- 32 confronti numerici PASS; RAS LQRI nominale 57/57, SEARCH-BOX LIMITED.
- 15 test aggiunti e 7 originari rieseguiti PASS; 67 controlli salvati invariati.
- Conservato il primo run con quattro FAIL causati dall'uso di linmod nel test;
  corretta la sola chiamata, senza cambiare modello, guadagni o soglie.
- Relazione aggiornata dopo validazione; presentazione 24 -> 20 slide, 17:55.
- Nessuna sintesi o campagna robusta rieseguita; PR draft, nessun merge.


## 29 settembre 2026 — Revisione organica e consegna degli originali

Richiesta del 28 settembre: usare esclusivamente gli originali del gruppo, senza costruire o completare automaticamente diagrammi. La decisione sostituisce il precedente percorso d'integrazione; le voci anteriori restano cronologia e non descrivono la consegna attuale.

Analisi preliminare di repository, traccia, artifact e materiale dei colleghi. Capitoli 1–7 conservati nei contenuti, salvo due correzioni verificate nel Capitolo 3 e rimandi/stile. Riscritti Capitoli 8–9, aggiunti schemi LFT, prestazione e D–K, grafici da dati salvati. Presentazione 19 slide, 17:15.

Backup completo esterno verificato prima delle rimozioni; conservate copie esatte del working tree. Tre originali spostati senza modifica dei byte in simulink/originals; rimossi generatori, diagrammi e dipendenze esclusivi dalla consegna. Inventario e hash in docs/organic_review.

104/104 test MATLAB PASS, 8 nuovi. Due suite riscrivono internamente m3/m5: isequaln con il baseline PASS, byte ripristinati e protezione aggiunta al runner. Audit originali: tre FAIL di caricamento per R2026a su R2025b; zero simulazioni accreditate. Errori preparatori nell'audit (nome del MAT e accumulatore di strutture/codice MATLAB in cache) corretti prima dell'esportazione, senza modificare risultati. Nessuna nuova sintesi, mu-analysis, Monte Carlo o RAS.

Relazione e presentazione compilate e verificate graficamente; rimossi gli overflow delle prime bozze. Controllori e artifact numerici consolidati invariati. Conformità complessiva PARTIAL: completamento e validazione degli originali richiedono intervento manuale. PR #33 rimane draft, nessun merge.

Verifica finale aggiuntiva: corretto il callback onCleanup con cattura esplicita dei valori; test di interruzione su file temporanei PASS. Totale aggiornato: 105/105 test, 9 nuovi. Aggiunte tabelle dei candidati strutturati e del disturbo dai dati salvati.

## 10 ottobre 2026 — Refactoring didattico H∞ e μ

- Due script accorpati con 13 sezioni: H∞ 913→458 righe, μ 2098→461.
- Matrici e risultati recuperati dai MAT esistenti, con realizzazioni identiche;
  PID ricostruito con pid2 dai parametri salvati, senza nuovi artifact.
- MATLAB R2025b Update 4: default, analisi archiviate e risintesi PASS;
  confronto numerico esatto, variabili Workspace e file mancanti verificati.
- Test ripetibili e resoconto in docs/RESOCONTO_REFACTORING_DIDATTICO.md.
  LQG/LQGI, Simulink, risultati, relazione e presentazione invariati.
- Branch codex/refactoring-didattico-hinf-mu da main 6133365, nessun merge.

## 2026-10-12 — Integrità degli otto modelli e audit corrente

Branch codex/chiusura-definitiva-progetto-sea da main fa78e588ede9b8a136692c19aeb39b01b56cb502. Working tree iniziale pulito; checkout separato per conservare la copia Desktop. Recuperati gli otto SLX dalla cartella Drive 1wDiaAQVR7cDDt7T8WUlyZ0vgEa-2LWLx, conservati sotto simulink/student_originals. SHA-256 download/importazione/dopo caricamento identici 8/8; CRC ZIP validi. Nessuna modifica, conversione, set_param o salvataggio degli originali. I tentativi read-only falliscono in R2025b Update 4 perché gli SLX sono R2026a Update 4: simulazioni NOT RUN, non attribuite alle prove MATLAB. L'inventario XML corrente sostituisce le conclusioni su disponibilità e collegamenti delle copie datate.

Primo runner: 111/112 PASS, un FAIL nel conteggio globale degli SLX di organicReviewTest; gli hash dei sei file storici restano identici. Il controllo viene circoscritto alla sua cartella originale e affiancato dalla verifica degli otto file attuali. Le campagne scientifiche e i documenti restano in lavorazione; nessuna dichiarazione di prontezza alla consegna. Gate integrità COMPLETE/PASS; gate Simulink PARTIAL/NOT RUN.

## 2026-10-12 — Diagnosi conclusiva MATLAB e confini scientifici

Branch codex/chiusura-definitiva-progetto-sea. Aggiunti runner esterni senza sintesi o riduzioni: sette scenari di rumore, propagazione ZOH fra campioni e doppia realizzazione; dieci nuovi impianti fisici incerti comuni più nominale, seed 20261012 e replay esatto; Lyapunov nello stato intero e griglia comune 150 punti. H∞ 2-DoF: picco encoder osservato 492784.658 N m, RMS integrato 13196.215; Kµ 87.096/8.288. Instabilità H∞ in 10/10 piante incerte, Kµ stabile 10/10. LQG/LQGI/Kµ 25/25 punti empirici; H∞1 23/25; H∞2 24 arresti numerici; PID 18 timeout del solver, tutti distinti da mancata convergenza fisica. Solo LQG/LQGI superano il gate numerico Lyapunov.

141/141 test MATLAB PASS, inclusi hash otto originali, setup bus, esiti RAS ignoti e condizioni per i livelli Lyapunov. Quattro default didattici PASS, Code Analyzer senza messaggi; 80 artifact fisici/controllori congelati identici. Corrette asserzioni sul conteggio storico SLX e singleton finale delle ss-array. Setup Simulink esterno, originali mai modificati. Gate analisi/test COMPLETE/PASS; prestazioni operative rumore FAIL; validazione SLX PARTIAL/NOT RUN per release R2026a. Documento e PDF in consolidamento, nessun merge.

## 2026-10-12 — Elaborati finali e manifest per revisione

Relazione 97 pagine e presentazione 21 slide compilate con audit PASS: zero errori, riferimenti indefiniti, destinazioni duplicate o contenuti fuori pagina. Esaminate tutte le slide e le pagine modificate dei Capitoli 9–11; sistemati colori delle esportazioni MATLAB e viste per l’orale. Scaletta verificata per somma: 17:50, 18:20 con slide autentica opzionale. Rimossa dal PDF la precedente campagna 40 campioni; nuovo Capitolo 11 con dieci impianti, nominale, tre figure e tabelle tracking/disturbo.

Prodotti REPORT_VERIFICA_SIMULINK, ANALISI_RUMORE_MISURA, CHIUSURA_FINALE_PROGETTO, checklist studenti e manifest di 237 file con SHA-256 portabili per i testi ed esatti per i binari. Dipendenze MATLAB rilevate (30) integrate con path dinamici e funzioni embedded. Archivio preservato; cache Python escluse. Controlli originali 8/8 PASS, 141/141 test PASS, quattro default e 80 artifact protetti PASS. Commit scientifici 27ad0db ed e880327. Nessun nuovo controllore o cambiamento SLX.

Stato documentale COMPLETE/PASS; validazione SLX PARTIAL/NOT RUN e immagini autentiche da completare su R2026a. Rumore e target temporali restano limiti scientifici dichiarati; 18 casi PID e 24 H∞2 numericamente ignoti sulla griglia. Branch pronto per revisione; nessun merge su main.

## 2026-11-01 — Carico distale e nuovo nominale

Branch codex/sea-revisione-finale-semplificata da main dbf6f00 (PR #46 integrata).
Incarico degli studenti: carico meccanico e ritardo incerti, confronto A/B,
semplificazione didattica e una PR senza merge. Consultate traccia ufficiale,
materiale Salaris Matlab/Slide/Appunti e riassunto; Drive in sola lettura.
Tre candidati 0.1/0.2/0.3 kg: M11=0.601/0.650/0.699 kg m²;
LQG fissato stabile nei tre casi. Scelti 0.2 kg ±50% come ipotesi,
non misura: massa distale effettiva 1 kg, intervallo del carico 0.1–0.3 kg.
Equazioni condivise M,C,G; nominale rigenerato a 14 stati. Equilibrio verticale
invariato, Jacobiano gravitazionale e inerzia aggiornati.
MATLAB R2026b: modello eseguito, tre test indipendenti PASS (equilibrio/Jacobiano,
energia Coriolis, contributo mEE*J'*J e gravita mEE*g*Jy').
Gate meccanica COMPLETE/PASS. Il primo fit additivo non soddisfa il criterio
di conservativita: lavoro A/B PARTIAL, errore conservato in log di sviluppo;
nessuna garanzia precedente trasferita.

## 2026-11-01 — Ritardi reali e modello concentrato additivo

Sei ureal attuativi indipendenti: wn 40 rad/s ±10%, zeta 0.8 ±10%,
td 15 ms ±20%; stesso ureal m_EE in A/B. Padé a uno stato,
ordine della pianta A fisso a 14. Candidati ritardo ±10/20/30%:
scarti additivi 0.0344/0.0683/0.1016 e di fase a 40 rad/s 3.1/6.2/9.2 gradi.
Scelto ±20%: variazione sensibile ma moderata, ipotesi non misurata.
Con td=18 ms gli errori moltiplicativi diretto/inverso hanno poli RHP
+133.3/+111.1; forma additiva stabile/propria. Peso dal fit su 29 drive
(20 dai dieci manipolatori, 8 vertici SISO, nominale); hold-out 30 campioni.
Un'inversione in spazio di stato del peso strettamente proprio ha introdotto
artefatti numerici: corretta eseguendo la normalizzazione in forma razionale.
Nessun rilassamento del criterio di copertura o di eccesso mediano 1.6.
Ordine selezionato 3: copertura 0.98037, eccesso mediano 1.0205,
hold-out 0.8788; LFT e ricostruzione B dei campioni completate senza errori.
Gate modellazione COMPLETE/PASS; copertura globale non dimostrata.

## 2026-11-01 — Ricostruzione e validazione A/B

Cinque test matlab.unittest superati, inclusi Jacobiani alle masse 0.1 e 0.3 kg,
identita del parametro reale nei due insiemi e ricostruzione degli impianti comuni.
Sette verifiche operative PASS: equilibrio, Jacobiano, nominali/LFT, struttura,
normalizzazione continua, replay dei dieci campioni e stabilita interna esplicita.
PBH dei modi instabili superato per stabilizzabilita/rilevabilita.
La copertura riguarda 29 casi di fit e 30 hold-out; nessuna inclusione globale
e nessuna garanzia trasferita dal modello A a B. Gate COMPLETE/PASS.


## 2026-11-02 — Controllori e verifiche con carico
Sono stati ricalcolati LQG, LQGI, Hinf1, Hinf2 e PID sul nominale con mEE=0.2 kg. Sette controllori fissati restano distinti dai sette correnti; ogni K è analizzato senza modificarlo su A e B (28 post-analisi). La prima D-K automatica è conservata nei file avvio_nominale; il tentativo finale usa MuN1 comune come inizializzazione e tre iterazioni su ciascun modello.

Esiti finali: LQG/LQGI RS PASS A/B, NP/RP FAIL; Hinf1 RS A PASS e B FAIL; Hinf2/PID NP PASS ma RS/RP FAIL; Mu_A e Mu_B RS PASS A/B ma NP/RP FAIL. Mu_A ha ordine 294 e offset DC 99.8%; Mu_B ordine 80, offset 21.9% e picco rumoroso 762 N m. Non sono promossi per il solo nome della sintesi. RAS: 86 convergenze, 12 mancate convergenze, 7 allontanamenti osservati, zero timeout/errori su 105 prove. Completate anche 14 prove non lineari nominali e 21 con solo carico variato.

Verifiche: campagna completa eseguita per fasi, run_all('rapida') eseguito, 5 test MATLAB e 7 controlli del runner PASS; Code Analyzer senza messaggi sui 16 file operativi. Assestamento non determinato segnato Inf, mai zero. Quality gate implementazione COMPLETE/PASS, obiettivi prestazionali PARTIAL/FAIL secondo i CSV. Relazione e consegna in completamento.


## 2026-11-02 — Specifiche prestazionali
Confrontati tre target (0.8 s/10%, 1.5 s/15%, 2 s/15%) e tre frequenze di riferimento (3, 4, 5 rad/s). Scelti Ts=2 s, Mp=15%, ess=5%, cross=25%, Mo=9/(s^2+6s+9). Il riferimento a 3 rad/s ha Ts=1.9447 s. We e Wu conservati. Le definizioni NS/NP/RS/RP e la soglia unitaria non cambiano. Recupero entro 0.5 gradi, picco e RMS del comando restano diagnostici senza limiti hardware. Risultati dei candidati conservati; nessun target rende automaticamente soddisfacenti tutti i K fissati. Quality gate COMPLETE/PASS per studio e coerenza, target dei controllori distinti nei CSV.


## 2026-11-02 — Semplificazione e allineamento Simulink
Il percorso accorpato resta unico. matrici_sea condivide le equazioni e controllori_sea evita elenchi incoerenti. La RAS riguarda solo i sette controllori correnti; le prove fissate restano nel confronto lineare. Gli otto SLX non sono duplicati né salvati: il runner aggiorna in memoria la massa effettiva nei generatori incorporati, i due drive, i guadagni e gli stati iniziali. Confrontate numericamente le funzioni meccaniche usate dai MATLAB Function con matrici_sea per ogni massa. Venti run di 2 s PASS con stati e Scope finiti; parametri e massa salvati. Cache coerenti anche nel formato della consegna. Quality gate COMPLETE/PASS; questo collaudo non certifica i target prestazionali.


## 2026-11-02 — Riscrittura didattica della relazione
Riscritti i 13 capitoli e le quattro appendici sul percorso fisico corrente: carico, ritardo, A/B, specifiche, controllori, robustezza, non lineare, campioni e conclusioni. Eliminati cronache delle versioni, matrici estese, ricerche ripetitive e trattazione sproporzionata di Lyapunov; conservati LFT, Kalman, azione integrale, mixed sensitivity, PID, D-K e tutte le distinzioni scientifiche necessarie. Tabelle e formule provengono da CSV/JSON tramite l’esportatore aggiornato. Risultati negativi preservati, inclusi offset e rumore dei candidati robusti.

PDF di 49 pagine, indice con 13 capitoli e quattro appendici, riferimenti e numerazione compilati. Nessun warning, overfull o riferimento irrisolto; controllo visivo sulle pagine renderizzate. Testo finale privo dei termini di cronaca vietati. Quality gate COMPLETE/PASS. La documentazione tecnica conserva la provenienza fuori dalla relazione.


## 2026-11-02 — Figure e presentazione
Aggiornati gli schemi del carico, del percorso SISO-MIMO e della LFT A/B. Rigenerate otto figure dai dati correnti, inclusa la sensibilità separata a wn, zeta e ritardo. Conservati gli schemi validi e le viste autentiche degli SLX. La presentazione esistente resta di 23 slide, con tabelle esportate dalla stessa fonte numerica della relazione.

Testo orale di 1990 parole, stima a 125 parole/min e 22 cambi di slide: 16:50; Alessio 7:40 e Valerio 8:26 di parlato. Note, scaletta e possibili domande aggiornate. La stima lascia margine sotto i 20 minuti; prova dal vivo NOT RUN. PDF 23 pagine senza warning o contenuti fuori margine, controllo visivo completato. Quality gate COMPLETE/PASS per elaborati.


## 2026-11-02 — Consegna autonoma finale
Confezionati gli stessi sorgenti, le sintesi coerenti, gli otto SLX e i PDF in Consegna_Progetto_SEA.zip. Il pacchetto è stato estratto in una nuova cartella TEMP esterna al repository. Il primo comando CLI aveva un errore di quoting e non ha avviato i calcoli; corretto il comando, restoredefaultpath e un assert hanno escluso il path del repository. run_all('rapida') e 20 esecuzioni collaudo_simulink sono terminati con exit code 0.

Confronto: sei CSV riprodotti identici, massa e selezione dei drive coerenti, massimo scarto relativo dei picchi Scope zero; 33 sorgenti e ingressi identici per SHA-256. Il pacchetto finale viene rigenerato con evidenze e documentazione definitive, verificando che il contenuto eseguibile resti quello collaudato. I log sono conservati, con soli spazi finali rimossi. Cinque test MATLAB, sette verifiche scientifiche, 28 post-analisi, 154 casi lineari, 105 RAS, 35 prove non lineari e 20 run SLX nella campagna principale. Rapida e SLX ripetuti dalla consegna.

Quality gate incarico R01–R22 COMPLETE/PASS. Gli obiettivi di controllo restano PARTIAL: nessuna RP raggiunta sulla famiglia completa, Hinf2/PID fragili, candidati D-K con offset e/o rumore elevati. Copertura globale B, RAS certificata, hardware e prova orale dal vivo non sono dichiarati eseguiti. Pubblicazione di una sola PR pronta per revisione; nessun merge.


## 2026-11-02 — Pubblicazione per revisione
Pubblicato il ramo e aperta una sola [PR #47](https://github.com/Deda-404/Progetto_CR/pull/47), pronta per revisione (non draft), base main dbf6f00. Nove commit tematici coprono le aree richieste; questo aggiornamento registra soltanto la pubblicazione. GitHub indica assenza di conflitti; nessun merge effettuato. Tutte le verifiche e i limiti scientifici rimangono quelli della consegna collaudata. Stato incarico COMPLETE/PASS, accettazione dei controllori PARTIAL secondo i risultati.
