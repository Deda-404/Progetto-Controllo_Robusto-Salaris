# Project Status

**Current milestone:** M2 — Equilibrio, linearizzazione e analisi strutturale
**Status:** COMPLETE — quality gate M2 superato
**Last validated milestone:** M2
**Last validated result:** `run_all.m` eseguito in MATLAB R2025b Update 4; 18 test top-level su 18 superati, regressione M1 annidata 7/7 e validazioni M1/M2 PASS
**Blocking issues:** nessuno per il completamento di M2
**Next task:** revisione e merge della Pull Request M2; non iniziare M3 senza il successivo incarico del gruppo
**Pull Request:** da aprire sul branch `codex/m2-equilibrium-linearization`
**Last update:** 2026-08-24 13:38 CEST

## Metriche M2 validate

| Metrica | Valore | Tolleranza / criterio |
| --- | ---: | ---: |
| Norma residuo equilibrio | \(5.8387489976584098\times10^{-14}\) | \(\le10^{-10}\) |
| Dimensioni \(A,B\) | 8×8, 8×2 | finite |
| Errore Jacobiano A massimo / Frobenius | \(4.126\times10^{-8}\) / \(6.124\times10^{-8}\) | \(\le10^{-6}\) |
| Errore Jacobiano A relativo | \(6.423\times10^{-12}\) | \(\le10^{-9}\) |
| Errore Jacobiano B | 0 | \(\le10^{-10}\) |
| Poli stabili / instabili / marginali | 6 / 2 / 0 | instabilità rilevata |
| Massima parte reale | 7.20942861374 s⁻¹ | calcolata |
| Rango controllabilità | 8/8 | tolleranza SVD 0.25 |
| Stabilizzabilità PBH | PASS sui 2 modi instabili | rango 8/8 |
| Rango osservabilità `Cmeas` | 8/8 | tolleranza SVD 0.0078125 |
| Rilevabilità `Cmeas` PBH | PASS sui 2 modi instabili | rango 8/8 |
| Rango osservabilità `Cq` | 8/8 | tolleranza SVD 0.0009765625 |
| Errore locale LTI/NL | da \(1.109\times10^{-4}\) a \(1.782\times10^{-13}\) | monotono; ordine \(>1.5\) |
| Code Analyzer | 0 messaggi | 0 |

## Quality gate M2

| Requisito | Esito |
| --- | --- |
| `main` contenente M1 verificato | PASS — merge `85075d7` |
| Equilibrio derivato autonomamente e relazione generale verificata | PASS |
| \(\bar q=[\pi/2,0]^T\), \(\bar\theta\), \(\bar\tau\) e residuo verificati | PASS |
| Jacobiani simbolici \(A\) 8×8 e \(B\) 8×2 dal modello M1 | PASS |
| Confronto indipendente a differenze finite | PASS |
| Validazione locale LTI/non lineare | PASS |
| Poli e instabilità open-loop classificati | PASS |
| Controllabilità SVD e stabilizzabilità PBH | PASS |
| `Cmeas=[q;theta]` motivata, osservabile e rilevabile | PASS |
| `Cq=q` definita come uscita prestazionale | PASS |
| Dataset M2 rigenerato | PASS |
| Figura poli rigenerata e ispezionata | PASS |
| Test M0/M1/M2 e `run_all.m` completo | PASS |
| Ricostruzione indipendente e confronto reference-last | PASS |
| Documentazione e diario aggiornati | PASS |

## Limiti e problemi aperti

- Le matrici di controllabilità e osservabilità sono a rango pieno ma hanno condizionamento elevato; lo scaling dovrà essere considerato nelle sintesi.
- La verifica LTI/non lineare è locale e non costituisce una stima della RAS.
- La struttura riguarda solo il modello meccanico a otto stati; M3 dovrà aggiungere separatamente gli attuatori esterni dopo approvazione dei parametri.
- Ritardo, incertezze, specifiche e controllori restano fuori scope.
- M3 non è autorizzata da questo avanzamento e non è stata iniziata.
