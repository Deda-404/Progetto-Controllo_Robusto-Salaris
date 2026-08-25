# M12 — μ-analysis del controllore H∞ strutturato A5

**Responsabile:** Alessio
**Stato:** `PARTIAL` — correttezza software `PASS`; NS `PASS`, NP `FAIL`, RS/RP `FAIL_CERTIFIED`

## Perimetro congelato

M12 è una milestone di sola analisi. Il controllore è il rappresentante M11
`A5`, full MIMO `tunableSS` di ordine reale 6, start 5, caricato da
`results/data/m11_hinfstruct_structured.mat`. Non è stata eseguita una nuova
sintesi `hinfstruct`. A5 appartiene alla frontiera Pareto M11 e porta l'ordine
da 18 di M10 a 6 con una norma pesata vicina al full-order; non è stato scelto
perché conforme a M5, che continua a fallire.

La pianta incerta è `GuncQ` dell'artifact M4 e i pesi sono esattamente `W1`,
`W2`, `W3=[]` dell'artifact M5. Non sono stati eseguiti retuning, nuovi
scaling, Monte Carlo o validazioni non lineari.

## Incertezza M4 e consistenza nominale

| Blocco | Tipo | Nominale | Intervallo / bound |
| --- | --- | ---: | ---: |
| `Delta_act1` | `ultidyn` | — | `||Delta||∞ <= 1` |
| `Delta_act2` | `ultidyn` | — | `||Delta||∞ <= 1` |
| `Jm1` | `ureal` | 0.01 | [0.0091, 0.0109], ±9% |
| `k1` | `ureal` | 50 | [46.5, 53.5], ±7% |
| `k2` | `ureal` | 40 | [37.2, 42.8], ±7% |

I due blocchi dinamici attuatore sono indipendenti e usano il peso `WI` M4
di ordine 1 nella convenzione `Ga_unc=Ga_nom*(1+WI*Delta_act)`. Il nominale
raw di `GuncQ` ha ordine 16: contiene i 14 poli M3 più due poli stabili
associati alla realizzazione del peso. Tutti i poli M3 sono inclusi entro
`1e-8`; l'errore massimo in frequenza tra `GuncQ.NominalValue` e `GfullQ` è
`4.219e-15`. Non sono comparsi blocchi inattesi.

## Pianta generalizzata incerta

La pianta è costruita con una sola istanza condivisa di `GuncQ` mediante
interconnessione nominata:

\[
P_{unc}=\begin{bmatrix}
W_1 & -W_1G_{unc}\\
0 & W_2\\
I & -G_{unc}
\end{bmatrix},
\qquad
T_{zw,unc}=\operatorname{lft}(P_{unc},K_{A5}).
\]

`Punc` è 6×4 e `Tzw_unc` è 4×2. La costruzione a pianta condivisa evita di
duplicare i blocchi incerti e gli stati interni. Il massimo errore in
frequenza tra `Punc.NominalValue` e la pianta M10 è `8.174e-14`; il weighted
closed loop nominale coincide con il rappresentante A5 M11 entro
`1.130e-12` sulle mappe ricostruite.

## Decomposizione N–Δ

La chiamata `lftdata(Tzw_unc)` restituisce:

- `M`: 9×7, ordine 26;
- `Delta`: 5×5;
- `M11mu`: 5×5, estratta dalla partizione uncertainty-to-uncertainty;
- cinque elementi `BlkStruct`, tutti 1×1 e con una occorrenza;
- cinque occorrenze normalizzate.

| Sorgente | Tipo normalizzato | Range / bound normalizzato |
| --- | --- | --- |
| `Delta_act1`, `Delta_act2` | `ultidyn` | bound 1 |
| `Jm1`, `k1`, `k2` | `ureal` | [-1, 1] |

`lft(Delta,M)` conserva esattamente l'insieme dei blocchi. L'errore nominale
è entro la tolleranza `1e-9`; la sostituzione di una perturbazione
deterministica non nominale dà errore frequenziale `0.000e+00`. Non sono
stati usati `minreal` o `simplify` nel quality gate.

## Nominal Stability e Nominal Performance

La dinamica interna fisica comprende 14 stati plant e 6 stati controller.
I 20 poli, senza cancellazioni, sono:

```text
-133.862633, -133.333675
-0.736157 ± 80.200737i, -0.922010 ± 70.079970i
-49.049606 ± 27.771016i, -28.890501 ± 27.911433i
-23.477015 ± 10.119391i, -2.763891 ± 12.872192i
-3.717779 ± 0.862145i, -4.783326 ± 3.970800i
-2.553653 ± 7.375296i
```

La massima parte reale è `-0.736157095561`; `S`, `T`, `KS` e lo stack
pesato sono stabili. I poli e le mappe coincidono con M11: **NS = PASS**.

La norma ricostruita è
`||[W1*S;W2*K*S]||∞ = 10.2476411502`, con picco a
`6.21670809748 rad/s`. Poiché il target congelato è `gamma<1`,
**NP = FAIL**. Il risultato non autorizza modifiche di M5.

## Robust Stability: `robstab` e μ manuale

`robstab` è stato eseguito una volta con display disattivato, sensitivity
attiva e opzioni `mussv` di default:

| Metodo | Lower margin | Upper margin | Frequenza critica [rad/s] | Esito |
| --- | ---: | ---: | ---: | --- |
| `robstab` | 0.875899252687 | 0.882789198079 | 81.9862784922 | `FAIL_CERTIFIED` |
| `mussv` fisso | 0.879212158739 | 0.883347347680 | 81.5955861689 | coerente |

La griglia manuale, definita prima dell'analisi, è
`logspace(-3,4,1201)`. I massimi lower/upper μ sono rispettivamente
`1.13205751127` e `1.13738190499`, entrambi a `81.5955861689 rad/s`.
La classificazione, l'ordine di grandezza e la frequenza critica sono
coerenti con `robstab`: il gate di consistenza manuale è `PASS`.

La perturbazione `wcuRS` porta la massima parte reale a circa `1.08e-9`,
coerentemente con il limite numerico di stabilità. I valori reali sono
`Jm1=0.01044636`, `k1=51.69921`, `k2=42.47176`; i moduli normalizzati sono
0.49596, 0.48549 e 0.88277. Entrambi i blocchi dinamici hanno peak gain
0.882789; alla frequenza critica le fasi sono circa -143.39° e -165.92°.

Le sensitivity RS esposte dall'API sono 16%, 80%, 1%, 0% e 1% per
`Delta_act1`, `Delta_act2`, `Jm1`, `k1` e `k2`: il canale attuatore 2 è il
contributo locale dominante secondo questa diagnostica. Questo non trasforma
la sensitivity in una misura esatta del contributo globale.

## Robust Performance: `robgain` e `wcgain`

`robgain(Tzw_unc,1)` restituisce performance margin `[0,0]`; la frequenza
critica non è applicabile. Il nominale `Delta=0` appartiene all'insieme M4,
quindi NP `FAIL` ha precedenza e **RP = FAIL_CERTIFIED**. Le sensitivity RP
non sono esposte in modo finito dall'API in questo caso e sono conservate
come `NaN`, senza valori inventati.

`wcgain` a uncertainty level 1 restituisce bound `[Inf,Inf]` e frequenza
critica `11.6337064663 rad/s`: l'insieme M4 contiene perturbazioni che
portano la chiusura al limite di stabilità, per cui il worst-case weighted
gain non è limitato. La sostituzione di `wcuGain` produce una norma numerica
`4.45231081353e14` e un polo con massima parte reale `7.11e-15`, coerente con
il risultato infinito. Questa diagnostica non sostituisce il performance
margin di `robgain`.

## Sintesi centrale NS / NP / RS / RP

| Property | Metric | Lower | Upper | Critical freq [rad/s] | Outcome |
| --- | ---: | ---: | ---: | ---: | --- |
| NS | max Re dei poli = -0.736157095561 | — | — | — | `PASS` |
| NP | norma pesata = 10.2476411502 | — | — | 6.21670809748 | `FAIL` |
| RS | robust stability margin | 0.875899252687 | 0.882789198079 | 81.9862784922 | `FAIL_CERTIFIED` |
| RP | performance margin a gamma=1 | 0 | 0 | — | `FAIL_CERTIFIED` |

La stabilità nominale non implica stabilità robusta. NP è necessaria per RP,
ma RS e RP restano proprietà distinte. I lower/upper bound sono intervalli di
certificazione e non vengono sostituiti dal loro valore medio.

## Artifact, test e limiti

`validate_m12_mu_analysis` genera
`results/data/m12_mu_analysis_a5.mat` e sei figure ingegneristiche. La suite
M12 contiene 54 test; sono stati superati 54/54, la regressione M9–M12 è
171/171 e l'intera suite è 310/310. `run_all` termina con exit code 0 e il
Code Analyzer restituisce zero messaggi sui file M12.

M12 resta `PARTIAL`: il software e la decomposizione sono corretti, ma A5
fallisce NP, RS e RP sul problema congelato. Non sono stati eseguiti
Monte Carlo, Simulink non lineare, retuning, `mixsyn`, `hinfsyn`,
`hinfstruct`, `musyn`, D–K iteration o M13 nei file M12.
