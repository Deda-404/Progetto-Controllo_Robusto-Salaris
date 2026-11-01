"""Tabelle e figure della revisione: solo CSV prodotti dalla pipeline MATLAB."""
from pathlib import Path
import csv
import math
import shutil
from collections import Counter

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "File_di_Funzioni_Progetto-Accorpati/risultati"
GEN = ROOT / "report/generated"
FIG = ROOT / "report/figures/definitiva"

def read(name):
    with (DATA / (name + ".csv")).open(encoding="utf-8-sig", newline="") as stream:
        return list(csv.DictReader(stream))

def esc(value):
    return str(value).replace("_", r"\_").replace("%", r"\%")

def num(value, digits=3):
    value = float(value)
    return "--" if not math.isfinite(value) else f"{value:.{digits}g}"

def table(name, headers, rows, caption):
    lines = [r"\par", r"\begin{table}[htbp]\centering\small",
             r"\setlength{\tabcolsep}{4pt}",
             r"\begin{tabular}{" + "l" + "r" * (len(headers) - 1) + r"}\toprule",
             " & ".join(headers) + r"\\\midrule"]
    lines += [" & ".join(map(str, row)) + r"\\" for row in rows]
    lines += [r"\bottomrule\end{tabular}", r"\caption{" + caption + "}", r"\end{table}", r"\par"]
    (GEN / ("definitiva_" + name + ".tex")).write_text("\n".join(lines) + "\n", encoding="utf-8")

def main():
    GEN.mkdir(exist_ok=True); FIG.mkdir(parents=True, exist_ok=True)
    for name in ["famiglia_attuatori", "peso_incertezza", "robustezza", "ras", "dieci_impianti"]:
        shutil.copy2(DATA / (name + ".png"), FIG)
    weights = read("ordini_peso")
    table("pesi", ["Ordine", r"$\max_j\|E_j/W\|_\infty$", "Eccesso mediano"],
          [[x["Ordine"], num(x["MaxNormaNormalizzata"], 5), num(x["EccessoMediano"], 5)] for x in weights],
          "Tre ordini provati: copertura dinamica dei 25 casi SISO. Selezionato l'ordine uno.")
    robust = read("confronto_robusto")
    rows = []
    for x in robust:
        rs = f'[{num(x["RS_lower"],4)}, {num(x["RS_upper"],4)}]'
        rp = (f'[{num(x["RP_lower"],4)}, {num(x["RP_upper"],4)}]'
              if x["MetodoRP"].startswith("robgain") else esc(x["MetodoRP"]).replace("LIMITE\\_DA\\_RS", "esclusa da RS"))
        rows.append([esc(x["Controllore"]), x["Analisi"][0], num(x["NormaNominale"],4), rs, rp])
    table("robustezza", ["Controllore", "Modello", "Norma nominale", "Margine RS", "Margine RP"],
          rows, "Stesso controllore sui due insiemi A/B. Un limite inferiore maggiore di uno certifica il requisito nel modello dichiarato. NP FAIL esclude RP gia sul nominale.")
    ras = read("ras"); names = list(dict.fromkeys(x["Controllore"] for x in ras))
    states = ["CONVERGENZA", "MANCATA_CONVERGENZA", "DIVERGENZA_OSSERVATA", "TIMEOUT", "ERRORE_NUMERICO"]
    rows = []
    for name in names:
        counts = Counter(x["Esito"] for x in ras if x["Controllore"] == name)
        assert sum(counts.values()) == 15
        assert set(counts).issubset(states), counts
        rows.append([esc(name)] + [counts[s] for s in states])
    table("ras", ["Controllore", "Conv.", "Non conv.", "Diverg.", "Timeout", "Errore"], rows,
          "Quindici condizioni iniziali comuni per controllore; gli arresti numerici restano distinti dalla divergenza osservata.")
    table("rumore", ["Controllore", "Picco a 2 ms", "Picco fra campioni", "RMS integrato"],
          [[esc(x["Controllore"]), num(x["PiccoCampioni"],4), num(x["PiccoTraCampioni"],4), num(x["RMSIntegrato"],4)] for x in read("rumore")],
          "Comando in N m: rumore encoder comune, 4 s, deviazione standard 0.05 gradi e mantenimento ZOH. Picchi osservati, senza saturazione; non limiti hardware.")
    plants = read("dieci_impianti"); rows = []
    for name in names:
        selected = [x for x in plants if x["Controllore"] == name and int(x["Impianto"]) > 0]
        stable = [x for x in selected if int(x["Stabile"])]
        def maximum(key):
            return num(max((float(x[key]) for x in stable), default=float("nan")),4)
        rows.append([esc(name), f"{len(stable)}/10", maximum("ErroreDC"),
                     maximum("PiccoComando"), maximum("PiccoDisturboRad")])
    table("impianti", ["Controllore", "Stabili", "Errore DC max", "Picco $u$ max", "Picco $q_d$ max"],
          rows, "Dieci impianti incerti comuni. Errore DC relativo; comando in N m e disturbo in rad. Massimi sui soli casi stabili; metriche temporali complete nei CSV.")
    values = []
    for name in names:
        tag = name.replace("_", "").replace("1", "One").replace("2", "Two")
        physical = [x for x in plants if x["Controllore"] == name and int(x["Impianto"]) > 0]
        noise = next(x for x in read("rumore") if x["Controllore"] == name)
        counts = Counter(x["Esito"] for x in ras if x["Controllore"] == name)
        data = {"Stable": str(sum(int(x["Stabile"]) for x in physical)),
                "Conv": str(counts["CONVERGENZA"]), "Timeout": str(counts["TIMEOUT"]),
                "Peak": num(noise["PiccoTraCampioni"], 4), "Rms": num(noise["RMSIntegrato"], 4)}
        for suffix, value in data.items():
            values.append(r"\newcommand{\Def" + tag + suffix + "}{" + value + "}")
    (ROOT / "presentation/generated/definitiva_values.tex").write_text("\n".join(values)+"\n", encoding="utf-8")
    print("Esportate cinque tabelle e cinque figure dai risultati MATLAB.")

if __name__ == "__main__":
    main()
