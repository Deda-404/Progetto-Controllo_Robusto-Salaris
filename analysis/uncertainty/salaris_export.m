function salaris_export
%SALARIS_EXPORT Pochi grafici direttamente dai risultati della revisione.
d=final_closure_load; source=fullfile(d.root,'results/data/salaris_revision');
destination=fullfile(d.root,'report/figures/salaris_revision');
if ~isfolder(destination),mkdir(destination);end
a=load(fullfile(source,'models.mat')); m=a.models;
f=figure('Visible','off','Color','w','Theme','light');
loglog(m.coverage.Omega,m.coverage.EnvelopeB,'LineWidth',1.5); hold on;
loglog(m.coverage.Omega,m.coverage.WeightA,'LineWidth',1.5);
loglog(m.coverage.Omega,reshape(abs(freqresp(m.Wres,m.coverage.Omega)),[],1),'--','LineWidth',1.5);
grid on; xlabel('Pulsazione [rad/s]'); ylabel('Modulo');
legend('Inviluppo campionato di B / H_0','Peso A: maggiorazione analitica','Residuo W_{res}','Location','northwest');
finish(f,'coverage');
tab=readtable(fullfile(source,'comparison.csv'),'TextType','string');
f=figure('Visible','off','Color','w','Theme','light');
margin=tab.RSLower;
if ismember('NestingConsistent',tab.Properties.VariableNames),margin(~tab.NestingConsistent)=NaN;end
values=reshape(margin,3,[])'; bar(values); yline(1,'--');
xticks(1:6); xticklabels([d.controllers.name]); ylabel('Limite inferiore margine RS');
legend(m.names,'Interpreter','none','Location','northwest'); grid on; finish(f,'rs_comparison');
if isfile(fullfile(source,'ras.mat'))
    a=load(fullfile(source,'ras.mat')); tab=a.metrics;
    f=figure('Visible','off','Color','w','Theme','light','Position',[100 100 1000 650]); tiledlayout(2,3);
    for k=1:6
        nexttile; rows=tab.Controller==d.controllers(k).name;
        r=tab(rows,:); good=r.Converged & r.WithinEpsilon; conv=r.Converged & ~r.WithinEpsilon;
        scatter(r.Q1deg(good),r.Q2deg(good),45,[0 .5 .3],'filled'); hold on;
        scatter(r.Q1deg(conv),r.Q2deg(conv),55,[.9 .5 0],'o','LineWidth',1.5);
        failed=~r.Converged & r.Status=="COMPLETED";
        unknown=r.Status~="COMPLETED";
        scatter(r.Q1deg(failed),r.Q2deg(failed),45,[.8 .1 .1],'x');
        scatter(r.Q1deg(unknown),r.Q2deg(unknown),45,[.4 .4 .4],'s');
        plot(0,0,'k+','MarkerSize',8,'LineWidth',1.3);
        grid on; title(d.controllers(k).name); xlabel('Delta q_1 [deg]'); ylabel('Delta q_2 [deg]');
    end
    finish(f,'ras_points');
    f=figure('Visible','off','Color','w','Theme','light','Position',[100 100 1000 430]); tiledlayout(1,2);
    for k=[2 6]
        nexttile; r=tab(tab.Controller==d.controllers(k).name,:);
        good=r.Converged & r.WithinEpsilon; conv=r.Converged & ~r.WithinEpsilon;
        scatter(r.Q1deg(good),r.Q2deg(good),70,[0 .5 .3],'filled'); hold on;
        scatter(r.Q1deg(conv),r.Q2deg(conv),80,[.9 .5 0],'o','LineWidth',1.6);
        plot(0,0,'k+','MarkerSize',10,'LineWidth',1.5); grid on;
        title(d.controllers(k).name); xlabel('Delta q_1 [deg]'); ylabel('Delta q_2 [deg]');
        set(gca,'FontSize',13);
    end
    finish(f,'ras_oral');
    f=figure('Visible','off','Color','w','Theme','light');
    for k=[1 2 4 6]
        rows=tab.Controller==d.controllers(k).name;
        plot(hypot(tab.Q1deg(rows),tab.Q2deg(rows)),rad2deg(tab.Jrad(rows)),'o','DisplayName',d.controllers(k).name);hold on;
    end
    yline(.5,'--','epsilon'); grid on; legend('Location','northwest');
    xlabel('Distanza iniziale [deg]'); ylabel('J = max scarto LIN/NL [deg]'); finish(f,'linear_nonlinear_error');
    f=figure('Visible','off','Color','w','Theme','light'); tiledlayout(2,1);
    for joint=1:2
        nexttile;
        for j=[2 4]
            tr=a.trajectories{6,j};
            if isfield(tr,'qNL')
                plot(tr.time,rad2deg(tr.qNL(:,joint)),'DisplayName',sprintf('NL %g deg',rad2deg(a.points(j,1))));hold on;
                plot(tr.time,rad2deg(tr.qLIN(:,joint)),'--','DisplayName',sprintf('LIN %g deg',rad2deg(a.points(j,1))));
            end
        end
        grid on; ylabel(sprintf('Delta q_%d [deg]',joint)); legend;
    end
    xlabel('Tempo [s]'); finish(f,'paired_responses');
end
if isfile(fullfile(source,'qr.mat'))
    a=load(fullfile(source,'qr.mat')); f=figure('Visible','off','Color','w','Theme','light'); tiledlayout(2,1);
    for output=[1 3]
        nexttile;
        for j=1:3,plot(a.qr.time,a.qr.responses{j}(:,output),'DisplayName',sprintf('Q x %g',a.qr.factors(j)));hold on;end
        grid on; legend; if output==1,ylabel('q_1 [rad]');else,ylabel('u_1 [N m]');end
    end
    xlabel('Tempo [s]'); finish(f,'qr');
end
    function finish(fig,name)
        set_scientific_figure_style(fig);
        exportgraphics(fig,fullfile(destination,name+".png"),'Resolution',170);close(fig);
    end
end

