function export_hinf_revision
%EXPORT_HINF_REVISION Tabelle e figure dai soli artifact della revisione.
root=fileparts(fileparts(mfilename('fullpath')));
folder=fullfile(root,'results','data','hinf_targeted_revision');
out=fullfile(root,'report','figures','hinf_targeted_revision');
if ~isfolder(out), mkdir(out); end
d=load(fullfile(folder,'study.mat')); study=d.study;
d=load(fullfile(folder,'fixed_campaign.mat')); campaign=d.campaign;
d=load(fullfile(folder,'extension_2dof.mat')); ext=d.extension;
r=study.cases{study.selected}; c=study.config;
rows=cell(numel(study.cases),23);
for i=1:numel(study.cases)
    q=study.cases{i}; values=nan(1,10); flags=false(1,4);
    if q.status=="SYNTHESIZED"
        values=[order(q.Khinf),q.hinf.norms,max(q.hinf.metrics,[],1)];
        flags=[q.hinf.stable,q.hinf.nominalPerformance,q.hinf.m5Temporal,q.hinf.revisedTemporal];
    end
    rows(i,:)=[num2cell([q.id,q.stage,q.parameters,q.bound.value,q.bound.frequency, ...
        q.gammaMix,q.gammaHinf,values]),{q.status,q.error}];
    gateRows(i,:) = flags; %#ok<AGROW>
end
names={'Id','Stage','OmegaW1','As','Ms','Ku','OmegaU','LowerBound','CriticalFrequency', ...
    'GammaMix','GammaHinf','Order','StackNorm','W1SNorm','W2KSNorm','SettlingTime', ...
    'OvershootPercent','SteadyErrorRelative','CrossCoupling','PeakControlNm','RmsControlNm','Status','Error'};
t=cell2table(rows,'VariableNames',names);
t=[t,array2table(gateRows,'VariableNames',{'NS','HinfNP','M5Temporal','RevisedTemporal'})];
writetable(t,fullfile(folder,'full_order.csv'));
fixedRows={}; startRows={};
for i=1:numel(campaign.families)
    f=campaign.families{i}; best=nan(1,13); flags=false(1,4);
    if ~isempty(f.bestRun)
        b=f.runs{f.bestRun}; e=b.evaluation;
        best=[b.order,b.objective,b.relativeGap,e.norms,max(e.metrics,[],1),e.maxRealPole];
        flags=[e.stable,b.performancePass,e.m5Temporal,e.revisedTemporal];
    end
    stableCount=sum(cellfun(@(x) x.stable,f.runs));
    fixedRows(end+1,:)=[{f.id,f.seed,numel(f.runs),stableCount},num2cell(best),num2cell(flags)]; %#ok<AGROW>
    for j=1:numel(f.runs)
        b=f.runs{j}; startRows(end+1,:)={f.id,j,f.seed,b.objective,b.stable,b.performancePass,b.error}; %#ok<AGROW>
    end
end
ft=cell2table(fixedRows,'VariableNames',{'Family','Seed','Starts','StableStarts','Order', ...
    'Objective','RelativeGap','StackNorm','W1SNorm','W2KSNorm','SettlingTime', ...
    'OvershootPercent','SteadyErrorRelative','CrossCoupling','PeakControlNm','RmsControlNm', ...
    'MaxRealPole','NS','HinfNP','M5Temporal','RevisedTemporal'});
writetable(ft,fullfile(folder,'fixed_order.csv'));
writetable(cell2table(startRows,'VariableNames',{'Family','Start','Seed','Objective','Stable','HinfNP','Error'}), ...
    fullfile(folder,'fixed_starts.csv'));
metrics=[study.baseline.evaluation.metrics;r.mix.metrics;r.hinf.metrics;ext.metrics];
mt=array2table(metrics,'VariableNames',{'SettlingTime','OvershootPercent','SteadyErrorRelative', ...
    'CrossCoupling','PeakControlNm','RmsControlNm'});
mt.Controller=repelem(["Baseline";"mixsyn";"hinfsyn";"2DoF"],2);
mt.Joint=repmat([1;2],4,1); writetable(mt,fullfile(folder,'tracking.csv'));
dt=array2table(r.hinf.disturbanceMetrics,'VariableNames',{'PeakPositionRad','PeakControlNm','RmsControlNm'});
dt.Joint=[1;2]; writetable(dt,fullfile(folder,'link_disturbance.csv'));
summary=struct('baselineParameters',study.baseline.parameters, ...
    'baselineGamma',study.baseline.gamma,'baselineBound',study.baseline.bound.value, ...
    'baselineBoundFrequency',study.baseline.bound.frequency, ...
    'selectedParameters',r.parameters,'gammaMix',r.gammaMix,'gammaHinf',r.gammaHinf, ...
    'lowerBound',r.bound.value,'boundFrequency',r.bound.frequency,'order',order(r.Khinf), ...
    'gammaRelativeError',r.gammaRelativeError,'mapError',r.mapError,'plantError',r.plantError, ...
    'normRelativeError',r.normRelativeError,'maxRealPole',r.hinf.maxRealPole, ...
    'twoDofTrackingNorm',ext.trackingNorm,'twoDofModelError',ext.modelErrorNorm, ...
    'twoDofM5',ext.m5Temporal,'twoDofRevised',ext.revisedTemporal, ...
    'revisedTargets',c.revised,'selectedId',study.selected);
fid=fopen(fullfile(folder,'summary.json'),'w'); fprintf(fid,'%s\n',jsonencode(summary,PrettyPrint=true)); fclose(fid);

omega=c.omega; a=squeeze(abs(freqresp(r.W1(1,1),omega))); b=squeeze(abs(freqresp(r.W2(1,1),omega)));
draw('01_W1'); loglog(omega,a,omega,1./a,'--','LineWidth',1.4); legend('|W_1|','1/|W_1|'); finish('Modulo');
draw('02_W2'); loglog(omega,b,omega,1./b,'--','LineWidth',1.4); legend('|W_2|','1/|W_2|'); finish('Modulo (coordinate SI)');
draw('03_S'); loglog(omega,max(sigma(r.hinf.S,omega),[],1),omega,1./a,'--','LineWidth',1.4); legend('\sigma_{max}(S)','1/|W_1|'); finish('Modulo');
draw('04_KS'); loglog(omega,max(sigma(r.hinf.KS,omega),[],1),omega,1./b,'--','LineWidth',1.4); legend('\sigma_{max}(KS)','1/|W_2|'); finish('Guadagno [N m/rad]');
draw('05_weighted'); semilogx(omega,max(sigma(r.W1*r.hinf.S,omega),[],1),omega,max(sigma(r.W2*r.hinf.KS,omega),[],1),'LineWidth',1.4);
yline(1,'k--'); legend('W_1 S','W_2 KS','Target 1'); finish('Massimo valore singolare');
draw('06_tracking'); tiledlayout(2,1);
for j=1:2
    nexttile; plot(c.time,rad2deg(r.hinf.responses{j}(:,1:2)),'LineWidth',1.2);
    yline(5,'k--'); grid on; xlabel('Tempo [s]'); ylabel('Posizione [gradi]'); title(sprintf('Gradino sul giunto %d',j)); legend('q_1','q_2','Riferimento');
end
saveFigure;
draw('07_control'); tiledlayout(2,1);
for j=1:2
    nexttile; plot(c.time,r.hinf.responses{j}(:,3:4),'LineWidth',1.2);
    grid on; xlabel('Tempo [s]'); ylabel('Comando [N m]'); title(sprintf('Gradino sul giunto %d',j)); legend('u_1','u_2');
end
saveFigure;
draw('08_fixed_order'); hold on;
for i=1:height(ft)
    if ft.NS(i), plot(ft.Order(i),ft.Objective(i),'o','MarkerSize',8,'DisplayName',char(ft.Family(i))); end
end
yline(1,'k--','Target 1','HandleVisibility','off'); yline(r.gammaHinf,'k:','Full-order','HandleVisibility','off');
xlabel('Ordine del controllore'); ylabel('Objective'); grid on; legend('Location','best');
title('A0 statico e A1 PI: nessuna soluzione stabile trovata'); saveFigure;
draw('09_2dof'); tiledlayout(2,1);
for j=1:2
    nexttile; plot(c.time,rad2deg(r.hinf.responses{j}(:,j)),c.time,rad2deg(ext.responses{j}(:,j)),'LineWidth',1.2);
    yline(5,'k--'); grid on; xlabel('Tempo [s]'); ylabel('Posizione [gradi]'); title(sprintf('Giunto %d',j)); legend('1-DoF','2-DoF','Riferimento');
end
saveFigure;
draw('10_link_disturbance'); tiledlayout(2,1);
for j=1:2
    nexttile; plot(c.time,rad2deg(r.hinf.disturbanceResponses{j}(:,1:2)),'LineWidth',1.2);
    grid on; xlabel('Tempo [s]'); ylabel('Posizione [gradi]'); title(sprintf('Coppia lato link %d: 0.5 N m',j)); legend('q_1','q_2');
end
saveFigure;
disp(t); disp(ft); disp(mt);
    function draw(name)
        figure('Visible','off','Color','w','Position',[50 50 1000 650],'Name',name);
    end
    function finish(label)
        xlabel('Frequenza [rad/s]'); ylabel(label); grid on; saveFigure;
    end
    function saveFigure
        fig=gcf; axesList=findall(fig,'Type','axes');
        set(axesList,'XColor','k','YColor','k','FontSize',12,'Color','w');
        set(findall(fig,'Type','text'),'Color','k');
        set(findall(fig,'Type','legend'),'TextColor','k','Color','w');
        exportgraphics(fig,fullfile(out,[fig.Name '.png']),'Resolution',160); close(fig);
    end
end
