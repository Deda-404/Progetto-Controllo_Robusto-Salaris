# Modello delle incertezze

## Obiettivo

La pianta M4 rappresenta un unico insieme incerto lineare sul quale usare `ureal`, `usample`, LFT, analisi μ e sintesi robusta. Le percentuali sono intervalli di progetto: non sono tolleranze sperimentali né intervalli statistici.

## Scelta dei parametri meccanici

Sono mantenuti tre parametri indipendenti e fisicamente interpretabili:

| Parametro | Nominale | Intervallo | Motivazione |
| --- | ---: | ---: | --- |
| `k1` | 50 N m/rad | ±10% | rigidezza SEA equivalente: materiale e assemblaggio |
| `k2` | 40 N m/rad | ±10% | stessa natura fisica sul secondo giunto |
| `Jm1` | 0.01 kg m² | ±10% | inerzia riflessa di motore e trasmissione |

La costruzione è diretta:

```matlab
p = sea_params_nominal;
k1  = ureal('k1',  p.Ks(1,1), 'Percentage', 10);
k2  = ureal('k2',  p.Ks(2,2), 'Percentage', 10);
Jm1 = ureal('Jm1', p.Jm(1,1), 'Percentage', 10);
```

La stessa `ureal` è riutilizzata in ogni occorrenza delle equazioni. Gli altri parametri restano nominali per mantenere una struttura Δ piccola e leggibile; ciò non implica che siano fisicamente invarianti.

## Variabilità degli attuatori

| Parametro | Nominale | Intervallo | Motivazione |
| --- | ---: | ---: | --- |
| `wn` | 40 rad/s | ±10% | variazione di drive e carico |
| `zeta` | 0.8 | ±10% | taratura e condizioni operative |
| ritardo | 15 ms | ±20% | latenza e jitter |

La famiglia include nominale con ritardo esatto, sei variazioni singole, otto corner e 105 campioni riproducibili. L'errore moltiplicativo rispetto al nominale Padé è coperto da un peso `WI` di ordine uno scelto per la forma a singola transizione e identificato con `ucover`. L'ordine non è selezionato tramite una gara fra modelli: MATLAB verifica direttamente stabilità, properness e copertura della famiglia.

La convenzione è

\[
G_{a,i}=G_{a,0}(1+W_I\Delta_i),\qquad \|\Delta_i\|_\infty\le1,
\]

con `Delta_act1` e `Delta_act2` indipendenti.

## Verifica e interpretazione

`GuncMeas` è 4×2, `GuncQ` è 2×2 e la struttura contiene tre blocchi reali `ureal` e due blocchi dinamici `ultidyn`. Il nominale coincide con M3 entro `1e-8`. Quaranta campioni `usample` hanno dimensioni, coefficienti e risposte finite e rispettano gli intervalli dichiarati.

Questi controlli validano la costruzione del modello, non la robustezza di un controllore. Robust Stability e Robust Performance sono valutate successivamente con μ; la Monte Carlo M16 resta evidenza empirica e non una certificazione.
