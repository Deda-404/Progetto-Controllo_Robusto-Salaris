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

- [x] Definire impianto generalizzato e segnali \(w,z,y,u\).
- [x] Approvare e registrare \(W_1,W_2\) ed eventuali altri pesi.
- [x] Eseguire `mixsyn` e validarne l'interconnessione.
- [x] Eseguire `hinfsyn` e validarne l'interconnessione.
- [x] Confrontare `mixsyn` e `hinfsyn` con le stesse specifiche.
- [x] Esplorare `hinfstruct` con struttura e ordine motivati.
- [x] Valutare \(\gamma\), \(S\), \(T\), \(KS\), tracking, disturbi e comando.
- [x] Implementare i controllori selezionati in Simulink.
- [x] Validare modello lineare e non lineare.
- [x] Stimare e documentare la RAS empirica.

M9 ha completato la baseline nominale 1-DoF con W1/W2 M5 congelati e
`W3=[]`. La stabilità interna e la ricostruzione indipendente sono `PASS`, ma
`gamma=10.2071036477`, tracking e cross-coupling falliscono i rispettivi
target: M9 resta quindi `PARTIAL`, senza retuning. M10 ha definito e validato
la pianta generalizzata nominale esplicita 1-DoF, eseguito una sintesi
`hinfsyn` di default e confrontato a parità di problema le mappe M9/M10. Il
risultato è quasi equivalente a M9 (`gamma=10.2071036477`) e conserva gli
stessi fallimenti prestazionali: anche M10 è `PARTIAL`. M11 ha completato la
campagna finita A0–A5 con cinque start per famiglia e ordine massimo sei:
A0–A2 non hanno rappresentanti stabili, mentre A3/A4/A5 formano la frontiera
Pareto con gamma 16.6419/11.6555/10.2477. M11 resta `PARTIAL` perché stabilità
globale, gamma<1 e tracking falliscono. Il gruppo ha successivamente
selezionato A5, ordine 6, per la sola analisi M12; questa scelta non promuove
A5 a controllore conforme a M5.

M15 implementa in un modello Simulink separato Khinf M10 e Kmu M13 senza
rigenerarli. Equilibrio, scenari M5, rumore, disturbi, confronti LTI/NL e RAS
empiriche sono stati eseguiti per entrambi. La validazione è completata ma i
target di tracking falliscono, quindi le caselle indicano esecuzione e
tracciabilità, non conformità prestazionale.

## \(\mu\)-analysis

- [x] Costruire e testare la struttura \(N\)-\(\Delta\).
- [x] Verificare Nominal Stability.
- [x] Verificare Nominal Performance.
- [x] Verificare Robust Stability.
- [x] Verificare Robust Performance.
- [x] Confrontare `mussv` con `robstab` e `robgain` su scaling coerente.
- [x] Identificare frequenze, blocchi e direzioni critiche.
- [x] Conservare lower/upper bound e dichiarare eventuali esiti inconclusivi.

M12 ha analizzato il controllore A5 congelato con `GuncQ` M4 e pesi M5.
La decomposizione N–Δ è coerente e la μ manuale conferma `robstab`. Gli esiti
sono distinti: NS `PASS`, NP `FAIL`, RS `FAIL_CERTIFIED` con margin
`[0.875899,0.882789]`, RP `FAIL_CERTIFIED` con margin `[0,0]`. Le caselle
indicano che le verifiche richieste sono state eseguite e documentate, non
che le proprietà prestazionali siano state soddisfatte. `wcgain` restituisce
gain non limitato nell'insieme M4 a causa del limite di stabilità incluso.

## \(\mu\)-synthesis

- [x] Eseguire D–K iteration su pianta e specifiche approvate.
- [x] Conservare e analizzare lo storico delle iterazioni.
- [x] Verificare ordine e stabilità interna del controllore.
- [x] Ripetere NS, NP, RS e RP a posteriori.
- [ ] Diagnosticare eventuali specifiche irrealizzabili.
- [ ] Ottenere approvazione prima di rilassamenti sostanziali.
- [ ] Registrare ogni rilassamento nel Decision Log.
- [ ] Se si riduce l'ordine, ripetere tutte le verifiche sul controllore ridotto.

M13 ha eseguito la singola campagna valida con `Display='short'`, cinque
iterazioni e problema M4/M5 congelato. Il controller restituito è 2×2 di
ordine 52 ed è nominalmente stabile; l'objective `10.4032233618` resta
maggiore di uno. M14 ha ripetuto la pipeline formale M12 sul Kmu senza
riduzione: NS `PASS`, NP `FAIL`, RS `PASS_CERTIFIED` con margin
`[1.250037,1.252573]` e RP `FAIL_CERTIFIED`. La verifica a posteriori è
quindi completata, mentre l'eventuale diagnosi globale di irrealizzabilità e
ogni rilassamento restano aperti.

## Validazione e confronto

- [x] Validare \(H_\infty\) e \(\mu\)-synthesis sul modello non lineare.
- [x] Definire criteri automatici e riproducibili per la RAS LQG M6.
- [x] Esplorare due sezioni e un dominio di stati iniziali documentati per M6.
- [x] Impostare un seed Monte Carlo esplicito.
- [x] Campionare indicativamente almeno 10 impianti incerti.
- [x] Confrontare stabilità, tempo di assestamento, banda ed errore.
- [x] Confrontare disturbi, comando e cross-coupling.
- [x] Distinguere evidenza Monte Carlo e garanzia \(\mu\).
- [x] Confrontare LQG, \(H_\infty\) e \(\mu\)-synthesis.
- [x] Confrontare formalmente \(H_\infty\) e D–K in RS, RP e margini.

M14 confronta l'A5 congelato M12 con Kmu: il margine RS passa da
`[0.875899,0.882789]` a `[1.250037,1.252573]`, con transizione certificata
`FAIL_CERTIFIED -> PASS_CERTIFIED`. Entrambi falliscono NP/RP sul target M5;
il confronto distingue quindi recupero della stabilità robusta e mancata
performance robusta.

M15 aggiunge la validazione nominale non lineare: Khinf e Kmu restano
all'equilibrio ma falliscono tracking M5. La RAS Khinf localizza un boundary
interno con raggio minimo 52.876°, mentre Kmu raggiunge il box in tutte le
direzioni; le regioni di accordo LTI/NL hanno raggio minimo 4° e 4.75°.
Queste evidenze non campionano M4 e non trasferiscono la RS lineare M14 al
modello non lineare.

M16 usa seed `20260826`, generatore `twister` e una sola sequenza comune di
40 campioni lineari M4 per M6, Khinf e Kmu. Tutti i campioni sono validi;
M6 è stabile 39/40, mentre Khinf e Kmu sono stabili 40/40. Il Sample 5 M6
instabile resta nel dataset e non riceve metriche prestazionali. Tracking,
banda diagonale, errore, disturbo, cross-coupling e comando sono quantificati
con pass rate espliciti: le caselle indicano esecuzione e tracciabilità, non
conformità ai target. Kmu 40/40 è coerente con la RS M14, ma la Monte Carlo
non è una certificazione e non fornisce probabilità fisiche. Il confronto è
paired e privo di score globale; la selezione finale resta fuori da M16.

## Deliverable finali

- [ ] `run_all.m` rigenera deterministicamente tutti i risultati finali.
- [ ] Parametri e specifiche hanno un'unica sorgente.
- [ ] Test automatici completi e tutti gli esiti documentati.
- [ ] Dati, figure e tabelle generati automaticamente.
- [ ] Relazione dettagliata sincronizzata col codice.
- [ ] Controllori finali salvati e identificati senza ambiguità.
- [ ] Codice MATLAB e modelli Simulink consegnabili.
- [ ] Presentazione basata sulla relazione e contenuta in 20 minuti.
