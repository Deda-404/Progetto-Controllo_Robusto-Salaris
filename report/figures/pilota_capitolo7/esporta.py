"""Figure del solo capitolo 7 dai dati già salvati; nessuna sintesi o simulazione.

Richiede numpy, scipy e matplotlib soltanto nell'ambiente di impaginazione.
Non scrive nei sorgenti MATLAB, negli SLX o nelle cartelle dei risultati.
"""
from pathlib import Path
import csv
import hashlib
import json
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from scipy.io import loadmat
from scipy.integrate import cumulative_trapezoid

OUT = Path(__file__).resolve().parent
ROOT = OUT.parents[2]
DATA = ROOT / "File_di_Funzioni_Progetto-Accorpati/risultati"
GEN = ROOT / "report/generated"
plt.rcParams.update({"font.size": 10, "axes.grid": True,
                     "figure.facecolor": "white", "savefig.facecolor": "white"})
l = loadmat(DATA / "lqg.mat", simplify_cells=True)["lqg"]
li = loadmat(DATA / "lqgi.mat", simplify_cells=True)["lqgi"]
m = loadmat(DATA / "modello.mat", simplify_cells=True)["modello"]
responses = loadmat(DATA / "confronto.mat", simplify_cells=True,
                    variable_names=["risposte"])["risposte"]
with (DATA / "kalman.csv").open(encoding="utf-8-sig") as f:
    kalman = list(csv.DictReader(f))
with (DATA / "dieci_impianti.csv").open(encoding="utf-8-sig") as f:
    nominal = [r for r in csv.DictReader(f) if r["Impianto"] == "0"
               and r["Controllore"] in {"LQG", "LQGI"}]

def save(fig, name):
    fig.tight_layout()
    fig.savefig(OUT / (name + ".png"), dpi=190)
    plt.close(fig)

fig, ax = plt.subplots(figsize=(7, 3.6))
ax.bar(["Posizione", "Velocità link", "Deformazione", "Velocità motore"],
       [2, 1, .1, 1], color=["#24678c", "#679fbc", "#d98b36", "#679fbc"])
ax.set_ylabel("Priorità adimensionale"); ax.set_ylim(0, 2.3)
save(fig, "priorita_costo")

fig, ax = plt.subplots(figsize=(6.8, 3.6))
for r in nominal:
    x, y = float(r["Assestamento"]), float(r["PiccoComando"])
    ax.scatter(x, y, s=75)
    ax.annotate(r["Controllore"], (x, y), xytext=(9, 7), textcoords="offset points")
ax.axvline(2, color="black", ls="--", lw=1, label="Target di 2 s")
ax.set(xlabel="Assestamento peggiore sui due giunti [s]",
       ylabel="Picco del comando di tracking [N m]", xlim=(0, 6.2), ylim=(0, 5.6))
ax.legend(); save(fig, "compromesso_nominale")

fig, axs = plt.subplots(1, 3, figsize=(10.2, 3.5))
x = [float(r["FattoreSigmaAssunta"]) for r in kalman]
for ax, key, label in zip(axs, ["PoloOsservatore", "ErroreStimaRMS", "ComandoRMS"],
                         ["Polo lento [1/s]", "Errore di stima RMS [rad]", "Comando RMS [N m]"]):
    ax.plot(x, [float(r[key]) for r in kalman], "o-", color="#24678c")
    ax.axvline(1, color="black", lw=.8, ls="--")
    ax.set(xlabel="Fattore della sigma assunta", ylabel=label)
save(fig, "kalman_sensibilita")

A, B, C, K, L = [np.asarray(v, dtype=float) for v in
                  (m["Afull"], m["Bfull"], m["Cfull"], l["Kstato"], l["L"])]
Acl = np.block([[A, -B @ K], [L @ C, A - B @ K - L @ C]])
transform = np.block([[np.eye(14), np.zeros((14,14))], [np.eye(14), -np.eye(14)]])
triangular = np.block([[A-B@K, B@K], [np.zeros((14,14)), A-L@C]])
assert np.linalg.norm(transform@Acl@transform-triangular) < 1e-8
assert np.max(np.linalg.eigvals(Acl).real) < 0
poles = {"Regolatore": np.linalg.eigvals(A-B@K),
         "Kalman": np.linalg.eigvals(A-L@C), "Chiusura LQG": np.linalg.eigvals(Acl)}
fig, ax = plt.subplots(figsize=(7.8, 4.2))
for (name, values), marker in zip(poles.items(), ["o", "+", "x"]):
    ax.scatter(values.real, values.imag, marker=marker, label=name, s=55)
ax.axvline(0, color="black", lw=.8)
ax.set(xlabel="Parte reale [1/s]", ylabel="Parte immaginaria [1/s]")
ax.legend(); save(fig, "poli_lqg")

t = np.linspace(0, 12, responses[0, 0].shape[0])
fig, axs = plt.subplots(2, 1, figsize=(8, 5.4))
for axis, ax in enumerate(axs):
    q = responses[0, 0][:, :2, axis]
    ax.plot(t, np.rad2deg(q[:, 0]), label="q1")
    ax.plot(t, np.rad2deg(q[:, 1]), label="q2")
    ax.axhline(5, color="black", ls="--", label="Riferimento comandato")
    ax.set(xlabel="Tempo [s]", ylabel="Deviazione [gradi]", title=f"Gradino al giunto {axis+1}")
    ax.legend(ncol=3)
save(fig, "lqg_tracking")

fig, axs = plt.subplots(3, 2, figsize=(10, 8))
for axis in range(2):
    y = responses[1, 0][:, :, axis]
    ref = np.zeros((len(t), 2)); ref[:, axis] = np.deg2rad(5)
    xi = cumulative_trapezoid(ref-y[:, :2], t, axis=0, initial=0)
    for row, values, label in [(0, np.rad2deg(y[:, :2]), "Posizione [gradi]"),
                                (1, y[:, 2:4], "Comando [N m]"),
                                (2, xi, "Integrale ricostruito [rad s]")]:
        ax = axs[row, axis]
        ax.plot(t, values[:, 0], label="Canale 1")
        ax.plot(t, values[:, 1], label="Canale 2")
        ax.set(xlabel="Tempo [s]", ylabel=label)
        if row == 0:
            ax.axhline(5, ls="--", color="black", lw=.8)
            ax.set_title(f"Riferimento al giunto {axis+1}")
        if row == 1: ax.legend()
save(fig, "lqgi_tracking_integrale")

def matrix(a):
    return r"\begin{bmatrix}" + "\\\\\n".join(
        " & ".join(f"{v:.5g}" for v in row) for row in np.atleast_2d(a)) + r"\end{bmatrix}"

parts = ["% Esportazione editoriale dai MAT correnti, nessuna sintesi.\n"]
parts.append(r"\[Q=\operatorname{blkdiag}(Q_8,0_{6\times6}),\quad R=0.1 I_2.\]")
parts.append(r"{\small\[Q_8=" + matrix(l["Q"][:8,:8]) + r".\]}")
for symbol, value in [("K", K), ("N_r", l["Nr"])]:
    if value.shape[1] > 7:
        parts.append(r"\[" + symbol + r"=[" + symbol + r"_a\;" + symbol + r"_b].\]")
        for suffix, piece in [("a", value[:,:7]), ("b", value[:,7:])]:
            parts.append(r"{\small\["+symbol+"_"+suffix+"="+matrix(piece)+r".\]}")
    else: parts.append(r"\["+symbol+"="+matrix(value)+r".\]")
(GEN/"pilota7_lqr.tex").write_text("\n".join(parts)+"\n", encoding="utf8")
(GEN/"pilota7_kalman.tex").write_text(r"{\small\[L="+matrix(L)+r".\]}"+"\n",encoding="utf8")
parts=[]
for symbol, value in [("K_x", li["Kx"]), ("K_i", li["Ki"])]:
    if value.shape[1] > 7:
        parts.append(r"\[K_x=[K_{x,a}\;K_{x,b}].\]")
        for suffix, piece in [("a", value[:,:7]), ("b", value[:,7:])]:
            parts.append(r"{\small\[K_{x,"+suffix+"}="+matrix(piece)+r".\]}")
    else: parts.append(r"\["+symbol+"="+matrix(value)+r".\]")
(GEN/"pilota7_lqgi.tex").write_text("\n".join(parts)+"\n",encoding="utf8")
inputs=["lqg.mat","lqgi.mat","modello.mat","confronto.mat","kalman.csv","dieci_impianti.csv"]
provenance={"input_sha256":{n:hashlib.sha256((DATA/n).read_bytes()).hexdigest() for n in inputs},
            "operazioni":["lettura dati salvati", "disegno curve salvate", "autovalori delle matrici salvate",
                          "quadratura trapezoidale dell'errore salvato per illustrare xi"],
            "nuove_sintesi":False,"nuove_simulazioni":False,
            "alpha_regolatore":float(-max(poles["Regolatore"].real)),
            "alpha_kalman":float(-max(poles["Kalman"].real))}
(OUT/"provenienza.json").write_text(json.dumps(provenance,indent=2)+"\n",encoding="utf8")
print("Sei figure e tre estratti di matrici dai dati correnti; dati originali invariati.")
