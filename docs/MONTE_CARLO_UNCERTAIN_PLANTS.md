# M16 — Monte Carlo sull'insieme incerto lineare M4

**Stato:** `COMPLETE` come valutazione empirica; non è una certificazione di robustezza.

## Disegno della campagna

La campagna usa seed `20260826`, generatore `twister` e 40 realizzazioni comuni. Ogni Sample ID descrive lo stesso impianto fisico per M6, Khinf e Kmu. I parametri `Jm1`, `k1` e `k2` variano ciascuno del ±10%; la famiglia attuatore è rappresentata dai due blocchi dinamici indipendenti coperti da WI.

Il Sample 0 nominale è un gate di ricostruzione e non entra nelle statistiche. I 40 campioni effettivi sono tutti interni a M4, i blocchi dinamici sono stabili e con bound unitario, e il replay seeded riproduce la sequenza.

## Stabilità empirica

| Controllore | Stabili | Frazione empirica | Sample instabili | Worst max Re [1/s] |
| --- | ---: | ---: | --- | ---: |
| M6 | 39/40 | 0.975 | 5 | +2.47065 |
| Khinf | 40/40 | 1.000 | nessuno | -0.0304135 |
| Kmu | 40/40 | 1.000 | nessuno | -0.0304794 |

Il Sample 5 M6 ha due poli nel semipiano destro e resta nel dataset. Le sue metriche prestazionali sono non eleggibili, non sostituite da valori nominali. La stabilità 40/40 di Kmu è coerente con la RS M14 `[1.06956057969,1.21287515623]`, ma non ne costituisce una seconda prova.

## Prestazione sui campioni

| Controllore | Core tracking, totale | Mediana worst Ts [s] | Mediana errore rel. | Mediana cross | Mediana peak u [N m] |
| --- | ---: | ---: | ---: | ---: | ---: |
| M6 | 27.5% | 0.856 | 0.023246 | 0.21094 | 4.6897 |
| Khinf | 0% | 2.223 | 0.48992 | 0.41630 | 5.1599 |
| Kmu | 0% | 2.020 | 0.50364 | 0.36897 | 5.1615 |

M6 mantiene il miglior tracking sul sottoinsieme stabile, ma non è robustamente certificato e perde stabilità in una realizzazione. Khinf e Kmu sono stabili in tutti i campioni, ma non rispettano il nucleo dei target M5. `uScale=12 N m` resta una normalizzazione, non una saturazione hardware.

## Interpretazione corretta

Le frazioni 39/40 e 40/40 descrivono soltanto questa sequenza finita. M4 non definisce probabilità fisiche e il campionamento uniforme è una regola computazionale. M16 non sostituisce M14, non produce margini robusti e non seleziona un vincitore mediante score globale.

Artifact: `results/data/m16_monte_carlo_uncertain_linear.mat`.
