# Revisione definitiva SEA — 31 ottobre 2026

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

La matrice R01–R20, i risultati finali e il collaudo della consegna vengono
consolidati al termine delle esecuzioni e della compilazione degli elaborati.
Un requisito di realizzazione può essere PASS pur documentando un
controllore con prestazioni FAIL; le due valutazioni non sono intercambiabili.
