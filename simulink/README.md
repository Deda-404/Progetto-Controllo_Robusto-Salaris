# Otto diagrammi Simulink

`student_originals/` contiene i modelli LQG, LQGI, H∞ e μ, ciascuno lineare e non lineare. `student_originals_manifest.json` conserva i SHA-256 originali. Tutti gli otto hanno superato **LOAD, COMPILE, SIMULATION e DYNAMIC VALIDATION PASS** in MATLAB/Simulink R2026b 26.2.0.3386108 su Windows. I file provengono da R2026a Update 4; nessuna conversione o modifica è stata applicata.

Gli orizzonti salvati sono 10 s, salvo LQG non lineare 4 s. Sono stati acquisiti riferimenti, quattro posizioni, misure encoder e due comandi per ramo. I tre rami H∞ sono attivi in parallelo. H∞ lineare seleziona le misure ideali, quello non lineare le misure rumorose; μ usa misure rumorose in entrambi i casi. I quattro encoder originali sono correlati per seed/configurazione. Queste condizioni restano quelle salvate.

```matlab
addpath('simulink','tools');
run_final_student_validation(false);
```

`setup_student_originals` fornisce esclusivamente matrici, bus e variabili esterne. `validate_student_originals(true)` compila ed esegue con SimulationInput, verifica porte, orizzonte, segnali finiti e hash, poi chiude senza salvare. `acquire_student_scope_buffers` legge i buffer visuali Scope senza attivare il logging; il decoder gestisce anche le porte vettoriali. L'API è interna e specifica di R2026b: se indisponibile, esportare gli Scope aperti dopo il run mediante Print to Figure; non cambiare selettori o parametri.

`analyze_student_scope_results` genera grafici e metriche dai campioni acquisiti. Picchi e RMS sono osservazioni sulla griglia del solver, non certificati continui o hardware. `export_student_schemes` produce otto viste generali autentiche e tre dettagli di sottosistemi senza salvare gli SLX. Il runner con `(false,true)` rielabora dati già registrati, ricontrollando gli hash; non conta come una nuova simulazione.

Risultati: `../results/data/final_simulink_validation/`. Schemi: `../report/figures/student_exports/`. Grafici: `../report/figures/final_simulink/`. Il collaudo dettagliato è in `../docs/REPORT_VERIFICA_SIMULINK.md` nel checkout integrale. Le altre cartelle Simulink del repository sono archivio e non appartengono alla consegna selezionata.

## Selezione esterna dei candidati con rumore

La baseline resta predefinita. `setup_student_originals('Hinf','noise_hinf3')` carica Ak2/Bk2/Ck2/Dk2 nuovi e `setup_student_originals('mu','noise_mu1')` il nuovo Kmu. Il runner richiede una cartella separata per i candidati, registra le matrici fornite e verifica i coefficienti prima/dopo il run. `analysis/noise_redesign/run_noise_simulink.m` esegue o verifica gli otto checkpoint abbinati nei sottofolder baseline/noise_hinf3/noise_mu1 di results/data/noise_redesign/simulink. Nessun parametro interno viene modificato; consultare il README dello studio per criteri e compromessi.
