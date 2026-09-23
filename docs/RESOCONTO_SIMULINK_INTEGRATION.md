# Resoconto integrazione Simulink — 23 settembre 2026

Responsabile: Alessio. Base main889c0eb46580767d8e6a958fda1af17f0c64658e, PR32 già integrata.
Branch codex/simulink-integration. PR in bozza, nessun merge automatico.

## Esito e provenienza
67/67 controlli Simulink e7/7 test MATLAB PASS, eseguiti realmente su R2025b.
Nessuna sintesi, musyn, Monte Carlo, RAS o Lyapunov rilanciata. Artifact validati invariati.
Originali: Progetto_LQR_simulink, Progetto_LQRI_simulink e Progetto_Hinf_simulink di Valerio, archivi .slx.zip già nei Download. La cartella Drive contiene pacchetti omonimi decompressi; non è stata verificata l'identità byte per byte di ogni file remoto. Nessuna scrittura su Drive.
Conservazione locale byte per byte in simulink/legacy/valerio, manifest SHA256 e inventario XML. Audit prima delle modifiche in SIMULINK_INITIAL_AUDIT.md.

## Struttura e modifiche
Conservati disposizione principale, Scope, selettori, guadagni e sottosistema Kalman. La funzione meccanica resta a8stati e richiama la fisica esistente. Actuators conserva la posizione e il ruolo: internamente State-Space standard con matrici M3 e6stati osservabili sostituisce i riferimenti LTI non risolti. Kmu deriva dalla stessa base Hinf e dallo stesso costruttore.

| Aspetto | Originale Valerio | Modello integrato | Motivazione |
|---|---|---|---|
| Disturbo | Sommato alla coppia motore | Canale link separato | BdFull M5 |
| Misura | Rumore scalare comune | Quattro componenti indipendenti | Rn M6 |
| Processo | Assente/sorgente LQRI scollegata | wd link, eta_u prima degli attuatori | Gw=[Bd B] |
| Stati8/14 | Attuatori impliciti, somma derivata incompleta | Meccanica8 e attuatori6, nessuna somma14+8 | Base Afull |
| Equilibrio | xbar corretto, bias dopo attuatori | Bias prima e stato attuatore di equilibrio | Simulatore MATLAB corrente |
| LQG | xhat e Nr già presenti | Struttura mantenuta, dati M6 espliciti | Riproducibilità |
| LQRI | Integratore su q ideale | r-q_mis, due memorie, nessun Nr | Legge M7 |
| Hinf | Vecchio r-q | K unico a4ingressi [r;q] | Vera architettura2-DoF |
| Kmu | Assente | K M13 ordine78, stessa pianta | Confronto omogeneo |
| Parametri | Bus esterno slBus1 | Vettore17 ricomposto in struttura | Nessun workspace implicito |

## Coordinate, attuatori, fisica
x_mech=[q;qdot;theta;thetadot],8stati assoluti. xact contiene6stati della realizzazione degli attuatori, non altri angoli. x_full=[x_mech-xbar;xact-xactbar],14stati incrementali.
xactbar=-Aa\(Ba*taubar); u_abs=taubar+u+eta_u; tau=Ca*xact+Da*u_abs. Bias una sola volta. Integratore meccanico inizializzato xbar. Riferimento5deg incrementale anche con qbar=[pi/2;0].
Link: M*qddot=Ks*(theta-q)-C*qdot-G+d_ext+wd. Motore: Jm*thetaddot=tau-Bm*thetadot-Ks*(theta-q).
Bfull=[Bmech*Da;Ba] identifica eta_u prima degli attuatori. La linearizzazione dei diagrammi verifica Gw=[Bd B] con errore7.11e-15.
Misure incrementali [q;theta], indici [1 2 5 6], quattro rumori dopo il selettore. Kalman14: xhatdot=A*xhat+B*u+L*(y_mis-C*xhat). eta_u è rumore ignoto, u è il comando noto.

## Controllori e artifact
LQG: u=-K*xhat+Nr*r, K/Nr/L/Qn/Rn da m6_lqg_no_integrator.mat. Lo stato vero serve solo a pianta, logging e test.
LQRI: Kx2x14 e Ki2x2 dalla scelta illustrativeIndex in m7_augmented_cost_feasibility.mat; u=-Kx*xhat-Ki*xi, xidot=r-q_mis. Nessun Nr e Kalman M6 invariato.
Hinf: selected_full_order.selected.K verificato anche contro nominal_study.study.selected.K; ordine22,4ingressi e2uscite. Kmu: m13.synthesis.K, ordine78. Nessun minreal, riduzione, osservatore aggiuntivo o vecchio prefiltro.

## Rumori, scenari, logging
Qn=0.01 I4; Rn=(0.05*pi/180)^2 I4. Il campo artifact Gw si chiama processNoiseInputMatrix.
Random Number vettoriali a0.002s, seed misura[101,211,307,401], processo[503,601,701,809]. Sono prove ZOH a banda finita: la varianza numerica non equivale esattamente all'intensità white noise continuo di lqe.
Interruttori indipendenti enableLinkDisturbance, enableMeasurementNoise, enableProcessNoise.
Equilibrio0.5s; confronto locale3s; tracking5deg separato sui due giunti4s; solo misura, solo processo, entrambi e replay0.5s. Kalman inizialmente perturbato1e-4 per3s; disturbo LQG/LQRI0.5Nm da1s per20s; disturbo+rumori1.5s; disturbo Hinf/Kmu3s.
Solver ode23t, RelTol1e-7, AbsTol1e-9, MaxStep0.002s. I dati versionati sono campioni uniformi0.002s ottenuti da logsout; copie adattive ridondanti eliminate per contenere le dimensioni.
Segnali: r,q_abs,dq,theta_abs,dtheta,x_mech,delta_x_mech,xact,x_full,u,u_abs,tau,d_ext,d_link_total,w_process,v,y_ideal,y_mis. xhat solo nei due Kalman; xi solo LQRI; controllerInput nei robusti.
Scope originali preservati, aggiunti q stimata/vera, disturbo e stati integrali. L'ingresso Process verification input è nullo nelle simulazioni ordinarie e consente la verifica automatica del canale processo.

## Risultati
Confronto indipendente lsim sulla mappa artifact, eccitazione[1e-4;-7e-5]rad per3s. Soglie prefissate q2e-7rad (0.2% dell'eccitazione), u2e-4Nm e attuatori2e-4Nm: includono interpolazione stiff e nonlinearità residue.
| Caso | max errore q rad | RMS errore q | max errore u Nm | errore attuatori Nm |
|---|---:|---:|---:|---:|

| LQG | 7.632222e-10 | 8.313023e-11 | 1.552119e-07 | 3.168794e-06 |
| LQRI | 2.963081e-10 | 4.112508e-11 | 3.821941e-08 | 1.618951e-08 |
| Hinf | 8.882476e-10 | 2.647677e-10 | 4.867047e-08 | 3.273268e-06 |
| Kmu | 1.032421e-09 | 3.230841e-10 | 1.208261e-08 | 6.065985e-09 |

Tracking4s: coda media ultimi0.2s; Ts nella fascia2% dell'ampiezza attorno alla coda, OS sul riferimento, cross=picco non comandato/picco comandato. Picco/RMS su entrambi i comandi. La coda4s non è un errore asintotico certificato, soprattutto per LQRI.
| Caso/giunto | Ts s | OS % | errore coda relativo | cross | picco Nm | RMS Nm |
|---|---:|---:|---:|---:|---:|---:|
| LQG/1 | 0.668 | 0.282975 | 0.00154956 | 0.169271 | 4.74628 | 0.619515 |
| LQG/2 | 0.474 | 0 | 0.000752039 | 0.169001 | 4.51098 | 0.238349 |
| LQRI/1 | 3.504 | 0 | 0.0519285 | 0.0377001 | 0.784014 | 0.429615 |
| LQRI/2 | 3.424 | 0 | 0.0393072 | 0.0372942 | 0.197494 | 0.148651 |
| Hinf/1 | 1.46 | 0 | 0.00518121 | 0.0142457 | 0.868258 | 0.56212 |
| Hinf/2 | 1.46 | 0 | 0.00247527 | 0.0105485 | 0.243891 | 0.192182 |
| Kmu/1 | 1.524 | 0 | 0.060204 | 0.104307 | 0.796375 | 0.499294 |
| Kmu/2 | 1.484 | 0 | 0.0307513 | 0.109861 | 0.199177 | 0.172824 |

| Caso | Rumori0.5s picco/RMS Nm | Errore prima disturbo rad | Media1–2s rad | Media finale rad |
|---|---|---|---|---|
| LQG | 0.339229/0.0919526 | [0, 8.797154192084203e-18] | [0.05233584579799423, -0.02799384005396751] | [0.07182525639837865, -0.028024006377385842] |
| LQRI | 0.347552/0.0952617 | [0, 6.1241878915392636e-18] | [0.04123579432997745, -0.018956959992708113] | [1.774915340657657e-08, 1.0824754726301374e-09] |
| Hinf | 21.5338/4.91417 | [-2.842170943040401e-17, -9.290689789285972e-18] | [0.0023675184562268496, -0.0029844272357990647] | [0.000582476965011347, -0.0007241890804404442] |
| Kmu | 8.00436/2.04816 | [0, 7.570980769951937e-18] | [0.04377874249261315, -0.03857268832624876] | [0.0076265180328181645, -0.005108800539016738] |

Rapporto delle norme finali LQRI/LQG2.3064e-7. Errore finale Kalman senza rumore inferiore1.3e-14; RMS aggregato con rumori0.01062, non interpretabile come errore angolare perché include stati con scale diverse. Replay: errore zero per tutti e4controllori. La prova breve0.5s NON sostituisce la campagna MATLAB4s: picco Hinf5685Nm ancora valido.

## Tutti i controlli
| Controllo | Esito | Valore | Soglia |
|---|---|---:|---:|
| LQG compile | PASS | 0 | 0 |
| LQG state count | PASS | 28 | 28 |
| LQG full state output | PASS | 14 | 14 |
| LQG estimated feedback | PASS | 1 | 1 |
| LQG Gw physical channels | PASS | 7.105427e-15 | 1e-05 |
| LQG equilibrium | PASS | 4.989439e-15 | 1e-08 |
| LQG MATLAB Simulink q | PASS | 7.632222e-10 | 2e-07 |
| LQG MATLAB Simulink u | PASS | 1.552119e-07 | 0.0002 |
| LQG actuators M3 | PASS | 3.168794e-06 | 0.0002 |
| LQG tracking finite j1 | PASS | 1 | 1 |
| LQG tracking finite j2 | PASS | 1 | 1 |
| LQG noise scenario 1 | PASS | 1 | 1 |
| LQG noise scenario 2 | PASS | 1 | 1 |
| LQG noise scenario 3 | PASS | 1 | 1 |
| LQG noise repeatability | PASS | 0 | 0 |
| LQG Kalman convergence | PASS | 1.230804e-14 | 1e-06 |
| LQG disturbance with noise | PASS | 1 | 1 |
| LQRI compile | PASS | 0 | 0 |
| LQRI state count | PASS | 30 | 30 |
| LQRI full state output | PASS | 14 | 14 |
| LQRI estimated feedback | PASS | 1 | 1 |
| LQRI measured integral input | PASS | 1 | 1 |
| LQRI no Nr block | PASS | 0 | 0 |
| LQRI Gw physical channels | PASS | 7.105427e-15 | 1e-05 |
| LQRI equilibrium | PASS | 5.25515e-15 | 1e-08 |
| LQRI MATLAB Simulink q | PASS | 2.963081e-10 | 2e-07 |
| LQRI MATLAB Simulink u | PASS | 3.821941e-08 | 0.0002 |
| LQRI actuators M3 | PASS | 1.618951e-08 | 0.0002 |
| LQRI tracking finite j1 | PASS | 1 | 1 |
| LQRI tracking finite j2 | PASS | 1 | 1 |
| LQRI noise scenario 1 | PASS | 1 | 1 |
| LQRI noise scenario 2 | PASS | 1 | 1 |
| LQRI noise scenario 3 | PASS | 1 | 1 |
| LQRI noise repeatability | PASS | 0 | 0 |
| LQRI Kalman convergence | PASS | 4.997831e-15 | 1e-06 |
| LQRI disturbance with noise | PASS | 1 | 1 |
| Hinf compile | PASS | 0 | 0 |
| Hinf state count | PASS | 36 | 36 |
| Hinf full state output | PASS | 14 | 14 |
| Hinf Gw physical channels | PASS | 7.105427e-15 | 1e-05 |
| Hinf equilibrium | PASS | 6.109706e-13 | 1e-08 |
| Hinf MATLAB Simulink q | PASS | 8.882476e-10 | 2e-07 |
| Hinf MATLAB Simulink u | PASS | 4.867047e-08 | 0.0002 |
| Hinf actuators M3 | PASS | 3.273268e-06 | 0.0002 |
| Hinf tracking finite j1 | PASS | 1 | 1 |
| Hinf tracking finite j2 | PASS | 1 | 1 |
| Hinf noise scenario 1 | PASS | 1 | 1 |
| Hinf noise scenario 2 | PASS | 1 | 1 |
| Hinf noise scenario 3 | PASS | 1 | 1 |
| Hinf noise repeatability | PASS | 0 | 0 |
| Hinf link disturbance | PASS | 1 | 1 |
| Kmu compile | PASS | 0 | 0 |
| Kmu state count | PASS | 92 | 92 |
| Kmu full state output | PASS | 14 | 14 |
| Kmu Gw physical channels | PASS | 7.105427e-15 | 1e-05 |
| Kmu equilibrium | PASS | 5.125327e-15 | 1e-08 |
| Kmu MATLAB Simulink q | PASS | 1.032421e-09 | 2e-07 |
| Kmu MATLAB Simulink u | PASS | 1.208261e-08 | 0.0002 |
| Kmu actuators M3 | PASS | 6.065985e-09 | 0.0002 |
| Kmu tracking finite j1 | PASS | 1 | 1 |
| Kmu tracking finite j2 | PASS | 1 | 1 |
| Kmu noise scenario 1 | PASS | 1 | 1 |
| Kmu noise scenario 2 | PASS | 1 | 1 |
| Kmu noise scenario 3 | PASS | 1 | 1 |
| Kmu noise repeatability | PASS | 0 | 0 |
| Kmu link disturbance | PASS | 1 | 1 |
| LQRI constant disturbance rejection | PASS | 2.306411e-07 | 0.1 |

Sette test MATLAB: esito numerico, quattro controllori, identità M6, identità M7, identità Hinf anche rispetto a nominal_study, identità Kmu, canali di rumore indipendenti.

## Warning, errori risolti e limiti
Gli originali sono R2026a; ambiente locale R2025b. Il caricamento di compatibilità segnala metadati slid/sltp_mm non riconosciuti, riferimenti cstblocks_lti e bus slBus1 non disponibili. Le copie usano State-Space standard e parametri M3 vettorializzati; la preferenza di caricamento è ripristinata a fine costruttore. Il vettore17 contiene parametri, NON stati.
Durante lo sviluppo sono stati corretti errori di API logging/riconnessione e inizializzazione di strutture nel validatore. Non sono difetti dei controllori; i test finali passano. Log di sviluppo conservato.
Le copie sono realmente compilate e simulate; nessun limite di impossibilità di esecuzione MATLAB/Simulink. Restano non eseguiti replay R2026a, hardware, code generation, saturazioni e rate limit. Le nuove prove sono nominali, non nuove certificazioni robuste.
La presentazione precedente riportava la vecchia catena Hinf/Kmu: aggiornata dalla parte Hinf in poi, versione precedente archiviata. Relazione ampliata con equazioni, convenzioni, tabelle e test Simulink.

## Esiti precedenti invariati
Hinf NS/NP PASS; RS FAIL; RP non accreditata (RS negativa e intervallo invertito); Monte Carlo0/40; M5 FAIL.
Kmu NS/NP/RS/RP PASS; Monte Carlo40/40; M5 FAIL. LQRI M7 PARTIAL.
PASS implementativo non significa conformità ai target.

## Esecuzione e consegna
Dalla radice MATLAB:
addpath('simulink','analysis'); setup_lqg_simulink;
Analoghi setup_lqri_simulink, setup_hinf_simulink, setup_kmu_simulink.
Esempio: setup_lqri_simulink(struct('reference',[0;0],'enableLinkDisturbance',true,'horizon',20));
Suite senza sintesi: setenv('CR_RUN_SCOPE','simulink'); run_all;
Ricostruzione facoltativa: build_simulink_integration;
Figure dai risultati: export_simulink_integration;
Non occorrono variabili manuali nel base workspace né l'esecuzione dei vecchi script di progetto.

Consegna:4SLX, originali preservati,4setup e setup comune, costruttore, simulatore, mappa lineare, validatore, test, dati MAT/JSON,3figure, relazione e presentazione PDF e questo resoconto in MD/TXT. PDF compilati con latexmk da report/presentation. Matricole e data formale restano da completare. PR in bozza; merge manuale.

Tracciabilità: results/data/simulink_integration/manifest.json contiene SHA256 delle evidenze; testi normalizzati UTF-8/LF senza BOM, binari invariati. report/build_simulink_text.py aggiorna tabelle e manifest dai risultati, senza sintesi.
