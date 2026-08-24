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

Al completamento M8 il comando pulisce e configura l'ambiente, esegue le
regressioni M0–M7, ricostruisce e valida il modello Simulink non lineare con
il controllore M6 invariato, rigenera tracking, disturbi, rumore, confronti
LTI/NL e le due sezioni RAS empiriche. M7 resta il risultato terminale
`PARTIAL`; non viene eseguito altro tuning.

## Stato corrente

- Milestone corrente: **M8 — Simulink e RAS LQG, COMPLETE**.
- Controllore validato: M6 LQG senza integratore, ordine 14, con `K/L/Nr`
  invariati; M7 resta `PARTIAL` e congelata.
- Risultato non lineare: equilibrio senza drift, sei tracking, sei disturbi e
  rumore seeded completati; scarto LTI/NL massimo 0.0006201 rad.
- RAS empirica: 57/57 punti convergenti in entrambe le sezioni entro il box
  computazionale ±60°; la frontiera è quindi search-box limited.
- Prossimo passo: **M9 — sintesi nominale `H_infinity mixsyn`**, non iniziata.

Per il dettaglio operativo vedere `docs/PROJECT_STATUS.md`, `docs/ROADMAP.md` e `docs/REQUIREMENTS_CHECKLIST.md`.
