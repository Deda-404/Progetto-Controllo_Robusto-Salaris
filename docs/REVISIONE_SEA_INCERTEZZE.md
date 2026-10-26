# Revisione conservativa SEA — fase A, 26.10.2026

Base: main remoto 0ed5611fdbb9c46475543f87eba68d9799b07bc5. Branch: codex/sea-incertezze-revisione-conservativa. Responsabile: Alessio. Implementazione e verifiche COMPLETE / PASS; risultati scientifici differenziati per modello. Nessuna nuova sintesi e nessuna fase B.

## Modifiche scientifiche

- La sezione opzionale 15 di File_di_Funzioni_Progetto-Accorpati/progetto_mu.m costruisce manualmente la LFT meccanica dalle porte elastiche e dall'accelerazione motore: M 5x7, Delta 3x3. L'inverso di Jm1 rimane esatto.
- Per ciascun attuatore B, M è 6x6 e Delta è diag(dw I2,dz,dT,Delta_R). La frequenza naturale è ripetuta coerentemente, il ritardo costante è parametrizzato attraverso l'equazione di Padé; il residuo dinamico ha peso analitico WR. Due attuatori più meccanica danno nove reali distinti e due dinamiche, dimensione totale 13.
- A concentra lo scarto in forma additiva attorno allo stesso nominale, con cinque blocchi totali. WA è un fattore spettrale costruito in frequenza scalata. La famiglia fisica è contenuta in B e B in A al raggio unitario; non si assume tale inclusione a ogni scala del margine.
- Il fit moltiplicativo storico è invariato. Lo zero RHP del Padé nominale rende instabile l'errore relativo normalizzato del ritardo esatto: la copertura in modulo sulla griglia non basta a dimostrare appartenenza alla palla stabile. I certificati storici rimangono circoscritti al loro insieme.

Le disuguaglianze, le porte e gli schemi sono nel capitolo 5. La correzione non sostituisce il modello storico e non allenta le specifiche. I parametri e le percentuali della costruzione manuale sono quelli congelati del progetto; modificarli richiede una nuova validazione.

## Risultati realmente calcolati

MATLAB R2026b 26.2.0.3386108, Robust Control disponibile, seed 20261026. Si eseguono robstab e robgain(CL,1), conservando strutture miste reali/dinamiche e l'interconnessione originale.

| Controllore | Modello | NS/NP | RS | RP | Esito RS/RP |
|---|---|---|---|---|---|
| Hinf22 | A | PASS | [0.00633167,0.00634435] | [0.00603461,0.00607495] | FAIL / FAIL |
| Hinf22 | B | PASS | [0.0288775,0.0289687] | non valido: [0.0189754,0.0183284] | FAIL / esclusa da RS |
| Mu78 | A | PASS | [0.608511,0.610286] | [0.607130,0.610700] | FAIL / FAIL |
| Mu78 | B | PASS | [1.265792,1.273609] | [1.264679,1.272385] | PASS / PASS |
| MuN1_82 | A | PASS | [0.683754,0.687756] | [0.638325,0.640005] | FAIL / FAIL |
| MuN1_82 | B | PASS | [1.265017,1.269991] | [1.263745,1.267751] | PASS / PASS |

Per Hinf22 e Mu78: mappa [r;d] -> [ze;zu]. Per MuN1_82: il proprio protocollo [r;d;nu] -> [ze;zu] e il suo Wn archiviato. W1, W2, Mo e controllori restano identici fra A/B. Le norme nominali sono rispettivamente 0.0474606, 0.634680, 0.673458; le bande diagonali nominali (rad/s, -3 dB sul guadagno DC) sono 2.68962/2.63652, 2.39330/2.56945, 2.32502/2.59425. Nessuna variazione significativa fra A e B.

Il FAIL su A non smentisce il PASS su B: A contiene perturbazioni ulteriori. Non è dimostrato un incremento della banda ottenibile senza risintesi. Le garanzie di B includono la famiglia fisica lineare con ritardi costanti nei range; non includono jitter arbitrario, non linearità o saturazioni. I fallimenti temporali e i limiti hardware storici restano aperti.

## Esecuzione separata

Il default dello script resta ricalcolaAnalisi=true, ricalcolaSintesi=false, confrontaIncertezze=false. Le prime quattordici sezioni sono identiche alla base, salvo l'aggiunta dei due nuovi flag.

Per eseguire il confronto, cambiare temporaneamente solo le impostazioni iniziali in progetto_mu.m:

~~~matlab
ricalcolaAnalisi=false;             % legge soltanto le analisi storiche
ricalcolaSintesi=false;
mostraFigure=false;
confrontaIncertezze=true;            % abilita la nuova sezione 15
analizzaConfrontoIncertezze=true;    % false: costruzione e controlli delle LFT
~~~

Eseguire lo script e ripristinare i flag storici prima di committare. Le nuove analisi usano checkpoint esclusivamente in results/data/sea_incertezze_conservativa. Un checkpoint è riusato soltanto se P, K, release e seed coincidono. Per un ricalcolo da zero conservare altrove questa sola cartella di confronto prima del run; nessun archivio storico deve essere spostato o sovrascritto.

I test preparano copie temporanee dello script in tmp/ e non richiedono di modificare i flag del sorgente:

~~~matlab
addpath(genpath('src'),genpath('analysis'),genpath('controllers'),'simulink');
r=runtests({'tests/test_sea_uncertainty_comparison.m', ...
    'tests/test_m4_uncertainty_model.m','tests/noiseRedesignTest.m'});
assertSuccess(r);
~~~

La classe dedicata confronta il corpo storico con il commit base tramite Git; il commit deve essere disponibile nel clone. Le analisi robuste salvate sono evidenze di esecuzioni reali; i test non avviano nuove sintesi.

## Quality gate

- PASS: 9/9 test dedicati, 9/9 regressioni M4 e 7/7 regressioni rumore. La regressione dinamica dello script confronta coefficienti, controllori, tracking e risultati archiviati con la base.
- PASS: esecuzione reale del default, robstab/robgain e mussv storici, tre figure attese e RNG ripristinato. RS Hinf circa [0.026154,0.026207]; Mu78 RS [1.79980,1.80442], RP [1.67717,1.68066]. Non sono stati riscritti i MAT di origine.
- PASS: nominale comune (scarto 1.05e-14); LFT meccanica (1.71e-14), attuative (1.44e-15), otto corner e 24 punti interni per verifica; perturbazione dinamica stabile non nulla e condivisa fra le costruzioni indipendenti.
- PASS: pesi stabili/propri, zeri ammissibili, identità spettrale (errore 1.05e-14), bound analitico del ritardo. I rapporti campionati massimi 0.8848 e 0.3383 sono evidenza numerica e non la dimostrazione della copertura continua.
- PASS: 261 archivi protetti identici (240 MAT, 19 SLX, 2 PDF), verificati contro i blob Git o gli SHA-256 LFS. Nessun nuovo run Simulink: integrità verificata, modelli invariati.
- Code Analyzer: nessuna segnalazione sul peso e sui test; un UNRCH sul ramo opzionale disattivato per default, eseguito nei test. Non è un errore del modello.
- NOT VALIDATED: margine RP numerico Hinf22/B invertito, anche dopo retry m9; escluso dai certificati. RP fallisce logicamente per RS.
- NOT RUN per perimetro: nuova musyn, ottimizzazione della banda, fase B, nuovi esperimenti hardware o Simulink. Non è stato rieseguito l'intero insieme storico di 141 test: sono state scelte le regressioni pertinenti.

## Evidenze e relazione

comparison.mat contiene modelli, pesi, sonde, controlli e audit completi; comparison.csv e validation.json sono i riepiloghi leggibili. I sei MAT individuali conservano gli output grezzi delle analisi, inclusi primo tentativo RP e retry; per la classificazione di validità dei limiti usare r.audits in comparison.mat. default_run.mat conserva il nuovo run storico separato. tests.csv, regression.csv, integrity.json e code_analyzer.json documentano i gate.

Gli approfondimenti sono aggiunti soltanto ai capitoli 5, 9 e 12, senza nuovi titoli numerati o cambiamenti a main.tex. Il generatore report/build_sea_uncertainty_table.py legge i risultati MATLAB. Il PDF aggiornato report/Progetto_CR_Revisione_conservativa.pdf è separato dal PDF storico: 111 pagine contro 108 della base ricompilata, zero overflow o riferimenti irrisolti, 68 etichette numerate invariate. I dieci avvisi hyperref su formule nei titoli sono identici alla base. Controllo visivo PASS sulle pagine modificate; dettagli in latex_audit.json e nel diario.

Per rigenerare la tabella e compilare senza sovrascrivere l'elaborato storico:

~~~text
python report/build_sea_uncertainty_table.py
cd report
latexmk -pdf -interaction=nonstopmode -halt-on-error -outdir=../tmp/sea_conservativa/latex -jobname=Progetto_CR_Revisione_conservativa main.tex
~~~

tools/audit_sea_revision.py ripete l'audit di integrità e delle parti storiche preservate. Non cancella file.
