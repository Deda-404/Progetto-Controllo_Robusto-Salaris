# Sintesi H-infinity nominale `mixsyn` — M9

**Responsabile:** Alessio  
**Stato:** `PARTIAL` — sintesi e validazione software corrette; obiettivi
pesato, tracking e cross-coupling non soddisfatti con i pesi M5 congelati.

## Perimetro

M9 valuta la prima e unica baseline nominale

```matlab
[Kmix, CLmix, gamma, info] = mixsyn(G, W1, W2, []);
```

Non sono stati usati la pianta incerta M4, `W3`, `hinfsyn`, mu-analysis,
retuning dei pesi o saturazioni. Il campo M5
`controllerSynthesisAllowed=false` resta invariato: descrive il gate storico
di M5, non impedisce la sintesi nella milestone successiva.

## Pianta nominale e interconnessione

La pianta `G:u->q` proviene direttamente da
`m3_nominal_actuated_plant.mat`: è 2×2, ha 14 stati, due poli instabili reali
con massima parte reale 7.20942861 s^-1 ed è stabilizzabile e rilevabile. Il
confronto frequenziale con il sottosistema `u->q` dell'artifact M5 ha errore
massimo `8.724e-17`.

Il disturbo `d` usa `BdFull` M5 ed entra come coppia lato link, senza
attraversare gli attuatori. Anche il relativo percorso `Gd:d->q` coincide con
l'artifact M5 entro la tolleranza numerica. Restano invariati:

- equilibrio `qbar=[pi/2;0]` e coordinate incrementali;
- attuatori `wn=40 rad/s`, `zeta=0.8`, ritardo 15 ms e Padé ordine 1;
- due zeri di trasmissione RHP a 133.3333 rad/s dovuti al Padé.

La configurazione 1-DoF è `e=r-q`, `u=Kmix*e`. Sono stati ricostruiti senza
`minreal`:

\[
S=(I+G K_{mix})^{-1},\qquad T=I-S,\qquad KS=K_{mix}S.
\]

Il prodotto è verificato numericamente come `Kmix*S`. Per il disturbo si ottengono
`q_d=S*Gd*d` e `u_d=-Kmix*S*Gd*d`.

## Pesi M5 congelati

I pesi sono caricati dall'artifact M5 e confrontati con una rigenerazione
tramite `build_m5_weights`; entrambi gli errori di trasferimento sono zero
alla precisione della verifica.

| Peso | Parametri | Guadagno DC | Guadagno alta frequenza |
| --- | --- | ---: | ---: |
| `W1` | `omegaB=12`, `As=0.05`, `Ms=2` | 20 | 0.5 |
| `W2` | `uScale=12 N m`, `omegaU=30`, `alpha=6` | 1/12 | 0.5 |
| `W3` | assente | — | — |

`uScale` è usato soltanto come normalizzazione prestazionale.

## Sintesi e ricostruzione indipendente

`mixsyn` ha restituito un controllore 2×2 di ordine 18 senza warning MATLAB.
I risultati principali sono:

| Metrica | Valore |
| --- | ---: |
| `gamma` restituito | 10.2071036477 |
| `info.gamma` | 10.2072906100 |
| `||W1*S||inf` | 10.1276254519 |
| frequenza di picco `W1*S` | 0 rad/s |
| `||W2*KS||inf` | 10.1853081898 |
| frequenza di picco `W2*KS` | 33.4393062 rad/s |
| `||[W1*S;W2*KS]||inf` | 10.2071033931 |
| frequenza di picco stacked | 4.04083357 rad/s |
| errore assoluto norma / `gamma` | 2.54649e-7 |
| errore relativo norma / `gamma` | 2.49484e-8 |
| `||CLmix-[W1*S;W2*KS]||inf` | 4.313e-12 |

La tolleranza relativa adottata per la norma è `1e-5`; quella per le
realizzazioni equivalenti è `1e-8`. Il valore stacked è maggiore di uno,
quindi il target mixed-sensitivity M5 non è soddisfatto. La decomposizione
mostra contributi elevati sia da `W1*S` a bassa frequenza sia da `W2*KS`
intorno alla banda del comando. Il picco stacked non coincide con lo zero
RHP a 133.3333 rad/s: le figure ne mostrano la posizione, ma M9 non attribuisce
causalmente il fallimento al solo Padé.

## Stabilità interna

L'interconnessione esplicita plant-controller conserva tutti i 32 stati e ha
massima parte reale dei poli `-0.683828559884 s^-1`. `S`, `T`, `KS`, `CLmix`
e la matrice interna esplicita risultano stabili. La realizzazione di `S`
contiene anch'essa 32 poli e il confronto fra i due insiemi ha distanza zero.

La minima separazione fra poli è `2.8763e-11` e il condition number della
matrice degli autovettori è `1.7650e5`, coerentemente con modi quasi ripetuti
nei due canali. Non sono state rimosse dinamiche con `minreal`; non emergono
cancellazioni di modi instabili. Il controllore isolato risulta stabile, ma
questa proprietà è registrata soltanto come diagnostica e non usata come
criterio di accettazione.

## Tracking nominale

Le simulazioni sono lineari, 1-DoF, senza precompensatore e senza clipping.

| Rif. | Giunto | Ts [s] | OS [%] | Errore regime [rad] | Errore [%] | Cross [%] | Peak U [N m] | Peak U/12 |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 2° | 1 | 1.566 | 171.88 | 0.017128 | 49.068 | 25.960 | 2.0639 | 0.17200 |
| 2° | 2 | 1.216 | 261.62 | 0.012541 | 35.927 | 17.924 | 0.57173 | 0.047644 |
| 5° | 1 | 1.566 | 171.88 | 0.042820 | 49.068 | 25.960 | 5.1599 | 0.42999 |
| 5° | 2 | 1.216 | 261.62 | 0.031352 | 35.927 | 17.924 | 1.4293 | 0.11911 |
| 8° | 1 | 1.566 | 171.88 | 0.068512 | 49.068 | 25.960 | 8.2558 | 0.68798 |
| 8° | 2 | 1.216 | 261.62 | 0.050163 | 35.927 | 17.924 | 2.2869 | 0.19058 |

I target `Ts<=0.8 s`, `OS<=10%` ed errore a regime `<=5%` falliscono. Anche
il limite diagnostico di cross-coupling `<=25%` fallisce di poco sul giunto
1. La linearità spiega l'invarianza delle metriche normalizzate con
l'ampiezza.

## Disturbo fisico lato link

| Disturbo | Giunto | Peak q [rad] | Offset [rad] | Recovery [s] | Cross [%] | Peak U [N m] | Peak U/12 |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 0.25 N m | 1 | 0.039170 | 0.015186 | 1.756 | 160.25 | 0.66249 | 0.055208 |
| 0.25 N m | 2 | 0.21793 | 0.049671 | 1.098 | 28.436 | 0.88765 | 0.073971 |
| 0.50 N m | 1 | 0.078339 | 0.030373 | 1.756 | 160.25 | 1.3250 | 0.11042 |
| 0.50 N m | 2 | 0.43586 | 0.099341 | 1.098 | 28.436 | 1.7753 | 0.14794 |
| 1.00 N m | 1 | 0.15668 | 0.060746 | 1.756 | 160.25 | 2.6500 | 0.22083 |
| 1.00 N m | 2 | 0.87172 | 0.19868 | 1.098 | 28.436 | 3.5506 | 0.29588 |

Gli offset non nulli sono riportati come risultato della struttura ottenuta;
M5 non definisce una soglia numerica autonoma di rigetto da applicare qui.

## Confronto diagnostico con M6

Il confronto usa direttamente `m6_lqg_no_integrator.mat`, senza retuning.

| Worst case sui sei scenari | M9 `mixsyn` | M6 LQG |
| --- | ---: | ---: |
| ordine controllore | 18 | 14 |
| tracking Ts [s] | 1.566 | 0.776 |
| tracking OS [%] | 261.62 | 0.26545 |
| tracking errore relativo [%] | 49.068 | 1.63e-12 |
| tracking cross-coupling [%] | 25.960 | 17.391 |
| tracking peak U [N m] | 8.2558 | 7.5034 |
| disturbo peak q [rad] | 0.87172 | 0.32051 |
| disturbo offset [rad] | 0.19868 | 0.32046 |
| disturbo cross-coupling [%] | 160.25 | 46.350 |
| disturbo peak U [N m] | 3.5506 | 2.5990 |

M9 riduce il massimo offset statico della tabella rispetto a M6, ma presenta
transitori, cross-coupling e tracking decisamente peggiori. Il confronto è
contestuale e non modifica né M6 né i pesi M9.

## Quality gate e limiti

| Gate | Esito |
| --- | --- |
| Nominal Stability | PASS |
| Weighted nominal mixed-sensitivity | FAIL — `gamma>=1` |
| Tracking M5 | FAIL |
| Disturbance rejection | QUANTIFIED — nessuna soglia M5 inventata |
| Control effort | QUANTIFIED — massimo 8.2558 N m, nessuna saturazione |
| Cross-coupling preliminare | FAIL |
| correttezza software e artifact | PASS |
| stato M9 | **PARTIAL** |

Questo risultato non autorizza modifiche a M5. Non sono state eseguite
analisi robuste sulla pianta M4 e non si può quindi concludere nulla su Robust
Stability o Robust Performance. Le attività `hinfsyn` e successive restano
fuori da M9 e richiedono la revisione del checkpoint.

## Riproduzione

`validate_m9_hinf_mixsyn` rigenera il dataset
`results/data/m9_hinf_mixsyn_nominal.mat` e sei figure in `results/figures`.
`run_all` esegue M9 dopo M8 e conserva il risultato prestazionale negativo
come `PARTIAL` senza trasformarlo in un errore software.
