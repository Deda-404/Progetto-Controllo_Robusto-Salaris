"""Audit di main/PR43; nessuna modifica dei sorgenti o dei dati scientifici.

Uso: python tools/inventario_ristrutturazione.py snapshot|finalize
La classificazione riguarda il futuro pacchetto: ARCHIVIATO significa
conservato nel repository ma escluso dalla consegna minima proposta.
"""
import collections
import csv
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs" / "audit_ristrutturazione"
OUT.mkdir(exist_ok=True)
PR = "origin/pr-43"


def git(*args):
    return subprocess.check_output(["git", "-C", str(ROOT), *args])


def tree(ref):
    result = {}
    for record in git("ls-tree", "-rlz", ref).split(b"\0"):
        if record:
            meta, name = record.split(b"\t", 1)
            mode, kind, sha, size = meta.decode().split()
            result[name.decode()] = {"blob": sha, "bytes": int(size)}
    return result


def dump(name, data):
    (OUT / name).write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


main = tree("origin/main")
pr = tree(PR)
if sys.argv[1] == "snapshot":
    hashes = {p: hashlib.sha256((ROOT / p).read_bytes()).hexdigest() for p in main}
    dump("integrita_prima.json", hashes)
    scratch = Path(tempfile.gettempdir()) / "sea_audit_20261025_pr43"
    scratch.mkdir(exist_ok=True)
    selected = []
    for p in pr:
        changed = p not in main or pr[p]["blob"] != main[p]["blob"]
        if changed and (Path(p).suffix in {".m", ".csv", ".md", ".tex", ".py"} or p.endswith(".pdf")):
            target = scratch / p
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(git("show", f"{PR}:{p}"))
            selected.append(p)
    # Dipendenza letta da build_salaris_models; il test non e autonomo senza M5.
    (scratch / "results/data").mkdir(parents=True, exist_ok=True)
    shutil.copyfile(ROOT / "results/data/m5_performance_specs.mat",
                    scratch / "results/data/m5_performance_specs.mat")
    dump("materiale_pr43.json", {"head": git("rev-parse", PR).decode().strip(),
        "extracted_to_temporary_directory": str(scratch), "files": selected})
    print(f"Snapshot: {len(hashes)} file baseline; {len(selected)} file PR letti in area temporanea.")
    sys.exit(0)

assert sys.argv[1] == "finalize"
dependencies = json.loads((OUT / "dipendenze_matlab.json").read_text(encoding="utf-8-sig"))
deps = {p for entry in dependencies for p in
        ([entry["files"]] if isinstance(entry["files"], str) else entry["files"])}
known_mat = {
    "m3_nominal_actuated_plant.mat", "m5_performance_specs.mat", "m6_lqg_no_integrator.mat",
    "m7_augmented_cost_feasibility.mat", "m4_uncertain_plant.mat", "nominal_study.mat",
    "selected_full_order.mat", "fixed_PID.mat", "m13.mat", "m12.mat", "m14.mat", "robust_study.mat",
    "m7_disturbance_comparison.mat", "m8_lqg_nonlinear_ras.mat", "m15_nonlinear_robust_validation.mat",
    "lyapunov_ras_nominal.mat", "m10_hinfsyn_nominal.mat", "m13_musyn_dk.mat",
    "hinf_noise_03.mat", "mu_noise_01.mat",
}
mat_candidates = []
for p in sorted(deps):
    source = (ROOT / p).read_text(encoding="utf-8-sig")
    for name in re.findall(r"['\"]([^'\"\n]*\.mat)['\"]", source):
        mat_candidates.append({"source": p, "literal": name, "certainty": "literal; inspect load/save and branch"})
dump("riferimenti_mat.json", mat_candidates)

rows = []
for p in sorted(main.keys() | pr.keys()):
    suffix = Path(p).suffix.lower()
    changed = p in main and p in pr and main[p]["blob"] != pr[p]["blob"]
    origin = "MAIN+PR_MODIFICATO" if changed else "MAIN+PR" if p in main and p in pr else "SOLO_PR43" if p in pr else "SOLO_MAIN"
    action, reason = "ARCHIVIATO", "Storia e supporto di sviluppo; conservare nel repository, non necessario al percorso minimo."
    target = "repository storico"
    if p.startswith("File_di_Funzioni_Progetto-Accorpati/") and suffix == ".m":
        action, reason, target = "ACCORPATO", "Procedimento didattico da distribuire nei sei script, eliminando i rinvii al repository.", "02 / 03 / 04 / 05"
    elif p in {"src/model/sea_nonlinear_rhs.m", "src/model/sea_link_inertia.m", "src/model/sea_coriolis.m", "src/model/sea_gravity.m", "src/model/sea_elastic_torque.m"}:
        action, reason, target = "CONSERVATO", "Fisica SEA necessaria: riuso matematico verificato, eventuale raccolta in un solo ausiliario.", "dinamica_sea.m"
    elif p in deps and suffix == ".m":
        action, reason, target = "ACCORPATO", "Dipendenza statica effettiva: integrare formule semplici; conservare separata solo matematica non lineare necessaria.", "script numerati / ausiliari essenziali"
    elif p.startswith("src/parameters/") and suffix == ".m":
        action, reason, target = "ACCORPATO", "Parametri e ipotesi da riunire in una fonte unica, preservando valori approvati.", "parametri_sea.m"
    elif p.startswith("analysis/progetto_") and suffix == ".m":
        action, reason = "ARCHIVIATO", "Ingresso storico o copia; conservare per riprodurre la baseline, usare i nuovi numerati nella consegna."
    elif p.startswith("analysis/uncertainty/") and p in pr and p not in main:
        action, reason, target = "SEMPLIFICATO", "PR43: selezionare formule e verifiche; non importare la catena di runner o le nuove scelte senza approvazione.", "01 / 04 / 05"
    elif p in {"src/actuators/build_manual_parametric_actuator.m", "src/uncertainty/build_manual_mechanical_lft.m"}:
        action, reason, target = "SEMPLIFICATO", "LFT manuale utile; adattare solo dopo decisione su parametri, meccanica e residuo.", "01_MODELLI_INCERTEZZE.m"
    elif p.startswith("report/sections/") and p in main:
        action, reason, target = "SEMPLIFICATO", "Base principale da riorganizzare, preservando risultati, limiti e tracciabilita.", "relazione in 12 capitoli"
    elif p == "report/sections/salaris_revision.tex":
        action, reason, target = "SEMPLIFICATO", "Fonte PR43 da selezionare criticamente, senza sostituire la relazione di main.", "capitoli incertezze / confronto"
    elif p.startswith("report/figures/schemes/") and p not in main:
        action, reason, target = "SEMPLIFICATO", "Schema PR43 da allineare alle convenzioni A parametrico / B concentrato e alle scelte approvate.", "schemi riproducibili"
    elif p.startswith("simulink/") and suffix == ".slx":
        action, reason, target = "CONSERVATO", "Originale di riferimento: vietati modifica, risalvataggio e riorganizzazione; integrazione futura degli studenti.", "riferimento immutato"
    elif p.startswith("results/data/") and suffix == ".mat" and Path(p).name in known_mat and (len(Path(p).parts)==3 or "hinf_final_coherent" in p or "/noise_redesign/" in p):
        action, reason, target = "CONSERVATO", "Dataset letto dai quattro ingressi o necessario alla banca consolidata; estrarre successivamente solo le variabili utili.", "banca minima portabile"
    elif p.startswith("results/data/salaris_revision/"):
        action, reason = "ARCHIVIATO", "Evidenza valida solo per le famiglie PR43; non trasferibile ai futuri A/B semplificati."
    elif p in {"report/main.tex", "presentation/main.tex", "presentation/OUTLINE_AND_TIMING.md", "presentation/SPEAKER_NOTES.md", "presentation/Presentazione_orale.txt", "README.md"}:
        action, reason, target = "SEMPLIFICATO", "Riorganizzare da main attorno al confronto delle incertezze, mantenendo evidenze e limiti.", "elaborati e LEGGIMI"
    elif p in {"AGENTS.md", "docs/DECISION_LOG.md", "docs/DIARIO_DI_BORDO.md", "docs/PROJECT_STATUS.md", "CHANGELOG.md"}:
        action, reason, target = "CONSERVATO", "Regole e cronologia; aggiornamento append-only ove richiesto, senza cancellare decisioni precedenti.", "repository"
    elif p.startswith("tests/"):
        action, reason = "CONSERVATO", "Regressione storica utile a proteggere i risultati; pacchetto minimo con sole verifiche pertinenti."
    rows.append({"File": p, "Origine": origin, "Azione_proposta": action,
        "Motivazione": reason, "Destinazione_proposta": target,
        "Dipendenza_statica_quattro_script": p in deps,
        "Blob_main": main.get(p, {}).get("blob", ""), "Blob_PR43": pr.get(p, {}).get("blob", ""),
        "Byte_main": main.get(p, {}).get("bytes", ""), "Byte_PR43": pr.get(p, {}).get("bytes", "")})
with (OUT / "inventario_file.csv").open("w", encoding="utf-8-sig", newline="") as stream:
    writer = csv.DictWriter(stream, fieldnames=list(rows[0])); writer.writeheader(); writer.writerows(rows)

# Duplicati esatti nel contenuto Git e duplicati testuali dopo normalizzazione CRLF.
by_blob = collections.defaultdict(list)
normalized = collections.defaultdict(list)
for p, info in main.items():
    by_blob[info["blob"]].append(p)
    if Path(p).suffix == ".m":
        content = (ROOT / p).read_bytes().replace(b"\r\n", b"\n")
        normalized[hashlib.sha256(content).hexdigest()].append(p)
dump("duplicati.json", {"git_identical": [v for v in by_blob.values() if len(v)>1],
    "matlab_normalized_identical": [v for v in normalized.values() if len(v)>1]})

# Grafo lessicale conservativo: un arco non prova esecuzione; assenza non prova inutilita.
paths = {p for p in main.keys() | pr.keys() if p.endswith(".m")}
by_name = collections.defaultdict(list)
for p in paths:
    by_name[Path(p).stem].append(p)
edges = []
for p in sorted(paths):
    source = (ROOT / p).read_text(encoding="utf-8-sig") if p in main else git("show", f"{PR}:{p}").decode("utf-8-sig")
    calls = set(re.findall(r"\b[A-Za-z]\w*\b", source)) & by_name.keys()
    for name in sorted(calls):
        for destination in by_name[name]:
            if destination != p:
                edges.append({"Source": p, "Candidate_dependency": destination})
with (OUT / "grafo_lessicale.csv").open("w", encoding="utf-8-sig", newline="") as stream:
    writer=csv.DictWriter(stream,fieldnames=["Source","Candidate_dependency"]);writer.writeheader();writer.writerows(edges)
before = json.loads((OUT / "integrita_prima.json").read_text(encoding="utf-8"))
changed_files = [p for p, sha in before.items() if hashlib.sha256((ROOT / p).read_bytes()).hexdigest()!=sha]
allowed_docs = {"README.md", "CHANGELOG.md", "docs/DECISION_LOG.md",
                "docs/DIARIO_DI_BORDO.md", "docs/PROJECT_STATUS.md"}
unexpected = sorted(set(changed_files) - allowed_docs)
git_changed = git("diff", "--name-only", "origin/main").decode().splitlines()
unexpected_git = sorted(set(git_changed) - allowed_docs)
dump("integrita_dopo.json", {"checked":len(before),"changed":changed_files,
    "authorized_documentation_changes":sorted(set(changed_files) & allowed_docs),
    "unexpected_changes":unexpected,"unexpected_git_changes":unexpected_git,
    "mat_slx_checked":sum(Path(p).suffix in {".mat",".slx"} for p in before),
    "all_slx_checked":sum(p.endswith('.slx') for p in before),
    "scientific_matlab_checked":sum(p.endswith('.m') for p in before),
    "pass":not unexpected and not unexpected_git})
counts = collections.Counter(r["Azione_proposta"] for r in rows)
summary={"baseline":git("rev-parse","origin/main").decode().strip(),
    "pr43":git("rev-parse",PR).decode().strip(),"main_files":len(main),"pr_files":len(pr),
    "union_files":len(rows),"main_matlab":sum(p.endswith('.m') for p in main),
    "main_mat":sum(p.endswith('.mat') for p in main),"main_slx":sum(p.endswith('.slx') for p in main),
    "changed_pr_files":sum(p not in main or pr[p]['blob']!=main[p]['blob'] for p in pr),
    "actions":dict(counts),"static_dependency_union":len(deps),"lexical_edges":len(edges),
    "no_deletion":True,"classification_status":"PROPOSTA, nessuna operazione sui file storici"}
dump("riepilogo_inventario.json",summary)
print(json.dumps(summary,ensure_ascii=False))
if unexpected or unexpected_git:
    raise SystemExit("FAIL: baseline scientifica cambiata: "+str(unexpected+unexpected_git))
