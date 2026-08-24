# Specifiche di prestazione M5

## Scopo e stato delle specifiche

M5 traduce il problema fisico del manipolatore SEA in obiettivi quantitativi, scenari di validazione e pesi per le future sintesi. I valori riportati sono target di progetto: non costituiscono prestazioni già raggiunte, limiti hardware certificati o margini robusti già dimostrati.

La source of truth è `src/parameters/performance_specs_m5.m`. La selezione usa i dataset validati M2 e M3 e viene rigenerata da `analysis/nominal/select_m5_performance_specs.m`.

## Obiettivo fisico e segnali

Il manipolatore deve essere mantenuto attorno all'equilibrio verticale superiore

\[
\bar q=\begin{bmatrix}\pi/2&0\end{bmatrix}^T,
\]

stabilizzando i due modi instabili e regolando le posizioni articolari (q_1,q_2). Le misure restano le quattro posizioni encoder ([q_1,q_2,\theta_1,\theta_2]^T), mentre l'uscita primaria di prestazione è (q=[q_1,q_2]^T).

Le funzioni richieste vengono mantenute distinte:

- **regulation:** ritorno a (\bar q) dopo condizioni iniziali o perturbazioni;
- **reference tracking:** inseguimento di piccole variazioni articolari attorno a (\bar q);
- **disturbance rejection:** attenuazione delle coppie esterne applicate ai link;
- **control effort:** contenimento della coppia comandata agli attuatori mediante una scala di normalizzazione;
- **high-frequency attenuation:** aumento della penalizzazione del comando prima dei modi elastici.

## Classificazione epistemica

| Classe | Significato | Esempi M5 |
| --- | --- | --- |
| requisito della traccia | problema o fenomeno da rappresentare, senza attribuire alla traccia scelte non univoche | scelta di un equilibrio e definizione dei disturbi |
| decisione approvata del progetto | scelta derivata, validata e registrata | equilibrio verticale superiore D-0003 |
| scelta di modellazione del progetto | rappresentazione fisica coerente con la traccia, ma non imposta in modo univoco | coppia esterna ai link D-0014 |
| assunzione di progetto | valore scelto per la futura verifica | ampiezze, (A_s), (M_s), scala di coppia, target temporali |
| criterio derivato | regola calcolata dai dati validati | finestra e ranking di (\omega_B), ammissibilità di (\omega_U) |
| criterio futuro | linguaggio di una verifica non ancora eseguita | upper bound di (\mu) per RS/RP |

In particolare, l'equilibrio (\bar q=[\pi/2,0]^T) è una decisione approvata del progetto, derivata e verificata in M2, non un requisito testuale della traccia. Analogamente, la coppia applicata direttamente alla dinamica dei link è la scelta di modellazione D-0014: è fisicamente coerente con il problema assegnato, ma non è l'unica collocazione possibile imposta dalla traccia. Questa correzione epistemica non modifica alcun valore numerico M5.

## Scenari di riferimento

Le variazioni articolari analizzate sono **2°, 5° e 8°**. Lo scenario nominale è 5°, cioè

\[
r_{nom}=0.0872665\ \mathrm{rad}.
\]

La consistenza locale è stata valutata confrontando la variazione esatta della coppia gravitazionale con il suo termine lineare lungo quattro direzioni articolari e con entrambi i segni.

| Ampiezza | Radianti | Massimo errore relativo della linearizzazione gravitazionale | Massima variazione di coppia gravitazionale |
| ---: | ---: | ---: | ---: |
| 2° | 0.034907 | 0.02565% | 0.32867 N m |
| **5°** | **0.087266** | **0.16043%** | **0.82080 N m** |
| 8° | 0.139626 | 0.41128% | 1.3107 N m |

Il caso 5° resta sufficientemente locale per questa verifica statica. Le ampiezze sono scenari di progetto e non corse articolari certificate.

## Disturbo fisico di coppia

Il disturbo principale è

\[
d=\begin{bmatrix}d_1&d_2\end{bmatrix}^T\ [\mathrm{N\,m}],
\]

applicato sul lato link:

\[
M(q)\ddot q+C(q,\dot q)\dot q+G(q)
=K_s(\theta-q)+d.
\]

Il comando (u=[u_1,u_2]^T) conserva il significato M3 e attraversa le dinamiche degli attuatori. Il disturbo (d) non è rumore additivo sulla misura e non attraversa gli attuatori.

Per lo stato meccanico (x=[q;\dot q;\theta;\dot\theta]), la derivazione all'equilibrio fornisce

\[
B_d=\begin{bmatrix}
0_{2\times2}\\
M(\bar q)^{-1}\\
0_{4\times2}
\end{bmatrix}
=\begin{bmatrix}
0&0\\0&0\\
6.25&-14.5833\\
-14.5833&47.9167\\
0&0\\0&0\\0&0\\0&0
\end{bmatrix}.
\]

Una differenza finita centrata del modello non lineare con disturbo restituisce errore assoluto e relativo pari a zero alla precisione numerica usata. La pianta nominale M5 mantiene 14 stati, ingressi ([u_1,u_2,d_1,d_2]) e uscite ([q_1,q_2,\theta_1,\theta_2]); il sottosistema da (u) coincide con M3 entro la precisione macchina e il feedthrough da (d) è nullo.

Le coppie analizzate sono **0.25, 0.50 e 1.00 N m**. Il caso nominale è 0.50 N m.

| Coppia | Deformazione SEA giunto 1 | Deformazione SEA giunto 2 |
| ---: | ---: | ---: |
| 0.25 N m | 0.0050 rad | 0.00625 rad |
| **0.50 N m** | **0.0100 rad** | **0.01250 rad** |
| 1.00 N m | 0.0200 rad | 0.02500 rad |

Nel caso nominale la coppia equivale a circa il 60.9% della massima variazione gravitazionale osservata nello scenario da 5°. È quindi significativa per la dinamica locale, produce deformazioni elastiche dell'ordine di (10^{-2}) rad e non viene interpretata come urto estremo. Le ampiezze non derivano da misure sperimentali.

## Scale dinamiche e banda target

I dataset validati forniscono:

- massima parte reale instabile (\lambda_{u,max}=7.20942861\ \mathrm{s^{-1}});
- primo modo elastico (\omega_{elastic,min}=69.9543360\ \mathrm{rad/s});
- banda attuatore nominale (\omega_{act}=34.7833702\ \mathrm{rad/s}).

La finestra è un criterio progettuale:

\[
\omega_{B,min}=1.5\lambda_{u,max}=10.8141429\ \mathrm{rad/s},
\]

\[
\omega_{B,max}=\min(0.40\omega_{act},0.20\omega_{elastic,min})
=13.9133481\ \mathrm{rad/s}.
\]

I coefficienti 1.5, 0.40 e 0.20 non sono requisiti della traccia. La selezione massimizza deterministicamente il margine minimo dai tre limiti e applica tie-break sul centro della finestra e sul valore di banda.

| Candidato | Margine inferiore | Margine attuatore | Margine elastico | Rank |
| ---: | ---: | ---: | ---: | ---: |
| 11 rad/s | 0.18586 | 2.91335 | 2.99087 | 3 |
| **12 rad/s** | **1.18586** | **1.91335** | **1.99087** | **1** |
| 13 rad/s | 2.18586 | 0.91335 | 0.99087 | 2 |

La banda target selezionata è quindi (\omega_B=12\ \mathrm{rad/s}). È un obiettivo per le sintesi successive, non una banda closed-loop già ottenuta.

## Target di sensitivity e peso W1

Il peso SISO è

\[
W_1(s)=\frac{s/M_s+\omega_B}{s+\omega_B A_s}.
\]

La griglia locale usa (A_s\in\{0.03,0.05,0.08\}) e (M_s\in\{1.7,2.0,2.4\}). La regola sceglie la severità mediana su entrambi gli assi, evitando sia il target più aggressivo sia quello più permissivo:

\[
A_s=0.05,\qquad M_s=2.0.
\]

Ne risultano

\[
W_1(0)=\frac{1}{A_s}=20,
\qquad
W_1(\infty)=\frac{1}{M_s}=0.5.
\]

(A_s=0.05) rappresenta un target di sensitivity a bassa frequenza dell'ordine del 5%; (M_s=2) ammette un picco desiderato dell'ordine di 6 dB. La futura sintesi dovrà stabilire se questi target siano contemporaneamente fattibili sull'ensemble M4.

## Scala dello sforzo e peso W2

In assenza di dati hardware, (u_{scale}) è una **scala di normalizzazione/prestazione**, non una saturazione certificata dell'attuatore. I candidati sono 8, 12 e 16 N m; il valore mediano

\[
u_{scale}=12\ \mathrm{N\,m}
\]

è superiore alle coppie elastiche degli scenari moderati, conserva margine dinamico e non assume disponibilità di coppie estreme.

Il peso SISO è

\[
W_2(s)=\frac{1}{u_{scale}}
\frac{s/\omega_U+1}{s/(\alpha\omega_U)+1},\qquad \alpha>1.
\]

La griglia usa (\omega_U\in\{25,30,35\}\ \mathrm{rad/s}) e (\alpha\in\{4,6\}). Sono ammissibili gli onset inferiori alla banda attuatore e non superiori a metà del primo modo elastico. Il ranking preferisce (u_{scale}) mediano, l'onset ammissibile più vicino dal basso alla banda attuatore e infine il maggiore incremento ad alta frequenza:

\[
\omega_U=30\ \mathrm{rad/s},\qquad \alpha=6.
\]

La distanza dalla banda attuatore è 4.78337 rad/s e quella dal primo modo elastico è 39.9543 rad/s. Gli asintoti verificati sono

\[
W_2(0)=\frac{1}{12}=0.0833333\ \mathrm{(N\,m)^{-1}},
\qquad
W_2(\infty)=\frac{6}{12}=0.5\ \mathrm{(N\,m)^{-1}}.
\]

Il peso aumenta quindi di un fattore sei e avvia la penalizzazione prima della banda attuatore e dei modi elastici.

## Struttura MIMO

Per M5 si assume simmetria fra i due giunti:

\[
W_1^{MIMO}=\operatorname{diag}(W_1,W_1),\qquad
W_2^{MIMO}=\operatorname{diag}(W_2,W_2).
\]

Entrambi i pesi sono 2×2, diagonali, stabili, propri, di ordine SISO uno e privi di valori non finiti. Non viene introdotto (W_3). La struttura prevista per la futura mixed sensitivity è

\[
\left\|\begin{bmatrix}W_1S\\W_2KS\end{bmatrix}\right\|_\infty,
\]

ma M5 non produce alcun controllore.

## Target temporali e interazione MIMO

I target di confronto per le milestone successive sono:

| Grandezza | Target M5 | Stato |
| --- | ---: | --- |
| settling time di tracking/regulation | ≤ 0.8 s | obiettivo, non verificato |
| overshoot | ≤ 10% | obiettivo, non verificato |
| errore tracking a regime | ≤ 5% | senza assumere a priori un integratore |
| disturbo costante/bassa frequenza | forte attenuazione | da quantificare closed-loop |
| errore con futuro integratore | zero | per ingressi costanti compatibili |
| cross-coupling di picco | ≤ 25% | preliminare |

Il cross-coupling verrà calcolato come (\max|q_2|/\max|q_1|) per eccitazione sul giunto 1 e simmetricamente nell'altra direzione. Il limite del 25% potrà essere rivisto solo sulla base di risultati closed-loop documentati.

## Linguaggio della robustezza

M5 distingue:

- **Nominal Stability**;
- **Nominal Performance**;
- **Robust Stability**;
- **Robust Performance**.

Le future verifiche useranno un upper bound di (\mu<1) per Robust Stability e un upper bound di (\mu<1) sul problema augmentato per Robust Performance. Nessun valore di (\mu), margine robusto o garanzia closed-loop è calcolato in M5.

## Artifact riproducibili

- `results/data/m5_performance_specs.mat` contiene specifiche, pesi, tabelle candidate, (B_d), pianta con disturbo e metriche;
- `results/figures/m5_weight_W1.png` mostra la sensibilità locale ad (A_s,M_s);
- `results/figures/m5_weight_W2.png` mostra scala e forma del peso sul comando;
- `results/figures/m5_spec_frequency_map.png` mostra la separazione fra instabilità, (\omega_B), (\omega_U), attuatore e modi elastici.

## Limiti

- Le ampiezze sono scenari di validazione, non dati sperimentali.
- Non è disponibile una saturazione hardware certificata.
- I pesi esprimono target; la loro fattibilità resta da verificare nelle sintesi successive.
- I pesi identici sui due giunti trascurano possibili esigenze di scaling asimmetrico.
- Il target di cross-coupling è preliminare.
- M5 non chiude anelli, non sintetizza controllori e non esegue `mussv`.
