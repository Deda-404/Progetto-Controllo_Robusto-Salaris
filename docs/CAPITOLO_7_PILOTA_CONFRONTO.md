# Capitolo 7 — intervento pilota da verificare

Il pilota riguarda esclusivamente il capitolo 7. Il riferimento didattico è il main dbf6f00; il confronto immediato è f81d4db. Non viene attribuita approvazione degli studenti al metodo editoriale. Gli altri capitoli, i controllori, gli script MATLAB, gli SLX, le specifiche, i pesi e i dati rimangono invariati. Il PDF integrale e lo ZIP della consegna non sono stati sostituiti durante il pilota.

Il risultato da leggere è `report/Capitolo_7_Pilota.pdf`, compilato da `report/capitolo7_pilota.tex` che include lo stesso `report/sections/07_lqg.tex` destinato alla relazione. Il fascicolo contiene il solo capitolo 7 e il suo indice, con la numerazione 7.x.

## Come è stato condotto il recupero

La base di lavoro è stato l'intero sorgente del main, non il riassunto della PR. Sono stati mantenuti i passaggi di motivazione, derivazione e interpretazione; i paragrafi incompatibili con i dati nuovi sono stati riscritti estesamente. Le matrici numeriche sono lette dai MAT attuali; le nuove curve usano risposte già salvate. Nessun controllore viene modificato o risintetizzato.

Un approfondimento non è considerato recuperato per la sola presenza del titolo. Nella matrice seguente è indicato il ragionamento effettivamente sviluppato. I casi in cui l'esperimento numerico originario non è riprodotto sono dichiarati come tali.

| Dimensione descrittiva | Main | Prima del pilota | Pilota |
|---|---:|---:|---:|
| Righe del capitolo | 613 | 384 | 867 |
| Sezioni e sottosezioni | 28 | 22 | 28, nello stesso ordine del main |

Le righe e le pagine non sono obiettivi di progetto né dimostrazioni di equivalenza didattica. Servono solo a rendere verificabile la consistenza materiale del pilota. La verifica decisiva è la lettura delle spiegazioni e delle figure sotto elencate.

## Confronto per ciascun approfondimento

| Riferimento nel pilota | Passaggio presente nel main | Sviluppo effettivo nel pilota e aggiornamento |
|---|---|---|
| 7.1 Obiettivo e architettura | LQR, quattro encoder, Kalman, prefiltro | Motivazione fisica della retroazione alla verticale instabile; distinzione fra stato disponibile nel progetto e misure disponibili; coordinate incrementali, carico nominale, percorso LQR → LQG → LQGI. |
| 7.2.1 Costo e unità | Costo quadratico, stato a 14 componenti, coordinate dei drive | Conservati costo e ordine completo; spiegato perché un'identità non motivata confronta impropriamente rad, rad/s e coordinate di realizzazione. Nessuna scala meccanica inventata per i sei stati dei drive. |
| 7.2.2 Scale | Provenienza di qs, qds e delta_s | Conservata la tabella; ripristinata la distinzione scala/peso relativo. Esempi: 5° e 2.5° normalizzati, velocità 12qs, deformazione sotto 0.5 N m, moto concorde link/rotore senza variazione elastica. |
| 7.2.3 Q non diagonale | F, Sx, Wq, Q=Ccost' Ccost | Tutti i passaggi mantenuti, incluse dimensioni 8×14 e 8×8. Espanso il quadrato della deformazione per spiegare il segno negativo dei termini misti senza confonderlo con un costo negativo. |
| 7.2.4 R | Coppia fisica, peso diretto, tre livelli | Conservati R=ru I, unità, interpretazione e livelli 0.01/0.05/0.10. Distinto il peso dalla saturazione; il candidato usa sempre 0.10. |
| 7.2.5 Ricerca e compromesso | Griglia finita, ammissibilità, score, grafico | Recuperati ragionamento sui 36 punti, protocollo di confronto separato sui due giunti, ammissibilità prima dello score, formula normalizzata e esempio delle priorità. La scansione sul nuovo carico NON è dichiarata eseguita. Il grafico numerico usa soltanto LQG/LQGI correnti, con didascalia esplicita. |
| 7.2.6 Riccati e matrici | CARE, Q/R/K/Nr, residui e poli | Ripristinate matrici numeriche Q8, K e Nr, aggiornate dai MAT del nominale con carico. Spiegati significato di P, blocco attuativo nullo, residuo e poli come verifiche diverse; derivato il prefiltro dall'equilibrio statico MIMO. |
| 7.3.1 Innovazione | Gw, rumore di processo/misura, osservatore | Conservati canali e ipotesi d'indipendenza; spiegato il confronto fra previsione e misura e il ruolo di L nella correzione dei diversi stati. |
| 7.3.2 Covarianze | Origine sigma, quadrato, intensità continue | Mantenuti i valori e le motivazioni fisiche; chiariti covarianza dei quattro ingressi rispetto a quella equivalente nello stato, rumore bianco ideale rispetto a campioni finiti e assenza di identificazione hardware. Rimossa soltanto la proporzione con una vecchia scala di coppia non adottata. |
| 7.3.3 Sensibilità Kalman | Matrice L, rapidità, rumore identico, H2 | Ripristinata L14×4 attuale. Spiegati error dynamics, ordine righe/colonne, velocità relativa e quadrato dei fattori su Rn. Cinque fattori, seed 20261101 e riferimento nullo sono quelli del CSV corrente; non il protocollo numerico del vecchio grafico. H2, RMS e picco rimangono distinti. |
| 7.3.4 Separazione | Matrice a 28 stati e coordinate dell'errore | Conservate e spiegate entrambe le forme; collegamento fra triangolarità e unione degli spettri. Specificati i 28 stati, il prefiltro statico e la portata nominale lineare del risultato. |
| 7.4.1 Tracking | Due gradini, assi, curve e metriche | Nuovo grafico dalle risposte salvate per entrambi gli assi; spiegazione separata del giunto comandato e di quello accoppiato. Dati correnti di assestamento, sovraelongazione, DC, cross e coppia, con unità e condizioni di prova. |
| 7.4.2 Disturbo | Due coppie sui link, offset e prefiltro | Ripristinata la spiegazione causale: r=0 rende Nr r nullo anche con errore; equilibrio sotto coppia distinto dal tracking nominale. Rimando puntuale al grafico corrente che mostra entrambi i disturbi e i due controllori. |
| 7.4.3 Stima e rumore | Errore stimato, differenza dei comandi, picchi | Ripristinata la lettura di errore di stima e tracking come quantità differenti, comando totale rispetto al solo contributo rumoroso e percorso innovazione → feedback → coppia. Dati RMS e picchi aggiornati. La vecchia traccia temporale di stima NON è trasferita al nuovo nominale. |
| 7.4.4 Poli e conclusioni | Grafico dei tre spettri, stabilità e RAS | Nuovo grafico dai coefficienti salvati, con tutti i 28 poli. Interpretazione degli assi, separazione e limiti delle conclusioni; NS, RS e costo comune distinti. Nessuna vecchia garanzia numerica ripristinata. |
| 7.5 Simulink | Equazioni di osservatore e feedback, modelli lineari/non lineari | Ripristinati flussi comando/misure e distinzione fra collaudo e prestazioni. Spiegati osservatore nominale sotto impianto perturbato, comando effettivo noto e inizializzazione in coordinate incrementali. Nessun SLX modificato o avviato nel pilota. |
| 7.6.1 Azione integrale | Offset, quattro misure, xi, modello interno, schema | Conservata la derivazione integrale e lo schema completo. Spiegati errore misurato rispetto a quello stimato, unità rad s, memoria non nulla a errore nullo e condizioni per l'equilibrio. |
| 7.6.2 Aumento | Aa/Ba/Br, 16 coordinate, PBH | Conservate matrici, dimensioni e condizione all'origine. La notazione x_aug evita di confondere la pianta aumentata con i sei stati attuativi xa. Nessuna nuova verifica PBH viene dichiarata effettuata durante la revisione. |
| 7.6.3 Costo integrale | Qi, livelli 20/200/800, significato | Recuperato il ragionamento sui livelli, senza inventare nuovi risultati per 20/800. Esempio fisico dell'errore di un grado persistente, crescita di xi e del costo quadratico; spiegato perché l'integratore non assicura maggiore rapidità. |
| 7.6.4 Riccati comune | Kx/Ki dalla stessa CARE e convenzione dei segni | Conservate equazioni, dimensioni e legge u=-Kx xhat-Ki xi; chiarito che Ki non viene assegnato a mano né corretto in base al suo segno numerico. |
| 7.6.5 Kalman riutilizzato | Realizzazione del controllore a 16 stati | Conservate matrici Ak/Bk/Ck e attraversamento nullo. Spiegato perché xi è già disponibile dalle misure e non deve essere stimata; stesso comando inviato alla pianta e al Kalman. |
| 7.6.6 Chiusura a 30 stati | Acl/Bcl, rumore nell'integratore, separazione e condizionamento | Tutte le matrici e il percorso delle perturbazioni mantenuti. Ripristinato il ragionamento sui poli ripetuti e sul residuo normalizzato; matrici Kx/Ki aggiornate dai MAT. Non attribuita al codice corrente una vecchia procedura di test non eseguita. |
| 7.6.7 Confronto LQG/LQGI | Disturbo, comando, tracking e stati integrali | Curve correnti e interpretazione estesa: comando permanente utile, precisione e lentezza, memoria del canale non comandato. La figura degli integratori usa una quadratura dichiarata dell'errore già salvato, non nuovi stati simulati. |
| 7.6.8 Risultati e limiti | DC/ultimo campione, FAIL, rumore, bias, saturazione e non lineare | Dati aggiornati su nominale e tre masse; assestamento LQGI FAIL mantenuto. Distinti offset a 12 s e DC, RS A/B e NP/RP, bias e anti-windup, grandezze assolute/incrementali e disturbi ignoti. |

Le righe 7.2, 7.3, 7.4 e 7.6 costituiscono i raggruppamenti delle sottosezioni, mantenuti nell'indice. La matrice distingue contenuto metodologico recuperato da esperimenti numerici non ripetuti: non certifica automaticamente l'equivalenza didattica, che rimane da valutare nella lettura del pilota.

## Figure: cosa è ripristinato e cosa non lo è

| Figura del main | Trattamento nel pilota |
|---|---|
| Trade-off di 36 costi LQR | Ragionamento e criteri recuperati; il vecchio insieme di punti non è usato. Figura 7.1 con due candidati correnti. La scansione numerica resta non riprodotta. |
| Priorità LQR selezionate | Figura 7.2 ridisegnata con le stesse priorità attuali, verificate tramite Q. |
| Sensibilità Kalman | Figura 7.3 aggiornata ai cinque fattori del CSV corrente, con tre pannelli: polo lento, errore RMS e coppia RMS. |
| Tracking LQG | Figura 7.4 dai due riferimenti nominali già salvati. |
| Disturbo LQG | Contenuto letto nella figura 7.7 corrente, che mostra anche LQGI e distingue entrambi i disturbi. |
| Traccia temporale di errore di stima e incremento di coppia | Non riutilizzata: non è disponibile una traccia aggiornata dello stesso esperimento nei dati correnti. Recuperate spiegazione, metriche attuali e lettura fisica; figura 7.3 non viene chiamata equivalente temporale di quella mancante. |
| Spettri LQG | Figura 7.5 aggiornata dai coefficienti salvati; controllata la trasformazione di separazione. |
| Architettura LQGI | Figura 7.6 originale pertinente conservata, senza modifiche. |
| Disturbo e comando LQG/LQGI | Figure 7.7 e 7.8 correnti, con interpretazione estesa. |
| Tracking LQGI e memorie | Figura 7.9 aggiornata: q/u dalle risposte salvate; xi ricostruita per quadratura trapezoidale dell'errore a 2 ms, dichiarata in didascalia. |

## Provenienza e verifiche

`report/figures/pilota_capitolo7/esporta.py` legge esclusivamente i dati correnti e scrive soltanto figure ed estratti LaTeX del capitolo 7. Non lancia MATLAB, non risolve Riccati, non modifica guadagni, non integra nuove traiettorie. La quadratura di xi e gli autovalori delle matrici salvate sono elaborazioni editoriali dichiarate. Gli hash delle fonti sono in `provenienza.json` nella stessa cartella.

Verifiche: compilazione del fascicolo, assenza di warning/overfull/riferimenti irrisolti, rendering e controllo visivo di tutte le pagine; confronto dei 28 percorsi dell'indice; identità SHA-256 di 561 file protetti (sorgenti MATLAB, SLX, MAT e tutti gli altri capitoli). Nessuna nuova campagna MATLAB/Simulink o sintesi è dichiarata eseguita.

Nella preparazione delle figure è stata corretta una conversione di tipo nel lettore Python: alcune matrici binarie esportate da MATLAB erano uint8 e l'operatore meno richiedeva il passaggio a double. Il grafico finale dei poli è stato rigenerato dopo aver verificato residuo di separazione e stabilità; nessun dato o modello originale è stato corretto. Le prime prove di compilazione sono state ripetute dopo la disponibilità degli asset grafici.

## Punto di arresto

Il pilota è pronto per la lettura degli studenti. Non è una dichiarazione di approvazione del metodo e non autorizza l'estensione agli altri capitoli. Il lavoro editoriale si ferma qui. La griglia numerica completa e la traccia temporale di stima sono esplicitamente non riprodotte; nessun vecchio PASS o risultato incompatibile viene presentato come attuale.
