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
`ru=[0.01,0.05,0.10]`. Prima si applicano i vincoli M5; soltanto i candidati
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
R=r_u I_2,\qquad r_u=0.10.
\]

La griglia diretta è stata realmente rieseguita. Il candidato LQR30 resta selezionato, con Q invariata e nuovi R, K e Nr. Non si tratta di una parametrizzazione equivalente. Le verifiche dipendenti sono rigenerate; non sono modificati criteri, scala di velocità o covarianze Kalman.

## Filtro di Kalman

L'osservatore usa due canali di coppia ai link e due canali equivalenti all'ingresso come disturbi di processo. Le deviazioni standard dichiarate sono 0.1 N m per entrambi i tipi; il rumore delle quattro misure è 0.05°. Quindi

\[
Q_n=0.1^2I_4,\qquad R_n=(0.05\pi/180)^2I_4.
\]

Aumentare `Qn/Rn` rende l'osservatore più rapido e più sensibile al rumore;
ridurlo fa l'opposto. La scelta nominale produce un rapporto fra velocità
minima dello stimatore e del regolatore pari a circa 1.4985. La matrice L e le covarianze sono identiche alla baseline; il rapporto cambia per effetto dei nuovi poli LQR. La sensibilità a rumore applicato identico è conservata e rigenerata.

## Separation principle e risultati

Il controllore usa `u=-K xhat + Nr r`. I poli dell'anello LQG coincidono con l'unione dei poli di `A-BK` e `A-LC` entro la tolleranza numerica. Il controllore ha ordine 14 e nessun integratore.

Sul tracking nominale lineare il candidato selezionato supera i target M5. I valori correnti sono esportati in `report/generated/lqr_matrices.tex`, nelle macro M18 e in `results/data/direct_weights_summary.mat`. Il disturbo costante lascia un offset, atteso senza azione integrale. Le prove di rumore sono riproducibili con seed 20260826.

Il controllore selezionato diventa il nuovo artifact M6 di riferimento. Dopo
questa scelta `K`, `L` e `Nr` vengono mantenuti invariati nelle verifiche
M7-M18; non è eseguito alcun retuning successivo.
