# Progetto SEA: istruzioni per la consegna

Alessio de Dato (635256), Valerio Rebechi (722224). 25 ottobre 2026.

Estrarre tutto lo ZIP, aprire `SEA_00_AVVIO_PROGETTO.m` in MATLAB e premere
**Run**. Non servono GitHub, Drive, Python, LaTeX o addpath manuali.
Ambiente verificato: MATLAB R2026b, Control System Toolbox e Robust Control
Toolbox. La riproduzione MATLAB non richiede Simulink o Symbolic Math Toolbox.

Il prefisso SEA è necessario: MATLAB non esegue script con nomi che iniziano
con una cifra. La numerazione 00-05 mantiene l'ordine didattico richiesto.

## Due modalità

In `parametri_sea.m`, la prima assegnazione è `p.modalita="rapida"`.

- **Rapida**, predefinita: ricostruisce i modelli e LQG/LQGI; carica le sintesi
  H∞/D-K, i margini robusti, i dieci impianti e la RAS già eseguiti. Produce
  tabelle e grafici, con messaggi che distinguono caricamento e calcolo.
- **Completa**: cambiare solo quella riga in `p.modalita="completa"`, poi
  eseguire lo stesso avvio. Ripete mixsyn, hinfsyn, un avvio hinfstruct, due
  D-K, post-analisi robusta, dieci impianti e simulazioni non lineari/RAS.
  Può richiedere diversi minuti. I timeout del solver sono esiti inconcludenti.

`p.figure=false` disattiva le finestre. Ogni script può essere aperto e avviato
singolarmente, mantenendo tutta la cartella estratta. `banca_consolidata.mat`
non viene sovrascritto. La completa aggiorna solo gli altri risultati S1 in
`dati/` e le figure corrispondenti; conservare una copia dello ZIP per confronti
fra esecuzioni o release diverse. Le durate e i limiti numerici possono cambiare.

## Percorso di lettura

| Script | Contenuto |
|---|---|
| SEA_00_AVVIO_PROGETTO | Avvio ordinato dei cinque passi |
| SEA_01_MODELLI_INCERTEZZE | Meccanica nominale, LFT manuale A, inviluppo B, verifiche |
| SEA_02_LQG_LQGI | Q/R, Kalman, Riccati, integratore misurato, piccoli sweep |
| SEA_03_HINF | P1/P2, mixsyn/hinfsyn omogenei e PID hinfstruct |
| SEA_04_MU_SINTESI | Due D-K, NS/NP/RS/RP e analisi incrociate |
| SEA_05_CONFRONTO_FINALE_RAS | Dieci impianti, nominale, non lineare, quindici punti RAS |

Gli unici ausiliari sono `parametri_sea`, `dinamica_sea` e `simula_sea`.
Formule, pesi e connessioni principali restano nei numerati.

## Problema scientifico dichiarato

Meccanica nominale; wn = 40 rad/s e zeta = 0.8, entrambi ±10% e indipendenti
fra i due attuatori. Ritardo noto 15 ms con Padé1, senza residuo aggiuntivo.
**A** conserva quattro parametri reali; **B** usa due blocchi dinamici SISO
indipendenti. Il peso analitico B contiene l'intero box A, ma ammette anche
dinamiche non fisiche per quel box. Non sono famiglie identiche.

I sei controllori consolidati sono conservati. Due nuove sintesi dedicate
Mu_A/Mu_B sono confrontate separatamente; non sono promosse automaticamente.
Pesi e target originali restano invariati. I dati mostrano garanzie robuste
raggiunte ma anche target temporali persi, amplificazione del rumore e
limiti non lineari. Consultare la relazione prima di interpretare i margini.

La RAS è una sezione empirica su quindici punti: verde convergente, rosso
non convergente entro l'orizzonte, grigio numericamente inconcludente.
Non è una certificazione del bordo della regione di attrazione.

## Documenti e risultati

- `documenti/relazione/Relazione_SEA.pdf`: relazione completa, con sorgenti.
- `documenti/presentazione/Presentazione_SEA.pdf`: 18 slide.
- `documenti/PRESENTAZIONE_NOTE.md`: regia, contenuti e tempi pianificati
  19:19; la durata reale richiede una prova cronometrata.
- `documenti/TRACCIABILITA.md`: copertura della traccia e limiti.
- `documenti/INTERFACCIA_SIMULINK.md`: segnali, matrici e condizioni iniziali.
- `dati/quadro_finale.csv`: sintesi del confronto; gli altri CSV conservano
  intervalli completi, metodi, metriche per campione ed esiti delle simulazioni.

Tutti gli stati di impianto e controllore sono integrati nelle simulazioni.
Nei MAT finali si conservano traiettorie q/u e indicatori necessari, evitando
centinaia di checkpoint. Le formule permettono il ricalcolo completo.

## Simulink

Gli studenti forniranno gli SLX definitivi. Nessun modello è stato creato,
modificato, risalvato o riorganizzato per S1. La nuova integrazione Simulink
è **NOT RUN**. I risultati storici MATLAB/Simulink, compreso lo studio del
rumore su M4, sono conservati e identificati come tali nella relazione.
Non vengono trasferiti ai nuovi modelli o controllori.

Per preparare le variabili dei futuri SLX, l'avvio esporta
`dati/interfacce_simulink.mat`. Non occorre avviare una D-K per usarlo.
