# Revisione didattica degli script H∞ e μ — 10 ottobre 2026

Base `main` 6133365, con PR #36 e #37 integrate. Branch di revisione:
`codex/refactoring-didattico-hinf-mu`; nessun merge automatico.

## Organizzazione ed esecuzione

| Script | Righe prima | Righe dopo | Sezioni principali |
| --- | ---: | ---: | ---: |
| `progetto_hinf_tre_controllori.m` | 913 | 458 | 13 |
| `progetto_mu.m` | 2098 | 461 | 13 |

Aprire il file in `File_di_Funzioni_Progetto-Accorpati/` e premere Run.
Occorre il repository completo, MATLAB R2025b, Control System Toolbox e Robust
Control Toolbox. I percorsi sono relativi a `mfilename('fullpath')`; non serve
preparare il Workspace. Gli artifact mancanti vengono identificati per nome.

H∞: `ricalcolaSintesi=false` riproduce i controllori precedenti; `true` esegue
mixsyn, hinfsyn e gli undici avvii hinfstruct. μ: `ricalcolaAnalisi=true` e
`ricalcolaSintesi=false` analizzano i controllori archiviati. Disattivare
`ricalcolaAnalisi` legge i margini precedenti senza inventare curve mussv.
Attivare `ricalcolaSintesi` esegue musyn e forza una nuova analisi.

Il procedimento matematico, le formule delle chiusure, le incertezze correlate,
le chiamate ai solver, le metriche e i grafici restano nei due script. Tre brevi
funzioni in `support/` gestiscono soltanto valutazione/selezione degli avvii PID
e lettura dei relativi parametri. LQG/LQGI non sono modificati.

## Provenienza delle realizzazioni

Sono eliminate tutte le appendici di coefficienti numerici: pianta H∞, Ke,
K2, parametri/prove PID, attuatore Ga, WI, pianta nominale μ, Khinf, Kmu e
tabella D-K/margini storici. I modelli meccanici restano espressi con formule.

| Dato | Fonte realmente ispezionata | Ordine |
| --- | --- | ---: |
| Pianta H∞ | `nominal_study.mat`: `study.physical` | 14 |
| Ke 1 DoF | `nominal_study.mat`: `study.one{study.selectedOne}.Kfeedback` | 18 |
| K2 / Khinf | `selected_full_order.mat`: `selected.K` | 22 |
| PID | `fixed_PID.mat`: avvii `f.runs`, parametri `f.info` dell'avvio migliore | 4 |
| Ga | `m4_uncertain_plant.mat`: `uncertainPlantInfo.GactuatorNominal`, conversione ss originale | 3 |
| WI | `m4_uncertain_plant.mat`: `WI` | 1 |
| Nominale μ di riferimento | `robust_study.mat`: `result.physical.NominalValue` | 16 |
| Kmu | `m13.mat`: `synthesis.K` | 78 |
| D-K | `m13.mat`: `synthesis.info`, cinque iterazioni | — |
| Margini e norme precedenti | `m12.mat`, `m14.mat`: `audit` | — |

Tutti i MAT finali sono in `results/data/hinf_final_coherent/`, tranne M4 in
`results/data/`. Non viene creato un nuovo artifact di controllore.

Il PID archiviato come conversione tunablePID2→ss presenta uno scarto massimo
ABCD di 1.4551915228366852e-11 rispetto allo script precedente. Per eliminarlo,
si usano i parametri salvati e la stessa costruzione `pid2`/`blkdiag` precedente:
la realizzazione ottenuta è identica, senza ridurre cifre o cambiare base.
Ga conserva anche i precedenti nomi vuoti di ingresso/uscita; i nomi fisici
vengono assegnati esplicitamente al blocco degli attuatori come prima.

Nessun minreal, balreal, riduzione d'ordine o separazione degli stati Kr/Ky.
Pesi, Mo, specifiche, parametri, ampiezze, griglie e seed sono invariati.

## Verifiche ed esiti

La baseline è stata eseguita e salvata prima delle modifiche. Le versioni di
sorgente precedenti sono recuperabili dal commit 6133365; snapshot, risultati
MAT e immagini dei sette grafici restano in `tmp/refactor_didactic/`.
Il manifest `docs/didactic_refactor/source_baseline.json` registra gli SHA-256
dei 786 file presenti prima della revisione.

Le verifiche comprendono dimensioni/ordini e identità di A/B/C/D; poli chiusi,
mappe in frequenza, norme H∞, guadagni DC, tracking, disturbi, picchi/RMS dei
comandi, margini adattivi RS/RP, bounds mussv, cinque iterazioni archiviate,
tabelle e variabili importanti del Workspace. Le griglie di confronto sono
quelle originali: H∞ 2401 frequenze, μ 1201; tempo 0:0.002:12 s.

Il confronto usa identità numerica, più restrittiva di una tolleranza, per le
realizzazioni e i risultati riproducibili. Restano inalterate le tolleranze
scientifiche degli script: mappe H∞ 1e-5, gamma relativo 2e-3, ricostruzione
nominale/LFT μ 1e-8. Non sono allargate per ottenere un esito positivo.

| Modalità eseguita in MATLAB | Esito |
| --- | --- |
| H∞ predefinita: tre controllori e quattro figure | PASS, risultati identici |
| H∞ nuova mixsyn/hinfsyn/hinfstruct, vecchio e nuovo script | PASS, risultati identici |
| μ predefinita: analisi adattiva, mussv e tre figure | PASS, risultati identici |
| μ analisi archiviate, vecchio e nuovo script | PASS, risultati identici |
| μ nuova musyn, vecchio e nuovo script | PASS, risultati identici |

La nuova musyn produce ordine 76 e obiettivo 0.8917483061 in entrambe le
versioni; differisce dall'archivio di ordine 78 e obiettivo 0.88380955757519075.
È il comportamento della risintesi numerica già presente, non un effetto del
refactoring. I controllori archiviati restano quelli del progetto.

Gli esiti scientifici negativi sono conservati: H∞ NS/NP PASS, RS FAIL, RP
numerica non validata per intervallo invertito ed esclusa da RS; Kmu archiviato
NS/NP/RS/RP PASS. I fallimenti temporali M5 restano visibili.

Durante la revisione sono stati rilevati e corretti: una funzione ausiliaria
di confronto non trasferita nella selezione PID; il campo del primo margine RP
(`audit.rpInitial.margin`); i nomi u/tau importati nella variabile Ga.
Le regressioni finali verificano le correzioni; i numeri non sono riordinati
o sostituiti per nascondere risultati inconclusivi.

Regressione finale PASS: scarto massimo zero per mappe in frequenza, guadagni
DC, poli, risposte al disturbo e picchi/RMS dei comandi. Sono verificate anche
identità delle variabili principali del Workspace, quattro/tre figure,
ripristino RNG e messaggi per artifact mancanti. Gli 778 file preesistenti
fuori dai due script e dai sei documenti aggiornabili sono invariati per SHA-256.
Code Analyzer: zero segnalazioni sui due script e sui tre ausiliari.

Per ripetere i confronti, dalla radice:

```text
python tools/verify_didactic_refactor.py --fresh
```

Se MATLAB non è nel PATH, aggiungere `--matlab "percorso/matlab.exe"`.
Senza `--fresh` si verificano le modalità predefinite e archiviate.
I test scrivono soltanto in `tmp/refactor_didactic/` e non alterano gli artifact.
Evidenze numeriche, console e integrità: `docs/didactic_refactor/`.

Non sono eseguite nuove simulazioni Simulink, prove non lineari, Monte Carlo
o RAS: restano fuori dall'ambito di questa revisione. I relativi modelli,
risultati, relazione e presentazione sono conservati per SHA-256.
