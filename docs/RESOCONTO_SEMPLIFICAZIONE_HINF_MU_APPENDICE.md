# Revisione didattica H∞, µ e appendice MATLAB — 2 ottobre 2026

## A. Branch e fonti

Branch: `codex/semplificazione-hinf-mu-appendice`, creata da `origin/main`
al commit `8ca8e7e`. La PR #33 risulta già integrata nella base remota;
le precedenti voci datate che la indicano draft sono conservate come cronologia.
Il checkout iniziale `codex/simulink-integration` era pulito. Nessun merge
su main, force push, riscrittura della storia o eliminazione di branch.

Analizzati inventario del repository, traccia ufficiale documentata in
`docs/ANALISI_TRACCIA.md`, decisioni, sorgenti LaTeX/MATLAB, figure e dati
consolidati. La fonte numerica corrente è `results/data/hinf_final_coherent/`,
integrata dall'audit `results/data/organic_review/numeric_audit.json`.
Il [PDF dei colleghi](https://drive.google.com/file/d/1J8iR3OVwtfgoGvEJYXBkDfEc6TvHjl_W/view)
è stato consultato in sola lettura come riferimento espositivo; non sono
trasferiti testo, codice, pesi, numeri o risultati. Il nostro disturbo è una
coppia lato link, diversa dalla perturbazione additiva di uscita del riferimento.

## B. File modificati e aggiunti

| File | Intervento |
|---|---|
| `report/sections/08_hinf.tex` | Riscrittura progressiva di motivazione, pesi, sintesi e conclusioni H∞. |
| `report/sections/09_mu.tex` | Percorso dalle incertezze fisiche alla post-analisi di Kµ. |
| `report/figures/schemes/generalized_plant.tex` | Nuova figura TikZ a due pannelli: circuito fisico e blocco P con K esterno. |
| `report/figures/schemes/ndelta_didactic.tex` | Nuovo schema N–Delta con porte interne ed esterne distinte. |
| `report/main.tex` | Stile MATLAB con listings e inclusione dell'appendice D. |
| `report/sections/D_codici_matlab.tex` | Appendice generata con estratti letterali dei sorgenti. |
| `report/sections/C_riproducibilita.tex` | Comandi di rigenerazione dei nuovi contenuti. |
| `report/build_didactic_tables.py` | Tre tabelle costruite soltanto dai JSON salvati. |
| `report/build_matlab_appendix.py` | Selezione degli estratti e registrazione delle righe sorgenti. |
| `report/generated/didactic_{hinf_comparison,hinf_disturbance,mixsyn_hinfsyn}.tex` | Confronti nominali, disturbo e equivalenza 1-DoF. |
| `report/generated/matlab_appendix_sources.json` | Provenienza dei 27 estratti. |
| `report/generated/report_latex_audit.txt` | Audit della nuova compilazione. |
| `report/Progetto_CR_Relazione_finale.pdf` | Relazione completa di 74 pagine. |
| `docs/didactic_review/{matlab_checks.csv,verification.json}` | Evidenze della verifica corrente. |
| `README.md`, `CHANGELOG.md`, `docs/{DIARIO_DI_BORDO,DECISION_LOG,PROJECT_STATUS}.md` | Stato e registri aggiornati prima del commit. |
| Questo resoconto | Motivazioni, modifiche, incongruenze e verifica finale. |

I capitoli 1–7, le appendici A–B, la presentazione, tutti i sorgenti MATLAB,
i test, i dati scientifici, i controllori e gli SLX sono invariati rispetto
alla base. Gli audit delle consegne precedenti restano documenti storici.

## C. Capitolo 8

La §8.3 introduce prima la domanda sull'amplificazione peggiore, poi w, z,
Tzw e la norma. Spiega gamma e la soglia uno, distinguendo prestazione
pesata, target temporali e robustezza. Non deduce RS da gamma < 1.

La §8.4 parte dallo schema di controllo e introduce Mo (la lettera o nel
codice, equivalente al nome M0 della richiesta), qm e l'errore q−qm.
Mo definisce il transitorio desiderato nel costo; K riceve r e q. La nuova
figura rende visibili r, d, u, q, Mo, pesi, uscite ze/zu e le porte di P.
G e Gd condividono i 14 stati fisici; P raccoglie modello e obiettivi.

Le §8.5–8.7 presentano separatamente: mixsyn sul problema 1-DoF;
hinfsyn sullo stesso problema, poi sulla vera struttura 2-DoF;
hinfstruct sulle sei famiglie realmente provate. Sono riportate le chiamate
effettive, i numeri di porte e il segno u=Kr r+Ky q. I due canali condividono
gli stati. È spiegato anche il caso r=0 e l'effetto delle condizioni iniziali.

Il tuning è ridotto a quattro passaggi: profilo iniziale, scelta fra i 21
profili, separazione riferimento/feedback, confronto dei tre Mo. La §8.9
confronta soltanto controllori H∞ con prove comuni, separando tracking e
disturbo. Sono conservati assestamento non conforme, rumore molto amplificato,
RAS empirica limitata e verifica Lyapunov fallita. Nessuna nuova ricerca.

## D. Capitolo 9

Il percorso segue incertezze → Delta → N–Delta → µ → NS/NP/RS/RP → musyn
→ post-analisi. Prima delle formule sono spiegati k1, k2, Jm1 (10%), famiglia
attuativa, inviluppo WI e due dinamiche indipendenti. Delta contiene cinque
blocchi, non tutti i parametri del fit degli attuatori. N è 9×9.

La µ è spiegata come inverso della più piccola perturbazione strutturata
critica; i limiti e i margini hanno significati distinti. L'iterazione D/G–K
è descritta con passi concettuali; opzioni e formule estese sono in appendice.
Il confronto finale conserva H∞: RS negativa; Kµ: RS/RP positive nel modello
lineare incerto, ordine 78, requisiti temporali parziali. I 120 attuatori
del fit e i 40 impianti Monte Carlo sono distinti.

## E. Appendice MATLAB

Appendice D: 27 estratti, 210 righe, 13 sezioni. Inclusione diretta tramite
`lstinputlisting`, con file, intervallo e scopo; non sono script autonomi.
Le appendici A–C sono preservate. Sono selezionati parametri, equilibrio,
Jacobiani, attuatore, modello a 14 stati, ureal/ultidyn, LQR/Kalman/LQG,
LQRI, pesi, mixsyn/hinfsyn, Mo, interconnessione 2-DoF, partizione di K,
tunablePID2/tunableSS, pianta incerta, musyn, robstab/robgain, mussv storico,
campioni comuni, Monte Carlo e dinamica/integratore non lineare.
Il manifest elenca tutti i percorsi e le righe. Il testo indica inoltre
il punto d'ingresso della RAS senza riprodurre interi script di ricerca.

I frammenti sono scelti per collegare formule e implementazione, evitando
plotting/salvataggi ripetitivi. I dettagli LFT e del limite inferiore sono
spostati qui per non interrompere il filo dei capitoli.

## F. Incongruenze e distinzioni chiarite

- Campagne precedenti e campagna finale usano configurazioni diverse:
  esplicitate le fonti, senza sostituire i dati storici. L'ordine Kµ corrente
  è 78; quello 70 di M13 non descrive questo controllore.
- Il segno di Ky è già incorporato nel controllore: uniformati testo e schemi
  alla realizzazione, senza cambiare matrici o duplicare stati.
- Le chiamate reali sono robstab e robgain(CL,1), non robuststab/robustperf.
  Il mussv diretto su griglia appartiene alle analisi precedenti.
- Le norme 1-DoF e 2-DoF misurano obiettivi diversi; il confronto non viene
  presentato come miglioramento percentuale di gamma.
- L'intervallo RP di H∞ ha gli estremi invertiti: resta non validato, senza
  scambio artificiale. RP è esclusa logicamente dalla RS negativa.
- WI rappresenta incertezza, non un W3 prestazionale inesistente.
- Grafici e dati sono conservati; le nuove didascalie distinguono feedback,
  obiettivo completo, nominale/robusto e prove effettivamente eseguite.

## G. Validazione

Rigenerazione Python dei soli contenuti editoriali; idempotenza verificata.
Compilazione dalla radice:

```powershell
& .\tools\build_m18_latex.ps1 -ReportOnly
```

Il tool usa `latexmk -pdf -interaction=nonstopmode -halt-on-error
-file-line-error -jobname=Progetto_CR_Relazione_finale main.tex` nella cartella
report. Tre passaggi pdflatex nella compilazione finale; 74 pagine. Audit PASS:
zero errori, riferimenti irrisolti, overfull hbox/vbox o destinazioni duplicate.
Nessun warning LaTeX residuo nel passaggio finale. Il launcher Perl segnala
una locale C.UTF-8 non disponibile e usa la locale Windows italiana: non
influisce sul PDF. I warning sui riferimenti del primo passaggio sono risolti.

Nella prima bozza una `path` in didascalia ha impedito la compilazione:
corretta prima della build finale. La lettura delle pagine renderizzate ha
portato a separare frecce/testo in N–Delta e a mantenere ciascun listato su
una pagina. Controllati front matter (pagine PDF 3–7), capitoli 8–9 (38–56)
e appendice D (67–74), inclusi schemi, tabelle, grafici e riferimenti.

Verifica MATLAB R2025b con le tre suite esistenti:

```matlab
addpath(genpath('src'),genpath('controllers'),genpath('analysis'));
r=runtests({'tests/hinfFinalCoherenceTest.m', ...
            'tests/hinfFinalDownstreamTest.m','tests/organicReviewTest.m'});
assertSuccess(r);
```

20/20 PASS: 6 coerenza, 5 downstream, 9 revisione organica. Sono ricontrollati
mappe 2-DoF, norma/poli, incertezze, identità dei controllori, campioni,
due piccole simulazioni non lineari locali, LFT, esiti negativi e hash degli
originali. È un sottoinsieme dei 105 test della precedente revisione:
non una nuova suite globale o 20 test aggiunti. Nessuna sintesi, ricerca
robusta, Monte Carlo o RAS rilanciata. Controllo Git sull'integrità scientifica
e `git diff --check`: PASS. Dettagli e SHA-256 del PDF nel manifest corrente.

Controllo finale delle 24 domande della richiesta:

| Domande | Risposte esplicite |
|---|---|
| 1–5: motivo, norma, w/z, W1/W2 | §8.1–8.3 |
| 6–8: Mo, P, modello fisico | §8.4 e figura 8.2 |
| 9–11: mixsyn/hinfsyn e differenze | §8.5–8.6.1 |
| 12–14: 2-DoF, Kr/Ky, r=0 | §8.6.2–8.6.3 |
| 15–17: hinfstruct, risultati, limiti nominali | §8.7–8.9, §8.3 e apertura §9.1 |
| 18–21: parametri, Delta, N–Delta, µ | §9.1–9.4 |
| 22: NP/RS/RP | §9.5 |
| 23: D/G–K | §9.6 |
| 24: confronto finale | §8.9 e §9.7 |

Quality gate editoriale: **PASS / COMPLETE**. Conformità scientifica globale:
**PARTIAL**, conservando limiti Simulink e target prestazionali non raggiunti.

## H. Git

Il commit contiene soltanto la revisione documentale e le sue evidenze.
Hash definitivo e conferma del push sono riportati nel messaggio di consegna;
il commit è consultabile con `git log -1` sul
[branch dedicato](https://github.com/Deda-404/Progetto_CR/tree/codex/semplificazione-hinf-mu-appendice).
Nessun merge automatico su main.
