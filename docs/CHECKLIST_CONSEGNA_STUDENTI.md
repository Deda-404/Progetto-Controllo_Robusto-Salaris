# Checklist finale degli studenti

## Eseguito e verificato nel branch

- [x] Branch dedicato; main non modificato e nessun merge.
- [x] Otto SLX correnti dal Drive, ZIP/CRC valido e SHA-256 sorgente/importazione/post-verifica identici.
- [x] Audit di tutti gli otto modelli e inizializzazione esclusivamente esterna.
- [x] Quattro script finali eseguiti; 80 artifact fisici/controllori identici.
- [x] 141/141 test MATLAB passati.
- [x] Rumore isolato e fra campioni, con risultati negativi espliciti.
- [x] Lyapunov nello stato completo e griglia RAS comune di 150 punti, con esiti ignoti distinti.
- [x] Dieci piante incerte nuove più nominale; tracking, stabilità e disturbo.
- [x] Capitoli 9–11, appendici e slide coerenti; note orali 17:50.

## Sul computer con R2026a

- [ ] Aprire una copia di lavoro del branch; annotare release e toolbox. Non convertire gli originali e non disabilitare il controllo di release.
- [ ] Confrontare gli otto hash con `student_originals_manifest.json`.
- [ ] Dalla radice: `addpath('simulink'); validate_student_originals(true);`. Il setup esterno passa matrici e bus; i parametri interni restano quelli salvati dagli studenti.
- [ ] Esaminare output, warning, dimensioni, condizioni iniziali, selettori, rumori e coppia lato link. Un run eseguito non è ancora una prestazione validata.
- [ ] Verificare il logging del comando e risolvere nel tempo gli impulsi rapidi. Dichiarare seed, tempi e ingressi effettivi degli SLX: non confondere con le nuove prove MATLAB isolate.
- [ ] Accreditare solo i risultati davvero ottenuti dagli otto originali. Se emergono difetti interni, annotarli per revisione manuale; non applicare automaticamente vecchie istruzioni ad altri modelli.
- [ ] `export_student_schemes`: controllare leggibilità, sfondo ed etichette delle immagini reali. Inserire le figure significative nella relazione e attivare la slide condizionale LQGI.
- [ ] Ricontrollare gli otto SHA-256 dopo run ed esportazione, senza salvare modifiche interne.

## Prima di inviare al docente

- [ ] Completare matricole e data di consegna; non sono state inventate.
- [ ] Discutere rumore critico, target temporali non tutti rispettati e casi RAS numericamente ignoti. Non dichiarare i controllori pronti per l'hardware.
- [ ] Provare l'esposizione con cronometro: 21 slide, stima 17:50; con slide autentica opzionale 18:20. Massimo 20 minuti.
- [ ] Rigenerare macro/tabelle e compilare entrambi i PDF dopo l'inserimento delle figure; audit senza errori, riferimenti indefiniti o contenuti fuori pagina.
- [ ] Usare il manifest di consegna per i file correnti e le dipendenze. I tre report interni e i resoconti storici sono per la verifica del gruppo.
- [ ] Revisionare e integrare manualmente il branch su GitHub. Questo lavoro non esegue il merge.

Il progetto resta PARTIAL sulla validazione Simulink finché gli otto run e le figure autentiche richieste non sono controllati. La presenza dei PDF e il superamento dei test software non annullano i limiti prestazionali.
