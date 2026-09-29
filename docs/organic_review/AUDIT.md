# Revisione organica: analisi preliminare e decisioni

Responsabile: Alessio. Analisi iniziata il 28 settembre 2026, conclusione documentale il 29 settembre.
Base: 91ea492815a1f128657bd975dcb8995319ab0397, branch codex/simulink-integration, PR #33 in bozza.

## Fonti e confini

La traccia ufficiale è stata letta integralmente e confrontata con il modello e con le richieste di consegna. Il prompt del 28 settembre sostituisce la precedente richiesta di costruire automaticamente i diagrammi: la consegna usa esclusivamente gli originali del gruppo. Nessuna modifica funzionale agli originali è autorizzata in questa fase; gli interventi richiesti sono elencati come attività manuali.

Sono stati analizzati prima degli interventi i capitoli 1–7, i costruttori del modello, i controllori e gli artifact MATLAB, la catena robusta e le dipendenze dei modelli. L'inventario completo è in inventory.csv. I risultati dei controllori non vengono identificati dai soli nomi dei file: la selezione è verificata nelle strutture MATLAB e nei test di identità.

Fonti esterne in sola lettura:
- traccia SEA del docente;
- [cartella degli originali](https://drive.google.com/drive/folders/1wDiaAQVR7cDDt7T8WUlyZ0vgEa-2LWLx);
- relazione dei colleghi Report_finale_CR.pdf, identificativo Drive 1J8iR3OVwtfgoGvEJYXBkDfEc6TvHjl_W.

La cartella degli originali contiene tre pacchetti espansi SLX, denominati LQR, LQRI e Hinf. Le copie locali corrispondono ai tre archivi scaricati, verificati tramite SHA-256. Non risultano disponibili originali Kmu o un diagramma del plant linearizzato.

## Confronto mirato con i colleghi e capitoli 1–7

| Aspetto | Progetto corrente | Riferimento dei colleghi | Decisione |
|---|---|---|---|
| Meccanica | 8 stati, qbar=[pi/2;0], 4 encoder | stessa impostazione fisica | Equazioni conservate |
| Attuatore | 40 rad/s, zeta=0.8, 15 ms | 30 rad/s, zeta=0.7, 20 ms | Non importare parametri |
| Incertezze | Jm1,k1,k2 ±10% e 2 dinamiche | altre scelte, inclusi m2 ±10%, rigidezze ±5% | Conservare il dominio corrente |
| LQR | costo fisico con deformazione, R=0.10 I | costo e prove differenti | Nessuna nuova selezione |
| Kalman | Gw=[Bd B], Qn=0.01 I4, 4 encoder | rumore su 14 stati e altre covarianze | Conservare L, Qn, Rn |
| hinfstruct | D regolabile nella realizzazione piena | D fissata a zero nell'esempio | Descrivere il codice corrente |

Capitolo 3: corretti soltanto il refuso ",qquad" e il conteggio dei poli: due instabili, due coppie complesse stabili, due poli reali stabili. Verifica sul MAT: -7.885509 e -4.073351 s^-1 per gli ultimi due.
Capitoli 1,4,5,6: pulizia delle etichette cronologiche e dei rimandi, senza modificare parametri o formule.
Capitolo 7: conservate derivazioni LQR/Kalman/LQRI, guadagni, tabelle e risultati; sostituita la sezione che attribuiva validazione ai diagrammi esclusi. Integratore MATLAB correttamente r-q_mis; il diagramma originale rimane da allineare manualmente.

## Configurazioni adottate

| Famiglia | Fonte effettiva | Dimensioni/ordine | Ruolo |
|---|---|---|---|
| LQG | m6_lqg_no_integrator.mat, K,L,Nr | K 2x14, L 14x4; controllore ordine 14 | Tracking nominale |
| LQRI | m7_augmented_cost_feasibility.mat, illustrativeIndex | Kx 2x14, Ki 2x2; ordine 16 | Reiezione DC, tracking lento |
| Hinf 1-DoF | hinf_final_coherent/nominal_study.mat, profili 1 e 12 | ordine 18 | Confronto mixsyn/hinfsyn |
| Hinf 2-DoF | selected_full_order.mat | 2x4, ordine 22 | Comparatore nominale |
| Strutturati | fixed_study.mat e fixed_*.mat | statico, PI, PID, SS2/4/6 | 66 avvii; minimo osservato 2 |
| Kmu | m13.mat; identità con m14 e robust_study | 2x4, ordine 78 | Candidato robusto |

I vecchi dataset robusti m9–m14 fuori da hinf_final_coherent, le prove con tolleranza predefinita e gli studi didattici separati non sono fonti dei risultati robusti finali. Restano conservati come calcoli MATLAB riproducibili; non vengono trasferiti ai controllori selezionati.
La post-analisi identifica cinque blocchi scalari, tutti con Occurrences=1. Delta è 5x5 e la parte certa della LFT è 9x9. L'identità nominale ricomposta è verificata senza nuova mu-analysis.

## Classificazione Simulink per contenuto

| Modello | Provenienza e contenuto | Stato | Posizione consegnata | Uso documentale / intervento manuale |
|---|---|---|---|---|
| Progetto_LQR_simulink | Originale Valerio; Kalman e -K*xhat+Nr*r | Non validato dinamicamente | simulink/originals | Cap.7/10; disturbo, rumori, ingressi liberi da verificare |
| Progetto_LQRI_simulink | Originale Valerio; Kx,Ki, osservatore | Non validato dinamicamente | simulink/originals | Cap.7/10; integratore su q_mis, process noise e link-side |
| Progetto_Hinf_simulink | Originale Valerio; errore a 2 ingressi | Incompatibile con controller finale 2x4 | simulink/originals | Cap.10; architettura 2-DoF da completare manualmente |
| Kmu | Non presente tra gli originali | Mancante | Nessun modello sostitutivo | Attività manuale |
| Plant linearizzato | Non presente tra gli originali | Mancante | Nessun modello sostitutivo | Attività manuale |
| Sette diagrammi prodotti dagli script | Provenienza verificata dai generatori e dal contenuto XML | Esclusi dalla consegna | Backup esterno | Risultati e immagini non attribuiti agli originali |

L'audit statico ha riscontrato: tau_d aggiunta sul lato motore; rumore encoder scalare condiviso; rumore di processo LQRI non collegato; integratore LQRI alimentato dalla posizione ideale; ingresso libero nella somma della derivata; dipendenze Gact e slBus1. I blocchi LTI richiamano la libreria standard cstblocks_lti. Non vengono sostituiti o ricablati automaticamente.

Il setup aggiunto fornisce dati e definizione del bus già dichiarato. Non altera i file SLX e rifiuta il caricamento del controller Hinf 2x4 nell'interfaccia originale a due ingressi.

## Backup e rimozioni

Prima delle rimozioni è stato creato e verificato:
C:/Users/aless/Desktop/Progetto_ISCR/CR/Progetto_CR_prima_revisione_organica_91ea492.zip

CRC di tutti gli elementi verificato e confronto byte dei dieci SLX effettuato. Le copie esatte del working tree, incluse le differenze CRLF dei testi, sono anche in:
C:/Users/aless/Desktop/Progetto_ISCR/CR/Progetto_CR_backup_organico_files

removed_files.json elenca file e hash. Non è stata riscritta la storia Git.
Sono esclusi diagrammi generati, generatori, simulatori e test esclusivi, relativi dati/figure/report e copie documentali obsolete. I test matematici e i risultati MATLAB consolidati sono conservati.

Diario, decision log e changelog sono registri amministrativi append-only e non fanno parte del testo della consegna. Le loro vecchie voci non sono cancellate; la nuova decisione precisa quali conclusioni sono applicabili alla consegna attuale.

## Verifiche e risultati

105/105 test MATLAB PASS, inclusi 9 nuovi test. I sette test del limite inferiore sono conservati e rieseguiti.
Due suite preesistenti rigenerano internamente i dataset del modello attuato e delle specifiche: confronto isequaln PASS con gli originali; byte iniziali ripristinati. run_all protegge ora anche le relative figure tramite backup temporaneo.
Nessuna sintesi, nuova Monte Carlo, nuova ricerca RAS o nuova mu-analysis.

Audit Simulink: tre tentativi di caricamento, tre errori LoadingNewerModel (file R2026a, ambiente R2025b Update 4). Nessuna compilazione o simulazione degli originali riuscita. Non è stata forzata la conversione.
Le due prove locali non lineari eseguite dai test usano MATLAB ode23t.

Rigenerati soltanto grafici di audit D–K/margini e documenti a partire dai dati salvati. Risultati Hinf/Kmu e relativi esiti negativi invariati. L'intervallo RP Hinf invertito resta non validato.

## Struttura didattica finale

- Capitolo 7: costo fisico LQR, scelta finita, Kalman, separazione, tracking, LQRI, disturbo e limiti.
- Capitolo 8: norma Hinf; S/T/KS; pesi e unità; ricerca e limite inferiore; mixsyn; generalized plant/hinfsyn; vero 2-DoF; strutture e multistart; confronto e limiti.
- Capitolo 9: incertezze normalizzate; occorrenze; LFT inferiore/superiore; definizione e limiti di mu; NS/NP/RS/RP; blocco prestazionale; D/G–K e fit; post-analisi e confronto.
- Presentazione: 19 slide, 17:15; diagrammi P-K/N-Delta, blocco di prestazione, ciclo D-K e grafici salvati. Nessuna schermata di un modello incompleto.

## Attività esclusivamente manuali residue

1. Rendere caricabili gli originali con R2026a o esportazione compatibile verificata.
2. Correggere manualmente disturbo, rumori, integratore e ingressi liberi; validare segni e coordinate.
3. Completare manualmente Hinf 2-DoF, Kmu e plant linearizzato; eseguire confronti lineari/non lineari e RAS LQG/LQRI sugli originali.
4. Completare matricole/data, provare l'esposizione a cronometro e revisionare la PR draft prima dell'eventuale merge.
