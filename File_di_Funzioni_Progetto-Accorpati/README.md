# Percorso MATLAB corrente

Dalla radice eseguire `run_all` oppure `run_all('completa')`. La prima modalità ricalcola modello, incertezze, LQG/LQGI e verifiche, caricando le sintesi onerose coerenti; la seconda rigenera anche H∞/PID, le due D–K, le post-analisi A/B, le prove non lineari, la RAS e Simulink.

`parametri_sea.m` centralizza masse, geometrie, attuatori, incertezze, specifiche, tempi e seed. La meccanica contiene soltanto m1=1 kg e m2=0.8 kg ±10%. I quattro reali attuativi sono frequenze naturali ±15% e ritardi ±20%; zeta=0.8 resta noto. A e B condividono meccanica, equilibrio e nominale. B concentra soltanto i drive.

I sette script operativi sono modello_sea, incertezze_attuatori, progetto_lqg, progetto_lqgi, progetto_hinf_tre_controllori, progetto_mu e confronto_ras. I Workspace sono separati. Eseguire uno script isolato richiede i risultati delle fasi precedenti; run_all gestisce l'ordine senza preparazione manuale.

MATLAB R2026b, Control System Toolbox e Robust Control Toolbox; Simulink per gli otto modelli esistenti. Le callback richiamano collaudo_simulink per assegnare il nominale. La variabile incorporata m2_eff rappresenta soltanto m2 e non una massa aggiuntiva.

I dati correnti sono in risultati/. La banca in dati/ conserva i coefficienti e i costi di riferimento; le vecchie cache non superano la firma corrente. I controlli scientifici sono verifica_sea e tests/seaFinaleTest.m. Le condizioni NS/NP/RS/RP e i target temporali si leggono separatamente. Stato e limiti: ../docs/REVISIONE_TRACCIA_20261104.md.
