"""Refresh Simulink numerical tables and evidence hashes without MATLAB synthesis."""
from pathlib import Path
import hashlib,json,re
ROOT=Path(__file__).resolve().parents[1]
s=json.loads((ROOT/'results/data/simulink_integration/summary.json').read_text())
assert s['passed'] and all(c['pass'] for c in s['checks'])
rowend=' '+chr(92)*2
comparison='\n'.join(c['kind']+' & '+' & '.join(f'{c[k]:.3g}' for k in ['maxAbsErrorQ','rmsErrorQ','maxAbsErrorU','GwError'])+rowend for c in s['controllers'])
tracking='\n'.join(f"{c['kind']} / {j} & "+' & '.join(f'{v:.4g}' if v is not None else r'$\infty$' for v in m)+rowend for c in s['controllers'] for j,m in enumerate(c['tracking'],1))
for name,body in [('comparison',comparison),('tracking',tracking)]:
 (ROOT/f'report/generated/simulink_{name}.tex').write_text(body+'\n',encoding='utf-8')
p=ROOT/'report/sections/10b_integrazione_simulink.tex';text=p.read_text(encoding='utf-8')
for columns,body in [('lrrrr',comparison),('lrrrrrr',tracking)]:
 pat=r'(\\begin\{tabular\}\{'+columns+r'\}.*?\\midrule\n).*?(\n\\bottomrule\\end\{tabular\})'
 text,n=re.subn(pat,lambda m:m[1]+body+m[2],text,count=1,flags=re.S);assert n==1
p.write_text(text,encoding='utf-8')
# TXT is an exact plain-text delivery copy of the complete Markdown report.
p=ROOT/'docs/RESOCONTO_SIMULINK_INTEGRATION.md'
p.with_suffix('.txt').write_text(p.read_text(encoding='utf-8'),encoding='utf-8')
paths=list((ROOT/'simulink').glob('*integration.m'))+list((ROOT/'simulink/models').glob('*.slx'))
paths+=list((ROOT/'results/data/simulink_integration').glob('*.mat'))
paths+=[ROOT/'results/data/simulink_integration/summary.json',ROOT/'analysis/validate_simulink_integration.m',ROOT/'tests/test_simulink_integration.m']
paths += [ROOT/'results/data'/n for n in ['m3_nominal_actuated_plant.mat','m5_performance_specs.mat','m6_lqg_no_integrator.mat','m7_augmented_cost_feasibility.mat']]
paths += [ROOT/'results/data/hinf_final_coherent'/n for n in ['selected_full_order.mat','nominal_study.mat','m13.mat']]
def evidence_hash(path):
    # Text is canonical UTF-8/LF without BOM, independent of Git autocrlf.
    data=path.read_text(encoding='utf-8-sig').encode('utf-8') if path.suffix in {'.m','.json'} else path.read_bytes()
    return hashlib.sha256(data).hexdigest()
manifest={str(p.relative_to(ROOT)).replace(chr(92),'/'):evidence_hash(p) for p in paths}
(ROOT/'results/data/simulink_integration/manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
print(f'{len(manifest)} evidence hashes; tables refreshed from {len(s["checks"])} passing checks.')
