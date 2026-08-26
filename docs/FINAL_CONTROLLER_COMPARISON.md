# M17 — Confronto finale dei controllori

**Responsabile:** Alessio

**Baseline:** `392ad170dc6665c87b769e314edb8380a4b1c8bc`

**Stato:** `COMPLETE`

## Scopo e perimetro

M17 raccoglie le evidenze congelate M6–M16 e assegna ai tre controllori
primari un ruolo finale per la relazione. È un'analisi degli artifact: non
esegue sintesi, tuning, Monte Carlo, simulazioni dinamiche, Simulink,
riduzione d'ordine, prefilter o nuove architetture 2-DoF. M4, M5 e i
controllori restano invariati.

La decisione è gerarchica e per ruolo. Non esiste uno score globale e non
viene dichiarato un vincitore assoluto: nessuno dei tre controllori domina
simultaneamente tracking, robustezza formale e complessità.

## Fonti congelate

| Evidenza | Artifact | Uso M17 |
| --- | --- | --- |
| M5 | `results/data/m5_performance_specs.mat` | target e `uScale` |
| M6 | `results/data/m6_lqg_no_integrator.mat` | `Klqg`, nominale lineare |
| M8 | `results/data/m8_lqg_nonlinear_ras.mat` | M6 nominale non lineare, rumore e RAS |
| M10 | `results/data/m10_hinfsyn_nominal.mat` | `Khinf`, nominale lineare |
| M12 | `results/data/m12_mu_analysis_a5.mat` | A5 storico, non candidato M17 |
| M13 | `results/data/m13_musyn_dk.mat` | `Kmu`, nominale lineare |
| M14 | `results/data/m14_final_mu_analysis_kmu.mat` | certificazione formale Kmu |
| M15 | `results/data/m15_nonlinear_robust_validation.mat` | Khinf/Kmu nominali non lineari e RAS |
| M16 | `results/data/m16_monte_carlo_uncertain_linear.mat` | campagna lineare incerta comune |

L'identità delle matrici di stato dei tre controllori è verificata fra le
milestone che li riutilizzano. Gli ordini ottenuti dagli artifact sono
14/18/52 e coincidono con quelli attesi.

## Classi di evidenza

Le quattro classi epistemiche restano separate:

1. **Nominal linear:** risultati LTI delle milestone di sintesi M6, M10 e
   M13.
2. **Nominal nonlinear:** M8 per M6 e M15 per Khinf/Kmu.
3. **Uncertain linear Monte Carlo:** M16, seed `20260826`, 40 campioni M4
   comuni.
4. **Formal robustness:** μ-analysis, `robstab` e `robgain` M12/M14.

I valori non vengono mediati fra classi. La Monte Carlo M16 è evidenza
empirica e non sostituisce la certificazione μ M14. Le RAS M8/M15 sono
stime empiriche sul modello non lineare nominale e non certificazioni
analitiche.

## Audit dei controllori

| Controller | Tipo | Ordine | Ingressi | Uscite | Misure/segnali | Identità |
| --- | --- | ---: | ---: | ---: | --- | --- |
| M6 `Klqg` | LQG senza integratore | 14 | 6 | 2 | `r1,r2,q1,q2,theta1,theta2` | PASS M6/M8/M16 |
| M10 `Khinf` | H∞ full-order | 18 | 2 | 2 | `e1,e2 = r-q` | PASS M10/M15/M16 |
| M13 `Kmu` | D–K / μ-synthesis | 52 | 2 | 2 | `e1,e2 = r-q` | PASS M13/M14/M15/M16 |

M12 analizza A5 M11, ordine 6. A5 è mantenuto come evidenza storica della
catena robusta ma non è un candidato primario M17 e i suoi risultati non
sono attribuiti a `Khinf` M10.

## Evidenza nominale lineare

| Controller | Stabilità interna | max Re polo | Worst Ts [s] | Worst OS [%] | Worst errore rel. | Worst cross | Norma pesata | Esito pesato |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| M6 | PASS | -5.5051 | 0.776 | 0.26545 | 1.6221e-14 | 0.17391 | N/A | N/A |
| Khinf | PASS | -0.68383 | 1.566 | 261.62 | 0.49068 | 0.25960 | 10.2071034 | FAIL |
| Kmu | PASS | -0.73199 | N/A nell'artifact M13 | N/A | N/A | N/A | 10.3917315 | FAIL |

La voce N/A per il tracking temporale Kmu non è interpolata da altre classi:
M13 contiene la ricostruzione LTI pesata, mentre il confronto temporale
disponibile è riportato nella classe nominale non lineare M15.

## Evidenza nominale non lineare

| Controller | Fonte | Tracking | Worst Ts [s] | Worst OS [%] | Worst errore rel. | Worst cross | Peak U tracking [N m] |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: |
| M6 | M8 | PASS | 0.77696 | 0.24099 | 0.0044128 | 0.17409 | 7.5034 |
| Khinf | M15 | FAIL | 1.7322 | 261.35 | 0.49068 | 0.25913 | 8.2558 |
| Kmu | M15 | FAIL | 1.7346 | 228.36 | 0.50442 | 0.23944 | 8.2599 |

M6 supera i target M5 di settling, overshoot, errore e cross-coupling per gli
scenari M8 2/5/8°. Khinf e Kmu falliscono il tracking; Kmu supera soltanto
il limite diagnostico di cross-coupling.

### Disturbo e rumore

| Controller | Worst peak q [rad] | Worst offset [rad] | Worst cross disturbo | Peak U disturbo [N m] |
| --- | ---: | ---: | ---: | ---: |
| M6, M8 0.25/0.5/1 N m | 0.31850 | 0.31849 | 0.46506 | 2.5979 |
| Khinf, M15 0.25/0.5/1 N m | 0.86163 | 0.19868 | 1.6011 | 3.3466 |
| Kmu, M15 0.25/0.5/1 N m | 0.84182 | 0.24657 | 1.4511 | 3.0672 |

Il disturbo è `QUANTIFIED`: M5 non fornisce un target finale che autorizzi
la promozione automatica a PASS. M8 riporta per M6 RMS di tracking
`0.0158 rad`, RMS di stima q `2.2627e-4 rad` e variazione RMS del comando
`0.0753 N m`, con repeat error nullo. M15 conserva separatamente le prove di
rumore Khinf/Kmu; la diversa architettura di misura impedisce uno score
unico.

## Monte Carlo lineare incerta M16

| Controller | Stabili | Sample instabili | Core tracking pass rate, totale | Mediana Ts [s] | Mediana errore rel. | Mediana cross |
| --- | ---: | --- | ---: | ---: | ---: | ---: |
| M6 | 39/40 | 5 | 0.30 | 0.846 | 0.017972 | 0.20825 |
| Khinf | 40/40 | nessuno | 0 | 2.105 | 0.48991 | 0.40919 |
| Kmu | 40/40 | nessuno | 0 | 1.968 | 0.50363 | 0.36275 |

Il Sample 5 M6 è conservato: presenta due poli RHP e max Re
`+1.80447 s^-1`. Non è stato rigenerato né sostituito. Khinf e Kmu sono
empiricamente stabili 40/40; per Kmu ciò è coerente con M14 ma non crea una
seconda certificazione. Le frequenze 39/40 e 40/40 non sono probabilità
fisiche.

## Stabilità e robustezza formale

| Controller | Nominale interna | MC M4 | Formal RS | Formal RP | Interpretazione |
| --- | --- | --- | --- | --- | --- |
| M6 | PASS | 39/40 empirico | N/A | N/A | limite esplicito: Sample 5 instabile |
| Khinf | PASS | 40/40 empirico | N/A | N/A | M12 non è riferibile a Khinf M10 |
| Kmu | PASS | 40/40 empirico | PASS_CERTIFIED `[1.25003698645,1.25257264120]` | FAIL_CERTIFIED `[0,0]` | RS recuperata, performance robusta non conforme |

Per Kmu la Nominal Performance M14 è `FAIL` con norma `10.3917314574`.
Robust Stability e Robust Performance sono proprietà distinte: la RS
certificata non cancella NP/RP né i fallimenti di tracking.

Per riferimento storico, A5 M12 ha RS `FAIL_CERTIFIED` con margine
`[0.875899252687,0.882789198079]` e RP `FAIL_CERTIFIED`; resta fuori dalla
terna primaria M17.

## Matrice M5

| Controller | Tracking | OS | Error | Cross | Weighted Performance | Nota |
| --- | --- | --- | --- | --- | --- | --- |
| M6 | PASS | PASS | PASS | PASS | N/A | M8 nominale non lineare; nessuna certificazione pesata equivalente |
| Khinf | FAIL | FAIL | FAIL | FAIL | FAIL | M15 più obiettivo pesato M10 |
| Kmu | FAIL | FAIL | FAIL | PASS | FAIL | M15 più NP/RP M14 |

Nessun controllore robusto soddisfa M5 e nessun candidato può essere
dichiarato conforme a tutte le specifiche disponibili.

## RAS e regione di accordo

| Controller | rmin [deg] | rmax [deg] | area [deg²] | Classificazione | Accordo LTI/NL rmin [deg] |
| --- | ---: | ---: | ---: | --- | ---: |
| M6 | 60 | 78.3244 | 14214 | SEARCH-BOX LIMITED | N/A |
| Khinf | 52.8763 | 78.3244 | 12721 | EMPIRICAL BOUNDARY LOCATED | 4.00 |
| Kmu | 60 | 78.3244 | 14214 | SEARCH-BOX LIMITED | 4.75 |

Tutte le RAS sono empiriche sul modello nominale non lineare. Per M6 e Kmu
il raggio 60° è il limite del box di ricerca, non una frontiera dinamica.
Nessuna regione è certificata analiticamente. Le regioni di accordo M15 sono
diagnostiche e non sono RAS robuste.

## Comando

| Controller | Peak tracking lineare [N m] | Peak tracking NL [N m] | Mediana tracking M16 [N m] | Peak disturbo NL [N m] | Mediana disturbo M16 [N m] |
| --- | ---: | ---: | ---: | ---: | ---: |
| M6 | 4.6897 | 7.5034 | 4.6897 | 2.5979 | 1.3080 |
| Khinf | 8.2558 | 8.2558 | 5.1599 | 3.3466 | 1.7871 |
| Kmu | N/A | 8.2599 | 5.1615 | 3.0672 | 1.6323 |

`uScale=12 N m` è esclusivamente una normalizzazione prestazionale. Non
esiste un limite hardware certificato né un modello di saturazione, quindi
M17 non dichiara `saturation PASS`.

## Complessità

| Controller | Tipo | Ordine | Certificato robusto | Nota |
| --- | --- | ---: | --- | --- |
| M6 | LQG observer-based | 14 | N/A | ordine minore della terna; nessun integratore |
| Khinf | H∞ full-order | 18 | N/A | baseline metodologica nominale |
| Kmu | D–K / μ-synthesis full-order | 52 | RS M14 | ordine maggiore; nessuna riduzione autorizzata |

La complessità è descritta tramite ordine e struttura. Non sono inventati
tempi CPU, memoria o costi hardware. Una riduzione futura di Kmu richiederebbe
autorizzazione e rivalidazione completa.

## Trade-off e selezione per ruolo

La regola usa le priorità approvate, senza somma pesata:

- **Final robust controller:** richiede prima RS formale su M4 e assenza di
  contraddizione M16; prestazioni, comando e ordine restano visibili.
- **Nominal performance reference:** richiede conformità del tracking M5 e
  usa poi le metriche temporali e il comando; l'instabilità M16 è un limite.
- **H-infinity reference:** conserva l'unica architettura H∞ full-order come
  comparatore metodologico fra sintesi nominale e D–K.

| Ruolo finale | Controller | Motivazione |
| --- | --- | --- |
| FINAL ROBUST CONTROLLER | `Kmu` | unico candidato con RS M14 `PASS_CERTIFIED` e nessuna contraddizione nei 40 campioni M16 |
| NOMINAL PERFORMANCE REFERENCE | M6 `Klqg` | unico candidato che supera i target di tracking nominale non lineare; Sample 5 resta un limite esplicito |
| H-INFINITY REFERENCE / COMPARATOR | `Khinf` | baseline H∞ full-order congelata, utile al confronto metodologico nonostante i FAIL prestazionali |

Questa assegnazione non afferma che Kmu soddisfi M5 o RP, che M6 sia
robustamente stabile, che Khinf sia inutile o che un controllore domini gli
altri.

## Artifact, figure e riproducibilità

L'esecuzione di `validate_m17_final_comparison(true)` salva
`results/data/m17_final_controller_comparison.mat`. Il dataset contiene
audit sorgenti e identità, matrici di evidenza separate, confronti di
stabilità/performance/non lineare/Monte Carlo/robustezza/RAS/comando/
complessità, tabella master, regola decisionale, ruoli, limiti e quality
gate.

Le sette figure per la relazione sono:

1. `m17_stability_evidence_summary.png`;
2. `m17_nominal_nonlinear_tracking.png`;
3. `m17_m16_stability_tracking.png`;
4. `m17_ras_comparison.png`;
5. `m17_control_effort_comparison.png`;
6. `m17_controller_complexity.png`;
7. `m17_final_tradeoff_summary.png`.

## Limiti e input per M18

M18 dovrà riportare senza modificarli: tabella master, matrice M5, tabella
stabilità nominale/MC/formale, margini RS/RP Kmu, Sample 5 M6, RAS e loro
semantica, comando con caveat `uScale`, ordini, strengths/weaknesses,
assegnazione per ruolo e le sette figure M17. Dovrà inoltre mantenere
separate validazione non lineare nominale, Monte Carlo lineare e
certificazione μ. M17 non avvia né implementa M18.
