# Simulink, validazione non lineare e RAS empirica LQG

## Perimetro e controllore

M8 valida esclusivamente il controllore M6 LQG senza integratore. Le matrici
`K`, `L` e `Nr` sono caricate da
`results/data/m6_lqg_no_integrator.mat`, incorporate numericamente nel modello
e confrontate bit per bit con il dataset; non sono stati eseguiti tuning LQR,
LQI o Kalman. M7 resta `PARTIAL` e congelata.

Le tre verifiche manuali M7 non sono state ricostruite in Simulink: nessuna
soddisfa insieme settling time e overshoot M5, quindi non esiste un secondo
controllore finale da validare in M8. Il risultato integrale resta la verifica
lineare documentata in M7 e non influenza il quality gate M8.

## Architettura Simulink

Il modello `simulink/SEA_LQG_nonlinear.slx` è costruito programmaticamente
usando soli blocchi standard e contiene i sottosistemi Reference, LQG
Controller, Actuator Dynamics, Nonlinear SEA Plant, Measurement Interface e
Signal Monitoring. Il controller espone separatamente precompensatore `Nr`,
feedback `-K`, comando incrementale, ingressi dell'osservatore, Kalman
Observer, coppia di equilibrio e comando assoluto. La catena è:

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
tolleranze lo scarto massimo sulle posizioni è `6.213e-6 rad`. È stato scelto
`ode23t`, adeguato alla combinazione moderatamente stiff di elasticità SEA,
attuatori e stimatore; i tempi a parete non sono usati come requisito perché
dipendono dalla macchina di esecuzione.

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
| `abs(q-qbar)` | `1.061e-16 rad` |
| `abs(theta-thetabar)` | `1.021e-16 rad` |
| `abs(u-taubar)` | `5.020e-15 N m` |

Le tolleranze del gate sono `1e-8` per posizione e comando. Non è osservato
drift.

## Tracking e confronto LTI/non lineare

Sono stati applicati gradini separati a entrambi i giunti per 2°, 5° e 8°.
Le metriche seguenti appartengono al modello non lineare; il picco comando è
assoluto e la deformazione include la deformazione di equilibrio.

| Rif. | Giunto | Ts [s] | OS [%] | errore statico rel. | cross coupling | peak u [N m] | peak SEA [rad] |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 2° | 1 | 0.67925 | 0.38381 | 0.0002508 | 0.16939 | 1.8043 | 0.010426 |
| 2° | 2 | 0.48155 | 0.02389 | 0.0001219 | 0.16919 | 1.7122 | 0.004864 |
| 5° | 1 | 0.67739 | 0.27498 | 0.0015603 | 0.16954 | 4.5106 | 0.026065 |
| 5° | 2 | 0.47643 | 0 | 0.0007594 | 0.16924 | 4.2806 | 0.012160 |
| 8° | 1 | 0.66984 | 0.07654 | 0.0039626 | 0.16982 | 7.2170 | 0.041703 |
| 8° | 2 | 0.47502 | 0 | 0.0019336 | 0.16934 | 6.8489 | 0.019457 |

| Rif. | Giunto | max `abs(qNL-qLTI)` [rad] | RMS [rad] |
| ---: | ---: | ---: | ---: |
| 2° | 1 | `8.8445e-6` | `4.4738e-6` |
| 2° | 2 | `4.3697e-6` | `2.4544e-6` |
| 5° | 1 | `1.3754e-4` | `6.8575e-5` |
| 5° | 2 | `6.8208e-5` | `3.7369e-5` |
| 8° | 1 | `5.5916e-4` | `2.7614e-4` |
| 8° | 2 | `2.7792e-4` | `1.4706e-4` |

L'accordo diminuisce regolarmente con l'ampiezza nei casi eseguiti; questa è
un'osservazione numerica locale, non un'ipotesi imposta al risultato.

## Disturbi fisici lato link

Sono stati simulati `d1` e `d2` separatamente a 0.25, 0.50 e 1.00 N m. Il
caso nominale resta 0.50 N m.

| d [N m] | Giunto | peak q [rad] | offset [rad] | Ts [s] | cross | peak u [N m] | max LTI-NL [rad] |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 0.25 | 1 | 0.036351 | 0.036204 | 0.65057 | 0.49494 | 0.64659 | `8.5758e-6` |
| 0.25 | 2 | 0.077920 | 0.077908 | 0.41999 | 0.23006 | 0.57962 | `2.7455e-5` |
| 0.50 | 1 | 0.072656 | 0.072357 | 0.64940 | 0.49515 | 1.2932 | `6.8416e-5` |
| 0.50 | 2 | 0.15568 | 0.15566 | 0.41323 | 0.23035 | 1.1579 | `2.1846e-4` |
| 1.00 | 1 | 0.14496 | 0.14431 | 0.64653 | 0.49596 | 2.5865 | `5.4261e-4` |
| 1.00 | 2 | 0.31009 | 0.31007 | 0.39435 | 0.23144 | 2.3054 | `1.7096e-3` |

L'offset è conservato e visibile: M6 non ha integratore.

## Rumore

Il seed è `20260826` e la deviazione standard encoder è quella selezionata in
M6, `8.7266e-4 rad`. Sul riferimento da 5° al giunto 1:

| Metrica RMS | Non lineare | Lineare M6 |
| --- | ---: | ---: |
| tracking | 0.0154 rad | 0.0145 rad |
| errore stima q | `2.2641e-4 rad` | `2.3377e-4 rad` |
| variazione comando | 0.0735 N m | 0.0784 N m |

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
