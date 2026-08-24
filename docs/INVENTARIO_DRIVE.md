# Inventario Google Drive

## Accesso e politica

**Cartella:** `Progetto IS CR`
**URL:** <https://drive.google.com/drive/folders/1LaC9iT9kSUVxR_j8lLfa63vx9Z7_iexb>
**Data verifica:** 2026-08-24
**Esito:** accesso in lettura riuscito tramite il plugin Google Drive
**Politica:** reference only; nessuna operazione di scrittura eseguita

## Struttura principale

```text
Progetto IS CR/
├── CR/
│   ├── Traccia 1 - Sospensione Attiva (1).pdf
│   ├── Traccia 2 - Manipolatore SEA (1).pdf
│   ├── Traccia 3 - Elicottero 2 DoF (1).pdf
│   └── MaterialeColleghi/
│       ├── Report_finale_CR.pdf
│       ├── Progetto_finale_CR.zip
│       └── Progetto_finale_CR/
│           ├── script MATLAB e dataset
│           ├── modelli Simulink
│           └── slprj/              cache generata, non sorgente
└── IS/
```

L'inventario M0 riguarda l'area `CR`. La cartella `IS` non è pertinente alla traccia corrente e non è stata approfondita.

## Sorgenti MATLAB rilevanti

| Path | Tipo | Scopo | Milestone associata | Utilità | Note |
| --- | --- | --- | --- | --- | --- |
| `CR/MaterialeColleghi/Progetto_finale_CR/Parametri_progetto.m` | `.m` | Parametri, equilibrio, condizioni iniziali e salvataggio dataset | M0–M5 | Alta | Contiene scelte del gruppo e una dipendenza finale da dataset \(\mu\) da non replicare |
| `.../Equilibrio.m` | `.m` | Calcolo di \(\bar x,\bar\theta,\bar\tau\) | M2 | Alta | Metodo riutilizzabile, punto non approvato |
| `.../Modello_non_lineare.m` | `.m` | Dinamica non lineare a 8 stati | M1 | Alta | Implementa direttamente le equazioni della traccia |
| `.../Modello_NL_simbolico.m` | `.m` | Versione simbolica della dinamica | M1–M2 | Alta | Usata per Jacobiani |
| `.../Linearizzazione_nominale.m` | `.m` | Equilibrio, Jacobiani, sistema LTI, ranghi e poli | M2 | Alta | Produce `dataset_linearizzazione_nominale.mat` |
| `.../Peso_incertezza_moltiplicativa_attuatori.m` | `.m` | Campionamento attuatori e copertura `ucover` | M3–M4 | Alta | 200 campioni, `WI` ordine 3; contiene una probabile anomalia nella stampa finale |
| `.../Modello_incerto_linearizzato.m` | `.m` | Pianta incerta concentrata o strutturata | M4 | Alta | `m2`, `k1`, `k2` e due alternative per gli attuatori |
| `.../LQG_lineare_nominale.m` | `.m` | LQR, Kalman, integratore e simulazioni nominali | M6–M7 | Alta | Dipende da `dataset_modello_nominale.mat` |
| `.../Hinfinito1_Hinfsyn_Mixsyn.m` | `.m` | `mixsyn`, `hinfsyn` 2-DoF, pesi e confronto | M5, M9–M10 | Alta | Salva `dataset_Hinf_nominali.mat` |
| `.../Hinfinito2_Hinfstruct.m` | `.m` | Sintesi a ordine fissato con `tunableSS` | M11 | Alta | Ordine attivo 10, 50 random starts |
| `.../Mu_Analysis.m` | `.m` | NS, NP, RS, RP con `lftdata`, `mussv`, `robstab`, `robgain` | M12, M14 | Alta | Da ricostruire con test di scaling e struttura |
| `.../Mu_sintesys_DK_iteration.m` | `.m` | D–K iteration con `musyn` | M13 | Alta | Selettori per modello e configurazione pesi |
| `.../Simulazioni_Robustezza_MUSYN.m` | `.m` | Riduzione d'ordine e Monte Carlo | M16–M17 | Alta | 10 campioni, seed 42, tracking/disturbo/sensitività |

## Modelli Simulink

| Path | Tipo | Scopo | Milestone associata | Utilità | Note |
| --- | --- | --- | --- | --- | --- |
| `.../Simulink_LQG.slx` | `.slx` | Implementazione LQG lineare/non lineare e rumori | M6–M8 | Alta | Sorgente Simulink; `.slxc` associato è cache |
| `.../Simulink_Hinf.slx` | `.slx` | Validazione \(H_\infty\), modello non lineare e RAS | M9–M12, M15 | Alta | Esiste anche un `.bak`, non sorgente |
| `.../Simulink_MuSyntesis.slx` | `.slx` | Validazione del controllore D–K sul modello non lineare | M13–M15 | Alta | Nome originale conserva il refuso `Syntesis` |

## Dataset MATLAB

| Path | Tipo | Scopo | Milestone associata | Utilità | Note |
| --- | --- | --- | --- | --- | --- |
| `.../dataset_parametri.mat` | `.mat` | Parametri e stati iniziali | M1–M18 | Alta | Generato da `Parametri_progetto.m` |
| `.../dataset_linearizzazione_nominale.mat` | `.mat` | Matrici LTI e proprietà strutturali | M2 | Alta | Generatore identificato |
| `.../dataset_modello_nominale.mat` | `.mat` | Pianta nominale completa usata da LQG e \(H_\infty\) | M3–M11 | Alta | Generatore non evidente nella cartella principale |
| `.../dataset_peso_incertezza_attuatori.mat` | `.mat` | Peso `WI` e modello attuatore incerto | M4 | Alta | Generato dallo script `ucover` |
| `.../dataset_modello_incerto_concentrata.mat` | `.mat` | Pianta con incertezza dinamica concentrata | M4, M12–M16 | Alta | Generatore identificato |
| `.../dataset_modello_incerto_strutturata.mat` | `.mat` | Pianta con parametri attuatori `ureal` | M4, M12–M16 | Alta | Generatore identificato |
| `.../dataset_Hinf_nominali.mat` | `.mat` | Controllore 2-DoF, pesi e gamma nominale | M9–M12 | Alta | Generato dallo script \(H_\infty\) |
| `.../dataset_MuSynthesis.mat` | `.mat` | Dataset storico/generico di \(\mu\)-synthesis | M13–M14 | Media | Ruolo ambiguo rispetto ai dataset nominati |
| `.../dataset_MuSynthesis_concentrata_originali.mat` | `.mat` | D–K, incertezza concentrata, specifiche originali | M13–M14 | Alta | Risultato del gruppo precedente |
| `.../dataset_MuSynthesis_concentrata_rilassati.mat` | `.mat` | D–K, incertezza concentrata, specifiche rilassate | M13–M17 | Alta | Risultato del gruppo precedente |
| `.../dataset_MuSynthesis_strutturata_originali.mat` | `.mat` | D–K con incertezza completamente strutturata | M13–M14 | Media | File molto grande; controllore di ordine elevato nel report |
| `.../dataset_MuSynthesis_concentrata_rilassati_conflict_copy_Bobby_2026_07_21.mat` | `.mat` | Copia in conflitto | Nessuna | Bassa | Artefatto collaborativo, da non usare come riferimento canonico |

## Documenti e altri artefatti

| Path | Tipo | Scopo | Milestone associata | Utilità | Note |
| --- | --- | --- | --- | --- | --- |
| `CR/Traccia 2 - Manipolatore SEA (1).pdf` | PDF | Specifica ufficiale | Tutte | Vincolante | Letta integralmente |
| `CR/MaterialeColleghi/Report_finale_CR.pdf` | PDF | Relazione del gruppo precedente | M0–M18 | Alta | Riferimento metodologico, non fonte di nostri risultati |
| `CR/MaterialeColleghi/Progetto_finale_CR.zip` | ZIP | Archivio completo del riferimento | M0 | Media | Duplica sostanzialmente la cartella esplorabile; 139,927,806 byte |
| `.../slprj/` | cartella generata | Cache/JIT/Stateflow/Simulink | Nessuna | Nessuna | Contiene `_jitprj`, `_sfprj`, `sim`; non è sorgente |
| `.../*.slxc`, `*.asv`, `*.bak`, `.MATLABDriveTag` | artefatti | Cache, autosave, backup e metadata | Nessuna | Bassa | Da escludere dal nostro repository |

Non sono presenti immagini standalone rilevanti nella radice del progetto; figure e schermate sono incorporate nel PDF o nei modelli. Il Drive non è stato modificato.

## Dipendenze e ordine apparente degli script

```text
Parametri_progetto
  -> Equilibrio
  -> Modello_NL_simbolico / Modello_non_lineare
  -> Linearizzazione_nominale
  -> [generatore non individuato] dataset_modello_nominale
  -> Peso_incertezza_moltiplicativa_attuatori
  -> Modello_incerto_linearizzato
  -> LQG_lineare_nominale
  -> Hinfinito1_Hinfsyn_Mixsyn / Hinfinito2_Hinfstruct
  -> Mu_Analysis
  -> Mu_sintesys_DK_iteration
  -> Simulazioni_Robustezza_MUSYN
```

Questa catena è descrittiva del riferimento e non verrà copiata: il nostro `run_all.m` dovrà rendere le dipendenze esplicite, deterministiche e testate.
