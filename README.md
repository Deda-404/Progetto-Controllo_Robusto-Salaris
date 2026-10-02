# Controllo robusto di un manipolatore SEA

Progetto di Controllo Robusto: modello planare a due giunti, 8 stati meccanici e 14 stati con attuatori. Confronto LQG/LQRI, H∞ 1-DoF e 2-DoF, sintesi strutturata e Kµ.

## Documenti di consegna

- [Relazione](report/Progetto_CR_Relazione_finale.pdf), sorgenti in report/.
- [Presentazione](presentation/Progetto_CR_Presentazione.pdf): 19 slide, scaletta 17:15.
- [Note orali](presentation/SPEAKER_NOTES.md).
- [Audit, inventario e limiti](docs/organic_review/AUDIT.md).
- [Resoconto della revisione](docs/RESOCONTO_REVISIONE_ORGANICA.txt).
- [Revisione didattica H∞/µ e appendice MATLAB](docs/RESOCONTO_SEMPLIFICAZIONE_HINF_MU_APPENDICE.md): relazione di 74 pagine; capitoli 8–9 e appendice D aggiornati il 2 ottobre 2026.

## Risultati e stato

105 test MATLAB PASS. H∞ 2-DoF: ordine 22, norma 0.0474606, NS/NP positive ma RS negativa. L'intervallo numerico RP è non valido; RP è comunque esclusa dal fallimento RS.
Nella revisione editoriale del 2 ottobre sono stati rieseguiti 20 test esistenti: 20/20 PASS, sottoinsieme della precedente verifica globale, senza nuove sintesi o campagne robuste.
Kµ: ordine 78, norma nominale 0.63468, margini RS circa 1.80 e RP circa 1.68 sul modello dichiarato. Restano fallimenti temporali.
LQG soddisfa il tracking nominale; LQRI elimina l'offset DC del disturbo costante nel modello lineare, con risposta più lenta.

La parte Simulink è **PARTIAL**. Sono consegnati soltanto i tre originali del gruppo, invariati: LQR/LQG, LQRI e Hinf. Sono R2026a e il caricamento è bloccato in R2025b. L'audit statico segnala collegamenti da completare manualmente; mancano gli originali Kµ e plant linearizzato. Nessuna simulazione degli originali è dichiarata validata.

## Esecuzione sicura delle verifiche

In MATLAB dalla radice:
```matlab
setenv('CR_RUN_SCOPE','verify'); run_all
```
Esegue i test pertinenti senza sintesi, mu-analysis o Monte Carlo. Le suite preesistenti di attuatori/specifiche rigenerano internamente dati: run_all conserva e ripristina gli artifact iniziali.

Altri ambiti:
```matlab
setenv('CR_RUN_SCOPE','originals'); run_all % audit senza salvare gli SLX
setenv('CR_RUN_SCOPE','export'); run_all    % figure dai dati salvati
```
Per compilare i PDF, eseguire `latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex` separatamente da report/ e presentation/.
Per rigenerare le nuove tabelle e l'appendice letterale, eseguire dalla radice
`python report/build_didactic_tables.py` e `python report/build_matlab_appendix.py`.
Il comando `tools/build_m18_latex.ps1 -ReportOnly` compila e audita la sola relazione.

## Struttura e fonti

- src/: meccanica, parametri, attuatori, incertezze.
- controllers/: sintesi e interconnessioni.
- analysis/: validatori, calcoli MATLAB, esportazione.
- tests/: verifiche matematiche e di coerenza.
- results/data/hinf_final_coherent/: **fonte dei controllori robusti adottati**.
- simulink/originals/: tre file originali e manifest SHA-256.
- docs/organic_review/: inventario, backup, identità degli artifact e audit.
- report/, presentation/: sorgenti e PDF.

MATLAB, Control System Toolbox e Robust Control Toolbox sono necessari alle analisi. Simulink serve per i diagrammi e il setup dei relativi tipi; alcuni test del modello simbolico richiedono Symbolic Math Toolbox, già usato dal progetto. Non sono state introdotte nuove dipendenze.

Gli studi didattici e i dataset robusti fuori dalla cartella adottata descrivono problemi separati: non usarli come fonte dei risultati dei capitoli 8–13. Il diario, il decision log, il changelog e i resoconti datati documentano la cronologia; la descrizione tecnica della consegna è nei PDF e nell'audit corrente.

La PR #33 è già integrata nella base remota 8ca8e7e. La revisione del 2 ottobre
usa `codex/semplificazione-hinf-mu-appendice`, senza merge automatico su main.
