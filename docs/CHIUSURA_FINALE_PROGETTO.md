# CHIUSURA FINALE PROGETTO

Revisione del 12 ottobre 2026 su `codex/chiusura-definitiva-progetto-sea`, base main fa78e588. Branch dedicato, nessun merge o force-push. GitHub è la fonte del progetto; Drive è stato letto senza scritture.

## Gate e prontezza

| Ambito | Stato | Evidenza |
|---|---|---|
| Otto originali | COMPLETE / PASS | CRC, byte e tre SHA-256 coincidenti |
| Audit XML e setup | COMPLETE / PASS statico | Inventario, segni, interfacce, matrici e bus esterni |
| Simulazione SLX | PARTIAL / NOT RUN | R2026a richiesto, R2025b rifiuta tutti gli otto |
| Script didattici | COMPLETE / PASS | Quattro default eseguiti; 80 file scientifici protetti identici; Code Analyzer senza messaggi |
| Test MATLAB | COMPLETE / PASS | 141/141 passati, nessuno incompleto |
| Rumore | COMPLETE come diagnosi; requisito operativo FAIL | Picchi continui critici H∞ e sensibilità Kµ; nessuna attenuazione artificiale |
| Dieci impianti incerti | COMPLETE / PASS come campagna | Replay, intervalli, blocchi normati; H∞ 0/10, Kµ 10/10 stabili |
| RAS e Lyapunov | COMPLETE come audit; limiti numerici espliciti | Stato intero, 150 punti, distinzione empirico/analitico/ignoto |
| Relazione e slide | Compilazione e ispezione in audit PDF | Capitoli 9–11 consolidati, slide 21, stima 17:50 |
| Prontezza finale | PARTIAL | Validazione e schermate originali R2026a ancora essenziali |

## Risultati conservati e nuove prove

Parametri, equilibrio, Padé, matrici nominali, pesi, incertezze, Kalman M6, LQG/LQGI e controllori robusti restano invariati. Le norme e i margini sono stati nuovamente verificati dal default dei quattro script, senza nuove sintesi. H∞ 2-DoF conserva ordine 22 e Kµ 78; tracking, rumore e robustezza pesata sono proprietà diverse.

La nuova campagna pratica campiona dieci piante fisiche con usample, seed 20261012, e aggiunge il nominale. Le realizzazioni e i parametri sono salvati; nessun riuso dei quaranta campioni. H∞ nominale è stabile, tutti i suoi campioni instabili. Kµ è stabile in tutti gli undici. Per gli instabili i tempi e gli altri indicatori sono NaN; non si accreditano risposte divergenti come prestazioni. Gradini separati di 5 gradi, disturbo link 0.5 N m da 1 s; tempi finiti, DC, accoppiamento, comando e recupero ±0.5 gradi sono distinti.

La diagnosi isolata encoder usa r=d=w=0, σ=0.05 gradi, ZOH 2 ms e 4 s. H∞ presenta picco fra campioni circa 492785 N m e RMS integrato 13196.2; Kµ 87.0963 e 8.28793. Il picco è osservato su scansione, non certificato globale. La doppia realizzazione e la quadratura raffinata concordano. Feedthrough H∞ nullo non elimina i modi molto rapidi.

## RAS comune e gate Lyapunov

Griglia 5×5 su ±60 gradi, δtheta=δq, velocità/attuatori/controller nulli; 12 s e ultimo secondo entro 0.5 gradi, 0.02/0.05 rad/s. Arresti per ampiezza o solver non sono prove di divergenza. PID usa ode15s in coordinate bilanciate dopo difficoltà con ode23t/ode15s originali; gli altri ode23t. Ogni punto ha un budget di 60 s di calcolo, indipendente dal tempo fisico; superarlo lascia ignota la convergenza.

| Controllore | Conv. / 25 | Criterio a 12 s fallito | Arresti/solver/tempo | Gate Lyapunov | Livello interno ρ |
|---|---:|---:|---:|---|---:|
| LQG | 25 | 0 | 0 | PASS | 1.01346e-12 |
| LQGI | 25 | 0 | 0 | PASS | 8.21719e-13 |
| Hinf1 | 23 | 2 | 0 | FAIL | -- |
| Hinf2 | 1 | 0 | 24 | FAIL | -- |
| PID | 3 | 4 | 18 | FAIL | -- |
| Kmu | 25 | 0 | 0 | FAIL | -- |

La matrice Lyapunov è calcolata nello stato aumentato completo. Positività, residuo assoluto e margine prudente di arrotondamento precedono qualsiasi livello interno; il gate richiede residuo+allowance<1e−6. Il resto cubico SEA è maggiorato analiticamente. I livelli ammessi sono sufficienti per il nominale non limitato in double controllata, non prove intervallari o hardware. Gli insiemi LQG/LQGI sono molto piccoli e non sono ingranditi nel confronto grafico. Le ricerche radiali consolidate hanno un protocollo distinto; non si sommano ai nuovi 25 punti.

## Documenti e consegna

Il Capitolo 9 spiega l'ordine elevato, 14 stati di pianta più pesi/Mo e scaling D–K. Il Capitolo 10 presenta RAS, Lyapunov, gate e rumore fra campioni in modo didattico. Il Capitolo 11 sostituisce integralmente la precedente trattazione Monte Carlo con i dieci impianti: stabilità, tracking e disturbo, tre figure e tabelle dai risultati effettivi. Appendici e presentazione seguono gli stessi dati; non narrano lo sviluppo delle revisioni. I quattro script finali e i file storici scientificamente necessari sono conservati.

La presentazione ha 21 slide e stima 17:50. La slide autentica LQGI è condizionale all'esportazione R2026a e aggiunge 0:30. Note orali e scaletta sono aggiornate; il tempo effettivo richiede prova del gruppo. Le miniature SLX non leggibili sono materiale interno, non figure accreditate.

`delivery/manifest.json` elenca i materiali correnti, le dipendenze e gli hash; i documenti interni non sono l'elaborato da inviare al docente. Le regressioni storiche mantengono dati necessari ai test: non sono risultati del nuovo Capitolo 11. La checklist elenca R2026a, verifica delle tracce, figure autentiche, matricole/data e prova orale.

## Problemi incontrati e corretti

Il primo test storico contava ricorsivamente anche i nuovi SLX invece dei soli sei d'archivio: limitato correttamente a originals/, con otto nuovi test SHA separati. La nuova asserzione sulla dimensione della ss-array non considerava il singleton finale restituito da MATLAB: verificati separatamente i due canali, i quattro ingressi e i dieci elementi. Entrambi i difetti di test sono corretti e il run finale passa.

Il primo controllo d'integrità dei quattro script includeva anche il file derivato m7_disturbance_comparison rigenerato dal plotting: conservati separatamente i modelli/controllori congelati e ripristinati gli output derivati del run. Il controllo finale su 80 artifact scientifici è passato. Problemi iniziali di allocazione struct nei nuovi runner sono corretti; solo i run riusciti sostengono le conclusioni. PID non lineare resta numericamente difficile; timeout e arresti sono esiti ignoti, non classificazioni fisiche inventate.

## Giudizio finale

Il branch è pronto per revisione scientifica e integrazione manuale. Gli elaborati sono riproducibili nei limiti dichiarati e mantengono risultati negativi. Non si dichiara completata la validazione Simulink richiesta dalla traccia: servono gli otto run e le immagini reali su R2026a. Non si dichiara pronto il controllo per hardware: rumore, saturazioni non modellate e target temporali falliti sono limiti effettivi. La chiusura documentale non equivale al superamento di tutti i requisiti prestazionali.

## Audit dei PDF compilati

`report/generated/report_latex_audit.txt`:

```text
STATUS=PASS
JOB=Progetto_CR_Relazione_finale
ERRORS=0
UNRESOLVED_REFERENCES=0
OVERFULL_HBOX=0
OVERFULL_VBOX=0
DUPLICATE_DESTINATIONS=0
Pages:           97
PDF=C:\Users\aless\OneDrive - University of Pisa\Documenti\ChatGPT\Progetto_CR&IS\Progetto_CR_chiusura\report\Progetto_CR_Relazione_finale.pdf
```

`presentation/generated/presentation_latex_audit.txt`:

```text
STATUS=PASS
JOB=Progetto_CR_Presentazione
ERRORS=0
UNRESOLVED_REFERENCES=0
OVERFULL_HBOX=0
OVERFULL_VBOX=0
DUPLICATE_DESTINATIONS=0
Pages:           21
PDF=C:\Users\aless\OneDrive - University of Pisa\Documenti\ChatGPT\Progetto_CR&IS\Progetto_CR_chiusura\presentation\Progetto_CR_Presentazione.pdf
```

Controllate visivamente tutte le slide e le pagine modificate dei Capitoli 9–11. Corretti pannelli troppo fitti, fuoriuscite e colori esportati dal tema scuro MATLAB. Il testo estratto dal PDF non contiene i conteggi obsoleti 40/40, 0/40, 37/40 o la vecchia diagnosi combinata del rumore.
