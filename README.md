# Controllo robusto di un manipolatore SEA a due giunti

Alessio de Dato (635256) e Valerio Rebechi (722224). Il progetto segue la Traccia n. 2 del professor Salaris: due masse puntiformi, molle SEA e due drive del secondo ordine con ritardo Padé. Il confronto principale riguarda le rappresentazioni delle incertezze attuative, parametrica A e concentrata additiva B, con la stessa meccanica incerta.

## Esecuzione

MATLAB R2026b, Control System Toolbox, Robust Control Toolbox; Simulink per gli otto SLX. Dalla radice del repository o dalla cartella estratta della consegna:

```matlab
run_all                 % ricostruisce il modello; usa le sintesi onerose salvate
run_all('completa')      % rigenera sintesi, robustezza, simulazioni, RAS e SLX
```

`parametri_sea.m` è l'unica configurazione del percorso corrente. `run_all.m` richiama sette script accorpati con Workspace separati. Il percorso è modello → incertezze → LQG → LQGI → H∞/PID → μ → confronto e RAS. `matrici_sea`, `dinamica_sea`, `interconnessione_sea` e `simula_sea` condividono equazioni e collegamenti.

La modalità rapida ricalcola A/B, peso, campioni, LQG/LQGI, risposte e rumore, e ripete una verifica non lineare locale. Carica H∞/D–K, analisi robuste e RAS verificandone la firma di configurazione e l'identità dei controllori. Per aggiornare soltanto la post-analisi, con modelli e controllori già salvati, aggiungere `File_di_Funzioni_Progetto-Accorpati` al percorso MATLAB ed eseguire `postanalisi_sea(true)`. La completa include due D–K, 14 post-analisi A/B, 77 casi lineari, 14 prove non lineari nominali, 21 con sola massa variata, 105 RAS e 20 run Simulink. Può richiedere un tempo elevato per i reali ripetuti e gli scaling. Per una sessione priva di grafica si può impostare `setenv('SEA_FIGURE','off')`; il percorso numerico resta lo stesso.

## Modello corrente

- Sole masse della traccia: m1=1 kg e m2=0.8 kg. m2 incerta ±10%, in [0.72,0.88] kg, condivisa da M/C/G e da A/B.
- Drive: wn=40 rad/s ±15%, td=15 ms ±20%, zeta=0.8 noto. Due canali con variazioni indipendenti.
- A: cinque reali indipendenti, wn1/td1/wn2/td2/m2. Le occorrenze ripetute restano correlate.
- B: due perturbazioni dinamiche SISO additive e la stessa m2. Peso di ordine 3, verificato in norma sui 25 casi di costruzione e sui 30 indipendenti. Copertura globale non dimostrata.
- Equilibrio verticale [pi/2;0], 14 stati fisici. I target adottati sono Ts≤5 s, overshoot≤15%, errore statico≤5% e cross≤25%. Stessi pesi e modello desiderato nelle due D–K.

Le tolleranze sono ipotesi ingegneristiche. La RAS è una sezione empirica nominale; i comandi sono risultati diagnostici senza limiti hardware assegnati. NS e RS riguardano la stabilità interna della chiusura. NP e RP applicano la soglia in norma unitaria alla mappa dichiarata verso errore e comando pesati. La post-analisi corrente usa il solo riferimento e il confronto storico include anche la coppia. Le prove di coppia e rumore descrivono scenari separati.

## Risultati e verifiche

Lo stato, gli esiti favorevoli e negativi e le verifiche effettivamente eseguite sono in [REVISIONE_TRACCIA_20261104.md](docs/REVISIONE_TRACCIA_20261104.md). I MAT/CSV sotto `File_di_Funzioni_Progetto-Accorpati/risultati` alimentano le tabelle e le figure. `confronto_robusto_r.*` identifica la post-analisi corrente `Tzr_v1`. `confronto_robusto.*` conserva la campagna storica su riferimento e disturbo. Con i dati validati disponibili, `studio_mu_riferimento` ricalcola il riesame dei controllori salvati e ripete le prove nominali sui candidati che passano RP in A e B. I risultati separati si trovano in `risultati/studio_mu_riferimento/`. MuN1 è il comparatore recuperato dall'inizializzazione comune dei due percorsi D–K.

Cinque test indipendenti correnti: `runtests('tests/seaFinaleTest.m')`. `verifica_sea` esegue otto controlli scientifici del percorso. I vecchi runner e i risultati in `analysis`, `controllers`, `results` e parte della documentazione restano patrimonio storico; i loro esiti non sono trasferiti alla configurazione corrente. `dati/banca_validata.mat` conserva costi e riferimenti fissati, senza sostituire le sintesi correnti.

## Elaborati

- La [relazione integrale](report/Progetto_CR_Relazione_finale.pdf) contiene l’indice generale e i 13 capitoli.
- La presentazione contiene 23 slide ed è disponibile in [PDF](presentation/Progetto_CR_Presentazione.pdf) e [PowerPoint](presentation/Progetto_CR_Presentazione.pptx).
- [Discorso orale](presentation/Presentazione_orale.txt) e [tempi stimati](presentation/OUTLINE_AND_TIMING.md).
- [Consegna autonoma](delivery/Consegna_Progetto_SEA.zip), rigenerata dagli stessi sorgenti e dati.

La compilazione usa i sorgenti LaTeX esistenti. `tools/esporta_definitiva.py` aggiorna le tabelle; gli esportatori delle figure leggono dati salvati. `tools/consegna_definitiva.py` verifica SHA-256 e integrità ZIP. Google Drive resta in sola lettura. La relazione integra le revisioni dei Capitoli 1–13, la specifica di assestamento a 5 s e il confronto fra le due mappe di prestazione. Lo stato delle verifiche editoriali è in [PROJECT_STATUS.md](docs/PROJECT_STATUS.md). La ZIP rimane quella collaudata il 4 novembre e contiene la versione precedente del PDF.
