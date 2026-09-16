# M16 — Monte Carlo sull'insieme incerto lineare M4

**Stato:** `COMPLETE` come valutazione empirica; non è una certificazione di robustezza.

## Disegno della campagna

La campagna usa seed `20260826`, generatore `twister` e 40 realizzazioni comuni. Ogni Sample ID descrive lo stesso impianto fisico per M6, Khinf e Kmu. I parametri `Jm1`, `k1` e `k2` variano ciascuno del ±10%; la famiglia attuatore è rappresentata dai due blocchi dinamici indipendenti coperti da WI.

Il Sample 0 nominale è un gate di ricostruzione e non entra nelle statistiche. I 40 campioni effettivi sono tutti interni a M4, i blocchi dinamici sono stabili e con bound unitario, e il replay seeded riproduce la sequenza.

## Stabilità empirica

| Controllore | Stabili | Frazione empirica | Sample instabili | Worst max Re [1/s] |
| --- | ---: | ---: | --- | ---: |
| M6 | 37/40 | 0.925 | 5, 6, 35 | +3.00423 |
| Khinf | 40/40 | 1.000 | nessuno | -0.0300875 |
| Kmu | 40/40 | 1.000 | nessuno | -0.0302809 |

I Sample 5, 6 e 35 M6 hanno ciascuno due poli nel semipiano destro e restano nel dataset. Le loro metriche prestazionali sono non eleggibili, non sostituite da valori nominali. La stabilità 40/40 di Kmu non contraddice il risultato RS negativo M14 `[0.774041952377,0.775696806012]`: il campione finito non esaurisce M4.

## Prestazione sui campioni

| Controllore | Core tracking, totale | Core tracking, soli stabili |
| --- | ---: | ---: |
| M6 | 57.5% | 62.1622% |
| Khinf | 0% | 0% |
| Kmu | 0% | 0% |

M6 mantiene il miglior tracking sul sottoinsieme stabile, ma non è robustamente certificato e perde stabilità in tre realizzazioni. Khinf e Kmu sono stabili in tutti i campioni, ma non rispettano il nucleo dei target M5. `uScale=12 N m` resta una scala prestazionale, non una saturazione hardware.

## Interpretazione corretta

Le frazioni 37/40 e 40/40 descrivono soltanto questa sequenza finita. M4 non definisce probabilità fisiche e il campionamento uniforme è una regola computazionale. M16 non sostituisce M14, non produce margini robusti e non seleziona un vincitore mediante score globale.

Artifact: `results/data/m16_monte_carlo_uncertain_linear.mat`.
