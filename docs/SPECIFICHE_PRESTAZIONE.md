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
| `omegaW1` | 8 rad/s | transizione del peso W1, distinta da omegaB |
| `As` | 0.15 | target di sensitivity a bassa frequenza |
| `Ms` | 2.5 | picco di sensitivity ammesso |
| `uScale` | 12 N m | scala di prestazione, non saturazione certificata |
| `ku` | 0.05 | guadagno diretto di W2 sul comando fisico |
| `omegaU` | 60 rad/s | inizio della maggiore penalizzazione del comando |
| `alpha` | 6 | incremento della penalizzazione in alta frequenza |
| settling | ≤0.8 s | target nominale |
| overshoot | ≤10% | target nominale |

## Peso W1

\[
W_1(s)=\frac{s/M_s+\omega_{W1}}{s+\omega_{W1}A_s}.
\]

A bassa frequenza

\[
W_1(0)=\frac{1}{A_s}=6.\overline{6}.
\]

La condizione `||W1 S||∞<1` chiede quindi una sensitivity dell'ordine di `As=0.15` vicino a zero. Ad alta frequenza

\[
W_1(\infty)=\frac{1}{M_s}=0.4,
\]

per cui il vincolo permette un picco di sensitivity circa pari a `Ms=2.5`. `omegaW1` colloca la transizione tra i due comportamenti.

## Peso W2

\[
W_2(s)=k_u
\frac{s/\omega_U+1}{s/(\alpha\omega_U)+1}.
\]

`W2` penalizza direttamente il comando fisico: DC=0.05, HF=0.30, zero a 60 rad/s e polo a 360 rad/s. La griglia limitata ha selezionato questi valori come compromesso non conforme. I target temporali, omegaB=12 e uScale=12 restano invariati; non sono introdotte saturazioni o riscalature della pianta.

## Implementazione e verifica

`build_m5_weights.m` costruisce due copie diagonali dei pesi SISO. I test verificano stabilità, properness, ordine, asintoti e dimensioni 2×2. La matrice del disturbo è ricavata dalle equazioni non lineari ed è confrontata con una differenza finita. M5 non sintetizza alcun controllore e non introduce `W3`.

## Revisione diretta 2026-09-16

Stage A: otto W1; Stage B: quattro configurazioni dei due migliori W1 con W2 rivisto. Nessun PASS. Il terzo peso rimane fisso nel solo studio aggiuntivo; la produzione M9–M14 usa due pesi. Tracciabilità completa in `RESOCONTO_REVISIONE_PESI_HINF_LQR_LQRI.txt`.
