# Controllo robusto di un manipolatore SEA a due giunti

Alessio de Dato (635256) e Valerio Rebechi (722224). Il progetto segue la Traccia n. 2 del professor Salaris: due masse puntiformi, molle SEA e due drive del secondo ordine con ritardo Padé. Il confronto principale riguarda le rappresentazioni delle incertezze attuative, parametrica A e concentrata additiva B, con la stessa meccanica incerta.

## Esecuzione

MATLAB R2026b, Control System Toolbox, Robust Control Toolbox; Simulink per gli otto SLX. Dalla radice del repository o dalla cartella estratta della consegna:

```matlab
run_all                 % ricostruisce il modello; usa le sintesi onerose salvate
run_all('completa')      % rigenera sintesi, robustezza, simulazioni, RAS e SLX
```

`parametri_sea.m` è l'unica configurazione del percorso corrente. `run_all.m` richiama sette script accorpati con Workspace separati. Il percorso è modello → incertezze → LQG → LQGI → H∞/PID → μ → confronto e RAS. `matrici_sea`, `dinamica_sea`, `interconnessione_sea` e `simula_sea` condividono equazioni e collegamenti.

La modalità rapida ricalcola A/B, peso, campioni, LQG/LQGI, risposte e rumore, e ripete una verifica non lineare locale. Carica H∞/D–K, analisi robuste e RAS verificandone la firma di configurazione e l'identità dei controllori. La completa include due D–K, 14 post-analisi A/B, 77 casi lineari, 14 prove non lineari nominali, 21 con sola massa variata, 105 RAS e 20 run Simulink. Può richiedere un tempo elevato per i reali ripetuti e gli scaling. Per una sessione priva di grafica si può impostare `setenv('SEA_FIGURE','off')`; il percorso numerico resta lo stesso.

## Modello corrente

- Sole masse della traccia: m1=1 kg e m2=0.8 kg. m2 incerta ±10%, in [0.72,0.88] kg, condivisa da M/C/G e da A/B.
- Drive: wn=40 rad/s ±15%, td=15 ms ±20%, zeta=0.8 noto. Due canali con variazioni indipendenti.
- A: cinque reali indipendenti, wn1/td1/wn2/td2/m2. Le occorrenze ripetute restano correlate.
- B: due perturbazioni dinamiche SISO additive e la stessa m2. Peso di ordine 3, verificato in norma sui 25 casi di costruzione e sui 30 indipendenti. Copertura globale non dimostrata.
- Equilibrio verticale [pi/2;0], 14 stati fisici. Target conservati: Ts≤2 s, overshoot≤15%, errore statico≤5%, cross≤25%. Stessi pesi e modello desiderato nelle due D–K.

Le tolleranze sono ipotesi ingegneristiche. La RAS è una sezione empirica nominale; i comandi sono risultati diagnostici senza limiti hardware assegnati. NS, NP, RS e RP rimangono proprietà distinte.

## Risultati e verifiche

Lo stato, gli esiti favorevoli e negativi e le verifiche effettivamente eseguite sono in [REVISIONE_TRACCIA_20261104.md](docs/REVISIONE_TRACCIA_20261104.md). I numeri autorevoli sono nei MAT/CSV correnti sotto `File_di_Funzioni_Progetto-Accorpati/risultati`; tabelle e figure dei PDF derivano da quei dati.

Cinque test indipendenti correnti: `runtests('tests/seaFinaleTest.m')`. `verifica_sea` esegue otto controlli scientifici del percorso. I vecchi runner e i risultati in `analysis`, `controllers`, `results` e parte della documentazione restano patrimonio storico; i loro esiti non sono trasferiti alla configurazione corrente. `dati/banca_validata.mat` conserva costi e riferimenti fissati, senza sostituire le sintesi correnti.

## Elaborati

- [Relazione integrale](report/Progetto_CR_Relazione_finale.pdf): 13 capitoli e quattro appendici.
- [Presentazione](presentation/Progetto_CR_Presentazione.pdf): 23 slide, con il confronto A/B dopo il modello dei drive.
- [Discorso orale](presentation/Presentazione_orale.txt) e [tempi stimati](presentation/OUTLINE_AND_TIMING.md).
- [Consegna autonoma](delivery/Consegna_Progetto_SEA.zip), rigenerata dagli stessi sorgenti e dati.

La compilazione usa i sorgenti LaTeX esistenti. `tools/esporta_definitiva.py` aggiorna le tabelle; gli esportatori delle figure leggono dati salvati. `tools/consegna_definitiva.py` verifica SHA-256 e integrità ZIP. Google Drive resta in sola lettura. La revisione del 10 novembre riguarda i sorgenti dei soli capitoli 1–4. Lo stato delle verifiche editoriali è in [PROJECT_STATUS.md](docs/PROJECT_STATUS.md). Il PDF e la ZIP collegati sopra appartengono alla consegna del 4 novembre.
