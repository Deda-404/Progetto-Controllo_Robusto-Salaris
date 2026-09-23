# Completamento PR #33 — 23 settembre 2026

Branch: codex/simulink-integration. Base di questa integrazione aggiuntiva: 8044946.
PR: https://github.com/Deda-404/Progetto_CR/pull/33 — deve restare draft, senza merge.

Esito: modello linearizzato Simulink esplicito validato; RAS nominale LQRI calcolata;
presentazione ridotta da 24 a 20 slide, durata prevista 17:55 (margine 2:05).
Il timing è una scaletta, non una prova orale cronometrata.

MODELLO LINEARE
Un solo SEA_linear_common.slx: Afull, [Bfull BdFull], 14 stati (8+6),
uscite CfullMeas e CfullQ separate. Selezione LQG/LQRI/Hinf/Kmu da artifact congelati.
Ordini completi 28/30/36/92, nessuna riduzione. Diagramma deterministico;
rumore e disturbo del progetto restano anche nei quattro modelli non lineari originari.
Nuove simulazioni: tre scenari di 3 s per controllore (5 gradi separatamente sui
due giunti e disturbo link-side [0.01;-0.007] Nm), più un confronto a piccolo segnale.
Le tracce non lineari del confronto sono quelle già calcolate e validate nella PR33.
32/32 controlli PASS, soglie 2e-7 rad e 2e-4 Nm fissate prima del calcolo.
Peggior errore Simulink lineare/MATLAB: q=1.07243261e-08 rad, u=1.79160285e-06 Nm.
Peggior errore non lineare/lineare Simulink: q=9.80032256e-10 rad, u=1.49484634e-07 Nm.

RAS LQRI
Protocollo M8 LQG riutilizzato direttamente: dq e dtheta uguali, velocità nulle,
attuatori in equilibrio, xhat0=0 e xi0=0. Riferimento, disturbi e rumori nulli.
Box +/-60 gradi, griglia 5x5, 36 direzioni, precisione radiale 1 grado;
orizzonti 8/12 s, ode23t, RelTol=1e-5, AbsTol=1e-7, MaxStep=0.005 s.
Coda: ultimo 10% dei campioni del solver, come M8; soglie 0.5 gradi per
q/theta, 0.02/0.05 rad/s per le velocità; verifica crescita finale e finitezza.
57/57 punti convergenti in 57 simulazioni, zero estensioni e zero errori.
Raggio minimo 60 gradi, massimo 78.324437;
area del poligono campionato 14213.599713 gradi quadrati.
Picco comando 240.96051415 Nm (LQG storico: 232.1879 Nm).
Identità K/L/Nr della RAS LQG storica verificata rispetto agli artifact correnti.
Entrambe SEARCH-BOX LIMITED: nessuna frontiera reale individuata, nessuna
certificazione e nessuna superiorità dimensionale della RAS dimostrata.
La sezione LQRI con stima iniziale coerente non è stata eseguita.
Nessuna saturazione hardware introdotta; picchi di coppia dichiarati.

TEST E FALLIMENTI DOCUMENTATI
67 controlli precedenti conservati, con evidenza salvata PASS (non rilanciati).
7 test originari rieseguiti: PASS. 15 test aggiunti: PASS. Totale 22/22.
Nuovi casi: 4 equivalenze MATLAB/SL lineare; 4 equivalenze NL/SL lineare;
4 verifiche effettive di matrici, interfacce e numero stati; protocollo RAS,
assenza di errori RAS, identità LQG storico (3 casi).
Prima esecuzione: 4 FAIL nel test dimensionale perché linmod a singolo output
restituisce una struttura. Corretto esclusivamente il test richiedendo quattro
output; modello, guadagni, soglie e risultati non sono stati adattati al PASS.
MAT/CSV initial_failure conservano il run iniziale; il run finale è 22/22 PASS.

RIPRODUZIONE SENZA SINTESI
MATLAB: setenv('CR_RUN_SCOPE','simulink-completion'); run_all
Il checkpoint RAS evita ripetizioni ed è accettato solo con identità esatta
di configurazione e artifact. Per ricalcolo completo, archiviare altrove
lqri_ras_checkpoint.mat prima di eseguire il percorso.
Documenti: python report/build_completion_text.py; latexmk -pdf nelle cartelle
report e presentation, poi copia main.pdf nei rispettivi nomi finali.

VINCOLI E LIMITI
Controllori/sintesi, quattro SLX non lineari, legacy Valerio e risultati robusti
precedenti non modificati. Nessuna sintesi, musyn, Monte Carlo o mu-analysis rilanciata.
MATLAB/Simulink erano disponibili: nuove simulazioni realmente eseguite in R2025b
Update 4. Restano non verificati replay R2026a, hardware, saturazioni e code generation.
Hinf RS FAIL e MC 0/40, Kmu RS/RP PASS e MC 40/40, M5 FAIL e M7 PARTIAL invariati.

PDF FINALI
report/Progetto_CR_Relazione_finale.pdf
presentation/Progetto_CR_Presentazione.pdf

FILE NUOVI PRINCIPALI
simulink/build_linear_common.m
simulink/setup_linear_common.m
simulink/simulate_linear_common.m
simulink/simulate_integrated_ras.m
simulink/models/SEA_linear_common.slx
analysis/validate_linear_common.m
analysis/ras/validate_lqri_ras.m
analysis/run_simulink_completion.m
analysis/export_simulink_completion.m
tests/test_simulink_completion.m
report/build_completion_text.py
report/sections/10c_simulink_completion.tex
report/figures/simulink_completion/linear_nonlinear.png
report/figures/simulink_completion/ras_lqg_lqri.png
docs/RESOCONTO_PR33_COMPLETION.md e .txt

MODIFICHE A FILE ESISTENTI
analysis/ras/estimate_lqg_ras.m: adattatore opzionale e checkpoint, default storici invariati.
run_all.m: nuovo percorso circoscritto simulink-completion.
report/sections/10b_integrazione_simulink.tex: collegamento alla nuova sezione.
report/sections/13_conclusioni_limiti.tex e C_riproducibilita.tex: esiti e riproduzione.
presentation/main.tex, OUTLINE_AND_TIMING.md, SPEAKER_NOTES.md e PDF: 20 slide, 17:55.
README.md, CHANGELOG.md, docs/DIARIO_DI_BORDO.md, DECISION_LOG.md, PROJECT_STATUS.md.
Relazione PDF aggiornata dopo validazione.

EVIDENZE AGGIUNTE (results/data/simulink_completion)
development_log.txt
Hinf_linear.mat
Kmu_linear.mat
linear_summary.json
linear_validation.mat
LQG_linear.mat
LQRI_linear.mat
lqri_ras.mat
lqri_ras_boundary.csv
lqri_ras_checkpoint.mat
lqri_ras_points.csv
lqri_ras_summary.json
manifest.json
unit_tests.csv
unit_tests.mat
unit_tests_initial_failure.csv
unit_tests_initial_failure.mat

Il commit finale è indicato nel messaggio di consegna della PR; git log -1 ne verifica l'identità.
