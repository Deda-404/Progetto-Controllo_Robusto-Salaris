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

- [x] Scegliere e motivare \(\omega_n\), \(\zeta\), \(\tau_d\).
- [x] Implementare secondo ordine e Padé del primo ordine.
- [x] Validare poli, guadagno statico e risposta degli attuatori.
- [x] Distinguere parametri certi, incerti e incertezza dinamica.
- [x] Approvare parametri incerti e percentuali per il baseline M4.
- [x] Motivare fisicamente ogni incertezza e dichiararla assunzione progettuale.
- [x] Costruire e testare `GuncMeas` e `GuncQ` nominalmente coerenti con M3.
- [x] Verificare che \(W_I\) copra 120 modelli attuatore, inclusi tutti i corner.
- [x] Verificare con `lftdata` numero, tipo, dimensione e occorrenze dei cinque blocchi incerti.

## Specifiche

- [x] Definire regolazione/tracking e variabili controllate.
- [x] Definire modello fisico e punto di applicazione dei disturbi.
- [x] Definire errore statico ammesso.
- [x] Definire banda o rapidità desiderata.
- [ ] Definire attenuazione dei disturbi e rumore.
- [ ] Definire limiti di coppia e saturazioni reali.
- [x] Definire il linguaggio e i criteri futuri dei margini di robustezza.
- [x] Tradurre le specifiche in pesi dimensionalmente coerenti.

M5 definisce la forte attenuazione dei disturbi costanti/bassa frequenza, ma la voce combinata disturbi/rumore resta aperta fino alla caratterizzazione dei canali di rumore. `uScale=12 N m` è una scala prestazionale, non una saturazione reale certificata; anche la relativa voce resta aperta.

## LQG

- [x] Sintetizzare LQG senza integratore.
- [ ] Sintetizzare LQG con integratore sulle uscite approvate.
- [x] Motivare e registrare \(Q\) e \(R\).
- [x] Motivare e registrare covarianze di processo e misura.
- [x] Verificare principio di separazione e poli dell'anello chiuso.
- [x] Validare stima dello stato, rumore e condizioni iniziali per M6.
- [x] Confrontare errore a regime con disturbo costante.
- [ ] Confrontare sforzo di controllo con e senza integratore.
- [ ] Implementare entrambe le versioni in Simulink.
- [x] Validare la versione senza integratore sul modello linearizzato.
- [x] Validare M6 senza integratore sul modello non lineare.
- [x] Stimare e documentare la RAS empirica M6 su due sezioni.

M7 resta correttamente `PARTIAL`: nessun controllore integrale finale è stato
pubblicato. M8 ha validato nel modello Simulink non lineare il solo LQG M6,
inclusi equilibrio, tracking 2/5/8°, disturbi, rumore, confronto LTI/NL e RAS
empirica. I25 resta un representative integral benchmark lineare e non entra
nel gate M8; pertanto le voci che richiedono *entrambe* le versioni rimangono
aperte senza occultare il risultato terminale M7.

## Controllo \(H_\infty\)

- [ ] Definire impianto generalizzato e segnali \(w,z,y,u\).
- [x] Approvare e registrare \(W_1,W_2\) ed eventuali altri pesi.
- [x] Eseguire `mixsyn` e validarne l'interconnessione.
- [ ] Eseguire `hinfsyn` e validarne l'interconnessione.
- [ ] Confrontare `mixsyn` e `hinfsyn` con le stesse specifiche.
- [ ] Esplorare `hinfstruct` con struttura e ordine motivati.
- [x] Valutare \(\gamma\), \(S\), \(T\), \(KS\), tracking, disturbi e comando.
- [ ] Implementare i controllori selezionati in Simulink.
- [ ] Validare modello lineare e non lineare.
- [ ] Stimare e documentare la RAS empirica.

M9 ha completato la baseline nominale 1-DoF con W1/W2 M5 congelati e
`W3=[]`. La stabilità interna e la ricostruzione indipendente sono `PASS`, ma
`gamma=10.2071036477`, tracking e cross-coupling falliscono i rispettivi
target: M9 resta quindi `PARTIAL`, senza retuning. La voce sull'impianto
generalizzato esplicito resta aperta per M10 `hinfsyn`; non sono state
eseguite analisi robuste.

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
- [x] Definire criteri automatici e riproducibili per la RAS LQG M6.
- [x] Esplorare due sezioni e un dominio di stati iniziali documentati per M6.
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
