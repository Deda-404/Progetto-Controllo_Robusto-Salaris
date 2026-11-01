# Consegna operativa corrente

[Scaricare Consegna_Progetto_SEA.zip](Consegna_Progetto_SEA.zip), estrarre tutto e aprire in MATLAB la cartella estratta.

```matlab
run_all                 % rapida: sintesi e campagne onerose caricate
run_all('completa')      % rigenerazione completa e collaudo Simulink
```

Servono MATLAB R2026b, Control System Toolbox, Robust Control Toolbox e Simulink. Non servono Python, Git, Symbolic Math Toolbox o percorsi del repository. LEGGIMI.txt nello ZIP descrive dati caricati, limiti e uso degli SLX tramite collaudo_simulink.

La consegna è generata dagli stessi sorgenti da `python tools/consegna_definitiva.py`; il manifest è [MANIFEST_DEFINITIVO.json](MANIFEST_DEFINITIVO.json). È stata verificata da una cartella estratta in TEMP con path MATLAB ripristinato: rapida e 28 run SLX PASS. I 31 sorgenti/ingressi necessari coincidono per hash con il repository.

I materiali delle consegne precedenti restano storia del progetto e non sono ingressi alternativi del percorso corrente. Il codice autorevole è nella radice e in File_di_Funzioni_Progetto-Accorpati; la cartella generata è ignorata da Git, mentre ZIP e manifest finali sono pubblicati.
