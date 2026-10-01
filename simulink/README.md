# Modelli originali

La cartella originals contiene esclusivamente i tre SLX originali di Valerio, invariati rispetto ai pacchetti condivisi. manifest.json conserva SHA-256 e origine locale del download; i file *_inventory.json conservano l'ispezione XML.

Il file chiamato LQR contiene osservatore e retroazione dello stato stimato (LQG).
I modelli sono R2026a: R2025b ne blocca il caricamento. Nessuna simulazione originale è validata.

setup_original_models restituisce i dati MATLAB e il bus già richiesto dagli originali. Non modifica o salva gli SLX. Per Hinf interrompe il setup con un errore esplicito: l'originale usa un errore a due canali, il controllore finale ha quattro ingressi [r;q].

Vedere docs/organic_review/AUDIT.md per disturbo lato link, rumori, integratore e collegamenti da completare manualmente, e per i modelli Kmu/linearizzato mancanti. Non sono forniti generatori o modelli sostitutivi.
