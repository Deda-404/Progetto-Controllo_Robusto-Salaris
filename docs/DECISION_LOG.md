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

---

## D-0002 — Convenzione unica dello stato non lineare

**Data:** 2026-08-24
**Milestone:** M1

### Problema

Fissare un ordine non ambiguo per coordinate di link, velocità, coordinate dei rotori e velocità dei rotori, valido per codice, test e futuro modello Simulink.

### Alternative

- raggruppare posizioni e velocità per ciascun giunto;
- usare l'ordine \([q;\theta;\dot q;\dot\theta]\);
- usare l'ordine fisico a blocchi \([q;\dot q;\theta;\dot\theta]\) indicato nel prompt M1.

### Scelta

Adottare in tutto il repository

\[
x=[q_1,q_2,\dot q_1,\dot q_2,\theta_1,\theta_2,
\dot\theta_1,\dot\theta_2]^T=[q;\dot q;\theta;\dot\theta].
\]

L'ingresso è sempre la coppia motore \(\tau=[\tau_1,\tau_2]^T\).

### Motivazione

L'ordine separa chiaramente la dinamica lato link e lato motore, rende immediati i vincoli cinematici dell'RHS ed è fissato esplicitamente per M1.

### Conseguenze

Ogni modello, linearizzazione, interfaccia Simulink e test successivo dovrà mantenere questo ordine oppure applicare e documentare una trasformazione esplicita.

### Stato

**APPROVATA**

---

## D-0003 — Equilibrio verticale superiore

**Data:** 2026-08-24
**Milestone:** M2
**Decisione precedente collegata:** P-0001

### Problema

Selezionare un punto statico fisicamente significativo per la linearizzazione del modello meccanico nominale a otto stati.

### Alternative

- configurazione verticale superiore \(\bar q=[\pi/2,0]^T\);
- una configurazione con coppia gravitazionale non nulla e deformazione SEA statica;
- una configurazione inferiore open-loop stabile.

### Scelta

Adottare

\[
\bar q=[\pi/2,0]^T,
\quad
\bar\theta=\bar q+K_s^{-1}G(\bar q),
\quad
\bar\tau=G(\bar q).
\]

Numericamente \(G(\bar q)\), \(\bar\theta-\bar q\) e \(\bar\tau\) sono inferiori a \(6\times10^{-16}\) nelle rispettive unità e \(\|f(\bar x,\bar\tau)\|_2=5.8387489976584098\times10^{-14}\).

### Motivazione

La configurazione è il verticale superiore, ha una relazione statica semplice derivata dal modello e produce due poli reali instabili, 7.20942861374 e 4.04083356564 s⁻¹. Costituisce quindi un problema di stabilizzazione significativo senza imporre artificialmente coppie nominali.

### Conseguenze

Jacobiani, modelli incrementali e future sintesi nominali useranno questo punto finché una decisione successiva non lo sostituirà. La validità del modello LTI resta locale.

### Stato

**APPROVATA — sostituisce la proposta P-0001**

---

## D-0004 — Misura principale delle posizioni link e motori

**Data:** 2026-08-24
**Milestone:** M2
**Decisione precedente collegata:** P-0002

### Problema

Definire una configurazione di misura plausibile e adeguata per il futuro estimatore, mantenendola distinta dall'uscita di prestazione.

### Alternative

- misurare soltanto \(q\);
- misurare \([q;\theta]\);
- includere direttamente anche le velocità.

### Scelta

Adottare come misura principale

\[
y_{meas}=[q;\theta],
\]

selezionata da `Cmeas`; non assumere misure dirette di velocità.

### Motivazione

Encoder di posizione lato link e lato motore sono plausibili e rendono direttamente disponibile la deformazione SEA. La matrice di osservabilità ha rango SVD 8/8 con \(\sigma_{min}=3101.1254321359797\), superiore alla tolleranza 0.0078125. Il PBH sui due modi instabili ha rango 8/8, quindi la coppia è osservabile e rilevabile.

### Conseguenze

Le velocità dovranno essere stimate. Il futuro LQG userà questa configurazione come baseline; covarianze e architettura dell'estimatore non sono ancora approvate. La sola misura \(q\) resta un caso informativo, anch'esso osservabile/rilevabile nel modello M2.

### Stato

**APPROVATA — risolve la parte misure di P-0002**

---

## D-0005 — Uscita primaria di prestazione

**Data:** 2026-08-24
**Milestone:** M2
**Decisione precedente collegata:** P-0002

### Problema

Separare le variabili fisiche da regolare dai segnali disponibili all'estimatore.

### Alternative

- regolare le sole posizioni dei link \(q\);
- regolare congiuntamente \([q;\theta]\);
- includere velocità o deformazioni come uscite primarie.

### Scelta

Adottare come uscita primaria di prestazione

\[
y_q=q,\qquad C_q=[I_2\ 0_{2\times6}],\qquad D_q=0.
\]

### Motivazione

Le coordinate dei link descrivono direttamente la posa del manipolatore e sono distinte dalle misure aggiuntive necessarie alla stima. Il modello `Gmech_q` conserva ordine 8 e il caso \(C_q\) risulta anche osservabile e rilevabile, pur non essendo scelto come misura principale.

### Conseguenze

Le future specifiche di tracking/regolazione saranno formulate prioritariamente su \(q\). Pesi, bande, errori ammessi e limiti restano da approvare nelle milestone dedicate.

### Stato

**APPROVATA — risolve la parte uscite di P-0002**

---

## D-0006 — Parametri nominali e simmetria degli attuatori

**Data:** 2026-08-24
**Milestone:** M3
**Decisione precedente collegata:** P-0003

### Problema

Definire \(\omega_n\), \(\zeta\), \(\tau_d\), ordine del Padé e relazione nominale fra i due attuatori senza dati sperimentali forniti dalla traccia.

### Alternative

- griglia autonoma con \(\omega_n\in\{25,40,60\}\) rad/s, \(\zeta\in\{0.6,0.8,1.0\}\) e \(\tau_d\in\{10,15,25\}\) ms, per 27 candidati;
- valori del riferimento, 30 rad/s, 0.7 e 20 ms, consultati soltanto dopo il primo PASS;
- canali nominali diversi, rinviati perché la traccia non fornisce dati per giustificare un'asimmetria.

### Scelta

Adottare per entrambi i canali:

\[
\omega_n=40\ \mathrm{rad/s},\qquad
\zeta=0.8,\qquad
\tau_d=0.015\ \mathrm{s},
\]

con Padé del primo ordine e blocco nominale

\[
G_A(s)=\operatorname{diag}(G_a(s),G_a(s)).
\]

I parametri sono una **assunzione nominale progettuale**, non valori identificati.

### Metriche

- attuatore SISO di ordine 3, guadagno statico 1;
- poli \(-32\pm24j\) e \(-133.3333\) s⁻¹, tutti stabili;
- zero Padé RHP \(+133.3333\) s⁻¹;
- rise time 0.0626454 s, settling time 0.109362 s, overshoot 1.47221% e banda 34.7834 rad/s;
- errori di fase Padé pari a 0.001063° e 0.006028° sui modi instabili M2, 4.76162° a 70 rad/s e 6.82742° a 80 rad/s;
- due canali di ordine complessivo 6 e pianta completa di ordine 14.

### Motivazione

L'attuatore è più rapido dei modi instabili a 4.0408 e 7.2094 s⁻¹, mantiene basso l'overshoot e introduce roll-off prima dei modi elastici a circa 70–80 rad/s. Il ritardo di 15 ms è significativo senza produrre, con Padé ordine 1, un errore di fase eccessivo nella zona dei modi instabili. La scelta è stata fissata prima del confronto reference-last e non è stata adattata per assomigliare al progetto precedente né per favorire un controllore non ancora progettato.

### Conseguenze e limitazioni

Il comando \(u\) è distinto dalla coppia effettiva \(\tau\) applicata al modello meccanico. I due attuatori sono identici soltanto nel nominale. Padé introduce uno zero RHP ma nessun polo instabile. In M4 dovranno essere decisi e approvati separatamente dispersioni parametriche, differenze fra canali e dinamiche non modellate; questa decisione non approva percentuali d'incertezza, ureal, ultidyn o \(W_I\).

### Stato

**APPROVATA — sostituisce la proposta P-0003**
