# Analisi del progetto di riferimento

## Scopo e limiti

Il progetto dei colleghi è stato consultato in sola lettura come riferimento metodologico. La relazione di 95 pagine e gli script Drive descrivono un flusso quasi completo da modello non lineare a Monte Carlo. Codice, numeri, controllori e conclusioni non vengono assunti come risultati del nostro progetto.

## Struttura metodologica osservata

1. Parametri, modello non lineare, equilibrio e linearizzazione simbolica.
2. Aggiunta di dinamiche nominali degli attuatori e ritardo Padé.
3. Modelli incerti concentrato e strutturato.
4. LQG con e senza integratore e filtro di Kalman.
5. \(H_\infty\) con `mixsyn`, `hinfsyn` 2-DoF e `hinfstruct` a ordine fissato.
6. \(\mu\)-analysis con decomposizione \(N\)-\(\Delta\).
7. D–K iteration mediante `musyn`.
8. Simulink non lineare, RAS empirica, riduzione d'ordine e Monte Carlo.

## Scelte significative del gruppo precedente

### Equilibrio verticale superiore

**SCELTA DEL GRUPPO:** \(\bar q=[\pi/2,0]^T\), \(\bar\theta=\bar q\), \(\bar\tau=0\).
**MOTIVAZIONE APPARENTE:** configurazione di pendolo inverso, gravitazione nulla nel punto e problema di stabilizzazione non banale.
**DOVE È IMPLEMENTATA:** `Parametri_progetto.m`, `Equilibrio.m`, `Linearizzazione_nominale.m`.
**DA RIUTILIZZARE COME METODO?** Da verificare.
**NOTE:** candidato naturale, ma deve essere confrontato con alternative e approvato dal gruppo.

### Misure di posizione

**SCELTA DEL GRUPPO:** LQG con \(y=[q;\theta]\); sintesi robusta con le sole posizioni dei link \(y=q\).
**MOTIVAZIONE APPARENTE:** encoder di posizione e ricostruzione delle velocità tramite osservatore; riduzione dei canali della sintesi robusta.
**DOVE È IMPLEMENTATA:** `Linearizzazione_nominale.m`, `LQG_lineare_nominale.m`, `Hinfinito1_Hinfsyn_Mixsyn.m`.
**DA RIUTILIZZARE COME METODO?** Sì, come confronto tra configurazioni di misura.
**NOTE:** osservabilità e coerenza tra architetture devono essere rieseguite.

### Dinamica degli attuatori

**SCELTA DEL GRUPPO:** \(\omega_n=30\,\mathrm{rad/s}\), \(\zeta=0.7\), \(\tau_d=20\,\mathrm{ms}\), Padé del primo ordine.
**MOTIVAZIONE APPARENTE:** valori ritenuti compatibili con attuatori industriali e richiesti dalla forma della traccia.
**DOVE È IMPLEMENTATA:** `Parametri_progetto.m`, `Peso_incertezza_moltiplicativa_attuatori.m`, `Modello_incerto_linearizzato.m`.
**DA RIUTILIZZARE COME METODO?** Da verificare.
**NOTE:** valori da sostenere con riferimenti o analisi di sensibilità, non da adottare automaticamente.

### Incertezze

**SCELTA DEL GRUPPO:** \(m_2\) ±10%, \(k_1,k_2\) ±5%; attuatori modellati alternativamente con incertezza moltiplicativa da `ucover` o con parametri `ureal`.
**MOTIVAZIONE APPARENTE:** carico variabile sul secondo link, deriva delle molle e confronto fra descrizione concentrata e strutturata.
**DOVE È IMPLEMENTATA:** `Peso_incertezza_moltiplicativa_attuatori.m`, `Modello_incerto_linearizzato.m`.
**DA RIUTILIZZARE COME METODO?** Sì.
**NOTE:** percentuali e parametri incerti restano da scegliere; lo script conserva anche prove precedenti 15%/10%.

### LQG e azione integrale

**SCELTA DEL GRUPPO:** \(Q_q=100I\), \(Q_i=500I\), \(R=\rho_R I\) e covarianze \(W=V=10^{-8}I\); confronto con e senza integratore.
**MOTIVAZIONE APPARENTE:** privilegiare le posizioni, eliminare offset da disturbo costante e studiare il compromesso autorità/sforzo di controllo.
**DOVE È IMPLEMENTATA:** `LQG_lineare_nominale.m`, `Simulink_LQG.slx`.
**DA RIUTILIZZARE COME METODO?** Sì, non nei valori numerici.
**NOTE:** covarianze nominali prive di caratterizzazione sperimentale; segni e interconnessione del controllore devono essere testati.

### Mixed-sensitivity e architettura 2-DoF

**SCELTA DEL GRUPPO:** peso \(W_1\) sull'errore, \(W_2\) sul comando e controllore 2-DoF \(u=K_1r-K_2y\).
**MOTIVAZIONE APPARENTE:** separare tracking e feedback regolativo e rappresentare limiti prestazionali/attuativi.
**DOVE È IMPLEMENTATA:** `Hinfinito1_Hinfsyn_Mixsyn.m`, `Hinfinito2_Hinfstruct.m`.
**DA RIUTILIZZARE COME METODO?** Sì.
**NOTE:** errore ammesso 8%, banda 0.85 rad/s e limite 70 Nm non sono approvati.

### `hinfstruct` a ordine fissato

**SCELTA DEL GRUPPO:** `tunableSS` 2x4, matrice D bloccata a zero, ordini da 4 a 10 e 50 random starts.
**MOTIVAZIONE APPARENTE:** ridurre la complessità mantenendo la struttura 2-DoF.
**DOVE È IMPLEMENTATA:** `Hinfinito2_Hinfstruct.m`.
**DA RIUTILIZZARE COME METODO?** Sì.
**NOTE:** più partenze non garantiscono l'ottimo globale; \(\gamma>1\) significa che le specifiche pesate non sono interamente soddisfatte.

### \(\mu\)-analysis

**SCELTA DEL GRUPPO:** estrazione con `lftdata`, partizione \(N_{11},N_{12},N_{21},N_{22}\), `mussv`, `robstab` e `robgain`.
**MOTIVAZIONE APPARENTE:** distinguere NS, NP, RS e RP e localizzare canali/frequenze critici.
**DOVE È IMPLEMENTATA:** `Mu_Analysis.m`.
**DA RIUTILIZZARE COME METODO?** Sì.
**NOTE:** la costruzione numerica dei blocchi e la coerenza dei margini richiedono test dedicati.

### D–K iteration e rilassamento

**SCELTA DEL GRUPPO:** `musyn` con `MixedMU`, massimo 5 iterazioni; successivo rilassamento selettivo del canale di disturbo.
**MOTIVAZIONE APPARENTE:** ottenere RS e RP quando il controllore nominale fallisce e diagnosticare l'incompatibilità delle specifiche.
**DOVE È IMPLEMENTATA:** `Mu_sintesys_DK_iteration.m`, dataset `dataset_MuSynthesis_*`.
**DA RIUTILIZZARE COME METODO?** Sì.
**NOTE:** il rilassamento da disturbo unitario a 0.2 deve essere formalizzato come modifica di specifica e approvato.

### RAS e Monte Carlo

**SCELTA DEL GRUPPO:** ricerca empirica in sezioni delle coordinate articolari; 10 campioni `usample` con `rng(42)` e metriche di tracking, banda, sensitività e disturbo.
**MOTIVAZIONE APPARENTE:** confrontare validità locale del modello lineare, capacità di recupero non lineare ed evidenza empirica di robustezza.
**DOVE È IMPLEMENTATA:** modelli `.slx`, `Simulazioni_Robustezza_MUSYN.m`, relazione.
**DA RIUTILIZZARE COME METODO?** Sì.
**NOTE:** servono criteri automatici di convergenza, saturazioni esplicite, tutti i quadranti rilevanti e distinzione fra evidenza Monte Carlo e garanzia \(\mu\).

## File principali per fase

| Fase | File di riferimento |
| --- | --- |
| Parametri/equilibrio | `Parametri_progetto.m`, `Equilibrio.m` |
| Modello non lineare | `Modello_non_lineare.m`, `Modello_NL_simbolico.m` |
| Linearizzazione | `Linearizzazione_nominale.m`, `dataset_linearizzazione_nominale.mat` |
| Attuatori/incertezza | `Peso_incertezza_moltiplicativa_attuatori.m`, `Modello_incerto_linearizzato.m` |
| LQG | `LQG_lineare_nominale.m`, `Simulink_LQG.slx` |
| \(H_\infty\) | `Hinfinito1_Hinfsyn_Mixsyn.m`, `Hinfinito2_Hinfstruct.m`, `Simulink_Hinf.slx` |
| \(\mu\)-analysis | `Mu_Analysis.m` |
| \(\mu\)-synthesis | `Mu_sintesys_DK_iteration.m`, `Simulink_MuSyntesis.slx` |
| Monte Carlo | `Simulazioni_Robustezza_MUSYN.m` |
| Relazione | `Report_finale_CR.pdf` |

## Criticità da non ereditare

1. Non è evidente uno script sorgente che rigeneri `dataset_modello_nominale.mat`, sebbene più script lo richiedano.
2. `Parametri_progetto.m` carica alla fine un dataset di \(\mu\)-synthesis, introducendo una dipendenza circolare e non necessaria nella fase parametri.
3. `Peso_incertezza_moltiplicativa_attuatori.m` contiene una chiamata `disp` non valida e un identificatore `w` non definito nella sezione risultati.
4. L'intestazione dello script \(H_\infty\) cita incertezze 15%/10%/10%, mentre lo script del modello attivo usa 10%/5%/5%.
5. `Mu_Analysis.m` carica anche un dataset generico `dataset_MuSynthesis.mat` prima della selezione effettiva del controllore, rendendo fragile la riproducibilità.
6. I valori `mussv`, `robstab` e `robgain` riportati nella relazione non sono sempre coerenti come scaling; interconnessione e struttura dei blocchi devono essere ricostruite e testate.
7. Il codice Monte Carlo attuale usa come target di riduzione 146 stati, mentre la relazione descrive anche una riduzione a 20 stati: esiste disallineamento codice–relazione.
8. Il disturbo è modellato prevalentemente come additivo di posizione; un disturbo di coppia ai giunti richiede un canale fisico differente.
9. Le funzioni peso sono vincoli morbidi: non sostituiscono una saturazione attuativa esplicita nel modello non lineare.

Queste osservazioni servono a progettare test e architettura originali; non costituiscono una correzione del materiale Drive, che resta immutato.

## Confronto reference-last eseguito in M4

Il confronto M4 è stato svolto il 2026-08-24 soltanto dopo che screening, range, famiglia, fit, pianta incerta, dataset, figure, 14 test M4 e regressioni M0–M3.1 avevano ottenuto un primo PASS indipendente.

Il nostro screening ha selezionato `k2`, `k1`, `Jm1`; il riferimento usa `m2`, `k1`, `k2`. I nostri range baseline sono ±7% sulle rigidezze e ±9% su `Jm1`, mentre il riferimento indica ±5% sulle rigidezze e ±10% su `m2`. La nostra famiglia usa 120 modelli con corner obbligatori e seed 20260824; l'inventario del riferimento indica 200 campioni. Il minimo peso coprente nostro è di ordine 1; il riferimento riporta ordine 3.

La coincidenza parziale sulle due rigidezze conferma soltanto che esse sono dinamicamente rilevanti in entrambe le impostazioni. Le differenze su terzo parametro, percentuali, numerosità e ordine del peso sono state mantenute. Il riferimento ha aiutato a controllare completezza metodologica e ordine di grandezza, non ha modificato l'ensemble M4.
