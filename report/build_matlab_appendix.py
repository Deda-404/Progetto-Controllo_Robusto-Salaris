"""Seleziona estratti letterali dei sorgenti MATLAB e registra le righe."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]
parts = [r"""\chapter{Principali codici MATLAB del progetto}\label{app:matlab}
Questa appendice raccoglie i passaggi necessari per leggere e riprodurre
il metodo, senza riportare plotting e salvataggi ripetitivi.
Ogni listato è incluso direttamente dal file indicato: non è una
riscrittura del codice. Gli estratti richiedono gli argomenti, i dati
e le funzioni del file completo; non sono script autonomi da incollare
ed eseguire in sequenza.

Per i Capitoli 8--9 la fonte corrente è la campagna
\path{analysis/run_hinf_final_*.m} e i dati in
\path{results/data/hinf_final_coherent}. Gli script didattici
\path{progetto_hinf.m} e i dataset M9--M14 nella radice di
\path{results/data} descrivono anche configurazioni precedenti:
non ne trasferiamo pesi, ordini e risultati alla campagna finale.
Le verifiche che non ripetono le sintesi sono nell'Appendice C.
"""]
manifest = []

def section(title):
    parts.append(r"\section{" + title + "}")

def excerpt(path, start, end, purpose):
    lines = (ROOT / path).read_text(encoding="utf-8-sig").splitlines()
    begin = next(i for i, value in enumerate(lines) if start in value)
    finish = next(i for i in range(begin, len(lines)) if end in lines[i])
    assert finish >= begin
    manifest.append({"file": path, "firstline": begin + 1, "lastline": finish + 1})
    parts.append(r"\par\medskip\noindent\begin{minipage}{\textwidth}\textbf{File:} \path{" + path + r"}\par\noindent\textit{Scopo.} " + purpose)
    parts.append(r"\lstinputlisting[firstline=" + str(begin + 1)
                 + ",lastline=" + str(finish + 1) + "]{../" + path + r"}\end{minipage}")

section("Parametri, equilibrio e linearizzazione")
excerpt("src/parameters/sea_params_nominal.m", "p.m1 =", "p.g =",
        "Definisce i parametri meccanici nominali centralizzati.")
excerpt("src/model/sea_static_equilibrium.m", "Gbar = sea_gravity", "xbar =",
        "Calcola posizione dei motori e coppia statica per la postura assegnata. Nel progetto si passa $\\bar q=[\\pi/2;0]$.")
excerpt("src/model/sea_linearize_static_equilibrium_analytic.m", "distalDerivative =", "B = [zeroBlock;",
        "Costruisce i blocchi del Jacobiano statico. La stessa funzione accetta parametri numerici o incerti, conservando le dipendenze delle equazioni SEA.")

section("Attuatori e modello nominale a 14 stati")
excerpt("src/actuators/build_nominal_actuator.m", "secondOrderNumerator =", "Gact = series",
        "Combina il secondo ordine con il ritardo approssimato tramite Padé del primo ordine. I valori nominali sono 40 rad/s, 0.8 e 15 ms.")
excerpt("src/model/build_m3_full_plant.m", "[Aact, Bact", "DfullQ =",
        "Collega gli otto stati meccanici ai sei dei due attuatori. Mantiene le viste delle quattro posizioni misurate e delle sole due posizioni articolari.")

section("Costruzione delle incertezze")
excerpt("src/uncertainty/build_uncertain_mechanical_plant.m", "row = find(rangeTable.Parameter", "value = ureal",
        "Crea uno scalare reale soltanto per i parametri selezionati nella tabella centrale; gli altri restano nominali. La tabella corrente assegna il 10\\% a $k_1,k_2,J_{m1}$.")
excerpt("src/uncertainty/build_m4_uncertain_plant.m", "DeltaAct1 =", "GactuatorsUncertain = append",
        "Inserisce le due incertezze dinamiche indipendenti tramite l'inviluppo $W_I$. Gli intervalli della famiglia attuativa sono condensati in questi blocchi.")

section("LQR, filtro di Kalman e controllore LQG")
excerpt("controllers/lqg/search_lqr_weights_m6.m", "[Ccost, Q, scales", "Nr = staticTrackingGain",
        "Costruisce il costo del candidato, calcola il feedback LQR e il guadagno statico sul riferimento. La selezione finale deriva dalla ricerca e dalle verifiche M6, non dal solo frammento.")
excerpt("controllers/lqg/design_kalman_m6.m", "A = m3Data.Afull", "L = lqe",
        "Calcola Kalman con disturbi lato link, errore del comando e quattro misure encoder. Le scale sono ipotesi progettuali, non dati sperimentali.")
excerpt("controllers/lqg/build_lqg_no_integrator.m", "controllerA =", "controllerD =",
        "Combina feedback e osservatore nel controllore senza integratore. Gli ingressi sono due riferimenti e quattro misure.")

section("LQGI con osservatore e integratore dell'errore")
excerpt("analysis/progetto_lqgi.m", "Aa=[A,zeros", "Bk=[zeros",
        "Mostra il problema LQR aumentato, la verifica Riccati e la realizzazione a 16 stati con Kalman M6. Si carica il candidato salvato all'indice \\texttt{illustrativeIndex}; non si usa lo stato vero nel controllo.")
excerpt("analysis/nonlinear/simulate_lqgi_nonlinear.m", "measured=[state(1:2)", "dz=[dm;",
        "Collega misure dei quattro encoder, stato stimato e memoria integrale alle equazioni SEA. Il rumore di processo entra solo nella pianta, mentre il Kalman conosce il comando calcolato.")
excerpt("analysis/run_hinf_final_nominal.m", "candidates=[study.one", "[~,ix]=sortrows(ranking,1:10)",
        "Documenta il criterio di selezione effettivo: stabilita e norma propria, soglia sul comando, numero e severita delle violazioni temporali, poi gli altri indicatori. Il confronto ricalcolato dei tre modelli desiderati e in omegaM\\_comparison.csv.")

section("Pesi, sensibilità mista e sintesi 1-DoF")
excerpt("controllers/hinf/hinf_revision_weights.m", "s = tf", "W2 =",
        "Costruisce i pesi dai cinque parametri del profilo; \\texttt{c.alpha=6}. Il profilo finale è $(2,0.15,3,0.003,80)$.")
excerpt("analysis/run_hinf_final_nominal.m", "[Kmix,CLmix", "r.K=r.Kfeedback",
        "Esegue le due sintesi 1-DoF sugli stessi pesi e scrive il controllore equivalente con ingressi separati $[r;q]$. Le verifiche successive confrontano mappe, norme e poli.")
excerpt("controllers/hinf/hinf_revision_plant.m", "G.InputName =", "'e(1)','e(2)'});",
        "Costruisce esplicitamente $P$ con errore $r-q$, due uscite pesate e due segnali per il controllore.")

section("Pianta 2-DoF, modello desiderato e partizioni del controllore")
excerpt("analysis/run_hinf_final_nominal.m", "w=c.referenceFrequencies(i)", "Mo=w^2/",
        "Definisce il modello di riferimento criticamente smorzato. I tre valori di frequenza provati sono 2, 3 e 4 rad/s.")
excerpt("controllers/hinf/hinf_final_2dof_plant.m", "physical.InputName=", "'q(1)','q(2)'});",
        "Collega modello fisico, $M_o$, $W_e$ e $W_u$ con errore $q-q_m$. Espone $[r;d;u]$ in ingresso e $[z_e;z_u;r;q]$ in uscita.")
excerpt("analysis/run_hinf_final_nominal.m", "r.P=hinf_final_2dof_plant", "[r.K,r.CL,r.gamma,r.info]",
        "Sintetizza il controllore con quattro ingressi e due comandi; riferimento e feedback sono progettati insieme.")
excerpt("controllers/hinf/hinf_final_evaluate.m", "[A,B,C,D]=ssdata", "e.maxRealPole=",
        "Partiziona $B_K,D_K$ nei canali $r$ e $q$, mantenendo $A_K,C_K$ condivise. La matrice chiusa verifica il segno $u=K_rr+K_yq$ e la stabilità interna senza cancellazioni.")

section("Sintesi strutturata sullo stesso problema")
excerpt("analysis/run_hinf_final_fixed.m", 'if name=="STATIC"', "[~,f.bestObjective,f.info]",
        "Definisce le famiglie statico, PI, PID e MIMO a ordine assegnato, con undici avvii e seed per famiglia. Le verifiche di ciascun risultato seguono nel file completo.")

section("Pianta incerta, analisi e sintesi robusta correnti")
excerpt("controllers/hinf/hinf_final_uncertain.m", "mech=m4.GmechUncQ", "physical=connect",
        "Preserva le proprietà incerte della meccanica e l'oggetto dinamico degli attuatori, aggiungendo il disturbo fisico lato link. Usare solo le matrici nominali eliminerebbe parte delle incertezze.")
excerpt("analysis/run_hinf_final_robust.m", "r=c.robust", "[K,objective,info]=musyn",
        "Prepara le opzioni della singola campagna D--K e chiama \\texttt{musyn} con le stesse porte del 2-DoF nominale.")
parts.append(r"""Le opzioni salvate sono: cinque iterazioni, \texttt{TargetPerf=0},
\texttt{TolPerf=0.01}, \texttt{MixedMU='on'}, \texttt{FullDG=[true true]},
\texttt{FitOrder=[5 2]}, griglia di 1201 frequenze da $10^{-3}$ a
$10^4$ rad/s, scaling automatico, regolarizzazione e limitazione
del guadagno attivi, \texttt{RandomStart=0}, \texttt{UseParallel=false},
\texttt{MinDecay=1e-7}, \texttt{MaxFrequency=Inf}, seed 20260918.
\texttt{FitOrder} limita il fit degli scaling, non l'ordine finale di $K$.
""")
excerpt("analysis/run_hinf_final_robust.m", "a.K=K; a.CL=lft", "[a.RP,a.rpWorst,a.rpInfo]",
        "A controllore fissato ricalcola nominale, struttura LFT e margini RS/RP sulla pianta originale. La funzione successiva conserva l'intervallo RP invertito e ne registra l'esito non validato.")

section("Calcolo diretto di mussv: procedura delle analisi precedenti")
excerpt("analysis/robust/analyze_m12_manual_mu.m", "omega = config.muFrequencyGrid", "lower = squeeze",
        "Calcola i limiti di $\\mu$ per il ritorno dell'incertezza su una griglia fissata. È una funzione delle analisi M12 precedenti, non la fonte dei margini finali di ordine 22 e 78. Un picco campionato non certifica da solo tutto l'asse delle frequenze.")

section("Campioni comuni e verifica Monte Carlo")
excerpt("analysis/monte_carlo/generate_m16_uncertainty_samples.m", "originalRng = rng", "[~, sampledValues] = usample",
        "Genera la sequenza riproducibile M16, con seed 20260826 e 40 campioni. Lo stato del generatore è preservato; il file completo controlla range, norme e replay.")
excerpt("analysis/run_hinf_final_monte_carlo.m", "old=load", "assert(isequaln(old.sampledValuesRaw",
        "Ricarica e verifica i campioni comuni prima di valutarli con i controllori finali. Le configurazioni dei vecchi controllori nel file M16 non sono adottate come ordini dei nuovi controllori.")

section("Dinamica non lineare e collegamento con il controllore")
excerpt("src/model/sea_nonlinear_rhs_with_link_disturbance.m", "q = x(1:2)", "xdot =",
        "Valuta le otto equazioni meccaniche con coppia motore e disturbo positivo sulle accelerazioni dei link. Il caso senza disturbo è in \\path{sea_nonlinear_rhs.m}.")
excerpt("analysis/nonlinear/simulate_hinf_final_nonlinear.m", "[ref,dist,nn]=signals(time)", "dz=[dm;",
        "Collega gli otto stati SEA, i sei stati attuativi e lo stato condiviso di $K$. Le posizioni misurate sono incrementali e possono contenere il rumore salvato; il simulatore usa \\texttt{ode23t}.")
parts.append(r"""La RAS nominale è calcolata da
\path{analysis/run_hinf_final_ras.m}, che richiama
\path{analysis/ras/estimate_m15_robust_ras.m} con lo stesso simulatore,
box, risoluzione e criteri del protocollo dichiarato. La chiamata
usa i controllori salvati e produce una sezione empirica, non
una certificazione globale. I risultati di questa relazione
non richiedono nuove ricerche RAS per essere letti o verificati.
""")

section("Formule di connessione e diagnosi del limite inferiore")
parts.append(r"""Le due LFT usate nei capitoli hanno le forme
\begin{equation}\label{eq:lowerlft}
 F_l(P,K)=P_{11}+P_{12}K(I-P_{22}K)^{-1}P_{21},
\end{equation}
\begin{equation}\label{eq:upperlft}
 F_u(N,\Delta)=N_{22}+N_{21}\Delta(I-N_{11}\Delta)^{-1}N_{12}.
\end{equation}
La prima chiude $u=Ky_K$ sulle porte inferiori; la seconda chiude
$w_\Delta=\Delta v_\Delta$ sulle porte superiori.
Nel codice \texttt{lft(Delta,M)} ricostruisce la seconda connessione.

Per la diagnosi 1-DoF, $S+GKS=I$ e $X=KS$.
A una frequenza fissata, con pesi scalari replicati
$a=|W_{1,s}|$, $b=|W_{2,s}|>0$, minimizzare
$a^2\|v-Gx\|^2+b^2\|x\|^2$ per una direzione unitaria $v$
fornisce il limite inferiore
\[
 \left\|\begin{bmatrix}W_1S\\W_2KS\end{bmatrix}\right\|_2
 \ge \frac{ab}{\sqrt{b^2+a^2\sigma_{\min}(G)^2}}.
\]
Si usa il valore singolare minimo, senza invertire $G$.
Il massimo sulla griglia è una diagnosi di richieste troppo severe:
non costruisce un controllore causale stabilizzante e non dimostra
la fattibilità quando è minore di uno. Il calcolo è in
\path{controllers/hinf/hinf_revision_lower_bound.m}, verificato
dai sette test in \path{tests/hinfLowerBoundTest.m}.
""")
(ROOT / "report/sections/D_codici_matlab.tex").write_text("\n\n".join(parts).rstrip() + "\n", encoding="utf-8")
(ROOT / "report/generated/matlab_appendix_sources.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
print(f"Appendice: {len(manifest)} estratti, {sum(r['lastline']-r['firstline']+1 for r in manifest)} righe MATLAB.")
