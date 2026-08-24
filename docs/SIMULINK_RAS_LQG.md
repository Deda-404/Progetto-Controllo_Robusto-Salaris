# Simulink, validazione non lineare e RAS empirica LQG

## Perimetro e controllore

M8 valida esclusivamente il controllore M6 LQG senza integratore. Le matrici
`K`, `L` e `Nr` sono caricate da
`results/data/m6_lqg_no_integrator.mat`, incorporate numericamente nel modello
e confrontate bit per bit con il dataset; non sono stati eseguiti tuning LQR,
LQI o Kalman. M7 resta `PARTIAL` e congelata.

Il candidato I25 non è stato ricostruito in Simulink: il confronto integrale
resta quello lineare già validato in M7, etichettato esclusivamente
**representative integral benchmark**. Questa scelta evita di trasformare un
candidato di feasibility non approvato in un secondo controllore M8 e non
influenza il quality gate.

## Architettura Simulink

Il modello originale `simulink/SEA_LQG_nonlinear.slx` è costruito
programmaticamente e contiene i moduli Reference, Controller, Actuators,
Nonlinear SEA Plant, Disturbance, Measurement Noise e Logging. La catena è:

`M6 LQG -> attuatori nominali M3 -> meccanica SEA non lineare M1`.

La meccanica usa realmente le funzioni M1 validate e integra otto stati:

\[
M(q)\ddot q+C(q,\dot q)\dot q+G(q)=K_s(\theta-q)+d,
\]
\[
J_m\ddot\theta+B_m\dot\theta=\tau-K_s(\theta-q).
\]

Il blocco non lineare non contiene le matrici linearizzate `A/B`. Fra comando
e coppia meccanica sono inseriti i sei stati del banco M3, secondo ordine più
Padé di ordine 1. La dinamica `Jm/Bm` compare soltanto nella meccanica SEA e
non viene duplicata negli attuatori.

Il plant fisico ha quindi 14 stati (8 meccanici + 6 attuatori); lo stimatore
M6 ha 14 stati. Il modello complessivo integra 28 stati continui.

## Coordinate e riproducibilità

Il plant usa coordinate assolute `x`. Controller e stimatore usano coordinate
incrementali; ai quattro encoder viene inviato
`delta y=[q;theta]-[qbar;thetabar]+v`, mentre il riferimento è `delta r`.
L'uscita incrementale del controller viene sommata a `taubar` prima del banco
attuatori. Gli stati attuatore di equilibrio sono ottenuti da
`-Aact\(Bact*taubar)`.

Ingressi, condizioni iniziali, orizzonte e solver sono sempre applicati con
`Simulink.SimulationInput`. I parametri derivano dai dataset M3/M6 e dalle
source of truth M1/M8; `Simulink.findVars` restituisce zero dipendenze dal base
workspace.

## Solver

Un gradino da 2° è stato simulato sia con `ode45` sia con `ode23t`. A parità di
tolleranze lo scarto massimo sulle posizioni è `5.5565e-6 rad`; nella prova
eseguita i tempi a parete sono stati rispettivamente 2.1604 s e 0.4780 s. È
stato scelto `ode23t`, adeguato alla combinazione moderatamente stiff di
elasticità SEA, attuatori e stimatore.

| Impostazione | Valore |
| --- | ---: |
| solver | `ode23t` |
| relative tolerance | `1e-5` |
| absolute tolerance | `1e-7` |
| max step | `0.005 s` |

Le tolleranze sono sufficienti a rendere trascurabile la differenza fra i due
solver senza richiedere valori estremi.

## Equilibrio

Con plant a `xbar`, attuatori all'equilibrio, stimatore incrementale nullo e
`r=d=v=0`, la simulazione di 4 s produce:

| Metrica | Massimo |
| --- | ---: |
| `abs(q-qbar)` | `4.086e-17 rad` |
| `abs(theta-thetabar)` | `3.845e-17 rad` |
| `abs(u-taubar)` | `1.686e-15 N m` |

Le tolleranze del gate sono `1e-8` per posizione e comando. Non è osservato
drift.

## Tracking e confronto LTI/non lineare

Sono stati applicati gradini separati a entrambi i giunti per 2°, 5° e 8°.
Le metriche seguenti appartengono al modello non lineare; il picco comando è
assoluto e la deformazione include la deformazione di equilibrio.

| Rif. | Giunto | Ts [s] | OS [%] | errore statico rel. | cross coupling | peak u [N m] | peak SEA [rad] |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 2° | 1 | 0.77696 | 0.24099 | 0.0002796 | 0.17267 | 1.8759 | 0.009460 |
| 2° | 2 | 0.51484 | 0.01228 | 0.0001269 | 0.17392 | 1.7241 | 0.004625 |
| 5° | 1 | 0.77110 | 0.11301 | 0.0017391 | 0.17286 | 4.6897 | 0.023650 |
| 5° | 2 | 0.51478 | 0 | 0.0007909 | 0.17398 | 4.3102 | 0.011563 |
| 8° | 1 | 0.76704 | 0 | 0.0044128 | 0.17319 | 7.5034 | 0.037840 |
| 8° | 2 | 0.51015 | 0 | 0.0020130 | 0.17409 | 6.8964 | 0.018501 |

| Rif. | Giunto | max `abs(qNL-qLTI)` [rad] | RMS [rad] |
| ---: | ---: | ---: | ---: |
| 2° | 1 | `9.8193e-6` | `5.0770e-6` |
| 2° | 2 | `4.5017e-6` | `2.5908e-6` |
| 5° | 1 | `1.5269e-4` | `7.6225e-5` |
| 5° | 2 | `7.0184e-5` | `3.9149e-5` |
| 8° | 1 | `6.2015e-4` | `3.0836e-4` |
| 8° | 2 | `2.8583e-4` | `1.5508e-4` |

L'accordo diminuisce regolarmente con l'ampiezza nei casi eseguiti; questa è
un'osservazione numerica locale, non un'ipotesi imposta al risultato.

## Disturbi fisici lato link

Sono stati simulati `d1` e `d2` separatamente a 0.25, 0.50 e 1.00 N m. Il
caso nominale resta 0.50 N m.

| d [N m] | Giunto | peak q [rad] | offset [rad] | Ts [s] | cross | peak u [N m] | max LTI-NL [rad] |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 0.25 | 1 | 0.039884 | 0.039780 | 0.75205 | 0.46360 | 0.64974 | `1.2625e-5` |
| 0.25 | 2 | 0.080094 | 0.080084 | 0.44318 | 0.22898 | 0.57625 | `3.2380e-5` |
| 0.50 | 1 | 0.079700 | 0.079485 | 0.74996 | 0.46390 | 1.2994 | `1.0068e-4` |
| 0.50 | 2 | 0.16000 | 0.15998 | 0.43745 | 0.22929 | 1.1512 | `2.5736e-4` |
| 1.00 | 1 | 0.15886 | 0.15838 | 0.74194 | 0.46506 | 2.5979 | `7.9600e-4` |
| 1.00 | 2 | 0.31850 | 0.31849 | 0.41009 | 0.23044 | 2.2917 | `2.0058e-3` |

L'offset è conservato e visibile: M6 non ha integratore.

## Rumore

Il seed è `20260826` e la deviazione standard encoder è quella selezionata in
M6, `8.7266e-4 rad`. Sul riferimento da 5° al giunto 1:

| Metrica RMS | Non lineare | Lineare M6 |
| --- | ---: | ---: |
| tracking | 0.0158 rad | 0.0150 rad |
| errore stima q | `2.2627e-4 rad` | `2.3377e-4 rad` |
| variazione comando | 0.0753 N m | 0.0803 N m |

Il rilancio con lo stesso vettore di rumore ha errore massimo nullo.

## Definizione empirica della RAS

La sezione primaria impone `delta q(0)=[dq1;dq2]`, velocità nulle,
`theta(0)=thetabar+delta q(0)`, attuatori all'equilibrio e `xhat(0)=0` nelle
coordinate incrementali. La deformazione SEA iniziale resta quindi quella di
equilibrio.

Il criterio, fissato prima della ricerca, richiede simulazione completata,
segnali finiti e limitati e, nell'ultimo 10% di 8 s:

- `max abs(q-qbar) <= 0.5 deg`;
- `max abs(qdot) <= 0.02 rad/s`;
- `max abs(theta-thetabar) <= 0.5 deg`;
- `max abs(thetadot) <= 0.05 rad/s`;
- nessuna crescita finale oltre il margine deterministico del 5%.

Un punto finito, limitato, non crescente e già ridotto sotto metà della
perturbazione iniziale, ma non ancora entro soglia, viene rilanciato a 12 s.
Nelle ricerche eseguite nessun punto ha richiesto l'estensione.

La ricerca applica prima la griglia simmetrica
`[-60,-30,0,30,60]^2`, poi 36 direzioni a passo 10° e bisezione con tolleranza
radiale 1°. Il budget è 400 simulazioni per sezione.

**60° è il limite della ricerca numerica, non una saturazione o un limite
fisico del manipolatore.** La frontiera radiale si arresta sul lato del box;
il raggio massimo dipende quindi dall'angolo rispetto al quadrato.

## Risultati RAS

| Metrica | Primaria `xhat0=0` | Secondaria stima coerente |
| --- | ---: | ---: |
| simulazioni/punti unici | 57 | 57 |
| convergenti | 57 | 57 |
| divergenti | 0 | 0 |
| raggio minimo | 60° | 60° |
| raggio massimo campionato | 78.3244° | 78.3244° |
| area poligonale approssimata | 14214 deg² | 14214 deg² |
| direzioni | 36 | 36 |
| direzione critica deterministica | 0° | 0° |
| direzione favorevole deterministica | 320° | 320° |

Tutti gli endpoint radiali sono convergenti: non è stata localizzata una
frontiera dinamica interna. La curva rappresentata è dunque **limitata dal
search box** e i risultati provano soltanto la convergenza dei punti esplorati
nel dominio scelto. Le direzioni riportate sono i primi indici selezionati
dal tie-break deterministico fra valori simmetrici equivalenti.

La seconda sezione usa la stessa perturbazione fisica ma inizializza lo
stimatore con il corrispondente stato incrementale coerente. È stata scelta
per isolare l'effetto dell'errore iniziale di stima senza introdurre un terzo
tipo di perturbazione; non è una RAS 14D.

## Sforzo di controllo e limiti metodologici

Ogni punto registra picchi di comando, deformazione SEA e coppia elastica.
`uScale=12 N m` rimane una normalizzazione prestazionale M5 e non una
saturazione hardware. Nessuna saturazione o anti-windup è stata inventata e
un comando elevato non modifica automaticamente la classificazione di
convergenza.

**La RAS riportata è una stima empirica su sezioni del dominio delle
condizioni iniziali e non un certificato analitico della regione di
attrazione completa.** Non certifica il comportamento fuori dal box, fra i
raggi campionati, in presenza di saturazioni fisiche non modellate o
incertezze M4. La verifica robusta e il Monte Carlo appartengono a milestone
successive e non sono stati anticipati.

## Artifact

- dataset: `results/data/m8_lqg_nonlinear_ras.mat`;
- modello: `simulink/SEA_LQG_nonlinear.slx`;
- figure: tracking non lineare, confronto LTI/NL, disturbi, RAS primaria e
  sezione secondaria;
- test: `tests/test_m8_simulink_ras.m`, T1–T18.

**Responsabile:** Alessio
