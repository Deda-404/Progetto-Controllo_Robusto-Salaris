# Project Status

**Current milestone:** M13 — D–K iteration / μ-synthesis sul problema M4/M5 congelato
**Status:** `COMPLETE` — sintesi software `PASS`, Kmu nominalmente stabile, objective `10.4032233618`
**Last validated milestone:** M13 `COMPLETE`; M8 resta l'ultima milestone non lineare `COMPLETE`
**Last tracking-conforming controller:** M6 — LQG nominale senza integratore
**M7:** `PARTIAL` — feasibility conclusa e accettata; nessun ulteriore tuning previsto
**Open technical issue:** l'objective M13 resta >1; RS/RP del nuovo Kmu non sono ancora verificate e appartengono a M14
**Next task:** revisione tecnica della PR M13; non iniziare M14 senza autorizzazione
**Pull Request:** PR M13 da aprire verso `main`; [PR #17](https://github.com/Deda-404/Progetto_CR/pull/17) `merged` al commit `9b69caa02c7f8dbca9cc2b936067f67c25904f1a`
**Last update:** 2026-08-25, quality gate M13 completato

## Quality gate M13 — COMPLETE

| Requisito | Esito |
| --- | --- |
| baseline Git | PASS — PR #17 mergiata al commit `9b69caa02c7f8dbca9cc2b936067f67c25904f1a` |
| technical aborted attempt | RECORDED — `Display='full'`, pausa interattiva batch, nessun output utilizzato |
| problema congelato | PASS — Punc M12 6×4, nmeas/ncont 2/2, identità nominale/LFT con errore `0` |
| incertezza congelata | PASS — cinque blocchi M4 e range invariati |
| pesi congelati | PASS — W1/W2 M5 invariati, `W3=[]`, nessun retuning |
| campagna valida | PASS — una chiamata non interattiva con `Display='short'`, MaxIter 5 e opzioni matematiche congelate |
| storico D–K | PASS — 5/5 iterazioni complete, classificazione diagnostica `MAX_ITER_REACHED` |
| objective musyn | QUANTIFIED — `10.4032233618`, best iteration 3, non certificazione RP |
| controller | PASS — Kmu 2×2, ordine 52, matrici finite, nessuna riduzione |
| stabilità nominale | PASS — 66 stati interni, max Re `-0.731994726169` |
| ricostruzione nominale | PASS — errore stack/Punc `4.083e-12` |
| norma nominale | QUANTIFIED — `10.3917314574` a `93.1402569484 rad/s` |
| confronto M10 | PASS metodologico — nessuna violazione del lower bound nominale |
| warning MATLAB | nessuno nel run valido |
| artifact | PASS — dataset raw/completo e sei figure |
| test M13 | PASS — 52/52 |
| suite completa / `run_all` | PASS — 362/362, exit code 0 |
| Code Analyzer M13 | PASS — zero messaggi su otto file |
| analisi formale RS/RP Kmu | NOT RUN corretto — riservata a M14 |
| stato | **COMPLETE — correttezza software e stabilità nominale PASS, objective >1 accettato** |

**Responsabile:** Alessio

## Quality gate M12 — PARTIAL

| Requisito | Esito |
| --- | --- |
| baseline Git | PASS — PR #16 mergiata al commit `c5b14e5332279e8e98b89d4c5b7a180102646fde` |
| controllore congelato | PASS — A5 M11, start 5, ordine 6, caricato dall'artifact |
| incertezza congelata | PASS — `GuncQ` M4, cinque blocchi e range invariati |
| pesi | PASS — W1/W2 M5 invariati, `W3=[]`, nessun retuning |
| pianta generalizzata incerta | PASS — `Punc` 6×4, `Tzw_unc` 4×2, una sola istanza condivisa di GuncQ |
| consistenza nominale | PASS — M4/M3 `4.219e-15`, Punc/M10 `8.174e-14`, chiusura A5/M11 coerente |
| N–Δ | PASS — M 9×7, Delta 5×5, cinque blocchi normalizzati, ricostruzione non nominale `0` |
| Nominal Stability | **PASS — 20 stati interni, max Re `-0.736157095561`** |
| Nominal Performance | **FAIL — norma `10.2476411502` > 1** |
| Robust Stability | **FAIL_CERTIFIED — margin `[0.875899252687, 0.882789198079]`** |
| μ manuale RS | PASS coerenza — margin `[0.879212158739, 0.883347347680]` |
| Robust Performance | **FAIL_CERTIFIED — NP FAIL, performance margin `[0,0]`** |
| worst-case gain | QUANTIFIED — `[Inf,Inf]`, sostituzione `4.4523e14` vicino al limite di stabilità |
| blocchi critici | QUANTIFIED — sensitivity RS massima su `Delta_act2` (80%) |
| artifact | PASS — dataset e sei figure |
| test M12 | PASS — 54/54 |
| regressione M9–M12 | PASS — 171/171 |
| suite completa / `run_all` | PASS software — 310/310, exit code 0 |
| Code Analyzer M12 | PASS — 0 messaggi su 11 file |
| sintesi / Monte Carlo / non lineare / M13 | NOT RUN corretto |
| stato | **PARTIAL — software corretto, NP/RS/RP non conformi** |

**Responsabile:** Alessio

## Quality gate M11 — PARTIAL

| Requisito | Esito |
| --- | --- |
| baseline Git | PASS — branch M11 da `47ea295aef28a941f2f443033c03f10c5a6caa4d` |
| housekeeping | PASS — PR #15 registrata come mergiata nel baseline commit |
| generalized plant | PASS — artifact M10 6×4, ordine 18, errore frequenziale nullo |
| pesi | PASS — W1/W2 M5 invariati, `W3=[]`, nessun retuning |
| campagna | PASS — A0–A5 congelate, ordine massimo 6, 30/30 record restituiti |
| multistart | PASS — cinque start/famiglia, seed base 20260827, no parallel |
| A0/A1 | FAIL di convergenza — 0/5 objective finiti, 0/5 stabili |
| A2 | FAIL di stabilità — 4/5 objective finiti, 0/5 stabili |
| A3 | PASS famiglia — 5/5 stabili; best ordine 2, start 4, gamma 16.6418540 |
| A4 | PASS famiglia — 5/5 stabili; best ordine 4, start 2, gamma 11.6555347 |
| A5 | PASS famiglia — 5/5 stabili; best ordine 6, start 5, gamma 10.2477452 |
| stabilità di tutti gli start | **FAIL — 15/30 stabili** |
| ricostruzione indipendente | PASS — S/T/KS/stack e objective coerenti per A3/A4/A5 |
| lower bound M10 | PASS — nessuna violazione rispetto a 10.2071036477 |
| frontiera Pareto | A3/A4/A5 — trade-off reale ordine/gamma, nessuna scelta forzata |
| weighted nominal objective | **FAIL — tutte le norme strutturate sono >1** |
| tracking | **FAIL — target M5 non soddisfatti** |
| cross-coupling tracking | **FAIL globale — solo A5 passa il limite diagnostico** |
| disturbo lato link | QUANTIFIED — 18 scenari complessivi sui rappresentanti |
| comando | QUANTIFIED_NO_SATURATION — `uScale=12 N m` solo normalizzazione |
| variabilità | QUANTIFIED — best/median/worst/std e best start per famiglia |
| artifact | PASS — dataset e sei figure |
| test M11 | PASS — 48/48 |
| regressione M9/M10/M11 | PASS — 117/117 |
| test top-level / `run_all` | PASS software — 256/256, exit code 0 |
| Code Analyzer M11 | PASS — 0 messaggi su 12 file |
| analisi robusta / M12 | NOT RUN corretto |
| stato | **PARTIAL — software corretto, performance non conforme** |

**Responsabile:** Alessio

## Quality gate M10 — PARTIAL

| Requisito | Esito |
| --- | --- |
| baseline Git | PASS — PR #14 mergiata al commit richiesto |
| generalized plant | PASS — 6×4, ordine 18, `connect/sumblk` |
| partizione | PASS — P11/P12 4×2, P21/P22 2×2, `nmeas=ncont=2` |
| convenzione | PASS — `e=r-q`, `P21=I`, `P22=-G` |
| equivalenza analitica | PASS — massimo errore frequenziale `1.137e-13` |
| cross-check `augw` | PASS diagnostico — errore `1.097e-14`, reference-last |
| gate M9 prima di `hinfsyn` | PASS — errori CLmix/stack `2.688e-12/2.535e-12` |
| sintesi | PASS software — `hinfsyn(P,2,2)` default, K ordine 18, nessun warning |
| stabilità nominale | PASS — 32 poli interni, max real part `-0.683828559887` |
| ricostruzione H∞ | PASS — norma `10.2071033931`, errore relativo `2.495e-8` |
| `CLhinf` ricostruito | PASS — errore H∞ `4.910e-12` |
| weighted nominal objective | **FAIL — `gammaHinf=10.2071036477 >= 1`** |
| tracking | **FAIL — worst Ts 1.566 s, OS 261.619%, errore 49.068%** |
| cross-coupling tracking | **FAIL diagnostico — worst 25.960% > 25%** |
| disturbo lato link | QUANTIFIED — worst peak/offset `0.87172/0.19868 rad` |
| comando | QUANTIFIED — worst 8.2558 N m = 0.68798 di `uScale` |
| M9/M10 consistency | PASS — delta gamma relativo `2.938e-13`, quasi-equivalenti |
| robustezza/M11+ | NOT RUN corretto — fuori scope M10 |
| artifact | PASS — dataset e sei figure |
| test M10 | PASS — 40/40 |
| test M9+M10 | PASS — 69/69 dopo aggiornamento del perimetro T22 M9 |
| test top-level / `run_all` | PASS software — 208/208, exit code 0 |
| Code Analyzer M10 / regressione M9 | PASS — 0 messaggi |
| `git diff --check` | PASS |
| stato | **PARTIAL — nessun retuning automatico M5** |

**Responsabile:** Alessio

## Quality gate M9 — PARTIAL

| Requisito | Esito |
| --- | --- |
| baseline Git | PASS — PR #13 mergiata al commit richiesto |
| pianta nominale | PASS — `G:u->q` 2×2, ordine 14, M3/M5 coerenti |
| attuatori/equilibrio | PASS — 40 rad/s, 0.8, 15 ms, Padé 1; `qbar=[pi/2;0]` |
| pesi | PASS — W1/W2 M5 congelati, errori di rigenerazione nulli, `W3=[]` |
| sintesi | PASS software — `mixsyn(G,W1,W2,[])`, K ordine 18, nessun warning |
| stabilità nominale | PASS — 32 poli interni, max real part `-0.683828559884` |
| norma ricostruita | PASS software — `10.2071033931`, errore relativo `2.495e-8` |
| `CLmix` ricostruito | PASS — errore H∞ `4.313e-12` |
| `||W1*S||inf` | `10.1276254519` |
| `||W2*KS||inf` | `10.1853081898` |
| weighted nominal objective | **FAIL — `gamma=10.2071036477 >= 1`** |
| tracking | **FAIL — worst Ts 1.566 s, OS 261.619%, errore 49.068%** |
| cross-coupling tracking | **FAIL diagnostico — worst 25.960% > 25%** |
| disturbo lato link | QUANTIFIED — worst peak/offset `0.87172/0.19868 rad` |
| comando | QUANTIFIED — worst 8.2558 N m = 0.68798 di `uScale` |
| saturazione | PASS metodologico — nessuna inventata |
| confronto M6 | PASS diagnostico — artifact M6 invariato |
| robustezza/μ-analysis | NOT RUN corretto — fuori scope M9 |
| artifact | PASS — dataset e sei figure |
| test M9 | PASS — 29/29 |
| test top-level / `run_all` | PASS software — 168/168, exit code 0 |
| Code Analyzer M9 | PASS — 0 messaggi su otto file |
| `git diff --check` | PASS |
| stato | **PARTIAL — nessun retuning automatico M5** |

**Responsabile:** Alessio

## Quality gate M8 — COMPLETE

| Requisito | Esito |
| --- | --- |
| governance M7 | PASS — `PARTIAL` terminale, M5 e checkpoint invariati |
| controllore primario | PASS — M6 `K/L/Nr` identici al dataset |
| modello Simulink | PASS — originale, modulare, senza base workspace |
| plant non lineare | PASS — equazioni M1 reali, 8 stati |
| attuatori M3 | PASS — secondo ordine + Padé 1, 6 stati |
| ordine fisico / stimatore | PASS — 14 / 14; totale continuo 28 |
| coordinate | PASS — plant assoluto, controller incrementale |
| solver | PASS — `ode23t`, `1e-5/1e-7`, max step 5 ms |
| equilibrio 4 s | PASS — errori q/theta/u `4.09e-17/3.85e-17/1.69e-15` |
| tracking | PASS — 2/5/8° separati su entrambi i giunti |
| LTI/NL | PASS — massimo scarto q `6.2015e-4 rad` |
| disturbi | PASS — d1/d2 a 0.25/0.50/1.00 N m; offset M6 visibile |
| rumore | PASS — seed 20260826, rilancio identico |
| RAS primaria | PASS — 57/57 convergenti, box computazionale interamente convergente |
| RAS secondaria | PASS diagnostico — stima iniziale coerente, 57/57 convergenti |
| frontiera | PASS — 36 direzioni; search-box limited |
| area poligonale | 14214 deg², non certificata oltre il box |
| saturazione | PASS — nessuna inventata; `uScale` resta normalizzazione |
| benchmark I25 | NOT RUN corretto — confronto lineare M7 preservato fuori dal gate |
| dataset / figure | PASS — un dataset, cinque figure |
| test M8 | PASS — T1–T18 |
| test top-level / `run_all` | PASS — 139/139, exit code 0 |
| Code Analyzer M8 | PASS — 0 messaggi su nove file |
| stato | **COMPLETE** |

**Responsabile:** Alessio

## Quality gate M7 final feasibility — PARTIAL

| Requisito | Esito |
| --- | --- |
| base Git | PASS — PR #11 unita in `main` al commit `b28a06a` |
| checkpoint I25 / Stage A-B | PASS — dataset e risultati preservati |
| architettura | PASS — `xi_dot=r-q`, `u=-Kx*x-Ki*xi+Nff*r` |
| scale fisiche M6 / `xiScale` M7 | PASS — identiche per 75/75 candidati |
| costruzione costo | PASS — `Qaug=CaugCost'*CaugCost` |
| coefficienti variati | PASS — sole priorità adimensionali autorizzate |
| Stage C1 | PASS software — griglia completa 75/75, tutti stabili |
| candidati promettenti C1 | **0/75** |
| candidati ammissibili C1 | **FAIL performance — 0/75** |
| miglior settling C1 | C113: 1.026 s, 40.8714%, `peakU/uScale=2.08761` |
| minimo overshoot | C161: 9.61367%, ma `Ts=Inf` entro 3 s |
| Stage C2 | NOT RUN corretto — nessun seed C1 promettente |
| Stage C3 | NOT RUN corretto — nessun candidato C2 vicino ai target |
| ricerca oltre C3 | NO |
| offset `d1/d2` | PASS — 75/75 entro `1e-4 rad`, massimo `2.241e-18` |
| `Nff` candidato-specifico | PASS — max cond 1.66908, max residuo `3.140e-16` |
| M5 / modello / Kalman / uncertainty set | PASS — invariati |
| candidato finale / guadagni finali | NOT RUN — insieme ammissibile vuoto |
| LQG-I ordine 16 / measured-estimated / rumore | NOT RUN — gate prestazionale fallito |
| dataset/figure feasibility | PASS — un dataset e due figure |
| Code Analyzer | PASS — 0 messaggi su otto file |
| test M7 estesi | PASS — 29/29 |
| test top-level / `run_all` | PASS software — 121/121, exit 0, esito finale PARTIAL |
| stato | **PARTIAL — revisione formale M5 richiesta** |

**Responsabile:** Alessio

## Quality gate M7 completion 2-DoF — PARTIAL

| Requisito | Esito |
| --- | --- |
| checkpoint precedente preservato | PASS — merge `f702b5b`, dataset e decisioni invariati |
| architettura 2-DoF | PASS — integratore più `Nff*r` |
| `Nff` candidato-specifico | PASS — nessun riuso di `Nr` M6 |
| condizionamento `Gdc_x` | PASS — massimo 1.75379 |
| residuo `Gdc_x*Nff-I` | PASS — massimo `2.483e-16` |
| indipendenza rigetto disturbo da `Nff` | PASS — differenza massima 0 rad |
| Stage A | PASS software — 28/28 eseguiti prima di Stage B |
| ammissibili Stage A | **FAIL performance — 0/28** |
| Stage B condizionale | PASS software — eseguita una volta, 25/25 |
| ammissibili Stage B | **FAIL performance — 0/25** |
| miglior Stage B | E16: 1.020 s, 40.6448%, 35.170 N m |
| M5 / Qx / `xiScale` | PASS — invariati |
| offset costante | PASS — 53/53 entro `1e-4 rad` |
| candidato finale | NOT RUN — insieme ammissibile vuoto |
| LQG-I ordine 16 / KF03 / separation | NOT RUN — secondo stop |
| measured-vs-estimated / rumore | NOT RUN — nessun controller finale |
| saturazione / anti-windup | PASS — non introdotti |
| dataset/figure feasibility | PASS |
| test M7 completion | PASS — 19/19 |
| test top-level / `run_all` | PASS software — 111/111, exit 0, esito finale PARTIAL |
| stato | **PARTIAL — revisione richiesta** |

**Responsabile:** Alessio

## Quality gate M7 — checkpoint PARTIAL

| Requisito | Esito |
| --- | --- |
| main contiene M6 | PASS — merge `5326567` verificato |
| due integratori sulle sole `q` | PASS |
| augmented plant | PASS — 16×16, PBH controllabile e stabilizzabile |
| zero obstruction | PASS — PBH/Rosenbrock a zero rango 16 |
| priorità M6 | PASS — blocco `Qx` riusato esattamente |
| `xiScale` | PASS — 0.0698131701 rad s derivata da M5 |
| griglia autonoma | PASS — 28/28 candidati |
| stabilità | PASS — 28/28 |
| offset `d1/d2` | PASS — 28/28 entro `1e-4 rad` via guadagno DC |
| tracking M5 | **FAIL — 0/28; minimo 1.964 s > 0.8 s** |
| candidato selezionato | NOT RUN — insieme ammissibile vuoto |
| Kalman KF03 / controller ordine 16 | NOT RUN — stop dopo il gate LQI |
| separation / rumore / measured-vs-estimated | NOT RUN — nessun controllore finale |
| saturazione / anti-windup | PASS — non introdotti |
| dataset finale e sette figure | NOT RUN — non pubblicati artifact finali impropri |
| dataset e figura checkpoint | PASS |
| test M7 checkpoint | PASS — 15/15 |
| test top-level / `run_all` | PASS tecnico — 107/107, exit 0, messaggio finale PARTIAL |
| Code Analyzer | PASS — 0 messaggi su sei file M7/pipeline |
| M5 modificata | NO |
| stato | **PARTIAL — revisione richiesta** |

**Responsabile:** Alessio

## Quality gate M6

| Requisito | Esito |
| --- | --- |
| cleanup epistemico M5 | PASS — nessun numero M5 modificato |
| modello nominale completo | PASS — 14 stati, 2 ingressi, 4 misure encoder |
| diagnosi baseline | PASS — modo dominante e rapporto pesi quantificati |
| coarse grid LQR | PASS — 240 candidati, 139 ammissibili |
| extended grid | NOT RUN — coarse grid già ammissibile |
| LQR selezionato | PASS — C193, `1/0.5/0.1/0.5`, `rhoU=8` |
| tracking fondamentale | PASS — worst settling 0.776 s |
| comando | PASS diagnostico — 4.6897 N m, 0.3908 di `uScale` |
| precompensatore | PASS — cond 1.1144, residuo 1.39e-17 |
| griglia Kalman | PASS — 27 candidati, 3 ammissibili, KF03 selezionato |
| stimatore | PASS — ratio 1.6928, H2 finita |
| principio di separazione | PASS — errore 2.43e-6 |
| controllore | PASS — ordine 14, nessun integratore |
| disturbo costante | PASS — offset quantificato 0.07959/0.16023 rad |
| rumore seeded | PASS — seed 20260826, rilancio identico |
| test M6 | PASS — T1–T26 |
| test top-level | PASS — 92/92, exit code 0 |
| Code Analyzer | PASS — 0 messaggi su 11 file |
| dataset e figure | PASS — un dataset e sette figure M6 |
| M7 | NOT STARTED |

## Storico del gate iniziale M6

La seguente tabella conserva lo stop PARTIAL precedente al retuning autorizzato; non descrive lo stato finale della milestone.

| Verifica | Esito |
| --- | --- |
| cleanup epistemico M5 | PASS — nessun numero modificato |
| modello M3 completo | PASS — 14 stati, 2 ingressi, 4 misure di posizione |
| costo LQR fisico | PASS — (Q=C_{cost}^TC_{cost}), nessun peso diretto sugli stati interni attuatore |
| griglia (\rho_U=[0.5,1,2,4,8]) | PASS — cinque candidati analizzati |
| stabilità nominale | PASS — 5/5 stabilizzanti |
| overshoot / errore statico | PASS — <0.001% / precisione numerica |
| cross-coupling preliminare | PASS diagnostico — circa 16.2% |
| settling ≤0.8 s | **FAIL — 1.222–1.232 s** |
| selezione (\rho_U) | FAIL — nessun candidato ammissibile |
| Kalman, LQG, rumore, separation principle | NOT RUN — arresto richiesto dal gate |
| regressioni M0–M5 | PASS — 66/66, exit code 0 |
| Code Analyzer M6 parziale | PASS — 0 messaggi |
| M7 | NOT STARTED |

## Baseline M5

| Componente | Scelta | Stato epistemico |
| --- | ---: | --- |
| Riferimento nominale | 5° = 0.0872665 rad | scenario di progetto |
| Disturbo nominale | 0.50 N m ai link | scenario di progetto |
| Finestra `omegaB` | 10.8141–13.9133 rad/s | derivata da M2/M3 |
| `omegaB` | 12 rad/s | target selezionato |
| `As`, `Ms` | 0.05, 2.0 | target W1 |
| `uScale` | 12 N m | normalizzazione, non saturazione |
| `omegaU`, `alpha` | 30 rad/s, 6 | target W2 |
| settling / overshoot | ≤0.8 s / ≤10% | verificato sul tracking nominale M6 |
| cross-coupling | ≤25% | preliminare |

`W1(0)=20`, `W1(inf)=0.5`, `W2(0)=0.0833333 (N m)^-1` e `W2(inf)=0.5 (N m)^-1`. Entrambi i pesi sono stabili, propri, SISO di ordine uno e replicati diagonalmente sui due giunti.

## Disturbance path M5

La coppia esterna entra sul lato link tramite il blocco `M(qbar)^-1` nelle sole righe di accelerazione link di `Bd`. La verifica a differenze finite ha errore nullo alla precisione numerica usata. La pianta a 14 stati usa ingressi `[u1,u2,d1,d2]`: `u` conserva il percorso M3 attraverso gli attuatori, mentre `d` entra direttamente nella meccanica e non nelle uscite.

## Quality gate M5

| Requisito | Esito |
| --- | --- |
| governance documentale normalizzata | PASS — 14 voci con `Responsabile: Alessio` |
| storia tecnica precedente invariata | PASS |
| obiettivi di controllo distinti | PASS |
| disturbo fisico di coppia ai link | PASS |
| `Bd` derivata e verificata | PASS — errore FD nullo |
| scenari riferimento/disturbo | PASS — 2/5/8° e 0.25/0.50/1.00 N m |
| banda derivata da M2/M3 | PASS — 12 rad/s nella finestra |
| W1/W2 autonomi e documentati | PASS |
| pesi stabili/propri e asintoti | PASS |
| target temporali e cross-coupling | PASS — definiti, non dichiarati raggiunti |
| nessun controllore o W3 | PASS |
| dataset e tre figure | PASS |
| test M5 | PASS — 14/14 |
| regressioni M0–M4.1 | PASS — 52/52 dentro T13 |
| test top-level `run_all` | PASS — 66/66, exit code 0 |
| Code Analyzer | PASS — 0 messaggi su 8 file |

## Ensemble baseline M4

| Componente | Scelta | Stato |
| --- | --- | --- |
| Parametri meccanici | `k2`, `k1`, `Jm1` | selezionati dallo screening 3/10 |
| Range meccanici | `k1/k2` ±7%, `Jm1` ±9% | assunzioni baseline |
| Attuatori | `wn` ±8%, `zeta` ±7.5%, ritardo ±20% | assunzioni baseline |
| Famiglia | 120 modelli, inclusi 8 corner | seed 20260824 |
| Ritardo della famiglia | esatto `exp(-jw*delay)` | nominale M3 ancora Padé 1 |
| Modello dinamico | input-moltiplicativo | `Ga_nom*(1+WI*Delta)` |
| `WI` | ordine 1, stabile e proprio | safety factor 1.08 |
| Delta attuatori | `Delta_act1`, `Delta_act2` | indipendenti, `ultidyn` 1x1 |
| Pianta | `GuncMeas` 4x2, `GuncQ` 2x2 | compatibili con `lftdata/usample` |

I range sono assunzioni ingegneristiche, non tolleranze misurate o intervalli identificati. Non sono stati adattati in base a risultati di controllo, che non esistono ancora.

## Screening autonomo

Lo screening usa perturbazioni centrali ±1%, ricostruzione completa di equilibrio, Jacobiani e pianta M3 su 501 frequenze fra 0.1 e 300 rad/s. La priorità combina:

- 65% sensibilità dinamica: FRF 30%, poli instabili 25%, modi elastici 25%, sigma dominante 20%;
- 15% plausibilità della variabilità fisica;
- 10% ruolo/numero delle occorrenze;
- 10% interpretabilità futura.

| Rank | Parametro | Dynamic score | Overall priority |
| ---: | --- | ---: | ---: |
| 1 | `k2` | 0.74829 | 0.75889 |
| 2 | `k1` | 0.58074 | 0.64998 |
| 3 | `Jm1` | 0.60392 | 0.59755 |
| 4 | `Jm2` | 0.59813 | 0.59379 |
| 5 | `m2` | 0.32355 | 0.54781 |

Gli altri candidati sono `l1`, `l2`, `m1`, `Bm2`, `Bm1`. `g` resta nota.

## Fit attuatore e copertura

| Metrica | Valore | Criterio |
| --- | ---: | --- |
| Modelli famiglia | 120 | almeno 100 |
| Nominale / singoli / corner / random | 1 / 6 / 8 / 105 | corner obbligatori |
| Intervallo frequenziale | 0.1–1000 rad/s, 801 punti | ritardo esatto |
| Ordine `WI` | 1 | minimo accettabile fra 1–4 |
| Polo / zero | -207.3533 / -1.32753 s⁻¹ | entrambi stabili |
| Guadagno zpk | 2.871319866 | calcolato |
| Worst `|E|/|WI|` | 0.925925926 | <=1+1e-9 |
| Margine minimo | 0.0130725422 | >=-1e-9 |
| Caso critico | `corner-212`, 281.8383 rad/s | 43.2, 0.74, 18 ms |

## Struttura Delta

| Nome | Tipo | Dimensione | Natura | Occorrenze LFT |
| --- | --- | --- | --- | ---: |
| `Delta_act1` | `ultidyn` | 1x1 | complesso dinamico | 1 |
| `Delta_act2` | `ultidyn` | 1x1 | complesso dinamico | 1 |
| `Jm1` | `ureal` | 1x1 | reale statico | 1 |
| `k1` | `ureal` | 1x1 | reale statico | 1 |
| `k2` | `ureal` | 1x1 | reale statico | 1 |

Ogni parametro fisico è creato una volta e riutilizzato nelle sue occorrenze; i due canali dinamici non condividono Delta.

## Cleanup metodologico M4.1

| Verifica | Esito |
| --- | --- |
| Source of truth nominali attuatore | `actuator_params_nominal.m` |
| Copia locale `40/0.8/0.015` | rimossa da `uncertainty_params_m4.m` |
| Input selezione meccanica | obbligatorio e proveniente dallo screening |
| Chiamata senza selezione | errore `M4Uncertainty:MissingSelection` |
| Default silenzioso `k2/k1/Jm1` | rimosso |
| Motivazione rigidezze | envelope moderato per materiale, assemblaggio e tolleranze equivalenti |
| Audit frasi improprie | nessuna occorrenza nei sorgenti/documenti tecnici |
| Test aggiunti | T15–T18, tutti PASS |

Il confronto pre/post cleanup restituisce esattamente gli stessi parametri, percentuali, coefficienti di `WI`, coverage ratio, margine, errori di coerenza nominale e conteggio `usample`.

## Coerenza nominale e campioni

| Verifica | Risultato |
| --- | ---: |
| Errore Frobenius meccanico `A` | 1.230e-12 |
| Errore meccanico `B` | 0 |
| `GuncMeas.NominalValue` vs M3, abs/rel | 4.890e-15 / 1.188e-14 |
| `GuncQ.NominalValue` vs M3, abs/rel | 6.328e-15 / 4.689e-12 |
| Campioni `usample` | 40/40 validi, seed 20260825 |
| Poli instabili per campione | sempre 2, attesi da M2 |
| Massima parte reale osservata | 7.2003–7.2196 s⁻¹ |

## Quality gate M4

| Requisito | Esito |
| --- | --- |
| main remoto con merge M3.1 verificato | PASS — base a1eca7b |
| screening autonomo e multifattore | PASS |
| tre parametri selezionati e motivati | PASS |
| scenari e range meccanici documentati | PASS |
| scenari e range attuatori documentati | PASS |
| nessun range copiato automaticamente | PASS |
| tre `ureal` corretti e consistenza meccanica | PASS |
| famiglia riproducibile con corner | PASS |
| ritardo esatto e mismatch Padé inclusi | PASS |
| `WI` minimo, stabile, proprio e coprente | PASS |
| due Delta dinamici indipendenti | PASS |
| `GuncMeas/GuncQ` costruite | PASS |
| nominale `Gunc` uguale a M3 | PASS |
| struttura `lftdata` documentata | PASS |
| 40 campioni validi | PASS |
| dataset e tre figure generati | PASS |
| 18 test M4/M4.1 e 34 regressioni pregresse | PASS |
| confronto reference-last | PASS — soluzione invariata |
| `run_all.m` exit code 0 | PASS — 52/52 test top-level |
| documentazione e diario | PASS |

## Limiti e problemi aperti

- Nessun range è sostenuto da identificazione sperimentale.
- Lo screening è locale all'equilibrio M2 e alla griglia 0.1–300 rad/s.
- `Jm2` è molto vicino a `Jm1` in priorità e resta il primo parametro escluso.
- La copertura `WI` è verificata sulla famiglia discreta e sulla griglia 0.1–1000 rad/s.
- I campioni M4 verificano la costruzione; non sono il Monte Carlo finale.
- L'instabilità open-loop meccanica resta attesa e non è un FAIL.
- Specifiche, pesi di prestazione, controllori e analisi robusta closed-loop non sono stati iniziati.
