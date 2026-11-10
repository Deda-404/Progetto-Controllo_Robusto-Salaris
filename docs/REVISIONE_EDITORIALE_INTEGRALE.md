# Relazione integrale — recupero discorsivo dopo il capitolo 7 approvato

Riferimento didattico: `main` **dbf6f00b06e0cddc65cd19e90d11ad3418cab2da**. Stato iniziale di questa fase: **2f83fcc**, con il pilota LQG/LQGI approvato dagli studenti. Ramo e PR invariati: `codex/sea-revisione-finale-semplificata`, [PR #47](https://github.com/Deda-404/Progetto_CR/pull/47). Nessun merge.

L'intervento riguarda spiegazioni, collegamenti, interpretazioni, figure da dati salvati e impaginazione. Non modifica MATLAB, SLX, controllori, parametri, pesi, soglie o risultati della campagna. Non sono state eseguite nuove sintesi, simulazioni, post-analisi robuste o prove Simulink. Il PDF integrale è in `report/Progetto_CR_Relazione_finale.pdf`.

## Criterio di verifica della profondità

Il confronto è stato svolto leggendo i sorgenti completi del main e verificando, per ogni argomento, problema fisico, motivazione, metodo, formule, interpretazione e collegamento alle prove. Il semplice ripristino di un titolo o di una formula non costituisce recupero. Righe, parole e pagine non sono criteri di accettazione.

La relazione conserva 13 capitoli e quattro appendici, nello stesso ordine. Sono presenti tutti i **129 percorsi di sezione e sottosezione** del main. Due soli titoli sono adattati nel significato:

- 9.1.1: «I tre parametri meccanici selezionati» diventa «Il carico meccanico selezionato»: la famiglia attuale mantiene una sola massa incerta, senza reintrodurre rigidezze e inerzie incerte.
- 10.11.1: «Otto nuove esecuzioni Simulink abbinate» diventa «Esecuzioni Simulink abbinate»: conserva il metodo del confronto, senza dichiarare otto nuove prove di riprogettazione con rumore.

Gli approfondimenti interni aggiunti ai capitoli 5 e 6 sono paragrafi non numerati; non cambiano l'indice. Non compaiono cronache delle revisioni nella relazione. Il fascicolo pilota resta una testimonianza del risultato approvato; il capitolo 7 integrale include poche ulteriori frasi interpretative su Q, Kalman e chiusura a 30 stati.

## Confronto dei contenuti, capitolo per capitolo

| Capitolo | Patrimonio teorico e didattico del main conservato | Sviluppo e coerenza con i dati attuali |
|---|---|---|
| 1 — Introduzione | Problema SEA, obiettivi, percorso dal nominale alla robustezza, classi di verifica, organizzazione | Spiegati carico e ruolo del confronto A/B; distinta la teoria di Lyapunov dal certificato numerico non disponibile. Nessuna garanzia attribuita alla semplice esecuzione. |
| 2 — Dinamica | Coordinate link/rotore, coppia elastica, equazioni M/C/G, energia, stato, ingressi, uscite e assunzioni | Carico presente nelle tre componenti attraverso la stessa massa; ragionamento energetico e positività dell'inerzia, equazioni del primo ordine, significato delle quattro misure e limiti del modello. Conservato il ragionamento, non soltanto le matrici. |
| 3 — Linearizzazione | Equilibrio statico, coordinate incrementali, Taylor/Jacobiano, poli, controllabilità/osservabilità | Motivato perché coppia gravitazionale nulla non significhi stabilità; carico nella derivata gravitazionale, verifica indipendente del Jacobiano, PBH e condizionamento. Spettro ridisegnato dalla matrice meccanica salvata. |
| 4 — Attuatori | Secondo ordine, scala di banda, ritardo/Padé, cascata SISO–MIMO, ordine del nominale | Distinti comando e coppia, poli/zero di Padé e incertezza del ritardo. Recuperato il confronto nominale ritardo esatto/Padé, valido a 15 ms; interpretata la sensibilità separata di frequenza, smorzamento e ritardo dai dati disponibili. |
| 5 — Incertezze | Famiglia fisica, reali normalizzati, pulling out the deltas, LFT, forme dinamiche, inviluppo, fitting, verifica e conservatività | Sviluppo dettagliato descritto nella tabella successiva. La meccanica è identica in A/B; cambia la rappresentazione dei medesimi drive. Il risultato non è una tabella di formule isolate. |
| 6 — Specifiche | Scenari, banda, target temporali, pesi e richiesta encoder | Spiegati separatamente assestamento attorno al valore finale, offset rispetto al riferimento e cross. Distinti scala LQR, banda del feedback, transizione del peso e Mo. Conservato il problema aggiuntivo di rumore come formulazione teorica. |
| 7 — LQG/LQGI | Tutti i 28 percorsi del pilota approvato: scale Q/R, Riccati, Kalman, covarianze, separazione, prefiltro, tracking, disturbo, integratore e chiusura completa | Mantenuti esempi, matrici e figure del pilota. Aggiunte frasi per leggere Q come penalità, K come reazione, L per righe/colonne e la matrice a 30 stati per sottosistemi. La griglia di 36 costi e la traccia temporale di stima restano limiti espliciti. |
| 8 — H∞ | Tutti i 22 percorsi: significato dei pesi e norma, energia, Mo, partizioni della pianta, S/KS/T, mixsyn/hinfsyn, 1/2-DoF, mappe chiuse, PID, tuning e confronto | Preservate le spiegazioni estese delle porte e dei segni, gli schemi e il motivo fisico del model following. Recuperate interpretazione di tracking, disturbo, rumore e RAS; figure del tracking e comando dai dati con carico. La seconda formulazione con rumore è spiegata integralmente come metodo, senza vecchi risultati HinfN. |
| 9 — µ | Tutti i 16 percorsi: origine fisica, Delta, N–Delta, definizione e lettura di µ, limiti numerici, NS/NP/RS/RP, D/G e D–K, post-analisi e ordine | Collegati massa condivisa, reali ripetuti, dinamiche indipendenti, geometria A/B e margini. Distinte analisi dirette e deduzioni da NP/RS; spiegato perché due margini non implichino inclusione delle famiglie. Conservata la teoria della D–K con misura rumorosa, con porte aggiornate e senza falsa campagna. |
| 10 — Non lineare, rumore e RAS | RAS nello stato completo, funzione di Lyapunov, cambio di coordinate, resto cubico, sottolivelli, sezioni empiriche, tracking/disturbo, encoder ZOH, intercampione, originali SLX e confronti abbinati | Derivazione condizionale completa del certificato, senza riutilizzare vecchi raggi. Ordini aumentati corretti per sette candidati. Recuperate posizioni e comandi non lineari e Scope già salvati; spiegati tempo finito/DC, picco/RMS, saturazioni assenti e differenza fra scenari. Le prove di riprogettazione con rumore rimangono metodo non eseguito sul carico. |
| 11 — Impianti comuni | Tutti i sei percorsi: costruzione campioni, stabilità prima delle metriche, tracking/cross, disturbo, collegamento a µ e candidati con rumore | Dieci settuple condivise, replay e ricostruzione A/B, casi instabili non rimossi, interpretazione di cross e recupero. La teoria del confronto rumoroso mantiene comuni sia i parametri sia la sequenza; non combina prove separate in una garanzia congiunta. |
| 12 — Confronto per ruolo | Scelta multicriterio, ruolo delle famiglie, fattibilità e confronto della seconda formulazione | Tabella attuale per tutti i sette candidati, NS distinta da NP/RS/RP e target. Motivate utilità e limiti di LQG, LQGI, Hinf1/2, PID e D–K. Conservata l'interpretazione delle due rappresentazioni, senza vecchi PASS RP. |
| 13 — Conclusioni | Catena dal modello alle prove, risultato del confronto, interpretazione dei fallimenti e limiti applicativi | Discussione discorsiva di massa, ritardo variabile, forma additiva, LFT, famiglie, controllori, rumore e attrazione. Nessun vincitore universale, certificato hardware o nuova campagna attribuita al recupero editoriale. |
| A — Parametri | Valori, unità e provenienza | Mantenuta tabella, distinta massa del carico da massa effettiva, costanza durante le prove e indipendenza dei drive. |
| B — Tracciabilità | Catena codice→dati→grafici→testo e fonti | Rimappata sui MAT/CSV autorevoli con carico; spiegate sintesi, post-analisi, replay ed esportazione, firme, Scope integrali/diradati e grafici teorici. Gli archivi obsoleti non sono fonti dei numeri attuali. |
| C — Riproducibilità | Tutti i quattro percorsi: rapida, completa, SLX e compilazione/consegna | Comandi e dipendenze attuali, dati caricati distinti dai calcoli, controllo delle firme e dei controllori, avvio automatico SLX, compilazione integrale e ruolo degli esportatori editoriali. |
| D — Codici e formule | Tutti i 14 percorsi dell'appendice, incluse le due LFT e il limite inferiore con sigma_min | Estratti letti direttamente dagli script correnti, con scopo e interpretazione. Recuperata la derivazione del limite inferiore attraverso minimo quadratico e SVD, compresi limiti di causalità e fattibilità. Il metodo Lyapunov è distinto dal codice RAS effettivamente eseguito. |

## Capitolo 5 — verifica specifica del cuore scientifico

| Passaggio | Ragionamento effettivamente sviluppato |
|---|---|
| Oggetto del confronto | A/B descrivono la stessa fisica nominale e la stessa massa incerta; il controllo fissato e gli impianti comuni separano rappresentazione e comportamento. |
| Significato dei range | Ipotesi di progetto distinte da identificazione sperimentale, intervalli di confidenza e probabilità hardware. |
| Carico meccanico | Un solo oggetto, stessa massa inerziale e gravitazionale; m2 invariata; M/C/G correlate; coppia nulla alla verticale ma Jacobiano diverso; carico costante distinto da presa durante il moto. |
| Normalizzazione | Esempi dimensionali e significato di delta=0,±1; parametro reale costante in frequenza, distinto da una funzione dinamica. |
| Drive SISO e MIMO | Ruolo dei coefficienti del secondo ordine, indipendenza dei drive e accoppiamento nella meccanica; lettura congiunta di modulo, fase, poli e gradino. |
| Pulling out the deltas | Segnali interni z1/z2/z3 e w1/w2/w3, sostituzione che ricostruisce i prodotti, occorrenze correlate della stessa frequenza naturale; Padé e dipendenza razionale dal ritardo. |
| LFT completa | Parte nota, porte interne e chiusura; buona posizione, nominale e sostituzioni fisiche; distinzione fra 7 parametri, 19 occorrenze e 14 stati. |
| Scelta della forma | Additiva, moltiplicativa e inversa, scostamento assoluto/relativo, collocazione SISO/MIMO. Con ritardo variabile gli zeri destri non si cancellano: una curva di modulo coperta non rende stabile la perturbazione. |
| Inviluppo | 20 drive dai dieci robot + 8 vertici + nominale = 29 casi SISO. Il massimo puntuale può cambiare caso e non è automaticamente un trasferimento causale. |
| Fit e peso | Ordini 1/2/3, stabilità e proprietà, margine di normalizzazione continuo, criterio sull'eccesso mediano e scelta dell'ordine minimo fra quelli esaminati. Spiegata la differenza fra rapporto mediano e norma massima. |
| Composizione B | Due ultidyn SISO indipendenti, non un unico errore comune e non un blocco pieno con cross attuativo. Carico fuori dal peso dinamico. |
| Verifica | Norme continue dei casi, 30 casi indipendenti e ricostruzione dei medesimi impianti. Nessuna inclusione globale A⊆B dichiarata. |
| Conseguenze | A conserva correlazioni fisiche; B ammette forme e fasi ulteriori. I margini espandono geometrie differenti; collegamento esplicito a H∞ nominale, µ-analysis e due D–K. |

## Figure e tabelle: conservazione, aggiornamento e limiti

| Patrimonio del main | Trattamento nella relazione integrale |
|---|---|
| Configurazione SEA, schemi dei drive e carico | Conservati gli schemi pertinenti e coerenti con il carico. |
| Poli meccanici | Ridisegnati da `modello.mat`; nessun vecchio spettro del nominale senza carico. |
| Ritardo puro/Padé | Conservato il confronto a 15 ms, con didascalia limitata al ritardo nominale. |
| Famiglia attuativa, Delta, tre forme, fit e peso | Conservati gli schemi validi e le figure correnti; vecchio inviluppo relativo sostituito dal peso additivo della medesima famiglia. |
| Tabelle di parametri/specifiche precedenti | Sostituite da valori e definizioni attuali, preservandone unità, origine e funzione didattica. |
| Griglia LQR, pesi, matrici, Kalman e poli LQG | Mantenuto il recupero del pilota e il confronto puntuale già documentato in `CAPITOLO_7_PILOTA_CONFRONTO.md`; non ricostruita una griglia numerica non disponibile sul carico. |
| Tracking LQG/LQGI, comando, integratore e disturbo | Conservate le figure aggiornate del pilota, comprese le spiegazioni sulla quadratura dell'integrale. |
| Traccia temporale dell'errore di stima | Non disponibile nei dati attuali: non dichiarata recuperata. Conservati teoria dell'errore, matrici L, poli e sensibilità RMS a sequenza comune. |
| Pesi H∞ e schemi di pianta generalizzata/2-DoF | Conservati: coefficienti e architettura pertinenti sono gli stessi. |
| Tre Mo e campagna di strutture a ordine fissato | Conservati ragionamento e alternative di struttura, senza trasferire vecchie norme o esiti di 66 avvii. Per il carico sono disponibili il modello scelto e il PID a tre avvii. |
| Tracking e comandi H∞ | Nuova figura da `confronto.mat`: entrambi i gradini e tutti i canali di posizione/comando dei tre candidati correnti. |
| Diagnosi frequenziale H∞ | Conservata la spiegazione di S, KS, T e mappa pesata; figura attuale di sensibilità/complementare. La vecchia figura a tre pannelli KS/costo non è riutilizzata come risultato corrente; non è dichiarata una nuova analisi numerica equivalente. |
| Disturbi H∞ | Figura corrente delle due coppie separate; mantenute definizioni, ingresso fisico e interpretazione di recupero/offset/comando. Le vecchie metriche non sono trasferite. |
| N–Delta, prestazione e D–K | Conservati gli schemi; margini, iterazioni e ordine riferiti soltanto ai candidati A/B attuali, con tabelle del riesame già salvato. |
| Lyapunov e RAS | Teoria completa; grafico e tabella dei 105 casi attuali. Non recuperati come attuali i vecchi ellissoidi, raggi, griglie o certificati. |
| Tracking/disturbo non lineari | Figure dai sette controllori in `ras.mat`: tracking e posizioni/comandi sotto coppia. Disturbo diviso in due tavole per mantenere leggibili assi e curve. Conservato il confronto lineare/non lineare LQG/LQGI disponibile. |
| Rumore e impulsi | Recuperate propagazione ZOH e interpretazione intercampione; figura di picco/RMS dal CSV comune. Non inventate tracce temporali o nuove campagne multi-seed non salvate per questa famiglia. |
| Viste autentiche SLX | Conservate tutte le sette viste pertinenti di architettura, Kalman, pianta, drive e interfacce H∞/µ. |
| Curve Scope | Ridisegnate dalle acquisizioni attuali di 2 s: LQG, LQGI, due µ e tre rami H∞. Distinte da tracking pulito e rumore isolato; non estese al regime. |
| Dieci impianti | Conservati grafico attuale e tabelle di stabilità, tracking e disturbo. La discussione spiega cross, offset, recupero e casi instabili; i grafici del diverso insieme M4 non vengono rinominati. |
| Confronto finale | Ripristinata una tabella di ruolo con i sette candidati e gli esiti attuali, senza vecchi PASS robusti. |

## Esperimenti che il recupero teorico non dichiara rieseguiti

Non sono nuove esecuzioni: scansione dei 36 costi LQR, tre sintesi per differenti Mo, esplorazione di sei strutture H∞/66 avvii, HinfN1/N2/N3 e D–K con rumore, test multi-seed dei candidati rumorosi, vecchie scansioni non lineari di ampiezza, ricerche radiali più dense, ellissoidi Lyapunov e vecchi confronti Scope. I ragionamenti pertinenti sono conservati; i vecchi numeri incompatibili non sono trasferiti.

Restano risultati della campagna salvata: carico e ritardo incerti, peso additivo, sette candidati, due D–K a tre iterazioni, margini A/B, dieci impianti fisici comuni, 105 RAS, 35 altre prove non lineari, rumore comune e collaudi SLX. LQG/LQGI mantengono RS A/B; nessun candidato soddisfa RP. Hinf2/PID restano fragili e i candidati µ non diventano soluzioni operative per il solo fatto di provenire da D–K.

## Verifica editoriale e integrità

Quality gate tecnico **COMPLETE/PASS**. Relazione integrale di **108 pagine**, compilata con latexmk/pdflatex: zero errori, warning, overfull, underfull e riferimenti irrisolti. Tutte le 108 pagine renderizzate e controllate nei contatti; dettagli del capitolo 5 verificati a 140 dpi. Controllati 18 estratti MATLAB con intervalli completi. Separati i paragrafi dai float per evitare frasi interrotte da figure o tabelle; uniformati simboli e segni dello schema didattico delle tre forme alle equazioni del testo.

I **589 file protetti** sono identici per SHA-256 allo stato iniziale. Lo ZIP supera il controllo CRC e manifest: cambiano esclusivamente PDF integrale e manifest interno; gli altri **89 contenuti** sono identici. La confezione del PDF non è un nuovo collaudo MATLAB/Simulink. Il PDF pilota e la presentazione restano conservati.

Il dettaglio macchina della compilazione, dell'indice e dell'integrità è in `EVIDENZE_EDITORIALI_INTEGRALI.json`. Sono controllati il PDF completo, le figure e le tabelle, gli estratti MATLAB, i riferimenti e la corrispondenza con le fonti. Il controllo dell'indice integra la lettura dei contenuti, senza sostituirla.

La revisione editoriale finale degli studenti resta distinta dal quality gate tecnico. Non viene attribuita un'approvazione preventiva a ogni nuova frase, né un esito prestazionale positivo ai controllori falliti.
