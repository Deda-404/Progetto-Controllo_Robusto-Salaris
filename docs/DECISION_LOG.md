# Decision Log

Le proposte del progetto precedente non diventano decisioni del presente progetto senza revisione del gruppo. Ogni modifica futura aggiungerà una nuova voce senza riscrivere la storia.

## D-0001 — Governo delle fonti e della workspace

**Data:** 2026-08-24
**Milestone:** M0

### Problema

Separare chiaramente materiale di riferimento, area di lavoro e autorità delle fonti.

### Alternative

- lavorare direttamente sul Drive condiviso;
- duplicare risultati dei colleghi nel nuovo progetto;
- mantenere Drive in sola lettura e GitHub come unica source of truth.

### Scelta

Drive in sola lettura; repository `Deda-404/Progetto_CR` come unica area modificabile; traccia ufficiale prioritaria.

### Motivazione

Preservare integrità accademica, tracciabilità Git e riproducibilità senza alterare il riferimento.

### Conseguenze

Ogni risultato dovrà essere rigenerato dal nostro codice; nessun file verrà scritto sul Drive.

### Stato

**APPROVATA**

---

## P-0001 — Punto di equilibrio

**Data:** 2026-08-24
**Milestone:** M2

### Problema

Scegliere una configurazione significativa per linearizzazione e controllo.

### Alternative

- configurazione verticale superiore \([\pi/2,0]^T\);
- equilibrio con coppia gravitazionale non nulla;
- altra configurazione compatibile con gli obiettivi d'esame.

### Scelta

Valutare \(\bar q=[\pi/2,0]^T\) come candidato, senza renderlo definitivo.

### Motivazione

Il riferimento mostra che produce un equilibrio instabile a coppia nominale nulla, ma la nostra scelta deve essere verificata e approvata.

### Conseguenze

M2 dovrà confrontare almeno le implicazioni fisiche, numeriche e di controllo del candidato.

### Stato

**PROPOSTA / DA VALUTARE**

## P-0002 — Misure e uscite di controllo

**Data:** 2026-08-24
**Milestone:** M2/M5

### Problema

Definire sensori disponibili, uscite regolate e ingressi del controllore.

### Alternative

- misurare \(q\) soltanto;
- misurare \([q;\theta]\);
- includere velocità misurate o stimate.

### Scelta

Confrontare \(y=q\) e \(y=[q;\theta]\); privilegiare sensori di posizione se osservabilità e prestazioni lo consentono.

### Motivazione

Il riferimento usa entrambe le configurazioni in fasi diverse; serve una scelta coerente e implementabile.

### Conseguenze

Osservabilità, filtro di Kalman e piante generalizzate dipenderanno dalla scelta.

### Stato

**PROPOSTA / DA VALUTARE**

## P-0003 — Parametri nominali degli attuatori

**Data:** 2026-08-24
**Milestone:** M3

### Problema

Assegnare \(\omega_n\), \(\zeta\) e \(\tau_d\), lasciati liberi dalla traccia.

### Alternative

- valori del riferimento: 30 rad/s, 0.7, 20 ms;
- valori derivati da un attuatore documentato;
- studio parametrico e scelta per requisiti.

### Scelta

Usare i valori del riferimento soltanto come baseline da confrontare, non come parametri approvati.

### Motivazione

La dichiarazione di ragionevolezza deve essere supportata da fonti o analisi.

### Conseguenze

M3 deve documentare criteri e sensibilità prima di centralizzare i valori finali.

### Stato

**PROPOSTA / DA VALUTARE**

## P-0004 — Struttura delle incertezze e peso \(W_I\)

**Data:** 2026-08-24
**Milestone:** M4

### Problema

Scegliere pochi parametri fisicamente incerti e una rappresentazione della variabilità degli attuatori.

### Alternative

- \(m_2\), \(k_1\), \(k_2\) con percentuali 10%/5%/5%;
- diverso sottoinsieme dopo analisi di sensibilità;
- attuatori `ureal` strutturati;
- incertezza moltiplicativa `ultidyn` coperta da \(W_I\).

### Scelta

Confrontare i due modelli attuativi e selezionare parametri/percentuali soltanto dopo sensibilità e motivazione fisica.

### Motivazione

Il riferimento dimostra entrambe le tecniche ma non giustifica definitivamente tutti i range.

### Conseguenze

La struttura \(\Delta\), le garanzie \(\mu\) e l'ordine dei controllori dipenderanno dalla scelta.

### Stato

**PROPOSTA / DA VALUTARE**

## P-0005 — Pesi LQR \(Q,R\)

**Data:** 2026-08-24
**Milestone:** M6/M7

### Problema

Bilanciare errore di posizione, integrale e sforzo di controllo.

### Alternative

- baseline del riferimento \(Q_q=100I\), \(Q_i=500I\), \(R=\rho_RI\);
- regola di Bryson con scaling fisico;
- tuning sistematico su specifiche temporali e limiti.

### Scelta

Usare i valori del riferimento soltanto come caso di confronto e progettare una taratura nostra.

### Motivazione

I pesi devono essere collegati a grandezze ammissibili e risultati eseguiti.

### Conseguenze

Il confronto di \(\rho_R\) e l'impatto sulla RAS saranno testati soltanto dopo approvazione.

### Stato

**PROPOSTA / DA VALUTARE**

## P-0006 — Covarianze Kalman \(W,V\)

**Data:** 2026-08-24
**Milestone:** M6/M7

### Problema

Rappresentare rumore di processo e misura in modo dimensionalmente e fisicamente coerente.

### Alternative

- \(W=V=10^{-8}I\) come baseline del riferimento;
- covarianze differenziate per tipo di stato/sensore;
- valori derivati da specifiche sensori e disturbi equivalenti.

### Scelta

Non adottare la baseline uniforme senza caratterizzazione; definire canali di rumore espliciti.

### Motivazione

Un fattore comune arbitrario non documenta il rapporto di fiducia modello/misure.

### Conseguenze

M6 deve includere analisi di sensibilità e unità dei canali stocastici.

### Stato

**PROPOSTA / DA VALUTARE**

## P-0007 — Specifiche, \(W_1\), \(W_2\), banda e coppia

**Data:** 2026-08-24
**Milestone:** M5

### Problema

Tradurre precisione, rapidità e limiti attuativi in pesi \(H_\infty\).

### Alternative

- baseline del riferimento: errore 8%, banda 0.85 rad/s, \(M_{perf}=3\), limite 70 Nm;
- specifiche diverse derivate da requisiti fisici;
- più scenari con analisi di fattibilità.

### Scelta

Conservare la baseline esclusivamente come proposta da riprodurre e criticare; non approvare ancora \(W_1\), \(W_2\), banda, errore o limite di coppia.

### Motivazione

La traccia richiede scelte ragionevoli e motivate, non il riuso di valori altrui.

### Conseguenze

M5 deve verificare scaling dimensionale, saturazioni reali e fattibilità prima della sintesi.

### Stato

**PROPOSTA / DA VALUTARE**

## P-0008 — Modello e ampiezza dei disturbi

**Data:** 2026-08-24
**Milestone:** M5

### Problema

Definire dove agisce il disturbo e quale ampiezza deve essere rigettata.

### Alternative

- coppia esterna ai giunti/link;
- disturbo additivo sulla misura/posizione;
- disturbo sul comando motore;
- scenari distinti per ciascun fenomeno.

### Scelta

Privilegiare un disturbo di coppia fisico coerente con l'esempio della traccia; mantenere il disturbo additivo di posizione del riferimento solo come confronto. Ampiezze 1 e 0.2 non sono approvate.

### Motivazione

Scalare da 1 a 0.2 cambia il requisito prestazionale e deve essere esplicito.

### Conseguenze

Canali della pianta generalizzata, unità dei pesi e interpretazione di RP cambieranno.

### Stato

**PROPOSTA / DA VALUTARE**
