# Revisione definitiva della traccia SEA — 4 novembre 2026

Responsabile: Alessio. Ramo `codex/sea-revisione-finale-semplificata`, PR #47. Base operativa verificata: `cbdee456cee9b766c4bbc7d107f46750a1553409`. Main `dbf6f00` consultato esclusivamente come patrimonio teorico e metodologico. Nessun nuovo ramo, nessuna nuova PR, nessun merge.

## Stato della revisione

Modellazione, sintesi, post-analisi, simulazioni e PDF COMPLETE. Gate tecnico PASS; accettazione prestazionale PARTIAL: nessun controllore ottiene RP PASS. Collaudo della consegna estratta in corso. Le registrazioni precedenti nella documentazione restano cronologia e non descrivono la configurazione corrente.

## Modello fisico e incertezze

La traccia ufficiale è stata letta integralmente su Drive in sola lettura; la figura originale della prima pagina è inclusa nella relazione. Sono mantenute esclusivamente m1=1 kg e m2=0.8 kg. La massa aggiuntiva della configurazione precedente è eliminata strutturalmente dalle funzioni operative, non azzerata né rinominata. M, C e G condividono lo stesso parametro m2. Gli altri dati fisici sono quelli della traccia e sono centralizzati in parametri_sea.m.

| Grandezza | Nominale | Incertezza | Intervallo |
|---|---:|---:|---|
| m2 | 0.8 kg | ±10% | 0.72–0.88 kg |
| wn1, wn2 | 40 rad/s | ±15% | 34–46 rad/s |
| td1, td2 | 15 ms | ±20% | 12–18 ms |
| zeta | 0.8 | 0% | noto ai fini del progetto |

Le tre tipologie corrispondono a cinque reali indipendenti in A. B conserva lo stesso m2 reale e sostituisce soltanto i drive con due perturbazioni SISO additive. Equilibrio, nominale, ingressi e misure coincidono. Le ripetizioni algebriche nella LFT non sono nuove variabili indipendenti.

Nella postura verticale Mbar=[[0.552,0.168],[0.168,0.072]] kg m² e Kg=[[-9.4176,-2.3544],[-2.3544,-2.3544]] N m/rad. Il punto di equilibrio rimane valido per ogni massa ammessa, mentre il Jacobiano varia. Cinque test MATLAB indipendenti sono passati; la prova geometrica sottrae il contributo di m2 senza invertire il caso algebrico singolare m2=0.

Il peso additivo selezionato ha ordine 3. Norme normalizzate massime 0.98007 sui 25 casi di costruzione e 0.94364 sui 30 indipendenti; eccesso mediano 1.0205. Verificati stabilità, proprietà e norma H∞ continua dei rapporti razionali, oltre alla griglia frequenziale. Nessuna inclusione globale A⊆B è dichiarata. La massa non entra nel peso dei drive.

## Controllori e confronto

Le famiglie conservate sono LQG, LQGI, mixsyn, hinfsyn 1-DoF e 2-DoF, hinfstruct PID, μ-synthesis su A e B. Tutte le sintesi correnti sono state rieseguite. Pesi, specifiche, rumori e inizializzazione D–K restano quelli del percorso precedente. L'analisi mantiene ogni K identico passando da A a B; le due sintesi μ sono poi confrontate sugli stessi dieci impianti fisici.

Tre iterazioni D–K: obiettivo circa 2.93 su A e 1.81 su B. Sono risultati di sintesi e non sostituiscono la post-analisi della pianta originale. NS/NP/RS/RP, target temporali, disturbo, rumore e comando sono trattati separatamente. Nessun target viene modificato per ottenere un PASS.

## Relazione, presentazione e riproducibilità

La relazione conserva i 13 capitoli e le quattro appendici della PR, con Riccati, covarianze, separazione, LFT, pianta generalizzata, H∞, μ, D/G, Lyapunov teorico, ZOH/intercampione e confronto multicriterio. Si correggono formule, parametri, numeri e interpretazioni incompatibili; non si importano vecchie garanzie dal main. Le parti teoriche senza una nuova campagna restano dichiarate come metodo.

La presentazione mantiene 23 slide; il confronto A/B è anticipato dopo il modello dei drive. Testo orale aggiornato: 2043 parole, 17:17 stimati a 125 parole/minuto con 22 cambi da 2 s; Alessio 8:00 e Valerio 8:33 di parlato. Prova dal vivo NON ESEGUITA.

I numeri nel testo vengono collegati all'esportatore delle tabelle; le figure si rigenerano dagli stessi dati della campagna. Gli esiti di cache con la vecchia configurazione sono rifiutati dalla firma. MATLAB R2026b, Control System Toolbox, Robust Control Toolbox e Simulink sono disponibili.

## Limiti e tracciabilità

Tolleranze ingegneristiche non misurate, Padé del primo ordine, copertura del peso campionata, RAS empirica nominale, assenza di saturazioni e limiti di targa. La stabilità robusta riguarda il modello lineare e l'insieme dichiarato. Le simulazioni fisiche comuni distinguono prestazioni del controllore da geometria della rappresentazione incerta.

Durante la ripresa dopo un riavvio accidentale, MATLAB ha segnalato errore 5201; il riavvio del MathWorks Service Host ha ripristinato l'esecuzione. Nessuna impostazione di sicurezza è stata disabilitata. Il gate di modellazione è stato ripetuto e salvato. Le evidenze effettive di sintesi e simulazioni sono raccolte in risultati/verifica_numerica_20261104.txt; l’audit PDF è in verifica_pdf_20261104.json. I due errori degli helper temporanei (radice derivata da pwd e who(ws)) sono conservati nei log e risolti con radice da mfilename ed evalin; i collaudi sono stati ripetuti con esito positivo.

## Esiti numerici e verifiche effettive

Tutte le sette chiusure nominali sono internamente stabili. La NP passa soltanto per Hinf2 e PID. La RS passa su A e B per LQG, LQGI, Hinf1, Mu_A e Mu_B; fallisce su entrambi per Hinf2 e PID. Hinf1 ha margine RS inferiore 1.40725 su A e 1.01379 su B: il secondo PASS è vicino alla soglia. Nessun RP PASS: esclusione per NP fallita oppure per RS fallita, con metodo esplicito nel CSV. Non viene attribuito un margine RP calcolato quando la prova non è stata svolta.

| K | Norma nominale | RS A, limite inferiore | RS B, limite inferiore | Campioni stabili /10 |
|---|---:|---:|---:|---:|
| LQG | 2.16850 | 1.45377 | 1.19464 | 10 |
| LQGI | 1.26114 | 1.40614 | 1.15239 | 10 |
| Hinf1 | 2.13092 | 1.40725 | 1.01379 | 10 |
| Hinf2 | 0.03120 | 0.04399 | 0.04025 | 1 |
| PID | 0.82976 | 0.23103 | 0.17025 | 8 |
| Mu_A | 1.89511 | 2.66196 | 1.95646 | 10 |
| Mu_B | 1.08745 | 2.46851 | 1.82486 | 10 |

Gli ordini delle due sintesi D–K sono 242 e 106; tre iterazioni per ciascuna, obiettivi finali 2.92947 e 1.81149. I risultati su B risultano più restrittivi nel confronto corrente, ma non dimostrano una relazione globale fra gli insiemi. Gli offset nominali di Mu_A e Mu_B sono circa 27.98% e 14.77%. Il LQG combina in questa campagna rapidità nominale (Ts=0.671 s) e RS, ma perde precisione con m2 variata; LQGI corregge l’offset con Ts=5.046 s, oltre il target. Hinf1 ha Ts=1.526 s ma NP fallita. I comandi con rumore di Hinf2, PID e delle due sintesi μ sono critici; non esistono saturazioni o limiti di targa che ne certifichino l’attuabilità.

Eseguite realmente: cinque test seaFinaleTest, ripetuti e ampliati con intervalli espliciti; otto verifiche scientifiche del runner; PBH di tutti i 14 modi (ranghi 14); 14 post-analisi A/B con ogni K invariato; 77 casi lineari (nominale più dieci impianti per sette K); 14 prove non lineari nominali; 21 con la sola massa variata; rumore encoder ZOH e confronto intercampione; 105 RAS. RAS: 88 convergenze, 15 mancate convergenze, due divergenze osservate, nessun timeout/errore. LQG/LQGI/Hinf1/Mu_A/Mu_B: 15/15; Hinf2: 13/15 e due divergenze; PID: 15 mancate convergenze.

Simulink: 20 run di 2 s sugli otto originali (nominale e primo campione, entrambe le sintesi μ nei due modelli robusti), tutti completati con stati e Scope finiti. Otto ulteriori avvii di 2 s con le InitFcn originali, tutti PASS, m2=0.8 kg persistente e DataSource Model File. Blocchi e posizioni conservati. Queste prove certificano l’esecuzione nel tempo collaudato, non prestazioni o stabilità asintotica. Analizzati 16 sorgenti: rimangono due suggerimenti non critici ISCL/SAGROW. Nessun test storico è attribuito alla configurazione corrente senza nuova esecuzione.

La campagna completa è stata eseguita per fasi; non si dichiara una singola chiamata a run_all(completa). run_all(rapida) è stato eseguito integralmente con le cache correnti e tutte le 12 figure rigenerate. La firma rifiuta configurazioni precedenti.

## Elaborati e copertura didattica

PDF compilati: relazione 111 pagine, presentazione 23 slide. Zero warning, overfull, underfull, riferimenti irrisolti o testo fuori pagina; tutte le pagine renderizzate e controllate visivamente. I SHA-256 sono nell’audit PDF. Corrette anche le illustrazioni del fitting: frequenza e ritardo indipendenti, smorzamento noto, quattro vertici SISO.

Capitoli 1–3: finalità, figura originale, parametri centralizzati, equazioni M/C/G, equilibrio e Jacobiani. Capitoli 4–6: Padé, cinque reali, due dinamiche SISO, peso e limiti della copertura, specifiche conservate. Capitoli 7–9: Riccati/LQR, Kalman, separazione, LQGI, H∞ e partizioni, PID strutturato, μ e D/G, due D–K e post-analisi corrente. Capitoli 10–11: originali Simulink, nonlinearità, rumore/intercampione, dieci impianti comuni e RAS. Capitoli 12–13: confronto multicriterio, limiti e conclusioni. Appendici A–D: parametri, tracciabilità, riproducibilità e codice operativo. Teoria Lyapunov e formulazioni ulteriori preservate, senza attribuirvi certificazioni non eseguite. Sono conservati gli argomenti pertinenti del main; nessun capitolo è eliminato per ridurre le pagine.

Semplificazioni: un solo file parametri, sette script lineari richiamati dal runner, Workspace separati, tabelle generate dai dati, descrizione progressiva di modello fisico e incertezze. Le funzioni locali restano il criterio ordinario; non sono stati aggiunti nuovi file operativi MATLAB. Tutte le figure numeriche e le tabelle dei risultati sono aggiornate; gli screenshot degli schemi conservano la topologia originale.

## Non eseguito e limiti

Non eseguite certificazione continua globale del box, Lyapunov robusto non lineare su tutta la famiglia, identificazione sperimentale delle tolleranze/rumori, validazione hardware, saturazioni fisiche, prova orale dal vivo o ripetizione della vecchia griglia di 36 candidati. Non sono obiettivi dichiarati raggiunti. SLX salvati e verificati con R2026b: apertura in R2025b richiederebbe conversione, non effettuata. È stato usato il runtime PDF già presente e autorizzato dal sistema, senza modificare le protezioni Windows.
