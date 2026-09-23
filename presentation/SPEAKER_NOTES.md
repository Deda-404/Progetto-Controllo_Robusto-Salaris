# Note del relatore — 20 slide, 17:55

Rispettare i tempi per slide. Margine residuo 2:05; evitare demo live e lettura integrale delle tabelle.

## 1. Titolo — 0:15

Presentare tema e autori, senza anticipare l'intera scaletta.

## 2. La domanda di progetto richiede evidenze diverse — 0:30

Distinguere subito modellazione, prestazione nominale, simulazione non lineare e robustezza. Una curva di tracking non dimostra tutte e quattro le proprietà.

## 3. L'elasticità separa link e rotori — 0:55

Leggere le due equazioni fisiche. L'elasticità separa link e rotori: quattro coordinate e quattro velocità. Indicare l'equilibrio e la necessità del feedback.

## 4. Attuatori e linearizzazione portano a 14 stati — 0:40

Spiegare i sei stati aggiuntivi: attuatori dinamici e Padé. La linearizzazione completa ha 14 stati; non confonderli con gli otto meccanici.

## 5. M4 combina parametri reali e dinamica non modellata — 0:45

Indicare i parametri reali incerti e le due incertezze dinamiche. Il dominio è ingegneristico, non una distribuzione statistica identificata.

## 6. M5 fissa target e pesi prima del confronto — 0:45

Richiamare settling 0.8 s e gli altri target originali. La scala del comando non è una saturazione. Non leggere tutte le curve della figura.

## 7. LQR: scale fisiche e pesi sono cose diverse — 1:05

Spiegare trasformazione fisica, scale e pesi diretti. Il costo sulla deformazione rende Q non diagonale. Indicare il candidato selezionato senza ripercorrere la ricerca.

## 8. Kalman: ipotesi del progetto, non dati del docente — 1:00

Descrivere le quattro misure e le covarianze assunte, non fornite dal docente. Più fiducia nelle misure accelera la stima e trasferisce più rumore al comando. Feedback su xhat.

## 9. M6 è il riferimento di tracking nominale — 0:40

Mostrare il tracking LQG e il suo ruolo nominale. Non ripetere Riccati e selezione dei pesi già discussi.

## 10. M7 chiude con un risultato negativo utile — 0:45

Spiegare che LQRI esiste ed è implementata, ma M7 resta PARTIAL rispetto ai target congiunti. Due stati integrali si aggiungono ai 14 stimati.

## 11. Da una norma minore di uno a un vero progetto 2-DoF — 1:30

Dedicare tempo alla vera architettura 2-DoF: riferimento e misura entrano separatamente, Kr e Ky condividono gli stati. Spiegare modello desiderato e uscite pesate. Gamma minore di uno riguarda quel problema pesato e non equivale al rispetto di M5.

## 12. H-infinity: tracking migliorato, robustezza insufficiente — 1:05

Mostrare miglioramento nominale e settling ancora troppo lento. Dichiarare chiaramente RS FAIL; l'intervallo RP invertito non viene accreditato. Non presentare questo controllore come robusto.

## 13. Kmu è il candidato robusto del modello dichiarato — 1:25

Spiegare ruolo della D-K iteration e della successiva post-analisi. Kmu conserva 78 stati, RS/RP maggiori di uno sul modello dichiarato. Restano settling e offset M5: robustezza e prestazione temporale sono giudizi diversi.

## 14. Quaranta campioni comuni: esiti opposti — 0:40

Confrontare 0/40, 40/40 e LQG storico 37/40. Il campionamento è un controllo empirico comune, non una probabilità fisica né un sostituto della mu-analysis.

## 15. Rumore e regione di attrazione mostrano altri limiti — 0:55

Evidenziare l'amplificazione del rumore Hinf nella campagna di quattro secondi. Spiegare raggio minimo zero come limite di risoluzione e Kmu come box-limited. Non confondere questi dati robusti con la nuova RAS LQRI.

## 16. Lyapunov: distinguere certificato e verifica campionata — 0:45

Distinguere equazione di Lyapunov, gate numerico e controllo campionato. Il residuo Hinf fallisce; il livello campionato Kmu non diventa un certificato. Nessuna nuova sintesi o riduzione è stata effettuata.

## 17. Simulink: due piante, la stessa architettura 8+6 — 1:00

Indicare i quattro modelli non lineari già validati e il solo nuovo diagramma lineare comune. Il blocco M3 espone 14 stati, Cmeas e Cq sono separati. Tutti i controllori provengono dagli artifact correnti; gli originali restano in legacy. Nessuna demo live nel tempo assegnato.

## 18. Rumori, Kalman e integratore: segnali distinti — 1:05

Seguire fisicamente i tre canali: coppia sui link, rumore prima degli attuatori, rumore sugli encoder. Kalman conosce il comando, non la realizzazione del rumore. LQRI integra r-q_mis; entrambi i feedback usano xhat. Citare discretizzazione ZOH e seed senza entrare nei dettagli di implementazione.

## 19. LQG e LQRI: disturbo costante e condizioni iniziali — 1:05

Il grafico dimostra l'offset LQG e la reiezione LQRI del disturbo costante. Aggiungere il nuovo confronto RAS: 57 punti su 57, stessa sezione iniziale e box, nessuna estensione oltre 8 s. Entrambi raggiungono il bordo: non concludere che la RAS sia infinita, certificata o migliore per LQRI. I picchi di coppia restano un limite pratico.

## 20. Validazione completata, limiti di progetto conservati — 1:05

Spiegare i due confronti distinti e citare le soglie 2e-7 rad e 2e-4 Nm. Nuovi 32 controlli e 15 test, più i sette originari rieseguiti; i 67 controlli salvati non sono stati ricalcolati. Concludere sui ruoli dei controllori e sui limiti hardware. Se chiesto, il run iniziale dei test conteneva un errore di uso di linmod, documentato e corretto solo nel test.
