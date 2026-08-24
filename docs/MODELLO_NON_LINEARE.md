# Modello non lineare del manipolatore SEA

## Sistema fisico e convenzioni

Il sistema è un manipolatore planare 2R con due coordinate di link
\(q=[q_1,q_2]^T\) e due coordinate di rotore \(\theta=[\theta_1,\theta_2]^T\).
Ogni motore trasmette coppia al link attraverso una molla torsionale. La
deformazione elastica e la coppia trasmessa sono

\[
\delta=\theta-q, \qquad \tau_{el}=K_s\delta.
\]

La coordinata \(q_2\) è relativa al primo link. Angoli e deformazioni sono
espressi in rad, velocità in rad/s, accelerazioni in rad/s² e coppie in N·m.

## Stato, ingresso e uscita

La convenzione unica adottata nel repository è

\[
x=\begin{bmatrix}q\\\dot q\\\theta\\\dot\theta\end{bmatrix}
=
[q_1,q_2,\dot q_1,\dot q_2,\theta_1,\theta_2,
\dot\theta_1,\dot\theta_2]^T.
\]

L'ingresso è \(\tau=[\tau_1,\tau_2]^T\), coppia applicata ai due motori.
La funzione dinamica restituisce \(\dot x\) nello stesso ordine dello stato:
le componenti 1–2 e 5–6 hanno unità rad/s, le componenti 3–4 e 7–8 rad/s².

## Parametri nominali

I soli valori usati in M1 sono quelli meccanici assegnati dalla traccia.

| Simbolo | Valore | Unità |
| --- | ---: | --- |
| \(m_1\) | 1.0 | kg |
| \(m_2\) | 0.8 | kg |
| \(l_1\) | 0.4 | m |
| \(l_2\) | 0.3 | m |
| \(J_{m1},J_{m2}\) | 0.01 | kg·m² |
| \(B_{m1},B_{m2}\) | 0.02 | N·m·s/rad |
| \(k_1\) | 50 | N·m/rad |
| \(k_2\) | 40 | N·m/rad |
| \(g\) | 9.81 | m/s² |

La funzione `sea_params_nominal` è l'unica sorgente software di questi
valori e costruisce \(J_m\), \(B_m\) e \(K_s\) come matrici diagonali 2×2.

## Equazioni

Le equazioni meccaniche implementate sono

\[
M(q)\ddot q+C(q,\dot q)\dot q+G(q)=K_s(\theta-q),
\]

\[
J_m\ddot\theta+B_m\dot\theta=\tau-K_s(\theta-q).
\]

Ponendo \(a=m_2l_1l_2\), i termini del lato link sono

\[
M(q)=\begin{bmatrix}
(m_1+m_2)l_1^2+m_2l_2^2+2a\cos q_2 & m_2l_2^2+a\cos q_2\\
m_2l_2^2+a\cos q_2 & m_2l_2^2
\end{bmatrix},
\]

\[
C(q,\dot q)=\begin{bmatrix}
-a\sin q_2\dot q_2 & -a\sin q_2(\dot q_1+\dot q_2)\\
a\sin q_2\dot q_1 & 0
\end{bmatrix},
\]

\[
G(q)=\begin{bmatrix}
(m_1+m_2)gl_1\cos q_1+m_2gl_2\cos(q_1+q_2)\\
m_2gl_2\cos(q_1+q_2)
\end{bmatrix}.
\]

La funzione completa calcola

\[
\ddot q=M(q)\backslash[\tau_{el}-C(q,\dot q)\dot q-G(q)],
\qquad
\ddot\theta=J_m\backslash[\tau-B_m\dot\theta-\tau_{el}],
\]

usando la soluzione di sistemi lineari MATLAB e mai l'inversa esplicita.

## Positività della matrice di inerzia

La positività non è dedotta dal solo campionamento. Per parametri fisici
strettamente positivi,

\[
m_{11}\ge m_1l_1^2+m_2(l_1-l_2)^2>0,
\]

e il determinante si riduce analiticamente a

\[
\det M=m_2l_1^2l_2^2\left(m_1+m_2\sin^2q_2\right)>0.
\]

Il criterio di Sylvester prova quindi che \(M(q)\) è definita positiva per
ogni \(q_2\). Il campionamento numerico su 2001 punti di \([-\pi,\pi]\)
controlla separatamente che l'implementazione rispetti questa proprietà.

## Struttura software

| File | Responsabilità | Output |
| --- | --- | --- |
| `src/parameters/sea_params_nominal.m` | Parametri nominali centralizzati | struttura `p` |
| `src/model/sea_link_inertia.m` | Inerzia lato link | matrice 2×2 in kg·m² |
| `src/model/sea_coriolis.m` | Termini Coriolis/centrifughi | matrice 2×2 |
| `src/model/sea_gravity.m` | Coppie gravitazionali | vettore 2×1 in N·m |
| `src/model/sea_elastic_torque.m` | Deformazione e coppia SEA | due vettori 2×1 |
| `src/model/sea_nonlinear_rhs.m` | Dinamica completa | vettore 8×1 |

Le funzioni ricevono tutti i dati per argomento: non usano `load`, variabili
globali, variabili del base workspace o side effect. L'RHS ha dimensione
fissa ed è predisposto per il successivo impiego in Simulink.

## Verifiche M1

L'esecuzione reale con MATLAB R2025b Update 4 ha prodotto:

| Verifica | Risultato | Tolleranza |
| --- | ---: | ---: |
| minimo autovalore di \(M\) | 0.01904266522239113 a \(q_2=0\) rad | maggiore di \(10^{-12}\) |
| massimo errore di simmetria di \(M\) | 0 | \(10^{-12}\) |
| massimo residuo di \((\dot M-2C)+(\dot M-2C)^T\) | \(4.906538933386797\times10^{-18}\) | \(10^{-12}\) |
| errore massimo formula di gravità | 0 | \(10^{-12}\) |
| errore massimo formula elastica | 0 | \(10^{-12}\) |
| errore cinematico RHS | 0 | \(10^{-12}\) |
| RHS finiti | 4 su 4 | nessun `NaN`/`Inf` |

La validazione riporta 2018 valutazioni deterministiche: 2001 configurazioni
per l'inerzia, 7 per Coriolis, 3 per gravità, 3 per elasticità e 4 per l'RHS.
La suite automatica comprende inoltre un confronto indipendente nel quale le
formule della traccia sono calcolate direttamente nel test.

## Confronto con il riferimento

Il confronto è stato eseguito solo dopo avere completato e testato la nostra
prima versione. Entrambi i progetti seguono necessariamente la scomposizione
fisica imposta dalla traccia e una dinamica a otto stati. La nostra M1 usa però
un'API numerica modulare con parametri restituiti esplicitamente e test
strutturali autonomi; non dipende da dataset e rinvia intenzionalmente
simbolico, equilibrio e Jacobiani a M2. L'inventario del riferimento conferma
che tali passaggi successivi esistono nel loro flusso, senza evidenziare termini
meccanici mancanti nella nostra M1. Non sono stati importati né copiati codice,
test, commenti, dati o risultati del riferimento.

## Limiti attuali

M1 descrive soltanto la meccanica nominale. Non definisce un punto di
equilibrio, non linearizza, non introduce la dinamica esterna del secondo
ordine o il ritardo degli attuatori e non include incertezze, saturazioni,
disturbi o controllori. Questi elementi restano esplicitamente fuori scope.
