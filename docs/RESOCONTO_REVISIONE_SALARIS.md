# Revisione delle incertezze SEA - 24 ottobre 2026

Responsabile: Alessio. Branch `codex/revisione-focus-incertezze-salaris`, base
`origin/main` 0ed5611 (PR #42 integrata). Nessun merge su main.

## Esito complessivo

Implementazione e collaudo dei modelli/analisi: **COMPLETE / PASS**.
Accettazione scientifica dei nuovi candidati: **PARTIAL**. Le nuove
rappresentazioni e le sintesi sono proposte per la revisione degli studenti;
la banca consolidata e gli otto SLX sono conservati.

La relazione principale sostituisce il precedente percorso di 108 pagine,
centrando il confronto sulle incertezze. La presentazione comprende 18 slide;
la scaletta pianifica 18:34, con Alessio 8:50 e Valerio 9:10 di contenuti.
La durata reale richiede una prova cronometrata.

## Operazioni eseguite in ordine

1. Audit di traccia originale, mandato del ricevimento, regole, dati,
   controllori, modelli ed elaborati. Drive utilizzato soltanto in lettura.
2. LFT manuale di k1, k2 e Jm1 attraverso coppie interne; confronto con ureal.
3. LFT manuale dei due attuatori: wn ripetuta, zeta e tau reali separati,
   residuo dinamico del ritardo distinto e additivo.
4. Modello A con un blocco pieno 2x2, variante A diagonale e modello B.
   Maggiorazione analitica: B contenuto in A diagonale contenuto in A pieno.
5. Stessi sei controllori analizzati sulle tre famiglie; sintesi H-infinity
   nominale comune e due D-K A/B per tre livelli dinamici, con analisi incrociate.
6. Dieci impianti parametrici comuni per sei controllori e dieci condizioni
   iniziali per ciascuno, con confronto LIN/NL e soglia di scostamento.
7. Tre scelte Q/R, Kalman per 600 s, riduzioni 82/70/60 e verifica delle
   cancellazioni. Riduzioni controllate anche sulla famiglia storica M4.
8. Sei schemi TikZ, grafici MATLAB, tabelle dai CSV, relazione e orale rifocalizzati.
9. Cinque test nuovi inclusi in 39 regressioni PASS; Code Analyzer su 17 file,
   nessuna segnalazione. Integrità degli artifact originali controllata in Git.

## Risultati principali

- Stesso Kmu consolidato: margine RS inferiore 0.3500 su A pieno,
  0.3538 su A diagonale e 0.8795 su B. Nessuno dei tre raggiunge RS unitaria.
  Frequenze critiche circa 13.30, 13.07 e 63.64 rad/s.
- Nuova sintesi B, fattore dinamico 1: RS [1.30865, 1.44456]. Il requisito
  pesato unitario fallisce già al nominale, norma circa 2.53865.
  Con limite esplicitamente rilassato a 3, RP [1.29882, 1.40743].
  Banda nominale minima 1.57372 rad/s, Ts 2.405 s, errore DC massimo 37.716%.
  La garanzia rilassata non soddisfa i target temporali M5 (0.8 s, 5% DC).
- Nuova sintesi B, fattore 0.1: RS inferiore 1.53966 e RP a livello 3
  inferiore 1.53022; banda 0.154929 rad/s. Il rallentamento deriva dal
  cambiamento esplicito delle specifiche, non dal passaggio da B ad A.
- Nessuna sintesi A supera RS nei tre livelli e nel budget di quattro
  iterazioni. Non è una prova di impossibilità né una misura della banda
  robusta massima. Non viene forzata una perdita di una decade fra A e B.
- Due righe Hinf2 (A pieno/diagonale) hanno stime quantitative incompatibili
  con la monotonia degli insiemi: restano inconclusive. I dati grezzi sono
  conservati; la relazione usa n.i. e non li impiega per confrontare i modelli.
- Dieci impianti fisici: LQG 10/10, LQGI 10/10, Hinf1 6/10, Hinf2 0/10,
  PID 4/10, Kmu 10/10 stabili. Il residuo dinamico è nullo in questa prova:
  è campionamento parametrico, non una garanzia sull'intera famiglia.
- RAS: 52 convergenze, 5 prove completate senza convergenza e 3 esiti
  numerici ignoti su 60 tentativi. Convergenza e J <= 0.5 gradi sono entrambe
  rispettate in 24 punti. Nessuna certificazione matematica della RAS.
  Hinf2 ha un timeout; PID ha due timeout. Gli altri quattro controllori
  convergono nei dieci punti, ma non tutti i transitori rispettano la soglia.
- Kalman: varianza di q e covarianza di x-xhat confrontate con quantità
  teoriche omogenee, dopo 60 s di transitorio su 600 s. Scarto massimo delle
  quattro varianze articolari riportate circa 1.5%.
- Riduzione 82 -> 60: errore relativo H-infinity 2.424e-8; M4 mantiene
  RS [1.84535,1.88178], RP [1.59624,1.60043]. Banda, norme disturbo e
  rumore praticamente invariate. Su B, RS inferiore circa 0.9403 sia a 82
  sia a 60: il nuovo insieme resta privo di garanzia, indipendentemente
  dalla riduzione. Il controllore a 60 stati resta un candidato.
- minreal a tolleranza 1e-8 elimina un solo stato, con errore relativo
  7.469e-5. Non viene adottato al posto della riduzione bilanciata.

## File modificati o aggiunti

- `src/uncertainty/build_manual_mechanical_lft.m` e
  `src/actuators/build_manual_parametric_actuator.m`: costruzioni manuali.
- `analysis/uncertainty/build_salaris_models.m`, `run_salaris_revision.m`
  e funzioni `salaris_*.m`: confronto, sintesi, prove ed esportazione.
- `tests/salarisModelsTest.m`; `run_all.m`, nuovo scope esplicito `salaris`.
- `results/data/salaris_revision/`: MAT di modelli/controllori/analisi,
  campioni, traiettorie, CSV, esiti dei test e diagnostica.
- `report/figures/schemes/`: sei nuovi schemi riproducibili.
- `report/figures/salaris_revision/`: sette figure dai run MATLAB, inclusa
  una selezione RAS leggibile per l'orale.
- `report/main.tex`, `report/sections/salaris_revision.tex`,
  `report/generated/salaris_*.tex` e PDF principale.
- `presentation/main.tex`, PDF, copione, note e scaletta dei due studenti.
- `tools/build_salaris_documents.py`: genera le tabelle dai CSV.
- README, stato, changelog, diario e decisioni; audit e questo resoconto.

Le sezioni precedenti della relazione, i dati consolidati, i quattro script
accorpati e gli otto SLX non sono stati eliminati. La versione precedente
integrale degli elaborati è recuperabile dalla base Git 0ed5611.

## Tracciabilità e limiti

Le fonti numeriche sono i CSV della cartella dedicata. `final_tests.csv`
registra 39/39 PASS; `code_analyzer.json` contiene 17 file senza messaggi.
I gate LaTeX sono in `report/generated/report_latex_audit.txt` e
`presentation/generated/presentation_latex_audit.txt`.

Il primo avvio della campagna si fermava per errore servizi MathWorks 5201;
un nuovo avvio ha risolto il problema. Il primo test della LFT falliva per
un percorso relativo, corretto prima della validazione. Un primo tentativo
D-K con fattori DG pieni è stato interrotto per costo di calcolo; la campagna
accreditata usa scalature diagonali, identiche impostazioni A/B e parametri
reali nell'analisi mista. Nessun tentativo interrotto è dichiarato validato.

Il test storico M3 rigenera un MAT e tre figure: dopo il collaudo sono stati
ripristinati esattamente dalla base Git. Il nuovo runner usa il meccanismo
già esistente di conservazione/ripristino degli output per le future esecuzioni.

Restano agli studenti la revisione del branch, la scelta dei candidati e
il merge, oltre alla prova orale dal vivo. Prima di promuovere le nuove
sintesi A/B o il controllore ridotto al posto degli originali occorrono anche
le rispettive prove non lineari/Simulink: questa revisione non trasferisce
loro il collaudo degli SLX originali. Le coppie restano non saturate e non
sono disponibili limiti hardware identificati.

## Pubblicazione per revisione

PR in bozza: https://github.com/Deda-404/Progetto_CR/pull/43.
Tre commit scientifici/editoriali distinti: 558c3a1, 0bdc6e0, 13710df.
Main rimane alla base 0ed5611; nessun merge eseguito.

L'audit del copione conta 1503 parole di parlato su 18 slide. La scaletta
riserva 1080 s ai contenuti, inclusa la spiegazione dei diagrammi, e 34 s
ai cambi: 18:34 pianificati. Evidenza in oral_timing.json. Il manifest e gli
archivi in delivery/ si riferiscono al pacchetto storico del 13 ottobre;
questa revisione usa i sorgenti, i PDF e le evidenze correnti del branch.
