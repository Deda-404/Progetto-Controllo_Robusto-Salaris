"""Formatta esclusivamente numeri esportati da MATLAB, senza nuovi calcoli di controllo."""
from pathlib import Path
import json,math,collections
ROOT=Path(__file__).resolve().parents[1]
DATA=ROOT/'results/data/final_closure'
OUT=ROOT/'report/generated'
def num(x,digits=3):
    if x is None or not math.isfinite(x):return '--'
    value=f'{x:.{digits}g}'
    if 'e' in value:
        a,b=value.split('e');return r'\ensuremath{'+a+r'\times10^{'+str(int(b))+'}}'
    return value
def label(x):return {'Hinf1':r'$H_\infty$ 1-DoF','Hinf2':r'$H_\infty$ 2-DoF','Kmu':r'$K_\mu$'}.get(x,x)
def table(name,columns,header,rows,caption):
    text=r'\begin{table}[htbp]\centering\small'+'\n'+r'\resizebox{\textwidth}{!}{\begin{tabular}{'+columns+'}'+r'\toprule'+'\n'
    text+=header+r'\\\midrule'+'\n'
    text+='\n'.join(' & '.join(str(x) for x in row)+r'\\' for row in rows)
    text+='\n'+r'\bottomrule\end{tabular}}'+'\n'+r'\caption{'+caption+'}\n'+r'\end{table}'+'\n'
    (OUT/name).write_text(text,encoding='utf-8')
def interval(rows,key,factor=1):
    values=[r[key]*factor for r in rows if r[key] is not None and math.isfinite(r[key])]
    if not values:return '--'
    lo,hi=min(values),max(values)
    return num(lo) if abs(hi-lo)<1e-12 else num(lo)+'--'+num(hi)

def main():
    d=json.loads((DATA/'summary.json').read_text(encoding='utf-8'))
    assert d['orders']==[14,16,18,22,4,78]
    noise=d['noise'];noiseRows=[]
    macros={'NoiseHinfPeak':noise[3]['intersamplePeakU'],'NoiseHinfRms':noise[3]['intersampleRmsU'],
            'NoiseMuPeak':noise[5]['intersamplePeakU'],'NoiseMuRms':noise[5]['intersampleRmsU']}
    for n in noise:
        m=next(r for r in d['noiseMetrics'] if r['Controller']==n['name'] and r['Scenario']=='measurement')
        noiseRows.append([label(n['name']),num(n['DkyNorm']),num(m['PeakU']),num(m['RmsU']),
                          num(n['intersamplePeakU']),num(n['intersampleRmsU']),num(n['intersamplePeakDelay'])])
    table('final_noise_table.tex','lrrrrrr',r'Controllore & $\|D_y\|_2$ & Picco camp. & RMS camp. & Picco fra camp. & RMS integrato & Ritardo picco [s]',noiseRows,
          r'Rumore encoder isolato: $r=d=w=0$, $\sigma_y=0.05^\circ$, $T_s=2$ ms, 4 s. Comando in N m. Il picco fra campioni è il massimo osservato sulla scansione temporale; l\textquotesingle RMS integra la propagazione ZOH.')
    plants=d['practicalPlants'];assert len(plants)==10
    table('final_plants_table.tex','rrrrrr',r'Impianto & $k_1$ & $k_2$ & $J_{m1}$ & $\|\Delta_{a1}\|_\infty$ & $\|\Delta_{a2}\|_\infty$',
          [[r['Plant'],num(r['k1'],5),num(r['k2'],5),num(r['Jm1'],5),num(r['Delta1HinfNorm'],5),num(r['Delta2HinfNorm'],5)] for r in plants],
          r'Dieci realizzazioni comuni, seed 20261012. Rigidezze in N m/rad, inerzia in kg m$^2$; norme dinamiche adimensionali. Ogni blocco dinamico ha ordine 3.')
    pr=d['practicalMetrics'];prRows=[];distRows=[]
    for name in ['Hinf2','Kmu']:
        for nominal in [True,False]:
            rr=[r for r in pr if r['Controller']==name and (r['Plant']==0)==nominal]
            st=[r for r in rr if r['Stable']]; unique=len(set(r['Plant'] for r in st));total=1 if nominal else 10
            recovery='--'
            if st:
                missing=sum(r['RecoveryTime'] is None for r in st)
                recovery=interval(st,'RecoveryTime')
                if missing:recovery+=f'; NR {missing}/{len(st)}'
            prRows.append([label(name)+' '+('nom.' if nominal else 'inc.'),f'{unique}/{total}',
                           interval(st,'SettlingTime'),interval(st,'OvershootPercent'),interval(st,'FinalErrorRelative',100),
                           interval(st,'CrossCoupling',100)])
            distRows.append([label(name)+' '+('nom.' if nominal else 'inc.'),interval(st,'DisturbancePeakQ',180/math.pi),
                             recovery,interval(st,'DisturbanceResidualQ',180/math.pi),interval(st,'DisturbancePeakU'),interval(st,'DisturbanceRmsU')])
    table('final_practical_table.tex','lrrrrr',r'Controllore & Stabili & $T_s$ [s] & OS [\%] & Errore DC [\%] & Accoppiamento [\%]',prRows,
          r'Tracking: nominali e intervalli sui dieci impianti incerti, per le due prove articolari. Prestazioni valutate solo se la chiusura è stabile. L\textquotesingle assestamento è rispetto al valore DC analitico, non al riferimento ideale.')
    table('final_practical_disturbance_table.tex','lrrrrr',r'Controllore & Picco $q$ [$^\circ$] & Recupero [s] & Residuo $q(8)$ [$^\circ$] & Picco $u$ [N m] & RMS $u$ [N m]',distRows,
          r'Disturbo link: nominali e intervalli sui campioni stabili, due prove da 0.5 N m. NR indica recupero non raggiunto nella fascia $\pm0.5^\circ$ entro 8 s; il tempo è contato dall\textquotesingle applicazione della coppia a 1 s. RMS sui due comandi e sull\textquotesingle intero orizzonte.')
    ras=d['rasMetrics'];assert len(ras)==150
    rows=[];counts={}
    for proof in d['lyapunov']:
        name=proof['name'];rr=[r for r in ras if r['Controller']==name];assert len(rr)==25
        statuses=collections.Counter(r['Status'] for r in rr);ok=sum(r['Converged'] for r in rr)
        non=statuses['FINITE_HORIZON_NONCONVERGENT'];unknown=25-ok-non
        counts[name]={'converged':ok,'finite_horizon_nonconvergent':non,'numerical_or_solver_unknown':unknown,'statuses':dict(statuses)}
        rows.append([label(name),proof['n'],f'{ok}/25',non,unknown,num(proof['residual']),
                     'PASS' if proof['gatePassed'] else 'FAIL',num(proof['rhoCertified'])])
    table('final_ras_table.tex','lrrrrrrr',r'Controllore & Stati & Conv. & Non conv. & Numerici & Residuo & Gate & $\rho$',rows,
          r'Stessa griglia e orizzonte 12 s. Non conv.: criterio finale non raggiunto; numerici: arresti per ampiezza, solver o limite di 60 s di calcolo per punto. Il gate riguarda positività, residuo e arrotondamento; $\rho$ è riportato solo se superato.')
    (DATA/'ras_counts.json').write_text(json.dumps(counts,indent=2)+'\n',encoding='utf-8')
    (OUT/'final_closure_values.tex').write_text('\n'.join(r'\newcommand{'+chr(92)+key+'}{'+num(value)+'}' for key,value in macros.items())+'\n',encoding='utf-8')
    print('Quattro tabelle, macro e conteggi derivati da summary.json.')
if __name__=='__main__':main()
