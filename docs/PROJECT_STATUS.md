# Stato del progetto

**Fase corrente:** refactoring strutturale e didattico concluso

**Ramo:** `codex/didactic-structural-refactor`

**Autori:** Alessio de Dato, Valerio Rebechi

**Ultimo aggiornamento:** 2026-09-01

## Decisioni vincolanti

- M0–M5 formano la macrofase «Modellazione, linearizzazione e definizione del problema di controllo».
- Esiste un unico insieme incerto M4; non sono presenti scenari alternativi.
- Specifiche e pesi M5 sono congelati.
- M6 LQG, M10 Khinf e M13 Kmu sono congelati; non sono state aperte nuove sintesi né eseguito retuning.
- M16 è una valutazione Monte Carlo empirica e non sostituisce la μ-analysis M14.
- Gli esiti negativi sono risultati tecnici e restano visibili.

## Struttura didattica corrente

La macrofase iniziale è percorribile per sezioni in `analysis/modellazione_linearizzazione_controllo.m`. Le funzioni matematiche riutilizzabili e i validator numerici restano separati.

| Parte | Scelta diretta | Verifica MATLAB |
| --- | --- | --- |
| M3 attuatore | wn 40 rad/s, ζ 0.8, ritardo 15 ms, Padé 1 | confronto manuale lento/nominale/veloce, `stepinfo`, `bandwidth`, Bode |
| M4 meccanica | Jm1, k1, k2 tutti ±10% | range, nominale, struttura `ureal`, campioni `usample` |
| M4 attuatori | wn e ζ ±10%, ritardo ±20% | famiglia di 120 modelli e copertura WI ordine 1 |
| M5 | ωB 12 rad/s, As 0.05, Ms 2, uScale 12 N m, ωU 30 rad/s, α 6 | asintoti, properness e disturbance path |
| M6 LQR | costo fisicamente normalizzato, rhoU 8 | CARE, stabilità, separazione e tracking |
| M6 Kalman | σd=σu=0.1 N m, σy=0.05° | stabilità dello stimatore e rapporto di velocità 1.693 |
| M7 | tre verifiche manuali LQI | tutte stabili e con offset nullo; nessuna conforme insieme a Ts e overshoot |

Le ricerche cartesiane, le classifiche e le funzioni di selezione automatica M3–M7 sono state rimosse. I test verificano il comportamento matematico pubblico e l'assenza dei moduli obsoleti.

## Esiti tecnici principali

| Milestone | Stato | Evidenza sintetica |
| --- | --- | --- |
| M1–M5 | `PASS` | modello, equilibrio, linearizzazione, attuatori, unico M4, specifiche e pesi verificati |
| M6 | `PASS` | LQG nominale ordine 14; worst Ts 0.776 s; peak u/uScale 0.3908 |
| M7 | `PARTIAL` | tre prove manuali; offset da disturbo annullato, ma 0/3 conformi a settling e overshoot |
| M8 | `COMPLETE` | validazione non lineare M6 e RAS empirica |
| M9–M11 | `PARTIAL` | sintesi H∞ corrette come metodo, obiettivi pesati maggiori di uno |
| M12 A5 | `PARTIAL` | NS PASS, NP FAIL, RS `[0.849720, 0.859945]` FAIL_CERTIFIED, RP FAIL_CERTIFIED |
| M13 Kmu | `COMPLETE` | artifact congelato, ordine 52; nessuna nuova `musyn` |
| M14 Kmu | `PARTIAL` | NS PASS, NP FAIL, RS `[1.069561,1.212875]` PASS_CERTIFIED, RP FAIL_CERTIFIED |
| M15 | `PARTIAL` | Khinf/Kmu stabili nominalmente ma tracking M5 fallito; RAS empiriche |
| M16 | `COMPLETE` empirico | M6 39/40, Khinf 40/40, Kmu 40/40; Sample 5 M6 instabile |
| M17 | `COMPLETE` | Kmu robusto finale, M6 riferimento nominale, Khinf comparatore H∞ |
| M18 | `COMPLETE` | tracciabilità, relazione e presentazione compilate e auditate |

## Interpretazione conclusiva

Kmu resta il controllore robusto finale perché M14 certifica la Robust Stability sull'M4 corrente. Questa proprietà non cancella NP, RP e tracking falliti. M6 resta il riferimento nominale, ma non possiede un certificato RS e perde stabilità nel Sample 5 M16. Khinf resta il comparatore full-order H∞.

Le frazioni 39/40 e 40/40 non sono probabilità fisiche. La certificazione RS deriva soltanto dalla μ-analysis M14. `uScale=12 N m` è una normalizzazione di prestazione, non una saturazione hardware.

## Quality gate conclusivo

- [x] refactoring M3–M7 e propagazione M12–M17;
- [x] controllori M6/Khinf/Kmu invariati;
- [x] M12, M14, M16 e M17 rigenerati sull'M4 corrente;
- [x] artifact obsoleti rimossi e recuperabili mediante Git;
- [x] suite MATLAB completa: 590/590 PASS;
- [x] `run_all` M0–M18: PASS, exit code 0;
- [x] Code Analyzer: 38 file modificati/creati, 0 segnalazioni;
- [x] `git diff --check`: PASS;
- [x] audit lessicale del codice e della documentazione corrente: PASS;
- [x] relazione: 41 pagine, audit LaTeX PASS, ispezione visiva PASS;
- [x] presentazione: 17 slide, audit LaTeX PASS, ispezione visiva PASS;
- [x] relazione A–P del refactoring prodotta.

Restano da completare manualmente soltanto le matricole degli autori e la data di consegna. Nessun commit, push, merge o apertura di pull request è stato eseguito automaticamente in questa revisione.
