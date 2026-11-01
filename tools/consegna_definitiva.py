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
Revisione A/B completata il 1 novembre 2026.

1. Estrarre tutto lo ZIP.
2. Aprire MATLAB R2026b e selezionare la cartella Consegna_Progetto_SEA.
3. Eseguire run_all oppure run_all('rapida').
4. Per rigenerare sintesi, robustezza, RAS e Simulink: run_all('completa').

Toolbox: Control System Toolbox, Robust Control Toolbox, Simulink.
R2026b 26.2.0.3386108 è la versione collaudata. Gli SLX originali sono
R2026a: R2025b non li apre senza conversione, qui non effettuata.
Non servono Symbolic Math Toolbox, Python, Git o accesso al repository.

La rapida ricalcola modello, peso, verifiche CARE, campioni, risposte e
rumore. Carica esplicitamente le sintesi H-infinity/D-K, la post-analisi
robusta e la RAS della campagna completa; ripete una verifica RAS locale.
La completa rigenera tutto, compresi 150 casi RAS e 28 run Simulink.
Le simulazioni possono richiedere diversi minuti; sono mostrati i progressi.
I risultati si trovano in risultati/. La banca originale in dati/ è conservata.
I controllori nuovi restano identificati separatamente da quelli originali.

Script, nell'ordine del percorso:
modello_sea; incertezze_attuatori; progetto_lqg; progetto_lqgi;
progetto_hinf_tre_controllori; progetto_mu; confronto_ras.
Ogni script è leggibile per sezioni. Eseguire prima run_all per predisporre
i dati delle sezioni dipendenti. Configurazione unica: parametri_sea.m.
collaudo_simulink esegue gli otto modelli con matrici e parametri espliciti:
modifica soltanto il modello in memoria e chiude senza salvare gli SLX.
Le callback storiche sono escluse durante questi run. Per ripetere i run
usare collaudo_simulink, non il tasto Run su uno SLX aperto senza preparazione.
Le quattro funzioni in simulink/support sono richiamate dai MATLAB Function.

Il confronto A/B riguarda wn e zeta indipendenti per i due attuatori, ±10%;
meccanica nominale, ritardo 15 ms noto e Padé comune di ordine uno.
La copertura di B è verificata sui casi SISO provati; non è una prova
di inclusione dell'intero box parametrico. Fallimenti di prestazione,
rumore elevato e limiti empirici della RAS sono risultati, non errori omessi.
Gli estratti Scope conservano picchi e conteggi dell'acquisizione integrale;
le curve archiviate sono diradate a massimo 2000 campioni per segnale.
I picchi dei diversi protocolli non sono direttamente intercambiabili.

Relazione e slide sono in relazione/. Sorgenti LaTeX e storia completa:
https://github.com/Deda-404/Progetto_CR/tree/codex/revisione-definitiva-sea-salaris

Se un path MATLAB personalizzato nasconde funzioni dei toolbox installati:
restoredefaultpath; rehash toolboxcache; cd(cartella_estratta); run_all
Questo ripristina il path solo nella sessione; non eseguire savepath.
"""

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    OUTPUT.mkdir(parents=True, exist_ok=True)
    mapping = {Path("run_all.m"): ROOT / "run_all.m"}
    mapping.update({Path(f.name): f for f in SOURCE.glob("*.m")})
    mapping[Path("dati/banca_validata.mat")] = SOURCE / "dati/banca_validata.mat"
    for name in ["sintesi_hinf", "sintesi_mu", "confronto_robusto", "ras"]:
        mapping[Path(f"dati/{name}.mat")] = SOURCE / f"risultati/{name}.mat"
    for source in (SOURCE / "risultati").iterdir():
        if source.suffix in {".csv", ".png", ".json", ".txt"} or source.name in {
            "simulink.mat", "modello.mat", "incertezze.mat", "lqg.mat", "lqgi.mat"}:
            mapping[Path("risultati") / source.name] = source
    for source in (ROOT / "simulink/student_originals").glob("*.slx"):
        mapping[Path("simulink") / source.name] = source
    for name in ["sea_link_inertia", "sea_coriolis", "sea_gravity", "sea_elastic_torque"]:
        mapping[Path(f"simulink/support/{name}.m")] = ROOT / f"src/model/{name}.m"
    for name in ["report/Progetto_CR_Relazione_finale.pdf", "presentation/Progetto_CR_Presentazione.pdf",
                 "presentation/Presentazione_orale.txt"]:
        mapping[Path("relazione") / Path(name).name] = ROOT / name
    mapping[Path("REVISIONE_DEFINITIVA.md")] = ROOT / "docs/REVISIONE_DEFINITIVA.md"
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
