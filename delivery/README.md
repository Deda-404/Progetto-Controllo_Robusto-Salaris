# Materiali di consegna e dipendenze

`manifest.json` seleziona gli elaborati correnti, gli otto SLX e le dipendenze di calcolo. Ogni riga indica percorso, ruolo e SHA-256. I file binari e gli SLX sono verificati byte per byte; per i testi si normalizza CRLF/LF per consentire checkout Windows/Linux. Il manifest non altera i file.

Al docente: i due PDF, i quattro script MATLAB e support/, gli otto `simulink/student_originals/`, i tre script di setup/validazione/esportazione e le dipendenze scientifiche selezionate. I risultati MAT permettono di verificare numeri e figure. Le fonti LaTeX e le immagini realmente referenziate sono elencate per una compilazione autonoma.

`source_dependencies.json` registra 30 dipendenze rilevate da MATLAB e i prodotti necessari. Il manifest aggiunge i path dinamici e le funzioni src/ richieste dalle funzioni embedded degli SLX: l’analizzatore statico non può risolverle tutte dal solo script. Non sono eliminati dal repository i dati scientifici necessari alle regressioni.

I tre documenti marcati `internal_group_review_only` sono per gli studenti, non costituiscono la relazione al docente. Diari, resoconti datati, vecchi SLX e la campagna precedente da 40 campioni sono esclusi dalla selezione ordinaria. Il file sorgente del Capitolo 11 conserva il nome tecnico esistente per non rompere i riferimenti delle regressioni, ma il suo contenuto è interamente la nuova verifica pratica di dieci impianti.

Per controllare la selezione dopo il checkout:

```text
python tools/build_delivery_manifest.py --check
```

Per rigenerarla dopo cambiamenti autorizzati a documenti/dati:

```text
python tools/build_delivery_manifest.py
```

Il run completo di 141 test richiede il checkout integrale GitHub e conserva dipendenze storiche. Per gli esperimenti conclusivi sono elencati i runner `run_final_noise_diagnostics`, `run_practical_robustness`, `run_final_ras_lyapunov`, summary e figure. Nessuno di questi tre runner riusa i quaranta campioni.

Stato della consegna: PARTIAL sulla validazione dinamica e sulle immagini degli otto originali, che richiedono R2026a. La checklist documenta i passi sul computer degli studenti. Rumore critico e target temporali falliti sono dichiarati nei PDF.
