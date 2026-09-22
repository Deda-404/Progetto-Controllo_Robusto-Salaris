function summary=export_hinf_final_results
%EXPORT_HINF_FINAL_RESULTS Esporta esclusivamente risultati MATLAB salvati.
root=fileparts(fileparts(mfilename('fullpath')));
folder=fullfile(root,'results','data','hinf_final_coherent');
figdir=fullfile(root,'report','figures','hinf_final'); if ~isfolder(figdir), mkdir(figdir); end
a=load(fullfile(folder,'nominal_study.mat')); study=a.study; q=study.selected; c=q.config;
a=load(fullfile(folder,'fixed_study.mat')); fixed=a.campaign;
a=load(fullfile(folder,'robust_study.mat')); robust=a.result;
rows=[];
for k=1:numel(study.one)
    r=study.one{k}; rows(k,:)=[k,r.parameters,r.bound.value,r.gammaMix,r.gamma,r.e.norms,max(r.e.metrics,[],1),r.e.order,r.e.stable,r.e.NP];
end
writematrix(rows,fullfile(folder,'one_dof.csv'));
summary=struct('baseCommit',c.baseCommit,'baseline',localEntry(study.one{1}), ...
    'bestOne',localEntry(study.one{study.selectedOne}),'selected',localEntry(q), ...
    'referenceCases',{cellfun(@localEntry,study.two,'UniformOutput',false)}, ...
    'minimumObservedOrder',fixed.minimumObservedOrder,'fixed',{{}});
for j=1:numel(fixed.families)
    f=fixed.families{j}; values=inf(numel(f.runs),1); stable=false(size(values)); np=stable;
    for k=1:numel(f.runs)
        r=f.runs{k};
        if isfield(r,'e'), stable(k)=r.e.stable; np(k)=r.valid && r.e.NP; values(k)=r.e.norms(1); end
    end
    [best,ix]=min(values);
    item=struct('name',f.name,'starts',numel(values),'stable',sum(stable),'NP',sum(np),'bestNorm',best);
    if isfinite(best), r=f.runs{ix}; item.order=r.e.order; item.metrics=r.e.metrics; item.objective=r.objective; end
    summary.fixed{j}=item;
end
summary.hinfRobust=localRobust(robust.m12);
summary.muRobust=localRobust(robust.m14);
summary.mu=struct('objective',robust.m13.objective,'order',order(robust.m13.K),'norms',robust.muEvaluation.norms,'metrics',robust.muEvaluation.metrics);
localFigure('weights_error',q.W1,inv(q.W1),c.omega,{'W_e','1/W_e'},figdir);
localFigure('weights_control',q.W2,inv(q.W2),c.omega,{'W_u','1/W_u'},figdir);
localFigure('sensitivity',q.e.S,study.one{1}.e.S,c.omega,{'2DoF feedback S','1DoF S'},figdir);
localFigure('control_sensitivity',q.e.KS,study.one{1}.e.KS,c.omega,{'2DoF feedback KS','1DoF KS'},figdir);
localFigure('weighted',q.e.weighted(1:2,:),q.e.weighted(3:4,:),c.omega,{'errore pesato [r;d]','comando pesato [r;d]'},figdir);
localTimeFigure('tracking_1dof',study.one{1}.e.responses,c.time,1:2,180/pi,'q (deg)',figdir);
localTimeFigure('tracking_2dof',q.e.responses,c.time,1:2,180/pi,'q (deg)',figdir);
localTimeFigure('command',q.e.responses,c.time,3:4,1,'u (N m)',figdir);
localTimeFigure('disturbance',q.e.disturbanceResponses,c.time,1:2,180/pi,'q (deg)',figdir);
f=figure('Visible','off','Color','w'); hold on;
for j=1:numel(fixed.families)
    family=fixed.families{j};
    for k=1:numel(family.runs)
        r=family.runs{k}; if r.valid, scatter(r.e.order,r.e.norms(1),25,'filled'); end
    end
end
yline(1,'k--'); xlabel('Ordine'); ylabel('Norma H-infinity verificata'); grid on;
localSave(f,fullfile(figdir,'fixed_order.png'));
file=fullfile(folder,'monte_carlo_study.mat');
if isfile(file)
    a=load(file); summary.monteCarloStable=a.result.stableCount;
    f=figure('Visible','off','Color','w'); bar([37 a.result.stableCount]);
    xticklabels({'LQG M6 invariato','Hinf 2DoF','Kmu 2DoF'}); ylim([0 40]); ylabel('Campioni stabili / 40'); grid on;
    localSave(f,fullfile(figdir,'monte_carlo.png'));
end
file=fullfile(folder,'nonlinear_study.mat');
if isfile(file)
    a=load(file); summary.nonlinear=cell(numel(a.campaign),1);
    for k=1:numel(a.campaign)
        r=a.campaign{k}; vals=cellfun(@(v)[v.amplitudeDeg v.joint v.metrics],r.tracking,'UniformOutput',false);
        summary.nonlinear{k}=struct('id',r.id,'tracking',vertcat(vals{:}),'equilibriumError',r.equilibriumError);
    end
end
file=fullfile(folder,'ras_study.mat');
if isfile(file)
    a=load(file); summary.ras=cellfun(@(r)r.metrics,a.results,'UniformOutput',false);
    f=figure('Visible','off','Color','w'); hold on;
    for k=1:numel(a.results)
        b=a.results{k}.boundary; plot([b.Dq1Deg;b.Dq1Deg(1)],[b.Dq2Deg;b.Dq2Deg(1)],'LineWidth',1.5);
    end
    axis equal; grid on; xlabel('dq1 (deg)'); ylabel('dq2 (deg)'); legend('Hinf 2DoF','Kmu 2DoF');
    localSave(f,fullfile(figdir,'ras.png'));
end
file=fullfile(folder,'lyapunov_study.mat');
if isfile(file)
    a=load(file); summary.lyapunov=cellfun(@(r)struct('name',r.name,'bound',r.bound,'rhoNumerical',r.rhoNumerical,'validationPassed',r.validationPassed),a.risultati,'UniformOutput',false);
end
file=fullfile(folder,'noise_study.mat');
if isfile(file)
    a=load(file); summary.noise=cellfun(@(r)struct('id',r.id,'peakU',r.peakU,'rmsU',r.rmsU,'repeatError',r.repeatError),a.results,'UniformOutput',false);
end
fid=fopen(fullfile(folder,'summary.json'),'w'); closeFile=onCleanup(@()fclose(fid)); fprintf(fid,'%s',jsonencode(summary,PrettyPrint=true));
end
function s=localEntry(q)
s=struct('architecture',q.architecture,'id',q.id,'parameters',q.parameters,'gamma',q.gamma, ...
    'order',q.e.order,'norms',q.e.norms,'metrics',q.e.metrics,'disturbanceMetrics',q.e.disturbanceMetrics, ...
    'NS',q.e.stable,'NP',q.e.NP,'M5',q.e.m5Temporal,'revised',q.e.revisedTemporal,'DC',q.e.dc, ...
    'maxRealPole',q.e.maxRealPole,'maxRealControllerPole',max(real(q.e.controllerPoles)));
end
function s=localRobust(a)
s=struct('RS',a.RS,'RP',a.RP,'RSOutcome',a.RSOutcome,'RPOutcome',a.RPOutcome,'nominalNorm',a.nominalNorm);
end
function localFigure(name,a,b,w,labels,folder)
f=figure('Visible','off','Color','w');
ha=semilogx(w,20*log10(sigma(a,w))','LineWidth',1.2); hold on;
hb=semilogx(w,20*log10(sigma(b,w))','--','LineWidth',1.2);
legend([ha(1),hb(1)],labels,'Location','best');
xlabel('Frequenza (rad/s)'); ylabel('Valori singolari (dB)'); grid on; title(strjoin(labels,' / '));
localSave(f,fullfile(folder,name+".png"));
end
function localTimeFigure(name,responses,t,cols,scale,ylab,folder)
f=figure('Visible','off','Color','w','Position',[100 100 1100 350]); tiledlayout(1,2);
for j=1:2
    nexttile; plot(t,responses{j}(:,cols)*scale,'LineWidth',1.2); xlim([0 4]); grid on;
    xlabel('Tempo (s)'); ylabel(ylab); title(sprintf('Ingresso sul giunto %d',j)); legend('Giunto 1','Giunto 2');
end
localSave(f,fullfile(folder,name+".png"));
end
function localSave(f,path)
set(findall(f,'Type','axes'),'XColor','k','YColor','k','Color','w','GridColor',[.65 .65 .65]);
set(findall(f,'Type','text'),'Color','k');
set(findall(f,'Type','legend'),'TextColor','k','Color','w','EdgeColor','k');
exportgraphics(f,path,'Resolution',160); close(f);
end
