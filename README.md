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

Al completamento M7 il comando pulisce e configura l'ambiente, esegue le regressioni M0–M6, rigenera il checkpoint 1-DoF, Stage A con feedforward candidato-specifico e la Stage B condizionale. La pipeline M6 completa resta validata; M7 non pubblica un controllore finale perché nessuno dei 53 candidati raggiunge insieme settling e overshoot M5. Un errore software genera un codice di uscita non nullo, mentre l’esito prestazionale atteso è segnalato come `PARTIAL`, non come PASS M7.

## Stato corrente

- Milestone corrente: **M7 — LQG nominale con integratore, stato PARTIAL**.
- Risultato strutturale: augmentazione 16×16 stabilizzabile, due integratori sulle posizioni e nessuna ostruzione a zero.
- Risultato completion: Stage A 0/28 e Stage B 0/25 ammissibili; E16 raggiunge 1.020 s ma con overshoot 40.6448% e comando 35.170 N m.
- Prossimo passo: nuova revisione della feasibility M7. M5 resta invariata, nessun controller finale è selezionato e M8 non è iniziata.

Per il dettaglio operativo vedere `docs/PROJECT_STATUS.md`, `docs/ROADMAP.md` e `docs/REQUIREMENTS_CHECKLIST.md`.
