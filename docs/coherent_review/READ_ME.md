# Evidenze della revisione del 6 ottobre 2026

L'inventario iniziale contiene 692 file Git letti e sottoposti a hash prima delle modifiche. baseline_inventory.json conserva percorsi, dimensioni, hash e riferimenti. coherence_audit.json, prodotto da tools/audit_coherent_revision.py, verifica artifact M1–M6, risultati robusti adottati e SLX; registra dipendenze LaTeX e figure realmente utilizzate. nomenclature_occurrences.csv distingue nomi SLX di provenienza, generatore storico disabilitato e documentazione cronologica dalle denominazioni attive. Esiti MATLAB in results/data/coherent_review/.

Analisi preliminare di traccia ufficiale, pipeline corrente, report e materiale pertinente del Drive. Nel riferimento dei colleghi sono stati letti report, tredici sorgenti MATLAB e inventari di undici MAT, inclusi modelli, controllori e matrici; tre SLX ispezionati staticamente. Nel riferimento non è presente una presentazione autonoma. Cache, slprj e archivi duplicati classificati come derivati. Nessun testo, controllore, figura o risultato dei colleghi è stato importato.

Trovati tre originali lineari del gruppo, precedentemente indicati come assenti. ID Drive e hash nel manifest dei sei SLX; copie locali identiche al download. Tre originali non lineari già presenti invariati. Audit XML con differenze precise per blocchi/SID rispetto alla chiusura MATLAB. original_models_audit.json conserva sei errori di versione, zero simulazioni.

Pipeline adottata:

- M3/M5/M6/M7 → LQGI a 16 stati di controllore → 30 stati chiusi → validation.mat / ras.mat → esportazione → Capitoli 7 e 10 / slide.
- nominal_study.mat → tre controllori Mo → stesse prove → omegaM_comparison → confronto del §8.4.1.
- nominal_study.mat / robust_study.mat / fixed_study.mat in hinf_final_coherent → figure, tabelle e spiegazioni dei Capitoli 8–9, senza nuova sintesi.

Manifest M18, risultati M9–M17 precedenti, organic_review e lqri_r_verification costituiscono materiale datato; il nome LQRI in tali archivi non identifica una seconda implementazione corrente. Le rinomine non riscrivono il diario. Il nuovo audit identifica le fonti effettivamente incluse nei PDF.

Verifica visiva di tutte le 19 slide e delle pagine PDF 32–46, 49–58, 62–67 e 78–83 della relazione. Schema LQGI corretto dopo il rendering per rimuovere una sovrapposizione sul collegamento encoder; PDF finale ricompilato e auditato. Si conservano gli esiti negativi intermedi nel diario.
