# Note per l'esposizione

## Slide 1 - Titolo (0:30)

- Messaggio: presentare sistema, obiettivo e natura conclusiva del lavoro.
- Spiegare: manipolatore planare 2-DoF con SEA.
- Non sovrainterpretare: non anticipare una conformità completa.
- Transizione: distinguere le evidenze richieste.

## Slide 2 - Domanda di progetto (1:00)

- Messaggio: il confronto richiede livelli di evidenza differenti.
- Spiegare: nominale, non lineare, Monte Carlo e mu-analysis.
- Non sovrainterpretare: simulazione e certificazione non sono sinonimi.
- Transizione: partire dal modello fisico.

## Slide 3 - Modello SEA (1:10)

- Messaggio: elasticità e coordinate motore/link determinano la struttura.
- Spiegare: due equazioni accoppiate, stato a otto componenti.
- Non sovrainterpretare: la linearizzazione resta locale.
- Transizione: aggiungere dinamica attuatore.

## Slide 4 - Attuatori (1:00)

- Messaggio: secondo ordine e ritardo Padé portano a 14 stati.
- Spiegare: parametri nominali e limite alle alte frequenze.
- Non sovrainterpretare: Padé non è il ritardo esatto.
- Transizione: modellare le dispersioni.

## Slide 5 - Incertezze (1:05)

- Messaggio: M4 contiene tre blocchi reali e due dinamici.
- Spiegare: screening, range e copertura di W_I.
- Non sovrainterpretare: i range non sono distribuzioni identificate.
- Transizione: fissare il criterio di prestazione.

## Slide 6 - Specifiche (1:00)

- Messaggio: i target M5 sono invariati; i pesi sono stati rivisti direttamente e poi fissati prima delle sintesi a valle.
- Spiegare: target e significato di W1/W2.
- Non sovrainterpretare: uScale non è una saturazione.
- Transizione: mostrare il riferimento nominale.

## Slide 7 - LQR: scale e pesi (1:00)

- Messaggio: la scala fisica non è un coefficiente di tuning.
- Spiegare: qs=5 gradi dal riferimento M5; qds=12 qs; ds=0.5/40 rad; uScale=12 N m è una scala desiderata, non un limite hardware.
- Calcolo: F forma [q; qdot; theta-q; thetadot]; Q=F' Sx^(-T) W Sx^(-1) F, con termini incrociati -640. R=ru I2, senza normalizzazione del comando.
- Scelta: nuova ricerca di 36 combinazioni con ru={0.01,0.05,0.10}; 9 ammissibili, selezionato LQR30 con ru=0.10 mediante i criteri invariati. Q resta identica, R e K cambiano realmente.
- Transizione: lo stato necessario a K non è tutto misurato.

## Slide 8 - Kalman: ipotesi e sensibilità (1:00)

- Messaggio: sigmaD=sigmaU=0.1 N m e sigmaY=0.05 gradi sono ipotesi del progetto, non dati del docente o di sensori identificati.
- Calcolo: Qn=0.01 I4, Rn=(0.05 pi/180)² I4; lqe produce L. Nel continuo sono intensità equivalenti: il rumore bianco ideale non ha deviazione standard istantanea finita.
- Spiegare: la stessa sequenza campionata di rumore è applicata ai tre stimatori. I valori aggiornati della tabella derivano da M6; L, Qn e Rn sono identici alla baseline, mentre cambia il regolatore.
- Non sovrainterpretare: non è identificazione sperimentale né una nuova ottimizzazione; la discretizzazione diagnostica non identifica le intensità continue.
- Transizione: combinare K e L tramite il principio di separazione.

## Slide 9 - LQG M6 (0:45)

- Messaggio: M6 è il miglior riferimento nominale di tracking.
- Spiegare: 36 costi LQR motivati, 9 ammissibili, scelta LQR30 mediante score normalizzato; poi ipotesi e sensibilità Kalman.
- Non sovrainterpretare: prestazione nominale non implica robustezza.
- Transizione: discutere l'integratore richiesto dalla traccia.

## Slide 10 - LQG-I M7 (0:55)

- Messaggio: tutti e tre i controllori LQRI sono implementati e stabili, ma nessuno soddisfa tutti i target M5.
- Spiegare: Qi=wbarI I2, con wbarI={20,200,800}; Q/R e Kalman provengono da M6. Il punto illustrativo 200 annulla l'offset DC, ma Ts=5.046 s supera 0.8 s.
- Non sovrainterpretare: distinguere implementazione valida da conformità prestazionale; il risultato negativo non implica inesistenza del controllore.
- Transizione: passare alle sintesi H-infinity.

## Slide 11 - H-infinity (1:15)

- Messaggio: mixsyn/hinfsyn sono coerenti ma gamma resta maggiore di uno.
- Spiegare: pesi diretti nelle coordinate fisiche; 8 casi W1 e 4 casi W2, tutti non conformi. Il W3 fissato nello studio non appartiene alla pianta M10 a due pesi. La Lower LFT è ricostruita e verificata.
- Non sovrainterpretare: A5 M12 non è Khinf M10.
- Transizione: utilizzare A5 come base della mu-analysis.

## Slide 12 - D-K iteration (1:00)

- Messaggio: la D-K iteration produce Kmu, ma non ne certifica ancora la robustezza.
- Spiegare: M13 è stata rigenerata una sola volta perché dipende dai nuovi pesi; best iteration 5, ordine 70. M14 usa lo stesso M4, non una nuova incertezza.
- Non sovrainterpretare: l'objective musyn non è un certificato RS o RP.
- Transizione: affidare la verifica ai quattro esiti indipendenti M14.

## Slide 13 - M14 (1:20)

- Messaggio: M14 produce RS FAIL_CERTIFIED; anche NP e RP falliscono. Non è trasferibile il certificato della precedente configurazione.
- Spiegare: intervallo del margine RS e distinzione NS/NP/RS/RP.
- Non sovrainterpretare: evitare la frase generica "Kmu è robusto".
- Transizione: verificare il modello non lineare nominale.

## Slide 14 - Non lineare (1:00)

- Messaggio: Khinf/Kmu sono stabili ma non raggiungono M5.
- Spiegare: settling, overshoot, errore e comando.
- Non sovrainterpretare: nessuna saturazione hardware.
- Transizione: qualificare la RAS.

## Slide 15 - Lyapunov nominale (1:20)

- Messaggio: P=lyap(Acl',I) riguarda l'intera chiusura: 28 stati LQG, 32 H-infinity, 84 Kmu, inclusi attuatori e osservatore/controllore.
- Dimostrazione: f(z)=Acl z+E r(z), con ||r|| <= c||z||³ nell'equilibrio superiore. Dal residuo di Lyapunov e dal limite cubico si ricava rhoA>0 che garantisce Vdot <= -(1-epsilon)/2 ||z||².
- Grafico: zoom della sezione analitica LQG, z=J dq con dtheta=dq, velocità e stati del controllore nulli. Le ellissi più ampie campionate e i punti delle simulazioni sono confrontati nella relazione, non in questa slide.
- Limiti: bound molto conservativo, calcolo in doppia precisione senza aritmetica intervallare, modello nominale senza saturazione e con Padé. Non è una RAS massima né una certificazione robusta M4.
- Confronto: 48 traiettorie aggiuntive sulle due ellissi verificano la decrescita numerica di V; i punti empirici M8/M15 restano un'evidenza distinta.
- Transizione: passare dalla stabilità nominale non lineare alla variabilità lineare M4.

## Slide 16 - Monte Carlo (1:15)

- Messaggio: stessi 40 campioni per tutti i controllori; i casi instabili restano nel dataset.
- Spiegare: seed, conteggi e core tracking pass rate.
- Non sovrainterpretare: la frazione stabile non è una probabilità fisica.
- Transizione: integrare le evidenze senza score globale.

## Slide 17 - Monte Carlo e mu-analysis (0:30)

- Messaggio: le due analisi rispondono a domande diverse.
- Spiegare: M16 osserva realizzazioni finite; M14 verifica il modello incerto strutturato.
- Non sovrainterpretare: la frequenza empirica non è una certificazione né sostituisce M14.
- Transizione: integrare le evidenze nella scelta per ruolo.

## Slide 18 - Decisione (1:00)

- Messaggio: la selezione è per ruolo.
- Spiegare: ruolo robusto non assegnato per assenza di un candidato con RS certificata; M6 riferimento nominale e Khinf comparatore.
- Non sovrainterpretare: nessun controllore domina tutte le metriche.
- Transizione: chiudere con limiti e implicazioni.

## Slide 19 - Limiti (0:55)

- Messaggio: deliverable completo e requisiti tecnici falliti possono coesistere.
- Spiegare: RP, tracking, saturazioni, incertezze, RAS, ordine.
- Non sovrainterpretare: gli sviluppi futuri non sono risultati correnti.

## Domande probabili

### Perché M7 non ha un controllore finale?

Le tre LQRI implementate non rispettano simultaneamente tutti i target M5. Il risultato è PARTIAL: il candidato illustrativo wbarI=200 è stabile e annulla l'offset DC, ma non soddisfa il settling richiesto.

### Perché gamma maggiore di uno è stato conservato?

La piccola ricerca autorizzata ha ridotto gamma modificando esplicitamente i pesi, ma non ha prodotto candidati conformi. I criteri non vengono cambiati per ottenere PASS e la ricerca termina al budget dichiarato.

### Qual è la differenza fra RS e RP?

RS richiede stabilità interna per tutte le incertezze ammesse. RP richiede anche il rispetto della prestazione pesata su tutto l'insieme. Il nuovo Kmu fallisce entrambe secondo M14.

### Perché Monte Carlo non certifica robustezza?

Perché verifica solo 40 realizzazioni e non tutte le perturbazioni ammissibili. Inoltre i range M4 non definiscono probabilità fisiche. M14 mantiene autorità sulla valutazione formale RS, qui negativa.

### Perché non è assegnato il ruolo robusto finale?

Il criterio richiede RS formale PASS_CERTIFIED. Nessuno dei controllori principali la possiede nella configurazione corrente; non viene alterato il criterio per assegnare comunque un vincitore. M6 resta il riferimento nominale.

### Perché M6 non è il controllore robusto finale?

Non ha un certificato RS su M4; gli eventuali campioni instabili M16 restano evidenza empirica, non probabilistica.

### Perché non ridurre Kmu?

La riduzione altererebbe il controllore congelato e richiederebbe una rivalidazione completa nominale, non lineare, Monte Carlo e mu. Non è autorizzata in M18.

### Cosa rappresenta uScale?

È la scala fisica desiderata da 12 N m usata nelle metriche del comando. Il nuovo W2 impiega invece il guadagno diretto ku=0.05; non viene trasformata la pianta. uScale non è un limite hardware e non attiva clipping.

### Cosa significa RAS search-box limited?

Tutti i punti sul limite del dominio esplorato sono convergenti. La frontiera reale non è stata individuata; il bordo della box non è una frontiera dinamica.

### Qual è il limite principale del modello di incertezza?

I range sono inviluppi ingegneristici e la dinamica attuatore è coperta da un peso, ma non derivano da identificazione sperimentale. Il certificato vale rispetto a M4, non a ogni impianto fisico possibile.

### La ricerca di rho certifica da sola la RAS?

No. Il livello rhoA segue da una maggiorazione analitica del resto non lineare e dall'equazione di Lyapunov. Il livello rhoS, più ampio, supera una verifica finita di Vdot, ma non è certificato. Nessuno dei due rappresenta la regione di attrazione massima.

### Perché le regioni analitiche sono così piccole?

La maggiorazione usa norme globali molto conservative e QL=I nelle coordinate numeriche SI. Include tutti gli stati dinamici, anche quelli interni. È una condizione sufficiente; una regione interna piccola non dimostra una scarsa capacità di convergenza reale e non permette di classificare i controllori mediante rho.
