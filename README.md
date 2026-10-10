# Controllo robusto di un manipolatore SEA

Modello planare a due giunti: 8 stati meccanici, 14 con attuatori. Confronto LQG/LQGI, H∞ 1-/2-DoF, sintesi strutturata e Kµ. Stato aggiornato al 6 ottobre 2026; questo repository è la fonte di verità.

## Documenti di consegna

- [Relazione](report/Progetto_CR_Relazione_finale.pdf): 83 pagine, sorgenti LaTeX in report/.
- [Presentazione](presentation/Progetto_CR_Presentazione.pdf): 19 slide, scaletta 17:45.
- [Note orali](presentation/SPEAKER_NOTES.md).
- [Resoconto in dieci punti e lista completa dei file](docs/RESOCONTO_REVISIONE_LQGI_HINF_MU.md).
- [Correzioni manuali Simulink](docs/CORREZIONI_SIMULINK_LQGI.md).
- [Stato, risultati e attività residue](docs/PROJECT_STATUS.md).

## Risultati e stato

**112/112 test MATLAB PASS**, sette nuovi controlli LQGI. Il servo usa `u=-Kx*xhat-Ki*xi`, `xi_dot=r-q_measured`; Kalman M6 e guadagni M7 invariati. Nuove prove lineari/non lineari, di rumore encoder/processo e RAS empirica LQGI: 57/57 punti convergenti nel box, senza saturazioni. Il tracking resta lento: 5.046 s nel confronto lineare M7.

Mo 2/3/4: tempi 2.918/1.944/1.460 s, norme 0.0305405/0.0312036/0.0474606. La scelta di 4 segue la minore violazione temporale, con compromessi su errore, comando e accoppiamento; non minimizza γ. Nessuno dei tre soddisfa 0.8 s.

H∞ 2-DoF: ordine 22, NS/NP PASS, RS FAIL. Intervallo RP invertito non validato; RP esclusa dal fallimento RS. Kµ: ordine 78, norma nominale 0.63468, margini RS circa 1.80 e RP circa 1.68 nel modello dichiarato; target temporali parziali. Controllori robusti, pesi e incertezze invariati, senza ripetere le sintesi.

**Simulink PARTIAL:** sei originali del gruppo conservati byte per byte, tre lineari e tre non lineari. Sei caricamenti falliti per R2026a su R2025b; nessuna simulazione degli originali validata. Audit statico e correzioni puntuali per integratore rumoroso, disturbo link, rumori e interfaccia H∞. Originale Kµ assente. I nomi SLX d'archivio restano provenienza, non versioni definitive LQGI.

## Esecuzione e rigenerazione

In MATLAB dalla radice:

```matlab
setenv('CR_RUN_SCOPE','verify'); run_all    % test senza nuova sintesi
setenv('CR_RUN_SCOPE','originals'); run_all % audit senza salvare gli SLX
setenv('CR_RUN_SCOPE','export'); run_all    % figure dai risultati correnti
```

Le suite che rigenerano internamente dati sono protette dal runner, che ripristina gli artifact iniziali. Test salvati in results/data/coherent_review/.

Per ricalcolare la campagna LQGI, dopo run_all che configura i path:

```matlab
validate_m7_lqg_integral; plot_lqgi_revision;
run_lqgi_validation; run_lqgi_ras;
export_hinf_readable_figures;
```

La RAS usa checkpoint identificati anche dall'hash del simulatore. Per tabelle, appendice, macro della presentazione e audit, dalla radice:

```text
python report/build_didactic_tables.py
python report/build_matlab_appendix.py
python presentation/build_review_values.py
python tools/audit_coherent_revision.py
```

`tools/build_m18_latex.ps1` compila e audita entrambi i PDF con i nomi di consegna; `-ReportOnly` compila la sola relazione. `tools/build_hinf_revision_report.py` è un generatore storico disabilitato nella CLI, per evitare di sovrascrivere i capitoli correnti con risultati di un problema precedente.

## Struttura e fonti

- src/, controllers/, analysis/, tests/: parametri, equazioni, controllori e verifiche.
- results/data/hinf_final_coherent/: fonte dei controllori robusti adottati.
- results/data/lqgi_validation/: traiettorie, rumore, metriche e RAS LQGI.
- results/data/coherent_review/: confronto Mo, test e audit dei sei originali.
- simulink/originals/: sei originali e manifest SHA-256.
- docs/coherent_review/: inventario iniziale, dipendenze, integrità e occorrenze classificate.
- report/, presentation/: sorgenti editabili e PDF.

MATLAB, Control System Toolbox e Robust Control Toolbox sono necessari alle analisi; Simulink ai diagrammi e ai tipi del setup. Alcuni test simbolici richiedono Symbolic Math Toolbox, già usato nel progetto. Nessuna nuova dipendenza.

Drive resta riferimento in sola lettura. Risultati robusti fuori dalla cartella adottata, vecchi manifest M18 e resoconti datati costituiscono cronologia. La PR #34 è integrata nella base 283193e; questa revisione usa `codex/revisione-lqgi-hinf-mu`, senza merge automatico su main.

## File MATLAB accorpati — 10 ottobre 2026

La cartella `File_di_Funzioni_Progetto-Accorpati/` raccoglie i quattro script
`progetto_lqg.m`, `progetto_lqgi.m`, `progetto_hinf_tre_controllori.m` e
`progetto_mu.m`. Il README della cartella descrive contenuti, dipendenze e
interruttori di analisi/sintesi. Aprire un file nell'Editor MATLAB e premere Run.

LQG/LQGI richiedono i dati e le funzioni del repository; H∞/µ sono autonomi.
La raccolta conserva integralmente i sorgenti consegnati e i percorsi originali
LQG/LQGI, con verifica SHA-256 e risoluzione dei dati dalla nuova posizione.
Branch di revisione: `codex/file-funzioni-progetto-accorpati`, basato su `main`
8e8de25. Il merge resta da decidere dopo la revisione del gruppo.

## Modelli Simulink dal Drive del progetto — 10 ottobre 2026

`simulink/drive_project/` contiene la copia completa della cartella Drive
condivisa: quattro nuove versioni LQG/LQGI lineari e non lineari, H∞ lineare,
e i 32 componenti della cartella H∞ non lineare estratta. Il README Simulink
chiarisce la distinzione fra file SLX e cartella; il manifest registra
provenienza, dimensioni e SHA-256. Gli originali preesistenti sono conservati.

Importazione e integrità statica COMPLETE / PASS, simulazioni NOT RUN.
I pacchetti sono R2026a Update 4; nessuna conversione o modifica. Branch
`codex/simulink-drive-aggiornamento`, basato su main a502609 con PR #36 integrata,
proposto per revisione prima del merge.
