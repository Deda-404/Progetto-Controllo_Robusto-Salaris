"""Verifica nomenclatura corrente, dipendenze LaTeX e integrita del baseline."""
from pathlib import Path
import csv
import hashlib
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'docs/coherent_review'
OUT.mkdir(parents=True, exist_ok=True)


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def listed_files():
    names = subprocess.check_output(
        ['git', '-c', 'core.quotepath=false', 'ls-files', '-c', '-o', '--exclude-standard'],
        cwd=ROOT, text=True, encoding='utf-8').splitlines()
    return sorted({n for n in names if (ROOT / n).is_file()})


def main():
    names = listed_files()
    baseline = json.loads((OUT / 'baseline_inventory.json').read_text(encoding='utf-8'))
    protected = []
    for row in baseline:
        n = row['path']
        if (n.startswith('results/data/hinf_final_coherent/') or
                re.match(r'results/data/m[1-6]_.*\.mat$', n) or
                n.startswith('simulink/originals/') and n.endswith('.slx')):
            current = digest(ROOT / n)
            protected.append({'path': n, 'baselineSha256': row['sha256'],
                              'currentSha256': current, 'unchanged': current == row['sha256']})
    assert all(r['unchanged'] for r in protected), 'Un artifact protetto e stato modificato.'
    originals = json.loads((ROOT / 'simulink/originals/manifest.json').read_text())
    assert len(originals) == 6
    for row in originals:
        assert digest(ROOT / 'simulink/originals' / row['file']) == row['sha256']

    occurrences, active_errors = [], []
    active_roots = ('analysis/', 'controllers/', 'src/', 'tests/', 'tools/',
                    'presentation/', 'report/sections/', 'simulink/')
    archived_names = re.compile(r'Progetto_LQRI_simulink|LQRI_(?:linear|nonlinear)_sim', re.I)
    for n in names:
        p = ROOT / n
        if p.suffix.lower() not in ('.m', '.tex', '.py', '.md', '.txt', '.json', '.csv', '.ps1'):
            continue
        if n.startswith('docs/coherent_review/') or n == 'tools/audit_coherent_revision.py':
            continue
        active = n.startswith(active_roots) or n in ('README.md', 'report/main.tex', 'run_all.m')
        for line_number, line in enumerate(p.read_text(encoding='utf-8-sig', errors='replace').splitlines(), 1):
            found = re.findall(r'(?i)\bLQRI\b|\blqri_[\w]+|\bLQI\b', line)
            if not found:
                continue
            classification = 'storico / risultato non adottato'
            if active:
                classification = 'nome originale SLX conservato per provenienza'
                residue = archived_names.sub('', line)
                if n == 'tools/build_hinf_revision_report.py':
                    classification = 'generatore storico disabilitato nella CLI'
                elif re.search(r'(?i)\bLQRI\b|\blqri_[\w]+|\bLQI\b', residue):
                    classification = 'ERRORE: nomenclatura attiva incoerente'
                    active_errors.append((n, line_number))
            occurrences.append([n, line_number, ', '.join(sorted(set(found))), classification])
    with (OUT / 'nomenclature_occurrences.csv').open('w', encoding='utf-8', newline='') as stream:
        writer = csv.writer(stream)
        writer.writerow(['File', 'Line', 'Terms', 'Classification'])
        writer.writerows(occurrences)
    assert not active_errors, active_errors

    inputs, assets, missing = [], [], []
    seen = set()

    def inspect(n, base):
        p = ROOT / n
        if n in seen:
            return
        seen.add(n)
        source = re.sub(r'(?m)(?<!\\)%.*$', '', p.read_text(encoding='utf-8-sig'))
        pattern = r'\\(input|includegraphics|lstinputlisting)(?:\[[^\]]*\])?\{([^{}]+)\}'
        for kind, target in re.findall(pattern, source):
            candidate = base / target
            if kind == 'input' and candidate.suffix != '.tex':
                candidate = candidate.with_suffix('.tex')
            if not candidate.is_file():
                missing.append({'source': n, 'target': target})
                continue
            relative = candidate.resolve().relative_to(ROOT.resolve()).as_posix()
            record = {'source': n, 'kind': kind, 'path': relative, 'sha256': digest(candidate)}
            inputs.append(record)
            if kind == 'includegraphics':
                assets.append(record)
            elif kind == 'input':
                inspect(relative, base)

    inspect('report/main.tex', ROOT / 'report')
    inspect('presentation/main.tex', ROOT / 'presentation')
    assert not missing, missing
    slides = (ROOT / 'presentation/main.tex').read_text(encoding='utf-8')
    assert slides.count('\\begin{frame}') == 19
    timing = (ROOT / 'presentation/OUTLINE_AND_TIMING.md').read_text(encoding='utf-8')
    seconds = sum(int(m) * 60 + int(s) for m, s in re.findall(r'\| (\d+):(\d+) \|', timing))
    assert seconds == 17 * 60 + 45
    report = {'status': 'PASS', 'filesInventoried': len(names),
              'protectedArtifacts': protected, 'originalSlxCount': len(originals),
              'activeNamingErrors': active_errors, 'classifiedOccurrences': len(occurrences),
              'latexInputs': inputs, 'figureAssets': assets, 'missingInputs': missing,
              'slides': 19, 'plannedTalkSeconds': seconds,
              'numericSources': ['results/data/lqgi_validation/validation.mat',
                                'results/data/lqgi_validation/ras.mat',
                                'results/data/coherent_review/omegaM_comparison.mat',
                                'results/data/hinf_final_coherent/'],
              'historicalManifests': ['report/generated/figure_manifest.mat',
                                      'results/data/organic_review/', 'results/data/lqri_r_verification.mat']}
    (OUT / 'coherence_audit.json').write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding='utf-8')
    print(f"PASS: {len(names)} files, {len(protected)} protected artifacts unchanged; "
          f"{len(inputs)} LaTeX dependencies, {len(assets)} figures, 19 slides, 17:45.")


if __name__ == '__main__':
    main()
