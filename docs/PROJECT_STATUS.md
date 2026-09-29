# Stato del progetto — 29 settembre 2026

Branch codex/simulink-integration; PR #33 draft, nessun merge.

Revisione teorica/documentale e inventario completati. Capitoli 1–7 analizzati prima degli interventi; formule, guadagni e parametri conservati. Correzione del refuso e del conteggio dei poli nel Capitolo 3. Capitoli 8–9 riscritti con pesi reali, LFT, struttura Delta, D/G–K e post-analisi.
Presentazione: 19 slide, 17:15.

MATLAB: 105/105 test PASS, inclusi 9 nuovi. Sette test del limite inferiore conservati.
Controllori, sintesi, dati robusti e risultati numerici consolidati invariati. Nessuna nuova sintesi, mu-analysis, Monte Carlo o ricerca RAS.
Due test preesistenti riscrivono MAT del modello attuato/specifiche: identità numerica verificata e byte iniziali ripristinati; il runner protegge ora i file.

Simulink: PARTIAL. Tre originali invariati in simulink/originals. Tre caricamenti falliti per file R2026a su R2025b; zero simulazioni originali eseguite. I difetti statici richiedono intervento manuale, dettagliato nell'audit. Modelli originali Kmu e lineare non disponibili.

Esiti prestazionali:
- LQG: tracking nominale soddisfatto; LQRI: offset DC nullo, tracking lento.
- Hinf: NS/NP PASS, RS FAIL, RP numericamente non validata ed esclusa da RS, Monte Carlo 0/40.
- Kmu: NS/NP/RS/RP PASS nel modello incerto; target temporali parziali, Monte Carlo 40/40.
- RAS MATLAB robusti empirica; nessuna RAS accreditata agli originali LQG/LQRI.

Conformità complessiva alla traccia: PARTIAL per Simulink e requisiti prestazionali dichiarati.
Attività manuali: compatibilità/completamento degli originali, relative validazioni e RAS, dati frontespizio, prova orale cronometrata e revisione PR.
