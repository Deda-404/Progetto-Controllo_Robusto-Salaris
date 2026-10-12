# Note per l’esposizione

Durata prevista 17:50. Prima della consegna fare una prova cronometrata. La lettura dei risultati segue modello, protocollo e limite della conclusione.

## 1. Titolo — 0:20

Presentare il problema e anticipare la distinzione fra risultati MATLAB e stato dei modelli originali.

## 2. SEA: otto stati meccanici, due poli instabili — 0:45

Spiegare la trasmissione elastica e la differenza fra q e theta. Il disturbo agisce direttamente sul link.

## 3. Sei stati di attuatore completano il modello — 0:45

Contare gli stati: 8 meccanici più 3 per ciascun attuatore. Il ritardo è approssimato con Padé; distinguere inviluppo campionato e insieme incerto.

## 4. Specifiche: norma pesata e tracking sono verifiche diverse — 0:35

Richiamare solo i tre target obbligatori. La scala 12 N m serve al confronto; non simula una saturazione.

## 5. LQR: il costo deriva dalle grandezze fisiche — 0:55

Mostrare come la deformazione elastica produce termini incrociati in Q. Le scale hanno origine fisica, i pesi esprimono priorità progettuali.

## 6. LQG: quattro encoder e stato stimato — 0:50

Il controllo usa xhat, non lo stato completo disponibile nel simulatore. Qn e Rn sono ipotesi; distinguere intensità continua e sequenza discreta di rumore. Il principio di separazione è nominale.

## 7. LQGI: memoria dell’errore misurato — 0:50

LQGI = LQR + Kalman + integratore. L’integratore accumula l’errore misurato;
Kx usa esclusivamente xhat. Il prefiltro LQG non reagisce al disturbo.
Il grafico aggiornato viene dalle equazioni MATLAB non lineari; DC nullo è
invece la verifica lineare. Il residuo a 8 s è distinto dal limite asintotico.

## 8. $H_\infty$: sensibilità mista e pesi adottati — 0:55

Spiegare W1 e W2, l’assenza di W3 e la stessa formulazione risolta da mixsyn e hinfsyn. Gamma inferiore a uno non controlla direttamente overshoot e settling.

## 9. Due gradi di libertà, stati condivisi — 1:05

Seguire i due rami: Kr e Ky condividono 22 stati. Mo descrive il tracking
desiderato. Con omegaM=2/3/4, Ts=2.918/1.944/1.460 s: tutti violano 0.8 s,
ma 4 minimizza la violazione; non minimizza gamma. Picco ed errore statico
aumentano. A r=0 il feedback può ancora comandare per disturbi o stati iniziali.

## 10. Ordine completo e ordine fissato: il compromesso rimane — 0:45

Confrontare full-order e SS2 sullo stesso problema. Undici avvii non garantiscono ottimo globale. Il risultato di ordine 2 non eredita robustezza.

## 11. $\mu$-analysis: separare controllore e incertezza — 0:55

Distinguere LFT inferiore P-K e superiore N-Delta. Leggere la dimensione 5 di Delta e 9 di N: cinque canali incerti più quattro esogeni/prestazionali.

## 12. $\mu$: valore singolare strutturato — 1:00

µ è l'inverso della minima dimensione critica, rispettando la struttura.
H=N11 ha dimensione 5, mentre N completa ha dimensione 9. µ grande significa
che basta poco scostamento. Non è una probabilità. robstab verifica stabilità,
robgain(CL,1) la mappa pesata. Si usano bound: margine inferiore sopra uno
garantisce la proprietà; un upper sotto uno la esclude.

## 13. D--K iteration: sintesi, analisi, fit degli scaling — 1:00

Descrivere il ciclo: K fissato, scaling in frequenza; fit razionale, nuova sintesi. MixedMU conserva parametri reali e usa D/G. PeakMuFit differisce da PeakMu: il fit costa ordine.

## 14. La post-analisi cambia la scelta del controllore — 0:50

Leggere la soglia uno nel grafico. Hinf fallisce RS; il suo intervallo RP invertito non viene corretto artificialmente. Kmu supera i limiti inferiori su entrambe le proprietà.

## 15. Robustezza pesata e requisiti temporali non coincidono — 0:45

Ribadire che RP riguarda la norma pesata. Kmu rimane più lento di 0.8 s e il primo giunto supera il 5% di offset.

## 16. Dieci impianti incerti: nominale e campioni comuni — 0:50

Dire che abbiamo generato dieci realizzazioni nuove con seed 20261012. Entrambi i controllori usano le stesse piante: tre parametri reali e due perturbazioni dinamiche attuative. Il nominale è stabile per entrambi; H∞ è instabile in tutti i dieci campioni, Kµ stabile in tutti. Questi conteggi non sono probabilità e non sostituiscono robstab/robgain.

## 17. Tracking e disturbi sugli impianti incerti — 1:00

Leggere prima il tracking: le curve chiare rappresentano la dispersione dei dieci impianti Kµ. H∞ è mostrato solo nel nominale, perché una chiusura instabile non riceve un tempo di assestamento valido. Poi il disturbo: 0.5 N m su un link alla volta da 1 s, riferimento nullo. I pannelli mostrano il giunto stimolato; il massimo sulle due posizioni arriva a 19.3 gradi nei campioni, come indicato nel testo e nella tabella della relazione. Recupero nella fascia ±0.5 gradi e offset a 8 s sono distinti; un offset fuori banda non è recupero. Le specifiche temporali restano parzialmente fallite.

## 18. Il rumore encoder produce impulsi fra i campioni — 1:15

La prova isola il rumore: riferimento, disturbo e processo nulli. Sigma è 0.05 gradi per campione, mantenuto per 2 ms. Il segno negativo è già in Ky, quindi il feedback nella formula ha segno positivo. Il solo grafico a 2 ms perde impulsi: H∞ raggiunge circa 4.93×10^5 N m con RMS integrato 1.32×10^4; Kµ circa 87.1 N m e 8.29 RMS. H∞ ha feedthrough nullo, ma modi molto rapidi. Il picco è osservato su una scansione, non un massimo globale certificato. Sono richieste del modello, prive di limiti hardware; non abbiamo aggiunto filtri o saturazioni.

## 19. RAS empirica e insieme interno di Lyapunov — 1:05

V è una distanza quadratica nello stato completo: pianta, attuatori e controllore, con osservatore/integratori quando presenti. La derivata contiene la parte lineare negativa e il resto non lineare. LQG e LQGI superano il gate numerico e forniscono insiemi interni molto piccoli. Per gli altri si legge la tabella della relazione. La griglia è identica, 25 punti nel box ±60 gradi: il bordo è solo il limite della ricerca. Verde significa criterio fisico rispettato nell’ultimo secondo di 12 s; rosso criterio non raggiunto; arancio solver o ampiezza numerica, convergenza ignota. Nessuna probabilità o garanzia hardware.

## 20. Gli otto Simulink originali degli studenti — 0:45

Tutti gli otto modelli manuali sono presenti: LQG, LQGI, H∞ e µ, lineari e non lineari. I tre hash coincidono per ciascun file. L’audit XML mostra già errore misurato LQGI, quattro ingressi 2-DoF e Kµ presente; non si devono applicare istruzioni di correzione riferite ad altri file. L’ambiente R2025b rifiuta questi R2026a: simulazioni e immagini autentiche richiedono la release corretta. Il setup è esterno e i modelli restano invariati.

## 21. Conclusioni e limiti verificati — 0:40

Concludere per ruolo: LQG è il riferimento nominale, LQGI annulla il disturbo DC con risposta lenta, H∞ mostra i benefici e i limiti del progetto nominale, Kµ conserva i margini robusti nel modello dichiarato. Il rumore e i target temporali restano problemi reali. Prima della consegna servono i run degli otto originali su R2026a, le schermate autentiche leggibili, matricole/data e prova orale. Non dichiarare il progetto pronto per l’hardware.

## Slide opzionale autentica — 0:30

Se l’esportazione R2026a è disponibile, indicare il percorso r−q_mis, integratore, Kalman e comando stimato sul diagramma reale LQGI. Non presentare una miniatura illeggibile o uno schema ricostruito come schermata Simulink.
