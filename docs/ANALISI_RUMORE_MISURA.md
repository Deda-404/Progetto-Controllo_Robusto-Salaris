# ANALISI RUMORE MISURA

Diagnosi del 13 ottobre 2026. Controllori archiviati invariati; nessuna nuova sintesi, riduzione, filtraggio, saturazione, anti-windup o modifica SLX. La prova MATLAB isolata e il collaudo dei diagrammi Simulink sono distinti di seguito.

## Protocollo e formula

`run_final_noise_diagnostics.m` usa seed 20261012, σy=0.05*pi/180 rad (8.72664626e−4), varianza 7.61543549e−7 rad², campioni gaussiani mantenuti per Ts=0.002 s, 4 s. LQG/LQGI ricevono quattro encoder, gli altri due; i primi due canali della stessa sequenza sono condivisi. Le sette prove distinguono riferimento pulito (5 gradi da 0.2 s), sola misura con r=d=w=0, solo q1, solo q2, sola coppia link (0.5 N m da 1 s), solo processo (σ=0.1 N m su link/comando) e combinata. L’intensità bianca continua di lqe non è questa varianza campionata. I rumori originali Simulink conservano il loro seed 20260826.

La legge 2-DoF è u=Kr*r+Ky*(q+v), q=G*u. Il segno del feedback è dentro Ky:

Tuv=(I−Ky*G)⁻¹*Ky; Tqv=G*Tuv.

Il codice costruisce Acl nello stato intero e verifica la mappa con `feedback(Ky,G,+1)`. Per LQG/LQGI Cm include q e theta e il feedback completo. La stabilità interna è verificata sui poli della matrice aumentata; rumore amplificato non è sinonimo di instabilità. Tutti i nominali risultano internamente stabili.

## Risultati: registrazione e propagazione fra i campioni

| Controllore | Ordine | ||Dy||₂ | Picco a 2 ms [N m] | RMS a 2 ms | Picco fra campioni | RMS integrato | Ritardo del picco [s] |
|---|---:|---:|---:|---:|---:|---:|---:|
| LQG | 14 | 0 | 0.3873 | 0.0878129 | 0.3873 | 0.0846225 | 0.002 |
| LQGI | 16 | 0 | 0.401348 | 0.0910337 | 0.401348 | 0.087719 | 0 |
| Hinf1 | 18 | 0 | 0.265565 | 0.0614703 | 0.265565 | 0.0556462 | 0.002 |
| Hinf2 | 22 | 0 | 22.1372 | 4.63596 | 492785 | 13196.2 | 1.25786e-05 |
| PID | 4 | 71544.2 | 315.014 | 62.7962 | 315.014 | 7.37014 | 0 |
| Kmu | 78 | 0 | 7.74712 | 1.89688 | 87.0963 | 8.28793 | 5.37932e-05 |

Il picco fra campioni è il massimo finito osservato sulla scansione logaritmica+uniforme, non un massimo globale dimostrato. L’RMS integra l’energia durante ogni intervallo di mantenimento, mediata sui due comandi e sui 4 s. Originale e coordinate bilanciate devono concordare entro 1e−4 relativo; il raffinamento della quadratura entro 2%. Questi due controlli passano. Non si tratta di interpolare il grafico: per ogni ritardo τ si propagano esattamente stato e ingresso costante con exp(Aτ) e l’integrale ZOH.

### Dinamiche e scala numerica

| Controllore | Polo più rapido, modulo [s⁻¹] | Picco campionato σmax(Tuv) [N m/rad] | Max Re polo interno [s⁻¹] | Errore formula | Errore ZOH coordinate |
|---|---:|---:|---:|---:|---:|
| LQG | 173.625 | 411.898 | -6.21853 | -- | 0 |
| LQGI | 174.424 | 426.02 | -0.821437 | -- | 0 |
| Hinf1 | 66733.9 | 270.614 | -0.683829 | 7.32322e-13 | 0 |
| Hinf2 | 181871 | 2.10225e+08 | -1 | 1.51214e-11 | 0 |
| PID | 18166.8 | 71544.2 | -0.281516 | 4.19878e-13 | 0 |
| Kmu | 20354.4 | 29440.9 | -0.527374 | 5.88927e-11 | 0 |

Il caso H∞ 2-DoF è grave anche con r=0: Dy=0 elimina il salto istantaneo, ma non impulsi subito dopo il cambio encoder. Poli molto rapidi e guadagni elevati a frequenze finite spiegano perché la sola griglia 2 ms perda quasi tutto il transitorio. La mappa è strettamente propria e tende a zero soltanto oltre quelle dinamiche; una griglia limitata alle frequenze di tracking non basta. Kµ mantiene sensibilità significativa al rumore e impulsi più grandi di quelli registrati a 2 ms. Il PID ha trasmissione diretta elevata: l’RMS immediato per canale è σy*sqrt(sum(Dy(i,:).^2)), mentre la dinamica successiva cambia l’RMS integrato. Non si corregge un segno per rendere più piccolo il grafico: il segno è verificato indipendentemente.

Il rumore encoder entra nel controllore prima dell’azione di comando. Gli attuatori filtrano u prima della coppia fisica, e la meccanica filtra ulteriormente le posizioni: q può apparire regolare mentre u è inaccettabile. Non abbiamo inventato limiti hardware o scambiato N m con rad. Ordine elevato e condizionamento richiedono cautela, ma l’accordo fra realizzazioni coordinate conferma questi picchi nel modello lineare adottato.

### Pesi e compromesso

We/Wu e Mo provengono dalla sintesi consolidata: errore di model following, disturbo fisico e sforzo sulle porte della pianta generalizzata. Il rumore encoder non è un ingresso esplicito di quel problema. W3 non è stato aggiunto. NP/RS/RP e un buon gradino non garantiscono attenuazione misura–comando. Per Kµ l’ordine 78 e gli scaling dinamici non sono, da soli, una spiegazione sufficiente: la mappa effettiva Tuv è l’evidenza quantitativa.

Lo studio Ts=1,2,5,10 ms conserva la varianza dei campioni: cambia la banda del processo mantenuto. `noise_sampling.csv` riporta **soltanto valori agli istanti campionati**, non risolve i picchi continui. Non confrontare quei RMS con una densità bianca continua né usarli per dichiarare il problema risolto. Un filtro posto prima del controllo cambierebbe rumore, fase e margini e richiederebbe verifiche nuove.

## Decisione e passi successivi

Nessuna correzione progettuale è stata adottata: le unità, i segni e le mappe risultano coerenti. Il limite è la formulazione e la risposta alle misure nel modello adottato; la simulazione non dimostra che quei comandi siano erogabili. Una futura sintesi potrebbe includere v e un vincolo pesato Tuv, oppure un filtraggio di misura motivato, verificando nuovamente tracking, disturbo, stabilità interna, RS/RP e rumore. Saturazioni, anti-windup e riduzione restano opzioni teoriche, non interventi applicati agli originali.

Fonti della prova MATLAB isolata: `noise_diagnostics.mat`, `noise_metrics.csv`, `noise_sampling.csv`; figure in `report/figures/final_closure/`.

## Confronto con gli otto Scope eseguiti in R2026b

Tutti gli originali hanno completato caricamento, compilazione e simulazione locale. Gli Scope visuali sono stati letti senza attivare il logging o cambiare alcun parametro del modello. Il formato dei buffer è stato verificato anche sui segnali vettoriali: i due comandi di ciascun ramo H∞ sono intercalati per campione dopo il vettore dei tempi. I dati integrali, le sorgenti dei canali e le metriche sono in `results/data/final_simulink_validation/`.

| Prova | Picco max comando registrato [N m] | RMS massimo tra i due canali [N m] | Feedback encoder selezionato |
|---|---:|---:|---|
| H∞ 2-DoF lineare | 1.72946 | 1.23 | ideale |
| H∞ 2-DoF non lineare | 733230.334 | 21519.988 | rumoroso |
| PID non lineare | 346.631 | 28.4 | rumoroso |
| Kμ lineare | 107.960 | 12.8635 | rumoroso |
| Kμ non lineare | 108.526 | 12.8223 | rumoroso |

H∞ lineare conserva i selettori sulla posizione ideale; H∞ non lineare li conserva sulla misura rumorosa. Tutti e tre i rami H∞ sono attivi in parallelo. La differenza dei comandi tra queste due esecuzioni non misura il solo effetto della meccanica non lineare. I modelli μ usano misure rumorose in entrambi i casi. I selettori non sono stati commutati.

Negli SLX σy=0.05° e Ts=2 ms restano identici al protocollo MATLAB, ma il seed è 20260826. I quattro canali encoder visualizzati contengono la stessa sequenza: correlazione circa uno e RMS vicino a 0.05°. Non vengono descritti come indipendenti. Nella prova MATLAB isolata le sequenze sono indipendenti e il seed è 20261012. Gli SLX applicano insieme riferimento [5°;0] e disturbo link [0.5;0] N m da 1 s, con rumori di processo attivi; la prova isolata usa r=d=w=0 per misurare il solo encoder. L'orizzonte SLX è 10 s, salvo LQG non lineare 4 s. Il confronto è quindi sul fenomeno e sui protocolli, non sull'identità dei valori di picco o RMS.

Le griglie Scope sono non uniformi. H∞ non lineare registra 231384 campioni per segnale, con intervallo massimo circa 1.109 ms; μ usa la propria griglia del solver salvato. Questi campioni mostrano comandi critici, ma non certificano il massimo continuo: un intervallo massimo inferiore a 2 ms non garantisce di risolvere ogni impulso di poche decine di microsecondi. L'RMS Scope è la quadratura trapezoidale dei quadrati sulle durate registrate, per ciascun canale; l'RMS MATLAB della tabella precedente integra la propagazione ZOH e media i due comandi. Non sono la stessa statistica.

Gli attuatori e la meccanica filtrano le richieste prima delle posizioni. Le curve articolari relativamente regolari, l'assenza di NaN/Inf e la stabilità nominale non rendono quei comandi erogabili. La diagnosi delle mappe Tuv/Tqv resta coerente con le simulazioni effettive: H∞ 2-DoF è fortemente sensibile al rumore, μ e PID conservano un limite significativo. Non sono state introdotte mitigazioni; filtraggio motivato, pesatura misura–comando, saturazioni/anti-windup o riduzione richiederebbero un nuovo progetto e nuove verifiche.

## Studio successivo con rumore esplicito — 13.10.2026

I risultati sopra descrivono la baseline e restano validi per quella formulazione. La revisione separata è documentata in Prova_di_Soluzione_Rumore_di_Misura.txt e ACCETTAZIONE_RUMORE_E_ORALE.md, con dati in results/data/noise_redesign. Tre H∞ non superano RS/RP; MuN1 riduce molto il comando e mantiene RS/RP, con offset q1 peggiore e target temporali parziali. Gli otto nuovi run abbinati non sostituiscono quelli precedenti. Baseline predefinita; decisione sull'adozione agli studenti. Il nuovo discorso completo è in presentation/Presentazione_orale.txt.
