# LQG nominale con azione integrale — checkpoint M7

## Stato della milestone

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
