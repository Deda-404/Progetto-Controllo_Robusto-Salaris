# Controllo robusto di un manipolatore SEA a due giunti

Revisione scientifica del 12 ottobre 2026. **141/141 test MATLAB PASS.** Branch `codex/chiusura-definitiva-progetto-sea`, base main `fa78e588`. Il branch è preparato per revisione e integrazione manuale; nessun merge automatico.

## Elaborati e verifica

- [Relazione PDF](report/Progetto_CR_Relazione_finale.pdf), fonti LaTeX in `report/`.
- [Presentazione PDF](presentation/Progetto_CR_Presentazione.pdf): 21 slide, stima 17:50.
- [Note orali](presentation/SPEAKER_NOTES.md) e [tempi](presentation/OUTLINE_AND_TIMING.md).
- [Chiusura e giudizio di consegna](docs/CHIUSURA_FINALE_PROGETTO.md).
- [Verifica degli otto Simulink](docs/REPORT_VERIFICA_SIMULINK.md).
- [Diagnosi del rumore](docs/ANALISI_RUMORE_MISURA.md).
- [Checklist studenti](docs/CHECKLIST_CONSEGNA_STUDENTI.md).
- [Manifest di consegna](delivery/manifest.json).

Il modello ha 8 stati meccanici e 14 con attuatori. Sono conservati LQG (14 stati), LQGI (16), H∞ 1-DoF (18), H∞ 2-DoF (22), PID (4) e Kµ (78), senza riduzioni o nuova sintesi. I quattro script finali sono in `File_di_Funzioni_Progetto-Accorpati/`; il loro default è stato eseguito e verificato.

La nuova campagna del Capitolo 11 usa **dieci impianti incerti nuovi e comuni più il nominale**, seed 20261012: H∞ 2-DoF 0/10 stabili, Kµ 10/10. Entrambi stabilizzano il nominale. Tracking e disturbi sono accreditati solo nelle chiusure stabili. Il campione non è una probabilità né un certificato.

**Il rumore resta critico.** Con encoder σ=0.05 gradi e ZOH di 2 ms, riferimento/disturbo/processo nulli, i picchi osservati fra campioni sono circa 4.93×10^5 N m per H∞ 2-DoF e 87.1 N m per Kµ; RMS integrati circa 1.32×10^4 e 8.29 N m. La sola registrazione a 2 ms perde impulsi rapidi. Sono richieste del modello senza saturazioni; nessuna attenuazione è stata introdotta per nascondere il risultato.

La RAS usa lo stato aumentato completo e una griglia comune di 25 punti per ciascuno dei sei controllori. I risultati empirici, gli arresti numerici e gli insiemi interni Lyapunov sono distinti nel Capitolo 10 e nei dati. Il dominio ±60 gradi non è il confine della RAS; le prove non includono limiti hardware.

**Simulink PARTIAL / simulazioni NOT RUN:** tutti gli otto originali studenti sono in `simulink/student_originals/`, con SHA-256 sorgente/importazione/dopo verifica identici. Sono R2026a Update 4 e il caricamento è rifiutato in R2025b Update 4. Audit XML e setup esterno sono disponibili; mancano run e schermate autentiche nella release corretta. MATLAB non sostituisce questa verifica.

## Esecuzione

Dalla radice in MATLAB, con Control System, Robust Control e Symbolic Math Toolbox:

```matlab
setenv('CR_RUN_SCOPE','verify'); run_all          % test, nessuna nuova sintesi
setenv('CR_RUN_SCOPE','originals'); run_all       % sola lettura degli SLX
setenv('CR_RUN_SCOPE','closure_export'); run_all  % figure dai dati conclusivi
setenv('CR_RUN_SCOPE','closure'); run_all         % nuovi esperimenti e RAS
addpath('tools'); verify_four_final_scripts      % quattro default e hash protetti
```

Le suite storiche sono conservate come regressioni; il runner ripristina i dati che rigenera durante i test. La nuova campagna non carica o riusa i vecchi 40 campioni. La RAS può richiedere diversi minuti e distingue il limite del solver dalla mancata convergenza fisica.

Tabelle, listati e PDF:

```text
python tools/build_final_closure_tables.py
python report/build_matlab_appendix.py
powershell -File tools/build_m18_latex.ps1
```

Per la validazione su R2026a, senza cambiare gli originali:

```matlab
addpath('simulink');
validate_student_originals(true);
export_student_schemes;
```

Il setup passa matrici e bus con `Simulink.SimulationInput.setVariable`; mantiene solver, collegamenti, rumori e selettori interni. Esaminare gli output prima di attribuire metriche validate agli SLX. Non convertire i modelli e non disabilitare il controllo di release.

## Fonti e cartelle

`results/data/hinf_final_coherent/` conserva i controllori robusti e i loro margini. `results/data/final_closure/` contiene la diagnosi del rumore, i dieci impianti campionati, la RAS e gli audit correnti; MAT, CSV e JSON rendono verificabili le figure. `src/`, `controllers/`, `analysis/` e `tests/` contengono le dipendenze scientifiche.

Drive è stato consultato in sola lettura. `simulink/originals/`, `simulink/drive_project/` e resoconti datati restano archivio; per la consegna degli otto file usare esclusivamente `student_originals/` e il suo manifest. Le vecchie istruzioni di correzione dei modelli non si applicano automaticamente ai file correnti.

La consegna non è ancora verificata integralmente: occorrono R2026a per i run e le immagini degli originali, matricole/data e prova orale cronometrata. Rumore, target temporali falliti e limiti numerici sono risultati da discutere, non gate software da dichiarare superati.
