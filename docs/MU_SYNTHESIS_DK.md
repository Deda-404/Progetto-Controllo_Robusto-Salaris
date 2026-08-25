# M13 — D–K iteration / μ-synthesis

**Responsabile:** Alessio

## Obiettivo e perimetro

M13 verifica se una singola sintesi D–K può produrre un candidato migliore
di A5 sul problema incerto già approvato. La milestone è uno studio di
fattibilità robusta, non una revisione delle specifiche: `GuncQ` M4, `Punc`
M12, W1/W2 M5, `W3=[]` e architettura 1-DoF restano congelati.

La pianta generalizzata ha dimensione 6×4, ingressi `[r;u]`, uscite
`[z1;z2;e]`, `nmeas=2`, `ncont=2` e forma

```text
Punc = [ W1  -W1*GuncQ
          0       W2
          I  -GuncQ   ].
```

Il gate precedente alla sintesi confronta la ricostruzione con
`m12_mu_analysis_a5.mat`: valore nominale, nomi I/O, uncertainty names,
dimensioni e struttura `lftdata` coincidono con errore nullo. I blocchi sono
esattamente `Delta_act1`, `Delta_act2`, `Jm1`, `k1`, `k2` con i range M4.

## Technical aborted attempt

Il tentativo 0 usava `Display='full'`. MATLAB R2025b ha completato una prima
K/DG-step e poi ha richiesto interattivamente conferma per continuare. La
modalità batch non supporta `input`, quindi la chiamata è terminata senza
restituire controller, objective o `info`. L'output parziale di console non
è stato usato scientificamente. Il gruppo ha classificato l'evento
`ABORTED_TECHNICAL — interactive Display mode` e ha autorizzato una sola
nuova chiamata con `Display='short'`.

La modifica di Display rende l'esecuzione non interattiva e non costituisce
retuning. Tutte le opzioni matematiche sono rimaste identiche.

## Configurazione della campagna valida

| Opzione | Valore |
| --- | --- |
| API | `[Kmu,CLperf,info] = musyn(Punc,2,2,opts)` |
| Display | `short` |
| MaxIter | 5 |
| TargetPerf / TolPerf | 0 / 0.01 |
| MixedMU | `on` |
| FullDG | `[true true]` |
| FitOrder | `[5 2]` |
| FrequencyGrid | griglia M12, 1201 punti da 1e-3 a 1e4 rad/s |
| AutoScale / Regularize / LimitGain | `on` / `on` / `on` |
| RandomStart / UseParallel | 0 / `false` |

Il run valido non ha prodotto warning e ha richiesto 47.21 s. Il secondo
output dell'API full-order è lo scalare `CLperf`; la chiusura `CLmu` è stata
ricostruita separatamente con `lft(Punc,Kmu)`.

## Storico D–K

| Iter | K-step gamma | Peak μ | Peak μ fitted | gap fit derivato | ordine K | fit D/G |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | 58.2086569179 | 46.3781410097 | 46.4603203537 | 0.0821793440 | 20 | 14 / 6 |
| 2 | 10.7642115144 | 10.6964379339 | 10.7906552130 | 0.0942172791 | 40 | 24 / 8 |
| 3 | 10.4439634184 | 10.4032233618 | 10.4568540041 | 0.0536306423 | 52 | 28 / 10 |
| 4 | 10.4469254036 | 10.4059698071 | 10.4553986438 | 0.0494288367 | 58 | 24 / 10 |
| 5 | 10.4147388534 | 10.4071710189 | 10.4181480840 | 0.0109770651 | 54 | 24 / 8 |

`musyn` ha restituito il controller della migliore iterazione, la 3, con
objective `10.4032233617655`. Poiché l'history ha raggiunto MaxIter, il
progetto classifica diagnosticamente la terminazione `MAX_ITER_REACHED`.
R2025b non espone un campo formale di termination status.

`PeakMu` e `PeakMuFit` sono scalari nell'`info` restituito; lower bound e
frequenza critica non sono quindi disponibili. I D/G scales completi sono
conservati nei campi raw `DG`, `dr`, `dc`, `PSI` e `FitOrder`. L'API non
fornisce un fit error esplicito: la tabella riporta il gap assoluto derivato
fra `PeakMuFit` e `PeakMu`, senza presentarlo come metrica MATLAB nativa.

## Controller e audit nominale

Kmu è un sistema 2×2 di ordine 52. Le matrici sono finite e il controller è
stabile anche isolatamente; nessuna riduzione d'ordine è stata eseguita.
La ricostruzione esplicita plant-controller produce 66 stati interni e
massima parte reale dei poli `-0.731994726169`, quindi Nominal Stability è
`PASS`.

| Metrica nominale | Valore |
| --- | ---: |
| `||W1*S||inf` | 10.2412656867 |
| `||W2*Kmu*S||inf` | 10.3788582451 |
| `||[W1*S;W2*Kmu*S]||inf` | 10.3917314574 |
| frequenza di picco stack | 93.1402569484 rad/s |
| errore stack vs `CLmu.NominalValue` | 4.083e-12 |

Il confronto nominale dà 10.2071033931 per M10, 10.2476411502 per A5 e
10.3917314574 per Kmu. Kmu non viola il benchmark nominale full-order M10;
il relativo gate metodologico è `PASS`.

## Interpretazione e limiti

L'objective robusto riportato dalla sintesi è `10.4032233618`, quindi resta
maggiore di uno. Questo risultato è valido: M10 aveva già mostrato che il
problema nominale congelato ha optimum circa 10.207. Non sono stati cambiati
pesi, incertezze, iterazioni o fit orders dopo il risultato.

M13 non dichiara Robust Stability o Robust Performance del nuovo
controller. L'objective `musyn` non viene chiamato certificazione; la
verifica indipendente NS/NP/RS/RP appartiene a M14. Non sono stati eseguiti
Monte Carlo, Simulink non lineare, tracking esteso, seconda campagna o
riduzione del controller.

## Quality gate

Frozen generalized plant, uncertainty, weights, D–K execution/history,
controller extraction, nominal internal stability, nominal weighted
reconstruction, lower-bound sanity e software correctness sono `PASS`.
Objective e ordine sono `QUANTIFIED`. M13 è `COMPLETE` come milestone di
sintesi, anche se l'objective resta maggiore di uno.
