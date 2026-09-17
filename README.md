# Controllo robusto di un manipolatore SEA a 2 DoF

Progetto universitario di Controllo Robusto sviluppato da **Alessio de Dato** e **Valerio Rebechi**. Il caso di studio è un manipolatore planare 2R azionato mediante Series Elastic Actuators (SEA), modellato e validato in MATLAB/Simulink.

Il repository contiene l'intero percorso di lavoro: modello non lineare, equilibrio e linearizzazione, dinamica degli attuatori, insieme incerto, specifiche, sintesi LQG e $H_\infty$, D--K iteration, $\mu$-analysis, simulazioni non lineari, regioni interne nominali di Lyapunov, mappe empiriche di attrazione e Monte Carlo.

## Revisione corrente: pesi diretti H-infinity, LQR e LQRI

La revisione parte dalla baseline `aae96148353506b8ba119de65f6dcf3103eec328`
(PR 29), su un branch dedicato riportato nello stato di progetto.
Modello M0–M4, target temporali M5 e criteri di selezione sono invariati.

- **H-infinity:** pianta nelle coordinate fisiche; 8 candidati W1 e 4 W2,
  tutti non conformi. Sono attivi omegaW1=8 rad/s, As=0.15, Ms=2.5,
  ku=0.05, omegaU=60 rad/s, alpha=6. M9/M10 restano a due pesi
  (gamma=5.67722); W3 è fisso e presente soltanto nello studio separato.
- **M6 LQG:** ricerca reale di 36 costi con ru={0.01,0.05,0.10};
  9 ammissibili, selezionato LQR30 con R=0.10 I2. Q e Kalman sono
  identici alla baseline, R/K/Nr sono ricalcolati.
- **M7 LQRI:** Qi=wbarI I2 con wbarI={20,200,800}, senza xiScale.
  Tre chiusure stabili di ordine 30; nessuna soddisfa tutti i target.
  Il punto illustrativo 200 annulla l'offset DC ma ha Ts=5.046 s.
- **M14:** il nuovo Kmu, ottenuto con una sola campagna D–K dipendente
  dai nuovi pesi, ha ordine 70. RS è FAIL_CERTIFIED con margine
  [0.774042,0.775697]; anche NP/RP falliscono.
  **Il ruolo robusto finale non è assegnato.** Il certificato precedente
  non è trasferibile al controllore corrente.

M16 resta evidenza empirica su 40 realizzazioni comuni M4, non una
certificazione né una probabilità fisica. La catena downstream viene
rigenerata soltanto perché i controllori sorgente sono cambiati.
Stato di validazione e limiti: `docs/PROJECT_STATUS.md`.
Il resoconto della revisione è `docs/RESOCONTO_REVISIONE_PESI_HINF_LQR_LQRI.txt`;
i resoconti del 10 e 14 settembre sono storici.

Per leggere i risultati già calcolati, senza ripetere sintesi:

```matlab
addpath(genpath('src'),genpath('controllers'),genpath('analysis'))
studio = study_hinf_weights;
build_direct_weights_summary
plot_hinf_revision
plot_lqri_revision
```

La produzione dello studio tramite `study_hinf_weights(true)` è riservata
all'assenza di una cache compatibile: al massimo 12 candidati, più M9/M10.
M11 conserva i suoi 30 avvii strutturati. La selezione dello studio a tre
pesi non va confusa con la produzione M10 a due pesi.
I Capitoli 6 e 8 separano target generali e pesi mixed-sensitivity;
il §8.3 include il diagramma della Lower LFT effettivamente usata in M10.

## Struttura del repository

```text
Progetto_CR/
├── run_all.m             esecuzione completa M0--M18
├── analysis/modellazione_linearizzazione_controllo.m
│                         macrofase didattica M0--M5, eseguibile per sezioni
├── analysis/progetto_lqg.m
│                         percorso didattico LQR/Kalman/LQG M6--M8 e RAS
├── analysis/progetto_lqri.m
│                         servo M7 con Kalman M6 e integratori misurati
├── analysis/progetto_hinf.m
│                         percorso didattico H-infinity M9--M12 e RAS
├── src/                  parametri, modello, attuatori e incertezze
├── controllers/          LQG, H-infinity e mu-synthesis
├── analysis/             analisi nominali, robuste e non lineari
├── simulink/             modelli Simulink
├── tests/                regressione automatica
├── results/              dati, figure e controllori validati
├── report/               relazione finale e sorgenti LaTeX
├── presentation/         presentazione, timing e note
├── docs/                 motivazioni, decisioni e tracciabilità
└── tools/                compilazione e controlli dei deliverable
```

## Requisiti software

- MATLAB R2025b;
- Simulink;
- Control System Toolbox;
- Robust Control Toolbox;
- Symbolic Math Toolbox;
- una distribuzione LaTeX compatibile con `latexmk`.
- Git LFS per scaricare le traiettorie Lyapunov complete.

Il file `results/data/lyapunov_trajectories.mat` è conservato
integralmente tramite Git LFS. Dopo il clone eseguire `git lfs install` e
`git lfs pull` dalla radice del repository. Il solo archivio ZIP o un clone
senza LFS potrebbe contenere il puntatore testuale invece dei dati MATLAB.

## Riproduzione

Dalla radice del repository:

```matlab
run_all
```

La pipeline esegue le verifiche M0--M18 e rigenera i risultati riproducibili. La D--K iteration M13 non viene rilanciata automaticamente: viene caricato e verificato l'artefatto approvato, evitando una nuova sintesi. Lo studio per l'esame è diviso in tre script indipendenti: `analysis/modellazione_linearizzazione_controllo.m` per M0--M5, `analysis/progetto_lqg.m` per M6--M8 e `analysis/progetto_hinf.m` per M9--M12. Gli ultimi due applicano la stessa metodologia RAS ai controllori significativi e mantengono separata la simulazione empirica dalla certificazione mu.

In M6 la normalizzazione fisica serve a costruire costi confrontabili, ma la scelta finale di Q e R deriva da una ricerca esplicita di 36 combinazioni. Prima vengono applicati i vincoli obbligatori M5; i candidati ammissibili sono poi ordinati mediante un compromesso normalizzato che include tracking e comando. Le ipotesi Kalman sono accompagnate da tre casi di sensibilità sulla deviazione standard del rumore di misura.

La revisione tecnica del settembre 2026 aggiunge un percorso che non rilancia le sintesi H-infinity:

```matlab
addpath(genpath('src'),genpath('controllers'),genpath('analysis'))
validate_lyapunov_ras
validate_lyapunov_trajectories
run('analysis/progetto_lqg.m')
run('analysis/progetto_hinf.m')
regenerate_document_figures
r = runtests('tests'); assertSuccess(r)
```

Il bound di Lyapunov include 28, 32 e 84 stati per LQG, Khinf e Kmu. Il confronto grafico distingue regione analitica sufficiente, ellisse verificata su punti finiti e traiettorie empiriche. Q/R, sigma e parametri della ricerca sono spiegati nei due script; le matrici numeriche sono esportate automaticamente in LaTeX.

**Attenzione:** `run_all` è la ricostruzione completa e rilancia M9–M11; non va ripetuto per il solo aggiornamento dei documenti. La revisione corrente ha eseguito le sintesi richieste e una sola nuova M13, dopo aver fissato i pesi; non implica ulteriori campagne.

Per rigenerare macro, tabelle e asset dei documenti:

```matlab
validate_m18_deliverables(true,true)
```

Per compilare relazione e presentazione:

```powershell
powershell -ExecutionPolicy Bypass -File tools/build_m18_latex.ps1
```

## Deliverable

- `report/Progetto_CR_Relazione_finale.pdf`;
- `presentation/Progetto_CR_Presentazione.pdf`;
- `docs/FINAL_DELIVERABLE_MANIFEST.md`;
- `docs/FINAL_EDITORIAL_AUDIT.md`.

## Limiti principali

- M7 non produce un controllore LQG con integratore finale;
- Kmu possiede RS certificata, ma fallisce NP, RP e tracking M5;
- Khinf e Kmu non soddisfano il tracking M5;
- M6 e Khinf non hanno una certificazione RS formale su M4;
- `uScale=12 N m` è una normalizzazione, non una saturazione hardware;
- le incertezze non derivano da identificazione sperimentale;
- la regione interna analitica di Lyapunov è nominale e conservativa; il livello più ampio campionato, le mappe M8/M15 e la Monte Carlo restano empirici;
- Kmu resta di ordine 52.

Prima della consegna devono essere completate le matricole degli autori e la data nel frontespizio.
# Revisione H-infinity del 17 settembre 2026

Il branch `codex/hinf-targeted-retuning` aggiunge una campagna nominale
isolata M9--M11: full-order gamma=0.866036 e MIMO ordine 6 objective=0.879311.
Il tracking 1-DoF resta non conforme. Baseline e pipeline `run_all` sono
conservate; i nuovi artifact non alimentano automaticamente M12 e successive.
Esecuzione dedicata e risultati: [resoconto H-infinity](docs/RESOCONTO_HINF_TARGETED_RETUNING.md).
Solo il Capitolo 8 della relazione integra la revisione; abstract e capitoli
successivi continuano a descrivere la baseline. Merge riservato al gruppo.
