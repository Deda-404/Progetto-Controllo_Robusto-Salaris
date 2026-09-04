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

- Messaggio: M5 è congelata prima delle sintesi.
- Spiegare: target e significato di W1/W2.
- Non sovrainterpretare: uScale non è una saturazione.
- Transizione: mostrare il riferimento nominale.

## Slide 7 - LQG M6 (1:10)

- Messaggio: M6 è il miglior riferimento nominale di tracking.
- Spiegare: 36 costi LQR motivati, 9 ammissibili, scelta LQR30 mediante score normalizzato; poi ipotesi e sensibilità Kalman.
- Non sovrainterpretare: prestazione nominale non implica robustezza.
- Transizione: discutere l'integratore richiesto dalla traccia.

## Slide 8 - LQG-I M7 (0:55)

- Messaggio: nessuna delle tre verifiche manuali produce un controllore finale.
- Spiegare: incompatibilità osservata fra settling time e overshoot.
- Non sovrainterpretare: non presentare un controllore integrale inesistente.
- Transizione: passare alle sintesi H-infinity.

## Slide 9 - H-infinity (1:15)

- Messaggio: mixsyn/hinfsyn sono coerenti ma gamma resta maggiore di uno.
- Spiegare: generalized plant e frontiera hinfstruct.
- Non sovrainterpretare: A5 M12 non è Khinf M10.
- Transizione: utilizzare A5 come base della mu-analysis.

## Slide 10 - D-K iteration (1:00)

- Messaggio: la D-K iteration produce Kmu, ma non ne certifica ancora la robustezza.
- Spiegare: M13 non viene rilanciata; best iteration e ordine 52 restano congelati, mentre M14 usa l'M4 corrente.
- Non sovrainterpretare: l'objective musyn non è un certificato RS o RP.
- Transizione: affidare la verifica ai quattro esiti indipendenti M14.

## Slide 11 - M14 (1:20)

- Messaggio: M14 certifica RS; NP e RP falliscono.
- Spiegare: intervallo del margine RS e distinzione NS/NP/RS/RP.
- Non sovrainterpretare: evitare la frase generica "Kmu è robusto".
- Transizione: verificare il modello non lineare nominale.

## Slide 12 - Non lineare (1:10)

- Messaggio: Khinf/Kmu sono stabili ma non raggiungono M5.
- Spiegare: settling, overshoot, errore e comando.
- Non sovrainterpretare: nessuna saturazione hardware.
- Transizione: qualificare la RAS.

## Slide 13 - RAS (0:55)

- Messaggio: tutte le RAS sono stime empiriche.
- Spiegare: stesso piano $\Delta q_1$--$\Delta q_2$, stesso box, solver, soglie e orizzonte; frontiera interna Khinf e search-box limit M6/Kmu.
- Non sovrainterpretare: 60 gradi non è una frontiera dinamica certificata.
- Transizione: introdurre l'insieme incerto campionato.

## Slide 14 - Monte Carlo (1:15)

- Messaggio: stessi 40 campioni per tutti i controllori; i casi instabili restano nel dataset.
- Spiegare: seed, conteggi e core tracking pass rate.
- Non sovrainterpretare: la frazione stabile non è una probabilità fisica.
- Transizione: integrare le evidenze senza score globale.

## Slide 15 - Monte Carlo e mu-analysis (0:30)

- Messaggio: le due analisi rispondono a domande diverse.
- Spiegare: M16 osserva realizzazioni finite; M14 verifica il modello incerto strutturato.
- Non sovrainterpretare: la frequenza empirica non è una certificazione né sostituisce M14.
- Transizione: integrare le evidenze nella scelta per ruolo.

## Slide 16 - Decisione (1:15)

- Messaggio: la selezione è per ruolo.
- Spiegare: Kmu robusto, M6 nominale, Khinf comparatore.
- Non sovrainterpretare: nessun controllore domina tutte le metriche.
- Transizione: chiudere con limiti e implicazioni.

## Slide 17 - Limiti (1:00)

- Messaggio: deliverable completo e requisiti tecnici falliti possono coesistere.
- Spiegare: RP, tracking, saturazioni, incertezze, RAS, ordine.
- Non sovrainterpretare: gli sviluppi futuri non sono risultati correnti.

## Domande probabili

### Perché M7 non ha un controllore finale?

Le tre verifiche manuali sull'architettura LQI/LQG-I non rispettano simultaneamente settling time e overshoot M5. Il risultato è preservato come PARTIAL, senza inventare un controllore.

### Perché gamma maggiore di uno è stato conservato?

Perché il problema, i pesi e i controllori sono congelati. Gamma maggiore di uno documenta la mancata conformità pesata; ritunare retroattivamente cambierebbe il problema approvato.

### Qual è la differenza fra RS e RP?

RS richiede stabilità interna per tutte le incertezze ammesse. RP richiede anche il rispetto della prestazione pesata su tutto l'insieme. Kmu supera RS ma fallisce RP.

### Perché Monte Carlo non certifica robustezza?

Perché verifica solo 40 realizzazioni e non tutte le perturbazioni ammissibili. Inoltre i range M4 non definiscono probabilità fisiche. Il certificato RS deriva da M14.

### Perché scegliere Kmu se il tracking è peggiore?

La scelta è per ruolo: Kmu è l'unico candidato con RS formale PASS_CERTIFIED. M6 resta il riferimento nominale proprio perché traccia meglio.

### Perché M6 non è il controllore robusto finale?

Non ha un certificato RS su M4; gli eventuali campioni instabili M16 restano evidenza empirica, non probabilistica.

### Perché non ridurre Kmu?

La riduzione altererebbe il controllore congelato e richiederebbe una rivalidazione completa nominale, non lineare, Monte Carlo e mu. Non è autorizzata in M18.

### Cosa rappresenta uScale?

È la scala da 12 N m usata in W2 per normalizzare il comando. Non è un limite di coppia hardware e non attiva clipping.

### Cosa significa RAS search-box limited?

Tutti i punti sul limite del dominio esplorato sono convergenti. La frontiera reale non è stata individuata; il bordo della box non è una frontiera dinamica.

### Qual è il limite principale del modello di incertezza?

I range sono inviluppi ingegneristici e la dinamica attuatore è coperta da un peso, ma non derivano da identificazione sperimentale. Il certificato vale rispetto a M4, non a ogni impianto fisico possibile.
