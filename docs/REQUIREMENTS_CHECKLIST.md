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
- [x] Approvare parametri incerti e percentuali per l'insieme unico M4.
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
- [x] Sintetizzare LQRI con Kalman M6 e integratori sulle uscite misurate.
- [x] Motivare e registrare \(Q\) e \(R\).
- [x] Motivare e registrare covarianze di processo e misura.
- [x] Verificare principio di separazione e poli dell'anello chiuso.
- [x] Validare stima dello stato, rumore e condizioni iniziali per M6.
- [x] Confrontare errore a regime con disturbo costante.
- [x] Confrontare sforzo di controllo con e senza integratore.
- [ ] Implementare entrambe le versioni in Simulink.
- [x] Validare la versione senza integratore sul modello linearizzato.
- [x] Validare M6 senza integratore sul modello non lineare.
- [x] Stimare e documentare la RAS empirica M6 su due sezioni.

M7 implementa tre LQRI a 30 stati chiusi, tutte stabili e con offset DC
nullo. Qi={20,200,800} I2 e Q/R/Kalman M6 sono espliciti. Nessuna raggiunge
tutti i target; il punto illustrativo 200 resta PARTIAL per il settling.
M8 valida il solo LQG M6 nel non lineare: la validazione non lineare
della LQRI e l'implementazione di entrambe in Simulink rimangono aperte.

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

M9/M10 usano i nuovi W1/W2 M5 diretti, senza W3. La stabilità interna e
la ricostruzione sono PASS; gamma=5.677221 e il tracking non raggiungono
i target. Il cross-coupling passa, senza compensare gli altri FAIL.
M11 conserva sei famiglie e cinque avvii ciascuna: 15/30 stabili,
A0–A2 prive di rappresentanti stabili; A3/A4/A5 hanno objective
8.167144/5.967246/5.708569. Nessuna è conforme. A5 resta il riferimento
di ordine sei per M12, non un controllore conforme alle specifiche.

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
`[0.839830,0.850574]`, RP `FAIL_CERTIFIED` con margin `[0,0]`. Le caselle
indicano che le verifiche richieste sono state eseguite e documentate, non
che le proprietà prestazionali siano state soddisfatte. `wcgain` restituisce
gain non limitato nell'insieme M4 a causa del limite di stabilità incluso.

## \(\mu\)-synthesis

- [x] Eseguire D–K iteration su pianta e specifiche approvate.
- [x] Conservare e analizzare lo storico delle iterazioni.
- [x] Verificare ordine e stabilità interna del controllore.
- [x] Ripetere NS, NP, RS e RP a posteriori.
- [ ] Diagnosticare eventuali specifiche irrealizzabili.
- [x] Ottenere approvazione per la revisione mirata dei pesi.
- [x] Registrare la revisione corrente nel Decision Log (D-0051).
- [ ] Se si riduce l'ordine, ripetere tutte le verifiche sul controllore ridotto.

M13 è stata rigenerata una sola volta sui pesi definitivamente selezionati,
con cinque iterazioni. Kmu è 2x2 di ordine 70 e nominalmente stabile;
objective=6.38492231705. M14 lo verifica senza riduzione: NS PASS,
NP FAIL, RS FAIL_CERTIFIED con margine [0.774042,0.775697], RP FAIL_CERTIFIED.
La diagnosi globale di irrealizzabilità resta aperta; il budget limitato
di ricerca non equivale a una dimostrazione di impossibilità.

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

M14 confronta A5 e Kmu correnti: entrambi falliscono RS/NP/RP.
Il margine RS di Kmu non migliora quello di A5. L'objective di sintesi
e la certificazione a posteriori restano due grandezze distinte.

M15 verifica le simulazioni nominali non lineari, senza nuovo tuning:
tracking FAIL per entrambi. Khinf ha RAS empirica con raggio minimo
44.895 gradi; Kmu raggiunge il box. L'accordo LTI/NL ha raggio minimo
4.5 e 5 gradi. Il budget RAS è stato corretto a 626 esecuzioni massime,
derivate dall'algoritmo, senza modificare precisione e convergenza.

M16 conserva seed 20260826 e 40 campioni comuni M4: M6 stabile in 37/40,
Khinf e Kmu in 40/40. I tre casi M6 instabili restano nel dataset e non
ricevono metriche prestazionali. La frazione stabile di Kmu non annulla
RS negativa e non rappresenta una probabilità fisica.

M17 mantiene i criteri e lascia il ruolo robusto finale NON ASSEGNATO.
M6 resta riferimento nominale e Khinf comparatore. Il gate software è
PASS, ma lo stato tecnico è PARTIAL per assenza del candidato robusto.

## Deliverable finali

- [x] `run_all.m` mantiene la pipeline storica M0–M18; il percorso di revisione congelata aggiunge esplicitamente Lyapunov e script didattici come documentato nel README.
- [x] Parametri e specifiche hanno un'unica sorgente.
- [x] Test automatici completi e tutti gli esiti documentati.
- [x] Dati, figure e tabelle generati automaticamente.
- [x] Relazione dettagliata sincronizzata col codice.
- [x] Controllori finali salvati e identificati senza ambiguità.
- [x] Codice MATLAB e modelli Simulink consegnabili.
- [x] Presentazione basata sulla relazione e contenuta in 20 minuti.

Il conteggio aggiornato delle pagine è registrato nell'audit LaTeX;
la presentazione mantiene 19 slide e timing stimato 19:00. Le caselle aperte nelle sezioni tecniche
rimangono intenzionalmente aperte: la finalizzazione documentale non
trasforma risultati falliti, parziali o non eseguiti in requisiti soddisfatti.

## Lyapunov nominale: revisione tecnica

- [x] Matrici aumentate complete LQG/H-infinity/Kmu, QL=I e P positiva.
- [x] Residuo dell'equazione di Lyapunov e Jacobiano non lineare verificati.
- [x] Maggiorazione analitica del resto e regione interna sufficiente.
- [x] Ricerca di un livello più ampio con campionamento, margine e seed espliciti; nessuna certificazione attribuita a punti finiti.
- [x] Sezioni coerenti con le condizioni iniziali empiriche e 48 traiettorie aggiuntive.
- [ ] Regione di attrazione massima, modello non lineare incerto, saturazioni hardware e verifica con aritmetica intervallare: non ottenuti.
