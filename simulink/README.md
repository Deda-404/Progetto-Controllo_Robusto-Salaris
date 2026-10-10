# Modelli originali

La cartella `originals` conserva i sei SLX già archiviati, invariati:
tre `Progetto_*_simulink.slx` e tre modelli lineari. `originals/manifest.json`
registra SHA-256 e provenienza; i file `*_inventory.json` conservano l'ispezione XML.

Il file chiamato LQR contiene osservatore e retroazione dello stato stimato (LQG).
I modelli sono R2026a: R2025b ne blocca il caricamento. Nessuna simulazione originale è validata.

setup_original_models restituisce i dati MATLAB e il bus già richiesto dagli originali. Non modifica o salva gli SLX. Per Hinf interrompe il setup con un errore esplicito: l'originale usa un errore a due canali, il controllore finale ha quattro ingressi [r;q].

Vedere docs/organic_review/AUDIT.md per disturbo lato link, rumori, integratore e collegamenti da completare manualmente, e per i modelli Kmu/linearizzato mancanti. Non sono forniti generatori o modelli sostitutivi.

## Importazione del Drive del progetto — 10 ottobre 2026

`drive_project/` riproduce integralmente i file della
[cartella Drive condivisa](https://drive.google.com/drive/folders/1wDiaAQVR7cDDt7T8WUlyZ0vgEa-2LWLx).
I dati sono stati scaricati in sola lettura e non modificati.

| Elemento | Tipo | Risultato del confronto con `originals/` |
| --- | --- | --- |
| `LQG_linear_sim.slx` | Archivio SLX | Nuova versione, nome originale conservato |
| `LQG_nonlinear_sim.slx` | Archivio SLX | Nuova versione, nome originale conservato |
| `LQGI_linear_sim.slx` | Archivio SLX | Nuova versione, nome originale conservato |
| `LQGI_nonlinear_sim.slx` | Archivio SLX | Nuova versione, nome originale conservato |
| `Hinf_linear_sim.slx` | Archivio SLX | SHA-256 identico al file già archiviato |
| `Hinf_nonlinear_sim.slx/` | Cartella con SLX estratto | 32/32 componenti identici a `Progetto_Hinf_simulink.slx` |

Sul Drive, `Hinf_nonlinear_sim.slx` è realmente una **cartella**, con XML,
Stateflow, thumbnail e altri componenti. La struttura estratta è mantenuta
senza ricomprimerla o presentarla come un nuovo modello eseguibile. Per il
medesimo contenuto in formato SLX è già disponibile
`originals/Progetto_Hinf_simulink.slx`.

`drive_project_manifest.json` registra URL/ID Drive, dimensione, data di
modifica e SHA-256 di ciascuno dei 37 file. Le dimensioni corrispondono ai
metadati Drive; i cinque archivi superano il controllo CRC ZIP. I sei originali
precedenti conservano i propri SHA-256. `.gitattributes` preserva i byte dei
file importati senza conversioni delle terminazioni di riga.

La release registrata nei pacchetti è **R2026a Update 4**. Questo intervento
verifica l'importazione e l'integrità statica: simulazione **NOT RUN**.
`setup_original_models.m` riguarda ancora i modelli precedenti in `originals/`;
non trasferisce automaticamente setup o certificazioni alle nuove versioni.
Le istruzioni storiche in `docs/CORREZIONI_SIMULINK_LQGI.md` si riferiscono
ai sei originali precedenti, non costituiscono un audit dei nuovi LQG/LQGI.
