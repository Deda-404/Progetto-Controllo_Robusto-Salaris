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

## 7. LQRI: memoria dell’errore misurato — 1:00

L’integratore accumula l’errore misurato. Il prefiltro LQG non reagisce al disturbo; LQRI elimina l’offset DC ma è più lento. Il grafico proviene da MATLAB lineare.

## 8. $H_\infty$: sensibilità mista e pesi adottati — 1:05

Spiegare W1 e W2, l’assenza di W3 e la stessa formulazione risolta da mixsyn e hinfsyn. Gamma inferiore a uno non controlla direttamente overshoot e settling.

## 9. Due gradi di libertà: riferimento e feedback condividono gli stati — 1:05

Seguire i due rami nel diagramma. Kr e Ky condividono 22 stati. Mo impone la forma desiderata, il disturbo fisico entra nei link. Le norme di obiettivi diversi non sono rapporti di miglioramento.

## 10. Ordine completo e ordine fissato: il compromesso rimane — 0:55

Confrontare full-order e SS2 sullo stesso problema. Undici avvii non garantiscono ottimo globale. Il risultato di ordine 2 non eredita robustezza.

## 11. $\mu$-analysis: separare controllore e incertezza — 1:05

Distinguere LFT inferiore P-K e superiore N-Delta. Leggere la dimensione 5 di Delta e 9 di N: cinque canali incerti più quattro esogeni/prestazionali.

## 12. Quattro domande: NS, NP, RS, RP — 1:05

Mu usa la perturbazione destabilizzante più piccola compatibile con la struttura. Il blocco prestazionale è fittizio. Non confondere valori di mu e margini; si usano limiti numerici.

## 13. D--K iteration: sintesi, analisi, fit degli scaling — 1:10

Descrivere il ciclo: K fissato, scaling in frequenza; fit razionale, nuova sintesi. MixedMU conserva parametri reali e usa D/G. PeakMuFit differisce da PeakMu: il fit costa ordine.

## 14. La post-analisi cambia la scelta del controllore — 1:00

Leggere la soglia uno nel grafico. Hinf fallisce RS; il suo intervallo RP invertito non viene corretto artificialmente. Kmu supera i limiti inferiori su entrambe le proprietà.

## 15. Robustezza pesata e requisiti temporali non coincidono — 0:50

Ribadire che RP riguarda la norma pesata. Kmu rimane più lento di 0.8 s e il primo giunto supera il 5% di offset.

## 16. Verifiche complementari: campioni incerti e non linearità — 0:45

I campioni sono identici fra controllori. Quaranta successi non sono una probabilità né una garanzia universale. L’accordo locale non lineare è verificato in MATLAB.

## 17. Rumore, RAS e Lyapunov: limiti da dichiarare — 0:55

Non nascondere le coppie molto elevate. RAS empirica limitata al piano iniziale e al box; il residuo Lyapunov fallito impedisce un certificato Hinf.

## 18. Simulink: stato effettivo degli originali — 0:50

Essere espliciti sul requisito Simulink incompleto: file originali conservati, nessuna ricostruzione automatica. Servono interventi manuali e una versione compatibile, poi confronti e RAS.

## 19. Conclusioni: scelta per ruolo e attività residue — 0:40

Concludere sui ruoli dei controllori, senza dichiarare conformità completa o validazione hardware. Lasciare il margine per domande.
