# Correzione conservativa della PR #47

Riferimento: main dbf6f00 (PR #46 integrata). Ramo invariato. Lo stato prima della correzione è recuperabile dal tag locale recupero/pr47-prima-correzione-7456a30 e dal commit 7456a30. Nessun reset, force push o merge.

## Confronto diretto dei contenuti

Tutti i sorgenti LaTeX sono stati confrontati direttamente con main, non soltanto con i messaggi dei commit. A = valido conservato, B = valido aggiornato ai nuovi parametri, C = sintesi motivata, D = cronaca esclusa. Le quantità sotto misurano soltanto la copertura strutturale; non sostituiscono il confronto degli argomenti.

| Sorgente | Righe main | Righe corrette | Sezioni main/corrette |
|---|---:|---:|---:|
| 01_introduzione.tex | 41 | 20 | 4/4 |
| 02_modello_dinamico.tex | 60 | 65 | 5/5 |
| 03_equilibrio_linearizzazione.tex | 51 | 44 | 3/3 |
| 04_attuatori.tex | 56 | 37 | 4/4 |
| 05_incertezze.tex | 207 | 110 | 4/8 |
| 06_specifiche_pesi.tex | 47 | 61 | 3/4 |
| 07_lqg.tex | 613 | 384 | 28/22 |
| 08_hinf.tex | 661 | 332 | 22/18 |
| 09_mu.tex | 491 | 281 | 16/11 |
| 10_originali_simulink.tex | 156 | 47 | 3/1 |
| 10_validazione_nonlineare.tex | 390 | 91 | 12/7 |
| 11_monte_carlo.tex | 111 | 28 | 6/5 |
| 12_confronto_finale.tex | 81 | 24 | 1/2 |
| 13_conclusioni_limiti.tex | 80 | 12 | 0/0 |
| A_parametri.tex | 3 | 24 | 0/0 |
| B_artifact_traceability.tex | 68 | 18 | 0/0 |
| C_riproducibilita.tex | 57 | 26 | 4/4 |
| D_codici_matlab.tex | 217 | 44 | 14/4 |

## Matrice degli argomenti e delle figure

| Capitolo / contenuto nel main | Conservato o recuperato | Aggiornato / eliminato e motivo |
|---|---|---|
| 1: problema, obiettivi, metodo, organizzazione | Tutte e quattro le sezioni | D: rimossa cronaca della revisione; B: carico e confronto A/B |
| 2: coordinate, M/C/G, lato motore, stato, assunzioni | Tutte le cinque sezioni e formule dinamiche | B: m2_eff in M/C/G e figura carico, senza doppio conteggio |
| 3: equilibrio, Jacobiani, poli e proprietà | Equazioni e tre sezioni | B: inerzia, Kg e poli dal nuovo nominale; esclusa figura poli obsoleta |
| 4: modello drive, scelta banda, Padé, SISO-MIMO | Quattro sezioni, schema drive-meccanica | B: ritardi indipendenti; vecchio grafico delay non ripresentato come verifica corrente |
| 5: ureal e realizzazioni SISO | Normalizzazione e secondo ordine | B: sei parametri drive e massa condivisa |
| 5: pulling out the deltas, LFT | Recuperate equazioni manuali e schema sea_delta | B: stato Padé con 1/td, 19 occorrenze / sette grandezze |
| 5: forme di incertezza, inviluppo, fitting | Recuperati sea_forme e sea_fit | B: forma additiva, otto vertici, errori assoluti; diagramma sea_fit corretto, non riusato con formule moltiplicative |
| 5: famiglia meccanica M4 e vecchia copertura | D: escluse dalla trattazione finale | Non appartengono alla famiglia fisica richiesta; nessun vecchio PASS trasferito |
| 6: specifiche, banda, rumore | Scenari, target e distinzione diagnostica | B: spiegato Mo=3, We(0)=6.67 non equivale al 5%; nessun rilassamento ulteriore né nuova scala hardware |
| 7: costo LQR, scale, Q non diagonale, R | Recuperate derivazione F/Sx, tabella delle scale, costo e CARE | B: nominale con carico, residui correnti; C: non ripetuta vecchia griglia 36 candidati |
| 7: Kalman, innovazione, covarianze | Recuperate intensità continue, canali di processo e interpretazione fisica | B: sensibilità su cinque fattori con stessa sequenza; escluse vecchie matrici e vecchio grafico |
| 7: principio di separazione | Recuperate matrici complete e coordinate errore | B: verifica corrente a 28 stati |
| 7: LQGI e modello interno | Recuperati misure, integratore, aumento, PBH, costo Qi, Riccati comune Kx/Ki | B: scelta Qi=200; C: non ripetuta vecchia griglia integrale |
| 7: realizzazione e chiusura LQGI | Recuperate matrici del controllore e chiuso a 30 stati | B: tempi e residui correnti; nessun vecchio coefficiente guadagno pubblicato |
| 7: figure e lettura tracking/disturbo/comando | Recuperato schema lqgi_architecture; rigenerate lqg_lqgi_risposte e lqg_lqgi_comando | B: stesse finalità didattiche dei grafici main, dati del nominale con carico |
| 8: segnali, We/Wu, norma, S/T | Recuperate spiegazioni e figura dei pesi tuttora identici | B: poli instabili aggiornati; nessuna equivalenza fra norma e target temporali |
| 8: pianta generalizzata, mixsyn/hinfsyn | Recuperati schema generalized_plant, partizione P1 e significato delle porte | B: dati e accordo numerico correnti |
| 8: modello desiderato, 2DoF | Recuperati risposta critica, mappe Tqr/Tqd/Tur/Tud e costo a blocchi; schema two_dof conservato | B: Mo=3; esclusa tabella delle vecchie sintesi Mo=2/3/4 |
| 8: PID con hinfstruct | Recuperati significato strutturale, tunablePID2 e formula PID 2DoF filtrato | C: escluse sei famiglie e dieci avvii storici, conservato solo protocollo effettivo a tre avvii |
| 8: tracking, disturbo e rumore | Curve S/T correnti e nuovo hinf_disturbi; definizioni picco/RMS/DC recuperate | B: numeri correnti; D: nessun vecchio progetto con rumore presentato come nuova sintesi |
| 9: struttura Delta, M-Delta/N-Delta | Recuperate partizione, ricostruzione LFT e schema ndelta_didactic | B: dimensione nDelta, parametri A/B; rimosse vecchie cinque incertezze |
| 9: definizione mu e limiti numerici | Recuperate definizione, interpretazione critica, struttura reale/dinamica e bounds | B: sette parametri A o massa/dinamiche B |
| 9: NS/NP/RS/RP | Recuperate definizioni estese, margini, blocco fittizio e schema performance | B: deduzioni RP da NP/RS dichiarate, nessun riordino degli intervalli |
| 9: D-K, ordine e post-analisi | Recuperato schema dk, spiegazione degli scaling e ordine; aggiunto riesame delle sei righe salvate | B: nessuna nuova sintesi; 294/80 stati e tutti i FAIL conservati |
| 10: scenari e stato completo | Recuperati coordinate assolute/incrementali, ingressi ignoti, interpretazione DC/finestra, picchi/RMS | B: due prove per candidato e tre masse, senza attribuire le vecchie ampiezze 2/8 gradi alla campagna corrente |
| 10: lineare/non lineare | Rigenerato lineare_nonlineare_lqg con medesimi ingressi e K | B: nominale con carico e traiettorie effettivamente integrate |
| 10: RAS e condizioni iniziali | Recuperata definizione nello stato aumentato e limiti delle sezioni; mantenuti 15 punti per candidato | C: esclusa lunga dimostrazione Lyapunov non certificante, senza nascondere convergenze/allontanamenti |
| 10: rumore encoder | Recuperate mappe Tuv/Tqv e interpretazione ZOH/intensità | B: picchi intercampione e RMS correnti; nessun vecchio seed attribuito alla prova nuova |
| 10: implementazioni Simulink | Recuperate viste autentiche Kalman, pianta non lineare e attuatori; conservate due viste LQGI | B: inizializzazione automatica nominale, collaudo campionato distinto; nessuna topologia ricostruita |
| 11: dieci impianti, stabilità, tracking, disturbo, interpretazione | Conservati cinque argomenti, tabelle e figure correnti | C/D: escluse campagne M4 e duplicazioni dei riferimenti; conteggio operativo 77 casi, non 154 |
| 12-13: confronto e conclusioni | Conservata lettura fisica A/B, ruoli delle famiglie e limiti | D: escluse conclusioni robuste riferite a incertezze diverse |
| Appendici: parametri, tracciabilità, riproducibilità, codici | Quattro appendici conservate | B: parametri e sorgenti correnti; C/D: esclusi estratti di orchestrazione obsoleti e tabella fissi dal corpo finale |

## Campagna corretta e limiti

Sette candidati predefiniti: LQG, LQGI, Hinf1, Hinf2, PID, Mu_A, Mu_B. `controllori_sea(p,true)` rende disponibili anche i riferimenti per un confronto mirato. La banca e i risultati precedenti restano recuperabili; nessun raddoppio predefinito di grafici, rumore o RAS. La cache robusta viene selezionata per nome e confrontata con i coefficienti effettivi, non rinominata.

Riesame di tutti i candidati salvati nella D-K: iniziale comune ordine 82, norma 1.0519, errore DC 3.823%; finali A/B ordine 294/80, norme 6.6543/1.4815 ed errori 99.8%/21.9%. Il costo esclude il rumore e We(0) non impone il 5%. Non è stata fatta una nuova sintesi indiscriminata. Una semplice approssimazione d'ordine non riprogetta tracking o penalizzazione del rumore, quindi non è stata usata per promuovere i candidati falliti. Nessun RP PASS; RS e target temporali conservano i rispettivi esiti, nessun limite hardware inventato. La copertura globale B e una RAS certificata restano non dimostrate.

## Verifiche della correzione

- Pipeline rapida rieseguita: nuova costruzione fisica, LFT, copertura e replay; nuove LQG/LQGI secondo il percorso esistente, Hinf/D-K/RS/RP/RAS caricati esplicitamente e controllati. Non sono state ripetute musyn o le 105 RAS.
- Cinque test seaFinaleTest e sette verifiche del runner superati. Stessi parametri fisici e stessi sette controllori principali.
- Otto SLX avviati singolarmente da path ripristinato: InitFcn attiva, nessun override del collaudatore, 2 s raggiunti, stati finiti e massa distale 1 kg. Questo dimostra l'inizializzazione nominale, non RS/RP o prestazione hardware.
- ZIP estratta fuori repository: rapida, 20 run campionati e otto avvii con callback attiva completati con exit code 0. Path del repository escluso da assert; sei CSV identici. Le prove autonome verificano massa, stati finiti e tempo finale, non i target.
- PDF finale 68 pagine: compilazione senza warning/overfull/riferimenti irrisolti; tutte le pagine renderizzate, controllo visivo e correzione degli schemi e dello sfondo delle nuove curve.
- Code Analyzer sui quattro sorgenti modificati: due suggerimenti non critici (isscalar e preallocazione di sei righe), nessun errore di sintassi. Non viene dichiarato un conteggio zero.
- Conservati i sei sorgenti della modellazione fisica/A-B byte per byte rispetto all'inizio della correzione. Gli otto SLX hanno identici conteggi e tipi di blocchi e linee; Simulink ha rinumerato soltanto gli identificatori generati interni dei MATLAB Function parametrizzati. Nessuna libreria o configurazione .satk aggiunta.

Le prime prove hanno rilevato un percorso temporaneo errato nel comando di ispezione, troncamenti di blocchi LaTeX al recupero, un controllo dell'esportatore ancora fissato a 28 righe e due condizioni del collaudatore incompatibili con l'uso InitFcn. Sono stati corretti, poi le prove interessate ripetute. Gli errori non hanno generato risultati scientifici promossi.


## Criteri di accettazione C01–C20

| Criterio | Evidenza della correzione | Esito |
|---|---|---|
| C01–C04 | Matrice per tutti i capitoli, derivazioni recuperate 5/7/8/9/10, lettura e compilazione | Attuato; revisione editoriale degli studenti |
| C05 | Esclusi blocchi di cronaca; nessun vecchio risultato presentato come corrente | Verificato |
| C06–C09 | Sei sorgenti fisici/A-B invariati, cinque test, LFT/replay/copertura rieseguiti | Verificato |
| C10–C11 | Sette candidati predefiniti, riferimenti opzionali, 77 casi lineari e sette prove di rumore | Verificato |
| C12–C14 | Sei righe D-K riesaminate; pesi/target discussi, FAIL conservati | Verificato; RP rimane FAIL |
| C15 | Otto avvii singoli in repository e nella ZIP; callback attiva | Verificato |
| C16 | Nessun nuovo modulo MATLAB, libreria, dipendenza o .satk | Verificato |
| C17 | Schemi recuperati e aggiornati, quattro nuove figure dagli stessi dati correnti | Verificato |
| C18–C19 | Medesimi campioni fisici, sei CSV riprodotti e nessun trasferimento di vecchi PASS | Verificato |
| C20 | Stesso ramo e PR #47; commit correttivi, nessun merge | Pubblicato sulla PR esistente; nessun merge |

Il recupero didattico riguarda gli argomenti elencati, non l'uguaglianza del numero di pagine o la reintroduzione di campagne obsolete. La valutazione editoriale finale spetta agli studenti; la consegna non dichiara risolti i limiti prestazionali.
