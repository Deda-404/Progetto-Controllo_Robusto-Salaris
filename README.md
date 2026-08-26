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

Il comando pulisce e configura l'ambiente, esegue le regressioni M0–M17,
ricostruisce gli artifact precedenti e completa il confronto artifact-only M17.
I risultati negativi M9–M12, M14 e M15 sono conservati senza ritunare M5;
M7 resta `PARTIAL` terminale. La sintesi M13 non viene rilanciata
automaticamente: il raw output autorizzato è congelato. M14 resta la fonte
della certificazione mu, M15 la validazione non lineare nominale, M16
l'evidenza empirica sui campioni lineari M4 e M17 la decisione per ruolo.

## Stato corrente

- Milestone corrente: **M17 — confronto finale dei controllori, COMPLETE**;
  M16/M13 restano `COMPLETE`, mentre M15/M14 restano `PARTIAL` per i
  risultati prestazionali negativi documentati.
- Controllore validato: M6 LQG senza integratore, ordine 14, con `K/L/Nr`
  invariati; M7 resta `PARTIAL` e congelata.
- Risultato non lineare: equilibrio senza drift, sei tracking, sei disturbi e
  rumore seeded completati; scarto LTI/NL massimo 0.0006201 rad.
- RAS empirica: 57/57 punti convergenti in entrambe le sezioni entro il box
  computazionale ±60°; la frontiera è quindi search-box limited.
- Risultato M9: interconnessione nominale stabile, controllore ordine 18,
  `gamma=10.2071036477` e norma ricostruita `10.2071033931`; obiettivi
  weighted e tracking falliti senza retuning, `W3` o analisi robusta.
- Risultato M10: generalized plant corretta, `gammaHinf=10.2071036477` e
  controller ordine 18 quasi equivalenti a M9; stabilità PASS, obiettivi
  weighted e tracking FAIL, senza retuning o analisi robusta.
- Risultato M11: 30/30 start conservati, 15 stabili; A0–A2 senza
  rappresentante stabile e frontiera Pareto A3/A4/A5 con ordine 2/4/6 e
  gamma 16.6419/11.6555/10.2477. M11 `PARTIAL` è accettata come studio
  strutturato concluso; il gruppo ha selezionato A5 per la sola analisi M12.
- Risultato M12: N–Δ e software `PASS`; NS `PASS`, NP `FAIL`, RS
  `FAIL_CERTIFIED` con margin `[0.875899,0.882789]` e RP `FAIL_CERTIFIED`.
- Risultato M13: cinque iterazioni D–K, objective `10.4032233618`, Kmu 2×2
  di ordine 52 e stabilità nominale `PASS` con max Re `-0.731994726169`.
  L'objective >1 è conservato senza retuning.
- Risultato M14: NS `PASS`, NP `FAIL`, RS `PASS_CERTIFIED` con margin
  `[1.250037,1.252573]` e RP `FAIL_CERTIFIED`. Rispetto ad A5, RS passa da
  `FAIL_CERTIFIED` a `PASS_CERTIFIED`: recupero certificato della stabilità
  robusta sul modello lineare incerto M4, senza conformità di performance.
- Risultato M15: equilibrio `PASS` per entrambi; tracking M5 `FAIL` con worst
  Ts 1.7322/1.7346 s e OS 261.35/228.36% per Khinf/Kmu. La RAS Khinf ha
  raggio minimo 52.876° con boundary interno; Kmu raggiunge il box con raggio
  minimo 60°. Le regioni empiriche di accordo LTI/NL hanno raggio minimo
  4°/4.75°. Software `PASS`, nessuna saturazione o incertezza non lineare.
- Risultato M16: 40 campioni M4 comuni, seed `20260826`; stabilità
  M6/Khinf/Kmu `39/40`, `40/40`, `40/40`. Il Sample 5 M6 ha due poli RHP e
  max Re `+1.80447`. I core tracking pass rate sono `30%/0%/0%`; Kmu 40/40
  è coerente con la RS certificata M14, ma la Monte Carlo non è un
  certificato né una probabilità fisica. Nessun retuning o score globale.
- Risultato M17: identità e ordini M6/Khinf/Kmu `14/18/52` verificati,
  evidenze nominali/non lineari/Monte Carlo/formali mantenute separate e
  nessuno score globale. La selezione finale è `Kmu` come final robust
  controller, M6 come nominal performance reference e `Khinf` come
  H-infinity reference/comparator. Kmu conserva tracking, NP e RP falliti;
  M6 conserva il Sample 5 instabile e M6/Khinf restano senza certificato RS.

Per il dettaglio operativo vedere `docs/PROJECT_STATUS.md`,
`docs/FINAL_CONTROLLER_COMPARISON.md`,
`docs/MONTE_CARLO_UNCERTAIN_PLANTS.md`, `docs/ROADMAP.md` e
`docs/REQUIREMENTS_CHECKLIST.md`.
