# μ-analysis finale del controllore D–K Kmu

**Responsabile:** Alessio
**Milestone:** M14
**Stato:** `PARTIAL` — software corretto e Robust Stability recuperata, ma
Nominal Performance e Robust Performance non conformi a M5

## Perimetro congelato

M14 è una verifica indipendente, non una nuova sintesi. Il controllore `Kmu`
è caricato direttamente da `results/data/m13_musyn_dk.mat`: è 2×2, ordine
52, coincide esattamente con `rawInfo(3).K` e non subisce riduzione o tuning.
La best iteration 3, l'objective `10.4032233618`, la norma nominale
`10.3917314574` e il polo interno massimo `-0.731994726169` sono letti
dall'artifact M13.

Restano congelati `GuncQ` M4, W1/W2 M5, `W3=[]`, l'architettura 1-DoF e la
pianta generalizzata

\[
P_{unc}=\begin{bmatrix}
W_1 & -W_1G_{unc,Q}\\
0 & W_2\\
I & -G_{unc,Q}
\end{bmatrix},
\qquad T_{zw,\mu}=\operatorname{lft}(P_{unc},K_\mu).
\]

`Punc` è 6×4 e `Tzw_mu_unc` è 4×2. Dimensioni, nomi, nominale, blocchi e
struttura `lftdata` coincidono con M12 e con l'audit registrato da M13.

## Pipeline M12 riutilizzata

La configurazione M14 deriva da `mu_analysis_specs_m12` e conserva senza
modifiche griglie, opzioni `mussv`/`robstab`/`robgain`/`wcgain`, target
`gamma=1` e tolleranze. Sono riusate direttamente:

- `decompose_m12_ndelta`;
- `analyze_m12_manual_mu`;
- `analyze_m12_robust_stability`;
- `analyze_m12_robust_performance`.

Non sono state eseguite `musyn`, `hinfsyn`, `mixsyn`, `hinfstruct`, D–K,
riduzione del controllore, retuning, Monte Carlo o simulazioni non lineari.

## Ricostruzione nominale

Il loop fisico usa la realizzazione completa di G e Kmu, senza `minreal`.
Sono ricostruiti indipendentemente

\[
S=(I+GK_\mu)^{-1},\qquad T=I-S,\qquad KS=K_\mu S,
\]

e lo stack `[W1*S; W2*Kmu*S]`. Le mappe, la norma e i 66 poli interni
coincidono con M13 entro le tolleranze. La massima parte reale è
`-0.731994726169`, quindi Nominal Stability è `PASS`.

La norma nominale è `10.3917314574`, con picco a
`93.1402569484 rad/s`. Poiché il target M5 resta 1, Nominal Performance è
`FAIL`. Questo esito non è un errore software e implica che Robust
Performance non possa essere `PASS`, dato che il nominale appartiene
all'insieme M4.

## Forma N–Δ e μ manuale

`lftdata(Tzw_mu_unc)` conserva i cinque blocchi `Delta_act1`, `Delta_act2`,
`Jm1`, `k1`, `k2`, tutti 1×1 e con una sola occorrenza. `Delta` e la
partizione uncertainty-to-uncertainty sono 5×5; la ricostruzione mediante
`lft(Delta,M)` supera sia il gate nominale sia la perturbazione deterministica
M12. Le tre `ureal` sono normalizzate in `[-1,1]` e le due `ultidyn` hanno
bound unitario.

Sulla griglia M12 da 1201 punti, `mussv(...,'s')` restituisce:

| Quantità | Valore |
| --- | ---: |
| massimo μ upper | 0.798429978849 |
| massimo μ lower | 0.798350124024 |
| frequenza critica upper/lower | 17.4113855855 rad/s |
| margine da μ, lower approximation | 1.25245798190 |
| margine da μ, upper approximation | 1.25258325878 |

## Robust Stability

`robstab` con le opzioni M12 produce il margine
`[1.25003698645, 1.25257264120]` a `17.3621393164 rad/s`. Il lower bound è
maggiore di uno, quindi RS è `PASS_CERTIFIED`. La classificazione coincide
con la μ manuale; gli errori sui margini e sulla frequenza rientrano nelle
tolleranze M12 e il gate di coerenza è `PASS`.

La perturbazione restituita da `robstab` è stata sostituita sia nella
chiusura pesata sia nel loop fisico. Le massime parti reali sono
`-2.205e-13` e `3.284e-13`: valori numericamente di frontiera, senza imporre
uno zero esatto del polo critico.

## Robust Performance e worst-case gain

`robgain(Tzw_mu_unc,1,options)` restituisce il performance margin `[0,0]`.
La precedenza NP→RP è applicata, quindi RP è `FAIL_CERTIFIED`. L'assenza di
una sensitivity RP finita è conservata come `NaN`; non viene inventata una
diagnostica.

Con uncertainty level 1, `wcgain` restituisce
`[25.9514560605, 26.1151353973]` a `16.1320063635 rad/s`. La sostituzione
reale della perturbazione dà gain `25.9514465894` e resta coerente con i
bound. Questi valori non sono confrontati come se fossero equivalenti
all'objective `musyn`: objective di sintesi, margini robusti e worst-case
gain hanno significati diversi.

## Confronto A5–Kmu

| Metrica | A5 M12 | Kmu M14 |
| --- | ---: | ---: |
| ordine controllore | 6 | 52 |
| norma pesata nominale | 10.2476411502 | 10.3917314574 |
| max Re nominale | -0.736157095561 | -0.731994726169 |
| NS | PASS | PASS |
| RS LowerBound | 0.875899252687 | 1.25003698645 |
| RS UpperBound | 0.882789198079 | 1.25257264120 |
| frequenza critica RS [rad/s] | 81.9862784922 | 17.3621393164 |
| RS | FAIL_CERTIFIED | PASS_CERTIFIED |
| RP margin | [0,0] | [0,0] |
| RP | FAIL_CERTIFIED | FAIL_CERTIFIED |
| wcgain | [Inf,Inf] | [25.9514560605,26.1151353973] |
| blocco dominante sensitivity RS | Delta_act2 | Delta_act2 |

I delta RS sono `+0.374137733765` sul lower bound e `+0.369783443123`
sull'upper bound, pari rispettivamente a `+42.7147%` e `+41.8881%` rispetto
ad A5. Entrambi i bound aumentano e la classificazione passa da
`FAIL_CERTIFIED` a `PASS_CERTIFIED`; il risultato è quindi
`CLEAR_IMPROVEMENT`, senza usare il midpoint. Si tratta di un recupero
certificato della Robust Stability, non della Robust Performance.

## Blocchi critici

`Delta_act2` resta il blocco dominante per RS: la sensitivity passa da 80
per A5 a 86 per Kmu. Seguono `Delta_act1` a 11, `k2` a 2, `Jm1` a 1 e `k1`
a 0. La tabella completa nell'artifact conserva sensitivity RS/RP/wcgain e
magnitudini normalizzate delle tre perturbazioni worst-case. I campi non
disponibili dall'API sono `NaN`, come richiesto.

## Esito finale

| Proprietà | Metrica | Lower | Upper | Frequenza critica | Esito |
| --- | ---: | ---: | ---: | ---: | --- |
| NS | max Re = -0.731994726169 | — | — | — | PASS |
| NP | gamma = 10.3917314574 | — | — | 93.1402569484 | FAIL |
| RS | robust stability margin | 1.25003698645 | 1.25257264120 | 17.3621393164 | PASS_CERTIFIED |
| RP | performance margin a gamma 1 | 0 | 0 | NaN | FAIL_CERTIFIED |

Frozen Kmu, M4, M5, Punc, ricostruzione nominale, N–Δ, coerenza μ/robstab
e software sono `PASS`; wcgain, confronto e blocchi critici sono
`QUANTIFIED`. M14 è `PARTIAL`, perché `COMPLETE` richiederebbe anche NP e RP
conformi. Kmu resta congelato a ordine 52; un'eventuale validazione non
lineare richiede una milestone M15 separata e una nuova autorizzazione.

## Artifact riproducibili

- `results/data/m14_final_mu_analysis_kmu.mat`;
- `results/figures/m14_mu_rs_bounds_kmu_vs_a5.png`;
- `results/figures/m14_rs_margins_a5_vs_kmu.png`;
- `results/figures/m14_nominal_weighted_a5_vs_kmu.png`;
- `results/figures/m14_worst_case_weighted_kmu.png`;
- `results/figures/m14_rs_sensitivity_a5_vs_kmu.png`;
- `results/figures/m14_ns_np_rs_rp_summary.png`.
