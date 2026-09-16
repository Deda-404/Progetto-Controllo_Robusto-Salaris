# Stato del progetto

## Revisione corrente — pesi H-infinity, LQR e LQRI (16 settembre 2026)

Branch `codex/direct-weights-hinf-lqr-lqri`, baseline
`aae96148353506b8ba119de65f6dcf3103eec328` (PR 29).
M0–M4, target M5 e soglie di selezione sono invariati.

- M6: nuova griglia R={0.01,0.05,0.10} I2, 9/36 ammissibili;
  selezionato LQR30 con R=0.10 I2. Q/L/Qn/Rn preservati, K/Nr ricalcolati.
- M7: Qi={20,200,800} I2; 3/3 stabili, 0/3 conformi. Punto illustrativo
  200, Ts=5.046 s. Test mirati M6/M7: 36/36 PASS.
- H-infinity: 8 casi Stage A e 4 Stage B, nessun PASS. W1=(s/2.5+8)/(s+1.2),
  W2=0.05(s/60+1)/(s/360+1), entrambi moltiplicati per I2.
  W3 fisso soltanto nello studio; M9/M10 restano a due pesi.
- M9/M10: gamma=5.677221; M11: 30 avvii, 15 stabili, A5=5.708569.
- M13: una sola nuova sintesi dipendente dai pesi, 5 iterazioni,
  Kmu di ordine 70. M14: NS PASS, NP FAIL, RS/RP FAIL_CERTIFIED;
  margine RS [0.774041952377,0.775696806012].
  Nessun controllore robusto finale può essere assegnato con il criterio vigente.
- M8 rigenerata e verificata. M15 completata: il tetto storico di
  400 simulazioni RAS è risultato insufficiente. Il limite calcolato dalla
  griglia/bisezione/estensione esistenti è 626 per controllore; criteri e
  precisione invariati. Checkpoint numerici impediscono ripetizioni inutili.
- M15 resta PARTIAL per tracking: Khinf Ts=1.482747 s; Kmu non si assesta
  entro 4 s. RAS empiriche: raggio minimo 44.895 e 60 gradi, rispettivamente.
- M16: M6 37/40 stabili (instabili 5,6,35), Khinf e Kmu 40/40.
  Core tracking sul totale: 57.5%, 0%, 0%. Non è una certificazione.
- M17: nessun robusto finale; M6 riferimento nominale, Khinf comparatore.
  Lyapunov e 48 traiettorie rigenerati per chiusure di ordine 28/32/84.
- Unica suite globale: 658/660 PASS, zero incomplete. Due aspettative
  obsolete (avvio A5 e ID instabili M6) corrette senza cambiare soglie:
  riesecuzione dei soli due test, 2/2 PASS. Gli esiti iniziali sono conservati.
- Code Analyzer: 177 file, zero segnalazioni. Audit LaTeX PASS:
  relazione 70 pagine, presentazione 19 slide; controllo visivo concluso.
- Consegna su branch dedicato e PR aperta verso main; nessun merge automatico.
  Stato pre-pubblicazione e resoconto: RESOCONTO_REVISIONE_PESI_HINF_LQR_LQRI.txt.

## Archivio delle revisioni precedenti — non descrive la configurazione corrente

**Fase corrente:** revisione LQRI e parametrizzazione diretta di R completata e verificata; pubblicazione su branch dedicato per revisione manuale. M7 resta PARTIAL sul requisito prestazionale.

**Ramo:** `codex/lqri-direct-r-review`

**Autori:** Alessio de Dato, Valerio Rebechi

**Ultimo aggiornamento:** 2026-09-14

## Revisione LQRI/R corrente

- M7 usa `u=-Kx*xhat-Ki*xi`, `xi_dot=r-q_measured`, Kalman M6 invariato.
- 14 stati fisici, 14 stimati, 2 integratori: chiusura reale di ordine 30.
- Q M6 riutilizzata; R diretta con griglia equivalente `ru={1/36,1/18,1/9}`.
- Tre prove wi={0.1,1,4} a Q/R fissi; punto illustrativo wi=1, R=(1/9)I2.
- Tutti i 30 poli stabili; parte reale dominante del punto wi=1: -0.830657 s^-1.
- M7 resta PARTIAL: settling 4.996 s, contro target 0.8 s; reiezione DC verificata.
- H-infinity, M8-M17 e presentazione non sono oggetto della revisione.
- I sorgenti LaTeX correnti sono preservati fuori dai passaggi strettamente coinvolti.
- Verifica corrente: `run_all` con `CR_RUN_SCOPE=lqri`; esiti registrati
  separatamente in `lqri_r_verification.mat/.csv`, senza attribuire i PASS storici.
- Esito: 106/106 PASS, zero failed/incomplete; 15.62176 s per i test.
- Entry point `analysis/progetto_lqri.m`: PASS; Code Analyzer su 172 file:
  zero segnalazioni. Nessuna nuova esecuzione globale M0-M18.
- Relazione: 72 pagine, audit LaTeX PASS, zero errori, riferimenti irrisolti,
  overfull e destinazioni duplicate; controllo visivo completato.
- Confronto con la baseline iniziale: differenze massime di K/Q/R M6 nulle;
  L/Qn/Rn identici. Risultati H-infinity, mu, Monte Carlo e presentazione invariati.
- Resoconto autosufficiente: `docs/RESOCONTO_REVISIONE_LQRI_R.txt`.
- Destinazione: PR aperta verso main; nessun merge automatico.

## Revisione storica del 10 settembre (M7 superata dalla revisione LQRI)

- Baseline: origin/main dopo PR 27, working tree inizialmente pulito.
  Le ulteriori modifiche manuali di Valerio non sono ancora pubblicate:
  verranno integrate quando disponibili; nessuna ricostruzione presunta.
- §7.1–7.5 preservate testualmente; §7.6 LQI estesa localmente.
  Confronto con stato vero, 16 stati, wi=1 e rhoU=8: offset DC LQI nullo,
  residuo massimo a 8 s 8.732e-5 rad. Nessuna nuova selezione finale M7.
- H-infinity: 13 candidati deterministici e 2 sintesi diagnostiche;
  gamma minimo 2.8056. ID 10 illustrativo: gamma 4.0730, overshoot
  144.44%, peak control 15.686 N m; non conforme e non adottato.
- Cinque campioni M4 comuni: ID 10 stabile in 2/5, baseline in 5/5.
  È un controllo empirico aggiuntivo, non la campagna M16.
- M5, M6 e M9–M16 restano la baseline; nessuna nuova musyn.
  W1/W2/W3 rivisti esistono esclusivamente nel nuovo studio.
- Verifica mirata M7: 7/7 PASS; suite globale eseguita una sola volta in
  copia isolata: 644/644 PASS, 0 failed/incomplete, 279.107 s.
- Code Analyzer: 172 file di progetto, zero segnalazioni.
- Relazione: 71 pagine; audit PASS, zero errori/overfull/riferimenti
  irrisolti. Controllate tutte le pagine; conservati gli spazi ereditati
  nelle sezioni protette, senza alterare margini o font globali.
- Presentazione non aggiornata. La successiva richiesta del gruppo autorizza
  commit, push di `codex/lqi-hinf-targeted-review` e PR verso `main`;
  nessun merge automatico e nessuna modifica diretta a `main`.
- Resoconto: `docs/REVISIONE_MIRATA_LQI_HINF.md`; esiti per test in
  `results/data/lqi_hinf_revision_verification.mat/.csv`.

Le sezioni seguenti conservano il contesto della revisione Lyapunov già
conclusa: i relativi conteggi di test/PDF e l'assenza di nuove sintesi
descrivono quella revisione, non la campagna mirata del 10 settembre.

## Decisioni vincolanti

- Esiste un unico insieme incerto M4; non sono presenti scenari alternativi.
- Specifiche e pesi M5, M6 LQG, M10 Khinf e M13 Kmu sono congelati.
- La ricerca LQR da 36 combinazioni è riprodotta senza cambiare candidati, score o selezione LQR30; non è un nuovo retuning.
- M16 è una valutazione Monte Carlo empirica e non sostituisce la μ-analysis M14.
- Gli esiti negativi rimangono risultati tecnici, non errori da occultare.
- La nuova analisi Lyapunov è nominale, aumentata e senza saturazione: non modifica la certificazione M14.

## Revisione Lyapunov precedente

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

## Verifica della revisione Lyapunov precedente

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
