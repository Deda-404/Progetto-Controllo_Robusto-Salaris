# Tracciabilità della traccia ufficiale SEA

La nuova consegna copre i requisiti MATLAB; l'integrazione Simulink S1
attende i modelli definitivi degli studenti. Le prestazioni non raggiunte
sono risultati dichiarati, distinti dal corretto svolgimento dei metodi.

| Requisito | Implementazione | Evidenza e stato |
|---|---|---|
| Fisica SEA, parametri e unità | dinamica_sea, parametri_sea; SEA_01 | Equilibrio, Jacobiani e canale disturbo verificati |
| Linearizzazione e misure | SEA_01, banca nominale | A/B nominalmente uguali; quattro encoder LQG, q per robusti |
| Secondo ordine con Padé1 | SEA_01 | Nominali conservati, tau noto 15 ms |
| Pochi parametri incerti motivati | SEA_01; relazione cap.3-5 | S1 approvata; LFT manuale e inclusione analitica |
| Specifiche e pesi dichiarati | parametri_sea, SEA_03 | Target invariati, pesi espliciti, nessun nuovo rilassamento |
| 1. LQG senza integratore | SEA_02 | lqr/lqe, Q/R, covarianze e identità del controllore |
| 1. LQG con integratore | SEA_02 | Sistema aumentato, Riccati, xi_dot=r-q_mis |
| 1. Lineare/non lineare e RAS | SEA_05 | Due tracking + due disturbi, 15 condizioni iniziali per K |
| 1. Simulink | Interfaccia numerica esportata | Nuovi SLX S1 NOT RUN; precedenti risultati conservati |
| 2. mixsyn e hinfsyn con confronto | SEA_03 | Stesso P1; norme ricostruite e nominali stabili |
| 2. hinfstruct/PID | SEA_03 | Un avvio dal PID consolidato, stessa P2 |
| 2. H∞ lineare/non lineare e RAS | SEA_05 | Prove reali; esiti inconcludenti conservati |
| 2. μ-analysis con incertezze e attuatori | SEA_04 | RS/RP adattive e N11/mussv su A/B; campioni distinti |
| 3. μ-synthesis D-K | SEA_04 | Due D-K dedicate, quattro iterazioni ciascuna, stessi pesi |
| 3. Post-analisi μ | SEA_04 | Analisi incrociata di Mu_A/Mu_B su entrambe le famiglie |
| 3. Eventuale rilassamento | Non necessario per RP S1 | Entrambe le sintesi raggiungono RP; target temporali ancora parziali |
| 3. μ lineare/non lineare e RAS | SEA_05 | Ordini 88/32; RAS 6/15 e 15/15, con limiti espliciti |
| 4. Confronto H∞/μ in RS/RP | SEA_04/05 | confronto_robusto.csv, quadro_finale.csv, relazione cap.10/12 |
| 5. Circa dieci impianti comuni | SEA_05 | 10 impianti fisici, stessi per tutti; metriche degli instabili NaN |
| Relazione, grafici, codice e controllori | documenti/relazione, nove .m, dati/ | Relazione riorganizzata dalla base consolidata; sorgenti inclusi |
| Presentazione ≤20 minuti | documenti/presentazione, PRESENTAZIONE_NOTE | 18 slide, 19:19 pianificati; prova dal vivo ancora necessaria |
| Riproduzione autonoma | SEA_00, LEGGIMI | Due modalità; nessuna dipendenza da repository o servizi online |

NS/NP/RS/RP restano proprietà separate. Il passaggio A/B cambia l'insieme
ammesso, mentre la risintesi cambia K: le due operazioni sono riportate
separatamente. I margini precedenti M4 e i nuovi S1 non sono intercambiabili.
