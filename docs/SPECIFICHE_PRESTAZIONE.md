# Specifiche e pesi di prestazione

## Obiettivo e scale dinamiche

Le specifiche traducono il problema fisico in target per LQG e mixed sensitivity. Dai risultati nominali si ottengono: polo instabile dominante 7.209 rad/s, prima risonanza elastica 69.95 rad/s e banda attuatore 34.78 rad/s. Il target

\[
\omega_B=12\ \mathrm{rad/s}
\]

è sopra la scala instabile e sotto i limiti attuativi ed elastici. MATLAB verifica la finestra 10.81–13.91 rad/s; non genera candidati.

## Specifiche finali

| Grandezza | Valore | Significato |
| --- | ---: | --- |
| riferimento nominale | 5° | piccola variazione attorno all'equilibrio |
| disturbo ai link | 0.5 N m | coppia esterna di verifica |
| `omegaB` | 12 rad/s | banda desiderata |
| `As` | 0.05 | target di sensitivity a bassa frequenza |
| `Ms` | 2 | picco di sensitivity ammesso |
| `uScale` | 12 N m | scala di prestazione, non saturazione certificata |
| `omegaU` | 30 rad/s | inizio della maggiore penalizzazione del comando |
| `alpha` | 6 | incremento della penalizzazione in alta frequenza |
| settling | ≤0.8 s | target nominale |
| overshoot | ≤10% | target nominale |

## Peso W1

\[
W_1(s)=\frac{s/M_s+\omega_B}{s+\omega_BA_s}.
\]

A bassa frequenza

\[
W_1(0)=\frac{1}{A_s}=20.
\]

La condizione `||W1 S||∞<1` chiede quindi una sensitivity dell'ordine di `As=0.05` vicino a zero. Ad alta frequenza

\[
W_1(\infty)=\frac{1}{M_s}=0.5,
\]

per cui il vincolo permette un picco di sensitivity circa pari a `Ms=2`. `omegaB` colloca la transizione tra i due comportamenti.

## Peso W2

\[
W_2(s)=\frac{1}{u_{scale}}
\frac{s/\omega_U+1}{s/(\alpha\omega_U)+1}.
\]

`W2` penalizza il segnale di comando. A bassa frequenza vale `1/uScale=1/12`; verso l'alta frequenza tende a `alpha/uScale=0.5`. La penalizzazione cresce di un fattore sei attorno a 30 rad/s, prima dei modi elastici, per evitare che il controllore insegua dinamiche rapide e poco affidabili.

## Implementazione e verifica

`build_m5_weights.m` costruisce due copie diagonali dei pesi SISO. I test verificano stabilità, properness, ordine, asintoti e dimensioni 2×2. La matrice del disturbo è ricavata dalle equazioni non lineari ed è confrontata con una differenza finita. M5 non sintetizza alcun controllore e non introduce `W3`.
