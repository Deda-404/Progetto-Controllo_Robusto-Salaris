# Revisione mirata LQI / H-infinity

Data: 2026-09-10. Responsabile: Alessio.
Ambito tecnico: §7.6, capitolo 8 e impaginazione.
Baseline: PR 27, commit 4ce6ad191ffcbf664d8fa0d4e82c81540ae52c46.

Nota di pubblicazione: la revisione tecnica è stata conclusa senza commit
o pubblicazione, come richiesto inizialmente. La successiva richiesta del
gruppo autorizza commit, push del branch e PR aperta verso main (D-0049),
senza merge. Gli esiti tecnici qui riportati restano invariati.

## 1. File modificati

52 file modificati o aggiunti; nessuna eliminazione. Percorsi relativi
alla radice del repository; esclusi log e render temporanei in results/tmp.

| File | Motivazione |
| --- | --- |
| `CHANGELOG.md` | Sintesi tecnica della revisione mirata. |
| `README.md` | Esecuzione separata, cache e limiti del nuovo studio. |
| `analysis/finalization/build_m18_figure_manifest.m` | Sei asset aggiunti; inventario tabellare su pagina dedicata. |
| `analysis/finalization/load_m18_validated_artifacts.m` | Carica le due nuove fonti analitiche senza sostituire la baseline. |
| `analysis/finalization/validate_m18_deliverables.m` | Censisce i due file tabellari esportati dalla cache. |
| `analysis/nominal/plot_lqi_hinf_revision.m` | Grafici e tabelle tracciabili dai MAT, senza sintesi. |
| `analysis/nominal/study_hinf_weights.m` | Campagna deterministica, diagnosi, norme e cinque campioni comuni. |
| `analysis/progetto_hinf.m` | Sezione 20 con tre pesi e verifiche, baseline delle sezioni precedenti preservata. |
| `analysis/progetto_lqg.m` | Rinvio esplicito allo script LQI a stato vero. |
| `analysis/progetto_lqi.m` | Modello aumentato, ARE/guadagni e confronto nominale sotto disturbo. |
| `docs/DECISION_LOG.md` | Decisione D-0048 e mancata adozione della nuova configurazione. |
| `docs/DIARIO_DI_BORDO.md` | Cronologia append-only, inclusi errori intermedi e test reali. |
| `docs/FINAL_DELIVERABLE_MANIFEST.md` | Inventario, conteggi e verifiche della consegna. |
| `docs/PROJECT_STATUS.md` | Stato corrente distinto dalla precedente revisione Lyapunov. |
| `docs/REVISIONE_MIRATA_LQI_HINF.md` | Resoconto verificabile in otto sezioni e inventario delle modifiche. |
| `report/Progetto_CR_Relazione_finale.pdf` | Relazione ricompilata con nuovi contenuti e impaginazione locale. |
| `report/figures/hinf_revision_sensitivity_envelopes.png` | Copia per la relazione: Valori singolari S/T e inviluppi 1/W1, 1/W3. |
| `report/figures/hinf_revision_tracking_control.png` | Copia per la relazione: Tracking e comandi del candidato illustrativo. |
| `report/figures/hinf_revision_weighted_channels.png` | Copia per la relazione: Tre norme frequenziali pesate e soglia unitaria. |
| `report/figures/hinf_revision_weights.png` | Copia per la relazione: Confronto leggibile dei pesi originali e rivisti. |
| `report/figures/m7_lqg_lqi_constant_disturbance.png` | Copia per la relazione: Offset LQG/LQI nei due casi di coppia costante. |
| `report/figures/m7_lqg_lqi_disturbance_control.png` | Copia per la relazione: Comandi nei medesimi esperimenti LQG/LQI. |
| `report/generated/figure_manifest.csv` | Inventario di 30 asset, inclusi sei nuovi. |
| `report/generated/figure_manifest.mat` | Stesso inventario in formato MATLAB. |
| `report/generated/figure_manifest.tex` | Inventario leggibile su una pagina, senza split longtable. |
| `report/generated/hinf_revision_results.tex` | Tabelle di campagna e confronto M10/ID10 da risultati reali. |
| `report/generated/lqi_revision_results.tex` | Matrici LQI e metriche dei disturbi da risultati reali. |
| `report/generated/report_latex_audit.txt` | Esito dell'ultima compilazione della relazione. |
| `report/main.tex` | Abstract coerente con lo studio separato e i suoi esiti negativi. |
| `report/sections/06_specifiche_pesi.tex` | Qualifica i pesi descritti come baseline, rinviando allo studio separato. |
| `report/sections/07_lqg.tex` | Sola §7.6 riscritta ed estesa; §7.1–7.5 preservate. |
| `report/sections/08_hinf.tex` | Audit, tre pesi, pianta/LFT, campagna e spiegazione didattica. |
| `report/sections/11_monte_carlo.tex` | Solo collocazione e larghezza della figura, numeri e testo invariati. |
| `report/sections/13_conclusioni_limiti.tex` | Aggiorna il futuro studio dei pesi alla luce del tentativo eseguito. |
| `report/sections/B_artifact_traceability.tex` | Provenienza delle nuove evidenze e inventario. |
| `report/sections/C_riproducibilita.tex` | Distingue replay storico, cache mirata e build della sola relazione. |
| `results/data/hinf_weight_revision.csv` | Metriche dei 14 casi, baseline inclusa. |
| `results/data/hinf_weight_revision.mat` | Campagna completa, piante campionate, controllori, norme e diagnosi. |
| `results/data/lqi_hinf_revision_verification.csv` | Esiti per ciascuno dei 644 test. |
| `results/data/lqi_hinf_revision_verification.mat` | Esito registrato dell'unica suite globale finale. |
| `results/data/m18_final_deliverable_audit.mat` | Audit aggiornato di fonti, tabelle e figure. |
| `results/data/m7_disturbance_comparison.csv` | Metriche dei quattro esperimenti sotto disturbo. |
| `results/data/m7_disturbance_comparison.mat` | Matrici, traiettorie, residui e metriche LQG/LQI. |
| `results/figures/hinf_revision_sensitivity_envelopes.png` | Figura numerica sorgente: Valori singolari S/T e inviluppi 1/W1, 1/W3. |
| `results/figures/hinf_revision_tracking_control.png` | Figura numerica sorgente: Tracking e comandi del candidato illustrativo. |
| `results/figures/hinf_revision_weighted_channels.png` | Figura numerica sorgente: Tre norme frequenziali pesate e soglia unitaria. |
| `results/figures/hinf_revision_weights.png` | Figura numerica sorgente: Confronto leggibile dei pesi originali e rivisti. |
| `results/figures/m7_lqg_lqi_constant_disturbance.png` | Figura numerica sorgente: Offset LQG/LQI nei due casi di coppia costante. |
| `results/figures/m7_lqg_lqi_disturbance_control.png` | Figura numerica sorgente: Comandi nei medesimi esperimenti LQG/LQI. |
| `tests/test_didactic_entry_points.m` | Estende metodi esistenti a LQI e problema H-infinity a tre pesi. |
| `tests/test_m18_final_deliverables.m` | Adegua i conteggi reali a 23 fonti, 19 file tabellari, 30 asset. |
| `tools/build_m18_latex.ps1` | Modalità ReportOnly e rilevamento degli ignored error LaTeX. |

## 2. Modifiche LQI

Si usa xi(t)=integrale_0^t (r-q) d tau e dot(xi)=r-Cq*x.
Il modello M3 ha 14 stati; l'aggiunta dei due integratori produce:

Aaug = [A, zeros(14,2); -Cq, zeros(2)], Baug = [B; zeros(2)],
Br = [zeros(14,2); eye(2)].

Il confronto riprende il punto M7 intermedio: wi=1, rhoU=8,
scala integrale qs*0.8=0.06981317008 rad s, Qi=205.175... I2,
Qaug=blkdiag(Q_M6,Qi), R=I2/18. Non è un nuovo controllore finale.
Si risolve l'ARE con lqr e si ricava Kaug=R^(-1)*Baug'*Paug;
Kx=Kaug(:,1:14), Ki=Kaug(:,15:16). Non si sceglie Ki a mano.

Guadagni arrotondati (valori completi in m7_disturbance_comparison.mat):

    Kx(:,1:7) =
      381.75   24.782  25.889  5.3979 -248.18 -18.735 -1.2107
       22.296 307.95    6.735  9.553    -6.014 -205.35 -0.88562

    Kx(:,8:14) =
      -1.2396 13.998 27.737 61.323 -1.0238 -2.6308 -16.996
       2.3461 -1.0238 -2.4981 -13.938 16.824 34.815 108.21

    Ki = [-60.707, 2.7917; -2.7917, -60.707]
    Nff = [89.441, 0.45133; 8.1751, 78.52]

La legge effettiva è u=-Kx*x-Ki*xi+Nff*r. M7 utilizza lo stato vero:
non è un LQG integrale con Kalman. LQG M6 ha invece 28 stati chiusi e
usa lo stato stimato. Sono verificati rango PBH a zero e Rosenbrock
entrambi pari a 16, residuo ARE relativo 1.2858e-13 e residuo del
guadagno 1.8532e-11. Tre verifiche a rhoU=16 fisso distinguono l'effetto
di wi dal contemporaneo cambio di R nei tre casi M7 originali.

Confronto su modello nominale lineare, r=0, x(0)=0, disturbo da t=0,
nessun rumore, tempo 0:0.002:8 s:

| Controllore | d [N m] | q1 DC [rad] | q2 DC [rad] | picco u [N m] | RMS u [N m] |
| --- | --- | ---: | ---: | ---: | ---: |
| LQG | [0.5;0] | 0.0724251 | -0.0283682 | 1.29317 | 0.787404 |
| LQG | [0;0.5] | -0.0272640 | 0.155869 | 1.15908 | 0.573655 |
| LQI | [0.5;0] | 0 | 0 | 0.871558 | 0.393515 |
| LQI | [0;0.5] | 0 | 0 | 1.13245 | 0.375585 |

RMS è aggregato su entrambi i canali e sugli stessi 8 s. Il massimo
residuo LQI a 8 s è 8.7316e-5 rad, distinto dallo zero asintotico.
Il confronto non dimostra equivalenza dei sensori o robustezza.
M7 resta PARTIAL: il punto intermedio supera OS=10% (16.585%) e non
si assesta entro l'orizzonte originale di 3 s; nessuno dei tre casi
rispetta contemporaneamente tutti i target M5. Saturazioni e anti-windup
non sono implementati.

## 3. Modifiche H-infinity

| Parametro | Originale | ID 10 illustrativo | Motivazione |
| --- | --- | --- | --- |
| W1 As, Ms | 0.05, 2 | invariati | Non si rilassano errore statico e parametro di picco |
| W1 omegaB | 12 rad/s | 16 rad/s | Terna interpretabile 8/12/16: estremo scelto dal criterio temporale |
| W2 scala DC | 1/12 | (5*pi/180)/12 | Requisito normalizzato a 5 gradi e 12 N m, esplicitamente meno restrittivo |
| W2 zero/polo | 30/180 rad/s | invariati | Stessa penalizzazione relativa del comando rapido |
| W3 | assente | (s/40+0.1)/(s/200+1) I2 | Roll-off nominale, DC 0.1 e HF 5; scelta progettuale dichiarata |

W1=(s/Ms+omegaB)/(s+omegaB*As) I2.
La mera trasformazione G_N=G*us/qs, K_N=K*qs/us NON riduce il gamma:
il vecchio problema trasformato in modo equivalente conserva 10.2071.
La nuova W2 cambia il requisito pesato, non è una correzione cosmetica
delle unità. W3 non è un requisito quantitativo del docente; M4 usa
incertezza moltiplicativa all'ingresso e richiede considerare Ti, non
certificare il sistema con W3*T di uscita.

Diagnosi: pianta instabile (4.0408, 7.2094 rad/s), ritardo Padé con zeri
RHP a 133.333 rad/s, due direzioni singolari molto diverse.
Con a=|W1|, b=|W2|, g=sigma_min(G), il limite puntuale necessario
a*b/sqrt(b^2+a^2*g^2) raggiunge 1.64496 a 5.7544 rad/s.
I pesi originali non possono quindi dare gamma<1; questa è una
condizione necessaria più debole del problema dinamico stabilizzante,
non una spiegazione quantitativa dell'intero gamma=10.2071.

Campagna finita: 12 triple (omegaB in 8/12/16, betaU in 1/2,
omegaT in 40/80) e un diagnostico senza W3. Aggiunte una conferma
hinfsyn sulla P esplicita e una sintesi solo-comando (gamma=0.4081,
senza requisito di tracking): 15 sintesi totali. Nessuna musyn.
Il criterio lessicografico è stabilità, eventuale gamma<1, numero di
violazioni temporali, massima violazione normalizzata, comando,
cross-coupling e infine gamma. ID 10 non è il minimo gamma.

La generalized plant normalizzata è 8x4:
P=[W1,-W1*Gn; 0,W2n; 0,W3*Gn; I,-Gn].
Sono verificati connect contro formula esplicita/augw, lower LFT contro
lo stack fisico, norme e stabilità della realizzazione completa.

## 4. Risultati H-infinity

| Metrica | M10 originale | ID 10 illustrativo |
| --- | ---: | ---: |
| gamma | 10.2071036 | 4.0729918 |
| norm W1S | 10.1276255 | 4.0702493 |
| norm W2KS | 10.1846919 | 4.0338581 |
| norm W3T | 0 (assente) | 2.5920687 |
| Ts [s] | 1.566 | 1.162 |
| Overshoot [%] | 261.619 | 144.440 |
| Errore statico relativo | 0.490679 | 0.201431 |
| Cross-coupling | 0.259598 | 0.199119 |
| Picco comando [N m] | 5.15985 | 15.68565 |
| RMS comando [N m] | 1.05170 | 1.19131 |
| Ordine controllore | 18 | 20 |
| Campioni M4 stabili | 5/5 | 2/5 |

Temporali: valori peggiori su due gradini da 5 gradi, 12 s, senza
disturbi/rumore. Ts usa una fascia pari al 2% del riferimento attorno
al valore DC effettivo; l'errore statico è verificato separatamente.
I gamma di problemi pesati diversi non sono una classifica di robustezza.

Il minimo gamma della campagna è 2.8056 (ID 3), comunque >1.
Tutti i 13 candidati sono nominalmente stabili ma nessuno rispetta
tutti i target M5. I cinque modelli M4 e i relativi poli sono salvati,
seed 20260910: controllo empirico limitato, non M16 e non certificazione.

Nessuna configurazione viene adottata nella baseline: M9/M10/M11/M12,
D–K M13, mu M14 e Monte Carlo M16 non vengono ricalcolati.
Questa separazione evita attribuzioni di certificati a controllori diversi.

## 5. Test e verifiche

- MATLAB R2025b tramite CLI: strumenti di sessione MATLAB non disponibili.
- Confronto LQI eseguito; test M7 esistenti: 7/7 PASS.
- Sezione 20 del codice didattico H-infinity eseguita isolatamente con
  cache, senza ripetere le sezioni Lyapunov invariate: PASS.
- Campagna, interconnessioni e norme: verifiche realmente eseguite.
- Code Analyzer: 172 file di progetto, 0 segnalazioni.
- Suite globale finale: **644/644 PASS**, zero failed/incomplete,
  **279.107 s**, eseguita una sola volta in copia locale isolata.
  Esiti per singolo test in results/data/lqi_hinf_revision_verification.mat
  e nell'omonimo CSV. I 188 file MATLAB della copia erano identici al
  working tree (inclusi esempi e riferimenti); il Code Analyzer riguarda
  i 172 file di progetto in analysis/controllers/src/tests e run_all.
- Relazione: 71 pagine, audit PASS, zero errori/overfull/riferimenti
  irrisolti/destinazioni duplicate. Tutte le pagine sono state renderizzate
  e ispezionate; nuovi grafici e matrici controllati anche a scala maggiore.
- Dopo la suite: sole rifiniture di float/caption e tacche frequenziali
  del grafico dei pesi. Rieseguito l'esportatore dalla cache e ricontrollato
  il relativo Code Analyzer; nessuna modifica a dati o algoritmi di sintesi.
- Nessun nuovo file di test: estesi test_didactic_entry_points e
  i conteggi di test_m18_final_deliverables.
- run_all, musyn e rigenerazione dei risultati robusti congelati: NOT RUN.

Il primo comando isolato H-infinity usava un nome di campo M3 errato:
corretto il solo comando di avvio, senza modifica del modello. Una
compilazione intermedia ha rilevato un underscore LaTeX non escapato
nell'appendice; corretto. Il manifest multipagina ha esposto un messaggio
di shrinkage nella versione longtable installata: l'inventario è stato
raggruppato in una tabella leggibile su pagina dedicata, e l'audit ora
intercetta anche gli "ignored error". Non si sopprimono errori per ottenere PASS.

## 6. Protezione del lavoro preesistente

Il controllo iniziale non rilevava modifiche non committate; il gruppo
ha chiarito che quelle ulteriori di Valerio non sono ancora pubblicate.
Non si può quindi dichiarare di aver integrato file non disponibili.

Il prefisso di 07_lqg.tex precedente alla sezione LQI è confrontato
testualmente con la copia iniziale, normalizzando soltanto CRLF/LF:
identico. Le parti Q/R, qs, CARE, Kalman e Lyapunov restano intatte.
Il backup diff iniziale è vuoto perché il working tree era pulito:
C:/tmp/pre_codex_manual_report_changes.patch.

Il test M7 ha rigenerato due MAT e una figura: il confronto ha verificato
identità del payload MAT dopo l'intestazione e identità dei pixel PNG.
Sono stati recuperati i quattro artefatti baseline originali (incluse
le due copie della figura), eliminando sole differenze di metadati.
Non sono stati usati checkout/reset sul working tree.

## 7. Limiti residui

- M7: reiezione nominale del disturbo ma nessun LQI finale conforme;
  la versione simulata usa lo stato vero.
- Studio H-infinity: nessun gamma<1, tracking M5 fallito e ID 10
  instabile in 3/5 campioni. Non è una soluzione finale implementabile.
- Nessun nuovo certificato robusto, identificazione sperimentale,
  saturazione o anti-windup.
- Le ampie spaziature ereditate nelle parti protette §7.1–7.5 non vengono
  corrette: il vincolo di non riformattarle prevale sulla compattazione.
  Le pagine sono state ispezionate e il limite non viene nascosto.
- Restano pagine di chiusura dei capitoli parzialmente occupate: non è
  stata forzata una compressione globale di testi, margini o grafici.
- Matricole e data di consegna restano da completare.
- Le modifiche future di Valerio richiederanno integrazione e verifica.

## 8. Git diff summary

Snapshot della chiusura tecnica, precedente alla richiesta di pubblicazione
e all'aggiornamento delle sole note Git. Non rappresenta lo stato remoto
successivo al push.

Ramo: codex/lqi-hinf-targeted-review.
Nessun commit/push/merge/PR. HEAD resta il commit baseline riportato sopra.
Main locale 6486bb240cdbcf4517ed1e893d83e6b1a34168e1;
origin/main 4ce6ad191ffcbf664d8fa0d4e82c81540ae52c46.
`git status --short`:

```text
 M CHANGELOG.md
 M README.md
 M analysis/finalization/build_m18_figure_manifest.m
 M analysis/finalization/load_m18_validated_artifacts.m
 M analysis/finalization/validate_m18_deliverables.m
 M analysis/progetto_hinf.m
 M analysis/progetto_lqg.m
 M docs/DECISION_LOG.md
 M docs/DIARIO_DI_BORDO.md
 M docs/FINAL_DELIVERABLE_MANIFEST.md
 M docs/PROJECT_STATUS.md
 M report/Progetto_CR_Relazione_finale.pdf
 M report/generated/figure_manifest.csv
 M report/generated/figure_manifest.mat
 M report/generated/figure_manifest.tex
 M report/generated/report_latex_audit.txt
 M report/main.tex
 M report/sections/06_specifiche_pesi.tex
 M report/sections/07_lqg.tex
 M report/sections/08_hinf.tex
 M report/sections/11_monte_carlo.tex
 M report/sections/13_conclusioni_limiti.tex
 M report/sections/B_artifact_traceability.tex
 M report/sections/C_riproducibilita.tex
 M results/data/m18_final_deliverable_audit.mat
 M tests/test_didactic_entry_points.m
 M tests/test_m18_final_deliverables.m
 M tools/build_m18_latex.ps1
?? analysis/nominal/plot_lqi_hinf_revision.m
?? analysis/nominal/study_hinf_weights.m
?? analysis/progetto_lqi.m
?? docs/REVISIONE_MIRATA_LQI_HINF.md
?? report/figures/hinf_revision_sensitivity_envelopes.png
?? report/figures/hinf_revision_tracking_control.png
?? report/figures/hinf_revision_weighted_channels.png
?? report/figures/hinf_revision_weights.png
?? report/figures/m7_lqg_lqi_constant_disturbance.png
?? report/figures/m7_lqg_lqi_disturbance_control.png
?? report/generated/hinf_revision_results.tex
?? report/generated/lqi_revision_results.tex
?? results/data/hinf_weight_revision.csv
?? results/data/hinf_weight_revision.mat
?? results/data/lqi_hinf_revision_verification.csv
?? results/data/lqi_hinf_revision_verification.mat
?? results/data/m7_disturbance_comparison.csv
?? results/data/m7_disturbance_comparison.mat
?? results/figures/hinf_revision_sensitivity_envelopes.png
?? results/figures/hinf_revision_tracking_control.png
?? results/figures/hinf_revision_weighted_channels.png
?? results/figures/hinf_revision_weights.png
?? results/figures/m7_lqg_lqi_constant_disturbance.png
?? results/figures/m7_lqg_lqi_disturbance_control.png
```

`git diff --stat` (soli file già tracciati; i nuovi sono elencati sopra):

```text
 CHANGELOG.md                                       |  14 +
 README.md                                          |  25 ++
 analysis/finalization/build_m18_figure_manifest.m  |  18 +-
 .../finalization/load_m18_validated_artifacts.m    |   6 +-
 analysis/finalization/validate_m18_deliverables.m  |   4 +
 analysis/progetto_hinf.m                           |  39 ++-
 analysis/progetto_lqg.m                            |   3 +
 docs/DECISION_LOG.md                               |  32 ++
 docs/DIARIO_DI_BORDO.md                            |  64 ++++
 docs/FINAL_DELIVERABLE_MANIFEST.md                 |  18 +-
 docs/PROJECT_STATUS.md                             |  39 ++-
 report/Progetto_CR_Relazione_finale.pdf            | Bin 2624356 -> 3334084 bytes
 report/generated/figure_manifest.csv               |   6 +
 report/generated/figure_manifest.mat               | Bin 3166 -> 3747 bytes
 report/generated/figure_manifest.tex               |  17 +-
 report/generated/report_latex_audit.txt            |   2 +-
 report/main.tex                                    |   5 +
 report/sections/06_specifiche_pesi.tex             |   5 +-
 report/sections/07_lqg.tex                         | 206 ++++++++++-
 report/sections/08_hinf.tex                        | 377 ++++++++++++++++++---
 report/sections/11_monte_carlo.tex                 |   4 +-
 report/sections/13_conclusioni_limiti.tex          |   6 +-
 report/sections/B_artifact_traceability.tex        |  10 +
 report/sections/C_riproducibilita.tex              |  23 +-
 results/data/m18_final_deliverable_audit.mat       | Bin 14870 -> 15492 bytes
 tests/test_didactic_entry_points.m                 |  14 +
 tests/test_m18_final_deliverables.m                |   6 +-
 tools/build_m18_latex.ps1                          |  19 +-
 28 files changed, 868 insertions(+), 94 deletions(-)
```

`git diff --check`: PASS. Nessun contenuto in staging. La suite isolata non
ha modificato il working tree della consegna. Gli ultimi ritocchi grafici
non hanno cambiato dati, controllori o gli esiti salvati.

SHA-256 della consegna PDF:
063f60a7b0119d91cc3a2749c2a9cf94df2d98ac84e4d5bd76e8c4309ab0bf87.
SHA-256 della presentazione invariata:
cff9fa87165afe5efd641a72f469d8afc5dcdb85a39913702a9afe71ed30e0c3.

## Fonti tecniche primarie consultate

- [MathWorks: mixsyn](https://www.mathworks.com/help/robust/ref/dynamicsystem.mixsyn.html)
  e [augw](https://www.mathworks.com/help/robust/ref/dynamicsystem.augw.html):
  convenzioni dei tre canali; i risultati numerici provengono dal progetto.
- [LaTeX Project, issue 1907](https://github.com/latex3/latex2e/issues/1907):
  messaggio longtable osservato durante la compilazione.
