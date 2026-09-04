# Controllo robusto di un manipolatore SEA a 2 DoF

Progetto universitario di Controllo Robusto sviluppato da **Alessio de Dato** e **Valerio Rebechi**. Il caso di studio è un manipolatore planare 2R azionato mediante Series Elastic Actuators (SEA), modellato e validato in MATLAB/Simulink.

Il repository contiene l'intero percorso di lavoro: modello non lineare, equilibrio e linearizzazione, dinamica degli attuatori, insieme incerto, specifiche, sintesi LQG e $H_\infty$, D--K iteration, $\mu$-analysis, simulazioni non lineari, regione empirica di attrazione e Monte Carlo.

## Risultato conclusivo

Nessun controllore soddisfa simultaneamente tutte le specifiche. La selezione è quindi distinta per ruolo:

- **Kmu** è il controllore robusto finale: M14 certifica la Robust Stability sull'insieme lineare incerto M4, mentre Nominal Performance e Robust Performance restano non conformi;
- **M6 LQG** è il riferimento di prestazione nominale: rispetta il tracking M5 sul modello nominale, ma presenta un caso instabile nella campagna M16 e non dispone di un certificato RS;
- **Khinf** è il comparatore metodologico full-order della sintesi $H_\infty$.

La Monte Carlo M16 usa 40 realizzazioni comuni dell'unico insieme M4: con il nuovo LQR M6 è stabile in 38/40 casi (Sample 5 e 6 instabili), Khinf e Kmu in 40/40. Queste frazioni sono evidenza empirica sul campione e non probabilità fisiche; la certificazione RS di Kmu deriva esclusivamente dalla $\mu$-analysis M14.

## Struttura del repository

```text
Progetto_CR/
├── run_all.m             esecuzione completa M0--M18
├── analysis/modellazione_linearizzazione_controllo.m
│                         macrofase didattica M0--M5, eseguibile per sezioni
├── analysis/progetto_lqg.m
│                         percorso didattico LQR/Kalman/LQG M6--M8 e RAS
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

## Riproduzione

Dalla radice del repository:

```matlab
run_all
```

La pipeline esegue le verifiche M0--M18 e rigenera i risultati riproducibili. La D--K iteration M13 non viene rilanciata automaticamente: viene caricato e verificato l'artefatto approvato, evitando una nuova sintesi. Lo studio per l'esame è diviso in tre script indipendenti: `analysis/modellazione_linearizzazione_controllo.m` per M0--M5, `analysis/progetto_lqg.m` per M6--M8 e `analysis/progetto_hinf.m` per M9--M12. Gli ultimi due applicano la stessa metodologia RAS ai controllori significativi e mantengono separata la simulazione empirica dalla certificazione mu.

In M6 la normalizzazione fisica serve a costruire costi confrontabili, ma la scelta finale di Q e R deriva da una ricerca esplicita di 36 combinazioni. Prima vengono applicati i vincoli obbligatori M5; i candidati ammissibili sono poi ordinati mediante un compromesso normalizzato che include tracking e comando. Le ipotesi Kalman sono accompagnate da tre casi di sensibilità sulla deviazione standard del rumore di misura.

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
- RAS e Monte Carlo hanno significato empirico;
- Kmu resta di ordine 52.

Prima della consegna devono essere completate le matricole degli autori e la data nel frontespizio.
