# Stato del progetto — 23 settembre 2026

Branch codex/simulink-integration, PR #33 draft; nessun merge.
Completamento revisione COMPLETE: un modello Simulink lineare M3 comune,
32/32 nuovi confronti PASS, 15/15 nuovi test e 7/7 originari rieseguiti PASS.
I 67 controlli della precedente integrazione rimangono intatti e PASS;
non sono stati rilanciati. Quattro modelli non lineari e legacy invariati.
RAS LQRI nominale: 57/57, zero errori/estensioni, SEARCH-BOX LIMITED ±60°;
stesso protocollo LQG (identità guadagni storici verificata), non certificata.
Primo run: quattro FAIL nel test dimensionale, uso errato del singolo output
linmod; corretta solo la chiamata del test. Evidenza iniziale conservata.
Presentazione: 20 slide, scaletta 17:55, margine 2:05; PDF aggiornati.
Conformità complessiva PARTIAL: Hinf NS/NP PASS, RS FAIL, RP non accreditata,
M5 FAIL, Monte Carlo 0/40; Kmu NS/NP/RS/RP PASS, M5 FAIL, 40/40; M7 PARTIAL.
Nessun controllore o risultato robusto modificato, nessuna nuova sintesi.
Ambiente eseguito: R2025b Update 4. Restano non verificati replay R2026a,
hardware, saturazioni e code generation. Resoconto: RESOCONTO_PR33_COMPLETION.txt.
Riproduzione circoscritta: CR_RUN_SCOPE=simulink-completion.
TODO: revisione manuale PR draft; matricole/data definitiva e prova orale cronometrata.
