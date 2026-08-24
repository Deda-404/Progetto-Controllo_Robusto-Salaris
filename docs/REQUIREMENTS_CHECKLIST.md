# Requirements checklist

La checklist deriva dalla traccia ufficiale. Un requisito tecnico resta non completato finché non è supportato da codice eseguito, test e risultati tracciabili.

## M0 — Fonti e ambiente

- [x] Traccia ufficiale letta integralmente.
- [x] Relazione del progetto precedente letta integralmente.
- [x] Google Drive consultato realmente in sola lettura.
- [x] Progetto CR precedente e sorgenti principali individuati.
- [x] Repository ufficiale verificato e remote `origin` corretto.
- [x] MATLAB e Simulink verificati mediante esecuzione batch.
- [x] Control System Toolbox verificato.
- [x] Robust Control Toolbox verificato.
- [x] Symbolic Math Toolbox verificato.
- [x] Struttura iniziale e documentazione di governo create.
- [x] Revisione e approvazione M0 da parte del gruppo.

## Modello e linearizzazione

- [x] Implementare fedelmente \(M(q)\), \(C(q,\dot q)\), \(G(q)\) e le dinamiche SEA.
- [x] Definire lo stato e verificare dimensioni e unità.
- [x] Testare simmetria e definita positività di \(M(q)\).
- [x] Testare assenza di `NaN`/`Inf` sui casi deterministici documentati per M1.
- [x] Scegliere e approvare il punto di equilibrio.
- [x] Calcolare \(\bar q,\bar\theta,\bar\tau,\bar x\).
- [x] Verificare numericamente \(f(\bar x,\bar\tau)=0\).
- [x] Calcolare Jacobiani e modello incrementale \((A,B,C,D)\).
- [x] Confrontare Jacobiani analitici/simbolici con differenze finite.
- [x] Analizzare poli e stabilità in anello aperto.
- [x] Verificare controllabilità e stabilizzabilità con SVD/PBH.
- [x] Scegliere le misure e verificare osservabilità e rilevabilità con SVD/PBH.
- [x] Confrontare modello lineare e non lineare per piccole perturbazioni.

## Attuatori e incertezze

- [ ] Scegliere e motivare \(\omega_n\), \(\zeta\), \(\tau_d\).
- [ ] Implementare secondo ordine e Padé del primo ordine.
- [ ] Validare poli, guadagno statico e risposta degli attuatori.
- [ ] Distinguere parametri certi, incerti e incertezza dinamica.
- [ ] Approvare parametri incerti e percentuali.
- [ ] Motivare fisicamente ogni incertezza.
- [ ] Costruire e testare la pianta incerta.
- [ ] Se usato, verificare che \(W_I\) copra i campioni dell'attuatore.
- [ ] Verificare numero, tipo, dimensione e occorrenze dei blocchi incerti.

## Specifiche

- [ ] Definire regolazione/tracking e variabili controllate.
- [ ] Definire modello fisico e punto di applicazione dei disturbi.
- [ ] Definire errore statico ammesso.
- [ ] Definire banda o rapidità desiderata.
- [ ] Definire attenuazione dei disturbi e rumore.
- [ ] Definire limiti di coppia e saturazioni reali.
- [ ] Definire margini di robustezza desiderati.
- [ ] Tradurre le specifiche in pesi dimensionalmente coerenti.

## LQG

- [ ] Sintetizzare LQG senza integratore.
- [ ] Sintetizzare LQG con integratore sulle uscite approvate.
- [ ] Motivare e registrare \(Q\) e \(R\).
- [ ] Motivare e registrare covarianze di processo e misura.
- [ ] Verificare principio di separazione e poli dell'anello chiuso.
- [ ] Validare stima dello stato, rumore e condizioni iniziali.
- [ ] Confrontare errore a regime con disturbo costante.
- [ ] Confrontare sforzo di controllo con e senza integratore.
- [ ] Implementare entrambe le versioni in Simulink.
- [ ] Validare entrambe sul modello linearizzato.
- [ ] Validare entrambe sul modello non lineare.
- [ ] Stimare e documentare la RAS empirica di entrambe.

## Controllo \(H_\infty\)

- [ ] Definire impianto generalizzato e segnali \(w,z,y,u\).
- [ ] Approvare e registrare \(W_1,W_2\) ed eventuali altri pesi.
- [ ] Eseguire `mixsyn` e validarne l'interconnessione.
- [ ] Eseguire `hinfsyn` e validarne l'interconnessione.
- [ ] Confrontare `mixsyn` e `hinfsyn` con le stesse specifiche.
- [ ] Esplorare `hinfstruct` con struttura e ordine motivati.
- [ ] Valutare \(\gamma\), \(S\), \(T\), \(KS\), tracking, disturbi e comando.
- [ ] Implementare i controllori selezionati in Simulink.
- [ ] Validare modello lineare e non lineare.
- [ ] Stimare e documentare la RAS empirica.

## \(\mu\)-analysis

- [ ] Costruire e testare la struttura \(N\)-\(\Delta\).
- [ ] Verificare Nominal Stability.
- [ ] Verificare Nominal Performance.
- [ ] Verificare Robust Stability.
- [ ] Verificare Robust Performance.
- [ ] Confrontare `mussv` con `robstab` e `robgain` su scaling coerente.
- [ ] Identificare frequenze, blocchi e direzioni critiche.
- [ ] Conservare lower/upper bound e dichiarare eventuali esiti inconclusivi.

## \(\mu\)-synthesis

- [ ] Eseguire D–K iteration su pianta e specifiche approvate.
- [ ] Conservare e analizzare lo storico delle iterazioni.
- [ ] Verificare ordine e stabilità interna del controllore.
- [ ] Ripetere NS, NP, RS e RP a posteriori.
- [ ] Diagnosticare eventuali specifiche irrealizzabili.
- [ ] Ottenere approvazione prima di rilassamenti sostanziali.
- [ ] Registrare ogni rilassamento nel Decision Log.
- [ ] Se si riduce l'ordine, ripetere tutte le verifiche sul controllore ridotto.

## Validazione e confronto

- [ ] Validare \(H_\infty\) e \(\mu\)-synthesis sul modello non lineare.
- [ ] Definire criteri automatici e riproducibili per la RAS.
- [ ] Esplorare un dominio e un insieme di stati iniziali documentati.
- [ ] Impostare un seed Monte Carlo esplicito.
- [ ] Campionare indicativamente almeno 10 impianti incerti.
- [ ] Confrontare stabilità, tempo di assestamento, banda ed errore.
- [ ] Confrontare disturbi, comando e cross-coupling.
- [ ] Distinguere evidenza Monte Carlo e garanzia \(\mu\).
- [ ] Confrontare LQG, \(H_\infty\) e \(\mu\)-synthesis.
- [ ] Confrontare formalmente \(H_\infty\) e D–K in RS, RP e margini.

## Deliverable finali

- [ ] `run_all.m` rigenera deterministicamente tutti i risultati finali.
- [ ] Parametri e specifiche hanno un'unica sorgente.
- [ ] Test automatici completi e tutti gli esiti documentati.
- [ ] Dati, figure e tabelle generati automaticamente.
- [ ] Relazione dettagliata sincronizzata col codice.
- [ ] Controllori finali salvati e identificati senza ambiguità.
- [ ] Codice MATLAB e modelli Simulink consegnabili.
- [ ] Presentazione basata sulla relazione e contenuta in 20 minuti.
