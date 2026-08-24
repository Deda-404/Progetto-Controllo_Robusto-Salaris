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
