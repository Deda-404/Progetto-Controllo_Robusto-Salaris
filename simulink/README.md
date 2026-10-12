# Otto modelli Simulink studenti, immutabili

La fonte corrente è `student_originals/`: LQG, LQGI, H∞ e µ, ciascuno lineare e non lineare. Sono gli otto pacchetti scaricati dal Drive il 12 ottobre 2026, non diagrammi ricostruiti. `student_originals_manifest.json` registra ID Drive, data, dimensioni e tre SHA-256 identici per ciascun file.

Tutti richiedono R2026a Update 4. Otto tentativi di caricamento con R2025b Update 4 sono falliti per release; nessuna simulazione originale è validata. Non disabilitare il controllo di release e non esportare o convertire gli SLX.

`setup_student_originals(kind)` prepara esclusivamente variabili MATLAB e il bus già richiesto. `validate_student_originals(false)` carica in sola lettura, chiude senza salvare e verifica gli hash. In R2026a, `validate_student_originals(true)` usa SimulationInput e gli stessi parametri interni; gli output salvati devono essere esaminati. `export_student_schemes` prepara schermate reali nella release corretta senza salvataggi dei modelli.

La verifica dettagliata è in `../docs/REPORT_VERIFICA_SIMULINK.md`; l’inventario completo ZIP/XML in `../docs/INVENTARIO_XML_SIMULINK.md`. Le miniature originali sono conservate come materiale di audit: non sono leggibili alla scala della relazione.

`originals/` (sei file) e `drive_project/` (importazione del 10 ottobre, inclusa una cartella estratta) sono archivio conservato. Non applicare agli otto file correnti i vecchi suggerimenti di modificare l’integratore o l’interfaccia H∞. L’audit corrente mostra già l’errore LQGI misurato, il 2-DoF a quattro ingressi e i modelli µ presenti.
