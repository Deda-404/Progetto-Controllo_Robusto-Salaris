# Diario di bordo

Il diario è append-only. Le nuove attività aggiungono voci senza cancellare o riscrivere quelle precedenti.

## 2026-08-24 12:07 — Inizializzazione M0 del progetto

**Autore:** Codex
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

**Autore:** Codex
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

**Autore:** Codex
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

**Autore:** Codex
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

**Autore:** Codex
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

**Autore:** Codex
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

**Autore:** Codex
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

**Autore:** Codex
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

**Autore:** Codex
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

**Autore:** Codex
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

**Autore:** Codex
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

**Autore:** Codex
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

**Autore:** Codex
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
