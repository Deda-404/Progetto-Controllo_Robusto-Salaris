# Controllo robusto di un manipolatore SEA a due giunti

Alessio de Dato e Valerio Rebechi. Revisione del 24 ottobre 2026, dopo il
ricevimento con il prof. Salaris. Il progetto confronta due rappresentazioni
delle incertezze degli attuatori: A dinamica concentrata e B parametrica.

LFT manuali della meccanica e dei due attuatori, residuo Padé separato,
sei schemi a blocchi e confronto con gli stessi controllori. Una variante
A diagonale distingue gli accoppiamenti dalla maggiorazione dell'inviluppo.
B è contenuto in A diagonale, contenuto in A pieno, per i pesi dichiarati.

**Modelli e collaudo COMPLETE/PASS: 39 test MATLAB R2026b e 17 file senza
segnalazioni Code Analyzer. Accettazione scientifica PARTIAL.** B raggiunge
RS/RP con limite di amplificazione rilassato a 3, ma restano target temporali
non soddisfatti; A non trova una soluzione robusta nella campagna limitata.
Nessun candidato sostituisce automaticamente la banca consolidata.

## Elaborati

- [Relazione PDF](report/Progetto_CR_Relazione_finale.pdf) e [sorgente](report/main.tex).
- [Presentazione PDF](presentation/Progetto_CR_Presentazione.pdf): 18 slide.
- [Copione](presentation/Presentazione_orale.txt) e [scaletta](presentation/OUTLINE_AND_TIMING.md):
  18:34 pianificati, con contenuti distribuiti fra i due studenti.
- [Resoconto della revisione](docs/RESOCONTO_REVISIONE_SALARIS.md), con risultati,
  esiti negativi, file modificati e attività da completare prima dell'adozione.
- [Audit iniziale](docs/AUDIT_REVISIONE_SALARIS.md) e [stato](docs/PROJECT_STATUS.md).

## Esecuzione

Dalla radice del repository, con MATLAB R2026b, Control System Toolbox e
Robust Control Toolbox; le regressioni simboliche usano Symbolic Math Toolbox:

```matlab
addpath(genpath('analysis'));
run_salaris_revision('models');
run_salaris_revision('analysis');
run_salaris_revision('synthesis');
run_salaris_revision('simulations');
run_salaris_revision('secondary');
salaris_final_checks;
```

Le fasi sono sequenziali; i dati sono in `results/data/salaris_revision/`.
Le sintesi riusano i checkpoint. Cambiare modello o specifiche richiede una
nuova cartella dei risultati. Lo scope `CR_RUN_SCOPE=salaris` di `run_all`
esegue le cinque fasi principali; il default `verify` conserva la regressione
storica. Per gli elaborati:

```text
python tools/build_salaris_documents.py
powershell -File tools/build_m18_latex.ps1
```

Dieci impianti parametrici comuni e dieci condizioni iniziali per controllore
sono esperimenti distinti. RAS, confronto LIN/NL e Kalman sono nuovi run MATLAB;
non sono nuovi collaudi Simulink dei candidati. I quattro script in
`File_di_Funzioni_Progetto-Accorpati/`, gli otto SLX e i controllori precedenti
restano conservati. Le vecchie sezioni e i risultati rimangono nel repository;
la precedente versione integrale è disponibile nella cronologia Git.

Il branch `codex/revisione-focus-incertezze-salaris` è dedicato alla revisione
degli studenti. Main non viene modificato. Drive rimane in sola lettura.

Revisione su GitHub: [PR #43 in bozza](https://github.com/Deda-404/Progetto_CR/pull/43).
