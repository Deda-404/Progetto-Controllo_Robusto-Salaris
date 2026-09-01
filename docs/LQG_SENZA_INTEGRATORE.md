# LQG nominale senza integratore

## Obiettivo e teoria

Il regolatore LQR minimizza

\[
J=\int_0^\infty (x^TQx+u^TRu)\,dt.
\]

Un peso maggiore in `Q` forza maggiormente gli stati corrispondenti; un peso maggiore in `R` riduce lo sforzo di controllo. Il progetto usa tutti i 14 stati della pianta M3, ma misura soltanto le quattro posizioni encoder `[q;theta]`.

## Normalizzazione fisica

La matrice `Q=Ccost'*Ccost` nasce da scale leggibili secondo la logica di Bryson:

- posizione: riferimento nominale di 5°;
- velocità: `omegaB` per la scala di posizione;
- deformazione SEA: coppia di disturbo divisa per la rigidezza minima;
- velocità motore: stessa scala cinetica usata per i link.

Le correzioni adimensionali finali sono

\[
w_q=1,\quad w_{\dot q}=0.5,\quad w_{\theta-q}=0.1,\quad
w_{\dot\theta}=0.5.
\]

Gli stati interni degli attuatori non ricevono pesi arbitrari diretti. Per il comando si usa

\[
R=\frac{8}{u_{scale}^2}I_2.
\]

Questa è l'unica scelta approvata. Non esistono griglie `coarse/extended` né ranking.

## Filtro di Kalman

L'osservatore usa due canali di coppia ai link e due canali equivalenti all'ingresso come disturbi di processo. Le deviazioni standard dichiarate sono 0.1 N m per entrambi i tipi; il rumore delle quattro misure è 0.05°. Quindi

\[
Q_n=0.1^2I_4,\qquad R_n=(0.05\pi/180)^2I_4.
\]

Aumentare `Qn/Rn` rende l'osservatore più rapido e più sensibile al rumore; ridurlo fa l'opposto. La scelta finale produce un rapporto fra velocità minima dello stimatore e del regolatore pari a 1.693.

## Separation principle e risultati

Il controllore usa `u=-K xhat + Nr r`. I poli dell'anello LQG coincidono con l'unione dei poli di `A-BK` e `A-LC` entro la tolleranza numerica. Il controllore ha ordine 14 e nessun integratore.

Sul tracking nominale il settling peggiore è 0.776 s, l'overshoot rispetta il 10% e il comando massimo è 4.69 N m, pari a 0.391 della scala prestazionale. Il disturbo costante lascia un offset, comportamento atteso senza azione integrale. Le prove di rumore sono riproducibili con seed 20260826.

Il controllore M6 resta congelato; il refactoring ha cambiato il metodo di esposizione e verifica, non `K`, `L` o `Nr`.
