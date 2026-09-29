"""Formatta soltanto dati MATLAB salvati; non calcola nuovi controllori."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "report/generated"
audit = json.loads((ROOT / "results/data/organic_review/numeric_audit.json").read_text())
summary = json.loads((ROOT / "results/data/hinf_final_coherent/summary.json").read_text())

def write(name, text):
    (OUT / name).write_text(text.strip() + "\n", encoding="utf-8")

def row(values):
    return " & ".join(str(x) if isinstance(x, str) else f"{x:.6g}" for x in values) + r" \\"

rows = [
    row([r["profile"], r["gammaMixsyn"], r["gammaHinfsyn"], r["maxRealPole"]])
    for r in audit["oneDof"]
]
write("organic_hinf_diagnostics.tex", r"""
\begin{table}[H]\centering\small
\begin{tabular}{rrrr}\toprule
Profilo 1-DoF & $\gamma_{\rm mixsyn}$ & $\gamma_{\rm hinfsyn}$ & $\max\Re(p_{\rm cl})$\\\midrule
""" + "\n".join(rows) + r"""
\bottomrule\end{tabular}
\caption{Due realizzazioni dello stesso problema, poli in s$^{-1}$.
Le differenze fra le norme sono inferiori a $4\,10^{-13}$.}
\end{table}
La massima parte reale dei poli interni del 2-DoF è circa $-1.000001$
s$^{-1}$; quella di $K_\mu$ è $-0.527374$ s$^{-1}$.
Le mappe generalizzate dei due casi 1-DoF coincidono entro $10^{-11}$ sulla
griglia verificata. Non è stata ricavata una nuova banda numerica scalare.
""")

rows = []
for r in audit["structured"]:
    worst = [max(v[k] for v in r["metrics"]) for k in range(6)]
    rows.append(row([r["family"], r["order"], r["maxRealPole"]] + worst))
write("organic_structured_metrics.tex", r"""
\begin{table}[H]\centering\small
\resizebox{\textwidth}{!}{\begin{tabular}{lrrrrrrrr}\toprule
Famiglia & Ord. & $\max\Re(p_{\rm cl})$ & $T_s$ & OS (\%) & $e_{ss}$ & Cross & Picco & RMS\\\midrule
""" + "\n".join(rows) + r"""
\bottomrule\end{tabular}}
\caption{Candidato con norma minima salvata per ciascuna famiglia con almeno
una chiusura stabile. Stesso protocollo: due gradini da $5^\circ$, 12 s.
Poli in s$^{-1}$, tempi in s, comandi in N m. Statico e PI non hanno candidati
stabili nella campagna; nessuna riga è omessa per nascondere una prestazione
temporale negativa.}
\end{table}
""")

rows = []
cases = [
    ("1-DoF iniziale", summary["baseline"]["disturbanceMetrics"]),
    ("1-DoF selezionato", summary["bestOne"]["disturbanceMetrics"]),
    ("2-DoF completo", summary["selected"]["disturbanceMetrics"]),
] + [(r["family"], r["disturbanceMetrics"]) for r in audit["structured"]] + [
    ("Kmu", audit["muDisturbanceMetrics"])
]
for label, values in cases:
    rows.append(row([label] + [max(v[k] for v in values) for k in range(4)]))
write("organic_disturbance_metrics.tex", r"""
\begin{table}[H]\centering\small
\begin{tabular}{lrrrr}\toprule
Controllore & Picco $q$ [rad] & Picco $u$ [N m] & RMS $u$ [N m] & Offset [rad]\\\midrule
""" + "\n".join(rows) + r"""
\bottomrule\end{tabular}
\caption{Coppia costante di 0.5 N m, applicata separatamente ai due link.
Massimi sui due esperimenti a stato iniziale nullo, orizzonte 12 s;
offset calcolato mediante guadagno DC, RMS sull'intero orizzonte.
I dati sono quelli delle mappe nominali salvate.}
\end{table}
""")
