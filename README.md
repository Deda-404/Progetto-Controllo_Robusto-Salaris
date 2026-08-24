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

Alla milestone M6 il comando pulisce e configura l'ambiente, esegue le regressioni M0–M5 e i test M6, ripete le validazioni precedenti e rigenera tuning LQR, selezione Kalman, controllore LQG, dataset e figure. Sono inclusi la coarse grid da 240 costi adimensionali, i 27 candidati Kalman, principio di separazione, tracking, disturbi e diagnostica seeded del rumore. Un fallimento critico genera un errore MATLAB e un codice di uscita non nullo.

## Stato corrente

- Milestone corrente: **M6 — LQG nominale senza integratore**.
- Risultato LQR: candidato C193 con `wq=1`, `wdelta=0.1`, `wqdot=wthetaDot=0.5`, `rhoU=8`; worst settling 0.776 s e picco comando 4.6897 N m.
- Risultato Kalman/LQG: KF03, ratio di decay 1.6928, controllore dinamico ordine 14 senza integratori e principio di separazione verificato.
- Prossimo passo: revisione della Pull Request M6. M7, Simulink, nonlinear simulation e analisi robusta non sono iniziati.

Per il dettaglio operativo vedere `docs/PROJECT_STATUS.md`, `docs/ROADMAP.md` e `docs/REQUIREMENTS_CHECKLIST.md`.
