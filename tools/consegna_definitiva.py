"""Confeziona la consegna del 01.12.2026 dalla cartella File_di_Funzioni_Progetto-Accorpati.

La cartella e gia autonoma: questo script non copia ne rinomina sorgenti.
1. elenca i file della cartella tracciati da Git (niente cache o file locali);
2. scrive MANIFEST_SHA256.json con l'impronta SHA-256 di ciascun file;
3. crea delivery/Progetto_Controllo_Robusto_SEA_01-12-2026.zip;
4. riapre lo ZIP e verifica integrita (testzip) e impronte.

Uso dalla radice del repository:  python tools/consegna_definitiva.py
"""
from pathlib import Path
import hashlib
import json
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[1]
CARTELLA = "File_di_Funzioni_Progetto-Accorpati"
SOURCE = ROOT / CARTELLA
ARCHIVE = ROOT / "delivery" / "Progetto_Controllo_Robusto_SEA_01-12-2026.zip"
MANIFEST = SOURCE / "MANIFEST_SHA256.json"
DATA_ELABORATO = "01.12.2026"
OBBLIGATORI = [
    "README.md", "LEGGIMI.txt", "run_all.m", "parametri_sea.m",
    "dati/banca_validata.mat", "test/seaFinaleTest.m", "test/verifica_sea.m",
    "elaborati/Traccia_ufficiale.pdf", "elaborati/Progetto_CR_Relazione_finale.pdf",
    "elaborati/Progetto_CR_Presentazione.pdf", "elaborati/Progetto_CR_Presentazione.pptx",
]


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def file_tracciati():
    out = subprocess.run(["git", "ls-files", "-z", CARTELLA], cwd=ROOT, check=True,
                         capture_output=True).stdout.decode("utf-8")
    nomi = [Path(x).relative_to(CARTELLA) for x in out.split("\0") if x]
    return sorted(n for n in nomi if n.name != MANIFEST.name)


def main():
    nomi = file_tracciati()
    mancanti = [n for n in OBBLIGATORI if Path(n) not in nomi]
    if mancanti:
        raise RuntimeError(f"File obbligatori assenti: {mancanti}")
    if any(n.suffix.lower() == ".zip" for n in nomi):
        raise RuntimeError("La cartella di consegna non deve contenere altri ZIP.")
    slx = [n for n in nomi if n.suffix == ".slx"]
    if len(slx) != 8:
        raise RuntimeError(f"Attesi 8 modelli Simulink, trovati {len(slx)}.")
    impronte = {n.as_posix(): sha(SOURCE / n) for n in nomi}
    manifest = {"elaborato": DATA_ELABORATO, "cartella": CARTELLA,
                "file": len(impronte), "sha256": impronte}
    MANIFEST.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    ARCHIVE.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(ARCHIVE, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=6) as z:
        for n in nomi + [Path(MANIFEST.name)]:
            z.write(SOURCE / n, (Path(CARTELLA) / n).as_posix())
    with zipfile.ZipFile(ARCHIVE) as z:
        assert z.testzip() is None
        for nome, impronta in impronte.items():
            assert hashlib.sha256(z.read(f"{CARTELLA}/{nome}")).hexdigest() == impronta
        assert len(z.namelist()) == len(impronte) + 1
    print(f"{len(impronte) + 1} file; ZIP {ARCHIVE.stat().st_size} byte; SHA-256 {sha(ARCHIVE)}")


if __name__ == "__main__":
    main()
