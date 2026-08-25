# Generalized plant esplicita e sintesi `hinfsyn` — M10

**Responsabile:** Alessio
**Stato:** `PARTIAL` — generalized plant, sintesi e ricostruzione corrette;
obiettivi pesato, tracking e cross-coupling non soddisfatti.

## Obiettivo e perimetro

M10 verifica il principio:

> stessa pianta / stessi pesi / stesso scaling / diversa interfaccia di sintesi

La pianta nominale `G:u->q`, i pesi W1/W2 e la configurazione 1-DoF sono
quelli congelati in M9. Non sono stati introdotti disturbi fisici
nell'obiettivo H∞, W3, precompensatori, 2-DoF, retuning, `hinfstruct`, pianta
incerta M4 o mu-analysis.

## Segnali e generalized plant

La costruzione originale usa `connect`, `sumblk` e nomi I/O espliciti:

\[
e=r-q,\qquad q=Gu,\qquad z_1=W_1e,\qquad z_2=W_2u,
\]

con ingresso `[r;u]` e uscita `[z1;z2;y]`, dove `y=e`. Tutti i segnali
elementari sono bidimensionali; P è quindi 6×4 e ha ordine 18.

La forma analitica attesa è

\[
P=\begin{bmatrix}
W_1 & -W_1G\\
0   & W_2\\
I   & -G
\end{bmatrix}
=\begin{bmatrix}P_{11}&P_{12}\\P_{21}&P_{22}\end{bmatrix}.
\]

| Partizione | Dimensione | Significato |
| --- | ---: | --- |
| P11 | 4×2 | `r -> [z1;z2]` |
| P12 | 4×2 | `u -> [z1;z2]` |
| P21 | 2×2 | `r -> y`, equivalente a I |
| P22 | 2×2 | `u -> y`, equivalente a `-G` |

Per `hinfsyn`, `nmeas=2` e `ncont=2`. MATLAB chiude la lower LFT con
`u=K*y`; il segno negativo è già contenuto in P22 e realizza quindi
`u=K(r-q)`.

Il massimo errore frequenziale `connect/sumblk` rispetto alla formula
analitica è `1.137e-13`; l'errore di `P22+G` è zero sulla griglia di audit.
Solo dopo questa verifica è stato eseguito il cross-check reference-last con
`augw`, che differisce di `1.097e-14`. Le matrici di stato non sono state
confrontate perché le realizzazioni possono essere diverse.

## Gate di equivalenza M9 prima della sintesi

Prima di chiamare `hinfsyn`, `Kmix` è stato caricato dall'artifact M9 e
chiuso sulla nuova P:

```matlab
CL_M9_from_P = lft(P,Kmix);
```

| Verifica | Valore |
| --- | ---: |
| `||CL_M9_from_P-CLmix_M9||inf` | 2.688e-12 |
| `||CL_M9_from_P-weightedClosedLoop_M9||inf` | 2.535e-12 |
| `||CL_M9_from_P||inf` | 10.2071033931 |
| errore relativo rispetto a `gamma_M9` | 2.495e-8 |

La tolleranza di equivalenza è `1e-8`: il gate è `PASS`. Questo risultato
dimostra prima della sintesi che segni, ordine dei segnali, partizione e
scaling rappresentano lo stesso problema di M9.

## Sintesi `hinfsyn`

È stata eseguita una sola baseline con opzioni default:

```matlab
[Khinf,CLhinf,gammaHinf,infoHinf] = hinfsyn(P,2,2);
```

Il controllore è 2×2, ha ordine 18 e non ha generato warning. La stabilità
isolata di K è registrata come diagnostica, non come requisito.

| Metrica | Valore |
| --- | ---: |
| `gammaHinf` | 10.2071036477 |
| `infoHinf.gamma` | 10.2072906100 |
| `||W1*S10||inf` | 10.1276254519 |
| picco `W1*S10` | 0 rad/s |
| `||W2*KS10||inf` | 10.1853081898 |
| picco `W2*KS10` | 33.4393062 rad/s |
| `||[W1*S10;W2*KS10]||inf` | 10.2071033931 |
| picco stacked | 4.04083357 rad/s |
| errore relativo norma / gamma | 2.495e-8 |
| `||CLhinf-stack||inf` | 4.910e-12 |

La ricostruzione usa la pianta fisica originale:

\[
S_{10}=(I+GK_{hinf})^{-1},\quad T_{10}=I-S_{10},\quad
KS_{10}=K_{hinf}S_{10}.
\]

Il target `gammaHinf<1` è `FAIL`.

## Stabilità interna e condizionamento

La matrice plant-controller esplicita conserva 14 stati della pianta e 18
del controllore, per 32 stati totali, senza `minreal`.

| Diagnostica | Valore |
| --- | ---: |
| massima parte reale dei poli | -0.683828559887 s^-1 |
| poli nella realizzazione S10 | 32 |
| distanza poli espliciti/S10 | 0 |
| minima separazione fra poli | 1.3398e-10 |
| condition number autovettori | 1.2916e5 |

S10, T10, KS10 e CLhinf sono stabili. I modi quasi ripetuti sono conservati;
non risultano cancellazioni nascoste di modi instabili.

## Tracking nominale M10

Configurazione: `e=r-q`, `u=Khinf*e`, nessun precompensatore o saturazione.

| Rif. | Giunto | Ts [s] | OS [%] | Errore [rad] | Errore [%] | Cross [%] | Peak U [N m] | Peak U/12 |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 2° | 1 | 1.566 | 171.88 | 0.017128 | 49.068 | 25.960 | 2.0639 | 0.17200 |
| 2° | 2 | 1.216 | 261.62 | 0.012541 | 35.927 | 17.924 | 0.57173 | 0.047644 |
| 5° | 1 | 1.566 | 171.88 | 0.042820 | 49.068 | 25.960 | 5.1599 | 0.42999 |
| 5° | 2 | 1.216 | 261.62 | 0.031352 | 35.927 | 17.924 | 1.4293 | 0.11911 |
| 8° | 1 | 1.566 | 171.88 | 0.068512 | 49.068 | 25.960 | 8.2558 | 0.68798 |
| 8° | 2 | 1.216 | 261.62 | 0.050163 | 35.927 | 17.924 | 2.2869 | 0.19058 |

I target Ts, OS ed errore statico M5 sono `FAIL`; anche il limite
diagnostico di cross-coupling del 25% è superato sul giunto 1.

## Disturbo fisico lato link

Il disturbo M5 non entra nella sintesi. È applicato dopo la sintesi tramite
`q_d=S10*Gd*d` e `u_d=-KS10*Gd*d`.

| d | Giunto | Peak q [rad] | Offset [rad] | Recovery [s] | Cross [%] | Peak U [N m] | Peak U/12 |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 0.25 N m | 1 | 0.039170 | 0.015186 | 1.756 | 160.25 | 0.66249 | 0.055208 |
| 0.25 N m | 2 | 0.21793 | 0.049671 | 1.098 | 28.436 | 0.88765 | 0.073971 |
| 0.50 N m | 1 | 0.078339 | 0.030373 | 1.756 | 160.25 | 1.3250 | 0.11042 |
| 0.50 N m | 2 | 0.43586 | 0.099341 | 1.098 | 28.436 | 1.7753 | 0.14794 |
| 1.00 N m | 1 | 0.15668 | 0.060746 | 1.756 | 160.25 | 2.6500 | 0.22083 |
| 1.00 N m | 2 | 0.87172 | 0.19868 | 1.098 | 28.436 | 3.5506 | 0.29588 |

Il rigetto è `QUANTIFIED`: M5 non contiene una soglia numerica autonoma da
trasformare in un PASS artificiale. `uScale=12 N m` resta una normalizzazione.

## Confronto M6 / M9 / M10

| Worst case | M6 LQG | M9 `mixsyn` | M10 `hinfsyn` |
| --- | ---: | ---: | ---: |
| ordine K | 14 | 18 | 18 |
| gamma | N/A | 10.2071036477 | 10.2071036477 |
| norma pesata | N/A | 10.2071033931 | 10.2071033931 |
| stabile nominalmente | sì | sì | sì |
| tracking Ts [s] | 0.776 | 1.566 | 1.566 |
| tracking OS [%] | 0.26545 | 261.62 | 261.62 |
| errore tracking [%] | 1.63e-12 | 49.068 | 49.068 |
| cross tracking [%] | 17.391 | 25.960 | 25.960 |
| tracking peak U [N m] | 7.5034 | 8.2558 | 8.2558 |
| disturbo peak q [rad] | 0.32051 | 0.87172 | 0.87172 |
| disturbo offset [rad] | 0.32046 | 0.19868 | 0.19868 |
| cross disturbo [%] | 46.350 | 160.25 | 160.25 |
| disturbo peak U [N m] | 2.5990 | 3.5506 | 3.5506 |

## Interpretazione M9/M10

La differenza relativa fra i gamma è `2.938e-13`; l'errore H∞ fra mappe
pesate è `1.274e-9` e quello fra i controllori come funzioni di trasferimento
è `5.576e-11`. Tracking e disturbi congelati sono riprodotti esattamente
nelle tabelle. La classificazione è quindi **quasi-equivalenti**, non
“M10 migliore”. Le differenze nelle realizzazioni numeriche non modificano il
problema closed-loop.

## Quality gate

| Gate | Esito |
| --- | --- |
| Generalized Plant Correctness | PASS |
| Nominal Stability | PASS |
| H∞ Reconstruction | PASS |
| Weighted Nominal Performance | FAIL |
| Tracking | FAIL |
| Cross-coupling | FAIL diagnostico |
| Disturbance | QUANTIFIED |
| Control effort | QUANTIFIED_NO_SATURATION |
| M9/M10 consistency | PASS — quasi-equivalenti |
| correttezza software | PASS |
| stato M10 | **PARTIAL** |

M10 non autorizza variazioni M5 né M11. Robust Stability e Robust
Performance non sono state valutate; il risultato riguarda esclusivamente la
pianta nominale.

## Riproduzione

`validate_m10_hinfsyn` rigenera
`results/data/m10_hinfsyn_nominal.mat` e sei figure M10. `run_all` esegue M10
dopo M9, perché il gate metodologico usa l'artifact M9 appena rigenerato.
