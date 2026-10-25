function export_s1_oral_figures
%EXPORT_S1_ORAL_FIGURES Selezioni leggibili dai dati S1 realmente simulati.
root=fileparts(fileparts(mfilename('fullpath'))); folder=fullfile(root,'Progetto_SEA_Consegna');
addpath(folder);p=parametri_sea;
a=load(fullfile(folder,'dati/confronto_finale.mat'));c=a.confronto;
b=load(fullfile(folder,'dati/banca_consolidata.mat'));b=b.banca;
indices=[1 4 6 8];names=["LQG","Hinf2","Kmu","Mu_B"];
f=figure('Color','white','Theme','light','Position',[50 50 1000 620]);tiledlayout(2,2);
for k=1:4
    nexttile;hold on;
    for j=1:10
        m=c.tracce{j,indices(k)};
        if m.stable,plot(p.time,rad2deg(m.tracking{1}(:,1)),'Color',[.25 .5 .7]);end
    end
    yline(5,'--k');title(names(k));xlabel('Tempo [s]');ylabel('q1 [deg]');grid on;
end
exportgraphics(f,fullfile(folder,'figure/orale_impianti.png'),'Resolution',180);
f=figure('Color','white','Theme','light','Position',[50 50 1000 620]);tiledlayout(2,2);
for k=1:4
    nexttile;hold on;t=c.rasTable(c.rasTable.Controllore==names(k),:);
    plot(t.Q1deg(t.Converge),t.Q2deg(t.Converge),'o','Color',[.1 .55 .3],'MarkerFaceColor',[.1 .55 .3]);
    ix=t.Completa & ~t.Converge;plot(t.Q1deg(ix),t.Q2deg(ix),'rx');
    ix=~t.Completa;plot(t.Q1deg(ix),t.Q2deg(ix),'s','Color',[.45 .45 .45],'MarkerFaceColor',[.7 .7 .7]);
    axis equal;xlim([-50 50]);ylim([-50 50]);grid on;title(names(k));xlabel('Delta q1 [deg]');ylabel('Delta q2 [deg]');
end
exportgraphics(f,fullfile(folder,'figure/orale_ras.png'),'Resolution',180);
v=struct('Q8',b.lqg.Q(1:8,1:8),'R',b.lqg.R,'Qi',b.lqgi.wbarI*eye(2), ...
    'Qn',b.lqg.Qn,'Rn',b.lqg.Rn,'L',b.lqg.L,'Ki',b.lqgi.Ki, ...
    'sourceCommit',b.sourceCommit,'legacyRS',b.historical.mu.RS, ...
    'legacyRP',b.historical.mu.RP);
fid=fopen(fullfile(folder,'dati/parametri_verificati.json'),'w');clean=onCleanup(@()fclose(fid));
fprintf(fid,'%s\n',jsonencode(v,'PrettyPrint',true));
end
