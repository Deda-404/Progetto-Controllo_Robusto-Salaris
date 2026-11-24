# Controllo robusto di un manipolatore SEA a due giunti

Alessio de Dato (635256) e Valerio Rebechi (722224). Corso di Controllo Robusto, professor Salaris, Traccia n. 2. Elaborato finale del **01.12.2026**.

Il progetto modella un manipolatore planare 2R con attuatori elastici in serie (SEA) e drive del secondo ordine con ritardo (Padé), descrive le incertezze in due modi (A parametrica, B concentrata additiva) e confronta controllori LQG/LQGI, H∞ (mixsyn, hinfsyn, hinfstruct) e µ-synthesis con analisi NS, NP, RS e RP.

## Dove guardare

| Cartella | Contenuto |
|---|---|
| [`File_di_Funzioni_Progetto-Accorpati/`](File_di_Funzioni_Progetto-Accorpati) | **Consegna autonoma**: codice MATLAB, 8 modelli Simulink, dati, risultati, test, relazione e presentazione. Il suo [README](File_di_Funzioni_Progetto-Accorpati/README.md) è l'indice operativo. |
| `report/` | Sorgenti LaTeX della relazione (13 capitoli + appendici). |
| `presentation/` | Sorgenti LaTeX delle 23 slide, tempi dell'esposizione. |
| `tools/` | `esporta_definitiva.py` (tabelle LaTeX dai CSV), `consegna_definitiva.py` (ZIP e manifest SHA-256). |
| `docs/` | Diario di bordo, registro delle decisioni, stato del progetto, analisi della traccia. |
| `Es_MatlabSimulink_Salaris/` | Esercitazioni del corso, solo riferimento. |

## Esecuzione

```matlab
cd File_di_Funzioni_Progetto-Accorpati
run_all              % rapida: ricalcola il percorso leggero, carica le sintesi onerose validate
run_all('completa')  % rigenera sintesi, mu-analysis, simulazioni, RAS e collaudi Simulink
```

Servono Control System Toolbox, Robust Control Toolbox e, per gli SLX, Simulink. Le release effettivamente usate e le verifiche eseguite sono riportate nel README della cartella di consegna.

## Compilazione degli elaborati

```bash
cd report && latexmk -pdf main.tex          # relazione
cd presentation && latexmk -pdf main.tex    # slide (usa ../report per figure e schemi)
python tools/consegna_definitiva.py         # delivery/Progetto_Controllo_Robusto_SEA_01-12-2026.zip
```

I PDF e il PowerPoint definitivi sono in `File_di_Funzioni_Progetto-Accorpati/elaborati/`. Le versioni precedenti del codice, dei risultati e della documentazione intermedia restano consultabili nella cronologia Git.
