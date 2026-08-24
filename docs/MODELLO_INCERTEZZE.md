# Modello delle incertezze M4

## Scopo e confini

La traccia richiede una pianta incerta con pochi parametri fisici ragionevoli e una descrizione della variabilità degli attuatori. M4 costruisce l'ensemble di progetto prima di conoscere l'esito di qualsiasi sintesi. Non introduce specifiche di prestazione, pesi `W1/W2`, controllori, analisi robusta closed-loop, RAS o Monte Carlo finale.

Il nominale resta quello approvato in M3.1:

- equilibrio `qbar = [pi/2; 0]`;
- modello meccanico a 8 stati;
- due attuatori nominali identici con `wn = 40 rad/s`, `zeta = 0.8`, ritardo `15 ms` e Padé ordine 1;
- pianta completa a 14 stati, ingressi `[u1;u2]`, misure `[q1;q2;theta1;theta2]` e uscita primaria `[q1;q2]`.

`actuator_params_nominal.m` è l'unica source of truth di `wn`, `zeta`, ritardo e ordine Padé. La configurazione M4 legge da questa funzione i nominali usati nelle tabelle e non ne conserva una copia numerica.

Tutte le percentuali M4 sono **assunzioni ingegneristiche di progetto**. Non sono tolleranze misurate, intervalli di confidenza identificati o dati del costruttore.

## Audit metodologico reference-last

Screening, selezione, range, famiglia degli attuatori, fit di `WI`, modello `uss`, test e primo quality gate sono stati completati usando soltanto traccia e modello M3.1. Il riferimento è stato consultato solo dopo il PASS tecnico e dei 14 test M4.

Il confronto successivo ha evidenziato:

| Aspetto | Nostro M4 | Riferimento precedente |
| --- | --- | --- |
| Parametri meccanici | `k2`, `k1`, `Jm1` | `m2`, `k1`, `k2` |
| Range baseline | rigidezze ±7%, `Jm1` ±9% | `m2` ±10%, rigidezze ±5% |
| Famiglia attuatori | 120 modelli | 200 campioni indicati |
| Ordine `WI` | minimo adeguato: 1 | ordine 3 indicato |

Questo confronto documenta soltanto il processo reference-last e non costituisce la motivazione dei valori M4. Range e selezione sono sostenuti esclusivamente da screening, ruolo fisico ed envelope ingegneristici. Non sono stati copiati codice, range, peso, realizzazioni, grafici o dataset.

## Screening di sensibilità

### Candidati e ricostruzione

I dieci candidati sono `m1`, `m2`, `l1`, `l2`, `Jm1`, `Jm2`, `Bm1`, `Bm2`, `k1`, `k2`; `g` è nota. Ogni parametro viene perturbato centralmente di ±1%. Per entrambe le perturbazioni lo script:

1. ricostruisce la struttura dei parametri;
2. ricalcola l'equilibrio alla stessa `qbar`;
3. ricalcola analiticamente `A` e `B` dalle equazioni SEA;
4. ricostruisce la pianta completa con gli attuatori M3 nominali;
5. valuta 501 frequenze logaritmiche da 0.1 a 300 rad/s.

Non vengono riutilizzate le matrici meccaniche nominali quando un parametro cambia.

### Metriche e priorità

Per ciascun candidato si calcolano:

- derivata centrale normalizzata della FRF MIMO verso `q`, con norma di Frobenius;
- sensibilità relativa dei due poli instabili;
- sensibilità relativa delle due coppie elastiche;
- effetto relativo sulla singular value dominante;
- frequenza del massimo effetto FRF;
- residuo del nuovo equilibrio.

Le quattro metriche dinamiche, normalizzate rispetto al massimo fra i candidati, producono

`DynamicScore = 0.30 FRF + 0.25 unstable + 0.25 elastic + 0.20 sigma`.

La priorità finale è

`OverallPriority = 0.65 DynamicScore + 0.15 physical variability + 0.10 occurrence role + 0.10 interpretability`.

I punteggi non dinamici e le relative motivazioni sono dichiarati nello script. L'ordinamento è decrescente per priorità, poi per sensibilità dinamica e infine usa l'ordine fisso dei candidati come tie-break deterministico.

### Risultato

| Rank | Parametro | FRF | Poli instabili | Modi elastici | Sigma dominante | Dynamic | Overall |
| ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | `k2` | 35.327 | 0.003094 | 0.35460 | 18.303 | 0.74829 | 0.75889 |
| 2 | `k1` | 22.278 | 0.000255 | 0.35263 | 13.427 | 0.58074 | 0.64998 |
| 3 | `Jm1` | 22.680 | 0.015041 | 0.36034 | 13.749 | 0.60392 | 0.59755 |
| 4 | `Jm2` | 24.560 | 0.14590 | 0.22503 | 11.530 | 0.59813 | 0.59379 |
| 5 | `m2` | 3.745 | 0.33944 | 0.03201 | 1.789 | 0.32355 | 0.54781 |
| 6 | `l1` | 16.425 | 0.28894 | 0.14501 | 7.802 | 0.53814 | 0.52229 |
| 7 | `l2` | 19.491 | 0.18885 | 0.17334 | 9.676 | 0.53060 | 0.51239 |
| 8 | `m1` | 14.630 | 0.13050 | 0.12824 | 6.981 | 0.38560 | 0.47314 |
| 9 | `Bm2` | 0.661 | 0.04048 | 0.000105 | 0.660 | 0.04271 | 0.27776 |
| 10 | `Bm1` | 0.693 | 0.00417 | 0.000120 | 0.634 | 0.01597 | 0.26038 |

Sono selezionati `k2`, `k1` e `Jm1`. `Jm1` precede di poco `Jm2`: il risultato dipende dalla regola esplicita, non da una scelta manuale nascosta. La selezione resta un insieme ridotto e interpretabile per la futura analisi strutturata. `uncertainty_params_m4` richiede esplicitamente questo vettore in input; una chiamata senza l'esito dello screening produce l'errore controllato `M4Uncertainty:MissingSelection`.

## Parametri considerati certi in M4

`m1`, `m2`, `l1`, `l2`, `Jm2`, `Bm1` e `Bm2` restano nominali. Questo non afferma che siano fisicamente invarianti: significa che non sono inclusi nell'ensemble baseline M4. In particolare:

- `l1/l2` sono assunte misurate e costruite con variabilità piccola rispetto a rigidezze e inerzia riflessa;
- `Bm1/Bm2` sono poco noti ma hanno effetto dinamico molto basso nello screening;
- `m2` influenza maggiormente i poli instabili, ma la sua priorità complessiva è quinta;
- `Jm2` è il primo escluso e costituisce il candidato naturale da riesaminare se emergessero dati fisici nuovi.

## Scenari meccanici e baseline

| Parametro | Nominale | MILD | BASELINE | CONSERVATIVE | Motivazione |
| --- | ---: | ---: | ---: | ---: | --- |
| `k2` | 40 Nm/rad | ±3% | **±7%** | ±12% | envelope moderato per materiale, assemblaggio e tolleranze equivalenti SEA |
| `k1` | 50 Nm/rad | ±3% | **±7%** | ±12% | stessa natura fisica, blocco indipendente |
| `Jm1` | 0.01 kg m² | ±4% | **±9%** | ±15% | inerzia riflessa di motore e trasmissione |

Gli otto corner di ogni scenario danno:

| Scenario | Max variazione FRF relativa | Frequenza | Max variazione poli instabili | Max variazione modi elastici |
| --- | ---: | ---: | ---: | ---: |
| MILD | 2.1237 | 80.700 rad/s | 0.0706% | 2.939% |
| BASELINE | 5.4732 | 83.326 rad/s | 0.1611% | 6.703% |
| CONSERVATIVE | 7.4353 | 86.038 rad/s | 0.2727% | 11.227% |

I grandi rapporti FRF compaiono vicino a risonanze/antirisonanze, dove una metrica relativa può amplificare piccoli spostamenti di frequenza. Non sono una misura di robustezza closed-loop. Il BASELINE è un envelope moderato, non deliberatamente ottimistico e non scelto per favorire un controllore.

## Modello meccanico `ureal`

`build_uncertain_mechanical_plant.m` crea una sola `ureal` per ciascun parametro selezionato e la riusa in tutte le occorrenze fisiche delle equazioni. I tre blocchi sono reali, scalari, statici e indipendenti:

- `k1 = ureal('k1',50,'Percentage',7)`;
- `k2 = ureal('k2',40,'Percentage',7)`;
- `Jm1 = ureal('Jm1',0.01,'Percentage',9)`.

La linearizzazione incerta è ottenuta dal Jacobiano analitico delle nostre equazioni alla configurazione approvata. L'errore nominale di Frobenius è `1.230e-12` su `A` e zero su `B`; gli errori frequenziali massimi del modello meccanico sono `1.751e-14` per le misure e `6.968e-15` verso `q`.

## Famiglia degli attuatori

### Scenari

| Parametro | Nominale | MILD | BASELINE | CONSERVATIVE |
| --- | ---: | ---: | ---: | ---: |
| `wn` | 40 rad/s | ±4% | **±8%** | ±15% |
| `zeta` | 0.8 | ±4% | **±7.5%** | ±12.5% |
| ritardo | 15 ms | ±8% | **±20%** | ±35% |

I valori nominali della tabella provengono da `actuator_params_nominal.m`. Il BASELINE copre `wn = 36.8...43.2 rad/s`, `zeta = 0.74...0.86` e ritardo `12...18 ms`. I range descrivono dispersione della dinamica chiusa dell'attuatore e latenza/jitter, non componenti identificati.

L'effetto massimo moltiplicativo sugli otto corner è 2.0828, 2.1697 e 2.3314 rispettivamente per MILD, BASELINE e CONSERVATIVE. Il massimo maggiore di 2 è plausibile alle alte frequenze per la combinazione di fase del ritardo esatto e nominale Padé non minimum-phase.

### Composizione riproducibile

La famiglia BASELINE contiene 120 modelli:

- 1 nominale con ritardo esatto;
- 6 variazioni singole min/max;
- 8 corner combinati;
- 105 campioni uniformi pseudo-casuali;
- seed `20260824`.

Su 801 punti fra 0.1 e 1000 rad/s si usa direttamente

`Gvar(jw) = wn^2/( (jw)^2 + 2*zeta*wn*(jw) + wn^2 ) * exp(-jw*delay)`.

Il nominale del progetto rimane razionale e usa Padé ordine 1. La famiglia FRD permette al fit di includere dispersione di `wn`, `zeta`, ritardo e mismatch ritardo esatto/Padé senza aumentare l'ordine del Padé.

## Errore moltiplicativo e peso `WI`

La convenzione è input-moltiplicativa:

`Ga,var = Ga,nom * (1 + WI * Delta)`, con `||Delta||inf <= 1`.

Per ciascun modello si calcola `Ei = Ga,var/Ga,nom - 1`. `ucover` prova ordini 1, 2, 3 e 4 in quest'ordine. Ogni candidato viene moltiplicato per un margine di sicurezza 1.08 e verificato direttamente sulla griglia completa. Tutti i quattro ordini coprono la famiglia; viene quindi scelto il minimo, ordine 1:

`WI(s) = 2.87131986636 * (s + 1.32752948673)/(s + 207.353298568)`.

Il peso è stabile, proprio e privo di cancellazioni patologiche. Le metriche della copertura sono:

| Metrica | Valore |
| --- | ---: |
| Ordine selezionato | 1 |
| Safety factor | 1.08 |
| Worst `|E|/|WI|` | 0.925925925926 |
| Minimum coverage margin | 0.0130725422 |
| Campione critico | `corner-212`: 43.2 rad/s, 0.74, 18 ms |
| Frequenza critica | 281.838293 rad/s |
| Tolleranza numerica | `1e-9` |

## Due incertezze dinamiche indipendenti

I due canali sono uguali soltanto nel nominale. M4 usa:

- `Delta_act1 = ultidyn(...,'Bound',1)`;
- `Delta_act2 = ultidyn(...,'Bound',1)`.

Un solo blocco condiviso imporrebbe variazioni perfettamente correlate senza evidenza fisica. I blocchi distinti permettono dispersioni indipendenti e conservano una struttura adatta alle future `lftdata`, `robuststab`, `robgain`, `mussv` e `musyn`.

## Pianta incerta completa e struttura Delta

La cascata degli attuatori incerti con la meccanica incerta produce:

- `GuncMeas`: 4 uscite `[q1;q2;theta1;theta2]`, 2 ingressi `[u1;u2]`;
- `GuncQ`: 2 uscite `[q1;q2]`, 2 ingressi `[u1;u2]`.

`lftdata(GuncMeas)` restituisce:

| Nome | Dimensione | Tipo | Reale/complesso | Statico/dinamico | Occorrenze |
| --- | --- | --- | --- | --- | ---: |
| `Delta_act1` | 1x1 | `ultidyn` | complesso | dinamico | 1 |
| `Delta_act2` | 1x1 | `ultidyn` | complesso | dinamico | 1 |
| `Jm1` | 1x1 | `ureal` | reale | statico | 1 |
| `k1` | 1x1 | `ureal` | reale | statico | 1 |
| `k2` | 1x1 | `ureal` | reale | statico | 1 |

Il numero di occorrenze è quello della rappresentazione LFT compressa: ogni parametro fisico è un solo blocco ripetuto internamente, non Delta artificialmente duplicati.

## Coerenza nominale

Su 801 frequenze fra 0.1 e 1000 rad/s:

| Confronto | Errore assoluto max | Errore relativo max |
| --- | ---: | ---: |
| Meccanica, misure | `1.751e-14` | `3.356e-14` |
| Meccanica, `q` | `6.968e-15` | `6.987e-12` |
| `GuncMeas.NominalValue` vs M3 | `4.890e-15` | `1.188e-14` |
| `GuncQ.NominalValue` vs M3 | `6.328e-15` | `4.689e-12` |

Tutti i valori sono ampiamente sotto la tolleranza `1e-8`; il nominale M3 non è stato alterato.

## Validazione `usample`

Con seed `20260825` sono state campionate 40 piante. Per tutte sono stati verificati dimensioni 4x2, risposta finita su 301 frequenze, parametri meccanici entro i range, campi della struttura presenti e poli finiti/classificabili. Esito: 40/40 PASS.

Ogni campione presenta due poli open-loop instabili, con massima parte reale fra 7.2003 e 7.2196 rad/s. Questo è coerente con M2/M3 e non è un fallimento: la campagna è una validazione di costruzione M4, non il Monte Carlo finale.

## Artifact e rigenerazione

- `results/data/m4_uncertain_plant.mat` contiene tabelle, scenari, metadata della famiglia, `WI`, struttura Delta, `GuncMeas`, `GuncQ` e metriche;
- `results/figures/m4_parameter_sensitivity.png`;
- `results/figures/m4_actuator_uncertainty_cover.png`;
- `results/figures/m4_uncertain_plant_samples.png`;
- `tests/test_m4_uncertainty_model.m` contiene 18 quality gate, inclusi source of truth, dipendenza dallo screening e preservazione delle decisioni;
- `run_all.m` rigenera e valida l'intera catena M0–M4.

## Limiti

- Nessun range deriva da misure sperimentali; nuovi dati fisici richiederebbero una decisione separata.
- Lo screening è locale al punto di equilibrio M2 e alla finestra 0.1–300 rad/s.
- I punteggi di plausibilità/interpretabilità sono criteri ingegneristici dichiarati, non quantità identificate.
- L'insieme non include correlazioni fra parametri.
- `WI` è una copertura discreta della famiglia definita sulla griglia, non una prova su ogni possibile tripla continua.
- La validazione `usample` non sostituisce né una futura mu-analysis né il Monte Carlo finale.
- Prestazioni e fattibilità dei controllori non sono state usate per restringere o ampliare l'ensemble.
