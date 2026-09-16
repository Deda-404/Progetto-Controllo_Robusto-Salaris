# M14 corrente: esito robusto negativo

Revisione 2026-09-16. Il Kmu corrente coincide esattamente con la best iteration 5 della nuova M13, ordine 70, senza riduzione. NS PASS; NP FAIL con norma 6.34971025763. RS FAIL_CERTIFIED, margine [0.774041952377,0.775696806012]; RP FAIL_CERTIFIED. Il vecchio certificato non è trasferibile al nuovo controllore.

wcgain restituisce [12.0757289608, Inf], mentre usubs produce guadagno 12.0761806812 e una chiusura stabile. L'upper bound infinito non implica che la perturbazione associata al lower bound finito sia destabilizzante. Il controllo è stato corretto senza cambiare tolleranze o criteri RS/RP. Fonte primaria: https://www.mathworks.com/help/robust/ref/dynamicsystem.wcgain.html

I paragrafi seguenti sono evidenza storica, precedente alla revisione, e non descrivono il controllore corrente.

## Evidenza storica precedente alla revisione diretta
# M14 — μ-analysis finale del Kmu congelato

**Stato:** `PARTIAL` — software corretto e RS certificata; NP e RP non conformi.

## Perimetro

Kmu è caricato senza modifiche dall'artefatto M13: è 2×2, ordine 52 e coincide con la best iteration 3 della singola campagna D–K approvata. M14 non esegue `musyn`, riduzione d'ordine o retuning. Il controllore congelato viene rivalutato sull'unico insieme M4 corrente e sugli stessi pesi M5.

La generalized plant ricostruita coincide con quella M12 corrente per dimensioni, nomi, nominale e struttura N–Δ. Il fatto che i range M4 correnti siano più semplici e uniformi di quelli usati durante la sintesi storica non modifica Kmu: modifica soltanto il dominio della post-analisi.

## Ricostruzione nominale

Il loop fisico completo, senza cancellazioni, ha 66 poli interni. La massima parte reale è -0.731994726169 1/s. La norma di `[W1 S; W2 Kmu S]` è 10.3917314574 con picco a 93.1402569484 rad/s.

## Esiti NS, NP, RS e RP

| Proprietà | Metrica | Esito |
| --- | --- | --- |
| NS | max Re poli = -0.731994726169 1/s | `PASS` |
| NP | norma pesata = 10.3917314574 | `FAIL` |
| RS | margine [1.06956057969, 1.21287515623] a 17.1668321112 rad/s | `PASS_CERTIFIED` |
| RP | performance margin [0,0] | `FAIL_CERTIFIED` |

La μ manuale restituisce massimo lower 0.824868445936 e massimo upper 0.916687174501; i margini approssimati sono 1.09088468544 e 1.21231452716. La diversa frequenza dei due picchi rende questa verifica diagnostica, mentre la certificazione riportata è quella di `robstab`.

Il worst-case weighted gain a livello d'incertezza unitario è compreso fra 28.5943581286 e 33.6645442638; la sostituzione reale fornisce 28.5945536079. Questi valori non sono equivalenti all'objective `musyn`.

## Confronto A5–Kmu sull'M4 corrente

| Metrica | A5 M12 | Kmu M14 |
| --- | ---: | ---: |
| ordine | 6 | 52 |
| norma nominale pesata | 10.2476411502 | 10.3917314574 |
| RS lower | 0.849720221286 | 1.06956057969 |
| RS upper | 0.859945221298 | 1.21287515623 |
| RS | `FAIL_CERTIFIED` | `PASS_CERTIFIED` |
| RP | `FAIL_CERTIFIED` | `FAIL_CERTIFIED` |

Il recupero RS è `CLEAR_IMPROVEMENT`, ma non implica Nominal Performance, Robust Performance o buon tracking. Kmu resta quindi il controllore robusto finale per ruolo, non un controllore globalmente conforme.

Artifact: `results/data/m14_final_mu_analysis_kmu.mat`.
