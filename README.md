# Progetto di Controllo Robusto — Manipolatore SEA 2 DoF

Progetto universitario di Controllo Robusto dedicato a un manipolatore planare 2R con Series Elastic Actuators (SEA). L'obiettivo finale è ottenere una catena di modellazione, sintesi e validazione MATLAB/Simulink completa, originale e riproducibile per controllori LQG, \(H_\infty\) e \(\mu\)-synthesis.

> **Google Drive = reference only (sola lettura).**
> **GitHub repository = source of truth del progetto.**

## Ambito

Il progetto comprenderà:

- modello non lineare, equilibrio e linearizzazione;
- dinamiche degli attuatori e incertezze fisicamente motivate;
- LQG con e senza integratore e filtro di Kalman;
- sintesi `mixsyn`, `hinfsyn`, `hinfstruct` e relativa \(\mu\)-analysis;
- \(\mu\)-synthesis mediante D–K iteration;
- validazioni lineari e non lineari, RAS empirica e Monte Carlo;
- generazione tracciabile di dati, figure, tabelle e relazione finale.

Le scelte numeriche del progetto di riferimento non sono decisioni del presente progetto finché non vengono riprodotte, motivate e approvate.

## Struttura

```text
Progetto_CR/
├── run_all.m
├── docs/                 analisi delle fonti e governo del progetto
├── src/                  parametri, modello, attuatori e incertezze
├── controllers/          LQG, H-infinity e mu-synthesis
├── analysis/             analisi nominali, RAS, robustezza e confronti
├── simulink/             modelli Simulink del progetto
├── tests/                test automatici
├── results/              dati, figure e controllori generati
└── report/               sorgenti della relazione
```

## Prerequisiti verificati

- MATLAB R2025b Update 4;
- Simulink 25.2;
- Control System Toolbox 25.2;
- Robust Control Toolbox 25.2;
- Symbolic Math Toolbox 25.2.

La verifica dell'ambiente è documentata in `docs/PROJECT_STATUS.md` e `docs/DIARIO_DI_BORDO.md`.

## Esecuzione

Dalla radice del repository:

```matlab
run_all
```

Alla milestone M3 il comando pulisce e configura l'ambiente, esegue i test M0/M1/M2/M3, ripete le validazioni M1–M3 e rigenera i dataset e le figure nominali. Sono inclusi selezione deterministica degli attuatori, confronto ritardo/Padé e quality gate della pianta completa a 14 stati. Un fallimento critico genera un errore MATLAB e un codice di uscita non nullo.

## Stato corrente

- Milestone corrente: **M3 — Dinamica nominale degli attuatori e pianta completa**.
- Ultimo risultato validato: attuatori nominali di ordine 3 per canale, blocco MIMO di ordine 6, pianta completa a 14 stati, 29 test top-level e quality gate M3 superato in MATLAB R2025b.
- Risultati di controllo validati: nessuno; le attività di sintesi restano fuori scope.
- Prossimo passo: revisione e merge della Pull Request M3; M4 non è iniziata.

Per il dettaglio operativo vedere `docs/PROJECT_STATUS.md`, `docs/ROADMAP.md` e `docs/REQUIREMENTS_CHECKLIST.md`.
