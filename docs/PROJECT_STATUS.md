# Stato del progetto — 2 ottobre 2026

Branch `codex/semplificazione-hinf-mu-appendice`, base `origin/main` 8ca8e7e.
La PR #33 risulta integrata nella base remota; le voci datate anteriori che
la indicano draft restano cronologia. Nessun merge automatico nella revisione corrente.

Revisione didattica: **COMPLETE / PASS**. Capitoli 8–9 riscritti con spiegazione
progressiva di H∞, Mo, pianta generalizzata, sintesi 1-/2-DoF e strutturata;
incertezze, Delta, N–Delta, µ, NS/NP/RS/RP, musyn e post-analisi.
Due nuovi schemi, tre tabelle dai dati salvati, appendice D con 27 estratti
letterali / 210 righe MATLAB. Capitoli 1–7 e presentazione conservati.
Relazione: 74 pagine, tre passaggi pdflatex, audit senza errori/riferimenti
irrisolti/overflow, revisione visiva completata. Presentazione: 19 slide, 17:15.

Ultima verifica: **20/20 test MATLAB PASS** su tre suite esistenti, sottoinsieme
dei 105/105 della revisione precedente. Controlli reali su mappe/norma/poli,
incertezze, identità dei controllori e campioni, due prove non lineari locali,
LFT, hash degli originali ed esiti negativi. Nessuna nuova sintesi, µ-analysis,
campagna Monte Carlo o ricerca RAS. Sorgenti e artifact scientifici invariati.

Esiti prestazionali consolidati:
- LQG: tracking nominale soddisfatto; LQRI: offset DC nullo, tracking lento.
- H∞: NS/NP PASS, RS FAIL, margine RP numericamente non validato e RP esclusa
  dal fallimento RS; Monte Carlo 0/40. Ordine 22, norma nominale 0.0474606.
- Kµ: NS/NP/RS/RP PASS nel modello incerto; target temporali parziali,
  Monte Carlo 40/40. Ordine 78, margini RS circa 1.80 e RP circa 1.68.
- RAS MATLAB robusti empirica; nessuna RAS accreditata agli originali LQG/LQRI.

Simulink: **PARTIAL**. Tre originali invariati in `simulink/originals`.
Tre caricamenti falliti per file R2026a su R2025b; zero simulazioni originali
validate. I difetti statici richiedono intervento manuale documentato nell'audit.
Modelli originali Kµ e lineare non disponibili. Nessun nuovo modello generato.

Conformità complessiva alla traccia: **PARTIAL** per Simulink e requisiti
prestazionali dichiarati. Attività ancora necessarie: compatibilità/completamento
manuale degli originali, relative validazioni e RAS, dati frontespizio,
prova orale cronometrata e revisione del branch corrente.

Resoconto: `docs/RESOCONTO_SEMPLIFICAZIONE_HINF_MU_APPENDICE.md`.
Evidenze correnti: `docs/didactic_review/`; audit precedenti conservati.
