"""Tabelle LaTeX della revisione: soltanto CSV prodotti dai run MATLAB."""
from pathlib import Path
import csv
import math

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'results/data/salaris_revision'
DEST = ROOT / 'report/generated'

def read(name):
    target = SOURCE / name
    if not target.exists():
        return []
    with target.open(encoding='utf-8-sig', newline='') as stream:
        return list(csv.DictReader(stream))

def raw(value):
    number = float(value)
    if math.isnan(number):
        return r'\mathrm{n.d.}'
    if math.isinf(number):
        return r'\infty'
    text = f'{number:.3g}'
    if 'e' in text:
        mantissa, power = text.split('e')
        return rf'{mantissa}\cdot10^{{{int(power)}}}'
    return text

def num(value):
    return '$' + raw(value) + '$'

def model(value):
    return {'A_full': 'A pieno', 'A_diagonal': 'A diag.', 'B_parametric': 'B'}[value]

def table(filename, headers, rows, caption):
    body = [r'\begin{table}[htbp]\centering\small',
            r'\begin{tabular}{' + 'l' * len(headers) + r'}\toprule',
            ' & '.join(headers) + r'\\\midrule']
    body += [' & '.join(row) + r'\\' for row in rows]
    body += [r'\bottomrule\end{tabular}', r'\caption{' + caption + '}', r'\end{table}']
    (DEST / filename).write_text('\n'.join(body) + '\n', encoding='utf-8')

def write(filename, text):
    (DEST / filename).write_text(text + '\n', encoding='utf-8')

def main():
    nominal=read('nominal_metrics.csv')
    if nominal:
        table('salaris_nominal.tex',['K','Ordine',r'$T_s$ [s]',r'OS [\%]',r'Errore DC',r'Picco $u$ [N m]'],
              [[r['Controller'],r['Order'],num(r['SettlingTime']),num(r['OvershootPercent']),num(r['RelativeDCError']),num(r['PeakTorque'])] for r in nominal],
              'Risultati nominali deterministici: massimo sui due gradini di riferimento di 5 gradi. Assestamento al 2 per cento attorno al valore DC effettivo.')
    comparison = read('comparison.csv')
    if comparison:
        rows = [[r['Controller'], model(r['Model']), r['NS'], r['NP'],
                 '$[' + raw(r['RSLower']) + ',' + raw(r['RSUpper']) + ']$' if r.get('NestingConsistent','1')=='1' else 'n.i.',
                 num(r['RPUpper']) if r.get('NestingConsistent','1')=='1' else 'n.i.', num(r['MinimumBandwidth'])] for r in comparison]
        table('salaris_comparison.tex', ['K', 'Modello', 'NS', 'NP', 'RS', r'RP $\le$', r'Banda [rad/s]'], rows,
              'Stessi controllori su tre famiglie. RP è maggiorato da RS quando RS fallisce. NP usa la stessa mappa pesata per tutti.')
        mu = [r for r in comparison if r['Controller'] == 'Kmu']
        text = r'Per il controllore consolidato $K_\mu$, i margini RS inferiori sono '
        text += ', '.join(model(r['Model']) + ': ' + num(r['RSLower']) for r in mu) + '.'
        text += ' Questi valori riguardano le nuove famiglie, non sostituiscono i margini storici di M4.'
        text += ' Le frequenze critiche RS corrispondenti sono ' + ', '.join(model(r['Model'])+': '+num(r['RSFrequency'])+' rad/s' for r in mu)+'.'
        write('salaris_findings.tex', text)
        inconsistent = [r for r in comparison if r.get('NestingConsistent','1') != '1']
        if inconsistent:
            with (DEST / 'salaris_findings.tex').open('a',encoding='utf-8') as stream:
                stream.write(' I margini indicati come n.i. violano numericamente la monotonia imposta dalle inclusioni: restano quantitativamente inconclusivi. I valori grezzi sono conservati nel CSV; non si usano per sostenere un vantaggio fra modelli.\n')
    synthesis = read('synthesis.csv')
    if synthesis:
        selected = [r for r in synthesis if r['Design'] == 'Hinf_common' or r['Design'] == 'musyn_' + r['AnalysisModel']]
        rows = [[r'$H_\infty$' if r['Design'] == 'Hinf_common' else r'$\mu$', model(r['AnalysisModel']),
                 num(r['BandwidthFactor']), r['Order'], num(r['RSLower']), num(r['RPLower']),
                 num(r['MinimumBandwidth'])] for r in selected]
        table('salaris_synthesis.tex', ['Sintesi', 'Modello', '$b$', 'Ordine', 'RS inf.', 'RP inf.', 'Banda [rad/s]'], rows,
              'Sintesi nominale comune e sintesi D--K distinte. Le analisi incrociate complete sono nel CSV synthesis.')
        passing = [r for r in selected if r['Design'] != 'Hinf_common' and float(r['RSLower']) > 1 and float(r['RPLower']) > 1]
        if passing:
            text = 'La campagna ha ottenuto RS e RP per: '
            text += '; '.join(model(r['AnalysisModel']) + ', $b=' + raw(r['BandwidthFactor']) + '$, banda ' + num(r['MinimumBandwidth']) + ' rad/s' for r in passing) + '.'
        else:
            text = 'Nella campagna D--K limitata qui eseguita non è stato ottenuto un candidato con RS e RP entrambe garantite. Questo esito non dimostra l\'impossibilità del problema e non determina una banda robusta massima.'
        text += ' Non si assume una perdita di una decade: si confrontano i valori effettivi e si mantiene distinto il fattore richiesto dalla banda ottenuta.'
        write('salaris_conclusions.tex', text)
        write('salaris_slide_conclusions.tex', 'Candidati con RS/RP garantite nella campagna: ' + str(len(passing)) + '. La ricerca limitata non dimostra una banda ottima.')
        last_level = min(float(r['BandwidthFactor']) for r in synthesis)
        compact = [r for r in selected if float(r['BandwidthFactor']) == last_level]
        table('salaris_slide_synthesis.tex', ['Sintesi', 'Modello', 'RS inf.', 'RP inf.', 'Banda'],
              [[r'$H_\infty$' if r['Design'] == 'Hinf_common' else r'$\mu$', model(r['AnalysisModel']), num(r['RSLower']), num(r['RPLower']), num(r['MinimumBandwidth'])] for r in compact],
              'Ultimo livello eseguito: $b=' + raw(last_level) + '$')
    samples = read('physical_samples_metrics.csv')
    temporal=read('synthesis_temporal_metrics.csv')
    if temporal:
        labels={'musyn_A_full':r'$\mu$ A','musyn_B_parametric':r'$\mu$ B','Hinf_common_nominal':r'$H_\infty$'}
        table('salaris_synthesis_temporal.tex',['K','$b$',r'$T_s$ [s]',r'Errore DC',r'Picco $u_r$',r'Picco $q_d$ [rad]'],
              [[labels[r['Design']],num(r['BandwidthFactor']),num(r['SettlingTime']),num(r['RelativeDCError']),num(r['TrackingPeakTorque']),num(r['DisturbancePeakRad'])] for r in temporal],
              'Prestazioni nominali effettive dei nuovi candidati. Coppie in N m, disturbo lato link 0.5 N m; valori massimi sui due canali.')
    relaxed = read('performance_relaxation.csv')
    if relaxed:
        rows=[]
        passing=[]
        for name in ['A_full','B_parametric']:
            for factor in sorted({float(r['BandwidthFactor']) for r in relaxed},reverse=True):
                group=[r for r in relaxed if r['Model']==name and float(r['BandwidthFactor'])==factor]
                good=[r for r in group if float(r['RSLower'])>1 and 1<float(r['RPLower'])<=float(r['RPUpper'])]
                chosen=min(good,key=lambda r:float(r['GainTarget'])) if good else max(group,key=lambda r:float(r['GainTarget']))
                if good:
                    passing.append(chosen)
                rows.append([model(name),num(factor),num(chosen['GainTarget']),num(chosen['RSLower']),num(chosen['RPLower']),num(chosen['MinimumBandwidth'])])
        table('salaris_relaxation.tex',['Modello','$b$',r'$\gamma_{req}$','RS inf.','RP inf.','Banda [rad/s]'],rows,
              'Primo livello fra 1,3,10 con garanzia RS/RP; se nessuno riesce è mostrato il livello 10, senza attribuirgli una garanzia.')
        slide=[r for r in relaxed if float(r['GainTarget'])==3 and float(r['BandwidthFactor']) in [1,.1]]
        table('salaris_slide_synthesis.tex',['Modello','$b$','RS inf.',r'RP inf. a $\gamma=3$','Banda'],
              [[model(r['Model']),num(r['BandwidthFactor']),num(r['RSLower']),num(r['RPLower']),num(r['MinimumBandwidth'])] for r in slide],
              'Stesso limite di amplificazione rilassato: 3')
        if passing:
            text='Con limiti di amplificazione esplicitamente rilassati risultano garantite RS/RP per: '
            text+='; '.join(model(r['Model'])+', $b='+raw(r['BandwidthFactor'])+r'$, $\gamma_{req}='+raw(r['GainTarget'])+'$, banda '+num(r['MinimumBandwidth'])+' rad/s' for r in passing)+'. '
            text+='Il livello unitario e i livelli rilassati sono requisiti diversi. La ricerca limitata non dimostra una banda robusta massima né l\'impossibilità delle formulazioni prive di un candidato accreditato.'
            best=max(passing,key=lambda r:float(r['MinimumBandwidth']))
            performance=next((r for r in temporal if r['Design']=='musyn_'+best['Model'] and float(r['BandwidthFactor'])==float(best['BandwidthFactor'])),None)
            if performance:
                text+=' Il candidato garantito con banda più alta ha assestamento nominale '+num(performance['SettlingTime'])+' s ed errore DC relativo '+num(100*float(performance['RelativeDCError']))+r'\%. Questi valori superano i target M5 di 0.8 s e 5\%: la garanzia pesata rilassata non accredita tali target temporali.'
            write('salaris_conclusions.tex',text)
            write('salaris_slide_conclusions.tex','Garanzie con requisito rilassato: '+', '.join(sorted({model(r['Model']) for r in passing}))+'. Nessuna conclusione di ottimalità della banda.')
    if samples:
        names = list(dict.fromkeys(r['Controller'] for r in samples))
        rows = []
        for name in names:
            group = [r for r in samples if r['Controller'] == name]
            stable = [r for r in group if r['Stable'] == '1']
            worst = lambda field: num(max(float(r[field]) for r in stable)) if stable else '--'
            rows.append([name, f'{len(stable)}/10', worst('SettlingTime'), worst('RelativeDCError'), worst('DisturbancePeakRad'), worst('DisturbancePeakTorque')])
        table('salaris_samples.tex', ['K', 'Stabili', r'$T_s$ [s]', 'Errore DC', r'Picco $q_d$ [rad]', r'Picco $u_d$ [N m]'], rows,
              'Dieci impianti parametrici comuni; massimi sui soli campioni stabili.')
    ras = read('ras_metrics.csv')
    if ras:
        rows = []
        for name in dict.fromkeys(r['Controller'] for r in ras):
            group = [r for r in ras if r['Controller'] == name]
            completed = [r for r in group if r['Status'] == 'COMPLETED']
            converged = sum(r['Converged'] == '1' for r in group)
            acceptable = sum(r['Converged'] == '1' and r['WithinEpsilon'] == '1' for r in group)
            rows.append([name, f'{converged}/10', f'{acceptable}/10', str(10-len(completed)),
                         num(max(float(r['Jrad']) for r in completed)) if completed else '--'])
        table('salaris_ras.tex', ['K', 'Convergenti', r'Convergenti, $J\le\varepsilon$', 'Ignote', r'Max $J$ [rad]'], rows,
              'Esplorazione empirica su dieci punti. Gli arresti numerici rimangono ignoti.')
    kalman = read('kalman.csv')
    blocks=read('lft_blocks.csv')
    if blocks:
        table('salaris_blocks.tex',['Costruzione','Parametro','Tipo','Dim. elem.','Occorrenze'],
              [[r['Model'],r['Block'].replace('_',r'\_'),r['Type'],r['ElementarySize'],r['Occurrences']] for r in blocks],
              'Strutture estratte con lftdata: stesso ingresso--uscita, realizzazioni diverse. Le occorrenze di un parametro condividono lo stesso scalare.')
    if kalman:
        table('salaris_kalman.tex', ['Coordinata', r'Var $q$ teorica', r'Var $q$ empirica', r'Var $e_q$ teorica', r'Var $e_q$ empirica'],
              [[r['Coordinate']] + [num(r[k]) for k in ['OutputVarianceTheory', 'OutputVarianceEmpirical', 'ErrorVarianceTheory', 'ErrorVarianceEmpirical']] for r in kalman],
              'Varianze in rad quadrati. Uscita ed errore di stima sono grandezze diverse; 540 s dopo il transitorio.')
    reduction = read('mu_reduction.csv')
    cancellations=read('mu_cancellations.csv')
    if cancellations:
        r=cancellations[0]
        write('salaris_cancellations.tex','La verifica con minreal a tolleranza $10^{-8}$ passa da '+r['OriginalOrder']+' a '+r['MinimalOrder']+' stati, con errore relativo di norma '+num(r['RelativeHinfError'])+'. È una diagnostica delle cancellazioni; il controllore originale rimane conservato.')
    if reduction:
        table('salaris_reduction.tex', ['Ordine', 'Modello', r'Errore rel. $H_\infty$', 'RS inf.', 'RP inf.', r'$\|T_{vu}\|_\infty$'],
              [[r['Order'], model(r['Model']), num(r['RelativeHinfError']), num(r['RSLower']), num(r['RPLower']), num(r['NoiseCommandNorm'])] for r in reduction],
              'Riduzioni del candidato MuN1 a 82 stati. Nessuna promozione automatica.')
    legacy=read('legacy_reduction.csv')
    if legacy:
        table('salaris_legacy_reduction.tex',['Ordine','NS','Norma nominale','RS inf.','RP inf.'],
              [[r['Order'],r['NS'],num(r['NominalNorm']),num(r['RSLower']),num(r['RPLower'])] for r in legacy],
              'Controllo della riduzione sulla famiglia storica M4, distinta dai nuovi modelli A/B.')
        table('salaris_slide_reduction.tex',['Ordine',r'Errore rel. $H_\infty$','RS M4','RP M4','RS B'],
              [[r['Order'],num(next(a['RelativeHinfError'] for a in reduction if a['Order']==r['Order'])),num(r['RSLower']),num(r['RPLower']),
                num(next(a['RSLower'] for a in reduction if a['Order']==r['Order'] and a['Model']=='B_parametric'))] for r in legacy],
              'La riduzione conserva i margini storici; B è una famiglia diversa')
    # Una tabella compatta per l'orale: stesso K, due modelli principali.
    if comparison:
        def slide_margin(name,kind):
            row=next(r for r in comparison if r['Controller']==name and r['Model']==kind)
            return num(row['RSLower']) if row.get('NestingConsistent','1')=='1' else 'n.i.'
        table('salaris_slide_results.tex', ['K', 'RS A', 'RS B'],
              [[name] + [slide_margin(name,kind) for kind in ['A_full', 'B_parametric']]
               for name in ['Hinf2', 'Kmu']], 'Stessi controllori, famiglie differenti')
    print('Tabelle generate dai CSV disponibili; nessun risultato numerico inserito manualmente.')

if __name__ == '__main__':
    main()
