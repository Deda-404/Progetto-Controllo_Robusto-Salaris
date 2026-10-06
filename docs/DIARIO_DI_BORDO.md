# Diario di bordo

Il campo “Responsabile” identifica il referente umano che revisiona, approva e mantiene la voce del diario.

Il diario è append-only. Le nuove attività aggiungono voci senza cancellare o riscrivere quelle precedenti.

## 2026-08-24 12:07 — Inizializzazione M0 del progetto

**Responsabile:** Alessio
**Milestone:** M0
**Tipo:** Setup / Analisi / Test / Documentazione / Git

### Attività svolta

- Letti integralmente la traccia ufficiale (3 pagine), la relazione del gruppo precedente (95 pagine, incluse tabelle e figure) e i prompt di governo.
- Verificato tramite plugin Google Drive l'accesso in sola lettura a `Progetto IS CR`, alle aree `CR`/`IS` e al progetto `CR/MaterialeColleghi/Progetto_finale_CR`.
- Inventariati script MATLAB, modelli Simulink, dataset, PDF, archivio e cache del progetto di riferimento.
- Letti in sola lettura i principali script di modello, linearizzazione, incertezza, LQG, \(H_\infty\), \(\mu\)-analysis, D–K iteration e Monte Carlo.
- Verificato il repository remoto `Deda-404/Progetto_CR`, clonato nella workspace e creato il branch `codex/m0-project-setup`.
- Verificato che `MeS.gitignore` non esiste più: il commit remoto `2600c4e` lo aveva già rinominato in `.gitignore`; il file è stato completato e normalizzato.
- Eseguito MATLAB in modalità batch e verificati versione, prodotti, licenze e comandi chiave.
- Creata la struttura iniziale, la documentazione di governo, lo smoke test M0 e il sorgente LaTeX minimale.

### File coinvolti

- `README.md` — modificato: scopo, governance, struttura, prerequisiti, esecuzione e stato.
- `.gitignore` — modificato: ignore MATLAB/Simulink/LaTeX/editor/OS e terminazione corretta.
- `AGENTS.md` — creato: regole permanenti.
- `CHANGELOG.md` — creato.
- `run_all.m` — creato: entry point M0 riproducibile.
- `docs/ANALISI_TRACCIA.md` — creato.
- `docs/ANALISI_PROGETTO_RIFERIMENTO.md` — creato.
- `docs/INVENTARIO_DRIVE.md` — creato.
- `docs/REQUIREMENTS_CHECKLIST.md` — creato.
- `docs/ROADMAP.md` — creato.
- `docs/DECISION_LOG.md` — creato.
- `docs/DIARIO_DI_BORDO.md` — creato.
- `docs/PROJECT_STATUS.md` — creato.
- `tests/test_m0_workspace.m` — creato.
- `report/main.tex` — creato.
- cartelle `src/`, `controllers/`, `analysis/`, `simulink/`, `results/` e sottocartelle — create con placeholder tracciabili.

### Motivo

Rendere il progetto originale, riproducibile e collaborabile prima di iniziare la modellazione, separando rigorosamente reference Drive e source of truth GitHub.

### Risultato

**SUCCESSO** — struttura, documentazione e smoke test M0 completati; commit associato alla chiusura della milestone.

### Verifiche effettuate

- Accesso Drive e listing reale delle cartelle.
- `git ls-remote`, clone, branch e remote.
- MATLAB R2025b Update 4 avviato con `-batch`.
- Licenze disponibili: Simulink, Control System Toolbox, Robust Control Toolbox, Symbolic Math Toolbox.
- Risoluzione dei comandi `sim`, `ss`, `lqr`, `kalman`, `mixsyn`, `hinfsyn`, `hinfstruct`, `ureal`, `mussv`, `musyn`, `syms`.
- Esecuzione reale di `run_all.m`: 2 test su 2 superati.
- `git diff --check`: nessun errore dopo la normalizzazione dei file Markdown.

### Problemi aperti

1. Il riferimento usa `dataset_modello_nominale.mat`, ma nella cartella principale non è evidente lo script che lo genera.
2. Esistono divergenze fra codice e relazione del riferimento su incertezze, ordine ridotto del controllore e alcuni risultati di robustezza.
3. Nessuna scelta tecnica libera della traccia è ancora approvata.

### Decisioni / Impatto

- Drive confermato in sola lettura; nessuna modifica effettuata.
- GitHub confermato come unica source of truth.
- Tutti i valori tecnici del riferimento registrati solo come proposte.
- M1 rimane esplicitamente fuori scope fino a nuova autorizzazione.

### Prossimo passo

Creare il commit M0, tentare il push del branch e attendere la revisione del gruppo prima di M1.

### Git

Branch: `codex/m0-project-setup`
Commit: commit M0 associato a questa voce (vedere `git log`)
Messaggio: `chore: initialize robust control project workspace`

---

## 2026-08-24 12:39 — Implementazione e validazione M1

**Responsabile:** Alessio
**Milestone:** M1
**Tipo:** Modellazione / Test / Documentazione / Git

### Attività svolta

- Verificata l'approvazione M0 tramite merge remoto della PR #1, aggiornato `main` e creato il branch `codex/m1-nonlinear-model`.
- Aggiunta in `AGENTS.md`, prima del codice M1, la regola permanente di ricostruzione indipendente e consultazione reference-last.
- Derivate dalla traccia le funzioni per parametri nominali, \(M(q)\), \(C(q,\dot q)\), \(G(q)\), deformazione/coppia SEA e RHS non lineare completo a otto stati.
- Fissata nel Decision Log la convenzione unica \(x=[q;\dot q;\theta;\dot\theta]\) e l'ingresso di coppia motore \(\tau\).
- Creati sette test M1 deterministici, inclusa una verifica che ricalcola direttamente le formule della traccia senza riusare le funzioni sotto test.
- Creata una validazione numerica dedicata e integrati test M0, test M1 e quality gate in `run_all.m`.
- Eseguita una prima versione funzionante in MATLAB prima di consultare l'inventario del riferimento; effettuato poi soltanto un confronto metodologico ad alto livello.
- Documentati equazioni, unità, API, prova analitica della positività, risultati numerici, confronto e limiti in `docs/MODELLO_NON_LINEARE.md`.

### File creati

- `src/parameters/sea_params_nominal.m`
- `src/model/sea_link_inertia.m`
- `src/model/sea_coriolis.m`
- `src/model/sea_gravity.m`
- `src/model/sea_elastic_torque.m`
- `src/model/sea_nonlinear_rhs.m`
- `tests/test_m1_nonlinear_model.m`
- `analysis/nominal/validate_m1_nonlinear_model.m`
- `docs/MODELLO_NON_LINEARE.md`

### File modificati

- `AGENTS.md`, `run_all.m`, `README.md`, `CHANGELOG.md`
- `docs/DECISION_LOG.md`, `docs/REQUIREMENTS_CHECKLIST.md`, `docs/PROJECT_STATUS.md`, `docs/DIARIO_DI_BORDO.md`

### Errori incontrati e correzioni

- Il primo `git fetch` eseguito con il client Linux non ha trovato credenziali interattive per GitHub. Il fetch è stato ripetuto con il runtime Git autenticato fornito dall'ambiente Codex e ha aggiornato correttamente `origin/main`.
- La prima esecuzione MATLAB del modello e dei test non ha prodotto errori; non sono stati nascosti test falliti.
- Un primo comando opzionale di analisi statica ha costruito in modo errato la lista dei file e MATLAB lo ha respinto prima di analizzare il codice. Il comando è stato corretto; sono state poi rimosse due direttive di soppressione obsolete segnalate da Code Analyzer.

### Verifiche e risultati

- `run_all.m` eseguito realmente con MATLAB R2025b Update 4: 9 test su 9 superati (2 M0 e 7 M1).
- Campionate 2001 configurazioni di \(q_2\) in \([-\pi,\pi]\): minimo autovalore di \(M\) pari a 0.01904266522239113 a \(q_2=0\) rad.
- Massimo errore di simmetria di \(M\): 0, con tolleranza \(10^{-12}\).
- Massimo residuo antisimmetria di \(\dot M-2C\): \(4.906538933386797\times10^{-18}\), con tolleranza \(10^{-12}\), su 7 casi deterministici.
- Errori massimi delle verifiche dirette di gravità, elasticità e coerenza cinematica: 0, con tolleranza \(10^{-12}\).
- RHS 8×1 finito in 4 casi su 4, inclusi velocità, deformazioni e coppie non nulle.
- Totale valutazioni deterministiche riportate dalla validazione: 2018.
- Code Analyzer eseguito sui file MATLAB di `src`, `analysis`, `tests` e su `run_all.m`: 0 messaggi dopo la correzione.
- `run_all.m` rieseguito dalla radice dopo le correzioni finali: PASS con codice di uscita 0.

### Confronto finale con il riferimento

Il riferimento conferma ad alto livello la stessa catena fisica imposta dalla traccia e l'uso di una dinamica a otto stati. La nostra organizzazione è modulare, numerica, senza dataset e accompagnata da test strutturali indipendenti; simbolico, equilibrio e linearizzazione sono stati deliberatamente rinviati. Non sono emersi termini meccanici mancanti e non sono stati copiati codice, commenti, test, dataset o risultati.

### Risultato

**SUCCESSO — M1 COMPLETE, quality gate PASS.**

### Problemi aperti

Nessun blocco per M1. Equilibrio, linearizzazione, attuatori esterni, incertezze e controllori restano fuori scope.

### Prossimo passo

Completare commit, push e Pull Request M1, quindi attendere la revisione del gruppo senza iniziare M2.

### Git

Branch: `codex/m1-nonlinear-model`
Commit e Pull Request: da associare alla chiusura della milestone (vedere `git log` e PR del branch)

---

## 2026-08-24 12:50 — Pubblicazione PR e resoconto M1

**Responsabile:** Alessio
**Milestone:** M1
**Tipo:** Git / Documentazione

### Attività svolta

- Creati i commit `f768ff0` per modello/test e `8db01a6` per documentazione/quality gate.
- Pubblicato `codex/m1-nonlinear-model` su `origin`.
- Aperta la Pull Request [#2](https://github.com/Deda-404/Progetto_CR/pull/2) verso `main`, lasciandola intenzionalmente non unita.
- Creato `Resosconto_per_GPT.txt`, riepilogo scaricabile e autosufficiente per trasferire a ChatGPT contesto, implementazione, test, metriche, problemi e stato Git senza schermate della chat.

### Problemi e correzioni

- GitHub CLI e `jq` non erano disponibili; un primo tentativo di pipeline PowerShell con il credential helper non era compatibile con l'eseguibile. La PR è stata aperta tramite API GitHub autenticata usando il credential helper senza stampare o salvare credenziali.

### Risultato

**SUCCESSO** — branch pubblicato, PR #2 aperta, nessun merge eseguito e resoconto finale predisposto.

### Prossimo passo

Attendere la revisione del gruppo sulla PR #2. M2 resta non iniziata.

---

## 2026-08-24 13:38 — Implementazione e primo quality gate M2

**Responsabile:** Alessio
**Milestone:** M2
**Tipo:** Equilibrio / Linearizzazione / Analisi strutturale / Test / Documentazione

### Attività svolta

- Letto integralmente il prompt M2 e verificati `AGENTS.md`, roadmap, decisioni, stato e modello M1.
- Rilevato inizialmente che `origin/main` non conteneva ancora M1; M2 è stata fermata senza creare un branch dalla base errata. Dopo il merge effettuato dal gruppo, verificato `85075d7` su `main` e creato `codex/m2-equilibrium-linearization`.
- Derivata e implementata la relazione statica generale \(\bar\theta=\bar q+K_s^{-1}G(\bar q)\), \(\bar\tau=G(\bar q)\), con verifica tramite l'RHS M1.
- Costruiti simbolicamente i Jacobiani dell'esatto `sea_nonlinear_rhs` e convertiti in matrici numeriche 8×8 e 8×2.
- Implementata una verifica indipendente mediante differenze finite centrate e selezionato il passo \(3\times10^{-6}\) tramite scansione deterministica.
- Definite separatamente l'uscita di prestazione \(q\) e la misura candidata \([q;\theta]\); costruiti i due modelli `ss` meccanici di ordine 8.
- Analizzati poli, ranghi SVD, tolleranze, condizionamento e PBH dei modi instabili per controllabilità/stabilizzabilità e osservabilità/rilevabilità.
- Verificato l'accordo locale fra RHS non lineare e approssimazione LTI su quattro ampiezze decrescenti.
- Creati nove test M2, inclusa la riesecuzione annidata dei sette test M1.
- Integrate validazione, dataset e figura in `run_all.m`; eseguito MATLAB prima di consultare il riferimento.
- Solo dopo il primo PASS completo, confrontato ad alto livello l'inventario del riferimento per equilibrio, linearizzazione simbolica, misure e comportamento qualitativo dei poli.

### File creati

- `src/model/sea_static_equilibrium.m`
- `src/model/sea_linearize_symbolic.m`
- `src/model/sea_output_matrices.m`
- `analysis/nominal/finite_difference_jacobian.m`
- `analysis/nominal/analyze_m2_structure.m`
- `analysis/nominal/validate_m2_equilibrium_linearization.m`
- `tests/test_m2_equilibrium_linearization.m`
- `results/data/m2_linearization_nominal.mat`
- `results/figures/m2_open_loop_poles.png`
- `docs/EQUILIBRIO_LINEARIZZAZIONE.md`

### Errori e problemi numerici

- Il primo tentativo di avvio M2 è stato correttamente bloccato perché `main` non conteneva M1; il gruppo ha risolto effettuando il merge della PR #2.
- La pipeline simbolica non ha prodotto errori.
- Con passo differenze finite \(10^{-6}\), il primo PASS mostrava errore massimo A \(4.113\times10^{-7}\). Una scansione da \(10^{-3}\) a \(10^{-7}\) ha evidenziato il miglior compromesso a \(3\times10^{-6}\), riducendo l'errore a \(4.126\times10^{-8}\); la tolleranza finale resta conservativa a \(10^{-6}\).
- Le matrici di controllabilità e osservabilità risultano fortemente condizionate, ma tutti i minimi singolari superano le tolleranze esplicite e i PBH indipendenti hanno rango pieno. Il condizionamento è documentato, non nascosto.
- La prima figura rifletteva il tema grafico scuro di MATLAB; dopo ispezione visiva sono stati fissati esplicitamente sfondo, colori, legenda e distinzione poli stabili/instabili.

### Risultati

- Equilibrio: \(\bar q=[\pi/2,0]^T\), \(\bar\tau=[5.766616847825057\times10^{-16},1.4416542119562643\times10^{-16}]^T\) N·m e residuo \(5.8387489976584098\times10^{-14}\).
- Jacobiani simbolici: \(A\) 8×8 e \(B\) 8×2, tutti finiti.
- Confronto differenze finite: errore massimo/Frobenius A \(4.126\times10^{-8}\)/\(6.124\times10^{-8}\), relativo \(6.423\times10^{-12}\); B esatto entro precisione numerica.
- Poli: 6 stabili, 2 instabili, 0 marginali; massima parte reale 7.20942861374 s⁻¹.
- Controllabilità: rango 8/8, tolleranza 0.25, \(\sigma_{min}=433.2193\); PBH stabilizzabilità PASS sui due modi instabili.
- Osservabilità `[q;theta]`: rango 8/8, tolleranza 0.0078125, \(\sigma_{min}=3101.1254\); PBH rilevabilità PASS.
- Caso informativo `q`: rango osservabilità 8/8 e rilevabilità PASS.
- Errori locali LTI/non lineare: \(1.109\times10^{-4}\), \(1.109\times10^{-7}\), \(1.109\times10^{-10}\), \(1.782\times10^{-13}\); ordini osservati 3.000, 3.000, 2.794.
- Primo `run_all.m` M2 completo: 18/18 test top-level PASS, regressione annidata M1 7/7 PASS, validazioni M1/M2 PASS e codice di uscita 0.
- Code Analyzer: 0 messaggi su sorgenti, analisi, test e `run_all.m`.
- Dopo gli aggiornamenti documentali e grafici, il controllo statico e `run_all.m` sono stati ripetuti dalla radice: stessi esiti PASS, dataset rigenerato e figura finale ispezionata con legenda corretta.

### Decisioni approvate

- D-0003: equilibrio verticale superiore \(\bar q=[\pi/2,0]^T\).
- D-0004: misura principale futura \(y_{meas}=[q;\theta]\), senza velocità dirette.
- D-0005: uscita primaria di prestazione \(y_q=q\).

Non sono stati approvati parametri attuatori, incertezze, Q/R, covarianze Kalman, pesi robusti o limiti di coppia.

### Confronto reference-last

L'inventario conferma ad alto livello l'uso nel riferimento di equilibrio verticale, linearizzazione simbolica e misure di posizione. La nostra pipeline è autonoma e aggiunge differenze finite, tolleranze SVD, PBH e confronto locale LTI/non lineare. Il comportamento instabile è qualitativamente coerente; non sono stati copiati codice, matrici, output, dataset o valori numerici.

### Risultato

**SUCCESSO — primo quality gate tecnico M2 PASS.**

### Prossimo passo

Eseguire il controllo finale del diff e `run_all`, completare commit/push/PR e creare `docs/handoff/Resoconto_M2_per_GPT.txt`. Non iniziare M3.

### Git

Branch: `codex/m2-equilibrium-linearization`
Commit e Pull Request: da associare alla chiusura M2

---

## 2026-08-24 13:45 — Pubblicazione PR e handoff M2

**Responsabile:** Alessio
**Milestone:** M2
**Tipo:** Git / Documentazione

### Attività svolta

- Creati i commit `3dcbec8` per implementazione/test/artifact e `0d60428` per documentazione e decisioni.
- Pubblicato `codex/m2-equilibrium-linearization` su `origin`.
- Aperta la Pull Request [#3](https://github.com/Deda-404/Progetto_CR/pull/3) verso `main`, senza eseguire il merge.
- Creato `docs/handoff/Resoconto_M2_per_GPT.txt`, mantenendo intatto il precedente resoconto M1.

### Risultato

**SUCCESSO** — M2 pubblicata per revisione, PR #3 aperta e handoff autosufficiente predisposto.

### Prossimo passo

Attendere la revisione del gruppo. Non iniziare M3.

---

## 2026-08-24 15:19 — Implementazione e quality gate M3

**Responsabile:** Alessio
**Milestone:** M3
**Tipo:** Attuatori / Padé / Pianta completa / Analisi strutturale / Test / Documentazione

### Attività svolta

- Letto integralmente il prompt M3 e verificati AGENTS.md, roadmap, decisioni, stato e risultati M2.
- Verificato che main contenesse il merge M2 f5800f2, quindi creato il branch codex/m3-actuator-dynamics senza iniziare M4.
- Prima di consultare il riferimento, definita una griglia deterministica originale di 27 candidati: frequenze naturali 25/40/60 rad/s, damping 0.6/0.8/1.0 e ritardi 10/15/25 ms.
- Selezionato autonomamente il candidato C14, con 40 rad/s, 0.8 e 15 ms, sulla base di rapidità, overshoot, roll-off prima dei modi elastici ed errore di fase Padé.
- Centralizzati i parametri e implementati secondo ordine puro, Padé ordine 1, attuatore SISO di ordine 3 e due canali diagonali di ordine 6.
- Costruita esplicitamente la cascata a 14 stati con convenzione [x_mech;x_act] e StateName verificati.
- Implementata una seconda cascata indipendente con series e confrontata la risposta 4×2 su 601 frequenze fra 0.01 e 1000 rad/s.
- Analizzati tutti i poli e ripetute controllabilità, stabilizzabilità, osservabilità e rilevabilità con SVD, scaling temporale e PBH.
- Creati undici test M3, aggiornato run_all.m e generati dataset più tre figure.
- Eseguito il primo PASS tecnico completo prima del confronto con il riferimento; soltanto dopo sono stati verificati ad alto livello i valori 30 rad/s, 0.7 e 20 ms usati dal progetto precedente.
- Scritta da zero la documentazione M3 e approvata la decisione D-0006, senza approvare incertezze.

### Errori e correzioni

- Il primo run_all M3 ha fallito esclusivamente T5: MATLAB restituiva il canale nullo di freqresp come vettore 101×1, mentre il test lo confrontava con uno 1×101. L'asserzione è stata corretta senza modificare il modello; il rilancio completo ha superato 29/29 test.
- Le matrici grezze ctrb e obsv hanno riportato rango numerico 10/14, con condizionamenti 1.851e23 e 2.477e19. Il risultato non è stato nascosto: una normalizzazione del tempo con scala 133.3333 rad/s restituisce rango 14/14, e PBH indipendenti su tutti i poli confermano controllabilità e osservabilità complete.
- Le prime figure M3 ereditavano il tema scuro di MATLAB, rendendo testi e assi poco leggibili; dopo ispezione visiva sono stati fissati esplicitamente sfondo, colori, griglia, legende e marcatori delle frequenze.
- Il grafico del modulo del solo ritardo mostrava rumore numerico dell'ordine di 1e-15; l'asse è stato limitato a ±0.02 dB per rappresentare correttamente l'identità all-pass.

### Risultati

- Candidato scelto: 40 rad/s, damping 0.8, ritardo 0.015 s, Padé ordine 1.
- Secondo ordine puro: poli -32±24j, DC gain 1, rise 0.0616973 s, settling 0.0939060 s e overshoot 1.51646%.
- Attuatore completo: ordine 3, poli -32±24j e -133.3333, zero RHP +133.3333 s⁻¹, DC gain 1, rise 0.0626454 s, settling 0.109362 s, overshoot 1.47221% e banda 34.7834 rad/s.
- Errore fase Padé: 0.0000161° a 1 rad/s, 0.001063° e 0.006028° sui due modi instabili M2, 4.76162° a 70 rad/s e 6.82742° a 80 rad/s. Errore massimo di modulo del solo ritardo 2.220e-16.
- Ordini SISO/MIMO/full: 3/6/14. GfullMeas ha 2 ingressi e 4 uscite.
- Interconnessione esplicita contro series: massimo errore assoluto e relativo 0 entro precisione numerica.
- Poli completi: 12 stabili, 2 instabili, 0 marginali; i sei poli attuativi sono stabili.
- Tempo normalizzato: controllabilità 14/14 con cond 3.594e5; osservabilità [q;theta] 14/14 con cond 147.7; osservabilità q 14/14 con cond 2.933e4.
- PBH su tutti i modi: minimo singolare 0.2064 per controllabilità, 0.005890 per osservabilità [q;theta] e 2.665e-5 per osservabilità q; stabilizzabilità e rilevabilità PASS.
- run_all.m reale in MATLAB R2025b Update 4: 29/29 test top-level, regressioni annidate M0/M1/M2 e validazioni M1/M2/M3 PASS, exit code 0.

### Confronto reference-last

Il riferimento usa 30 rad/s, damping 0.7 e ritardo 20 ms. Il confronto, svolto soltanto dopo il primo PASS, conferma lo stesso ordine di grandezza e l'uso del Padé richiesto dalla traccia. La nostra scelta 40/0.8/15 ms è rimasta invariata ed è motivata dalla griglia originale; non sono stati copiati codice, realizzazioni, matrici, nomi, dataset, figure o risultati.

### Risultato

**SUCCESSO — quality gate tecnico M3 PASS.**

### Problemi aperti

I parametri non sono identificati sperimentalmente; i canali sono identici solo nel nominale; Padé ordine 1 sottostima la perdita di fase alle alte frequenze; lo scaling resta necessario. Incertezze, percentuali, pesi, specifiche e controllori restano fuori scope.

### Prossimo passo

Completare controllo statico e run_all finali, commit, push, Pull Request e handoff M3. Fermarsi senza iniziare M4.

### Git

Branch: codex/m3-actuator-dynamics
Commit e Pull Request: da associare alla chiusura M3

---

## 2026-08-24 15:24 — Pubblicazione PR e preparazione handoff M3

**Responsabile:** Alessio
**Milestone:** M3
**Tipo:** Git / Documentazione

### Attività svolta

- Creati i commit 3da195f per implementazione, test e artifact, e 5ce3a33 per documentazione e decisioni.
- Pubblicato codex/m3-actuator-dynamics su origin.
- Aperta la Pull Request #4 verso main: https://github.com/Deda-404/Progetto_CR/pull/4.
- Verificato tramite risposta GitHub che la PR fosse open e non merged.
- Predisposto docs/handoff/Resoconto_M3_per_GPT.txt senza sovrascrivere gli handoff precedenti.

### Problemi e correzioni

Il primo comando locale usato per costruire la richiesta API GitHub conteneva un errore di quoting Python ed è terminato prima dell'invio. Il comando è stato corretto; la PR #4 è stata poi creata correttamente senza stampare o salvare credenziali.

### Risultato

**SUCCESSO** — M3 pubblicata per revisione, PR #4 aperta e nessun merge eseguito.

### Prossimo passo

Attendere la revisione del gruppo. Non iniziare M4.

---

## 2026-08-24 15:43 — Correzione metodologica della selezione attuatore M3.1

**Responsabile:** Alessio
**Milestone:** M3.1
**Tipo:** Selezione nominale / Test / Documentazione

### Problema metodologico

La versione M3 calcolava correttamente le metriche dei 27 candidati, ma leggeva prima actuator_params_nominal.m e usava quei valori per etichettare il candidato selezionato. Era quindi una candidate comparison del nominale già fissato, non una candidate selection completa dalla griglia.

### Attività svolta

- Verificato il merge M3 c988d06 su main e creato codex/m3-actuator-selection-fix da una worktree pulita.
- Rimossa da select_nominal_actuator.m ogni dipendenza da actuator_params_nominal.m.
- Derivati dai poli M2 lambda_u_max=7.20942861374 rad/s e omega_el_min=69.9543 rad/s.
- Applicata la finestra progettuale 4*lambda_u_max <= BW <= 0.60*omega_el_min, cioè 28.8377–41.9726 rad/s.
- Imposti overshoot <=2% ed errore fase Padé a 80 rad/s <=10°.
- Identificati come ammissibili C13, C14, C25 e C26.
- Definita la quasi-parità del settling come entro il 10% dal minimo ammissibile; i coefficienti 4, 0.60 e 10% sono criteri progettuali M3.1, non requisiti della traccia.
- Nel gruppo in quasi-parità, applicata la preferenza per il ritardo maggiore e poi tie-break deterministici su settling, overshoot, distanza dal centro della finestra di banda, frequenza naturale, damping e indice.
- La regola ha selezionato C14 dalle metriche: 40 rad/s, 0.8 e 15 ms. Il risultato coincide con D-0006, quindi modello nominale e parametri centralizzati non sono stati modificati.
- Separata nella validazione la selezione da metriche dal successivo controllo di coerenza con i parametri dichiarati; un'eventuale differenza genera un arresto che richiede revisione del gruppo.
- Esteso il dataset con criteri, candidati ammissibili, regola, ranking e flag di coerenza.

### Test aggiunti

- indipendenza dal file dei parametri nominali, verificata sul sorgente e sulle dipendenze statiche;
- appartenenza del selezionato alla griglia;
- derivazione dei criteri dai poli M2 e rispetto di tutti i vincoli;
- esclusione corretta dei candidati non ammissibili;
- ripetibilità e determinismo della selezione, incluso C14 con rank 1.

### Risultati

- Test M3 dedicati: 16/16 PASS.
- Test top-level complessivi: 34/34 PASS.
- Regressioni annidate M0/M1/M2: PASS.
- Validazioni M1/M2/M3: PASS.
- Code Analyzer sui file M3.1 e run_all.m: 0 messaggi.
- run_all.m reale in MATLAB R2025b Update 4: PASS, exit code 0.
- Ordine e dinamica del modello finale invariati: SISO 3, MIMO 6, pianta 14 stati.

### Risultato

**SUCCESSO — M3.1 COMPLETE, selezione C14 riproducibile dalle metriche e quality gate PASS.**

### Problemi aperti

Nessun blocco per M3.1. La soglia di quasi-parità del 10% è una decisione progettuale esplicita e potrà essere riesaminata dal gruppo; non sono state introdotte incertezze o attività M4.

### Prossimo passo

Creare commit, push, Pull Request dedicata e handoff M3.1. Fermarsi senza iniziare M4.

---

## 2026-08-24 15:48 — Pubblicazione PR e handoff M3.1

**Responsabile:** Alessio
**Milestone:** M3.1
**Tipo:** Git / Documentazione

### Attività svolta

- Creati i commit a9129c6 per selezione, validazione, test e dataset, e f60a504 per motivazione e documentazione metodologica.
- Pubblicato codex/m3-actuator-selection-fix su origin.
- Aperta la Pull Request #5 verso main: https://github.com/Deda-404/Progetto_CR/pull/5.
- Verificato che la PR fosse open e non merged.
- Creato docs/handoff/Resoconto_M3_1_per_GPT.txt senza sovrascrivere gli handoff M1–M3.

### Risultato

**SUCCESSO** — M3.1 pubblicata per revisione, PR #5 aperta, handoff predisposto e nessun merge eseguito.

### Prossimo passo

Attendere la revisione del gruppo. Non iniziare M4.

---

## 2026-08-24 16:31 — Implementazione e primo quality gate M4

**Responsabile:** Alessio
**Milestone:** M4
**Tipo:** Screening / Incertezze parametriche / `ucover` / Pianta `uss` / Test / Documentazione

### Attività svolta

- Letto integralmente il prompt M4 e verificati AGENTS.md, roadmap, decisioni, stato e documenti tecnici M1–M3.1.
- Verificato che `main`/`origin/main` contenessero il merge M3.1 a1eca7b e creato il branch `codex/m4-uncertainty-model`; nessuna attività M5 o di controllo è stata iniziata.
- Prima di consultare il riferimento, implementato uno screening originale dei dieci candidati con perturbazioni ±1%, ricalcolo di equilibrio/Jacobiani/pianta e quattro metriche dinamiche su 0.1–300 rad/s.
- Definita una regola di priorità esplicita, composta al 65% da sensibilità dinamica e al 35% da variabilità fisica, ruolo delle occorrenze e interpretabilità.
- Selezionati autonomamente `k2`, `k1`, `Jm1`; definiti scenari MILD/BASELINE/CONSERVATIVE e baseline ±7%, ±7%, ±9%.
- Implementata una linearizzazione analitica compatibile con valori numerici e `ureal`; costruite una sola `ureal` per parametro fisico e la meccanica incerta dalla nostre equazioni.
- Definiti tre scenari attuatore e baseline `wn` ±8%, `zeta` ±7.5%, ritardo ±20%.
- Costruita una famiglia FRD da 120 modelli con ritardo esatto: 1 nominale, 6 variazioni singole, 8 corner e 105 casuali con seed 20260824.
- Provati con `ucover` gli ordini 1–4, aggiunto margine 8% e selezionato il minimo peso stabile/proprio che copre la famiglia.
- Costruite `Delta_act1` e `Delta_act2` indipendenti, `GuncMeas` 4x2 e `GuncQ` 2x2; estratta e tabulata la struttura `lftdata`.
- Validata la coerenza nominale con M2/M3, eseguiti 40 campioni `usample` con seed 20260825 e generati dataset più tre figure.
- Creati i 14 test M4, incluso il rilancio delle 34 regressioni M0–M3.1.
- Ottenuto il primo PASS indipendente prima del riferimento. Soltanto dopo sono stati confrontati parametri/range/campioni/ordine del peso del progetto precedente; l'ensemble nostro è rimasto invariato.
- Scritti da zero `docs/MODELLO_INCERTEZZE.md` e le decisioni D-0007–D-0012.

### Errori e correzioni

- Il checkout Windows aveva convertito tutti i file versionati in CRLF, facendoli apparire modificati a Git senza differenze di contenuto. Sono stati normalizzati i terminatori e configurato `core.autocrlf=true`; la worktree è tornata a mostrare soltanto i file M4 reali.
- La prima esecuzione dei test M4 ha superato T1–T13 ma T14 è terminato in errore durante la concatenazione di una `TestSuite.empty`. La suite è stata inizializzata dal primo file di test e il rilancio ha superato 14/14.
- L'ispezione visiva iniziale ha mostrato assi scuri ereditati dal tema MATLAB e una legenda `WI` associata ai primi tre campioni invece che a campioni/inviluppo/peso. Sono stati fissati esplicitamente colori di assi e legende e sono stati passati gli handle corretti.
- Il Code Analyzer ha segnalato quattro parentesi superflue, rimosse senza cambiare il calcolo.

### Risultati

- Ranking primi cinque: `k2` 0.75889, `k1` 0.64998, `Jm1` 0.59755, `Jm2` 0.59379, `m2` 0.54781.
- Famiglia attuatore: 120 modelli su 801 frequenze fra 0.1 e 1000 rad/s.
- `WI(s)=2.87131986636(s+1.32752948673)/(s+207.353298568)`, ordine 1.
- Worst `|E|/|WI|=0.925925925926`; margine minimo 0.0130725422; caso `corner-212` a 281.838293 rad/s.
- Struttura Delta: due `ultidyn` complessi dinamici e tre `ureal` reali statiche, tutti scalari e con una occorrenza LFT.
- Errore nominale massimo `GuncMeas`/M3: abs 4.890e-15, rel 1.188e-14; `GuncQ`: abs 6.328e-15, rel 4.689e-12.
- `usample`: 40/40 campioni validi; due poli instabili per campione, coerenti con M2.
- Test M4: 14/14 PASS; regressioni annidate M0–M3.1: 34/34 PASS.

### Confronto reference-last

Il riferimento seleziona `m2,k1,k2`, usa ±10%/±5%, indica 200 campioni e `WI` ordine 3. Il nostro risultato usa `k2,k1,Jm1`, ±7%/±9%, 120 modelli e ordine 1. La coincidenza sulle rigidezze è parziale; differenze e motivazioni sono state preservate.

### Risultato

**SUCCESSO — primo quality gate tecnico M4 PASS e documentazione sostanziale completata.**

### Problemi aperti

I range non sono identificati sperimentalmente; `Jm2` è vicino a `Jm1` nel ranking; la copertura è discreta sulla griglia; `usample` non è il Monte Carlo finale. Il rilancio finale di `run_all`, i commit, il push, la PR e l'handoff restano da completare.

### Prossimo passo

Eseguire Code Analyzer e `run_all` finali, ispezionare le figure rigenerate, aggiornare gli esiti, creare commit/push/PR e handoff. Fermarsi senza iniziare M5.

---

## 2026-08-24 16:46 — Pubblicazione PR e handoff M4

**Responsabile:** Alessio
**Milestone:** M4
**Tipo:** Quality gate finale / Git / Handoff

### Attività svolta

- Eseguito `matlab.exe -batch "run_all"`: 48/48 test top-level e validazioni M1–M4 PASS, exit code 0.
- Eseguito Code Analyzer sui file M4 e `run_all.m`: 0 messaggi.
- Rigenerate e ispezionate le tre figure M4 con assi chiari e legende corrette.
- Verificato che il rilancio avesse modificato nei vecchi artifact M2/M3 soltanto timestamp/metadata; ripristinati quei sei file da HEAD per evitare rumore nella PR.
- Creati i commit 82cf501 per implementazione/test/artifact e cb89427 per documentazione/decisioni.
- Pubblicato `codex/m4-uncertainty-model` su `origin`.
- Aperta la Pull Request #6 verso `main`: https://github.com/Deda-404/Progetto_CR/pull/6.
- Verificato alla creazione che la PR fosse `open` e `merged=false`.
- Creato `docs/handoff/Resoconto_M4_per_GPT.txt` senza sovrascrivere gli handoff precedenti.

### Problemi e correzioni

Il primo tentativo di apertura PR tramite PowerShell non ha ricevuto dati dall'helper credenziali e si è arrestato prima della richiesta HTTP. È stato riutilizzato in memoria l'helper Git che aveva autenticato il push; la PR è stata creata senza stampare o salvare segreti.

### Risultato

**SUCCESSO — M4 pubblicata per revisione, PR #6 aperta, handoff completo e nessun merge eseguito.**

### Prossimo passo

Attendere la revisione del gruppo. Non iniziare M5.

---

## 2026-08-24 — Cleanup metodologico M4.1

**Responsabile:** Alessio
**Milestone:** M4.1
**Tipo:** Centralizzazione / Dipendenze / Regressioni

### Attività svolta

- Verificato il merge M4 `2adfd25` su `main` e creato `codex/m4-uncertainty-cleanup` da worktree pulita.
- Rimossa dalla motivazione delle rigidezze la frase basata sul confronto numerico con il riferimento.
- Riformulato il ±7% come envelope progettuale prudente ma moderato per dispersione di materiale, assemblaggio e tolleranze equivalenti, non identificato sperimentalmente.
- Rimossi da `uncertainty_params_m4.m` i nominali duplicati `40/0.8/0.015`; la funzione legge ora `actuator_params_nominal.m` e registra la source of truth.
- Rimosso il default silenzioso `k2/k1/Jm1`; input mancante o vuoto genera `M4Uncertainty:MissingSelection`.
- Confermata la catena `screen_parameter_sensitivity -> selectedMechanicalParameters -> uncertainty_params_m4`.
- Eseguito un audit testuale dei sorgenti e documenti tecnici: nessuna formulazione residua indica range scelti per differenziarsi; il confronto reference-last resta soltanto come audit metodologico dichiarato non motivazionale.
- Riformulate D-0007, D-0008, D-0009 e D-0011 e aggiunta D-0013 sulle dipendenze esplicite.
- Aggiunti T15 source of truth, T16 dipendenza dallo screening, T17 preservazione decisioni e T18 regressione M0–M4.
- Salvato nel dataset M4 anche `actuatorNominalSource`.

### Risultati

- Test M4/M4.1 dedicati: 18/18 PASS.
- Test top-level `run_all`: 52/52 PASS, exit code 0.
- Code Analyzer: 0 messaggi.
- Selezione invariata: `k2`, `k1`, `Jm1`.
- Range invariati: ±7%, ±7%, ±9%; attuatori ±8%, ±7.5%, ±20%.
- `WI` invariato esattamente: ordine 1, guadagno 2.8713198663559063, zero -1.3275294867275236 e polo -207.35329856846647.
- Coverage invariato: worst ratio 0.92592592592592582 e margine 0.013072542199752015.
- Coerenza nominale invariata: errori assoluti `GuncMeas/GuncQ` 4.8901839403574157e-15 / 6.3283000096977494e-15.
- `usample` invariato: 40/40 campioni validi.

### Risultato

**SUCCESSO — cleanup tecnico M4.1 PASS, nessuna modifica numerica dell'uncertainty set.**

### Prossimo passo

Completare rilancio finale, commit, push, PR dedicata e handoff. Non iniziare M5.

---

## 2026-08-24 17:17 — Pubblicazione PR e handoff M4.1

**Responsabile:** Alessio
**Milestone:** M4.1
**Tipo:** Quality gate finale / Git / Handoff

### Attivita svolta

- Consolidati i commit `6a715ab` per implementazione, test e dataset e `9c7297a` per documentazione e decisioni.
- Pubblicato `codex/m4-uncertainty-cleanup` su `origin`.
- Aperta la Pull Request [#7](https://github.com/Deda-404/Progetto_CR/pull/7) verso `main`.
- Verificato alla creazione che la PR fosse `open` e `merged=false`.
- Creato `docs/handoff/Resoconto_M4_1_per_GPT.txt` senza sovrascrivere gli handoff precedenti.
- Registrati nell'handoff source of truth, flusso di screening, audit delle motivazioni, preservazione numerica, T15-T18 e risultato di `run_all`.

### Risultato

**SUCCESSO — M4.1 pubblicata per revisione, PR #7 aperta, handoff completo e nessun merge eseguito.**

### Prossimo passo

Attendere la revisione del gruppo. Non iniziare M5.

---

## 2026-08-24 17:44 — Implementazione e primo quality gate M5

**Responsabile:** Alessio
**Milestone:** M5
**Tipo:** Governance / Specifiche / Pesi / Disturbo / Test / Documentazione

### Attività svolta

- Verificato su `main` il merge M4.1 `ba8c197` e creato `codex/m5-performance-specs` da worktree pulita.
- Normalizzati esclusivamente i metadati storici `Autore` in `Responsabile: Alessio`, aggiunta la nota semantica iniziale e mantenuti invariati attività, risultati, problemi, date e cronologia Git.
- Aggiunta in `AGENTS.md` la regola permanente sulla voce documentale del progetto.
- Centralizzati scenari, criteri, pesi e target in `performance_specs_m5.m`, con classificazione fra requisito, assunzione e criterio derivato.
- Derivata dai dataset M2/M3 la finestra 10.8141429–13.9133481 rad/s e selezionato deterministicamente `omegaB=12` rad/s sui candidati 11/12/13.
- Selezionati sulla griglia locale `As=0.05`, `Ms=2`, `uScale=12 N m`, `omegaU=30 rad/s` e `alpha=6` con regole esplicite.
- Costruiti `W1/W2` SISO e MIMO diagonali, stabili e propri; verificati gli asintoti 20/0.5 e 0.0833333/0.5.
- Derivata `Bd` con `M(qbar)^-1` nelle accelerazioni link e verificata mediante differenze finite del modello non lineare con disturbo.
- Costruita la pianta nominale a 14 stati con ingressi separati `[u1,u2,d1,d2]`, preservando il percorso attuato M3.
- Analizzati riferimenti 2°/5°/8° e disturbi 0.25/0.50/1.00 N m; il caso nominale produce deformazioni SEA 0.0100/0.0125 rad.
- Generati dataset, tre figure M5 e documento `SPECIFICHE_PRESTAZIONE.md`; aggiunte D-0014–D-0020.

### Problemi e correzioni

La prima esecuzione T1–T14 ha prodotto un solo FAIL in T8: il test confrontava direttamente due oggetti `tf` numericamente identici ma con nomi I/O differenti. Le altre 13 verifiche, compresa la regressione M0–M4.1 da 52 test, erano PASS. T8 è stato corretto per confrontare le risposte frequenziali dei canali diagonali ed è stato rieseguito isolatamente con esito PASS.

Un controllo aggiuntivo dei nomi salvati nel dataset si è inizialmente arrestato perché le stringhe della riga `-batch` erano state interpretate senza virgolette. La cell array è stata quotata esplicitamente e il controllo ripetuto ha confermato tutti gli undici campi obbligatori.

### Risultati finali

- Code Analyzer sui sei file core M5, sul test M5 e su `run_all.m`: 0 messaggi.
- Suite M5 corretta: 14/14 PASS.
- `matlab.exe -batch "run_all"`: 66/66 test top-level e validazioni M1–M5 PASS, exit code 0.
- Selezione autonoma: `omegaB=12`, `As=0.05`, `Ms=2`, `uScale=12`, `omegaU=30`, `alpha=6`.
- Errore `Bd` analitica/differenze finite: 0 assoluto e relativo alla precisione numerica usata.
- Consistenza locale scenario 5°: errore gravitazionale massimo 0.16043%.
- Nessun controllore, `W3`, `mixsyn` o calcolo di `mu` introdotto.
- Ispezionate le tre figure finali; corretta esplicitamente la scala logaritmica W1/W2 e verificata la leggibilità della frequency map.
- Le rigenerazioni M2–M4 differivano da HEAD soltanto per 3–16 byte di timestamp/metadata e sono state ripristinate per evitare rumore nella milestone M5.

### Risultato

**SUCCESSO — M5 COMPLETE, quality gate PASS e artifact riproducibili.**

### Prossimo passo

Creare commit piccoli, pubblicare il branch, aprire la Pull Request e completare l'handoff. Non iniziare M6.

---

## 2026-08-24 18:00 — Pubblicazione PR e handoff M5

**Responsabile:** Alessio
**Milestone:** M5
**Tipo:** Git / Quality gate finale / Handoff

### Attività svolta

- Creati i commit `f7002ac` per codice, test e artifact e `2e4dd34` per governance, specifiche e decisioni.
- Pubblicato `codex/m5-performance-specs` su `origin`.
- Aperta la Pull Request [#8](https://github.com/Deda-404/Progetto_CR/pull/8) verso `main`.
- Verificato alla creazione che la PR fosse `open` e `merged=false`.
- Creato `docs/handoff/Resoconto_M5_per_GPT.txt` con cleanup documentale, specifiche, formule, `Bd`, artifact, test, problemi e quality gate.

### Risultato

**SUCCESSO — M5 pubblicata per revisione, PR #8 aperta, handoff completo e nessun merge eseguito.**

### Prossimo passo

Attendere la revisione del gruppo. Non iniziare M6.

---

## 2026-08-24 18:20 — Avvio M6 e cleanup epistemico preliminare

**Responsabile:** Alessio
**Milestone:** M6
**Tipo:** Governance / Classificazione epistemica

### Attività svolta

- Verificato su `main` il merge M5 `6c4e0af` e creato `codex/m6-lqg-no-integrator` da worktree pulita.
- Corretto in `performance_specs_m5.m` e `SPECIFICHE_PRESTAZIONE.md` lo stato epistemico dell'equilibrio verticale superiore: decisione approvata D-0003, non requisito della traccia.
- Corretto lo stato epistemico della coppia esterna ai link: scelta di modellazione D-0014 coerente con la traccia, ma non imposta in modo univoco.
- Registrata D-0021 senza riscrivere le decisioni storiche.

### Risultato

Cleanup esclusivamente documentale e semantico: nessun valore numerico, peso, scenario o modello M5 è stato modificato.

### Prossimo passo

Sintetizzare e validare il controllore LQG nominale M6 sui 14 stati, senza integratore e senza iniziare M7.

---

## 2026-08-24 18:45 — Arresto al quality gate LQR M6

**Responsabile:** Alessio
**Milestone:** M6
**Tipo:** Sintesi LQR / Prestazioni / Quality gate

### Attività svolta

- Costruito il costo fisico sui 14 stati con (q_s=5°), scale di velocità (\omega_Bq_s) e deformazione SEA (\delta_s=0.0125) rad.
- Analizzati in modo indipendente i candidati (\rho_U=[0.5,1,2,4,8]) con (R=\rho_U/u_{scale}^2 I_2).
- Per ogni candidato sono stati calcolati (K), poli, precompensatore statico, tracking separato da 5°, cross-coupling, picco del comando e risposta ai disturbi da 0.5 N m.
- Confrontata la metrica di assestamento implementata con `stepinfo` al 2%.
- Eseguita una sola estensione diagnostica (\rho_U=[0.25,0.1,0.05,0.01,0.001]) per verificare se il fallimento dipendesse dal bordo inferiore della griglia.

### Risultati

Tutti i cinque candidati della griglia sono stabilizzanti, rispettano overshoot ed errore statico e mantengono il cross-coupling sotto il target preliminare del 25%. Il worst-case settling cresce da 1.222 s a 1.232 s ed eccede sempre il target M5 di 0.8 s. Anche l'estensione diagnostica più aggressiva raggiunge soltanto 1.21251 s; il limite non è quindi risolto abbassando semplicemente (\rho_U).

### Quality gate

**FAIL — nessun candidato LQR ammissibile; M6 dichiarata PARTIAL.**

Come richiesto, non sono stati modificati M5, i pesi relativi o l'architettura e non sono state avviate selezione Kalman, costruzione LQG o M7.

La regressione baseline `run_all.m` M0–M5 è stata rieseguita dopo il cleanup con 66/66 test top-level PASS ed exit code 0. Il Code Analyzer sui sei file nuovi/modificati direttamente coinvolti ha restituito 0 messaggi. Un doppio rilancio dello screening ha confermato tabella deterministica e assenza di candidati ammissibili.

### Prossimo passo

Richiedere revisione del gruppo sulla strategia di tuning prima di proseguire.

---

## 2026-08-24 20:05 — Ripresa autorizzata, retuning LQR e completamento tecnico M6

**Responsabile:** Alessio
**Milestone:** M6
**Tipo:** Diagnosi / Tuning LQR / Kalman / LQG / Test

### Attività svolta

- Preservato integralmente il precedente stop PARTIAL e mantenuti invariati target, (\omega_B), ampiezza riferimento, (u_{scale}) e scale fisiche.
- Quantificato il costo baseline: pesi equivalenti posizione/deformazione 131.312/6400, rapporto 0.02052, rango (Q)=8 e condition number non nullo 14109.1.
- Identificato il modo dominante (-4.38277\pm1.16189j) e le partecipazioni aggregate in posizione, velocità, motore e attuatore.
- Eseguita la coarse grid completa da 240 candidati, senza preselezione: 139 soddisfano i target fondamentali; la extended grid non è stata avviata.
- Dimostrato l'effetto di (w_\delta): a parametri restanti fissi il settling passa da 1.220 a 0.776 s riducendo la priorità da 1 a 0.1.
- Selezionato C193 con (w_q=1), (w_\delta=0.1), (w_{velocity}=0.5) e (\rho_U=8): picco comando 4.6897 N m, cross-coupling 17.39% e picco deformazione normalizzato 1.8917.
- Analizzati 27 candidati Kalman; tre sono ammissibili e KF03 minimizza (H_2), con ratio di decay 1.6928.
- Costruito il controllore LQG di ordine 14 senza integratori e verificato il principio di separazione con errore (2.43\times10^{-6}).
- Generati dataset, sette figure e simulazione di rumore riproducibile con seed 20260826.

### Problemi e correzioni

La prima esecuzione T1–T26 ha prodotto un solo errore in T14: `struct2array` tentava di concatenare campi scalari e vettoriali delle metriche di rumore. Le restanti 25 verifiche, compresa la regressione M0–M5 da 66 test, erano PASS. T14 è stato corretto verificando esplicitamente ogni campo e il rilancio isolato è risultato PASS.

### Risultati tecnici

- Tracking LQG: settling 0.776/0.514 s, overshoot 0.265/0.025%, errore statico alla precisione numerica.
- Disturbi costanti: offset 0.07959/0.16023 rad, mantenuti come benchmark senza integratore.
- Rumore: RMS tracking 0.0150231 rad, stima (q) 0.000233771 rad, variazione comando 0.0802548 N m.
- Code Analyzer sui file core eseguito durante lo sviluppo: un warning `STRNU` nella gestione della colorbar, corretto usando un handle esplicito.

### Risultato

**SINTESI E VALIDAZIONE M6 PASS; quality gate finale `run_all` ancora da eseguire.**

### Prossimo passo

Completare documentazione, rilanciare T1–T26 e `run_all`, ispezionare gli artifact e pubblicare la PR senza merge. Non iniziare M7.

---

## 2026-08-24 20:35 — Quality gate finale M6

**Responsabile:** Alessio
**Milestone:** M6
**Tipo:** Quality gate / Artifact / Documentazione

### Attività svolta

- Eseguito Code Analyzer su 11 file core, test e pipeline: 0 messaggi.
- Ispezionate le sette figure M6; evidenziato C193 nel confronto candidati e rimossa una voce di legenda spuria dal grafico dei poli.
- Eseguito `matlab.exe -batch "run_all"` con pipeline completa M0–M6.
- Rigenerati dataset e figure e verificati i campi obbligatori del dataset tramite test automatici.

### Risultati finali

- Test top-level: 92/92 PASS, incluse T1–T26 e regressione interna M0–M5 da 66 test.
- Coarse grid: 240 candidati, 139 fondamentali PASS, extended grid non eseguita.
- C193: worst settling 0.776 s, overshoot 0.26545%, cross-coupling 17.391%, peak control 4.6897 N m.
- KF03: ratio 1.69275, (H_2=539.325), stimatore stabile.
- LQG: ordine 14, zero integratori aggiunti, separation error (2.433\times10^{-6}).
- `run_all`: exit code 0 e messaggio finale PASS.

### Risultato

**SUCCESSO — M6 COMPLETE, quality gate PASS e artifact riproducibili.**

### Prossimo passo

Creare commit piccoli, pubblicare il branch e aprire la Pull Request dedicata senza merge. Non iniziare M7.

---

## 2026-08-24 20:50 — Pubblicazione PR e handoff M6

**Responsabile:** Alessio
**Milestone:** M6
**Tipo:** Git / Pull Request / Handoff

### Attività svolta

- Creati i commit `cbb3921` per implementazione, test e artifact e `e016b17` per documentazione e decisioni.
- Pubblicato `codex/m6-lqg-no-integrator` su `origin` mediante il credential manager configurato.
- Aperta la Pull Request [#9](https://github.com/Deda-404/Progetto_CR/pull/9) verso `main`.
- Verificato alla creazione che la PR fosse `open`, `draft=false` e `merged=false`.
- Completato `docs/handoff/Resoconto_M6_per_GPT.txt` con tentativo fallito, diagnosi modale, tuning, matrici, metriche, test, artifact e limiti.

### Risultato

**SUCCESSO — M6 pubblicata per revisione, PR #9 aperta e nessun merge eseguito.**

### Prossimo passo

Attendere la revisione del gruppo. Non iniziare M7.

---

## 2026-08-24 23:05 — Augmentazione, griglia LQI e stop PARTIAL M7

**Responsabile:** Alessio
**Milestone:** M7
**Tipo:** Modellazione / Tuning LQI / Quality gate

### Attività svolta

- Verificato il merge M6 su `origin/main` tramite il commit `5326567` e creato `codex/m7-lqg-integral` da quel punto.
- Costruita autonomamente l’augmentazione 16×16 con due soli integratori sulle posizioni articolari e verificati PBH, stabilizzabilità e rango Rosenbrock in `s=0`.
- Riutilizzato esattamente il blocco `Q` M6 sui 14 stati fisici; derivata da M5 la scala `xiScale=0.0698131701 rad s`.
- Eseguite tutte le 28 combinazioni `wi=[0.05,0.10,0.25,0.50,1,2,4]` e `rhoU=[4,8,12,16]`, senza preselezione e senza `Nr`.
- Simulati per ogni candidato i due step da 5° e i due disturbi costanti da 0.5 N m, registrando stabilità, tracking, comando, deformazione, guadagni, disturbo e stato integrale.
- Verificata numericamente l’eliminazione degli offset DC: 28/28 candidati entro `1e-4 rad`.

### Risultato inatteso e controllo incrociato

Nessun candidato rispetta il target M5 di settling pari a 0.8 s. Il punto più rapido è I25 (`wi=4`, `rhoU=4`) con 1.964 s, overshoot nullo e picco comando pari a 0.0684212 di `uScale`. Il guadagno statico disturbo-posizione di I25 è nullo; dopo 8 s le componenti interessate sono `3.23e-10` e `2.24e-10 rad`. La convenzione di segno, il riuso esatto di `Q_M6`, le dimensioni, i poli e i ranghi PBH sono stati ricontrollati separatamente.

### Quality gate

**PARTIAL — 0/28 candidati fondamentali ammissibili.**

Come prescritto, M5 non è stato modificato, I25 non è stato selezionato e non sono stati costruiti controllore LQG-I finale, analisi di rumore, confronto measured/estimated o dataset finale. Sono stati prodotti soltanto il dataset di checkpoint, la figura della griglia, i test del percorso parziale e l’handoff per la revisione.

### Prossimo passo

Richiedere al gruppo una decisione esplicita sul retuning; non ampliare `wi`, non introdurre feedforward e non modificare M5 automaticamente. Non iniziare M8.

---

## 2026-08-24 23:35 — Verifica riproducibile del checkpoint M7

**Responsabile:** Alessio
**Milestone:** M7
**Tipo:** Test / Artifact / Handoff

### Verifiche eseguite

- Code Analyzer sui sei file M7 e pipeline: 0 messaggi.
- Suite M7 isolata: 15/15 test PASS, 0 failed, 0 incomplete.
- `matlab.exe -batch "run_all"`: 107/107 test top-level PASS, rigenerazione completa M0–M6 e checkpoint M7, codice di uscita 0.
- Ispezionata la figura della griglia dopo aver rappresentato esplicitamente come clipped i casi non assestati entro 3 s.
- Verificati `git diff --check`, dataset parziale, documentazione tecnica e handoff.

### Risultato

La pipeline è tecnicamente riproducibile e termina con il messaggio esplicito `[PARTIAL]`. Non viene dichiarato un quality gate M7 PASS: la suite verifica la correttezza dello stop, non sostituisce il requisito di settling fallito.

### Prossimo passo

Pubblicare il checkpoint su PR dedicata senza merge e attendere la decisione del gruppo sul retuning. Non iniziare M8.

---

## 2026-08-24 23:50 — Pubblicazione PR e handoff del checkpoint M7

**Responsabile:** Alessio
**Milestone:** M7
**Tipo:** Git / Pull Request / Handoff

### Attività svolta

- Creati i commit `fde78ff` per implementazione, test, documentazione e artifact M7 e `16befa6` per la rigenerazione degli artifact baseline durante `run_all`.
- Pubblicato `codex/m7-lqg-integral` su `origin`.
- Aperta la Pull Request [#10](https://github.com/Deda-404/Progetto_CR/pull/10) verso `main`.
- Verificato via API che la PR sia `open`, `draft=false`, `merged=false`, con head e base corretti.
- Aggiornato l’handoff scaricabile con formulazione, griglia, guadagni diagnostici, trade-off, test e motivo dello stop.

### Risultato

**Checkpoint M7 PARTIAL pubblicato per revisione; nessun merge eseguito.**

### Prossimo passo

Attendere istruzioni del gruppo sulla strategia di retuning. Non modificare M5 e non iniziare M8.

---

## 2026-08-24 — Completamento autorizzato M7 con servo 2-DoF

**Responsabile:** Alessio
**Milestone:** M7 completion
**Tipo:** Architettura / Tuning / Feasibility

### Attività svolta

- Verificato il merge della PR #10 su `origin/main` al commit `f702b5b` e creato `codex/m7-integral-completion` senza riscrivere il checkpoint precedente.
- Implementata la legge `u=-Kx*x-Ki*xi+Nff*r`, mantenendo `xi_dot=r-Cq*x` e il costo M6 sui 14 stati.
- Calcolato per ogni candidato `Nff=Gdc_x\I2` dalla relativa `Kx`, senza usare `Nr` M6 o `inv`.
- Ripetuta Stage A sugli stessi 28 candidati e conservato per ogni punto il confronto 1-DoF/2-DoF.
- Verificato con `Nff=0` che il rigetto del disturbo è invariato: differenza massima degli offset 0 rad.
- Poiché Stage A ha fallito, eseguita una sola Stage B sulle 25 combinazioni autorizzate.

### Risultati Stage A

Tutti i 28 candidati sono stabili, ben condizionati e con offset entro `1e-4 rad`; nessuno è ammissibile. I25 passa da 1.964 a 1.880 s, ma introduce 28.824% di overshoot e 10.972 N m di picco comando. Il feedforward non risolve quindi il trade-off della griglia originale.

### Risultati Stage B

Tutti i 25 candidati sono stabili e rigettano il disturbo; nessuno soddisfa settling e overshoot. E16 (`wi=32`, `rhoU=1`) minimizza il settling a 1.020 s, ma ha 40.6448% di overshoot, 35.170 N m di comando e deformazione normalizzata 4.9922. Il massimo condition number di `Gdc_x` sui 53 candidati è 1.75379 e il massimo residuo feedforward è `2.483e-16`: il fallimento non dipende da inversione DC mal condizionata.

### Quality gate

**PARTIAL — Stage A 0/28, Stage B 0/25.**

Come richiesto, E16 non è stato promosso, M5 non è stata modificata e non sono stati costruiti controller LQG-I ordine 16, diagnostica Kalman/rumore o artifact finali. Sono stati generati soltanto dataset e figure di feasibility.

### Prossimo passo

Arrestarsi per revisione del gruppo. Non iniziare M8.

---

## 2026-08-24 — Quality gate software del completamento M7

**Responsabile:** Alessio
**Milestone:** M7 completion
**Tipo:** Test / Pipeline / Artifact

### Verifiche eseguite

- Code Analyzer sui file core e test M7: 0 messaggi.
- Test M7 completion isolati: 19/19 PASS, 0 failed, 0 incomplete.
- `matlab.exe -batch "run_all"`: 111/111 test top-level PASS, rigenerazione M0–M6 e delle due Stage M7, exit code 0.
- Ispezionate le figure di feasibility e dell’effetto feedforward.
- Verificato che il dataset finale `m7_lqg_integral.mat` non venga creato in assenza di candidato ammissibile.

### Distinzione dei gate

- software/test: **PASS**;
- controller synthesis finale: **NOT RUN** per insieme ammissibile vuoto;
- performance: **FAIL**;
- stato M7: **PARTIAL**.

### Prossimo passo

Pubblicare il checkpoint completion sul branch dedicato e fermarsi per revisione. Non iniziare M8.

---

## 2026-08-24 — Pubblicazione feasibility M7 2-DoF

**Responsabile:** Alessio
**Milestone:** M7 completion
**Tipo:** Git / Pull Request / Handoff

### Attività svolta

- Creati i commit `d85e8ce` per software/test/artifact, `eb48273` per documentazione e `263bd16` per la rigenerazione baseline prodotta da `run_all`.
- Pubblicato il branch `codex/m7-integral-completion` su `origin`.
- Aperta la Pull Request [#11](https://github.com/Deda-404/Progetto_CR/pull/11) verso `main`.
- Verificato che la PR sia `open`, `draft=false`, `merged=false`, con base `main` e head corretti.
- Aggiornato l’handoff con checkpoint storico, Stage A/B, feasibility, guadagni diagnostici, test e quality gate.

### Risultato

**Feasibility M7 2-DoF pubblicata per revisione; nessun merge eseguito.**

### Prossimo passo

Fermarsi e attendere la decisione del gruppo. Non iniziare M8.

---

## 2026-08-24 — Ultima feasibility M7 con co-tuning del costo augmentato

**Responsabile:** Alessio
**Milestone:** M7 final feasibility
**Tipo:** Sintesi / Tuning strutturato / Quality gate

### Attività svolta

- Verificato il merge della PR #11 su `origin/main` al commit `b28a06a` e creato `codex/m7-augmented-cost-retuning`.
- Preservati i dataset e i risultati dei checkpoint I25 1-DoF e Stage A/B 2-DoF.
- Esteso il costruttore LQI con `CaugCost` esplicita e priorità adimensionali opzionali, verificando l'identità delle scale fisiche M6 e di `xiScale` M7.
- Implementati valutatore candidato 2-DoF, `Nff` candidato-specifico e ricerca strutturata limitata a C1–C3.
- Eseguita integralmente C1 sui 75 punti autorizzati e applicata senza deroghe la definizione di punto promettente per l'accesso a C2.
- Generati dataset di feasibility, frontiera di Pareto, figura del trade-off e confronto M6/I25/E16/finale.

### Risultati

C1 produce 75/75 candidati stabili e 75/75 con entrambi gli offset entro `1e-4 rad`, ma 0/75 candidati ammissibili e 0/75 promettenti. C113 (`wq=1`, `wi=32`, `rhoU=2`) ha il settling minimo, 1.026 s, con overshoot 40.8714%, comando 25.051 N m e deformazione normalizzata 5.03633. C161 ha il minimo overshoot, 9.61367%, ma worst settling `Inf` entro l'orizzonte di 3 s.

Poiché nessun punto rispetta `Ts<=1.0 s` né la coppia `OS<=15%`, `Ts<=1.2 s`, C2 non riceve seed e non viene eseguita. C3 non è necessaria né autorizzata. Non è stata aggiunta alcuna ricerca oltre C3.

### Quality gate

**PARTIAL — 0/75 ammissibili; nessun controllore finale.**

Con l'architettura LQI/LQG-I studiata e l'ensemble di costi fisicamente normalizzati analizzato, la coppia di requisiti `Ts<=0.8 s` e `OS<=10%` non è risultata simultaneamente raggiungibile.

### Prossimo passo

Fermarsi. La prossima attività richiede una revisione formale della specifica M5; non eseguire altro tuning M7 e non iniziare M8.

---

## 2026-08-24 — Quality gate software della feasibility finale M7

**Responsabile:** Alessio
**Milestone:** M7 final feasibility
**Tipo:** Test / Pipeline / Artifact

### Verifiche eseguite

- Code Analyzer sugli otto file MATLAB nuovi o modificati: 0 messaggi.
- Suite M7 estesa: 29/29 test PASS, 0 failed, 0 incomplete.
- `matlab.exe -batch "run_all"`: 121/121 test top-level PASS, exit code 0.
- Rigenerati tutti i dataset e le figure M0–M7, inclusi i tre artifact obbligatori della feasibility finale.
- Verificata l'assenza di `results/data/m7_lqg_integral.mat` dopo il fallimento prestazionale.
- Verificato `git diff --check` senza errori.

### Distinzione dei gate

- software/test: **PASS**;
- Stage C1: **PASS software**, 75/75 punti;
- performance: **FAIL**, 0/75 ammissibili;
- C2/C3: **NOT RUN corretto** per assenza di seed promettenti;
- stato M7: **PARTIAL**.

### Prossimo passo

Pubblicare la PR dedicata senza merge e fermarsi. Il passo successivo autorizzabile è una revisione formale M5, non altro tuning e non M8.

---

## 2026-08-24 — Pubblicazione della feasibility finale M7

**Responsabile:** Alessio
**Milestone:** M7 final feasibility
**Tipo:** Git / Pull Request / Handoff

### Attività svolta

- Creati i commit `e95fbed` per software, test e artifact e `1c75d9b` per documentazione e handoff.
- Pubblicato `codex/m7-augmented-cost-retuning` su `origin`.
- Aperta la Pull Request [#12](https://github.com/Deda-404/Progetto_CR/pull/12) verso `main`.
- Verificato via API che la PR sia `open`, `draft=false`, `merged=false`, con head e base corretti.
- Aggiornato l'handoff scaricabile con C1/C2/C3, Pareto, punti diagnostici, confronto checkpoint, test, `run_all` e gate finale.

### Risultato

**Ultima feasibility M7 pubblicata per revisione; nessun merge eseguito.**

### Prossimo passo

Fermarsi. È richiesta una revisione formale della specifica M5; non ampliare le griglie, non eseguire altro tuning M7 e non iniziare M8.

---

## 2026-08-24 — Chiusura governance M7 e autorizzazione M8

**Responsabile:** Alessio
**Milestone:** chiusura M7 / avvio M8
**Tipo:** Governance / Git

### Attività svolta

- Verificato il merge della PR #12 in `origin/main` al commit `6339bc2`.
- Aggiornato lo stato obsoleto che indicava la PR aperta e M8 non autorizzata.
- Congelato M7 come `PARTIAL — feasibility conclusa e accettata; nessun ulteriore tuning previsto`.
- Confermato M6 come ultimo controllore validato e M8 come milestone corrente.
- Creato il branch `codex/m8-simulink-lqg-ras` dall'ultimo `main` remoto.

### Vincoli confermati

M5 e i checkpoint M7 restano invariati. M8 userà esclusivamente `K`, `L`, `Nr` M6 senza rituning; non sono autorizzati M9, sintesi H-infinity o mu-analysis.

---

## 2026-08-24 — Modello Simulink e validazioni non lineari M8

**Responsabile:** Alessio
**Milestone:** M8
**Tipo:** Implementazione / Simulink / Validazione

### Attività svolta

- Costruito programmaticamente `SEA_LQG_nonlinear.slx` con controller M6,
  attuatori nominali M3 e meccanica non lineare M1.
- Separati plant assoluto, misure/riferimenti incrementali e stato stimatore.
- Eliminata ogni dipendenza dal base workspace mediante parametri incorporati
  e `Simulink.SimulationInput`.
- Confrontati `ode45` e `ode23t`; selezionato `ode23t` con tolleranze motivate.
- Eseguiti equilibrio, sei tracking, sei disturbi fisici, rumore seeded e
  confronti LTI/non lineare.
- Definito il criterio RAS prima della ricerca e implementate griglia
  grossolana, ricerca radiale e bisezione deterministica.

### Risultati

L'equilibrio non mostra drift. Lo scarto LTI/non lineare massimo sui tracking
è `6.2015e-4 rad` nel caso 8°. Gli offset da disturbo restano visibili, come
previsto per M6 senza integratore. Il rumore con seed 20260826 è riproducibile
con errore di rilancio nullo.

La sezione primaria `xhat0=0` e la sezione con stima iniziale coerente
producono entrambe 57/57 punti convergenti nel box ±60°. La frontiera è quindi
search-box limited; area poligonale 14214 deg² e raggi 60–78.3244°.

### Limiti

La RAS è empirica e sezionale, non una certificazione completa. Il box è un
limite numerico, non fisico. Nessuna saturazione, sintesi robusta, Monte Carlo
o nuovo tuning è stato introdotto. I25 resta fuori dal gate e viene citato
solo come representative integral benchmark lineare M7.

### Quality gate

**PASS — M8 COMPLETE; M7 resta PARTIAL e congelata.**

---

## 2026-08-24 — Quality gate software M8

**Responsabile:** Alessio
**Milestone:** M8
**Tipo:** Test / Pipeline / Artifact

### Verifiche eseguite

- Code Analyzer sui nove file MATLAB M8 nuovi o modificati: 0 messaggi.
- Suite M8 isolata: 18/18 test PASS anche dopo la ricostruzione del modello.
- `matlab.exe -batch "run_all"`: 139/139 test top-level PASS, exit code 0.
- Rigenerate realmente le validazioni M0–M7 e l'intera pipeline M8, incluse
  114 simulazioni/punti unici sulle due sezioni RAS.
- Verificata la presenza di tutti i campi obbligatori del dataset e delle
  cinque figure.
- `git diff --check`: PASS; gli artifact storici M2–M7 rigenerati senza
  modifiche progettuali sono stati ripristinati al contenuto versionato.

### Risultato

**Quality gate M8 completo PASS.** Il prossimo passo indicato è M9, ma non è
stato iniziato.

---

## 2026-08-24 — Pubblicazione M8

**Responsabile:** Alessio
**Milestone:** M8
**Tipo:** Git / Pull Request / Handoff

### Attività svolta

- Creati tre commit separati per software, artifact e documentazione.
- Pubblicato `codex/m8-simulink-lqg-ras` su `origin`.
- Aperta la Pull Request
  [#13](https://github.com/Deda-404/Progetto_CR/pull/13) verso `main`.
- Creato l'handoff scaricabile `Resoconto_M8_per_GPT.txt` con architettura,
  metriche, RAS, test, quality gate e riferimenti Git.

### Risultato

**M8 pubblicata per revisione senza merge autonomo. M9 non iniziata.**

---

## 2026-08-25 — Avvio M9 e housekeeping della baseline

**Responsabile:** Alessio
**Milestone:** M9
**Tipo:** Governance / Git / Audit

### Attività svolta

- Sincronizzato `main` con `origin/main` e verificato il merge della PR #13
  al commit `57912473c4337270dec14d3f566cf9d763ea759f`.
- Verificata la baseline: M0–M6 COMPLETE, M7 PARTIAL terminale, M8 COMPLETE,
  M9 non ancora implementata.
- Creato `codex/m9-hinf-mixsyn` dall'ultimo `main` remoto.
- Corretto lo stato documentale obsoleto che indicava la PR #13 ancora
  aperta; M8 e la relativa storia tecnica restano invariati.

### Vincoli confermati

M9 userà la pianta nominale completa M3 e i pesi M5 congelati, con `W3=[]`.
Non saranno modificati M5, M7 o M8 e non saranno eseguiti `hinfsyn`,
mu-analysis, D-K iteration o tuning automatico dei pesi.

---

## 2026-08-25 — Sintesi, ricostruzione e quality gate M9

**Responsabile:** Alessio
**Milestone:** M9
**Tipo:** Implementazione / Validazione / Artifact

### Attività svolta

- Ricavata `G:u->q` 2×2 di ordine 14 dall'artifact M3 e verificati entrambi
  i percorsi `u` e `d` contro l'artifact M5.
- Caricati W1/W2 da M5, confrontati con la rigenerazione centralizzata e
  preservati `controllerSynthesisAllowed=false`, `W3=[]` e `uScale` come
  normalizzazione senza saturazione.
- Eseguita una sola sintesi `mixsyn(G,W1,W2,[])`, senza retuning.
- Ricostruiti indipendentemente `S`, `T`, `KS` e il closed loop pesato;
  verificata la stabilità interna mediante la matrice completa a 32 stati,
  senza `minreal`.
- Simulati sei tracking, sei disturbi lato link e il confronto diagnostico
  con M6 sugli stessi scenari.
- Generati un dataset M9, sei figure e 29 test automatici dedicati.

### Risultati

Il controllore ha ordine 18. `gamma=10.2071036477` e la norma ricostruita è
`10.2071033931`, con errore relativo `2.495e-8`; l'errore rispetto a `CLmix`
è `4.313e-12`. La massima parte reale dei poli interni è
`-0.683828559884`, quindi Nominal Stability è `PASS`.

Il target pesato è `FAIL`. Il tracking ha worst settling 1.566 s, overshoot
261.619%, errore statico relativo 49.068% e cross-coupling 25.960%; anche i
relativi gate falliscono. Il massimo comando è 8.2558 N m, pari a 0.68798
di `uScale`. Il disturbo produce worst peak/offset 0.87172/0.19868 rad; non è
stata inventata una soglia M5 assente.

### Esito

**M9 PARTIAL:** sintesi e correttezza software valide, obiettivi fondamentali
non soddisfatti. I pesi M5 non sono stati modificati e non è stato iniziato
alcun tuning, `hinfsyn` o lavoro di robustezza.

---

## 2026-08-25 — Quality gate software M9

**Responsabile:** Alessio
**Milestone:** M9
**Tipo:** Test / Pipeline / Artifact

### Verifiche eseguite

- Suite M9 isolata: 29/29 test PASS, 0 failed, 0 incomplete.
- `matlab.exe -batch "run_all"`: 168/168 test top-level PASS, exit code 0.
- Rigenerate realmente le validazioni M1–M9; M7 è rimasta `PARTIAL`
  terminale e M8 `COMPLETE`.
- Code Analyzer sugli otto file MATLAB M9 nuovi o modificati: 0 messaggi.
- `git diff --check`: PASS.
- Ripristinati al contenuto versionato gli artifact storici M2–M8 riscritti
  dalla rigenerazione, preservando soltanto dataset e figure M9 nuovi.

### Distinzione dei gate

- software/test: **PASS**;
- Nominal Stability: **PASS**;
- weighted nominal objective: **FAIL**;
- tracking e cross-coupling: **FAIL**;
- stato complessivo M9: **PARTIAL**.

---

## 2026-08-25 — Pubblicazione del checkpoint M9

**Responsabile:** Alessio
**Milestone:** M9
**Tipo:** Git / Pull Request / Handoff

### Attività svolta

- Creati commit separati per software/test, artifact e documentazione.
- Pubblicato `codex/m9-hinf-mixsyn` su `origin`.
- Aperta la Pull Request
  [#14](https://github.com/Deda-404/Progetto_CR/pull/14) verso `main`.
- Verificato che la PR sia aperta, non draft, non mergiata e mergeable, con
  base `main` al commit `57912473c4337270dec14d3f566cf9d763ea759f`.
- Creato l'handoff autosufficiente `Resoconto_M9_per_GPT.txt`.

### Risultato

**M9 PARTIAL pubblicata per revisione senza merge autonomo.** Non è stata
iniziata M10.

---

## 2026-08-25 — Avvio M10 e housekeeping della baseline

**Responsabile:** Alessio
**Milestone:** M10
**Tipo:** Governance / Git / Audit

### Attività svolta

- Sincronizzato `main` con `origin/main` e verificato il merge della PR #14
  al commit `8a4a3f423210464f9a46a21daa8806722e7a7506`.
- Verificata la baseline: M0–M6 COMPLETE, M7 PARTIAL terminale, M8 COMPLETE,
  M9 PARTIAL validata e M10 non iniziata.
- Creato `codex/m10-hinfsyn-generalized-plant` dall'ultimo `main` remoto.
- Corretto lo stato documentale obsoleto della PR #14 senza alterare il
  risultato tecnico negativo M9.

### Vincoli confermati

M10 userà la stessa pianta nominale, gli stessi pesi e lo stesso scaling di
M9. Prima di `hinfsyn`, la generalized plant dovrà riprodurre il closed loop
M9 con `Kmix`. Non saranno eseguiti retuning, `hinfstruct`, mu-analysis,
validazione robusta M4 o attività M11+.

---

## 2026-08-25 — Generalized plant, sintesi e confronto nominale M10

**Responsabile:** Alessio
**Milestone:** M10
**Tipo:** Implementazione / Validazione / Artifact

### Attività svolta

- Costruita autonomamente la pianta generalizzata mediante `connect` e
  `sumblk`, con ingressi `[r;u]`, uscite `[z1;z2;y]` e partizione compatibile
  con `hinfsyn(P,2,2)`.
- Verificate forma analitica, convenzione `P22=-G`, dimensioni e coerenza
  frequenziale; `augw` è stato usato soltanto come cross-check successivo.
- Richiuso il controllore M9 congelato sulla nuova P prima della sintesi:
  mappe, norma e scaling M9 sono stati riprodotti entro `2.688e-12`.
- Eseguita una sola sintesi `hinfsyn` con opzioni di default, senza retuning,
  W3, precompensatore o modifica degli scenari.
- Ricostruite indipendentemente `S10`, `T10`, `KS10`, interconnessione pesata
  e matrice interna a 32 stati; simulati gli stessi tracking e disturbi M9.
- Generati dataset M10, sei figure, documento tecnico e 40 test dedicati.

### Risultati

P è 6×4, di ordine 18; le partizioni sono P11/P12 4×2 e P21/P22 2×2.
L'errore massimo rispetto alla forma analitica è `1.137e-13` e quello
rispetto ad `augw` è `1.097e-14`.

Il controllore `Khinf` è 2×2, di ordine 18. `gammaHinf=10.2071036477` e la
norma pesata ricostruita è `10.2071033931`, con errore relativo `2.495e-8`.
La massima parte reale dei poli interni è `-0.683828559887`; stabilità e
ricostruzione sono `PASS`.

Le mappe M9/M10 sono quasi equivalenti: differenza relativa dei gamma
`2.938e-13` ed errore H∞ delle mappe pesate `1.274e-9`. Restano però
`gamma>1`, worst settling 1.566 s, overshoot 261.619%, errore statico
49.068% e cross-coupling 25.960%.

### Esito

**M10 PARTIAL:** generalized plant, sintesi, stabilità e confronto sono
validati; weighted performance, tracking e cross-coupling falliscono. M5 è
rimasta invariata e non è stata iniziata alcuna attività M11 o robusta.

---

## 2026-08-25 — Quality gate software M10

**Responsabile:** Alessio
**Milestone:** M10
**Tipo:** Test / Pipeline / Artifact

### Verifiche eseguite

- Suite M10 isolata: 40/40 test `PASS`.
- Il primo `run_all` ha rilevato un unico fallimento nel test storico M9
  T22: il test cercava `hinfsyn` in tutta la cartella condivisa
  `controllers/hinf/`, includendo impropriamente i nuovi file M10.
- Corretto T22 limitandone l'audit ai sei file appartenenti alla pipeline M9;
  nessun criterio tecnico M9 e nessun risultato numerico sono stati cambiati.
- Regressione congiunta M9+M10: 69/69 test `PASS`.
- `matlab.exe -batch "run_all"`: 208/208 test top-level `PASS`, tutte le
  validazioni M1–M10 eseguite, exit code 0.
- Code Analyzer sui file M10 e sul test M9 modificato: 0 messaggi.
- `git diff --check`: `PASS`.
- Ripristinati al contenuto versionato dataset, figure e modello Simulink
  storici M2–M9 riscritti dalla rigenerazione; conservati soltanto gli
  artifact nuovi M10.

### Distinzione dei gate

- software/test: **PASS**;
- Generalized Plant Correctness: **PASS**;
- Nominal Stability: **PASS**;
- H∞ Reconstruction: **PASS**;
- Weighted Nominal Performance: **FAIL**;
- tracking e cross-coupling: **FAIL**;
- disturbo e sforzo: **QUANTIFIED** senza soglie o saturazioni inventate;
- M9/M10 consistency: **PASS**, quasi-equivalenti;
- stato complessivo M10: **PARTIAL**.

---

## 2026-08-25 — Pubblicazione del checkpoint M10

**Responsabile:** Alessio
**Milestone:** M10
**Tipo:** Git / Pull Request / Handoff

### Attività svolta

- Creati commit separati per software/test, artifact e documentazione.
- Pubblicato `codex/m10-hinfsyn-generalized-plant` su `origin`.
- Aperta la Pull Request
  [#15](https://github.com/Deda-404/Progetto_CR/pull/15) verso `main`.
- Verificato che la PR sia aperta, non draft e non mergiata, con base `main`
  al commit `8a4a3f423210464f9a46a21daa8806722e7a7506`.
- Creato l'handoff autosufficiente `Resoconto_M10_per_GPT.txt`.

### Risultato

**M10 PARTIAL pubblicata per revisione senza merge autonomo.** Non è stata
iniziata alcuna attività M11.

---

## 2026-08-25 — Avvio M11 e audit della baseline strutturata

**Responsabile:** Alessio
**Milestone:** M11
**Tipo:** Governance / Git / Audit API

### Attività svolta

- Sincronizzato `main` e verificato il merge della PR #15 al commit
  `47ea295aef28a941f2f443033c03f10c5a6caa4d`.
- Verificato che `codex/m11-hinfstruct-structured` sia pulito e abbia
  merge-base esattamente uguale al commit di baseline.
- Confermati M7 terminale `PARTIAL`, M8 `COMPLETE`, M9/M10 `PARTIAL` e M5
  invariata.
- Letti generalized plant, artifact, codice, test e handoff M9/M10.
- Verificate localmente in MATLAB R2025b le API `hinfstruct`,
  `hinfstructOptions`, `tunableGain`, `tunablePID`, `tunableSS`,
  `getBlockValue` e `rsampleBlock`.
- Verificato con un problema tunabile minimo che `RandomStart=4` produce
  cinque record `info` quando il target non è raggiunto: uno nominale e
  quattro randomizzati, ciascuno con objective, iterazioni e blocchi tuned.

### Perimetro congelato

La campagna usa esclusivamente P M10, W1/W2 M5 e struttura 1-DoF. Sono
predefinite A0 gain MIMO statico, A1 PI decentralizzato, A2 PIDF
decentralizzato e A3–A5 `tunableSS` full MIMO di ordine 2/4/6. Ogni famiglia
ha cinque start deterministici. Non sono autorizzati altri ordini, nuovi
pesi, W3, prefilter, 2-DoF, pianta M4, mu-analysis o attività M12.

---

## 2026-08-25 — Campagna `hinfstruct` strutturata M11

**Responsabile:** Alessio
**Milestone:** M11
**Tipo:** Implementazione / Sintesi / Audit

### Attività svolta

- Definite prima della sintesi le architetture A0–A5, con ordine massimo sei
  e numero di parametri tunabili esplicito.
- Eseguite sei chiamate di campagna con seed base `20260827` e seed di
  famiglia deterministici, senza parallelizzazione o variazioni successive.
- Conservati e classificati tutti i 30 record, inclusi objective infiniti e
  controllori instabili; nessuno start è stato rimosso silenziosamente.
- Ricostruite per ogni controllore numerico le mappe `S/T/KS`, lo stack
  pesato, la dinamica interna plant-controller e il lower bound M10, senza
  `minreal`.

### Risultato

A0 e A1 hanno 0/5 objective finiti e 0/5 soluzioni stabili. A2 ha quattro
objective finiti ma 0/5 chiusure stabili. A3, A4 e A5 hanno 5/5 start stabili
ciascuna; i rispettivi rappresentanti sono start 4/2/5, ordine 2/4/6 e gamma
16.6418540/11.6555347/10.2477452. Nessuna soluzione viola il lower bound
`gamma_M10=10.2071036477`.

A3/A4/A5 formano tutte la frontiera Pareto: a un ordine maggiore corrisponde
un gamma minore. Non emerge un controllore dominante e non è stata imposta
una scelta mediante tracking o score arbitrario.

---

## 2026-08-25 — Validazione, artifact e quality gate M11

**Responsabile:** Alessio
**Milestone:** M11
**Tipo:** Test / Artifact / Quality gate

### Attività svolta

- Valutati per A3/A4/A5 i 18 tracking 2°/5°/8° e i 18 disturbi lato link
  0.25/0.50/1.00 N m, con le metriche congelate M9/M10.
- Generati `m11_hinfstruct_structured.mat` e sei figure per ordine/gamma,
  dispersione multistart, Pareto, risposta pesata, tracking e sforzo/disturbo.
- Aggiunti 48 test M11: 48/48 `PASS`; regressione M9/M10/M11 117/117
  `PASS`; Code Analyzer 0 messaggi sui 12 file M11.
- Esteso ed eseguito `run_all`: 256/256 test, tutte le validazioni M0–M11 e
  exit code 0. Gli artifact storici rigenerati ma fuori scope sono stati
  ripristinati.

### Quality gate

Structured campaign correctness, reconstruction, lower-bound sanity e
software correctness sono `PASS`. La stabilità di tutti gli start è `FAIL`
(15/30); weighted performance, tracking e cross-coupling globale sono
`FAIL`. Disturbo, comando e variabilità sono quantificati. M11 è classificata
`PARTIAL` e A3/A4/A5 sono trasmessi al gruppo per revisione; nessuna M12 è
stata avviata.

---

## 2026-08-25 — Pubblicazione del checkpoint M11

**Responsabile:** Alessio
**Milestone:** M11
**Tipo:** Git / Pull Request / Handoff

### Attività svolta

- Creati commit separati per software/test, artifact e documentazione.
- Pubblicato `codex/m11-hinfstruct-structured` su `origin`.
- Aperta la Pull Request
  [#16](https://github.com/Deda-404/Progetto_CR/pull/16) verso `main`.
- Verificata la PR aperta, non draft e non mergiata, con base `main` al
  commit `47ea295aef28a941f2f443033c03f10c5a6caa4d`.
- Creato l'handoff autosufficiente `Resoconto_M11_per_GPT.txt`.

### Risultato

**M11 PARTIAL pubblicata per revisione senza merge autonomo.** A3/A4/A5
restano candidati Pareto e non è stata iniziata M12.

---

## 2026-08-25 — Avvio M12 e housekeeping della baseline

**Responsabile:** Alessio
**Milestone:** M12
**Tipo:** Governance / Git / Audit

### Attività svolta

- Sincronizzato `main` e verificato il merge reale della PR #16 al commit
  `c5b14e5332279e8e98b89d4c5b7a180102646fde`.
- Creato `codex/m12-mu-analysis-a5` esattamente dal merge commit M11.
- Registrato M11 come checkpoint `PARTIAL` validato e accettato; M8 resta
  l'ultima milestone `COMPLETE` e M6 il controllore nominale con tracking
  conforme.
- Congelato il perimetro M12 come sola analisi robusta del rappresentante A5
  caricato dall'artifact M11, con modello incerto M4 e pesi M5 invariati.

### Vincoli confermati

Nessun nuovo tuning M11, retuning M5, Monte Carlo, Simulink non lineare,
`musyn`, D-K iteration o attività M13 è autorizzato.

---

## 2026-08-25 — Implementazione e validazione della μ-analysis M12

**Responsabile:** Alessio
**Milestone:** M12
**Tipo:** Implementazione / Analisi robusta / Artifact

### Attività svolta

- Caricato il rappresentante A5, start 5 e ordine 6, direttamente
  dall'artifact M11 senza nuove chiamate `hinfstruct`.
- Verificati il nominale `GuncQ` rispetto a M3, i cinque blocchi M4 e i pesi
  W1/W2 M5 congelati; `W3=[]` e nessun retuning.
- Costruita `Punc` con una sola istanza condivisa della pianta incerta e
  verificata la chiusura nominale contro M10 e A5 M11.
- Estratta e verificata la forma N–Δ; eseguiti `mussv` su griglia fissa,
  `robstab`, `robgain` a gamma 1 e `wcgain` a uncertainty level 1.
- Sostituite le perturbazioni worst-case e conservati poli, gain, sensitivity
  e valori actual/normalizzati disponibili dall'API.

### Risultato

La dinamica nominale a 20 stati è internamente stabile, con massima parte
reale `-0.736157095561`: NS `PASS`. La norma nominale è `10.2476411502` a
`6.21670809748 rad/s`: NP `FAIL`.

`robstab` restituisce margin `[0.875899252687,0.882789198079]` a
`81.9862784922 rad/s`, quindi RS `FAIL_CERTIFIED`. La μ manuale produce
margin `[0.879212158739,0.883347347680]` a `81.5955861689 rad/s` e conferma
classificazione e frequenza. `robgain` restituisce `[0,0]`; NP fallita implica
RP `FAIL_CERTIFIED`. `wcgain` è `[Inf,Inf]` e la perturbazione sostituita porta
la chiusura vicino al limite di stabilità. M12 è `PARTIAL`, senza modifica
del controllore o dell'insieme incerto.

---

## 2026-08-25 — Test, regressioni e quality gate M12

**Responsabile:** Alessio
**Milestone:** M12
**Tipo:** Test / Quality gate / Riproducibilità

### Attività svolta

- Creati 54 test M12 per fonti congelate, identità A5, interconnessione,
  N–Δ, bound μ, `robstab`, `robgain`, `wcgain`, artifact e divieti di scope.
- Eseguita la suite M12: 54/54 `PASS`.
- Eseguita la regressione M9–M12: 171/171 `PASS`.
- Eseguita la suite completa tramite `run_all`: 310/310 test, validazioni
  M1–M12 e exit code 0.
- Eseguito MATLAB Code Analyzer sui file M12: zero messaggi.
- Ispezionate le sei figure; il riepilogo rappresenta separatamente NS, NP,
  RS e RP. Ripristinati gli artifact storici riscritti ma fuori scope.

### Quality gate

Frozen controller, frozen uncertainty, N–Δ, consistenza μ manuale e
correttezza software sono `PASS`. NS è `PASS`; NP è `FAIL`; RS e RP sono
`FAIL_CERTIFIED`; worst-case gain e blocchi critici sono `QUANTIFIED`.
Lo stato complessivo è **M12 PARTIAL**. Non sono stati eseguiti Monte Carlo,
Simulink non lineare, `musyn`, D-K iteration, retuning o M13.

---

## 2026-08-25 — Pubblicazione del checkpoint M12

**Responsabile:** Alessio
**Milestone:** M12
**Tipo:** Git / Pull Request / Handoff

### Attività svolta

- Creati commit separati per software/test, artifact e documentazione.
- Pubblicato `codex/m12-mu-analysis-a5` su `origin`.
- Aperta la Pull Request
  [#17](https://github.com/Deda-404/Progetto_CR/pull/17) verso `main`.
- Verificata la PR aperta, non draft e non mergiata, con base `main` al
  commit `c5b14e5332279e8e98b89d4c5b7a180102646fde`.
- Creato l'handoff autosufficiente `Resoconto_M12_per_GPT.txt`.

### Risultato

**M12 PARTIAL pubblicata per revisione senza merge autonomo.** Il risultato
giustifica una discussione separata sull'eventuale M13, che non è stata
iniziata.

---

## 2026-08-25 — Avvio M13 e incidente tecnico `Display='full'`

**Responsabile:** Alessio
**Milestone:** M13
**Tipo:** Governance / Audit API / Errore registrato

### Attività svolta

- Verificata la PR #17 come `merged` al commit
  `9b69caa02c7f8dbca9cc2b936067f67c25904f1a` e creato il branch
  `codex/m13-musyn-dk` dalla baseline esatta.
- Verificata su R2025b la firma full-order di `musyn`, i campi documentati
  dell'`info` e la semantica di `MaxIter`.
- Superati i gate di identità Punc M12, incertezze M4 e pesi M5.
- Avviata la configurazione iniziale con `Display='full'`.

### Incidente

Dopo la prima K/DG-step, `musynEngine` ha richiesto input interattivo per
continuare. MATLAB batch ha terminato senza restituire Kmu, CLperf o info.
Il tentativo è stato registrato `ABORTED_TECHNICAL`; nessun output parziale è
stato usato e non è stato effettuato un rilancio senza autorizzazione.

---

## 2026-08-25 — Ripresa autorizzata e singola campagna D–K valida

**Responsabile:** Alessio
**Milestone:** M13
**Tipo:** Sintesi robusta / Artifact / Audit nominale

### Attività svolta

- Modificato esclusivamente Display da `full` a `short`, mantenendo MaxIter,
  TargetPerf, TolPerf, MixedMU, FullDG, FitOrder, griglia e opzioni K-step.
- Ripetuti con esito `PASS` tutti i gate frozen prima della chiamata.
- Eseguita la prima e unica campagna M13 valida, completando 5/5 iterazioni.
- Conservati raw `info`, D/G scales, fit orders, history non filtrata,
  controller e chiusura incerta.
- Ricostruiti esplicitamente poli interni nominali, S, T, KS e stack pesato.

### Risultato

La migliore iterazione è la 3, con objective `10.4032233618`; Kmu è 2×2 di
ordine 52. La chiusura nominale ha 66 stati e max Re
`-0.731994726169`, quindi NS `PASS`. La norma nominale stacked è
`10.3917314574` a `93.1402569484 rad/s`; il lower-bound sanity rispetto a
M10 è `PASS`. L'objective resta >1 ed è conservato senza retuning.

Nessuna analisi RS/RP indipendente, riduzione d'ordine, seconda campagna,
Monte Carlo, Simulink non lineare o M14 è stata eseguita.

---

## 2026-08-25 — Test, run_all e quality gate M13

**Responsabile:** Alessio
**Milestone:** M13
**Tipo:** Test / Riproducibilità / Quality gate

### Attività svolta

- Creata la suite M13 T01–T52: 52/52 `PASS`.
- Eseguito MATLAB Code Analyzer su otto file M13: zero messaggi.
- Eseguito `run_all` M0–M13: 362/362 test e exit code 0.
- Verificato che `run_all` ricarichi l'artifact congelato M13 senza una
  seconda chiamata di sintesi.
- Prodotti `m13_musyn_dk.mat` e sei grafici tecnici.

### Quality gate

Frozen plant/uncertainty/weights, D–K execution/history, controller,
stabilità nominale, ricostruzione pesata, lower-bound sanity e software sono
`PASS`; objective e ordine sono `QUANTIFIED`. **M13 è COMPLETE.** M14 non è
iniziata e richiede autorizzazione separata.

---

## 2026-08-25 — Pubblicazione M13

**Responsabile:** Alessio
**Milestone:** M13
**Tipo:** Git / Pull Request / Handoff

### Attività svolta

- Creati i commit `e1cdc382309fc7257566dffe3a6785922ce3d884`
  per software/artifact e `7b12dd2a0bebf8c87c8afabbd0611245cd755c89`
  per documentazione e handoff.
- Pubblicato `codex/m13-musyn-dk` su `origin`.
- Aperta la [PR #18](https://github.com/Deda-404/Progetto_CR/pull/18)
  verso `main`, non draft e non mergiata.
- Aggiornato `Resoconto_M13_per_GPT.txt` con configurazione, history,
  controller, gate, test e distinzione del tentativo tecnico abortito.

### Risultato

**M13 COMPLETE pubblicata per revisione tecnica senza merge autonomo.** Non
è stata iniziata M14.

---

## 2026-08-25 — Avvio M14 e gate delle fonti congelate

**Responsabile:** Alessio
**Milestone:** M14
**Tipo:** Governance / Audit / Housekeeping

### Attività svolta

- Verificata realmente la PR #18 come `merged` al commit
  `49f37c6e027aaa37db65f27530901965f897f11f` e creato il branch
  `codex/m14-final-mu-analysis-kmu` dalla baseline esatta.
- Verificate in MATLAB R2025b le API M12 `lftdata`, `mussv`, `robstab`,
  `robgain`, `wcgain`, `usubs`, `actual2normalized`, `robOptions` e
  `wcOptions`.
- Caricato Kmu dall'artifact M13 e verificata l'identità esatta con
  `rawInfo(bestIteration).K`: best iteration 3, controller 2×2 ordine 52.
- Ripetuti i gate Punc M12/M13, M4 e M5 senza modifica di blocchi, range,
  pesi o opzioni robuste.

### Nota tecnica

Una prima prova read-only avviata con PTY è rimasta nel livello terminale su
una richiesta ANSI, senza uso CPU e senza risultati. Il processo è stato
terminato e la stessa prova è stata rilanciata in modalità batch non
interattiva. Non è stata eseguita sintesi e nessun dato parziale è stato
usato.

---

## 2026-08-25 — μ-analysis finale Kmu e confronto con A5

**Responsabile:** Alessio
**Milestone:** M14
**Tipo:** Analisi robusta / Artifact / Figure

### Attività svolta

- Derivata la configurazione M14 da M12, mantenendo identiche griglie,
  opzioni, target gamma e tolleranze.
- Ricostruiti senza `minreal` S, T, KS, stack pesato e 66 poli interni;
  verificata la coincidenza con M13.
- Riutilizzate le funzioni M12 per N–Δ, μ manuale, `robstab`, `robgain` e
  `wcgain`, incluse le sostituzioni reali delle perturbazioni worst-case.
- Costruiti confronto centrale A5/Kmu, tabella dei blocchi critici,
  classificazione RS deterministica e riepilogo NS/NP/RS/RP.
- Generati l'artifact `m14_final_mu_analysis_kmu.mat` e sei grafici tecnici.

### Risultato

NS è `PASS`, con max Re `-0.731994726169`; NP è `FAIL`, con norma
`10.3917314574`. `robstab` restituisce
`[1.25003698645,1.25257264120]` a `17.3621393164 rad/s`, quindi RS è
`PASS_CERTIFIED`. La μ manuale restituisce
`[1.25245798190,1.25258325878]` e la coerenza è `PASS`.

RP è `FAIL_CERTIFIED` con margin `[0,0]`; `wcgain` è
`[25.9514560605,26.1151353973]` e la sostituzione è coerente. Rispetto ad A5,
i bound RS aumentano di `0.374137733765` e `0.369783443123`, con transizione
`FAIL_CERTIFIED -> PASS_CERTIFIED`: `CLEAR_IMPROVEMENT`. `Delta_act2` resta
il blocco dominante per sensitivity RS.

---

## 2026-08-25 — Test e quality gate M14

**Responsabile:** Alessio
**Milestone:** M14
**Tipo:** Test / Riproducibilità / Quality gate

### Attività svolta

- Creati 56 test M14 per baseline, fonti congelate, identità nominale, N–Δ,
  bound, worst-case, confronto A5/Kmu, divieti di scope e stato complessivo.
- Il primo avvio della suite ha rilevato un errore di setup nella
  concatenazione dei percorsi sorgente: 0/56 eseguiti, 56 incompleti. La
  lista è stata corretta da matrice di caratteri a cell array.
- Il secondo avvio ha superato 56/56 test, senza imporre RS `PASS` come
  aspettativa hardcoded.
- Eseguito `run_all` M0–M14: 418/418 test, tutte le validazioni completate
  ed exit code 0; M13 è stata ricaricata dall'artifact senza nuova `musyn`.
- MATLAB Code Analyzer ha restituito zero messaggi sugli otto file M14 e su
  `run_all.m`.

### Quality gate

Frozen Kmu/M4/M5/Punc, ricostruzione nominale, N–Δ, coerenza μ/robstab e
software sono `PASS`; RS è `PASS_CERTIFIED`, mentre NP e RP falliscono. Il
risultato complessivo è **M14 PARTIAL**. Nessuna nuova sintesi, riduzione,
retuning, simulazione non lineare, Monte Carlo o M15 è stata eseguita.

---

## 2026-08-25 — Pubblicazione M14

**Responsabile:** Alessio
**Milestone:** M14
**Tipo:** Git / Pull Request / Handoff

### Attività svolta

- Creato il commit tecnico
  `544077374f67d4c65f6c466c55e7e8b83d888109` con pipeline, test, artifact,
  figure, documento tecnico e integrazione `run_all`.
- Pubblicato `codex/m14-final-mu-analysis-kmu` su `origin`.
- Aperta la [PR #19](https://github.com/Deda-404/Progetto_CR/pull/19)
  verso `main`, non draft e non mergiata.
- Creato l'handoff autosufficiente `Resoconto_M14_per_GPT.txt` con sezioni
  A–U e link reale della PR.

### Risultato

**M14 PARTIAL pubblicata per revisione tecnica senza merge autonomo.** M15
non è stata iniziata.

---

## 2026-08-25 — Avvio M15 e audit delle fonti congelate

**Responsabile:** Alessio
**Milestone:** M15
**Tipo:** Governance / Audit / Simulink

### Attività svolta

- Verificata PR #19 mergiata e baseline esatta
  `c51142e624adea610e72d16ddfd764008cb65371`; creato il branch
  `codex/m15-nonlinear-robust-validation`.
- Auditati modello M8, equazioni M1, attuatori/equilibrio M3, configurazione
  solver/RAS, artifact M10/M13/M14 e pipeline `run_all`.
- Caricati Khinf ordine 18 e Kmu ordine 52 direttamente dagli artifact,
  verificando identità delle matrici e best iteration Kmu.
- Costruito `SEA_ROBUST_nonlinear.slx` separato dal modello M8, con feedback
  q-only, coordinate assolute/incrementali e soli ingressi SimulationInput.

### Esito

Frozen controllers, frozen nonlinear plant, configurazione solver ed
equilibri sono `PASS`. Nessuna sintesi, riduzione, saturazione, incertezza o
M16 è stata avviata.

---

## 2026-08-25 — Campagna non lineare M15

**Responsabile:** Alessio
**Milestone:** M15
**Tipo:** Simulazioni / RAS / Artifact

### Attività svolta

- Eseguiti per entrambi i controller equilibrio, sei tracking, sei disturbi,
  noisy/repeat/noise-free, confronti LTI/NL, RAS empirica e regione di
  accordo su 36 direzioni.
- Conservate configurazioni M8: `ode23t`, tolleranze, orizzonti, griglia RAS,
  criterio di coda, seed `20260826` e assenza di saturazione.
- Il primo completamento numerico si è arrestato nella tabella riepilogativa
  per orientamento riga/colonna; nessun risultato è stato inventato. È stato
  aggiunto un checkpoint prima delle elaborazioni finali.
- Il gate plant inizialmente risultava `FAIL` per una negazione booleana
  errata su `m8ModelModified=false`; corretta la logica, tutti gli audit
  fisici risultano `PASS`.
- Diagnosticata e corretta la duplicazione degli stati instabili nella
  cascata LTI diretta del disturbo, adottando la realizzazione D-0042 a stato
  fisico condiviso. Sono stati rieseguiti soltanto i 12 disturbi.

### Risultati

- Tracking Khinf/Kmu `FAIL`: worst Ts 1.7322/1.7346 s, OS
  261.347/228.364%, errore 49.0679/50.4416%.
- Cross-coupling diagnostico: Khinf `FAIL` 25.913%, Kmu `PASS` 23.944%.
- RAS Khinf: 282 simulazioni, rmin 52.876°, area 12721 deg², boundary
  interno. RAS Kmu: 107 simulazioni, rmin 60°, area 14213.6 deg²,
  search-box limited.
- Agreement region: rmin 4° Khinf e 4.75° Kmu; aree 99.522 e
  111.721 deg².
- Noise repeat error nullo per entrambi; comando quantificato senza
  saturazione.

### Quality gate

Software, modello, equilibri e simulazioni richieste sono `PASS`; tracking
M5 fallisce. M15 è **PARTIAL**. La RS `PASS_CERTIFIED` di Kmu resta riferita
esclusivamente al modello lineare incerto M4.

---

## 2026-08-25 — Test dedicati M15

**Responsabile:** Alessio
**Milestone:** M15
**Tipo:** Test / Riproducibilità

### Attività svolta

- Creata la suite T01–T60 per baseline, controller, architettura, scenari,
  rumore, RAS, agreement regions, artifact e divieti metodologici.
- Eseguita realmente la suite M15: **60/60 PASS**.
- Corretti tre avvisi stilistici del Code Analyzer nei file M15.
- Generati dataset da 13 MB, modello Simulink e otto figure tecniche.

### Stato

- Eseguito realmente `run_all` M0–M15: **478/478 test PASS**, tutte le
  validazioni terminate, exit code 0.
- M13 è stata ricaricata dall'artifact senza nuova `musyn`; M14 ha confermato
  RS `PASS_CERTIFIED` sul modello lineare incerto e stato `PARTIAL`.
- M15 ha rigenerato RAS/agreement e confermato software `PASS`, tracking
  Khinf/Kmu `FAIL`, stato `PARTIAL`.
- Code Analyzer: zero messaggi sui file M15 e `run_all.m`.

Resta da pubblicare la PR dedicata. Non è stata iniziata M16.

---

## 2026-08-25 — Pubblicazione M15

**Responsabile:** Alessio
**Milestone:** M15
**Tipo:** Git / Pull Request / Handoff

### Attività svolta

- Creato il commit tecnico/documentale
  `1a3867b82e80e00f9ebc76d326a7377051c0ef37`.
- Pubblicato `codex/m15-nonlinear-robust-validation` su `origin`.
- Aperta la [PR #20](https://github.com/Deda-404/Progetto_CR/pull/20)
  verso `main`, non draft, mergeable e non mergiata.
- Aggiornato `Resoconto_M15_per_GPT.txt` con branch, commit, PR, risultati,
  478/478 test e limiti metodologici.

### Risultato

**M15 PARTIAL pubblicata per revisione tecnica senza merge autonomo.** Kmu
resta RS `PASS_CERTIFIED` soltanto sul modello lineare incerto M4; M16 non è
stata iniziata.

---

## 2026-08-26 — Avvio M16 e audit del percorso A

**Responsabile:** Alessio
**Milestone:** M16
**Tipo:** Governance / Audit / Monte Carlo lineare

### Attività svolta

- Verificata PR #20 `MERGED` e baseline esatta
  `8e1c8437c786a252a380ce6b4452d32bebf9c2c6`; creato il branch
  `codex/m16-monte-carlo-m4` senza lavorare su `main`.
- Registrata la decisione D-0043: percorso A, M4/M5/M6/Khinf/Kmu congelati,
  nessuna nuova sintesi, riduzione, retuning, saturazione, simulazione non
  lineare incerta o M17.
- Auditati gli artifact M4, M5, M6, M10, M13, M14 e M15. Confermati i cinque
  blocchi `Jm1`, `k1`, `k2`, `Delta_act1`, `Delta_act2`; controller identici
  agli artifact, di ordine 14, 18 e 52.
- Congelati prima della campagna seed `20260826`, generatore `twister`, 40
  campioni e griglie temporali M5. È stata usata una sola sequenza effettiva
  `usample`; il secondo replay del seed è servito esclusivamente all'audit e
  non è entrato nelle simulazioni.

### Note tecniche

- Due errori iniziali di preallocazione di struct sono avvenuti prima della
  campagna effettiva e sono stati corretti senza produrre o sostituire
  campioni.
- Il primo gate nominale M6 ha evidenziato una distanza fra insiemi di poli
  `8.3803e-7`, a fronte di mappe coincidenti a `2.0704e-12` assoluto e
  `2.2899e-13` relativo. La tolleranza poli, distinta da quella delle mappe,
  è stata motivatamente posta a `1e-5` per i modi ripetuti/condizionati M6;
  nessun controller o modello è stato modificato.

### Esito audit

Baseline, incertezza congelata, controller congelati, replay e gate nominali
M6/Khinf/Kmu sono `PASS`. Sample 0 riproduce 28/32/66 stati interni ed è
escluso dalle statistiche Monte Carlo.

---

## 2026-08-26 — Campagna Monte Carlo M16

**Responsabile:** Alessio
**Milestone:** M16
**Tipo:** Analisi / Artifact / Figure

### Attività svolta

- Generati una sola volta 40 campioni comuni M4 e conservati i
  `sampledValues` raw, i valori `ureal`, le deviazioni percentuali e gli
  oggetti LTI campionati `Delta_act1/2` con diagnostica di norma, ordine,
  stabilità e finitezza.
- Costruita per ogni sample una pianta fisica lineare a stato condiviso con
  ingressi `[u1 u2 d1 d2]`, uscite `[q1 q2 theta1 theta2]` e disturbo lato
  link. Gli errori massimi verso gli oggetti `usubs` sono `5.2736e-16`
  assoluto, `4.5213e-15` relativo sulle misure e `2.8949e-12` relativo su q.
- Valutati M6, Khinf e Kmu congelati sugli stessi SampleID: stabilità,
  banda diagonale, tracking 5 deg, disturbo 0.50 N m, cross-coupling e
  comando senza clipping.
- Salvati dataset `m16_monte_carlo_uncertain_linear.mat`, nove figure e il
  documento tecnico `MONTE_CARLO_UNCERTAIN_PLANTS.md`.

### Risultati

- Tutti i 40 campioni sono validi. Stabilità empirica: M6 `39/40`, Khinf
  `40/40`, Kmu `40/40`. Il Sample 5 M6 ha due poli RHP e max Re
  `+1.80447`; è conservato e non sostituito.
- Mediane di banda diagonale `(BW1,BW2)` [rad/s]: M6 `(4.6729,10.376)`,
  Khinf `(13.412,28.445)`, Kmu `(12.033,29.155)`.
- Core tracking pass rate rispetto ai 40 sample: M6 `30%`, Khinf `0%`, Kmu
  `0%`. I fallimenti prestazionali sono documentati come risultati, senza
  retuning.
- Kmu `40/40` è coerente con M14 RS `PASS_CERTIFIED`, margine
  `[1.25003698645,1.25257264120]`; la Monte Carlo non è una certificazione
  né una probabilità fisica.
- Il confronto paired non produce score globale né seleziona un vincitore;
  la decisione resta rinviata a M17.

### Quality gate

M16 è **COMPLETE**: campagna finita e riproducibile, validità, ricostruzione
fisica, gate nominali, coerenza M14 e correttezza software `PASS`. Stabilità
M6/Khinf/Kmu e prestazioni sono correttamente `QUANTIFIED`.

---

## 2026-08-26 — Verifica integrale M16

**Responsabile:** Alessio
**Milestone:** M16
**Tipo:** Test / Riproducibilità / Qualità

### Attività svolta

- Suite class-based dedicata M16 T01–T69: **69/69 PASS**.
- Regressione aggregata M14–M16: **185/185 PASS**. Il primo comando di
  aggregazione non ha avviato test perché i `TestSuite` avevano orientamenti
  incompatibili; corretto soltanto il comando di esecuzione con `a(:)`.
- Suite completa standalone: **547/547 PASS**.
- Eseguito realmente `run_all` M0–M16: **547/547 PASS**, tutte le
  validazioni concluse ed exit code 0. M13 è stato ricaricato dall'artifact,
  senza nuova `musyn`.
- MATLAB Code Analyzer: zero messaggi sui file M16, sulla suite dedicata e
  su `run_all.m`.
- Il replay integrale ha riscritto deterministicamente artifact/figure
  storici M2–M15 e i due modelli Simulink; tali modifiche binarie, estranee
  allo scope congelato, sono state ripristinate. Restano nel diff soltanto
  codice, documenti e artifact nuovi M16.

### Stato

**M16 COMPLETE e pronta per pubblicazione in PR senza merge autonomo.** M17
non è stata iniziata.

---

## 2026-08-26 — Pubblicazione M16

**Responsabile:** Alessio
**Milestone:** M16
**Tipo:** Git / Pull Request / Handoff

### Attività svolta

- Creato il commit tecnico/documentale
  `fb41f7710cd7ce82d8f878214b75fcd5b1ba7326`.
- Pubblicato `codex/m16-monte-carlo-m4` su `origin`.
- Aperta la [PR #21](https://github.com/Deda-404/Progetto_CR/pull/21)
  verso `main`, non draft, aperta e non mergiata.
- Creato l'handoff autosufficiente `Resoconto_M16_per_GPT.txt` con sezioni
  A–U, risultati, test, limiti e riferimenti Git reali.

### Risultato

**M16 COMPLETE pubblicata per revisione tecnica senza merge autonomo.** La
Monte Carlo resta evidenza empirica lineare e non sostituisce la
certificazione mu M14. M17 non è stata iniziata.

---

## 2026-08-27 — Confronto finale artifact-only M17

**Responsabile:** Alessio

**Milestone:** M17

**Tipo:** Analisi / Decisione / Artifact / Figure

### Attività svolta

- Verificata su GitHub la PR #21 `MERGED` e sincronizzato `main` al commit
  `392ad170dc6665c87b769e314edb8380a4b1c8bc`; creato il branch
  `codex/m17-final-comparison` da working tree pulita.
- Caricati senza rigenerazione gli artifact M5/M6/M8/M10/M12/M13/M14/M15/
  M16 e verificata l'identità dei controllori M6, Khinf e Kmu fra tutte le
  milestone che li riusano. Gli ordini risultano 14/18/52.
- Costruiti confronti separati per nominale lineare, nominale non lineare,
  Monte Carlo lineare incerta e robustezza formale. A5 M12 è conservato come
  evidenza storica e non confuso con Khinf M10.
- Prodotti tabella master, matrice M5, confronti di stabilità, RAS, comando e
  complessità, strengths/weaknesses e sette figure tracciabili.
- Salvato `m17_final_controller_comparison.mat`; nessuna sintesi, tuning,
  nuova sequenza `usample`, simulazione dinamica, Simulink, riduzione,
  prefilter, score globale o M18 è stata eseguita.

### Decisione

La regola gerarchica derivata dagli artifact assegna Kmu al ruolo **FINAL
ROBUST CONTROLLER**, M6 al ruolo **NOMINAL PERFORMANCE REFERENCE** e Khinf
al ruolo **H-INFINITY REFERENCE / COMPARATOR**. La motivazione non cancella
gli esiti negativi: Kmu fallisce tracking, NP e RP; M6 conserva il Sample 5
instabile; Khinf fallisce tracking e weighted performance.

### Stato

M17 è `COMPLETE` come confronto e decisione. Nessun controller è dichiarato
conforme a tutte le specifiche M5 e la Monte Carlo M16 non è interpretata
come certificazione.

---

## 2026-08-27 — Verifica integrale M17

**Responsabile:** Alessio

**Milestone:** M17

**Tipo:** Test / Riproducibilità / Qualità

### Risultati

- Suite class-based M17 T01–T42: **42/42 PASS**.
- Regressione aggregata M16–M17: **111/111 PASS**.
- Suite completa standalone: **589/589 PASS**.
- `run_all` reale M0–M17: **589/589 PASS**, exit code 0. M13 è stato
  ricaricato dall'artifact senza nuova `musyn`; M17 ha caricato gli artifact
  M6–M16 senza nuova sintesi, campionamento o Simulink.
- MATLAB Code Analyzer: **zero messaggi** sui cinque moduli M17, parametri,
  suite dedicata e `run_all.m`.
- Gli artifact/figure M2–M16 e i modelli Simulink riscritti deterministicamente
  da `run_all` sono stati ripristinati perché fuori scope. Un rerun M17 dopo
  il ripristino ha superato nuovamente **42/42**.
- `git diff --check`: **PASS**.

### Stato

**M17 COMPLETE e riproducibile; pronta per pubblicazione in PR senza merge
autonomo.**

---

## 2026-08-27 — Pubblicazione M17

**Responsabile:** Alessio

**Milestone:** M17

**Tipo:** Git / Pull Request / Handoff

### Attività svolta

- Creato il commit tecnico/documentale
  `b80af4230ea4a1337cd8ad164cc984b986b4bd76`.
- Pubblicato `codex/m17-final-comparison` su `origin`.
- Aperta la [PR #22](https://github.com/Deda-404/Progetto_CR/pull/22)
  verso `main`, non draft, `OPEN` e non mergiata.
- Preparato l'handoff autosufficiente `Resoconto_M17_per_GPT.txt` con
  sezioni A–V, fonti, decisione, test, limiti e input esatti per M18.

### Risultato

**M17 COMPLETE pubblicata per revisione tecnica senza merge autonomo.**

---

## 2026-08-27 — Finalizzazione artifact-only M18

**Responsabile:** Alessio

**Milestone:** M18

**Tipo:** Relazione / Presentazione / Tracciabilità / Riproducibilità

### Attività svolta

- Verificata su GitHub la PR #22 `MERGED` e sincronizzato `main` al commit
  `75d194d49a96b67309b1853f154bdd22a168ca4f`; creato il branch
  `codex/m18-final-deliverables` da working tree pulita.
- Caricati gli artifact congelati M1–M17 senza nuova sintesi, retuning,
  riduzione, Monte Carlo, simulazione dinamica o Simulink.
- Generato un audit di 59 valori, 11 tabelle, il manifest di 15 figure e 13
  asset di presentazione; i 19 controlli di riconciliazione sono `PASS`.
- Prodotta la relazione modulare in italiano con 13 capitoli e 3 appendici.
  Il PDF è di 27 pagine e conserva esplicitamente gli esiti negativi.
- Prodotta una presentazione Beamer 16:9 di 17 slide, con timing stimato
  17:30, note oratore e distinzione esplicita fra Monte Carlo M16 e
  certificazione mu M14.
- Compilati entrambi i PDF con zero errori, riferimenti irrisolti, overflow
  o destinazioni duplicate. I dati anagrafici restano marcati
  `USER INPUT REQUIRED BEFORE SUBMISSION`.

### Stato

M18 è `COMPLETE` come finalizzazione dei deliverable. Questo stato non
modifica i risultati tecnici: Kmu conserva RS certificata ma NP/RP e tracking
falliti; M6 conserva il Sample 5 instabile; RAS e Monte Carlo restano
empiriche; saturazioni e limiti hardware reali restano non verificati.

---

## 2026-08-27 — Verifica integrale M18

**Responsabile:** Alessio

**Milestone:** M18

**Tipo:** Test / Build / Ispezione visiva / Qualità

### Risultati

- Suite class-based M18 T01–T60: **60/60 PASS**.
- Suite completa standalone: **649/649 PASS**.
- `run_all` reale M0–M18: **649/649 PASS**, exit code 0; M13 ricaricata
  dall'artifact senza nuova `musyn`.
- Audit LaTeX relazione/presentazione: zero errori, riferimenti irrisolti,
  overflow e destinazioni duplicate; PDF rispettivamente di 27/17 pagine.
- Ispezione visiva completata su tutte le 27 pagine e tutte le 17 slide;
  nessun elemento tagliato, sovrapposto o illeggibile.
- MATLAB Code Analyzer: zero messaggi sui moduli M18, test e `run_all.m`.
- Gli artifact, le figure M2–M17 e i modelli Simulink riscritti
  deterministicamente da `run_all` sono stati ripristinati perché fuori
  scope; l'audit M18 è stato rigenerato sugli artifact congelati.
- `git diff --check`: PASS.

### Stato

**M18 COMPLETE e riproducibile; pronta per pubblicazione in PR senza merge
autonomo.**

---

## 2026-08-27 — Pubblicazione M18

**Responsabile:** Alessio

**Milestone:** M18

**Tipo:** Git / Pull Request / Handoff finale

### Attività svolta

- Creato il commit tecnico/documentale
  `0db991dcb78dee23c4bf47ecd755ca0968c47ee6`.
- Pubblicato `codex/m18-final-deliverables` su `origin`.
- Aperta la [PR #23](https://github.com/Deda-404/Progetto_CR/pull/23)
  verso `main`, non draft, `OPEN` e non mergiata.
- Preparato l'handoff conclusivo `Resoconto_M18_per_GPT.txt` con le sezioni
  A--U, i riferimenti ai deliverable, gli esiti tecnici conservati e la
  checklist manuale pre-consegna.

### Risultato

**M18 COMPLETE pubblicata per revisione e merge manuali. Nessuna nuova
milestone tecnica è aperta.**

---

## 2026-08-27 — Revisione editoriale finale

**Responsabili:** Alessio de Dato, Valerio Rebechi

**Tipo:** Relazione / Presentazione / Repository / Consegna

### Attività svolta

- Verificata la baseline della PR #23, mergiata nel commit
  `6486bb240cdbcf4517ed1e893d83e6b1a34168e1`.
- Mantenuti invariati specifiche M5, pesi, insieme incerto M4 e controllori
  M6, Khinf e Kmu; non sono state eseguite nuove sintesi o retuning.
- Ampliata la relazione con le motivazioni ingegneristiche e i limiti delle
  diverse classi di evidenza.
- Chiarito che M13 produce Kmu, mentre la certificazione RS deriva dalla
  post-analisi indipendente M14.
- Corretta la tabella M16 separando il numero di casi instabili dal Sample
  ID instabile e denominando la percentuale frazione empirica.
- Aggiornati autori, README, manifest e stato del progetto.
- Rimossi i resoconti operativi intermedi non più necessari; le citazioni
  storiche nel diario e nel changelog sono conservate come cronologia.
- Avviata la validazione completa di tabelle, PDF, test, pipeline e analisi
  statica prima della pubblicazione della revisione.

### Stato

Revisione editoriale in corso. I risultati tecnici positivi e negativi
rimangono quelli validati in M1--M18.

---

## 2026-08-27 — Validazione della revisione editoriale finale

**Responsabili:** Alessio de Dato, Valerio Rebechi

**Tipo:** Test / Build / Ispezione visiva / Qualità editoriale

### Risultati

- Test dedicati M18: **60/60 PASS**.
- Suite completa standalone: **649/649 PASS**.
- `run_all` M0--M18: **PASS**, 649/649 test interni ed exit code 0;
  M13 ha ricaricato l'artifact senza nuova `musyn`.
- MATLAB Code Analyzer: **15 file, zero segnalazioni**.
- Relazione compilata in **45 pagine** e presentazione in **17 slide**;
  entrambi gli audit LaTeX riportano zero errori, riferimenti irrisolti,
  overflow e destinazioni duplicate.
- Ispezione visiva completata su tutte le 45 pagine e le 17 slide senza
  tagli, sovrapposizioni o elementi illeggibili.
- Gli output tecnici M1--M17 rigenerati da `run_all` sono stati ripristinati
  alla baseline; restano modificati solo i deliverable e l'audit M18.
- Specifiche, pesi e controllori congelati risultano invariati.
- `git diff --check` e audit del linguaggio operativo: **PASS**.

### Stato

**Revisione editoriale COMPLETE e pronta per la pull request.** Restano da
inserire manualmente le matricole e la data di consegna. Nessun merge viene
eseguito automaticamente.

---

## 2026-08-27 — Pubblicazione della revisione editoriale finale

**Responsabili:** Alessio de Dato, Valerio Rebechi

**Tipo:** Git / Pull Request / Consegna

### Attività svolta

- Creati commit logici separati per pulizia operativa, deliverable finali,
  audit del repository e registrazione della pubblicazione.
- Pubblicato `codex/final-human-editorial-review` su `origin`.
- Aperta la [PR #24](https://github.com/Deda-404/Progetto_CR/pull/24),
  intitolata “Final editorial review: report, presentation and repository
  cleanup”, verso `main`.
- Verificato che la PR sia `OPEN`, non draft e non mergiata.

### Risultato

**Revisione editoriale finale pubblicata per revisione umana.** I PDF sono
pronti; prima della consegna devono essere inserite soltanto le matricole e la
data. Nessun merge è stato eseguito.

---

## 2026-09-01 — Refactoring strutturale e didattico

**Tipo:** MATLAB / Controllo robusto / Documentazione / Test

### Attività

- Studiati gli esempi didattici Salaris pertinenti prima delle modifiche.
- Creata la macrofase eseguibile M0–M5 e riscritte le spiegazioni di
  attuatori, incertezze, pesi e LQG.
- Unificato M4 con range meccanici ±10% e famiglia attuatore ±10/±10/±20%.
- Rimossi selettori, screening, griglie, ranking e artifact obsoleti M3–M7.
- Conservati invariati M5, M6, Khinf e Kmu; M13 ha ricaricato l'artefatto
  approvato senza una nuova chiamata a `musyn`.
- Rieseguite M12, M14, M16 e M17: A5 RS `FAIL_CERTIFIED`, Kmu RS
  `PASS_CERTIFIED`, Kmu RP `FAIL_CERTIFIED`, Monte Carlo 39/40, 40/40,
  40/40.
- Aggiornati report, presentazione, documenti tecnici e test verso il
  comportamento matematico pubblico.

### Stato

Implementazione tecnica e propagazione concluse; quality gate completo,
build PDF e ispezione visiva in esecuzione.

---

## 2026-09-01 — Chiusura del refactoring strutturale e didattico

**Tipo:** Test / Pipeline / Documentazione / Consegna

### Risultati

- Suite MATLAB completa: **590/590 PASS**, nessun test fallito o incompleto.
- `run_all` M0–M18: **PASS** con exit code 0; M13 ha ricaricato l'artifact
  congelato senza nuova `musyn`.
- Code Analyzer: **38 file MATLAB, zero segnalazioni**.
- `git diff --check` e audit dei termini obsoleti nel tree corrente: **PASS**.
- Relazione compilata in **41 pagine** e presentazione in **17 slide**;
  audit LaTeX e ispezione visiva entrambi **PASS**.
- Prodotti il report finale A–P e il resoconto TXT trasferibile.

### Stato

**Refactoring COMPLETE.** Restano da inserire manualmente soltanto matricole
e data di consegna. Il ramo non è stato committato, pubblicato o mergiato
automaticamente.

## 2026-09-08/09 — Revisione tecnica Q/R, Kalman e Lyapunov nominale

**Tipo:** Ricognizione / Metodologia / Codice / Test / Documenti

È stata verificata la baseline remota dopo l'integrazione della PR 26: main ec93ddfe5e926f02c0373e7cee86236c3460f2eb. Il lavoro è stato separato sul ramo codex/lyapunov-technical-coherence-review. Sono stati confrontati codice, requisiti e richieste precedenti con la traccia e con gli esercizi LQG, mixed sensitivity, incertezza e mu-analysis del docente. Non è stato scritto sul Drive di riferimento né su main.

Sono stati riscritti i due script didattici, esposti i calcoli Q/R e Kalman, aggiunta sensibilità a rumore identico e implementata la verifica Lyapunov aumentata per tre controllori. Il limite analitico deriva dalle equazioni SEA, non dall'interpolazione dei punti simulati. Sono stati eseguiti 8192 punti indipendenti per controllore e 48 traiettorie ulteriori.

### Problemi incontrati e correzioni

- Nell'esportazione delle matrici LaTeX, la concatenazione iniziale fra char e string produceva dimensioni incompatibili; è stata resa esplicitamente string.
- Un backslash del testo LaTeX veniva interpretato come escape da fprintf; corretto l'escaping e rigenerate le tabelle.
- La prima compilazione rilevava una riga fuori margine nel collegamento fra qs e il codice; corretta l'impaginazione. La procedura ora classifica gli overfull come FAIL invece di registrare PASS con un conteggio non nullo.
- La prima regressione completa ha superato 644/644 test. Il successivo Code Analyzer su 172 file ha però arrestato il comando con tre segnalazioni: blocco hinfsyn volutamente irraggiungibile, concatenazione incrementale delle direzioni e assegnazione inutilizzata. Il comando di sintesi è stato reso un esempio commentato e protetto dal congelamento; le altre due istruzioni sono state semplificate senza cambiare i calcoli.
- Piccoli incrementi positivi di V, dell'ordine di 1e-22 rispetto al valore iniziale, compaiono quando LQG raggiunge il roundoff. Sono registrati, non eliminati; le verifiche distinguono questa tolleranza numerica dalla prova analitica.

### Verifiche già concluse

- Test mirati: 50/50 PASS; prima suite completa: 644/644 PASS, nessun incompleto.
- M5 e matrici Q/R/K/L M6 confrontate con l'artifact estratto dalla baseline Git: identità verificata.
- Script didattici LQG e H-infinity eseguiti; nessuna nuova sintesi H-infinity o musyn.
- Nuova esecuzione di Lyapunov e di entrambi gli script dopo la correzione statica: PASS; Code Analyzer 172 file, 0 segnalazioni.
- Figure documentali rigenerate con sfondo bianco e testi/assi neri.
- Prima correzione PDF: 63 pagine e 19 slide, audit LaTeX senza errori né overfull.
- Ispezione delle 63 pagine e 19 slide; accorciato un titolo M14 per evitare taglio nel rendering.

La verifica conclusiva successiva alle ultime correzioni tipografiche viene registrata in una voce separata. run_all resta NOT RUN in questa revisione per preservare le sintesi congelate. Le vecchie voci non sono riscritte retroattivamente.

## 2026-09-09 — Verifica conclusiva della revisione tecnica

L'ultima ripetizione intermedia della suite ha prodotto 631 PASS e 13 failed/incomplete: l'esportatore PNG non riusciva ad aprire m6_lqr_selected_weights.png durante il setup M6. Il file è stato poi verificato come accessibile in modalità esclusiva. Non è stata attribuita una causa specifica non dimostrata e non sono stati modificati pesi o criteri per aggirare l'errore. L'esito completo è conservato in results/data/revision_test_results_io_failure.csv e .mat.

La successiva esecuzione isolata, senza operazioni concorrenti sulle figure, ha superato **644/644 test**, 0 failed e 0 incomplete, in 68.4859 s di tempo test. Il confronto con la baseline conferma M5 e le matrici Q/R/K/L M6 invariati. Gli artifact M10, M13, M14 e M16 sono identici byte per byte a quelli della baseline ec93ddf.

Code Analyzer: **172 file, 0 segnalazioni**. Gli script didattici e la ricerca Lyapunov sono stati rieseguiti dopo le correzioni. Il calcolo rimane nominale e conservativo; il livello numerico campionato non è certificato.

Sono consegnati la relazione di **63 pagine**, la presentazione di **19 slide** con stima **19:00**, gli audit LaTeX, i risultati per test e il resoconto A–K in Markdown/TXT. Il controllo visivo completo è stato seguito da un'ispezione mirata delle ultime modifiche. Gli overfull e i riferimenti irrisolti sono assenti.

**COMPLETE come revisione tecnica locale.** Nessuna nuova sintesi robusta, musyn, retuning, riduzione o modifica di main. run_all è NOT RUN deliberato per evitare M9–M11. La pubblicazione del nuovo ramo non è stata eseguita. Restano le matricole e la data di consegna da compilare manualmente.

## 2026-09-09 — Sincronizzazione finale degli asset e chiusura locale

La verifica M18 successiva alla suite completa ha superato **60/60 test**, 0 failed e 0 incomplete, in 11.0632 s. Ha ricopiato le figure sorgenti rigenerate dalla regressione nelle cartelle documentali. Il confronto SHA-256 finale conferma identità per tutti i **24 asset della relazione** e i **10 asset selezionati nelle slide**. Entrambi i PDF sono stati ricompilati dopo questa sincronizzazione: 63 pagine e 19 slide, audit PASS con tutti i conteggi di errore a zero. Non sono stati rieseguiti i generatori MATLAB dopo la compilazione finale.

Il resoconto A–K in Markdown/TXT e lo stato del progetto riportano questi controlli. La chiusura Git riguarda soltanto il ramo locale di revisione; nessun push, nuova PR o merge.

## 2026-09-09 — Pubblicazione richiesta e adeguamento Git LFS

È stato richiesto l'allineamento del repository GitHub con la revisione locale.
Il primo push del commit c3dc9be è stato rifiutato prima della creazione del
branch remoto: results/data/lyapunov_trajectories.mat pesa 260319104 byte e
supera il limite GitHub di 100 MiB. Nessun dato è stato rimosso o ricalcolato.

Si conserva integralmente il MAT mediante Git LFS, limitando la regola a
questo singolo file. SHA-256 dei dati:
aae30fedb3d863b434649d184aee60d4822c22c5bbdc28c1a7baef6a4c203099.
Il commit non ancora pubblicato viene adeguato per sostituire il blob Git
oversize con il puntatore LFS; non vengono riscritti commit remoti o usato
force push. README e stato riportano i requisiti di download. Le verifiche
MATLAB già concluse restano valide: sorgenti, dati, figure e PDF non cambiano.
Il completamento del push richiede la verifica dell'identità degli SHA locale
e remoto; main resta escluso dalla pubblicazione.

## 2026-09-10 — Revisione mirata §7.6 / H-infinity: analisi e calcoli

Ricognizione Git eseguita prima delle modifiche: status, diff, diff dei
capitoli 7/8 e log; working tree pulito. Backup diff vuoto conservato in
C:/tmp/pre_codex_manual_report_changes.patch. Creato il ramo
codex/lqi-hinf-targeted-review da origin/main dopo PR 27, senza commit.
Il gruppo conferma che le ulteriori modifiche di Valerio non sono pubblicate
e limita inizialmente i controlli ai test esistenti; successivamente consente
nuovi test solo se indispensabili. Non è necessario aggiungere file di test.

Eseguito il confronto LQI con stato vero e wi=1, rhoU=8, due coppie da 0.5 N m,
riferimento nullo, condizioni iniziali nulle e orizzonte 8 s. LQG conserva
offset; LQI ha guadagno DC nullo e residuo massimo a 8 s 8.7316e-5 rad.
Verificati CARE, guadagni e ranghi; suite specifica M7 7/7 PASS.
Il setup M7 rigenera due MAT e una figura storica con gli stessi risultati.

L'audit originale H-infinity distingue scaling delle coordinate e modifica
del requisito W2. Un limite necessario puntuale supera 1 (circa 1.645),
quindi i pesi originali non possono soddisfare gamma<1. Eseguite 13 nuove
sintesi mixsyn, una hinfsyn equivalente e un diagnostico solo-comando:
15 in totale, nessuna musyn. Gamma minimo 2.8056; nessun candidato conforme.
ID 10 illustrativo: gamma 4.0730, overshoot 144.44%, peak control 15.686 N m,
stabile su 2/5 campioni M4. Baseline M10 stabile su 5/5 degli stessi campioni.
Archiviate anche le cinque piante, i poli dominanti e seed 20260910.

M9–M16 non vengono aggiornati perché la nuova configurazione non è adottata.
Esportati sei grafici e due file tabellari dalle cache; M18 censisce i nuovi
artefatti. Prima compilazione della relazione: 72 pagine, audit LaTeX PASS,
nessun overfull o riferimento irrisolto. La presentazione non è ricompilata.

Correzioni diagnostiche: un avviso Code Analyzer di impaginazione nel nuovo
script è stato eliminato; il primo comando di verifica isolata della sezione
H-infinity cercava il campo inesistente Gq nel MAT M3. Il comando è stato
corretto costruendo G dalle matrici Afull/Bfull/CfullQ effettive; non si tratta
di una nuova sintesi né di una riesecuzione della suite globale.

### Chiusura e verifiche del 10 settembre

La suite globale è stata eseguita una sola volta in una copia locale isolata
con 188 file MATLAB identici al working tree, LFS completo e tutti gli
artefatti presenti. Esito: 644/644 PASS, zero failed/incomplete, 279.107 s.
I test storici rigenerano M3/M5/M6/M7 nella copia, non nella consegna.
Esiti per test conservati in lqi_hinf_revision_verification.mat/.csv.

Code Analyzer: 172 file di progetto, zero segnalazioni. Dopo la suite sono
state rifinite soltanto caption/float e tacche del grafico dei pesi;
l'esportatore è stato rieseguito dalla cache con verifica statica, senza
nuove sintesi. La relazione finale conta 71 pagine: audit LaTeX PASS.
Il controllo visivo comprende tutte le pagine e dettagli dei nuovi grafici.
Il manifest occupa una pagina dedicata; l'audit intercetta anche gli
"ignored error". Conservati gli spazi delle sezioni protette e le normali
pagine parziali di chiusura capitolo, senza compressione globale.

I quattro artefatti M7 rigenerati nel test iniziale sono stati ricopiati
dalla baseline dopo aver verificato identità dei payload MAT e dei pixel:
eliminate esclusivamente variazioni di intestazione/metadati. Baseline M5,
M6 e M9–M16, cartella presentation e capitolo Lyapunov sono identici a HEAD.
Il prefisso §7.1–7.5 è identico alla copia iniziale (solo CRLF/LF normalizzati
nel confronto). Nessuna modifica manuale di Valerio non ancora pubblicata
può essere dichiarata integrata.

Il ramo resta codex/lqi-hinf-targeted-review con HEAD a 4ce6ad191ffcbf664d8fa0d4e82c81540ae52c46.
Non sono stati creati commit, eseguiti push o aperte PR. Main non è modificato.

## 2026-09-10 — Pubblicazione richiesta della revisione mirata

Il gruppo richiede successivamente l'allineamento GitHub e l'apertura
della PR per le modifiche già apportate. La nuova autorizzazione è
registrata in D-0049; la precedente chiusura senza pubblicazione resta
documentata sopra come stato storico.

Verificati 52 file modificati o aggiunti sul branch
`codex/lqi-hinf-targeted-review`, nessuna eliminazione e
`git diff --check` PASS. Dopo fetch, HEAD e origin/main coincidono ancora
con 4ce6ad191ffcbf664d8fa0d4e82c81540ae52c46; il branch remoto e una PR
corrispondente non risultano presenti. Riletti gli esiti salvati:
644/644 PASS e audit LaTeX PASS, relazione di 71 pagine.

La pubblicazione prevista comprende un commit, push del solo branch
dedicato e PR aperta verso main per revisione manuale. Non vengono
rieseguiti test, sintesi o simulazioni; logica del codice e artefatti
validati restano invariati. Il controllo del diff staged, esteso ai nuovi
file, rileva una riga vuota finale in `analysis/progetto_lqi.m`: viene
rimossa esclusivamente questa riga per superare il controllo whitespace.
Main e la cronologia pubblicata sono preservati.

## 2026-09-14 — Revisione mirata LQRI e peso R diretto

La PR 28 risulta integrata in origin/main (7abc2ad). Il working tree
iniziale è pulito e non presenta ulteriori modifiche manuali al LaTeX.
Creato codex/lqri-direct-r-review dalla baseline remota corrente.
Il Capitolo 7 è letto nella versione corrente e conservato in una copia
temporanea per il confronto delle sezioni protette.

Individuate le dipendenze M6/M7, i test e i generatori M18; nessuna
revisione generale del repository. Il costo R è parametrizzato da ru,
con matrici equivalenti. LQRI riusa Q/L/Qn/Rn M6 e integra r-q_measured,
senza prefiltro; sono costruite le chiusure a 30 stati e la trasformazione
di separazione. Le tre prove wi usano tutte R=(1/9)I2.

Prima verifica M7: tutti i punti stabili, reiezione DC verificata,
nessun punto conforme al settling M5. wi=1: Ts=4.996 s, polo dominante
circa -0.830657 s^-1, residuo relativo CARE 4.56824e-13. Il dato negativo
non viene corretto mediante tuning. Al termine di 8 s il residuo di
disturbo massimo è 1.58277e-4 rad, distinto dal limite DC numericamente nullo.

Rimossi dal flusso attivo gli script della precedente architettura,
il prefiltro M7, la tabella e quattro copie dei due grafici obsoleti.
I grafici rimossi sono recuperabili dalla storia Git e da una copia
temporanea locale. Il generatore misto precedente è separato: la parte
H-infinity resta un esportatore da cache, senza modifiche a pesi o risultati.

La revisione dei test adotta controlli indipendenti di equazioni fisiche,
Riccati, selezione encoder, equilibrio, separazione e risposta tramite expm.
Avviata la verifica run_all circoscritta; gli esiti conclusivi saranno
registrati separatamente dalle validazioni storiche.

### Diagnostica dei primi test

Prima esecuzione circoscritta: 102/106 PASS, quattro verifiche fallite.
Tre riguardano la tolleranza assoluta 1e-6 nel confronto dei poli ripetuti
vicino a -133.333 s^-1: scarti massimi 6.906e-6, 1.092e-6 e 5.635e-6,
condizionamento delle basi modali fino a 9.368e9. Le matrici chiuse sono
stabili e i residui spettrali normalizzati sono inferiori a 2.77e-17.
Il test adotta quindi il residuo normalizzato della matrice caratteristica,
mantenendo la verifica della similarità e di tutti i 30 poli naturali.
Non vengono cambiati guadagni, pesi o matrici chiuse.

La quarta verifica cerca una frase del refactoring precedente nello stato
progetto: viene aggiornata al nome della revisione corrente, conservando
i controlli relativi a M4/M14 e Monte Carlo. Gli esiti iniziali completi
restano in results/data/lqri_r_initial_verification.csv.

### Chiusura delle verifiche e preparazione della pubblicazione

Il percorso `run_all` con `CR_RUN_SCOPE=lqri` termina con 106/106 PASS,
zero failed/incomplete; durata complessiva dei soli test 15.62176 s.
Gli esiti sono conservati in `lqri_r_verification.mat/.csv`. Il percorso
globale M0-M18 resta NOT RUN nella revisione corrente: nessuna nuova
esecuzione H-infinity, musyn, mu-analysis, Monte Carlo, non lineare o RAS.
Anche `analysis/progetto_lqri.m` viene eseguito con PASS, riusando la cache.
Il controllo finale Code Analyzer esamina 172 file senza segnalazioni.

Il confronto con la copia M6 iniziale restituisce differenze massime
nulle per K, Q e R e identita' esatta di L, Qn e Rn. Restano LQR30 e
9/36 candidati ammissibili. I 15 PNG M6 rigenerati hanno pixel identici
alla baseline; sono conservati i file originali, senza differenze di
soli metadati in relazione e presentazione. H-infinity, mu, Monte Carlo,
validazione non lineare e RAS mantengono dati e codice congelati.
Il solo commento iniziale della tabella H-infinity viene allineato al
nome dell'esportatore separato; i suoi valori sono invariati.

La relazione compila con `-ReportOnly`: 72 pagine, audit PASS, zero
errori, riferimenti irrisolti, overfull o destinazioni duplicate.
Controllate visivamente tutte le pagine e singolarmente quelle modificate;
corretto localmente un paragrafo interrotto dalle tabelle, intervenendo
sull'esportatore e rigenerando il solo confronto M7 e il PDF. Nessuna
modifica numerica deriva dalla correzione di impaginazione.
Preservato il testo iniziale delle sezioni 7.1, 7.2.1-7.2.3 e 7.3-7.5,
normalizzando soltanto CRLF/LF nel confronto. Presentazione invariata.

Creato `docs/RESOCONTO_REVISIONE_LQRI_R.txt` con i sedici punti richiesti,
matrici complete, inventario dei file, esiti positivi e negativi.
M7 resta PARTIAL: Ts=4.996 s per wi=1 contro target 0.8 s; l'errore DC
nullo non viene confuso con il residuo finito a 8 s.

Il fetch conclusivo conferma origin/main alla baseline
7abc2ad84fe2b3fc9e89e1459bd054932c2f2bab; non risultano PR preesistenti
per `codex/lqri-direct-r-review`. La pubblicazione autorizzata prevede
commit coerente, push del solo branch e PR aperta verso main. Nessun
merge automatico, force push o modifica diretta al branch principale.

## 2026-09-16 — Pesi diretti e rigenerazione delle dipendenze

Responsabile: Alessio. Branch: codex/direct-weights-hinf-lqr-lqri.
Baseline: aae96148353506b8ba119de65f6dcf3103eec328 (PR 29).

La ricognizione iniziale ha rilevato working tree pulito; il diff dei tre
capitoli interessati è stato salvato prima degli interventi. M0–M4 e le
parti non dipendenti della relazione sono preservati. Le modifiche manuali
non sono ricostruite da versioni storiche.

Fase B: M6 realmente ricalcolata su 36 costi, 9 ammissibili, R=0.10 I2
selezionata; Q e Kalman identici alla baseline. M7 con Qi diretto 20/200/800:
tutte le chiusure a 30 stati stabili, nessun candidato conforme. Verifica
mirata M6/M7: 36/36 PASS, distinta dalla verifica globale ancora da eseguire.

Fasi C/D: 8 casi W1 e 4 W2; tutti FAIL con criteri invariati. M5 usa i nuovi
pesi fisici, senza normalizzazione della pianta; M9/M10 eseguite una volta
(gamma=5.677221), M11 conserva 30 avvii (15 stabili, A5=5.708569).
W3 rimane fisso nello studio e assente in produzione. Diagramma Lower LFT
M10 generato; pesi spostati da §§6.3–6.5 al §8.2.

Fase E: M12/M13/M14 realmente dipendenti rigenerate; una sola nuova musyn,
Kmu ordine 70, migliore iterazione 5. M14 RS FAIL_CERTIFIED con margine
[0.774041952377,0.775696806012], NP/RP negativi. Il controllo wcgain è stato
corretto: wcu realizza il lower bound, mentre upper bound infinito non
dimostra da solo l'instabilità di tale sostituzione. Fonte primaria:
https://www.mathworks.com/help/robust/ref/dynamicsystem.wcgain.html
Le soglie di confronto restano invariate.

M8 rigenerata con PASS software. Primo tentativo M15 interrotto dal limite
RAS di 400 chiamate, prima di produrre un nuovo artifact finale: il fallimento
è conservato nel log di esecuzione. Il limite ora deriva dal massimo della
stessa ricerca (626), senza cambiare convergenza, precisione o orizzonti.
Un checkpoint con identità delle sorgenti salva i punti completati.
M15/M16/M17 e Lyapunov sono in completamento; suite globale e PDF finali
non ancora dichiarati validati. Nessuna sintesi già completata è ripetuta
per questa correzione. Presentazione aggiornata soltanto nei passaggi
dipendenti; restano 19 slide e lo stesso impianto grafico.

## 2026-09-16 — Chiusura della revisione dei pesi diretti

Completate le sole dipendenze: M15 software PASS, tracking FAIL; M16
37/40 stabili per M6 e 40/40 per Khinf/Kmu. I campioni 5,6,35 M6 restano
nel dataset. M17 non assegna un controllore robusto finale perché M14
fallisce RS; le percentuali Monte Carlo non modificano tale conclusione.
Rigenerate le regioni nominali Lyapunov e le 48 traiettorie.

Unica suite globale: 658/660 PASS, zero incomplete, 297.697682 s.
Fallimenti: testT02SelectedArchitectureIsA5 attendeva l'avvio storico 5
anziché il nuovo 4; testT28M6SampleFivePreserved attendeva solo 5,6,
omettendo il nuovo campione instabile 35. Aggiornate soltanto queste
aspettative dipendenti dai dati: riesecuzione mirata 2/2 PASS.
Conservati separatamente i risultati iniziali e la verifica correttiva.
Nessuna soglia modificata e nessuna seconda suite globale.
Code Analyzer conclusivo: 177 file, zero segnalazioni.

La revisione visiva dei PDF ha motivato solo correzioni locali dei float
dipendenti e del paragrafo conclusivo M14: relazione 70 pagine e
presentazione 19 slide, audit PASS senza riferimenti irrisolti o overfull.
Rimosse dal diff le rigenerazioni M3 della suite: MAT identico escluso
l'header temporale e PNG con pixel identici alla baseline. Nessun dato
manuale eliminato. M0–M4 rimangono invariati.

Resoconto autosufficiente in RESOCONTO_REVISIONE_PESI_HINF_LQR_LQRI.txt.
Pubblicazione del solo branch dedicato, con PR aperta per revisione:
nessun merge automatico o aggiornamento diretto di main.

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

Audit, conservazione dei modelli Valerio e correzione su base889c0eb. Risolti incompatibilità di versione, libreria LTI e bus esterni, disturbo motore errato, rumore scalare, integratore ideale e interfaccia Hinf obsoleta.67/67 controlli+7/7 test PASS realmente eseguiti. Aggiornati PDF e resoconto. Nessuna sintesi costosa ripetuta; limiti e fallimenti preservati.


### Chiusura del pacchetto Simulink

Normalizzati spazi finali e caratteri di formattazione del log; aggiornati hash. Nessuna modifica numerica. PDF verificati:57pagine e24slide, nessun riferimento mancante o contenuto fuori margine.

## 2026-09-23 — Chiusura dei tre punti di revisione PR #33

Realizzato un solo diagramma M3 lineare comune ai quattro controllori, senza
modificare i quattro modelli non lineari esistenti. Eseguiti 32 confronti
lineare Simulink/MATLAB e non lineare/lineare: PASS. Usate per il secondo
confronto le tracce non lineari già validate, senza duplicarne il calcolo.
Eseguita RAS LQRI nominale con algoritmo e criteri M8 invariati: 57/57 punti
convergenti in 8 s, zero estensioni, zero errori, box ±60° raggiunto.
Verificata l'identità K/L/Nr della RAS LQG storica con gli artifact correnti.
La prima esecuzione della suite ha fallito quattro verifiche dimensionali:
linmod con un output restituiva una struttura. La chiamata nel test è stata
corretta a quattro output, senza cambiare progetto o soglie. Run iniziale
conservato in unit_tests_initial_failure.mat/.csv. Run finale: 22/22 PASS
(7 originari + 15 nuovi). I 67 controlli precedenti non sono rilanciati;
evidenza e modelli originali restano invariati.
Documenti aggiornati dopo il calcolo: relazione, resoconto TXT/MD e
presentazione di 20 slide con scaletta 17:55, non durata orale misurata.
Stato implementativo COMPLETE; conformità M5/M7 e risultati robusti invariati.
Nessuna sintesi, riduzione, Monte Carlo o mu-analysis. PR mantenuta draft.


## 29 settembre 2026 — Revisione organica e consegna degli originali

Richiesta del 28 settembre: usare esclusivamente gli originali del gruppo, senza costruire o completare automaticamente diagrammi. La decisione sostituisce il precedente percorso d'integrazione; le voci anteriori restano cronologia e non descrivono la consegna attuale.

Analisi preliminare di repository, traccia, artifact e materiale dei colleghi. Capitoli 1–7 conservati nei contenuti, salvo due correzioni verificate nel Capitolo 3 e rimandi/stile. Riscritti Capitoli 8–9, aggiunti schemi LFT, prestazione e D–K, grafici da dati salvati. Presentazione 19 slide, 17:15.

Backup completo esterno verificato prima delle rimozioni; conservate copie esatte del working tree. Tre originali spostati senza modifica dei byte in simulink/originals; rimossi generatori, diagrammi e dipendenze esclusivi dalla consegna. Inventario e hash in docs/organic_review.

104/104 test MATLAB PASS, 8 nuovi. Due suite riscrivono internamente m3/m5: isequaln con il baseline PASS, byte ripristinati e protezione aggiunta al runner. Audit originali: tre FAIL di caricamento per R2026a su R2025b; zero simulazioni accreditate. Errori preparatori nell'audit (nome del MAT e accumulatore di strutture/codice MATLAB in cache) corretti prima dell'esportazione, senza modificare risultati. Nessuna nuova sintesi, mu-analysis, Monte Carlo o RAS.

Relazione e presentazione compilate e verificate graficamente; rimossi gli overflow delle prime bozze. Controllori e artifact numerici consolidati invariati. Conformità complessiva PARTIAL: completamento e validazione degli originali richiedono intervento manuale. PR #33 rimane draft, nessun merge.

Verifica finale aggiuntiva: corretto il callback onCleanup con cattura esplicita dei valori; test di interruzione su file temporanei PASS. Totale aggiornato: 105/105 test, 9 nuovi. Aggiunte tabelle dei candidati strutturati e del disturbo dai dati salvati.

## 2026-10-02 — Semplificazione H-infinity/mu e appendice MATLAB

Richiesta: intervenire direttamente sul repository fino a commit e push,
preservando risultati e metodo. Analizzati inventario, traccia, decisioni,
LaTeX, MATLAB, dati e figure. Consultato soltanto il PDF Drive pertinente
in sola lettura. Checkout iniziale pulito; fetch e nuova branch
codex/semplificazione-hinf-mu-appendice da origin/main 8ca8e7e, che include
la PR #33. Il repository vuoto nel percorso OneDrive non è stato usato.

Riscritti capitoli 8–9; aggiunti schemi pianta generalizzata a due pannelli
e N-Delta, tre tabelle dai JSON salvati e appendice D (27 estratti letterali,
210 righe MATLAB). Distinti problemi 1-/2-DoF, segno Ky, fonti correnti/storiche,
120 attuatori/40 impianti, gamma/RS/RP. Conservati esiti negativi, intervallo
RP invertito non validato, rumore, RAS e limiti Simulink. Nessuna modifica
ai capitoli 1–7, alla presentazione o ai file scientifici.

Verifica MATLAB R2025b: hinfFinalCoherenceTest 6/6, hinfFinalDownstreamTest
5/5, organicReviewTest 9/9; totale 20/20 PASS. Sottoinsieme dei 105 precedenti,
nessuna suite globale nuova. Incluse due piccole prove non lineari locali;
nessuna sintesi, ricerca robusta, campagna Monte Carlo o RAS rilanciata.
CSV e manifest in docs/didactic_review. Nessun test aggiunto.

Prima bozza LaTeX fallita per path in didascalia; corretta prima della build
finale. Migliorati schema N-Delta e impaginazione dei listati dopo controllo
visivo. tools/build_m18_latex.ps1 -ReportOnly: tre passaggi pdflatex, 74 pagine,
zero errori/riferimenti irrisolti/overfull/destinazioni duplicate; nessun
warning LaTeX finale. Resta il messaggio launcher Perl sulla locale C.UTF-8,
con fallback Windows italiano. Controllati visivamente PDF 3–7, 38–56, 67–74.
Verifica delle 24 domande di leggibilità e integrità Git scientifica PASS.

Resoconto completo in docs/RESOCONTO_SEMPLIFICAZIONE_HINF_MU_APPENDICE.md.
README, changelog, decisioni e stato aggiornati prima del commit.
Quality gate editoriale PASS/COMPLETE; conformità globale PARTIAL invariata.
Pubblicazione richiesta sul solo branch dedicato; nessun merge su main,
force push, eliminazione di branch o modifica dei riferimenti esterni.

## 2026-10-06 — Revisione coerente LQGI, H-infinity e mu

Analisi preliminare completa del repository (692 file, 172 sorgenti MATLAB), traccia ufficiale, pipeline, dati salvati e riferimento Drive in sola lettura. Consultati report, 13 script e inventari di 11 MAT dei colleghi; nessun risultato importato. Ritrovati e acquisiti byte per byte tre originali lineari del gruppo. Branch codex/revisione-lqgi-hinf-mu da origin/main 283193e, con PR #34 integrata.

La MATLAB M7 usava già lo stato stimato: la correzione principale riguarda nomenclatura e coerenza delle fonti, non sostituzione con un altro controllore. Nomi attivi LQGI, Kalman M6 e tre coppie di guadagni M7 verificate identiche al baseline. Nuovo simulatore non lineare a 30 stati con integratore sull'errore misurato, quattro encoder e quattro rumori di processo; 6 tracking, 6 disturbi, equilibrio, 3 prove di rumore e ripetizione. RAS: 57/57 punti, box esaurito, picco 240.2349 N m senza saturazioni.

Il confronto iniziale rumoroso con la chiusura lineare ha mostrato discrepanze fino a 0.0071 rad. Corretto il rispetto delle discontinuità ZOH separando gli intervalli di integrazione e usando il hold lineare esatto; ricalcolati i casi e invalidato il checkpoint mediante hash del simulatore. Differenza finale massima 4.6870e-5 rad. Non sono stati modificati guadagni o covarianze per migliorare il risultato.

Mo 2/3/4 ricalcolati dai tre controllori salvati, senza sintesi. Tempi 2.918/1.944/1.460 s, norme 0.0305405/0.0312036/0.0474606: 4 scelto per minore violazione temporale, con peggioramenti espliciti su altri indicatori. Capitoli 7–10 e conclusioni aggiornati; 8.2 spostata dopo il paragrafo richiesto del §8.6.1, figure 8.4/8.6 ridisegnate, Tabella 8.4 riordinata. Capitolo 9 chiarisce mu strutturata, H=N11, robstab e robgain. Slide 6–9, 12, 15–19 aggiornate; 19 slide, 17:45.

112/112 test MATLAB PASS, sette nuovi. Dieci sorgenti LQGI senza segnalazioni Code Analyzer; baseline con due warning preesistenti di crescita array nei vecchi esportatori/RAS. Audit di 85 artifact protetti PASS, incluse fonti robuste e tre originali precedenti. Sei hash SLX PASS; sei load_system FAIL per R2026a su R2025b, simulazioni NOT RUN. Istruzioni manuali puntuali con SID: nessun diagramma sostitutivo, nessuna rinomina definitiva degli originali.

Prima build delle slide interrotta perché la figura dedicata era ancora in esportazione; ricompilata dopo il completamento. Un'etichetta dello schema LQGI sovrapposta ai blocchi è stata rimossa dopo il rendering. Build finali: relazione 83 pagine, presentazione 19; zero errori, riferimenti irrisolti, overflow o destinazioni duplicate. Resta il warning di locale del launcher Perl con fallback Windows, estraneo al documento. Nuovi numeri soltanto da esecuzioni reali; nessuna nuova sintesi robusta o Monte Carlo.

README, changelog, decisioni, stato e resoconto aggiornati prima del commit. Gate scientifico/editoriale PASS/COMPLETE; conformità complessiva PARTIAL per Simulink e requisiti prestazionali. Pubblicazione sul ramo dedicato, senza merge o force push.
