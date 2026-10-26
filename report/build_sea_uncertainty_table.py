"""Export the unnumbered conservative-comparison tables from executed MATLAB data."""
import csv
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
rows = list(csv.DictReader((ROOT / 'results/data/sea_incertezze_conservativa/comparison.csv').open(encoding='utf-8')))
assert len(rows) == 6
names = {'Hinf22': r'$H_\infty$ (22)', 'Mu78': r'$K_\mu$ (78)', 'MuN1_82': 'MuN1 (82)'}
lines = [r'\begin{center}\small', r'\begin{tabular}{llclll}\toprule',
         r'Controllore & Modello & NS/NP & Margine RS & Margine RP & RS/RP\\\midrule']
for r in rows:
    rs = f"$[{float(r['RS_lower']):.5g},{float(r['RS_upper']):.5g}]$"
    valid = float(r['RP_lower']) <= float(r['RP_upper'])
    rp = f"$[{float(r['RP_lower']):.5g},{float(r['RP_upper']):.5g}]$" if valid else 'non valido'
    status = 'PASS/PASS' if r['RP'] == 'PASS' else 'FAIL/FAIL'
    assert r['NS'] == r['NP'] == '1'
    lines.append(f"{names[r['Controller']]} & {r['Model'][0]} & PASS & {rs} & {rp} & {status}" + r'\\')
lines += [r'\bottomrule\end{tabular}', r'\end{center}',
          r'\begin{center}\small', r'\begin{tabular}{lrrr}\toprule',
          r'Controllore & $\|T_{zw,0}\|_\infty$ & Banda $q_1/r_1$ & Banda $q_2/r_2$\\\midrule']
for r in rows[::2]:
    lines.append(f"{names[r['Controller']]} & {float(r['NominalNorm']):.6g} & {float(r['Bandwidth1']):.5f} & {float(r['Bandwidth2']):.5f}" + r'\\')
lines += [r'\bottomrule\end{tabular}', r'\end{center}']
(ROOT / 'report/generated/sea_uncertainty_comparison.tex').write_text('\n'.join(lines)+'\n',encoding='utf-8')
