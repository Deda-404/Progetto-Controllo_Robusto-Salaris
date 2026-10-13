# Consegna del progetto SEA

Alessio de Dato, matricola 635256; Valerio Rebechi, matricola 722224. Data: 13.10.2026.

Gli elaborati sono `report/Progetto_CR_Relazione_finale.pdf` (100 pagine) e `presentation/Progetto_CR_Presentazione.pdf` (22 slide). Le note orali suddividono l'esposizione tra i due autori, con stima 18:45 da confermare mediante prova cronometrata.

La cartella e lo ZIP `Consegna_SEA_2026-10-13` contengono i PDF, le fonti LaTeX, le figure, i quattro script MATLAB, le funzioni necessarie, i dataset scientifici e gli otto originali Simulink. Sono esclusi cronologie, documenti interni, cache, log di debug e test intermedi. Il file `MANIFEST_CONSEGNA.json` del pacchetto verifica ogni file copiato mediante SHA-256 esatto; `delivery/manifest.json` nel repository registra anche i ruoli e la normalizzazione LF dei testi per checkout portabili.

## Esecuzione MATLAB/Simulink

Collaudo svolto in MATLAB/Simulink **R2026b 26.2.0.3386108**, Windows, con Control System, Robust Control e Symbolic Math Toolbox 26.2. Sono riusciti quattro script, 141 regressioni e otto simulazioni, con originali invariati. Dal MATLAB aperto nella radice del pacchetto:

```matlab
addpath('tools','simulink');
run_final_student_validation(false);       % esegue gli otto diagrammi e valuta gli Scope
run_final_student_validation(false,true);  % verifica e rielabora i dati inclusi senza nuovi run
```

I quattro script in `File_di_Funzioni_Progetto-Accorpati/` possono essere eseguiti singolarmente dall'Editor. `support/` e i dataset inclusi sono necessari ai default. Il runner completo senza argomenti esegue anche le 141 regressioni e richiede il checkout integrale GitHub, con Git LFS per i dati Scope. Il pacchetto ordinario riproduce i diagrammi e gli esperimenti selezionati senza i test intermedi.

Il setup fornisce matrici e bus dall'esterno; solver, selettori, rumori, sample time e logging SLX restano invariati. Gli otto SHA-256 devono coincidere con `simulink/student_originals_manifest.json` prima e dopo. Il lettore dei buffer visuali Scope usa una API interna R2026b: in altre release, se indisponibile, esportare gli Scope dopo l'esecuzione tramite Print to Figure senza modificare il modello. Il runner segnala errore se l'acquisizione obbligatoria è incompleta.

## Elaborati e dati

Le fonti LaTeX conservano le immagini effettivamente utilizzate. Per ricompilare con una distribuzione TeX, latexmk e Poppler disponibili:

```text
python tools/build_final_simulink_tables.py
python report/build_matlab_appendix.py
powershell -File tools/build_m18_latex.ps1
```

I MAT finali conservano controllori, campioni degli impianti incerti, dati Scope e prove di rumore/RAS. `delivery/source_dependencies.json` registra le dipendenze rilevate da MATLAB; il manifest integra i path dinamici e le funzioni embedded. L'inventario può essere verificato nel repository con `python tools/build_delivery_manifest.py --check`. Il pacchetto ha un manifest proprio perché sostituisce il README del repository con queste istruzioni e non include documentazione interna.

Il collaudo riuscito non elimina i target temporali falliti o il limite sul rumore. H∞ 2-DoF non lineare registra circa 733230 N m, μ circa 108/109 N m. Picchi Scope e RMS da quadratura non certificano valori continui; non sono prove hardware. H∞ lineare usa misure ideali, quello non lineare rumorose. Gli encoder SLX sono correlati e il protocollo differisce dalla prova MATLAB isolata. Le garanzie μ valgono per il modello dichiarato; RAS empirica, arresti numerici e certificati Lyapunov restano distinti.
