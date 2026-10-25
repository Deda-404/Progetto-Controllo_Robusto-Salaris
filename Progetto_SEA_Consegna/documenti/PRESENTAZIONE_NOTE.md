# Presentazione: note e tempi

18 slide. Contenuti: 18:45; cambi: 34 s. Totale pianificato: 19:19. La durata effettiva richiede una prova cronometrata.

## 1. Titolo - Alessio, 25 s

Presentare la domanda sulle rappresentazioni e distinguere subito analisi a controllore fisso e sintesi dedicata.

## 2. Sistema SEA ed equilibrio - Alessio, 60 s

Seguire le coppie elastiche con i segni opposti. Il disturbo entra sui link; la dinamica del drive precede la coppia motore. Equilibrio verticale instabile e misure encoder.

## 3. Attuatore nominale - Alessio, 60 s

Spiegare wn, zeta e tau. I nominali gia verificati sono conservati. Lo zero RHP di Pade e una conseguenza dell’approssimazione, non un polo instabile del drive.

## 4. Scelta dei parametri - Valerio, 55 s

Mostrare i cinque valori e le metriche del preliminare. Il ritardo non e fisicamente irrilevante: renderlo noto e una restrizione approvata. La meccanica resta nota per isolare il confronto.

## 5. A parametrico - Valerio, 75 s

Derivare verbalmente z1, z2, z3. La stessa delta_wn chiude due porte: numeratore, rigidezza e smorzamento non possono variare indipendentemente. Due attuatori indipendenti.

## 6. B concentrato - Valerio, 65 s

Seguire il ramo u-WI-Delta e la somma prima del nominale. Due blocchi SISO non introducono crosstalk. Il peso rappresenta la variabilita dei secondi ordini, non un residuo del ritardo.

## 7. Copertura e conservativita - Alessio, 65 s

Spiegare E/WI stabile e proprio e la maggiorazione su tutto il box. Il fit campionato non e la prova. Distinguere l’inclusione unitaria dalle espansioni normalizzate dei margini.

## 8. Pianta generalizzata - Alessio, 65 s

Indicare w, u, z, y. Specificare che Mo entra nel costo e non e un prefiltro applicato dopo la sintesi. W1 sull’errore, W2 sul comando; nessun W3 aggiuntivo.

## 9. LQG/LQGI - Alessio, 80 s

Kalman stima le velocita e i drive da quattro encoder. L’integratore usa l’errore misurato. Q non e diagonale perche pesa theta-q. LQGI elimina DC del disturbo ma e lento.

## 10. H-infinity - Valerio, 70 s

Le prime due righe confrontano davvero mixsyn e hinfsyn. P2 e PID hanno un altro costo. Conservare la banca mentre il ricalcolo dimostra la sintesi; nessun minimo globale dichiarato.

## 11. NS/NP/RS/RP - Valerio, 60 s

Definire separatamente NS, NP, RS e RP. Un upper di mu sotto uno e una garanzia; campioni stabili non bastano. I bounds invertiti restano esiti numerici inconcludenti.

## 12. Controllori fissi - Valerio, 65 s

LQG/LQGI sono l’esempio piu chiaro di cambiamento di garanzia: stesso K, stessa pianta nominale, A passa e B fallisce. L’insieme concentrato e piu ampio e il peso contiene margine conservativo.

## 13. D-K - Alessio, 65 s

Descrivere K-step e D-step e leggere i quattro passi effettivi. Parametri reali e dinamici danno strutture diverse; identico budget non garantisce identica difficolta ne ottimalita.

## 14. Sintesi incrociata - Alessio, 65 s

Mu_B raggiunge garanzie incrociate con 32 stati, Mu_A ne usa 88. Per Kmu su A si usa solo la deduzione a raggio uno da B, preservando gli intervalli diretti incoerenti.

## 15. Dieci impianti - Alessio, 55 s

I dieci impianti sono fisici, inclusi nominale ed estremi, e sono identici per tutti. Hinf2 e PID mostrano fallimenti. Non presentare una dinamica ultidyn casuale come un attuatore fisico identificato.

## 16. RAS - Valerio, 75 s

Spiegare gli stati iniziali completi e le soglie dell’ultimo secondo. La non convergenza entro 12 s non e instabilita matematica. Hinf2/PID hanno arresti numerici. Mu_A6 contro Mu_B15 e un limite non lineare concreto.

## 17. Rumore e storia - Valerio, 60 s

Non nascondere il costo sul rumore dei nuovi K. Ricordare il risultato precedente MuN1 senza trasferirne la garanzia da M4 a S1. La nuova integrazione Simulink e ancora da svolgere sui modelli definitivi degli studenti.

## 18. Conclusioni - Valerio, 60 s

Rispondere alla domanda iniziale: per K fisso B e qui piu conservativo, ma puo semplificare la sintesi. Citare i target persi e i limiti del rumore. Nessun vincitore universale o promozione automatica.
