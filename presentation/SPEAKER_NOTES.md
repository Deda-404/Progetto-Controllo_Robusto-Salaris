# Note per l’esposizione

Il discorso completo e le risposte di preparazione sono in `Presentazione_orale.txt`. Il conteggio del parlato e l’equilibrio fra studenti sono in `OUTLINE_AND_TIMING.md`.

Attenzione ai protocolli: i numeri della slide 18 sono MATLAB isolato, quelli della slide 19 sono Scope Simulink combinato. RMS integrato medio fra canali e massimo RMS per canale non sono la stessa statistica.

La slide 19 usa candidati verificati separatamente: HinfN3 non supera RS; MuN1 supera RS/RP ma non tutti i target temporali. Nessuna certificazione hardware.

## 1. Controllo robusto di un manipolatore planare 2-DoF con SEA — Alessio, 0:17

mostrare il titolo; restare sulla slide durante l'introduzione.

## 2. SEA: otto stati meccanici, due poli instabili — Alessio, 0:47

indicare theta e q nelle due equazioni, poi l'equilibrio.

## 3. Sei stati di attuatore completano il modello — Alessio, 0:47

indicare il modello dell'attuatore e l'inviluppo d'incertezza. Passaggio a Valerio.

## 4. Specifiche: norma pesata e tracking sono verifiche diverse — Valerio, 0:47

indicare la tabella delle specifiche; distinguere la scala del comando dal limite hardware.

## 5. LQR: il costo deriva dalle grandezze fisiche — Valerio, 0:48

indicare i termini elastici del costo e la legge di feedback.

## 6. LQG: quattro encoder e stato stimato — Valerio, 0:49

seguire misura, innovazione e stato stimato. Passaggio ad Alessio.

## 7. LQGI: memoria dell'errore misurato — Alessio, 0:48

indicare il recupero dopo il disturbo nel grafico.

## 8. H-infinity: sensibilità mista e pesi adottati — Alessio, 0:50

indicare separatamente W1 e W2 e il significato di gamma.

## 9. Due gradi di libertà, stati condivisi — Alessio, 0:49

seguire i rami Kr e Ky. Passaggio a Valerio.

## 10. Ordine completo e ordine fissato: il compromesso rimane — Valerio, 0:38

confrontare le due righe della tabella, senza equiparare i loro certificati.

## 11. Mu-analysis: separare controllore e incertezza — Valerio, 0:48

indicare il blocco Delta e la parte nota della LFT.

## 12. Mu: valore singolare strutturato — Valerio, 0:48

leggere NS, NP, RS e RP. Passaggio ad Alessio.

## 13. D-K iteration: sintesi, analisi, fit degli scaling — Alessio, 0:52

seguire il ciclo D-K e il grafico della storia delle iterazioni.

## 14. La post-analisi cambia la scelta del controllore — Alessio, 0:50

confrontare i margini con la soglia uno. Specificare che sono i controllori della prima formulazione.

## 15. Robustezza pesata e requisiti temporali non coincidono — Alessio, 0:49

indicare le righe tracking e RS/RP. Passaggio a Valerio.

## 16. Dieci impianti incerti: nominale e campioni comuni — Valerio, 0:39

indicare nominale e campioni, ricordando che sono comuni e congelati.

## 17. Tracking e disturbi sugli impianti incerti — Valerio, 0:49

indicare le bande di traiettorie, poi il disturbo.

## 18. Il rumore encoder produce impulsi fra i campioni — Valerio, 0:50

indicare picchi fra campioni e formula Tuv. Passaggio ad Alessio.

## 19. Risultati della sintesi con rumore esplicito — Alessio, 0:57

tabella Scope prima/dopo; precisare che lo scenario è combinato e la scelta finale resta agli studenti.

## 20. RAS empirica e insieme interno di Lyapunov — Alessio, 0:52

la figura mostra la griglia baseline; i risultati dei candidati sono distinti nella relazione.

## 21. Simulink lineare: servo LQGI — Alessio, 0:49

seguire riferimento, controllore, pianta e ritorno delle misure. Passaggio a Valerio.

## 22. Simulink non lineare: la stessa architettura LQGI — Valerio, 0:48

indicare attuatori, pianta non lineare, integratore dello stato e misure.

## 23. Conclusioni e limiti verificati — Valerio, 0:52

lasciare la conclusione visibile; entrambi possono rispondere alle domande.
