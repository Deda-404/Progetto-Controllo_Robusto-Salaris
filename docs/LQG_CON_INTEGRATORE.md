# LQG nominale con azione integrale — M7 e completamento 2-DoF

## Stato corrente dopo il completamento autorizzato

M7 resta `PARTIAL`. Dopo il merge del checkpoint 1-DoF, il gruppo ha autorizzato un servo 2-DoF con feedforward di riferimento calcolato separatamente per ogni `Kx`. Stage A ha riesaminato gli stessi 28 candidati e Stage B ha eseguito una sola estensione da 25 candidati. Entrambe restituiscono zero progetti fondamentali ammissibili. M5 è invariata e nessun candidato estremo è stato promosso.

Gli artifact correnti sono `results/data/m7_lqi_2dof_feasibility.mat`, `results/figures/m7_lqi_candidate_comparison.png` e `results/figures/m7_lqi_feedforward_effect.png`. Il precedente `m7_lqi_grid_partial.mat` resta conservato senza riscrittura.

## Stato del checkpoint 1-DoF preservato

M7 è `PARTIAL`. La ricostruzione indipendente dell’augmentazione e l’intera griglia prescritta sono state completate, ma nessuno dei 28 candidati soddisfa simultaneamente il target di tracking M5 e il rigetto del disturbo costante. In accordo con il gate della milestone, M5 non è stato modificato e non sono stati costruiti né pubblicati un controllore LQG-I finale o il dataset finale `m7_lqg_integral.mat`.

Il checkpoint riproducibile è conservato in `results/data/m7_lqi_grid_partial.mat`; la figura `results/figures/m7_lqi_candidate_comparison.png` mostra il trade-off che ha imposto lo stop.

## 1. Motivazione

M6 usa un LQG nominale di ordine 14 senza integratori. Il precompensatore statico consente tracking nominale a errore nullo, ma non costituisce un internal model: i disturbi costanti da 0.5 N m producono offset di 0.079585 rad sul giunto 1 e 0.160232 rad sul giunto 2. M7 verifica se due integratori dell’errore articolare rimuovano tali offset senza perdere il target di settling pari a 0.8 s.

## 2. Confronto controllato con M6

Il blocco sui 14 stati fisici di ogni costo M7 coincide bit per bit con `Q` del dataset M6. Restano quindi invariati `wq=1`, `wqdot=0.5`, `wdelta=0.1` e `wthetaDot=0.5`. Non sono stati ritoccati il modello M3, le ampiezze M5, `uScale` o le covarianze KF03.

La sola nuova priorità è `wi`; `rhoU` varia esclusivamente nella griglia esplicita richiesta. Il precompensatore `Nr` M6 non è usato nella sintesi o nella simulazione dei candidati M7.

## 3. Formulazione integrale

Sono introdotti esattamente due stati, uno per ciascuna posizione articolare:

\[
\dot\xi=r-q,\qquad \xi=[\xi_1\;\xi_2]^T.
\]

Non sono integrati né `theta` né altri stati. Per il problema di regolazione, `r=0`, e la legge risultante dalla sintesi LQR mantiene senza correzioni manuali la convenzione

\[
u=-K_xx-K_i\xi.
\]

## 4. Augmentazione

La pianta full-state ideale è

\[
A_{aug}=\begin{bmatrix}A&0\\-C_q&0\end{bmatrix},\qquad
B_{aug}=\begin{bmatrix}B\\0\end{bmatrix}.
\]

Le dimensioni verificate sono 16×16 e 16×2. Tutti i modi superano il test PBH di controllabilità con rango 16. In particolare il PBH a zero ha rango 16 e la matrice di Rosenbrock `[A B; Cq 0]` ha rango 16: non è presente un’ostruzione da zero invariante in `s=0`. La matrice di controllabilità non scalata ha rango numerico 8 a causa del forte condizionamento già noto per la realizzazione attuativa; il test modale PBH a rango pieno è il criterio strutturale affidabile, coerente con M3.

## 5. Stabilizzabilità

I 16 test PBH modali restituiscono rango pieno. I due modi integrali a zero sono controllabili e la coppia `(Aaug,Baug)` è stabilizzabile. Tutti i 28 guadagni LQI ottenuti rendono il servo full-state asintoticamente stabile. M7 non è quindi `BLOCKED` per motivi strutturali.

## 6. Normalizzazione di xi

La scala è derivata dalla source of truth M5, senza hardcoding:

\[
\xi_{scale}=r_{amp}t_{s,target}=\operatorname{deg2rad}(5)\,0.8
=0.0698131701\ \mathrm{rad\,s}.
\]

Per entrambi i giunti si usa `Qi=wi/xiScale^2`; il comando conserva `R=rhoU/uScale^2 I2`. La matrice `Qaug` è semidefinita positiva e `R` è definita positiva per ogni candidato.

## 7. Grid tuning

Sono state eseguite tutte le 28 combinazioni

- `wi = [0.05 0.10 0.25 0.50 1 2 4]`;
- `rhoU = [4 8 12 16]`.

Per ciascun candidato sono registrati stabilità, tracking sui due step da 5°, comando, deformazione SEA, coppia elastica, norme di `Kx` e `Ki`, risposta ai due disturbi da 0.5 N m, cross-coupling, offset DC e indicatore lineare del picco integrale. Tutte le simulazioni usano la pianta nominale M3 completa a 14 stati.

## 8. Selezione e stop richiesto

I 28 candidati sono stabili e tutti annullano il guadagno DC disturbo-posizione entro la tolleranza `1e-4 rad`. Nessuno raggiunge tuttavia il settling M5 di 0.8 s. Il candidato più vicino al target, non selezionato, è I25:

| Grandezza diagnostica I25 | Valore |
| --- | ---: |
| `wi`, `rhoU` | 4, 4 |
| worst settling tracking | 1.964 s |
| gap rispetto al target | 1.164 s |
| overshoot | 0% |
| peak control / `uScale` | 0.0684212 |
| deformazione normalizzata | 1.3135 |
| worst settling disturbo | 2.19 s |
| norma `Ki` | 243.09 |

Per `wi<=1` il tracking non entra nella banda del 2% entro l’orizzonte M6 di 3 s; per `wi=2` il worst settling è 2.704–2.776 s e per `wi=4` è 1.964–2.014 s. Il ranking fondamentale non viene applicato perché l’insieme ammissibile è vuoto. I25 è soltanto il candidato diagnostico con settling minimo, non un controllore approvato.

## 9. Osservatore

Il piano approvato prevede il riuso esatto di `L`, `Qn` e `Rn` di KF03, con osservatore fisico di ordine 14 e due integratori interni non stimati. La costruzione è stata correttamente arrestata prima di questo passo: senza candidato LQI ammissibile non esiste un guadagno finale da associare al Kalman M6.

## 10. Realizzazione LQG-I

L’architettura primaria resta definita da `xi_dot=r-Sq*y` e `u=-Kx*xhat-Ki*xi`, senza `Nr`, con ingressi `[r1 r2 q1 q2 theta1 theta2]` e due uscite di comando. Non è stata materializzata una realizzazione state-space finale di ordine 16, perché ciò avrebbe promosso arbitrariamente un candidato che non supera il gate.

## 11. Tracking

Il target critico è stato valutato realmente su entrambi gli step da 5°. Overshoot ed errore statico non sono il problema: la violazione è il settling. Il miglior valore della griglia è 1.964 s contro 0.8 s. Nel caso deterministico con condizioni iniziali coerenti, un futuro LQG-I avrebbe lo stesso tracking del servo full-state; aggiungere l’osservatore non risolve quindi questa incompatibilità.

## 12. Disturbance rejection

La verifica non si limita all’argomento teorico. Per I25 il guadagno statico dai due disturbi alle due posizioni è numericamente nullo. Dopo 8 s, le componenti interessate valgono rispettivamente `3.23e-10 rad` e `2.24e-10 rad`, sotto `1e-4 rad`. Il confronto diagnostico è:

| Disturbo costante | offset M6 | offset DC I25 | campione I25 a 8 s |
| --- | ---: | ---: | ---: |
| `d1=0.5 N m` | 0.0795850 rad | 0 rad | 3.23e-10 rad |
| `d2=0.5 N m` | 0.1602320 rad | 0 rad | 2.24e-10 rad |

L’integratore ottiene dunque il beneficio centrale atteso, ma non basta a rendere il progetto ammissibile.

## 13. Rumore

La diagnostica measured-error contro estimated-error e la simulazione con seed M6 `20260826` sono rinviate: richiedono un candidato finale. Eseguirle su I25 e presentarle come M7 avrebbe confuso un punto diagnostico non approvato con il controllore della milestone. Il seed è già centralizzato in `lqg_specs_m7.m` tramite la configurazione M6.

## 14. Windup e limiti

Non sono state introdotte saturazioni, perché `uScale=12 N m` è una normalizzazione prestazionale e non un limite hardware certificato. Non è stato implementato anti-windup. Il picco di `xi` e il comando sono comunque registrati per ogni candidato nella tabella parziale; diventeranno rilevanti quando una successiva milestone disporrà di limiti motivati e simulazioni non lineari.

## 15. Confronto finale M6/M7

Il confronto completo richiesto non è producibile senza selezionare un controllore M7. Il risultato validato al checkpoint è più circoscritto: M6 soddisfa il tracking con worst settling 0.776 s ma conserva gli offset 0.079585/0.160232 rad; la griglia integrale annulla gli offset, mentre il miglior settling è 1.964 s. La tabella controller order, rumore e separation principle resta intenzionalmente assente fino alla revisione del gruppo.

Il prossimo passo deve essere autorizzato esplicitamente: per esempio ampliare `wi`, introdurre un confronto feedforward secondario oppure rivedere la struttura del costo. Non è autorizzata una modifica automatica di M5.

## 16. Autorizzazione del servo 2-DoF

Il gruppo ha mantenuto target, scale e costo M6 e ha separato le due funzioni che nel checkpoint erano entrambe affidate all’integratore:

\[
\dot\xi=r-C_qx,\qquad
u=-K_xx-K_i\xi+N_{ff}r.
\]

`Ki/xi` conserva l’internal model e il rigetto dei disturbi costanti. `Nff` agisce soltanto sul percorso nominale del riferimento. Non sostituisce l’integratore e non viene accreditato dell’offset nullo.

## 17. Calcolo candidato-specifico di Nff

Per ogni `Kx` è stato costruito

\[
A_{cl,x}=A-BK_x,\qquad
G_{dc,x}=\operatorname{dcgain}(A_{cl,x},B,C_q,0),\qquad
N_{ff}=G_{dc,x}\backslash I_2.
\]

Non è usato `Nr` M6 e non è usato `inv`. Sui 53 candidati complessivi il massimo condition number di `Gdc_x` è 1.75379 e il massimo residuo Frobenius `||Gdc_x*Nff-I||` è `2.483e-16`: tutti i problemi sono ben condizionati.

Con riferimento nullo il termine `B*Nff*r` scompare. Le simulazioni con `Nff=0` e con `Nff` candidato-specifico restituiscono esattamente gli stessi offset da disturbo; la massima differenza numerica è 0 rad. L’errore statico nullo deriva quindi dall’integratore.

## 18. Stage A — griglia originale con feedforward

Stage A ha ripetuto prima di ogni estensione `wi=[0.05,0.10,0.25,0.50,1,2,4]` e `rhoU=[4,8,12,16]`. Tutti i 28 candidati sono stabili, ben condizionati e rigettano i due disturbi entro `1e-4 rad`; nessuno soddisfa simultaneamente settling e overshoot.

Il punto con settling minimo resta la coppia I25 (`wi=4`, `rhoU=4`), ma non viene selezionato:

| Metrica I25 | 1-DoF, `Nff=0` | 2-DoF |
| --- | ---: | ---: |
| worst settling | 1.964 s | 1.880 s |
| worst overshoot | 0% | 28.824% |
| peak control | 0.821 N m | 10.972 N m |
| peak `xi` complessivo | valore nel dataset checkpoint | 0.039899 rad s |
| worst offset disturbo | 0 rad | 0 rad |

Per I25,

\[
N_{ff}=\begin{bmatrix}
125.7326 & 6.23275\\
17.6025 & 95.8478
\end{bmatrix}.
\]

Il feedforward anticipa il riferimento e riduce lievemente il settling, ma introduce un overshoot incompatibile con il limite del 10%. Sui candidati a `wi` minore l’overshoot può restare sotto il limite, mentre la coda integrale non raggiunge il settling di 0.8 s.

## 19. Confronto 1-DoF contro 2-DoF

La tabella `feedforwardComparison` conserva per tutti i 28 punti Stage A settling, overshoot, picco comando, picco integrale e offset con e senza feedforward. L’effetto non è uniformemente favorevole: la crescita del comando accelera la salita, ma l’interazione con i poli del servo integrale genera sovraelongazione e coda lenta.

Le risposte al disturbo delle due architetture si sovrappongono campione per campione perché `r=0`: questa è la verifica quantitativa che `Nff` non partecipa al rigetto statico.

## 20. Stage B — unica estensione autorizzata

Poiché Stage A ha prodotto 0/28 candidati ammissibili, è stata eseguita una sola griglia estesa con `wi=[4,8,16,32,64]` e `rhoU=[1,2,4,8,12]`. Tutti i 25 candidati sono stabili e annullano gli offset, ma nessuno soddisfa il gate.

Il minimo settling appartiene a E16 (`wi=32`, `rhoU=1`):

| Metrica diagnostica E16 | Valore |
| --- | ---: |
| worst settling | 1.020 s |
| worst overshoot | 40.6448% |
| peak control | 35.170 N m = 2.93083 `uScale` |
| peak deformazione | 0.062403 rad = 4.9922 `deltaScale` |
| `||Kx||F`, `||Ki||F`, `||Nff||F` | 1568.6, 1375.1, 492.56 |
| peak `xi` | 0.014549 rad s |
| worst picco disturbo | 0.047616 rad |
| worst settling disturbo | 0.946 s |
| worst offset disturbo | 0 rad |
| polo dominante | -4.5617 ± 4.4982j |

Il secondo giunto di E16 raggiunge 0.812 s, ma il primo richiede 1.020 s e sovraelonga del 40.6%. Il candidato non è ragionevole né ammissibile; non viene approvato.

## 21. Feasibility table e secondo stop

`feasibilityTable` ordina Stage B per settling e conserva `wi`, `rhoU`, comando, deformazione, norme dei tre guadagni, elementi di `Nff` e polo dominante. Il risultato mostra che aumentare `wi` fino a 64 non porta la coppia settling/overshoot nell’area richiesta. I punti più rapidi richiedono inoltre comandi e deformazioni nettamente maggiori.

Il gate autorizzato prescrive lo stop se anche Stage B fallisce. Di conseguenza non sono stati costruiti il Kalman augmentato, il controller di ordine 16, la diagnostica measured/estimated, il rumore M7, il confronto finale M6/M7 o il dataset `m7_lqg_integral.mat`. KF03 e M6 restano invariati; non esiste un guadagno LQI approvato a cui associarli.

## 22. Stato finale e limiti

- software, griglie, test DC e artifact di feasibility: validabili indipendentemente;
- sintesi controller M7: `FAIL` prestazionale, non errore numerico;
- performance M7: `FAIL`, 0/28 Stage A e 0/25 Stage B;
- stato milestone: `PARTIAL`;
- M5, saturazioni e anti-windup: invariati;
- M8: non iniziata.

Ogni ulteriore modifica della struttura del servo o dei target richiede una nuova decisione del gruppo.
