# Resoconto H-infinity: revisione coerente

Branch `codex/hinf-final-coherent-revision`, base main `693e316` (PR #31, tecnico `b6155a4`). Nessun merge. Responsabile: Alessio.

## Esito

Catena numerica M9–M18 ricostruita sui nuovi controllori. Kmu è il candidato robusto: RS/RP PASS; H-infinity è un comparatore nominale, non raccomandato per implementazione a causa della fragilità e dell'amplificazione del rumore. M5 rimane FAIL per entrambi. Nessun risultato negativo è stato trasformato in PASS.

## Audit e lower bound

L'audit iniziale precede le modifiche ed è in `HINF_FINAL_INITIAL_AUDIT.md`.
Da S+GKS=I, minimizzando a²||v-Gx||²+b²||x||², si ottiene
H=a²I-a⁴G(a²G*G+b²I)^(-1)G*. Il massimo autovalore conduce al bound
ab/sqrt(b²+a² sigma_min(G)²). La direzione è il vettore singolare sinistro
debole. Pesi scalari replicati e b>0; non serve rango pieno. Il supremo
continuo è un lower bound; il massimo campionato non certifica fattibilità.
Verdetto: sigma_min corretto, formula conservata. Sette test PASS prima delle sintesi.

## Pesi e ricerca

21 profili dichiarati in `hinf_final_config.m`, non un prodotto cartesiano.
Baseline riprodotta: (omegaW1,As,Ms,ku,omegaU)=(2,.20,4,.003,80).
Migliore 1-DoF: (2,.15,3,.003,80), pesi adottati anche nel 2-DoF.
alpha=6, nessun W3. M5, incertezze, attuatori e fisica invariati.
La penalizzazione ku=.003 non viene chiamata ottima.
`one_dof.csv` contiene tutti i 21 candidati, parametri, bound, gamma dei due solver,
norme dello stack, massimi temporali, ordine, NS e NP; le matrici e i poli sono nei MAT.
Colonne CSV: id, cinque parametri, bound, gammaMix, gammaHinf, tre norme,
Ts/OS/ess/cross/picco/RMS, ordine/NS/NP.

Il primo controllo con RelTol predefinita è conservato integralmente in
`numerical_diagnostics_default_solver`. Due differenze mixsyn/hinfsyn
superavano la tolleranza dell'audit per la precisione di arresto del solver.
La campagna definitiva usa RelTol=1e-4 per entrambi, senza cambiare le soglie.
Questo spiega gamma riprodotta .862267 rispetto alla precedente .866036.
Tutti i 21 casi superano l'audit delle identità; quelli con gamma>1 restano negativi.

## Risultati nominali

Massimi sui due gradini 5°, 12 s, dt=.002 s. Assestamento nella fascia 2%
attorno al DC finale; errore statico verificato separatamente. RMS sui due comandi e sull'intero orizzonte.

| Caso | Norma propria | Ordine | Ts s | OS % | ess relativo | Cross | Picco Nm | RMS Nm |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Baseline riprodotta | 0.8622669 | 18 | 1.456 | 129.916 | 0.1706854 | 0.1851985 | 13.26335 | 1.001502 |
| Migliore 1-DoF | 0.9534125 | 18 | 1.558 | 125.2761 | 0.142055 | 0.1813211 | 13.96453 | 0.9952691 |
| Vero 2-DoF | 0.04746058 | 22 | 1.46 | 0 | 0.00516895 | 0.01424643 | 0.8682575 | 0.5849533 |

Il vecchio prefiltro/command-shaping rimane storico: Ts 1.784 s, OS circa1.76%,
picco .843 Nm, norma della propria mappa 1.38148>1. Non è una sintesi 2-DoF.
Il nuovo controllore riceve [r;q], ha stati condivisi e produce u=Kr*r+Ky*q.
La pianta è 8x6; w=[r;d], d entra tramite BdFull; z=[We(q-Mo*r);Wu*u].
Mo è un secondo ordine criticamente smorzato con frequenze 2,3,4 rad/s.
Le norme sono rispettivamente .0305405, .0312036, .0474606; si sceglie 4 rad/s
per il minor fallimento temporale, non per la norma più piccola.
Norme di problemi diversi non sono confrontate come se fossero lo stesso obiettivo.
Il picco senza rumore è inferiore alla scala 12 Nm, che non è un limite hardware.

## Hinfstruct

11 avvii per famiglia (RandomStart=10), seed espliciti. Ordine 8 non necessario.

| Famiglia | Avvii | NS | NP | Migliore norma |
|---|---:|---:|---:|---:|
| STATIC | 11 | 0 | 0 | NON VALIDATO |
| PI | 11 | 0 | 0 | NON VALIDATO |
| PID | 11 | 5 | 4 | 0.8009463 |
| SS2 | 11 | 10 | 8 | 0.6821904 |
| SS4 | 11 | 11 | 11 | 0.2650774 |
| SS6 | 11 | 11 | 11 | 0.1220644 |

Ordine minimo OSSERVATO: 2; nessuna pretesa di ottimalità globale.
Il migliore ordine 2 ha OS22.82% e cross .386, quindi il full-order resta il comparatore nominale.

## M12–M14

Hinf: NS/NP PASS, RS FAIL, margine [.018124894,.018161666], frequenza critica70.32 rad/s.
robgain restituisce [.017254265,.017194475] invertito anche dopo MussvOptions=m9:
intervallo RP NON VALIDATO; RP è comunque esclusa perché richiede RS.
Gli estremi non sono stati scambiati. Dati e primo tentativo restano nel MAT.

D-K: una campagna sullo stesso problema 2-DoF, cinque iterazioni,
objective .883809558, Kmu ordine78. Post-analisi indipendente:
NS PASS, NP PASS (.634679627), RS PASS [1.7997984,1.8044243],
RP PASS [1.6771692,1.6806616]. Nessun vecchio Kmu/certificato riutilizzato.
Kmu tracking: Ts [1.522,1.478] s, OS0, offset [5.998,3.067]%,
cross massimo .10989, picco .798054 Nm. M5 FAIL: assestamento e offset sul primo giunto.

## Non lineare, rumore, RAS, Lyapunov

Tutte le equazioni di controllo sono calcolate in MATLAB. Integrazione diretta
ode23t delle equazioni SEA esistenti, RelTol1e-5, AbsTol1e-7, MaxStep.005;
usati gli stessi scenari M15. Non viene dichiarata una nuova esecuzione Simulink:
il modello storico conserva l'interfaccia 1-DoF e non è modificato.
Il nuovo integratore è verificato contro le risposte lineari a piccolo segnale.
Rispetto ai tempi adattivi Simulink, l'uscita uniforme .002 s introduce una
differenza di campionamento nelle metriche di coda; il confronto è paired
per condizioni iniziali, criteri, orizzonti e rumore, non per i passi interni.

Tracking a 2/5/8° e disturbi .25/.5/1 Nm ricalcolati per entrambi.
L'offset NL usa la media della coda effettiva (ultimo10%), correggendo
l'uso del DC lineare nel vecchio estrattore. I risultati storici restano invariati.
Il rumore è la stessa sequenza M15; ripetizione identica.
Hinf: picco5685.14 Nm, RMS118.233 Nm. Kmu: picco8.12068 Nm, RMS1.93368 Nm.
Questi valori impediscono di giudicare il comando dal solo gradino privo di rumore.

RAS: stessi25 punti di griglia,36 direzioni, box±60°, risoluzione1°, orizzonti8/12s.
L'evento a magnitudine1e6 anticipa un FAIL già previsto dal criterio invariato.
Hinf27/285 punti convergenti; raggio minimo risolto0°, massimo6.984°;
zero non significa assenza di una RAS locale. Kmu57/57 convergenti,
tutti gli estremi del box: SEARCH-BOX LIMITED, non frontiera certificata.
Picchi sui punti convergenti61.06 Nm e2763.22 Nm: nessuna garanzia hardware.

Lyapunov Hinf: P positiva ma residuo65.2659, gate numerico FAIL; nessun certificato.
Kmu: n92, residuo.0449288, rho interno1.06569e-12; livello campionato3.69696,
verifica indipendente2048 direzioni x4 frazioni PASS. Il livello campionato non è certificato.

## Monte Carlo e selezione M17

Stessi40 campioni M16 (identità verificata, seed20260826). Hinf0/40 stabili,
Kmu40/40. LQG resta37/40 sulla medesima sequenza invariata, senza riuso per i nuovi K.
Ruoli: LQG riferimento M5 nominale; Hinf comparatore nominale fragile;
Kmu candidato robusto M4, con limiti temporali e implementativi espliciti.

## PRIMA / DOPO

| Voce | Prima | Dopo Hinf / Kmu |
|---|---|---|
| Gamma full | .866036 (1-DoF) | .0474606 / .634680 (problema2-DoF) |
| Ordine full |18|22 /78|
| Gamma fixed |.879227|.682190|
| Ordine fixed minimo osservato |6|2|
| Ts massimo s |1.456|1.460 /1.522|
| OS massimo % |circa130.1|0 /0|
| Offset massimo % |circa17.14|.5169 /5.998|
| Cross massimo |circa.185|.01425 /.10989|
| Picco tracking Nm |13.31|.8683 /.7981|
| RS margin |non calcolato per K.866; vecchio Kmu circa.775|.0181 FAIL /1.800 PASS|
| RP |non trasferibile|FAIL per RS, intervallo non validato /PASS|
| MC stabile |vecchia catena40/40,40/40|0/40,40/40|
| M5 |FAIL|FAIL /FAIL|

## Verifiche e riproducibilità

18 test MATLAB PASS:7 lower bound,6 coerenza nominale/robusta/fixed-order,
5 downstream (mappa NL locale per entrambi, identità40campioni, identitàNL,
gate Lyapunov). Gli errori di setup iniziali e il primo arresto Lyapunov sono
registrati nei log; risolti il setup e la gestione esplicita del risultato negativo.
MATLAB ha inizialmente incontrato errore5201, risolto riavviando Service Host.
Non si ripete l'intero run_all dopo avere eseguito separatamente tutti i calcoli
mirati: evita costo computazionale inutile e rispetta la richiesta di contenere le esecuzioni.
`run_all` instrada ora la catena corrente; `CR_RUN_SCOPE=legacy` identifica quella storica.
Esportazione: `export_hinf_final_results`, poi `python report/build_hinf_final_text.py`,
compilazione LaTeX da `report/`. Python formatta risultati MATLAB, non calcola controllo.

Aggiornati Sommario, Capitoli8–13, AppendiceB, riproducibilità, macro e tracciabilità
M18, README, stato, diario, decisioni e changelog. Capitoli1–7 congelati.
I dati precedenti e i primi tentativi numerici sono conservati; sorgenti e PDF
precedenti archiviati. La lista dei file correnti e SHA256 è nel manifest M18.

## Limiti e TODO umani

Matricole e data definitiva di consegna. Revisione manuale prima del merge.
Non validati: intervallo numerico RP Hinf, certificato Lyapunov Hinf,
saturazioni/hardware, non lineare incerto, nuova interfaccia Simulink2-DoF.
I calcoli NL/RAS richiesti sono stati eseguiti in MATLAB e sono disponibili.
Risultati peggiorati:RS/MonteCarlo/rumore/RAS Hinf; complessitàKmu78 vs70.
Nessun merge automatico.
