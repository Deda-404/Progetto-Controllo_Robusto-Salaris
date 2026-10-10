# File MATLAB accorpati del progetto

Questa cartella raccoglie i quattro script didattici, con sezioni numerate,
formule commentate e risultati disponibili nel Workspace.

| File | Contenuto | Dipendenze |
| --- | --- | --- |
| `progetto_lqg.m` | LQR, Kalman, LQG, Lyapunov e RAS | Cartelle e dati del repository |
| `progetto_lqgi.m` | LQR con integratore e osservatore di Kalman | Cartelle e dati del repository |
| `progetto_hinf_tre_controllori.m` | H∞ 1 DoF, H∞ 2 DoF e migliore PID della campagna finale | `results/data/hinf_final_coherent/` e `support/` |
| `progetto_mu.m` | Modello incerto, µ-analisi, sintesi D-K e verifica H∞/Kµ | `results/data/hinf_final_coherent/` e `m4_uncertain_plant.mat` |

Aprire uno script nell'Editor MATLAB e premere **Run**. In alternativa, dalla
radice del repository, per esempio:

```matlab
run(fullfile('File_di_Funzioni_Progetto-Accorpati','progetto_mu.m'));
```

MATLAB R2025b, Control System Toolbox e Robust Control Toolbox sono gli ambienti
di riferimento. I quattro script inizializzano il Workspace: eseguirli uno alla
volta. Tutti individuano la radice del repository dal proprio percorso;
questa cartella deve quindi rimanere direttamente nella radice del progetto.
LQG conserva le esportazioni dei propri risultati già previste dal sorgente.

H∞ usa `ricalcolaSintesi=false` di default; impostarlo a `true` rilancia
`mixsyn`, `hinfsyn` e `hinfstruct`. µ usa `ricalcolaAnalisi=true` e
`ricalcolaSintesi=false`: analizza realmente i controllori archiviati; con
`ricalcolaSintesi=true` esegue una nuova `musyn` e la verifica successiva.
`mostraFigure=false` disabilita i grafici in entrambi gli script robusti.

LQG/LQGI coincidono con i sorgenti già in `analysis/` e restano invariati.
H∞/µ seguono tredici passi didattici; caricano le realizzazioni originali dai
MAT invece di riportarne i coefficienti. Il PID viene ricostruito con `pid2`
dai parametri salvati, per conservare esattamente la precedente realizzazione.
Le sole funzioni di supporto H∞ valutano gli avvii di nuova sintesi e leggono
i parametri PID; il procedimento matematico resta nei due script principali.

Occorre scaricare il repository completo, mantenendo questa cartella nella
radice, con `results/data/` e `support/`. I file necessari vengono verificati
prima dei calcoli; se manca un MAT, il messaggio ne indica il percorso.
Con µ e `ricalcolaAnalisi=false` si leggono solo i margini archiviati; i bounds
di `mussv` non vengono inventati né mostrati come ricalcolati.

La revisione è sul branch `codex/refactoring-didattico-hinf-mu`, senza merge
automatico. Test e provenienza: `docs/RESOCONTO_REFACTORING_DIDATTICO.md`.
