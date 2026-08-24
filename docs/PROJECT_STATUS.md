# Project Status

**Current milestone:** M7 — LQG nominale con azione integrale
**Status:** PARTIAL — griglia LQI completa, nessun candidato soddisfa il tracking M5
**Last validated milestone:** M6
**Last validated result:** `run_all.m` exit 0, 107/107 test PASS; M7 checkpoint con 28/28 candidati stabili e offset DC entro `1e-4 rad`, 0/28 entro il settling M5, minimo 1.964 s
**Blocking issues:** la griglia integrale prescritta non raggiunge il target di settling 0.8 s senza `Nr`; revisione del gruppo richiesta
**Next task:** decidere esplicitamente il retuning M7; non modificare M5 e non iniziare M8
**Pull Request:** [#10 — M7: evaluate integral LQG grid checkpoint](https://github.com/Deda-404/Progetto_CR/pull/10), aperta, non draft e non unita
**Last update:** 2026-08-24 23:50 CEST

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
