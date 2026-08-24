# Equilibrio, linearizzazione e analisi strutturale M2

## Ambito

M2 usa esclusivamente il modello meccanico nominale SEA a otto stati validato
in M1. La fase determina un equilibrio statico, linearizza esattamente l'RHS
M1, costruisce due configurazioni di uscita e verifica poli, controllabilità,
stabilizzabilità, osservabilità, rilevabilità e accordo locale LTI/non lineare.

Non sono incluse dinamiche esterne degli attuatori, ritardo, incertezze o
controllori.

## Equilibrio statico generale

Per una configurazione di link assegnata \(\bar q\), si impongono velocità e
accelerazioni nulle. Le equazioni M1 diventano

\[
G(\bar q)=K_s(\bar\theta-\bar q), \qquad
\bar\tau=K_s(\bar\theta-\bar q).
\]

Poiché \(K_s\) è invertibile,

\[
\bar\theta=\bar q+K_s^{-1}G(\bar q), \qquad
\bar\tau=G(\bar q),
\]

e

\[
\bar x=[\bar q;0;\bar\theta;0].
\]

`sea_static_equilibrium` implementa queste relazioni per qualunque \(\bar q\)
2×1 e verifica il risultato richiamando direttamente
`sea_nonlinear_rhs(\bar x,\bar\tau,p)`.

## Equilibrio scelto

Il candidato verticale superiore è

\[
\bar q=\begin{bmatrix}\pi/2\\0\end{bmatrix}\ \mathrm{rad}.
\]

La valutazione numerica autonoma produce

\[
G(\bar q)=\bar\tau=
\begin{bmatrix}
5.766616847825057\times10^{-16}\\
1.4416542119562643\times10^{-16}
\end{bmatrix}\ \mathrm{N\,m},
\]

\[
\bar\theta=
\begin{bmatrix}
1.5707963267948966\\
3.6041355298906603\times10^{-18}
\end{bmatrix}\ \mathrm{rad},
\]

\[
\bar x=
\begin{bmatrix}
1.5707963267948966&0&0&0&
1.5707963267948966&3.6041355298906603\times10^{-18}&0&0
\end{bmatrix}^T.
\]

La norma euclidea del residuo del modello non lineare è

\[
\|f(\bar x,\bar\tau)\|_2=5.8387489976584098\times10^{-14},
\]

inferiore alla tolleranza \(10^{-10}\). I valori non esattamente nulli
derivano dalla rappresentazione floating-point di \(\pi/2\), non da termini
imposti nel codice. L'equilibrio è fisicamente significativo e l'analisi dei
poli conferma che pone un problema di stabilizzazione open-loop non banale;
la scelta è quindi approvata in D-0003.

## Modello incrementale

Si definiscono

\[
\Delta x=x-\bar x, \qquad \Delta\tau=\tau-\bar\tau,
\]

e il modello del primo ordine

\[
\Delta\dot x=A\Delta x+B\Delta\tau,
\]

con

\[
A=\left.\frac{\partial f}{\partial x}\right|_{\bar x,\bar\tau},
\qquad
B=\left.\frac{\partial f}{\partial\tau}\right|_{\bar x,\bar\tau}.
\]

`sea_linearize_symbolic` costruisce simbolicamente l'RHS richiamando le
funzioni M1 e valuta i Jacobiani al punto di lavoro. Le matrici numeriche sono

\[
A=\begin{bmatrix}
0&0&1&0&0&0&0&0\\
0&0&0&1&0&0&0&0\\
-287.975&563.713333333333&0&0&312.5&-583.333333333333&0&0\\
704.641666666667&-1838.18666666667&0&0&-729.166666666667&1916.66666666667&0&0\\
0&0&0&0&0&0&1&0\\
0&0&0&0&0&0&0&1\\
5000&0&0&0&-5000&0&-2&0\\
0&4000&0&0&0&-4000&0&-2
\end{bmatrix},
\]

\[
B=\begin{bmatrix}
0&0\\0&0\\0&0\\0&0\\0&0\\0&0\\100&0\\0&100
\end{bmatrix}.
\]

Entrambe sono finite e hanno dimensioni rispettivamente 8×8 e 8×2.

## Verifica indipendente dei Jacobiani

`finite_difference_jacobian` applica differenze finite centrate direttamente
all'RHS M1, senza condividere espressioni Jacobiane con la derivazione
simbolica. Il passo assoluto \(h=3\times10^{-6}\) bilancia troncamento e
cancellazione numerica; è stato selezionato mediante una scansione
deterministica del passo.

| Metrica | \(A\) | \(B\) | Criterio |
| --- | ---: | ---: | ---: |
| errore assoluto massimo | \(4.125922714592889\times10^{-8}\) | 0 | \(\le10^{-6}\) |
| errore di Frobenius | \(6.1244117265199256\times10^{-8}\) | 0 | \(\le10^{-6}\) |
| errore relativo di Frobenius | \(6.4229732628019935\times10^{-12}\) | 0 | \(\le10^{-9}\) |

## Uscite e misure

L'uscita primaria di prestazione è la posizione dei link:

\[
y_q=q,\quad
C_q=\begin{bmatrix}I_2&0_{2\times6}\end{bmatrix},\quad
D_q=0_{2\times2}.
\]

La misura candidata approvata per il futuro estimatore è costituita dalle
quattro posizioni ottenibili con encoder lato link e motore:

\[
y_{meas}=\begin{bmatrix}q\\\theta\end{bmatrix},\quad
C_{meas}=\begin{bmatrix}
I_2&0&0&0\\
0&0&I_2&0
\end{bmatrix},\quad
D_{meas}=0_{4\times2}.
\]

Le velocità non sono assunte misurate; saranno oggetto di stima nelle fasi
successive. `Gmech_state=ss(A,B,Cmeas,Dmeas)` e
`Gmech_q=ss(A,B,Cq,Dq)` sono entrambi modelli meccanici di ordine 8 e non
includono gli attuatori esterni di M3.

## Poli open-loop

La classificazione usa \(10^{-8}\ \mathrm{s}^{-1}\) come fascia marginale.

| # | Polo [s⁻¹] | Classe |
| ---: | ---: | --- |
| 1–2 | \(-0.683828559885 \pm 79.4003109267j\) | stabile |
| 3–4 | \(-0.961872494974 \pm 69.9477228456j\) | stabile |
| 5 | \(7.20942861374\) | instabile |
| 6 | \(4.04083356564\) | instabile |
| 7 | \(-7.88550918251\) | stabile |
| 8 | \(-4.07335088716\) | stabile |

Risultano 6 poli stabili, 2 instabili e nessun polo marginale. La massima
parte reale è \(7.20942861374\ \mathrm{s}^{-1}\), quindi il candidato
verticale superiore è open-loop instabile come dedotto dal nostro modello.

La figura originale è rigenerata in
`results/figures/m2_open_loop_poles.png`.

## Controllabilità e stabilizzabilità

Per \(\mathcal C=\operatorname{ctrb}(A,B)\), il rango è calcolato dalla SVD
con tolleranza esplicita

\[
t_{svd}=\max(m,n)\,\operatorname{eps}(\sigma_{max}).
\]

| Metrica | Valore |
| --- | ---: |
| rango SVD | 8/8 |
| tolleranza | 0.25 |
| \(\sigma_{min}(\mathcal C)\) | 433.21929998023779 |
| numero di condizionamento | \(2.9957229275929797\times10^{11}\) |

Il numero di condizionamento segnala una forte differenza di scala nelle
potenze di \(A\), ma il minimo singolare resta molto sopra la tolleranza. Il
PBH sui due modi instabili restituisce rango 8/8 in entrambi i casi; i minimi
singolari sono 0.635221991708346 e 0.385353964545422, contro tolleranze
\(9.09494701772928\times10^{-12}\). Il modello è quindi controllabile e, in
particolare, stabilizzabile.

## Osservabilità e rilevabilità

Per \(C_{meas}\):

| Metrica | Valore |
| --- | ---: |
| rango SVD | 8/8 |
| tolleranza | 0.0078125 |
| \(\sigma_{min}(\mathcal O)\) | 3101.1254321359797 |
| numero di condizionamento | \(4.2585425124850553\times10^8\) |

Il PBH sui due poli instabili ha rango 8/8, minimi singolari
0.137308853790714 e 0.236897379586997 e tolleranza
\(1.09139364212751\times10^{-11}\). La misura \([q;\theta]\) è dunque
osservabile e rilevabile ed è approvata in D-0004.

Anche il caso informativo con la sola \(q\) ha rango 8/8, tolleranza
0.0009765625, \(\sigma_{min}=186.72810017380434\), condizionamento
\(1.9069768020462918\times10^9\) e supera il PBH di rilevabilità. Non viene
però adottato come misura principale in M2: conservare anche \(\theta\) offre
accesso diretto alla deformazione elastica senza assumere velocità misurate.

## Validazione locale LTI/non lineare

La verifica usa direzioni deterministiche non nulle per stato e coppia. Per
ogni ampiezza \(\varepsilon\) confronta

\[
f(\bar x+\varepsilon d_x,\bar\tau+\varepsilon d_\tau)
\quad\text{e}\quad
A\varepsilon d_x+B\varepsilon d_\tau.
\]

| \(\varepsilon\) | Errore assoluto | Errore relativo | Ordine verso il caso successivo |
| ---: | ---: | ---: | ---: |
| \(10^{-2}\) | \(1.1089741907062683\times10^{-4}\) | \(2.4191298402277601\times10^{-6}\) | 2.9999972 |
| \(10^{-3}\) | \(1.1089813179803198\times10^{-7}\) | \(2.4191431322431786\times10^{-8}\) | 2.9999962 |
| \(10^{-4}\) | \(1.1089909571529759\times10^{-10}\) | \(2.4191641366772758\times10^{-10}\) | 2.7939189 |
| \(10^{-5}\) | \(1.7824161749622497\times10^{-13}\) | \(3.8881807456371769\times10^{-12}\) | — |

L'errore decresce monotonicamente più rapidamente del primo ordine lungo la
direzione verificata, confermando localmente i Jacobiani. Questo test non è
una stima della regione di validità né della RAS.

## Dataset e riproducibilità

`run_all.m` rigenera `results/data/m2_linearization_nominal.mat`, contenente
parametri, equilibrio, matrici \(A,B,C,D\), poli, modelli `ss`, metriche SVD e
PBH, confronto Jacobiani e verifica locale. Il dataset è prodotto unicamente
dal nostro codice e non deriva dal file del progetto precedente.

La suite M2 comprende nove test: equilibrio generale e scelto, dimensioni dei
Jacobiani, confronto simbolico/numerico, validazione locale, controllabilità e
stabilizzabilità, osservabilità e rilevabilità, matrici di uscita e regressione
integrale dei sette test M1.

## Confronto reference-last

Il confronto con l'inventario del riferimento è avvenuto soltanto dopo il
primo `run_all` M2 positivo. Sono comuni, perché derivano dalla traccia, la
configurazione verticale superiore, la linearizzazione simbolica e l'uso di
misure di posizione. La nostra pipeline aggiunge verifiche indipendenti a
differenze finite, tolleranze SVD esplicite, PBH sui modi critici e confronto
locale LTI/non lineare; genera inoltre un dataset con nome e contenuto propri.
Il comportamento qualitativo instabile è coerente. Non sono stati confrontati
o importati numeri, matrici, codice o struttura interna del riferimento.

## Limiti M2

- La linearizzazione è locale all'equilibrio nominale scelto.
- I numeri di condizionamento delle matrici di controllabilità/osservabilità
  richiedono attenzione allo scaling nelle sintesi successive.
- La rilevabilità è verificata sul modello meccanico a otto stati, non sul
  futuro modello esteso con attuatori.
- Non sono ancora definiti Q/R, covarianze Kalman, specifiche robuste, pesi,
  saturazioni o incertezze.
- M3 non è iniziata.
