# Project Status

**Current milestone:** M4 — Modellazione delle incertezze e pianta incerta
**Status:** COMPLETE — quality gate tecnico M4 superato
**Last validated milestone:** M4
**Last validated result:** `run_all.m` in MATLAB R2025b, 48/48 test top-level, screening, `WI`, `Gunc`, coerenza nominale e 40/40 campioni PASS
**Blocking issues:** nessuno
**Next task:** revisione della Pull Request M4; non iniziare M5 senza il successivo incarico del gruppo
**Pull Request:** da aprire sul branch `codex/m4-uncertainty-model`
**Last update:** 2026-08-24 16:31 CEST

## Ensemble baseline M4

| Componente | Scelta | Stato |
| --- | --- | --- |
| Parametri meccanici | `k2`, `k1`, `Jm1` | selezionati dallo screening 3/10 |
| Range meccanici | `k1/k2` ±7%, `Jm1` ±9% | assunzioni baseline |
| Attuatori | `wn` ±8%, `zeta` ±7.5%, ritardo ±20% | assunzioni baseline |
| Famiglia | 120 modelli, inclusi 8 corner | seed 20260824 |
| Ritardo della famiglia | esatto `exp(-jw*delay)` | nominale M3 ancora Padé 1 |
| Modello dinamico | input-moltiplicativo | `Ga_nom*(1+WI*Delta)` |
| `WI` | ordine 1, stabile e proprio | safety factor 1.08 |
| Delta attuatori | `Delta_act1`, `Delta_act2` | indipendenti, `ultidyn` 1x1 |
| Pianta | `GuncMeas` 4x2, `GuncQ` 2x2 | compatibili con `lftdata/usample` |

I range sono assunzioni ingegneristiche, non tolleranze misurate o intervalli identificati. Non sono stati adattati in base a risultati di controllo, che non esistono ancora.

## Screening autonomo

Lo screening usa perturbazioni centrali ±1%, ricostruzione completa di equilibrio, Jacobiani e pianta M3 su 501 frequenze fra 0.1 e 300 rad/s. La priorità combina:

- 65% sensibilità dinamica: FRF 30%, poli instabili 25%, modi elastici 25%, sigma dominante 20%;
- 15% plausibilità della variabilità fisica;
- 10% ruolo/numero delle occorrenze;
- 10% interpretabilità futura.

| Rank | Parametro | Dynamic score | Overall priority |
| ---: | --- | ---: | ---: |
| 1 | `k2` | 0.74829 | 0.75889 |
| 2 | `k1` | 0.58074 | 0.64998 |
| 3 | `Jm1` | 0.60392 | 0.59755 |
| 4 | `Jm2` | 0.59813 | 0.59379 |
| 5 | `m2` | 0.32355 | 0.54781 |

Gli altri candidati sono `l1`, `l2`, `m1`, `Bm2`, `Bm1`. `g` resta nota.

## Fit attuatore e copertura

| Metrica | Valore | Criterio |
| --- | ---: | --- |
| Modelli famiglia | 120 | almeno 100 |
| Nominale / singoli / corner / random | 1 / 6 / 8 / 105 | corner obbligatori |
| Intervallo frequenziale | 0.1–1000 rad/s, 801 punti | ritardo esatto |
| Ordine `WI` | 1 | minimo accettabile fra 1–4 |
| Polo / zero | -207.3533 / -1.32753 s⁻¹ | entrambi stabili |
| Guadagno zpk | 2.871319866 | calcolato |
| Worst `|E|/|WI|` | 0.925925926 | <=1+1e-9 |
| Margine minimo | 0.0130725422 | >=-1e-9 |
| Caso critico | `corner-212`, 281.8383 rad/s | 43.2, 0.74, 18 ms |

## Struttura Delta

| Nome | Tipo | Dimensione | Natura | Occorrenze LFT |
| --- | --- | --- | --- | ---: |
| `Delta_act1` | `ultidyn` | 1x1 | complesso dinamico | 1 |
| `Delta_act2` | `ultidyn` | 1x1 | complesso dinamico | 1 |
| `Jm1` | `ureal` | 1x1 | reale statico | 1 |
| `k1` | `ureal` | 1x1 | reale statico | 1 |
| `k2` | `ureal` | 1x1 | reale statico | 1 |

Ogni parametro fisico è creato una volta e riutilizzato nelle sue occorrenze; i due canali dinamici non condividono Delta.

## Coerenza nominale e campioni

| Verifica | Risultato |
| --- | ---: |
| Errore Frobenius meccanico `A` | 1.230e-12 |
| Errore meccanico `B` | 0 |
| `GuncMeas.NominalValue` vs M3, abs/rel | 4.890e-15 / 1.188e-14 |
| `GuncQ.NominalValue` vs M3, abs/rel | 6.328e-15 / 4.689e-12 |
| Campioni `usample` | 40/40 validi, seed 20260825 |
| Poli instabili per campione | sempre 2, attesi da M2 |
| Massima parte reale osservata | 7.2003–7.2196 s⁻¹ |

## Quality gate M4

| Requisito | Esito |
| --- | --- |
| main remoto con merge M3.1 verificato | PASS — base a1eca7b |
| screening autonomo e multifattore | PASS |
| tre parametri selezionati e motivati | PASS |
| scenari e range meccanici documentati | PASS |
| scenari e range attuatori documentati | PASS |
| nessun range copiato automaticamente | PASS |
| tre `ureal` corretti e consistenza meccanica | PASS |
| famiglia riproducibile con corner | PASS |
| ritardo esatto e mismatch Padé inclusi | PASS |
| `WI` minimo, stabile, proprio e coprente | PASS |
| due Delta dinamici indipendenti | PASS |
| `GuncMeas/GuncQ` costruite | PASS |
| nominale `Gunc` uguale a M3 | PASS |
| struttura `lftdata` documentata | PASS |
| 40 campioni validi | PASS |
| dataset e tre figure generati | PASS |
| 14 test M4 e 34 regressioni pregresse | PASS |
| confronto reference-last | PASS — soluzione invariata |
| `run_all.m` exit code 0 | PASS — 48/48 test top-level |
| documentazione e diario | PASS |

## Limiti e problemi aperti

- Nessun range è sostenuto da identificazione sperimentale.
- Lo screening è locale all'equilibrio M2 e alla griglia 0.1–300 rad/s.
- `Jm2` è molto vicino a `Jm1` in priorità e resta il primo parametro escluso.
- La copertura `WI` è verificata sulla famiglia discreta e sulla griglia 0.1–1000 rad/s.
- I campioni M4 verificano la costruzione; non sono il Monte Carlo finale.
- L'instabilità open-loop meccanica resta attesa e non è un FAIL.
- Specifiche, pesi di prestazione, controllori e analisi robusta closed-loop non sono stati iniziati.
