"""Generate Chapter 8 tables and the review memo from executed MATLAB data."""
import csv
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / 'results/data/hinf_targeted_revision'


def read(name):
    with (DATA / name).open(encoding='utf-8-sig', newline='') as stream:
        return list(csv.DictReader(stream))


def number(value, digits=4):
    v = float(value)
    return '--' if v != v else f'{v:.{digits}g}'


def latex_table(headers, rows, caption):
    return ('\\begin{table}[htbp]\\centering\\small\n'
            + '\\begin{tabular}{' + 'l' * len(headers) + '}\\toprule\n'
            + ' & '.join(headers) + '\\\\\\midrule\n'
            + '\n'.join(' & '.join(row) + '\\\\' for row in rows)
            + '\n\\bottomrule\\end{tabular}\n\\caption{' + caption + '}\\end{table}\n')


def main():
    s = json.loads((DATA / 'summary.json').read_text())
    full, fixed, tracking = read('full_order.csv'), read('fixed_order.csv'), read('tracking.csv')
    selected = next(row for row in full if int(row['Id']) == s['selectedId'])
    generated = ROOT / 'report/generated/hinf_targeted_revision'
    generated.mkdir(parents=True, exist_ok=True)
    tables = latex_table(
        ['Parametro', 'Baseline', 'Revisione'],
        [[label, number(old), number(new)] for label, old, new in zip(
            [r'$\omega_{W1}$ [rad/s]', r'$A_s$', r'$M_s$', r'$k_u$', r'$\omega_U$ [rad/s]'],
            s['baselineParameters'], s['selectedParameters'])]
        + [[r'Lower bound', number(s['baselineBound'], 7), number(s['lowerBound'], 7)],
           [r'$\omega$ critica [rad/s]', number(s['baselineBoundFrequency']), number(s['boundFrequency'])],
           [r'$\gamma$ hinfsyn', number(s['baselineGamma'], 8), number(s['gammaHinf'], 8)]],
        'La baseline corrente e il nuovo problema restano distinti; M5 non viene riscritto.')
    tables += latex_table(
        ['ID', 'Fase', r'$\omega_{W1}$', r'$A_s$', r'$M_s$', r'$k_u$', r'$\omega_U$', 'LB', r'$\gamma_{mix}$', r'$\gamma_{hinf}$'],
        [[row[k] if k in ('Id', 'Stage') else number(row[k]) for k in
          ['Id', 'Stage', 'OmegaW1', 'As', 'Ms', 'Ku', 'OmegaU', 'LowerBound', 'GammaMix', 'GammaHinf']]
         for row in full],
        'Campagna finita: 12 candidati iniziali e 9 nell\'unico ampliamento. ID 12 scartato prima dei solver; trattini significano NOT RUN.')
    (generated / 'search.tex').write_text(tables, encoding='utf-8')
    families = {'A0': 'Statico MIMO', 'A1': 'PI diagonale', 'A2': 'PID filtrato',
                'A3': 'MIMO ordine 2', 'A4': 'MIMO ordine 4', 'A5': 'MIMO ordine 6'}
    fixed_table = latex_table(
        ['Famiglia', 'Stabili/11', 'Ordine', 'Objective', r'Gap [\%]', r'$\|W_1S\|$', r'$\|W_2KS\|$'],
        [[families[row['Family']], row['StableStarts'] + '/11', number(row['Order']), number(row['Objective'], 6),
          number(100 * float(row['RelativeGap'])), number(row['W1SNorm'], 6), number(row['W2KSNorm'], 6)] for row in fixed],
        'Migliore soluzione stabile per famiglia; gap sulla norma verificata rispetto al full-order. Assenza di soluzioni stabili trovate non dimostra impossibilita\'.')
    fixed_table += latex_table(
        ['Famiglia', r'$t_s$ [s]', r'OS [\%]', r'$e_{ss}$ [\%]', 'Cross', 'Picco [N m]', 'RMS [N m]'],
        [[families[row['Family']], number(row['SettlingTime']), number(row['OvershootPercent']),
          number(100 * float(row['SteadyErrorRelative'])), number(row['CrossCoupling']),
          number(row['PeakControlNm']), number(row['RmsControlNm'])] for row in fixed],
        'Peggiori metriche fra i due gradini da 5 gradi per ciascuna famiglia. Nessun target temporale viene modificato dopo la sintesi.')
    (generated / 'fixed.tex').write_text(fixed_table, encoding='utf-8')
    temporal = latex_table(
        ['Controllore', 'Giunto', r'$t_s$ [s]', r'OS [\%]', r'$e_{ss}$ [\%]', 'Cross', 'Picco', 'RMS'],
        [[row['Controller'], row['Joint'], number(row['SettlingTime']), number(row['OvershootPercent']),
          number(100 * float(row['SteadyErrorRelative'])), number(row['CrossCoupling']),
          number(row['PeakControlNm']), number(row['RmsControlNm'])] for row in tracking if row['Controller'] != 'mixsyn'],
        'Stessi gradini, orizzonte 12 s e passo 2 ms. Picco e RMS in N m; RMS aggregato sui due attuatori e su tutti i campioni.')
    (generated / 'tracking.tex').write_text(temporal, encoding='utf-8')
    chapter = r'''\chapter{Controllo $H_\infty$: baseline e revisione controllata}
\label{cap:hinf}
\section{Obiettivo, perimetro e baseline conservata}
Questa revisione riguarda esclusivamente M9--M11. Pianta M3, modello
incerto M4, specifiche generali M5, LQG/LQRI, Kalman e RAS M6--M8
rimangono congelati. Tutti i precedenti artifact M9/M10/M11 sono conservati
integralmente; i nuovi risultati sono in una directory separata.
Il Capitolo 9 e i successivi descrivono la catena storica e non certificano
i controllori qui introdotti. Anche il riepilogo generale precedente
resta riferito alla baseline, in attesa della revisione successiva autorizzata.

La traccia consente semplificazioni motivate delle prestazioni.
I due gradi di liberta' indicano i due giunti del manipolatore, non impongono
un'architettura di controllo a due gradi di liberta'. La sintesi principale
resta $u=K(r-q)$, nelle coordinate fisiche M3: $u$ in N m, $q$ in rad.
Per $G:u\mapsto q$ definiamo
\[
S=(I+GK)^{-1},\qquad T=I-S,\qquad KS=K(I+GK)^{-1}.
\]
La norma $H_\infty$ e' il massimo valore singolare sulla frequenza per una
mappa stabile; essa limita il guadagno energetico per ingressi $L_2$.
Un gradino permanente non appartiene a $L_2$: norma pesata, overshoot e
picco istantaneo del comando devono essere verificati separatamente.

La prima configurazione storica aveva $\omega_{W1}=12$, $A_s=0.05$,
$M_s=2$, $k_u=1/12$, $\omega_U=30$, con $\gamma\simeq10.207$.
La baseline corrente, successiva alla prima revisione, usa
$(8,0.15,2.5,0.05,60)$ e $\gamma\simeq5.677221$; il suo M11 A5
aveva objective circa 5.708569. Entrambi gli esiti negativi rimangono
tracciati. Il testo integrale del precedente Capitolo 8 e' archiviato in
\path{report/archive/hinf_before_retuning/08_hinf.tex}.

\section{Pesi e target separati dalle specifiche M5}
Si mantengono due filtri scalari replicati sui giunti, senza $W_3$:
\[
W_1=\frac{s/M_s+\omega_{W1}}{s+\omega_{W1}A_s}I_2,\qquad
W_2=k_u\frac{s+\omega_U}{s/6+\omega_U}I_2.
\]
Con $\|[W_1S;W_2KS]\|_\infty<1$ valgono gli inviluppi
$\bar\sigma(S)<1/|W_{1,siso}|$ e $\bar\sigma(KS)<1/|W_{2,siso}|$.
Il parametro $A_s$ limita la sensitivity DC nel problema pesato;
non sostituisce automaticamente la specifica temporale originale.

Prima della campagna si fissano target temporali H-infinity rivisti:
$t_s\le2$ s, overshoot $\le20\%$, errore statico relativo $\le20\%$,
cross-coupling $\le0.25$. M5 conserva rispettivamente 0.8 s, 10\%, 5\%
e il target preliminare 0.25. Questi rilassamenti sono decisioni progettuali,
non equivalenze fra specifiche. Picco e RMS del comando sono misurati:
la scala storica 12 N m non e' una saturazione certificata.

Il nuovo peso selezionato ha $W_1(0)=5$, $W_1(\infty)=0.25$,
polo a 0.4 e zero a 8 rad/s. Il crossover del peso e' circa 2.024 rad/s.
$W_2$ passa da 0.003 a 0.018, con zero a 80 e polo a 480 rad/s.
L'inviluppo del comando passa quindi da circa 333.3 a 55.56 nelle
coordinate SI adottate. Non e' un limite di coppia costante in N m.

\section{Pianta generalizzata ed equivalenza dei solver}
La sintesi M9 rivista usa \texttt{mixsyn(G,W1,W2,[])}. M10 costruisce
indipendentemente con \texttt{connect/sumblk}
\[
\begin{bmatrix}z_1\\z_2\\e\end{bmatrix}
=\underbrace{\begin{bmatrix}W_1&-W_1G\\0&W_2\\I&-G\end{bmatrix}}_P
\begin{bmatrix}r\\u\end{bmatrix},\qquad e=r-q.
\]
Si applica \texttt{hinfsyn(P,2,2)} alla pianta $6\times4$. La lower LFT
$F_\ell(P,K)$ deve coincidere con $[W_1S;W_2KS]$.
Si confrontano $P$ e \texttt{augw}, la mappa ricostruita e la LFT per
lo stesso controllore, e le norme restituite dai due solver.
Due soluzioni ottime non devono necessariamente avere coefficienti identici.
La stabilita' interna si verifica sulla matrice completa a 32 stati
plant--controller, senza cancellazioni mediante \texttt{minreal}.

\section{Diagnosi e rilassamento guidato}
\subsection{Lower bound prima di ogni sintesi}
Ponendo $a=|W_{1,siso}|$, $b=|W_{2,siso}|$ e
$g=\underline\sigma(G)$, l'identita' $S+GKS=I$ implica
\[
\gamma\ge\sup_\omega
\frac{a(\omega)b(\omega)}{\sqrt{b(\omega)^2+a(\omega)^2g(\omega)^2}}.
\]
Il limite deriva dal minimo rispetto al comando complesso libero $v$
di $a^2|1-gv|^2+b^2|v|^2$. Non impone causalita' o stabilita':
e' necessario, non sufficiente. Il massimo campionato su 2401 frequenze
fra $10^{-4}$ e $10^4$ rad/s e' ancora un lower bound: un valore inferiore
a uno non prova fattibilita', un valore maggiore o uguale a uno esclude
il candidato. Tutti i parametri, il massimo e la frequenza critica sono salvati.

Il valore storico circa 1.645 apparteneva ai pesi iniziali con
$\omega_{W1}=12$. Per la baseline corrente il limite e' 1.044723
a 6.166 rad/s, ancora incompatibile con $\gamma<1$.
Il nuovo candidato ha limite 0.257005 a 24.927 rad/s.

\subsection{Campagna finita e motivazione fisica}
La pianta presenta poli instabili a circa 4.04 e 7.21 rad/s; i primi
modi elastici sono a circa 69.95 e 79.40 rad/s. Gli attuatori restano
a $\omega_n=40$ rad/s, $\zeta=0.8$, ritardo 15 ms, Pad\'e di ordine uno,
con zero nel semipiano destro a 133.33 rad/s.
La prima fase incrocia quattro profili $(\omega_{W1},A_s,M_s)$:
$(4,.20,4)$, $(5,.15,3)$, $(6,.10,3)$, $(8,.08,2.5)$, con tre
profili $(k_u,\omega_U)$: $(.03,80)$, $(.04,60)$, $(.05,50)$.
Si tratta di 12 casi motivati, non dell'intero prodotto cartesiano
dei singoli intervalli. Uno viene escluso dal bound; i restanti 11
producono $\gamma>1$ (il migliore circa 3.245).

Si attiva una sola estensione: $\omega_{W1}\in\{2,3,4\}$,
$A_s=.20$, $M_s=4$, $k_u\in\{.003,.005,.01\}$, $\omega_U=80$.
La transizione di W1 scende per separare il tracking lento dall'azione
rapida necessaria alla stabilizzazione; non si assume che la banda
del loop possa essere inferiore al polo instabile.
La penalizzazione del comando viene ridotta sensibilmente per lasciare
autorita' stabilizzante. Lo zero a 80 rad/s e' pari a due volte
$\omega_n$ e vicino ai modi elastici: questo spostamento rilassa
il comando in quella regione, non certifica protezione delle risonanze.
Il ritardo e la meccanica non vengono modificati. Il picco nominale
misurato di 13.31 N m esplicita il prezzo attuativo; fattibilita' hardware
e robustezza non sono dimostrate da questa sintesi nominale.
Non vengono aggiunti altri tentativi dopo i nove casi dell'estensione.
\input{generated/hinf_targeted_revision/search.tex}

\section{Full-order e verifiche temporali}
Un solo candidato, ID 13, raggiunge $\gamma<1$: entrambi i solver
restituiscono $\gamma=0.8660359345$, ordine 18. La differenza relativa
fra i gamma e' $6.43\,10^{-14}$; l'errore massimo in frequenza fra
lower LFT e stack ricostruito e' $3.68\,10^{-13}$.
La massima parte reale dei poli interni e' circa $-0.683829$.
Le norme dei canali sono circa 0.86530 per $W_1S$ e 0.83629 per $W_2KS$;
la norma dello stack non e' il massimo delle due norme separate.

I gradini sono separati, di 5 gradi, per 12 s con passo 2 ms.
Il settling e' l'ultimo ingresso definitivo nella banda del 2\%
dell'ampiezza richiesta intorno al valore finale calcolato con DC gain;
l'offset dal riferimento viene misurato separatamente.
L'overshoot e' riferito all'ampiezza richiesta, non al valore finale.
Il cross-coupling e' il picco del giunto non eccitato diviso per il picco
del giunto eccitato. L'RMS aggrega entrambi gli attuatori e l'intero orizzonte.
Queste definizioni rimangono fisse per tutti i confronti.
\input{generated/hinf_targeted_revision/tracking.tex}
\begin{table}[htbp]\centering\small
\begin{tabular}{lcccc}\toprule
Configurazione & NS & NP pesata & Tempo M5 & Tempo rivisto\\\midrule
Baseline 1-DoF & PASS & FAIL & FAIL & FAIL\\
Nuovo full-order 1-DoF & PASS & PASS & FAIL & FAIL\\
Nuovo MIMO ordine 6 & PASS & PASS & FAIL & FAIL\\
Estensione 2-DoF & PASS & FAIL$^*$ & FAIL & PASS\\\bottomrule
\end{tabular}
\caption{Classificazioni separate. $^*$Per il tracking 2-DoF si misura una nuova
mappa; il feedback conserva il gamma 1-DoF, senza trasferirlo al tracking.}
\end{table}
Il full-order 1-DoF viola tutti e tre i target M5 di settling, overshoot
ed errore statico. Nel set rivisto viola l'overshoot, fino al 130.12\%:
la revisione risolve la fattibilita' nominale pesata, non il tracking 1-DoF.

\section{Fixed-order: minimo ordine trovato}
Solo dopo il PASS full-order vengono provati statico MIMO, PI
decentralizzato, PID con filtro derivativo e MIMO dinamici di ordine 2, 4, 6.
Ogni famiglia usa \texttt{RandomStart=10}, cioe' dieci avvii casuali
oltre a quello nominale: 66 tentativi totali. I seed sono 20260917--20260922,
con 300 iterazioni massime per avvio e nessun incremento adattativo.
Sono salvati objective, blocchi sintonizzati, stabilita', norme ricostruite
e metriche di tutti gli avvii. Il guadagno statico e il PI non forniscono
soluzioni stabili trovate; questo non e' un certificato di impossibilita'.
\input{generated/hinf_targeted_revision/fixed.tex}
L'ordine minimo riuscito nella campagna e' 6: objective 0.879311348,
norma verificata 0.879227202 e gap circa 1.523\% dal full-order.
La piccola differenza objective/norma e' numerica, verificata entro
la tolleranza 0.5\%. Il risultato non dimostra l'ottimalita' globale
del minimo ordine: \texttt{hinfstruct} e' una ricerca locale.
L'ordine 8 non viene attivato perche' l'ordine 6 raggiunge gia' il target.

\section{Disturbo fisico e studio 2-DoF separato}
La verifica applica una coppia di 0.5 N m separatamente a ciascun link,
usando esattamente $B_d$ di M5. Le mappe sono $q_d=SG_d d$ e
$u_d=-KSG_d d$, ricostruite sulla stessa matrice aumentata.
Il confronto indipendente con $SG_d$ e' incluso nei test.
I picchi di posizione sono circa 0.0690 e 0.2430 rad; quelli di comando
1.046 e 1.162 N m. Non viene dichiarata una reiezione conforme senza
un relativo target. Il disturbo resta nella verifica separata:
aggiungerlo come ulteriore ingresso penalizzato cambierebbe l'obiettivo
e impedirebbe il confronto diretto con la mixed sensitivity standard.
Non e' sostituito da un disturbo artificiale di posizione.

Come estensione didattica si aggiunge un prefiltro stabile, senza
rifare la sintesi o imporre la struttura dei colleghi:
\[
M_o(s)=\left(\frac{2}{s+2}\right)^2 I_2,\quad
F(s)=T(0)^{-1}M_o(s),\quad
u=K(F r-q)=K_r r-K_y q.
\]
Qui $K_y=K$, $K_r=KF$. La frequenza 2 rad/s deriva dal corner W1
selezionato; $M_o$ e' diagonale, mentre la matrice statica $T(0)^{-1}$
compensa il guadagno nominale e l'accoppiamento a regime.
Non si inverte dinamicamente la pianta e non si cancellano zeri instabili.
La realizzazione condivide gli stati di K e aggiunge quattro stati stabili
di prefiltro (ordine complessivo 22); non duplica due implementazioni di K.
La stabilita' interna resta verificata e la mappa dal disturbo non cambia.

Questa e' una estensione di command shaping, non una nuova sintesi
$H_\infty$ 2-DoF ottima o un requisito imposto dalla traccia.
Gli esempi del corso motivano la sintesi 1-DoF; il prefiltro viene
derivato autonomamente dalle mappe gia' validate. Il confronto metodologico
con il riferimento Drive e' successivo alla realizzazione e non ne
adotta valori, pesi, disturbi o controllori.
Il tracking ha errore DC nominale nullo, overshoot massimo 1.763\%
e settling massimo 1.784 s: PASS sui target temporali rivisti, ma
FAIL su quello originale di 0.8 s. Con gli stessi pesi, tuttavia,
\[
\left\|\begin{bmatrix}W_1(I-TF)\\W_2KSF\end{bmatrix}\right\|_\infty
=1.381480>1.
\]
Il feedback conserva gamma 0.866036; tale valore non e' il gamma della
nuova mappa di tracking. Miglioramento temporale e conformita' pesata
restano giudizi distinti. La norma di $TF-M_o$ e' circa 0.2920.

\section{Figure didattiche e riproducibilita'}
'''
    figures = [('01_W1', 'Peso W1 e inverso: accuratezza e rilassamento in frequenza.'),
               ('02_W2', 'Peso W2 e inverso: penalizzazione del comando nelle coordinate SI.'),
               ('03_S', 'Sensitivity rispetto al nuovo inviluppo.'),
               ('04_KS', 'Mappa del comando rispetto al nuovo inviluppo.'),
               ('05_weighted', 'Canali pesati e livello uno.'),
               ('06_tracking', 'Due gradini separati da 5 gradi: il PASS pesato non elimina l\'overshoot.'),
               ('07_control', 'Coppie richieste nei medesimi esperimenti.'),
               ('08_fixed_order', 'Frontiera ordine--objective; vengono conservati gli esiti negativi.'),
               ('09_2dof', 'Confronto 1-DoF/2-DoF sulla stessa pianta e sugli stessi riferimenti.'),
               ('10_link_disturbance', 'Verifica fisica con coppie disturbanti lato link di 0.5 N m.')]
    for name, caption in figures:
        chapter += (r'\begin{figure}[p]\centering' + '\n'
                    + r'\includegraphics[width=0.86\textwidth]{figures/hinf_targeted_revision/' + name + '.png}\n'
                    + '\\caption{' + caption + '}\\end{figure}\n')
    chapter += r'''
Gli script dedicati \path{run_hinf_revision},
\path{run_hinf_revision_fixed}, \path{extend_hinf_revision_2dof}
ed \path{export_hinf_revision} leggono M3/M5 congelati e scrivono
soltanto i nuovi artifact. I checkpoint evitano di ripetere sintesi
gia' eseguite. Il comando generale \texttt{run\_all} rimane riferito
alla pipeline storica e non e' stato eseguito in questa revisione.
I sette test mirati verificano identita', stabilita' interna, bound,
66 avvii, metriche e separazione dei criteri. La valutazione e' nominale
lineare: nessuna RAS o garanzia robusta viene trasferita ai nuovi K.
La revisione si arresta qui: nessuna nuova $\mu$-analysis o $\mu$-synthesis.
\clearpage
'''
    target = ROOT / 'report/sections/08_hinf.tex'
    archive = ROOT / 'report/archive/hinf_before_retuning/08_hinf.tex'
    if not archive.exists():
        archive.parent.mkdir(parents=True, exist_ok=True)
        archive.write_bytes(target.read_bytes())
    target.write_text(chapter, encoding='utf-8')
    memo = f'''# Revisione mirata H-infinity — resoconto per il merge

Branch: `codex/hinf-targeted-retuning`. Base: `cb325f6` (main, PR 30).
Responsabile: Alessio. Data: 17 settembre 2026.

La fattibilita nominale pesata e stata raggiunta. Il tracking 1-DoF rimane
non conforme: il lavoro non viene dichiarato un PASS globale.
Main non e modificato; merge riservato al gruppo.

## Parametri e risultati

| Voce | Baseline corrente | Revisione |
|---|---:|---:|
| omegaW1 [rad/s] | 8 | 2 |
| As | 0.15 | 0.20 |
| Ms | 2.5 | 4 |
| ku | 0.05 | 0.003 |
| omegaU [rad/s] | 60 | 80 |
| alpha | 6 | 6 |
| Lower bound | {s['baselineBound']:.9f} | {s['lowerBound']:.9f} |
| Frequenza del bound [rad/s] | {s['baselineBoundFrequency']:.6f} | {s['boundFrequency']:.6f} |
| gamma hinfsyn | {s['baselineGamma']:.9f} | {s['gammaHinf']:.9f} |
| gamma mixsyn nuovo | — | {s['gammaMix']:.9f} |
| Ordine full-order | 18 | 18 |

Differenza relativa gamma mixsyn/hinfsyn: {s['gammaRelativeError']:.3g}.
Errore mappe pesate/LFT: {s['mapError']:.3g}; errore P/augw: {s['plantError']:.3g}.
Massima parte reale poli interni: {s['maxRealPole']:.9f}.
Il lower bound storico 1.645 riguarda i pesi anteriori alla baseline corrente
(omegaW1=12, As=.05, Ms=2, ku=1/12, omegaU=30; gamma circa 10.207).

## Ricerca e motivazione dei rilassamenti

12 casi iniziali: quattro profili W1 e tre profili W2 accoppiati, non una
ricerca cartesiana esaustiva. ID 12 e scartato con LB>=1 prima dei solver.
Gli altri 11 hanno gamma>1; minimo 3.244811. Unica estensione: nove casi
con omegaW1={{2,3,4}}, As=.20, Ms=4, ku={{.003,.005,.01}}, omegaU=80.
Solo ID 13 raggiunge gamma<1. Sono state eseguite 20 coppie mixsyn/hinfsyn
nella campagna; una precedente sonda esplorativa su ID 1, senza modifiche
agli artifact, aveva gia verificato gamma 3.244811.

Poli instabili 4.04/7.21 rad/s, attuatore wn=40, modi elastici circa
69.95/79.40 rad/s, zero Pade RHP 133.33 rad/s: tutti invariati.
Il corner W1=2 riduce la richiesta di tracking, non impone una banda di
stabilizzazione inferiore al polo instabile. As=.20 rilassa la sensitivity
DC; Ms=4 consente un picco maggiore. ku=.003 lascia maggiore autorita
stabilizzante: il picco misurato arriva a 13.31 N m. omegaU=80 ritarda
la crescita del peso verso due volte wn, vicino ai modi elastici; questa
scelta non certifica robustezza ne protezione dalle risonanze.
Nessun limite hardware e dedotto da uScale=12. Nessuna scala della pianta
e cambiata e nessuna incertezza e ridotta.

I target rivisti sono fissati prima delle sintesi: settling<=2 s,
overshoot<=20%, errore statico<=20%, cross<=.25. M5 resta 0.8 s, 10%,
5%, cross preliminare .25. Il rilassamento non equivale a M5.

## Metriche temporali

Due gradini separati di 5 gradi; 12 s, passo 2 ms. Settling nella banda
del 2% dell'ampiezza richiesta intorno al valore finale DC; offset misurato
separatamente. Overshoot riferito al riferimento. Cross: picco giunto non
eccitato / picco giunto eccitato. Picco massimo sui due comandi; RMS
aggregato sui due attuatori e sull'intero orizzonte.

| Controllore | Giunto | Ts [s] | OS [%] | Errore [%] | Cross | Picco [N m] | RMS [N m] |
|---|---:|---:|---:|---:|---:|---:|---:|
'''
    for row in tracking:
        if row['Controller'] == 'mixsyn':
            continue
        memo += '| ' + ' | '.join([row['Controller'], row['Joint'], number(row['SettlingTime']),
                                  number(row['OvershootPercent']), number(100 * float(row['SteadyErrorRelative'])),
                                  number(row['CrossCoupling']), number(row['PeakControlNm']), number(row['RmsControlNm'])]) + ' |\n'
    memo += '''
Full-order 1-DoF: NS PASS; Hinf NP PASS; M5 temporal FAIL (Ts, overshoot,
offset); revised temporal FAIL (overshoot). Nessuna modifica a posteriori
delle metriche o soglie. Il PASS nominale non certifica RS/RP.

## Fixed-order

10 RandomStart oltre alla partenza nominale per famiglia, seed 20260917–20260922,
MaxIter=300. Tutti i 66 avvii sono salvati; nessun aumento del budget.

| Famiglia | Avvii stabili | Ordine | Objective | Norma verificata | Gap [%] | W1S | W2KS |
|---|---:|---:|---:|---:|---:|---:|---:|
'''
    for row in fixed:
        memo += '| ' + ' | '.join([families[row['Family']], row['StableStarts'] + '/11', number(row['Order']),
                                  number(row['Objective'], 8), number(row['StackNorm'], 8),
                                  number(100 * float(row['RelativeGap'])), number(row['W1SNorm']), number(row['W2KSNorm'])]) + ' |\n'
    memo += '''
Il minimo ordine trovato e 6, non un minimo globale dimostrato.
Ordine 8 NOT RUN perche 6 e gia conforme. Tutti i rappresentanti stabili
restano FAIL sui target temporali originali e rivisti. Metriche complete
per famiglia in `results/data/hinf_targeted_revision/fixed_order.csv`;
per ogni singolo avvio, mappe e metriche per giunto nei MAT fixed_*.mat.

## Disturbo e 2-DoF

La verifica del disturbo usa BdFull M5: due gradini separati da 0.5 N m
lato link, senza disturbi artificiali di posizione. Picchi di posizione
0.0690/0.2430 rad e comando 1.046/1.162 N m. Non si inventa una soglia
di reiezione. La sintesi conserva lo stesso problema mixed sensitivity
per verificare mixsyn/hinfsyn; aggiungere ingressi pesati di disturbo
costituirebbe un diverso obiettivo. Mappe SGd verificate separatamente.

Estensione opzionale: Mo=(2/(s+2))^2 I, F=T(0)^(-1) Mo,
u=K(F r-y)=Kr r-Ky y, realizzazione condivisa di K (18+4=22 stati).
La frequenza deriva dal W1 selezionato; nessun numero dei colleghi copiato.
E un prefiltro didattico, non una sintesi Hinf 2-DoF ottima.
Stessa pianta, stessi pesi, ampiezza e metriche; disturbo invariato.
NS PASS; target temporali rivisti PASS; M5 FAIL sul settling.
La nuova norma di tracking e 1.381480>1 (FAIL); il feedback conserva
gamma=.866036, che non viene trasferito alla nuova mappa.

## File e riproducibilita

- `analysis/run_hinf_revision.m`: campagna full-order separata, checkpoint e selezione.
- `analysis/run_hinf_revision_fixed.m`: sei famiglie, 66 avvii e ordine 8 condizionale.
- `analysis/extend_hinf_revision_2dof.m`: estensione separata e verifiche.
- `analysis/export_hinf_revision.m`: CSV, JSON e dieci figure con assi neri.
- `controllers/hinf/hinf_revision_*.m`: configurazione, pesi, bound, P, valutazione e metriche.
- `tests/test_hinf_targeted_revision.m`: sette verifiche mirate.
- `results/data/hinf_targeted_revision/`: nuovi artifact completi e output dei test.
- `report/sections/08_hinf.tex`: unico capitolo aggiornato.
- `report/archive/hinf_before_retuning/08_hinf.tex`: testo precedente integrale.
- `report/generated/hinf_targeted_revision/`, `report/figures/hinf_targeted_revision/`: tabelle e figure nuove.
- `report/Progetto_CR_Relazione_finale.pdf`: relazione ricompilata, con il resto riferito alla baseline.
- `tools/build_hinf_revision_report.py`: genera tabelle, capitolo e questo resoconto dai dati.
- `tools/verify_hinf_revision.py`: controlla il perimetro rispetto a main, gli hash e il log LaTeX.
- README, CHANGELOG, PROJECT_STATUS, DECISION_LOG, DIARIO_DI_BORDO: annotazioni di ambito.

```matlab
addpath('analysis');
run_hinf_revision;
run_hinf_revision_fixed;
extend_hinf_revision_2dof;
export_hinf_revision;
assertSuccess(runtests('tests/test_hinf_targeted_revision.m'));
```

Con artifact presenti, le sintesi sono lette dai checkpoint verificati.
Per una riproduzione da zero usare un clone separato senza la sola directory
dei nuovi risultati; non cancellare le baseline. Non eseguire run_all:
la pipeline globale storica resta congelata e non adotta automaticamente
questi nuovi controllori.

Tabelle/test/figure derivano da MATLAB R2025b realmente eseguito.
Test mirati: 7/7 PASS; Code Analyzer: zero segnalazioni sui nuovi file MATLAB.
Gli esiti di performance FAIL restano distinti dai test di correttezza PASS.
Audit dei file congelati e compilazione PDF registrati in
`results/data/hinf_targeted_revision/verification.json`.

## Materiale e limite della revisione

La traccia SEA locale e stata letta integralmente. Il materiale del corso
`Es_MatlabSimulink_Salaris/MixSyn-Connect-lft/MixedSensitivity_SISO_1dof.m`
supporta la costruzione con connect/sumblk. Il riferimento dei colleghi
su Drive e stato consultato in sola lettura dopo la prima implementazione
indipendente; usa scelte e disturbi differenti, non trasferiti al progetto.
Riferimento: https://drive.google.com/file/d/1J8iR3OVwtfgoGvEJYXBkDfEc6TvHjl_W/view
API consultate: https://www.mathworks.com/help/robust/ref/dynamicsystem.mixsyn.html
e https://www.mathworks.com/help/robust/ref/dynamicsystem.hinfstruct.html

M9/M10/M11 storici, M0–M8, Capitoli 1–7, Capitolo 9 e successivi restano
inalterati nei sorgenti e nei dati. Il vecchio abstract e le conclusioni
generali sono anch'essi conservati: il nuovo Capitolo 8 esplicita che
descrivono la baseline. Nessun risultato robusto o RAS storico e attribuito
ai nuovi controllori. STOP prima di mu-analysis/mu-synthesis: la revisione
nominale e pronta per il controllo del gruppo, non per una dichiarazione
di completezza robusta del progetto.
'''
    (ROOT / 'docs/RESOCONTO_HINF_TARGETED_RETUNING.md').write_text(memo, encoding='utf-8')


if __name__ == '__main__':
    main()
