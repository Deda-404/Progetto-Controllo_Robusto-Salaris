# Audit editoriale conclusivo

## Perimetro

La revisione è stata eseguita sul ramo `codex/final-human-editorial-review`,
creato dalla baseline della PR #23, mergiata nel commit
`6486bb240cdbcf4517ed1e893d83e6b1a34168e1`.

Autori dei deliverable:

- Alessio de Dato;
- Valerio Rebechi.

Restano da completare soltanto matricole e data di consegna. La revisione non
modifica modello M4, specifiche e pesi M5, controllori M6/Khinf/Kmu, risultati
numerici o conclusioni NS/NP/RS/RP. Non sono state eseguite nuove sintesi,
retuning, riduzioni d'ordine o campagne Monte Carlo.

## Pulizia dei materiali operativi

Sono stati rimossi dal ramo corrente il resoconto operativo in radice e i
venti resoconti intermedi presenti in `docs/handoff/`. La loro storia resta
recuperabile mediante Git; nessun dato tecnico necessario alla riproduzione è
stato cancellato.

L'unica dipendenza automatica individuata era il test T20 di M7. Il test è
stato aggiornato per verificare i due registri di governance effettivamente
consegnati:

- `docs/PROJECT_STATUS.md`;
- `docs/DIARIO_DI_BORDO.md`.

Non risultano altre dipendenze di codice, pipeline, relazione, presentazione o
manifest dai resoconti rimossi.

## Audit del linguaggio operativo

Le occorrenze sono state classificate prima della rimozione:

1. **Materiale operativo non necessario:** resoconti intermedi e riferimenti
   di coordinamento nella documentazione destinata alla consegna. Rimossi.
2. **Cronologia del progetto:** vecchie voci in `CHANGELOG.md` e
   `docs/DIARIO_DI_BORDO.md`. Conservate perché documentano eventi realmente
   avvenuti e i file sono cronologici/append-only.
3. **Decisioni tecniche storiche:** formulazioni in `docs/DECISION_LOG.md` e
   nei documenti delle singole milestone. Conservate quando necessarie a
   spiegare una decisione o una dipendenza storica.
4. **Regole interne del repository:** `AGENTS.md`. Conservato perché è un
   file di governo dello sviluppo, non un deliverable accademico.
5. **Controlli automatici:** stringhe nei test che verificano l'assenza dei
   vecchi file o di termini operativi nel README. Conservate perché hanno
   funzione negativa e non compaiono nei deliverable.

README, relazione, presentazione e manifest non contengono istruzioni di
coordinamento o testi rivolti a strumenti conversazionali. Questo audit non
afferma che nel corso del progetto non siano mai stati usati strumenti di
assistenza automatica: certifica soltanto che il materiale conclusivo è stato
reso autosufficiente, tecnico e adatto alla consegna.

## Commenti MATLAB

I commenti e i messaggi utente delle fasi M17/M18 e di `run_all.m` sono stati
riscritti in termini ingegneristici: “risultati validati”, “confronto basato
sulle evidenze” e “generazione documentale”. I nomi di funzioni o campi
storici contenenti `frozen` non sono stati rinominati, perché una modifica API
avrebbe introdotto rischio tecnico senza beneficio editoriale. In tali casi
il termine descrive inoltre correttamente un risultato mantenuto invariato.

## Relazione

La relazione:

- identifica gli autori e mantiene visibili i soli dati anagrafici mancanti;
- motiva modello, equilibrio, linearizzazione, attuatori e scelta delle
  incertezze;
- esplicita la derivazione di specifiche, normalizzazioni e pesi;
- descrive separatamente LQG M6 e il risultato negativo M7;
- chiarisce generalized plant, equivalenza M9/M10 e frontiera M11;
- distingue la produzione di Kmu in M13 dalla certificazione RS in M14;
- separa validazione non lineare, RAS empirica, Monte Carlo e mu-analysis;
- conserva tracking, NP e RP falliti e l'instabilità M6 del Sample 5;
- conclude con una selezione per ruolo e non con un vincitore assoluto.

Le tabelle generate sono state uniformate in italiano. I range M4 riportano
esplicitamente ±7%, ±9%, ±8%, ±7,5% e ±20% secondo i relativi parametri. La
tabella Monte Carlo distingue “N. instabili” da “Sample ID instabile”: M6
riporta 1 e 5; Khinf/Kmu riportano 0 e “--”. La percentuale è denominata
“Frazione empirica”.

## Presentazione

La presentazione resta composta da 17 slide, con timing stimato di 17:30. La
slide M13 afferma che la D--K iteration produce Kmu e specifica che
l'objective non è un certificato. La slide successiva attribuisce
correttamente a M14 la certificazione RS. Sono stati aggiornati autori, ruoli
in italiano, note dell'oratore e transizioni.

## Validazione

La validazione conclusiva ha prodotto i seguenti esiti:

- generazione M18 e riconciliazione degli artifact: PASS;
- relazione: 45 pagine A4, 13 capitoli, 3 appendici, 15 figure e 11
  tabelle;
- presentazione: 17 slide 16:9, timing stimato 17:30;
- audit LaTeX di entrambi i PDF: zero errori, riferimenti irrisolti,
  overflow e destinazioni duplicate;
- ispezione visiva di tutte le 45 pagine e di tutte le 17 slide: nessun
  elemento tagliato, sovrapposto o illeggibile;
- test dedicati M18: 60/60 PASS;
- suite completa: 649/649 PASS;
- `run_all` M0--M18: PASS, 649/649 test interni ed exit code 0;
- Code Analyzer: 15 file controllati, zero segnalazioni;
- specifiche M5 verificate byte-per-byte rispetto alla baseline dopo il
  ripristino di un commento editoriale non ammissibile nel file congelato;
- `git diff --check`: PASS;
- audit dei termini operativi nei deliverable finali: PASS.

`run_all` ha ripetuto la campagna deterministica M16 con il seed già
congelato esclusivamente come verifica di riproducibilità. Non è stata aperta
una nuova campagna, non sono stati modificati i campioni e gli artifact
tecnici rigenerati sono stati ripristinati alla baseline. M13 ha ricaricato
il controllore congelato senza eseguire una nuova `musyn`.

Il quality gate editoriale è pertanto **COMPLETE**. Restano esclusivamente
gli input manuali indicati nel manifest e la revisione umana della pull
request; il ramo non viene mergiato automaticamente.
