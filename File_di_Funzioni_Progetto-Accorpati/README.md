# Progetto SEA — cartella di consegna (elaborato del 01.12.2026)

Alessio de Dato e Valerio Rebechi — Controllo Robusto, prof. Salaris, Traccia n. 2.

Questa cartella è tutto ciò che serve: codice MATLAB, 8 modelli Simulink, dati, risultati, test, relazione e presentazione. Non servono la repository, Google Drive, Python o un Workspace preparato.

## Avvio rapido

1. Estrarre lo ZIP e aprire questa cartella come *Current Folder* in MATLAB.
2. Eseguire `run_all` (equivale a `run_all('rapida')`).
3. Facoltativo: `runtests('test/seaFinaleTest.m')` e, per rigenerare tutto, `run_all('completa')`.
4. Ogni `.slx` in `simulink/` si apre e si avvia con *Run*: la callback `InitFcn` chiama `collaudo_simulink` e carica da sola modello e controllori.

Toolbox: Control System, Robust Control, Simulink; per lo SLX `LQG_linear_sim` anche DSP System Toolbox (blocchi di varianza su misura e stima). Se un path personale nasconde funzioni dei toolbox: `restoredefaultpath; rehash toolboxcache` (non eseguire `savepath`).

**Rapida** ricalcola modello, incertezze, peso WI, LQG/LQGI, analisi H∞ nominali, norme nominali delle due mappe, dieci impianti, rumore e una simulazione non lineare di controllo; **carica** (dopo controllo della firma di configurazione e dell'identità dei controllori) sintesi H∞/PID, D–K, margini robusti, prove non lineari e RAS della campagna completa. **Completa** rigenera davvero tutto, comprese le due D–K, la µ-analysis su entrambe le mappe e i 20 collaudi Simulink (ore di calcolo). Il log è in `risultati/esecuzione_<modalità>.txt`.

## Indice degli script

| Script | Cosa fa | Capitolo | Richiede | Produce | Da solo? |
|---|---|---|---|---|---|
| `run_all.m` | Esegue tutto in ordine, Workspace separati | — | — | log | sì |
| `parametri_sea.m` | Unica configurazione: fisica, incertezze, pesi, specifiche, seed | 2, 4–6 | — | struttura `p` | sì |
| `modello_sea.m` | Equilibrio, linearizzazione, drive con Padé, pianta a 14 stati | 2–4 | `dati/banca_validata.mat` | `modello.mat`, `candidati_massa.csv`, `sensibilita_attuatori.csv` | sì |
| `incertezze_attuatori.m` | Famiglie A (5 reali) e B (m2 + 2 dinamiche additive), LFT, peso WI | 5 | `modello.mat` | `incertezze.mat`, `forme_incertezza.csv`, `ordini_peso.csv` | dopo `modello_sea` |
| `progetto_lqg_lqgi.m` | LQR + Kalman, prefiltro; LQGI con integratore | 7 | `modello.mat` | `lqg.mat`, `lqgi.mat`, `kalman.csv` | dopo `modello_sea` |
| `progetto_hinf_tre_controllori.m` | mixsyn ≡ hinfsyn 1-DoF, hinfsyn 2-DoF, PID con hinfstruct | 8 | `modello.mat` | `sintesi_hinf.mat`, `hinf.csv` | sì |
| `progetto_mu.m` | D–K su A e B, µ-analysis (NS/NP/RS/RP) su Tzr e Tz[r;d], riesame D–K | 9, 12 | MAT precedenti | `confronto_robusto_r.csv`, `confronto_robusto_rd.csv`, `mappa_completa_nominale.csv`, `dk_*.csv`, `studio_mu_riferimento/` | dopo i precedenti |
| `confronto_ras.m` | Dieci impianti comuni, rumore encoder, non lineare, RAS | 10–12 | MAT precedenti | `dieci_impianti.csv`, `rumore.csv`, `nonlineare.csv`, `ras.csv` | dopo i precedenti |
| `collaudo_simulink.m` | Inizializza gli SLX (callback) o li collauda (20 run) | 10 | MAT precedenti | `simulink.csv` | sì |

`supporto/` contiene le funzioni condivise: `matrici_sea` (M, C, G, Kg), `dinamica_sea` (equazioni non lineari), `interconnessione_sea` (pianta generalizzata comune), `controllori_sea` (elenco dei controllori), `postanalisi_sea` (NS/NP/RS/RP), `simula_sea` (simulatore non lineare), `rumore_continuo_sea` (rumore ZOH e picchi intercampione), `stessi_controllori` (confronto a tolleranza delle cache).
`test/` contiene `seaFinaleTest.m` (5 test unitari) e `verifica_sea.m` (8 controlli scientifici eseguiti da `run_all`). `simulink/` contiene gli 8 modelli e, in `simulink/supporto/`, le 4 funzioni chiamate dai blocchi MATLAB Function.
`elaborati/` contiene traccia, relazione, presentazione (PDF e PowerPoint) e testo orale. `dati/banca_validata.mat` conserva i controllori di riferimento fissati, i pesi LQG/Kalman approvati e MuN1.

## Configurazione fisica (traccia, Tabella 1)

m1 = 1 kg, **m2 = 0.8 kg ±10 %**, l1 = 0.4 m, l2 = 0.3 m, Jm = 0.01 kg·m², Bm = 0.02 N·m·s/rad, k1 = 50 N·m/rad, k2 = 40 N·m/rad. Drive: **ωn = 40 rad/s ±15 %**, ζ = 0.8 noto, **τd = 15 ms ±20 %**, Padé del primo ordine. Equilibrio q̄ = [π/2; 0]. Stato meccanico [q, q̇, θ, θ̇], 14 stati con i drive. Nessuna massa aggiuntiva dell'end-effector.

Pesi: We(s) = (s/3+2)/(s+0.3), Wu(s) = 0.003(s+80)/(s/6+80), Mo(s) = 9/(s+3)², diagonali. Target nominali: Ts ≤ 5 s, Mp ≤ 15 %, errore statico ≤ 5 %, cross-coupling ≤ 25 %. We(0) = 6.67 implica che la soglia unitaria tollera fino al 15 % di errore statico per elemento: il 5 % va verificato a parte (Capitolo 6).

## Come leggere i risultati

- **NS / RS**: stabilità interna del chiuso completo, nominale / per tutta la famiglia (A o B). Margine RS > 1 → PASS, < 1 → FAIL, altrimenti INCONCLUDENTE.
- **NP / RP**: ‖Tz‖∞ < 1 nominale / per tutta la famiglia, su due mappe con gli stessi pesi: **Tzr** (solo riferimento) e **Tz[r;d]** (riferimento e disturbo di coppia). `NP_FAIL` e `LIMITE_DA_RS` indicano esiti dedotti, non un margine RP calcolato.
- **Dieci impianti**: evidenza empirica sugli stessi campioni per tutti; non sostituisce la µ-analysis.
- **RAS**: stima empirica su 15 condizioni iniziali; TIMEOUT non significa instabilità.
- I test software (PASS/FAIL/NOT RUN) sono distinti dalle specifiche dei controllori: un controllore può fallire RP con tutte le verifiche software PASS.

## Esiti principali

Nominale (prove lineari, Capitolo 10) e robustezza (Capitolo 9) per i sette controllori della banca e per MuN1, inizializzazione comune delle due D–K.

| Controllore | 4 target nominali | NS | RS A/B | NP / RP su Tzr (A/B) | NP / RP su Tz[r;d] (A/B) |
|---|---|---|---|---|---|
| LQG | PASS | PASS | PASS/PASS | PASS / PASS-PASS | FAIL / FAIL-FAIL |
| LQGI | FAIL (Ts) | PASS | PASS/PASS | FAIL / FAIL-FAIL | FAIL / FAIL-FAIL |
| Hinf1 | FAIL (Mp, ess, cross) | PASS | PASS/PASS | FAIL / FAIL-FAIL | FAIL / FAIL-FAIL |
| Hinf2 | PASS | PASS | FAIL/FAIL | PASS / FAIL-FAIL | PASS / FAIL-FAIL |
| PID | FAIL (cross) | PASS | FAIL/FAIL | PASS / FAIL-FAIL | PASS / FAIL-FAIL |
| Mu_A | FAIL (Ts, ess) | PASS | PASS/PASS | FAIL / FAIL-FAIL | FAIL / FAIL-FAIL |
| Mu_B | FAIL (ess) | PASS | PASS/PASS | PASS / FAIL-FAIL | FAIL / FAIL-FAIL |
| MuN1 | FAIL (ess 8.24 %) | PASS | PASS/PASS | PASS / PASS-PASS | PASS / PASS-PASS |

Margini RP di MuN1 su Tz[r;d]: [1.599, 1.897] in A e [1.533, 1.536] in B (`risultati/verifica_rp_mappa_completa_20261124.csv`). Fonti: `confronto_robusto_r.csv`, `confronto_robusto.csv`, `studio_mu_riferimento/`, `dieci_impianti.csv`.

## Release e verifiche

| Prova | Release | Esito |
|---|---|---|
| Campagna completa (sintesi H∞ e D–K, µ-analysis su Tzr, RAS, 20 collaudi Simulink) | R2026b, 04.11.2026 | PASS (`verifica_numerica_20261104.txt`) |
| RP sulla mappa completa Tz[r;d] per MuN1 e i sette controllori | R2026a, 24.11.2026 | eseguita (`verifica_rp_mappa_completa_20261124.*`) |
| ZIP estratto: manifest 95/95, 5/5 test unitari, `run_all` rapida, 8/8 verifiche, 8 SLX avviati dalla callback, 20/20 collaudi Simulink | R2026a, 24.11.2026 | PASS (`collaudo_consegna_20261124.txt`) |
| `run_all('completa')` sul codice riorganizzato | — | NOT RUN (ore di calcolo; i risultati caricati vengono dalla campagna del 04.11) |

Gli SLX sono salvati in R2026a e si aprono in R2026a e nelle release successive.
