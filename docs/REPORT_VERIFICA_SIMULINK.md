# Verifica degli otto modelli Simulink

Prove locali del 13.10.2026. MATLAB 26.2.0.3386108 (R2026b) su Windows PCWIN64; Simulink, Control System, Robust Control e Symbolic Math Toolbox 26.2. Gli SLX R2026a Update 4 sono eseguiti in R2026b senza conversione.

## VALIDAZIONE SIMULINK R2026a — ESECUZIONE LOCALE

Il titolo identifica i modelli richiesti dalla traccia; la release effettivamente usata è **R2026b**, installata in `C:\Program Files\MATLAB\R2026b`. Otto LOAD PASS, COMPILE PASS, SIMULATION PASS e DYNAMIC VALIDATION PASS. Questi esiti attestano esecuzione e interpretazione dei segnali, non il soddisfacimento di ogni target prestazionale.

| Modello | Durata [s] | Solver salvato | Warning acquisiti | Esito |
|---|---:|---|---|---|
| mu_linear_sim | 10 | VariableStepAuto | nessuno | quattro livelli PASS |
| Hinf_linear_sim | 10 | VariableStepAuto | nessuno | quattro livelli PASS |
| LQGI_linear_sim | 10 | VariableStepAuto | nessuno | quattro livelli PASS |
| LQG_linear_sim | 10 | VariableStepAuto | nessuno | quattro livelli PASS |
| LQGI_nonlinear_sim | 10 | VariableStepAuto | nessuno | quattro livelli PASS |
| LQG_nonlinear_sim | 4 | ode23t | nessuno | quattro livelli PASS |
| Hinf_nonlinear_sim | 10 | VariableStepAuto | nessuno | quattro livelli PASS |
| mu_nonlinear_sim | 10 | VariableStepAuto | nessuno | quattro livelli PASS |

## Acquisizione e controlli

`sim` restituisce `tout`; il logging degli Scope è disattivato negli originali. `acquire_student_scope_buffers.m` legge i buffer visivi già esistenti con l’API interna R2026b `Simulink.scopes.WebScope.getAllInstances/getDataFromBuffer`. Nessun setter del modello, switch, logging, solver o callback è modificato. Il prefisso contiene i tempi; i segnali vettoriali successivi sono intercalati per campione. Il decoder è controllato anche con comando iniziale nullo dei controllori strettamente propri e feedthrough iniziale del PID confrontato con la matrice D salvata.

Le porte compilate, lo stato attivo dei blocchi e i percorsi sorgenti degli Scope sono nei JSON. I campioni coprono l’orizzonte completo e non contengono NaN/Inf. I MAT contengono tempi e valori esatti acquisiti; le figure sono prodotte da questi dati. RMS con quadratura trapezoidale sui tempi effettivi; picco massimo dei campioni, senza certificazione del massimo continuo. L’errore medio è calcolato nell’ultimo secondo, e=q−r. Il tempo di assestamento è l’ultima entrata nella fascia ±2% del riferimento di q1 nella prova combinata: non è il tempo di un gradino pulito.

## Descrizione e risultati per modello

### mu_linear_sim.slx

1. Struttura: anello lineare a 14 stati fisici e attuativi.
2. Controllore: Kμ a 78 stati, u=Kr r+Ky qmis.
3. Plant: Aplant 14×14, Bplant 14×8, Cplant 4×14, Dplant 4×8; ingressi [u;d;w_link;w_u].
4. Misure: quattro encoder [q1,q2,theta1,theta2]; H∞ e μ usano le prime due nel feedback.
5. Riferimento acquisito: [5°;0] da 1 s, posizione incrementale rispetto a qbar=[π/2;0].
6. Disturbo salvato: [0.5;0] N m lato link da 1 s; non separato dal riferimento in questo run.
7. Rumori: encoder σ=0.05°, processo con varianza 0.01 N²m², Ts=0.002 s, seed 20260826. I quattro rumori encoder attivi acquisiti sono correlati, con correlazione circa uno; non si assume indipendenza.
8. Interfaccia e legge: Kμ a 78 stati, u=Kr r+Ky qmis.
9. Inizializzazione: pianta, osservatore, integratori e controllori in deviazioni iniziali nulle.
10. Risultati: tutti i segnali acquisiti finiti, durata 10 s. La tabella distingue i rami effettivamente eseguiti.
11. Anomalie/limiti: rumori e disturbo presenti insieme; offset, oscillazioni e sforzo non sono nascosti. I picchi continui possono superare quelli registrati.

| Ramo | e medio q1/q2 [deg] | OS q1 [%] | Ts q1 [s] | Picco u1/u2 [N m] | RMS u1/u2 [N m] | RMS misura selezionata [deg] |
|---|---|---:|---|---|---|---|
| mu | 0.231943 / -0.557252 | 10.5929 | non raggiunto entro il run | 107.96 / 50.3382 | 12.8635 / 3.30551 | 0.0497186 |

Configurazione solver: `{"relative_tolerance": "1e-3", "absolute_tolerance": "auto", "max_step": "auto"}`.
Selettore `mu_linear_sim/Manual Switch`: sw=0, ingresso 2, sorgente `mu_linear_sim/Mux3`. Nessuna commutazione.

SHA-256 prima/dopo: `9d60a5b211c989f2c3324b47e6c218fc470d834d5633481c0d3c927c6eee078b`; coincide con il manifest. Figure: `report/figures/final_simulink/mu_linear_sim.png`. Dati e metadati: `mu_linear_sim_scope_buffers.mat`, `mu_linear_sim_dynamic_review.json`, `mu_linear_sim_audit.json` nella cartella dei risultati.

### Hinf_linear_sim.slx

1. Struttura: anello lineare a 14 stati fisici e attuativi.
2. Controllore: tre controllori in parallelo: H∞ 1-DoF (18 stati), H∞ 2-DoF (22) e PID (4).
3. Plant: Aplant 14×14, Bplant 14×8, Cplant 4×14, Dplant 4×8; ingressi [u;d;w_link;w_u].
4. Misure: quattro encoder [q1,q2,theta1,theta2]; H∞ e μ usano le prime due nel feedback.
5. Riferimento acquisito: [5°;0] da 1 s, posizione incrementale rispetto a qbar=[π/2;0].
6. Disturbo salvato: [0.5;0] N m lato link da 1 s; non separato dal riferimento in questo run.
7. Rumori: encoder σ=0.05°, processo con varianza 0.01 N²m², Ts=0.002 s, seed 20260826. I quattro rumori encoder attivi acquisiti sono correlati, con correlazione circa uno; non si assume indipendenza.
8. Interfaccia e legge: 1-DoF su r−qmis; 2-DoF/PID su [r;qmis], senza duplicare gli stati fra i due canali.
9. Inizializzazione: pianta, osservatore, integratori e controllori in deviazioni iniziali nulle.
10. Risultati: tutti i segnali acquisiti finiti, durata 10 s. La tabella distingue i rami effettivamente eseguiti.
11. Anomalie/limiti: rumore encoder bypassato nel feedback salvato; questo run non verifica la sensibilità agli encoder.

| Ramo | e medio q1/q2 [deg] | OS q1 [%] | Ts q1 [s] | Picco u1/u2 [N m] | RMS u1/u2 [N m] | RMS misura selezionata [deg] |
|---|---|---:|---|---|---|---|
| 1-DoF | 1.29729 / -0.732794 | 162.828 | non raggiunto entro il run | 13.9372 / 3.54759 | 1.85775 / 0.376298 | 0 |
| 2-DoF | 0.00799962 / -0.0575135 | 2.39412 | 8.794 | 1.72946 / 0.90966 | 1.22896 / 0.31828 | 0 |
| PID | -0.0142501 / -0.254528 | 76.509 | non raggiunto entro il run | 3.85287 / 0.710806 | 1.33178 / 0.233648 | 0 |

Configurazione solver: `{"relative_tolerance": "1e-3", "absolute_tolerance": "auto", "max_step": "auto"}`.
Selettore `Hinf_linear_sim/Manual Switch`: sw=0, ingresso 2, sorgente `Hinf_linear_sim/Mux3`. Nessuna commutazione.
Selettore `Hinf_linear_sim/Manual Switch1`: sw=0, ingresso 2, sorgente `Hinf_linear_sim/Mux1`. Nessuna commutazione.
Selettore `Hinf_linear_sim/Manual Switch2`: sw=0, ingresso 2, sorgente `Hinf_linear_sim/Mux6`. Nessuna commutazione.

SHA-256 prima/dopo: `27b5132d581c2d220ef3d3c5cce1c66fb13f95a0c2f9c2a390127ecd1a1cda9d`; coincide con il manifest. Figure: `report/figures/final_simulink/Hinf_linear_sim.png`. Dati e metadati: `Hinf_linear_sim_scope_buffers.mat`, `Hinf_linear_sim_dynamic_review.json`, `Hinf_linear_sim_audit.json` nella cartella dei risultati.

### LQGI_linear_sim.slx

1. Struttura: anello lineare a 14 stati fisici e attuativi.
2. Controllore: LQGI, 14 stati di osservatore e due integratori; u=−Kx xhat−Ki xi.
3. Plant: Aplant 14×14, Bplant 14×8, Cplant 4×14, Dplant 4×8; ingressi [u;d;w_link;w_u].
4. Misure: quattro encoder [q1,q2,theta1,theta2]; H∞ e μ usano le prime due nel feedback.
5. Riferimento acquisito: [5°;0] da 1 s, posizione incrementale rispetto a qbar=[π/2;0].
6. Disturbo salvato: [0.5;0] N m lato link da 1 s; non separato dal riferimento in questo run.
7. Rumori: encoder σ=0.05°, processo con varianza 0.01 N²m², Ts=0.002 s, seed 20260826. I quattro rumori encoder attivi acquisiti sono correlati, con correlazione circa uno; non si assume indipendenza.
8. Interfaccia e legge: integrazione dell’errore misurato r−qmis, non dello stato vero.
9. Inizializzazione: pianta, osservatore, integratori e controllori in deviazioni iniziali nulle.
10. Risultati: tutti i segnali acquisiti finiti, durata 10 s. La tabella distingue i rami effettivamente eseguiti.
11. Anomalie/limiti: rumori e disturbo presenti insieme; offset, oscillazioni e sforzo non sono nascosti. I picchi continui possono superare quelli registrati.

| Ramo | e medio q1/q2 [deg] | OS q1 [%] | Ts q1 [s] | Picco u1/u2 [N m] | RMS u1/u2 [N m] | RMS misura selezionata [deg] |
|---|---|---:|---|---|---|---|
| LQGI | 0.0180962 / -0.0260922 | 3.41722 | 8.008 | 1.47894 / 0.505781 | 1.22299 / 0.207605 | 0.0497376 |

Configurazione solver: `{"relative_tolerance": "1e-3", "absolute_tolerance": "auto", "max_step": "auto"}`.

SHA-256 prima/dopo: `6c8248318c57d30853d345992dbf0d0e18256ca019c99a89107bd5729fa374dc`; coincide con il manifest. Figure: `report/figures/final_simulink/LQGI_linear_sim.png`. Dati e metadati: `LQGI_linear_sim_scope_buffers.mat`, `LQGI_linear_sim_dynamic_review.json`, `LQGI_linear_sim_audit.json` nella cartella dei risultati.

### LQG_linear_sim.slx

1. Struttura: anello lineare a 14 stati fisici e attuativi.
2. Controllore: LQG, 14 stati di osservatore; u=Nr r−K xhat.
3. Plant: Aplant 14×14, Bplant 14×8, Cplant 4×14, Dplant 4×8; ingressi [u;d;w_link;w_u].
4. Misure: quattro encoder [q1,q2,theta1,theta2]; H∞ e μ usano le prime due nel feedback.
5. Riferimento acquisito: [5°;0] da 1 s, posizione incrementale rispetto a qbar=[π/2;0].
6. Disturbo salvato: [0.5;0] N m lato link da 1 s; non separato dal riferimento in questo run.
7. Rumori: encoder σ=0.05°, processo con varianza 0.01 N²m², Ts=0.002 s, seed 20260826. I quattro rumori encoder attivi acquisiti sono correlati, con correlazione circa uno; non si assume indipendenza.
8. Interfaccia e legge: LQG, 14 stati di osservatore; u=Nr r−K xhat.
9. Inizializzazione: pianta, osservatore, integratori e controllori in deviazioni iniziali nulle.
10. Risultati: tutti i segnali acquisiti finiti, durata 10 s. La tabella distingue i rami effettivamente eseguiti.
11. Anomalie/limiti: rumori e disturbo presenti insieme; offset, oscillazioni e sforzo non sono nascosti. I picchi continui possono superare quelli registrati.

| Ramo | e medio q1/q2 [deg] | OS q1 [%] | Ts q1 [s] | Picco u1/u2 [N m] | RMS u1/u2 [N m] | RMS misura selezionata [deg] |
|---|---|---:|---|---|---|---|
| LQG | 4.14389 / -1.60494 | 85.4564 | non raggiunto entro il run | 4.74994 / 0.889303 | 1.82978 / 0.311894 | 0.0497376 |

Configurazione solver: `{"relative_tolerance": "1e-3", "absolute_tolerance": "auto", "max_step": "auto"}`.

SHA-256 prima/dopo: `eb01cb8e66b919301181c647c931d9ffbaf48dac3b0fc5eb8d8df87da36f1ea9`; coincide con il manifest. Figure: `report/figures/final_simulink/LQG_linear_sim.png`. Dati e metadati: `LQG_linear_sim_scope_buffers.mat`, `LQG_linear_sim_dynamic_review.json`, `LQG_linear_sim_audit.json` nella cartella dei risultati.

### LQGI_nonlinear_sim.slx

1. Struttura: anello con equazioni meccaniche non lineari e attuatori LTI.
2. Controllore: LQGI, 14 stati di osservatore e due integratori; u=−Kx xhat−Ki xi.
3. Plant: otto stati meccanici assoluti più sei attuativi, disturbo positivo sulle accelerazioni dei link.
4. Misure: quattro encoder [q1,q2,theta1,theta2]; H∞ e μ usano le prime due nel feedback.
5. Riferimento acquisito: [5°;0] da 1 s, posizione incrementale rispetto a qbar=[π/2;0].
6. Disturbo salvato: [0.5;0] N m lato link da 1 s; non separato dal riferimento in questo run.
7. Rumori: encoder σ=0.05°, processo con varianza 0.01 N²m², Ts=0.002 s, seed 20260826. I quattro rumori encoder attivi acquisiti sono correlati, con correlazione circa uno; non si assume indipendenza.
8. Interfaccia e legge: integrazione dell’errore misurato r−qmis, non dello stato vero.
9. Inizializzazione: meccanica a xbar, velocità nulle; attuatori, osservatore e controllore in deviazioni nulle.
10. Risultati: tutti i segnali acquisiti finiti, durata 10 s. La tabella distingue i rami effettivamente eseguiti.
11. Anomalie/limiti: rumori e disturbo presenti insieme; offset, oscillazioni e sforzo non sono nascosti. I picchi continui possono superare quelli registrati.

| Ramo | e medio q1/q2 [deg] | OS q1 [%] | Ts q1 [s] | Picco u1/u2 [N m] | RMS u1/u2 [N m] | RMS misura selezionata [deg] |
|---|---|---:|---|---|---|---|
| LQGI | 0.0177844 / -0.0261094 | 3.41056 | 8.008 | 1.47881 / 0.505494 | 1.22191 / 0.207376 | 0.0497376 |

Configurazione solver: `{"relative_tolerance": "1e-3", "absolute_tolerance": "auto", "max_step": "auto"}`.

SHA-256 prima/dopo: `c1ceef864070be2afc5ae0dba9b3481f80c9378c05555e47f3d17f2a3152bcfe`; coincide con il manifest. Figure: `report/figures/final_simulink/LQGI_nonlinear_sim.png`. Dati e metadati: `LQGI_nonlinear_sim_scope_buffers.mat`, `LQGI_nonlinear_sim_dynamic_review.json`, `LQGI_nonlinear_sim_audit.json` nella cartella dei risultati.

### LQG_nonlinear_sim.slx

1. Struttura: anello con equazioni meccaniche non lineari e attuatori LTI.
2. Controllore: LQG, 14 stati di osservatore; u=Nr r−K xhat.
3. Plant: otto stati meccanici assoluti più sei attuativi, disturbo positivo sulle accelerazioni dei link.
4. Misure: quattro encoder [q1,q2,theta1,theta2]; H∞ e μ usano le prime due nel feedback.
5. Riferimento acquisito: [5°;0] da 1 s, posizione incrementale rispetto a qbar=[π/2;0].
6. Disturbo salvato: [0.5;0] N m lato link da 1 s; non separato dal riferimento in questo run.
7. Rumori: encoder σ=0.05°, processo con varianza 0.01 N²m², Ts=0.002 s, seed 20260826. I quattro rumori encoder attivi acquisiti sono correlati, con correlazione circa uno; non si assume indipendenza.
8. Interfaccia e legge: LQG, 14 stati di osservatore; u=Nr r−K xhat.
9. Inizializzazione: meccanica a xbar, velocità nulle; attuatori, osservatore e controllore in deviazioni nulle.
10. Risultati: tutti i segnali acquisiti finiti, durata 4 s. La tabella distingue i rami effettivamente eseguiti.
11. Anomalie/limiti: rumori e disturbo presenti insieme; offset, oscillazioni e sforzo non sono nascosti. I picchi continui possono superare quelli registrati.

| Ramo | e medio q1/q2 [deg] | OS q1 [%] | Ts q1 [s] | Picco u1/u2 [N m] | RMS u1/u2 [N m] | RMS misura selezionata [deg] |
|---|---|---:|---|---|---|---|
| LQG | 4.04648 / -1.7367 | 83.9653 | non raggiunto entro il run | 4.74994 / 0.889276 | 1.65385 / 0.293114 | 0.0505303 |

Configurazione solver: `{"relative_tolerance": "1.0000000000000001e-05", "absolute_tolerance": "9.9999999999999995e-08", "max_step": "0.0050000000000000001"}`.

SHA-256 prima/dopo: `d628ed44dbba7bc6248340c0d1d94600e38b8f09984ff228b8201cf5bcbb0ff9`; coincide con il manifest. Figure: `report/figures/final_simulink/LQG_nonlinear_sim.png`. Dati e metadati: `LQG_nonlinear_sim_scope_buffers.mat`, `LQG_nonlinear_sim_dynamic_review.json`, `LQG_nonlinear_sim_audit.json` nella cartella dei risultati.

### Hinf_nonlinear_sim.slx

1. Struttura: anello con equazioni meccaniche non lineari e attuatori LTI.
2. Controllore: tre controllori in parallelo: H∞ 1-DoF (18 stati), H∞ 2-DoF (22) e PID (4).
3. Plant: otto stati meccanici assoluti più sei attuativi, disturbo positivo sulle accelerazioni dei link.
4. Misure: quattro encoder [q1,q2,theta1,theta2]; H∞ e μ usano le prime due nel feedback.
5. Riferimento acquisito: [5°;0] da 1 s, posizione incrementale rispetto a qbar=[π/2;0].
6. Disturbo salvato: [0.5;0] N m lato link da 1 s; non separato dal riferimento in questo run.
7. Rumori: encoder σ=0.05°, processo con varianza 0.01 N²m², Ts=0.002 s, seed 20260826. I quattro rumori encoder attivi acquisiti sono correlati, con correlazione circa uno; non si assume indipendenza.
8. Interfaccia e legge: 1-DoF su r−qmis; 2-DoF/PID su [r;qmis], senza duplicare gli stati fra i due canali.
9. Inizializzazione: meccanica a xbar, velocità nulle; attuatori, osservatore e controllore in deviazioni nulle.
10. Risultati: tutti i segnali acquisiti finiti, durata 10 s. La tabella distingue i rami effettivamente eseguiti.
11. Anomalie/limiti: rumori e disturbo presenti insieme; offset, oscillazioni e sforzo non sono nascosti. I picchi continui possono superare quelli registrati.

| Ramo | e medio q1/q2 [deg] | OS q1 [%] | Ts q1 [s] | Picco u1/u2 [N m] | RMS u1/u2 [N m] | RMS misura selezionata [deg] |
|---|---|---:|---|---|---|---|
| 1-DoF | 1.29733 / -0.729072 | 161.658 | non raggiunto entro il run | 13.9731 / 3.53465 | 1.8575 / 0.377479 | 0.0497998 |
| 2-DoF | 0.00927796 / -0.061434 | 4.78204 | non raggiunto entro il run | 733230 / 274402 | 21520 / 8050.11 | 0.0497998 |
| PID | -0.0176666 / -0.234487 | 75.9971 | non raggiunto entro il run | 346.631 / 0.703891 | 28.4011 / 0.232395 | 0.0497998 |

Configurazione solver: `{"relative_tolerance": "1e-3", "absolute_tolerance": "auto", "max_step": "auto"}`.
Selettore `Hinf_nonlinear_sim/Manual Switch`: sw=1, ingresso 1, sorgente `Hinf_nonlinear_sim/Sum7`. Nessuna commutazione.
Selettore `Hinf_nonlinear_sim/Manual Switch1`: sw=1, ingresso 1, sorgente `Hinf_nonlinear_sim/Sum10`. Nessuna commutazione.
Selettore `Hinf_nonlinear_sim/Manual Switch2`: sw=1, ingresso 1, sorgente `Hinf_nonlinear_sim/Sum13`. Nessuna commutazione.

SHA-256 prima/dopo: `a8ddab01bf44e80597943b80c12667b1f9b6bb28fdc21a95cb69ee540e8e354c`; coincide con il manifest. Figure: `report/figures/final_simulink/Hinf_nonlinear_sim.png`. Dati e metadati: `Hinf_nonlinear_sim_scope_buffers.mat`, `Hinf_nonlinear_sim_dynamic_review.json`, `Hinf_nonlinear_sim_audit.json` nella cartella dei risultati.

### mu_nonlinear_sim.slx

1. Struttura: anello con equazioni meccaniche non lineari e attuatori LTI.
2. Controllore: Kμ a 78 stati, u=Kr r+Ky qmis.
3. Plant: otto stati meccanici assoluti più sei attuativi, disturbo positivo sulle accelerazioni dei link.
4. Misure: quattro encoder [q1,q2,theta1,theta2]; H∞ e μ usano le prime due nel feedback.
5. Riferimento acquisito: [5°;0] da 1 s, posizione incrementale rispetto a qbar=[π/2;0].
6. Disturbo salvato: [0.5;0] N m lato link da 1 s; non separato dal riferimento in questo run.
7. Rumori: encoder σ=0.05°, processo con varianza 0.01 N²m², Ts=0.002 s, seed 20260826. I quattro rumori encoder attivi acquisiti sono correlati, con correlazione circa uno; non si assume indipendenza.
8. Interfaccia e legge: Kμ a 78 stati, u=Kr r+Ky qmis.
9. Inizializzazione: meccanica a xbar, velocità nulle; attuatori, osservatore e controllore in deviazioni nulle.
10. Risultati: tutti i segnali acquisiti finiti, durata 10 s. La tabella distingue i rami effettivamente eseguiti.
11. Anomalie/limiti: rumori e disturbo presenti insieme; offset, oscillazioni e sforzo non sono nascosti. I picchi continui possono superare quelli registrati.

| Ramo | e medio q1/q2 [deg] | OS q1 [%] | Ts q1 [s] | Picco u1/u2 [N m] | RMS u1/u2 [N m] | RMS misura selezionata [deg] |
|---|---|---:|---|---|---|---|
| mu | 0.230087 / -0.555954 | 10.6678 | non raggiunto entro il run | 108.526 / 50.7817 | 12.8223 / 3.29 | 0.049807 |

Configurazione solver: `{"relative_tolerance": "1e-3", "absolute_tolerance": "auto", "max_step": "auto"}`.
Selettore `mu_nonlinear_sim/Manual Switch1`: sw=1, ingresso 1, sorgente `mu_nonlinear_sim/Sum10`. Nessuna commutazione.

SHA-256 prima/dopo: `2c4043bc805fbddeff1357b6de5a02073f11729bfdb33007c98de71bbacb12de`; coincide con il manifest. Figure: `report/figures/final_simulink/mu_nonlinear_sim.png`. Dati e metadati: `mu_nonlinear_sim_scope_buffers.mat`, `mu_nonlinear_sim_dynamic_review.json`, `mu_nonlinear_sim_audit.json` nella cartella dei risultati.

## Ripetizione e limite della API

Dalla radice: `addpath('simulink','tools'); run_final_student_validation;`. Il runner fallisce se una verifica obbligatoria resta incompleta. Per riusare i run conservati, controllando gli hash e ricalcolando metriche/figure: `run_final_student_validation(false,true)`.

La lettura del buffer usa un’API interna specifica di R2026b. In una release che non la espone, il fallback è manuale: preparare il Workspace con i campi di `setup_student_originals(kind)`, aprire il modello, eseguire senza cambiare parametri, aprire gli Scope `Uscita ideale`, `Uscita misurata` e `Variabile/i di controllo`; scegliere Print → Print to Figure. Nella figura MATLAB salvare FIG e PNG, leggendo XData/YData delle curve per i dati. Non fare doppio clic sui Manual Switch: li commuta. Chiudere il modello senza salvare e ricontrollare SHA-256. La sola schermata non certifica picchi più rapidi della griglia.

Documentazione ufficiale: [Scope](https://www.mathworks.com/help/simulink/slref/scope.html), [Manual Switch](https://www.mathworks.com/help/simulink/slref/manualswitch.html). Inventario completo: `docs/INVENTARIO_XML_SIMULINK.md`.

## Studio successivo con rumore esplicito — 13.10.2026

I risultati sopra descrivono la baseline e restano validi per quella formulazione. La revisione separata è documentata in Prova_di_Soluzione_Rumore_di_Misura.txt e ACCETTAZIONE_RUMORE_E_ORALE.md, con dati in results/data/noise_redesign. Tre H∞ non superano RS/RP; MuN1 riduce molto il comando e mantiene RS/RP, con offset q1 peggiore e target temporali parziali. Gli otto nuovi run abbinati non sostituiscono quelli precedenti. Baseline predefinita; decisione sull'adozione agli studenti. Il nuovo discorso completo è in presentation/Presentazione_orale.txt.
