# Roadmap tecnica

Ogni milestone termina con test, quality gate e aggiornamento di diario, changelog, decision log e project status. I nomi dei file previsti possono essere raffinati, mantenendo separazione delle responsabilità e riproducibilità.

| Milestone | Obiettivo | Input e file previsti | Implementazione | Test, output e criterio di accettazione | Dipendenze |
| --- | --- | --- | --- | --- | --- |
| **M0 — Setup** | Rendere fonti, ambienti e repository verificati | PDF, Drive, GitHub; `AGENTS.md`, `docs/*`, `run_all.m` | Inventario, governance, struttura e smoke test | Accessi reali, toolbox licenziati, test workspace PASS, commit M0 | Nessuna |
| **M1 — Modello non lineare** | Implementare la dinamica SEA a 8 stati | Traccia; `src/parameters/`, `src/model/` | Funzioni modulari per \(M,C,G\), coppia elastica e \(\dot x\) | Dimensioni, simmetria/positività di \(M\), unità, energia e assenza `NaN/Inf`; modello originale e testato | M0 approvata |
| **M2 — Equilibrio e linearizzazione** | Ottenere punto di lavoro e modello incrementale | M1; `analysis/nominal/`, `src/model/` | Scelta approvata dell'equilibrio, Jacobiani e sistema `ss` | Residuo equilibrio, differenze finite, poli, controllabilità/stabilizzabilità, osservabilità/rilevabilità e confronto NL/LTI PASS | M1 |
| **M3 — Attuatori** | Aggiungere secondo ordine e ritardo Padé | M2; `src/actuators/` | Parametri approvati, modello SISO/MIMO e cascata con la meccanica | Guadagno statico, poli, risposta al gradino, ordine e confronto ritardo/Padé; dataset nominale rigenerabile | M2 |
| **M4 — Incertezze** | Costruire una famiglia incerta fisicamente motivata | M3; `src/uncertainty/` | `ureal`, eventuale `ultidyn`/`ucover`, campioni e pianta `uss` | Blocchi, occorrenze, range, copertura di \(W_I\), nominal value e campioni validi | M3, decisioni sulle incertezze |
| **M5 — Specifiche e pesi** | Quantificare prestazioni e limiti | M4; `docs/DECISION_LOG.md`, `controllers/hinf/` | Definizione di uscite, disturbi, banda, errore, coppia e pesi | Coerenza dimensionale, fattibilità preliminare e grafici dei pesi; specifiche approvate | M4 |
| **M6 — LQG senza integratore** | Stabilizzare il modello nominale con stima di stato | M3, misure e covarianze; `controllers/lqg/` | LQR, Kalman e interconnessione esplicita | Stabilità, principio di separazione, rumore, condizioni iniziali e sforzo; controllore salvato | M2–M3, decisioni Q/R/W/V |
| **M7 — LQG con integratore** | Eliminare offset sulle uscite selezionate | M6; `controllers/lqg/` | Modello aumentato e anti-windup se necessario | Stabilità, errore a regime, confronto con M6, comando e saturazioni; entrambi i LQG validati | M6 |
| **M8 — Simulink e RAS LQG** | Validare LQG sul modello non lineare | M1, M6–M7; `simulink/`, `analysis/ras/` | Schemi lineare/NL, rumori, disturbi e ricerca automatica RAS | Criterio di convergenza, dominio e sezioni documentati; confronto con/senza integratore | M7 |
| **M9 — \(H_\infty\) `mixsyn`** | Sintetizzare mixed-sensitivity nominale | M3, M5; `controllers/hinf/` | Interconnessione 1-DoF e sintesi `mixsyn` | Stabilità, norma ricostruita, \(W_1S\), \(W_2KS\), tracking/disturbi/comando | M5 |
| **M10 — \(H_\infty\) `hinfsyn`** | Sintetizzare e confrontare una pianta generalizzata | M5, M9; `controllers/hinf/` | `connect`/`sumblk`, eventuale 2-DoF, `hinfsyn` | Stessa convenzione/scaling di M9, \(\gamma\), poli, canali e confronto equo | M9 |
| **M11 — `hinfstruct`** | Esplorare strutture implementabili | M5, M10; `controllers/hinf/` | PID/MIMO o `tunableSS`, ordini e partenze multiple | Stabilità di tutte le soluzioni candidate, specifiche pesate, ordine e variabilità tra start | M10 |
| **M12 — \(\mu\)-analysis di \(H_\infty\)** | Verificare NS, NP, RS e RP del controllore nominale | M4, controllore selezionato M9–M11; `analysis/robustness/` | `lftdata`, \(N\)-\(\Delta\), `mussv`, `robstab`, `robgain` | Struttura verificata, lower/upper bound coerenti, frequenze critiche e quattro esiti separati | M4, M10 |
| **M13 — D–K iteration** | Sintetizzare un controllore robusto | Pianta generalizzata incerta e pesi approvati; `controllers/mu/` | `musyn`, storico iterazioni e diagnostica | Stabilità nominale, ordine, convergence history; rilassamenti solo se approvati | M12 |
| **M14 — \(\mu\)-analysis finale** | Verificare a posteriori il controllore D–K | M13; `analysis/robustness/` | Stessa pipeline e scaling di M12 | NS/NP/RS/RP, margini e confronto ripetibile con \(H_\infty\) | M13 |
| **M15 — Validazione NL \(H_\infty\)/\(\mu\)** | Testare i robusti sul modello completo | M1, M10–M14; `simulink/`, `analysis/ras/` | Schemi non lineari, saturazioni, disturbi, rumore e RAS | Stabilità locale, transitori, comando, RAS empirica e regione di accordo LTI/NL | M14 |
| **M16 — Monte Carlo** | Valutare dispersione su campioni incerti | M4, controllori finali; `analysis/monte_carlo/` | `rng(seed)`, `usample`, simulazioni e metriche | Campioni riproducibili, stabilità, banda, assestamento, errore, disturbi e cross-coupling | M14–M15 |
| **M17 — Confronto complessivo** | Selezionare e motivare i controllori finali | Risultati M6–M16; `analysis/comparison/` | Tabelle e figure generate dal codice | Confronto nominale/robusto, lineare/NL, RAS, comando, complessità e limiti | M16 |
| **M18 — Relazione finale** | Produrre deliverable d'esame coerenti | Tutti i risultati validati; `report/`, `results/` | LaTeX, tabelle/figure importate dalla pipeline e revisione tracciabilità | `run_all` da workspace pulita, relazione compilata, numeri riconciliati, presentazione <=20 min | M17 |

## Regole di avanzamento

- Una milestone è `COMPLETE` solo quando tutti i criteri di accettazione applicabili sono `PASS`.
- Un `FAIL` critico impedisce l'avanzamento automatico.
- Un requisito non eseguito è `NOT RUN`, non `PASS`.
- Ogni output numerico deve essere rigenerabile da `run_all.m` o da una fase richiamata esplicitamente da esso.
- Dopo M0 è obbligatorio attendere l'autorizzazione del gruppo prima di iniziare M1.
