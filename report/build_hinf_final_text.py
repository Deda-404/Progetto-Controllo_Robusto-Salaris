"""Reporting only: formats MATLAB's summary.json; performs no control calculation."""
from pathlib import Path
import json
import hashlib

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / 'results/data/hinf_final_coherent'
REPORT = ROOT / 'report'

def n(x):
    return '---' if x is None else f'{x:.6g}'

def main():
    s = json.loads((DATA / 'summary.json').read_text())
    macros = {'FinalGamma': s['selected']['gamma'], 'FinalOrder': s['selected']['order'],
              'FinalMuGamma': s['mu']['norms'][0], 'FinalMuOrder': s['mu']['order'],
              'FinalMuObjective': s['mu']['objective'], 'FinalMinOrder': s['minimumObservedOrder']}
    for prefix, key in [('FinalH', 'hinfRobust'), ('FinalMu', 'muRobust')]:
        for kind in ['RS', 'RP']:
            for side in ['LowerBound', 'UpperBound']:
                macros[prefix + kind + side] = s[key][kind][side]
    (REPORT / 'generated/hinf_final_values.tex').write_text(
        '% Source: MATLAB export_hinf_final_results, summary.json\n' +
        ''.join('\\newcommand{\\' + k + '}{' + n(v) + '}\n' for k, v in macros.items()), encoding='utf-8')
    rows = []
    for label, key in [('1-DoF iniziale', 'baseline'), ('1-DoF selezionato', 'bestOne'), ('2-DoF selezionato', 'selected')]:
        r = s[key]
        worst = [max(row[i] for row in r['metrics']) for i in range(6)]
        rows.append(label + ' & ' + n(r['gamma']) + ' & ' + str(r['order']) + ' & ' + ' & '.join(map(n, worst)) + r' \\')
    (REPORT / 'generated/hinf_final_tracking.tex').write_text(
        '\\begin{tabular}{lrrrrrrrr}\n\\toprule\nCaso & Norma & Ord. & $T_s$ & OS (\\%) & $e_{ss}$ & Cross & Picco & RMS \\\\\n\\midrule\n' +
        '\n'.join(rows) + '\n\\bottomrule\n\\end{tabular}\n', encoding='utf-8')
    rows = []
    for f in s['fixed']:
        rows.append(f['name'] + ' & ' + str(f['starts']) + ' & ' + str(f['stable']) + ' & ' + str(f['NP']) + ' & ' + n(f['bestNorm']) + r' \\')
    (REPORT / 'generated/hinf_final_fixed.tex').write_text(
        '\\begin{tabular}{lrrrr}\n\\toprule\nFamiglia & Avvii & NS & NP & Migliore norma \\\\\n\\midrule\n' +
        '\n'.join(rows) + '\n\\bottomrule\n\\end{tabular}\n', encoding='utf-8')
    manifest = {'source': 'results/data/hinf_final_coherent/summary.json',
                'producer': 'analysis/export_hinf_final_results.m', 'macros': macros,
                'frozen': 'M0--M8; original MAT files retained', 'branchBase': s['baseCommit']}
    (REPORT / 'generated/hinf_final_traceability.json').write_text(json.dumps(manifest, indent=2), encoding='utf-8')
    paths = list(DATA.rglob('*')) + list((REPORT / 'figures/hinf_final').rglob('*'))
    paths += list((REPORT / 'generated').glob('hinf_final*'))
    paths = sorted(p for p in paths if p.is_file() and p.name != 'hinf_final_manifest.json')
    manifest = {'baseCommit': s['baseCommit'], 'files': [
        {'path': p.relative_to(ROOT).as_posix(), 'sha256': hashlib.sha256(p.read_bytes()).hexdigest(),
         'bytes': p.stat().st_size} for p in paths]}
    (REPORT / 'generated/hinf_final_manifest.json').write_text(json.dumps(manifest, indent=2), encoding='utf-8')

if __name__ == '__main__':
    main()
