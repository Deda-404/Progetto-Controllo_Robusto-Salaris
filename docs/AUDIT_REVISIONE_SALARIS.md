# Audit mirato del 24 ottobre 2026

Responsabile: Alessio. Base: `origin/main` 0ed5611, dopo PR #42.
Branch: `codex/revisione-focus-incertezze-salaris`.

## Fonti

La traccia originale è stata riletta integralmente attraverso Google Drive in
sola lettura: [Traccia 2 - Manipolatore SEA](https://drive.google.com/file/d/1-oXYqX_l1EJ7Tsd0Lubur3a1zqEi7ro7/view).
Le indicazioni del ricevimento sono quelle allegate al mandato di revisione
(22 ottobre). Non è stato individuato un ulteriore documento autonomo con titolo
«Correzioni del prof. Salaris». Non si attribuiscono al docente requisiti ulteriori.

Sono stati esaminati AGENTS.md, stato e decisioni, i quattro script accorpati,
le funzioni meccaniche, gli attuatori, le incertezze M4, le interconnessioni
H-infinity e mu, i dati consolidati, relazione e presentazione. Gli otto SLX
rimangono quelli già collaudati in R2026b: non servono modifiche ai blocchi per
costruire il confronto lineare fra famiglie di incertezza.

## Esito e riuso

| Parte | Situazione iniziale | Intervento pertinente |
|---|---|---|
| Meccanica SEA ed equilibrio | Modello e Jacobiani verificati | Conservati; aggiunta LFT manuale di k1, k2, Jm1 |
| Parametri incerti | k1, k2, Jm1 ±10%; attuatori 10/10/20% | Intervalli e motivazioni conservati |
| Attuatori M4 | Due blocchi dinamici SISO moltiplicativi | Conservati come baseline; nuovi modelli A/B separati |
| Residuo Padé | Inviluppo frequenziale inglobato nel peso | Distinto dal ritardo reale; residuo additivo stabile |
| LFT automatica | Già disponibile attraverso lftdata | Confronto ingresso-uscita con due costruzioni manuali |
| Controllori | LQG, LQGI, Hinf 1/2 DoF, PID, mu | Nessuna riscrittura; stessa banca per A e B |
| Sintesi robusta | Una famiglia soltanto | D-K A/B, pesi comuni e rilassamenti dichiarati |
| RAS | Griglie e Lyapunov molto articolati | Dieci punti, confronto LIN/NL e indice J distinto dalla convergenza |
| Campionamento | Dieci impianti dinamici già disponibili | Dieci nuovi campioni fisici comuni; residuo nullo dichiarato |
| Kalman | Intensità continue e rumore ZOH distinti | Covarianza teorica/empirica sullo stesso processo continuo |
| Ordine mu | Baseline 78 e candidato rumoroso 82 | Candidato 82 conservato; prove a 70 e 60 |
| Elaborati | 108 pagine e 23 slide | Percorso principale riscritto intorno alle incertezze; fonti precedenti conservate |

## Correzione concettuale sul ritardo

Il Padé1 ha uno zero in +2/tau. Il rapporto fra ritardo esatto e Padé1 ha
quindi un polo nel semipiano destro: una copertura del modulo lungo l'asse
immaginario non dimostra l'appartenenza a un blocco `ultidyn` stabile.
I vecchi certificati restano validi per la famiglia razionale M4 dichiarata;
non diventano automaticamente certificati per tutti i ritardi esatti.
La nuova famiglia B usa `H(p)*(Dp(tau)+Wres*Dres)`.

Riferimenti di sintassi: documentazione MathWorks
[lftdata](https://www.mathworks.com/help/robust/ref/inputoutputmodel.lftdata.html) e
[Padé](https://www.mathworks.com/help/control/ref/dynamicsystem.pade.html).
La derivazione e la scelta dei nuovi pesi sono sviluppate nei sorgenti del
progetto, non importate dal materiale dei colleghi.

## Gate iniziali

Modelli manuali: COMPLETE / PASS, 5/5 test effettivamente eseguiti R2026b.
Il primo test falliva per un percorso relativo durante `runtests`; corretto
usando la radice ricavata da `mfilename`, quindi ripetuto con successo.
Primo avvio della campagna: NOT RUN per errore servizi MathWorks 5201;
il log iniziale è conservato durante il collaudo. I risultati successivi
sono registrati separatamente nel resoconto finale e nei CSV della revisione.

Le nuove rappresentazioni e i candidati restano proposte per la revisione
degli studenti nel branch: nessuna sostituzione della baseline né merge.
