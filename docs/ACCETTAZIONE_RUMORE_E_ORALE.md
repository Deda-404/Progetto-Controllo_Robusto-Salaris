# Accettazione della sintesi con rumore e degli elaborati

La baseline resta predefinita. HinfN3 è respinto come soluzione robusta; MuN1 è una proposta verificata, con target temporali parziali e offset q1 peggiore. L'adozione finale e il merge spettano agli studenti.

| Requisito | Risultato | Evidenza |
|---|---|---|
| Nuova sintesi H∞ | PARTIAL; tre nominali stabili, RS/RP FAIL | `hinf_noise_01/02/03.mat`, relativi audit |
| Nuova sintesi μ | PASS sintesi/NS/NP/RS/RP; proposta separata | `mu_noise_01.mat`, ordine 82, obiettivo 0.874392 |
| Riduzione picco comando | H∞ NL 733230.334→1.768299 N m; μ NL 108.526404→2.250912, 48.2144 volte | Scope abbinati, protocollo originale combinato |
| Riduzione RMS comando | H∞ NL 21519.988→1.230300; μ NL 12.822342→1.357397 N m, 9.44627 volte | massimo RMS per canale, Scope |
| Solo encoder, tre seed | PASS: picco/RMS μ migliorano >10 volte in ciascun seed | 144 righe `noise_metrics.csv`, quadratura ZOH e accordo delle coordinate |
| Tracking | PARTIAL: μ Ts 1.558/1.482 s; offset 8.243/2.192%; M5 invariata; overshoot μ NL combinato 10.67→35.60% | `plants_metrics.csv`, nominale, e `candidate.e.metrics` |
| Disturbi | PARTIAL: μ picco q peggiore 0.30716→0.33405 rad; RMS comando peggiore 0.41904→0.49867 N m | stessa coppia link, stessi orizzonti |
| Stabilità nominale | PASS | poli nello stato aumentato, nessuna cancellazione minreal |
| Robust stability | H∞ FAIL; μ PASS, [1.84622,1.88174] | nuovi `robstab` e `mussv` |
| Robust performance | H∞ FAIL; μ PASS, [1.59634,1.60036] | nuovo `robgain(CL,1)`; precedente [1.59623,1.60042] |
| Dieci impianti congelati | H∞N3 6/10; μN1 10/10 stabili | stessi oggetti MAT del Capitolo 11 |
| RAS/stato intero | H∞ 13 convergenze/12 arresti; μ 25 convergenze, certificato Lyapunov NON OTTENUTO | 36/96 stati; `ras/ras_lyapunov.mat` |
| Prove Simulink | PASS: otto nuovi run, baseline/candidato su quattro originali | audit, Workspace e hash coefficienti, Scope completi |
| Integrità 8 SLX | PASS | manifest, hash prima/dopo e `initial_integrity.json` |
| Risultati precedenti | PASS | audit finale dei 197 MAT/SLX preesistenti; nessun MAT scientifico sovrascritto |
| Quattro script principali | PASS | eseguiti identici in copia isolata, hash dei sorgenti |
| Regressioni | PASS 141/141; PASS 7/7 dedicate | CSV dei nuovi run, separati dalle evidenze precedenti |
| Relazione | PASS: 108 pagine, audit e controllo visivo | `report/generated/report_latex_audit.txt` e controllo visivo |
| Schemi lineari/non lineari | PASS: autentici e controllati visivamente nei PDF | due slide LQGI, ulteriori dettagli H∞/μ nella relazione |
| Presentazione | 23 slide, 18:47 stimati | PDF e audit; stima da conteggio, prova dal vivo ancora necessaria |
| Presentazione_orale.txt | PASS: 2237 parole, alternanza, appendice di 25 domande | `oral_timing.json`: Alessio 9:27, Valerio 8:36, cambi 0:44 |
| Prova_di_Soluzione_Rumore_di_Misura.txt | PASS: dodici sezioni, dati e compromessi | generato da `summary.json` |

Nessun Umax reale è documentato: la scala di 12 N m non è un dato di targa. Le realizzazioni gaussiane hanno supporto non limitato; picchi finiti e margini del modello non sono una certificazione hardware. I protocolli MATLAB indipendente e SLX correlato restano distinti.
