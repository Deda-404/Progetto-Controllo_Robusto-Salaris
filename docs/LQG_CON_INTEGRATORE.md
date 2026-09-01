# Verifica LQI con azione integrale

## Obiettivo

Due integratori sulle posizioni articolari eliminano l'offset per riferimenti e coppie costanti compatibili. Lo stato augmentato è

\[
\dot\xi=r-C_qx,
\]

e il comando è `u=-Kx*x-Ki*xi+Nff*r`.

## Metodo didattico

Il costo sui 14 stati fisici riusa esattamente `Q` di M6. La scala dell'integratore è `referenceAmplitude*settlingTimeTarget`. Si confrontano soltanto tre punti espliciti:

| Tuning | `wi` | `rhoU` | Interpretazione |
| --- | ---: | ---: | --- |
| weakIntegral | 0.1 | 16 | integratore debole, comando penalizzato |
| balanced | 1 | 8 | compromesso |
| strongIntegral | 4 | 4 | integratore più forte, comando meno penalizzato |

Non è eseguito alcun prodotto cartesiano, ranking o co-tuning automatico.

## Risultato

Tutti e tre i sistemi augmentati sono stabilizzabili, stabili in anello chiuso e annullano l'offset da coppia costante entro `1e-4` rad. Tuttavia nessuno soddisfa simultaneamente settling ≤0.8 s e overshoot ≤10%: `weakIntegral` non si assesta entro 3 s; `balanced` ha settling 2.924 s e overshoot 20.4%; `strongIntegral` 1.88 s e 28.8%.

Il risultato negativo viene conservato come informazione progettuale. Lo stato M7 è `PARTIAL`, non viene pubblicato un controllore LQI finale e M6 resta il riferimento nominale.
