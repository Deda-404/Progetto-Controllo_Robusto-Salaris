function capture_final_robustness
%CAPTURE_FINAL_ROBUSTNESS Preserve complete current-release margin values.
root=fileparts(fileparts(mfilename('fullpath')));
set(groot,'defaultFigureVisible','off');
analisi={};confronto=table();
run(fullfile(root,'File_di_Funzioni_Progetto-Accorpati/progetto_mu.m'));
root=fileparts(fileparts(mfilename('fullpath')));
evidence=struct('release',version('-release'),'version',version, ...
    'source','progetto_mu.m, default analysis on unchanged stored controllers', ...
    'Hinf_RS',analisi{1}.RS,'Hinf_RP',analisi{1}.RP, ...
    'Mu_RS',analisi{2}.RS,'Mu_RP',analisi{2}.RP);
folder=fullfile(root,'results/data/final_simulink_validation');
save(fullfile(folder,'robustness_R2026b.mat'),'evidence','analisi','confronto','-v7');
f=fopen(fullfile(folder,'robustness_R2026b.json'),'w');cleanup=onCleanup(@()fclose(f));
fprintf(f,'%s',jsonencode(evidence,PrettyPrint=true));
figure('Visible','off','Theme','light','Color','w','Position',[100 100 1000 400]);
tiledlayout(1,2,'Padding','compact');
nexttile;bar([evidence.Hinf_RS.LowerBound evidence.Hinf_RS.UpperBound; ...
    evidence.Mu_RS.LowerBound evidence.Mu_RS.UpperBound]);yline(1,'k--');grid on;
xticklabels({'Hinf 2-DoF','Kmu'});ylabel('Margine RS');legend('Lower bound','Upper bound','Location','northwest');
nexttile;bar([evidence.Mu_RP.LowerBound evidence.Mu_RP.UpperBound]);yline(1,'k--');grid on;
xticklabels({'Kmu'});ylabel('Margine RP');title('Hinf: intervallo RP non validato');
exportgraphics(gcf,fullfile(root,'report/figures/final_simulink/robust_margins_R2026b.png'),'Resolution',180);
close all;
end
