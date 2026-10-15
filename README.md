# Controllo robusto di un manipolatore SEA a due giunti

Alessio de Dato (635256) e Valerio Rebechi (722224), 13.10.2026. Revisione con rumore esplicito completata in MATLAB/Simulink R2026b 26.2.0.3386108: 141 regressioni, sette test dedicati, quattro script invariati e otto nuovi run abbinati PASS. I 197 MAT/SLX preesistenti restano identici. Branch `codex/sintesi-robusta-rumore-e-orale-finale`, da main `a4b3817` dopo il merge della PR #40; nessun merge nella revisione corrente.

[PR #41 — revisione con rumore e orale finale](https://github.com/Deda-404/Progetto_CR/pull/41) aperta in bozza; ramo e otto nuovi oggetti Git LFS pubblicati, nessun merge.

La baseline rimane predefinita. Tre nuovi H∞ di ordine 22 riducono il rumore ma falliscono RS/RP. Il nuovo μ, MuN1 di ordine 82, supera NS/NP/RS/RP e resta una proposta per la revisione degli studenti: nel Simulink non lineare il picco passa da 108.526 a 2.25091 N m e il massimo RMS per canale da 12.8223 a 1.35740 N m. I rapporti sono 48.21 e 9.446. Nel protocollo encoder isolato, picco e RMS migliorano oltre dieci volte in ciascuno dei tre seed.

Il compromesso resta esplicito: il tracking μ ha Ts=1.558/1.482 s e offset 8.243%/2.192%; l'offset q1 peggiora rispetto alla baseline e la reiezione del disturbo è leggermente peggiore. RS è [1.84622,1.88174], RP [1.59634,1.60036], per il modello incerto dichiarato. I dieci impianti congelati sono stabili con MuN1; la griglia RAS ha 25 convergenze empiriche, senza certificato Lyapunov numericamente accreditato. Nessun limite di coppia hardware documentato consente una certificazione fisica.

## Elaborati e preparazione

- [Relazione PDF](report/Progetto_CR_Relazione_finale.pdf), 108 pagine; [sorgente](report/main.tex).
- [Presentazione PDF](presentation/Progetto_CR_Presentazione.pdf), 23 slide con schemi Simulink autentici lineare e non lineare.
- [Discorso completo](presentation/Presentazione_orale.txt): 2237 parole, alternanza Alessio/Valerio e 25 domande in appendice; 18:47 stimati a 125 parole/minuto inclusi 44 s di cambi slide.
- [Quaderno dello studio del rumore](docs/Prova_di_Soluzione_Rumore_di_Misura.txt) e [tabella di accettazione](docs/ACCETTAZIONE_RUMORE_E_ORALE.md).
- [Note di regia](presentation/SPEAKER_NOTES.md), [tempi](presentation/OUTLINE_AND_TIMING.md) e [istruzioni di consegna](delivery/README.md).

I due TXT sono materiali di preparazione degli studenti; il pacchetto li colloca in `preparazione_studenti/`. Gli allegati scientifici rimangono PDF, sorgenti, dati e modelli. Il pacchetto precedente resta conservato.

## Modelli, controllori e prove

Il modello ha otto stati meccanici e 14 con attuatori. La baseline comprende LQG (14), LQGI (16), H∞ 1-DoF (18), H∞ 2-DoF (22), PID (4) e Kμ (78). I quattro script didattici in `File_di_Funzioni_Progetto-Accorpati/` conservano i default e i dati consolidati.

Lo studio separato è in `analysis/noise_redesign/`, con [istruzioni riproducibili](analysis/noise_redesign/README.md). Usa W1, W2, Mo, fisica e incertezze originali, aggiungendo soltanto gli ingressi encoder esogeni e Wn. I candidati, i nuovi margini, i tre seed/otto scenari e gli otto run sono in `results/data/noise_redesign/`. Le tre figure di confronto sono in `report/figures/noise_redesign/`; gli schemi autentici provengono da `report/figures/student_exports/`.

H∞ lineare mantiene feedback ideale: verifica l'interfaccia e non certifica attenuazione encoder. H∞ non lineare e i due μ ricevono misure rumorose. Encoder SLX correlati, seed 20260826; studio MATLAB indipendente con tre seed diversi. Picchi Scope, picchi su scansione fra campioni e RMS dei due protocolli conservano significati distinti. Gaussiane non limitate e prove finite non garantiscono un massimo universale.

## Esecuzione

Servono MATLAB/Simulink R2026b, Control System, Robust Control e Symbolic Math Toolbox. Dalla radice:

```matlab
addpath(genpath('analysis'),genpath('controllers'),genpath('src'),'simulink');
run_noise_synthesis('hinf');
run_noise_synthesis('mu');
validate_noise_candidates;
audit_noise_robustness;
run_noise_simulink;
validate_noise_plants;
export_noise_redesign;
r=runtests('tests/noiseRedesignTest.m'); assertSuccess(r);
```

Le sintesi e le simulazioni riusano i checkpoint verificati; la RAS ha istruzioni dedicate nel README dello studio. `setup_student_originals('mu','noise_mu1')` e l'analogo H∞ selezionano i candidati solo tramite variabili esterne; senza secondo argomento si carica la baseline. Per ripetere i quattro default e l'intera regressione senza sovrascrivere i MAT storici usare una copia isolata del checkout, come nel collaudo registrato in `results/data/noise_redesign/regression/`.

```text
python tools/build_noise_redesign_documents.py
python tools/audit_oral_timing.py
powershell -File tools/build_m18_latex.ps1
python tools/build_delivery_manifest.py --check
```

Gli otto SLX devono coincidere sempre con `simulink/student_originals_manifest.json`. Nessun blocco, selettore, solver, rumore o callback è stato modificato. L'acquisizione Scope usa una API interna R2026b; su altra release può servire Print to Figure. Git LFS è necessario per i buffer Scope voluminosi. Drive rimane in sola lettura. Restano revisione degli studenti, decisione sull'adozione e prova orale dal vivo.
