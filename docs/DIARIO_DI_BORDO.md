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
