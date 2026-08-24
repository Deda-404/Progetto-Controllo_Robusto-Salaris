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
