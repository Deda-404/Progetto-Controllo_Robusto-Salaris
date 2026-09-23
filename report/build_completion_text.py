"""Render PR33 completion text from executed MATLAB evidence (no calculations)."""
from pathlib import Path
import csv
import json
import re

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "results/data/simulink_completion"
linear = json.loads((DATA / "linear_summary.json").read_text())
ras = json.loads((DATA / "lqri_ras_summary.json").read_text())
tests = list(csv.DictReader((DATA / "unit_tests.csv").open()))
assert linear["passed"] and len(linear["checks"]) == 32
assert len(tests) == 22 and all(t["Passed"] in ("1", "true") for t in tests)

def write(path, text):
    (ROOT / path).write_text(text.rstrip() + "\n", encoding="utf-8")

rows = []
for c in linear["controllers"]:
    q, u = (max(e[j] for e in c["linearErrorsQU"]) for j in range(2))
    nq, nu = c["nonlinearErrorsQU"]
    rows.append(f'{c["kind"]} & {q:.3e} & {u:.3e} & {nq:.3e} & {nu:.3e} ' + r"\\")
row_text = "\n".join(rows)
peak = ras["maximumConvergentControlNm"]

chapter = r"""\section{Completamento: Simulink linearizzato e RAS LQRI}
\label{sec:simulink-completion}
Le verifiche seguenti estendono l'integrazione senza ricostruire i quattro
modelli non lineari, modificare controllori o rieseguire sintesi e analisi robuste.
Sono eseguite con MATLAB/Simulink R2025b Update 4.

\subsection{Un solo diagramma lineare per quattro controllori}
Il modello \path{simulink/models/SEA_linear_common.slx} contiene esplicitamente
il plant completo M3, realizzato con un blocco State-Space di 14 stati:
\[
 \dot x=A_{\rm full}x+[B_{\rm full}\ B_{d,\rm full}]
 \begin{bmatrix}u\\d\end{bmatrix},\quad
 y=C_{\rm full,Meas}x,\qquad q=C_{\rm full,Q}x.
\]
Gli ultimi due prodotti sono blocchi Gain distinti: quattro misure e due
posizioni dei link. I primi otto stati sono meccanici, gli ultimi sei degli
attuatori. Tutte le coordinate del diagramma lineare sono incrementali;
lo zero corrisponde all'equilibrio assoluto del modello non lineare.
Il disturbo entra tramite $B_{d,\rm full}$, senza attraversare gli attuatori.

\path{setup_linear_common.m} seleziona le matrici del controllore dagli
stessi artifact dell'integrazione. LQG e LQRI ricevono $[r;y]$ (sei ingressi);
H-infinity e Kmu ricevono $[r;q]$ (quattro ingressi), conservando la vera
architettura 2-DoF a stati condivisi. Il selettore riguarda solo le misure
al controllore, non elimina stati dalla pianta. Gli ordini complessivi sono
28, 30, 36 e 92; non si applicano riduzioni o \texttt{minreal}.
Per LQG lo stato interno iniziale è $\hat x_0$, per LQRI è
$[\hat x_0;\xi_0]$. Il plant comune è deterministico: la validazione dei
rumori resta nei quattro modelli non lineari già verificati.

\subsection{Due confronti distinti, con esiti numerici}
Per ogni controllore si eseguono tre simulazioni lineari di 3 s:
gradino di $5^\circ$ sul primo giunto, sul secondo giunto e, a riferimento
nullo, disturbo $[0.01;-0.007]$ N m sui link da $t=0$.
La mappa MATLAB indipendente è assemblata da plant e controllore e simulata
con \texttt{lsim}; non è una linearizzazione automatica del nuovo diagramma.
Il solver del modello lineare è \texttt{ode23t}, con tolleranze relativa
$10^{-9}$, assoluta $10^{-11}$ e passo massimo 0.002 s.
Le uscite sono confrontate sulla griglia 0.002 s, interpolando linearmente
i campioni del solver. Le differenze includono dunque errore numerico e
di interpolazione, non una discrepanza di progetto.

Si esegue inoltre il modello lineare con $r=[10^{-4};-7\,10^{-5}]$ rad
per 3 s e lo si confronta con le tracce non lineari già validate e conservate
in \path{results/data/simulink_integration/*_runs.mat}.
Riutilizzare queste tracce evita di ripetere la campagna precedente;
le matrici e i modelli sorgente restano invariati.
\begin{table}[htbp]\centering\small
\begin{tabular}{lrrrr}\toprule
 & \multicolumn{2}{c}{Lineare SL / MATLAB} & \multicolumn{2}{c}{Non lineare SL / lineare SL}\\
 & max $|e_q|$ [rad] & max $|e_u|$ [Nm] & max $|e_q|$ [rad] & max $|e_u|$ [Nm]\\\midrule
__ROWS__
\bottomrule\end{tabular}
\caption{Massimi sui tre scenari per le prime due colonne; piccolo segnale
per le ultime due. SL indica Simulink. Dati: linear\_summary.json.}
\end{table}
Tutte le 32 verifiche numeriche superano le soglie, fissate prima del calcolo,
di $2\,10^{-7}$ rad e $2\,10^{-4}$ N m, coerenti con l'integrazione precedente.
Queste soglie verificano l'equivalenza implementativa, non i target M5.
\begin{figure}[htbp]\centering
\includegraphics[width=.90\textwidth]{figures/simulink_completion/linear_nonlinear.png}
\caption{Sovrapposizione delle traiettorie lineari e non lineari a piccolo segnale.}
\end{figure}

\subsection{RAS nominale LQRI: stesso protocollo, stessi limiti interpretativi}
La ricerca utilizza direttamente \path{estimate_lqg_ras.m} e
\path{evaluate_m8_convergence.m}. Alla funzione di ricerca sono aggiunti
solo un simulatore opzionale e un checkpoint: le chiamate storiche M8
mantengono i valori predefiniti. L'adattatore esegue
\texttt{SEA\_LQRI\_integrated}, senza cambiare $K_x,K_i,L,Q_n,R_n$.
Il confronto LQG usa i dati M8 salvati: un test verifica l'identità esatta
dei guadagni $K,L,N_r$ rispetto agli artifact correnti.

La sezione iniziale è
$\delta x_{\rm mech}=[\delta q;0_2;\delta q;0_2]$,
con attuatori all'equilibrio, $\hat x_0=0_{14}$ e, per LQRI, $\xi_0=0_2$.
Riferimento, disturbo e rumori sono nulli; non sono introdotte saturazioni.
Si usa il box $[-60,60]^2$ gradi, griglia iniziale $5\times5$, 36 direzioni
a intervalli di $10^\circ$ e bisezione radiale con precisione $1^\circ$
se l'estremo non converge. Il budget massimo è 400 simulazioni.
Il solver è \texttt{ode23t}, tolleranze $10^{-5}$ e $10^{-7}$,
passo massimo 0.005 s: gli stessi valori di M8.

L'orizzonte è 8 s, estendibile a 12 s secondo il criterio M8.
La coda è l'ultimo 10\% dei \emph{campioni del solver}, come nel codice storico:
non è una nuova griglia uniforme né necessariamente l'ultimo 10\% del tempo.
Le soglie sono $0.5^\circ$ per link e rotori, 0.02 rad/s per i link e
0.05 rad/s per i rotori, con controllo della crescita finale
(fattore 0.05 e pavimento $0.05^\circ$). Le traiettorie devono essere
complete, finite e limitate a $10^6$; si controlla anche lo stato integrale.
La sezione opzionale con stima iniziale coerente non è rieseguita per LQRI.

\begin{table}[htbp]\centering
\begin{tabular}{lrr}\toprule
Protocollo nominale, stima iniziale nulla & LQG M6 & LQRI M7\\\midrule
Punti convergenti / esaminati & 57/57 & 57/57\\
Simulazioni / estensioni a 12 s & 57 / 0 & 57 / 0\\
Raggio minimo risolto [gradi] & 60 & 60\\
Raggio massimo campionato [gradi] & 78.3244 & 78.3244\\
Area del poligono campionato [gradi$^2$] & 14213.60 & 14213.60\\
Massimo comando osservato [Nm] & 232.1879 & __PEAK__\\\bottomrule
\end{tabular}
\caption{Entrambe le ricerche sono SEARCH-BOX LIMITED e non certificate.}
\end{table}
Non si osservano errori di simulazione, punti non convergenti o necessità
di estendere l'orizzonte LQRI. Il risultato non stabilisce quale controllore
abbia la RAS effettiva maggiore: entrambe le ricerche raggiungono il bordo.
Il raggio massimo supera $60^\circ$ perché è una distanza radiale in un box.
L'area è quella del poligono delle direzioni campionate; non è una misura
certificata della RAS. La ricerca finita non esclude punti interni sfavorevoli
o regioni non connesse radialmente. I picchi superiori a 200 Nm non sono
confrontati con un limite hardware non identificato.
\begin{figure}[htbp]\centering
\includegraphics[width=\textwidth]{figures/simulink_completion/ras_lqg_lqri.png}
\caption{Sezioni empiriche LQG e LQRI nel medesimo dominio. La frontiera
del disegno è il limite della ricerca, non una frontiera di stabilità provata.}
\end{figure}

\subsection{Test aggiunti e tracciabilità degli errori di sviluppo}
Restano intatti i 67 controlli e i sette test precedenti. La nuova suite
aggiunge 15 casi: quattro confronti lineari, quattro confronti a piccolo
segnale, quattro verifiche del diagramma M3 e degli ordini totali, tre
verifiche del protocollo RAS, dell'assenza di errori e dell'identità LQG.
I sette test originari sono rieseguiti insieme ai nuovi: 22/22 PASS.
Le 67 simulazioni di verifica originarie non sono rilanciate;
la loro evidenza salvata resta 67/67 PASS e viene controllata dalla suite.

Il primo run dei test ha prodotto quattro FAIL per un errore nel test:
\texttt{linmod} con un solo output restituisce una struttura, non la matrice A.
La chiamata è stata corretta richiedendo quattro output; modello e soglie
non sono cambiati. MAT e CSV del run iniziale sono conservati con suffisso
\texttt{initial\_failure}. Le simulazioni numeriche non avevano fallito.
Il nuovo percorso \texttt{CR\_RUN\_SCOPE=simulink-completion} rigenera solo
modello lineare, confronti e RAS nominale (ripresa da checkpoint compatibile).
Le evidenze sono in \path{results/data/simulink_completion}; nessun risultato
robusto precedente è ricalcolato o sostituito.
""".replace("__ROWS__", row_text).replace("__PEAK__", f"{peak:.4f}")
write("report/sections/10c_simulink_completion.tex", chapter)

slides = r"""\begin{frame}{Simulink: due piante, la stessa architettura 8+6}
\small
\[x_{\rm mech}=[q;\dot q;\theta;\dot\theta]\in\mathbb R^8,
\qquad x_a\in\mathbb R^6.\]
\begin{itemize}
\item Quattro modelli non lineari conservati: coordinate assolute,
attuatori inizializzati all'equilibrio, feedback incrementale.
\item Un solo nuovo modello lineare comune, con i controllori congelati:
\end{itemize}
\[\dot x=A_{\rm full}x+B_{\rm full}u+B_{d,\rm full}d,
\quad y=C_{\rm full,Meas}x,\quad q=C_{\rm full,Q}x.\]
\begin{itemize}
\item LQG/LQRI ricevono $[r;y]$; H-infinity/Kmu ricevono $[r;q]$.
\item Ordini totali: 28, 30, 36, 92. Nessuna nuova sintesi o riduzione.
\item Originali di Valerio in legacy; parametri e guadagni dagli artifact MATLAB.
\end{itemize}
\end{frame}

\begin{frame}{Rumori, Kalman e integratore: segnali distinti}
\small
\[d_{\rm link}=d_{\rm ext}+w_d,\quad
u_{\rm abs}=\bar\tau+\delta u+\eta_u,\quad y_{\rm mis}=y_{\rm ideal}+v.\]
\[G_w=[B_d\ B],\quad Q_n=0.01I_4,\quad R_n=(0.05\pi/180)^2 I_4.\]
\[\dot{\hat x}=A\hat x+B\delta u+L(y_{\rm mis}-C\hat x).\]
\begin{columns}[T]
\column{.48\textwidth}
\textbf{LQG}\[\delta u=-K\hat x+N_rr.\]
Lo stato vero serve al confronto, non al feedback.
\column{.48\textwidth}
\textbf{LQRI}\[\delta u=-K_x\hat x-K_i\xi,\quad\dot\xi=r-q_{\rm mis}.\]
Due integratori, nessun $N_r$ aggiuntivo.
\end{columns}
\par\medskip
Quattro rumori di misura indipendenti, seed fissi, ZOH 0.002 s.
Prove a banda finita: non white noise continuo esatto.
\end{frame}

\begin{frame}{LQG e LQRI: disturbo costante e condizioni iniziali}
\small
{\centering\includegraphics[width=\textwidth,height=.42\textheight,keepaspectratio]{../report/figures/simulink_integration/disturbance.png}\par}
\small
$d_1=0.5$ Nm da 1 s: a 20 s LQG mantiene offset;
LQRI lascia $\|e_q\|\simeq1.78\,10^{-8}$ rad.
\par\medskip
RAS nominale, stesso protocollo: \textbf{57/57 punti convergenti per entrambi},
box $\pm60^\circ$, 36 direzioni, precisione $1^\circ$, $\hat x_0=0$, $\xi_0=0$.
\par\medskip
\bad{Entrambe limitate dal box: nessuna RAS certificata o superiorità dimostrata.}
Picchi osservati: LQG 232.19 Nm, LQRI __PEAK__ Nm; M7 resta PARTIAL.
\end{frame}

\begin{frame}{Validazione completata, limiti di progetto conservati}
\small
\begin{tabular}{lrr}\toprule
Confronto, quattro controllori & max errore $q$ [rad] & max errore $u$ [Nm]\\\midrule
Simulink lineare / MATLAB lineare & __LQ__ & __LU__\\
SL non lineare / lineare (piccolo segnale) & __NQ__ & __NU__\\\bottomrule
\end{tabular}
\par\medskip
\good{32/32 nuovi controlli; 15/15 nuovi test e 7/7 originari PASS.}
Le evidenze originarie 67/67 restano invariate.
\begin{itemize}
\item LQG: riferimento nominale. LQRI: reiezione del disturbo costante.
\item Kmu: RS/RP PASS sul modello M4; H-infinity: RS FAIL.
\item M5 resta FAIL per i due robusti. Nessuna nuova garanzia hardware.
\item Simulato su R2025b; saturazioni, code generation e replay R2026a non verificati.
\end{itemize}
\end{frame}
\end{document}
"""
max_l = [max(e[j] for c in linear["controllers"] for e in c["linearErrorsQU"]) for j in range(2)]
max_n = [max(c["nonlinearErrorsQU"][j] for c in linear["controllers"]) for j in range(2)]
for key, value in zip(("__LQ__", "__LU__", "__NQ__", "__NU__"), max_l + max_n):
    slides = slides.replace(key, f"{value:.2e}")
slides = slides.replace("__PEAK__", f"{peak:.2f}")
path = ROOT / "presentation/main.tex"
source = path.read_text(encoding="utf-8")
starts = list(re.finditer(r"\\begin\{frame\}", source))
write("presentation/main.tex", source[:starts[16].start()] + slides)

seconds = [15,30,55,40,45,45,65,60,40,45,90,65,85,40,55,45,60,65,65,65]
assert sum(seconds) == 1075
titles = ["Titolo"] + re.findall(r"\\begin\{frame\}\{([^}]+)\}", (ROOT / "presentation/main.tex").read_text(encoding="utf-8"))
assert len(titles) == 20
notes = [
"Presentare tema e autori, senza anticipare l'intera scaletta.",
"Distinguere subito modellazione, prestazione nominale, simulazione non lineare e robustezza. Una curva di tracking non dimostra tutte e quattro le proprietà.",
"Leggere le due equazioni fisiche. L'elasticità separa link e rotori: quattro coordinate e quattro velocità. Indicare l'equilibrio e la necessità del feedback.",
"Spiegare i sei stati aggiuntivi: attuatori dinamici e Padé. La linearizzazione completa ha 14 stati; non confonderli con gli otto meccanici.",
"Indicare i parametri reali incerti e le due incertezze dinamiche. Il dominio è ingegneristico, non una distribuzione statistica identificata.",
"Richiamare settling 0.8 s e gli altri target originali. La scala del comando non è una saturazione. Non leggere tutte le curve della figura.",
"Spiegare trasformazione fisica, scale e pesi diretti. Il costo sulla deformazione rende Q non diagonale. Indicare il candidato selezionato senza ripercorrere la ricerca.",
"Descrivere le quattro misure e le covarianze assunte, non fornite dal docente. Più fiducia nelle misure accelera la stima e trasferisce più rumore al comando. Feedback su xhat.",
"Mostrare il tracking LQG e il suo ruolo nominale. Non ripetere Riccati e selezione dei pesi già discussi.",
"Spiegare che LQRI esiste ed è implementata, ma M7 resta PARTIAL rispetto ai target congiunti. Due stati integrali si aggiungono ai 14 stimati.",
"Dedicare tempo alla vera architettura 2-DoF: riferimento e misura entrano separatamente, Kr e Ky condividono gli stati. Spiegare modello desiderato e uscite pesate. Gamma minore di uno riguarda quel problema pesato e non equivale al rispetto di M5.",
"Mostrare miglioramento nominale e settling ancora troppo lento. Dichiarare chiaramente RS FAIL; l'intervallo RP invertito non viene accreditato. Non presentare questo controllore come robusto.",
"Spiegare ruolo della D-K iteration e della successiva post-analisi. Kmu conserva 78 stati, RS/RP maggiori di uno sul modello dichiarato. Restano settling e offset M5: robustezza e prestazione temporale sono giudizi diversi.",
"Confrontare 0/40, 40/40 e LQG storico 37/40. Il campionamento è un controllo empirico comune, non una probabilità fisica né un sostituto della mu-analysis.",
"Evidenziare l'amplificazione del rumore Hinf nella campagna di quattro secondi. Spiegare raggio minimo zero come limite di risoluzione e Kmu come box-limited. Non confondere questi dati robusti con la nuova RAS LQRI.",
"Distinguere equazione di Lyapunov, gate numerico e controllo campionato. Il residuo Hinf fallisce; il livello campionato Kmu non diventa un certificato. Nessuna nuova sintesi o riduzione è stata effettuata.",
"Indicare i quattro modelli non lineari già validati e il solo nuovo diagramma lineare comune. Il blocco M3 espone 14 stati, Cmeas e Cq sono separati. Tutti i controllori provengono dagli artifact correnti; gli originali restano in legacy. Nessuna demo live nel tempo assegnato.",
"Seguire fisicamente i tre canali: coppia sui link, rumore prima degli attuatori, rumore sugli encoder. Kalman conosce il comando, non la realizzazione del rumore. LQRI integra r-q_mis; entrambi i feedback usano xhat. Citare discretizzazione ZOH e seed senza entrare nei dettagli di implementazione.",
"Il grafico dimostra l'offset LQG e la reiezione LQRI del disturbo costante. Aggiungere il nuovo confronto RAS: 57 punti su 57, stessa sezione iniziale e box, nessuna estensione oltre 8 s. Entrambi raggiungono il bordo: non concludere che la RAS sia infinita, certificata o migliore per LQRI. I picchi di coppia restano un limite pratico.",
"Spiegare i due confronti distinti e citare le soglie 2e-7 rad e 2e-4 Nm. Nuovi 32 controlli e 15 test, più i sette originari rieseguiti; i 67 controlli salvati non sono stati ricalcolati. Concludere sui ruoli dei controllori e sui limiti hardware. Se chiesto, il run iniziale dei test conteneva un errore di uso di linmod, documentato e corretto solo nel test."
]
timeline = ["# Scaletta e tempi — PR #33", "", "20 slide; esposizione prevista **17:55**, margine **2:05** sul massimo di 20:00.", "Il tempo include titolo e conclusioni. Nessuna dimostrazione live aggiuntiva nel blocco da 20 minuti.", "I tempi sono una scaletta di esposizione, non una durata misurata con una prova orale.", "", "| Slide | Contenuto | Durata | Fine cumulativa |", "|---:|---|---:|---:|"]
speaker = ["# Note del relatore — 20 slide, 17:55", "", "Rispettare i tempi per slide. Margine residuo 2:05; evitare demo live e lettura integrale delle tabelle.", ""]
total = 0
for i, (title, sec, note) in enumerate(zip(titles, seconds, notes), 1):
    total += sec
    duration = f"{sec//60}:{sec%60:02d}"
    timeline.append(f"| {i} | {title} | {duration} | {total//60}:{total%60:02d} |")
    speaker += [f"## {i}. {title} — {duration}", "", note, ""]
timeline += ["", "Le precedenti slide 17–24 sono compresse nelle attuali 17–20. H∞, Kµ, risultati robusti e limiti restano nelle slide 11–16.", "Se una sezione sfora, abbreviare il commento a grafici già spiegati; non omettere risultati negativi o limiti della RAS."]
write("presentation/OUTLINE_AND_TIMING.md", "\n".join(timeline))
write("presentation/SPEAKER_NOTES.md", "\n".join(speaker))

summary = f"""# Completamento PR #33 — 23 settembre 2026

Branch: codex/simulink-integration. Base di questa integrazione aggiuntiva: 8044946.
PR: https://github.com/Deda-404/Progetto_CR/pull/33 — deve restare draft, senza merge.

Esito: modello linearizzato Simulink esplicito validato; RAS nominale LQRI calcolata;
presentazione ridotta da 24 a 20 slide, durata prevista 17:55 (margine 2:05).
Il timing è una scaletta, non una prova orale cronometrata.

MODELLO LINEARE
Un solo SEA_linear_common.slx: Afull, [Bfull BdFull], 14 stati (8+6),
uscite CfullMeas e CfullQ separate. Selezione LQG/LQRI/Hinf/Kmu da artifact congelati.
Ordini completi 28/30/36/92, nessuna riduzione. Diagramma deterministico;
rumore e disturbo del progetto restano anche nei quattro modelli non lineari originari.
Nuove simulazioni: tre scenari di 3 s per controllore (5 gradi separatamente sui
due giunti e disturbo link-side [0.01;-0.007] Nm), più un confronto a piccolo segnale.
Le tracce non lineari del confronto sono quelle già calcolate e validate nella PR33.
32/32 controlli PASS, soglie 2e-7 rad e 2e-4 Nm fissate prima del calcolo.
Peggior errore Simulink lineare/MATLAB: q={max_l[0]:.8e} rad, u={max_l[1]:.8e} Nm.
Peggior errore non lineare/lineare Simulink: q={max_n[0]:.8e} rad, u={max_n[1]:.8e} Nm.

RAS LQRI
Protocollo M8 LQG riutilizzato direttamente: dq e dtheta uguali, velocità nulle,
attuatori in equilibrio, xhat0=0 e xi0=0. Riferimento, disturbi e rumori nulli.
Box +/-60 gradi, griglia 5x5, 36 direzioni, precisione radiale 1 grado;
orizzonti 8/12 s, ode23t, RelTol=1e-5, AbsTol=1e-7, MaxStep=0.005 s.
Coda: ultimo 10% dei campioni del solver, come M8; soglie 0.5 gradi per
q/theta, 0.02/0.05 rad/s per le velocità; verifica crescita finale e finitezza.
57/57 punti convergenti in 57 simulazioni, zero estensioni e zero errori.
Raggio minimo 60 gradi, massimo {ras['maximumRadiusDeg']:.6f};
area del poligono campionato {ras['approximateAreaDeg2']:.6f} gradi quadrati.
Picco comando {peak:.8f} Nm (LQG storico: 232.1879 Nm).
Identità K/L/Nr della RAS LQG storica verificata rispetto agli artifact correnti.
Entrambe SEARCH-BOX LIMITED: nessuna frontiera reale individuata, nessuna
certificazione e nessuna superiorità dimensionale della RAS dimostrata.
La sezione LQRI con stima iniziale coerente non è stata eseguita.
Nessuna saturazione hardware introdotta; picchi di coppia dichiarati.

TEST E FALLIMENTI DOCUMENTATI
67 controlli precedenti conservati, con evidenza salvata PASS (non rilanciati).
7 test originari rieseguiti: PASS. 15 test aggiunti: PASS. Totale 22/22.
Nuovi casi: 4 equivalenze MATLAB/SL lineare; 4 equivalenze NL/SL lineare;
4 verifiche effettive di matrici, interfacce e numero stati; protocollo RAS,
assenza di errori RAS, identità LQG storico (3 casi).
Prima esecuzione: 4 FAIL nel test dimensionale perché linmod a singolo output
restituisce una struttura. Corretto esclusivamente il test richiedendo quattro
output; modello, guadagni, soglie e risultati non sono stati adattati al PASS.
MAT/CSV initial_failure conservano il run iniziale; il run finale è 22/22 PASS.

RIPRODUZIONE SENZA SINTESI
MATLAB: setenv('CR_RUN_SCOPE','simulink-completion'); run_all
Il checkpoint RAS evita ripetizioni ed è accettato solo con identità esatta
di configurazione e artifact. Per ricalcolo completo, archiviare altrove
lqri_ras_checkpoint.mat prima di eseguire il percorso.
Documenti: python report/build_completion_text.py; latexmk -pdf nelle cartelle
report e presentation, poi copia main.pdf nei rispettivi nomi finali.

VINCOLI E LIMITI
Controllori/sintesi, quattro SLX non lineari, legacy Valerio e risultati robusti
precedenti non modificati. Nessuna sintesi, musyn, Monte Carlo o mu-analysis rilanciata.
MATLAB/Simulink erano disponibili: nuove simulazioni realmente eseguite in R2025b
Update 4. Restano non verificati replay R2026a, hardware, saturazioni e code generation.
Hinf RS FAIL e MC 0/40, Kmu RS/RP PASS e MC 40/40, M5 FAIL e M7 PARTIAL invariati.

PDF FINALI
report/Progetto_CR_Relazione_finale.pdf
presentation/Progetto_CR_Presentazione.pdf

FILE NUOVI PRINCIPALI
simulink/build_linear_common.m
simulink/setup_linear_common.m
simulink/simulate_linear_common.m
simulink/simulate_integrated_ras.m
simulink/models/SEA_linear_common.slx
analysis/validate_linear_common.m
analysis/ras/validate_lqri_ras.m
analysis/run_simulink_completion.m
analysis/export_simulink_completion.m
tests/test_simulink_completion.m
report/build_completion_text.py
report/sections/10c_simulink_completion.tex
report/figures/simulink_completion/linear_nonlinear.png
report/figures/simulink_completion/ras_lqg_lqri.png
docs/RESOCONTO_PR33_COMPLETION.md e .txt

MODIFICHE A FILE ESISTENTI
analysis/ras/estimate_lqg_ras.m: adattatore opzionale e checkpoint, default storici invariati.
run_all.m: nuovo percorso circoscritto simulink-completion.
report/sections/10b_integrazione_simulink.tex: collegamento alla nuova sezione.
report/sections/13_conclusioni_limiti.tex e C_riproducibilita.tex: esiti e riproduzione.
presentation/main.tex, OUTLINE_AND_TIMING.md, SPEAKER_NOTES.md e PDF: 20 slide, 17:55.
README.md, CHANGELOG.md, docs/DIARIO_DI_BORDO.md, DECISION_LOG.md, PROJECT_STATUS.md.
Relazione PDF aggiornata dopo validazione.

EVIDENZE AGGIUNTE (results/data/simulink_completion)
"""
summary += "\n".join(p.name for p in sorted(DATA.iterdir()) if p.is_file())
summary += "\n\nIl commit finale è indicato nel messaggio di consegna della PR; git log -1 ne verifica l'identità.\n"
write("docs/RESOCONTO_PR33_COMPLETION.md", summary)
write("docs/RESOCONTO_PR33_COMPLETION.txt", summary)
