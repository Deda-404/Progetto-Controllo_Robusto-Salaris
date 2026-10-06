"""Esporta soltanto i valori LQGI gia eseguiti per le slide."""
from pathlib import Path
import json
root=Path(__file__).resolve().parents[1]
s=json.loads((root/'results/data/lqgi_validation/summary.json').read_text())
n=s['noise'][1]; r=s['ras']
values={'LqgiNoisePeak':n[1],'LqgiNoiseRms':n[2],
        'LqgiRasConvergent':r['numberConvergent'],'LqgiRasPoints':r['numberUniquePoints'],
        'LqgiRasMinimum':r['minimumRadiusDeg'],'LqgiRasCommand':r['maximumConvergentControlNm']}
out=root/'presentation/generated/coherent_review_values.tex'
out.write_text('% Source: results/data/lqgi_validation/summary.json\n'+''.join(
    f'\\newcommand{{\\{k}}}{{{v:.5g}}}\n' for k,v in values.items()),encoding='utf-8')
