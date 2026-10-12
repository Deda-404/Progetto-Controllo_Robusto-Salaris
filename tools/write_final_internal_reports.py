"""Genera i tre resoconti interni da evidenze reali, con limiti espliciti."""
from pathlib import Path
import json,csv,math,hashlib
ROOT=Path(__file__).resolve().parents[1]
D=ROOT/'results/data/final_closure'
def read(name):return json.loads((ROOT/name).read_text(encoding='utf-8-sig'))
def write(name,s):(ROOT/name).write_text(s.strip()+'\n',encoding='utf-8')
def num(x):return '--' if x is None else f'{x:.6g}'
def clean(x):return str(x).replace('|','\\|').replace('\n',' ')

def main():
    manifest=read('simulink/student_originals_manifest.json');audits=read('results/data/final_closure/slx_static_audit.json')
    runtime=read('results/data/final_closure/slx_runtime_audit.json');summary=read('results/data/final_closure/summary.json')
    counts=read('results/data/final_closure/ras_counts.json');scripts=read('results/data/final_closure/four_scripts_execution.json')
    tests=list(csv.DictReader((ROOT/'results/data/coherent_review/matlab_tests.csv').open(encoding='utf-8-sig')))
    passed=sum(float(t['Passed'])==1 for t in tests)
    sim='''# REPORT VERIFICA SIMULINK

Audit del 12 ottobre 2026. Fonte corrente: gli otto pacchetti SLX della cartella Drive `1wDiaAQVR7cDDt7T8WUlyZ0vgEa-2LWLx`, recuperati in sola lettura. Copie canoniche in `simulink/student_originals/`. I modelli preesistenti restano archivio e non sono la fonte di questo audit.

## Esito e integrità

Integrità COMPLETE / PASS: otto archivi ZIP con CRC valido, dimensioni confrontate con il provider e SHA-256 sorgente/importazione/post-verifica identici. Nessun `set_param`, `save_system`, aggiunta di blocchi, cambio di solver, conversione o disattivazione del controllo di release è stato applicato agli originali.

Tutti gli otto sono Simulink R2026a Update 4 (26.1.0.3312084). L'ambiente reale è MATLAB/Simulink R2025b Update 4: otto `load_system` falliscono per release. Simulazioni originali **NOT RUN**, validazione dinamica **PARTIAL**. Gli errori completi e gli hash prima/dopo sono in `results/data/final_closure/slx_runtime_audit.json`.

| File | Byte | SHA-256 sorgente = importazione = dopo verifica |
|---|---:|---|
'''
    for m in manifest['models']:
        file=ROOT/m['relative_path'];actual=hashlib.sha256(file.read_bytes()).hexdigest()
        assert actual==m['sha256_source']==m['sha256_imported']==m['sha256_post_validation']
        sim+=f"| {m['name']} | {file.stat().st_size} | `{actual}` |\n"
    sim+='''
## Architettura e variabili esterne

Le piante lineari hanno Aplant 14×14, Bplant=[Bfull BdFull BdFull Bfull] 14×8, Cplant 4×14, Dplant 4×8 e x0plant nullo. Gli ingressi sono [u; d_link; w_link; w_u], non quattro copie del comando. Cm misura [q1 q2 theta1 theta2]; la coppia dei link entra prima dell'accelerazione, il rumore w_u prima degli attuatori. La pianta aperta è instabile: stabilità e feedback vanno verificati nell'anello completo.

LQG usa u=Nr*r−K*xhat, Kalman a 14 stati e quattro encoder rumorosi. LQGI usa u=−Kx*xhat−Ki*xi, xi_dot=r−q_mis, Kalman M6 e integratori separati dallo stimatore. H∞ confronta un ramo 1-DoF su r−q_mis e rami 2-DoF/PID su [r;q_mis]. Kµ usa [r;q_mis] con un'unica realizzazione a 78 stati. Non si duplicano gli stati fra riferimento e feedback.

I non lineari integrano otto stati meccanici assoluti [q;qdot;theta;thetadot], partono da xbar e sottraggono l'equilibrio prima del controllo. Gli attuatori LTI hanno stati incrementali; Gact conserva il Padé del progetto. Le funzioni embedded applicano il disturbo sul lato link con segno positivo e richiamano inerzia, Coriolis, gravità e coppia elastica in src/. Le unità dei calcoli sono rad, rad/s, N m; le figure convertono in gradi quando dichiarato.

`setup_student_originals(kind)` prepara matrici, guadagni, controllori LTI e `slBus1`, senza scrivere gli SLX. Il bus deriva esattamente dai campi m1,m2,l1,l2,Jm,Bm,Ks,g della funzione nominale. Le InitFcn lineari trovano la radice con `which('progetto_lqgi.m')` e caricano M3/M5; i path di progetto sono aggiunti esternamente. Il callback contiene assignin nel sorgente originale: non è stato riscritto. Le matrici caricate coincidono con quelle del setup.

## Rumori, scenari e limiti statici

I Random Number encoder hanno media nulla, varianza (0.05*pi/180)^2 per i quattro canali e Ts=0.002 s; il processo ha varianza 0.01 N²m² e lo stesso Ts. I blocchi salvano seed 20260826, spesso uguale fra misura/link/comando: non si assume indipendenza fra blocchi senza verificare le sequenze effettive. La nuova diagnosi MATLAB usa un protocollo distinto, seed 20261012, misura e processo indipendenti e scenari isolati; non è un replay degli Scope.

I gradini impostati sono q1=5*pi/180, q2=0 e d=[0.5;0] da 1 s. Il tempo di riferimento, se assente nell'XML, resta un default da verificare in R2026a. I selettori manuali sono elencati con i valori salvati; non sono stati commutati per produrre nuove prove. Un parametro omesso nell'XML non viene inventato. Scope e Demux mostrano posizioni/comandi, ma senza caricamento non si validano dimensioni compilate o logging.

## Verifica per modello
'''
    descriptions={
      'LQG':'Osservatore su misure [q;theta], feedback stimato e guadagno Nr. Nessun integratore servo. Il processo agisce sulla pianta, non sul segnale u conosciuto dal Kalman.',
      'LQGI':'La connessione dal sommatore delle misure al selettore e alla somma r−q_mis è presente. Non occorre applicare la vecchia istruzione di spostare l’integratore; riguardava altri file. I segni del comando restano −Kx e −Ki.',
      'Hinf':'Tre rami separati: Controller H-inf/1-DoF usa Ak1,Bk1,Ck1,Dk1 su errore; 2-DoF usa Ak2,Bk2,Ck2,Dk2 su Mux [r;q_mis]; PID usa Kpid. Le interfacce a quattro ingressi sono già presenti.',
      'mu':'Il blocco LTI richiama Kmu e riceve riferimento e misure selezionate. Entrambi i modelli µ sono presenti; l’indicazione di modello mancante non si applica a queste copie.'}
    keys={'A','B','C','D','Gain','Multiplication','Inputs','InitialCondition','LTIObject','sys','System','SampleTime','Variance','Mean','Seed','Time','FinalValue','CurrentSetting'}
    for a in audits:
        fam=a['model'].split('_')[0]
        sim+=f"\n### {a['model']}\n\n{descriptions[fam]}\n\n"
        sim+=f"Blocchi inventariati: {len(a['blocks'])}; collegamenti espliciti: {len(a['connections'])}. Impostazioni salvate: `{clean(a['settings'])}`. Callback: {', '.join(a['callbacks']) or 'nessuno rilevato'}.\n\n"
        if 'nonlinear' in a['model']:
            sim+='Integrazione meccanica assoluta a xbar e attuatori Gact; funzioni embedded e dipendenze sono nell’inventario completo. '
        else:sim+='Piante State-Space Aplant/Bplant/Cplant/Dplant e x0plant; callback di caricamento M3/M5. '
        sim+='Dimensioni e inizializzazione descritte sopra sono coerenti staticamente con le variabili MATLAB; la compilazione rimane non eseguita.\n\n'
        sim+='| Percorso originale | Blocco | Parametri scientifici salvati |\n|---|---|---|\n'
        for b in a['blocks']:
            params={k:v for k,v in b['parameters'].items() if k in keys}
            if b['type'] not in ['StateSpace','Gain','Integrator','RandomNumber','ManualSwitch','Mux','Sum','Step','S-Function']:continue
            if not params and b['type']!='Integrator':continue
            sim+=f"| `{clean(b['path'])}` | {b['type']} | `{clean(params) if params else 'IC implicita: verificare runtime'}` |\n"
        sim+='\nEsito: integrità PASS; struttura XML ispezionata; load FAIL per release; sim NOT RUN; nessuna prestazione Simulink accreditata.\n'
    sim+='''
## Problemi esterni risolti e blocchi residui

Risolti esternamente: disponibilità degli otto pacchetti reali, path e dipendenze src/, matrici della pianta a otto ingressi, guadagni LQG/LQGI, matrici condivise 2-DoF, oggetti Kpid/Kmu e tipo bus. Non si dichiara che un audit XML abbia escluso qualsiasi problema di dimensioni, solver o collegamenti.

La sola configurazione non lineare LQG esplicita StopTime=4, ode23t, RelTol=1e-5, AbsTol=1e-7, MaxStep=0.005; gli altri config mostrano VariableStepAuto senza tutte le impostazioni esplicite. Le dinamiche rapide rendono necessaria una verifica del solver reale e del comando fra i campioni su R2026a. Modifiche interne non sono autorizzate: se un run rivela un difetto interno, documentarlo e lasciarlo agli studenti.

Le miniature `report/figures/student_originals/` sono estratte byte per byte dai pacchetti. Le etichette non sono leggibili alla scala del PDF: non sono state usate come false schermate di validazione. `export_student_schemes.m` prepara esportazioni reali e leggibili su R2026a. LQGI è predisposto come slide condizionale.

Sul computer con R2026a: eseguire `validate_student_originals(true)`, controllare i segnali salvati, confrontare con i casi MATLAB dichiarando i diversi tempi/seed/selettori, verificare hash, poi `export_student_schemes`. Solo dopo annotare PASS/FAIL di compilazione, simulazione e metriche. Nessuna conversione di release.

Fonti dettagliate: `docs/INVENTARIO_XML_SIMULINK.md`, JSON statico/runtime e manifest. Il comportamento di SimulationInput è documentato da [MathWorks](https://www.mathworks.com/help/simulink/slref/simulink.simulationinput.setvariable.html).
'''
    write('docs/REPORT_VERIFICA_SIMULINK.md',sim)

    noise='''# ANALISI RUMORE MISURA

Diagnosi del 12 ottobre 2026. Controllori archiviati invariati; nessuna nuova sintesi, riduzione, filtraggio, saturazione, anti-windup o modifica SLX. Le prove sono MATLAB, non Simulink.

## Protocollo e formula

`run_final_noise_diagnostics.m` usa seed 20261012, σy=0.05*pi/180 rad (8.72664626e−4), varianza 7.61543549e−7 rad², campioni gaussiani mantenuti per Ts=0.002 s, 4 s. LQG/LQGI ricevono quattro encoder, gli altri due; i primi due canali della stessa sequenza sono condivisi. Le sette prove distinguono riferimento pulito (5 gradi da 0.2 s), sola misura con r=d=w=0, solo q1, solo q2, sola coppia link (0.5 N m da 1 s), solo processo (σ=0.1 N m su link/comando) e combinata. L’intensità bianca continua di lqe non è questa varianza campionata. I rumori originali Simulink conservano il loro seed 20260826.

La legge 2-DoF è u=Kr*r+Ky*(q+v), q=G*u. Il segno del feedback è dentro Ky:

Tuv=(I−Ky*G)⁻¹*Ky; Tqv=G*Tuv.

Il codice costruisce Acl nello stato intero e verifica la mappa con `feedback(Ky,G,+1)`. Per LQG/LQGI Cm include q e theta e il feedback completo. La stabilità interna è verificata sui poli della matrice aumentata; rumore amplificato non è sinonimo di instabilità. Tutti i nominali risultano internamente stabili.

## Risultati: registrazione e propagazione fra i campioni

| Controllore | Ordine | ||Dy||₂ | Picco a 2 ms [N m] | RMS a 2 ms | Picco fra campioni | RMS integrato | Ritardo del picco [s] |
|---|---:|---:|---:|---:|---:|---:|---:|
'''
    for x in summary['noise']:
        m=next(r for r in summary['noiseMetrics'] if r['Controller']==x['name'] and r['Scenario']=='measurement')
        noise+=f"| {x['name']} | {x['order']} | {num(x['DkyNorm'])} | {num(m['PeakU'])} | {num(m['RmsU'])} | {num(x['intersamplePeakU'])} | {num(x['intersampleRmsU'])} | {num(x['intersamplePeakDelay'])} |\n"
    noise+='''
Il picco fra campioni è il massimo finito osservato sulla scansione logaritmica+uniforme, non un massimo globale dimostrato. L’RMS integra l’energia durante ogni intervallo di mantenimento, mediata sui due comandi e sui 4 s. Originale e coordinate bilanciate devono concordare entro 1e−4 relativo; il raffinamento della quadratura entro 2%. Questi due controlli passano. Non si tratta di interpolare il grafico: per ogni ritardo τ si propagano esattamente stato e ingresso costante con exp(Aτ) e l’integrale ZOH.

### Dinamiche e scala numerica

| Controllore | Polo più rapido, modulo [s⁻¹] | Picco campionato σmax(Tuv) [N m/rad] | Max Re polo interno [s⁻¹] | Errore formula | Errore ZOH coordinate |
|---|---:|---:|---:|---:|---:|
'''
    for x in summary['noise']:
        noise+=f"| {x['name']} | {num(x['controllerFastestPoleMagnitude'])} | {num(x['peakSigma'])} | {num(x['loopMaxRealPole'])} | {num(x['formulaRelativeError'])} | {num(x['zohRelativeAgreement'])} |\n"
    noise+='''
Il caso H∞ 2-DoF è grave anche con r=0: Dy=0 elimina il salto istantaneo, ma non impulsi subito dopo il cambio encoder. Poli molto rapidi e guadagni elevati a frequenze finite spiegano perché la sola griglia 2 ms perda quasi tutto il transitorio. La mappa è strettamente propria e tende a zero soltanto oltre quelle dinamiche; una griglia limitata alle frequenze di tracking non basta. Kµ mantiene sensibilità significativa al rumore e impulsi più grandi di quelli registrati a 2 ms. Il PID ha trasmissione diretta elevata: l’RMS immediato per canale è σy*sqrt(sum(Dy(i,:).^2)), mentre la dinamica successiva cambia l’RMS integrato. Non si corregge un segno per rendere più piccolo il grafico: il segno è verificato indipendentemente.

Il rumore encoder entra nel controllore prima dell’azione di comando. Gli attuatori filtrano u prima della coppia fisica, e la meccanica filtra ulteriormente le posizioni: q può apparire regolare mentre u è inaccettabile. Non abbiamo inventato limiti hardware o scambiato N m con rad. Ordine elevato e condizionamento richiedono cautela, ma l’accordo fra realizzazioni coordinate conferma questi picchi nel modello lineare adottato.

### Pesi e compromesso

We/Wu e Mo provengono dalla sintesi consolidata: errore di model following, disturbo fisico e sforzo sulle porte della pianta generalizzata. Il rumore encoder non è un ingresso esplicito di quel problema. W3 non è stato aggiunto. NP/RS/RP e un buon gradino non garantiscono attenuazione misura–comando. Per Kµ l’ordine 78 e gli scaling dinamici non sono, da soli, una spiegazione sufficiente: la mappa effettiva Tuv è l’evidenza quantitativa.

Lo studio Ts=1,2,5,10 ms conserva la varianza dei campioni: cambia la banda del processo mantenuto. `noise_sampling.csv` riporta **soltanto valori agli istanti campionati**, non risolve i picchi continui. Non confrontare quei RMS con una densità bianca continua né usarli per dichiarare il problema risolto. Un filtro posto prima del controllo cambierebbe rumore, fase e margini e richiederebbe verifiche nuove.

## Decisione e passi successivi

Nessuna correzione progettuale è stata adottata: le unità, i segni e le mappe risultano coerenti. Il limite è la formulazione e la risposta alle misure nel modello adottato; la simulazione non dimostra che quei comandi siano erogabili. Una futura sintesi potrebbe includere v e un vincolo pesato Tuv, oppure un filtraggio di misura motivato, verificando nuovamente tracking, disturbo, stabilità interna, RS/RP e rumore. Saturazioni, anti-windup e riduzione restano opzioni teoriche, non interventi applicati agli originali.

Fonti: `noise_diagnostics.mat`, `noise_metrics.csv`, `noise_sampling.csv`; figure in `report/figures/final_closure/`. Differiscono dai precedenti esperimenti non lineari combinati per seed, ingresso e osservazione del comando: quei numeri non sono stati trasferiti al nuovo protocollo.
'''
    write('docs/ANALISI_RUMORE_MISURA.md',noise)

    final=f'''# CHIUSURA FINALE PROGETTO

Revisione del 12 ottobre 2026 su `codex/chiusura-definitiva-progetto-sea`, base main fa78e588. Branch dedicato, nessun merge o force-push. GitHub è la fonte del progetto; Drive è stato letto senza scritture.

## Gate e prontezza

| Ambito | Stato | Evidenza |
|---|---|---|
| Otto originali | COMPLETE / PASS | CRC, byte e tre SHA-256 coincidenti |
| Audit XML e setup | COMPLETE / PASS statico | Inventario, segni, interfacce, matrici e bus esterni |
| Simulazione SLX | PARTIAL / NOT RUN | R2026a richiesto, R2025b rifiuta tutti gli otto |
| Script didattici | COMPLETE / PASS | Quattro default eseguiti; {scripts['protectedCount']} file scientifici protetti identici; Code Analyzer senza messaggi |
| Test MATLAB | COMPLETE / PASS | {passed}/{len(tests)} passati, nessuno incompleto |
| Rumore | COMPLETE come diagnosi; requisito operativo FAIL | Picchi continui critici H∞ e sensibilità Kµ; nessuna attenuazione artificiale |
| Dieci impianti incerti | COMPLETE / PASS come campagna | Replay, intervalli, blocchi normati; H∞ 0/10, Kµ 10/10 stabili |
| RAS e Lyapunov | COMPLETE come audit; limiti numerici espliciti | Stato intero, 150 punti, distinzione empirico/analitico/ignoto |
| Relazione e slide | Compilazione e ispezione in audit PDF | Capitoli 9–11 consolidati, slide 21, stima 17:50 |
| Prontezza finale | PARTIAL | Validazione e schermate originali R2026a ancora essenziali |

## Risultati conservati e nuove prove

Parametri, equilibrio, Padé, matrici nominali, pesi, incertezze, Kalman M6, LQG/LQGI e controllori robusti restano invariati. Le norme e i margini sono stati nuovamente verificati dal default dei quattro script, senza nuove sintesi. H∞ 2-DoF conserva ordine 22 e Kµ 78; tracking, rumore e robustezza pesata sono proprietà diverse.

La nuova campagna pratica campiona dieci piante fisiche con usample, seed 20261012, e aggiunge il nominale. Le realizzazioni e i parametri sono salvati; nessun riuso dei quaranta campioni. H∞ nominale è stabile, tutti i suoi campioni instabili. Kµ è stabile in tutti gli undici. Per gli instabili i tempi e gli altri indicatori sono NaN; non si accreditano risposte divergenti come prestazioni. Gradini separati di 5 gradi, disturbo link 0.5 N m da 1 s; tempi finiti, DC, accoppiamento, comando e recupero ±0.5 gradi sono distinti.

La diagnosi isolata encoder usa r=d=w=0, σ=0.05 gradi, ZOH 2 ms e 4 s. H∞ presenta picco fra campioni circa {summary['noise'][3]['intersamplePeakU']:.6g} N m e RMS integrato {summary['noise'][3]['intersampleRmsU']:.6g}; Kµ {summary['noise'][5]['intersamplePeakU']:.6g} e {summary['noise'][5]['intersampleRmsU']:.6g}. Il picco è osservato su scansione, non certificato globale. La doppia realizzazione e la quadratura raffinata concordano. Feedthrough H∞ nullo non elimina i modi molto rapidi.

## RAS comune e gate Lyapunov

Griglia 5×5 su ±60 gradi, δtheta=δq, velocità/attuatori/controller nulli; 12 s e ultimo secondo entro 0.5 gradi, 0.02/0.05 rad/s. Arresti per ampiezza o solver non sono prove di divergenza. PID usa ode15s in coordinate bilanciate dopo difficoltà con ode23t/ode15s originali; gli altri ode23t. Ogni punto ha un budget di 60 s di calcolo, indipendente dal tempo fisico; superarlo lascia ignota la convergenza.

| Controllore | Conv. / 25 | Criterio a 12 s fallito | Arresti/solver/tempo | Gate Lyapunov | Livello interno ρ |
|---|---:|---:|---:|---|---:|
'''
    for p in summary['lyapunov']:
        c=counts[p['name']]
        final+=f"| {p['name']} | {c['converged']} | {c['finite_horizon_nonconvergent']} | {c['numerical_or_solver_unknown']} | {'PASS' if p['gatePassed'] else 'FAIL'} | {num(p['rhoCertified'])} |\n"
    final+='''
La matrice Lyapunov è calcolata nello stato aumentato completo. Positività, residuo assoluto e margine prudente di arrotondamento precedono qualsiasi livello interno; il gate richiede residuo+allowance<1e−6. Il resto cubico SEA è maggiorato analiticamente. I livelli ammessi sono sufficienti per il nominale non limitato in double controllata, non prove intervallari o hardware. Gli insiemi LQG/LQGI sono molto piccoli e non sono ingranditi nel confronto grafico. Le ricerche radiali consolidate hanno un protocollo distinto; non si sommano ai nuovi 25 punti.

## Documenti e consegna

Il Capitolo 9 spiega l'ordine elevato, 14 stati di pianta più pesi/Mo e scaling D–K. Il Capitolo 10 presenta RAS, Lyapunov, gate e rumore fra campioni in modo didattico. Il Capitolo 11 sostituisce integralmente la precedente trattazione Monte Carlo con i dieci impianti: stabilità, tracking e disturbo, tre figure e tabelle dai risultati effettivi. Appendici e presentazione seguono gli stessi dati; non narrano lo sviluppo delle revisioni. I quattro script finali e i file storici scientificamente necessari sono conservati.

La presentazione ha 21 slide e stima 17:50. La slide autentica LQGI è condizionale all'esportazione R2026a e aggiunge 0:30. Note orali e scaletta sono aggiornate; il tempo effettivo richiede prova del gruppo. Le miniature SLX non leggibili sono materiale interno, non figure accreditate.

`delivery/manifest.json` elenca i materiali correnti, le dipendenze e gli hash; i documenti interni non sono l'elaborato da inviare al docente. Le regressioni storiche mantengono dati necessari ai test: non sono risultati del nuovo Capitolo 11. La checklist elenca R2026a, verifica delle tracce, figure autentiche, matricole/data e prova orale.

## Problemi incontrati e corretti

Il primo test storico contava ricorsivamente anche i nuovi SLX invece dei soli sei d'archivio: limitato correttamente a originals/, con otto nuovi test SHA separati. La nuova asserzione sulla dimensione della ss-array non considerava il singleton finale restituito da MATLAB: verificati separatamente i due canali, i quattro ingressi e i dieci elementi. Entrambi i difetti di test sono corretti e il run finale passa.

Il primo controllo d'integrità dei quattro script includeva anche il file derivato m7_disturbance_comparison rigenerato dal plotting: conservati separatamente i modelli/controllori congelati e ripristinati gli output derivati del run. Il controllo finale su 80 artifact scientifici è passato. Problemi iniziali di allocazione struct nei nuovi runner sono corretti; solo i run riusciti sostengono le conclusioni. PID non lineare resta numericamente difficile; timeout e arresti sono esiti ignoti, non classificazioni fisiche inventate.

## Giudizio finale

Il branch è pronto per revisione scientifica e integrazione manuale. Gli elaborati sono riproducibili nei limiti dichiarati e mantengono risultati negativi. Non si dichiara completata la validazione Simulink richiesta dalla traccia: servono gli otto run e le immagini reali su R2026a. Non si dichiara pronto il controllo per hardware: rumore, saturazioni non modellate e target temporali falliti sono limiti effettivi. La chiusura documentale non equivale al superamento di tutti i requisiti prestazionali.
'''
    final+='\n## Audit dei PDF compilati\n\n'
    for name in ['report/generated/report_latex_audit.txt','presentation/generated/presentation_latex_audit.txt']:
        text=(ROOT/name).read_text(encoding='utf-8-sig')
        assert 'STATUS=PASS' in text,name
        final+='`'+name+'`:\n\n```text\n'+text.strip()+'\n```\n\n'
    final+='Controllate visivamente tutte le slide e le pagine modificate dei Capitoli 9–11. Corretti pannelli troppo fitti, fuoriuscite e colori esportati dal tema scuro MATLAB. Il testo estratto dal PDF non contiene i conteggi obsoleti 40/40, 0/40, 37/40 o la vecchia diagnosi combinata del rumore.\n'
    write('docs/CHIUSURA_FINALE_PROGETTO.md',final)
    print('Tre report interni prodotti e hash verificati.')
if __name__=='__main__':main()
