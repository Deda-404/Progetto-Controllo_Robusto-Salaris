# Note per l’esposizione

La scaletta è una stima da verificare con una prova orale cronometrata. Non leggere tutte le formule: indicare ingresso, uscita e significato fisico.

## 1. Titolo — 0:20

Presentare il problema e anticipare la distinzione fra risultati MATLAB e stato dei modelli originali.

## 2. SEA: otto stati meccanici, due poli instabili — 0:55

Spiegare la trasmissione elastica e la differenza fra q e theta. Il disturbo agisce direttamente sul link.

## 3. Sei stati di attuatore completano il modello — 0:55

Contare gli stati: 8 meccanici più 3 per ciascun attuatore. Il ritardo è approssimato con Padé; distinguere inviluppo campionato e insieme incerto.

## 4. Specifiche: norma pesata e tracking sono verifiche diverse — 0:40

Richiamare solo i tre target obbligatori. La scala 12 N m serve al confronto; non simula una saturazione.

## 5. LQR: il costo deriva dalle grandezze fisiche — 1:00

Mostrare come la deformazione elastica produce termini incrociati in Q. Le scale hanno origine fisica, i pesi esprimono priorità progettuali.

## 6. LQG: quattro encoder e stato stimato — 1:00

Il controllo usa xhat, non lo stato completo disponibile nel simulatore. Qn e Rn sono ipotesi; distinguere intensità continua e sequenza discreta di rumore. Il principio di separazione è nominale.

## 7. LQGI: memoria dell’errore misurato — 1:00

LQGI = LQR + Kalman + integratore. L’integratore accumula l’errore misurato;
Kx usa esclusivamente xhat. Il prefiltro LQG non reagisce al disturbo.
Il grafico aggiornato viene dalle equazioni MATLAB non lineari; DC nullo è
invece la verifica lineare. Il residuo a 8 s è distinto dal limite asintotico.

## 8. $H_\infty$: sensibilità mista e pesi adottati — 1:05

Spiegare W1 e W2, l’assenza di W3 e la stessa formulazione risolta da mixsyn e hinfsyn. Gamma inferiore a uno non controlla direttamente overshoot e settling.

## 9. Due gradi di libertà e confronto Mo — 1:15

Seguire i due rami: Kr e Ky condividono 22 stati. Mo descrive il tracking
desiderato. Con omegaM=2/3/4, Ts=2.918/1.944/1.460 s: tutti violano 0.8 s,
ma 4 minimizza la violazione; non minimizza gamma. Picco ed errore statico
aumentano. A r=0 il feedback può ancora comandare per disturbi o stati iniziali.

## 10. Ordine completo e ordine fissato: il compromesso rimane — 0:55

Confrontare full-order e SS2 sullo stesso problema. Undici avvii non garantiscono ottimo globale. Il risultato di ordine 2 non eredita robustezza.

## 11. $\mu$-analysis: separare controllore e incertezza — 1:05

Distinguere LFT inferiore P-K e superiore N-Delta. Leggere la dimensione 5 di Delta e 9 di N: cinque canali incerti più quattro esogeni/prestazionali.

## 12. µ: valore singolare strutturato — 1:15

µ è l'inverso della minima dimensione critica, rispettando la struttura.
H=N11 ha dimensione 5, mentre N completa ha dimensione 9. µ grande significa
che basta poco scostamento. Non è una probabilità. robstab verifica stabilità,
robgain(CL,1) la mappa pesata. Si usano bound: margine inferiore sopra uno
garantisce la proprietà; un upper sotto uno la esclude.

## 13. D--K iteration: sintesi, analisi, fit degli scaling — 1:10

Descrivere il ciclo: K fissato, scaling in frequenza; fit razionale, nuova sintesi. MixedMU conserva parametri reali e usa D/G. PeakMuFit differisce da PeakMu: il fit costa ordine.

## 14. La post-analisi cambia la scelta del controllore — 1:00

Leggere la soglia uno nel grafico. Hinf fallisce RS; il suo intervallo RP invertito non viene corretto artificialmente. Kmu supera i limiti inferiori su entrambe le proprietà.

## 15. Robustezza pesata e requisiti temporali non coincidono — 0:50

Ribadire che RP riguarda la norma pesata. Kmu rimane più lento di 0.8 s e il primo giunto supera il 5% di offset.

## 16. Verifiche complementari: campioni incerti e non linearità — 0:45

I campioni sono identici fra controllori. Quaranta successi non sono una probabilità né una garanzia universale. L’accordo locale non lineare è verificato in MATLAB.

## 17. Rumore, RAS e Lyapunov — 1:05

LQGI aggiunge 57/57 punti convergenti e raggiunge il bordo del box: non è
una frontiera fisica né una regione operativa con saturazioni. Comando fino
a 240 N m. Le prove di rumore hanno quattro encoder per LQGI e due per
Hinf/Kmu: specificare il protocollo, senza fare una graduatoria universale.
Il residuo Lyapunov fallito impedisce un certificato Hinf; per LQGI non è calcolato.

## 18. Simulink: stato effettivo degli originali — 0:50

Sei originali, lineari e non lineari, conservati con SHA-256. Kx usa già xhat,
ma l'integratore usa la posizione ideale: spostarlo sul segnale misurato.
Correggere rumori indipendenti e coppia lato link. Release R2026a o esportazione
compatibile. Istruzioni con SID in docs/CORREZIONI_SIMULINK_LQGI.md. Nessuna
simulazione degli originali è validata; manca un originale Kmu del gruppo.

## 19. Conclusioni: scelta per ruolo e attività residue — 0:40

Concludere sui ruoli dei controllori, senza dichiarare conformità completa o validazione hardware. Lasciare il margine per domande.
