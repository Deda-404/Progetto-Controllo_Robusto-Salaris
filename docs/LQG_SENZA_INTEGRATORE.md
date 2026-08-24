# LQG nominale senza integratore — M6

## Stato e percorso della milestone

M6 è `COMPLETE` per la sintesi e validazione LTI nominale. Il primo tentativo, basato sulle sole priorità unitarie e sulla variazione di (\rho_U), rimane registrato: i cinque candidati (\rho_U=[0.5,1,2,4,8]) erano stabilizzanti ma mostravano worst settling 1.222–1.232 s, oltre il target M5 di 0.8 s. Anche la diagnostica fino a (\rho_U=0.001) raggiungeva soltanto 1.2125 s. Il gruppo ha quindi autorizzato esclusivamente il retuning dei coefficienti adimensionali del costo, lasciando invariati target e scale fisiche M5.

## 1. Modello usato

La sintesi usa la pianta nominale M3 completa: 14 stati, due ingressi di comando prima degli attuatori e quattro misure encoder ([q_1,q_2,\theta_1,\theta_2]^T). Gli stati comprendono gli otto stati meccanici e i sei stati della dinamica attuativa con Padé nominale. Le coordinate sono incrementali rispetto all'equilibrio D-0003; nessuna velocità è misurata direttamente.

## 2. Normalizzazione e diagnosi baseline

Le scale, mai modificate durante il retuning, sono:

| Variabile | Scala | Valore | Peso quadratico baseline (1/scala^2) |
| --- | --- | ---: | ---: |
| (q) | (q_s=5°) | 0.0872665 rad | 131.312 |
| (\dot q) | (\dot q_s=\omega_Bq_s) | 1.04720 rad/s | 0.911891 |
| (\theta-q) | (\delta_s=d_{nom}/\min(k_1,k_2)) | 0.0125 rad | 6400 |
| (\dot\theta) | (\dot\theta_s=\omega_Bq_s) | 1.04720 rad/s | 0.911891 |

Con priorità unitarie, il peso posizione/deformazione era 0.02052: la deformazione risultava quindi pesata circa 48.7 volte più della posizione. La matrice (Q) baseline aveva rango 8, otto autovalori nulli e condition number sui soli autovalori non nulli pari a 14109.1.

Per (\rho_U=0.5), il modo dominante era (-4.38277\pm1.16189j). Le partecipazioni aggregate del modo erano 39.84% in (q), 47.49% in (\dot q), 8.07% in (\theta), 1.55% in (\dot\theta) e 3.04% negli stati attuatore. La coppia compare inoltre fra i maggiori residui del canale (r_1\rightarrow q_1), collegandola quantitativamente al settling lento.

## 3. Costo LQR e retuning strutturato

La normalizzazione fisica è mantenuta e vengono introdotte soltanto priorità adimensionali:

\[
z_x=\begin{bmatrix}
\sqrt{w_q}\,q/q_s\\
\sqrt{w_{\dot q}}\,\dot q/\dot q_s\\
\sqrt{w_\delta}\,(\theta-q)/\delta_s\\
\sqrt{w_{\dot\theta}}\,\dot\theta/\dot\theta_s
\end{bmatrix},\qquad Q=C_{cost}^TC_{cost}.
\]

I sei stati interni degli attuatori non ricevono pesi diretti dipendenti dalla realizzazione. La coarse grid combina (w_q=[1,2,4,8]), (w_\delta=[0.1,0.25,0.5,1]), (w_{velocity}=[0.5,1,2]) e (\rho_U=[0.5,1,2,4,8]) per 240 sintesi reali. Sono risultati ammissibili 139 candidati; la extended grid non è stata eseguita.

## 4. Selezione LQR

Il ranking scarta instabilità e violazioni fondamentali, quindi minimizza nell'ordine picco comando normalizzato, deformazione normalizzata e norma di (K), preferendo infine il maggiore (\rho_U). Il candidato selezionato è C193:

| Parametro/metrica | Valore |
| --- | ---: |
| (w_q,w_{\dot q},w_\delta,w_{\dot\theta}) | 1, 0.5, 0.1, 0.5 |
| (\rho_U) | 8 |
| worst settling | 0.776 s |
| worst overshoot | 0.26545% |
| errore statico relativo | (5.25\times10^{-15}) |
| worst cross-coupling | 17.391% |
| peak control | 4.6897 N m = 0.3908 (u_{scale}) |
| peak deformazione giunti | 0.023646 / 0.011557 rad |
| peak deformazione normalizzata | 1.8917 |
| peak coppia elastica giunti | 1.1823 / 0.4623 N m |
| (\|K\|_F) | 432.87 |

Il comando è moderato rispetto alla scala prestazionale, che non viene interpretata come saturazione. La deformazione supera localmente (\delta_s), ma resta una metrica diagnostica priva di limite hardware certificato.

Il miglior cross-coupling fra i candidati fondamentali appartiene a C034 (14.12%), ma richiede 25.09 N m, cioè 2.091 volte (u_{scale}), e una norma di guadagno 3221.2. Non viene selezionato perché il ranking privilegia il progetto meno aggressivo compatibile con i target.

La verifica obbligatoria sul ruolo di (w_\delta), a (w_q=1), (w_{velocity}=0.5) e (\rho_U=8), mostra:

| (w_\delta) | settling [s] | parte reale dominante | peak (u/u_s) | peak (\delta/\delta_s) |
| ---: | ---: | ---: | ---: | ---: |
| 1.00 | 1.220 | -4.3377 | 0.5939 | 1.3653 |
| 0.50 | 1.092 | -4.5381 | 0.4926 | 1.4778 |
| 0.25 | 0.948 | -4.8570 | 0.4321 | 1.6361 |
| 0.10 | 0.776 | -5.5051 | 0.3908 | 1.8917 |

I dati confermano che il costo Bryson-like iniziale sovrapenalizzava la variabile interna (\theta-q) rispetto all'obiettivo di tracking. Ridurre la sola priorità adimensionale sposta il modo lento e rende raggiungibile il target, senza modificare M5.

## 5. Prefiltro

Il precompensatore è ottenuto dalla soluzione lineare (G_{dc}N_r=I_2), senza `inv`:

\[
N_r=\begin{bmatrix}
53.73943 & -0.79651\\
4.30445 & 49.39156
\end{bmatrix}.
\]

Il condition number di (G_{dc}) è 1.1144 e il residuo di inversione è (1.39\times10^{-17}). Il precompensatore migliora il tracking nominale ma non è un internal model: disturbi persistenti e mismatch possono produrre offset.

## 6. Modello di rumore

Il rumore di processo entra tramite (G_w=[B_d\ B]), con due perturbazioni di coppia lato link e due perturbazioni equivalenti del comando. Il rumore di misura agisce sui quattro encoder. Le covarianze derivano da standard deviation fisiche, non da matrici epsilon arbitrarie.

## 7. Covarianze candidate

Sono valutate tutte le 27 combinazioni di (\sigma_D=[0.025,0.05,0.10]) N m, (\sigma_U=[0.10,0.25,0.50]) N m e (\sigma_Y=[0.05,0.10,0.25])°. Per ogni combinazione:

\[
Q_n=\operatorname{diag}(\sigma_D^2,\sigma_D^2,\sigma_U^2,\sigma_U^2),
\quad R_n=\sigma_{Y,rad}^2I_4.
\]

## 8. Selezione Kalman

Tre candidati rispettano (1.5\leq\alpha_e/\alpha_c\leq5). Il ranking minimizza la norma (H_2) continua da rumore di misura alle variabili normalizzate dell'errore e poi (\|L\|_F). È selezionato KF03:

| Grandezza | Valore |
| --- | ---: |
| (\sigma_D) | 0.10 N m |
| (\sigma_U) | 0.10 N m |
| (\sigma_Y) | 0.05° = 0.000872665 rad |
| decay regolatore / stimatore | 5.5051 / 9.3187 s⁻¹ |
| ratio stimatore/regolatore | 1.6928 |
| (\|L\|_F) | 7040.6 |
| metrica (H_2) | 539.32 |

## 9. Controllore e principio di separazione

Il controllore dinamico realizza

\[
\dot{\hat x}=(A-BK-LC)\hat x+BN_rr+Ly,
\qquad u=-K\hat x+N_rr.
\]

Ha 14 stati, ingressi ([r_1,r_2,q_1,q_2,\theta_1,\theta_2]) e uscite ([u_1,u_2]), senza stati integrali. Il sistema augmentato ([x;\hat x]) ha 28 poli. La distanza massima fra i poli combined e l'unione dei poli regolatore/stimatore è (2.43\times10^{-6}), entro la tolleranza (10^{-4}).

## 10. Tracking nominale

| Step | settling LQG | overshoot | errore statico relativo | cross-coupling | peak control |
| --- | ---: | ---: | ---: | ---: | ---: |
| (r_1=5°) | 0.776 s | 0.26545% | (1.62\times10^{-14}) | 17.264% | 4.6897 N m |
| (r_2=5°) | 0.514 s | 0.02517% | (7.79\times10^{-15}) | 17.391% | 4.3102 N m |

Con condizioni iniziali coerenti (x(0)=\hat x(0)=0) e senza rumore, full-state LQR e LQG coincidono entro (3.69\times10^{-15}) rad sulle posizioni e (1.08\times10^{-13}) N m sul comando. Questo non implica equivalenza in presenza di disturbo non modellato o errore iniziale di stima.

## 11. Disturbo costante

| Step | peak q sul giunto eccitato | offset statico | settling | cross-coupling | peak control |
| --- | ---: | ---: | ---: | ---: | ---: |
| (d_1=0.5) N m | 0.07979 rad | 0.07959 rad | 0.752 s | 46.35% | 1.2995 N m |
| (d_2=0.5) N m | 0.16025 rad | 0.16023 rad | 0.444 s | 22.89% | 1.1526 N m |

Gli offset non nulli sono attesi: il controllore non contiene un internal model del disturbo costante. I risultati sono conservati come benchmark per M7. Il cross-coupling di disturbo non è il target preliminare definito per il tracking e viene riportato senza occultarlo.

## 12. Rumore riproducibile

La simulazione con `rng(20260826,'twister')` e rumore encoder coerente con (\sigma_Y) selezionato restituisce:

- RMS tracking complessivo: 0.0150231 rad;
- RMS errore di stima su (q): 0.000233771 rad;
- RMS variazione del comando rispetto al caso deterministico: 0.0802548 N m.

Un secondo rilancio con lo stesso seed coincide campione per campione. La simulazione è diagnostica e non sostituisce la metrica stocastica continua (H_2).

## 13. Limiti

- La validazione è LTI nominale e locale all'equilibrio M2.
- Non sono stati applicati saturazioni, rate limits o limiti di deformazione certificati.
- La norma di (L) è elevata in coordinate di stato non normalizzate; il ranking usa anche la metrica fisica (H_2).
- Il disturbo costante produce offset e può generare interazione MIMO significativa.
- Non sono eseguite sintesi su M4, analisi robusta, simulazioni non lineari, Simulink o RAS.

## 14. Aspettative per M7

M7 non è stata iniziata. La futura azione integrale dovrà essere confrontata con questa baseline preservando rapidità, comando, rumore e interazione MIMO, e dovrà dimostrare la riduzione dell'offset costante senza assumere saturazioni hardware non disponibili.

## Artifact riproducibili

- `results/data/m6_lqg_no_integrator.mat`;
- `results/figures/m6_lqr_cost_tuning.png`;
- `results/figures/m6_lqr_delta_weight_effect.png`;
- `results/figures/m6_lqr_candidate_comparison.png`;
- `results/figures/m6_lqg_reference_tracking.png`;
- `results/figures/m6_lqg_disturbance_response.png`;
- `results/figures/m6_lqg_estimation.png`;
- `results/figures/m6_lqg_poles.png`.
