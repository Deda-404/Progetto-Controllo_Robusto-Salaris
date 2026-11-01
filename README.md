# Controllo robusto di un manipolatore SEA a due giunti

Alessio de Dato (635256) e Valerio Rebechi (722224). Revisione definitiva A/B,
1 novembre 2026. Il progetto conserva modello nominale, controllori originali,
indice della relazione e otto modelli Simulink; concentra lo studio sulle
incertezze dei due attuatori.

## Esecuzione

MATLAB R2026b 26.2.0.3386108, Control System Toolbox e Robust Control Toolbox.
Per gli SLX serve Simulink. Dalla radice:

```matlab
run_all                 % verifica rapida; sintesi e campagne onerose caricate
run_all('completa')      % rigenera sintesi, analisi, 150 prove RAS e 28 run SLX
```

Non servono Symbolic Math Toolbox né un Workspace preparato manualmente.
La rapida dichiara i dati caricati e ripete modello, fitting, CARE, campioni,
risposte, rumore e una verifica RAS locale. La completa richiede diversi minuti.
I PASS software e i FAIL scientifici sono distinti nei risultati.

## Percorso operativo unico

| Componente | Funzione |
|---|---|
| run_all.m | Unico ingresso corrente, sette script in ordine |
| File_di_Funzioni_Progetto-Accorpati/modello_sea.m | Equilibrio, meccanica, drive, confronto con main |
| incertezze_attuatori.m | A/B, campioni, LFT, scostamenti, peso |
| progetto_lqg.m; progetto_lqgi.m | CARE, osservatore, integratore e verifiche |
| progetto_hinf_tre_controllori.m | Sensibilità mista, 2-DoF e PID |
| progetto_mu.m | Due D–K e post-analisi a K fissato |
| confronto_ras.m | Dieci impianti comuni, rumore, non lineare e RAS |
| parametri_sea.m | Configurazione unica |
| interconnessione_sea.m; dinamica_sea.m; simula_sea.m | Tre funzioni condivise per i calcoli |
| verifica_sea.m; collaudo_simulink.m | Verifiche scientifiche e SLX |
| dati/banca_validata.mat | Coefficienti originali, provenienza in tools/prepara_banca_definitiva.m |
| risultati/ | Evidenze e grafici del percorso corrente |

I nomi abbreviati della tabella appartengono alla cartella degli script accorpati.
Le funzioni condivise evitano duplicazioni delle equazioni e delle connessioni.
Non si aggiungono al path i vecchi alberi analysis, controllers e src.
Essi conservano campagne M4 e approfondimenti storici, citati come tali nella
relazione; non sono ingressi alternativi del progetto corrente.
Solo quattro helper meccanici di src/model sono richiesti dai MATLAB Function
degli SLX e vengono copiati nella consegna.

## Risultati e limiti

A: frequenza naturale e smorzamento ±10%, indipendenti fra i due attuatori,
quattro ureal. B: due ultidyn SISO indipendenti con peso ricavato dalla stessa
famiglia. Meccanica nominale, ritardo noto 15 ms e Padé comune di ordine uno.
Il fitting di ordine uno copre dinamicamente i 25 casi SISO provati
(max norma normalizzata 0.980392); non dimostra inclusione dell'intero box.

LQG/LQGI mantengono RS su A e B, ma falliscono il costo prestazionale comune.
Hinf2 e i PID falliscono RS. Kmu e MuN1 superano RS/RP su entrambi i modelli.
La D–K A limitata a tre iterazioni fallisce NP; la D–K B supera RS/RP ma
amplifica fortemente il rumore. Non si conclude che cambiare descrizione
migliori fisicamente un controllore fissato.

RAS: 150 prove, 117 convergenze empiriche, 24 mancate convergenze,
9 divergenze osservate, nessun timeout o errore numerico nella campagna finale.
Sono sezioni finite della regione di attrazione, non certificati globali.
I picchi fra campioni mostrano limiti che il solo campionamento a 2 ms nasconde.
Nessuna saturazione hardware è stata inventata.

## Elaborati, consegna e verifiche

- [Relazione PDF](report/Progetto_CR_Relazione_finale.pdf) e [sorgente](report/main.tex).
- [Presentazione PDF](presentation/Progetto_CR_Presentazione.pdf), 23 slide.
- [Discorso aggiornato](presentation/Presentazione_orale.txt) e [tempi stimati](presentation/OUTLINE_AND_TIMING.md).
- [Consegna autonoma ZIP](delivery/Consegna_Progetto_SEA.zip): estrarre e lanciare run_all.
- [Metodo, fonti, risultati e matrice R01–R20](docs/REVISIONE_DEFINITIVA.md).
- [Stato](docs/PROJECT_STATUS.md), [diario](docs/DIARIO_DI_BORDO.md) e [decisioni](docs/DECISION_LOG.md).

Gli otto SLX originali sono invariati. collaudo_simulink assegna il Model
Workspace in memoria, esclude le callback che ripristinerebbero il nominale
e acquisisce gli Scope; chiude senza salvare. Il test corrente dura 2 s
per combinazione. Non equivale a una certificazione hardware o a tutti
gli esperimenti MATLAB. Gli estratti Scope sono diradati; i picchi salvati
e il controllo di finitezza usano l'acquisizione integrale.

Rigenerazione degli elaborati: python tools/esporta_definitiva.py, quindi
pdflatex su report/main.tex e presentation/main.tex (due passaggi), copiando
i PDF ai nomi finali già presenti. python tools/consegna_definitiva.py
confeziona gli stessi sorgenti e verifica SHA-256 e ZIP. Python e LaTeX
servono per modificare gli elaborati, non per usare la consegna.

Drive resta in sola lettura. Il ramo è codex/revisione-definitiva-sea-salaris;
la PR raccoglie il lavoro eseguito e resta da revisionare, senza merge.
