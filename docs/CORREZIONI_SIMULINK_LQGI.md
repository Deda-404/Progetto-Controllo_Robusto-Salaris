# Correzioni degli originali Simulink — 6 ottobre 2026

Responsabile: Alessio. Stato **PARTIAL / NON VALIDATO in Simulink**.
Sei caricamenti R2026a su R2025b falliscono con
`Simulink:Commands:LoadingNewerModel`. Nessun diagramma sostitutivo generato.
Manifest e SHA-256 conservano la provenienza: LQRI nei nomi originali
identifica l'archivio, non la versione definitiva valida del servo.

## File controllati e compatibilità

In `simulink/originals`: `Progetto_LQR_simulink.slx`,
`Progetto_LQRI_simulink.slx`, `Progetto_Hinf_simulink.slx` (non lineari),
`LQR_linear_sim.slx`, `LQRI_linear_sim.slx`, `Hinf_linear_sim.slx`.
I tre lineari, trovati sul Drive in questa revisione, sono copie esatte;
i tre non lineari già archiviati restano invariati. Il modello chiamato LQR
contiene Kalman e ha ruolo LQG. I modelli dei colleghi non sono trasferiti.

Aprire in R2026a e correggere una copia **del diagramma originale**. Per
R2025b usare `Save > Export Model to > Previous Version`; non disabilitare
il controllo di release per dichiarare una simulazione valida. Dopo correzione
e confronto salvare `LQGI_linear_sim.slx` e `LQGI_nonlinear_sim.slx` fra i
modelli validati, preservando gli originali e registrando i nuovi hash.
Le copie definitive non sono state create o accreditate in questa revisione.

Caricare `data=setup_original_models("LQGI")` nel Model Workspace. Usare
A 14×14, B 14×2, C 4×14, L 14×4, Kx 2×14 e Ki 2×2 del M7 con wbarI=200.
Non usare A meccanica 8×8 nel Kalman. Verificare bus `slBus1`, libreria
Control System Toolbox e `Gact` dei due LTI. Non risintetizzare i guadagni.

## Lineare: istruzioni sui SID originali

| Blocco / SID | Collegamento e correzione |
|---|---|
| State-Space / 64 | Conservare A=Afull, B=Bfull, C=CfullMeas; D=zeros(4,2), x0=zeros(14,1) |
| Sum3 / 54 | y ideale + rumore → Kalman SID28; conservare `++`, quattro misure |
| Selettore1 / 50 | Indici [1 2]. Staccare `64:out1 → 50:in1`; collegare **`54:out1 → 50:in1`** |
| Sum5 / 56 e Integrator1 / 27 | Conservare qmis in1 meno, r in2 più; xi0=zeros(2,1) |
| Kalman filter / 28 | A*xhat+B*u+L*(ymis-C*xhat); xhat0=zeros(14,1); uscita su Gain SID20 |
| Gain / 20, Gain1 / 21, Sum / 51 | Conservare Kx*xhat, Ki*xi, `Matrix(K*u)` e somma `--`; medesimo u a pianta e Kalman |
| Rumore di misura / 47 | Sostituire sequenza scalare condivisa con quattro canali indipendenti o il vettore salvato |

Per le prove complete ampliare gli ingressi **del solo State-Space fisico**
a `[u;d;w]`, con Bplant=[Bfull,BdFull,BdFull,Bfull] (14×8) e Dplant=zeros(4,8).
Sono due comandi, due disturbi deterministici lato link e quattro rumori di
processo. Il Kalman conserva B=Bfull e conosce soltanto u, non d o w.
Nei test puliti gli ingressi aggiunti devono essere zero, non scollegati.

## Non lineare: istruzioni sui SID originali

| Blocco / SID | Collegamento e correzione |
|---|---|
| Integrator / 15 e Sum2 / 39 | Conservare stato assoluto x0=xbar e sottrazione xbar prima dei sensori |
| Selettore / 36 | Conservare [1 2 5 6], ordine [q1 q2 theta1 theta2] |
| Sum3 / 40 | Misure ideali + quattro rumori indipendenti → Kalman SID16 |
| Selettore1 / 50 | Staccare `36:out1 → 50:in1`; collegare **`40:out1 → 50:in1`** |
| Sum5 / 49 e Integrator1 / 51 | Conservare qmis in1 meno e r in2 più; xi0=zeros(2,1) |
| Kalman filter / 16 | Conservare 14 stati, L M6, u da Sum SID37; xhat0=zeros(14,1) |
| Gain / 13, Gain1 / 48, Sum / 37 | Conservare Kx*xhat, Ki*xi e somma `--`: nessun feedback del vero x |
| Mux1 / 68, tau_d1 / 70, tau_d2 / 71 | Togliere d da Sum1 `38:in1` lato motore e portarlo alla dinamica dei link |
| Non linear plant / 28, MATLAB Function / 31 | Il chart dichiara già d alla porta 4, scollegata. Esporla e collegarla nel sottosistema |
| Rumore di proceso / 35 | Sorgente scollegata. Definire due canali lato link e due prima degli attuatori, ignoti al Kalman |
| Sum4 / 41 | Secondo ingresso libero della derivata: eliminare ingresso o collegare zero di dimensione 8; non sommare coppie direttamente a xdot |

Verificare nel chart originale le equazioni:

`ddq = M(q) \ (Ks*(theta-q) - C(q,dq)*dq - G(q) + d)`

`ddtheta = Jm \ (tau - Bm*dtheta - Ks*(theta-q))`.

d non entra nella seconda equazione come coppia motore. I rumori lato link
si sommano a d; quelli lato ingresso a u prima degli attuatori. Il Kalman
conosce u e riceve ymis; non conosce questi rumori. Correggere il chart già
presente, senza importare quello dei colleghi.

L'originale usa `tau=taubar+Gact*u`, con stati attuativi incrementali nulli:
è equivalente alla nuova integrazione MATLAB con stati attuativi assoluti
all'equilibrio e `uAbsolute=taubar+u`. Non aggiungere taubar due volte.
Nella forma assoluta inizializzare xa0=-Aa\(Ba*taubar).

## Rumori, altri controllori e verifiche finali

Per un confronto identico usare `measurementNoise` e `processNoise` delle
prove 2 e 3 in `results/data/lqgi_validation/validation.mat`, con From
Workspace e ZOH: stesso seed 20260826, 2 ms, stessa sequenza encoder.
Quattro Random Number con semi distinti producono canali indipendenti,
ma non garantiscono la stessa sequenza di randn. Campioni ZOH e intensità
bianche continue lqe restano distinti. Nessuna covarianza viene modificata.

Gli H∞ originali hanno due errori in ingresso; il K corrente è 2×4 su
`[r1 r2 q1 q2]`. Modificare manualmente quella interfaccia e mantenere
un solo stato dinamico di 22 componenti, col segno in Ky. Duplicare le
realizzazioni Kr/Ky non rappresenta il controllore salvato. Per Kµ servirebbe
la stessa interfaccia con 78 stati: non è disponibile un originale del
gruppo e non è stato trasferito quello dei colleghi.

Prima di dichiarare valide e rinominare le copie:

1. Confrontare Acl a 30 stati, poli e risposte con `evaluate_lqgi_candidate`,
   usando stessi ingressi e condizioni iniziali.
2. Perturbare la pianta con xhat0=xi0=0: u(0)=0 deve distinguere feedback
   stimato da un uso accidentale dello stato vero.
3. Verificare che il rumore encoder di q entri subito in xi_dot con segno meno.
4. Confrontare equilibrio, gradini 2/5/8 gradi (8 s), disturbi separati
   0.25/0.5/1 N m (8 s) e rumore (4 s) con `validation.mat`. Non chiamare
   il residuo a 8 s errore DC.
5. Ripetere RAS con protocollo M8, inizializzazioni dichiarate e stessi
   solver/tolleranze. Le prove senza saturazioni non validano una RAS hardware.
6. Registrare release, metriche, warning, modifiche dei fili e hash delle
   copie. Solo dopo questo confronto chiamarle LQGI e accreditarne i risultati.
