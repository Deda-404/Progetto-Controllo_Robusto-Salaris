# LQRI M7: LQR con integratore e osservatore di Kalman

Data della revisione: 2026-09-14. Responsabile: Alessio.

## Ambito e correzione architetturale

M7 realizza un servo con azione integrale e stato stimato. La precedente
retroazione ideale dello stato fisico è rimossa dal flusso attivo. Le
analisi robuste e non lineari successive restano riferite ai controllori
già validati e non vengono estese implicitamente alla nuova LQRI.

Le misure disponibili sono le quattro posizioni encoder incrementali
\(y=Cx+v=[q^T,\theta^T]^T+v\). Con \(E_q=[I_2\ 0]\), si implementa

\[
\dot\xi=r-E_qy,\qquad
\dot{\hat x}=A\hat x+Bu+L(y-C\hat x),\qquad
u=-K_x\hat x-K_i\xi.
\]

Kalman stima soltanto i 14 stati fisici. I due stati integrali sono
memorie interne del controllore, calcolate direttamente dalle misure.
Non si usa \(r-C_q\hat x\) e non si introduce un prefiltro in M7.
Il controllore autonomo ha ordine 16; pianta e controllore insieme
hanno 30 stati. La LQG M6 conserva invece \(u=-K\hat x+N_rr\).

## Sintesi aumentata e costo

Il modello per il progetto è \(x_a=[x^T,\xi^T]^T\), con

\[
A_a=\begin{bmatrix}A&0\\-C_q&0\end{bmatrix},\quad
B_a=\begin{bmatrix}B\\0\end{bmatrix},\quad
B_r=\begin{bmatrix}0\\I_2\end{bmatrix}.
\]

Si conserva esattamente Q di M6 e si usa

\[
J=\int_0^\infty(x_a^TQ_ax_a+u^TRu)\,dt,\quad
Q_a=\operatorname{blkdiag}(Q,Q_i),\quad
Q_i=\frac{w_i}{s_\xi^2}I_2,\quad R=r_uI_2.
\]

La scala già giustificata \(s_\xi=(5\pi/180)\,0.8\) rad s viene conservata
per mantenere il significato dei valori disponibili di wi, senza aprire
una nuova ricerca di costo. Corrisponde all'accumulo dell'errore nominale
per il tempo target, non a un limite hardware.

Le tre prove usano wi = 0.1, 1, 4 con Q e R=(1/9)I2 fissi. Il punto
illustrativo wi=1 è dichiarato prima della valutazione, non selezionato
per ottenere un PASS. Un wi maggiore penalizza maggiormente l'accumulo,
con possibili effetti su rapidità, comando e sovraelongazione; non esiste
una monotonia universale di ogni guadagno o polo in un sistema MIMO.

La soluzione stabilizzante della CARE soddisfa

\[
A_a^TP_a+P_aA_a-P_aB_aR^{-1}B_a^TP_a+Q_a=0,\qquad
[K_x\ K_i]=R^{-1}B_a^TP_a.
\]

Kx (2x14) e Ki (2x2) derivano dalla stessa ottimizzazione. Ki non è
assegnato manualmente. Il segno della legge resta coerente con
xi_dot=r-q_measured. Il test PBH e la matrice di Rosenbrock all'origine
hanno rango 16 sul modello nominale.

## Osservatore invariato e chiusura completa

L (14x4), Qn e Rn sono caricati direttamente dall'artifact M6. Non sono
modificati per migliorare la prestazione M7 e xi non viene aggiunto
allo stimatore. Nelle coordinate z=[x;xi;xhat]:

\[
A_{\rm cl}=\begin{bmatrix}
A&-BK_i&-BK_x\\
-C_q&0&0\\
LC&-BK_i&A-BK_x-LC
\end{bmatrix},\quad
B_{\rm cl}=\begin{bmatrix}
0&B_d&0\\I_2&0&-E_q\\0&0&L
\end{bmatrix}.
\]

Gli ingressi sono [r;d;v]. Il termine -Eq*v è essenziale: l'integratore
accumula l'errore misurato. Con ex=x-xhat, la trasformazione produce

\[
\begin{bmatrix}
A-BK_x&-BK_i&BK_x\\
-C_q&0&0\\
0&0&A-LC
\end{bmatrix}.
\]

Sono costruite e confrontate entrambe le matrici. La verifica comprende
tutti i 30 poli e l'unione degli spettri del regolatore aumentato e
dell'osservatore, senza riduzione tramite cancellazioni.

Per wi=1 e ru=1/9 il residuo relativo CARE è circa 4.56824e-13,
quello della trasformazione è circa 2.10043e-13; la parte reale dominante
è -0.830657 s^-1. I valori completi sono nei MAT e nel resoconto finale.

## Esperimenti e lettura corretta degli esiti

Si confrontano M6 e M7 sul medesimo nominale, con pianta e osservatore
inizializzati a zero, xi(0)=0, rumore nullo, passo 0.002 s e durata 8 s:

- due gradini separati di riferimento da 5 gradi;
- due disturbi separati da 0.5 N m ai link, con riferimento nullo;
- entrambe le coppie e la memoria integrale.

L'offset DC viene calcolato dall'equilibrio della chiusura, non
identificato con l'ultimo campione della simulazione. La prova indipendente
tramite expm controlla la coerenza della simulazione e la reiezione a 20 s
del punto wi=1, oltre 16 costanti di tempo del suo modo dominante.

Il principio del modello interno implica errore statico nullo solo per
una chiusura stabile con equilibrio compatibile e comando realizzabile.
Il contributo integrale permanente consente di compensare il disturbo:
l'errore non scompare senza una corrispondente coppia di controllo.

| wi | ru | Settling peggiore su 8 s | Overshoot | Esito M5 |
| ---: | ---: | ---: | ---: | --- |
| 0.1 | 1/9 | non raggiunto entro 8 s | 0% | FAIL |
| 1 | 1/9 | 4.996 s | 0% | FAIL |
| 4 | 1/9 | 2.616 s | 0% | FAIL |

Tutti i punti sono nominalmente stabili e hanno offset DC numericamente
nullo, ma nessuno rispetta il target di settling 0.8 s. M7 resta PARTIAL,
pur implementando correttamente l'architettura richiesta. Non si sostituisce
il riferimento di prestazione nominale M6.

## Riproduzione e tracciabilità

- Parametri: src/parameters/lqg_specs_m7.m.
- Riccati: controllers/lqg/build_lqri_augmented_cost.m.
- Chiusura: analysis/nominal/evaluate_lqri_candidate.m.
- Validazione: analysis/nominal/validate_m7_lqg_integral.m.
- Percorso didattico: analysis/progetto_lqri.m.
- Confronto e documenti: analysis/nominal/plot_lqri_revision.m.
- Artifact: m7_augmented_cost_feasibility.mat, m7_lqg_integral.mat,
  m7_disturbance_comparison.mat/.csv, m7_lqri_tracking_comparison.csv.
- Test indipendenti: tests/test_m7_lqg_integral.m.
- Esiti della revisione: lqri_r_verification.mat/.csv.

run_all con CR_RUN_SCOPE=lqri esegue soltanto la revisione e le suite
coinvolte. Il percorso completo storico rimane disponibile con variabile
vuota; gli esiti dei due percorsi non sono intercambiabili.

## Limiti

La verifica è nominale e lineare. Non comprende robustezza M4, nuova
campagna Monte Carlo, RAS, validazione non lineare LQRI, saturazioni o
anti-windup. Un bias encoder può azzerare l'errore misurato lasciando
errore fisico; con saturazione può verificarsi windup. Gli esiti
M8-M16 precedenti non costituiscono validazione di questa architettura.
