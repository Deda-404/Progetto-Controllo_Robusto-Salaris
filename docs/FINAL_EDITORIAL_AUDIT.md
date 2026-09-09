# Audit editoriale e strutturale conclusivo

> Documento storico della revisione integrata nella PR 26 (47 pagine, 17 slide). Per la revisione tecnica corrente di Lyapunov, Q/R e Kalman si vedano `PROJECT_STATUS.md` e `REVISIONE_TECNICA_LYAPUNOV.md`. I test e i conteggi sottostanti non sono quelli della revisione dell'8 settembre 2026.

## Perimetro

La revisione corrente è stata eseguita sul ramo `codex/lqr-kalman-hinf-ras-didactic-rework` per rendere il progetto coerente con una metodologia universitaria leggibile: scelta ingegneristica, motivazione, verifica MATLAB ed eventuale correzione. È stato usato come riferimento anche lo stato storico precedente, senza copiarne automaticamente le scelte numeriche.

Specifiche e pesi M5, Khinf M10 e Kmu M13 sono rimasti congelati. È stata eseguita esclusivamente la ricerca LQR compatta richiesta per aggiornare M6; dopo la selezione LQR30 non sono state aperte nuove iterazioni di retuning. M13 ha ricaricato l'artifact approvato senza chiamare nuovamente `musyn`.

## Revisione del codice

- M0–M5 sono presentati come una sola macrofase sequenziale, mantenendo separate le funzioni matematiche riutilizzabili.
- M3 usa la scelta diretta `wn=40 rad/s`, `zeta=0.8`, `delay=0.015 s`, Padé 1 e tre confronti manuali.
- M4 usa un solo insieme incerto: `k1`, `k2`, `Jm1`, `wn`, `zeta` a ±10% e ritardo a ±20%.
- M5 espone direttamente un solo set di specifiche e i pesi W1/W2, senza candidati o ranking.
- M6 confronta 36 costi LQR leggibili, applica prima i gate M5 e seleziona LQR30 fra 9 candidati ammissibili; il filtro di Kalman conserva un modello di covarianza fisicamente motivato e una sensibilità a tre livelli di rumore encoder.
- M7 è una verifica didattica di tre punti LQI, senza selettore automatico.
- Sono stati rimossi 11 moduli di screening, griglia, ranking o selezione e 9 artifact che li rappresentavano. I file eliminati restano recuperabili mediante Git.
- I test M3–M7 sono stati riscritti per verificare proprietà matematiche pubbliche e assenza dell'infrastruttura obsoleta.

## Propagazione robusta

La profondità di Controllo Robusto è stata mantenuta: modello `ureal`, `usample`, mixed sensitivity, H∞, generalized plant, μ-analysis, D–K synthesis congelata, Robust Stability, Robust Performance, validazione non lineare e Monte Carlo.

Gli esiti correnti sono:

- M12 A5: NS PASS, NP FAIL, RS FAIL_CERTIFIED con margine `[0.849720, 0.859945]`, RP FAIL_CERTIFIED;
- M13 Kmu: artifact congelato, ordine 52, objective storico `10.4032233618`;
- M14 Kmu: NS PASS, NP FAIL, RS PASS_CERTIFIED con margine `[1.069561, 1.212875]`, RP FAIL_CERTIFIED;
- M16, seed `20260826`: stabilità empirica M6/Khinf/Kmu `38/40`, `40/40`, `40/40`; Sample 5 e 6 M6 instabili;
- M17: Kmu controllore robusto finale, M6 riferimento nominale, Khinf comparatore H∞.

La Monte Carlo M16 resta evidenza empirica lineare e non è presentata come certificazione né come sostituto della μ-analysis M14.

## Relazione e presentazione

La relazione è stata ampliata soprattutto nei capitoli su attuatori, incertezze, specifiche, pesi, LQR/LQI, Kalman/LQG e distinzione fra sintesi M13 e certificazione M14. Gli esiti negativi NP, RP, tracking e M7 restano visibili e interpretati.

La presentazione conserva 17 slide e distingue correttamente il ruolo storico della D–K synthesis M13 dalla post-analisi M14. Tabelle, macro e figure sono state rigenerate dall'insieme M4 corrente.

## Quality gate

- suite MATLAB standalone: **599/599 PASS**, 0 failed, 0 incomplete;
- `run_all` M0–M18: **PASS**, exit code 0;
- M13: artifact ricaricato, nessuna nuova `musyn`;
- Code Analyzer: **162 file, 0 segnalazioni**;
- `git diff --check`: **PASS**;
- audit lessicale del codice e della documentazione corrente: **PASS**;
- relazione: **47 pagine**, audit LaTeX con 0 errori, riferimenti irrisolti, overflow e destinazioni duplicate;
- presentazione: **17 slide**, audit LaTeX con gli stessi conteggi tutti a zero;
- ispezione visiva completa e successivo controllo mirato delle pagine/slides aggiornate: **PASS**.

Il quality gate è **COMPLETE**: `run_all` M0–M18 ha terminato con exit code 0. Restano da inserire manualmente soltanto le matricole degli autori e la data di consegna.
