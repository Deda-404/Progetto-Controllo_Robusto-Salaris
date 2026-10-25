# Ristrutturazione didattica SEA: audit e proposta scientifica

Data: 25 ottobre 2026. Responsabile: Alessio.
Branch: `codex/ristrutturazione-didattica-sea`.
Base verificata dopo fetch: `origin/main`, commit
`0ed5611fdbb9c46475543f87eba68d9799b07bc5`.
PR esaminata: [#43](https://github.com/Deda-404/Progetto_CR/pull/43), head
`d3074e941c85917ae85e41e4762f91eb8417a55a`, aperta in bozza e senza commenti
di approvazione alla data della verifica.

**Stato: FASE 0 COMPLETE / PASS; FASE 1 PARTIAL / decisione richiesta.
FASE 2-8 NOT RUN. Il progetto ristrutturato e il relativo ZIP non sono ancora
prodotti o validati.** Questo documento è il primo avanzamento del report
richiesto, da completare dopo l'approvazione delle scelte scientifiche.

## 1. Fonti e confini dell'autorizzazione

Sono stati consultati la [traccia ufficiale SEA](https://drive.google.com/file/d/1-oXYqX_l1EJ7Tsd0Lubur3a1zqEi7ro7/view),
`AGENTS.md`, decisioni e diario, sorgenti e dati di main, relazione e
presentazione di main, sorgenti/CSV/elaborati della PR #43 e le due cartelle
Drive indicate nel mandato. Drive è stato usato esclusivamente in lettura.
La traccia lascia libere la selezione dei pochi parametri incerti e le relative
percentuali; non impone di mantenere i tre parametri meccanici M4 incerti.
Richiede comunque LQG con/senza integratore, mixsyn/hinfsyn e confronto,
esplorazione hinfstruct, D-K, post-analisi robusta, implementazioni lineari e
non lineari MATLAB/Simulink, RAS e circa dieci impianti campionati.

Le indicazioni del ricevimento effettivamente disponibili sono i resoconti
scritti del 24 ottobre nella PR #43. Non è stata individuata nel materiale
consultato una trascrizione autonoma dell'audio: non si attribuiscono al docente
contenuti ulteriori. Il mandato corrente prevale sulle precedenti preferenze
organizzative e chiede espressamente approvazione prima della semplificazione
scientifica.

Le scelte già approvate e implementate sono distinte dalla proposta nuova:

| Elemento | Stato e trattamento |
|---|---|
| Meccanica della traccia e stato a 8 coordinate | Conservati |
| Equilibrio qbar = [pi/2;0], theta coerente, velocità nulle | Approvato D-0003, conservato |
| Attuatori nominali wn = 40 rad/s, zeta = 0.8, tau = 15 ms, Padé1 | Approvato D-0006, conservato |
| Encoder [q;theta] per LQG/LQGI; q per i robusti | Conservati senza cambiare le architetture |
| M4: k1,k2,Jm1 ±10%; dispersioni wn/zeta ±10%, tau ±20% nel peso | Famiglia storica conservata con i propri certificati |
| Q/R, Kalman, W1/W2/Mo e sei controllori consolidati | Conservati; nessuna nuova selezione o promozione |
| MuN1 a 82 stati e candidati con rumore | Restano candidati separati; nessuna adozione implicita |
| Modelli della PR43 e riduzione a 60 stati | Studio esistente, adozione ancora proposta |
| Nuova riduzione delle incertezze S1 | **DA APPROVARE**, descritta al §6 |

## 2. Stato iniziale e inventario completo

L'inventario copre tutti i **1125 file tracciati di main** e tutti i **1275
file dell'unione main/PR43**. Main contiene 259 sorgenti MATLAB, 240 MAT e
19 file SLX: gli otto in `simulink/student_originals/` sono un sottoinsieme
distinto dalle copie storiche. La PR modifica o aggiunge 167 file; 150 sono
aggiunte, senza rimuovere file di main.

Ogni file ha una riga in
[`audit_ristrutturazione/inventario_file.csv`](audit_ristrutturazione/inventario_file.csv),
con origine, blob Git delle due versioni, dimensione, azione proposta,
motivazione e destinazione. Le azioni riguardano la **futura consegna**:
ARCHIVIATO significa conservato nel repository, escluso dal percorso minimo.
Nessun file storico è stato spostato, eliminato o riscritto scientificamente.
Nessuna voce richiede ELIMINATO: le copie superflue saranno escluse dallo ZIP,
senza distruggere la storia.

La classificazione è una proposta ragionata, non una prova automatica di
inutilità. Il grafo lessicale contiene riferimenti candidati, anche in commenti:
assenza di un arco non autorizza a cancellare una funzione. Le dipendenze
MATLAB effettive e i caricamenti sono registrati separatamente.

### Punti di ingresso e dipendenze reali

| Ingresso | Dipendenze MATLAB statiche, incluso l'ingresso | Criticità concreta |
|---|---:|---|
| progetto_lqg.m | 14 | Ricerca LQR, Lyapunov e grafici richiamano altre cartelle; scrive un MAT e può rigenerare una validazione mancante |
| progetto_lqgi.m | 3 | Il grafico richiamato carica altri MAT e produce output nel repository |
| progetto_hinf_tre_controllori.m | 4 | Tre helper e MAT esterni; esportazione dei candidati con rumore attiva nel default |
| progetto_mu.m | 1 | Procedimento interno al file, ma più MAT esterni; ricalcola l'analisi robusta nel default |
| run_all.m | Ingresso di verifica e scope storici | Non è l'avvio semplice del futuro pacchetto |

L'unione delle quattro chiusure statiche comprende **21 file MATLAB**.
Fonte: `audit_ristrutturazione/dipendenze_matlab.json`, prodotto da
`matlab.codetools.requiredFilesAndProducts` in R2026b. Non comprende tutti i
caricamenti a runtime: `riferimenti_mat.json` elenca i letterali trovati nei
sorgenti, inclusi riferimenti commentati e scritture da distinguere manualmente.

I MAT letti dagli ingressi includono M3, M5, M6, M7, M4 e gli archivi
`nominal_study`, `selected_full_order`, `fixed_PID`, `m12`, `m13`, `m14`,
`robust_study`; i grafici storici aggiungono archivi M8/M15/Lyapunov. Le
sezioni sul rumore leggono anche `hinf_noise_03` e `mu_noise_01`. La nuova banca
portabile dovrà estrarre solo le variabili usate, conservando gli archivi
originali e verificando l'identità delle realizzazioni. Non è sufficiente
copiare la sola cartella dei quattro script.

Duplicati MATLAB esatti verificati:

- `analysis/progetto_lqg.m` e la copia accorpata;
- `analysis/progetto_lqgi.m` e la copia accorpata.

Sono duplicati anche due checklist e numerose figure fra results/report/assets;
l'elenco esatto è in `audit_ristrutturazione/duplicati.json`. I duplicati degli
SLX sono solo riferimenti da conservare, senza riorganizzarli. La directory
iniziale della chat contiene un Git vuoto; il repository valido è questa
cartella `Progetto_CR_finale`. La vecchia copia `Progetto_CR_chiusura` ha un
collegamento worktree non più risolvibile: non viene usata come fonte corrente.

## 3. Riuso critico della PR #43

| Materiale | Esito dell'audit |
|---|---|
| LFT manuale meccanica e attuatori | Da conservare come derivazione verificata; adattamento solo dopo approvazione |
| Correlazione delle occorrenze di wn | Da conservare: due occorrenze nella costruzione manuale, cinque in quella automatica esaminata |
| Residuo additivo del ritardo | Correzione concettuale utile; nel percorso semplificato proposto non serve modellare il ritardo esatto |
| A pieno, A diagonale, B parametrico | Troppi casi per il nuovo percorso principale; restano studio storico |
| Sei schemi TikZ | Recuperabili, con segnali e convenzioni da riallineare |
| NS/NP/RS/RP e controlli di monotonia | Riutilizzare la logica di verifica e gli esiti inconclusivi espliciti |
| Dieci impianti e dieci condizioni iniziali | Metodo riutilizzabile; i nuovi campioni devono corrispondere al nuovo insieme approvato |
| Catena salaris_*.m | Non importare come nuova architettura; integrare il ragionamento nei numerati |
| CSV e MAT PR43 | Evidenze delle sole famiglie PR43, senza trasferirne margini ai nuovi modelli |
| Risintesi A/B e riduzioni 82/70/60 | Conservare risultati; non ripetere la campagna né promuovere candidati automaticamente |

**Convenzione da correggere:** il mandato attuale chiama **A il parametrico**
e **B il concentrato**. La PR43 usa le lettere al contrario. Nei nuovi script
si useranno i nomi estesi insieme alla lettera; i CSV storici manterranno i
propri nomi originali, con una legenda, senza rinominarli silenziosamente.

Due intervalli Hinf2 della PR43 violano la monotonia attesa rispetto
all'inclusione degli insiemi e sono già marcati inconclusivi. La nuova analisi
non li userà come evidenza di superiorità di un modello. Le prestazioni
rilassate della PR43 non saranno presentate come rispetto dei target M5.

## 4. Relazione e presentazione da preservare

Il PDF di main ha **108 pagine** e la presentazione **23 slide**; la PR43 ha
23 pagine e 18 slide. Il nuovo `report/main.tex` della PR43 include soltanto
`sections/salaris_revision`: le precedenti sezioni restano nel repository ma
non vengono più compilate nel documento principale.

Sono stati fortemente ridotti nel nuovo percorso il progetto esplicito di Q,
la sintesi e la realizzazione LQGI, il confronto mixsyn/hinfsyn sullo stesso
problema 1-DoF, gli schemi autentici Simulink e lo studio del rumore con i suoi
vantaggi e peggioramenti. Questi risultati significativi devono essere
recuperati da main in forma compatta; non basta una menzione dei nomi dei
controllori. Non si sostituirà integralmente la relazione di main con quella
della PR43. Le parti molto estese di ricerca/Lyapunov resteranno accessibili
come storia, separando risultati scientifici utili e dettagli di sviluppo.

Il nuovo indice seguirà i dodici capitoli del mandato, con più spazio per
attuatori, rappresentazioni, confronto robusto e conclusioni. L'orale conserverà
un budget inferiore a venti minuti e tutti i metodi richiesti; durata reale da
verificare con prova cronometrata. Nessun nuovo PDF è stato prodotto in questa fase.

## 5. Alternative scientifiche studiate

Sono state valutate quattro selezioni di parametri per attuatore, senza
adottarne nessuna: wn; wn/zeta; wn/tau; zeta/tau. Per ogni parametro sono
stati esaminati cinque valori normalizzati [-1,-0.5,0,0.5,1], variando un solo
parametro alla volta negli intervalli storici. Non è una griglia cartesiana
né un'ottimizzazione di robustezza. Sono stati confrontati errore relativo
complesso e fase, con il nominale e lo stesso Padé1.

| Parametro variato | Valori provati | max errore relativo fino a 12 rad/s | fino a 40 rad/s | max variazione di fase fino a 40 rad/s |
|---|---|---:|---:|---:|
| wn [rad/s] | 36,38,40,42,44 | 5.53% | 16.41% | 7.54 gradi |
| zeta | 0.72,0.76,0.8,0.84,0.88 | 4.77% | 11.11% | 3.02 gradi |
| tau [ms] | 12,13.5,15,16.5,18 | 3.58% | 11.18% | 6.41 gradi |

Fonte numerica: `audit_ristrutturazione/sensibilita_attuatori.csv`.
Queste misure riguardano il blocco attuatore, non il margine robusto del SEA.
Il ritardo resta rilevante: la sua esclusione dalla variabilità richiede una
decisione di scopo, non discende da una presunta trascurabilità fisica.

| Selezione | Vantaggio | Costo o informazione persa |
|---|---|---|
| Solo wn | Un solo parametro fisico per canale | Non varia smorzamento né latenza |
| wn/zeta | Varia rapidità e forma del secondo ordine; Padé comune | Non varia latenza; wn è ripetuta nella LFT |
| wn/tau | Varia rapidità e fase del ritardo | Smorzamento fisso; rapporto fra Padé differenti non è automaticamente stabile |
| zeta/tau | Poche occorrenze reali nella costruzione esaminata | Frequenza naturale fissa; stessa attenzione al rapporto dei Padé |

Gli errori nominali fra le quattro costruzioni candidate e il nominale sono
inferiori a 7e-16 sulla griglia esaminata. Le occorrenze automatiche sono
5 per wn e 1 ciascuna per zeta/tau: sono proprietà della realizzazione,
non numeri di parametri fisici indipendenti. La LFT manuale della PR43
mostra che wn può essere conservata come lo stesso scalare ripetuto due volte.

## 6. Proposta S1 da approvare integralmente o correggere

**Nessuno dei seguenti punti è stato adottato o inserito nei parametri di produzione.**

1. Conservare i nominali, l'equilibrio, le misure, i disturbi, i pesi e la
   banca consolidata. Usare come unico confronto principale **wn e zeta
   indipendenti per ciascun attuatore, entrambi ±10%**. Il ritardo resta
   **noto a 15 ms, rappresentato con Padé1**, senza residuo dinamico aggiuntivo.
2. Tenere **nominali i parametri meccanici nel nuovo confronto centrale**,
   per isolare l'effetto della rappresentazione attuativa. Conservare M4,
   incertezze k1/k2/Jm1 e relativi risultati in una sezione storica esplicita.
   È una restrizione dell'insieme del problema, non una equivalenza con M4
   né una dichiarazione di assenza delle dispersioni reali.
3. Costruire **A parametrico** con quattro scalari reali indipendenti:
   wn_i = 40(1+0.1 delta_wn_i), zeta_i = 0.8(1+0.1 delta_zeta_i).
   La struttura manuale proposta è
   Delta_A = diag(delta_wn1 I2, delta_zeta1, delta_wn2 I2, delta_zeta2).
   Le ripetizioni di wn restano correlate; i due attuatori restano indipendenti.
4. Costruire **B concentrato diagonale** con due blocchi dinamici SISO
   indipendenti: G_B = G_0 diag(1+WI Delta_1,1+WI Delta_2),
   con Delta_i stabile, proprio e norma H-infinity non superiore a uno.
   Escludere il blocco pieno 2x2 dal percorso principale perché aggiunge
   accoppiamenti non presenti nei due drive SISO.
5. Per WI usare la maggiorazione analitica di primo ordine descritta sotto,
   da verificare in codice dopo approvazione. Non riprendere il peso M4:
   copre una diversa dispersione. I pesi **prestazionali** rimangono quelli
   consolidati; eventuali loro rilassamenti successivi richiedono una
   proposta esplicita con l'elenco dei requisiti persi.

La scelta wn/zeta conserva due effetti fisici distinti con un Padé nominale
comune e permette una spiegazione semplice dell'inviluppo concentrato.
L'alternativa con tau incerto resta scientificamente legittima, ma richiede
un'altra scelta coerente di rappresentazione del ritardo.

### Costruzione proposta di WI e inclusione degli insiemi

Posto H = wn^2/(s^2+2 zeta wn s+wn^2), il Padé fisso è comune e si cancella
algebricamente nel rapporto G_A/G_0. L'errore relativo è

    E = H/H0 - 1 = (alpha s^2 + beta s)/(s^2+2 zeta wn s+wn^2)
    alpha = wn^2/40^2 - 1
    beta  = 2*0.8*wn^2/40 - 2*zeta*wn

Su wn in [36,44], zeta in [0.72,0.88], risultano |alpha| <= 0.21 e
|beta| <= 14.08 rad/s. Per 0 < zeta <= 1 vale

    |(j omega)^2+2 zeta wn j omega+wn^2| >= zeta*(omega^2+wn^2).

Quindi una scelta analiticamente sufficiente, proposta e non ancora
implementata nel nuovo modello, è

    WI(s) = c*s/(s+36),
    c = hypot(0.21,14.08/36)/0.72 = 0.6165601466349685.

Infatti E/WI = (alpha s+beta)(s+36)/(c*(s^2+2 zeta wn s+wn^2))
è stabile e proprio e ha modulo non superiore a uno sull'asse immaginario
per tutto il box. Il valore all'origine è definito per continuità: E e WI
hanno entrambi uno zero in zero. Si ottiene così A contenuto in B per i
due canali indipendenti. Il viceversa non segue: B ammette dinamiche non
parametriche. La maggiorazione può essere conservativa; non dimostra che
B sia una scelta peggiore per ogni scopo o che una D-K troverà una soluzione.

La giustificazione usa il Padé identico: non garantisce tutti i ritardi
esatti. Con tau incerto, il rapporto dei Padé diversi può lasciare un polo
RHP dal denominatore nominale; un fit del solo modulo non basta a costruire
una perturbazione stabile. È il motivo per cui la scelta di scopo va resa
esplicita e approvata, anziché nasconderla nel peso.

## 7. Struttura proposta e riuso dei controllori

    Progetto_SEA_Consegna/
      00_AVVIO_PROGETTO.m
      01_MODELLI_INCERTEZZE.m
      02_LQG_LQGI.m
      03_HINF.m
      04_MU_SINTESI.m
      05_CONFRONTO_FINALE_RAS.m
      parametri_sea.m
      dinamica_sea.m
      simula_sea.m
      dati/          banca compatta verificata e risultati essenziali
      figure/        sole figure necessarie
      documenti/     relazione, presentazione, schemi e interfacce
      LEGGIMI.md

Questa è una struttura progettata, **non un pacchetto già creato**. Il numero
effettivo degli ausiliari matematici andrà confermato nell'accorpamento.
`parametri_sea` sarà l'unica fonte leggibile di parametri/ipotesi; ciascuno
script mostrerà all'inizio le parti realmente usate. Formule, matrici,
connessioni, pesi e chiamate di sintesi resteranno visibili nei numerati.
`dinamica_sea` conserverà la fisica non lineare; `simula_sea` servirà
all'integrazione dello stato completo. Nessun framework o dipendenza Git/Drive.

Modalità rapida: carica realizzazioni e risultati verificati, ricostruisce
risposte essenziali, indica ciò che è caricato e ciò che è calcolato.
Non avvia D-K né analisi robuste costose. Modalità completa: ricostruisce
modelli, esegue sintesi e post-analisi con seed espliciti. I controllori
archiviati non vengono sovrascritti da una risintesi.

Le sei realizzazioni consolidate caricate in questo audit sono internamente
stabili sul nominale; ordini 14,16,18,22,4,78 e ingressi rispettivamente
6,6,4,4,4,4, con due uscite. Le verifiche sono in
`audit_ristrutturazione/controllori_baseline.csv`. LQG/LQGI ricevono
[r1,r2,q1,q2,theta1,theta2]; i robusti [r1,r2,q1,q2]. Le uscite sono
comandi di coppia in N m. Posizioni in rad, velocità in rad/s; gli stati
attuativi sono coordinate della realizzazione, non angoli fisici aggiuntivi.
Lo stato LQGI include due integrali in rad*s dell'errore **misurato**.
Segni e stati di ciascuna realizzazione devono restare quelli degli archivi.

I controllori saranno prima analizzati invariati su A/B. Solo per la
mu-sintesi sono pertinenti due progettazioni dedicate, con gli stessi pesi
e lo stesso budget. mixsyn e hinfsyn dovranno essere confrontati sul medesimo
problema 1-DoF, conservando inoltre il 2-DoF già significativo.

La NP comune del confronto userà i pesi finali già archiviati
(profilo [2,0.15,3,0.003,80], alpha=6, omegaM=4); il costo originario
di ciascun controllore resterà distinto. Il vecchio documento M5 descrive
anche un precedente set di pesi: non deve diventare una seconda fonte
silenziosa. I target temporali restano 0.8 s, overshoot 10%, errore DC 5%.
Q/R e covarianze saranno quelle salvate: Qn = 0.01 I4,
Rn = (0.05*pi/180)^2 I4, nella convenzione continua documentata.

## 8. Campioni, RAS, schemi e Simulink

Dopo approvazione si useranno circa dieci impianti fisici comuni con nominale,
estremi e punti interni, dichiarando quali canali variano. La tabella finale
riporterà NS, NP, intervalli RS/RP di A/B, differenze, ordine, tracking,
assestamento, overshoot, errore DC, disturbo e comando. Nessun margine verrà
trasferito dalla famiglia storica. La prova empirica resta distinta dalla
garanzia robusta.

La RAS userà lo stesso insieme di 10-20 punti per ciascun controllore:
coordinate Delta q1/Delta q2, Delta theta = Delta q, velocità, stati dei
drive e dei controllori nulli, riferimento/disturbo/rumore nulli. Il criterio
di convergenza e l'orizzonte saranno espliciti; integrazione incompleta
significherà esito numerico inconcludente. Nessun nuovo studio Lyapunov;
nessun contorno verrà dichiarato bordo certificato della RAS.

Schemi nuovi prodotti in questa fase: **nessuno**. Sono stati esaminati i
sei TikZ della PR43. Il piano richiede schemi per SEA, nominale attuativo,
A parametrico, B concentrato, LFT, pianta generalizzata, LQG/Kalman,
LQGI/integratore, mix-sensitivity, 2-DoF, D-K, N-Delta e confronto A/B.
Si riutilizzeranno le fonti di main e le parti pertinenti della PR43,
allineandole alle equazioni effettivamente eseguite.

Gli SLX esistenti restano intatti, nella loro organizzazione originale.
Nessun SLX è stato aperto, modificato, risalvato o simulato nell'audit.
`setup_student_originals.m` documenta già molte variabili esterne: sarà
usato come riferimento per un'interfaccia esplicita. Gli studenti forniranno
i nuovi SLX definitivi; fino ad allora la nuova integrazione Simulink resta
**NOT RUN**, senza ereditare le vecchie validazioni.
La loro eventuale inclusione nello ZIP va concordata quando saranno forniti:
nessuna riorganizzazione autonoma dei modelli è prevista dalla struttura sopra.

## 9. Verifiche realmente eseguite e limiti

Ambiente: MATLAB **R2026b 26.2.0.3386108**, Control System, Robust Control,
Symbolic Math e Simulink disponibili, rilevati in `ambiente.json`.

| Verifica | Esito di questo audit | Evidenza |
|---|---|---|
| Fisica, equilibrio/Jacobiani, attuatori, M4, M5, LQG/LQGI | **78/78 PASS**, zero incomplete | test_baseline.csv/MAT |
| Cinque test LFT della PR43, senza cambiare i sorgenti | **5/5 PASS** | test_pr43.csv |
| Stabilità interna e interfacce dei sei controllori congelati | **PASS** | controllori_baseline.csv |
| Code Analyzer su tutti i 259 MATLAB di main | 243 file senza messaggi; 16 con segnalazioni preesistenti | code_analyzer.json |
| Quattro ingressi principali al Code Analyzer | Nessun messaggio | stesso JSON |
| Code Analyzer del nuovo strumento di audit MATLAB | Nessun messaggio | code_analyzer_audit.json |
| Integrità MAT/SLX e sorgenti scientifici preesistenti | **PASS**, byte invariati | integrita_prima.json / integrita_dopo.json |
| Nuovi A/B, robustezza e risintesi del pacchetto | **NOT RUN / NON VALIDATI** | decisione S1 pendente |
| Nuovi campioni, nuova RAS, nuovi SLX | **NOT RUN / NON VALIDATI** | fasi successive |
| Nuovo ZIP estratto fuori repository | **NOT RUN / NON VALIDATO** | pacchetto non ancora costruito |

Le 16 segnalazioni riguardano 11 file di esempi didattici del docente e
cinque file del progetto, principalmente esportatori/test storici; vi è
anche un ritorno potenzialmente non assegnato in `estimate_lqg_ras.m`.
Non sono state corrette alterando la baseline; nessuna equivalenza o
inutilità è dedotta dal solo Code Analyzer. Il controllo manuale ha inoltre
verificato path, clearvars, caricamenti, scritture, callback e interfacce dei
punti di ingresso, oltre alle equazioni rilevanti della PR43.

Sono registrati anche gli avvii non riusciti:

- Il primo audit si è fermato prima delle regressioni per un uso numerico
  del costruttore uss nello strumento nuovo: corretto usando ss per il Padé
  certo; il log iniziale è conservato. Nessun sorgente di produzione coinvolto.
- Il primo collaudo PR43 in area temporanea era 4/5: mancava il MAT M5,
  letto da build_salaris_models. Fornita una copia esatta del MAT baseline,
  il collaudo è 5/5. Sono conservati CSV e log del primo tentativo: è una
  dipendenza del test, non una nuova scoperta sul modello.

Le suite M3/M5 riscrivono alcuni risultati durante l'esecuzione. Il meccanismo
esistente `preserve_validation_outputs` li ha salvati e ripristinati, poi
sono stati confrontati gli hash. Non si sono eseguite nuove mixsyn, hinfsyn,
hinfstruct, musyn, robstab, robgain o campagne RAS/Monte Carlo.

Ripetibilità da una copia del checkout con MATLAB e i dati disponibili:

    python tools/inventario_ristrutturazione.py snapshot
    matlab -batch "addpath('tools'); audit_ristrutturazione_didattica"
    python tools/inventario_ristrutturazione.py finalize

L'inventario usa Git per l'audit dello sviluppo; questi strumenti non saranno
dipendenze dell'esecuzione dello ZIP. Il controllo dei cinque test PR43 è
ripetibile dalla branch PR43 con le dipendenze main presenti. Le directory
temporanee dell'audit non costituiscono un pacchetto consegnabile.

Riferimenti di sintassi consultati: documentazione ufficiale MathWorks
[ureal](https://www.mathworks.com/help/robust/ref/ureal.html) e
[lftdata](https://www.mathworks.com/help/robust/ref/inputoutputmodel.lftdata.html).
Le formule della proposta sono derivate sopra e non attribuite alla
documentazione né al progetto dei colleghi.

## 10. Tracciabilità verso tutta la traccia ufficiale

PASS storico indica evidenza preesistente conservata; non certifica
automaticamente il nuovo pacchetto. Questa tabella dimostra la mappatura di
tutti i requisiti e rende esplicite le coperture ancora pendenti.

| Requisito della traccia | Fonte conservata in main | Nuova collocazione prevista | Stato corrente |
|---|---|---|---|
| Equazioni meccaniche e parametri nominali | src/model, sea_params_nominal; report cap.2 | 01, dinamica_sea; cap.2 | 78 regressioni includono fisica PASS |
| Scelta equilibrio e linearizzazione | M2; report cap.3 | 01; cap.2 | Regressioni PASS, scelta invariata |
| Attuatori secondo ordine e Padé1 | M3; report cap.4 | 01; cap.3 | Regressioni PASS |
| Pochi parametri incerti motivati | M4, decisioni D-0007 e successive | 01; cap.3-5 | Storico conservato; S1 da approvare |
| Misure e obiettivi quantitativi | M2/M5, specifiche, uscite C | parametri_sea, 01; cap.2/6 | Conservati, nessuna nuova taratura |
| 1: LQG senza integratore, rumori e covarianze | M6, progetto_lqg; report cap.7 | 02; cap.7 | Regressioni PASS |
| 1: LQG con integratore e motivazione | M7, progetto_lqgi; report cap.7 | 02; cap.7 | Regressioni PASS |
| 1: MATLAB lineare/non lineare e RAS | m8, lqgi_validation, final_closure | 02/05; cap.11 | Storico conservato; nuova RAS NOT RUN |
| 1: Simulink lineare/non lineare | student_originals, final_simulink_validation | interfacce; cap.11 | Storico conservato; nuovi SLX attesi |
| 2: mixsyn e hinfsyn, stesso problema e confronto | script Hinf sezioni 5-8, campagne finali | 03; cap.8 | Sintesi storiche conservate |
| 2: esplorazione hinfstruct/PID | fixed_PID e campagna m11 | 03; cap.8 | Conservati, nessuna nuova sintesi |
| 2: robustezza parametrica e dinamica attuativa | m12/m14 e PR43 | 01/04; cap.10 | Nuovo confronto A/B NOT RUN |
| 2: MATLAB/Simulink e RAS H-infinity | m15, final_closure, originali | 03/05, interfacce; cap.11 | Storico conservato; nuovo collaudo NOT RUN |
| 3: mu-synthesis con D-K iteration | m13 e storia D-K | 04; cap.9 | Banca conservata; sintesi S1 NOT RUN |
| 3: post-analisi mu | m14, audit robusti | 04; cap.10 | Storico conservato; A/B NOT RUN |
| 3: eventuale rilassamento motivato | PR43, evidenze separate | 04; cap.9-10 | Nessun nuovo rilassamento approvato |
| 3: MATLAB/Simulink non lineare e RAS mu | originali, final_closure, noise_redesign | 04/05, interfacce; cap.11 | Storico conservato; nuovo collaudo NOT RUN |
| 4: confronto H-infinity/mu dei margini RS/RP | report cap.9/12; PR43 comparison.csv | 04/05; cap.10/12 | Nuova tabella A/B NOT RUN |
| 5: circa dieci impianti comuni e metriche | final_closure/practical_robustness, PR43 | 05; cap.11 | Campioni storici conservati; nuovi NOT RUN |
| Relazione con grafici, frammenti di codice e controllori | report di main e appendici | documenti/; dodici capitoli | Base protetta; riorganizzazione NOT RUN |
| Codice MATLAB/Simulink consegnabile | quattro script, dati, SLX originali | sei numerati e ZIP autonomo | Struttura proposta; ZIP NOT RUN |
| Presentazione di massimo 20 minuti | 23 slide/18:47 stimati main; PR43 separata | documenti/; nuovo focus | Da aggiornare e provare dal vivo |

## 11. Prossimo passo e problemi aperti

È richiesta una sola decisione raggruppata su **S1 (§6)**. Se approvata,
le fasi 2-8 procederanno con i sei numerati, conservazione della baseline,
verifiche A/B e collaudo dello ZIP estratto in un percorso indipendente.
Se modificata, cambieranno soltanto le parti scientifiche indicate dagli studenti.

Restano aperti: scelta scientifica S1, nuovi margini robusti, eventuali
rilassamenti, collaudo del pacchetto, nuovi SLX degli studenti e prova orale.
Nessun successo numerico futuro viene anticipato. Nessun merge eseguito.
