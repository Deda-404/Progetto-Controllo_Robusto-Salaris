# Report finale del refactoring strutturale e didattico

> **Snapshot storico (2026-09-01).** Questo documento descrive il refactoring
> precedente sul ramo `codex/didactic-structural-refactor`. Per lo stato
> corrente, i risultati aggiornati e la pubblicazione GitHub usare
> `RESOCONTO_REVISIONE_LQR_LQG_HINF_RAS.md`.

Data della revisione: 2026-09-01

Ramo di lavoro: `codex/didactic-structural-refactor`

## A. File modificati

La revisione modifica 196 file già tracciati. Il numero comprende sorgenti, test, documentazione, modelli Simulink e artifact rigenerati; le immagini e i file MAT non sono stati ritoccati manualmente, ma prodotti dalle rispettive validazioni.

I 35 sorgenti MATLAB modificati più rilevanti sono:

- `run_all.m`;
- `src/parameters/{uncertainty_params_m4,performance_specs_m5,lqg_specs_m6,lqg_specs_m7,monte_carlo_specs_m16}.m`;
- `src/performance/build_m5_weights.m`;
- `src/uncertainty/build_uncertain_mechanical_plant.m`;
- i validator M3–M7, M12, M14, M16 e M18;
- i builder M4 e M18 e il loader della generalized plant M13;
- i test M3–M8 e M13/M14/M16/M17/M18.

Sono stati inoltre aggiornati README, roadmap, checklist, registri di progetto, documenti tecnici M3–M18, relazione LaTeX, presentazione, tabelle, macro e manifest generati. La relazione e la presentazione compilate fanno parte degli output aggiornati.

## B. File eliminati

Sono stati eliminati 20 file obsoleti, tutti recuperabili dalla storia Git.

Moduli di screening, griglia, ranking o selezione rimossi (11):

- `analysis/nominal/diagnose_m6_baseline_cost.m`;
- `analysis/nominal/select_m5_performance_specs.m`;
- `analysis/nominal/select_nominal_actuator.m`;
- `analysis/nominal/validate_m7_augmented_cost_feasibility.m`;
- `analysis/uncertainty/evaluate_uncertainty_scenarios.m`;
- `analysis/uncertainty/screen_parameter_sensitivity.m`;
- `controllers/lqg/retune_lqi_augmented_cost_m7.m`;
- `controllers/lqg/select_kalman_filter.m`;
- `controllers/lqg/select_lqi_integral.m`;
- `controllers/lqg/select_lqr_no_integrator.m`;
- `controllers/lqg/tune_lqr_cost_m6.m`.

Artifact collegati alla vecchia infrastruttura rimossi (9):

- `results/data/m7_lqi_2dof_feasibility.mat`;
- `results/data/m7_lqi_grid_partial.mat`;
- `results/figures/m4_parameter_sensitivity.png`;
- `results/figures/m6_lqr_candidate_comparison.png`;
- `results/figures/m6_lqr_cost_tuning.png`;
- `results/figures/m6_lqr_delta_weight_effect.png`;
- `results/figures/m7_augmented_cost_pareto.png`;
- `results/figures/m7_lqi_candidate_comparison.png`;
- `results/figures/m7_lqi_feedforward_effect.png`.

## C. File creati

Sono stati creati:

- `analysis/modellazione_linearizzazione_controllo.m`, percorso didattico sequenziale M0–M5;
- `controllers/lqg/design_lqr_m6.m`, progetto LQR diretto;
- `controllers/lqg/design_kalman_m6.m`, progetto Kalman diretto;
- `results/data/m7_lqg_integral.mat`, risultato delle tre verifiche manuali M7;
- `results/figures/m6_lqr_physical_normalization.png`, figura della normalizzazione fisica M6;
- `docs/REFACTORING_DIDATTICO_FINALE.md`, questo report A–P;
- `docs/STATUS_REFACTORING_DIDATTICO.txt`, resoconto breve trasferibile a un'altra chat.

## D. Nuova struttura M0–M5

M0–M5 costituiscono ora la macrofase «Modellazione, linearizzazione e definizione del problema di controllo». Lo script principale è suddiviso in sezioni `%%` e segue:

1. parametri nominali;
2. modello dinamico non lineare SEA;
3. equilibrio;
4. linearizzazione;
5. poli, modi e proprietà strutturali;
6. attuatore nominale;
7. insieme incerto unico;
8. specifiche di prestazione;
9. pesi W1 e W2.

Le funzioni fisiche, la linearizzazione, i costruttori dell'attuatore e dei pesi restano separati e riutilizzabili. I validator rimangono come quality gate numerici, non come motori di selezione.

## E. Nuova definizione delle incertezze

`uncertainty_params_m4.m` non accetta più scenari e non espone più varianti mild/baseline/conservative. Esiste un solo insieme di intervalli di progetto. Le grandezze meccaniche sono costruite con `ureal(...,'Percentage',...)`; la famiglia dinamica degli attuatori è coperta dal peso moltiplicativo WI di ordine 1, verificato sui corner, sulle variazioni singole e su campioni casuali.

Le percentuali sono engineering uncertainty assumptions, non tolleranze sperimentali né distribuzioni probabilistiche. `usample` continua a essere utilizzabile sul modello incerto risultante.

## F. Tabella finale delle incertezze `ureal`

| Parametro | Nominale | Variazione | Range | Rappresentazione |
| --- | ---: | ---: | ---: | --- |
| k1 | 50 N m/rad | ±10% | [45, 55] | `ureal` reale |
| k2 | 40 N m/rad | ±10% | [36, 44] | `ureal` reale |
| Jm1 | 0.01 kg m² | ±10% | [0.009, 0.011] | `ureal` reale |
| wn | 40 rad/s | ±10% | [36, 44] | famiglia attuatore coperta da WIΔ |
| zeta | 0.8 | ±10% | [0.72, 0.88] | famiglia attuatore coperta da WIΔ |
| delay | 0.015 s | ±20% | [0.012, 0.018] | famiglia attuatore coperta da WIΔ |

M4 verifica 40/40 campioni `usample` con seed `20260825`. La famiglia dell'attuatore contiene 120 modelli e il worst ratio `|E|/|WI|` è 0.925926, quindi la copertura numerica è rispettata sulla campagna dichiarata.

## G. Motivazione finale di wn, zeta e delay

La scelta nominale resta `wn=40 rad/s`, `zeta=0.8`, `delay=0.015 s`, Padé ordine 1.

- `wn=40 rad/s` colloca la banda misurata dell'attuatore a 34.7834 rad/s, dentro la finestra 28.8377–41.9726 rad/s ottenuta dai poli instabili, dai modi elastici e dalla separazione di banda desiderata.
- `zeta=0.8` produce una risposta sufficientemente smorzata: overshoot 1.472% e settling 0.109 s.
- `delay=15 ms` introduce una perdita di fase significativa ma gestibile: l'errore della Padé è circa 4.76° a 70 rad/s e 6.83° a 80 rad/s.
- Padé ordine 1 mantiene un modello razionale compatto e rende esplicito lo zero RHP a 133.33 rad/s, senza introdurre un ordine ingiustificato.

La scelta è verificata confrontando manualmente un caso lento, quello nominale e uno veloce; non deriva più da 27 combinazioni con ranking multicriterio.

## H. Specifiche finali adottate

| Grandezza | Valore | Significato |
| --- | ---: | --- |
| omegaB | 12 rad/s | banda di progetto |
| As | 0.05 | errore/sensibilità ammessa a bassa frequenza |
| Ms | 2 | massimo picco di sensibilità desiderato |
| uScale | 12 N m | scala prestazionale del comando, non saturazione hardware |
| omegaU | 30 rad/s | inizio della penalizzazione crescente del comando |
| alpha | 6 | rapporto tra penalizzazione alta e bassa frequenza |
| settling time | ≤ 0.8 s | target temporale |
| overshoot | ≤ 10% | target temporale |
| errore a regime | ≤ 5% | target di tracking |
| cross-coupling | picco ≤ 25% | target MIMO preliminare |

`omegaB=12 rad/s` è interno alla finestra calcolata 10.814–13.913 rad/s. I valori sono scelte semplici e congelate, verificate direttamente senza costruire combinazioni candidate.

## I. Formule e motivazione di W1 e W2

Il peso sulla sensibilità è

`W1(s) = (s/Ms + omegaB) / (s + omegaB As)`.

Ne segue `W1(0)=1/As=20` e `W1(∞)=1/Ms=0.5`. La condizione `||W1 S||∞ < 1` richiede quindi sensibilità piccola a bassa frequenza, effettua la transizione intorno a `omegaB` e ammette alle alte frequenze un picco approssimativamente legato a `Ms`.

Il peso sul comando è

`W2(s) = (1/uScale) (s/omegaU + 1) / (s/(alpha omegaU) + 1)`.

Ne segue `W2(0)=1/uScale=1/12` e `W2(∞)=alpha/uScale=0.5`. A bassa frequenza il comando è normalizzato rispetto a 12 N m; intorno a 30 rad/s la penalizzazione cresce per scoraggiare comandi rapidi vicini alla banda attuativa e ai modi elastici. `alpha=6` determina l'aumento asintotico. Entrambi i pesi sono stabili, propri, del primo ordine e replicati diagonalmente sui due giunti.

## J. Nuovo metodo di scelta Q/R LQR

Il costo resta `J = integral(x'Qx + u'Ru) dt`, ma Q e R non sono più cercati su griglie. Gli stati sono normalizzati con scale fisiche legate ad ampiezza di riferimento, banda e deformazione SEA, secondo una logica di Bryson. Su tale normalizzazione sono applicati coefficienti semplici:

- peso posizione `wq=1`;
- peso velocità `0.5`;
- peso deformazione elastica `0.1`;
- peso velocità motore `0.5`;
- penalizzazione del comando `rhoU=8`.

`design_lqr_m6.m` costruisce direttamente Q/R e risolve la CARE. Il risultato congelato mantiene worst settling 0.776 s e picco di comando pari a 0.3908 della scala M5. Non sono rimasti campi o tolleranze legati a ranking.

## K. Nuovo metodo di scelta delle covarianze Kalman

`design_kalman_m6.m` costruisce un unico modello di rumore con deviazioni standard:

- disturbo di coppia ai link `sigmaD=0.1 N m`;
- incertezza/disturbo sul canale di ingresso `sigmaU=0.1 N m`;
- rumore di misura `sigmaY=0.05°`.

Le covarianze sono ottenute dai quadrati delle deviazioni standard e alimentano direttamente il progetto dello stimatore. Un Qn maggiore rispetto a Rn rende l'osservatore più rapido; un Rn maggiore lo rende più prudente. Il rapporto di velocità stimatore/regolatore risultante è 1.693 e il separation principle è verificato. Non esiste più un selettore di candidati Kalman.

## L. Numero di grid search/ranking eliminati

Sono stati eliminati 11 moduli software dedicati a screening, scenari, griglie, retuning, ranking o selezione automatica e 9 artifact derivati. Sono scomparsi tutti i ranking automatici M3–M7.

Il minimo numerico documentabile comprende 27 combinazioni dell'attuatore M3 e 240 configurazioni LQR M6, cioè almeno 267 candidati automatici rimossi, oltre alle combinazioni M5 e alle campagne M7. Restano soltanto tre confronti manuali M3 e tre verifiche manuali M7, senza score globale né selezione automatica.

## M. Test eseguiti

- suite MATLAB completa: 590 test, 590 PASS, 0 failed, 0 incomplete;
- `run_all` M0–M18: PASS, exit code 0;
- M18: tracciabilità, relazione e presentazione PASS;
- Code Analyzer: 38 file MATLAB modificati/creati, 0 messaggi;
- `git diff --check`: PASS;
- ricerca di terminologia e campi obsoleti nel tree operativo: 0 occorrenze;
- audit LaTeX della relazione e della presentazione: 0 errori, riferimenti irrisolti, overfull box e destinazioni duplicate;
- ispezione visiva: 41 pagine della relazione e 17 slide, PASS.

La pipeline ha ricaricato M13 dall'artifact congelato senza aprire una nuova D–K synthesis. M16 è stata riprodotta con lo stesso seed e gli stessi 40 campioni comuni.

## N. Eventuali test falliti

Nel gate conclusivo non risultano test falliti o incompleti. Durante il refactoring una prima esecuzione completa aveva evidenziato 9 regressioni documentali/storiche; tutte sono state corrette e i test mirati successivi hanno raggiunto 279/279 PASS prima del gate finale 590/590.

Gli stati `PARTIAL` di M7, M9–M12, M14 e M15 non sono fallimenti software: rappresentano requisiti prestazionali non soddisfatti e sono conservati intenzionalmente. In particolare Kmu passa RS ma fallisce NP/RP, e M6 è instabile nel Sample 5 M16.

## O. Modifiche effettuate alla relazione

La relazione finale è stata ampliata e riallineata alla nuova narrativa didattica. Gli interventi principali riguardano:

- macrofase M0–M5 e passaggio esplicito da modello fisico a problema di controllo;
- significato e verifica di `wn`, `zeta`, ritardo e Padé;
- singolo insieme incerto M4, tabella dei range e distinzione fra assunzioni ingegneristiche e dati sperimentali;
- origine delle specifiche M5 e derivazione degli asintoti W1/W2;
- scelta Q/R con normalizzazione fisica, covarianze Kalman e separation principle;
- M7 presentato come studio manuale con risultato negativo, non come tuning incompleto da riaprire;
- conservazione della generalized plant, H∞, μ-analysis e D–K synthesis;
- distinzione epistemica fra campagna storica M13, certificazione corrente M14 e Monte Carlo empirica M16;
- confronto finale per ruoli, senza score globale.

La relazione compilata è di 41 pagine; la presentazione è di 17 slide. Entrambe hanno audit LaTeX e visivo PASS.

## P. Parti consapevolmente non semplificate

Non sono stati semplificati o rimossi gli elementi che costituiscono il nucleo del progetto di Controllo Robusto:

- modello uncertain e blocchi `ureal`;
- campionamento `usample`;
- peso dinamico dell'incertezza attuativa;
- mixed sensitivity e generalized plant;
- sintesi H∞ e confronto strutturato;
- μ-analysis NS/NP/RS/RP;
- artifact D–K/Kmu e verifica indipendente M14;
- validazioni non lineari, RAS e Monte Carlo M16;
- distinzione fra evidenza empirica e certificazione robusta.

Questi elementi hanno valore matematico e didattico sostanziale. La semplificazione ha riguardato il processo di scelta dei parametri e la sovrastruttura software, non la fisica corretta, i controllori congelati o la profondità dell'analisi robusta.

## Stato finale

Il refactoring è concluso e riproducibile. Il repository privilegia ora comprensibilità, motivazione fisica e poche scelte verificabili, mantenendo visibili sia i risultati positivi sia quelli negativi. Prima della consegna restano soltanto l'inserimento manuale delle matricole e della data.
