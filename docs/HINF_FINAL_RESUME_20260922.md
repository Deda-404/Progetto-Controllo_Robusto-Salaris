# Ripresa della revisione coerente, 22 settembre 2026

Branch: `codex/hinf-final-coherent-revision`; base: `693e316`.
Stato: **IN CORSO**, nessun merge. Responsabile: Alessio.

La campagna nominale e quella strutturata erano terminate prima
dell'interruzione. Anche la campagna D-K ha terminato le cinque iterazioni:
objective finale migliore circa 0.8838; post-analisi Kmu con margine RS
[1.7998, 1.80442] e margine RP [1.67717, 1.68066]. Questi numeri provengono
da `results/data/hinf_final_coherent/robust_study.mat`, non dalla baseline.

Il candidato Hinf 2DoF selezionato ha norma circa 0.0474606, tracking nominale
senza overshoot e assestamento 1.46 s. M5 resta FAIL (target 0.8 s).
La sua stabilità robusta peggiora nettamente: margine [0.0181249, 0.0181617].
Il solver RP restituisce estremi invertiti [0.0172543, 0.0171945], anche
dopo un secondo controllo con `MussvOptions='m9'`: questo intervallo non
è validato. RP non può comunque essere soddisfatta se RS fallisce.
Non si scambiano gli estremi per ottenere un intervallo apparentemente valido.

All'avvio della ripresa MATLAB ha restituito errore MathWorks 5201.
Il riavvio del solo MathWorks Service Host ha ripristinato MATLAB R2025b
Update 4 e la disponibilità del Robust Control Toolbox. Non sono state
modificate licenze, impostazioni di sicurezza o installazioni.

Sono avviati Monte Carlo paired e Lyapunov. Gli script della nuova catena
salvano in una directory distinta, preservando gli artifact precedenti.
La conversione del modello Simulink richiede inoltre la dichiarazione delle
librerie prevista dalla skill locale; domanda inviata, in attesa di risposta.
I sorgenti e il PDF precedenti sono archiviati in
`report/archive/before_final_coherent/` prima della revisione editoriale.

Rimangono da completare: simulazioni non lineari/RAS, revisione del PDF,
test finali della catena, resoconto, commit e pubblicazione del branch.

Chiusura successiva: NL, rumore e RAS completati con integrazione MATLAB delle equazioni originali; 18 test PASS. La copia Simulink non è stata realizzata. Esiti e limiti definitivi nel RESOCONTO_HINF_FINAL_COHERENT_REVISION.md.
