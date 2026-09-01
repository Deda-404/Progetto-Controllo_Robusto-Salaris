# Dinamica degli attuatori

## Obiettivo

Il comando `u` non agisce istantaneamente sul manipolatore: attraversa la dinamica chiusa del drive e un ritardo prima di diventare la coppia motore `tau`. Il modello per ciascun giunto è

\[
G_a(s)=\frac{\omega_n^2}{s^2+2\zeta\omega_n s+\omega_n^2}e^{-\tau_ds}.
\]

`Jm` e `Bm` restano nel modello meccanico SEA: il blocco attuatore non li duplica.

## Significato dei parametri

- `wn` stabilisce la scala di rapidità e la banda del drive. Un valore troppo basso rallenta la stabilizzazione; uno troppo alto nasconde dinamiche non modellate e si avvicina ai modi elastici.
- `zeta` controlla smorzamento e overshoot. `zeta=0.8` dà una risposta rapida ma ben smorzata.
- `delay` sottrae fase in modo crescente con la frequenza. Il nominale di 15 ms è abbastanza piccolo alle frequenze dei poli instabili, ma non trascurabile verso i modi elastici.

## Scelta ingegneristica

Sono adottati direttamente

\[
\omega_n=40\ \mathrm{rad/s},\qquad \zeta=0.8,\qquad
\tau_d=0.015\ \mathrm{s}.
\]

La pianta meccanica ha il polo instabile dominante a 7.209 rad/s e il primo modo elastico a 69.95 rad/s. La banda dell'attuatore risultante, 34.78 rad/s, è quindi nettamente sopra la scala instabile e sotto la prima risonanza elastica. MATLAB confronta soltanto tre casi espliciti (`slow`, `nominal`, `fast`) per rendere visibile questo compromesso; non esegue un ranking.

La scelta nominale produce rise time 0.0626 s, settling 0.109 s e overshoot 1.47%. Il secondo ordine ha poli `-32 ± 24j`.

## Padé del primo ordine

Per le sintesi serve un modello razionale. Si usa

\[
e^{-\tau_ds}\simeq\frac{1-\tau_ds/2}{1+\tau_ds/2}.
\]

L'ordine uno mantiene il modello contenuto e riproduce molto bene la fase nella zona dei poli instabili. A 80 rad/s l'errore di fase è 6.83°, quindi il limite dell'approssimazione resta esplicito. Lo zero in `+133.33` rad/s è non minimum-phase, mentre il polo corrispondente è stabile.

## Verifica MATLAB e risultato

`build_nominal_actuator.m` costruisce il modello; `validate_m3_nominal_actuated_plant.m` usa `stepinfo`, `bandwidth`, risposta in frequenza e confronto di fase. Due copie diagonali forniscono sei stati attuativi; con gli otto stati meccanici la pianta completa ha 14 stati, due ingressi e quattro misure `[q;theta]`.

La cascata esplicita coincide numericamente con `series` e la pianta è stabilizzabile e rilevabile. I valori scelti sono assunzioni nominali di progetto, non parametri identificati.
