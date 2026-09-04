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

La ricerca compatta confronta 36 combinazioni didattiche, ottenute da
`wq=[0.5,1,2]`, `wqdot=wthetaDot=[0.5,1]`, `wdelta=[0.1,0.5]` e
`rhoU=[4,8,16]`. Prima si applicano i vincoli M5; soltanto i candidati
ammissibili sono ordinati con uno score normalizzato che combina settling,
overshoot, errore statico, cross-coupling, picco e RMS del comando. Sono
ammissibili 9 candidati su 36 e viene selezionato `LQR30`.

Le correzioni adimensionali selezionate sono

\[
w_q=2,\quad w_{\dot q}=1,\quad w_{\theta-q}=0.1,\quad
w_{\dot\theta}=1.
\]

Gli stati interni degli attuatori non ricevono pesi arbitrari diretti. Per il comando si usa

\[
R=\frac{16}{u_{scale}^2}I_2=0.111111I_2.
\]

Questa è l'unica ricerca LQR aperta dalla revisione: non modifica M5 e non
coinvolge Khinf o Kmu. Non esistono griglie estese né una seconda iterazione
di retuning.

## Filtro di Kalman

L'osservatore usa due canali di coppia ai link e due canali equivalenti all'ingresso come disturbi di processo. Le deviazioni standard dichiarate sono 0.1 N m per entrambi i tipi; il rumore delle quattro misure è 0.05°. Quindi

\[
Q_n=0.1^2I_4,\qquad R_n=(0.05\pi/180)^2I_4.
\]

Aumentare `Qn/Rn` rende l'osservatore più rapido e più sensibile al rumore;
ridurlo fa l'opposto. La scelta nominale produce un rapporto fra velocità
minima dello stimatore e del regolatore pari a 1.510. La sensibilità
`sigmaY=[0.025,0.05,0.10]` gradi conferma il compromesso: il rapporto di
velocità passa da 2.112 a 1.192 mentre il guadagno dell'osservatore e la
trasmissione del rumore diminuiscono.

## Separation principle e risultati

Il controllore usa `u=-K xhat + Nr r`. I poli dell'anello LQG coincidono con l'unione dei poli di `A-BK` e `A-LC` entro la tolleranza numerica. Il controllore ha ordine 14 e nessun integratore.

Sul tracking nominale lineare il settling peggiore è 0.678 s, l'overshoot è
0.404%, il cross-coupling peggiore è 0.169 e il comando massimo è 4.511 N m;
RMS ed energia del comando sono rispettivamente 0.626 N m e 2.332 N m^2 s.
Il disturbo costante lascia un offset, comportamento atteso senza azione
integrale. Le prove di rumore sono riproducibili con seed 20260826.

Il controllore selezionato diventa il nuovo artifact M6 di riferimento. Dopo
questa scelta `K`, `L` e `Nr` vengono mantenuti invariati nelle verifiche
M7-M18; non è eseguito alcun retuning successivo.
