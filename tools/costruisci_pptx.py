"""Costruisce la versione PowerPoint delle slide dal PDF beamer.

Ogni slide diventa un'immagine a pagina intera con il testo orale nelle note.
La tabella degli esiti (slide 15) resta modificabile: lo sfondo viene preso da
una compilazione in cui le celle sono \\phantom, e la tabella PowerPoint viene
posizionata sulle stesse coordinate misurate nel PDF (regole e testo).

Uso dalla radice, dopo aver compilato presentation/main.tex:
    python tools/costruisci_pptx.py [cartella_presentation]
Richiede pdflatex/latexmk, poppler (pdftoppm, pdftotext), python-pptx, Pillow, NumPy.
"""
from pathlib import Path
import html
import re
import subprocess
import tempfile

import sys

import numpy as np
from PIL import Image
from pptx import Presentation
from pptx.dml.color import RGBColor
from pptx.enum.text import MSO_ANCHOR, PP_ALIGN
from pptx.oxml.ns import qn
from pptx.util import Emu, Pt

ROOT = Path(__file__).resolve().parents[1]
PRES = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else ROOT / "presentation"
OUT = ROOT / "File_di_Funzioni_Progetto-Accorpati" / "elaborati"
SLIDE_TABELLA = 15
W_PX, H_PX = 1928, 1085
W_EMU, H_EMU = 15240000, 8572500


def compila(nome):
    subprocess.run(["latexmk", "-pdf", "-interaction=nonstopmode", "-halt-on-error", nome],
                   cwd=PRES, check=True, capture_output=True)


def tabella_phantom():
    src = (PRES / "generated/finale_slide_esiti.tex").read_text(encoding="utf-8")
    righe = []
    for riga in src.splitlines():
        if "&" in riga:
            fine = r"\\\midrule" if riga.endswith(r"\\\midrule") else r"\\"
            celle = riga[: -len(fine)].split("&")
            riga = " & ".join(r"\phantom{" + c.strip() + "}" for c in celle) + fine
        righe.append(riga)
    (PRES / "generated/finale_slide_esiti_phantom.tex").write_text("\n".join(righe) + "\n", encoding="utf-8")
    main = (PRES / "main.tex").read_text(encoding="utf-8")
    (PRES / "phantom.tex").write_text(main.replace("generated/finale_slide_esiti.tex",
                                                   "generated/finale_slide_esiti_phantom.tex"), encoding="utf-8")


def celle_tabella():
    """Testo delle celle in Unicode semplice per PowerPoint."""
    sostituzioni = [(r"$T_s$", "Tₛ"), (r"$\mathrm{NP}_r$", "NPᵣ"), (r"$\mathrm{RP}_r$", "RPᵣ"),
                    (r"$\mathrm{RP}_{rd}$", "RP rd"), (r"Norma $r$", "Norma r"), (r"\_", "_")]
    righe = []
    for riga in (PRES / "generated/finale_slide_esiti.tex").read_text(encoding="utf-8").splitlines():
        if "&" not in riga:
            continue
        riga = riga.replace(r"\\\midrule", "").rstrip("\\")
        for a, b in sostituzioni:
            riga = riga.replace(a, b)
        riga = re.sub(r"\\num\{([^}]*)\}", r"\1", riga)
        righe.append([c.strip() for c in riga.split("&")])
    return righe


def regole(png):
    a = np.array(Image.open(png).convert("L")) < 100
    # righe orizzontali lunghe, esclusa la barra del titolo che occupa tutta la larghezza
    ys = [y for y in range(a.shape[0]) if not a[y, 0] and a[y].sum() > 0.3 * a.shape[1]]
    gruppi = []
    for y in ys:
        if gruppi and y - gruppi[-1][-1] <= 1:
            gruppi[-1].append(y)
        else:
            gruppi.append([y])
    xs = np.where(a[gruppi[0][0]])[0]
    return [(g[0], g[-1]) for g in gruppi], xs.min(), xs.max()


def colonne(pdf, n_colonne, pagina):
    """Estensione orizzontale [pt] di ogni colonna, su intestazione e tutte le righe."""
    with tempfile.TemporaryDirectory() as tmp:
        out = Path(tmp) / "p.html"
        subprocess.run(["pdftotext", "-f", str(pagina), "-l", str(pagina), "-bbox", str(pdf), str(out)], check=True)
        parole = [(float(a), float(b), float(c), html.unescape(t)) for a, b, c, t in re.findall(
            r'<word xMin="([\d.]+)" yMin="([\d.]+)" xMax="([\d.]+)" yMax="[\d.]+">([^<]*)</word>', out.read_text())]
    testa = next(p for p in parole if p[3] == "Controllore")
    ultima = min(p[1] for p in parole if p[3] == "MuN1")
    y_dati = next(p[1] for p in parole if p[3] == "LQG")
    riga = sorted([p for p in parole if abs(p[1] - y_dati) < 1], key=lambda p: p[0])
    assert len(riga) == n_colonne, riga
    destre = [p[2] for p in riga]
    estensioni = [[p[0], p[2]] for p in riga]
    for x0, y, x1, _ in parole:
        if not testa[1] - 1 <= y <= ultima + 1:
            continue
        if abs(x0 - riga[0][0]) < 1:
            j = 0
        else:
            j = next(k for k in range(1, n_colonne) if x1 <= destre[k] + 1)
        estensioni[j] = [min(estensioni[j][0], x0), max(estensioni[j][1], x1)]
    return estensioni


def main():
    compila("main.tex")
    tabella_phantom()
    compila("phantom.tex")
    with tempfile.TemporaryDirectory() as tmp:
        tmp = Path(tmp)
        subprocess.run(["pdftoppm", "-scale-to-x", str(W_PX), "-scale-to-y", str(H_PX), "-png",
                        str(PRES / "main.pdf"), str(tmp / "s")], check=True)
        subprocess.run(["pdftoppm", "-f", str(SLIDE_TABELLA), "-l", str(SLIDE_TABELLA), "-scale-to-x", str(W_PX),
                        "-scale-to-y", str(H_PX), "-png", str(PRES / "phantom.pdf"), str(tmp / "ph")], check=True)
        immagini = sorted(tmp.glob("s-*.png"))
        sfondo = next(tmp.glob("ph-*.png"))
        (top0, top1), (mid0, mid1), (bot0, _) = regole(sfondo)[0][:3]
        tabella = celle_tabella()
        estensioni = colonne(PRES / "main.pdf", len(tabella[0]), SLIDE_TABELLA)
        testi = re.findall(r"SLIDE \d+ — [^\n]*\n[^\n]*\n[^\n]*\nTesto da pronunciare:\n([^\n]*)",
                           (OUT / "Presentazione_orale.txt").read_text(encoding="utf-8"))
        assert len(immagini) == len(testi) == 23

        pres = Presentation()
        pres.slide_width, pres.slide_height = Emu(W_EMU), Emu(H_EMU)
        vuoto = pres.slide_layouts[6]
        emu_px = W_EMU / W_PX
        info = subprocess.run(["pdfinfo", str(PRES / "main.pdf")], check=True, capture_output=True, text=True).stdout
        pagina_pt = float(re.search(r"Page size:\s+([\d.]+)", info).group(1))
        emu_pt = W_EMU / pagina_pt
        for n, (img, nota) in enumerate(zip(immagini, testi), start=1):
            slide = pres.slides.add_slide(vuoto)
            slide.shapes.add_picture(str(sfondo if n == SLIDE_TABELLA else img), 0, 0, W_EMU, H_EMU)
            slide.notes_slide.notes_text_frame.text = nota
            if n != SLIDE_TABELLA:
                continue
            sx, dx = estensioni[0][0] - 3, estensioni[-1][1] + 3
            confini = [sx] + [(estensioni[i][1] + estensioni[i + 1][0]) / 2 for i in range(len(estensioni) - 1)] + [dx]
            sinistra = int(sx * emu_pt)
            alto = int((top1 + 1) * emu_px)
            alt_testa = int((mid0 - top1 - 1) * emu_px)
            alt_riga = int((bot0 - mid1 - 1) / (len(tabella) - 1) * emu_px)
            forma = slide.shapes.add_table(len(tabella), len(tabella[0]), sinistra, alto,
                                           int((dx - sx) * emu_pt), alt_testa + alt_riga * (len(tabella) - 1))
            t = forma.table
            tblPr = t._tbl.tblPr
            for attr in ("firstRow", "bandRow"):
                tblPr.set(attr, "0")
            stile = tblPr.find(qn("a:tableStyleId"))
            if stile is not None:
                tblPr.remove(stile)
            for j in range(len(tabella[0])):
                t.columns[j].width = int((confini[j + 1] - confini[j]) * emu_pt)
            t.rows[0].height = alt_testa
            for i in range(1, len(tabella)):
                t.rows[i].height = alt_riga
            for i, riga in enumerate(tabella):
                for j, testo in enumerate(riga):
                    cella = t.cell(i, j)
                    cella.fill.background()
                    cella.margin_left = cella.margin_right = int(1.5 * emu_pt)
                    cella.margin_top = cella.margin_bottom = 0
                    cella.vertical_anchor = MSO_ANCHOR.MIDDLE
                    cella.text_frame.word_wrap = False
                    par = cella.text_frame.paragraphs[0]
                    par.alignment = PP_ALIGN.LEFT if j == 0 else PP_ALIGN.RIGHT
                    run = par.add_run()
                    run.text = testo
                    run.font.size = Pt(8 * W_EMU / 12700 / pagina_pt)
                    run.font.name = "Calibri"
                    run.font.color.rgb = RGBColor(0, 0, 0)
                    tcPr = cella._tc.get_or_add_tcPr()
                    for lato in ("a:lnB", "a:lnT", "a:lnR", "a:lnL"):
                        ln = tcPr.makeelement(qn(lato), {"w": "0"})
                        ln.append(ln.makeelement(qn("a:noFill"), {}))
                        tcPr.insert(0, ln)
        pres.save(OUT / "Progetto_CR_Presentazione.pptx")
    for f in ["phantom.tex", "generated/finale_slide_esiti_phantom.tex"]:
        (PRES / f).unlink()
    for ext in ["pdf", "aux", "log", "nav", "out", "snm", "toc", "fls", "fdb_latexmk", "vrb"]:
        (PRES / f"phantom.{ext}").unlink(missing_ok=True)
    print("PowerPoint di 23 slide con tabella modificabile e note.")


if __name__ == "__main__":
    main()
