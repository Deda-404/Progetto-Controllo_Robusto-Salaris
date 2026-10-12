# REPORT VERIFICA SIMULINK

Audit del 12 ottobre 2026. Fonte corrente: gli otto pacchetti SLX della cartella Drive `1wDiaAQVR7cDDt7T8WUlyZ0vgEa-2LWLx`, recuperati in sola lettura. Copie canoniche in `simulink/student_originals/`. I modelli preesistenti restano archivio e non sono la fonte di questo audit.

## Esito e integrità

Integrità COMPLETE / PASS: otto archivi ZIP con CRC valido, dimensioni confrontate con il provider e SHA-256 sorgente/importazione/post-verifica identici. Nessun `set_param`, `save_system`, aggiunta di blocchi, cambio di solver, conversione o disattivazione del controllo di release è stato applicato agli originali.

Tutti gli otto sono Simulink R2026a Update 4 (26.1.0.3312084). L'ambiente reale è MATLAB/Simulink R2025b Update 4: otto `load_system` falliscono per release. Simulazioni originali **NOT RUN**, validazione dinamica **PARTIAL**. Gli errori completi e gli hash prima/dopo sono in `results/data/final_closure/slx_runtime_audit.json`.

| File | Byte | SHA-256 sorgente = importazione = dopo verifica |
|---|---:|---|
| mu_linear_sim.slx | 82649 | `9d60a5b211c989f2c3324b47e6c218fc470d834d5633481c0d3c927c6eee078b` |
| Hinf_linear_sim.slx | 163837 | `27b5132d581c2d220ef3d3c5cce1c66fb13f95a0c2f9c2a390127ecd1a1cda9d` |
| LQGI_linear_sim.slx | 139852 | `6c8248318c57d30853d345992dbf0d0e18256ca019c99a89107bd5729fa374dc` |
| LQG_linear_sim.slx | 91403 | `eb01cb8e66b919301181c647c931d9ffbaf48dac3b0fc5eb8d8df87da36f1ea9` |
| LQGI_nonlinear_sim.slx | 124303 | `c1ceef864070be2afc5ae0dba9b3481f80c9378c05555e47f3d17f2a3152bcfe` |
| LQG_nonlinear_sim.slx | 126957 | `d628ed44dbba7bc6248340c0d1d94600e38b8f09984ff228b8201cf5bcbb0ff9` |
| Hinf_nonlinear_sim.slx | 245910 | `a8ddab01bf44e80597943b80c12667b1f9b6bb28fdc21a95cb69ee540e8e354c` |
| mu_nonlinear_sim.slx | 108233 | `2c4043bc805fbddeff1357b6de5a02073f11729bfdb33007c98de71bbacb12de` |

## Architettura e variabili esterne

Le piante lineari hanno Aplant 14×14, Bplant=[Bfull BdFull BdFull Bfull] 14×8, Cplant 4×14, Dplant 4×8 e x0plant nullo. Gli ingressi sono [u; d_link; w_link; w_u], non quattro copie del comando. Cm misura [q1 q2 theta1 theta2]; la coppia dei link entra prima dell'accelerazione, il rumore w_u prima degli attuatori. La pianta aperta è instabile: stabilità e feedback vanno verificati nell'anello completo.

LQG usa u=Nr*r−K*xhat, Kalman a 14 stati e quattro encoder rumorosi. LQGI usa u=−Kx*xhat−Ki*xi, xi_dot=r−q_mis, Kalman M6 e integratori separati dallo stimatore. H∞ confronta un ramo 1-DoF su r−q_mis e rami 2-DoF/PID su [r;q_mis]. Kµ usa [r;q_mis] con un'unica realizzazione a 78 stati. Non si duplicano gli stati fra riferimento e feedback.

I non lineari integrano otto stati meccanici assoluti [q;qdot;theta;thetadot], partono da xbar e sottraggono l'equilibrio prima del controllo. Gli attuatori LTI hanno stati incrementali; Gact conserva il Padé del progetto. Le funzioni embedded applicano il disturbo sul lato link con segno positivo e richiamano inerzia, Coriolis, gravità e coppia elastica in src/. Le unità dei calcoli sono rad, rad/s, N m; le figure convertono in gradi quando dichiarato.

`setup_student_originals(kind)` prepara matrici, guadagni, controllori LTI e `slBus1`, senza scrivere gli SLX. Il bus deriva esattamente dai campi m1,m2,l1,l2,Jm,Bm,Ks,g della funzione nominale. Le InitFcn lineari trovano la radice con `which('progetto_lqgi.m')` e caricano M3/M5; i path di progetto sono aggiunti esternamente. Il callback contiene assignin nel sorgente originale: non è stato riscritto. Le matrici caricate coincidono con quelle del setup.

## Rumori, scenari e limiti statici

I Random Number encoder hanno media nulla, varianza (0.05*pi/180)^2 per i quattro canali e Ts=0.002 s; il processo ha varianza 0.01 N²m² e lo stesso Ts. I blocchi salvano seed 20260826, spesso uguale fra misura/link/comando: non si assume indipendenza fra blocchi senza verificare le sequenze effettive. La nuova diagnosi MATLAB usa un protocollo distinto, seed 20261012, misura e processo indipendenti e scenari isolati; non è un replay degli Scope.

I gradini impostati sono q1=5*pi/180, q2=0 e d=[0.5;0] da 1 s. Il tempo di riferimento, se assente nell'XML, resta un default da verificare in R2026a. I selettori manuali sono elencati con i valori salvati; non sono stati commutati per produrre nuove prove. Un parametro omesso nell'XML non viene inventato. Scope e Demux mostrano posizioni/comandi, ma senza caricamento non si validano dimensioni compilate o logging.

## Verifica per modello

### Hinf_linear_sim.slx

Tre rami separati: Controller H-inf/1-DoF usa Ak1,Bk1,Ck1,Dk1 su errore; 2-DoF usa Ak2,Bk2,Ck2,Dk2 su Mux [r;q_mis]; PID usa Kpid. Le interfacce a quattro ingressi sono già presenti.

Blocchi inventariati: 95; collegamenti espliciti: 119. Impostazioni salvate: `{'SolverName': 'VariableStepAuto'}`. Callback: InitFcn.

Piante State-Space Aplant/Bplant/Cplant/Dplant e x0plant; callback di caricamento M3/M5. Dimensioni e inizializzazione descritte sopra sono coerenti staticamente con le variabili MATLAB; la compilazione rimane non eseguita.

| Percorso originale | Blocco | Parametri scientifici salvati |
|---|---|---|
| `Hinf_linear_sim/Controller H-inf` | StateSpace | `{'A': 'Ak1', 'B': 'Bk1', 'C': 'Ck1', 'D': 'Dk1', 'InitialCondition': '0'}` |
| `Hinf_linear_sim/Controller H-inf1` | StateSpace | `{'A': 'Ak2', 'B': 'Bk2', 'C': 'Ck2', 'D': 'Dk2', 'InitialCondition': '0'}` |
| `Hinf_linear_sim/Disturbo di coppia` | Step | `{'Time': '[1 1]', 'FinalValue': '[0.5 0]', 'SampleTime': '0'}` |
| `Hinf_linear_sim/Disturbo di coppia1` | Step | `{'Time': '[1 1]', 'FinalValue': '[0.5 0]', 'SampleTime': '0'}` |
| `Hinf_linear_sim/Disturbo di coppia2` | Step | `{'Time': '[1 1]', 'FinalValue': '[0.5 0]', 'SampleTime': '0'}` |
| `Hinf_linear_sim/Manual Switch` | ManualSwitch | `{'CurrentSetting': '0'}` |
| `Hinf_linear_sim/Manual Switch1` | ManualSwitch | `{'CurrentSetting': '0'}` |
| `Hinf_linear_sim/Manual Switch2` | ManualSwitch | `{'CurrentSetting': '0'}` |
| `Hinf_linear_sim/Mux` | Mux | `{'Inputs': '2'}` |
| `Hinf_linear_sim/Mux4` | Mux | `{'Inputs': '2'}` |
| `Hinf_linear_sim/Mux7` | Mux | `{'Inputs': '2'}` |
| `Hinf_linear_sim/Rumore di processo link` | RandomNumber | `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `Hinf_linear_sim/Rumore di processo link1` | RandomNumber | `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `Hinf_linear_sim/Rumore di processo link2` | RandomNumber | `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `Hinf_linear_sim/Rumore di processo u` | RandomNumber | `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `Hinf_linear_sim/Rumore di processo u1` | RandomNumber | `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `Hinf_linear_sim/Rumore di processo u2` | RandomNumber | `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `Hinf_linear_sim/Rumori di misura` | RandomNumber | `{'Mean': '[0 0 0 0]', 'Variance': '[(0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `Hinf_linear_sim/Rumori di misura1` | RandomNumber | `{'Mean': '[0 0 0 0]', 'Variance': '[(0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `Hinf_linear_sim/Rumori di misura2` | RandomNumber | `{'Mean': '[0 0 0 0]', 'Variance': '[(0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `Hinf_linear_sim/State-Space` | StateSpace | `{'A': 'Aplant', 'B': 'Bplant', 'C': 'Cplant', 'D': 'Dplant', 'InitialCondition': 'x0plant'}` |
| `Hinf_linear_sim/State-Space1` | StateSpace | `{'A': 'Aplant', 'B': 'Bplant', 'C': 'Cplant', 'D': 'Dplant', 'InitialCondition': 'x0plant'}` |
| `Hinf_linear_sim/State-Space2` | StateSpace | `{'A': 'Aplant', 'B': 'Bplant', 'C': 'Cplant', 'D': 'Dplant', 'InitialCondition': 'x0plant'}` |
| `Hinf_linear_sim/Sum` | Sum | `{'Inputs': '\|+-'}` |
| `Hinf_linear_sim/Sum1` | Sum | `{'Inputs': '\|++'}` |
| `Hinf_linear_sim/Sum2` | Sum | `{'Inputs': '\|++'}` |
| `Hinf_linear_sim/Sum3` | Sum | `{'Inputs': '\|++'}` |
| `Hinf_linear_sim/r1` | Step | `{'FinalValue': '5*pi/180', 'SampleTime': '0'}` |
| `Hinf_linear_sim/r2` | Step | `{'FinalValue': '0', 'SampleTime': '0'}` |

Esito: integrità PASS; struttura XML ispezionata; load FAIL per release; sim NOT RUN; nessuna prestazione Simulink accreditata.

### Hinf_nonlinear_sim.slx

Tre rami separati: Controller H-inf/1-DoF usa Ak1,Bk1,Ck1,Dk1 su errore; 2-DoF usa Ak2,Bk2,Ck2,Dk2 su Mux [r;q_mis]; PID usa Kpid. Le interfacce a quattro ingressi sono già presenti.

Blocchi inventariati: 191; collegamenti espliciti: 203. Impostazioni salvate: `{'SolverName': 'VariableStepAuto'}`. Callback: InitFcn.

Integrazione meccanica assoluta a xbar e attuatori Gact; funzioni embedded e dipendenze sono nell’inventario completo. Dimensioni e inizializzazione descritte sopra sono coerenti staticamente con le variabili MATLAB; la compilazione rimane non eseguita.

| Percorso originale | Blocco | Parametri scientifici salvati |
|---|---|---|
| `Hinf_nonlinear_sim/Actuators/Mux` | Mux | `{'Inputs': '2'}` |
| `Hinf_nonlinear_sim/Actuators1/Mux` | Mux | `{'Inputs': '2'}` |
| `Hinf_nonlinear_sim/Actuators2/Mux` | Mux | `{'Inputs': '2'}` |
| `Hinf_nonlinear_sim/Controller H-inf (1-DoF)` | StateSpace | `{'A': 'Ak1', 'B': 'Bk1', 'C': 'Ck1', 'D': 'Dk1', 'InitialCondition': '0'}` |
| `Hinf_nonlinear_sim/Controller H-inf (2-DoF)` | StateSpace | `{'A': 'Ak2', 'B': 'Bk2', 'C': 'Ck2', 'D': 'Dk2', 'InitialCondition': '0'}` |
| `Hinf_nonlinear_sim/Disturbi di coppia` | Step | `{'Time': '[1 1]', 'FinalValue': '[0.5 0]', 'SampleTime': '0'}` |
| `Hinf_nonlinear_sim/Disturbi di coppia1` | Step | `{'Time': '[1 1]', 'FinalValue': '[0.5 0]', 'SampleTime': '0'}` |
| `Hinf_nonlinear_sim/Disturbi di coppia2` | Step | `{'Time': '[1 1]', 'FinalValue': '[0.5 0]', 'SampleTime': '0'}` |
| `Hinf_nonlinear_sim/Integrator` | Integrator | `{'InitialCondition': 'xbar'}` |
| `Hinf_nonlinear_sim/Integrator1` | Integrator | `{'InitialCondition': 'xbar'}` |
| `Hinf_nonlinear_sim/Integrator2` | Integrator | `{'InitialCondition': 'xbar'}` |
| `Hinf_nonlinear_sim/Mux` | Mux | `{'Inputs': '2'}` |
| `Hinf_nonlinear_sim/Mux1` | Mux | `{'Inputs': '2'}` |
| `Hinf_nonlinear_sim/Mux2` | Mux | `{'Inputs': '2'}` |
| `Hinf_nonlinear_sim/Rumore di processo link` | RandomNumber | `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `Hinf_nonlinear_sim/Rumore di processo link1` | RandomNumber | `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `Hinf_nonlinear_sim/Rumore di processo link2` | RandomNumber | `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `Hinf_nonlinear_sim/Rumore di processo u1` | RandomNumber | `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `Hinf_nonlinear_sim/Rumore di processo u2` | RandomNumber | `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `Hinf_nonlinear_sim/Rumore di processo u3` | RandomNumber | `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `Hinf_nonlinear_sim/Rumori di misura1` | RandomNumber | `{'Mean': '[0 0 0 0]', 'Variance': '[(0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `Hinf_nonlinear_sim/Rumori di misura2` | RandomNumber | `{'Mean': '[0 0 0 0]', 'Variance': '[(0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `Hinf_nonlinear_sim/Rumori di misura3` | RandomNumber | `{'Mean': '[0 0 0 0]', 'Variance': '[(0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `Hinf_nonlinear_sim/Sum` | Sum | `{'Inputs': '\|+-'}` |
| `Hinf_nonlinear_sim/Sum10` | Sum | `{'Inputs': '\|++'}` |
| `Hinf_nonlinear_sim/Sum11` | Sum | `{'Inputs': '\|++'}` |
| `Hinf_nonlinear_sim/Sum13` | Sum | `{'Inputs': '\|++'}` |
| `Hinf_nonlinear_sim/Sum14` | Sum | `{'Inputs': '\|++'}` |
| `Hinf_nonlinear_sim/Sum15` | Sum | `{'Inputs': '++\|'}` |
| `Hinf_nonlinear_sim/Sum16` | Sum | `{'Inputs': '\|+-'}` |
| `Hinf_nonlinear_sim/Sum17` | Sum | `{'Inputs': '\|++'}` |
| `Hinf_nonlinear_sim/Sum2` | Sum | `{'Inputs': '++\|'}` |
| `Hinf_nonlinear_sim/Sum3` | Sum | `{'Inputs': '\|+-'}` |
| `Hinf_nonlinear_sim/Sum4` | Sum | `{'Inputs': '++\|'}` |
| `Hinf_nonlinear_sim/Sum5` | Sum | `{'Inputs': '\|+-'}` |
| `Hinf_nonlinear_sim/Sum6` | Sum | `{'Inputs': '\|++'}` |
| `Hinf_nonlinear_sim/Sum7` | Sum | `{'Inputs': '\|++'}` |
| `Hinf_nonlinear_sim/Sum8` | Sum | `{'Inputs': '\|++'}` |
| `Hinf_nonlinear_sim/Sum9` | Sum | `{'Inputs': '\|++'}` |
| `Hinf_nonlinear_sim/r1` | Step | `{'FinalValue': '5*pi/180', 'SampleTime': '0'}` |
| `Hinf_nonlinear_sim/r2` | Step | `{'FinalValue': '0', 'SampleTime': '0'}` |

Esito: integrità PASS; struttura XML ispezionata; load FAIL per release; sim NOT RUN; nessuna prestazione Simulink accreditata.

### LQG_linear_sim.slx

Osservatore su misure [q;theta], feedback stimato e guadagno Nr. Nessun integratore servo. Il processo agisce sulla pianta, non sul segnale u conosciuto dal Kalman.

Blocchi inventariati: 41; collegamenti espliciti: 49. Impostazioni salvate: `{'SolverName': 'VariableStepAuto'}`. Callback: InitFcn.

Piante State-Space Aplant/Bplant/Cplant/Dplant e x0plant; callback di caricamento M3/M5. Dimensioni e inizializzazione descritte sopra sono coerenti staticamente con le variabili MATLAB; la compilazione rimane non eseguita.

| Percorso originale | Blocco | Parametri scientifici salvati |
|---|---|---|
| `LQG_linear_sim/Disturbo di coppia` | Step | `{'Time': '[1 1]', 'FinalValue': '[0.5 0]', 'SampleTime': '0'}` |
| `LQG_linear_sim/Gain` | Gain | `{'Gain': 'K', 'Multiplication': 'Matrix(K*u)'}` |
| `LQG_linear_sim/Gain1` | Gain | `{'Gain': 'Nr', 'Multiplication': 'Matrix(K*u)'}` |
| `LQG_linear_sim/Kalman filter/Add` | Sum | `{'Inputs': '+++'}` |
| `LQG_linear_sim/Kalman filter/Gain` | Gain | `{'Gain': 'A', 'Multiplication': 'Matrix(K*u)'}` |
| `LQG_linear_sim/Kalman filter/Gain1` | Gain | `{'Gain': 'C', 'Multiplication': 'Matrix(K*u)'}` |
| `LQG_linear_sim/Kalman filter/Gain2` | Gain | `{'Gain': 'B', 'Multiplication': 'Matrix(K*u)'}` |
| `LQG_linear_sim/Kalman filter/Gain3` | Gain | `{'Gain': 'L', 'Multiplication': 'Matrix(K*u)'}` |
| `LQG_linear_sim/Kalman filter/Integrator` | Integrator | `IC implicita: verificare runtime` |
| `LQG_linear_sim/Kalman filter/Sum` | Sum | `{'Inputs': '\|+-'}` |
| `LQG_linear_sim/Modello linearizzato` | StateSpace | `{'A': 'Aplant', 'B': 'Bplant', 'C': 'Cplant', 'D': 'Dplant', 'InitialCondition': 'x0plant'}` |
| `LQG_linear_sim/Mux` | Mux | `{'Inputs': '2'}` |
| `LQG_linear_sim/Rumore di processo link` | RandomNumber | `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `LQG_linear_sim/Rumore di processo u` | RandomNumber | `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `LQG_linear_sim/Rumori di misura` | RandomNumber | `{'Mean': '[0 0 0 0]', 'Variance': '[(0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `LQG_linear_sim/Sum` | Sum | `{'Inputs': '\|+-'}` |
| `LQG_linear_sim/Sum3` | Sum | `{'Inputs': '\|++'}` |
| `LQG_linear_sim/r1` | Step | `{'FinalValue': '5*pi/180', 'SampleTime': '0'}` |
| `LQG_linear_sim/r2` | Step | `{'FinalValue': '0', 'SampleTime': '0'}` |

Esito: integrità PASS; struttura XML ispezionata; load FAIL per release; sim NOT RUN; nessuna prestazione Simulink accreditata.

### LQG_nonlinear_sim.slx

Osservatore su misure [q;theta], feedback stimato e guadagno Nr. Nessun integratore servo. Il processo agisce sulla pianta, non sul segnale u conosciuto dal Kalman.

Blocchi inventariati: 74; collegamenti espliciti: 80. Impostazioni salvate: `{'StopTime': '4', 'AbsTol': '9.9999999999999995e-08', 'MaxStep': '0.0050000000000000001', 'RelTol': '1.0000000000000001e-05', 'SolverName': 'ode23t'}`. Callback: InitFcn.

Integrazione meccanica assoluta a xbar e attuatori Gact; funzioni embedded e dipendenze sono nell’inventario completo. Dimensioni e inizializzazione descritte sopra sono coerenti staticamente con le variabili MATLAB; la compilazione rimane non eseguita.

| Percorso originale | Blocco | Parametri scientifici salvati |
|---|---|---|
| `LQG_nonlinear_sim/Actuators1/Mux` | Mux | `{'Inputs': '2'}` |
| `LQG_nonlinear_sim/Disturbi di coppia` | Step | `{'Time': '[1 1]', 'FinalValue': '[0.5 0]', 'SampleTime': '0'}` |
| `LQG_nonlinear_sim/Gain2` | Gain | `{'Gain': 'K', 'Multiplication': 'Matrix(K*u)'}` |
| `LQG_nonlinear_sim/Gain3` | Gain | `{'Gain': 'Nr', 'Multiplication': 'Matrix(K*u)'}` |
| `LQG_nonlinear_sim/Integrator1` | Integrator | `{'InitialCondition': 'xbar'}` |
| `LQG_nonlinear_sim/Kalman filter1/Add` | Sum | `{'Inputs': '+++'}` |
| `LQG_nonlinear_sim/Kalman filter1/Gain` | Gain | `{'Gain': 'A', 'Multiplication': 'Matrix(K*u)'}` |
| `LQG_nonlinear_sim/Kalman filter1/Gain1` | Gain | `{'Gain': 'C', 'Multiplication': 'Matrix(K*u)'}` |
| `LQG_nonlinear_sim/Kalman filter1/Gain2` | Gain | `{'Gain': 'B', 'Multiplication': 'Matrix(K*u)'}` |
| `LQG_nonlinear_sim/Kalman filter1/Gain3` | Gain | `{'Gain': 'L', 'Multiplication': 'Matrix(K*u)'}` |
| `LQG_nonlinear_sim/Kalman filter1/Integrator` | Integrator | `IC implicita: verificare runtime` |
| `LQG_nonlinear_sim/Kalman filter1/Sum` | Sum | `{'Inputs': '\|+-'}` |
| `LQG_nonlinear_sim/Mux1` | Mux | `{'Inputs': '2'}` |
| `LQG_nonlinear_sim/Rumore di processo link` | RandomNumber | `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `LQG_nonlinear_sim/Rumore di processo u` | RandomNumber | `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `LQG_nonlinear_sim/Rumori di misura1` | RandomNumber | `{'Mean': '[0 0 0 0]', 'Variance': '[(0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `LQG_nonlinear_sim/Sum10` | Sum | `{'Inputs': '\|++'}` |
| `LQG_nonlinear_sim/Sum4` | Sum | `{'Inputs': '\|+-'}` |
| `LQG_nonlinear_sim/Sum5` | Sum | `{'Inputs': '++\|'}` |
| `LQG_nonlinear_sim/Sum6` | Sum | `{'Inputs': '\|+-'}` |
| `LQG_nonlinear_sim/Sum7` | Sum | `{'Inputs': '\|++'}` |
| `LQG_nonlinear_sim/Sum9` | Sum | `{'Inputs': '\|++'}` |
| `LQG_nonlinear_sim/r1 (q1)` | Step | `{'FinalValue': '5*pi/180', 'SampleTime': '0'}` |
| `LQG_nonlinear_sim/r2 (q2)` | Step | `{'FinalValue': '0', 'SampleTime': '0'}` |

Esito: integrità PASS; struttura XML ispezionata; load FAIL per release; sim NOT RUN; nessuna prestazione Simulink accreditata.

### LQGI_linear_sim.slx

La connessione dal sommatore delle misure al selettore e alla somma r−q_mis è presente. Non occorre applicare la vecchia istruzione di spostare l’integratore; riguardava altri file. I segni del comando restano −Kx e −Ki.

Blocchi inventariati: 44; collegamenti espliciti: 53. Impostazioni salvate: `{'SolverName': 'VariableStepAuto'}`. Callback: InitFcn.

Piante State-Space Aplant/Bplant/Cplant/Dplant e x0plant; callback di caricamento M3/M5. Dimensioni e inizializzazione descritte sopra sono coerenti staticamente con le variabili MATLAB; la compilazione rimane non eseguita.

| Percorso originale | Blocco | Parametri scientifici salvati |
|---|---|---|
| `LQGI_linear_sim/Disturbo di coppia` | Step | `{'Time': '[1 1]', 'FinalValue': '[0.5 0]', 'SampleTime': '0'}` |
| `LQGI_linear_sim/Gain` | Gain | `{'Gain': 'Kx', 'Multiplication': 'Matrix(K*u)'}` |
| `LQGI_linear_sim/Gain1` | Gain | `{'Gain': 'Ki', 'Multiplication': 'Matrix(K*u)'}` |
| `LQGI_linear_sim/Integrator1` | Integrator | `IC implicita: verificare runtime` |
| `LQGI_linear_sim/Kalman filter/Add` | Sum | `{'Inputs': '+++'}` |
| `LQGI_linear_sim/Kalman filter/Gain` | Gain | `{'Gain': 'A', 'Multiplication': 'Matrix(K*u)'}` |
| `LQGI_linear_sim/Kalman filter/Gain1` | Gain | `{'Gain': 'C', 'Multiplication': 'Matrix(K*u)'}` |
| `LQGI_linear_sim/Kalman filter/Gain2` | Gain | `{'Gain': 'B', 'Multiplication': 'Matrix(K*u)'}` |
| `LQGI_linear_sim/Kalman filter/Gain3` | Gain | `{'Gain': 'L', 'Multiplication': 'Matrix(K*u)'}` |
| `LQGI_linear_sim/Kalman filter/Integrator` | Integrator | `IC implicita: verificare runtime` |
| `LQGI_linear_sim/Kalman filter/Sum` | Sum | `{'Inputs': '\|+-'}` |
| `LQGI_linear_sim/Modello linearizzato` | StateSpace | `{'A': 'Aplant', 'B': 'Bplant', 'C': 'Cplant', 'D': 'Dplant', 'InitialCondition': 'x0plant'}` |
| `LQGI_linear_sim/Mux` | Mux | `{'Inputs': '2'}` |
| `LQGI_linear_sim/Rumore di processo link` | RandomNumber | `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `LQGI_linear_sim/Rumore di processo u` | RandomNumber | `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `LQGI_linear_sim/Rumori di misura` | RandomNumber | `{'Mean': '[0 0 0 0]', 'Variance': '[(0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `LQGI_linear_sim/Sum` | Sum | `{'Inputs': '\|--'}` |
| `LQGI_linear_sim/Sum3` | Sum | `{'Inputs': '\|++'}` |
| `LQGI_linear_sim/Sum5` | Sum | `{'Inputs': '-+\|'}` |
| `LQGI_linear_sim/r1 (q1)` | Step | `{'FinalValue': '5*pi/180', 'SampleTime': '0'}` |
| `LQGI_linear_sim/r2 (q2)` | Step | `{'FinalValue': '0', 'SampleTime': '0'}` |

Esito: integrità PASS; struttura XML ispezionata; load FAIL per release; sim NOT RUN; nessuna prestazione Simulink accreditata.

### LQGI_nonlinear_sim.slx

La connessione dal sommatore delle misure al selettore e alla somma r−q_mis è presente. Non occorre applicare la vecchia istruzione di spostare l’integratore; riguardava altri file. I segni del comando restano −Kx e −Ki.

Blocchi inventariati: 77; collegamenti espliciti: 84. Impostazioni salvate: `{'SolverName': 'VariableStepAuto'}`. Callback: InitFcn.

Integrazione meccanica assoluta a xbar e attuatori Gact; funzioni embedded e dipendenze sono nell’inventario completo. Dimensioni e inizializzazione descritte sopra sono coerenti staticamente con le variabili MATLAB; la compilazione rimane non eseguita.

| Percorso originale | Blocco | Parametri scientifici salvati |
|---|---|---|
| `LQGI_nonlinear_sim/Actuators/Mux` | Mux | `{'Inputs': '2'}` |
| `LQGI_nonlinear_sim/Disturbi di coppia` | Step | `{'Time': '[1 1]', 'FinalValue': '[0.5 0]', 'SampleTime': '0'}` |
| `LQGI_nonlinear_sim/Gain` | Gain | `{'Gain': 'Kx', 'Multiplication': 'Matrix(K*u)'}` |
| `LQGI_nonlinear_sim/Gain1` | Gain | `{'Gain': 'Ki', 'Multiplication': 'Matrix(K*u)'}` |
| `LQGI_nonlinear_sim/Integrator` | Integrator | `{'InitialCondition': 'xbar'}` |
| `LQGI_nonlinear_sim/Integrator1` | Integrator | `IC implicita: verificare runtime` |
| `LQGI_nonlinear_sim/Kalman filter/Add` | Sum | `{'Inputs': '+++'}` |
| `LQGI_nonlinear_sim/Kalman filter/Gain` | Gain | `{'Gain': 'A', 'Multiplication': 'Matrix(K*u)'}` |
| `LQGI_nonlinear_sim/Kalman filter/Gain1` | Gain | `{'Gain': 'C', 'Multiplication': 'Matrix(K*u)'}` |
| `LQGI_nonlinear_sim/Kalman filter/Gain2` | Gain | `{'Gain': 'B', 'Multiplication': 'Matrix(K*u)'}` |
| `LQGI_nonlinear_sim/Kalman filter/Gain3` | Gain | `{'Gain': 'L', 'Multiplication': 'Matrix(K*u)'}` |
| `LQGI_nonlinear_sim/Kalman filter/Integrator` | Integrator | `IC implicita: verificare runtime` |
| `LQGI_nonlinear_sim/Kalman filter/Sum` | Sum | `{'Inputs': '\|+-'}` |
| `LQGI_nonlinear_sim/Mux` | Mux | `{'Inputs': '2'}` |
| `LQGI_nonlinear_sim/Rumore di processo link` | RandomNumber | `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `LQGI_nonlinear_sim/Rumore di processo u` | RandomNumber | `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `LQGI_nonlinear_sim/Rumori di misura` | RandomNumber | `{'Mean': '[0 0 0 0]', 'Variance': '[(0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `LQGI_nonlinear_sim/Sum` | Sum | `{'Inputs': '\|--'}` |
| `LQGI_nonlinear_sim/Sum1` | Sum | `{'Inputs': '++\|'}` |
| `LQGI_nonlinear_sim/Sum2` | Sum | `{'Inputs': '\|+-'}` |
| `LQGI_nonlinear_sim/Sum3` | Sum | `{'Inputs': '\|++'}` |
| `LQGI_nonlinear_sim/Sum5` | Sum | `{'Inputs': '-+\|'}` |
| `LQGI_nonlinear_sim/Sum6` | Sum | `{'Inputs': '\|++'}` |
| `LQGI_nonlinear_sim/Sum7` | Sum | `{'Inputs': '\|++'}` |
| `LQGI_nonlinear_sim/r1 (q1)` | Step | `{'FinalValue': '5*pi/180', 'SampleTime': '0'}` |
| `LQGI_nonlinear_sim/r2 (q2)` | Step | `{'FinalValue': '0', 'SampleTime': '0'}` |

Esito: integrità PASS; struttura XML ispezionata; load FAIL per release; sim NOT RUN; nessuna prestazione Simulink accreditata.

### mu_linear_sim.slx

Il blocco LTI richiama Kmu e riceve riferimento e misure selezionate. Entrambi i modelli µ sono presenti; l’indicazione di modello mancante non si applica a queste copie.

Blocchi inventariati: 33; collegamenti espliciti: 42. Impostazioni salvate: `{'SolverName': 'VariableStepAuto'}`. Callback: InitFcn.

Piante State-Space Aplant/Bplant/Cplant/Dplant e x0plant; callback di caricamento M3/M5. Dimensioni e inizializzazione descritte sopra sono coerenti staticamente con le variabili MATLAB; la compilazione rimane non eseguita.

| Percorso originale | Blocco | Parametri scientifici salvati |
|---|---|---|
| `mu_linear_sim/Disturbo di coppia` | Step | `{'Time': '[1 1]', 'FinalValue': '[0.5 0]', 'SampleTime': '0'}` |
| `mu_linear_sim/Linear plant` | StateSpace | `{'A': 'Aplant', 'B': 'Bplant', 'C': 'Cplant', 'D': 'Dplant', 'InitialCondition': 'x0plant'}` |
| `mu_linear_sim/Manual Switch` | ManualSwitch | `{'CurrentSetting': '0'}` |
| `mu_linear_sim/Mux` | Mux | `{'Inputs': '2'}` |
| `mu_linear_sim/Mux4` | Mux | `{'Inputs': '2'}` |
| `mu_linear_sim/Rumore di processo link` | RandomNumber | `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `mu_linear_sim/Rumore di processo u` | RandomNumber | `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `mu_linear_sim/Rumori di misura` | RandomNumber | `{'Mean': '[0 0 0 0]', 'Variance': '[(0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `mu_linear_sim/Sum2` | Sum | `{'Inputs': '\|++'}` |
| `mu_linear_sim/r1` | Step | `{'FinalValue': '5*pi/180', 'SampleTime': '0'}` |
| `mu_linear_sim/r2` | Step | `{'FinalValue': '0', 'SampleTime': '0'}` |

Esito: integrità PASS; struttura XML ispezionata; load FAIL per release; sim NOT RUN; nessuna prestazione Simulink accreditata.

### mu_nonlinear_sim.slx

Il blocco LTI richiama Kmu e riceve riferimento e misure selezionate. Entrambi i modelli µ sono presenti; l’indicazione di modello mancante non si applica a queste copie.

Blocchi inventariati: 65; collegamenti espliciti: 69. Impostazioni salvate: `{'SolverName': 'VariableStepAuto'}`. Callback: InitFcn.

Integrazione meccanica assoluta a xbar e attuatori Gact; funzioni embedded e dipendenze sono nell’inventario completo. Dimensioni e inizializzazione descritte sopra sono coerenti staticamente con le variabili MATLAB; la compilazione rimane non eseguita.

| Percorso originale | Blocco | Parametri scientifici salvati |
|---|---|---|
| `mu_nonlinear_sim/Actuators1/Mux` | Mux | `{'Inputs': '2'}` |
| `mu_nonlinear_sim/Disturbi di coppia1` | Step | `{'Time': '[1 1]', 'FinalValue': '[0.5 0]', 'SampleTime': '0'}` |
| `mu_nonlinear_sim/Integrator1` | Integrator | `{'InitialCondition': 'xbar'}` |
| `mu_nonlinear_sim/Mux` | Mux | `{'Inputs': '2'}` |
| `mu_nonlinear_sim/Mux1` | Mux | `{'Inputs': '2'}` |
| `mu_nonlinear_sim/Rumore di processo link1` | RandomNumber | `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `mu_nonlinear_sim/Rumore di processo u1` | RandomNumber | `{'Mean': '[0 0]', 'Variance': '[0.01 0.01]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `mu_nonlinear_sim/Rumori di misura1` | RandomNumber | `{'Mean': '[0 0 0 0]', 'Variance': '[(0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2 (0.05*pi/180)^2]', 'Seed': '20260826', 'SampleTime': '0.002'}` |
| `mu_nonlinear_sim/Sum10` | Sum | `{'Inputs': '\|++'}` |
| `mu_nonlinear_sim/Sum11` | Sum | `{'Inputs': '\|++'}` |
| `mu_nonlinear_sim/Sum2` | Sum | `{'Inputs': '++\|'}` |
| `mu_nonlinear_sim/Sum3` | Sum | `{'Inputs': '\|+-'}` |
| `mu_nonlinear_sim/Sum9` | Sum | `{'Inputs': '\|++'}` |
| `mu_nonlinear_sim/r1` | Step | `{'FinalValue': '5*pi/180', 'SampleTime': '0'}` |
| `mu_nonlinear_sim/r2` | Step | `{'FinalValue': '0', 'SampleTime': '0'}` |

Esito: integrità PASS; struttura XML ispezionata; load FAIL per release; sim NOT RUN; nessuna prestazione Simulink accreditata.

## Problemi esterni risolti e blocchi residui

Risolti esternamente: disponibilità degli otto pacchetti reali, path e dipendenze src/, matrici della pianta a otto ingressi, guadagni LQG/LQGI, matrici condivise 2-DoF, oggetti Kpid/Kmu e tipo bus. Non si dichiara che un audit XML abbia escluso qualsiasi problema di dimensioni, solver o collegamenti.

La sola configurazione non lineare LQG esplicita StopTime=4, ode23t, RelTol=1e-5, AbsTol=1e-7, MaxStep=0.005; gli altri config mostrano VariableStepAuto senza tutte le impostazioni esplicite. Le dinamiche rapide rendono necessaria una verifica del solver reale e del comando fra i campioni su R2026a. Modifiche interne non sono autorizzate: se un run rivela un difetto interno, documentarlo e lasciarlo agli studenti.

Le miniature `report/figures/student_originals/` sono estratte byte per byte dai pacchetti. Le etichette non sono leggibili alla scala del PDF: non sono state usate come false schermate di validazione. `export_student_schemes.m` prepara esportazioni reali e leggibili su R2026a. LQGI è predisposto come slide condizionale.

Sul computer con R2026a: eseguire `validate_student_originals(true)`, controllare i segnali salvati, confrontare con i casi MATLAB dichiarando i diversi tempi/seed/selettori, verificare hash, poi `export_student_schemes`. Solo dopo annotare PASS/FAIL di compilazione, simulazione e metriche. Nessuna conversione di release.

Fonti dettagliate: `docs/INVENTARIO_XML_SIMULINK.md`, JSON statico/runtime e manifest. Il comportamento di SimulationInput è documentato da [MathWorks](https://www.mathworks.com/help/simulink/slref/simulink.simulationinput.setvariable.html).
