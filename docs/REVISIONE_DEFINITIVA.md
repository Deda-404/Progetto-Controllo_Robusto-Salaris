# Revisione finale del progetto SEA — evidenze tecniche

Data di completamento documentale: 2 novembre 2026. Campagna MATLAB: 1 novembre 2026, seed 20261101, R2026b 26.2.0.3386108. Base main `dbf6f00b06e0cddc65cd19e90d11ad3418cab2da`, contenente PR #46; ramo unico `codex/sea-revisione-finale-semplificata`. Nessun merge.

## Fonti e perimetro

Consultate la traccia ufficiale «Manipolatore planare 2R con SEA», la versione main, gli script accorpati, gli otto SLX, relazione e slide esistenti. Il materiale del professor Salaris è stato letto nelle cartelle Matlab, Slide e Appunti, compreso il riassunto di controllo robusto e il capitolo sulle incertezze. Drive è rimasto in sola lettura. Massa, intervalli e target sono scelte di progetto; non sono misure né prescrizioni attribuite al docente.

## Scelte consolidate

Massa aggiuntiva 0.2 kg ±50%, dopo confronto 0.1/0.2/0.3 kg. La stessa massa entra in M, C e G; nessuna incertezza aggiunta su Ks o Jm. Equilibrio `[pi/2;0]`, coppia nulla analiticamente. Errore relativo del Jacobiano 6.20e-11. Mbar = [0.650 0.210; 0.210 0.090], Kg = [-10.791 -2.943; -2.943 -2.943].

Attuatori: wn=40±10% rad/s, zeta=0.8±10%, td=15±20% ms, tre parametri per canale. Ritardo scelto confrontando ±10/20/30%; Padé di ordine uno, 14 stati fisici invariati.

A contiene sette reali indipendenti, con massa condivisa fra tutte le occorrenze. La LFT estratta ha 19 occorrenze: massa 5, ciascuna wn 5, ciascun td e zeta 1. Non sono 19 grandezze fisiche. B contiene due ultidyn SISO e lo stesso ureal meccanico. La forma additiva evita i poli destri generati dai rapporti moltiplicativi con ritardo variabile. Esempio td=18 ms: poli +133.333 e +111.111 nei due errori relativi.

Peso selezionato: `(861.4711 s + 0.00408509)/(s^3 + 106.7152 s^2 + 4537.9213 s + 71007.8405)`. I coefficienti in MAT restano a piena precisione. Ordini 1/2/3 confrontati; scelto 3 per copertura ed eccesso mediano 1.0205. Max norma normalizzata 0.980367 sui 29 casi di costruzione e 0.878798 sui 30 indipendenti. Ricostruzione A/B sugli stessi dieci impianti: errore massimo in frequenza 1.03e-14. Inclusione dell’intero box NON DIMOSTRATA.

Specifiche: candidati Ts 0.8/1.5/2 s e Mp 10/15/15%. Scelti 2 s e 15%, conservando ess 5% e cross 25%. Mo=9/(s²+6s+9), con Ts 1.9447 s. We e Wu invariati e semplici; il requisito normalizzato resta <1. Recupero, rumore e coppie sono indicatori diagnostici, senza soglie hardware arbitrarie.

## Controllori e risultati

Sette controllori fissati analizzati senza modifica su A/B. Risintetizzati LQG, LQGI, Hinf1, Hinf2, PID e due D-K. Primo avvio automatico D-K conservato nei file `avvio_nominale`; tentativo finale con MuN1 comune, tre iterazioni, stessi pesi. I file correnti non usano cache del precedente nominale.

| Controllore corrente | RS A (limite inferiore) | RS B | NP | RP A/B |
|---|---:|---:|---|---|
| LQG | 1.4593 | 1.1972 | FAIL | FAIL |
| LQGI | 1.4185 | 1.1550 | FAIL | FAIL |
| Hinf1 | 1.3370 | 0.9485 | FAIL | FAIL |
| Hinf2 | 0.05535 | 0.03714 | PASS | FAIL |
| PID | 0.2522 | 0.2004 | PASS | FAIL |
| Mu_A | 2.5314 | 1.7804 | FAIL | FAIL |
| Mu_B | 2.5648 | 1.9511 | FAIL | FAIL |

Gli intervalli completi sono in `confronto_robusto.csv`. La perdita di RP è dedotta dal nominale se NP fallisce; da RS quando la stabilità è esclusa; altrimenti si usa robgain. I valori dedotti non sono presentati come una misura diretta. Nessun intervallo viene riordinato. Tutti i correnti sono NS PASS; Hinf2_fisso è NS FAIL.

LQG soddisfa i target temporali nominali (Ts 0.731 s), ma può avere offset sotto carico e disturbo. LQGI ha offset DC nullo e Ts 5.15 s. Hinf2 raggiunge i target nominali ma è stabile in 4/10 impianti; PID in 7/10. Mu_A: ordine 294, errore DC 99.8%. Mu_B: ordine 80, errore DC 21.9%, picco da rumore 762 N m. Hinf2: picco fra campioni 269010 N m. Nessun candidato viene dichiarato utilizzabile grazie al solo gamma.

RAS finale: 105 prove, 86 convergenze, 12 mancate convergenze, 7 allontanamenti, zero timeout/errori. Le 35 altre simulazioni comprendono 14 tracking/disturbo e 21 prove con sole masse 0.1/0.2/0.3 kg. I risultati sono nominali rispetto ai drive salvo dove esplicitamente campionati; non sono garanzie non lineari robuste.

## Verifiche realmente eseguite

- Campagna completa per fasi: nuove sintesi, 28 post-analisi, 154 casi lineari (14 K × 11 impianti), rumore comune, 105 RAS, 35 altre prove non lineari. Log `esecuzione_completa.txt` con provenienza delle fasi.
- `run_all('rapida')`: esecuzione nuova, sintesi onerose e RAS esplicitamente caricate e controllate.
- Cinque test `seaFinaleTest`: equilibrio/Jacobiano, carico puntiforme, identità energetica, A/B e bordi di massa. Tutti PASS.
- Sette verifiche del runner PASS, inclusi replay esatto, normalizzazione continua e stabilità interna da matrice esplicita. PBH sui modi instabili verificato.
- Code Analyzer: nessun messaggio sui 16 file operativi.
- Simulink: 20 run di 2 s su otto modelli, nominale e primo campione. Formule M/C/G confrontate, massa/drive/controller registrati, stati e Scope finiti. Gli SLX su disco rimangono invariati.
- Relazione 49 pagine e slide 23 pagine: compilazione senza warning, overfull o riferimenti irrisolti; tutte le pagine renderizzate e controllo visivo completato.
- ZIP estratto fuori repository con restoredefaultpath: pipeline rapida e 20 SLX PASS, sei CSV identici e scarto dei massimi Scope nullo. I 33 sorgenti/ingressi sono identici per SHA-256; il pacchetto finale conserva lo stesso contenuto eseguibile collaudato.

## Requisiti R01–R22

Tutti i percorsi sotto appartengono a `File_di_Funzioni_Progetto-Accorpati`, salvo indicazione.

| ID | Evidenza verificabile | Esito |
|---|---|---|
| R01 | matrici_sea.m, dinamica_sea.m; test carico puntiforme | PASS |
| R02 | modello_sea.m: unico ureal m_EE; test ai bordi | PASS |
| R03 | incertezze_attuatori.m; parametri_dieci_impianti.csv | PASS |
| R04 | medesimi campioniFisici e delta normalizzate; erroreAB 1.03e-14 | PASS |
| R05 | stessa meccanicaIncerta in PA/PB | PASS |
| R06 | forme_incertezza.csv; delta additive stabili e proprie | PASS |
| R07 | lftdata, ricostruzione e verifica_sea | PASS |
| R08 | modello.mat, riassunto_numerico.json, PBH e Jacobiano | PASS |
| R09 | 28 righe confronto_robusto.csv, sette fissati e sette correnti | PASS |
| R10 | margini RS/RP nuovi, deduzioni analitiche dichiarate | PASS |
| R11 | sintesi_hinf.mat, sintesi_mu.mat, CARE; primo tentativo conservato | PASS |
| R12 | candidati_specifiche.csv, candidati_riferimento.csv; capitolo 6 | PASS |
| R13 | soglie unitarie immutate; FAIL preservati | PASS |
| R14 | parametri_sea.m e candidati fisici arrotondati | PASS |
| R15 | MAT/CSV pieni; esportatore arrotonda solo per LaTeX | PASS |
| R16 | 13 capitoli e appendici riscritti; confronto discorsivo | PASS |
| R17 | nessuna cronaca di PR, branch o versioni nel testo finale | PASS |
| R18 | niente nuove famiglie o griglie estese; RAS empirica e funzioni condivise | PASS |
| R19 | ras.mat, nonlineare.csv, carico_nonlineare.csv | PASS |
| R20 | collaudo_simulink.m e simulink.mat con massa e dati assegnati | PASS |
| R21 | 23 slide, tabelle generate dagli stessi CSV; discorso 16:50 stimati | PASS |
| R22 | manifest, 33 ingressi identici, rapida e 20 SLX dalla ZIP estratta | PASS |

Gli esiti della matrice riguardano l’esecuzione dei requisiti dell’incarico. Non significano che tutti i controllori raggiungano gli obiettivi. Restano non dimostrate la copertura globale del box e una RAS certificata; hardware e prova orale dal vivo non sono stati eseguiti.
