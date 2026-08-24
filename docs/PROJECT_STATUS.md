# Project Status

**Current milestone:** M1 — Modello non lineare del manipolatore SEA
**Status:** COMPLETE — quality gate M1 superato
**Last validated milestone:** M1
**Last validated result:** `run_all.m` eseguito in MATLAB R2025b Update 4; 9 test su 9 superati e validazione numerica M1 PASS
**Blocking issues:** nessuno per il completamento di M1
**Next task:** revisione e merge della Pull Request M1; non iniziare M2 senza il successivo incarico del gruppo
**Last update:** 2026-08-24 12:39 CEST

## Metriche M1 validate

| Metrica | Valore | Tolleranza / criterio |
| --- | ---: | ---: |
| Configurazioni inerzia | 2001 in \([-\pi,\pi]\) | campionamento deterministico |
| Minimo autovalore di \(M\) | 0.01904266522239113 a \(q_2=0\) rad | \(>10^{-12}\) |
| Massimo errore di simmetria di \(M\) | 0 | \(\le10^{-12}\) |
| Configurazioni Coriolis | 7 | deterministiche |
| Massimo residuo antisimmetria di \(\dot M-2C\) | \(4.906538933386797\times10^{-18}\) | \(\le10^{-12}\) |
| Configurazioni gravità / elasticità / RHS | 3 / 3 / 4 | deterministiche |
| Massimo errore formula gravità / elasticità | 0 / 0 | \(\le10^{-12}\) |
| Massimo errore cinematico RHS | 0 | \(\le10^{-12}\) |
| RHS senza `NaN`/`Inf` | 4 su 4 | tutti finiti |

## Quality gate M1

| Requisito | Esito |
| --- | --- |
| Implementazione derivata dalla traccia | PASS |
| Nessun codice del riferimento copiato | PASS |
| Parametri nominali centralizzati | PASS |
| Convenzione dello stato documentata | PASS |
| \(M(q)\) implementata, simmetrica e positiva nei test | PASS |
| Positività di \(M(q)\) giustificata anche analiticamente | PASS |
| \(C(q,\dot q)\) e proprietà di \(\dot M-2C\) verificate | PASS |
| \(G(q)\) ed elasticità SEA verificate | PASS |
| Dinamica completa a 8 stati | PASS |
| Assenza `NaN`/`Inf` nei casi documentati | PASS |
| Test indipendenti rispetto alle funzioni | PASS |
| `run_all.m` eseguito realmente | PASS |
| Documentazione e diario aggiornati | PASS |

## Limiti e problemi aperti

- Il campionamento numerico di \(M\) valida l'implementazione sul dominio scelto; la positività globale è sostenuta separatamente dalla derivazione analitica documentata.
- Non è ancora scelto alcun punto di equilibrio e non sono stati calcolati Jacobiani o modelli lineari.
- Dinamica esterna degli attuatori, ritardo, incertezze, controllori e Simulink restano fuori scope.
- M2 non è autorizzata da questo avanzamento e non è stata iniziata.
