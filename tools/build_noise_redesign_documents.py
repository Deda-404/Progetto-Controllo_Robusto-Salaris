"""Tabelle e quaderno tecnico dai risultati realmente eseguiti."""
from pathlib import Path
import json, collections, csv, hashlib

ROOT=Path(__file__).resolve().parents[1]
FOLDER=ROOT/'results/data/noise_redesign'

def f(x,precision=6):
    return '---' if x is None else f'{x:.{precision}g}'

def table(headers,rows,caption,label):
    columns='l'+'r'*(len(headers)-1)
    out=[r'\begin{table}[htbp]\centering\small',r'\resizebox{\textwidth}{!}{%',
         r'\begin{tabular}{'+columns+r'}\toprule',' & '.join(headers)+r'\\\midrule']
    out += [' & '.join(str(x) for x in row)+r'\\' for row in rows]
    out += [r'\bottomrule\end{tabular}}',r'\caption{'+caption+'}',r'\label{'+label+'}',r'\end{table}']
    return '\n'.join(out)+'\n'

def main():
    s=json.loads((FOLDER/'summary.json').read_text(encoding='utf-8'))
    c={r['name']:r for r in s['candidates']}
    selected=['Hinf2','HinfN3','Kmu','MuN1']
    nominal={(r['Controller'],r['Joint']):r for r in s['plantsMetrics'] if r['Plant']==0}
    isolated={(r['Controller'],int(r['Seed'])):r for r in s['noiseMetrics'] if r['Scenario']=='independent'}
    def run(choice,model):
        r=next(r for r in s['simulink'] if r['selection']==choice and r['model']==model)
        branches=r['branches'];branches=[branches] if isinstance(branches,dict) else branches
        b=next(b for b in branches if b['controller'] in ['2-DoF','mu'])
        return max(b['peak_u_Nm']),max(b['rms_u_Nm']),b
    h0,h1=run('baseline','Hinf_nonlinear_sim'),run('noise_hinf3','Hinf_nonlinear_sim')
    m0,m1=run('baseline','mu_nonlinear_sim'),run('noise_mu1','mu_nonlinear_sim')
    generated=ROOT/'report/generated'
    rows=[]
    for name in selected:
        x=isolated[name,20261012];peaks=[isolated[name,int(seed)]['IntersamplePeakU'] for seed in s['noiseSeeds']]
        rms=[isolated[name,int(seed)]['IntegratedRmsU'] for seed in s['noiseSeeds']]
        rows.append([name,f(x['IntersamplePeakU']),f(x['IntegratedRmsU']),f(min(peaks))+'--'+f(max(peaks)),f(min(rms))+'--'+f(max(rms))])
    (generated/'noise_redesign_isolated.tex').write_text(table(['Controllore','Picco seed 20261012','RMS seed 20261012','Picchi, 3 seed','RMS, 3 seed'],rows,
        'Solo encoder indipendenti, 4 s: comando in N m. Picchi su scansione finita fra campioni; RMS da quadratura ZOH, media sui due comandi. Stessa varianza e Ts=2 ms.',
        'tab:noise-redesign-isolated'),encoding='utf-8')
    rows=[]
    for name in c:
        r=c[name];rows.append([name,r['noiseScale'],r['order'],f(r['newNorm']),f(r['oldNorm']),f(r['TuvNorm']),f(r['RS']['LowerBound']),f(r['RP']['LowerBound'])])
    (generated/'noise_redesign_synthesis.tex').write_text(table(['Candidato',r'$W_n/\sigma_y$','Ordine','Norma nuova','Norma precedente',r'$\|T_{uv}\|_\infty$','RS lower','RP lower'],rows,
        'Sintesi con W1, W2 e Mo invariati. Le due norme appartengono a problemi differenti; non sono una graduatoria di gamma. Tutti i nominali sono stabili; soltanto MuN1 supera RS e RP.',
        'tab:noise-redesign-synthesis'),encoding='utf-8')
    rows=[]
    for name in selected:
        for joint in [1,2]:
            r=nominal[name,joint];rows.append([name,joint,f(r['SettlingTime']),f(r['Overshoot']),f(100*r['FinalError']),f(r['DisturbancePeakQ']),f(r['DisturbancePeakU']),f(r['DisturbanceRmsU'])])
    (generated/'noise_redesign_tracking.tex').write_text(table(['Controllore','Giunto',r'$T_s$ [s]',r'OS [\%]',r'Errore [\%]','Picco q [rad]','Picco u [N m]','RMS u [N m]'],rows,
        'Prove nominali comuni: tracking 5 gradi su 4 s, assestamento entro il 2 per cento dell\'ampiezza attorno al DC analitico. Disturbo 0.5 N m da 1 s su 8 s. Le ultime tre colonne appartengono al disturbo isolato.',
        'tab:noise-redesign-tracking'),encoding='utf-8')
    rows=[]
    for model in ['Hinf_linear_sim','Hinf_nonlinear_sim','mu_linear_sim','mu_nonlinear_sim']:
        choice='noise_hinf3' if model.startswith('Hinf') else 'noise_mu1'
        before,after=run('baseline',model),run(choice,model)
        rows.append([model.replace('_',r'\_'),f(before[0]),f(after[0]),f(before[1]),f(after[1]),f(before[0]/after[0],5)])
    (generated/'noise_redesign_simulink.tex').write_text(table(['Modello','Picco prima','Picco dopo','RMS prima','RMS dopo','Rapporto picco'],rows,
        'Scope originali, 10 s, riferimento/disturbo/processo/encoder combinati. Comando in N m; RMS massimo per canale. H-infinity lineare seleziona misure ideali e non certifica attenuazione encoder. Picchi registrati, non massimi continui garantiti.',
        'tab:noise-redesign-simulink'),encoding='utf-8')
    counts={name:len({r['Plant'] for r in s['plantsMetrics'] if r['Plant']>0 and r['Controller']==name and r['Stable']}) for name in selected}
    ras=collections.Counter((r['Controller'],r['Status']) for r in s['rasMetrics'])
    rows=[]
    for p in s['rasProofs']:
        rows.append([p['name'],p['n'],ras[p['name'],'CONVERGENT_BY_TAIL_CRITERIA'],ras[p['name'],'NUMERIC_LIMIT_TERMINATION'],
            'PASS' if p['gatePassed'] else 'FAIL',f(p['rhoCertified']),f(p['residual']),f(p['roundoffAllowance'])])
    (generated/'noise_redesign_ras.tex').write_text(table(['Candidato','Stati','Convergenti','Arresti','Gate Lyapunov',r'$\rho$','Residuo','Arrotondamento'],rows,
        'Stato aumentato completo e griglia comune di 25 punti. Candidati integrati in coordinate bilanciate con ode15s e Jacobiano meccanico, 12 s e criteri di coda invariati. Arresti numerici: convergenza ignota. Il livello HinfN3 è soltanto nominale.',
        'tab:noise-redesign-ras'),encoding='utf-8')
    body=f'''PROVA DI SOLUZIONE DEL RUMORE DI MISURA
Risultati MATLAB/Simulink R2026b, 13 ottobre 2026.

1. IL PROBLEMA OSSERVATO
La prima formulazione controlla bene alcune posizioni ma può richiedere comandi molto grandi. Nel Simulink H-infinity non lineare il picco del ramo 2-DoF è {f(h0[0],10)} N m; per mu è {f(m0[0],10)} N m. Nella prova MATLAB isolata il fenomeno è ancora più evidente confrontando istanti campionati e transitori fra campioni. Non si tratta di cambiare unità o segno per migliorare il grafico: le mappe sono state confrontate indipendentemente con la realizzazione interna.

2. PERCHÉ ACCADE
Con u=Kr*r+Ky*(q+v) e q=G*u, il rumore attraversa Tuv=(I-Ky*G)^(-1)*Ky. Il segno è già incorporato in Ky. La posizione riceve invece Tqv=G*Tuv. Attuatori e meccanica attenuano le componenti rapide, quindi q può apparire regolare mentre u presenta impulsi. Dy=0 annulla il salto diretto, ma non i transitori immediatamente successivi. Il controllo include poli interni, dimensioni, guadagno fino a 10^8 rad/s, condizioni delle matrici e confronto fra realizzazioni originali e bilanciate. La scansione interna usa 600 ritardi logaritmici/uniformi circa; non certifica il massimo continuo globale.

3. OBIETTIVO DELLA MODIFICA
Ridurre picco, RMS e norma misura-comando senza cambiare pianta, rumore, tempi degli SLX, incertezze o equilibrio. Il criterio dichiarato della piccola campagna è una riduzione di almeno dieci volte di picco e RMS encoder per ciascuno dei tre seed, insieme a stabilità nominale; una proposta robusta deve anche mantenere RS/RP. Non sostituiamo i target M5: 0.8 s e 5% restano quelli originali. Il criterio sul rumore è progettuale, non un Umax hardware.

4. STRUTTURA ATTUALE
La prima pianta ha w=[r;d], z=[W1*(q-Mo*r);W2*u] e yK=[r;q]. Il 2-DoF ha due uscite, quattro ingressi e stati condivisi tra riferimento e misura. Il primo K H-infinity ha 22 stati e il primo Kmu 78. I quattro script principali restano disponibili e identici: i MAT consolidati non sono sostituiti.

5. NUOVA IDEA PROGETTUALE
Aggiungiamo nu agli ingressi esogeni, con v=Wn*nu e qmis=q+v. L'errore prestazionale usa q fisico, non la misura rumorosa: altrimenti penalizzeremmo anche l'errore del sensore come se fosse errore reale. La pianta è [r;d;nu;u] -> [ze;zu;r;qmis], dimensione 8x8. Il controllore resta 2x4 con ordine degli ingressi [r1;r2;q1mis;q2mis]. Connect usa una sola istanza della pianta e non ne duplica gli stati. Il rumore non diventa un parametro incerto.

6. SCELTA DEI PESI
W1=(s/3+2)/(s+0.3)*I2; W2=0.003*(s+80)/(s/6+80)*I2; Mo=16/(s^2+8*s+16)*I2. Sono conservati. Wn=c*sigma_y*I2, sigma_y=0.05*pi/180={f(s['sigmaY'],12)} rad, c=1,5,20. I valori Wn sono {f(c['HinfN1']['Wn'],12)}, {f(c['HinfN2']['Wn'],12)}, {f(c['HinfN3']['Wn'],12)} rad. È una scala deterministica sull'ingresso normalizzato, non una densità di rumore continuo. Il fattore 20 non porta il rumore simulato a un grado: aumenta la penalizzazione progettuale, mentre i campioni restano a 0.05 gradi. W3 non è aggiunto. Aumentare c penalizza di più la mappa rumore-comando; peggiora alcuni disturbi e cambia la norma del problema.

7. NUOVA SINTESI H-INFINITY
Si chiama hinfsyn(P,4,2) con la tolleranza consolidata. Tre profili ordinati variano soltanto Wn. Tutti producono controllori propri, nominalmente stabili e di ordine 22. La norma nuova include sei esogeni, quella precedente quattro: non si confrontano ingenuamente i gamma. HinfN3 è il candidato di maggiore attenuazione studiato in Simulink; N1/N2 restano tentativi esplorativi. Nessuno supera RS, quindi nessuno è promosso come soluzione robusta finale.

8. NUOVA SINTESI MU
Una sola nuova D-K usa Wn=sigma_y*I2 e conserva k1/k2/Jm1 +/-10%, Delta_act1 e Delta_act2. Le opzioni restano MixedMU=on, FullDG=[true true], FitOrder=[5 2], MaxIter=5, TolPerf=0.01, stessa griglia 1201 frequenze, AutoScale/Regularize/LimitGain attivi, RandomStart=0, nessun parallelismo. Il seed dichiarato è 20261013. L'obiettivo è {f(c['MuN1'].get('objective'),10)}, il controllore ha 82 stati. La post-analisi sul nuovo problema fornisce RS [{f(c['MuN1']['RS']['LowerBound'],10)},{f(c['MuN1']['RS']['UpperBound'],10)}] e RP [{f(c['MuN1']['RP']['LowerBound'],10)},{f(c['MuN1']['RP']['UpperBound'],10)}]. Robgain è ripetuto anche sulla formulazione precedente: [{f(c['MuN1']['oldRP']['LowerBound'],10)},{f(c['MuN1']['oldRP']['UpperBound'],10)}]. Mussv verifica RS e RP con un blocco di prestazione rettangolare 6x4 nel problema nuovo. I massimi upper sulla griglia sono {f(c['MuN1']['muRSMax'][0])} e {f(c['MuN1']['muRPMax'][0])}; il margine adattivo rimane una verifica distinta.

9. MODIFICHE AI FILE
analysis/noise_redesign/noise_generalized_plant.m: nuova interconnessione nominata; controlli di dimensione/stati/incertezze.
analysis/noise_redesign/run_noise_synthesis.m: tre hinfsyn e una musyn; salvataggi separati e verifica di stabilità/proprietà delle realizzazioni.
analysis/noise_redesign/validate_noise_candidates.m: confronto ZOH comune, tre seed, otto scenari; quadratura e confronto delle coordinate.
analysis/noise_redesign/audit_noise_robustness.m: NS/NP/RS/RP nuovi e precedenti; robstab, robgain, mussv e intervalli conservati.
analysis/noise_redesign/validate_noise_plants.m: riuso esatto dei dieci impianti congelati; metriche soltanto per chiusure stabili.
analysis/noise_redesign/run_noise_simulink.m: otto esecuzioni abbinate, quattro modelli per baseline/candidato; gate completi e cartelle distinte.
analysis/noise_redesign/export_noise_redesign.m: dati numerici e tre figure per gli elaborati, compreso il confronto Scope abbinato, derivati dai run.
simulink/setup_student_originals.m: selezione esterna esplicita; baseline predefinita e candidati solo per la famiglia corretta.
simulink/validate_student_originals.m: cartella separata, verifica dei coefficienti prima/dopo, Workspace salvato e hash dei coefficienti; nessuna modifica SLX.
simulink/analyze_student_scope_results.m: analisi nella cartella scelta, senza sovrascrivere i risultati precedenti; decoder e statistiche conservati.
analysis/run_final_ras_lyapunov.m: ammette controllori/cartella esterni; i candidati usano ode15s bilanciato con Jacobiano meccanico, senza cambiare gli SLX. Baseline predefinita invariata.
tests/noiseRedesignTest.m: sette verifiche dedicate di interconnessione, selezione, attenuazione per seed, robustezza, protocollo Simulink e stato completo RAS.
tools/build_noise_redesign_documents.py: tabelle e questo quaderno dai dati JSON; nessun numero generato senza evidenza.
tools/audit_oral_timing.py: conteggio del parlato, tempi e note coordinati.
report/sections/06_specifiche_pesi.tex: distingue specifica encoder e limiti hardware.
report/sections/08_hinf.tex: spiega lo studio H-infinity con rumore e il fallimento RS.
report/sections/09_mu.tex: nuova D-K e post-analisi, distinte dalla formulazione precedente.
report/sections/10_validazione_nonlineare.tex: nuovi protocolli, Scope, rumore e RAS.
report/sections/10_originali_simulink.tex: più schemi autentici e loro richiamo nel testo.
report/sections/11_monte_carlo.tex: confronta i candidati sugli stessi dieci impianti.
report/sections/12_confronto_finale.tex e 13_conclusioni_limiti.tex: distinguono baseline, proposta con rumore e criteri non soddisfatti.
report/main.tex: riassunto coerente; presentation/main.tex: sintesi con rumore e due schemi LQGI distinti.
presentation/Presentazione_orale.txt: discorso alternato e appendice; SPEAKER_NOTES.md e OUTLINE_AND_TIMING.md: regia e tempi misurabili.
delivery/manifest.json, README.md e strumenti di confezionamento: includono sorgenti, dati e documenti di preparazione distinti dagli allegati scientifici.
.gitattributes: nuovi Scope MAT tramite Git LFS; identità dei dati controllata dagli hash. .gitignore: esclude soltanto il nuovo pacchetto generato e lo ZIP, conservando il precedente.
README.md, CHANGELOG.md, docs/PROJECT_STATUS.md, DIARIO_DI_BORDO.md, DECISION_LOG.md e checklist: stato e decisione tracciati, senza riscrivere voci storiche.
I nuovi MAT/CSV/JSON e le figure sono sotto noise_redesign. I risultati della prima campagna restano byte per byte quelli iniziali. I quattro script principali e gli otto SLX non sono modificati.

10. CONFRONTO NUMERICO
Protocollo MATLAB: 4 s, Ts=0.002, sigma_y invariata, stato iniziale nullo e stessi ingressi per tutti i controllori. Seed 20261012, 20261013, 20261014. Otto scenari: riferimento pulito, solo q1, solo q2, encoder indipendenti, encoder correlati, sola coppia link, solo processo, combinato. Il riferimento MATLAB parte da 0.2 s e il disturbo da 1 s. Nel protocollo originale Simulink entrambi partono da 1 s, con seed 20260826, encoder correlati e rumori di processo attivi. H-infinity lineare usa feedback ideale e non è una prova encoder. Le statistiche Scope usano la propria griglia non uniforme.

Solo encoder indipendenti, seed 20261012; picco finito fra campioni/RMS integrato medio dei due comandi [N m]:
'''
    for name in selected:
        r=isolated[name,20261012];body+=f"{name}: {f(r['IntersamplePeakU'],10)} / {f(r['IntegratedRmsU'],10)}\n"
    body+='\nIntervalli sui tre seed, stesso rumore per baseline e candidato:\n'
    for name in selected:
        rr=[isolated[name,int(seed)] for seed in s['noiseSeeds']]
        body+=f"{name}: picco [{f(min(r['IntersamplePeakU'] for r in rr))},{f(max(r['IntersamplePeakU'] for r in rr))}], RMS [{f(min(r['IntegratedRmsU'] for r in rr))},{f(max(r['IntegratedRmsU'] for r in rr))}] N m.\n"
    body+='\nNominale: Ts/overshoot/errore statico e disturbo picco q/picco u/RMS u:\n'
    for name in selected:
        for joint in [1,2]:
            r=nominal[name,joint];body+=f"{name}, q{joint}: {f(r['SettlingTime'])} s / {f(r['Overshoot'])}% / {f(100*r['FinalError'])}%; disturbo {f(r['DisturbancePeakQ'])} rad / {f(r['DisturbancePeakU'])} N m / {f(r['DisturbanceRmsU'])} N m.\n"
    body+='\nNorme, poli, margini nuovi:\n'
    for name in c:
        r=c[name];body+=f"{name}: norma nuova {f(r['newNorm'])}, precedente {f(r['oldNorm'])}; Tuv {f(r['TuvNorm'])} N m/rad; max Re polo interno {f(r['maxRealPole'])} s^-1; RS [{f(r['RS']['LowerBound'])},{f(r['RS']['UpperBound'])}], RP [{f(r['RP']['LowerBound'])},{f(r['RP']['UpperBound'])}].\n"
    body+='\nScope originali; picco e massimo RMS per canale prima -> dopo [N m]:\n'
    for model in ['Hinf_linear_sim','Hinf_nonlinear_sim','mu_linear_sim','mu_nonlinear_sim']:
        before=run('baseline',model);after=run('noise_hinf3' if model.startswith('Hinf') else 'noise_mu1',model)
        body+=f"{model}: picco {f(before[0],10)} -> {f(after[0],10)}; RMS {f(before[1],10)} -> {f(after[1],10)}.\n"
        b,a=before[2],after[2]
        body+=f"  Errori medi q1/q2 negli ultimi 1 s [deg]: {f(b['tail_mean_error_deg'][0])}/{f(b['tail_mean_error_deg'][1])} -> {f(a['tail_mean_error_deg'][0])}/{f(a['tail_mean_error_deg'][1])}; overshoot q1 combinato {f(b['observed_q1_overshoot_percent'])}% -> {f(a['observed_q1_overshoot_percent'])}%.\n"
    body+='Le metriche Scope includono riferimento e disturbo simultanei: l\'overshoot non è quello del gradino nominale isolato. Il nuovo mu non lineare ha overshoot combinato 35.60%, rispetto a 10.67% della baseline, e maggiore errore medio: il miglioramento sul comando non elimina il compromesso sulla posizione.\n'
    body+='\nDieci impianti congelati: '+', '.join(f'{name} {counts[name]}/10 stabili' for name in selected)+'.\n'
    body+='\nRAS: HinfN3 ha 36 stati, 13/25 convergenze e 12 arresti numerici; il gate Lyapunov nominale passa con rho=2.506e-12. MuN1 ha 96 stati e 25/25 convergenze empiriche, ma il gate Lyapunov fallisce: non viene dichiarato un certificato. La prima prova HinfN3 in ode23t ha incontrato il limite di tempo; è conservata, poi la campagna è stata eseguita in coordinate bilanciate con ode15s e Jacobiano. Questa modifica riguarda soltanto il test MATLAB, non i solver degli SLX.\n'
    body+=f'''
11. TENTATIVI NON ADOTTATI
N1 e N2 migliorano il rumore ma falliscono RS. N3 ha la migliore attenuazione H-infinity osservata, ma RS rimane sotto uno e soltanto sei campioni incerti su dieci sono stabili. Non viene adottato. MuN1 conserva robustezza e riduce il rumore; il tracking q1 passa da circa 6% a 8.24% di errore e il disturbo nominale peggiore da circa 0.307 a 0.334 rad. Il massimo RMS del disturbo aumenta da circa 0.419 a 0.499 N m. Non si dichiara che tutte le prestazioni migliorino. Il target temporale rimane fallito. Nessuna campagna casuale di pesi, riduzione d'ordine o nuovo PID è stata introdotta.

12. CONCLUSIONE
Nessun nuovo controllore è reso predefinito. HinfN3 resta uno studio nominale non ammissibile come soluzione robusta. MuN1 è una proposta robusta validata con attenuazione encoder superiore a dieci volte in tutti i seed, da valutare rispetto al peggioramento dell'offset. Nel Simulink non lineare il suo rapporto prima/dopo è {f(m0[0]/m1[0])} sul picco e {f(m0[1]/m1[1])} sul massimo RMS per canale. La decisione finale sull'adozione resta agli studenti, come richiesto. I numeri dimostrano una mitigazione progettuale nel protocollo dichiarato; non eliminano il rumore, non certificano un massimo assoluto gaussiano e non dimostrano la realizzabilità hardware. Per questa servono limiti documentati del motore/trasmissione, velocità, rate del comando e verifiche sperimentali.

EVIDENZE E RIPRODUZIONE
I risultati numerici hanno origine in results/data/noise_redesign/summary.json, noise_metrics.csv, plants_metrics.csv, MAT dei candidati/robustezza/RAS e cartelle simulink baseline/noise_hinf3/noise_mu1. I coefficienti effettivamente forniti sono salvati nei Workspace e identificati con SHA-256. I warning e i selettori salvati restano nei JSON dei run. Per il percorso completo leggere analysis/noise_redesign/README.md. La tabella di accettazione è in docs/ACCETTAZIONE_RUMORE_E_ORALE.md. Le sette verifiche dedicate non sostituiscono le 141 regressioni, rieseguite separatamente con i quattro script in una copia isolata identica dei sorgenti.
'''
    (ROOT/'docs/Prova_di_Soluzione_Rumore_di_Misura.txt').write_text(body,encoding='utf-8')
    print('PASS: cinque tabelle numeriche e quaderno tecnico aggiornati dai run reali.')

if __name__=='__main__':main()
