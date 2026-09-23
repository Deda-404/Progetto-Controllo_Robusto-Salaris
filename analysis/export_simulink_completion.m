function export_simulink_completion
%EXPORT_SIMULINK_COMPLETION Figures from executed evidence, no new analysis.
root=fileparts(fileparts(mfilename('fullpath')));
folder=fullfile(root,'results/data/simulink_completion');
target=fullfile(root,'report/figures/simulink_completion');
if ~isfolder(target), mkdir(target); end
old=load(fullfile(root,'results/data/m8_lqg_nonlinear_ras.mat'));
new=load(fullfile(folder,'lqri_ras.mat'));
f=figure('Visible','off','Color','w','Position',[100 100 1050 440]);
for j=1:2
    subplot(1,2,j);
    if j==1, points=old.rasAllPoints; boundary=old.rasBoundary; name='LQG M6';
    else, points=new.search.allPoints; boundary=new.search.boundary; name='LQRI M7'; end
    plot(boundary.Dq1Deg([1:end 1]),boundary.Dq2Deg([1:end 1]),'-','Color',[.1 .3 .5]); hold on;
    scatter(points.Dq1Deg(points.Convergent),points.Dq2Deg(points.Convergent),20,[0 .5 .5],'filled');
    scatter(points.Dq1Deg(~points.Convergent),points.Dq2Deg(~points.Convergent),28,[.7 .2 .1],'x');
    axis equal; xlim([-65 65]); ylim([-65 65]); grid on;
    xlabel('Initial q_1 deviation [deg]'); ylabel('Initial q_2 deviation [deg]');
    title(sprintf('%s: %d/%d convergent',name,sum(points.Convergent),height(points)));
    set(gca,'Color','w','XColor','k','YColor','k');
end
set(findall(f,'Type','text'),'Color','k');
exportgraphics(f,fullfile(target,'ras_lqg_lqri.png'),'Resolution',180); close(f);
f=figure('Visible','off','Color','w','Position',[100 100 1000 650]);
for k=1:4
    kinds=["LQG","LQRI","Hinf","Kmu"]; kind=kinds(k);
    l=load(fullfile(folder,kind+"_linear.mat"));
    n=load(fullfile(root,'results/data/simulink_integration',kind+"_runs.mat"),'small');
    subplot(2,2,k);
    plot(l.small.time,l.small.dq(:,1),'Color',[.1 .3 .5]); hold on;
    plot(n.small.time,n.small.dq(:,1),'--','Color',[.8 .3 .1]);
    xlabel('Time [s]'); ylabel('q_1 deviation [rad]'); title(kind); grid on;
    legend('Linear Simulink','Nonlinear Simulink','Location','southeast','TextColor','k','Color','w');
    set(gca,'Color','w','XColor','k','YColor','k');
end
set(findall(f,'Type','text'),'Color','k');
exportgraphics(f,fullfile(target,'linear_nonlinear.png'),'Resolution',180); close(f);
end
