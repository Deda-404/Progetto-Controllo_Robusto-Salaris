# Stato corrente — 26.10.2026, revisione conservativa SEA fase A

Implementazione e collaudo COMPLETE / PASS. Base main remoto 0ed5611; branch codex/sea-incertezze-revisione-conservativa. LFT manuali meccanica/attuatori, pesi analitici e sei analisi robuste implementati come ramo opzionale; nessuna nuova sintesi, nessuna fase B, nessun merge.

Risultati: NS/NP PASS per tutti; Mu78 e MuN1_82 PASS RS/RP su B parametrico (margini circa 1.26), FAIL su A concentrato. Hinf22 FAIL RS su entrambi; RP/B numerico NON VALIDATO per limiti invertiti, RP esclusa da RS. Bande nominali identiche. I certificati storici restano riferiti al modello moltiplicativo.

8/9 test dedicati e 16/16 regressioni PASS; default µ reale eseguito con tre figure e RNG ripristinato. 261 archivi precedenti invariati. Code Analyzer: solo avviso di ramo opzionale disattivato, effettivamente collaudato. Accettazione scientifica PARTIAL rispetto a tutti gli insiemi e ai target preesistenti, senza occultare i FAIL.

Dettagli: docs/REVISIONE_SEA_INCERTEZZE.md. Dati: results/data/sea_incertezze_conservativa/. Relazione aggiornata e pubblicazione nel commit successivo; decisione sull'integrazione riservata agli studenti.

---

# Stato corrente — 13.10.2026, revisione con rumore

Implementazione, collaudo ed elaborati COMPLETE/PASS; accettazione scientifica PARTIAL. Tre H∞ con rumore esplicito nominalmente stabili ma RS/RP FAIL, nessuna promozione. MuN1 (82 stati) mantiene NS/NP/RS/RP: RS [1.84622,1.88174], RP [1.59634,1.60036]. Picco μ non lineare 108.526→2.25091 N m (48.21 volte), RMS 12.8223→1.35740 (9.446 volte). Rumore encoder isolato: oltre dieci volte in picco/RMS in tutti i tre seed.

Baseline predefinita; MuN1 è una proposta separata. Target temporali ancora parziali, offset q1 8.243% peggiore, reiezione della coppia moderatamente peggiore. Dieci impianti originali: HinfN3 6/10, MuN1 10/10 stabili. RAS MuN1 25/25 convergenze empiriche; gate Lyapunov FAIL. HinfN3 13 convergenze e 12 arresti numerici; solo un livello nominale minimo accreditato.

R2026b locale: quattro script identici, 141/141 regressioni e 7/7 test dedicati PASS; otto run baseline/candidato sui quattro SLX interessati. Identità del Workspace salvata e controllata; 197 MAT/SLX precedenti e otto hash di provenienza invariati. I run baseline storici restano intatti. Nuove evidenze in results/data/noise_redesign/.

Relazione 108 pagine e 23 slide compilate/auditate; schemi autentici lineare/non lineare e confronto Scope. Due TXT completi, 2237 parole pronunciate, 18:47 stimati con cambi slide, Alessio 9:27 e Valerio 8:36. Prova dal vivo ancora necessaria. Nuovo pacchetto Consegna_SEA_Rumore_Orale_2026-10-13 con preparazione_studenti distinta; precedente consegna conservata.

Branch codex/sintesi-robusta-rumore-e-orale-finale da main a4b3817, PR #40 già integrata. [PR #41](https://github.com/Deda-404/Progetto_CR/pull/41) aperta in bozza, ramo pubblicato con otto oggetti LFS (232 MB). Nessun merge eseguito nella revisione. Prossimo passo degli studenti: revisionare evidenze e PR, decidere l'adozione, provare il discorso; servono dati di targa e dinamica reale dei motori per valutare l'hardware.

---

## Stati registrati in precedenza

# Stato del progetto — 6 ottobre 2026

Branch `codex/revisione-lqgi-hinf-mu`, base origin/main 283193e con PR #34 integrata. Nessun merge automatico nella revisione corrente.

Revisione MATLAB, risultati, relazione e presentazione: **COMPLETE / PASS**. Architettura LQGI verificata e nomenclatura corrente coerente; nuovo simulatore non lineare con quattro encoder, errore misurato integrato e rumori di processo non osservati direttamente. Kalman M6, guadagni/costi M7, controllori robusti, pesi e incertezze invariati.

Ultima verifica: **112/112 test MATLAB PASS**, sette nuovi test. Dieci sorgenti LQGI controllati dal Code Analyzer: zero segnalazioni. Baseline di 172 file MATLAB: due segnalazioni preesistenti di crescita array, non critiche, nei vecchi esportatori/RAS. Audit di 85 artifact protetti: byte invariati. Sei SLX corrispondenti al proprio SHA-256.

Nuovi risultati: sei tracking e sei disturbi non lineari LQGI, tre esperimenti di rumore con ripetizione identica, corrispondenti chiusure lineari ZOH esatte. Scarto massimo lineare/non lineare nelle prove di rumore 4.6870e-5 rad. RAS LQGI: 57/57 punti, 57 simulazioni, zero estensioni, raggi minimo 60 gradi e massimo 78.3244; box esaurito, non frontiera fisica. Comando massimo 240.2349 N m senza saturazioni.

Confronto Mo 2/3/4 ricalcolato dai controllori salvati: norme 0.0305405/0.0312036/0.0474606, tempi 2.918/1.944/1.460 s. Tutti falliscono il target temporale; 4 minimizza la violazione secondo il criterio reale, non la norma. Nessuna nuova hinfsyn, hinfstruct, musyn, ricerca robusta o Monte Carlo.

Relazione **83 pagine**, presentazione **19 slide / 17:45**, appendice con 29 estratti letterali / 228 righe MATLAB. Audit PDF PASS: zero errori, riferimenti irrisolti, overflow o destinazioni duplicate. Parti modificate e tutte le slide controllate visivamente. Figure 8.2, 8.4, 8.6 e Tabella 8.4 mantengono i numeri richiesti.

Esiti consolidati:

- LQG: tracking nominale soddisfatto. LQGI: DC del disturbo nullo nel lineare, tracking lento; nuove prove MATLAB distinte da Simulink.
- H∞: NS/NP PASS, RS FAIL; RP numerica non validata ed esclusa da RS. Monte Carlo 0/40.
- Kµ: NS/NP/RS/RP PASS nel modello dichiarato; target temporali parziali, Monte Carlo 40/40. Ordine 78, margini RS circa 1.80 e RP circa 1.68.

**Simulink PARTIAL / NOT RUN:** sei originali invariati, R2026a e non caricabili in R2025b. Audit statico e istruzioni per integratore sull'errore rumoroso, disturbo link, quattro rumori, attuatori e H∞ a quattro ingressi. Nessun originale Kµ disponibile; nessun sostituto generato o simulazione accreditata.

Conformità complessiva **PARTIAL** per Simulink e target prestazionali dichiarati. Prossimo passo: aprire gli originali in R2026a o esportarli da quella versione verso R2025b; applicare e verificare `docs/CORREZIONI_SIMULINK_LQGI.md`; completare i dati del frontespizio e la prova orale cronometrata.

Resoconto: docs/RESOCONTO_REVISIONE_LQGI_HINF_MU.md. Evidenze: docs/coherent_review/, results/data/coherent_review/, results/data/lqgi_validation/. Le vecchie voci del diario e delle decisioni restano cronologia append-only.

## 2026-10-10 — Raccolta MATLAB per revisione

File_di_Funzioni_Progetto-Accorpati contiene i quattro script LQG, LQGI, H∞ e µ,
con istruzioni per esecuzione e dipendenze. Branch dedicato da main 8e8de25:
codex/file-funzioni-progetto-accorpati. Stato organizzativo COMPLETE / PASS;
revisione e decisione sul merge in attesa del gruppo.

Copie verificate tramite SHA-256, contenuto LQG/LQGI equivalente agli allegati,
percorsi dei dati coerenti con la nuova collocazione. Nessun cambiamento alle
versioni consegnate o ai risultati scientifici. Nessuna nuova validazione
numerica: restano gli esiti e i limiti preesistenti, stato complessivo PARTIAL.

## 2026-10-10 — Modelli Drive importati in Simulink

simulink/drive_project e drive_project_manifest.json: COMPLETE / PASS per
importazione e integrità statica. Fonte Drive condivisa, 37/37 file:
cinque archivi SLX e cartella H∞ non lineare con 32 componenti. Nuove versioni
LQG/LQGI lineari/non lineari; H∞ coincide con gli originali già disponibili.
Tutti i pacchetti registrano R2026a Update 4.

Verificati dimensioni provider, cinque CRC ZIP, SHA-256 e identità dei sei
originali preesistenti. Nessuna modifica del contenuto dei modelli o conversione
di release. Simulazioni NOT RUN; nuovi LQG/LQGI non ancora validati in Simulink,
nessun certificato trasferito dalle versioni precedenti. Stato complessivo
PARTIAL invariato. Branch codex/simulink-drive-aggiornamento da main a502609,
con PR #36 già integrata, in attesa di revisione e decisione sul merge.

## 2026-10-10 — Script didattici H∞/μ: COMPLETE / PASS

Branch codex/refactoring-didattico-hinf-mu da main 6133365 (PR #36/#37
integrate). H∞ 458 righe, μ 461, 13 sezioni ciascuno; MAT esistenti e sole
funzioni ausiliarie PID. Run dall'Editor senza preparare il Workspace.
Default, archivi e risintesi verificati in MATLAB R2025b Update 4;
ABCD e risultati prima/dopo identici, scarto zero nella regressione finale.
778 file protetti invariati. LQG/LQGI, dati, modelli, relazione e presentazione
conservati; nessuna nuova validazione Simulink o non lineare. Stato generale
PARTIAL invariato. Prossimo passo: revisione della PR, decisione sul merge.
Dettagli: docs/RESOCONTO_REFACTORING_DIDATTICO.md.

## 2026-10-12 — Chiusura scientifica in corso

Otto originali correnti disponibili e integri. Audit ZIP/XML PASS; caricamento R2025b FAIL per release, simulazioni NOT RUN. Nuove prove MATLAB di rumore e dieci impianti incerti eseguite; consolidamento RAS, test e PDF in corso. Stato complessivo PARTIAL. Nessun merge su main.

## 2026-10-12 — Diagnosi conclusiva MATLAB e confini scientifici

Branch codex/chiusura-definitiva-progetto-sea. Aggiunti runner esterni senza sintesi o riduzioni: sette scenari di rumore, propagazione ZOH fra campioni e doppia realizzazione; dieci nuovi impianti fisici incerti comuni più nominale, seed 20261012 e replay esatto; Lyapunov nello stato intero e griglia comune 150 punti. H∞ 2-DoF: picco encoder osservato 492784.658 N m, RMS integrato 13196.215; Kµ 87.096/8.288. Instabilità H∞ in 10/10 piante incerte, Kµ stabile 10/10. LQG/LQGI/Kµ 25/25 punti empirici; H∞1 23/25; H∞2 24 arresti numerici; PID 18 timeout del solver, tutti distinti da mancata convergenza fisica. Solo LQG/LQGI superano il gate numerico Lyapunov.

141/141 test MATLAB PASS, inclusi hash otto originali, setup bus, esiti RAS ignoti e condizioni per i livelli Lyapunov. Quattro default didattici PASS, Code Analyzer senza messaggi; 80 artifact fisici/controllori congelati identici. Corrette asserzioni sul conteggio storico SLX e singleton finale delle ss-array. Setup Simulink esterno, originali mai modificati. Gate analisi/test COMPLETE/PASS; prestazioni operative rumore FAIL; validazione SLX PARTIAL/NOT RUN per release R2026a. Documento e PDF in consolidamento, nessun merge.

## 2026-10-12 — Elaborati finali e manifest per revisione

Relazione 97 pagine e presentazione 21 slide compilate con audit PASS: zero errori, riferimenti indefiniti, destinazioni duplicate o contenuti fuori pagina. Esaminate tutte le slide e le pagine modificate dei Capitoli 9–11; sistemati colori delle esportazioni MATLAB e viste per l’orale. Scaletta verificata per somma: 17:50, 18:20 con slide autentica opzionale. Rimossa dal PDF la precedente campagna 40 campioni; nuovo Capitolo 11 con dieci impianti, nominale, tre figure e tabelle tracking/disturbo.

Prodotti REPORT_VERIFICA_SIMULINK, ANALISI_RUMORE_MISURA, CHIUSURA_FINALE_PROGETTO, checklist studenti e manifest di 237 file con SHA-256 portabili per i testi ed esatti per i binari. Dipendenze MATLAB rilevate (30) integrate con path dinamici e funzioni embedded. Archivio preservato; cache Python escluse. Controlli originali 8/8 PASS, 141/141 test PASS, quattro default e 80 artifact protetti PASS. Commit scientifici 27ad0db ed e880327. Nessun nuovo controllore o cambiamento SLX.

Stato documentale COMPLETE/PASS; validazione SLX PARTIAL/NOT RUN e immagini autentiche da completare su R2026a. Rumore e target temporali restano limiti scientifici dichiarati; 18 casi PID e 24 H∞2 numericamente ignoti sulla griglia. Branch pronto per revisione; nessun merge su main.
