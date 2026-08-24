# Analisi della traccia ufficiale

**Documento analizzato:** `Traccia 2 - Manipolatore SEA`
**Estensione:** 3 pagine
**Stato lettura:** completa
**Ruolo:** specifica primaria e vincolante

## Sistema assegnato

Il sistema è un manipolatore planare 2R con masse concentrate e Series Elastic Actuators. Le coordinate dei link sono \(q=[q_1,q_2]^T\), quelle dei rotori \(\theta=[\theta_1,\theta_2]^T\), la deformazione elastica è \(\delta=\theta-q\) e l'ingresso è la coppia motore \(\tau\).

Le equazioni assegnate sono:

\[
M(q)\ddot q+C(q,\dot q)\dot q+G(q)=K_s(\theta-q),
\]

\[
J_m\ddot\theta+B_m\dot\theta=\tau-K_s(\theta-q).
\]

La traccia fornisce esplicitamente la struttura di \(M(q)\), \(C(q,\dot q)\) e \(G(q)\), oltre ai valori nominali dei parametri meccanici. Queste espressioni devono essere riprodotte fedelmente e testate dal nostro codice.

## Requisiti obbligatori

1. Modellare il sistema non lineare e scegliere un punto di equilibrio attorno al quale linearizzarlo.
2. Modellare ogni attuatore come un secondo ordine con ritardo di trasporto, approssimato con Padé del primo ordine.
3. Scegliere un numero limitato e ragionevole di parametri incerti, motivandone il ruolo fisico e dinamico.
4. Scegliere le misure disponibili e definire quantitativamente obiettivi e requisiti prestazionali.
5. Sintetizzare un controllo LQG con e senza integratore, motivando l'eventuale necessità dell'azione integrale e le covarianze dei rumori.
6. Implementare LQG in MATLAB/Simulink sia sul modello linearizzato sia su quello non lineare e valutarne empiricamente la RAS.
7. Sintetizzare controllori \(H_\infty\) mediante `mixsyn` e `hinfsyn`, confrontandoli.
8. Esplorare `hinfstruct`, ad esempio con una struttura PID o altra struttura MIMO appropriata.
9. Implementare i controllori \(H_\infty\) sui modelli lineare e non lineare, con valutazione della RAS.
10. Analizzare stabilità e prestazione robuste del controllore \(H_\infty\) tramite \(\mu\)-analysis, includendo incertezze parametriche e dinamica degli attuatori.
11. Eseguire \(\mu\)-synthesis mediante D–K iteration e ripetere la \(\mu\)-analysis a posteriori.
12. Se la sintesi robusta è irrealizzabile, rilassare gli obiettivi in modo ragionevole e motivato.
13. Confrontare \(H_\infty\) e \(\mu\)-synthesis in termini di robusta stabilità, robusta prestazione e margini.
14. Campionare indicativamente una decina di impianti linearizzati nell'insieme di incertezza e confrontarne stabilità e prestazioni.

## Scelte lasciate libere

Le seguenti scelte devono essere effettuate e motivate dal gruppo; la traccia non ne prescrive il valore:

- punto di equilibrio;
- insieme delle misure;
- obiettivo specifico di regolazione o tracking;
- parametri nominali \(\omega_n\), \(\zeta\) e \(\tau_d\) degli attuatori;
- parametri considerati incerti e relative percentuali;
- rappresentazione dell'incertezza dinamica;
- banda, errore ammesso, attenuazione dei disturbi e margini desiderati;
- limiti di coppia e modello fisico del disturbo;
- pesi LQR e covarianze Kalman;
- pesi \(W_1\), \(W_2\), \(W_I\) e architettura dell'impianto generalizzato;
- struttura e ordine del controllore `hinfstruct`;
- criterio numerico e dominio esplorato per la RAS;
- numero esatto di campioni e metriche Monte Carlo.

Nessuna di queste scelte è approvata durante M0.

## Analisi richieste

- equilibrio e coerenza delle equazioni;
- stabilità in anello aperto;
- controllabilità e osservabilità rispetto alle misure scelte;
- stabilità e prestazione nominali;
- stabilità e prestazione robuste, mantenute come proprietà distinte;
- confronto temporale e frequenziale dei controllori;
- frequenze e direzioni critiche della \(\mu\)-analysis;
- impatto delle incertezze e del rilassamento delle specifiche;
- confronto finale dei margini di robustezza.

## Simulazioni richieste

- modello linearizzato nominale;
- modello non lineare completo;
- LQG con e senza integratore;
- controllori \(H_\infty\) selezionati;
- controllore ottenuto con D–K iteration;
- stima empirica della RAS per i controllori richiesti;
- campioni della famiglia incerta con confronto di stabilità, tempo di assestamento o banda, reiezione dei disturbi e altre metriche motivate.

La RAS ricavata da simulazioni deve essere descritta come stima empirica e accompagnata da dominio esplorato, stati perturbati, criterio di convergenza, orizzonte di simulazione e tolleranze.

## Deliverable

- codice MATLAB sviluppato dal gruppo;
- modelli Simulink;
- relazione dettagliata con risultati principali, grafici, frammenti di codice e controllori individuati;
- materiale sufficiente a riprodurre i risultati dichiarati;
- presentazione orale, basata sulla relazione, di durata massima pari a 20 minuti.

## Requisiti della relazione

- Ogni risultato numerico deve essere tracciabile al codice e a un output validato.
- Grafici e tabelle devono essere generati dalla pipeline del progetto.
- Scelte libere, semplificazioni e rilassamenti devono essere motivati.
- Risultati negativi e limiti devono essere riportati.
- Il progetto precedente non può essere usato come fonte sostitutiva dei risultati del nostro gruppo.
