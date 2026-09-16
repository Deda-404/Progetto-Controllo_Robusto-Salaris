# M17 — Confronto finale dei controllori

## Configurazione corrente — 16 settembre 2026

I nuovi pesi M5 hanno richiesto la rigenerazione della catena dipendente.
Kmu ha ordine 70 e M14 restituisce RS FAIL_CERTIFIED, con margine
[0.774041952377,0.775696806012]; NP/RP falliscono. Il criterio del ruolo
robusto richiede ancora RS PASS_CERTIFIED e stabilità empirica M16:
il ruolo resta pertanto NON ASSEGNATO, senza abbassare i requisiti.
M6 è il riferimento nominale e Khinf il comparatore H-infinity.
I nuovi numeri M15/M16 e il gate M17 sono riportati negli artifact
rigenerati e nel resoconto `RESOCONTO_REVISIONE_PESI_HINF_LQR_LQRI.txt`.

## Confronto storico precedente — risultati non trasferibili

**Stato:** `COMPLETE` — decisione per ruolo, senza score globale.

## Metodo

M17 carica gli artefatti validati e mantiene separate quattro classi di evidenza: nominale lineare, nominale non lineare, Monte Carlo lineare incerta e robustezza formale. Non esegue sintesi, tuning, simulazioni o riduzione d'ordine.

| Controllore | Tipo | Ordine | Identità |
| --- | --- | ---: | --- |
| M6 | LQG senza integratore | 14 | PASS M6/M8/M16 |
| Khinf | H∞ full-order | 18 | PASS M10/M15/M16 |
| Kmu | D–K / μ-synthesis | 52 | PASS M13/M14/M15/M16 |

## Evidenza prestazionale e robusta

| Controllore | Tracking nominale NL | Monte Carlo M4 | RS formale | RP formale |
| --- | --- | --- | --- | --- |
| M6 | `PASS` | 38/40 empirico; Sample 5 e 6 instabili | N/A | N/A |
| Khinf | `FAIL` | 40/40 empirico | N/A | N/A |
| Kmu | `FAIL` | 40/40 empirico | `PASS_CERTIFIED` [1.06956057969,1.21287515623] | `FAIL_CERTIFIED` |

M6 ha worst settling nominale non lineare 0.67925 s e rispetta i target M5 studiati. Khinf e Kmu falliscono il tracking. M12 riguarda A5, non Khinf: non si trasferisce quindi una certificazione formale a Khinf.

La Monte Carlo conserva i due casi M6 instabili; il peggiore ha max Re +2.93760 1/s. I core tracking pass rate sul totale sono 55% per M6 e 0% per i due controllori robusti. Queste frazioni non sono probabilità fisiche.

## Assegnazione finale

| Ruolo | Controllore | Motivazione |
| --- | --- | --- |
| controllo robusto finale | Kmu | unico con RS M14 certificata; RP e tracking restano falliti |
| riferimento di prestazione nominale | M6 | unico conforme al tracking nominale M5; limite M16 esplicito |
| comparatore H∞ | Khinf | soluzione full-order che conserva il confronto metodologico |

Nessun controllore soddisfa tutte le specifiche. L'ordine 52 di Kmu è un costo implementativo non ridotto; `uScale` non certifica la fattibilità attuativa; le RAS M8/M15 sono empiriche.

Artifact: `results/data/m17_final_controller_comparison.mat`.
