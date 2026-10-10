# File MATLAB accorpati del progetto

Questa cartella raccoglie i quattro script didattici, con sezioni numerate,
formule commentate e risultati disponibili nel Workspace.

| File | Contenuto | Dipendenze |
| --- | --- | --- |
| `progetto_lqg.m` | LQR, Kalman, LQG, Lyapunov e RAS | Cartelle e dati del repository |
| `progetto_lqgi.m` | LQR con integratore e osservatore di Kalman | Cartelle e dati del repository |
| `progetto_hinf_tre_controllori.m` | H∞ 1 DoF, H∞ 2 DoF e migliore PID della campagna finale | File autonomo |
| `progetto_mu.m` | Modello incerto, µ-analisi, sintesi D-K e verifica H∞/Kµ | File autonomo |

Aprire uno script nell'Editor MATLAB e premere **Run**. In alternativa, dalla
radice del repository, per esempio:

```matlab
run(fullfile('File_di_Funzioni_Progetto-Accorpati','progetto_mu.m'));
```

MATLAB R2025b, Control System Toolbox e Robust Control Toolbox sono gli ambienti
di riferimento. I quattro script inizializzano il Workspace: eseguirli uno alla
volta. LQG e LQGI individuano la radice del repository dal proprio percorso;
questa cartella deve quindi rimanere direttamente nella radice del progetto.
LQG conserva le esportazioni dei propri risultati già previste dal sorgente.

H∞ usa `ricalcolaSintesi=false` di default; impostarlo a `true` rilancia
`mixsyn`, `hinfsyn` e `hinfstruct`. µ usa `ricalcolaAnalisi=true` e
`ricalcolaSintesi=false`: analizza realmente i controllori archiviati; con
`ricalcolaSintesi=true` esegue una nuova `musyn` e la verifica successiva.
`mostraFigure=false` disabilita i grafici in entrambi gli script robusti.

Sono copie integrali delle versioni consegnate: LQG/LQGI coincidono con i
sorgenti già in `analysis/`, H∞/µ sono le ultime versioni validate. Gli originali
LQG/LQGI sono conservati per mantenere i riferimenti esistenti. L'organizzazione
non modifica modelli, pesi, controllori, risultati o limiti scientifici.
Le verifiche di questa raccolta riguardano identità dei quattro file e
risoluzione dei percorsi; non costituiscono una nuova campagna numerica.

Il branch `codex/file-funzioni-progetto-accorpati` è proposto per revisione
prima di decidere il merge in `main` o ulteriori modifiche.
