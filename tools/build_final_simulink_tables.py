"""Build document tables directly from the verified original-SLX Scope results."""
from pathlib import Path
import json, csv
ROOT=Path(__file__).resolve().parents[1]
DATA=ROOT/'results/data/final_simulink_validation'
def records(value):
    return value if isinstance(value,list) else [value]
def number(value):
    if value is None:return '--'
    if abs(value)>=1e4:
        mantissa,exponent=f'{value:.2e}'.split('e')
        return '$'+mantissa+r'\times10^{'+str(int(exponent))+'}$'
    return f'{value:.3g}'
def main():
    rows=[]
    for family in ['LQG','LQGI','Hinf','mu']:
        for mode in ['linear','nonlinear']:
            name=f'{family}_{mode}_sim'
            review=json.loads((DATA/f'{name}_dynamic_review.json').read_text(encoding='utf-8'))
            assert review['status']=='DYNAMIC VALIDATION PASS',name
            for item in records(review['branches']):
                rows.append({'model':name,'mode':mode,'controller':item['controller'],
                    'error_q1_deg':item['tail_mean_error_deg'][0],'error_q2_deg':item['tail_mean_error_deg'][1],
                    'peak_u_Nm':max(item['peak_u_Nm']),'max_channel_rms_u_Nm':max(item['rms_u_Nm']),
                    'overshoot_q1_percent':item['observed_q1_overshoot_percent'],
                    'settling_q1_s':item['observed_settling_2percent_s'],
                    'max_scope_step_s':item['max_command_sample_gap_s']})
    with (DATA/'dynamic_metrics.csv').open('w',encoding='utf-8',newline='') as f:
        writer=csv.DictWriter(f,fieldnames=list(rows[0]));writer.writeheader();writer.writerows(rows)
    lines=[]
    for mode,title in [('linear','lineari'),('nonlinear','non lineari')]:
        lines += [r'\begin{table}[htbp]\centering\small',r'\begin{tabular}{lrrrr}\toprule',
            r'Controllore & $\bar e_1$ [deg] & $\bar e_2$ [deg] & Picco $u$ [N m] & RMS max [N m]\\\midrule']
        for row in rows:
            if row['mode']!=mode:continue
            name={'mu':r'$K_\mu$','1-DoF':r'$H_\infty$ 1-DoF','2-DoF':r'$H_\infty$ 2-DoF'}.get(row['controller'],row['controller'])
            lines.append(name+' & '+' & '.join(number(row[k]) for k in ['error_q1_deg','error_q2_deg','peak_u_Nm','max_channel_rms_u_Nm'])+r'\\')
        lines += [r'\bottomrule\end{tabular}',
            r'\caption{Simulink: diagrammi '+title+r' nella configurazione salvata. Errori medi nell’ultimo secondo, $e=q-r$; picco sui due comandi registrati e massimo dei due RMS temporali. Riferimento e disturbo iniziano insieme a 1 s; rumori di processo attivi.}',
            r'\label{tab:simulink-'+mode+r'}\end{table}']
    (ROOT/'report/generated/final_simulink_results.tex').write_text('\n'.join(lines)+'\n',encoding='utf-8')
    hinf=next(v for v in rows if v['model']=='Hinf_nonlinear_sim' and v['controller']=='2-DoF')
    mu=next(v for v in rows if v['model']=='mu_linear_sim')
    macros=(r'\newcommand{\SimHinfNLPeak}{\ensuremath{'+f"{hinf['peak_u_Nm']/1e5:.2f}"+r'\times10^{5}}}'+'\n'+
            r'\newcommand{\SimMuLinPeak}{'+f"{mu['peak_u_Nm']:.0f}"+'}\n')
    bounds=json.loads((DATA/'robustness_R2026b.json').read_text(encoding='utf-8'))
    for prefix,source in [('FinalHRS','Hinf_RS'),('FinalHRP','Hinf_RP'),('FinalMuRS','Mu_RS'),('FinalMuRP','Mu_RP')]:
        for field in ['LowerBound','UpperBound']:
            macros+='\\renewcommand{\\'+prefix+field+'}{'+f'{bounds[source][field]:.6g}'+'}\n'
    macros+=r'\newcommand{\FinalHRSFrequency}{'+f"{bounds['Hinf_RS']['CriticalFrequency']:.4g}"+'}\n'
    (ROOT/'report/generated/final_simulink_values.tex').write_text(macros,encoding='utf-8')
    print(f'PASS: {len(rows)} executed controller/model combinations, original Scope data.')
if __name__=='__main__':main()
