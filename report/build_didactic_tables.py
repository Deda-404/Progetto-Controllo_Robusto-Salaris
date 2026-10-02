"""Formatta il confronto H-infinity dai JSON consolidati, senza sintesi."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "report/generated"
summary = json.loads((ROOT / "results/data/hinf_final_coherent/summary.json").read_text())
audit = json.loads((ROOT / "results/data/organic_review/numeric_audit.json").read_text())

def write(name, content):
    (OUT / name).write_text(content.strip() + "\n", encoding="utf-8")

def row(values):
    return " & ".join(str(x) if isinstance(x, str) else f"{x:.6g}" for x in values) + r" \\"

cases = []
for label, key in [(r"\texttt{mixsyn}/\texttt{hinfsyn}", "bestOne"),
                   (r"\texttt{hinfsyn}", "selected")]:
    q = summary[key]
    worst = [max(v[i] for v in q["metrics"]) for i in range(6)]
    cases.append(row([label, "1-DoF" if key == "bestOne" else "2-DoF",
                      q["order"], q["norms"][0], worst[0], worst[1], 100*worst[2], worst[4]]))
for q in audit["structured"]:
    worst = [max(v[i] for v in q["metrics"]) for i in range(6)]
    cases.append(row([r"\texttt{hinfstruct} " + q["family"], "2-DoF",
                      q["order"], q["norm"], worst[0], worst[1],
                      r"$<10^{-10}$" if 100*worst[2] < 1e-10 else 100*worst[2], worst[4]]))
write("didactic_hinf_comparison.tex", r"""
% Source: summary.json and organic_review/numeric_audit.json; no synthesis.
\begin{tabular}{llrrrrrr}\toprule
Metodo & Struttura & Ord. & $\|T_{zw}\|_\infty$ & $T_s$ & OS & $e_{ss}$ & Picco $u$\\
 & & & & [s] & [\%] & [\%] & [N m]\\\midrule
""" + "\n".join(cases) + r"""
\bottomrule\end{tabular}
""")

# Il confronto mixsyn/hinfsyn riusa i numeri del controllo indipendente.
write("didactic_mixsyn_hinfsyn.tex", r"""
\begin{tabular}{lrr}\toprule
Profilo & $\gamma_{\rm mixsyn}$ & $\gamma_{\rm hinfsyn}$\\\midrule
""" + "\n".join(row(["Iniziale" if q["profile"] == 1 else "Selezionato",
                          q["gammaMixsyn"], q["gammaHinfsyn"]])
                     for q in audit["oneDof"]) + r"""
\bottomrule\end{tabular}
""")

# La tabella dei disturbi del capitolo 8 contiene solo controllori H-infinity.
cases = [("1-DoF iniziale", summary["baseline"]["disturbanceMetrics"]),
         ("1-DoF selezionato", summary["bestOne"]["disturbanceMetrics"]),
         ("2-DoF completo", summary["selected"]["disturbanceMetrics"])]
cases += [(q["family"], q["disturbanceMetrics"]) for q in audit["structured"]]
write("didactic_hinf_disturbance.tex", r"""
\begin{tabular}{lrrrr}\toprule
Controllore & Picco $q$ [rad] & Picco $u$ [N m] & RMS $u$ [N m] & Offset [rad]\\\midrule
""" + "\n".join(row([label] + [max(v[i] for v in values) for i in range(4)])
                     for label, values in cases) + r"""
\bottomrule\end{tabular}
""")
