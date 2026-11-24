"""Copia gli stessi sorgenti autorevoli e confeziona una sola consegna."""
from pathlib import Path
import hashlib
import json
import shutil
import zipfile

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "File_di_Funzioni_Progetto-Accorpati"
OUTPUT = ROOT / "delivery/Consegna_Progetto_SEA"
ARCHIVE = OUTPUT.with_suffix(".zip")

README = """PROGETTO SEA — CONSEGNA AUTONOMA
Alessio de Dato e Valerio Rebechi
Massa m2 incerta e confronto A/B; elaborati del 4 novembre 2026.

1. Estrarre tutto lo ZIP.
2. Aprire MATLAB R2026b e selezionare la cartella Consegna_Progetto_SEA.
3. Eseguire run_all oppure run_all('rapida').
4. Per rigenerare sintesi, analisi robuste, RAS e Simulink: run_all('completa').

Toolbox: Control System Toolbox, Robust Control Toolbox, Simulink.
R2026b 26.2.0.3386108 è la versione verificata. Gli SLX sono R2026b;
R2025b non li apre senza conversione, qui non effettuata.
Non servono Symbolic Math Toolbox, Python, Git o accesso al repository.
Collaudo da ZIP estratta in TEMP con path pulito: rapida integrale, 8 verifiche,
20 run Simulink e 8 callback originali PASS. Sette CSV identici al repository;
33 ingressi eseguibili corrispondono agli hash del pacchetto collaudato.
Dopo il collaudo sono aggiornati soltanto documentazione, evidenze e manifest.

La rapida ricalcola modello, incertezze, peso, LQG/LQGI, campioni,
risposte, rumore e una simulazione locale. Carica esplicitamente le sintesi
H-infinity/D-K, l'analisi robusta e la RAS della campagna completa,
verificando configurazione e identità dei controllori.
La completa rigenera tutto: 105 RAS, 14 prove non lineari nominali,
21 prove con sola massa m2 variata e 20 run Simulink. Può richiedere
diverse decine di minuti, soprattutto per D-K e analisi robuste.

La configurazione unica è parametri_sea.m. Gli script sono richiamati
in ordine da run_all, con Workspace separati. Risultati in risultati/;
dati/banca_validata.mat conserva i controllori di riferimento.
La campagna predefinita usa sette candidati; controllori_sea(p,true)
include esplicitamente i riferimenti per un confronto mirato.
Le altre quattro MAT in dati/ contengono i risultati coerenti della campagna.

m1=1 kg; m2=0.8 kg ±10%, intervallo [0.72,0.88] kg.
Le due masse sono quelle della traccia; m2 compare in M, C e G.
wn=40 rad/s ±15%, zeta=0.8 noto, td=15 ms ±20% per ogni drive.
A: quattro reali attuativi e una massa reale comune, cinque scalari.
B: due perturbazioni dinamiche additive e la stessa massa reale.
Peso di ordine 3; copertura verificata su 25 casi e 30 indipendenti,
non dimostrata sull'intero box. Gli stessi dieci impianti per tutti i K.
Target: 2 s, 15%, errore statico 5%, cross 25%; soglie NS/NP/RS/RP immutate.
I fallimenti prestazionali, il rumore eccessivo e i limiti della RAS
rimangono nei risultati. Non tutti i controllori sono utilizzabili.

Gli otto SLX si possono aprire singolarmente e avviare con Run.
La callback InitFcn individua automaticamente collaudo_simulink.m e assegna
il nominale dal contenuto locale della consegna, senza Workspace precedente.
La variabile m2_eff dei generatori non lineari riceve esclusivamente m2;
i due drive hanno realizzazioni distinte. Nessuna libreria esterna richiesta.
collaudo_simulink senza argomenti esegue invece le 20 prove campionate.
Il completamento e gli stati finiti sono verifiche di esecuzione;
RS/RP, target temporali e ampiezze dei comandi sono riportati separatamente.
I modelli sono stati salvati con R2026b; gli originali sono recuperabili
nella cronologia Git. Non è stata modificata la topologia.

Relazione, slide e testo orale sono in relazione/.
Evidenze e limiti correnti: REVISIONE_TRACCIA_20261104.md.
Sorgenti e storia: https://github.com/Deda-404/Progetto_CR
Ramo: codex/sea-revisione-finale-semplificata.

In caso di path personale che nasconde funzioni dei toolbox:
restoredefaultpath; rehash toolboxcache; cd(cartella_estratta); run_all
Il ripristino vale per la sessione; non eseguire savepath.
"""

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    OUTPUT.mkdir(parents=True, exist_ok=True)
    mapping = {Path("run_all.m"): ROOT / "run_all.m"}
    mapping.update({Path(f.name): f for f in SOURCE.glob("*.m")})
    mapping[Path("dati/banca_validata.mat")] = SOURCE / "dati/banca_validata.mat"
    for name in ["sintesi_hinf", "sintesi_mu", "confronto_robusto_r", "ras"]:
        mapping[Path(f"dati/{name}.mat")] = SOURCE / f"risultati/{name}.mat"
    for source in (SOURCE / "risultati").iterdir():
        correnti={"candidati_massa","candidati_ritardo","candidati_specifiche","candidati_riferimento",
                  "confronto_robusto","confronto_robusto_r","dieci_impianti","dk_1","dk_2","forme_incertezza","hinf",
                  "kalman","massa_nonlineare","nonlineare","ordini_peso","parametri_dieci_impianti",
                  "ras","riesame_mu","rumore","sensibilita_attuatori","simulink","simulink_autonomo",
                  "esecuzione_rapida","verifiche","riassunto_numerico","oral_timing","code_analyzer",
                  "verifica_modellazione_20261104","verifica_numerica_20261104","verifica_pdf_20261104",
                  "collaudo_consegna_20261104"}
        if source.suffix==".png" or source.stem in correnti or source.name in {
            "modello.mat", "incertezze.mat", "lqg.mat", "lqgi.mat"}:
            mapping[Path("risultati") / source.name] = source
    for source in (ROOT / "simulink/student_originals").glob("*.slx"):
        mapping[Path("simulink") / source.name] = source
    for name in ["sea_link_inertia", "sea_coriolis", "sea_gravity", "sea_elastic_torque"]:
        mapping[Path(f"simulink/support/{name}.m")] = ROOT / f"src/model/{name}.m"
    for name in ["report/Progetto_CR_Relazione_finale.pdf", "presentation/Progetto_CR_Presentazione.pdf",
                 "presentation/Progetto_CR_Presentazione.pptx", "presentation/Presentazione_orale.txt"]:
        mapping[Path("relazione") / Path(name).name] = ROOT / name
    mapping[Path("REVISIONE_TRACCIA_20261104.md")] = ROOT / "docs/REVISIONE_TRACCIA_20261104.md"
    expected = {str(path.as_posix()) for path in mapping} | {"LEGGIMI.txt", "MANIFEST_SHA256.json"}
    unexpected = {str(f.relative_to(OUTPUT).as_posix()) for f in OUTPUT.rglob("*") if f.is_file()} - expected
    if unexpected:
        raise RuntimeError(f"File estranei nella cartella generata, non rimossi automaticamente: {unexpected}")
    for target, source in mapping.items():
        destination = OUTPUT / target
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, destination)
        assert sha(source) == sha(destination)
    (OUTPUT / "LEGGIMI.txt").write_text(README, encoding="utf-8")
    records = {str(f.relative_to(OUTPUT).as_posix()): sha(f) for f in OUTPUT.rglob("*")
               if f.is_file() and f.name != "MANIFEST_SHA256.json"}
    manifest = json.dumps(records, indent=2, ensure_ascii=False) + "\n"
    (OUTPUT / "MANIFEST_SHA256.json").write_text(manifest, encoding="utf-8")
    (ROOT / "delivery/MANIFEST_DEFINITIVO.json").write_text(manifest, encoding="utf-8")
    with zipfile.ZipFile(ARCHIVE, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=6) as archive:
        for path in sorted(OUTPUT.rglob("*")):
            if path.is_file():
                archive.write(path, Path(OUTPUT.name) / path.relative_to(OUTPUT))
    with zipfile.ZipFile(ARCHIVE) as archive:
        assert archive.testzip() is None
        for path, digest in records.items():
            assert hashlib.sha256(archive.read(f"{OUTPUT.name}/{path}")).hexdigest() == digest
    print(f"{len(records)+1} file; ZIP {ARCHIVE.stat().st_size} byte; SHA-256 {sha(ARCHIVE)}")

if __name__ == "__main__":
    main()
