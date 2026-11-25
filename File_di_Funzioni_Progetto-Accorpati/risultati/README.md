# Risultati

Tutti i file sono prodotti dagli script della cartella superiore e corrispondono alla configurazione identificata dalla firma `p.firma` (versione 3) di `parametri_sea.m`: m2 = 0.8 kg ±10 %, ωn ±15 %, τd ±20 %, ζ noto, pesi We/Wu/Mo del Capitolo 6. Gli script rifiutano un MAT con firma diversa o con controllori diversi da quelli correnti.

## Per capitolo

| Capitolo | File | Prodotto da |
|---|---|---|
| 2–4 Modello | `modello.mat`, `candidati_massa.csv`, `sensibilita_attuatori.csv`, `nominale.png`, `sensibilita_singoli_parametri.png` | `modello_sea` |
| 5 Incertezze | `incertezze.mat`, `forme_incertezza.csv`, `ordini_peso.csv`, `peso_incertezza.png`, `famiglia_attuatori.png` | `incertezze_attuatori` |
| 6 Specifiche | `candidati_specifiche.csv`, `candidati_riferimento.csv`, `candidati_ritardo.csv` (studio delle soglie) | campagne precedenti, conservate |
| 7 LQG/LQGI | `lqg.mat`, `lqgi.mat`, `kalman.csv`, `lqg_lqgi_*.png`, `lineare_nonlineare_lqg.png` | `progetto_lqg_lqgi` |
| 8 H∞ | `sintesi_hinf.mat`, `hinf.csv`, `sensibilita_hinf.png`, `hinf_disturbi.png` | `progetto_hinf_tre_controllori` |
| 9 µ e D–K | `sintesi_mu.mat`, `dk_1.csv`, `dk_2.csv`, `riesame_mu.csv`, `studio_mu_riferimento/`, `robustezza.png` | `progetto_mu` |
| 9, 12 Robustezza | `confronto_robusto_r.csv/.mat` (mappa Tzr, ufficiale), `confronto_robusto.csv/.mat` (mappa Tz[r;d]), `confronto_robusto_rd.csv/.mat` e `mappa_completa_nominale.csv` (mappa Tz[r;d] con MuN1) | `progetto_mu` |
| 10–11 Validazione | `dieci_impianti.csv/.png`, `parametri_dieci_impianti.csv`, `rumore.csv`, `nonlineare.csv`, `massa_nonlineare.csv`, `simulink.csv`, `simulink_autonomo.csv` | `confronto_ras`, `collaudo_simulink` |
| 12 RAS | `ras.csv`, `ras.mat`, `ras.png` | `confronto_ras` |
| Verifiche | `verifiche.csv` (8 controlli), `esecuzione_rapida.txt` (log), `riassunto_numerico.json` | `run_all`, `verifica_sea` |

## Come leggere le colonne di robustezza

`NS`, `NP`, `RS`, `RP` seguono le definizioni del Capitolo 9. `RS_lower/upper` e `RP_*_lower/upper` sono i limiti dei margini (robstab, robgain): > 1 → PASS, < 1 → FAIL, a cavallo di 1 → INCONCLUDENTE. `MetodoRP = NP_FAIL` indica che RP è FAIL perché fallisce già la prestazione nominale; `LIMITE_DA_RS` indica che RP è limitata dal margine RS < 1. In questi due casi il margine RP non viene calcolato.

## Evidenze datate

- `verifica_numerica_20261104.txt`, `verifica_modellazione_20261104.txt`: campagna completa del 4 novembre 2026, MATLAB R2026b.
- `esecuzione_rapida.txt`: ultimo log della modalità rapida (la release è riportata nella prima riga).
- `confronto_robusto.csv` è la mappa riferimento–disturbo calcolata il 4 novembre per i sette controllori; `confronto_robusto_rd.csv` la ripete includendo MuN1 quando viene eseguita la modalità completa.
