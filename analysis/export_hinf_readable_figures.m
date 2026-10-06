function audit=export_hinf_readable_figures
%EXPORT_HINF_READABLE_FIGURES Confronto Mo e figure 8.4/8.6, senza risintesi.
root=fileparts(fileparts(mfilename('fullpath')));
a=load(fullfile(root,'results/data/hinf_final_coherent/nominal_study.mat'));
study=a.study;q=study.selected;c=q.config;
out=fullfile(root,'results/data/coherent_review');if ~isfolder(out),mkdir(out);end
rows=zeros(3,12); evaluations=cell(3,1);
for k=1:3
    r=study.two{k};
    e=hinf_final_evaluate(study.physical,r.K,r.W1,r.W2,r.Mo,study.spec,c,r.architecture);
    assert(max(abs(e.metrics-r.e.metrics),[],'all')<1e-9,'Mo:Reproduction','Le metriche salvate non si riproducono.');
    assert(max(abs(e.disturbanceMetrics-r.e.disturbanceMetrics),[],'all')<1e-9);
    v=max(e.metrics,[],1);
    % Banda del solo modello desiderato: non banda effettiva del feedback.
    modelBand=r.omegaM*sqrt(sqrt(2)-1);
    modelTs=fzero(@(t)(1+r.omegaM*t)*exp(-r.omegaM*t)-.02,[0,20/r.omegaM]);
    rows(k,:)=[r.omegaM,e.norms(1),v(1),v(2),100*v(3),v(4:6), ...
        e.m5Failures,max(1,max(e.m5Ratios)),modelBand,modelTs];
    evaluations{k}=e;
end
metrics=array2table(rows,'VariableNames',{'OmegaMRadSec','WeightedNorm','SettlingSec', ...
    'OvershootPercent','TrackingErrorPercent','CrossCoupling','PeakUNm','RmsUNm', ...
    'M5Failures','MaximumNormalizedViolation','ModelBandwidthRadSec','ModelSettlingSec'});
assert(study.selected.architecture=="2DOF" && study.selected.omegaM==4);
audit=struct('metrics',metrics,'evaluations',{evaluations}, ...
    'selectionRanking',study.selectionRanking,'selectionIndex',study.selectionIndex, ...
    'selectedOmegaM',4,'synthesisRepeated',false,'source',"hinf_final_coherent/nominal_study.mat");
save(fullfile(out,'omegaM_comparison.mat'),'audit','-v7');writetable(metrics,fullfile(out,'omegaM_comparison.csv'));
fid=fopen(fullfile(root,'report/generated/omegaM_comparison.tex'),'w');assert(fid~=-1);cleanup=onCleanup(@()fclose(fid));
fprintf(fid,'%% Ricalcolato da export_hinf_readable_figures.m, nessuna nuova sintesi.\n');
fprintf(fid,'\\begin{center}\\small\\begin{tabular}{rrrrrrr}\\toprule\n');
fprintf(fid,'$\\omega_M$ & norma pesata & $T_s$ [s] & OS [\\%%] & $e_{ss}$ [\\%%] & picco $u$ & RMS $u$ \\\\\n\\midrule\n');
for k=1:3,fprintf(fid,'%.0f & %.6g & %.4g & %.4g & %.5g & %.5g & %.5g \\\\\n',[rows(k,1:5),rows(k,7:8)]);end
fprintf(fid,'\\bottomrule\\end{tabular}\\end{center}\n');clear cleanup
folder=fullfile(root,'report/figures/hinf_final');
blue=[.07,.28,.53];orange=[.78,.32,.10];green=[.12,.48,.31];
f=figure('Visible','off','Color','w','Position',[50 50 1100 1140]);tiledlayout(3,1,'TileSpacing','compact','Padding','compact');
nexttile;hold on;localSigma(q.e.S,c.omega,blue,'-');localSigma(study.one{1}.e.S,c.omega,orange,'--');
ylabel('sigma_{max}(S_y) [dB]');legend('2-DoF: S_y=(I-GK_y)^{-1}','1-DoF iniziale: S','Location','southwest');
title('Feedback: amplificazione dell''errore di posizione');localAxes;
nexttile;hold on;localSigma(q.e.KS,c.omega,blue,'-');localSigma(study.one{1}.e.KS,c.omega,orange,'--');
ylabel('sigma_{max}(KS) [dB rif. 1 N m/rad]');legend('2-DoF: (-K_y)S_y','1-DoF iniziale: KS','Location','southwest');
title('Richiesta di comando per deviazione di posizione');localAxes;
nexttile;hold on;localSigma(q.e.weighted,c.omega,blue,'-');
localSigma(q.e.weighted(1:2,:),c.omega,orange,'--');localSigma(q.e.weighted(3:4,:),c.omega,green,':');
yline(0,'-.k','Soglia unitaria','HandleVisibility','off');
ylabel('Guadagno numerico pesato [dB]');legend('T_{zw} completo','Canali di errore pesato','Canali di comando pesato','Location','southwest');
title('Problema 2-DoF: ingresso [r;d], uscita [z_e;z_u]');localAxes;
localSave(f,'frequency_diagnostics.png',folder,root);
f=figure('Visible','off','Color','w','Position',[50 50 1250 750]);tiledlayout(2,2,'TileSpacing','compact','Padding','compact');
dc=dcgain(q.e.disturbance);
for j=1:2
    y=q.e.disturbanceResponses{j};
    nexttile(j);hold on;
    plot(c.time,rad2deg(y(:,1)),'Color',blue,'LineWidth',1.9);
    plot(c.time,rad2deg(y(:,2)),'--','Color',orange,'LineWidth',1.8);
    yline(rad2deg(dc(1,j)*study.spec.disturbanceTorqueAmplitude),':','Color',blue,'HandleVisibility','off');
    yline(rad2deg(dc(2,j)*study.spec.disturbanceTorqueAmplitude),':','Color',orange,'HandleVisibility','off');
    grid on;xlim([0 c.time(end)]);xlabel('Tempo [s]');ylabel('Deviazione articolare [deg]');
    title(sprintf('r=0; disturbo costante d_%d=0.5 N m',j));legend('q_1','q_2','Location','best');
    nexttile(j+2);hold on;
    plot(c.time,y(:,3),'Color',blue,'LineWidth',1.9);
    plot(c.time,y(:,4),'--','Color',orange,'LineWidth',1.8);
    grid on;xlim([0 c.time(end)]);xlabel('Tempo [s]');ylabel('Comando incrementale [N m]');legend('u_1','u_2','Location','best');
end
localSave(f,'disturbance_positions_commands.png',folder,root);
disp(metrics);
end
function localSigma(system,w,color,style)
sv=sigma(system,w);semilogx(w,20*log10(max(sv,[],1)),'Color',color,'LineStyle',style,'LineWidth',1.8);
end
function localAxes
set(gca,'XScale','log');grid on;xlabel('Frequenza angolare [rad/s]');xlim([1e-3 1e4]);
end
function localSave(f,name,folder,root)
set_scientific_figure_style(f);exportgraphics(f,fullfile(folder,name),'Resolution',210);close(f);
out=fullfile(root,'results/figures/hinf_readable');if ~isfolder(out),mkdir(out);end
copyfile(fullfile(folder,name),fullfile(out,name));
end
