# Report finale della ristrutturazione didattica SEA

25 ottobre 2026. Responsabile: Alessio.
Branch `codex/ristrutturazione-didattica-sea`, base main
`0ed5611fdbb9c46475543f87eba68d9799b07bc5`. Nessun merge.

**Fasi 0-8 del mandato corrente: COMPLETE / PASS tecnico**, entro il confine
Simulink stabilito dagli studenti. S1 è stata approvata esplicitamente con
«approvo, continua nell'esecuzione». Non sono stati adottati nuovi pesi,
rilassamenti, saturazioni, riduzioni o modifiche SLX. La conformità alle
prestazioni resta **PARTIAL**: diversi target temporali e il comportamento
in presenza di rumore non sono soddisfatti. La nuova integrazione Simulink
resta **NOT RUN**, in attesa degli SLX definitivi degli studenti.

## 1. Stato iniziale e fonti

Main coincideva con il commit indicato nel mandato. La PR #43, head
`d3074e941c85917ae85e41e4762f91eb8417a55a`, era aperta in bozza, senza
approvazione registrata dei suoi nuovi modelli. Sono stati letti traccia SEA,
AGENTS, decisioni, script, controllori, dati, relazione e presentazione di
main e materiale della PR43. Drive è rimasto in sola lettura.
Non è stata inventata una trascrizione del ricevimento: sono state usate
soltanto le indicazioni scritte disponibili.

Main ha 1125 file, 259 sorgenti MATLAB, 240 MAT e 19 SLX. L'unione con PR43
ha 1275 file. La cartella di lavoro valida è Progetto_CR_finale; la directory
superiore della chat contieneva un Git vuoto e non è stata usata come repository.

## 2. Audit file per file e dipendenze

`audit_ristrutturazione/inventario_file.csv` classifica tutti i 1275 file in
CONSERVATO / ACCORPATO / SEMPLIFICATO / ARCHIVIATO, con motivazione, origine,
blob e destinazione. Non sono necessarie cancellazioni: ELIMINATO ha zero
voci. ARCHIVIATO significa conservato nel repository ed escluso dalla nuova
consegna, non spostato o distrutto. Il grafo lessicale conservativo ha 688
archi candidati; non viene interpretato come prova automatica di inutilità.

Le quattro chiusure MATLAB statiche comprendevano 21 file distinti: 14 per
LQG, 3 per LQGI, 4 per H∞ e 1 per μ, con sovrapposizione. I MAT caricati
e i percorsi dinamici richiedevano altre parti del repository. Sono esatti
duplicati i due LQG/LQGI in analysis e nella raccolta accorpata; risultano
duplicate anche checklist e numerose figure. Il pacchetto nuovo non dipende
da nessuna di queste copie o cartelle storiche.

## 3. File recuperati e accorpamenti effettivi

| Materiale precedente | Destinazione effettiva | Trattamento |
|---|---|---|
| Quattro ingressi accorpati | Sei SEA_00--SEA_05 | Procedimento ridistribuito per ordine didattico |
| Modello, parametri, attuatori | SEA_01 e parametri_sea | Formule e matrici esplicite; unica fonte di ipotesi |
| Cinque funzioni fisiche SEA | dinamica_sea | Stesse equazioni in un solo ausiliario numerico |
| LQR, Kalman, LQGI e helper di grafico | SEA_02 e SEA_05 | Riccati, guadagni e integratore visibili |
| H∞ e tre helper PID | SEA_03 | P1/P2, pesi e chiamate di sintesi nel file |
| μ-analysis e D-K | SEA_04 | Due famiglie, stessi pesi e post-analisi incrociata |
| RHS, prove non lineari e RAS | simula_sea e SEA_05 | Stato completo, quindici punti, tre esiti |
| Controllori MAT consolidati | dati/banca_consolidata.mat | Realizzazioni originali, senza minreal o riduzioni |
| LFT manuale utile della PR43 | SEA_01 | Adattata allo S1 approvato, senza importare runner o residui |
| Equazioni fisiche e derivazione di Q di main | Nuova relazione cap.2/7 | Testo e formule recuperati e riorganizzati |
| Matrici LQR/Kalman e risultati rumore di main | Appendici e tabelle della nuova relazione | Fonti precedenti conservate e dichiarate |

Le funzioni Lyapunov e i vecchi esportatori non sono inutili in assoluto:
restano disponibili per riprodurre gli studi storici. Non sono necessari
al nuovo percorso empirico e sono esclusi dallo ZIP. Nessun sorgente
scientifico preesistente è stato cancellato o sovrascritto.

## 4. Nuova struttura reale

La cartella Progetto_SEA_Consegna contiene sei script principali:
SEA_00_AVVIO_PROGETTO, SEA_01_MODELLI_INCERTEZZE, SEA_02_LQG_LQGI,
SEA_03_HINF, SEA_04_MU_SINTESI, SEA_05_CONFRONTO_FINALE_RAS.
Gli unici tre ausiliari sono parametri_sea, dinamica_sea e simula_sea.
Non ci sono classi, factory, wrapper o framework nella consegna.

**Correzione tecnica necessaria:** MATLAB rifiuta i nomi che iniziano con
una cifra, come confermato da run e Code Analyzer. Il prefisso SEA conserva
la numerazione e permette Run nativo, evitando caricatori basati su eval.
Ogni ingresso inizializza parametri e dati realmente usati. Nessuna variabile
di un precedente Base Workspace è richiesta. I soli percorsi sono derivati
dalla posizione del file. Gli strumenti Python/PowerShell di sviluppo non
sono inclusi né necessari per eseguire il pacchetto.

## 5. Parametri approvati e motivazioni

Nominali ed equilibrio invariati: wn=40 rad/s, zeta=.8, tau=.015 s,
qbar=[pi/2;0], meccanica della traccia. S1 conserva soltanto wn/zeta ±10%
per attuatore, indipendenti fra canali. Tau è noto e rappresentato con
Padé1, senza residuo aggiuntivo. La meccanica è nominale nel confronto
centrale; M4 e le sue incertezze meccaniche sono conservati come storia.
È una restrizione dichiarata del problema, non una equivalenza con M4.

Sono state studiate le alternative wn, wn/zeta, wn/tau e zeta/tau e cinque
valori per parametro, variando un parametro alla volta. La selezione wn/zeta
conserva effetti distinti di rapidità e smorzamento con un Padé comune.
Il ritardo resta fisicamente rilevante: la sua esclusione dalla variabilità
è una decisione di scopo approvata. Il piccolo studio LQG/Kalman usa cinque
fattori, mantenendo come scelta i costi e le covarianze consolidate.

## 6. Modelli A/B e verifiche

A è il parametrico: quattro scalari reali, wn ripetuta due volte per
canale nella LFT manuale, sei porte totali. B è il concentrato: due ultidyn
SISO indipendenti, nessun accoppiamento pieno 2×2. La convenzione è quella
del mandato corrente; la PR43 chiamava A/B al contrario.

Il peso approvato è WI=.6165601466*s/(s+36). La dimostrazione su tutto
il box usa l'errore relativo E=(alpha*s²+beta*s)/(s²+2*zeta*wn*s+wn²),
|alpha|≤.21, |beta|≤14.08. E/WI è stabile/proprio e ha norma ≤1.
Pertanto A è contenuto nel B unitario; B include anche perturbazioni
dinamiche non riconducibili a parametri fisici costanti.

Nominali A/B contro la banca: errori circa 8.37e-15 e 6.81e-15.
LFT manuale contro le formule dirette: errore sotto 1e-15 sulle prove.
Massimo osservato ||E/WI|| sulle 25 coppie: .559738. La griglia controlla
l'implementazione; la copertura globale deriva dalla dimostrazione.
L'inclusione del box unitario non giustifica un ordine universale dei
margini nelle espansioni oltre il box: la dipendenza parametrica è non lineare.

## 7. Controllori, sintesi e garanzie

Sono conservati LQG 14, LQGI 16, Hinf1 18, Hinf2 22, PID 4 e Kmu 78 stati.
La ricostruzione LQR/Kalman/LQGI verifica residui Riccati e identità dei
guadagni. La modalità completa esegue mixsyn e hinfsyn sullo stesso P1,
hinfsyn P2, un avvio hinfstruct dal PID consolidato e due D-K dedicate.
I ricalcoli H∞ non sovrascrivono la banca. I nuovi Mu_A/Mu_B sono strumenti
di confronto, non controllori promossi automaticamente.

W1/W2/Mo, costi, covarianze e target restano invariati. Le D-K usano lo
stesso budget di quattro iterazioni e fit [2,1], scalature diagonali e
MixedMU attivo. Non sono richiesti nuovi rilassamenti per raggiungere RP S1.
Il costo comune 2-DoF è distinto dal costo proprio LQR o mixed sensitivity.

| K | Ordine | RS A lower | RS B lower | RP A lower | RP B lower | Stabili/10 | RAS converge/15 | RAS inconcl. |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| LQG | 14 | 1.728 | 0.9914 | 0 | 0 | 10 | 15 | 0 |
| LQGI | 16 | 1.68 | 0.957 | 0 | 0 | 10 | 15 | 0 |
| Hinf1 | 18 | 2.586 | 1.046 | 0 | 0 | 10 | 15 | 0 |
| Hinf2 | 22 | 0.5655 | 0.0332 | 0 | 0 | 3 | 11 | 4 |
| PID | 4 | 0.2945 | 0.1252 | 0 | 0 | 7 | 4 | 4 |
| Kmu | 78 | 3.353 | 1.898 | 1 | 1.448 | 10 | 15 | 0 |
| Mu_A | 88 | 4.415 | 2.385 | 3.873 | 2.03 | 10 | 6 | 0 |
| Mu_B | 32 | 4.326 | 3.011 | 4.226 | 2.625 | 10 | 15 | 0 |

Per LQG/LQGI/Hinf1 il costo comune fallisce già NP e RP è zero. Per Hinf2/PID
il fallimento RS esclude RP; gli upper RP dedotti sono marcati come tali.
Per Kmu su A il bound diretto RP è invertito anche con opzioni m9: entrambi
gli esiti grezzi sono conservati. La garanzia unitaria deriva da RP su B;
il bound riportato è [1,RS_A upper], non un riordinamento dell'esito né
un trasferimento del margine oltre uno.

B è più conservativo per diversi K fissi, ma la D-K su B produce qui
ordine 32 contro 88 su A, con migliori garanzie incrociate sul B. Il
risultato riguarda questa campagna finita e questi pesi, non un optimum
universale. Non è stata eseguita una campagna di riduzioni d'ordine.

## 8. Simulazioni e RAS

Dieci impianti fisici comuni includono nominale, estremi e punti interni.
Sono campioni di A, contenuto in B; non sono campioni dinamici arbitrari
presentati come impianti fisici. Si verifica stabilità interna prima delle
metriche: per gli instabili i valori prestazionali restano NaN.
Tutti gli otto controllori hanno due tracking e due disturbi nominali
non lineari: 32 integrazioni completate. Picchi/RMS sono osservazioni
sulla griglia dichiarata, non massimi continui certificati.

La RAS integra l'intero stato: dq/dtheta iniziali uguali, velocità, drive
e controllori nulli, r=d=v=0. Quindici punti comuni; ultimo secondo entro
12 s, soglie .5 gradi e .02 rad/s. Su 120 prove: 96 convergenze, 16
completate senza convergenza, 8 inconcludenti (quattro Hinf2, quattro PID).
Non convergere entro T non è instabilità matematica. Non si costruiscono
nuovi studi Lyapunov o contorni certificati. I MAT conservano q/u e gli
indicatori necessari; tutti gli stati sono comunque integrati.

## 9. Schemi ed elaborati

Prodotti 13 schemi TikZ riproducibili: SEA fisico, nominale attuativo,
A parametrico, B concentrato, LFT, pianta generalizzata, LQG/Kalman,
LQGI/integratore misurato, mix-sensitivity, 2-DoF con stati condivisi,
D-K, N-Delta e confronto A/B. Sono allineati a equazioni, segnali e codice.

La relazione di main è stata riorganizzata in dodici capitoli e appendici,
con **33 pagine**. Non è stata sostituita dalla relazione PR43:
sono recuperati fisica, derivazione Q, matrici e risultati precedenti
significativi, incluso il rumore. La presentazione ha **18 slide**, con
19:19 pianificati; la durata reale richiede una prova orale cronometrata.
PDF compilati con MiKTeX: zero errori, riferimenti irrisolti, destinazioni
duplicate e overflow. Pagine e slide sono state renderizzate e controllate.

Il compilatore integrato dell'editor ha inizialmente avuto timeout durante
il download dei pacchetti e un progetto stale mentre cambiavano i sorgenti;
questi tentativi non sono accreditati. I PDF consegnati derivano dalle
compilazioni locali effettivamente riuscite e dal controllo tecnico/visivo.

## 10. Protezione della baseline e gate

Verificati SHA-256 di 830 file scientifici preesistenti:
**259 MATLAB e 259 MAT/SLX, inclusi tutti i 19 SLX, invariati byte per byte**.
Restano intatti anche i precedenti sorgenti LaTeX, PDF e figure. Nessuno
SLX è stato creato, aperto, simulato, risalvato o riorganizzato per S1.
Il MAT portabile conserva la banca originale senza trasformazioni di stato.

| Gate | Esito |
|---|---|
| Audit baseline e PR43 | 78 test baseline + 5 LFT PR43 PASS |
| Nuovi test S1 | 50/50 PASS |
| Estrazione ZIP e modalità rapida | 50/50 PASS, esecuzione reale indipendente |
| Estrazione ZIP e modalità completa | 50/50 PASS, nuove sintesi e simulazioni reali |
| Dipendenze | Nove MATLAB nella consegna; nessuna funzione scientifica del repository richiesta |
| Integrità baseline | PASS, nessun byte scientifico preesistente alterato |
| PDF | PASS tecnico e visivo |
| Target temporali/rumore | PARTIAL, fallimenti conservati e discussi |
| Nuova integrazione Simulink | NOT RUN, modelli definitivi attesi |

Fallimenti tecnici iniziali conservati: costruttore uss numerico corretto
con ss nell'audit; MAT M5 mancante nella copia di test PR43 poi fornito;
nomi MATLAB numerici rifiutati e corretti con prefisso SEA; controllo CRC
chiamato prima della chiusura dello ZIP, ripetuto correttamente dopo
chiusura. Nessun tentativo fallito è dichiarato validato. Il bound RP
incoerente resta una limitazione numerica esplicita.

## 11. ZIP e riproduzione indipendente

Archivio `delivery/Progetto_SEA_Consegna.zip`: **69 file**,
sei principali + tre ausiliari MATLAB, **otto MAT**, CSV essenziali, figure,
relazione, presentazione, sorgenti TikZ/LaTeX e LEGGIMI.
Dimensione 32582050 byte; SHA-256
`ebc5bb045d15bc2490a0e8c8c471798dec4862f63dd65fd86e701e0afec8f759`. CRC e hash dei file estratti PASS.

Entrambe le modalità sono state eseguite realmente in una cartella
temporanea esterna, dopo restoredefaultpath e senza percorsi scientifici
del repository. La rapida carica le analisi robuste; la completa ripete
sintesi, post-analisi, campionamento, non lineare e RAS. La banca originale
non è riscritta. I file di sviluppo e i checkpoint storici non sono nello ZIP.

## 12. Risultati non validati e problemi aperti

Nuovi SLX S1 e relativa integrazione MATLAB/Simulink: non validati, per
esplicito rinvio agli studenti. Non è certificato l'hardware, non sono
identificati limiti di coppia, saturazioni o ritardi reali. La sezione RAS
è empirica. Il margine diretto RP di Kmu su A resta inconcludente; la
garanzia unitaria è giustificata separatamente per inclusione.

Mu_B raggiunge RS/RP ma ha Ts=1.985 s e DC=5.454%, oltre i target .8 s e
5%; il guadagno rumore-comando circa 1.36e6 è peggiore del Kmu storico
(circa 2.94e4). Mu_A ha ordine 88 e solo sei convergenze RAS. Non viene
quindi dichiarato un vincitore operativo né occultato un peggioramento.
Non servono ulteriori approvazioni per la struttura eseguita; eventuali
future variazioni scientifiche o adozioni operative richiederanno una
decisione specifica. Restano la scelta dei modelli Simulink definitivi e
la prova orale dal vivo. Nessun merge automatico.

## 13. Tabella finale di tracciabilità della traccia

| Requisito | Implementazione | Evidenza e stato |
|---|---|---|
| Fisica SEA, parametri e unità | dinamica_sea, parametri_sea; SEA_01 | Equilibrio, Jacobiani e canale disturbo verificati |
| Linearizzazione e misure | SEA_01, banca nominale | A/B nominalmente uguali; quattro encoder LQG, q per robusti |
| Secondo ordine con Padé1 | SEA_01 | Nominali conservati, tau noto 15 ms |
| Pochi parametri incerti motivati | SEA_01; relazione cap.3-5 | S1 approvata; LFT manuale e inclusione analitica |
| Specifiche e pesi dichiarati | parametri_sea, SEA_03 | Target invariati, pesi espliciti, nessun nuovo rilassamento |
| 1. LQG senza integratore | SEA_02 | lqr/lqe, Q/R, covarianze e identità del controllore |
| 1. LQG con integratore | SEA_02 | Sistema aumentato, Riccati, xi_dot=r-q_mis |
| 1. Lineare/non lineare e RAS | SEA_05 | Due tracking + due disturbi, 15 condizioni iniziali per K |
| 1. Simulink | Interfaccia numerica esportata | Nuovi SLX S1 NOT RUN; precedenti risultati conservati |
| 2. mixsyn e hinfsyn con confronto | SEA_03 | Stesso P1; norme ricostruite e nominali stabili |
| 2. hinfstruct/PID | SEA_03 | Un avvio dal PID consolidato, stessa P2 |
| 2. H∞ lineare/non lineare e RAS | SEA_05 | Prove reali; esiti inconcludenti conservati |
| 2. μ-analysis con incertezze e attuatori | SEA_04 | RS/RP adattive e N11/mussv su A/B; campioni distinti |
| 3. μ-synthesis D-K | SEA_04 | Due D-K dedicate, quattro iterazioni ciascuna, stessi pesi |
| 3. Post-analisi μ | SEA_04 | Analisi incrociata di Mu_A/Mu_B su entrambe le famiglie |
| 3. Eventuale rilassamento | Non necessario per RP S1 | Entrambe le sintesi raggiungono RP; target temporali ancora parziali |
| 3. μ lineare/non lineare e RAS | SEA_05 | Ordini 88/32; RAS 6/15 e 15/15, con limiti espliciti |
| 4. Confronto H∞/μ in RS/RP | SEA_04/05 | confronto_robusto.csv, quadro_finale.csv, relazione cap.10/12 |
| 5. Circa dieci impianti comuni | SEA_05 | 10 impianti fisici, stessi per tutti; metriche degli instabili NaN |
| Relazione, grafici, codice e controllori | documenti/relazione, nove .m, dati/ | Relazione riorganizzata dalla base consolidata; sorgenti inclusi |
| Presentazione ≤20 minuti | documenti/presentazione, PRESENTAZIONE_NOTE | 18 slide, 19:19 pianificati; prova dal vivo ancora necessaria |
| Riproduzione autonoma | SEA_00, LEGGIMI | Due modalità; nessuna dipendenza da repository o servizi online |

NS/NP/RS/RP restano proprietà separate. Il passaggio A/B cambia l'insieme
ammesso, mentre la risintesi cambia K: le due operazioni sono riportate
separatamente. I margini precedenti M4 e i nuovi S1 non sono intercambiabili.
