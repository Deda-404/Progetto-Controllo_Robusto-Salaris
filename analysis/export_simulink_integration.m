function export_simulink_integration
%EXPORT_SIMULINK_INTEGRATION Figures from validated simulations only.
root=fileparts(fileparts(mfilename('fullpath')));
folder=fullfile(root,'results/data/simulink_integration');
a=load(fullfile(folder,'validation.mat')); assert(a.summary.passed);
out=fullfile(root,'report/figures/simulink_integration'); if ~isfolder(out),mkdir(out);end
kinds=["LQG","LQRI","Hinf","Kmu"];
f=figure('Visible','off','Color','w','Position',[50 50 1200 900]);
tiledlayout(4,2,'TileSpacing','compact');
for k=1:4
 a=load(fullfile(folder,char(kinds(k)+"_runs.mat")));
 for j=1:2
  r=a.tracking{j}; nexttile;
  plot(r.time,r.dq*180/pi,'LineWidth',1.3);hold on;
  plot(r.time,r.r(:,j)*180/pi,'k--','LineWidth',1);
  title(sprintf('%s: gradino giunto %d',kinds(k),j));ylabel('Delta q [deg]');xlabel('Tempo [s]');grid on;
  set(gca,'Color','w','XColor','k','YColor','k');
  if k==1 && j==1,legend('q1','q2','r','Location','southeast','Color','w','TextColor','k');end
 end
end
set(findall(f,'Type','text'),'Color','k');
exportgraphics(f,fullfile(out,'tracking.png'),'Resolution',170,'BackgroundColor','white');close(f);
f=figure('Visible','off','Color','w','Position',[50 50 1100 430]);tiledlayout(1,2,'TileSpacing','compact');
a=load(fullfile(folder,'LQG_disturbance.mat'));b=load(fullfile(folder,'LQRI_disturbance.mat'));
for j=1:2
 nexttile;plot(a.dist.time,a.dist.dq(:,j)*180/pi,'LineWidth',1.4);hold on;
 plot(b.dist.time,b.dist.dq(:,j)*180/pi,'LineWidth',1.4);
 title(sprintf('Disturbo link 0.5 Nm, giunto %d',j));ylabel('Delta q [deg]');xlabel('Tempo [s]');grid on;
 legend('LQG','LQRI','Location','best','Color','w','TextColor','k');set(gca,'Color','w','XColor','k','YColor','k');
end
set(findall(f,'Type','text'),'Color','k');
exportgraphics(f,fullfile(out,'disturbance.png'),'Resolution',170,'BackgroundColor','white');close(f);
f=figure('Visible','off','Color','w','Position',[50 50 1100 430]);tiledlayout(1,2,'TileSpacing','compact');
for j=1:2
 nexttile;hold on;
 for k=1:4
  a=load(fullfile(folder,char(kinds(k)+"_runs.mat")));r=a.small;
  G=simulink_integration_linear_map(r.config); y=lsim(G,[r.r r.d_ext],r.time);
  if j==1,err=max(abs(r.dq-y(:,1:2)),[],2);else,err=max(abs(r.u-y(:,3:4)),[],2);end
  semilogy(r.time,max(err,eps),'LineWidth',1.2);
 end
 set(gca,'YScale','log','Color','w','XColor','k','YColor','k');grid on;xlabel('Tempo [s]');
 if j==1,ylabel('Errore massimo q [rad]');else,ylabel('Errore massimo u [Nm]');end
 legend(kinds,'Location','best','Color','w','TextColor','k');
end
set(findall(f,'Type','text'),'Color','k');
exportgraphics(f,fullfile(out,'equivalence.png'),'Resolution',170,'BackgroundColor','white');close(f);
end
