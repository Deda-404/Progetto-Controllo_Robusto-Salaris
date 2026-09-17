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
**Milestone:** M3, verificata metodologicamente in M3.1
**Decisione precedente collegata:** P-0003

### Problema

Definire \(\omega_n\), \(\zeta\), \(\tau_d\), ordine del Padé e relazione nominale fra i due attuatori senza dati sperimentali forniti dalla traccia.

### Alternative

- griglia autonoma con \(\omega_n\in\{25,40,60\}\) rad/s, \(\zeta\in\{0.6,0.8,1.0\}\) e \(\tau_d\in\{10,15,25\}\) ms, per 27 candidati;
- valori del riferimento, 30 rad/s, 0.7 e 20 ms, consultati soltanto dopo il primo PASS;
- canali nominali diversi, rinviati perché la traccia non fornisce dati per giustificare un'asimmetria.

### Regola di selezione M3.1

La decisione non deriva più dal confronto con parametri precaricati. `select_nominal_actuator.m` ricava dai poli M2 \(\lambda_{u,max}=7.20943\) rad/s e \(\omega_{el,min}=69.9543\) rad/s, quindi impone:

\[
4\lambda_{u,max}\le BW_{act}\le0.60\omega_{el,min},
\qquad M_p\le2\%,
\qquad |\Delta\phi_{Pad\acute e}(80)|\le10^\circ.
\]

I moltiplicatori 4 e 0.60 e la fascia di quasi-parità del settling del 10% sono criteri progettuali, non requisiti della traccia. Risultano ammissibili C13, C14, C25 e C26. Tutti hanno settling entro il 10% dal minimo ammissibile; viene quindi preferito il ritardo maggiore compatibile, 15 ms, e fra C14/C26 il minor settling seleziona C14. Gli ulteriori tie-break preferiscono, nell'ordine, overshoot minore, distanza minore dal centro della finestra di banda, \(\omega_n\) minore, \(\zeta\) minore e indice minore.

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

L'attuatore è più rapido dei modi instabili a 4.0408 e 7.2094 s⁻¹, mantiene basso l'overshoot e introduce roll-off prima dei modi elastici a circa 70–80 rad/s. Il ritardo di 15 ms è significativo senza superare il limite di errore Padé. M3.1 ha verificato che la stessa scelta emerge dalle metriche della griglia senza leggere `actuator_params_nominal.m`: non è quindi un candidato preselezionato, ma il risultato riproducibile della regola documentata. La scelta non è stata adattata per assomigliare al riferimento né per favorire un controllore non ancora progettato.

### Conseguenze e limitazioni

Il comando \(u\) è distinto dalla coppia effettiva \(\tau\) applicata al modello meccanico. I due attuatori sono identici soltanto nel nominale. Padé introduce uno zero RHP ma nessun polo instabile. In M4 dovranno essere decisi e approvati separatamente dispersioni parametriche, differenze fra canali e dinamiche non modellate; questa decisione non approva percentuali d'incertezza, ureal, ultidyn o \(W_I\).

### Stato

**APPROVATA E CONFERMATA DA M3.1 — sostituisce la proposta P-0003**

---

## D-0007 — Parametri meccanici incerti `k2`, `k1`, `Jm1`

**Data:** 2026-08-24
**Milestone:** M4
**Decisione precedente collegata:** P-0004

### Problema

Ridurre i dieci candidati meccanici a un insieme piccolo, fisicamente interpretabile e adatto alla futura mu-analysis.

### Alternative

- rendere incerti tutti i candidati;
- imporre a priori un insieme fisso senza eseguire lo screening;
- selezionare tre parametri tramite screening multifattore riproducibile;
- includere anche il quarto classificato `Jm2`.

### Evidenze e scelta

Lo screening ±1% ricostruisce equilibrio, Jacobiani e pianta completa su 0.1–300 rad/s. La priorità combina al 65% quattro metriche dinamiche e al 35% plausibilità fisica, ruolo delle occorrenze e interpretabilità. Il ranking autonomo è `k2`, `k1`, `Jm1`, `Jm2`, `m2`, `l1`, `l2`, `m1`, `Bm2`, `Bm1`, con priorità 0.75889, 0.64998 e 0.59755 per i primi tre.

Selezionare come blocchi reali indipendenti `k2`, `k1` e `Jm1`. `Jm2` resta il primo escluso; non vi è evidenza sufficiente per aumentare a quattro blocchi.

### Motivazione

Le rigidezze dominano lo spostamento dei modi elastici e la risposta frequenziale. `Jm1` completa l'insieme con un parametro di natura diversa e un'elevata sensibilità ai modi elastici. La funzione di configurazione riceve ora obbligatoriamente questa selezione dallo screening e non possiede un default silenzioso.

### Conseguenze e limiti

Gli altri parametri restano nominali soltanto nell'ensemble M4. Lo screening è locale al punto M2 e dipende dai pesi espliciti della priorità; nuovi dati sperimentali richiedono una nuova decisione.

### Stato

**APPROVATA PER IL MODELLO M4 — da riesaminare solo con nuove evidenze fisiche**

---

## D-0008 — Scenari e range meccanici baseline

**Data:** 2026-08-24
**Milestone:** M4

### Problema

Definire range difendibili senza dati di tolleranza o identificazione e senza ottimizzarli per un controllore futuro.

### Alternative

- usare una percentuale unica e non qualificata per nature fisiche diverse;
- adottare un unico envelope non qualificato;
- documentare scenari MILD/BASELINE/CONSERVATIVE per ciascuna natura fisica.

### Evidenze e scelta

Adottare rigidezze ±3/±7/±12% e `Jm1` ±4/±9/±15% nei tre scenari. Il BASELINE usa quindi `k1,k2` ±7% e `Jm1` ±9%. Sugli otto corner, il BASELINE produce variazione massima dei modi elastici 6.703%, dei poli instabili 0.1611% e FRF relativa massima 5.4732 vicino a 83.326 rad/s.

### Motivazione

Il 7% è un envelope progettuale prudente ma moderato per dispersione di materiale, assemblaggio e tolleranze equivalenti della rigidezza SEA. Il 9% rappresenta variabilità moderata dell'inerzia riflessa di motore e trasmissione. Entrambi sono assunzioni ingegneristiche non identificate sperimentalmente e non sono scelti per rendere fattibile una sintesi.

### Conseguenze e limiti

I range sono assunzioni ingegneristiche, non tolleranze misurate. I tre `ureal` sono indipendenti; nessuna correlazione è modellata. M5 o M13 non potranno riscrivere retroattivamente questi range per ragioni di performance.

### Stato

**APPROVATA PER IL BASELINE M4**

---

## D-0009 — Range e famiglia degli attuatori

**Data:** 2026-08-24
**Milestone:** M4

### Problema

Costruire una famiglia attuativa attorno al nominale M3 che rappresenti dispersione di banda, damping e ritardo, compreso il mismatch ritardo esatto/Padé.

### Alternative

- soli campioni casuali;
- soli corner;
- attuatori parametrici `ureal` senza errore dinamico concentrato;
- famiglia FRD con nominale, variazioni singole, corner e casuali.

### Evidenze e scelta

Adottare scenari MILD/BASELINE/CONSERVATIVE: `wn` ±4/±8/±15%, `zeta` ±4/±7.5/±12.5%, ritardo ±8/±20/±35%. Il BASELINE genera 120 modelli: 1 nominale esatto, 6 singoli, 8 corner e 105 casuali con seed 20260824. Il ritardo è `exp(-jw*delay)` su 0.1–1000 rad/s; il nominale del progetto resta Padé ordine 1.

### Motivazione

Gli envelope baseline sono moderati e interpretabili come dispersione della dinamica chiusa e latenza/jitter. FRD evita di aumentare artificialmente l'ordine del Padé e include esplicitamente il suo mismatch.

### Conseguenze e limiti

La famiglia è una griglia/campionamento riproducibile, non un'identificazione continua garantita. Il massimo errore moltiplicativo degli otto corner baseline è 2.1697 a circa 302 rad/s. I nominali `wn`, `zeta` e ritardo sono letti esclusivamente da `actuator_params_nominal.m`.

### Stato

**APPROVATA PER IL FIT M4**

---

## D-0010 — Incertezza attuatore input-moltiplicativa

**Data:** 2026-08-24
**Milestone:** M4
**Decisione precedente collegata:** P-0004

### Problema

Scegliere una rappresentazione razionale, compatibile con LFT e futura analisi robusta, della famiglia con ritardo esatto.

### Alternative

- incertezza additiva;
- incertezza output-moltiplicativa;
- parametri attuativi completamente strutturati;
- incertezza input-moltiplicativa pesata.

### Scelta e motivazione

Adottare `Ga,var = Ga,nom*(1 + WI*Delta)`, `||Delta||inf <= 1`, e calcolare `Ei = Ga,var/Ga,nom - 1`. Per i canali SISO la convenzione input/output è numericamente equivalente, ma quella input-moltiplicativa mantiene esplicita la perturbazione prima della pianta meccanica e coincide con l'interfaccia richiesta per M4.

### Conseguenze e limiti

La dinamica non modellata viene concentrata in un envelope non strutturato; i contributi separati di `wn`, `zeta` e ritardo non saranno identificabili dalla futura mu-analysis. Resta disponibile la tabella della famiglia per diagnostica.

### Stato

**APPROVATA — risolve la rappresentazione dinamica di P-0004**

---

## D-0011 — Peso `WI` stabile e proprio di ordine minimo 1

**Data:** 2026-08-24
**Milestone:** M4

### Problema

Scegliere il minimo ordine stabile e proprio che copra tutti i 120 modelli, evitando dinamica aggiuntiva non necessaria.

### Alternative

- ordini 1, 2, 3 o 4 ottenuti da `ucover`;
- fit manuale di ordine prefissato;
- nessun margine di sicurezza.

### Evidenze e scelta

Con fattore 1.08, tutti gli ordini 1–4 risultano stabili, propri e coprenti. Selezionare il primo:

`WI(s) = 2.87131986636 (s+1.32752948673)/(s+207.353298568)`.

Il worst ratio è 0.925925925926, il margine minimo 0.0130725422 e il caso critico è `corner-212` a 281.838293 rad/s. La tolleranza numerica è `1e-9`.

### Motivazione

Ordini superiori non aggiungono necessità di copertura e aumentano la complessità futura. Il polo e lo zero sono stabili e non quasi coincidenti.

### Conseguenze e limiti

Il peso copre la famiglia discreta sulla griglia 0.1–1000 rad/s; non costituisce prova per ogni combinazione continua fuori dalla griglia. Se la famiglia cambia, il fit deve essere rigenerato.

### Stato

**APPROVATA PER M4**

---

## D-0012 — Due blocchi dinamici attuatori indipendenti

**Data:** 2026-08-24
**Milestone:** M4

### Problema

Decidere se i due attuatori, identici nel nominale, debbano condividere la stessa perturbazione dinamica.

### Alternative

- un solo `Delta_act` condiviso;
- due blocchi correlati;
- due `ultidyn` scalari indipendenti.

### Evidenze e scelta

Usare `Delta_act1` e `Delta_act2`, complessi dinamici 1x1 con bound 1. `lftdata` conferma due blocchi distinti, ciascuno con una occorrenza, oltre ai tre `ureal` meccanici.

### Motivazione

Non esiste evidenza fisica di dispersione perfettamente correlata fra i canali. L'indipendenza evita un'ipotesi ottimistica e conserva i nomi necessari alla diagnostica futura.

### Conseguenze e limiti

L'ensemble può essere più ampio del caso di variazione comune. Una futura correlazione richiederebbe dati e una nuova decisione, non una semplificazione automatica.

### Stato

**APPROVATA PER LA STRUTTURA DELTA M4 — completa P-0004**

---

## D-0013 — Dipendenze esplicite e source of truth della configurazione M4

**Data:** 2026-08-24
**Milestone:** M4.1

### Problema

La prima configurazione M4 duplicava i nominali attuatore e permetteva una chiamata senza screening tramite un default `k2/k1/Jm1`. Entrambi i comportamenti potevano mascherare divergenze future pur lasciando invariati i risultati correnti.

### Alternative

- conservare copie numeriche e default per comodità;
- leggere i nominali M3 ma mantenere una selezione meccanica predefinita;
- rendere entrambe le dipendenze esplicite e testate.

### Scelta

`uncertainty_params_m4` legge `wn`, `zeta` e ritardo esclusivamente da `actuator_params_nominal.m` e richiede in input `selectedMechanicalParameters` prodotti dallo screening. Input mancante o vuoto genera `M4Uncertainty:MissingSelection`.

### Evidenze e motivazione

I test T15 e T16 verificano sia la dipendenza dalla source of truth sia l'assenza del default. T17 conferma che il cleanup non cambia selezione, range, ordine di `WI` o coerenza nominale. La catena diventa quindi univoca:

`screen_parameter_sensitivity -> selectedMechanicalParameters -> uncertainty_params_m4`.

### Conseguenze e limiti

Le chiamate future devono passare esplicitamente lo screening. L'uncertainty set resta `k2/k1/Jm1`, ±7/±7/±9%, range attuatore ±8/±7.5/±20%, `WI` ordine 1 e due Delta indipendenti.

### Stato

**APPROVATA — CLEANUP M4.1, NESSUNA MODIFICA NUMERICA DELL'ENSEMBLE**

---

## D-0014 — Disturbo esterno come coppia ai link

**Data:** 2026-08-24
**Milestone:** M5

### Problema

Definire il fenomeno fisico principale per le future verifiche di disturbance rejection senza confonderlo con rumore di misura o comando attuatore.

### Alternative

- perturbazione additiva sulla posizione misurata;
- coppia additiva sul comando motore prima dell'attuatore;
- coppia esterna (d=[d_1,d_2]^T) applicata direttamente alla dinamica dei link.

### Criterio e scelta

È scelta la coppia esterna ai link, coerente con (M(q)\ddot q+C(q,\dot q)\dot q+G(q)=K_s(\theta-q)+d). Nel modello linearizzato (B_d) ha il solo blocco (M(\bar q)^{-1}) sulle accelerazioni link. Il comando (u) continua invece ad attraversare gli attuatori M3.

### Motivazione

La scelta rappresenta un carico meccanico esterno reale, preserva le unità N m e mantiene separati disturbo, comando e misura. La derivazione analitica di (B_d) coincide con una differenza finita centrata del modello non lineare.

### Conseguenze

La pianta M5 ha ingressi ([u_1,u_2,d_1,d_2]) e uscite ([q_1,q_2,\theta_1,\theta_2]), senza feedthrough additivo del disturbo sulle uscite.

### Stato epistemico

**APPROVATA COME MODELLO FISICO M5; LE AMPIEZZE RESTANO SCENARI DI PROGETTO**

---

## D-0015 — Ampiezze nominali di validazione

**Data:** 2026-08-24
**Milestone:** M5

### Problema

Fissare ampiezze riproducibili per tracking locale e disturbo senza presentarle come limiti hardware o dati sperimentali.

### Alternative

- riferimenti articolari 2°, 5° e 8°;
- disturbi 0.25, 0.50 e 1.00 N m;
- valori singoli non accompagnati da uno studio locale.

### Criterio e scelta

Sono conservate tutte le griglie; i casi nominali sono 5° (0.0872665 rad) e 0.50 N m. La consistenza del riferimento viene valutata sull'errore della linearizzazione gravitazionale; il disturbo viene confrontato con la scala gravitazionale locale e con la deformazione statica (K_s^{-1}d).

### Motivazione

A 5° il massimo errore relativo gravitazionale locale è 0.16043%. Il disturbo da 0.50 N m vale circa il 60.9% della massima variazione gravitazionale dello stesso scenario e produce deformazioni SEA di 0.0100/0.0125 rad: è significativo ma non descrive un urto estremo.

### Conseguenze

Le sintesi successive dovranno verificare almeno i tre livelli di entrambe le griglie. Nessun valore costituisce corsa, saturazione o tolleranza certificata.

### Stato epistemico

**APPROVATA COME BASELINE DI VALIDAZIONE M5; ASSUNZIONE NON SPERIMENTALE**

---

## D-0016 — Banda target (\omega_B=12\) rad/s

**Data:** 2026-08-24
**Milestone:** M5

### Problema

Collocare la rapidità desiderata sopra la scala dei poli instabili ma sotto i limiti imposti da attuatore e modi elastici.

### Alternative

- candidati 11, 12 e 13 rad/s;
- banda scelta senza usare i dataset dinamici;
- valore continuo al bordo della finestra.

### Criterio e scelta

La finestra è (1.5\lambda_{u,max}\leq\omega_B\leq\min(0.40\omega_{act},0.20\omega_{elastic,min})). Con i dati M2/M3 risulta 10.8141429–13.9133481 rad/s. Il ranking massimizza il minimo dei tre margini, poi usa distanza dal centro, valore di banda e indice come tie-break. È selezionato 12 rad/s.

### Motivazione

Il candidato conserva 1.18586 rad/s dal limite inferiore, 1.91335 rad/s dal limite attuatore e 1.99087 rad/s dal limite elastico, migliorando il margine minimo rispetto a 11 e 13 rad/s.

### Conseguenze

I coefficienti 1.5, 0.40 e 0.20 sono criteri progettuali. La banda è un target da verificare closed-loop e non una prestazione già ottenuta.

### Stato epistemico

**APPROVATA COME BANDA TARGET M5, DERIVATA DAI DATASET VALIDATI**

---

## D-0017 — Target di sensitivity (A_s=0.05), (M_s=2)

**Data:** 2026-08-24
**Milestone:** M5

### Problema

Bilanciare attenuazione a bassa frequenza e picco desiderato di sensitivity nel peso (W_1).

### Alternative

- (A_s\in\{0.03,0.05,0.08\});
- (M_s\in\{1.7,2.0,2.4\});
- estremi più aggressivi o più permissivi della griglia locale.

### Criterio e scelta

Per (W_1(s)=(s/M_s+\omega_B)/(s+\omega_BA_s)), la regola deterministica preferisce la severità mediana su (A_s) e poi su (M_s). Sono scelti (A_s=0.05) e (M_s=2).

### Motivazione

Gli asintoti verificati sono (W_1(0)=20) e (W_1(\infty)=0.5). Il target corrisponde a sensitivity a bassa frequenza dell'ordine del 5% e picco desiderato dell'ordine di 6 dB senza adottare gli estremi locali.

### Conseguenze

Il peso è stabile, proprio e di ordine uno. La fattibilità simultanea dei target sarà valutata dalle future sintesi; M5 non dichiara il requisito soddisfatto.

### Stato epistemico

**APPROVATA COME TARGET W1 M5; FATTIBILITÀ CLOSED-LOOP NON ANCORA VERIFICATA**

---

## D-0018 — Scala di normalizzazione dello sforzo (u_{scale}=12\) N m

**Data:** 2026-08-24
**Milestone:** M5

### Problema

Normalizzare lo sforzo di controllo in assenza di una saturazione hardware dichiarata dalla traccia.

### Alternative

- 8, 12 o 16 N m;
- dichiarare uno dei valori come limite fisico;
- evitare lo scaling dimensionale del comando.

### Criterio e scelta

È scelto il valore mediano 12 N m dopo confronto con coppie elastiche e scenari di disturbo moderati.

### Motivazione

La scala è superiore alle coppie richieste dagli scenari locali, mantiene margine dinamico e non assume disponibilità di coppie estremamente elevate senza dati hardware.

### Conseguenze

(u_{scale}) è esclusivamente un parametro di normalizzazione/prestazione. Saturazione, slew rate e limiti termici dovranno essere definiti soltanto se saranno disponibili dati fisici.

### Stato epistemico

**APPROVATA COME SCALA PRESTAZIONALE M5; NON È UNA SATURAZIONE CERTIFICATA**

---

## D-0019 — Roll-up del comando con (\omega_U=30\) rad/s e (\alpha=6)

**Data:** 2026-08-24
**Milestone:** M5

### Problema

Aumentare la penalizzazione del comando ad alta frequenza prima di eccitare attuatori e modi elastici.

### Alternative

- (\omega_U\in\{25,30,35\}\) rad/s;
- (\alpha\in\{4,6\});
- peso costante senza aumento ad alta frequenza.

### Criterio e scelta

Per (W_2=(1/u_{scale})(s/\omega_U+1)/(s/(\alpha\omega_U)+1)), l'onset deve essere sotto la banda attuatore e non oltre metà del primo modo elastico. Il ranking preferisce (u_{scale}) mediano, l'onset ammissibile più vicino dal basso alla banda attuatore e il maggiore (\alpha). Sono selezionati 30 rad/s e 6.

### Motivazione

L'onset dista 4.78337 rad/s dalla banda attuatore e 39.9543 rad/s dal primo modo elastico. Gli asintoti verificati sono 0.0833333 e 0.5 (N m)(^{-1}), quindi la penalizzazione aumenta di un fattore sei.

### Conseguenze

Il peso è stabile, proprio e di ordine uno. Il roll-up limita la richiesta di comando in frequenza ma non sostituisce una futura saturazione fisica.

### Stato epistemico

**APPROVATA COME TARGET W2 M5; EFFETTO CLOSED-LOOP NON ANCORA VERIFICATO**

---

## D-0020 — Target temporali e cross-coupling preliminare

**Data:** 2026-08-24
**Milestone:** M5

### Problema

Definire metriche comuni per confrontare i futuri controllori nominali e robusti.

### Alternative

- nessun target fino alla sintesi;
- target temporali e MIMO estremamente severi;
- baseline moderata, esplicitamente non ancora soddisfatta.

### Criterio e scelta

Sono adottati settling time ≤0.8 s, overshoot ≤10%, errore di tracking a regime ≤5% senza assumere a priori un integratore, forte attenuazione dei disturbi costanti/bassa frequenza e cross-coupling di picco ≤25% come target preliminare. Per un futuro controllore integrale l'obiettivo su ingressi costanti compatibili sarà errore nullo.

### Motivazione

Le metriche collegano rapidità, precisione e interazione MIMO senza anticipare la struttura del controllore. Il cross-coupling sarà misurato in entrambe le direzioni articolari.

### Conseguenze

Ogni milestone di sintesi dovrà dichiarare separatamente target soddisfatti, violati o non valutati. NS, NP, RS e RP restano distinti; M5 non calcola (\mu).

### Stato epistemico

**APPROVATA COME BASELINE DI CONFRONTO M5; CROSS-COUPLING PRELIMINARE**

---

## D-0021 — Correzione epistemica di equilibrio e disturbo M5

**Data:** 2026-08-24
**Milestone:** M6, cleanup preliminare M5

### Problema

I metadati M5 classificavano l'equilibrio verticale superiore e la collocazione del disturbo ai link come requisiti della traccia, mentre le decisioni storiche D-0003 e D-0014 ne documentano la natura progettuale.

### Criterio e scelta

L'equilibrio (\bar q=[\pi/2,0]^T) è riclassificato come decisione approvata del progetto, derivata e validata in M2. La coppia esterna ai link è riclassificata come scelta di modellazione del progetto, fisicamente coerente con la traccia ma non imposta da essa in modo univoco.

### Motivazione

La classificazione epistemica deve distinguere ciò che la traccia richiede dalle scelte tecniche con cui il gruppo rende il problema riproducibile. D-0003 e D-0014 restano le fonti decisionali; non viene riscritta la loro cronologia.

### Conseguenze

Sono aggiornati soltanto metadati e documentazione. Equilibrio, (B_d), ampiezze, pesi e tutti i valori numerici M5 restano invariati.

### Stato epistemico

**APPROVATA COME CORREZIONE DOCUMENTALE PRELIMINARE M6 — NESSUNA MODIFICA NUMERICA M5**

---

## D-0022 — Normalizzazione fisica del costo LQR M6

**Data:** 2026-08-24
**Milestone:** M6, screening LQR parziale

### Problema

Costruire il costo di stato del primo regolatore nominale senza dipendere da pesi numerici arbitrari o dalla realizzazione interna dei blocchi attuatore.

### Alternative

- pesi diagonali assegnati direttamente ai 14 stati;
- regola di Bryson sulle sole coordinate meccaniche;
- costo sulle variabili fisiche normalizzate (q), (\dot q), (\theta-q) e (\dot\theta).

### Criterio e scelta

È adottato (Q=C_{cost}^TC_{cost}) con scale (q_s=5°), (\dot q_s=\omega_Bq_s), (\delta_s=d_{nom}/\min(k_1,k_2)=0.0125) rad e (\dot\theta_s=\omega_Bq_s). I sei stati interni degli attuatori non ricevono penalizzazioni dirette arbitrarie.

### Motivazione

Le scale provengono dalle source of truth M3/M5, conservano unità e significato fisico e rendono il costo indipendente da trasformazioni di similitudine della realizzazione attuativa. La CARE è risultata risolvibile per tutti i candidati analizzati.

### Conseguenze e limiti

La normalizzazione è approvata come base dello screening. Il risultato negativo sul settling richiede revisione prima di cambiare pesi relativi, griglia o target.

### Stato epistemico

**APPROVATA COME NORMALIZZAZIONE M6; SELEZIONE LQR NON COMPLETATA**

---

## D-0023 — Nessun candidato (\rho_U) ammissibile nella griglia M6

**Data:** 2026-08-24
**Milestone:** M6, quality gate LQR

### Problema

Selezionare il maggiore (\rho_U\in\{0.5,1,2,4,8\}) che soddisfi stabilità, settling non superiore a 0.8 s, overshoot non superiore al 10% ed errore statico di tracking non superiore al 5%.

### Evidenze

Tutti i cinque regolatori sono stabilizzanti, hanno overshoot massimo inferiore a 0.001%, errore statico alla precisione numerica e cross-coupling di picco circa 16.2%. Il worst-case settling è però compreso fra 1.222 s e 1.232 s. `stepinfo` ha confermato indipendentemente 1.22134 s sul giunto 1 per (\rho_U=0.5). Un'estensione diagnostica fino a (\rho_U=0.001) riduce il valore soltanto a 1.21251 s, con crescita marcata del guadagno LQR.

### Criterio e scelta

Nessun candidato viene selezionato. Non vengono modificate silenziosamente specifiche M5, pesi relativi o struttura di controllo.

### Conseguenze e limiti

M6 è `PARTIAL` e la sintesi Kalman/LQG non viene iniziata. Il gruppo deve decidere se autorizzare una revisione della normalizzazione relativa, ampliare l'architettura o riclassificare il target temporale prima di proseguire.

### Stato epistemico

**QUALITY GATE LQR FAIL — REVISIONE DEL GRUPPO RICHIESTA**

---

## D-0024 — Retuning adimensionale e selezione LQR C193

**Data:** 2026-08-24
**Milestone:** M6

### Problema

Il tuning iniziale sulle sole (R) non modificava il modo dominante e non raggiungeva il settling di 0.8 s. Il gruppo ha autorizzato la revisione esclusiva delle priorità relative del costo, preservando scale fisiche e specifiche M5.

### Alternative

- modificare il target M5 o (\omega_B), non autorizzato;
- continuare a ridurre (\rho_U), già smentito dalla diagnostica;
- esplorare coefficienti adimensionali su posizione, velocità e deformazione SEA.

### Metriche, criterio e scelta

La coarse grid da 240 candidati ha prodotto 139 candidati fondamentali ammissibili; non è stata eseguita la extended grid. Il ranking minimizza picco comando normalizzato, deformazione normalizzata e norma di (K), poi preferisce il maggiore (\rho_U). È selezionato C193 con (w_q=1), (w_{\dot q}=w_{\dot\theta}=0.5), (w_\delta=0.1) e (\rho_U=8).

### Motivazione

A parametri restanti fissi, ridurre (w_\delta) da 1 a 0.1 diminuisce il worst settling da 1.220 a 0.776 s e sposta la parte reale dominante da -4.3377 a -5.5051, mentre il comando scende da 0.5939 a 0.3908 della scala prestazionale. I dati confermano che il costo Bryson-like iniziale sovrapenalizzava la variabile interna (\theta-q) rispetto all'obiettivo di tracking.

### Conseguenze e limiti

Il tracking soddisfa settling, overshoot, errore statico e cross-coupling preliminare. Il picco deformazione è 1.8917 volte (\delta_s), valore diagnostico e non violazione di un limite fisico inesistente. Le scale M5 restano invariate.

### Stato epistemico

**APPROVATA COME SELEZIONE LQR M6 DA METRICHE — SOSTITUISCE LO STOP D-0023 SENZA CANCELLARNE L'EVIDENZA**

---

## D-0025 — Modello di process noise (G_w=[B_d\ B])

**Data:** 2026-08-24
**Milestone:** M6

### Problema

Rappresentare perturbazioni dinamiche per lo stimatore senza usare covarianze opache o la pianta incerta M4.

### Alternative

- rumore di processo applicato direttamente a tutti i 14 stati;
- soli disturbi ai link;
- due disturbi di coppia ai link e due mismatch equivalenti del comando attuatore.

### Criterio e scelta

È scelto (G_w=[B_d\ B]) con (w=[w_{d1},w_{d2},w_{u1},w_{u2}]^T). I primi due canali conservano il modello M5; gli ultimi due rappresentano perturbazioni equivalenti del comando nominale.

### Motivazione

La struttura mantiene unità di coppia, separa carico esterno e mismatch attuativo ed evita rumore artificiale indipendente su coordinate di stato dipendenti dalla realizzazione.

### Conseguenze e limiti

Il modello è nominale e non sostituisce l'ensemble strutturato M4. Correlazioni e spettri reali richiederebbero dati sperimentali.

### Stato epistemico

**APPROVATA COME MODELLO DI PROCESS NOISE M6**

---

## D-0026 — Covarianze e selezione Kalman KF03

**Data:** 2026-08-24
**Milestone:** M6

### Problema

Selezionare uno stimatore abbastanza rapido rispetto al regolatore senza privilegiare poli arbitrariamente veloci e rumorosi.

### Alternative

- (W=V=\epsilon I) senza interpretazione;
- 27 combinazioni di standard deviation fisiche definite in M6;
- selezione basata soltanto sul massimo decay.

### Metriche, criterio e scelta

Per ogni combinazione sono calcolati stabilità, decay, ratio stimatore/regolatore, (\|L\|_F) e norma (H_2) dal rumore encoder alle variabili normalizzate dell'errore. Tre candidati rispettano il ratio 1.5–5. È scelto KF03 con (\sigma_D=0.10) N m, (\sigma_U=0.10) N m e (\sigma_Y=0.05°): ratio 1.6928, (H_2=539.32) e (\|L\|_F=7040.6).

### Motivazione

KF03 minimizza la metrica (H_2) fra i candidati ammissibili e poi la norma del guadagno, secondo un ranking deterministico indipendente dal progetto di riferimento.

### Conseguenze e limiti

Lo stimatore è stabile e consente il controllore dinamico di ordine 14. Le standard deviation sono scenari di progetto, non specifiche certificate dei sensori.

### Stato epistemico

**APPROVATA COME SELEZIONE KALMAN NOMINALE M6**

---

## D-0027 — Precompensatore statico MIMO (N_r)

**Data:** 2026-08-24
**Milestone:** M6

### Problema

Ridurre l'errore statico nominale di tracking in assenza di stati integrali.

### Alternative

- nessun precompensatore;
- inversione esplicita non condizionata;
- soluzione lineare del guadagno DC MIMO da feedforward a (q).

### Metriche, criterio e scelta

È adottata la soluzione (G_{dc}N_r=I_2), con condition number 1.1144 e residuo (1.39\times10^{-17}). Numericamente (N_r=[[53.73943,-0.79651];[4.30445,49.39156]]).

### Motivazione

La soluzione è ben condizionata, finita e porta il guadagno DC nominale riferimento-posizione all'identità senza usare `inv`.

### Conseguenze e limiti

(N_r) non costituisce un internal model. Gli offset LQG misurati per disturbi costanti, 0.07959 e 0.16023 rad nei due casi, restano intenzionalmente visibili come baseline per M7.

### Stato epistemico

**APPROVATA PER IL TRACKING NOMINALE M6 SENZA INTEGRATORE**

---

## D-0028 — Due integratori sulle sole posizioni articolari e scala fisica di xi

**Data:** 2026-08-24
**Milestone:** M7

### Problema

Definire l’internal model M7 e una normalizzazione confrontabile con il costo M6, senza introdurre stati o pesi arbitrari.

### Alternative

- integrare le sole posizioni articolari misurate;
- integrare anche le coordinate motore `theta`;
- usare una scala adimensionale fissata numericamente;
- derivare la scala dall’ampiezza e dal target temporale M5.

### Metriche, criterio e scelta

Si adottano esattamente due stati con `xi_dot=r-q` nel servo ideale. La scala è `xiScale=referenceAmplitude*settlingTimeTarget=0.0698131701 rad s`, letta da M5; `Qi=wi/xiScale^2` è uguale sui due giunti. L’augmentazione ha dimensione 16, PBH a zero di rango 16 e Rosenbrock a zero di rango 16.

### Motivazione

Le uscite regolate sono `q1,q2`; integrare `theta` introdurrebbe due internal model non richiesti. La scala scelta lega l’accumulo d’errore allo scenario nominale e al target già approvati, isolando `wi` come coefficiente adimensionale.

### Conseguenze e limiti

Il costo sui primi 14 stati resta esattamente quello M6. La scelta non determina ancora un guadagno finale e non affronta saturazione o windup.

### Stato epistemico

**APPROVATA COME FORMULAZIONE E NORMALIZZAZIONE DEL CHECKPOINT M7**

---

## D-0029 — Nessun candidato ammissibile nella griglia LQI M7

**Data:** 2026-08-24
**Milestone:** M7, quality gate LQI

### Problema

Selezionare autonomamente un candidato fra 28 combinazioni di `wi` e `rhoU` che mantenga i target M5 e annulli gli offset da disturbo costante.

### Alternative

- promuovere il candidato con minimo settling anche se fuori specifica;
- modificare automaticamente il target M5;
- ampliare la griglia senza autorizzazione;
- registrare il trade-off e fermare la milestone.

### Metriche, criterio e scelta

Tutti i 28 candidati sono stabili e hanno offset DC sui due disturbi entro `1e-4 rad`; nessuno rispetta il settling di 0.8 s. Il minimo è 1.964 s per I25 (`wi=4`, `rhoU=4`), con gap 1.164 s. Per `wi=2` il settling è 2.704–2.776 s; per `wi<=1` non entra nella banda del 2% entro 3 s. L’insieme fondamentale-ammissibile è vuoto e nessun candidato viene selezionato.

### Motivazione

La regola M7 vieta di scegliere un controllore soltanto perché annulla l’offset quando il tracking degrada gravemente. Promuovere I25 renderebbe il confronto metodologicamente scorretto.

### Conseguenze e limiti

M7 è `PARTIAL`; il dataset finale, il controllore LQG-I, la diagnostica rumore, la separazione augmentata e il confronto finale M6/M7 non vengono prodotti. M5 resta invariato. Il dataset parziale conserva l’intera griglia e I25 esclusivamente come punto diagnostico.

### Stato epistemico

**QUALITY GATE LQI FAIL — REVISIONE DEL GRUPPO RICHIESTA**

---

## D-0030 — Architettura measured-error, riuso KF03 e anti-windup rinviati al progetto ammissibile

**Data:** 2026-08-24
**Milestone:** M7

### Problema

Definire le scelte di implementazione successive senza trasformare un candidato non ammissibile in un controllore finale.

### Alternative

- integrare `r-Sq*y`, quindi l’uscita realmente misurata;
- integrare `r-Cq*xhat`;
- ritunare simultaneamente il Kalman;
- riusare `L/Qn/Rn` di KF03;
- introdurre saturazione e anti-windup in assenza di limiti hardware.

### Metriche, criterio e scelta

La baseline prevista resta `xi_dot=r-Sq*y`; la variante estimated-error dovrà essere una sola diagnostica secondaria. Il Kalman previsto resta KF03 per isolare l’effetto integrale. Saturazione e anti-windup restano disabilitati. Poiché la griglia LQI non produce una selezione, il confronto measured/estimated, il riuso numerico di `L` nella realizzazione e le metriche seeded non sono stati eseguiti.

### Motivazione

L’uscita `q` è misurata direttamente e l’integrazione measured-error realizza l’internal model dell’errore regolato. Cambiare contemporaneamente stimatore e servo impedirebbe un confronto leggibile con M6. `uScale` non è un limite certificato e non giustifica una saturazione artificiale.

### Conseguenze e limiti

Le scelte sono vincoli per la ripresa, non evidenza di un controllore validato. Il rumore encoder entrerà nel canale integrale e dovrà essere quantificato soltanto dopo una nuova selezione autorizzata. Il rischio di windup resta aperto per la futura validazione non lineare con limiti motivati.

### Stato epistemico

**ARCHITETTURA BASELINE CONFERMATA; IMPLEMENTAZIONE FINALE NOT RUN PER STOP D-0029**

---

## D-0031 — Servo integrale 2-DoF con feedforward candidato-specifico

**Data:** 2026-08-24
**Milestone:** M7 completion

### Problema

Migliorare il tracking del riferimento senza modificare M5 e senza perdere l’internal model che annulla gli offset da disturbo.

### Alternative

- ampliare immediatamente `wi` senza cambiare architettura;
- riusare automaticamente `Nr` M6;
- eliminare l’integratore e affidare lo statico al feedforward;
- separare tracking e regolazione con `u=-Kx*x-Ki*xi+Nff*r`.

### Metriche, criterio e scelta

Il gruppo ha autorizzato l’ultima alternativa. Per ogni candidato si calcola autonomamente `Gdc_x` dalla relativa `Kx` e si risolve `Gdc_x*Nff=I2` senza `inv`. Sui 53 candidati Stage A/B il massimo condition number è 1.75379 e il massimo residuo è `2.483e-16`.

### Motivazione

Il percorso `Nff*r` può modellare il transitorio nominale senza cambiare il servo feedback. Con `r=0` scompare, mentre `Ki/xi` resta attivo: le simulazioni con e senza feedforward hanno differenza nulla nell’offset da disturbo.

### Conseguenze e limiti

`Nff` non viene interpretato come fonte del rigetto statico e non coincide con `Nr` M6. La sua efficacia transitoria deve comunque rispettare settling, overshoot e comando; il buon condizionamento DC non garantisce tali prestazioni.

### Stato epistemico

**APPROVATA COME ARCHITETTURA DI FEASIBILITY M7 2-DoF**

---

## D-0032 — Stage A e Stage B senza candidati ammissibili

**Data:** 2026-08-24
**Milestone:** M7 completion, quality gate

### Problema

Determinare se il feedforward candidato-specifico e, solo se necessario, una maggiore priorità integrale rendano raggiungibili i target M5 invariati.

### Alternative

- selezionare il candidato col solo settling minimo;
- accettare un overshoot o comando estremo;
- modificare M5 automaticamente;
- conservare la feasibility table e fermarsi.

### Metriche, criterio e scelta

Stage A ripete prima i 28 punti originali: 28 stabili, 28 con offset entro `1e-4 rad`, 0 ammissibili. I25 passa da 1.964 a 1.880 s ma l’overshoot cresce a 28.824%. Stage B esegue una sola griglia da 25 punti: 25 stabili, 25 con offset entro tolleranza, 0 ammissibili. E16 ha il minimo settling, 1.020 s, ma overshoot 40.6448%, peak control 35.170 N m e deformazione normalizzata 4.9922.

### Motivazione

Né il punto più rapido né quelli meno aggressivi raggiungono simultaneamente settling ≤0.8 s e overshoot ≤10%. Promuovere E16 violerebbe due requisiti e la regola che vieta l’adozione automatica di un estremo.

### Conseguenze e limiti

Nessun candidato è selezionato. Non vengono costruiti LQG-I finale, controller ordine 16, diagnostica Kalman/rumore o confronto finale M6/M7. M5, KF03, saturazioni e anti-windup restano invariati. La feasibility table è pubblicata per la decisione successiva del gruppo.

### Stato epistemico

**QUALITY GATE PERFORMANCE FAIL — M7 RESTA PARTIAL, SECONDO STOP RICHIESTO**

---

## D-0033 — Stop definitivo del tuning M7 dopo il co-tuning augmentato

**Data:** 2026-08-24
**Milestone:** M7 final feasibility

### Problema

Verificare un'ultima volta se il fallimento dei checkpoint dipendesse dal riuso delle priorità M6, ottimizzate per il regolatore senza integratore, senza alterare scale fisiche, architettura o target M5.

### Alternative

- modificare indiscriminatamente scale e priorità con una grande griglia;
- scegliere comunque E16 o il candidato C1 più rapido;
- applicare la ricerca strutturata C1–C3 e rispettarne i gate;
- cambiare M5, Kalman, architettura o iniziare M8.

### Metriche, criterio e scelta

È stata applicata la sola ricerca strutturata autorizzata. C1 ha valutato 75 combinazioni di `wq`, `wi` e `rhoU`, lasciando `wqdot=wthetaDot=0.5` e `wdelta=0.1`. Tutti i punti sono stabili e annullano gli offset, ma nessuno è ammissibile. C113 minimizza il settling a 1.026 s con overshoot 40.8714%, `peakU/uScale=2.08761` e `peakDelta/deltaScale=5.03633`. C161 raggiunge il minimo overshoot, 9.61367%, ma non si assesta entro l'orizzonte di 3 s (`Ts=Inf`).

Nessun C1 soddisfa la definizione di “promettente”: `Ts<=1.0 s`, oppure `OS<=15%` con `Ts<=1.2 s`. C2 non è quindi autorizzata e riceve zero seed; C3 non è necessaria né autorizzata. Non è stata eseguita alcuna Stage ulteriore.

### Motivazione

La frontiera di Pareto conferma un conflitto continuo: i punti più rapidi hanno overshoot 40–41%, mentre la riduzione dell'overshoot porta il settling oltre 2 s o fuori orizzonte e non riduce comando/deformazione. Nessun ranking secondario può sostituire i requisiti fondamentali `Ts<=0.8 s` e `OS<=10%`.

### Conseguenze e limiti

Nessun candidato finale è selezionato. KF03 non viene associato a un servo non ammissibile; controller ordine 16, separation principle, measured/estimated error e rumore restano `NOT RUN`. M5, modello, uncertainty set e checkpoint restano invariati. La prossima attività ammissibile è una revisione formale della specifica M5; altro tuning M7 e M8 non sono autorizzati.

### Stato epistemico

**ULTIMA FEASIBILITY M7 CONCLUSA — PERFORMANCE FAIL, M7 PARTIAL, REVISIONE FORMALE M5 RICHIESTA**

---

## D-0034 — Accettazione terminale della feasibility M7 e autorizzazione M8

**Data:** 2026-08-24
**Milestone:** chiusura M7 / avvio M8

### Problema

Stabilire se il mancato raggiungimento simultaneo di `Ts<=0.8 s` e `OS<=10%` richieda altro tuning M7 oppure possa essere conservato come risultato progettuale prima della validazione non lineare.

### Decisione

La feasibility M7 è considerata conclusa. Il mancato raggiungimento simultaneo dei target Ts/OS viene mantenuto come risultato progettuale, senza tuning ulteriore. M8 è autorizzata.

### Motivazione

Tre fasi indipendenti hanno verificato struttura integrale, servo 2-DoF e co-tuning del costo fisicamente normalizzato senza produrre un candidato ammissibile. Un'ulteriore ricerca cambierebbe il perimetro approvato senza nuova evidenza. La validazione Simulink/non lineare può invece procedere sul controllore M6 già completo e validato.

### Conseguenze e limiti

M7 resta `PARTIAL`, non `COMPLETE`. I checkpoint M7 e M5 restano invariati. Il controllore primario M8 è esclusivamente M6 (`K`, `L`, `Nr` dal dataset approvato); I25 può comparire soltanto come “representative integral benchmark” diagnostico. M8 non autorizza nuovo tuning LQR/LQI/Kalman e non autorizza M9.

### Stato epistemico

**M7 PARTIAL ACCETTATA COME RISULTATO TERMINALE — M8 AUTORIZZATA**

---

## D-0035 — Sezioni e criterio deterministico della RAS empirica M8

**Data:** 2026-08-24
**Milestone:** M8

### Problema

Definire una validazione non lineare riproducibile del controllore M6 senza
confondere una ricerca numerica su sezioni con un certificato della regione di
attrazione completa.

### Decisione

La sezione primaria usa perturbazioni `dq1/dq2`, velocità nulle, `theta`
traslata dello stesso `dq`, attuatori all'equilibrio e stimatore incrementale
nullo. La seconda sezione diagnostica modifica soltanto l'inizializzazione
dello stimatore, resa coerente con lo stato fisico. Il criterio usa gli ultimi
10% di 8 s, soglie 0.5°/0.02 rad/s/0.5°/0.05 rad/s, finitezza, limitatezza e
assenza di crescita; l'estensione a 12 s segue una regola deterministica.

La ricerca combina griglia 5×5 e 36 raggi con bisezione a 1° dentro il box
±60°. `60°` è esclusivamente un limite computazionale. Nessuna saturazione è
aggiunta e `uScale=12 N m` resta una normalizzazione M5.

### Risultato e motivazione

Entrambe le sezioni hanno 57/57 punti unici convergenti; tutti gli endpoint
radiali raggiungono il search box. I raggi campionati sono 60–78.3244° e
l'area poligonale è 14214 deg². Non essendo stata trovata una divergenza, la
curva pubblicata è una frontiera della ricerca, non una frontiera dinamica.

### Conseguenze e limiti

Il risultato dimostra convergenza soltanto nei punti esplorati. Non autorizza
estrapolazioni fuori dal box, certificazioni 14D, saturazioni hardware,
Monte Carlo o robustezza M4. I25 resta un “representative integral benchmark”
lineare già documentato e non entra nel gate M8.

### Stato epistemico

**APPROVATA COME STIMA EMPIRICA SU DUE SEZIONI — NON CERTIFICATO ANALITICO**

---

## D-0036 — Baseline M9 1-DoF a pesi M5 congelati e stop senza retuning

**Data:** 2026-08-25
**Milestone:** M9

### Problema

Stabilire come interpretare il risultato della sintesi nominale `mixsyn`
quando i pesi M5 approvati non producono `gamma<1`, senza alterare
retroattivamente le specifiche o anticipare M10 e l'analisi robusta.

### Alternative

- modificare `W1/W2` finché il target pesato risulta soddisfatto;
- introdurre `W3` o passare a `hinfsyn` nella stessa milestone;
- selezionare una diversa architettura o un precompensatore per migliorare il
  tracking;
- conservare la baseline 1-DoF richiesta, diagnosticarla e fermare il tuning.

### Decisione e criterio

Si adotta come unico risultato M9 la struttura `e=r-q`, `u=Kmix*e` ottenuta
con `mixsyn(G,W1,W2,[])`, pianta nominale M3 a 14 stati e pesi W1/W2 caricati
dall'artifact M5; `W3` resta assente. La norma stacked ricostruita
`10.2071033931` coincide con `gamma=10.2071036477` entro errore relativo
`2.495e-8`, ma supera uno. Anche i target di tracking risultano falliti.

La sintesi e la stabilità interna sono accettate come checkpoint tecnico;
M9 è classificata `PARTIAL`. Non si esegue alcun retuning automatico di M5 e
non si introduce una sintesi diversa senza nuova autorizzazione.

### Motivazione

Cambiare i pesi dopo aver osservato il risultato renderebbe M9 una campagna
di tuning non approvata e romperebbe la tracciabilità M5. Il fallimento
quantificato è informazione progettuale: `W1*S` resta elevato a bassa
frequenza e `W2*KS` ha il proprio picco a 33.4393 rad/s. Lo zero RHP Padé è
registrato a 133.3333 rad/s, ma la sola posizione dei picchi non consente di
attribuirgli l'intero fallimento.

### Conseguenze e limiti

M5, M6, M7, M8 e la pianta incerta M4 restano invariati. Non sono autorizzati
`hinfsyn`, mu-analysis, D-K iteration o dichiarazioni di Robust Stability e
Robust Performance. Il checkpoint richiede revisione tecnica prima di M10 o
di qualsiasi variazione delle specifiche.

### Stato epistemico

**BASELINE M9 VALIDATA — PERFORMANCE FAIL, M9 PARTIAL, NESSUN RETUNING**

---

## D-0037 — Pianta generalizzata M10 esplicita e confronto a specifiche congelate

**Data:** 2026-08-25
**Milestone:** M10

### Problema

Costruire l'interconnessione nominale richiesta da `hinfsyn` senza cambiare
il problema M9 e stabilire come interpretare un controllore numericamente
diverso ma con mappe chiuse e prestazioni coincidenti entro le tolleranze.

### Alternative

- usare direttamente `augw` come unica definizione della pianta;
- modificare pesi o architettura per ottenere `gamma<1`;
- costruire la pianta esplicita, validarla contro M9 prima della sintesi e
  usare `augw` soltanto come controllo incrociato;
- trattare ogni differenza nei coefficienti del controllore come una nuova
  soluzione sostanziale, indipendentemente dalle mappe ingresso-uscita.

### Decisione e criterio

Si adotta la pianta generalizzata 1-DoF con ingressi `[r;u]`, uscite
`[z1;z2;y]`, `e=r-q`, `z1=W1*e`, `z2=W2*u`, `y=e`, quindi
`P=[W1,-W1*G;0,W2;I,-G]`, `nmeas=2` e `ncont=2`. La costruzione mediante
interconnessione nominata è primaria; la forma analitica e `augw` sono audit
indipendenti.

Prima di chiamare `hinfsyn`, `lft(P,Kmix)` deve riprodurre la chiusura pesata
M9. Superato questo gate, è autorizzata una sola sintesi `hinfsyn` con opzioni
di default. Pesi M5, pianta M3, scaling, architettura e scenari rimangono
congelati.

Il risultato M10 è considerato quasi equivalente a M9 quando norma pesata,
mappe `S/T/KS`, mappe chiuse e poli coincidono entro le tolleranze numeriche
documentate, anche se le realizzazioni interne dei controllori differiscono.

### Risultato e motivazione

Il gate pre-sintesi è `PASS`: errore massimo sulla chiusura M9
`2.688e-12` e norma stacked `10.2071033931`. La sintesi produce
`gammaHinf=10.2071036477`; la norma ricostruita è `10.2071033931`, con
errore relativo `2.495e-8`. La differenza relativa tra i gamma M9/M10 è
`2.938e-13` e l'errore massimo delle mappe pesate è `1.274e-9`.

La stabilità interna e la coerenza dell'interconnessione sono confermate,
ma `gamma>1` e i target di tracking restano falliti esattamente come in M9.
Non emerge quindi alcuna giustificazione per modificare retroattivamente M5
o avviare retuning nella stessa milestone.

### Conseguenze e limiti

M10 è un checkpoint nominale `PARTIAL`: completa e valida la formulazione
esplicita `hinfsyn`, ma non soddisfa la performance pesata o temporale. Non
sono state introdotte `W3`, azioni 2-DoF, `hinfstruct`, incertezze M4,
mu-analysis o sintesi robusta. Ogni passo successivo richiede autorizzazione
separata.

### Stato epistemico

**INTERCONNESSIONE E SINTESI NOMINALI VALIDATE — M9/M10 QUASI EQUIVALENTI, PERFORMANCE FAIL**

---

## D-0038 — Campagna strutturata M11 finita e frontiera Pareto senza selezione forzata

**Data:** 2026-08-25
**Milestone:** M11

### Problema

Determinare quanto della prestazione full-order M10 sia riproducibile con
controllori implementabili di ordine non superiore a sei, mantenendo
identici pianta generalizzata, pesi e canali prestazionali.

### Alternative

- cambiare W1/W2 o aggiungere W3 per cercare artificialmente `gamma<1`;
- ampliare ordini, seed o numero di partenze dopo avere osservato i risultati;
- scegliere un controllore mediante uno score arbitrario che mescoli gamma,
  ordine e tracking;
- eseguire una campagna finita A0–A5 e conservare la frontiera ordine/gamma.

### Decisione e criterio

La campagna è congelata a sei famiglie: guadagno statico full, PI e PIDF
decentralizzati, quindi `tunableSS` full MIMO di ordine 2, 4 e 6. Sono usati
cinque start per famiglia, seed base `20260827`, e ogni record viene
classificato senza rimuovere fallimenti o instabilità.

Il rappresentante di famiglia è la soluzione stabile a objective finito con
objective minimo e tie-break sull'indice di start. Il confronto tra famiglie
usa la dominanza Pareto su solo ordine reale e norma pesata. Tracking e
disturbo restano diagnostiche esterne alla selezione `hinfstruct`.

### Risultato e motivazione

A0 e A1 non producono objective finiti; A2 produce quattro objective finiti
ma nessuna chiusura internamente stabile. A3, A4 e A5 hanno cinque start
stabili ciascuna. I rappresentanti sono A3 start 4, ordine 2,
`gamma=16.6418540`; A4 start 2, ordine 4, `gamma=11.6555347`; A5 start 5,
ordine 6, `gamma=10.2477452`.

Le tre soluzioni sono non dominate: ogni aumento d'ordine riduce gamma. A5
si avvicina al full-order M10 entro circa 0.40%, ma non domina A3/A4 in
ordine. Tutte le norme restano maggiori di uno e i target di tracking
falliscono. Non esiste quindi una base tecnica per imporre un singolo
controllore M11 o alterare retroattivamente M5.

### Conseguenze e limiti

M11 è `PARTIAL`: correttezza della campagna, ricostruzione e lower-bound
sanity sono `PASS`, mentre stabilità di tutti gli start, weighted performance,
tracking e cross-coupling globale sono `FAIL`. A3/A4/A5 sono trasmessi al
gruppo come frontiera Pareto. Non vengono eseguiti nuova campagna, retuning,
pianta incerta M4, mu-analysis o M12.

### Stato epistemico

**CAMPAGNA M11 VALIDATA — FRONTIERA A3/A4/A5, NESSUNA SELEZIONE AUTOMATICA, M11 PARTIAL**

---

## D-0039 — Selezione del controllore strutturato A5 per la mu-analysis M12

**Data:** 2026-08-25
**Milestone:** M12

### Problema

Selezionare, tra i candidati Pareto M11 congelati, il controllore da
sottoporre all'analisi formale NS/NP/RS/RP senza avviare una nuova sintesi.

### Decisione

Il gruppo seleziona `A5 — Full MIMO tunableSS order 6`. Il controllore deve
essere caricato esclusivamente da
`results/data/m11_hinfstruct_structured.mat`, usando il representative e lo
start già salvati. Non è autorizzato alcun nuovo run `hinfstruct`.

### Motivazione

A5 appartiene alla frontiera Pareto M11, riduce l'ordine da 18 di M10 a 6 e
mantiene la norma pesata molto vicina al riferimento full-order. Costituisce
quindi il trade-off ordine/prestazione scelto per l'analisi robusta. La
selezione non implica conformità a M5: weighted objective e tracking A5
restano falliti.

### Verifica sul controller congelato

L'artifact M11 conferma architecture A5, representative start 5, ordine
reale 6, stabilità interna `PASS`, objective solver `10.2477452425` e norma
pesata ricostruita `10.2476411502`. Questi valori sono letti dal dataset e
verificati dalla pipeline M12, non ricostruiti mediante nuova sintesi.

### Conseguenze e limiti

A3 e A4 restano alternative M11 congelate ma sono fuori dal perimetro
primario M12. M10 resta il riferimento nominale full-order. Controller,
uncertainty set M4 e pesi M5 non possono essere modificati durante M12. La
decisione autorizza sola analisi, non `musyn`, D-K iteration o M13.

### Stato epistemico

**APPROVATA DAL GRUPPO COME SELEZIONE DI ANALISI M12 — NON COME CONTROLLER CONFORME A M5**

---

## D-0040 — M13 come D–K feasibility study sul problema M4/M5 congelato

**Data:** 2026-08-25
**Milestone:** M13

### Problema

A5 M11 è nominalmente stabile, ma M12 certifica il fallimento di Robust
Stability prima del livello unitario M4. Occorre verificare se una sintesi
D–K può produrre un nuovo candidato senza trasformare il fallimento di A5 in
una giustificazione implicita per cambiare pesi o incertezze.

### Decisione

M13 viene autorizzata come D–K feasibility study sul problema M4/M5
congelato, non come revisione delle specifiche. Sono mantenuti invariati
`Punc` M12, i cinque blocchi M4, W1/W2 M5, `W3=[]`, l'architettura 1-DoF e la
partizione 2/2. È autorizzata una sola campagna valida full-order con cinque
iterazioni massime e history completa.

### Motivazione

A5 fornisce un punto di partenza nominalmente stabile e M12 dà una reale
motivazione per la sintesi robusta. Tuttavia M10 ha già stabilito un optimum
nominale full-order circa `10.207 > 1`; non è quindi lecito richiedere
objective <1 o usare un fallimento RP per ritunare M5 dentro M13.

Il tentativo iniziale con `Display='full'` è classificato
`ABORTED_TECHNICAL`: R2025b richiede input interattivo dopo ogni iterazione e
non ha restituito output. La ripresa con `Display='short'` è stata autorizzata
come prima e unica campagna M13 valida, lasciando identiche tutte le opzioni
matematiche.

### Risultato e conseguenze

La campagna valida completa 5/5 iterazioni e restituisce Kmu 2×2 di ordine
52, nominalmente stabile, con objective `10.4032233618`. Il risultato resta
maggiore di uno e viene conservato senza retuning o seconda campagna. M13 è
`COMPLETE` come sintesi e audit nominale; la certificazione indipendente
NS/NP/RS/RP del nuovo controller è fuori scope e richiede una M14 separata.

### Stato epistemico

**M13 COMPLETE COME SINTESI D–K — OBJECTIVE QUANTIFICATO, NESSUNA CERTIFICAZIONE RS/RP**

---

## D-0041 — Kmu recupera Robust Stability ma non Robust Performance

**Data:** 2026-08-25
**Milestone:** M14

### Problema

Stabilire con una verifica indipendente se il Kmu full-order M13 migliori la
robustezza rispetto ad A5 M12, senza interpretare l'objective `musyn` come
certificazione e senza modificare il problema M4/M5.

### Alternative

- usare il midpoint dei bound per dichiarare un miglioramento;
- confondere l'objective M13 con il margine `robgain` o con `wcgain`;
- ritunare pesi, incertezze o controllore dopo avere osservato NP/RP;
- riusare integralmente la pipeline M12 e classificare separatamente NS, NP,
  RS e RP dai rispettivi criteri.

### Decisione e criterio

Si adotta la quarta alternativa. Il confronto RS usa entrambi i bound e la
transizione di classificazione: `CLEAR_IMPROVEMENT` richiede bound Kmu
chiaramente superiori e una classe migliore. Kmu resta congelato a ordine 52;
non viene promosso a controllore conforme a M5 quando NP o RP falliscono.

### Risultato e motivazione

La stessa pipeline M12 restituisce per Kmu RS
`PASS_CERTIFIED`, margin `[1.25003698645,1.25257264120]`, mentre A5 era
`FAIL_CERTIFIED`, margin `[0.875899252687,0.882789198079]`. I delta sono
`+0.374137733765` e `+0.369783443123`; la transizione è quindi
`CLEAR_IMPROVEMENT` e certifica il recupero della Robust Stability.

La norma nominale Kmu è però `10.3917314574 > 1`; NP e RP restano
rispettivamente `FAIL` e `FAIL_CERTIFIED`. L'objective `musyn`
`10.4032233618` resta una metrica di sintesi, non una certificazione
alternativa.

### Conseguenze e limiti

M14 è `PARTIAL`: software e RS sono validati, ma la performance M5 non è
soddisfatta. Non vengono autorizzati retuning, seconda sintesi, riduzione del
controllore o M15. Kmu è conservato come candidato con stabilità robusta
certificata; ogni futura validazione non lineare richiede revisione e
milestone separate.

### Stato epistemico

**RS RECUPERATA E CERTIFICATA — NP/RP NON CONFORMI, M14 PARTIAL**

---

## D-0042 — Realizzazione LTI del disturbo M15 con stato fisico condiviso

**Data:** 2026-08-25
**Milestone:** M15

### Problema

Le formule richieste `q_d=S*Gd*d` e `u_d=-KS*Gd*d` sono stabili come mappe
closed-loop. Una cascata diretta di due oggetti `ss`, tuttavia, duplica la
realizzazione della pianta instabile contenuta in S e Gd. La simulazione nel
tempo dipenderebbe così da cancellazioni numeriche di modi instabili e può
produrre transitori spurii enormi.

### Decisione

Le mappe LTI del disturbo vengono realizzate con un unico stato fisico G/Gd
e gli stati del controllore. Le matrici interne sono quelle della chiusura
esplicita già usata in M9/M10; le uscite sono q e u. La realizzazione è
verificata stabile e conserva esattamente il significato delle formule
`S*Gd` e `-KS*Gd` senza ridurre il controllore.

### Motivazione e conseguenze

La scelta elimina un artefatto di rappresentazione, non modifica plant,
controller, pesi o risultati non lineari. Gli scarti LTI/NL del disturbo
diventano finiti e fisicamente interpretabili: massimi q 0.14209 rad per
Khinf e 0.08718 rad per Kmu. Non è usato `minreal` e non è eseguita alcuna
riduzione d'ordine.

### Stato epistemico

**APPROVATA COME CORREZIONE DI REALIZZAZIONE NUMERICA — NESSUNA MODIFICA DEL PROBLEMA M15**

---

## D-0043 — Percorso A e campagna Monte Carlo M16 congelata

**Data:** 2026-08-26
**Milestone:** M16

### Problema

Dopo M14/M15 occorre decidere se modificare specifiche e sintesi oppure
conservare i risultati negativi e completare la valutazione statistica
richiesta dalla traccia sull'insieme incerto M4.

### Alternative

- riaprire M5 e ritunare pesi o controllori;
- modificare M4 o aumentare i campioni dopo avere osservato i risultati;
- mantenere congelati M4/M5 e i controllori, usando M16 come sola evidenza
  empirica lineare comune.

### Decisione

Il gruppo approva il percorso A: M4, M5, M6 `Klqg`, M10 `Khinf` e M13
`Kmu` restano congelati. M16 usa 40 campioni prodotti da una sola sequenza
`usample` con seed `20260826` e generatore `twister`; gli stessi
`sampledValues(i)` sono applicati ai tre controllori. Sample 0 è soltanto un
benchmark nominale ed è escluso dalle statistiche.

Non sono autorizzati sintesi, retuning, riduzione, saturazione, prefilter,
2-DoF, modello non lineare incerto o M17 dentro M16. Il replay del seed è
ammesso esclusivamente come audit e non alimenta le simulazioni.

### Motivazione

Il fallimento prestazionale M5 è già informazione progettuale verificata.
Cambiare il problema dopo avere osservato M10–M15 romperebbe la
tracciabilità. La campagna comune permette invece un confronto paired equo e
riproducibile, preservando la distinzione fra certificazione mu M14,
simulazione non lineare nominale M15 ed evidenza empirica lineare M16.

### Conseguenze e limiti

M16 può essere `COMPLETE` anche in presenza di campioni instabili o target
falliti, purché campagna, ricostruzioni e software siano corretti. Il Monte
Carlo non costituisce una garanzia robusta né una stima di probabilità
fisica. Un campione Kmu instabile avrebbe invece bloccato metodologicamente
M16 per contraddizione con M14; la campagna eseguita risulta coerente, con
Kmu stabile 40/40. M6 è stabile 39/40 e il Sample 5 instabile viene
conservato senza sostituzione.

### Stato epistemico

**APPROVATA DAL GRUPPO — M16 COMPLETE COME VALUTAZIONE EMPIRICA LINEARE,
NESSUNA SELEZIONE FINALE DEL CONTROLLORE**

---

## D-0044 — Selezione finale gerarchica e per ruolo

**Data:** 2026-08-27
**Milestone:** M17

### Problema

Trasformare le evidenze congelate M6–M16 in una scelta finale trasparente
senza inventare un controllore conforme a tutte le specifiche M5 e senza
combinare certificazione μ, Monte Carlo, RAS, tracking e ordine in uno score
arbitrario.

### Alternative

- imporre un vincitore assoluto mediante somma pesata di grandezze
  semanticamente incompatibili;
- scegliere una tecnica in base al nome senza verificare gli artifact;
- riaprire sintesi, tuning o riduzione per nascondere gli esiti negativi;
- applicare una gerarchia distinta per robustezza formale, prestazione
  nominale e ruolo metodologico H∞.

### Decisione e criterio

Si adotta la quarta alternativa. Il ruolo **FINAL ROBUST CONTROLLER**
richiede prima una certificazione RS sullo stesso insieme M4 e poi assenza di
contraddizioni empiriche M16. Il ruolo **NOMINAL PERFORMANCE REFERENCE**
richiede conformità del tracking M5 nominale non lineare e conserva come
limite la stabilità Monte Carlo. Il ruolo **H-INFINITY REFERENCE** identifica
l'architettura full-order H∞ congelata come comparatore metodologico.

La regola, applicata agli artifact, assegna:

- M13 `Kmu` a **FINAL ROBUST CONTROLLER**;
- M6 `Klqg` a **NOMINAL PERFORMANCE REFERENCE**;
- M10 `Khinf` a **H-INFINITY REFERENCE / COMPARATOR**.

### Evidenze determinanti

Kmu è l'unico candidato primario con RS M14 `PASS_CERTIFIED`, margine
`[1.25003698645,1.25257264120]`, ed è stabile 40/40 nella campagna M16.
Restano però NP `FAIL`, RP `FAIL_CERTIFIED`, tracking M15 `FAIL` e ordine 52.

M6 è l'unico candidato che supera tracking, overshoot, errore e
cross-coupling M5 nel nominale non lineare M8; nella campagna M16 è stabile
39/40 e il Sample 5 instabile è preservato. Non gli è attribuita alcuna
certificazione RS o RP.

Khinf è stabile 40/40 in M16 ma fallisce tracking e weighted performance.
M12 certifica A5 M11, non Khinf M10: perciò RS e RP del candidato Khinf
restano N/A.

### Conseguenze e limiti

Nessun controller è dichiarato conforme a tutte le specifiche M5. La RS
Kmu non viene promossa a Robust Performance; M16 resta evidenza empirica e
le RAS restano stime non certificate. `uScale=12 N m` resta una
normalizzazione e non una saturazione hardware. Nessuna riduzione di Kmu,
nuova sintesi, retuning, revisione M4/M5 o attività M18 è autorizzata in
M17.

### Stato epistemico

**APPROVATA DAI DATI M6–M16 — SELEZIONE PER RUOLO, NESSUN VINCITORE
ASSOLUTO E NESSUNA CONFORMITÀ GLOBALE M5 DICHIARATA**

---

## D-0045 — Refactoring didattico e unico insieme incerto M4

**Data:** 2026-09-01
**Milestone:** revisione strutturale conclusiva

### Decisione

M0–M5 vengono presentate come un'unica macrofase didattica. Le scelte di
attuatore, specifiche, costo LQR e covarianze Kalman sono dichiarate
direttamente e verificate; non sono più ottenute mediante prodotti
cartesiani, classifiche o selettori automatici.

M4 contiene un solo insieme: `Jm1`, `k1`, `k2`, `wn` e `zeta` variano del
±10%, il ritardo del ±20%. La famiglia attuatore resta coperta da WI di
ordine 1. M5 e i controllori M6, Khinf e Kmu restano congelati.

### Conseguenze

Sono state rimosse le funzioni e gli artifact delle ricerche non più
coerenti. M12 e M14 sono state ripetute sul dominio M4 corrente senza
rilanciare M13: A5 fallisce RS con margine `[0.849720,0.859945]`; Kmu
mantiene RS certificata con `[1.069561,1.212875]` e fallisce RP. M16 resta
una campagna empirica comune 39/40, 40/40, 40/40 e non sostituisce M14.

### Stato epistemico

**APPROVATO COME SEMPLIFICAZIONE DIDATTICA; NESSUNA NUOVA SINTESI O
CERTIFICAZIONE ATTRIBUITA ALLA MONTE CARLO.**

## D-0046 — Revisione tecnica nominale di Lyapunov e trasparenza LQG

Data: 2026-09-08/09. Responsabile: Alessio.

### Decisione

Si recepisce la revisione tecnica richiesta dopo la PR 26. M5 e i controllori M6, M10, M13 restano congelati. La scelta LQR30 con 9/36 ammissibili appartiene alla revisione precedente: la ricerca viene riprodotta a parità di candidati e criterio, non riaperta. La rimozione delle ricerche M3–M7 descritta in D-0045 non descrive più M6; il replay corrente mantiene la ricerca M6 già approvata nella PR 26.

La normalizzazione distingue qs=5 gradi, qds=12 qs, ds=0.5/40 rad e uScale=12 N m dai pesi adimensionali wq=2, wv=1, wdelta=0.1 e rhoU=16. Le sigma Kalman sono ipotesi del progetto, non dati del docente. Una sensibilità semplice varia solo la covarianza assunta, mantenendo identico il rumore applicato.

### Metodo e alternative

Una ricerca numerica di Vdot su punti finiti, da sola, non certifica una RAS. Per questo si affianca al livello campionato una condizione sufficiente analitica: maggiorazione cubica del resto nominale e P dall'equazione di Lyapunov sul sistema completo. Sono inclusi 28/32/66 stati rispettivamente per LQG/Khinf/Kmu. Si evita di certificare soltanto il sottosistema fisico omettendo osservatore o controllore dinamico.

Si conserva QL=I nelle coordinate numeriche correnti. Un'ottimizzazione del certificato, cambi di coordinate più sofisticati o aritmetica intervallare restano sviluppi futuri. La doppia precisione e il controllo dei residui non sono una prova formale degli arrotondamenti.

### Conseguenze

- Il limite analitico è molto conservativo, nominale, senza saturazioni e con Padé 1; non è una RAS massima.
- Il livello campionato più ampio e le mappe M8/M15 restano evidenze numeriche.
- Le 48 traiettorie aggiuntive non ampliano il certificato.
- M14 e M16 non sono riclassificate; i conteggi correnti M16 sono 38/40, 40/40, 40/40, con Sample 5 e 6 M6 instabili. Il precedente 39/40 in D-0045 è storico.
- Non viene eseguito run_all perché rilancerebbe M9–M11. Sono eseguiti suite completa, script didattici, validatori e rigenerazione grafica a controllori congelati.
- I flag M18 descrivono soltanto il generatore documentale; la suite completa non viene più dichiarata PASS da una funzione che non la esegue.

### Stato epistemico

METODO IMPLEMENTATO ED ESEGUITO. Bound analitico sufficiente sul nominale, con matrici e residui verificati in doppia precisione; nessuna verifica intervallare e nessun nuovo certificato robusto M4.

## D-0047 — Conservazione delle traiettorie mediante Git LFS

Data: 2026-09-09. Responsabile: Alessio.

Per pubblicare il lavoro richiesto dal gruppo senza perdere dati, il solo
artifact results/data/lyapunov_trajectories.mat viene gestito tramite Git LFS.
Il push ordinario è stato rifiutato per la dimensione di 260319104 byte.
Non si riducono campioni o precisione e non si ripetono simulazioni.

La conversione riguarda il formato di archiviazione Git, non i byte del MAT
disponibile nel working tree. Si adegua il solo commit locale mai pubblicato;
main e la cronologia remota sono preservati. Per ottenere i dati completi
dopo il clone occorre Git LFS. La decisione non autorizza un merge automatico.

## D-0048 — Studio mirato LQI e H-infinity separato dalla baseline

Data: 2026-09-10. Responsabile: Alessio.

La revisione autorizzata riguarda §7.6, capitolo 8 e impaginazione.
Il working tree iniziale è pulito e coincide con origin/main dopo PR 27.
Il gruppo conferma che le ulteriori modifiche di Valerio non sono ancora
pubblicate: saranno integrate quando disponibili, senza ricostruirle.
Il prefisso del capitolo 7 precedente alla sezione LQI resta intatto.

LQI è un servo a stato vero di 16 stati, non LQG con stima. Il punto
wi=1, rhoU=8 viene ripreso da M7 soltanto per illustrare la reiezione
di disturbi costanti: non è una nuova scelta di controllore finale.
Tre calcoli a rhoU=16 fisso separano l'effetto di wi dal cambio di R.

La nuova campagna H-infinity è ammessa in deroga al congelamento storico
solo come studio separato: 13 candidati deterministici più una conferma
hinfsyn e un diagnostico solo-comando. W1 conserva As e Ms; W2 passa
a una specifica normalizzata alle scale di 5 gradi e 12 N m (requisito
meno restrittivo dichiarato, non mera conversione di coordinate).
W3 è una scelta nominale di roll-off, non requisito quantitativo del docente
né certificato per l'incertezza moltiplicativa all'ingresso M4.

Tutti i candidati sono nominalmente stabili; nessuno soddisfa gamma<1
e tutti i target M5. ID 10 è selezionato dal criterio temporale esplicito,
non dal gamma minimo. Non viene adottato: M9–M16 restano invariati,
senza nuova D–K o post-analisi mu. Anche i risultati negativi e i cinque
campioni empirici sono salvati. Non sono autorizzati commit o pubblicazione.

I test esistenti vengono estesi nelle verifiche pertinenti, senza creare
nuovi file di test. La suite globale è riservata alla fase conclusiva.

## D-0049 — Pubblicazione della revisione mirata già validata

Data: 2026-09-10. Responsabile: Alessio.

La richiesta successiva del gruppo autorizza la pubblicazione del lavoro
già concluso, superando esclusivamente il divieto di commit e pubblicazione
di D-0048. Si prevede un commit della revisione sul branch
`codex/lqi-hinf-targeted-review`, push su origin e PR verso `main`,
da lasciare aperta per revisione manuale. Non sono autorizzati merge
automatici, modifiche dirette a main o ulteriori interventi tecnici.
La logica del codice, dati, figure, PDF e verifiche già registrate restano
invariati durante questa operazione Git; è ammessa la sola pulizia di
whitespace necessaria al controllo del diff.

## D-0050 — LQRI con Kalman M6 e parametrizzazione diretta di R

Data: 2026-09-14. Responsabile: Alessio. Stato: APPROVATA DAL GRUPPO.

La richiesta successiva sostituisce l'architettura M7 a stato fisico
disponibile con un servo LQRI: `u=-Kx*xhat-Ki*xi`, `xi_dot=r-q_measured`.
Il filtro M6 continua a stimare solo i 14 stati fisici, con L/Qn/Rn
invariati; i due integratori sono stati interni calcolati dall'errore misurato.
Si elimina il prefiltro M7 e si verifica la chiusura completa a 30 stati.
La decisione supera la sola parte M7 di D-0048; H-infinity resta invariata.

R viene costruita direttamente da ru, con griglia M6 {1/36,1/18,1/9}.
Le matrici numeriche R dei 36 candidati sono identiche a quelle precedenti:
non si esegue un nuovo retuning M6. La scala prestazionale M5 uScale
resta valida negli altri usi, ma non normalizza più R.

Per la sensibilità M7 si conservano tre wi={0.1,1,4}, mantenendo Q M6 e
R=(1/9)I2 fissi. La scala integrale esistente è conservata per evitare
un ulteriore cambiamento implicito del costo. wi=1 è scelto a priori
come punto illustrativo, senza attribuirgli conformità M5 non dimostrata.

Le modifiche restano circoscritte a M6/M7 e alle dipendenze documentali.
Il percorso run_all con CR_RUN_SCOPE=lqri non esegue M8-M17; il percorso
completo storico rimane disponibile e distinto. È autorizzata la
pubblicazione su branch dedicato e PR verso main, senza merge automatico.

## D-0051 — Revisione diretta e circoscritta di W1/W2, R e Qi

Data: 2026-09-16. Responsabile: Alessio. Stato: RICHIESTA APPROVATA;
verifica finale della realizzazione in corso.

La richiesta corrente supera il congelamento dei soli pesi/controllori
coinvolti da D-0050: R M6 usa {0.01,0.05,0.10}; Qi M7 usa direttamente
{20,200,800}; W1/W2 sono rivisti nelle coordinate fisiche mediante una
ricerca limitata a 8+4 candidati. Restano fissi M0–M4, target M5, Kalman
M6 e criteri PASS/FAIL. omegaW1 è separato da omegaB per non modificare Q.
W3 è presente solo nello studio, non nella produzione M9/M10.

La selezione ha attivato omegaW1=8, As=0.15, Ms=2.5, ku=0.05, omegaU=60,
alpha=6. Nessuno dei candidati H-infinity è conforme; non sono autorizzate
ulteriori ricerche per forzare un PASS. R=0.10 I2 è selezionato dai criteri
esistenti. La LQRI illustrativa usa Qi=200 I2 e rimane PARTIAL.

Poiché i controllori cambiano, sono rigenerate le sole dipendenze downstream,
inclusa una nuova M13. M14 dimostra RS negativa per Kmu corrente: nessun
trasferimento del certificato storico, nessun ruolo robusto assegnato.
M16 mantiene valore esclusivamente empirico.

Il limite RAS M15 di 400 esecuzioni non copriva il caso peggiore della
ricerca già prevista. Viene derivato un limite finito di 626 dalla griglia,
dalle 36 direzioni, dalla tolleranza radiale di 1 grado e dalle due durate
8/12 s per punto. Nessuna soglia o durata è rilassata; il checkpoint serve
soltanto a evitare ripetizioni. Questa è una correzione del budget di
esecuzione, non una nuova ricerca di parametri del controllore.

Prima della pubblicazione devono essere mostrati git status, diff stat e
il resoconto tecnico autosufficiente; nessun merge automatico.

## D-0052 — Retuning nominale H-infinity separato dalla baseline

Data: 2026-09-17. Responsabile: Alessio. Stato: REVISIONE RICHIESTA DAL GRUPPO,
implementata su branch dedicato; merge e adozione definitiva da controllare.

La richiesta corrente autorizza esclusivamente la revisione H-infinity,
superando il precedente divieto di ulteriori ricerche in D-0051 per questo
studio limitato. M0--M8, specifiche generali M5 e modello incerto restano fissi.
I nuovi pesi non sono scritti in M5 e non sostituiscono gli artifact esistenti.
Prima fase: 12 profili accoppiati; unico ampliamento: 9 profili. Bound prima
di ogni sintesi; una coppia esclusa senza solver. Target temporali rivisti
fissati prima dei risultati: 2 s, 20% overshoot, 20% offset, cross .25.
Nessun target viene alterato per ottenere PASS.

Si seleziona omegaW1=2, As=.20, Ms=4, ku=.003, omegaU=80, alpha=6:
gamma full-order .866036. La riduzione della penalizzazione di comando e
sostanziale, motivata dal conflitto di stabilizzazione con la prima griglia;
il picco di 13.31 N m è esplicitamente riportato, senza certificato hardware.
Hinfstruct usa dieci RandomStart oltre a quello nominale per famiglia:
ordine minimo riuscito 6. Il tracking 1-DoF resta non conforme.

Il prefiltro 2-DoF è un'estensione nominale distinta; migliora il tracking
ma la nuova norma pesata è 1.381480. Non si trasferisce il PASS del feedback.
La coppia disturbante lato link M5 è verificata separatamente, mantenendo
l'equivalenza del problema mixed sensitivity fra mixsyn e hinfsyn.
Capitolo 9 e catena robusta non modificati: nessuna garanzia storica sui nuovi K.
