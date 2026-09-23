# Audit iniziale integrazione Simulink — 23 settembre 2026

Base: main 889c0eb46580767d8e6a958fda1af17f0c64658e (PR32 integrata).
Branch: codex/simulink-integration. Audit prima delle modifiche ai modelli.

## Fonti e precedenza
I tre archivi Progetto_{LQR,LQRI,Hinf}_simulink.slx.zip sono presenti nei Download dal 22 settembre. La cartella Drive fornita contiene i corrispondenti pacchetti SLX decompressi. Conservazione byte per byte degli archivi locali come SLX in legacy/valerio; manifest SHA256 e inventario XML completo. La richiesta esplicita autorizza questi modelli come base, in deroga alla regola generale di ricostruzione indipendente di AGENTS.md. Nessuna scrittura su Drive.

## Equazioni e artifact correnti
M3: 8 stati meccanici e 6 stati attuatori, Afull=[Am Bm*Ca;0 Aa], Bfull=[Bm*Da;Ba]. eta_u entra prima degli attuatori. Il disturbo link entra attraverso M(q)\d nelle sole accelerazioni dei link. M6: K, Nr, L, Qn=0.01 I4, Rn=(0.05*pi/180)^2 I4. Il campo Gw è salvato come processNoiseInputMatrix (non Gw). M7 corrente: m7_augmented_cost_feasibility.mat, designs{config.illustrativeIndex}; Kx 2x14, Ki 2x2, nessun Nr. Hinf selected_full_order.selected.K e nominal_study.study.selected; Kmu m13.synthesis.K; ingressi [r;q], uscita u, ordini 22/78. Nessuna sintesi da ripetere.

## Audit delle strutture originali
Tutti i blocchi, parametri e collegamenti XML sono conservati nell'inventario JSON.
- Meccanica: funzione a 8 stati corretta per tau motore, ma priva del disturbo link. La versione LQRI dichiara d senza usarlo e senza collegamento esterno.
- Actuators: due LTI System, Demux/Mux; le variabili dipendono dal workspace. Occorre caricare M3 e rendere osservabili i sei stati nella stessa base di Afull.
- Equilibrio: integratore xbar e sottrazione xbar già presenti. taubar è aggiunta dopo gli attuatori; adottare l'esatta convenzione della catena MATLAB, con bias prima degli attuatori e loro inizializzazione di equilibrio.
- tau_d: sommato alla coppia motore nei tre originali; va spostato al canale link.
- Sum4: secondo ingresso non collegato dopo la derivata meccanica; rimuovere la somma, senza aggiungere Gw*w a otto stati.
- Misura: selezione [1 2 5 6] corretta; rumore scalare comune alle quattro misure errato. Usare quattro componenti indipendenti.
- LQG: feedback xhat e prefiltro Nr già corretti strutturalmente; Kalman A/B/C/L da M3/M6.
- LQRI: due guadagni Kx/Ki e segni negativi già corretti; integratore usa q ideale (Selector collegato prima del rumore), da correggere a q misurata. Random Number processo presente ma scollegato.
- Hinf: ingresso r-q a due canali obsoleto; deve diventare concatenazione [r;q] senza prefiltro.
- Kmu: modello assente; derivare dalla medesima infrastruttura Hinf con altro artifact.
- Scope, disposizione principale, nomi e sottosistema Kalman sono riutilizzabili.

## Validazione e limiti iniziali
I modelli originali non sono autonomi: richiedono variabili esterne non incluse negli archivi. Compilazione originale NON VALIDATA. Il primo audit MATLAB ha letto correttamente artifact e covarianze; l'ultima interrogazione è fallita perché cercava il nome Gw invece di processNoiseInputMatrix. Non è un difetto del dataset.
API MATLAB locali autorizzate esplicitamente; sole librerie standard. Validazione prevista: compile/dimensioni, identità artifact, Jacobiani A/B/Bd/Gw, equilibrio, risposta attuatori, quattro confronti lineari, tracking, Kalman, disturbo costante LQG/LQRI, rumori separati e combinati e ripetibilità. M7 PARTIAL e fallimenti robusti/M5 restano invariati.
