# Dinamica nominale degli attuatori e pianta completa M3

## Scopo e confini

M3 aggiunge al modello meccanico M2 una dinamica esterna per ciascun attuatore. Il comando richiesto `u` attraversa il secondo ordine e il ritardo; l'uscita `tau` è la coppia effettivamente applicata all'ingresso motore del modello SEA a otto stati:

```text
u -> dinamica attuatore + ritardo -> tau -> meccanica SEA M2 -> q, theta
```

Il blocco non sostituisce né duplica `Jm*theta_ddot + Bm*theta_dot`, già contenuto nella meccanica M1/M2. Tutte le grandezze M3 sono nominali. Non sono introdotti range, `ureal`, `ultidyn`, `ucover`, pesi d'incertezza o controllori.

## Modello imposto dalla traccia

Per ogni canale:

\[
G_m(s)=\frac{\omega_n^2}{s^2+2\zeta\omega_n s+\omega_n^2}e^{-\tau_d s}
=G_0(s)e^{-\tau_d s}.
\]

Il ritardo è rappresentato nel modello razionale con Padé del primo ordine:

\[
P_1(s)=\frac{1-\tau_d s/2}{1+\tau_d s/2},\qquad
G_a(s)=G_0(s)P_1(s).
\]

Ne segue un attuatore SISO di ordine 3. Due copie diagonali producono un blocco MIMO 2×2 di ordine 6; la cascata esplicita con gli 8 stati meccanici ha ordine 14.

## Analisi deterministica e scelta nominale

I parametri non sono forniti dalla traccia. Prima di consultare il riferimento sono stati valutati 27 candidati ottenuti dal prodotto cartesiano:

| Parametro | Valori valutati |
| --- | --- |
| \(\omega_n\) | 25, 40, 60 rad/s |
| \(\zeta\) | 0.6, 0.8, 1.0 |
| \(\tau_d\) | 0.010, 0.015, 0.025 s |

La tabella completa è generata da `analysis/nominal/select_nominal_actuator.m` e salvata come `candidateTable` nel dataset M3. Sull'intera griglia si osservano:

| Metrica | Minimo | Massimo |
| --- | ---: | ---: |
| Rise time | 0.03135 s | 0.13612 s |
| Settling time | 0.07291 s | 0.26248 s |
| Overshoot | 0% | 9.4581% |
| Banda | 16.0573 rad/s | 68.8348 rad/s |
| Errore di fase Padé a 80 rad/s | 2.2338° | 24.5916° |

È selezionato il candidato `C14`:

\[
\boxed{\omega_n=40\ \mathrm{rad/s},\quad \zeta=0.8,\quad
\tau_d=0.015\ \mathrm{s},\quad n_{Pad\acute e}=1.}
\]

La scelta bilancia quattro criteri:

- i poli instabili meccanici di M2 sono a 4.0408 e 7.2094 s⁻¹, quindi l'attuatore è sensibilmente più rapido delle dinamiche di stabilizzazione a bassa frequenza;
- \(\zeta=0.8\) limita l'overshoot nominale senza imporre il caso criticamente smorzato;
- la banda di 34.7834 rad/s mantiene un roll-off attuativo rilevante prima dei modi elastici a circa 69.95 e 79.40 rad/s;
- 15 ms rappresentano un ritardo non trascurabile, ma l'errore del Padé del primo ordine resta moderato nella zona dei modi elastici.

Questi valori sono una **assunzione nominale progettuale**, non un'identificazione sperimentale. Dovranno essere sottoposti a un modello d'incertezza soltanto in M4.

## Secondo ordine e attuatore SISO

Per i parametri selezionati:

\[
G_0(s)=\frac{1600}{s^2+64s+1600}.
\]

Il guadagno statico è 1 e i poli sono \(-32\pm24j\) s⁻¹. Le metriche del secondo ordine puro sono:

| Metrica | Valore |
| --- | ---: |
| Rise time | 0.0616973 s |
| Settling time | 0.0939060 s |
| Overshoot | 1.51646% |
| Banda | 34.7834 rad/s |

Con Padé, l'attuatore completo conserva guadagno statico unitario e ha:

| Proprietà | Valore |
| --- | --- |
| Ordine | 3 |
| Poli | \(-32\pm24j\), \(-133.3333\) s⁻¹ |
| Zero | \(+133.3333\) s⁻¹, RHP |
| Rise time | 0.0626454 s |
| Settling time | 0.109362 s |
| Overshoot | 1.47221% |
| Banda | 34.7834 rad/s |

Lo zero RHP nasce dall'approssimazione del ritardo e rende il canale non minimum-phase; non è un polo e non rende internamente instabile l'attuatore. Tutti i suoi poli sono nel semipiano sinistro e non sono state applicate cancellazioni artificiali.

## Ritardo esatto e Padé

Il solo fattore Padé del primo ordine è all-pass: il massimo errore numerico di modulo rispetto a \(e^{-j\omega\tau_d}\) sulla griglia 0.1–200 rad/s è \(2.220\times10^{-16}\). Il confronto di fase è:

| Frequenza [rad/s] | Fase esatta | Fase Padé | Errore assoluto |
| ---: | ---: | ---: | ---: |
| 1 | -0.859437° | -0.859421° | 0.0000161° |
| 4.04083 | -3.47284° | -3.47178° | 0.001063° |
| 7.20943 | -6.19605° | -6.19002° | 0.006028° |
| 70 | -60.1606° | -55.3989° | 4.76162° |
| 80 | -68.7549° | -61.9275° | 6.82742° |

L'approssimazione è quindi molto accurata alle frequenze dei modi instabili M2 e meno accurata, come atteso, avvicinandosi ai modi elastici. Il suo uso è imposto dalla traccia e il limite deve essere ricordato nelle analisi robuste successive.

## Blocco MIMO a sei stati

Il nominale assume due canali identici e disaccoppiati:

\[
G_A(s)=\operatorname{diag}(G_a(s),G_a(s)).
\]

Il blocco ha due ingressi `u1,u2`, due uscite `tau1,tau2`, sei stati e guadagno statico \(I_2\). I canali incrociati sono nulli sulla griglia di test. L'identità fra attuatori è solo una simmetria nominale; differenze fra canali non sono modellate in M3.

## Costruzione esplicita della pianta a 14 stati

La convenzione è fissata senza affidarsi all'ordine interno di `connect`:

\[
x_{full}=\begin{bmatrix}x_{mech}\\x_{act}\end{bmatrix},
\]

con i primi otto stati meccanici

\[
[q_1,q_2,\dot q_1,\dot q_2,\theta_1,\theta_2,
\dot\theta_1,\dot\theta_2]^T
\]

seguiti dai sei stati dei due attuatori. I `StateName` sono assegnati e verificati nei test.

Posti

\[
\dot x_m=A_mx_m+B_m\tau,\qquad
\dot x_a=A_ax_a+B_au,\qquad
\tau=C_ax_a+D_au,
\]

le matrici complete sono costruite direttamente come

\[
A_{full}=\begin{bmatrix}A_m&B_mC_a\\0&A_a\end{bmatrix},
\qquad
B_{full}=\begin{bmatrix}B_mD_a\\B_a\end{bmatrix}.
\]

Per una generica uscita meccanica \(y=C_mx_m+D_m\tau\):

\[
C_{full}=\begin{bmatrix}C_m&D_mC_a\end{bmatrix},\qquad
D_{full}=D_mD_a.
\]

Sono generati `GfullMeas` con due ingressi e quattro uscite \([q;\theta]\), e `GfullQ` con due ingressi e due uscite \(q\). Entrambi hanno esattamente 14 stati.

Una seconda costruzione indipendente con `series(GactuatorsMimo,GmechanicalMeas)` coincide sulla griglia logaritmica 0.01–1000 rad/s: massimo errore assoluto e relativo pari a zero entro precisione numerica.

## Poli della pianta completa

La pianta conserva gli otto poli meccanici M2 e aggiunge due copie dei tre poli attuativi:

- modi meccanici complessi stabili: \(-0.683829\pm79.4003j\), \(-0.961872\pm69.9477j\) s⁻¹;
- modi meccanici reali stabili: \(-7.88551\), \(-4.07335\) s⁻¹;
- modi meccanici reali instabili: \(+7.20943\), \(+4.04083\) s⁻¹;
- poli attuativi, ciascuno con molteplicità due: \(-32\pm24j\), \(-133.3333\) s⁻¹.

La classificazione completa è 12 stabili, 2 instabili e 0 marginali. Non compaiono nuovi poli instabili; lo zero Padé RHP non va confuso con questa classificazione.

## Proprietà strutturali e scaling

L'estesa separazione di scale rende le matrici grezze `ctrb` e `obsv` numericamente fuorvianti. Con la tolleranza SVD automatica, entrambe riportano rango 10/14 e condizionamenti rispettivamente \(1.851\times10^{23}\) e \(2.477\times10^{19}\). Questo non viene nascosto né interpretato come perdita strutturale.

Normalizzando il tempo con \(\omega_s=\max_i|p_i|=133.3333\) rad/s, cioè usando \(A/\omega_s\) e \(B/\omega_s\), si ottiene:

| Proprietà | Rango | Condizionamento | PBH su tutti i modi | PBH modi critici |
| --- | ---: | ---: | --- | --- |
| Controllabilità | 14/14 | \(3.594\times10^5\) | PASS, \(\sigma_{min}\ge0.2064\) | stabilizzabile, PASS |
| Osservabilità con `[q;theta]` | 14/14 | \(1.477\times10^2\) | PASS, \(\sigma_{min}\ge0.005890\) | rilevabile, PASS |
| Osservabilità informativa con `q` | 14/14 | \(2.933\times10^4\) | PASS, \(\sigma_{min}\ge2.665\times10^{-5}\) | rilevabile, PASS |

La conclusione strutturale è quindi: pianta completamente controllabile e osservabile nelle due configurazioni analizzate, oltre che stabilizzabile e rilevabile. La misura principale approvata in M2 resta `[q;theta]`.

## Figure, dati e riproducibilità

`run_all.m` rigenera:

- `results/figures/m3_delay_pade_comparison.png`;
- `results/figures/m3_actuator_bode.png`;
- `results/figures/m3_full_plant_sigma.png`;
- `results/data/m3_nominal_actuated_plant.mat`.

Il dataset contiene parametri, equilibrio, matrici meccaniche e complete, modelli SISO/MIMO, poli, tabella candidati, metriche Padé, equivalenza d'interconnessione e analisi strutturali.

## Confronto reference-last

La prima implementazione, i 27 candidati e il primo quality gate completo sono stati ottenuti senza consultare i parametri del progetto precedente. Solo dopo il PASS è stato verificato che quel progetto usa, ad alto livello, 30 rad/s, 0.7 e 20 ms. La nostra scelta 40 rad/s, 0.8 e 15 ms non è stata modificata: deriva dai criteri sopra, mentre il riferimento è stato usato soltanto come controllo dell'ordine di grandezza e della metodologia Padé.

Non sono stati copiati codice, realizzazioni, matrici, nomi, dataset, figure o risultati del riferimento.

## Limiti

- I parametri attuativi sono assunzioni progettuali, non dati identificati.
- Padé del primo ordine rappresenta bene il ritardo a bassa frequenza ma sottostima la perdita di fase verso e oltre i modi elastici.
- Il modello nominale assume canali identici e non descrive dispersione, dinamiche non modellate, saturazioni, dead-zone o limiti di coppia.
- Le singular values mostrano le dinamiche nominali, ma non definiscono una banda di controllo finale.
- Nessuna proprietà di robustezza è dichiarata in M3; incertezze e relativa validazione appartengono a M4.
