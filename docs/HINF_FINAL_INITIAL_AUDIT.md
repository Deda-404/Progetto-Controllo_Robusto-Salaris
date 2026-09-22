# Audit iniziale e derivazione del lower bound

Data: 18 settembre 2026. Base: main `693e316` (merge PR 31), commit tecnico
`b6155a4`. Prima delle modifiche la copia di lavoro era pulita. Il branch
di revisione è `codex/hinf-final-coherent-revision`.

## Stato osservato prima di modificare i file

- M3/M5 sono gli artifact fisici congelati. I nuovi pesi .003/2 rad/s
  appartengono alla directory `hinf_targeted_revision`, non a M5.
- Il Capitolo 8 contiene gamma .866 e il prefiltro con norma tracking 1.38148.
- `load_m12_a5_controller` carica ancora M11 storico, mentre M15 carica
  M10/M13 storici: la revisione precedente non costituisce una catena corrente.
- Il problema robusto esistente è 1-DoF 6x4 e suppone K 2x2. Non può ricevere
  silenziosamente un controllore 2x4. Serve una costruzione coerente esplicita.
- Il nuovo incarico supera lo STOP M12 della revisione precedente. M0–M8,
  parametri e incertezze restano congelati; i risultati negativi sono conservati.

## Derivazione MIMO

Fissata una frequenza, siano `X=KS`, `S=I-GX`, `a=|W1s|`, `b=|W2s|>0`.
Per ogni vettore unitario d'ingresso `v`, poniamo `x=Xv`. Allora

```
||[aS;bX]||_2² >= ||[aS;bX]v||²
               = a²||v-Gx||²+b²||x||²
               >= min_x (a²||v-Gx||²+b²||x||²).
```

Il minimo quadratico, senza vincoli su x, è raggiunto da
`x*=(a²G*G+b²I)^(-1)a²G*v`; l'asterisco su una matrice indica l'aggiunta.
Il costo minimo è `v* H v`, con

```
H = a²I - a⁴G(a²G*G+b²I)^(-1)G*.
```

Per `G=U diag(sigma_i) V*`, gli autovalori di H sono
`a²b²/(b²+a²sigma_i²)`. Il maggiore corrisponde a **sigma_min**, non a
sigma_max. La direzione scelta è il vettore singolare **sinistro** associato
al più piccolo valore singolare: v appartiene allo spazio delle uscite di G,
che coincide con quello del riferimento. Si ottiene

```
||[W1S;W2KS](jw)||_2 >= a b / sqrt(b²+a² sigma_min(G(jw))²).
```

Anzi, il rilassamento puntuale matriciale è esatto: scegliendo
`X*=(a²G*G+b²I)^(-1)a²G*` simultaneamente per tutte le colonne,
lo stack ha proprio questa norma. Non si afferma che X* definisca un
controllore causale, proprio o stabilizzante su tutte le frequenze.

## Ipotesi e verdetto

La pianta del progetto è quadrata 2x2; i pesi sono scalari replicati su due
canali. Non occorre invertire G, né supporne il rango pieno: b>0 rende la
matrice del costo definita positiva. Per sigma_min=0 il bound è a; vicino
alla singolarità converge ad a senza divisioni per sigma_min. Gli zeri di
W2 o pesi non scalari richiedono un'altra analisi e sono rifiutati dall'API.
Le risposte devono essere finite sulle frequenze valutate.

Il supremo continuo del termine destro è un lower bound della norma Hinf.
Il massimo su un insieme finito è minore o uguale a quel supremo: se supera
uno esclude il candidato, se è sotto uno non garantisce fattibilità.

**Verdetto analitico: la formula precedente e sigma_min sono corretti.**
Non si cambiano valori o filtro di selezione storici. Si aggiungono il
commento matematico, controlli delle ipotesi e sette test di proprietà.
La conclusione numerica viene registrata dopo l'esecuzione dei test, prima
di qualunque nuova sintesi.

Verifica eseguita: MATLAB R2025b, 7/7 test PASS. Gate lower bound chiuso prima delle nuove sintesi. Nessun ricalcolo della vecchia campagna richiesto: formula invariata.
