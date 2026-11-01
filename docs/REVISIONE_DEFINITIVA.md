# Revisione definitiva SEA — 1 novembre 2026

Responsabile: Alessio. Base: origin/main 0ed5611fdbb9c46475543f87eba68d9799b07bc5.
Il ramo codex/revisione-definitiva-sea-salaris conserva relazione, indice,
controllori originali e otto SLX. Le modifiche scientifiche sono autorizzate
dall'incarico definitivo; adozione e merge restano alla revisione degli studenti.

## Percorso e provenienza

I quattro script accorpati esistenti sono aggiornati in sede. Il percorso
run_all esegue sette script didattici; sei funzioni condivise contengono
configurazione, interconnessione, dinamica non lineare, integrazione,
verifiche e collaudo Simulink. Non usa genpath né i runner in analysis,
controllers o src. I quattro helper meccanici originali restano necessari
esclusivamente ai MATLAB Function degli SLX. La consegna è una copia degli
stessi sorgenti, generata automaticamente.

La banca validata conserva matrici e controllori provenienti da main;
tools/prepara_banca_definitiva.m documenta l'estrazione. I risultati storici
non vengono rinominati come nuovi risultati. Le risintesi sono esplicite.
La modalità rapida carica le sintesi e le campagne onerose dichiarandolo;
la completa le ricalcola.

Le PR 43, 44 e 45 sono state consultate senza merge o cherry-pick:
la 43 sostituiva la relazione con un elaborato ridotto, la 44 introduceva
un'architettura parallela, la 45 lasciava l'analisi separata dal percorso
predefinito. Si conservano le lezioni metodologiche utili (confronti
omogenei, normalizzazione, provenienza), non quei difetti organizzativi.

## Fonti effettivamente consultate

- [Traccia ufficiale 2](https://drive.google.com/file/d/1SslzEc6_-SfOLIJyR6Qb7XTx2DfH65mt/view):
  equazioni, confronto dei controllori, dieci impianti, limite orale.
- [Lezione3004.m](https://drive.google.com/file/d/1eBF1ZGKLhwiReaWv11tH2MFWv-qCVVjW/view):
  ureal, usubs, usample, frd e variazione dei parametri.
- [Lezione3004_1.m](https://drive.google.com/file/d/1BRRVgh9aW4M360xJO5ETXb9rHkLywnPh/view):
  scostamenti relativi, inviluppo e fitmagfrd; qui la scelta interattiva
  dei punti è sostituita dal massimo riproducibile dei campioni.
- [Capitolo 5](https://drive.google.com/file/d/1ZE4s4RYfgb5k2V6jB8bEi4bEEocwP1f0/view):
  pulling out the deltas, normalizzazione, ripetizioni reali e M–Delta.
- [Capitolo 4](https://drive.google.com/file/d/1Lgk_5PN2ONw4ZcSBFyJFI2Z7GAuGt7oq/view):
  pianta generalizzata e sensibilità mista.
- [Appunti](https://drive.google.com/file/d/1HOvOZ0tELDyTlpRVvW8mqWdE3VtYfUd1/view)
  e [riassunto](https://drive.google.com/file/d/1rd2cNTtBw6Z4DNa3OsXE850MCCSxQad_/view):
  forme di incertezza, piccolo guadagno, NS/NP/RS/RP e D–K.
- Documentazione MathWorks di [fitmagfrd](https://www.mathworks.com/help/robust/ref/frd.fitmagfrd.html),
  [ucover](https://www.mathworks.com/help/robust/ref/dynamicsystem.ucover.html)
  e [lftdata](https://www.mathworks.com/help/robust/ref/inputoutputmodel.lftdata.html).

Drive è rimasto in sola lettura. Non è stato consultato un audio originale
del ricevimento: le indicazioni attribuite al docente sono il resoconto
degli studenti, distinto dalle slide e dalla traccia.

## Ipotesi e metodo

Nominale, equilibrio, meccanica, misure e pesi restano quelli di main.
Solo la descrizione incerta corrente cambia: due tipi di parametro,
frequenza naturale e smorzamento, indipendenti nei due giunti (quattro
scalari). Intervalli ±10%, nominali 40 rad/s e 0.8; ritardo noto 15 ms,
Padé di ordine uno comune. Il ritardo variabile è escluso esplicitamente,
non dichiarato trascurabile. Le tolleranze sono ipotesi ingegneristiche.

A usa quattro ureal nella realizzazione fisica a 14 stati complessivi.
B usa due ultidyn SISO indipendenti, G0*(1+WI*Delta). Il peso proviene
dagli stessi dieci impianti, dai quattro vertici SISO e dal nominale:
25 casi SISO, non 25 manipolatori. Il Padé comune viene cancellato
analiticamente prima della normalizzazione per evitare uno zero RHP
invertito. Il peso scelto è stabile, proprio e minimo-fase.

Ordini provati 1, 2, 3; criterio dichiarato: ordine minimo con norma
normalizzata <=1 ed eccesso mediano <=1.6. Ordine selezionato 1:
massima norma continua 0.980392, eccesso 1.457951.
Questa verifica copre i casi provati in frequenza continua, non dimostra
l'inclusione dell'intero box A in B. Non si trasferiscono garanzie mediante
una presunta inclusione. I raggi robusti >1 rappresentano espansioni
diverse per A e B e non ammettono un ordinamento universale.

## Verifiche intermedie e fallimenti conservati

Nominale: differenza massima in risposta rispetto a main 3.36e-15.
Equilibrio e Jacobiano indipendente verificati; CARE LQG/LQGI e separazione
coerenti con le matrici congelate. Ricostruzione LFT automatica e manuale
verificata su sostituzioni fisiche. Controllo continuo delle perturbazioni
normalizzate e replay del campionamento inclusi in verifica_sea.

Una prima realizzazione algebrica di A produceva 22 stati ridondanti:
è stata sostituita dalla realizzazione fisica a 14 stati. Il candidato
D–K di quella prova (186 stati) è scartato e i suoi numeri non sono usati
negli elaborati. La nuova D–K A a 142 stati fallisce NP; B a 32 stati
supera RS/RP, con forte amplificazione del rumore. Nessun peso è stato
rilassato per ottenere PASS.

Un avvio hinfstruct ha restituito un chiuso instabile: conservato in
infoPID, non selezionato. Gli altri due avvii sono confrontati prima
della scelta. Il comando viene misurato anche fra campioni: il solo
campionamento a 2 ms sottostima gravemente Hinf2 e Mu_B.

RAS: 15 condizioni per controllore, stessa sezione dello stato aumentato,
15 s, soglie esplicite. Convergenza empirica, mancata convergenza,
divergenza osservata, timeout ed errore numerico sono categorie distinte.
Le prime prove hanno mostrato timeout per modi molto veloci; una
similitudine numerica del controllore e un Jacobiano del sistema
completo migliorano l'integrazione senza ridurre l'ordine.

Gli errori preliminari Simulink hanno riguardato la risoluzione delle
variabili nelle maschere LTI, poi corretta assegnando il Model Workspace
in memoria prima della compilazione, e un path MATLAB incompleto.
restoredefaultpath e rehash toolboxcache ripristinano i prodotti
installati. Gli SLX non vengono salvati o modificati.

## Accettazione finale

Un requisito di realizzazione può essere PASS pur documentando un
controllore con prestazioni FAIL; le due valutazioni non sono intercambiabili.

La pipeline completa è terminata in R2026b 26.2.0.3386108: due D–K,
risintesi H-infinity/PID, venti post-analisi (dieci controllori per A/B),
110 chiusure fisiche (dieci campioni più nominale), venti prove non lineari
di tracking/disturbo e 150 condizioni RAS. Sette verifiche fisiche e
dinamiche PASS; Code Analyzer senza segnalazioni sui quattordici sorgenti
operativi. Gli otto SLX sono invariati e completano 28 run di 2 s,
con stati finiti, Scope acquisiti e coefficienti conservati nei dati.

| Controllore | Ordine | Norma comune | RS A/B | RP A/B | Impianti stabili /10 | RAS convergenti /15 |
|---|---:|---:|---|---|---:|---:|
| LQG | 14 | 2.16850 | PASS/PASS | FAIL/FAIL | 10 | 15 |
| LQGI | 16 | 1.51358 | PASS/PASS | FAIL/FAIL | 10 | 15 |
| Hinf1 | 18 | 1.86565 | PASS/PASS | FAIL/FAIL | 10 | 15 |
| Hinf2 | 22 | 0.04746 | FAIL/FAIL | FAIL/FAIL | 2 | 12 |
| PID originale | 4 | 0.80095 | FAIL/FAIL | FAIL/FAIL | 8 | 0 |
| Kmu originale | 78 | 0.63468 | PASS/PASS | PASS/PASS | 10 | 15 |
| MuN1 | 82 | 0.67342 | PASS/PASS | PASS/PASS | 10 | 15 |
| Mu_A | 142 | 3.70000 | PASS/PASS | FAIL/FAIL | 10 | 15 |
| Mu_B | 32 | 0.39001 | PASS/PASS | PASS/PASS | 10 | 15 |
| PID nuovo | 4 | 0.67799 | FAIL/FAIL | FAIL/FAIL | 8 | 0 |

Tutti nominalmente stabili. NP richiede norma comune <1.
Per Hinf2 i margini RS sono circa [0.2563,0.2583] su A e
[0.1054,0.1056] su B; per Kmu [3.3362,3.3599] e [2.6674,2.6728].
Gli intervalli completi e il metodo RP sono in confronto_robusto.csv:
un FAIL NP esclude RP, mentre un limite superiore RS <1 esclude la
garanzia RP senza inventare un margine robgain.

La RAS finale conta 117 convergenze, 24 mancate convergenze e 9
divergenze osservate. I timeout iniziali sono risolti mediante
similitudine numerica e Jacobiano, senza riduzione dei controllori.
Il rumore è distinto dalle prove RAS: Hinf2 raggiunge circa 5.45e5 N m
fra campioni contro 22.1 N m sui nodi; Kmu 78.8 N m, MuN1 1.123 N m,
Mu_B circa 2.39e5 N m. Nessun risultato certifica un attuatore reale.

La cartella estratta fuori dal repository ha eseguito la modalità rapida
e tutti i 28 run SLX, dopo restoredefaultpath e senza alcun percorso del
repository. I 31 sorgenti/ingressi necessari coincidono per SHA-256;
gli Scope hanno scarto relativo nullo rispetto al collaudo del repository.
La rietichettatura del PID nuovo è stata verificata separatamente in
entrambe le cartelle. Evidenze: collaudo_consegna.json e
collaudo_consegna.txt nella cartella risultati.

La riduzione operativa è effettiva: il vecchio run_all aggiungeva alberi
con 193 file MATLAB (src, analysis, controllers) e sei runner Simulink.
Il percorso corrente richiede quattordici sorgenti principali e quattro
helper per gli SLX, senza quegli alberi. Il conteggio precedente descrive
la superficie resa visibile al path, non una stima esatta delle chiamate
transitive. La prova da estrazione dimostra l'assenza delle dipendenze
storiche, che restano recuperabili nel repository e in Git.

Relazione esistente: 120 pagine, stesso indice; grafici A/B, quattro
nuovi schemi vettoriali e tabelle derivate dai CSV. Conservati meccanica,
LQR/Kalman, LQGI, H-infinity, mu, Lyapunov e contenuti storici validi,
con etichette di provenienza. Presentazione: stessi 23 frame e titoli,
discorso aggiornato, 17:42 stimati inclusi i cambi. Controllo visivo
effettuato e audit senza testo oltre pagina o riferimenti indefiniti.

| ID | Stato | Evidenza e portata |
|---|---|---|
| R01 | PASS | Titoli di capitoli/sezioni/sottosezioni identici a main; audit_editoriale.json |
| R02 | PASS | Diff dei capitoli e appendici; approfondimenti validi conservati, M4 identificato |
| R03 | PASS | 14 sorgenti + 4 helper; run senza src/analysis/controllers nella copia estratta |
| R04 | PASS | Quattro script esistenti riscritti in sede, tre script didattici aggiunti; run_all eseguito |
| R05 | PASS | Due tipi di parametro, quattro scalari; sensibilita_attuatori.csv e cap. 4–5 |
| R06 | PASS | Modello fisico a 14 stati, ureal, campioni e verifica nominale/LFT |
| R07 | PASS | Ordini 1/2/3; peso stabile e minimo-fase; norme continue dei 25 casi, limite globale esplicito |
| R08 | PASS | Fonti consultate sopra; procedimento Lezione3004_1 reso automatico e riproducibile |
| R09 | PASS | LFT manuale e automatica, ripetizioni reali, schemi e sostituzioni numeriche |
| R10 | PASS | confronto_robusto.csv: stesso K su A e B, NS/NP/RS/RP distinti |
| R11 | PASS | Due D–K e nuovo PID; stessi dieci impianti e campagna non lineare; esiti negativi conservati |
| R12 | PASS | Sensibilità dei drive, cinque covarianze Kalman, tre ordini peso, tre avvii PID; pesi originali invariati |
| R13 | PASS | ras.csv/ras.mat/ras.png: 150 condizioni, cinque categorie separate, nessuna frontiera certificata |
| R14 | PASS | parametri_dieci_impianti.csv, seed e replay esatto, dieci_impianti.csv |
| R15 | PASS | Schemi TikZ integrati: SISO/MIMO, LFT, tre forme, fitting; schemi di controllo originali conservati |
| R16 | PASS | Otto SLX invariati; 28 run nel repository e nella consegna, segnali e parametri salvati |
| R17 | PASS | ZIP estratto fuori repository; rapida e collaudo Simulink realmente eseguiti |
| R18 | PASS | Log completa/rapida, CSV/MAT, sette verifiche, Code Analyzer e audit PDF; nessun PASS inferito dal solo avvio |
| R19 | PASS | Un solo run_all autorevole; copie di consegna identiche; runner storici esclusi dal path |
| R20 | PASS | Branch pubblicato e [PR #46](https://github.com/Deda-404/Progetto_CR/pull/46) aperta per revisione, senza merge |

Rimangono fuori dalle verifiche eseguite: prova orale dal vivo, validazione
hardware, copertura rigorosa dell'intero box A da parte di B, ritardo
variabile e incertezza meccanica. Non sono dichiarati soddisfatti né
confusi con i requisiti implementativi R01–R20.

Il 1 novembre un nuovo avvio MATLAB ha dato errore 5201. Con nessuna
sessione MATLAB attiva, il riavvio del solo MathWorks Service Host ha
ripristinato l'avvio; il collaudo della consegna è stato poi realmente
eseguito. Nessuna modifica alla licenza o ai controlli di accesso.

Pubblicazione: [branch](https://github.com/Deda-404/Progetto_CR/tree/codex/revisione-definitiva-sea-salaris),
[PR #46](https://github.com/Deda-404/Progetto_CR/pull/46).
Commit scientifici principali: 677ad20 (modelli), 7324839 (codice e campagne),
8db1b6d (relazione e presentazione). Il commit di confezionamento aggiunge
ZIP, manifest e registrazione finale, senza modificare i calcoli.
