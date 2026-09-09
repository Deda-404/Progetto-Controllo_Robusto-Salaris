# Stato del progetto

**Fase corrente:** revisione tecnica del refactoring strutturale e didattico conclusa e validata.

**Ramo:** `codex/lyapunov-technical-coherence-review`

**Autori:** Alessio de Dato, Valerio Rebechi

**Ultimo aggiornamento:** 2026-09-09

## Decisioni vincolanti

- Esiste un unico insieme incerto M4; non sono presenti scenari alternativi.
- Specifiche e pesi M5, M6 LQG, M10 Khinf e M13 Kmu sono congelati.
- La ricerca LQR da 36 combinazioni è riprodotta senza cambiare candidati, score o selezione LQR30; non è un nuovo retuning.
- M16 è una valutazione Monte Carlo empirica e non sostituisce la μ-analysis M14.
- Gli esiti negativi rimangono risultati tecnici, non errori da occultare.
- La nuova analisi Lyapunov è nominale, aumentata e senza saturazione: non modifica la certificazione M14.

## Revisione corrente

I due script `analysis/progetto_lqg.m` e `analysis/progetto_hinf.m` espongono direttamente modello, scale, matrici e calcoli. Il primo distingue qs fisico e pesi adimensionali, sviluppa Q/R, CARE e Kalman, verifica separazione e simulazioni. Il secondo ricostruisce i pesi e la pianta generalizzata, ricarica Khinf e ne verifica norme, risposta e stabilità interna.

Le sigma Kalman sono ipotesi progettuali, non dati del docente. I tre stimatori sono confrontati con la stessa sequenza di rumore applicato. Il progetto nominale rimane invariato.

La nuova analisi Lyapunov include 28/32/66 stati per LQG/Khinf/Kmu. Il limite analitico del resto cubico produce regioni interne sufficienti con rho circa 6.0044e-9, 3.5414e-10, 2.9332e-11. Le regioni campionate più ampie non sono certificate. Sono salvate 48 traiettorie aggiuntive e le matrici complete.

## Esiti tecnici preservati

| Evidenza | Risultato |
| --- | --- |
| M6 nominale | 9/36 candidati ammissibili; LQR30; Ts peggiore 0.678 s |
| M7 integrale | PARTIAL: 0/3 conformi simultaneamente a settling e overshoot |
| M10 Khinf | ordine 18; gamma 10.2071 > 1 |
| M13 Kmu | ordine 52; controllore D–K storico congelato |
| M14 Kmu | RS [1.069561,1.212875] PASS_CERTIFIED; NP FAIL; RP FAIL_CERTIFIED |
| M16 | M6 38/40, Khinf 40/40, Kmu 40/40; Sample 5 e 6 M6 instabili |
| M17 | Kmu robusto finale; M6 riferimento nominale; Khinf comparatore |

Le regioni empiriche M8/M15 e le frazioni Monte Carlo non diventano certificati grazie alla nuova analisi nominale. Il valore rho dipende dalle coordinate interne e non classifica i controllori. uScale=12 N m non è una saturazione hardware.

## Verifica della revisione corrente

- Script didattici LQG e H-infinity: eseguiti, identità dei controllori verificata.
- Test mirati: 50/50 PASS.
- Lyapunov: tre modelli, verifica indipendente di 8192 punti ciascuno; 48 traiettorie.
- Figure documentali: rigenerate con sfondo bianco e testi/assi neri.
- Relazione: 63 pagine; presentazione: 19 slide, stima 19:00.
- Prima compilazione: una riga fuori margine; corretta. Audit successivo: PASS, zero errori/riferimenti irrisolti/overfull/destinazioni duplicate.
- Suite completa conclusiva: 644/644 PASS, 0 failed, 0 incomplete. Il tentativo intermedio con errore I/O PNG (631 PASS, 13 incomplete/failed) è conservato separatamente; la riesecuzione isolata è PASS.
- Code Analyzer: 172 file di progetto, 0 segnalazioni dopo correzione dei tre avvisi iniziali.
- Consegna M18 conclusiva: 60/60 PASS; 24 asset della relazione e 10 delle slide identici alle figure sorgenti per SHA-256; PDF ricompilati dopo la sincronizzazione, audit PASS.
- `git diff --check`: PASS. M5/Q/R/K/L M6 invariati rispetto alla baseline; artifact M10/M13/M14/M16 identici byte per byte.
- `run_all`: NOT RUN in questa revisione perché rilancerebbe le sintesi M9–M11. La suite usa gli artifact congelati.
- Nessuna nuova musyn, hinfsyn, mixsyn o hinfstruct; nessun retuning.

Gli esiti 599/599, run_all PASS e 47 pagine/17 slide appartengono alla revisione precedente, ora integrata nella PR 26: non sono la validazione della revisione corrente.

## Consegna e Git

Su richiesta del gruppo è stata avviata la pubblicazione del ramo di revisione.
Il primo push è stato rifiutato perché il MAT delle traiettorie pesa 260319104
byte. Il file viene quindi conservato integralmente con Git LFS, senza
ricalcolare i risultati. La pubblicazione riguarda il branch, non un merge su
main; le istruzioni di clone LFS sono nel README.

Baseline remota verificata: PR 26 integrata, main a ec93ddfe5e926f02c0373e7cee86236c3460f2eb. Il nuovo lavoro è separato sul ramo indicato e non modifica main direttamente.

Restano da completare le matricole e la data di consegna. Il resoconto dettagliato corrente è `docs/REVISIONE_TECNICA_LYAPUNOV.md`; la versione TXT ne facilita il trasferimento. Pubblicazione e revisione manuale non equivalgono a un merge automatico.
