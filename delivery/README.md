# Archivio della consegna del 13 ottobre 2026

Questo documento e i pacchetti descritti si riferiscono alla consegna del 13 ottobre.
La revisione del 24 ottobre è descritta nel README principale e in
docs/RESOCONTO_REVISIONE_SALARIS.md; i PDF correnti sono in report/ e presentation/.
Il manifest di questa cartella registra il pacchetto storico del 13 ottobre.

---

# Consegna del progetto SEA con studio del rumore

Alessio de Dato, matricola 635256; Valerio Rebechi, matricola 722224. Data: 13.10.2026.

Elaborati scientifici: report/Progetto_CR_Relazione_finale.pdf (108 pagine) e presentation/Progetto_CR_Presentazione.pdf (23 slide). Sono inclusi sorgenti LaTeX, immagini autentiche, quattro script MATLAB con i default consolidati, funzioni, dati e otto SLX originali. La consegna precedente resta conservata; il nuovo pacchetto si chiama Consegna_SEA_Rumore_Orale_2026-10-13.

I due TXT Prova_di_Soluzione_Rumore_di_Misura.txt e Presentazione_orale.txt si trovano nella cartella preparazione_studenti insieme alla tabella di accettazione. Sono materiali interni per lo studio e la preparazione, distinti dagli allegati scientifici per il docente. Note e scaletta nella cartella presentation completano la regia. La stima orale è 18:47 a 125 parole/minuto, inclusi 44 s di cambi slide; l'appendice di domande non rientra nei venti minuti.

## Esecuzione e provenienza

Collaudo reale in MATLAB/Simulink R2026b 26.2.0.3386108, Windows, Control System/Robust Control/Symbolic Math Toolbox 26.2. Quattro script identici rieseguiti e 141 regressioni PASS in copia isolata; sette test dedicati e otto nuovi run abbinati PASS. I 197 MAT/SLX preesistenti sono invariati.

Per lo studio nuovo seguire analysis/noise_redesign/README.md. Le sintesi e i run SLX riusano i checkpoint verificati. Le metriche encoder, gli impianti e gli esportatori sono ripetibili. Per rieseguire da zero la sintesi lavorare su una copia, conservando prima i MAT candidati; nessun MAT consolidato va cancellato. La baseline resta predefinita. La selezione candidata avviene soltanto tramite setup_student_originals e le variabili esterne.

I quattro script in File_di_Funzioni_Progetto-Accorpati possono essere eseguiti dall'Editor. La regressione integrale richiede il checkout GitHub completo e Git LFS; ripeterla in copia isolata per preservare gli artifact congelati. Il pacchetto contiene gli esiti e i sorgenti necessari allo studio, senza l'intero archivio storico dei test.

Solver, selettori, sample time, seed e callback degli SLX sono immutati. L'acquisizione Scope usa una API interna R2026b; su altre release può servire Print to Figure. Controllare sempre gli otto SHA-256 rispetto a simulink/student_originals_manifest.json, prima e dopo. H∞ lineare mantiene feedback ideale, gli altri tre modelli studiati feedback rumoroso; encoder SLX correlati e MATLAB isolato indipendente sono protocolli diversi.

## Rigenerazione degli elaborati

```text
python tools/build_noise_redesign_documents.py
python tools/audit_oral_timing.py
powershell -File tools/build_m18_latex.ps1
```

L'esportatore del quaderno rigenera docs/Prova_di_Soluzione_Rumore_di_Misura.txt; l'audit orale legge anche il TXT nella preparazione del pacchetto e rigenera regia e tempi. I sette test dedicati sono inclusi; l'intera regressione storica richiede il checkout completo.

MANIFEST_CONSEGNA.json verifica byte per byte i file copiati e compressi. delivery/manifest.json nel repository registra ruoli e hash normalizzati LF per testi portabili, esatti per binari. I vecchi resoconti, cronologie e cache restano esclusi dalla consegna ordinaria.

## Risultato e limiti

MuN1 (ordine 82) mantiene RS [1.84622,1.88174] e RP [1.59634,1.60036]. Nel run μ non lineare il picco passa da 108.526 a 2.25091 N m, RMS da 12.8223 a 1.35740. Offset q1 8.243% e assestamento 1.558 s non rispettano i target: la proposta resta separata dalla baseline. I tre H∞ falliscono RS/RP. Dieci impianti stabili e 25 convergenze μ sono evidenze empiriche; il gate Lyapunov non è superato. Nessun limite hardware Umax è inventato. Picchi finiti, rumori gaussiani non limitati e norme pesate non certificano un massimo assoluto di coppia o l'hardware.
