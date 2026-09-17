# Revisione mirata H-infinity — resoconto per il merge

Branch: `codex/hinf-targeted-retuning`. Base: `cb325f6` (main, PR 30).
Responsabile: Alessio. Data: 17 settembre 2026.

La fattibilita nominale pesata e stata raggiunta. Il tracking 1-DoF rimane
non conforme: il lavoro non viene dichiarato un PASS globale.
Main non e modificato; merge riservato al gruppo.

## Parametri e risultati

| Voce | Baseline corrente | Revisione |
|---|---:|---:|
| omegaW1 [rad/s] | 8 | 2 |
| As | 0.15 | 0.20 |
| Ms | 2.5 | 4 |
| ku | 0.05 | 0.003 |
| omegaU [rad/s] | 60 | 80 |
| alpha | 6 | 6 |
| Lower bound | 1.044723362 | 0.257005195 |
| Frequenza del bound [rad/s] | 6.165950 | 24.926808 |
| gamma hinfsyn | 5.677221153 | 0.866035934 |
| gamma mixsyn nuovo | — | 0.866035934 |
| Ordine full-order | 18 | 18 |

Differenza relativa gamma mixsyn/hinfsyn: 6.42e-14.
Errore mappe pesate/LFT: 3.67e-13; errore P/augw: 3.02e-14.
Massima parte reale poli interni: -0.683828560.
Il lower bound storico 1.645 riguarda i pesi anteriori alla baseline corrente
(omegaW1=12, As=.05, Ms=2, ku=1/12, omegaU=30; gamma circa 10.207).

## Ricerca e motivazione dei rilassamenti

12 casi iniziali: quattro profili W1 e tre profili W2 accoppiati, non una
ricerca cartesiana esaustiva. ID 12 e scartato con LB>=1 prima dei solver.
Gli altri 11 hanno gamma>1; minimo 3.244811. Unica estensione: nove casi
con omegaW1={2,3,4}, As=.20, Ms=4, ku={.003,.005,.01}, omegaU=80.
Solo ID 13 raggiunge gamma<1. Sono state eseguite 20 coppie mixsyn/hinfsyn
nella campagna; una precedente sonda esplorativa su ID 1, senza modifiche
agli artifact, aveva gia verificato gamma 3.244811.

Poli instabili 4.04/7.21 rad/s, attuatore wn=40, modi elastici circa
69.95/79.40 rad/s, zero Pade RHP 133.33 rad/s: tutti invariati.
Il corner W1=2 riduce la richiesta di tracking, non impone una banda di
stabilizzazione inferiore al polo instabile. As=.20 rilassa la sensitivity
DC; Ms=4 consente un picco maggiore. ku=.003 lascia maggiore autorita
stabilizzante: il picco misurato arriva a 13.31 N m. omegaU=80 ritarda
la crescita del peso verso due volte wn, vicino ai modi elastici; questa
scelta non certifica robustezza ne protezione dalle risonanze.
Nessun limite hardware e dedotto da uScale=12. Nessuna scala della pianta
e cambiata e nessuna incertezza e ridotta.

I target rivisti sono fissati prima delle sintesi: settling<=2 s,
overshoot<=20%, errore statico<=20%, cross<=.25. M5 resta 0.8 s, 10%,
5%, cross preliminare .25. Il rilassamento non equivale a M5.

## Metriche temporali

Due gradini separati di 5 gradi; 12 s, passo 2 ms. Settling nella banda
del 2% dell'ampiezza richiesta intorno al valore finale DC; offset misurato
separatamente. Overshoot riferito al riferimento. Cross: picco giunto non
eccitato / picco giunto eccitato. Picco massimo sui due comandi; RMS
aggregato sui due attuatori e sull'intero orizzonte.

| Controllore | Giunto | Ts [s] | OS [%] | Errore [%] | Cross | Picco [N m] | RMS [N m] |
|---|---:|---:|---:|---:|---:|---:|---:|
| Baseline | 1 | 1.486 | 162.1 | 81.51 | 0.2447 | 5.994 | 1.204 |
| Baseline | 2 | 1.136 | 228.6 | 60.76 | 0.1811 | 1.582 | 0.4228 |
| hinfsyn | 1 | 1.456 | 113.1 | 17.14 | 0.185 | 13.31 | 1.004 |
| hinfsyn | 2 | 1.148 | 130.1 | 15.81 | 0.1726 | 3.973 | 0.3518 |
| 2DoF | 1 | 1.552 | 1.763 | 3.109e-13 | 0.0325 | 0.8432 | 0.5808 |
| 2DoF | 2 | 1.784 | 0.1906 | 1.776e-13 | 0.02932 | 0.2175 | 0.1994 |

Full-order 1-DoF: NS PASS; Hinf NP PASS; M5 temporal FAIL (Ts, overshoot,
offset); revised temporal FAIL (overshoot). Nessuna modifica a posteriori
delle metriche o soglie. Il PASS nominale non certifica RS/RP.

## Fixed-order

10 RandomStart oltre alla partenza nominale per famiglia, seed 20260917–20260922,
MaxIter=300. Tutti i 66 avvii sono salvati; nessun aumento del budget.

| Famiglia | Avvii stabili | Ordine | Objective | Norma verificata | Gap [%] | W1S | W2KS |
|---|---:|---:|---:|---:|---:|---:|---:|
| Statico MIMO | 0/11 | -- | -- | -- | -- | -- | -- |
| PI diagonale | 0/11 | -- | -- | -- | -- | -- | -- |
| PID filtrato | 8/11 | 4 | 4.506757 | 4.5067491 | 420.4 | 4.505 | 4.5 |
| MIMO ordine 2 | 10/11 | 2 | 1.8741186 | 1.8741007 | 116.4 | 1.874 | 1.851 |
| MIMO ordine 4 | 11/11 | 4 | 1.2980924 | 1.298088 | 49.89 | 1.298 | 1.272 |
| MIMO ordine 6 | 11/11 | 6 | 0.87931135 | 0.8792272 | 1.523 | 0.8783 | 0.8429 |

Il minimo ordine trovato e 6, non un minimo globale dimostrato.
Ordine 8 NOT RUN perche 6 e gia conforme. Tutti i rappresentanti stabili
restano FAIL sui target temporali originali e rivisti. Metriche complete
per famiglia in `results/data/hinf_targeted_revision/fixed_order.csv`;
per ogni singolo avvio, mappe e metriche per giunto nei MAT fixed_*.mat.

## Disturbo e 2-DoF

La verifica del disturbo usa BdFull M5: due gradini separati da 0.5 N m
lato link, senza disturbi artificiali di posizione. Picchi di posizione
0.0690/0.2430 rad e comando 1.046/1.162 N m. Non si inventa una soglia
di reiezione. La sintesi conserva lo stesso problema mixed sensitivity
per verificare mixsyn/hinfsyn; aggiungere ingressi pesati di disturbo
costituirebbe un diverso obiettivo. Mappe SGd verificate separatamente.

Estensione opzionale: Mo=(2/(s+2))^2 I, F=T(0)^(-1) Mo,
u=K(F r-y)=Kr r-Ky y, realizzazione condivisa di K (18+4=22 stati).
La frequenza deriva dal W1 selezionato; nessun numero dei colleghi copiato.
E un prefiltro didattico, non una sintesi Hinf 2-DoF ottima.
Stessa pianta, stessi pesi, ampiezza e metriche; disturbo invariato.
NS PASS; target temporali rivisti PASS; M5 FAIL sul settling.
La nuova norma di tracking e 1.381480>1 (FAIL); il feedback conserva
gamma=.866036, che non viene trasferito alla nuova mappa.

## File e riproducibilita

- `analysis/run_hinf_revision.m`: campagna full-order separata, checkpoint e selezione.
- `analysis/run_hinf_revision_fixed.m`: sei famiglie, 66 avvii e ordine 8 condizionale.
- `analysis/extend_hinf_revision_2dof.m`: estensione separata e verifiche.
- `analysis/export_hinf_revision.m`: CSV, JSON e dieci figure con assi neri.
- `controllers/hinf/hinf_revision_*.m`: configurazione, pesi, bound, P, valutazione e metriche.
- `tests/test_hinf_targeted_revision.m`: sette verifiche mirate.
- `results/data/hinf_targeted_revision/`: nuovi artifact completi e output dei test.
- `report/sections/08_hinf.tex`: unico capitolo aggiornato.
- `report/archive/hinf_before_retuning/08_hinf.tex`: testo precedente integrale.
- `report/generated/hinf_targeted_revision/`, `report/figures/hinf_targeted_revision/`: tabelle e figure nuove.
- `report/Progetto_CR_Relazione_finale.pdf`: relazione ricompilata, con il resto riferito alla baseline.
- `tools/build_hinf_revision_report.py`: genera tabelle, capitolo e questo resoconto dai dati.
- `tools/verify_hinf_revision.py`: controlla il perimetro rispetto a main, gli hash e il log LaTeX.
- README, CHANGELOG, PROJECT_STATUS, DECISION_LOG, DIARIO_DI_BORDO: annotazioni di ambito.

```matlab
addpath('analysis');
run_hinf_revision;
run_hinf_revision_fixed;
extend_hinf_revision_2dof;
export_hinf_revision;
assertSuccess(runtests('tests/test_hinf_targeted_revision.m'));
```

Con artifact presenti, le sintesi sono lette dai checkpoint verificati.
Per una riproduzione da zero usare un clone separato senza la sola directory
dei nuovi risultati; non cancellare le baseline. Non eseguire run_all:
la pipeline globale storica resta congelata e non adotta automaticamente
questi nuovi controllori.

Tabelle/test/figure derivano da MATLAB R2025b realmente eseguito.
Test mirati: 7/7 PASS; Code Analyzer: zero segnalazioni sui nuovi file MATLAB.
Gli esiti di performance FAIL restano distinti dai test di correttezza PASS.
Audit dei file congelati e compilazione PDF registrati in
`results/data/hinf_targeted_revision/verification.json`.

## Materiale e limite della revisione

La traccia SEA locale e stata letta integralmente. Il materiale del corso
`Es_MatlabSimulink_Salaris/MixSyn-Connect-lft/MixedSensitivity_SISO_1dof.m`
supporta la costruzione con connect/sumblk. Il riferimento dei colleghi
su Drive e stato consultato in sola lettura dopo la prima implementazione
indipendente; usa scelte e disturbi differenti, non trasferiti al progetto.
Riferimento: https://drive.google.com/file/d/1J8iR3OVwtfgoGvEJYXBkDfEc6TvHjl_W/view
API consultate: https://www.mathworks.com/help/robust/ref/dynamicsystem.mixsyn.html
e https://www.mathworks.com/help/robust/ref/dynamicsystem.hinfstruct.html

M9/M10/M11 storici, M0–M8, Capitoli 1–7, Capitolo 9 e successivi restano
inalterati nei sorgenti e nei dati. Il vecchio abstract e le conclusioni
generali sono anch'essi conservati: il nuovo Capitolo 8 esplicita che
descrivono la baseline. Nessun risultato robusto o RAS storico e attribuito
ai nuovi controllori. STOP prima di mu-analysis/mu-synthesis: la revisione
nominale e pronta per il controllo del gruppo, non per una dichiarazione
di completezza robusta del progetto.
