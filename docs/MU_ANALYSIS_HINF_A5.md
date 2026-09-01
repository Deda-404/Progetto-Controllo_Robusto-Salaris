# M12 — μ-analysis del controllore strutturato A5

**Stato:** `PARTIAL` — software corretto; NS `PASS`, NP `FAIL`, RS e RP `FAIL_CERTIFIED`.

## Perimetro

M12 analizza il controllore A5 di M11, ordine 6, senza eseguire una nuova sintesi. La pianta incerta è l'unico insieme M4 corrente; i pesi sono esattamente W1 e W2 di M5 e `W3=[]`.

| Blocco | Tipo | Nominale | Intervallo / bound |
| --- | --- | ---: | ---: |
| `Delta_act1` | `ultidyn` | — | norma H∞ ≤ 1 |
| `Delta_act2` | `ultidyn` | — | norma H∞ ≤ 1 |
| `Jm1` | `ureal` | 0.01 kg m² | ±10% |
| `k1` | `ureal` | 50 N m/rad | ±10% |
| `k2` | `ureal` | 40 N m/rad | ±10% |

I blocchi dinamici degli attuatori sono indipendenti e usano il peso moltiplicativo WI verificato in M4. I tre parametri reali sono normalizzati in `[-1,1]`. La costruzione di Punc usa una sola istanza condivisa della pianta incerta.

## Decomposizione N–Δ

La generalized plant è 6×4 e la chiusura pesata 4×2. `lftdata` restituisce cinque blocchi scalari, una matrice M 9×7 e una Δ 5×5. La ricostruzione nominale e una sostituzione perturbata superano le tolleranze; non sono usati `minreal` o `simplify` nei gate.

## Esiti NS, NP, RS e RP

| Proprietà | Metrica | Esito |
| --- | --- | --- |
| NS | max Re poli = -0.736157095561 1/s | `PASS` |
| NP | norma pesata = 10.2476411502 a 6.21670809748 rad/s | `FAIL` |
| RS | margine [0.849720221286, 0.859945221298] a 82.8412691446 rad/s | `FAIL_CERTIFIED` |
| RP | performance margin [0,0] | `FAIL_CERTIFIED` |

La verifica μ manuale sulla griglia `logspace(-3,4,1201)` fornisce massimi lower/upper 1.16029137701 e 1.17386307189; i corrispondenti margini approssimati sono 0.851888115360 e 0.861852479309. La classificazione è coerente con `robstab`.

`wcgain` restituisce `[Inf,Inf]`: l'insieme contiene una perturbazione che porta la chiusura al limite di stabilità. Questo non è un errore software e non cambia la precedenza logica: il nominale appartiene all'insieme, quindi NP fallita implica RP non certificabile come positiva.

## Interpretazione

A5 è nominalmente stabile ma non robustamente stabile sull'M4 corrente. M12 resta un'analisi formale distinta da Monte Carlo e non autorizza retuning, nuovi pesi o una nuova sintesi.

Artifact: `results/data/m12_mu_analysis_a5.mat`.
