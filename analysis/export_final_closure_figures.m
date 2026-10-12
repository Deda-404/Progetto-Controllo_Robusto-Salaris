function export_final_closure_figures
%EXPORT_FINAL_CLOSURE_FIGURES Figures from actual final-closure MATLAB data.
d=final_closure_load; folder=fullfile(d.root,'results/data/final_closure');
figures=fullfile(d.root,'report/figures/final_closure'); if ~isfolder(figures),mkdir(figures);end
set(groot,'defaultFigureVisible','off'); cleanup=onCleanup(@()close('all'));
set(groot,'defaultAxesFontSize',10,'defaultLineLineWidth',1.2);
set(groot,'defaultFigureColor','white','defaultAxesColor','white', ...
    'defaultAxesXColor','black','defaultAxesYColor','black','defaultTextColor','black', ...
    'defaultLegendTextColor','black','defaultLegendColor','white');
noise=load(fullfile(folder,'noise_diagnostics.mat')); noise=noise.result;
f=figure('Position',[50 50 1000 700]); tiledlayout(2,2,'TileSpacing','compact');
for k=3:6
    nexttile; rr=noise.runs{k,2};
    plot(rr.time,rr.output(:,3:4)); grid on;
    xlabel('Tempo (s)');ylabel('Contributo encoder a u (N m)'); title(char(d.controllers(k).name));
end
exportgraphics(f,fullfile(figures,'noise_command.png'),'Resolution',200);
f=figure('Position',[50 50 950 430]); tiledlayout(1,2);
nexttile; hold on;
for k=3:6,loglog(noise.diagnostic(k).omega,noise.diagnostic(k).sigmaMaxTuv,'DisplayName',char(d.controllers(k).name));end
set(gca,'XScale','log','YScale','log');grid on;xlabel('Frequenza (rad/s)');ylabel('sigma max T_{uv} (N m/rad)');legend('Location','best');
nexttile; hold on;
for k=3:6
    plot(noise.runs{k,2}.time,rad2deg(noise.runs{k,2}.output(:,1)),'DisplayName',char(d.controllers(k).name));
end
grid on;xlabel('Tempo (s)');ylabel('q_1 (gradi)');legend('Location','best');
exportgraphics(f,fullfile(figures,'noise_frequency_position.png'),'Resolution',200);
f=figure('Position',[50 50 1000 650]);tiledlayout(2,2,'TileSpacing','compact');
for k=3:6
    nexttile;plot(noise.runs{k,2}.time(1:end-1),noise.diagnostic(k).intersamplePeakPerInterval);
    grid on;xlabel('Tempo del campione (s)');ylabel('Massimo fra i campioni (N m)');title(char(d.controllers(k).name));
end
exportgraphics(f,fullfile(figures,'noise_intersample.png'),'Resolution',200);
practical=load(fullfile(folder,'practical_robustness.mat')); practical=practical.result;
f=figure('Position',[50 50 1050 650]); tiledlayout(2,2,'TileSpacing','compact');
for joint=1:2
    for output=1:2
        nexttile(2*(joint-1)+output);hold on;tt=practical.runs{1,2}.trackingTime;
        for p=2:11
            plot(tt,rad2deg(practical.runs{p,2}.tracking{joint}(:,output)),'Color',[.70 .78 .87],'HandleVisibility','off');
        end
        plot(tt,rad2deg(practical.runs{1,2}.tracking{joint}(:,output)),'Color',[0 .35 .60],'LineWidth',1.8,'DisplayName','Kmu nominale');
        plot(tt,rad2deg(practical.runs{1,1}.tracking{joint}(:,output)),'--','Color',[.7 .2 .1],'DisplayName','Hinf2 nominale');
        target=zeros(size(tt)); if joint==output,target(:)=5;end
        plot(tt,target,':k','DisplayName','Riferimento');grid on;
        title(sprintf('Gradino giunto %d: q_%d',joint,output));xlabel('Tempo (s)');ylabel('Posizione (gradi)');
        if joint==1 && output==1,legend('Location','best');end
    end
end
exportgraphics(f,fullfile(figures,'practical_tracking.png'),'Resolution',200);
f=figure('Position',[50 50 1050 650]); tiledlayout(2,2,'TileSpacing','compact');
for joint=1:2
    for output=1:2
        nexttile(2*(joint-1)+output);hold on;tt=practical.runs{1,2}.disturbanceTime;
        for p=2:11
            plot(tt,rad2deg(practical.runs{p,2}.disturbance{joint}(:,output)),'Color',[.70 .78 .87],'HandleVisibility','off');
        end
        plot(tt,rad2deg(practical.runs{1,2}.disturbance{joint}(:,output)),'Color',[0 .35 .60],'LineWidth',1.8,'DisplayName','Kmu nominale');
        plot(tt,rad2deg(practical.runs{1,1}.disturbance{joint}(:,output)),'--','Color',[.7 .2 .1],'DisplayName','Hinf2 nominale');
        grid on;title(sprintf('Disturbo link %d: q_%d',joint,output));xlabel('Tempo (s)');ylabel('Deviazione (gradi)');
        if joint==1 && output==1,legend('Location','best');end
    end
end
exportgraphics(f,fullfile(figures,'practical_disturbance.png'),'Resolution',200);
f=figure('Position',[50 50 1000 440]);tiledlayout(1,2);
nexttile;hold on;
for k=1:2
    dominant=cellfun(@(r)r.maxRealPole,practical.runs(:,k));
    plot(0:10,dominant,'o-','DisplayName',char(practical.controllers(k).name));
end
yline(0,':k','HandleVisibility','off');grid on;xlabel('Impianto (0 = nominale)');ylabel('Massima parte reale dei poli (s^{-1})');legend('Location','best');
nexttile; counts=zeros(2,1);
for k=1:2,counts(k)=sum(cellfun(@(r)r.stable,practical.runs(2:end,k)));end
bar(categorical({'Hinf2','Kmu'}),counts);ylim([0 11]);ylabel('Impianti incerti stabili su 10');grid on;
exportgraphics(f,fullfile(figures,'practical_comparison.png'),'Resolution',200);
% Less crowded views for the 20-minute talk, from the same responses.
for scenario=["tracking","disturbance"]
    f=figure('Position',[50 50 1100 340]);tiledlayout(1,2,'TileSpacing','compact');
    for joint=1:2
        nexttile;hold on;set(gca,'FontSize',13);
        if scenario=="tracking",tt=practical.runs{1,2}.trackingTime;else,tt=practical.runs{1,2}.disturbanceTime;end
        for p=2:11
            y=practical.runs{p,2}.(scenario){joint};
            plot(tt,rad2deg(y(:,joint)),'Color',[.7 .78 .87],'HandleVisibility','off');
        end
        y=practical.runs{1,2}.(scenario){joint};
        plot(tt,rad2deg(y(:,joint)),'Color',[0 .35 .6],'LineWidth',1.8,'DisplayName','Kmu nominale');
        y=practical.runs{1,1}.(scenario){joint};
        plot(tt,rad2deg(y(:,joint)),'--','Color',[.7 .2 .1],'DisplayName','Hinf2 nominale');
        title(sprintf('Ingresso sul giunto %d: q_%d',joint,joint));grid on;
        xlabel('Tempo (s)');ylabel('Posizione (gradi)');
        if joint==1,legend('Location','best');end
    end
    exportgraphics(f,fullfile(figures,"slide_practical_"+scenario+".png"),'Resolution',200);
end
f=figure('Position',[50 50 750 450]);tiledlayout(2,1,'TileSpacing','compact');
for k=[4 6]
    nexttile;plot(noise.runs{k,2}.time(1:end-1),noise.diagnostic(k).intersamplePeakPerInterval);
    title(char(d.controllers(k).name));grid on;xlabel('Tempo (s)');ylabel('Picco tra campioni (N m)');
end
exportgraphics(f,fullfile(figures,'slide_noise_intersample.png'),'Resolution',200);
if isfile(fullfile(folder,'ras_metrics.csv'))
    ras=load(fullfile(folder,'ras_lyapunov.mat')); ras=ras.result;
    f=figure('Position',[50 50 1100 680]);tiledlayout(2,3,'TileSpacing','compact');
    for k=1:6
        nexttile;hold on;r=ras.metrics(string(ras.metrics.Controller)==d.controllers(k).name,:);
        ok=r.Converged; interrupted=contains(string(r.Status),'NUMERIC') | contains(string(r.Status),'SOLVER');
        scatter(r.Q1deg(ok),r.Q2deg(ok),40,[.1 .55 .25],'filled','DisplayName','Convergente');
        scatter(r.Q1deg(~ok & ~interrupted),r.Q2deg(~ok & ~interrupted),45,[.75 .15 .1],'x','DisplayName','Non convergente a 12 s');
        scatter(r.Q1deg(interrupted),r.Q2deg(interrupted),45,[.9 .55 .1],'s','DisplayName','Arresto numerico');
        plot(0,0,'kp','MarkerSize',11,'DisplayName','Equilibrio');
        rectangle('Position',[-60 -60 120 120],'LineStyle',':');xlim([-65 65]);ylim([-65 65]);axis square;grid on;
        title(char(d.controllers(k).name));xlabel('delta q_1 (gradi)');ylabel('delta q_2 (gradi)');
        if k==1,legend('Location','southoutside','FontSize',8);end
    end
    exportgraphics(f,fullfile(figures,'ras_common_grid.png'),'Resolution',200);
end
end
