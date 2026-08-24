# Project Status

**Current milestone:** M3.1 — Correzione metodologica della selezione attuatore
**Status:** COMPLETE — selezione da metriche e quality gate M3.1 superati
**Last validated milestone:** M3.1
**Last validated result:** run_all.m eseguito in MATLAB R2025b Update 4; 34 test top-level su 34 superati, regressioni annidate M0/M1/M2 PASS, selezione C14 indipendente e validazioni M1/M2/M3 PASS
**Blocking issues:** nessuno per il completamento di M3.1
**Next task:** revisione e merge della Pull Request M3.1; non iniziare M4 senza il successivo incarico del gruppo
**Pull Request:** da associare dopo la pubblicazione del branch codex/m3-actuator-selection-fix
**Last update:** 2026-08-24 15:43 CEST

## Scelta nominale M3

| Parametro | Valore | Stato |
| --- | ---: | --- |
| \(\omega_n\) | 40 rad/s | assunzione nominale progettuale |
| \(\zeta\) | 0.8 | assunzione nominale progettuale |
| \(\tau_d\) | 0.015 s | assunzione nominale progettuale |
| Ordine Padé | 1 | imposto dalla traccia |
| Canali | 2 identici e diagonali | simmetria nominale |

La scelta deriva ora direttamente dalle metriche della griglia deterministica di 27 candidati. `select_nominal_actuator.m` non legge `actuator_params_nominal.m`; il confronto di consistenza avviene soltanto dopo la selezione. Non è un'identificazione sperimentale e non approva alcuna percentuale d'incertezza.

## Criteri e risultato M3.1

| Criterio | Valore | Origine |
| --- | ---: | --- |
| \(\lambda_{u,max}\) | 7.20943 rad/s | massimo modulo dei poli instabili M2 |
| \(\omega_{el,min}\) | 69.9543 rad/s | minimo modulo dei poli complessi M2 |
| Banda minima | 28.8377 rad/s | \(4\lambda_{u,max}\) |
| Banda massima | 41.9726 rad/s | \(0.60\omega_{el,min}\) |
| Overshoot massimo | 2% | criterio progettuale M3.1 |
| Errore fase Padé massimo a 80 rad/s | 10° | criterio progettuale M3.1 |
| Fascia di quasi-parità settling | 10% dal minimo ammissibile | tie-break progettuale M3.1 |

I coefficienti 4, 0.60 e 10% sono criteri progettuali, non requisiti della traccia. I candidati ammissibili sono C13, C14, C25 e C26. La preferenza per il ritardo maggiore nel gruppo in quasi-parità, seguita dal minor settling, seleziona C14: 40 rad/s, 0.8 e 15 ms. Il modello nominale M3 e D-0006 restano invariati.

## Metriche M3 validate

| Metrica | Valore | Criterio |
| --- | ---: | --- |
| Ordine attuatore SISO / blocco MIMO / pianta | 3 / 6 / 14 | esatto, senza cancellazioni |
| Dimensioni GfullMeas | 4×2, 14 stati | richieste dalla traccia |
| Guadagno statico attuatore | 1 | errore \(\le10^{-12}\) |
| Poli attuatore SISO | \(-32\pm24j\), \(-133.3333\) s⁻¹ | tutti stabili |
| Zero Padé RHP | \(+133.3333\) s⁻¹ | \(+2/\tau_d\) |
| Rise / settling / overshoot | 0.0626454 s / 0.109362 s / 1.47221% | calcolati |
| Banda attuatore | 34.7834 rad/s | calcolata |
| Errore fase Padé a 4.0408 / 7.2094 rad/s | 0.001063° / 0.006028° | calcolato |
| Errore fase Padé a 70 / 80 rad/s | 4.76162° / 6.82742° | calcolato |
| Errore massimo modulo del solo ritardo | \(2.220\times10^{-16}\) | \(\le10^{-12}\) |
| Equivalenza cascata esplicita/indipendente | errore assoluto e relativo 0 | \(\le10^{-9}\) |
| Poli completi stabili / instabili / marginali | 12 / 2 / 0 | nessun nuovo polo instabile |
| Controllabilità, tempo scalato | 14/14, cond \(3.594\times10^5\) | PBH all-mode PASS |
| Stabilizzabilità | PASS sui 2 modi instabili | PBH rango 14/14 |
| Osservabilità [q;theta], tempo scalato | 14/14, cond \(1.477\times10^2\) | PBH all-mode PASS |
| Rilevabilità [q;theta] | PASS sui 2 modi instabili | PBH rango 14/14 |
| Osservabilità informativa q | 14/14, cond \(2.933\times10^4\) | PBH all-mode PASS |
| Code Analyzer M3.1 | 0 messaggi | 0 |

I ranghi grezzi di ctrb e obsv con tolleranza automatica sono 10/14 per il forte condizionamento (\(1.851\times10^{23}\) e \(2.477\times10^{19}\)). La normalizzazione temporale e i PBH su tutti i poli confermano che non si tratta di una perdita strutturale.

## Quality gate M3.1

| Requisito | Esito |
| --- | --- |
| main contenente il merge M3 verificato | PASS — base c988d06 |
| 27 candidati nominali analizzati autonomamente | PASS |
| Selezione indipendente da `actuator_params_nominal.m` | PASS |
| Criteri derivati dai poli M2 e vincoli documentati | PASS |
| Ammissibili C13, C14, C25, C26 identificati | PASS |
| Tie-break deterministico e selezione C14 dalle metriche | PASS |
| Modello nominale e D-0006 confermati senza modifiche | PASS |
| Secondo ordine e guadagno statico verificati | PASS |
| Padé ordine 1, polo stabile e zero RHP verificati | PASS |
| Confronto ritardo esatto/Padé | PASS |
| Attuatore SISO ordine 3 e blocco MIMO ordine 6 | PASS |
| Pianta esplicita ordine 14, 2 ingressi, 4 misure | PASS |
| Convenzione [x_mech;x_act] e StateName verificati | PASS |
| Interconnessione indipendente con series | PASS |
| Poli completi classificati | PASS |
| Controllabilità/stabilizzabilità SVD e PBH | PASS |
| Osservabilità/rilevabilità SVD e PBH | PASS |
| Dataset M3 rigenerato | PASS |
| Tre figure M3 rigenerate e ispezionate | PASS |
| Regressioni M0/M1/M2 e 34/34 test top-level | PASS |
| run_all.m completo con exit code 0 | PASS |
| Ricostruzione indipendente e confronto reference-last | PASS |
| Documentazione, decisione e diario aggiornati | PASS |

## Limiti e problemi aperti

- I parametri attuativi non derivano da identificazione sperimentale.
- Padé ordine 1 sottostima progressivamente la perdita di fase del ritardo esatto verso e oltre 70–80 rad/s.
- I canali sono identici soltanto nel nominale; dispersione e dinamiche non modellate sono fuori scope M3.
- Le matrici strutturali grezze sono fortemente condizionate; le sintesi future dovranno mantenere scaling esplicito.
- Non sono ancora definiti incertezze, specifiche, limiti di coppia, pesi o controllori.
- M4 non è stata iniziata.
