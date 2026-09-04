# Resoconto finale — revisione LQR/LQG, H∞ e RAS

Data: 2026-09-04
Repository: `Deda-404/Progetto_CR`
Branch: `codex/lqr-kalman-hinf-ras-didactic-rework`
Base verificata: `origin/main` al commit `5bd969e2c8bcd80cc48bc3b5f3176f2816d4443b`
Commit storico di confronto: `4609d3cca0af84411f2c88404c33bb97c563ae03`

## 1. Stato iniziale

Il progetto era già completo fino a M18, con specifiche M5, controllori
robusti e risultati negativi da preservare. La revisione è partita da una
working tree separata da `main` e ha mantenuto come invarianti M5, Khinf M10,
Kmu M13 e la distinzione fra Monte Carlo M16 e certificazione μ M14.

## 2. Confronto con il commit 4609d3c

Il commit storico usava una ricerca LQR coarse da 240 costi, selezionava C193
fra 139 candidati ammissibili e valutava 27 terne di covarianze Kalman. La
revisione precedente aveva poi semplificato M6 a una scelta diretta. Lo stato
finale adotta un compromesso didattico: 36 costi LQR espliciti, gate M5 prima
dello score, una sola scelta Kalman nominale accompagnata da tre casi di
sensibilità. Le generalized plant, Khinf e Kmu non sono state risintetizzate.

## 3. File modificati

Le modifiche sorgente principali riguardano:

- `src/parameters/{uncertainty_params_m4,lqg_specs_m6,lqg_specs_m7}.m`;
- `controllers/lqg/design_lqr_m6.m`;
- `analysis/nominal/{evaluate_m6_closed_loop,validate_m6_lqg_no_integrator,validate_m7_lqg_integral}.m`;
- `analysis/ras/{estimate_lqg_ras,estimate_m15_robust_ras,simulate_m8_nonlinear}.m`;
- `analysis/comparison/` e `analysis/finalization/` per propagare i nuovi dati;
- `simulink/build_m8_simulink_model.m` e i due modelli `.slx`;
- test M4, M6, M8, M15, M17 e M18;
- README, documentazione tecnica, relazione e presentazione.

Dataset, tabelle e figure sono stati rigenerati dalle rispettive pipeline e
non modificati manualmente.

## 4. File creati

Sono stati aggiunti:

- `analysis/progetto_lqg.m`;
- `analysis/progetto_hinf.m`;
- `analysis/ras/build_common_ras_comparison.m`;
- `controllers/lqg/search_lqr_weights_m6.m`;
- `controllers/lqg/analyze_kalman_sensitivity_m6.m`;
- `tests/test_didactic_entry_points.m`;
- dataset e figure della ricerca LQR, sensibilità Kalman e RAS comune;
- questo resoconto e la versione TXT per il passaggio a GPT.

## 5. Espansione M0–M5

`analysis/modellazione_linearizzazione_controllo.m` è ora un percorso
sequenziale eseguibile per sezioni: modello non lineare, equilibrio,
linearizzazione, attuatori, insieme incerto, specifiche e pesi. Ogni sezione
espone scopo, formule, dati sorgente, output e quality gate. Le funzioni
matematiche riutilizzabili restano separate.

## 6. Script progetto_lqg

`analysis/progetto_lqg.m` copre soltanto M6–M8: ricerca LQR, progetto Kalman,
separation principle, confronto LQI M7, Simulink non lineare e RAS LQG. Non
contiene sintesi H∞ o μ.

## 7. Script progetto_hinf

`analysis/progetto_hinf.m` copre soltanto M9–M12: mixed sensitivity,
generalized plant, confronto full-order/strutturato e μ-analysis di A5. Non
chiama `musyn`, non modifica Khinf e non include la D–K synthesis M13.

## 8. Separazione dei percorsi

Non esiste uno script combinato M6–M12. I tre entry point didattici sono
M0–M5, M6–M8 e M9–M12; `run_all.m` resta il gate integrale M0–M18.

## 9. Logica della ricerca LQR

La ricerca usa due stadi. Prima elimina instabilità e violazioni dei target
M5 di settling, overshoot ed errore statico; il cross-coupling è registrato
come gate diagnostico. Soltanto i candidati ammissibili ricevono uno score
normalizzato su settling 30%, overshoot 20%, errore 10%, cross-coupling 10%,
picco comando 15% e RMS comando 15%.

## 10. Spazio dei candidati

Sono valutate 36 combinazioni:

- `wq = [0.5, 1, 2]`;
- `wqdot = wthetaDot = [0.5, 1]`;
- `wdelta = [0.1, 0.5]`;
- `rhoU = [4, 8, 16]`.

Non è prevista una griglia estesa e non viene aperta una seconda iterazione.

## 11. Motivazione dei valori

Le scale fisiche restano quelle M5: riferimento 5°, velocità caratteristica
`omegaB*qScale`, deformazione SEA da coppia nominale/rigidezza minima e
comando normalizzato con `uScale=12 N m`. I moltiplicatori sono pochi,
simmetrici sui giunti e scelti per mostrare il compromesso fra rapidità,
elasticità e sforzo senza tornare alla vecchia esplorazione a 240 punti.

## 12. Matrici Q e R selezionate

LQR30 usa `wq=2`, `wqdot=wthetaDot=1`, `wdelta=0.1`, `rhoU=16`.
Ne segue `R=0.111111 I2`. La matrice `Q=Ccost' Ccost` ha blocchi non nulli:
`Q11=Q22=902.6245`, `Q15=Q51=Q26=Q62=-640`,
`Q55=Q66=640`, `Q33=Q44=Q77=Q88=0.9119`; gli stati interni degli
attuatori non ricevono pesi diretti arbitrari.

## 13. Risultati LQR

Sono ammissibili 9 candidati su 36. LQR30 ha score `0.394292`, worst settling
`0.678 s`, overshoot `0.4044%`, cross-coupling `0.16936`, picco comando
`4.5106 N m`, RMS comando `0.6261 N m` ed energia `2.3325 N m^2 s`. CARE,
stabilità e precompensatore statico sono verificati.

## 14. Modifiche Kalman

Il progetto nominale conserva quattro canali di processo: due coppie lato
link e due perturbazioni equivalenti all'ingresso, con quattro misure encoder
`[q;theta]`. È stata aggiunta un'analisi riproducibile per
`sigmaY=[0.025,0.05,0.10]` gradi; la scelta nominale resta `0.05°`.

## 15. Motivazione Qn/Rn

Le deviazioni standard dichiarate sono `sigmaD=sigmaU=0.1 N m` e
`sigmaY=0.05°`, quindi `Qn=0.1^2 I4` e
`Rn=(0.05*pi/180)^2 I4`. Con misura più affidabile l'osservatore accelera ma
amplifica maggiormente il rumore; con misura più rumorosa diventa più lento e
prudente. Il rapporto stimatore/regolatore nominale è `1.5099`.

## 16. Pesi H∞

I valori numerici M5 di W1 e W2 non sono stati modificati: W1 passa da
`1/As=20` a `1/Ms=0.5`, W2 da `1/uScale=0.08333` a
`alpha/uScale=0.5`, con `omegaB=12 rad/s`, `omegaU=30 rad/s` e `alpha=6`.
Sono state ampliate spiegazione, asintoti, significato fisico e uso nella
generalized plant; non è stato effettuato retuning H∞.

## 17. Capitolo delle incertezze

La relazione distingue parametri incerti, parametri fissi, unità, valore
nominale, intervallo e razionale. Le percentuali sono assunzioni
ingegneristiche per il progetto, non tolleranze identificate né distribuzioni
probabilistiche.

## 18. Parametri incerti

L'unico insieme M4 contiene: `k1=50 N m/rad` in `[45,55]`,
`k2=40 N m/rad` in `[36,44]`, `Jm1=0.01 kg m^2` in `[0.009,0.011]`,
`wn=40 rad/s` in `[36,44]`, `zeta=0.8` in `[0.72,0.88]` e
`delay=0.015 s` in `[0.012,0.018]`.

## 19. Parametri mantenuti fissi

Restano nominali `m1=1 kg`, `m2=0.8 kg`, `l1=0.4 m`, `l2=0.3 m`,
`Jm2=0.01 kg m^2`, `Bm1=Bm2=0.02 N m s/rad` e `g=9.81 m/s^2`.

## 20. Motivazione degli intervalli

Le rigidezze rappresentano dispersione di assemblaggio/materiale; Jm1 la
direzione dominante di inerzia riflessa; `wn` e `zeta` variazioni di drive e
carico; il ritardo include latenza e jitter. I restanti parametri sono fissati
per evitare un insieme sovradimensionato e non identificato sperimentalmente.

## 21. Nuovo schema Simulink didattico

`SEA_LQG_nonlinear.slx` è stato ricostruito con soli blocchi standard. Al
livello principale separa Reference, LQG Controller, Actuator Dynamics,
Nonlinear SEA Plant, Measurement Interface e Signal Monitoring. Nel
controller sono visibili `Nr`, `-K`, somma incrementale, ingressi `u/y`,
osservatore Kalman, coppia di equilibrio e comando assoluto. Nessuna equazione
o matrice è nascosta in una libreria custom.

## 22. Inventario dei controllori RAS

Il confronto comune include M6 LQG senza integratore (ordine 14), Khinf M10
full-order (ordine 18) e Kmu M13 congelato (ordine 52).

## 23. Metodo RAS comune

I tre controllori usano lo stesso modello meccanico non lineare M1, gli stessi
attuatori nominali M3, lo stesso equilibrio, solver, orizzonti, griglia,
direzioni, box e criterio di convergenza. Il risultato è comparativo ed
empirico, non una regione di attrazione certificata.

## 24. Piano delle condizioni iniziali

Si perturba il piano `(delta q1(0),delta q2(0))`; le velocità sono nulle,
`theta(0)=thetabar+delta q(0)` per non introdurre deformazione SEA aggiuntiva,
gli attuatori partono all'equilibrio e gli stati del controllore/stimatore
partono da zero.

## 25. Griglia e intervallo

La griglia grossolana è `[-60,-30,0,30,60]^2` gradi. La frontiera radiale usa
36 direzioni, box ±60° e bisezione con tolleranza radiale 1°.

## 26. Simulazioni e punti

M6 usa 57 punti unici; Khinf 143; Kmu 57. La differenza deriva dal fatto che
Khinf localizza una frontiera interna e richiede bisezioni aggiuntive, mentre
M6 e Kmu arrivano al limite del box in ogni direzione.

## 27. Criterio di convergenza

Il solver è `ode23t`, orizzonte 8 s estendibile a 12 s. Nell'ultimo 10% si
richiedono `|q-qbar|<=0.5°`, `|qdot|<=0.02 rad/s`,
`|theta-thetabar|<=0.5°`, `|thetadot|<=0.05 rad/s`, segnali finiti e limitati
e assenza di crescita finale significativa.

## 28. Saturazioni

Non sono presenti saturazioni hardware né anti-windup inventati. `uScale=12
N m` è esclusivamente una normalizzazione prestazionale; i picchi di comando
sono riportati come limite implementativo da valutare.

## 29. RAS M6 LQG

57/57 punti convergono, frazione empirica 1, raggio minimo 60°, massimo
78.324°, area poligonale 14214 deg² e massimo comando convergente 223.74 N m.
Classificazione: `SEARCH-BOX LIMITED`.

## 30. RAS Khinf

101/143 punti convergono e 42 divergono, frazione empirica 0.70629, raggio
minimo 52.876°, massimo 78.324°, area 12721 deg² e massimo comando convergente
70.869 N m. Classificazione: `EMPIRICAL BOUNDARY LOCATED`.

## 31. RAS Kmu

57/57 punti convergono, frazione empirica 1, raggio minimo 60°, massimo
78.324°, area 14214 deg² e massimo comando convergente 77.257 N m.
Classificazione: `SEARCH-BOX LIMITED`.

## 32. Altri controllori

M7 non entra nel confronto perché le tre verifiche LQI rigettano il disturbo
ma nessuna soddisfa insieme settling e overshoot M5; non esiste quindi un
controllore integrale finale. A5 M11/M12 resta oggetto di μ-analysis storica,
non un controllore finale RAS aggiuntivo.

## 33. Tabella comparativa RAS

| Controllore | Conv./punti | Frazione | r min [°] | Area [deg²] | Max u conv. [N m] | Classe |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| M6 | 57/57 | 1.0000 | 60.000 | 14214 | 223.74 | search-box limited |
| Khinf | 101/143 | 0.7063 | 52.876 | 12721 | 70.869 | empirical boundary located |
| Kmu | 57/57 | 1.0000 | 60.000 | 14214 | 77.257 | search-box limited |

## 34. Interpretazione

Nel box esaminato M6 e Kmu convergono in tutti i punti provati; ciò non
permette di ordinare le loro vere regioni oltre ±60°. Khinf mostra invece una
frontiera interna campionata. Il picco di comando molto elevato di M6 segnala
un limite pratico importante in assenza di saturazione.

## 35. Limiti metodologici

RAS e Monte Carlo dipendono da griglia, orizzonte e soglie; non certificano il
continuo né il modello incerto non lineare. Le incertezze M4 non sono
identificate sperimentalmente. Kmu conserva ordine 52. Nessun controllore
soddisfa tutte le specifiche: Kmu passa RS ma fallisce NP/RP e tracking.

## 36. Test eseguiti

La suite MATLAB contiene 599 test e ha completato 599/599 PASS. Il Code
Analyzer copre 162 file `.m` con 0 segnalazioni. Sono inoltre eseguiti i tre
script didattici, il build/compile dei modelli Simulink, `run_all` M0–M18,
compilazione LaTeX e audit dei PDF.

## 37. Risultati conclusivi

M6 passa il tracking nominale ma in M16 è stabile in 38/40 campioni; i Sample
5 e 6 hanno rispettivamente max Re `+2.9376` e `+0.20602`. Khinf e Kmu sono
stabili 40/40 ma falliscono il core tracking. La sola certificazione RS resta
M14 per Kmu, margine `[1.069561,1.212875]`; M16 è evidenza empirica.

## 38. Problemi residui

Restano intenzionalmente aperti: M7 senza controllore finale; NP/RP Kmu e
tracking Khinf/Kmu non conformi; due campioni M6 instabili; assenza di limiti
attuativi certificati; parametri incerti non identificati; matricole e data di
consegna ancora da inserire nei frontespizi.

## 39. Differenze rispetto alla revisione precedente

Sono state aggiunte la ricerca LQR compatta, la sensibilità Kalman, la
separazione degli script LQG/H∞, il confronto RAS a tre controllori e lo schema
Simulink didattico. La relazione passa a 47 pagine, M18 riconcilia 78 valori e
18 figure. Con LQR30 M16 passa dal precedente 39/40 al corrente 38/40; il
nuovo risultato negativo è conservato e documentato.

## 40. Commit

- `13851f83dbf1cfb23d0cd8dc9a880d9744bee59c` — `feat: revise LQR Kalman and common RAS workflow`;
- `5c22fe9ae1d0a6e77760aca0f0321f0c1700b7a0` — `docs: reconcile control design and validation deliverables`;
- il commit di chiusura aggiorna esclusivamente questi metadati di
  pubblicazione; il suo SHA è l'HEAD della PR e non può essere auto-incluso
  nel contenuto che determina il medesimo SHA.

## 41. Pull Request

Pull Request `#26`: `https://github.com/Deda-404/Progetto_CR/pull/26`.
Base `main`, head `codex/lqr-kalman-hinf-ras-didactic-rework`, stato `open`,
`merged=false`. `main` non è stato modificato direttamente e non è stato
eseguito alcun merge automatico.
