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

Alla milestone M0 il comando configura i path, imposta il seed riproducibile ed esegue esclusivamente gli smoke test della struttura. Le pipeline tecniche saranno aggiunte nelle milestone successive senza dipendere da variabili residue nel workspace.

## Stato corrente

- Milestone corrente: **M0 — Setup, fonti e repository**.
- Ultimo risultato validato: accessi, ambiente MATLAB e struttura minima della workspace.
- Risultati di controllo validati: **nessuno; M1 non è iniziata**.
- Prossimo passo: revisione del gruppo e approvazione delle proposte iniziali prima di M1.

Per il dettaglio operativo vedere `docs/PROJECT_STATUS.md`, `docs/ROADMAP.md` e `docs/REQUIREMENTS_CHECKLIST.md`.
