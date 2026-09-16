# Validazione non lineare dei controllori H∞ e D–K

## Configurazione corrente — 16 settembre 2026

M15 è stata rigenerata dopo la selezione definitiva dei pesi M5. Khinf
ha ordine 18 e Kmu ordine 70; il nuovo Kmu fallisce RS in M14.
Le matrici restano congelate durante M15. Software PASS, tracking FAIL,
stato PARTIAL; nessuna saturazione introdotta.

| Metrica corrente | Khinf | Kmu |
| --- | ---: | ---: |
| Ts [s] | 1.482747 | Inf (non assestato entro 4 s) |
| Overshoot [%] | 228.44698 | 182.07275 |
| Errore statico relativo | 0.8150955 | 0.9324754 |
| Peak delta u [N m] | 9.59350 | 8.79533 |
| Raggio minimo RAS empirica [gradi] | 44.895 | 60 (limitato dal box) |
| Raggio minimo accordo LTI/NL [gradi] | 4.5 | 5 |

Il tetto storico di 400 simulazioni ha interrotto il primo tentativo RAS.
Il budget è ora 626, derivato dalla griglia e dalla bisezione già esistenti,
senza cambiare criteri, risoluzione o orizzonti; eseguite 501/90 simulazioni
per Khinf/Kmu. Il checkpoint verifica l'identità delle sorgenti.
Fonte corrente: `m15_nonlinear_robust_validation.mat` e
`RESOCONTO_REVISIONE_PESI_HINF_LQR_LQRI.txt`.

## Archivio della precedente configurazione (numeri non correnti)

**Responsabile:** Alessio  
**Milestone:** M15  
**Stato:** `PARTIAL` — software e simulazioni `PASS`, tracking M5 `FAIL`

## Obiettivo e perimetro congelato

M15 valida sul modello non lineare nominale due controllori già congelati:

| Controller | Source artifact | Dimensione | Ordine | Stato formale precedente |
| --- | --- | ---: | ---: | --- |
| Khinf | `results/data/m10_hinfsyn_nominal.mat` | 2×2 | 18 | stabilità nominale PASS; nessuna RS M10 disponibile |
| Kmu | `results/data/m13_musyn_dk.mat` | 2×2 | 52 | M14 RS `PASS_CERTIFIED` sul modello lineare incerto M4 |

Le matrici A/B/C/D sono caricate direttamente dagli artifact, ne sono
registrati dimensioni, norme e checksum numerici, e Kmu coincide con
`rawInfo(3).K`. Non sono state eseguite nuove sintesi, riduzioni d'ordine,
retuning, prefiltri, integratori, saturazioni, Monte Carlo o campionamenti M4.

## Modello Simulink e coordinate

Il modello dedicato `simulink/SEA_ROBUST_nonlinear.slx` non modifica
`SEA_LQG_nonlinear.slx`. La parte fisica riusa:

- le equazioni non lineari M1 tramite `m8_nonlinear_sea_sfun`;
- gli attuatori M3, secondo ordine più Padé, con sei stati;
- `xbar`, `taubar` e gli stati attuatore di equilibrio M3;
- il disturbo fisico di coppia sul lato link.

La pianta integra 8 stati meccanici e 6 attuativi. Il controllore aggiunge
18 o 52 stati. Il feedback usa soltanto le posizioni dei link:

\[
q_\delta=q_{abs}-\bar q,\quad y=q_\delta+v_q,\quad
e=r_\delta-y,\quad u_\delta=K e,\quad u_{abs}=\bar\tau+u_\delta.
\]

Non sono usati encoder motore, stimatore Kalman, feedforward o 2-DoF. Tutti
gli ingressi e gli stati iniziali passano mediante `Simulink.SimulationInput`;
`Simulink.findVars` non trova dipendenze dal base workspace.

## Solver e logging

La configurazione coincide con M8: `ode23t`, `RelTol=1e-5`, `AbsTol=1e-7`,
`MaxStep=0.005 s` e griglia di ingresso `0.002 s`. Sono registrati tempo,
stati meccanici, attuatori, stati del controllore, comando incrementale e
assoluto, coppie attuatore, riferimento, disturbo, rumore, errore e misura.

`uScale=12 N m` è usata soltanto come normalizzazione prestazionale. Nel
modello non esiste clipping o saturazione.

## Equilibrio

Con stato fisico e attuatori all'equilibrio, stato del controllore nullo e
`r=d=v=0`, entrambi i run di 4 s sono finiti e limitati:

| Controller | max q drift [rad] | max theta drift [rad] | max delta u [N m] | max norma xK |
| --- | ---: | ---: | ---: | ---: |
| Khinf | `2.2550e-16` | `1.7972e-16` | `3.4446e-15` | `3.2062e-15` |
| Kmu | `1.6340e-16` | `1.2190e-16` | `2.8342e-15` | `3.2623e-15` |

Le tolleranze M8 `1e-8` sono rispettate: entrambi i gate sono `PASS`.

## Tracking non lineare

Sono stati eseguiti 2°, 5° e 8° su ciascun giunto, senza rumore, disturbo,
prefiltro o estensione dell'orizzonte di 4 s.

| Worst case | Khinf | Kmu | Target M5 |
| --- | ---: | ---: | ---: |
| settling [s] | 1.7322 | 1.7346 | ≤0.8 |
| overshoot [%] | 261.347 | 228.364 | ≤10 |
| errore statico relativo [%] | 49.0679 | 50.4416 | ≤5 |
| cross-coupling [%] | 25.913 | 23.944 | ≤25, diagnostico |
| peak delta u [N m] | 8.2558 | 8.2599 | quantificato |
| peak deformazione SEA [rad] | 0.18134 | 0.18154 | quantificato |
| peak coppia elastica [N m] | 9.0671 | 9.0769 | quantificato |

Entrambi falliscono il tracking M5. Khinf fallisce anche il limite
diagnostico di cross-coupling; Kmu lo rispetta. Il risultato negativo è
coerente con M10/M13 e non ha attivato modifiche dei controllori o dei pesi.

## Accordo LTI/non lineare nel tracking

Ogni controller è confrontato con le proprie mappe congelate `T` e `KS`.

| Worst discrepancy | Khinf | Kmu |
| --- | ---: | ---: |
| max q [rad] | 0.038773 | 0.024631 |
| RMS q [rad] | 0.008260 | 0.006028 |
| max u [N m] | 0.48698 | 0.84678 |
| RMS u [N m] | 0.06718 | 0.08446 |

## Disturbi lato link

I sei scenari per controller applicano 0.25, 0.50 e 1.00 N m separatamente
ai due link per 8 s. Non è introdotta una nuova soglia: l'esito è
`QUANTIFIED`.

| Worst case | Khinf | Kmu |
| --- | ---: | ---: |
| peak q [rad] | 0.86163 | 0.84182 |
| offset [rad] | 0.19868 | 0.24657 |
| peak delta u [N m] | 3.3466 | 3.0672 |
| max scarto q LTI/NL [rad] | 0.14209 | 0.08718 |
| RMS scarto q [rad] | 0.02489 | 0.01671 |
| max scarto u [N m] | 0.71457 | 0.46659 |

La risposta LTI del disturbo usa una realizzazione interna con un unico
stato fisico condiviso fra G e Gd. Essa è equivalente a `S*Gd` e
`-KS*Gd`, ma evita di duplicare i modi instabili della pianta e affidarne la
cancellazione alla precisione numerica.

## Rumore

Con seed `20260826` è stata rigenerata la matrice M8 a quattro canali; i
primi due canali identici sono applicati a Khinf e Kmu. Sul riferimento 5°
al giunto 1:

| Metrica | Khinf | Kmu |
| --- | ---: | ---: |
| RMS tracking [rad] | 0.048495 | 0.049029 |
| RMS variazione comando [N m] | 0.015040 | 0.015866 |
| RMS variazione q [rad] | `2.9114e-4` | `2.7338e-4` |
| repeat error | 0 | 0 |

Non è calcolato un errore di stima. Il confronto con M6 richiede cautela:
M6 usa quattro encoder rumorosi, mentre i robusti usano soltanto q1/q2.

## RAS empirica

La sezione impone perturbazioni iniziali q1/q2, velocità nulle, theta
traslata insieme a q, attuatori all'equilibrio e stato controller nullo.
Griglia, 36 direzioni, box ±60°, tolleranza radiale 1°, orizzonti 8/12 s,
criterio di coda e bound numerico coincidono con M8.

| Controller | Sim. | Conv./div. | r min/max [deg] | area [deg²] | Classificazione |
| --- | ---: | ---: | ---: | ---: | --- |
| M6 frozen M8 | 57 | 57/0 | 60 / 78.324 | 14213.6 | SEARCH-BOX LIMITED |
| Khinf | 282 | 101/42 | 52.876 / 78.324 | 12721 | EMPIRICAL BOUNDARY LOCATED |
| Kmu | 107 | 57/0 | 60 / 78.324 | 14213.6 | SEARCH-BOX LIMITED |

Khinf localizza la direzione critica a 250°. Kmu e M6 raggiungono il box in
tutte le direzioni: non se ne deduce una regione più grande del dominio
esplorato. Queste sono sezioni empiriche, non regioni di attrazione
certificate e non includono incertezze M4.

## EMPIRICAL LTI/NL AGREEMENT REGION

Su 36 direzioni di riferimento si cerca fino a 8° il massimo raggio con
scarto q massimo ≤0.5°, tolleranza radiale 0.25° e orizzonte 4 s.

| Controller | Sim. | r min/max [deg] | area [deg²] | direzioni a 8° | critica |
| --- | ---: | ---: | ---: | ---: | ---: |
| Khinf | 206 | 4.00 / 8.00 | 99.522 | 2 | 100° |
| Kmu | 216 | 4.75 / 7.75 | 111.721 | 0 | 100° |

Questa regione diagnostica non è una RAS, una regione robusta o una regione
certificata.

## Interpretazione e quality gate

Kmu è robustamente stabile rispetto all'insieme **lineare** M4 secondo M14
e mostra, separatamente, il comportamento sopra descritto sul modello non
lineare nominale. M15 non dimostra stabilità robusta non lineare.

Frozen controllers, plant M1/M3, solver, equilibrio, simulazioni richieste e
software sono `PASS`. Disturbi, rumore, comando, confronti LTI/NL, RAS e
agreement regions sono quantificati. Tracking Khinf/Kmu è `FAIL`; pertanto
M15 è correttamente `PARTIAL`.

## Artifact

- `results/data/m15_nonlinear_robust_validation.mat`;
- `simulink/SEA_ROBUST_nonlinear.slx`;
- otto figure `results/figures/m15_*.png`;
- suite `tests/test_m15_nonlinear_robust.m`, T01–T60.
