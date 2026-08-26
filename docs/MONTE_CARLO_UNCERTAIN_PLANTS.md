# Monte Carlo lineare sugli impianti incerti M4

**Responsabile:** Alessio
**Milestone:** M16
**Stato:** `COMPLETE` — campagna software/metodologica `PASS`, prestazioni
empiriche quantificate senza retuning

## Scopo e separazione delle evidenze

M16 confronta i controllori congelati M6 LQG, M10 Khinf e M13 Kmu sugli
stessi campioni lineari dell'insieme incerto M4. La milestone è una
valutazione e non una nuova sintesi. Sono rimasti invariati M4, M5, `Klqg`,
`Khinf` e `Kmu`; non sono stati eseguiti tuning, riduzione, saturazione,
Simulink o simulazioni non lineari.

Le tre evidenze finali hanno significati distinti:

- M14 fornisce la certificazione lineare mediante analisi mu;
- M15 simula il modello non lineare nominale;
- M16 produce evidenza empirica/statistica su campioni lineari M4.

Il Monte Carlo non sostituisce `robstab`, non certifica Robust Stability o
Robust Performance e non identifica probabilità fisiche. I range M4 sono
engineering envelopes, non distribuzioni probabilistiche stimate da dati.

## Campagna congelata

| Proprietà | Valore |
| --- | --- |
| seed | `20260826` |
| generatore | `twister` |
| campioni | 40 |
| generazione effettiva | una chiamata `usample(GuncMeas,40)` |
| replay | una seconda chiamata dopo reset del seed, usata solo per audit |
| tracking | 5° separatamente sui due giunti, 4 s, passo 2 ms |
| disturbo | 0.50 N m separatamente sui due link, 8 s, passo 2 ms |
| Sample 0 | benchmark nominale, escluso dalle statistiche |

Il replay riproduce esattamente parametri reali e risposte dei due blocchi
dinamici entro la tolleranza `1e-12`. La sequenza effettiva è generata una
sola volta e `sampledValues(i)` è riusato per tutti i controllori.

## Insieme M4 e validità dei campioni

La source of truth è `results/data/m4_uncertain_plant.mat`. I cinque blocchi
congelati sono:

- `Jm1` ±9%;
- `k1` ±7%;
- `k2` ±7%;
- `Delta_act1`, `ultidyn` indipendente con bound 1;
- `Delta_act2`, `ultidyn` indipendente con bound 1.

Non sono campionati direttamente `wn`, `zeta` o ritardo: la loro famiglia è
già rappresentata da `WI*Delta_act`. Tutti i 40 campioni rispettano i range
`ureal`; i blocchi dinamici sono stabili, finiti e con norma H-infinity non
superiore al bound unitario entro tolleranza. Le realizzazioni LTI complete
dei due `Delta_act` sono conservate nell'artifact, senza comprimerle in
scalari.

## Pianta fisica campionata a stato condiviso

Per ogni campione sono ricavati separatamente, dagli stessi `sampledValues`:

- i due attuatori campionati da
  `uncertainPlantInfo.GactuatorsUncertain`;
- la meccanica campionata da `GmechUncMeas/GmechUncQ`;
- il disturbo di coppia che entra direttamente nella dinamica lato link.

La realizzazione ha ingressi `[u1,u2,d1,d2]` e uscite
`[q1,q2,theta1,theta2]`. Attuatori e meccanica compaiono una sola volta, così
il percorso di disturbo non duplica stati instabili. Non è usato `minreal`.

Su 161 frequenze fra 0.01 e 1000 rad/s, gli errori massimi rispetto agli
oggetti M4 sostituiti direttamente sono:

| Percorso | Errore assoluto max | Errore relativo max |
| --- | ---: | ---: |
| `u -> [q;theta]` | `5.274e-16` | `4.521e-15` |
| `u -> q` | `5.274e-16` | `2.895e-12` |

Il gate della realizzazione fisica è `PASS` per 40/40 campioni.

## Controllori e gate nominale

| Controller | Artifact | Convenzione | Ordine |
| --- | --- | --- | ---: |
| M6 | `m6_lqg_no_integrator.mat` | `Klqg`, riferimento più misure `[q;theta]` | 14 |
| Khinf | `m10_hinfsyn_nominal.mat` | `e=r-q` | 18 |
| Kmu | `m13_musyn_dk.mat` | `e=r-q`, best iteration 3 | 52 |

Sample 0 usa gli attuatori nominali minimi M3 invece degli stati non minimi
che `NominalValue` conserva da `WI*Delta=0`. In questo modo il gate confronta
le realizzazioni fisiche interne di ordine 28/32/66 senza cancellazioni.

| Controller | Errore mappa abs | Errore mappa rel | Distanza poli | Stati |
| --- | ---: | ---: | ---: | ---: |
| M6 | `2.070e-12` | `2.290e-13` | `8.380e-7` | 28 |
| Khinf | `3.691e-12` | `8.613e-14` | `4.123e-10` | 32 |
| Kmu | `3.264e-11` | `6.548e-13` | `1.331e-10` | 66 |

La tolleranza sui poli è `1e-5`, motivata dai modi ripetuti/condizionati di
M6; le mappe sono confrontate con tolleranza assoluta e relativa `1e-7`.
Tutti i gate nominali sono `PASS`.

## Stabilità empirica

| Controller | Stable/40 | Rate | Worst max Re | Median max Re | P05 | P95 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| M6 | 39/40 | 0.975 | `+1.80447` | `-0.34308` | `-2.2636` | `-0.09972` |
| Khinf | 40/40 | 1.000 | `-0.0303583` | `-0.32014` | `-0.51300` | `-0.14590` |
| Kmu | 40/40 | 1.000 | `-0.0304222` | `-0.33125` | `-0.69247` | `-0.14584` |

M6 è instabile nel solo Sample 5, con due poli RHP e massima parte reale
`+1.80447 s^-1`; le metriche prestazionali di tale campione sono `NaN` e non
vengono trattate come valide. Il campione è conservato e non sostituito.

Kmu è stabile in tutti i 40 campioni validi. Il risultato è **coerente** con
M14, che certifica RS con margine
`[1.25003698645,1.25257264120]`; non costituisce una nuova certificazione.

## Banda diagonale closed-loop

La banda è calcolata separatamente mediante `bandwidth(T11)` e
`bandwidth(T22)`. Non viene definita una singola banda MIMO certificata.

| Controller | BW1 median [rad/s] | BW1 P05–P95 | BW2 median [rad/s] | BW2 P05–P95 |
| --- | ---: | ---: | ---: | ---: |
| M6 | 4.6729 | 3.9867–5.8592 | 10.376 | 8.053–29.353 |
| Khinf | 13.412 | 7.0634–20.242 | 28.445 | 23.581–31.237 |
| Kmu | 12.033 | 7.1696–17.341 | 29.155 | 22.942–32.996 |

Le bande sono finite per tutti i campioni stabili. Per il Sample 5 M6 sono
correttamente `NaN` con motivazione `NOT_ELIGIBLE_UNSTABLE`.

## Tracking lineare incerto

Le statistiche seguenti usano il peggiore dei due giunti per ogni campione
stabile. Un `Ts=Inf` indica che il segnale non si assesta entro l'orizzonte
congelato di 4 s e resta incluso nelle statistiche/pass rate.

| Controller | Ts median [s] | OS median [%] | Errore median [%] | Cross median [%] | Peak U median [N m] |
| --- | ---: | ---: | ---: | ---: | ---: |
| M6 | 0.846 | 1.519 | 1.797 | 20.825 | 4.6897 |
| Khinf | 2.082 | 273.16 | 48.991 | 40.919 | 5.1599 |
| Kmu | 1.927 | 239.88 | 50.363 | 36.275 | 5.1615 |

Pass rate per campione, con entrambi i giunti conformi:

| Controller | Ts total/stable | OS total/stable | errore total/stable | cross total/stable | core Ts+OS+errore total/stable |
| --- | ---: | ---: | ---: | ---: | ---: |
| M6 | 30.0% / 30.77% | 97.5% / 100% | 97.5% / 100% | 82.5% / 84.62% | 30.0% / 30.77% |
| Khinf | 0% / 0% | 0% / 0% | 0% / 0% | 10.0% / 10.0% | 0% / 0% |
| Kmu | 0% / 0% | 0% / 0% | 0% / 0% | 17.5% / 17.5% | 0% / 0% |

Il cross-coupling resta diagnostico e non è incluso nel core pass M9–M15;
includendolo, M6 passa 25.0% dei 40 campioni e i robusti 0%.

## Disturbo di coppia e comando

M5 non assegna un target numerico autonomo alla reiezione del disturbo; gli
esiti sono quindi `QUANTIFIED`, non trasformati in PASS artificiali.

| Controller | Peak q median [rad] | Abs offset median [rad] | Cross median [%] | Peak U median [N m] |
| --- | ---: | ---: | ---: | ---: |
| M6 | 0.16070 | 0.15907 | 47.813 | 1.3080 |
| Khinf | 0.44270 | 0.099055 | 161.93 | 1.7871 |
| Kmu | 0.42295 | 0.12293 | 146.62 | 1.6323 |

`uScale=12 N m` è soltanto una normalizzazione. Non è applicato clipping e
non viene dichiarato alcun superamento/soddisfacimento di una saturazione
hardware inesistente.

## Confronto paired

I tre confronti `Kmu-Khinf`, `Kmu-M6` e `Khinf-M6` usano SampleID identici e
solo campioni stabili comuni. Per Kmu contro Khinf:

- Kmu ha max-real-pole minore in 28/40 campioni;
- Kmu ha cross-coupling tracking minore in 36/40;
- Kmu ha peak q da disturbo minore in 38/40;
- Khinf ha errore statico tracking minore in 40/40;
- Khinf ha peak U tracking minore in 40/40.

Rispetto ai robusti, M6 mostra in genere tracking, errore e comando migliori
sui 39 campioni stabili comuni, ma perde stabilità nel Sample 5. Non viene
costruito uno score globale e M16 non seleziona un controllore vincitore: la
valutazione complessiva appartiene a M17.

## Relazione con M15

L'artifact M15 è caricato soltanto come benchmark documentale. Simulink non
viene rieseguito. I risultati M15 sono nominali/non lineari; quelli M16 sono
incerti/lineari. La dispersione M16 non viene aggregata con la RAS o con gli
scarti LTI/NL M15.

## Quality gate

| Gate | Esito |
| --- | --- |
| baseline Git / PR #20 | PASS |
| incertezza M4 congelata | PASS |
| controllori congelati | PASS |
| campagna comune e riproducibile | PASS |
| validità 40/40 campioni | PASS |
| realizzazione fisica condivisa | PASS |
| gate nominali M6/Khinf/Kmu | PASS |
| coerenza Kmu/M14 | PASS |
| stabilità | QUANTIFIED |
| banda | QUANTIFIED_DIAGONAL_CLOSED_LOOP |
| tracking/pass rate | QUANTIFIED |
| disturbo/cross/comando | QUANTIFIED_NO_SATURATION |
| confronto paired | QUANTIFIED_NO_GLOBAL_SCORE |
| correttezza software | PASS |
| stato M16 | **COMPLETE** |

M16 è `COMPLETE` perché la campagna richiesta è finita, riproducibile e
metodologicamente coerente. L'instabilità M6 e i fallimenti prestazionali
sono risultati della valutazione, non errori software.

## Artifact

- `results/data/m16_monte_carlo_uncertain_linear.mat`;
- nove figure `results/figures/m16_*.png`;
- suite `tests/test_m16_monte_carlo.m`, T01–T69;
- pipeline modulare in `analysis/monte_carlo/`.

## Limiti

- 40 campioni non definiscono una probabilità fisica di successo;
- non è costruito un modello non lineare incerto;
- M16 non sostituisce i certificati mu M14;
- il Sample 0 non appartiene alle statistiche;
- non sono introdotti saturazione, weighted norm opzionale o score globale;
- la scelta finale del controllore è rinviata a M17.
