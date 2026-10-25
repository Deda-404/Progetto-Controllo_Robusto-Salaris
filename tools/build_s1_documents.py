"""Elaborati S1 dai CSV eseguiti, conservando fisica e derivazioni di main.
Questo strumento di sviluppo non serve all'esecuzione della consegna.
"""
from pathlib import Path
import csv
import json
import math
import shutil

ROOT=Path(__file__).resolve().parents[1]
PKG=ROOT/'Progetto_SEA_Consegna'
DOC=PKG/'documenti'
REL=DOC/'relazione'
SLIDES=DOC/'presentazione'
SCHEMES=DOC/'schemi'
SCHEMES.mkdir(exist_ok=True)

def read(name):
    return list(csv.DictReader((PKG/'dati'/name).open(encoding='utf-8-sig')))

def esc(s):
    return str(s).replace('_',r'\_').replace('%',r'\%').replace('&',r'\&')

def num(v,d=4):
    try:
        n=float(v)
        if not math.isfinite(n): return r'$\infty$' if math.isinf(n) else 'n.i.'
        return f'{n:.{d}g}'
    except (ValueError,TypeError): return esc(v)

def table(headers,rows,caption=''):
    body='\n'.join(' & '.join(str(c) for c in row)+r'\\' for row in rows)
    text=r'\begin{center}\small\begin{tabular}{l'+('r'*(len(headers)-1))+r'}\toprule'+'\n'
    text+=' & '.join(headers)+r'\\\midrule'+'\n'+body+'\n'+r'\bottomrule\end{tabular}'
    if caption:text+='\n'+r'\par\medskip\footnotesize '+caption
    return text+'\n'+r'\end{center}'+'\n'

def diagram(name,body):
    (SCHEMES/(name+'.tex')).write_text(r'''\begin{tikzpicture}[>=Latex,thick,
 b/.style={draw,rounded corners=1pt,minimum height=9mm,minimum width=18mm,align=center},
 s/.style={draw,circle,inner sep=1pt,minimum size=5mm},font=\small]
'''+body+'\n'+r'\end{tikzpicture}'+'\n',encoding='utf-8')

diagram('sea',r'''
\node[b] (a) at (0,2) {$G_{a,i}$};\node[s] (sm) at (2,2) {$\Sigma$};
\node[b] (motor) at (4,2) {Motore\\$J_m,B_m$};
\node[s] (es) at (7,2) {$\Sigma$};\node[b] (ks) at (7,0) {$K_s$};
\node[s] (sl) at (5,0) {$\Sigma$};\node[b] (link) at (2.5,0) {Link\\$M,C,G$};
\draw[->](-1.8,2)--node[above]{$u$}(a);\draw[->](a)--node[above]{$\tau$}(sm);
\draw[->](sm)--node[above]{$+$}(motor);\draw[->](motor)--node[above]{$\theta\ (+)$}(es);
\draw[->](es)--node[right]{$\theta-q$}(ks);\draw[->](ks)--node[below]{$\tau_{el}$}(sl);
\draw[->](sl)--(link);\draw[->](link)--node[above]{$q$}(.5,0);
\draw[->](.8,0)--(.8,-1.8)--(8.2,-1.8)--(8.2,2)--node[above]{$-$}(es);
\draw[->](5.8,0)--(5.8,.9)--(2,.9)--node[right]{$-$}(sm);
\draw[->](5,-1.2)--node[right]{$d$}(sl);
''')
diagram('nominale',r'''
\node[b](h) at (0,0) {$H_0(s)$\\$\omega_n=40,\ \zeta=0.8$};
\node[b](d) at (4,0) {$D_{p0}(s)$\\$\tau_0=15$ ms};
\draw[->](-3,0)--node[above]{$u_i$}(h);\draw[->](h)--(d);
\draw[->](d)--node[above]{$\tau_i$}(7,0);
''')
diagram('parametrico',r'''
\node[b,minimum width=40mm,minimum height=14mm](m) at (0,0) {$M_{osc}$\\$(x,v)$};
\node[b,minimum width=45mm](delta) at (0,2) {$\delta_{\omega i} I_2,\ \delta_{\zeta i}$};
\node[b](dp) at (4,0) {$D_{p0}$};
\draw[->](-3.8,0)--node[above]{$u_i$}(m);\draw[->](m)--node[above]{$x_i$}(dp);
\draw[->](dp)--node[above]{$\tau_i$}(6.5,0);
\draw[->](m.north east)--(2.8,.7)--(2.8,2)--node[above]{$z_\Delta$}(delta.east);
\draw[->](delta.west)--(-2.8,2)--(-2.8,.7)--node[above]{$w_\Delta$}(m.north west);
\node[align=center] at (0,-1.2) {$w_\Delta=\Delta_i z_\Delta$; tre porte, due parametri fisici.};
''')
diagram('concentrato',r'''
\node[s](sum) at (1,0) {$\Sigma$};\node[b](g) at (4,0) {$G_{a0}=H_0D_{p0}$};
\node[b](w) at (-1,1.7) {$W_I$};\node[b](d) at (1,1.7) {$\Delta_i$};
\draw[->](-4,0)--node[above]{$u_i$}(sum);\draw[->](sum)--(g);\draw[->](g)--node[above]{$\tau_i$}(7,0);
\draw[->](-3,0)--(-3,1.7)--(w);\draw[->](w)--(d);\draw[->](d)--node[right]{$+$}(sum);
\node[align=center] at (1,-1.2) {$i=1,2$ indipendenti, $\|\Delta_i\|_\infty\le1$; nessun canale incrociato.};
''')
diagram('lft',r'''
\node[b,minimum width=45mm,minimum height=18mm](m) at (0,0) {$M$ certo};
\node[b,minimum width=30mm](d) at (0,2) {$\Delta$ normalizzata};
\draw[->](-4,-.3)--node[above]{$u$}(m.west);\draw[->](m.east)--node[above]{$y$}(4,-.3);
\draw[->](m.north east)--(2.8,.9)--(2.8,2)--node[above]{$z_\Delta$}(d.east);
\draw[->](d.west)--(-2.8,2)--(-2.8,.9)--node[above]{$w_\Delta$}(m.north west);
\node at (0,-1.3) {$G=F_u(M,\Delta)=\texttt{lft(Delta,M)}$};
''')
diagram('generalizzata',r'''
\node[b,minimum width=48mm,minimum height=20mm](p) at (0,0) {$P$: SEA, $M_o,W_1,W_2$};
\node[b,minimum width=35mm](k) at (0,-2.3) {$K=[K_r\ K_y]$};
\draw[->](-5,.5)--node[above]{$w=[r;d]$}(-2.4,.5);
\draw[->](2.4,.5)--node[above]{$z=[W_1(q-M_or);W_2u]$}(7,.5);
\draw[->](2.4,-.5)--(3.8,-.5)--(3.8,-2.3)--node[above]{$y=[r;q]$}(k.east);
\draw[->](k.west)--(-3.8,-2.3)--(-3.8,-.5)--node[above]{$u$}(-2.4,-.5);
''')
diagram('lqg',r'''
\node[b](nr) at (-2,1) {$N_r$};\node[s](sum) at (0,1) {$\Sigma$};
\node[b](p) at (3,1) {SEA nominale};\node[b](kal) at (3,-1) {Kalman\\$A-LC,B,L$};
\node[b](kk) at (0,-1) {$K$};\node[s](ym) at (6,1) {$\Sigma$};
\draw[->](-4,1)--node[above]{$r$}(nr);\draw[->](nr)--(sum);\draw[->](sum)--node[above]{$u$}(p);
\draw[->](p)--node[above]{$[q;\theta]$}(ym);\draw[->](6,2)--node[right]{$v$}(ym);
\draw[->](ym)--(7,1)--(7,-1)--node[above]{$y_{mis}$}(kal.east);
\draw[->](1,1)--(1,0)--(3,0)--(kal.north);
\draw[->](kal)--node[above]{$\hat x$}(kk);\draw[->](kk)--node[right]{$-$}(sum);
\draw[->](3,2)--node[right]{$d$}(p);
''')
diagram('lqgi',r'''
\node[s](e) at (-2,1) {$\Sigma$};\node[b](i) at (0,1) {$1/s$};
\node[b](ki) at (2,1) {$K_i$};\node[s](u) at (4,1) {$\Sigma$};
\node[b](p) at (7,1) {SEA};\node[b](kal) at (7,-1.3) {Kalman};\node[b](kx) at (4,-1.3) {$K_x$};
\draw[->](-4,1)--node[above]{$r$}(e);\draw[->](e)--(i);\draw[->](i)--node[above,yshift=5mm]{$\xi$}(ki);
\draw[->](ki)--node[above]{$-$}(u);\draw[->](u)--node[above]{$u$}(p);
\draw[->](p)--node[above]{$y_{mis}=[q;\theta]+v$}(11,1);
\draw[->](10,1)--(10,-1.3)--(kal);\draw[->](kal)--node[above]{$\hat x$}(kx);
\draw[->](kx)--node[right]{$-$}(u);\draw[->](5,1)--(5,0)--(7,0)--(kal.north);
\node[b](sel) at (3,2.5) {$E=[I_2\ 0]$};
\draw[->](9,1)--(9,2.5)--(sel.east);
\draw[->](sel.west)--(-2,2.5)--node[right]{$-q_{mis}$}(e);
''')
diagram('mixsyn',r'''
\node[s](e) at (0,0) {$\Sigma$};\node[b](k) at (2,0) {$K_e$};\node[b](g) at (5,0) {$G$};
\node[b](w1) at (0,2) {$W_1$};\node[b](w2) at (3.5,2) {$W_2$};
\draw[->](-2,0)--node[above]{$r$}(e);\draw[->](e)--node[above]{$e$}(k);
\draw[->](k)--node[above]{$u$}(g);\draw[->](g)--node[above]{$q$}(8,0);
\draw[->](7,0)--(7,-1.2)--(0,-1.2)--node[right]{$-$}(e);
\draw[->](.6,0)--(.6,1)--(0,1)--(w1);\draw[->](w1)--node[above]{$z_1$}(0,3);
\draw[->](3.5,0)--(w2);\draw[->](w2)--node[above]{$z_2$}(3.5,3);
''')
diagram('due_dof',r'''
\node[b](kr) at (0,1) {$K_r$};\node[s](sum) at (3,1) {$\Sigma$};\node[b](g) at (6,1) {$G$};
\node[b](ky) at (3,-1) {$K_y$};\draw[->](-3,1)--node[above]{$r$}(kr);
\draw[->](kr)--(sum);\draw[->](sum)--node[above]{$u$}(g);\draw[->](g)--node[above]{$q$}(9,1);
\draw[->](8,1)--(8,-1)--node[above]{$q_{mis}$}(ky);\draw[->](ky)--node[right]{$+$}(sum);
\node[align=center] at (3,-2.2) {$K_y$ contiene il segno; $K_r,K_y$ condividono lo stesso $x_c$.};
''')
diagram('dk',r'''
\node[b](k) at (0,1) {K-step\\$H_\infty$ scalata};\node[b](mu) at (4,1) {Analisi $\mu$\\sulla LFT};
\node[b](fit) at (4,-1) {Fit razionale\\delle scalature};\node[b](d) at (0,-1) {D-step\\$D,G$ diagonali};
\draw[->](k)--node[above]{$K_j$}(mu);\draw[->](mu)--node[right]{bounds}(fit);
\draw[->](fit)--(d);\draw[->](d)--node[left]{$D_j,G_j$}(k);
''')
diagram('robusta',r'''
\node[b,minimum width=45mm,minimum height=18mm](n) at (0,0) {$N=F_l(P,K)$};
\node[b,minimum width=38mm](d) at (0,2) {$\Delta_A$ oppure $\Delta_B$};
\draw[->](n.north east)--(2.8,.9)--(2.8,2)--node[above]{$z_\Delta$}(d.east);
\draw[->](d.west)--(-2.8,2)--(-2.8,.9)--node[above]{$w_\Delta$}(n.north west);
\draw[->](-5,-.3)--node[above]{$w=[r;d]$}(n.west);\draw[->](n.east)--node[above]{$z_p$}(5,-.3);
\node[align=center] at (0,-1.4) {RS: $\mu_\Delta(N_{11})$; RP: aggiunta del blocco fittizio di prestazione.};
''')
diagram('confronto',r'''
\node[b](a) at (0,1) {$F_l(P_A,K)$};\node[b](b) at (0,-1) {$F_l(P_B,K)$};
\node[b](r) at (5,0) {NS/NP/RS/RP\\con stessi pesi};
\draw[->](-4,0)--(-3,0)--(-3,1)--node[above]{$r,d$}(a);
\draw[->](-3,0)--(-3,-1)--(b);\draw[->](a)--(3,1)--(r);
\draw[->](b)--(3,-1)--(r);\draw[->](r)--node[above]{confronto}(8,0);
\node at (0,-2) {Analisi: stesso $K$. Sintesi dedicata: $K_A,K_B$ separati.};
''')

quadro=read('quadro_finale.csv'); robust=read('confronto_robusto.csv'); nominal=[x for x in read('dieci_impianti.csv') if x['Impianto']=='1']
hf=read('confronto_hinf.csv'); qr=read('scelte_lqg.csv'); ras=read('ras_empirica.csv'); nl=read('lineare_nonlineare.csv')
v=json.loads((PKG/'dati/parametri_verificati.json').read_text())
robrows=[]
for x in quadro:
    rs=[r for r in robust if r['Controllore']==x['Controllore']]
    vals=[]
    for field in ['RS','RP']:
        for r in rs:
            lo=num(r[field+'_lower']);hi=num(r[field+'_upper'])
            vals.append(f'[{lo}, {hi}]'+(r'$^*$' if 'INCLUSIONE' in r['MetodoRP'] and field=='RP' else ''))
    robrows.append([esc(x['Controllore']),num(x['Ordine']),num(rs[0]['NormaNominaleComune']),*vals])
robtable=table(['K','Ord.','NP: norma',r'$\rho_{RS,A}$',r'$\rho_{RS,B}$',r'$\rho_{RP,A}$',r'$\rho_{RP,B}$'],robrows)
nomtable=table(['K',r'$T_s$ [s]',r'$M_p$ [\%]',r'$e_{DC}$ [\%]',r'$u_{pk}$ [N m]',r'$\|T_{uv}\|_\infty$'],
    [[esc(x['Controllore']),num(x['Ts_s']),num(x['Overshoot_percent']),num(100*float(x['ErroreDC_rel'])),num(x['PiccoTracking_Nm']),num(x['GuadagnoRumoreComando'])] for x in nominal])
rastable=table(['K','Stabili/10','Convergenti/15','Non convergenti','Inconcludenti'],
    [[esc(x['Controllore']),num(x['StabiliSu10']),num(x['RasConvergentiSu15']),str(15-int(x['RasConvergentiSu15'])-int(x['RasInconcludenti'])),num(x['RasInconcludenti'])] for x in quadro])
qrtable=table(['Fattore',r'Decad. LQR [s$^{-1}$]',r'$u_{pk}$ [N m]',r'$e_{rms}$ [rad]',r'Decad. filtro [s$^{-1}$]'],
    [[num(x[c]) for c in ['Fattore','DecadimentoLQR','PiccoComandoNm','ErroreStimatoreRMSrad','DecadimentoKalman']] for x in qr])
hftable=table(['Metodo','Ordine','Norma proprio problema'],[[esc(x['Metodo']),num(x['Ordine']),num(x['GammaProprioProblema'],6)] for x in hf])
disttable=table(['K',r'$q_{pk,d}$ [rad]',r'$q_{DC,d}$ [rad]',r'$u_{pk,d}$ [N m]',r'$u_{rms,r}$ [N m]'],
    [[esc(x['Controllore']),num(x['PiccoDisturbo_rad']),num(x['ResiduoDisturboDC_rad']),num(x['ComandoDisturbo_Nm']),num(x['RMSTracking_Nm'])] for x in nominal])
for name,text in [('robustezza',robtable),('nominale',nomtable),('ras',rastable),('lqg',qrtable),('hinf',hftable),('disturbi',disttable)]:
    (REL/(name+'.tex')).write_text(text,encoding='utf-8')

# Testo fisico e derivazione Q recuperati dalla relazione principale di main.
physical=(ROOT/'report/sections/02_modello_dinamico.tex').read_text(encoding='utf-8-sig')
physical=physical.split(r'\section{Implementazione e verifiche}')[0].split('\n',1)[1]
physical=physical.replace(r'=K_s(\theta-q),',r'=K_s(\theta-q)+d,')
physical=physical.replace(r'\theta-q)-C(q,\dot q)\dot q-G(q)\right]',r'\theta-q)-C(q,\dot q)\dot q-G(q)+d\right]')
oldlq=(ROOT/'report/sections/07_lqg.tex').read_text(encoding='utf-8-sig')
qderivation=oldlq.split(r'\subsection{Trasformazione esplicita e matrice Q non diagonale}')[1].split(r'\subsection{R: peso diretto dello sforzo di controllo}')[0]
shutil.copyfile(ROOT/'report/generated/lqr_matrices.tex',REL/'matrici_lqr.tex')
shutil.copyfile(ROOT/'report/generated/kalman_matrices.tex',REL/'matrici_kalman.tex')
shutil.copyfile(ROOT/'report/generated/noise_redesign_synthesis.tex',REL/'rumore_storico_sintesi.tex')
shutil.copyfile(ROOT/'report/generated/noise_redesign_simulink.tex',REL/'rumore_storico_simulink.tex')
shutil.copyfile(ROOT/'report/figures/noise_redesign/noise_before_after.png',PKG/'figure/rumore_storico.png')

PREAMBLE=r'''\documentclass[11pt,a4paper,oneside]{report}
\usepackage[T1]{fontenc}\usepackage[utf8]{inputenc}\usepackage[italian]{babel}
\usepackage{amsmath,amssymb,mathtools,graphicx,booktabs,longtable,array,geometry,hyperref,xcolor,tikz,listings,float}
\usetikzlibrary{arrows.meta,positioning,calc}
\geometry{margin=2.35cm}\setlength{\emergencystretch}{3em}
\hypersetup{hypertexnames=false,colorlinks=true,linkcolor=blue!45!black,urlcolor=blue!55!black}
\lstset{language=Matlab,basicstyle=\ttfamily\footnotesize,breaklines=true,columns=fullflexible,frame=single}
\newcommand{\schema}[2]{\begin{figure}[htbp]\centering\resizebox{.95\linewidth}{!}{\input{../schemi/#1}}\caption{#2}\end{figure}}
\newcommand{\grafico}[2]{\begin{figure}[htbp]\centering\includegraphics[width=.98\linewidth]{../../figure/#1}\caption{#2}\end{figure}}
\title{Manipolatore SEA a due giunti\\\large Incertezza parametrica e concentrata degli attuatori}
\author{Alessio de Dato -- matricola 635256\\Valerio Rebechi -- matricola 722224}
\date{25 ottobre 2026}
\setcounter{tocdepth}{0}
\begin{document}\maketitle
\begin{abstract}
Confrontiamo due rappresentazioni della variabilita degli attuatori di un
manipolatore SEA: quattro parametri reali indipendenti e due blocchi dinamici
SISO concentrati. Conserviamo il nominale, i sei controllori consolidati e
i pesi prestazionali. Mostriamo una LFT manuale e una maggiorazione analitica
dell'errore relativo che contiene l'intero box parametrico. L'analisi dello
stesso controllore sui due insiemi e separata dalle due sintesi D--K dedicate.
Il concentrato riduce alcuni margini dei controllori fissi, ma la sua sintesi
dedicata produce in questa campagna un candidato a 32 stati, rispetto agli
88 del candidato parametrico, con garanzie su entrambi i modelli. Restano
requisiti temporali non soddisfatti e sensibilita al rumore. Dieci impianti
fisici e quindici condizioni iniziali comuni completano il confronto,
distinguendo convergenza, mancata convergenza nell'orizzonte ed esiti numerici
inconcludenti. Le verifiche Simulink precedenti sono conservate come storia;
la nuova integrazione e riservata ai modelli che saranno forniti dagli studenti.
\end{abstract}\tableofcontents
'''
TEXT=r'''
\chapter{Introduzione e problema SEA}
La domanda del progetto e come cambino le conclusioni di robustezza quando
la stessa variabilita attuativa viene rappresentata conservandone i parametri
fisici oppure tramite un inviluppo dinamico. I controllori servono a rendere
visibili le conseguenze delle due descrizioni. Non confrontiamo due impianti
nominali differenti e non attribuiamo a un insieme le garanzie calcolate su un altro.

La traccia richiede LQG con e senza integratore, sensibilita mista con
\texttt{mixsyn}/\texttt{hinfsyn}, esplorazione \texttt{hinfstruct}, sintesi D--K,
analisi $\mu$, simulazioni lineari/non lineari e RAS. Tutti questi metodi
restano nel percorso. I valori nominali e le scelte consolidate sono
conservati; e stata approvata la semplificazione S1 delle sole incertezze.
\schema{confronto}{Confronto diretto: stesso controllore e stessi pesi. Le sintesi dedicate vengono considerate separatamente.}

\chapter{Modello fisico e linearizzazione}
%PHYSICAL%
\schema{sea}{Interazione motore--molla--link. Il comando attraversa il drive; il disturbo esterno e applicato ai link.}
\section{Equilibrio, modello incrementale e stato completo}
Manteniamo $\bar q=[\pi/2,0]^T$, $\bar\tau=G(\bar q)$ e
$\bar\theta=\bar q+K_s^{-1}G(\bar q)$. Analiticamente $G(\bar q)=0$;
i residui floating-point non rappresentano deformazioni fisiche.
Le coordinate di lavoro sono deviazioni da questo equilibrio.
Il modello meccanico ha due modi instabili, circa $+7.2094$ e $+4.0408$
s$^{-1}$, e modi elastici attorno a 70--80 rad/s.

Posto $M_0=M(\bar q)$ e $K_g=\partial G/\partial q|_{\bar q}$,
\[
A_m=\begin{bmatrix}0&I&0&0\\-M_0^{-1}(K_s+K_g)&0&M_0^{-1}K_s&0\\
0&0&0&I\\J_m^{-1}K_s&0&-J_m^{-1}K_s&-J_m^{-1}B_m\end{bmatrix}.
\]
Il disturbo entra con $B_d=[0;M_0^{-1};0;0]$, mentre la coppia motore entra
nell'accelerazione dei rotori. Un Jacobiano numerico indipendente della
nuova funzione non lineare verifica questa linearizzazione e il canale del
disturbo. Le potenze di $A$ sono mal condizionate: le verifiche storiche di
controllabilita e osservabilita usano anche PBH e riscalamento del tempo.
La pianta nominale completa ha 14 stati: otto meccanici e sei dei drive.
La sua realizzazione conservata e usata senza trasformare le coordinate
interne degli osservatori LQG/LQGI.

\chapter{Attuatori e scelta dei parametri}
\section{Nominale e significato fisico}
Per ciascun attuatore
\[
G_{a0}(s)=H_0(s)D_{p0}(s),\quad
H_0=\frac{40^2}{s^2+2(0.8)(40)s+40^2},\quad
D_{p0}=\frac{1-0.015s/2}{1+0.015s/2}.
\]
$\omega_n$ governa la scala dinamica del drive; $\zeta$ ne cambia smorzamento
e forma; $\tau$ sottrae fase. Inerzia e smorzamento dei rotori sono gia
nella meccanica e non vengono duplicati nel drive.
La banda nominale storicamente verificata e circa 34.78 rad/s: sopra i
modi instabili, sotto i modi elastici. I nominali sono assunzioni progettuali,
non dati identificati. Padé1 ha polo $-133.33$ e zero $+133.33$ s$^{-1}$.
\schema{nominale}{Secondo ordine e Padé1 nominali, uguali nei due modelli incerti.}
\section{Selezione limitata e decisione S1}
Il preliminare ha considerato solo $\omega_n$, oppure le coppie
$\omega_n/\zeta$, $\omega_n/\tau$ e $\zeta/\tau$. Cinque valori per parametro
sono stati esaminati uno alla volta. I nominali consolidati non sono stati
nuovamente ottimizzati. I valori provati sono
\[
\omega_n=\{36,38,40,42,44\},\quad
\zeta=\{.72,.76,.8,.84,.88\},\quad
\tau=\{12,13.5,15,16.5,18\}\ \mathrm{ms}.
\]
Fino a 40 rad/s il massimo scostamento relativo complesso del drive e
16.41\%, 11.11\% e 11.18\% rispettivamente. Sono sensibilita del blocco,
non margini robusti del manipolatore. Il ritardo non e trascurabile:
sceglierlo noto e una restrizione dichiarata del problema.

S1 adotta due parametri per attuatore, $\omega_n\in[36,44]$ e
$\zeta\in[.72,.88]$, indipendenti fra canali; $\tau=15$ ms e noto.
Meccanica e altre grandezze restano nominali nel confronto principale.
Questa scelta isola rapidita e smorzamento e mantiene comune il Padé.
La precedente famiglia M4 resta distinta: comprendeva $k_1,k_2,J_{m1}$
incerti e un altro inviluppo attuativo, anche per variabilita del ritardo.

\chapter{Costruzione delle incertezze}
\section{A: quattro parametri reali e occorrenze correlate}
\[
\omega_{ni}=40(1+.1\delta_{\omega i}),\quad
\zeta_i=.8(1+.1\delta_{\zeta i}),\quad\delta\in[-1,1].
\]
Ogni nome identifica un parametro reale costante; le sue ripetizioni non
sono indipendenti. Ponendo $d_\omega=4$, $d_\zeta=.08$, la LFT manuale
dell'oscillatore usa
\begin{align*}
z_1&=u-x,& z_2&=40(u-x)-1.6v+4w_1-.16w_\zeta,& z_3&=v,\\
\dot x&=v,&\dot v&=1600(u-x)-64v+160w_1+4w_2-6.4w_\zeta.
\end{align*}
Chiudendo $w_1=\delta_\omega z_1$, $w_2=\delta_\omega z_2$ e
$w_\zeta=\delta_\zeta z_3$ si ottiene esattamente
$\ddot x+2\zeta\omega_n\dot x+\omega_n^2x=\omega_n^2u$.
Segue il Padé fisso. La struttura totale e
\[
\Delta_A=\operatorname{diag}(\delta_{\omega1}I_2,\delta_{\zeta1},
\delta_{\omega2}I_2,\delta_{\zeta2}).
\]
Sono sei porte ma quattro parametri. La costruzione automatica esaminata
nel preliminare ripeteva $\omega_n$ cinque volte: ridurre le occorrenze
della realizzazione non cambia il numero di parametri fisici.
\schema{parametrico}{LFT manuale di un attuatore A. I due canali usano parametri indipendenti.}
\schema{lft}{Convenzione della LFT superiore: $w_\Delta=\Delta z_\Delta$.}
\section{B: due blocchi dinamici concentrati}
\[
G_B=G_{a0}\operatorname{diag}(1+W_I\Delta_1,1+W_I\Delta_2),\quad
\Delta_i\in\mathcal H_\infty,\quad\|\Delta_i\|_\infty\le1.
\]
I blocchi sono stabili e propri, indipendenti. Non si introduce un blocco
pieno $2\times2$: gli accoppiamenti aggiunti non hanno una motivazione
fisica nei due drive SISO. Il modello concentra la dispersione del secondo
ordine; non aggiunge un errore del ritardo esatto.
\schema{concentrato}{Modello B per ciascun canale. Il ramo incerto e scalare e indipendente dall'altro attuatore.}
\section{Peso analitico valido per tutto il box}
Il Padé comune si cancella nel rapporto. Con $H=\omega_n^2/(s^2+2\zeta\omega_ns+\omega_n^2)$,
\[
E=\frac H{H_0}-1=\frac{\alpha s^2+\beta s}{s^2+2\zeta\omega_ns+\omega_n^2},\quad
\alpha=\frac{\omega_n^2}{40^2}-1,\quad
\beta=\frac{1.6\omega_n^2}{40}-2\zeta\omega_n.
\]
Sul box $|\alpha|\le.21$, $|\beta|\le14.08$ rad/s. Per $0<\zeta\le1$,
\[
|{-\omega^2}+2\zeta\omega_nj\omega+\omega_n^2|
\ge\zeta(\omega^2+\omega_n^2).
\]
Si sceglie il peso di ordine uno
\[
W_I=c\frac{s}{s+36},\qquad
c=\frac{\sqrt{.21^2+(14.08/36)^2}}{.72}=.6165601466.
\]
Infatti $E/W_I=(\alpha s+\beta)(s+36)/[c(s^2+2\zeta\omega_ns+\omega_n^2)]$
e stabile e proprio. I due zeri in origine si cancellano per continuita;
la disuguaglianza precedente e Cauchy--Schwarz maggiorano il modulo con uno
su tutto l'asse immaginario, per tutto il box. Il peso non deriva da un fit
su pochi campioni. Le 25 coppie della verifica hanno massimo osservato
$\|E/W_I\|_\infty=0.559738$: servono a controllare il codice e a mostrare
lo scarto della maggiorazione, senza sostituire la dimostrazione.
\grafico{01_attuatori.png}{Famiglia fisica campionata e confronto fra inviluppo campionato e maggiorazione analitica.}

\chapter{Confronto delle rappresentazioni}
Nel box dichiarato ogni modello A e un modello B, scegliendo
$\Delta_i=E_i/W_I$: pertanto $\mathcal A\subseteq\mathcal B$.
Il viceversa non vale in generale: B ammette perturbazioni dinamiche che
non corrispondono a nessuna coppia costante $\omega_n,\zeta$.
Il concentrato perde la struttura fisica e l'inviluppo analitico aggiunge
conservativita. Questi due effetti contribuiscono insieme alle differenze;
non si attribuisce tutto alla sola etichetta parametrico/concentrato.

\textbf{Portata dell'inclusione.} La prova riguarda il box unitario S1.
Le espansioni normalizzate oltre quel box non sono identiche: la dipendenza
del drive dai parametri reali e non lineare. Non imponiamo quindi un ordine
universale dei margini scalati soltanto dall'inclusione unitaria.
RS/RP sul B unitario implicano le corrispondenti proprieta su A unitario.
Un intervallo diretto numericamente incoerente non viene riordinato.

Per A sono immediati significato fisico, normalizzazione e campionamento,
ma i blocchi reali ripetuti rendono piu articolate l'analisi mista e le
scalature D/G. B ha due blocchi dinamici e un peso semplice; la perdita di
struttura puo rendere peggiori le garanzie dei controllori fissi, ma una
sintesi su B puo risultare piu semplice. Questo sara un risultato della
campagna finita, non una proprieta generale di tutti gli algoritmi.

\chapter{Specifiche, segnali e pesi}
I test usano riferimenti separati di 5 gradi e disturbi ai link di 0.5 N m.
Restano i target consolidati: $T_s\le0.8$ s, overshoot $\le10\%$,
errore DC relativo $\le5\%$, banda desiderata 12 rad/s.
La scala di 12 N m non e una saturazione hardware.
Il confronto comune usa
\[
W_1=\frac{s/3+2}{s+.3}I_2,\quad
W_2=.003\frac{s+80}{s/6+80}I_2,\quad
M_o=\frac{16}{s^2+8s+16}I_2.
\]
$W_1$ pesa l'errore di inseguimento del modello, $W_2$ penalizza il comando,
$M_o$ e parte del costo del 2-DoF. Non e un prefiltro aggiunto dopo la sintesi.
$W_1(0)=6.667$, $W_1(\infty)=1/3$; $W_2(0)=.003$ e
$W_2(\infty)=.018$. Non e aggiunto $W_3$ ne un nuovo peso di rumore.
\[
w=[r;d],\quad z_p=[W_1(q-M_or);W_2u],\quad y_K=[r;q].
\]
Il disturbo non attraversa il drive. LQG/LQGI mantengono quattro encoder;
i robusti ne usano due. Queste architetture preesistenti restano diverse,
mentre per ciascun K il passaggio A/B conserva le stesse misure.
\schema{generalizzata}{Pianta generalizzata 2-DoF. Le porte prestazionali e le misure del controllore sono distinte.}

\chapter{LQG e LQGI}
\section{Costo fisico, Riccati e osservatore}
Il regolatore usa $u=-K\hat x+N_rr$; $\hat x$ e stimato dai quattro encoder.
Il prefiltro rende unitario il guadagno statico nominale riferimento--q,
ma non contiene un modello interno del disturbo costante.
Il costo e $J=\int_0^\infty(x^TQx+u^TRu)dt$.
Le scale fisiche conservate sono $q_s=5\pi/180$, $\dot q_s=12q_s$,
$\delta_s=.5/40=.0125$, $\dot\theta_s=\dot q_s$.
%QDERIVATION%
Le matrici finali restano quelle consolidate, con $R=.1I_2$;
la selezione storica confrontava 36 configurazioni. Non la ripetiamo per
cercare una nuova soluzione. Il piccolo studio a cinque fattori verifica
la sensibilita attorno al punto adottato, senza promuovere una taratura diversa.
La prima parte delle colonne seguenti varia $Q$ a $R$ fisso; la seconda
varia soltanto $R_n$ assunto dal filtro, mantenendo il rumore fisico identico.
\input{lqg}
L'errore RMS di stima deriva dalla covarianza stazionaria continua, non
da una simulazione ZOH con varianze interpretate come intensita bianche.
\[
Q_n=.01I_4,\quad R_n=(.05\pi/180)^2I_4,\quad G_w=[B_d\ B_u],
\]
\[
\dot{\hat x}=A\hat x+B_uu+L(y_{mis}-C\hat x).
\]
Sono ipotesi di rumore, non dati di targa di un encoder identificato.
Le intensita hanno la convenzione temporale continua gia documentata.
Il principio di separazione richiede stabilita di $A-BK$ e $A-LC$;
il nuovo script verifica i residui Riccati e l'identita col controllore salvato.
\schema{lqg}{Retroazione LQG con comando noto allo stimatore e quattro misure rumorose.}
\section{Integratore dell'errore misurato}
Con $\dot\xi=r-q_{mis}$ si usa
\[
A_a=\begin{bmatrix}A&0\\-C_q&0\end{bmatrix},\quad
B_a=\begin{bmatrix}B_u\\0\end{bmatrix},\quad
Q_a=\operatorname{diag}(Q,200I_2),\quad R_a=.1I_2.
\]
Il costo integrale e quello consolidato, non un nuovo optimum.
$[K_x\ K_i]=R_a^{-1}B_a^TP_a$ proviene da un'unica Riccati.
La realizzazione ha 16 stati $[\hat x;\xi]$ e legge
$[r;q_{mis};\theta_{mis}]$. L'anello chiuso ha 30 stati e usa
$u=-K_x\hat x-K_i\xi$: non si applica il feedback allo stato vero simulato.
\schema{lqgi}{LQGI: l'integratore riceve q misurato; Kalman riceve gli stessi encoder e il comando effettivo.}
Il residuo DC del disturbo costante e nullo nel lineare, ma il candidato
LQGI ha $T_s=5.05$ s e non soddisfa il target temporale. LQG resta il
riferimento rapido nominale. I risultati robusti sui due insiemi sono
riportati al Capitolo 10: un costo comune 2-DoF non coincide con il costo LQR.

\chapter{Controllo H-infinity}
\section{Stesso problema 1-DoF per mixsyn e hinfsyn}
Per $u=K_e(r-q)$,
\[
S=(I+GK_e)^{-1},\quad T=I-S,\quad
\gamma=\left\|\begin{bmatrix}W_1S\\W_2K_eS\end{bmatrix}\right\|_\infty.
\]
La pianta esplicita e
\[
P_1=\begin{bmatrix}W_1&-W_1G\\0&W_2\\I&-G\end{bmatrix}.
\]
\texttt{connect} evita copie separate dei modi instabili di G.
\texttt{mixsyn(G,W1,W2,[])} e \texttt{hinfsyn(P1,2,2)} risolvono
lo stesso costo; si confrontano norme ricostruite dalle mappe, non soltanto
il valore restituito dal solver.
\schema{mixsyn}{Sensibilita mista: errore e comando sono pesati separatamente.}
\section{Due gradi di liberta e PID strutturato}
Per $u=K_rr+K_yq$ la pianta P2 include r e d e il modello desiderato Mo.
$K_y$ contiene il segno della retroazione; gli stati di $K_r,K_y$ sono
condivisi nella realizzazione del controllore.
\schema{due_dof}{Canali del 2-DoF: rappresentazione dei trasferimenti, con una sola realizzazione di K.}
La struttura PID per ciascun giunto e
\[
u_i=K_{pi}(b_ir_i-q_i)+\frac{K_{ii}}s(r_i-q_i)
+\frac{K_{di}s}{1+T_{fi}s}(c_ir_i-q_i).
\]
Una nuova chiamata \texttt{hinfstruct} parte dal PID consolidato, con un
solo avvio e 100 iterazioni massime. Il fine e mostrare la sintesi, senza
ripetere una grande ottimizzazione. Le realizzazioni originali restano nella banca.
\input{hinf}
Le ultime due righe hanno un costo diverso dalle prime due; non si interpreta
la riduzione di gamma come un miglioramento percentuale dello stesso problema.
Hinf2 mostra tracking nominale senza overshoot ma fallisce RS anche su A.
Una piccola norma pesata non garantisce robustezza o rispetto di tutti i target.
\grafico{03_hinf.png}{Pesi usati e sensibilita delle due sintesi dello stesso problema 1-DoF.}

\chapter{Mu-sintesi e iterazioni D-K}
\section{LFT, valore singolare strutturato e scalature}
Dopo chiusura di K, la parte nota N e collegata a Delta attraverso
$w_\Delta=\Delta z_\Delta$. RS dipende dal blocco $N_{11}$ fra queste porte.
La grandezza strutturata e
\[
\mu_\Delta(M)=\left[\min_{\Delta}\{\|\Delta\|:\det(I-M\Delta)=0\}\right]^{-1}.
\]
I parametri reali ripetuti devono restare reali e correlati. I bounds di
\texttt{mussv} sono distinti: upper consente una garanzia, lower individua
una perturbazione destabilizzante. I bounds su una griglia finita non
sostituiscono da soli l'analisi adattiva \texttt{robstab}.
\schema{dk}{D-K: sintesi scalata, analisi strutturata e fit delle scalature, con budget identico.}
Per ciascuna famiglia eseguiamo una sola D-K con quattro iterazioni massime,
fit [2,1], scalature diagonali, MixedMU attivo, stessa griglia e seed.
I pesi non sono cambiati. Nessuna riduzione o cancellazione e adottata.
Il candidato parametrico ha 88 stati e quello concentrato 32: l'ordine
del primo e un costo concreto, non una necessita teorica dimostrata.
Le post-analisi sullo stesso K e le analisi incrociate rimangono separate.
\grafico{04_robustezza.png}{Margini inferiori RS e storia D-K effettivamente eseguita. Il picco riportato dalla sintesi non sostituisce la post-analisi.}

\chapter{Analisi robusta comparativa}
\section{NS, NP, RS e RP}
NS e stabilita interna del nominale. NP aggiunge la norma pesata comune
minore di uno. RS chiede stabilita per tutte le perturbazioni ammesse;
RP aggiunge il requisito prestazionale. Il margine e riferito alla
normalizzazione dichiarata: un limite inferiore sopra uno certifica il
requisito, un superiore sotto uno ne dimostra il fallimento.
\schema{robusta}{Chiusura N--Delta. Per RP si considera il problema aumentato con il blocco fittizio di prestazione.}
\section{Stessi controllori, modelli diversi}
\input{robustezza}
Tutti i nominali sono stabili. Per LQG/LQGI/Hinf1 NP sul costo comune
fallisce: cio non contraddice i loro costi originari. In questo caso il
margine RP comune e zero gia al nominale. Dove RS fallisce, RP fallisce
e [0,RS upper] e soltanto un limite dedotto, non una nuova chiamata riuscita
di \texttt{robgain}. Gli intervalli completi e la loro origine sono nei CSV.

$^*$Per Kmu su A la chiamata diretta a \texttt{robgain} produce un
intervallo invertito, anche ripetendo con opzioni m9. Entrambi gli esiti
grezzi sono conservati. L'intervallo riportato [1,RS upper] e un altro
bound: RP sul B unitario implica RP su A unitario; non si riordinano i
numeri incoerenti e non si trasferisce il valore del margine oltre uno.

LQG e LQGI superano RS su A ma la falliscono di poco su B. Hinf1 supera
RS in entrambi i modelli, pur non soddisfacendo il costo comune. Hinf2 e
PID falliscono RS in entrambi. Kmu storico mantiene RS e RP su B e, per
inclusione, su A. Questi sono risultati nuovi per S1: i certificati M4
non sono stati riutilizzati per ottenerli.
\section{Risintesi dedicate e conservativita}
Mu\_A e Mu\_B superano NS/NP/RS/RP su entrambe le famiglie senza rilassare
i pesi. Mu\_B raggiunge margini inferiori RS/RP su B circa 3.011/2.625,
con 32 stati; Mu\_A circa 2.385/2.030, con 88 stati.
Il concentrato offre quindi in questa campagna una sintesi piu contenuta,
anche se le garanzie dei controllori fissi sono spesso meno favorevoli.
Il risultato dipende da pesi, inizializzazione, fit e budget finito;
non dimostra una superiorita universale del modello o dell'algoritmo.

\chapter{Campionamento, simulazioni e RAS}
\section{Dieci impianti fisici comuni}
Il primo campione e nominale; seguono estremi e punti interni deterministici
dei quattro parametri. Sono gli stessi per tutti gli otto K. Non si campionano
dinamiche arbitrarie di B chiamandole impianti fisici: i dieci appartengono
alla famiglia parametrica A, contenuta in B. Lo stato di stabilita interna
precede le metriche: per gli instabili i valori temporali sono NaN.
\input{ras}
Hinf2 e stabile solo in tre campioni e PID in sette; gli altri in tutti
e dieci. Questo e coerente con le garanzie/fallimenti, ma dieci successi
non dimostrano RS. La prova non sostituisce la $\mu$-analysis.
\grafico{05_dieci_impianti.png}{Tracking q1 nei soli campioni stabili. Nero: nominale; azzurro: altri impianti. Le assenze non sono risposte nascoste, ma chiusure instabili escluse dalle metriche.}
\section{Nominale, disturbo e sforzo di controllo}
\input{nominale}
\input{disturbi}
$T_s$ e misurato nella banda del 2\% dell'ampiezza del riferimento attorno
al proprio valore DC. L'errore DC e riportato separatamente: un buon
assestamento al valore finale non garantisce tracking unitario. Overshoot
e riferito al comando. Picchi e RMS sono misurati sulla griglia di 5 ms,
su 12 s, prendendo il caso peggiore fra i due giunti; RMS massimo per
canale, integrato nel tempo. Non sono massimi continui certificati.

Le norme rumore--comando rivelano un limite ulteriore: il costo usato non
penalizza esplicitamente gli encoder. Mu\_A e Mu\_B hanno rispettivamente
circa $5.00\cdot10^7$ e $1.36\cdot10^6$ di guadagno H-infinity da v a u,
contro $2.94\cdot10^4$ di Kmu. Non sono automaticamente candidati operativi
preferibili: i miglioramenti di robustezza pesata hanno un prezzo.
Nessun nuovo peso di rumore viene introdotto silenziosamente.
\section{Confronto lineare/non lineare}
Per ciascuno degli otto controllori sono state eseguite quattro prove
non lineari: gradino su r1/r2, disturbo su d1/d2. Tutte le 32 integrazioni
raggiungono 12 s. Il confronto usa l'intero controllore e i sei stati
dei drive; non si sostituisce lo stato stimato con quello vero.
Le differenze massime LIN/NL e i comandi sono registrati nel CSV dedicato.
\grafico{05_lin_nl_1.png}{Gradino r1: tratteggio lineare, continuo non lineare; stesso colore per lo stesso giunto.}
\grafico{05_lin_nl_2.png}{Disturbo d1 da t=1 s: confronto lineare/non lineare senza modificare K.}
\section{Sezione empirica di attrazione}
Si usano quindici coppie iniziali comuni nel piano Delta q1/Delta q2,
con Delta theta = Delta q. Velocita, stati drive e controllore sono nulli;
riferimento, disturbo e rumore nulli. Per l'ultimo secondo entro 12 s,
richiediamo posizioni link/rotori entro 0.5 gradi e velocita entro .02 rad/s.
E un criterio fisico di convergenza osservata, non una prova asintotica.

Su 120 punti: 96 convergenze, 16 integrazioni completate senza convergenza
e 8 inconcludenti. Hinf2 e PID hanno quattro arresti numerici ciascuno.
Mu\_A converge solo in sei punti, Mu\_B in quindici. Cio mostra che una
garanzia sul modello lineare non determina la sezione non lineare.
Il limite numerico di 35 s per integrazione evita blocchi del solver;
un timeout non e instabilita matematica. Non si interpola un bordo della RAS.
\grafico{05_ras.png}{Verde: convergenza osservata; croce rossa: non convergenza nell'orizzonte; grigio: risultato numericamente inconcludente. Nessun contorno certificato.}

\chapter{Confronto finale e conclusioni}
Per i controllori fissi A consente qui garanzie piu favorevoli di B:
LQG/LQGI passano da RS verificata a RS fallita. Il significato non e che
l'impianto fisico cambi: B ammette piu perturbazioni e l'inviluppo e
conservativo. A e piu interpretabile fisicamente; B e piu compatto nella
struttura incerta e nella sintesi dedicata osservata.

Con pesi identici, la sintesi B a 32 stati offre margini robusti elevati
su entrambi i modelli e quindici convergenze empiriche. Rimangono
$T_s=1.985$ s contro .8 s richiesti, errore DC 5.454\% contro 5\% e forte
amplificazione del rumore. La sintesi A ha errore DC 4.284\% e
$T_s=1.485$ s, ma ordine 88, amplificazione ancora maggiore e solo sei
convergenze RAS. I due nuovi K sono strumenti di confronto, non sostituti
automatici della banca consolidata.

La scelta del modello dipende quindi dallo scopo: conservare informazione
fisica o ottenere una descrizione dinamica semplice che la contenga.
Un margine numerico maggiore va letto insieme all'insieme coperto, al costo
del controllo, al rumore e ai requisiti temporali. Il problema pesato ha
soluzioni robuste S1 senza nuovi rilassamenti; non tutti i target originali
sono pero raggiunti. Limiti hardware, saturazioni e ritardi misurati restano
fuori dal modello approvato. La nuova validazione Simulink attende gli SLX
che gli studenti decideranno di integrare.

\appendix
\chapter{Matrici e codici essenziali}
Le matrici seguenti sono quelle consolidate, conservate anche nel MAT
portabile; il codice ricalcola Riccati e guadagni e ne verifica l'identita.
\input{matrici_lqr}\input{matrici_kalman}
Le istruzioni principali sono leggibili nei sei file numerati. Il prefisso
SEA e necessario perche i nomi MATLAB devono iniziare con una lettera.
\lstinputlisting[firstline=25,lastline=47]{../../SEA_01_MODELLI_INCERTEZZE.m}
\lstinputlisting[firstline=10,lastline=27]{../../SEA_02_LQG_LQGI.m}
\lstinputlisting[firstline=17,lastline=36]{../../SEA_04_MU_SINTESI.m}

\chapter{Risultati storici conservati e Simulink}
Il precedente M4 comprendeva incertezze meccaniche e una diversa famiglia
dinamica: i suoi certificati rimangono validi per quella famiglia razionale,
non sono prova per tutti i ritardi esatti. In particolare il rapporto fra
ritardo esatto e Padé nominale puo avere un polo RHP: un fit del solo modulo
non basta a dimostrare appartenenza a un blocco dinamico stabile.

La seconda formulazione storica introduceva rumore encoder esogeno nella
sintesi. MuN1, 82 stati, conservava RS/RP M4 e riduceva molto il comando,
con peggioramento dell'offset q1 e target temporali parziali. Queste
evidenze restano significative e separate dai nuovi candidati S1.
\input{rumore_storico_sintesi}\input{rumore_storico_simulink}
\grafico{rumore_storico.png}{Studio del rumore precedente: fonte e famiglia M4, non nuove simulazioni S1.}
Gli otto SLX precedenti e le loro prove sono conservati nel progetto
storico senza modifiche. Non sono dichiarati i modelli definitivi della
nuova consegna. Le interfacce numeriche dei controllori sono disponibili
in dati/interfacce\_simulink.mat e descritte nel documento allegato.
Un collegamento futuro deve rispettare ordine delle misure, segni, unita
e condizioni iniziali; i nuovi SLX non sono ancora validati.

\chapter{Riproducibilita e tracciabilita}
Estrarre lo ZIP e avviare SEA\_00\_AVVIO\_PROGETTO in MATLAB. La modalita
rapida carica le sintesi/analisi eseguite e mostra grafici e tabelle;
ricostruisce modelli e LQG/LQGI. La completa ripete anche le sintesi,
le analisi robuste, i dieci impianti e la RAS. I file letti e salvati sono
relativi alla cartella estratta, senza Git, Drive, Symbolic Toolbox o
addpath manuali. Ambiente accreditato: MATLAB R2026b, Control System e
Robust Control Toolbox. Simulink non serve per la riproduzione MATLAB.

I dati numerici della relazione provengono dai CSV in dati/: quadro\_finale,
confronto\_robusto, dieci\_impianti, lineare\_nonlineare, ras\_empirica,
confronto\_hinf e scelte\_lqg. Cinquanta test dedicati verificano fisica,
Jacobiani, LFT, nominali, interfacce, costi e classificazione delle evidenze.
I tentativi numerici falliti e gli intervalli incoerenti sono conservati
nel report tecnico di ristrutturazione, senza nasconderli nelle conclusioni.
La tabella di tracciabilita completa e allegata in forma Markdown.
\begin{thebibliography}{9}
\bibitem{traccia} P. Salaris, Traccia 2: Manipolatore planare 2 DoF con SEA, testo ufficiale del corso.
\bibitem{main} A. de Dato, V. Rebechi, Relazione e sorgenti consolidati del progetto SEA, 13 ottobre 2026. Fisica, Q/R, Kalman, controllori e risultati storici preservati.
\bibitem{mw} MathWorks, Robust Control Toolbox: documentazione di ureal, lftdata, mixsyn, hinfsyn, hinfstruct, musyn, robstab, robgain e mussv.
\end{thebibliography}
\end{document}
'''
TEXT=TEXT.replace('%PHYSICAL%',physical).replace('%QDERIVATION%',qderivation)
(REL/'main.tex').write_text(PREAMBLE+TEXT,encoding='utf-8')

# Beamer riusa formato e linguaggio visivo della presentazione principale.
slide_head=r'''\documentclass[aspectratio=169,12pt]{beamer}
\usepackage[T1]{fontenc}\usepackage[utf8]{inputenc}\usepackage[italian]{babel}
\usepackage{amsmath,graphicx,booktabs,tikz}\usetikzlibrary{arrows.meta,positioning,calc}
\definecolor{deepblue}{RGB}{20,52,92}\setbeamercolor{structure}{fg=deepblue}
\setbeamercolor{frametitle}{fg=white,bg=deepblue}\setbeamertemplate{navigation symbols}{}
\setbeamertemplate{footline}{\hfill\insertframenumber/\inserttotalframenumber\hspace{1em}\vskip.5em}
\hypersetup{pdfauthor={Alessio de Dato; Valerio Rebechi},pdftitle={SEA: incertezze parametriche e concentrate}}
\newcommand{\diagram}[1]{\centering\resizebox{.86\linewidth}{!}{\input{../schemi/#1}}\par}
\newcommand{\plotdata}[1]{\centering\includegraphics[height=.64\textheight,width=.94\linewidth,keepaspectratio]{../../figure/#1}\par}
\title{Manipolatore SEA a due giunti}\subtitle{Due rappresentazioni dell'incertezza degli attuatori}
\author{Alessio de Dato -- 635256\\Valerio Rebechi -- 722224}\date{25 ottobre 2026}
\begin{document}\begin{frame}[plain]\titlepage\end{frame}
'''
frames=[]
def frame(title,body): frames.append(r'\begin{frame}{'+title+'}\n'+body+'\n'+r'\end{frame}'+'\n')
frame('Sistema SEA ed equilibrio',r'''\diagram{sea}
\small $\bar q=[\pi/2,0]^T$, 8 stati meccanici + 6 drive. Encoder link/rotori per LQG; q per i robusti.''')
frame('Attuatore nominale',r'''\diagram{nominale}
\[G_{a0}=\frac{40^2}{s^2+64s+1600}\frac{1-.015s/2}{1+.015s/2}\]
\small Banda 34.78 rad/s; zero Padé a +133.33 s$^{-1}$. Nessuna duplicazione di Jm/Bm.''')
frame('Scelta di pochi parametri incerti',r'''\small
\begin{center}\begin{tabular}{lrr}\toprule
Parametro&Intervallo&Scost. max a 40 rad/s\\\midrule
$\omega_n$&36--44 rad/s&16.41\%\\$\zeta$&.72--.88&11.11\%\\$\tau$&12--18 ms&11.18\%\\\bottomrule\end{tabular}\end{center}
Cinque valori per parametro, uno alla volta. S1 approvato: wn/zeta incerti,
tau noto a 15 ms; meccanica nominale nel confronto centrale. M4 conservato separatamente.''')
frame('A parametrico e LFT manuale',r'''\diagram{parametrico}
\[\Delta_A=\operatorname{diag}(\delta_{\omega1}I_2,\delta_{\zeta1},\delta_{\omega2}I_2,\delta_{\zeta2})\]
\small Quattro parametri reali indipendenti; sei porte. Le ripetizioni di wn sono correlate.''')
frame('B concentrato diagonale',r'''\diagram{concentrato}
\[W_I=.6165601\frac{s}{s+36},\quad \|\Delta_i\|_\infty\le1\]
\small Due dinamiche SISO indipendenti. Il blocco pieno aggiungerebbe accoppiamenti non previsti.''')
frame('Copertura e conservativita',r'''\plotdata{01_attuatori.png}
\small Prova analitica sul box: $\mathcal A\subseteq\mathcal B$. Massimo campionato $\|E/W_I\|_\infty=.559738$.
L'inclusione unitaria non ordina automaticamente tutte le espansioni dei margini.''')
frame('Segnali e pianta generalizzata',r'''\diagram{generalizzata}
\small Stessi W1, W2 e Mo per A/B; d e una coppia sui link. Norma pesata e target temporali restano distinti.''')
frame('LQG e integratore misurato',r'''\diagram{lqgi}
\small LQG: $u=-K\hat x+N_rr$. LQGI: $\dot\xi=r-q_{mis}$, $u=-K_x\hat x-K_i\xi$.
Stesso Kalman; Q/R e covarianze consolidate. LQG Ts=.675 s; LQGI Ts=5.05 s con reiezione DC del disturbo.''')
frame('H-infinity: metodi e problemi',hftable+r'''\small Le prime due righe risolvono lo stesso P1.
Il 2-DoF e il PID usano P2: gamma di problemi diversi non costituisce una classifica.''')
frame('NS, NP, RS e RP',r'''\diagram{robusta}
\small NS: nominale internamente stabile. NP: norma comune sotto uno.
RS: stabilita sull'intera famiglia. RP: anche prestazione.
Un risultato campionario non certifica RS/RP.''')
rs_slide=table(['K',r'RS lower A',r'RS lower B'],[[esc(x['Controllore']),num(x['RS_A_lower']),num(x['RS_B_lower'])] for x in quadro[:6]])
frame('Stessi controllori, rappresentazione diversa',rs_slide+r'''\small LQG/LQGI: PASS su A, FAIL su B. Hinf2/PID fragili in entrambi.
Kmu conserva RS/RP. Il concentrato copre un insieme piu ampio del box fisico.''')
frame('Due D-K dedicate, stessi pesi',r'''\plotdata{04_robustezza.png}
\small Quattro iterazioni massime e stesso fit [2,1]. Il K-step non sostituisce la post-analisi.''')
frame('Sintesi e verifica incrociata',table(['K','Ordine','RP lower A','RP lower B'],[[esc(x['Controllore']),num(x['Ordine']),num(x['RP_A_lower']),num(x['RP_B_lower'])] for x in quadro[5:]])+r'''\small Kmu su A: bound da inclusione, margine diretto inconcludente.
Mu\_B ha ordine 32 contro 88 di Mu\_A; nessuna riduzione adottata.''')
frame('Dieci impianti fisici comuni',r'''\plotdata{orale_impianti.png}
\small Hinf2 stabile 3/10, PID 7/10; gli altri 10/10. Stessi campioni per tutti. Solo le risposte stabili sono tracciate.''')
frame('Sezione empirica di attrazione',r'''\plotdata{orale_ras.png}
\small Quindici punti per K; Delta theta=Delta q, altri stati nulli. Verde convergente, rosso non convergente entro T, grigio inconcludente.
Mu\_A: 6/15; Mu\_B: 15/15. Nessun bordo certificato.''')
frame('Rumore e risultati conservati',r'''\small I nuovi K non penalizzano esplicitamente gli encoder:
\[\|T_{uv}\|_\infty:\quad K_\mu\simeq2.94\,10^4,\quad K_{\mu B}\simeq1.36\,10^6.\]
La formulazione storica con rumore produceva MuN1 a 82 stati: RS/RP su M4,
picco Simulink non lineare 108.526 $\to$ 2.251 N m, ma offset q1 peggiore.
\medskip\par Famiglie, pesi ed evidenze restano distinti. I nuovi SLX saranno forniti dagli studenti.''')
frame('Conclusioni del confronto A/B',r'''\begin{itemize}
\item A conserva significato fisico e correlazioni; B aggiunge dinamiche ammesse e conservativita.
\item Su K fissi, B riduce qui diverse garanzie. Nella sintesi finita, B produce il candidato piu compatto.
\item Mu\_B supera RS/RP su A/B; Ts=1.985 s e DC=5.454\% non rispettano tutti i target.
\item Rumore, ordine e comportamento non lineare impediscono una scelta basata solo sui margini.
\end{itemize}''')
(SLIDES/'main.tex').write_text(slide_head+''.join(frames)+r'\end{document}'+'\n',encoding='utf-8')

times=[25,60,60,55,75,65,65,65,80,70,60,65,65,65,55,75,60,60]
titles=['Titolo','Sistema SEA ed equilibrio','Attuatore nominale','Scelta dei parametri','A parametrico','B concentrato','Copertura e conservativita','Pianta generalizzata','LQG/LQGI','H-infinity','NS/NP/RS/RP','Controllori fissi','D-K','Sintesi incrociata','Dieci impianti','RAS','Rumore e storia','Conclusioni']
notes=[
'Presentare la domanda sulle rappresentazioni e distinguere subito analisi a controllore fisso e sintesi dedicata.',
'Seguire le coppie elastiche con i segni opposti. Il disturbo entra sui link; la dinamica del drive precede la coppia motore. Equilibrio verticale instabile e misure encoder.',
'Spiegare wn, zeta e tau. I nominali gia verificati sono conservati. Lo zero RHP di Pade e una conseguenza dell’approssimazione, non un polo instabile del drive.',
'Mostrare i cinque valori e le metriche del preliminare. Il ritardo non e fisicamente irrilevante: renderlo noto e una restrizione approvata. La meccanica resta nota per isolare il confronto.',
'Derivare verbalmente z1, z2, z3. La stessa delta_wn chiude due porte: numeratore, rigidezza e smorzamento non possono variare indipendentemente. Due attuatori indipendenti.',
'Seguire il ramo u-WI-Delta e la somma prima del nominale. Due blocchi SISO non introducono crosstalk. Il peso rappresenta la variabilita dei secondi ordini, non un residuo del ritardo.',
'Spiegare E/WI stabile e proprio e la maggiorazione su tutto il box. Il fit campionato non e la prova. Distinguere l’inclusione unitaria dalle espansioni normalizzate dei margini.',
'Indicare w, u, z, y. Specificare che Mo entra nel costo e non e un prefiltro applicato dopo la sintesi. W1 sull’errore, W2 sul comando; nessun W3 aggiuntivo.',
'Kalman stima le velocita e i drive da quattro encoder. L’integratore usa l’errore misurato. Q non e diagonale perche pesa theta-q. LQGI elimina DC del disturbo ma e lento.',
'Le prime due righe confrontano davvero mixsyn e hinfsyn. P2 e PID hanno un altro costo. Conservare la banca mentre il ricalcolo dimostra la sintesi; nessun minimo globale dichiarato.',
'Definire separatamente NS, NP, RS e RP. Un upper di mu sotto uno e una garanzia; campioni stabili non bastano. I bounds invertiti restano esiti numerici inconcludenti.',
'LQG/LQGI sono l’esempio piu chiaro di cambiamento di garanzia: stesso K, stessa pianta nominale, A passa e B fallisce. L’insieme concentrato e piu ampio e il peso contiene margine conservativo.',
'Descrivere K-step e D-step e leggere i quattro passi effettivi. Parametri reali e dinamici danno strutture diverse; identico budget non garantisce identica difficolta ne ottimalita.',
'Mu_B raggiunge garanzie incrociate con 32 stati, Mu_A ne usa 88. Per Kmu su A si usa solo la deduzione a raggio uno da B, preservando gli intervalli diretti incoerenti.',
'I dieci impianti sono fisici, inclusi nominale ed estremi, e sono identici per tutti. Hinf2 e PID mostrano fallimenti. Non presentare una dinamica ultidyn casuale come un attuatore fisico identificato.',
'Spiegare gli stati iniziali completi e le soglie dell’ultimo secondo. La non convergenza entro 12 s non e instabilita matematica. Hinf2/PID hanno arresti numerici. Mu_A6 contro Mu_B15 e un limite non lineare concreto.',
'Non nascondere il costo sul rumore dei nuovi K. Ricordare il risultato precedente MuN1 senza trasferirne la garanzia da M4 a S1. La nuova integrazione Simulink e ancora da svolgere sui modelli definitivi degli studenti.',
'Rispondere alla domanda iniziale: per K fisso B e qui piu conservativo, ma puo semplificare la sintesi. Citare i target persi e i limiti del rumore. Nessun vincitore universale o promozione automatica.'
]
lines=['# Presentazione: note e tempi','',f'{len(titles)} slide. Contenuti: {sum(times)//60}:{sum(times)%60:02d}; cambi: 34 s. Totale pianificato: {(sum(times)+34)//60}:{(sum(times)+34)%60:02d}. La durata effettiva richiede una prova cronometrata.','']
for i,(title,sec,note) in enumerate(zip(titles,times,notes),1):
    who='Alessio' if ((i-1)//3)%2==0 else 'Valerio'
    lines.extend([f'## {i}. {title} - {who}, {sec} s','',note,''])
(DOC/'PRESENTAZIONE_NOTE.md').write_text('\n'.join(lines),encoding='utf-8')
(DOC/'ORIGINE_CONTENUTI.md').write_text('''# Origine dei contenuti

La relazione riorganizza la base principale del gruppo, non sostituisce main
con la relazione PR43. Equazioni fisiche e descrizione delle coordinate sono
recuperate dal precedente capitolo 2, aggiungendo il canale del disturbo.
La derivazione di Q tramite F e Sx e recuperata dal capitolo 7; matrici LQR,
Kalman e tabelle dello studio del rumore sono i sorgenti precedenti invariati.
Le architetture LQGI, mixed sensitivity, 2-DoF e D-K conservano le formulazioni
dei capitoli 7-9, con nuova esposizione compatta. Il confronto S1, le due D-K,
gli impianti comuni e la RAS provengono dai nuovi script e CSV, non dai risultati
delle altre famiglie. La LFT manuale recupera la derivazione utile della PR43,
senza importare la sua catena software o i suoi modelli non approvati.
''',encoding='utf-8')
print('Generati relazione, 18 slide, 13 schemi TikZ e note: dati da CSV S1.')
