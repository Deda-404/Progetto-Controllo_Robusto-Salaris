# Confronto dei controllori adottati

La fonte robusta è results/data/hinf_final_coherent; i risultati di altre sintesi non sono trasferiti ai controllori selezionati.

| Proprietà | LQG | LQRI | Hinf 2-DoF | Kmu 2-DoF |
|---|---|---|---|---|
| Ordine | 14 | 16 | 22 | 78 |
| Stabilità nominale | PASS | PASS | PASS | PASS |
| Tracking richiesto | PASS | FAIL | FAIL | FAIL |
| Reiezione DC coppia costante | offset | offset nullo nel lineare | vedi dati | vedi dati |
| Norma pesata 2-DoF | non confrontata | non confrontata | 0.0474606 | 0.63468 |
| RS | non certificata | non certificata | FAIL | PASS |
| RP | non valutata | non valutata | esclusa per RS | PASS |
| Campioni stabili comuni | 37/40 | non valutati | 0/40 | 40/40 |

LQG è il riferimento nominale; LQRI illustra l'azione integrale; Hinf resta il comparatore nominale e Kmu il candidato robusto del modello dichiarato. Nessun risultato equivale a validazione hardware o dei modelli Simulink originali.
