# Controllo robusto di un manipolatore SEA a due giunti

Alessio de Dato (635256) e Valerio Rebechi (722224). Progetto con carico incerto all’end-effector e ritardo variabile nei due drive. Un solo percorso MATLAB accorpato, gli otto modelli Simulink esistenti e confronto fra rappresentazione parametrica A e concentrata B.

## Esecuzione

MATLAB R2026b, Control System Toolbox, Robust Control Toolbox; Simulink per gli SLX. Dalla radice:

```matlab
run_all                 % ricalcola modello e verifiche; carica le sintesi onerose
run_all('completa')      % rigenera sintesi, robustezza, 105 RAS e 20 run SLX
```

La rapida ricostruisce A/B e il peso, sintetizza LQG/LQGI, verifica la coerenza dei dati caricati e ripete risposte, rumore e una simulazione locale. La completa include 14 prove non lineari nominali e 21 con solo carico variato. Richiede diverse decine di minuti, soprattutto per D–K e analisi robusta. Non servono Symbolic Math Toolbox né un Workspace preparato manualmente.

## Percorso operativo

`run_all.m` richiama sette script nella cartella `File_di_Funzioni_Progetto-Accorpati`: modello, incertezze, LQG, LQGI, H∞/PID, µ e confronto/RAS. `parametri_sea.m` centralizza le scelte. Le funzioni condivise `matrici_sea`, `dinamica_sea`, `interconnessione_sea`, `controllori_sea` e `simula_sea` evitano duplicazioni delle equazioni e dei controllori. `verifica_sea` e `collaudo_simulink` eseguono i controlli.

La banca in `dati/banca_validata.mat` conserva i coefficienti fissati del primo esperimento; le nuove sintesi sono in `risultati`. La firma di configurazione e l’identità dei controllori impediscono di usare dati incompatibili. Gli alberi `analysis`, `controllers` e `src` conservano la provenienza storica, fuori dal percorso corrente. Solo quattro helper di `src/model` sono richiesti dai MATLAB Function degli SLX.

## Modello e risultati

- Carico `mEE=0.2 kg`, intervallo `[0.1,0.3] kg`; contribuisce a M, C e G tramite `m2+mEE`.
- Drive nominali: 40 rad/s, 0.8, 15 ms; intervalli ±10%, ±10%, ±20%, indipendenti per canale.
- A: sei reali attuativi e una massa reale condivisa. B: due dinamiche SISO additive e la stessa massa reale.
- Peso additivo di ordine 3: massima norma normalizzata 0.9804 su 29 casi, 0.8788 su 30 casi indipendenti. Nessuna prova di copertura globale del box.
- Target: Ts≤2 s, Mp≤15%, ess≤5%, cross≤25%; modello desiderato `9/(s²+6s+9)`. Soglie NS/NP/RS/RP immutate.

LQG e LQGI mantengono RS su A/B ma non NP/RP sul costo comune. Hinf1 mantiene RS su A e la perde su B. Hinf2 e PID hanno NP ma falliscono RS/RP. Mu_A e Mu_B mantengono RS ma falliscono NP/RP e presentano offset e/o rumore elevati. Nessuna soluzione viene promossa soltanto per il valore della norma o il metodo di sintesi.

Dieci impianti fisici comuni: Hinf2 stabile in 4/10, PID in 7/10; gli altri cinque controllori correnti in 10/10. RAS: 86 convergenze, 12 mancate convergenze entro 15 s, 7 allontanamenti osservati su 105, nessun timeout o errore numerico. Sono sezioni empiriche nominali. Il rumore è verificato anche fra campioni; non sono inventati limiti di coppia hardware.

## Elaborati e consegna

- [Relazione](report/Progetto_CR_Relazione_finale.pdf), con i 13 capitoli e quattro appendici.
- [Presentazione](presentation/Progetto_CR_Presentazione.pdf), 23 slide.
- [Discorso](presentation/Presentazione_orale.txt), [note](presentation/SPEAKER_NOTES.md) e [tempi](presentation/OUTLINE_AND_TIMING.md): 16:50 stimati, prova dal vivo ancora necessaria.
- [ZIP autonomo](delivery/Consegna_Progetto_SEA.zip): estrarre e lanciare `run_all`.
- [Evidenze e requisiti R01–R22](docs/REVISIONE_DEFINITIVA.md), [stato](docs/PROJECT_STATUS.md), [diario](docs/DIARIO_DI_BORDO.md), [decisioni](docs/DECISION_LOG.md).

Gli SLX su disco restano invariati. `collaudo_simulink` aggiorna in memoria matrici, massa effettiva nei generatori incorporati, drive e controllori; usa `SimulationInput`, esclude le callback che sovrascriverebbero i dati e chiude senza salvare. L’esecuzione riproducibile passa dal runner. I 20 run verificano parametri, stati e Scope; non sostituiscono i target di controllo.

Per rigenerare gli elaborati: `python tools/esporta_definitiva.py`, due passaggi `pdflatex` nelle cartelle report e presentation e copia dei PDF ai nomi finali. `python tools/audit_oral_timing.py` aggiorna i tempi. `python tools/consegna_definitiva.py` confeziona gli stessi sorgenti e controlla ZIP e SHA-256. Python e LaTeX servono per modificare gli elaborati, non per eseguire la consegna.

Il ramo di lavoro è `codex/sea-revisione-finale-semplificata`, da main `dbf6f00` con PR #46 integrata. Drive è usato in sola lettura. La [PR #47](https://github.com/Deda-404/Progetto_CR/pull/47) è aperta e pronta per la revisione del gruppo. Nessun merge eseguito.
