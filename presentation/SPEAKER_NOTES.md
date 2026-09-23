# Note aggiornate

Le prime10slide conservano fisica e LQG/LQRI. Da Hinf valgono i risultati PR32:gamma0.04746,ordine22,RS negativo; Kmu78stati,RS/RP>1 e40/40 campioni stabili. Non usare i dati della versione archiviata.
Gamma<1 riguarda il problema pesato, non garantisce il tracking M5. Nel2-DoF riferimento e misura entrano separatamente con stati condivisi.
Aprire setup_lqg_simulink: mostrare8stati meccanici,6attuatori e14stimati. Lo stato vero non è feedback. Rumore misura4componenti; wd link, eta_u prima degli attuatori. Qn/Rn di lqe non equivalgono esattamente alle varianze dei generatori ZOH.
Confrontare LQG/LQRI con disturbo0.5Nm da1s fino20s. Nr non reagisce al disturbo; xi integra r-q_mis e compensa l'offset. M7 resta PARTIAL rispetto a M5.
Mostrare Hinf/Kmu con ingresso[r;q], senza vecchio r-q, prefiltro o Kalman aggiuntivo. Kmu mantiene78stati.
I67controlli e7test PASS certificano solo le verifiche implementative dichiarate. Le prove rumore0.5s non annullano il grave picco Hinf della campagna4s. Hardware, saturazione, code generation e replay R2026a non verificati. Originali R2026a preservati, copie realmente eseguite su R2025b.
