# Chiusura finale del progetto SEA

Collaudo locale del 13.10.2026 sul branch `codex/validazione-finale-matlab-simulink`, basato su main `14359392bd8cde5249fae91a050cfba8c79eacd4`. Responsabile: Alessio. Nessun merge automatico.

## VALIDAZIONE SIMULINK R2026a — ESECUZIONE LOCALE

I modelli R2026a Update 4 sono stati eseguiti nella release effettivamente installata, **R2026b 26.2.0.3386108**, Windows locale, `C:\Program Files\MATLAB\R2026b`. Simulink, Control System, Robust Control e Symbolic Math Toolbox 26.2 disponibili. Ambiente verificato da terminale, senza conversioni o mescolamento di toolbox tra release.

Gli otto file hanno superato caricamento, compilazione, simulazione e valutazione dei segnali. Orizzonte 10 s, salvo LQG non lineare 4 s. I tre rami H∞ sono eseguiti in parallelo; nessun selettore è stato commutato. SHA-256 identici prima/dopo e al manifest, 8/8. Nessun warning numerico acquisito. Dettagli, hash, percorsi, metriche e sorgenti per ogni modello in `REPORT_VERIFICA_SIMULINK.md` e `results/data/final_simulink_validation/`.

## Test e confronto scientifico

141/141 test MATLAB PASS in R2025b e R2026b, nessuno incompleto. Quattro script consegnati eseguiti nelle due release; Code Analyzer dei quattro script senza messaggi e 80 file fisici/controllori congelati invariati. Il primo run R2026b ha prodotto 140/141: confronto K/L con tolleranza assoluta 1e−12, scarti di pochi 1e−11. Corretto soltanto quel test a AbsTol/RelTol 1e−10; restano verifiche di Riccati, residui, poli e dimensioni. Il fallimento è conservato in `matlab_tests_R2026b_first.csv/.mat`.

LQG resta sotto disturbo con offset medio q1 circa 4.14° nel lineare. LQGI lo riduce a circa 0.0181° a tempo finito, con assestamento lento. H∞ lineare seleziona misure ideali: non è una prova del rumore encoder. H∞ non lineare seleziona misure rumorose e il 2-DoF registra circa 7.33×10^5 N m. Kμ registra circa 108 N m nel lineare e 109 N m nel non lineare. Posizioni relativamente regolari non implicano comando implementabile. Tutti i campioni acquisiti sono finiti; i picchi sono osservati, non massimi continui certificati.

Il Capitolo 9 mantiene la distinzione ordine/ampiezza e NS/NP/RS/RP. I limiti numerici H∞ RS non coincidono tra release: circa [0.018129,0.018166] in R2025b, [0.026154,0.026207] nel run R2026b a precisione stampata. RS resta FAIL; l’intervallo RP invertito resta non validato. Non viene dichiarata equivalenza numerica di questi intervalli. I margini Kμ RS≈1.80 e RP≈1.68 e le conclusioni qualitative sono riprodotti. Gli artifact scientifici conservati non sono sovrascritti; gli elaborati usano i margini del collaudo R2026b quando riportano questa analisi.

Il Capitolo 10 conserva lo stato aumentato completo, la RAS comune (25 punti per controllore) e gli esiti numericamente ignoti. LQG/LQGI superano il gate Lyapunov con insiemi interni molto piccoli; nessun certificato viene attribuito ai quattro casi con gate fallito. Nessuna nuova RAS fittizia viene attribuita agli SLX.

Il Capitolo 11 conserva dieci impianti incerti comuni più nominale, seed 20261012: H∞ 0/10 stabili, Kμ 10/10. Le traiettorie instabili non ricevono metriche di tracking valide. Campionamento e incertezze invariati; Monte Carlo non è un certificato μ.

## Gate

| Gate | Esito tecnico | Evidenza |
|---|---|---|
| A ambiente | PASS | R2026b compatibile, prodotti, quattro script e 141 test |
| B otto SLX | PASS | load/compile/sim 8/8, porte, orizzonte, hash |
| C dinamica | PASS | Scope autentici, 12 combinazioni, unità e limiti dichiarati |
| D scienza | PASS con limiti prestazionali | rumore, RS/RP, RAS e dieci piante coerenti; differenze numeriche tra release dichiarate |
| E relazione | PASS | 100 pagine, audit LaTeX senza errori/overflow e controllo visivo di tutte le pagine; schemi reali e dati Scope |
| F presentazione | PASS | 22 slide controllate, audit senza errori/overflow, schema e curve autentiche, stima 18:45 |
| G repository | PASS | branch e otto oggetti LFS pubblicati; PR #40 aperta, 350 hash manifest PASS, nessun merge |

Sette gate su sette superati: 100% del collaudo richiesto, supportato da test, simulazioni, integrità, audit PDF e pubblicazione. Questa percentuale non esprime il soddisfacimento di tutti i target o una validazione hardware.

## Problemi risolti e limiti

R2026b inizialmente conteneva solo MATLAB/Copilot: i test di licenza erano positivi ma i prodotti non erano installati. Installati localmente i quattro prodotti necessari; configurata una JVM esterna supportata. Il download della configurazione mpm ha restituito HTTP 403; utilizzato il contenuto della configurazione ufficiale già acquisito, dopo autorizzazione esplicita dell’utente.

Il logging Scope rimane disattivato. Il lettore dei buffer ha inizialmente incontrato i segnali vettoriali a due componenti; il formato corretto è tempo contiguo e valori intercalati. Individuata una prima separazione delle componenti non corretta tramite il comando iniziale fisicamente impossibile del secondo canale. Corretto il decoder, recuperati gli stessi campioni originali senza modificare o risimulare inutilmente i modelli e verificato con stato iniziale nullo/feedthrough PID; effettuato anche un nuovo run H∞ lineare col lettore finale. I numeri intermedi non sono usati negli elaborati.

La API visuale è interna e specifica di R2026b; in altre release il runner restituisce errore e le istruzioni indicano Print to Figure. Il rumore attivo ha canali encoder correlati, a differenza della prova MATLAB isolata. Non sono aggiunti filtri, saturazioni, modifiche di pesi o nuove sintesi. L’RMS dei comandi da Scope dipende dalla quadratura dei campioni e non è un integrale continuo certificato.

## Consegna riproducibile

Cartella e ZIP Consegna_SEA_2026-10-13: 327 file, 392200933 byte compressi. Verifica SHA-256 di tutti i file copiati e dentro lo ZIP PASS; otto originali invariati. Audit in delivery/package_audit.json. Inclusi i dataset RAS letti dai default e results/figures; escluso il grezzo delle traiettorie Lyapunov inutilizzato. Quattro script eseguiti da copia isolata dei materiali selezionati: 4/4 PASS, Code Analyzer zero e 15 dataset protetti invariati. La verifica integrale separata protegge 80 artifact. Evidenza in delivery/portable_scripts_audit.json.

## Elaborati e azioni degli studenti

Alessio de Dato, matricola 635256; Valerio Rebechi, matricola 722224; data 13.10.2026. Relazione: `report/Progetto_CR_Relazione_finale.pdf`, 100 pagine. Presentazione: `presentation/Progetto_CR_Presentazione.pdf`, 22 slide, 18:45 stimati. Schemi autentici: otto viste generali e tre sottosistemi; curve complete di otto run e vista orale μ. Tutte le 100 pagine e le 22 slide sono state controllate visivamente; frontespizio, didascalie e grafici nominali rietichettati sono stati ricontrollati dopo la compilazione finale. Zero errori LaTeX, riferimenti irrisolti, overflow o destinazioni duplicate negli audit generated/*latex_audit.txt. Le 13 figure nominali sono rigenerate dai dati congelati con etichette descrittive, senza riferimenti a fasi pregresse.

Restano la prova orale cronometrata, la revisione umana della PR e la decisione sul merge. Limiti scientifici da esporre: rumore H∞/μ, target temporali falliti, casi RAS ignoti e assenza di saturazioni/dati hardware. Nessun modello va modificato per presentare un esito più favorevole.

## Pubblicazione conclusa

PR #40: https://github.com/Deda-404/Progetto_CR/pull/40, aperta per revisione su main, senza merge. Branch codex/validazione-finale-matlab-simulink pubblicato con gli otto oggetti LFS (171 MB). Commit di collaudo ca0f64d e di elaborati/consegna 266782e. Stato remoto verificato sul secondo commit, PR senza conflitti e base 14359392 invariata; il commit di chiusura registra il gate G. ZIP e PDF finali restano identici agli audit di consegna.

## Studio successivo con rumore esplicito — 13.10.2026

I risultati sopra descrivono la baseline e restano validi per quella formulazione. La revisione separata è documentata in Prova_di_Soluzione_Rumore_di_Misura.txt e ACCETTAZIONE_RUMORE_E_ORALE.md, con dati in results/data/noise_redesign. Tre H∞ non superano RS/RP; MuN1 riduce molto il comando e mantiene RS/RP, con offset q1 peggiore e target temporali parziali. Gli otto nuovi run abbinati non sostituiscono quelli precedenti. Baseline predefinita; decisione sull'adozione agli studenti. Il nuovo discorso completo è in presentation/Presentazione_orale.txt.
