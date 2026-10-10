# Evidenze del refactoring didattico

Baseline: main 6133365, prima delle modifiche. `source_baseline.json` contiene
gli SHA-256 originali; `integrity_report.json` confronta i 786 file preesistenti.
`numerical_report.json` registra scarti, variabili Workspace e Code Analyzer
(zero segnalazioni). `test_summary.json` collega le modalità ai log e agli hash.

Le console riportano i test realmente eseguiti. `verify_mu_console.txt` conserva
anche il FAIL preparatorio sui nomi della variabile Ga dopo il PASS delle tre
modalità. La correzione dei soli nomi è verificata da `final_console.txt` e
`final_checks_console.txt`. I risultati dinamici rimangono identici.
`history_console.txt` documenta il campo annidato rpInitial.margin.
Le console sono normalizzate a LF senza spazi finali; righe e numeri sono
conservati. Gli hash del riepilogo normalizzano LF, indipendentemente da Git.

Snapshot sorgente, MAT di confronto e sette PNG sono temporanei, in
tmp/refactor_didactic. La baseline è recuperabile dalla storia Git; i test
in tools/verify_didactic_refactor.py rigenerano tutti i confronti.
