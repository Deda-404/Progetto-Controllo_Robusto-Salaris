function plot_lyapunov_ras(risultati,root)
%PLOT_LYAPUNOV_RAS Confronta sezioni di Lyapunov e prove empiriche.
arguments
    risultati (3,1) cell
    root (1,:) char
end
m8=load(fullfile(root,'results','data','m8_lqg_nonlinear_ras.mat'));
m15=load(fullfile(root,'results','data','m15_nonlinear_robust_validation.mat'));
punti={m8.rasAllPoints,m15.rasResults(1).allPoints,m15.rasResults(2).allPoints};
t=linspace(0,2*pi,361); cerchio=[cos(t);sin(t)];
for tipo=1:2
    f=figure('Visible','off','Color','white','Position',[40 40 1440 500]);
    layout=tiledlayout(f,1,3,'TileSpacing','compact');
    for k=1:3
        r=risultati{k}; nexttile; hold on;
        if tipo==1
            p=punti{k};
            scatter(p.Dq1Deg(p.Convergent),p.Dq2Deg(p.Convergent),20, ...
                [0.1 0.55 0.3],'filled','DisplayName','Simulazioni convergenti');
            scatter(p.Dq1Deg(~p.Convergent),p.Dq2Deg(~p.Convergent),28, ...
                [0.75 0.15 0.1],'x','DisplayName','Non convergenti');
            el=rad2deg(sqrt(r.rhoNumerical)*(chol(r.sectionP)\cerchio));
            plot(el(1,:),el(2,:),'--','Color',[0.75 0.35 0], ...
                'LineWidth',1.8,'DisplayName','Livello campionato (non certificato)');
            xlim([-65 65]); ylim([-65 65]);
        else
            el=rad2deg(sqrt(r.bound.rhoCertified)*(chol(r.sectionP)\cerchio));
            plot(el(1,:),el(2,:),'Color',[0 0.25 0.7], ...
                'LineWidth',2,'DisplayName','Limite analitico sufficiente');
            limite=1.15*max(abs(el),[],'all');
            xlim([-limite limite]); ylim([-limite limite]);
        end
        plot(0,0,'+k','LineWidth',1.5,'MarkerSize',8,'DisplayName','Equilibrio');
        axis square; grid on; box on;
        title(r.name); xlabel('\Delta q_1(0) [deg]'); ylabel('\Delta q_2(0) [deg]');
        legend('Location','southoutside','FontSize',9);
    end
    if tipo==1
        title(layout,'Sezioni z=J\Delta q: confronto numerico con M8/M15');
        nome='lyapunov_ras_comparison.png';
    else
        title(layout,'Zoom sulle regioni interne nominali: limite analitico, non RAS massima');
        nome='lyapunov_ras_certified_sections.png';
    end
    set_scientific_figure_style(f);
    exportgraphics(f,fullfile(root,'results','figures',nome),'Resolution',180);
    close(f);
end
r=risultati{1};
el=rad2deg(sqrt(r.bound.rhoCertified)*(chol(r.sectionP)\cerchio));
f=figure('Visible','off','Color','white','Position',[40 40 620 500]);
plot(el(1,:),el(2,:),'LineWidth',2); hold on; plot(0,0,'+k','MarkerSize',10);
grid on; axis equal;
xlabel('\Delta q_1(0) [deg]'); ylabel('\Delta q_2(0) [deg]');
title('LQG: sezione interna nominale');
set_scientific_figure_style(f);
exportgraphics(f,fullfile(root,'results','figures','lyapunov_lqg_section_slide.png'),'Resolution',180);
close(f);
end
