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
