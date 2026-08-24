# Project Status

**Current milestone:** M3 — Dinamica nominale degli attuatori e pianta completa
**Status:** COMPLETE — quality gate M3 superato
**Last validated milestone:** M3
**Last validated result:** run_all.m eseguito in MATLAB R2025b Update 4; 29 test top-level su 29 superati, regressioni annidate M0/M1/M2 PASS e validazioni M1/M2/M3 PASS
**Blocking issues:** nessuno per il completamento di M3
**Next task:** revisione e merge della Pull Request M3; non iniziare M4 senza il successivo incarico del gruppo
**Pull Request:** da associare dopo la pubblicazione del branch codex/m3-actuator-dynamics
**Last update:** 2026-08-24 CEST

## Scelta nominale M3

| Parametro | Valore | Stato |
| --- | ---: | --- |
| \(\omega_n\) | 40 rad/s | assunzione nominale progettuale |
| \(\zeta\) | 0.8 | assunzione nominale progettuale |
| \(\tau_d\) | 0.015 s | assunzione nominale progettuale |
| Ordine Padé | 1 | imposto dalla traccia |
| Canali | 2 identici e diagonali | simmetria nominale |

La scelta deriva da una griglia deterministica autonoma di 27 candidati. Non è un'identificazione sperimentale e non approva alcuna percentuale d'incertezza.

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
| Code Analyzer | 0 messaggi | 0 |

I ranghi grezzi di ctrb e obsv con tolleranza automatica sono 10/14 per il forte condizionamento (\(1.851\times10^{23}\) e \(2.477\times10^{19}\)). La normalizzazione temporale e i PBH su tutti i poli confermano che non si tratta di una perdita strutturale.

## Quality gate M3

| Requisito | Esito |
| --- | --- |
| main contenente M2 verificato e branch M3 dedicato | PASS — base f5800f2 |
| 27 candidati nominali analizzati autonomamente | PASS |
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
| Regressioni M0/M1/M2 e 29/29 test top-level | PASS |
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
