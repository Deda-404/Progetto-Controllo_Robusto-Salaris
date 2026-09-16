# M11 corrente: medesime strutture, nuovi pesi M5

Revisione 2026-09-16. Una campagna di 30 partenze, cinque per A0–A5, è stata rieseguita senza modificare architetture, seed, solver o criteri. A0/A1 non hanno rappresentanti validi stabili, A2 non ha chiusure stabili, A3/A4/A5 hanno cinque chiusure stabili ciascuna. Objective migliori: A3=8.16714387415, A4=5.96724587110, A5=5.70856883334. Nessuno è PASS prestazionale.

A5 corrente alimenta M12. Il confronto completo con M9/M10, incluse norme, tracking e comando, è esportato in results/data/direct_hinf_production.csv e nella relazione. I paragrafi numerici seguenti conservano la baseline precedente, non gli artifact aggiornati.

## Evidenza storica precedente alla revisione diretta
# M11 — Structured H-infinity con strutture implementabili

**Responsabile:** Alessio
**Stato:** `PARTIAL` — campagna corretta e riproducibile, target prestazionali non soddisfatti

## Obiettivo e problema congelato

M11 misura il costo imposto dalla riduzione di ordine e dalla struttura del
controllore. Non è una nuova campagna di tuning delle specifiche. La sintesi
usa la generalized plant M10 senza modifiche:

\[
P=\begin{bmatrix}W_1&-W_1G\\0&W_2\\I&-G\end{bmatrix},
\qquad e=r-q,
\]

con dimensione 6×4, ordine 18, `nmeas=ncont=2`. L'audit iniziale ha
restituito errore frequenziale nullo rispetto all'artifact M10. `G` è la
pianta nominale M3 2×2 di ordine 14; `W1` e `W2` sono gli artifact M5
congelati e i rispettivi errori di rigenerazione sono nulli. `W3=[]`.

La norma di confronto full-order è letta dall'artifact M10:

`gamma_full = 10.2071036477417`.

Ogni soluzione strutturata stabile deve rispettare
`gamma_struct >= gamma_full*(1-1e-4)`. Una violazione arresta la campagna
come possibile incongruenza di pianta, scaling, segno o canali.

## Campagna finita

La configurazione è stata congelata prima della sintesi. Per ogni famiglia
sono stati richiesti cinque start totali: uno nominale e quattro partenze
interne casuali di `hinfstruct`. Il seed base è `20260827`; i seed di famiglia
sono `20260827:20260832`, l'esecuzione parallela è disabilitata e non sono
stati cambiati seed dopo l'osservazione dei risultati.

| ID | Struttura | Ordine nominale | Parametri tunabili | API |
| --- | --- | ---: | ---: | --- |
| A0 | guadagno statico MIMO full 2×2 | 0 | 4 | `tunableGain` |
| A1 | due PI SISO decentralizzati | 2 max | 4 | due `tunablePID('PI')` |
| A2 | due PIDF SISO decentralizzati | 4 max | 8 | due `tunablePID('PID')` |
| A3 | MIMO full 2×2 | 2 | 16 | `tunableSS(...,'full')` |
| A4 | MIMO full 2×2 | 4 | 36 | `tunableSS(...,'full')` |
| A5 | MIMO full 2×2 | 6 | 64 | `tunableSS(...,'full')` |

La semantica `RandomStart=4` è stata verificata localmente su MATLAB R2025b:
l'array `info` contiene cinque record, quello nominale più quattro random.
I blocchi ottimizzati sono estratti con `getValue` dai `TunedBlocks` restituiti
da `hinfstruct`; il controllore finale è sempre convertito in un modello LTI
numerico 2×2 auditabile.

## Audit di ogni partenza e variabilità

Per ciascuno dei 30 record sono conservati objective, iterazioni, warning,
blocchi ottimizzati, controllore numerico, ordine e classificazione. La
stabilità usa la matrice plant-controller completa, senza `minreal`, e
controlla anche `S`, `T`, `KS` e `lft(P,K)`.

| ID | Totali | Objective finito | Stabili | Migliore | Mediana | Peggiore finito | Std | Best start | Stato famiglia |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A0 | 5 | 0 | 0 | — | — | — | — | — | `NO_VALID_STABLE` |
| A1 | 5 | 0 | 0 | — | — | — | — | — | `NO_VALID_STABLE` |
| A2 | 5 | 4 | 0 | 31.7502 | 53.0114 | 70.8568 | 21.618 | 2 | `NO_VALID_STABLE` |
| A3 | 5 | 5 | 5 | 16.6419 | 17.2772 | 18.2497 | 0.68779 | 4 | `ALL_VALID_STABLE` |
| A4 | 5 | 5 | 5 | 11.6555 | 11.9112 | 13.8284 | 1.0274 | 2 | `ALL_VALID_STABLE` |
| A5 | 5 | 5 | 5 | 10.2477 | 10.2977 | 10.9260 | 0.28908 | 5 | `ALL_VALID_STABLE` |

A0 e A1 restituiscono cinque record con objective infinito. A2 restituisce
quattro objective finiti, ma nessuna dinamica internamente stabile; queste
partenze sono classificate `INVALID_UNSTABLE`, non eliminate. A3–A5 hanno
cinque start validi e stabili ciascuna. La variabilità è quindi quantificata,
ma il requisito “tutte le soluzioni candidate stabili” fallisce sull'intera
campagna.

## Rappresentanti e ricostruzione indipendente

Il rappresentante di una famiglia è il minimo objective tra gli start
`VALID_STABLE`; l'indice di start è il tie-break deterministico. Tracking e
disturbo non intervengono in questa selezione.

| ID | Ordine reale | Start | Objective | `||W1S||∞` | `||W2KS||∞` | Norma stack | Errore relativo objective | Gap relativo da M10 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A3 | 2 | 4 | 16.6418540 | 16.6193082 | 16.6340257 | 16.6415387 | 1.895e-5 | 0.630388 |
| A4 | 4 | 2 | 11.6555347 | 11.6501593 | 11.6433762 | 11.6550588 | 4.083e-5 | 0.141858 |
| A5 | 6 | 5 | 10.2477452 | 10.1986114 | 10.2349542 | 10.2476412 | 1.016e-5 | 0.0039715 |

Tutti i lower-bound check sono `PASS`. A5 riproduce la norma full-order M10
entro circa lo 0.40% con un controllore di ordine 6 invece di 18; A3 e A4
offrono riduzioni ulteriori al costo di gap rispettivamente del 63.0% e
14.2%. Nessuna soluzione soddisfa `gamma<1`.

## Frontiera Pareto

La selezione usa esclusivamente ordine e norma pesata, senza score misti.
A3, A4 e A5 sono tutte non dominate: aumentando l'ordine da 2 a 4 e 6 si
riduce la norma. Non emerge un vincitore unico. I tre controllori sono quindi
mantenuti come candidati Pareto per revisione del gruppo; M11 non decide quale
controller debba entrare in una futura M12.

## Tracking, disturbo e comando

Sono stati eseguiti, senza prefilter e con `u=K(r-q)`, i sei tracking M5
2°/5°/8° separati sui due giunti e i sei disturbi lato link
0.25/0.50/1.00 N m per ogni rappresentante.

| Controllore | Worst Ts [s] | Worst OS [%] | Worst errore statico rel. | Worst cross tracking | Peak U tracking [N m] | Peak q disturbo [rad] | Offset disturbo [rad] | Peak U disturbo [N m] |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| M6 LQG | 0.776 | 0.265 | ~0 | 0.1739 | 7.503 | 0.3205 | 0.3205 | 2.599 |
| M9 mixsyn | 1.566 | 261.62 | 0.4907 | 0.2596 | 8.256 | 0.8717 | 0.1987 | 3.551 |
| M10 hinfsyn | 1.566 | 261.62 | 0.4907 | 0.2596 | 8.256 | 0.8717 | 0.1987 | 3.551 |
| M11 A3 | 3.260 | 225.75 | 0.7905 | 0.6552 | 7.711 | 0.7641 | 0.4839 | 3.986 |
| M11 A4 | 2.846 | 227.24 | 0.5544 | 0.4988 | 7.978 | 0.6763 | 0.3393 | 3.344 |
| M11 A5 | 1.924 | 233.51 | 0.5092 | 0.2391 | 8.051 | 0.7010 | 0.2908 | 3.268 |

Tutti i rappresentanti M11 falliscono almeno settling, overshoot ed errore
statico; A3/A4 falliscono anche la soglia diagnostica di cross-coupling. A5
passa il solo cross-coupling tracking. Il disturbo è `QUANTIFIED` senza soglie
aggiunte. I picchi di comando sono riportati anche divisi per
`uScale=12 N m`; la scala resta una normalizzazione e non una saturazione.

## Quality gate e limiti

| Gate | Esito |
| --- | --- |
| structured campaign correctness | PASS |
| internal stability, tutti gli start | FAIL — 15/30 stabili |
| reconstruction, rappresentanti | PASS |
| full-order lower-bound sanity | PASS |
| weighted nominal performance | FAIL |
| tracking | FAIL |
| cross-coupling | FAIL |
| disturbance | QUANTIFIED |
| control effort | QUANTIFIED_NO_SATURATION |
| start variability | QUANTIFIED |
| software correctness | PASS |
| stato complessivo M11 | **PARTIAL** |

Non sono stati eseguiti retuning M5, analisi sulla pianta incerta M4,
`mussv`, `robuststab`, `robgain`, `musyn`, D–K iteration, prefilter, azione
2-DoF o attività M12. Qualunque scelta tra A3/A4/A5 o nuova campagna richiede
revisione e autorizzazione separate.

## Riproducibilità

La funzione `validate_m11_hinfstruct` genera
`results/data/m11_hinfstruct_structured.mat` e sei figure M11. La suite
`test_m11_hinfstruct.m` contiene 48 test. Il `run_all` esegue l'intera catena
M0–M11 e conserva separati correttezza software ed esito prestazionale.
