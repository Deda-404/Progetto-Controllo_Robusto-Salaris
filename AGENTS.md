# AGENTS.md

Queste regole sono permanenti e si applicano a ogni attività nel repository.

## Autorità delle fonti

1. La traccia ufficiale del docente è la fonte primaria e vincolante.
2. Seguono le decisioni approvate e registrate nel repository.
3. Equazioni e risultati prodotti dal nostro codice prevalgono sui riferimenti esterni.
4. Il progetto dei colleghi sul Google Drive è un riferimento tecnico in sola lettura.
5. La relazione dei colleghi è un riferimento metodologico, non la nostra soluzione.
6. La conoscenza generale può integrare, ma non contraddire, la traccia.

## Ambienti e integrità accademica

- Google Drive è **reference only**: non creare, modificare, rinominare, spostare o cancellare file sul Drive.
- Il repository GitHub `Deda-404/Progetto_CR` è la **source of truth** e l'unica area di lavoro del progetto.
- Studiare il progetto precedente senza copiarne automaticamente testo, codice, controllori, grafici, numeri o conclusioni.
- Le scelte del gruppo precedente restano proposte finché non vengono comprese, riprodotte, motivate e approvate.
- Non inventare mai risultati numerici, matrici, poli, \(\gamma\), \(\mu\), margini, RAS, metriche temporali, Monte Carlo o output Simulink.
- Un risultato può essere dichiarato validato soltanto se deriva da codice realmente eseguito o da un calcolo analitico implementato e verificabile.
- Se MATLAB, Simulink o un toolbox non sono disponibili, marcare il relativo lavoro `NON VALIDATO`.

## Independent reconstruction rule

- Il progetto di riferimento serve esclusivamente a comprendere metodologia, completezza e criticità; non costituisce la base diretta delle nuove implementazioni.
- Derivare ogni nuova componente prioritariamente dalla traccia ufficiale, progettandone autonomamente formule, API, struttura software e test.
- Non copiare né parafrasare direttamente codice, commenti, struttura interna delle funzioni, testo, grafici, dataset o risultati del riferimento.
- Consultare preferibilmente il riferimento soltanto dopo avere progettato, implementato e testato una prima versione indipendente.
- Usare il confronto successivo per controllare completezza e convenzioni, documentando le differenze senza modificare il nostro lavoro al solo scopo di farlo assomigliare al riferimento.

## Sviluppo e riproducibilità

- MATLAB e Simulink sono gli ambienti tecnici principali.
- Centralizzare parametri fisici, attuatori, incertezze, specifiche, limiti e seed; evitare costanti duplicate.
- La pipeline deve convergere verso un `run_all.m` deterministico che rigeneri parametri, modelli, controllori, analisi, dati, tabelle e figure.
- Usare seed casuali espliciti per Monte Carlo e altre procedure stocastiche.
- Non dipendere da variabili lasciate nel MATLAB Workspace.
- La relazione segue sempre la catena `codice -> dati -> figure/tabelle -> relazione`.
- Non inserire in relazione numeri privi di uno script o file dati di origine.
- Non modificare silenziosamente specifiche, pesi, incertezze, equilibrio, limiti o architetture di controllo.

## Test e quality gate

- Ogni fase critica richiede test proporzionati: dimensioni, proprietà fisiche, equilibrio, Jacobiani, stabilità, controllabilità, osservabilità, prestazioni e robustezza.
- Un comando che non genera errori non è, da solo, una validazione.
- Registrare i test falliti e i risultati inattesi; non nasconderli.
- Ogni milestone termina con un quality gate `PASS / FAIL / NOT RUN` e uno stato `COMPLETE / PARTIAL / BLOCKED`.
- Non procedere automaticamente oltre un `FAIL` critico.
- Mantenere distinte Nominal Stability, Nominal Performance, Robust Stability e Robust Performance.
- Monte Carlo fornisce evidenza empirica; la \(\mu\)-analysis fornisce una garanzia rispetto al modello di incertezza.

## Documentazione obbligatoria

- Semplicita didattica prioritaria: pochi ingressi e funzioni locali; funzioni esterne solo per correttezza, riuso effettivo o leggibilita. Evitare proliferazione di file e cache.
- Il percorso corrente e `run_all.m` con gli script accorpati. I runner storici in `analysis/`, `src/`, `controllers/` restano archivio di provenienza, fuori dal percorso operativo.
- La consegna deriva dagli stessi sorgenti. Tracciabilita, seed e test reali restano obbligatori; non richiedono infrastrutture sproporzionate.

- `README.md`: scopo, struttura, prerequisiti, esecuzione e stato sintetico; non è un diario.
- `docs/DIARIO_DI_BORDO.md`: cronologia append-only di ogni attività significativa, inclusi fallimenti e verifiche.
- `CHANGELOG.md`: sintesi tecnica delle modifiche.
- `docs/DECISION_LOG.md`: decisioni, alternative, motivazioni, conseguenze e stato.
- `docs/PROJECT_STATUS.md`: milestone, ultimo risultato validato, problemi e prossimo passo.
- Aggiornare documentazione e diario prima del commit pertinente.
- Non cancellare né riscrivere retroattivamente le vecchie voci del diario; aggiungere una nuova voce quando una decisione cambia.

### Project documentation voice

- La documentazione tecnica deve essere scritta come documentazione del progetto, non come diario di uno strumento software.
- Non usare formule come “io ho fatto”, “Codex ha fatto”, “l'agente ha deciso” o “ChatGPT ha suggerito”.
- Preferire la forma impersonale o la prima persona plurale tecnica: “è stato verificato”, “abbiamo scelto”, “si è osservato”.
- Quando serve un referente personale, usare `Responsabile: Alessio`.
- Non inserire firme automatiche nei sorgenti MATLAB.
- Non inserire nomi di strumenti nei commenti del codice se non sono tecnicamente necessari.
- Eventuali obblighi formali di disclosure previsti dal corso devono comunque essere rispettati separatamente.

## Git workflow

- `main` deve rimanere ragionevolmente stabile e comprensibile.
- Per modifiche significative usare branch `codex/<milestone>-<descrizione>`.
- Creare commit piccoli e semanticamente coerenti, associabili a una voce del diario.
- Non fare force push e non riscrivere inutilmente la cronologia.
- Non commettere autosave, cache, output di code generation o file temporanei.
- File `.m`, `.mlx`, `.slx`, `.tex` e risultati finali rilevanti non vanno ignorati automaticamente.
- Prima di un commit: test, quality gate, diario, changelog e project status devono essere aggiornati.

## Processo per ogni modifica importante

1. Leggere la traccia e queste regole.
2. Controllare `docs/PROJECT_STATUS.md` e le decisioni esistenti.
3. Consultare soltanto il materiale di riferimento pertinente.
4. Migliorare il percorso esistente con codice originale, semplice e leggibile.
5. Eseguire test reali e conservare gli output necessari.
6. Documentare esiti positivi, negativi e limiti.
7. Aggiornare diario, changelog, decision log e relazione quando applicabile.
8. Creare un commit coerente.

## Approvazioni

Richiedere revisione del gruppo prima di rendere definitive modifiche sostanziali a obiettivi, punto di equilibrio, misure, incertezze, specifiche, limiti, pesi o struttura di controllo. Dopo M0 non iniziare M1 senza autorizzazione esplicita.
