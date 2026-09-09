function tablePaths = build_technical_revision_tables(root)
%BUILD_TECHNICAL_REVISION_TABLES Numeri LaTeX dagli script effettivamente eseguiti.
arguments
    root (1,1) string = string(fileparts(fileparts(fileparts(mfilename('fullpath')))))
end
dati=fullfile(root,'results','data'); destinazione=fullfile(root,'report','generated');
l=load(fullfile(dati,'didactic_lqg_calculations.mat'));
h=load(fullfile(dati,'didactic_hinf_calculations.mat'));
y=load(fullfile(dati,'lyapunov_ras_nominal.mat'));
t=load(fullfile(dati,'lyapunov_trajectories.mat'));
m6=load(fullfile(dati,'m6_lqg_no_integrator.mat'));
assert(norm(l.K-m6.K,'fro')<1e-6 && norm(l.L-m6.L,'fro')<1e-6, ...
    'Revision:ControllerIdentity','Gli script non riproducono M6.');
f=fopen(fullfile(destinazione,'lqr_matrices.tex'),'w');
chiudi=onCleanup(@() fclose(f));
fprintf(f,'%s\n','% Generato da build_technical_revision_tables, non modificare.', ...
    '\[Q=\operatorname{blkdiag}(Q_8,0_{6\times6}),\qquad R=\tfrac{1}{9}I_2.\]', ...
    '{\small');
scriviMatrice(f,'Q_8',l.Q(1:8,1:8));
fprintf(f,'%s\n','\[K=[K_a\ K_b],\quad K_a=K(:,1{:}7),\quad K_b=K(:,8{:}14).\]');
scriviMatrice(f,'K_a',l.K(:,1:7)); scriviMatrice(f,'K_b',l.K(:,8:14));
scriviMatrice(f,'N_r',l.Nr);
fprintf(f,'%s\n','}'); clear chiudi
f=fopen(fullfile(destinazione,'kalman_matrices.tex'),'w');
chiudi=onCleanup(@() fclose(f));
fprintf(f,'%s\n','{\small'); scriviMatrice(f,'L',l.L);
fprintf(f,'%s\n','}'); clear chiudi

f=fopen(fullfile(destinazione,'kalman_sensitivity_fixed.tex'),'w');
chiudi=onCleanup(@() fclose(f));
fprintf(f,'%s\n','\begin{table}[H]\centering\small', ...
    '\begin{tabular}{rrrrr}\toprule', ...
    '$\sigma_{y,ass}/\sigma_y$ & $\alpha_e/\alpha_c$ & RMS $e_q$ [rad] & RMS $\Delta u$ [N m] & $\|G_{v\to C_{cost}e}\|_2$ \\', ...
    '\midrule');
for k=1:3
    r=l.sensibilita(k,:);
    fprintf(f,'%.2g & %.5g & %.5g & %.5g & %.5g \\\\\n', ...
        r.fattori,r.velocita,r.erroreRms,r.comandoRms,r.normaH2);
end
fprintf(f,'%s\n','\bottomrule\end{tabular}', ...
    '\caption{Sensibilit\`a a parit\`a di rumore applicato: seed 20260826, $\sigma_y=0.05^\circ$, passo 2 ms, 4 s. Varia solo $R_n$ assunto.}\label{tab:kalman-fixed}', ...
    '\end{table}'); clear chiudi

f=fopen(fullfile(destinazione,'lqg_poles.tex'),'w');
chiudi=onCleanup(@() fclose(f));
fprintf(f,'%s\n','\begin{table}[H]\centering\small', ...
    '\begin{tabular}{rrrr}\toprule', ...
    '$\Re\lambda(A-BK)$ & $\Im\lambda(A-BK)$ & $\Re\lambda(A-LC)$ & $\Im\lambda(A-LC)$ \\', '\midrule');
for k=1:numel(l.poliLqr)
    fprintf(f,'%.6g & %.6g & %.6g & %.6g \\\\\n', ...
        real(l.poliLqr(k)),imag(l.poliLqr(k)),real(l.poliKalman(k)),imag(l.poliKalman(k)));
end
fprintf(f,'%s\n','\bottomrule\end{tabular}', ...
    '\caption{Poli in s$^{-1}$. Le due coppie di colonne elencano spettri distinti; le righe non associano un modo del regolatore a uno dello stimatore.}', ...
    '\end{table}'); clear chiudi

f=fopen(fullfile(destinazione,'lyapunov_summary.tex'),'w');
chiudi=onCleanup(@() fclose(f));
fprintf(f,'%s\n','\begin{table}[H]\centering\small', ...
    '\begin{tabular}{lrrrrr}\toprule', ...
    'Controllore & $n_z$ & $\max\Re\lambda(A_{cl})$ & $\lambda_{\min}(P)$ & $\lambda_{\max}(P)$ & $\|E_L\|_2$ \\', '\midrule');
for k=1:3
    r=y.risultati{k}; b=r.bound;
    fprintf(f,'%s & %d & %.5g & %.5g & %.5g & %.3g \\\\\n', ...
        r.name,size(r.Acl,1),max(real(eig(r.Acl))),b.lambdaMinP,b.lambdaMaxP,b.residualNorm);
end
fprintf(f,'%s\n','\bottomrule\end{tabular}', ...
    '\caption{Lyapunov sul sistema completo: $E_L=A_{cl}^TP+PA_{cl}+I$. Calcolo in doppia precisione.}', ...
    '\end{table}', ...
    '\begin{table}[H]\centering\small','\begin{tabular}{lrrrrr}\toprule', ...
    'Controllore & $\|PE\|_2$ & $\rho_a$ analitico & $\rho_s$ campionato & $\max\dot V/\|z\|^2$ & Punti ricerca \\', '\midrule');
for k=1:3
    r=y.risultati{k};
    fprintf(f,'%s & %.5g & %.5g & %.5g & %.5g & %d \\\\\n', ...
        r.name,r.bound.normPE,r.bound.rhoCertified,r.rhoNumerical,r.maxValidationRatio,r.searchPointCount);
end
fprintf(f,'%s\n','\bottomrule\end{tabular}', ...
    '\caption{Il massimo riportato usa gli 8192 punti della verifica indipendente. Solo $\rho_a$ deriva dalla maggiorazione analitica; $\rho_s$ non \`e certificato.}', ...
    '\end{table}'); clear chiudi

f=fopen(fullfile(destinazione,'lyapunov_sections.tex'),'w');
chiudi=onCleanup(@() fclose(f));
for k=1:3
    r=y.risultati{k};
    fprintf(f,'%s\n','\paragraph{'+r.name+'}');
    scriviMatrice(f,'H=J^TPJ',r.sectionP);
    raggi=rad2deg(sqrt(r.bound.rhoCertified./eig(r.sectionP)));
    fprintf(f,'I semiassi della sezione interna sono %.5g e %.5g gradi. ',min(raggi),max(raggi));
    fprintf(f,'Il raggio euclideo garantito nello stato completo \\`e %.5g.\n',r.bound.stateRadius);
end
clear chiudi

f=fopen(fullfile(destinazione,'revision_values.tex'),'w');
chiudi=onCleanup(@() fclose(f));
nomi=["RevQs";"RevQds";"RevDeltaScale";"RevCareResidual";"RevRegulatorDecay"; ...
    "RevEstimatorDecay";"RevSeparation";"RevRn";"RevCubicBound";"RevHinfCrossover"; ...
    "RevTrajectoryFinalV";"RevTrajectoryIncrement"];
valori=[l.qs;l.Sx(3,3);l.Sx(5,5);norm(l.residuoCare,'fro'); ...
    min(-real(l.poliLqr));min(-real(l.poliKalman));l.erroreSeparazione;l.Rn(1,1); ...
    y.risultati{1}.bound.c;h.crossoverW1;max(t.tabella.rapportoFinaleV); ...
    max(t.tabella.maxIncrementoRelativo)];
for k=1:numel(nomi)
    fprintf(f,'\\newcommand{\\%s}{\\num{%0.7g}}\n',nomi(k),valori(k));
end
clear chiudi
sourceArtifact=[repmat("results/data/didactic_lqg_calculations.mat",8,1); ...
    "results/data/lyapunov_ras_nominal.mat";"results/data/didactic_hinf_calculations.mat"; ...
    repmat("results/data/lyapunov_trajectories.mat",2,1)];
sourceField=["qs";"Sx(3,3)";"Sx(5,5)";"norm(residuoCare,'fro')"; ...
    "min(-real(poliLqr))";"min(-real(poliKalman))";"erroreSeparazione"; ...
    "Rn(1,1)";"risultati{1}.bound.c";"crossoverW1"; ...
    "max(tabella.rapportoFinaleV)";"max(tabella.maxIncrementoRelativo)"];
writetable(table(nomi,valori,sourceArtifact,sourceField), ...
    fullfile(destinazione,'revision_numeric_audit.csv'));
tablePaths=fullfile(destinazione,["lqr_matrices.tex";"kalman_matrices.tex"; ...
    "kalman_sensitivity_fixed.tex";"lqg_poles.tex"; ...
    "lyapunov_summary.tex";"lyapunov_sections.tex"]);
f=fopen(fullfile(destinazione,'kalman_slide.tex'),'w');
chiudi=onCleanup(@() fclose(f));
fprintf(f,'%s\n','\begin{tabular}{rrr}\toprule', ...
    'Fattore $\sigma_y$ & $\alpha_e/\alpha_c$ & RMS $\Delta u$ \\', '\midrule');
for k=1:3
    fprintf(f,'%.2g & %.3f & %.4f \\\\\n', ...
        l.sensibilita.fattori(k),l.sensibilita.velocita(k),l.sensibilita.comandoRms(k));
end
fprintf(f,'%s\n','\bottomrule\end{tabular}', ...
    '\par\scriptsize RMS in N m, passo 2 ms, 4 s, seed 20260826.\small');
end

function scriviMatrice(f,nome,M)
fprintf(f,'%s\n','\[',string(nome)+'=\begin{bmatrix}');
for k=1:size(M,1)
    fprintf(f,'%s\n',string(strjoin(compose('%.5g',M(k,:)),' & '))+" \\");
end
fprintf(f,'%s\n','\end{bmatrix}','\]');
end
