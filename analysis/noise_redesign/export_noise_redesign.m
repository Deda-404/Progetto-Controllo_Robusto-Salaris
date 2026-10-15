function summary = export_noise_redesign
% Dati numerici e figure: unica origine per tabelle e testi della revisione.
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
folder=fullfile(root,'results/data/noise_redesign');
a=load(fullfile(folder,'noise_validation.mat'));noise=a.result;
a=load(fullfile(folder,'plants_validation.mat'));plants=a.result;
a=load(fullfile(folder,'ras/ras_lyapunov.mat'));ras=a.result;
summary=struct('release',version('-release'),'noiseSeeds',noise.seeds,'sigmaY',noise.sigmaY, ...
    'Ts',noise.Ts,'duration',noise.duration,'baselineDefault',true,'candidates',[], ...
    'noiseMetrics',table2struct(noise.metrics),'plantsMetrics',table2struct(plants.metrics), ...
    'rasMetrics',table2struct(ras.metrics),'simulink',[]);
files=["hinf_noise_01","hinf_noise_02","hinf_noise_03","mu_noise_01"];
for j=1:numel(files)
    a=load(fullfile(folder,files(j)+".mat"));c=a.candidate;
    a=load(fullfile(folder,files(j)+"_robust.mat"));r=a.audit;
    diagnostic=noise.diagnostics(strcmp(string({noise.diagnostics.name}),c.name));
    item=struct('id',files(j),'name',c.name,'order',order(c.K),'noiseScale',c.noiseScale, ...
        'Wn',c.Wn(1,1),'newNorm',c.newNorm,'oldNorm',c.e.norms(1),'maxRealPole',c.e.maxRealPole, ...
        'tracking',c.e.metrics,'disturbance',c.e.disturbanceMetrics, ...
        'TuvNorm',c.noiseGain,'RS',r.new.RS,'RSOutcome',r.new.RSOutcome, ...
        'RP',r.new.RP,'RPOutcome',r.new.RPOutcome,'oldRP',r.old.RP, ...
        'muRSMax',r.new.muRSMax,'muRPMax',r.new.muRPMax, ...
        'diagnostic',rmfield(diagnostic,{'omega','singular'}));
    if j==4,item.objective=c.objective;item.dkIterations=numel(c.dkInfo);end
    summary.candidates=[summary.candidates;{item}];
end
choices=["baseline","noise_hinf3","noise_mu1"];
for choice=choices
    models=["Hinf_linear_sim","Hinf_nonlinear_sim","mu_linear_sim","mu_nonlinear_sim"];
    for model=models
        file=fullfile(folder,'simulink',choice,model+"_dynamic_review.json");if ~isfile(file),continue;end
        review=jsondecode(fileread(file));run=jsondecode(fileread(fullfile(folder,'simulink',choice,model+"_audit.json")));
        item=struct('selection',choice,'model',model,'branches',review.branches, ...
            'release',run.release,'hashBefore',run.sha256_before,'hashAfter',run.sha256_after, ...
            'warning',run.warning,'error',run.error,'identity',run.controller_identity, ...
            'solver',run.solver,'solverConfiguration',run.solver_configuration,'switches',run.switches);
        summary.simulink=[summary.simulink;{item}];
    end
end
for j=1:numel(ras.proofs)
    proof=ras.proofs{j};summary.rasProofs(j)=rmfield(proof,{'Acl','balanceTransform','Ab','Pb','sectionMatrix'});
end
f=fopen(fullfile(folder,'summary.json'),'w');cleanup=onCleanup(@()fclose(f));
fprintf(f,'%s',jsonencode(summary,PrettyPrint=true));clear cleanup
figures=fullfile(root,'report/figures/noise_redesign');if ~isfolder(figures),mkdir(figures);end
selected=[1 2 5 6];labels=["Hinf baseline","mu baseline","Hinf rumore","mu rumore"];
fig=figure('Visible','off','Color','w','Theme','light','Position',[100 100 1180 480]);
cleanup=onCleanup(@()close(fig));tiledlayout(1,2,'Padding','compact','TileSpacing','compact');
for metric=["IntersamplePeakU","IntegratedRmsU"]
    nexttile;hold on;grid on;
    for k=1:4
        values=noise.metrics.(metric)(strcmp(noise.metrics.Controller,noise.controllers(selected(k)).name) & ...
            strcmp(noise.metrics.Scenario,'independent'));
        scatter(k*ones(size(values)),values,45,'filled');
    end
    set(gca,'YScale','log','XTick',1:4,'XTickLabel',labels,'FontSize',12);xtickangle(15);
    ylabel('Comando [N m]');
    if metric=="IntersamplePeakU",title('Picco osservato fra campioni');else,title('RMS integrato, media di due canali');end
end
sgtitle('Solo encoder indipendenti: tre seed, stessa varianza e Ts = 2 ms');
exportgraphics(fig,fullfile(figures,'noise_before_after.png'),'Resolution',180);clear cleanup
fig=figure('Visible','off','Color','w','Theme','light','Position',[100 100 1160 450]);cleanup=onCleanup(@()close(fig));
tiledlayout(1,2,'Padding','compact','TileSpacing','compact');
nexttile;hold on;grid on;
for k=1:4
    diagnostic=noise.diagnostics(selected(k));loglog(diagnostic.omega,diagnostic.singular,'LineWidth',1.3,'DisplayName',labels(k));
end
set(gca,'XScale','log','YScale','log','FontSize',12);xlabel('Frequenza [rad/s]');ylabel('sigma max Tuv [N m/rad]');legend('Location','best');
nexttile;hold on;grid on;
for k=[2 6]
    run=noise.runs{k,1,4};plot(run.t,run.y(:,3),'LineWidth',.7,'DisplayName',char(noise.controllers(k).name));
end
xlim([0 .12]);xlabel('Tempo [s]');ylabel('u1 campionato [N m]');title('mu: campioni a 2 ms, complementari ai picchi');legend;
exportgraphics(fig,fullfile(figures,'frequency_and_command.png'),'Resolution',180);clear cleanup
fig=figure('Visible','off','Color','w','Theme','light','Position',[100 100 1180 700]);
cleanup=onCleanup(@()close(fig));tiledlayout(2,2,'Padding','compact','TileSpacing','compact');
for model=["Hinf_nonlinear_sim","mu_nonlinear_sim"]
    if startsWith(model,'Hinf')
        choice="noise_hinf3";candidateName="HinfN3";columns=3:4;branch="(2-DoF)";
    else
        choice="noise_mu1";candidateName="MuN1";columns=1:2;branch="";
    end
    position=nexttile;hold on;grid on;ylabel('q1 [deg]');title(strrep(model,'_',' '));
    command=nexttile;hold on;grid on;ylabel('|u1| [N m]');set(gca,'YScale','log');upper=1;
    for selection=["baseline",choice]
        a=load(fullfile(folder,'simulink',selection,model+"_scope_buffers.mat"),'records');
        names=cellfun(@(v)string(v.scope),a.records);
        ur=a.records{contains(names,'Variabil') & contains(names,'controllo')};
        qr=a.records{contains(names,'Uscita ideale') & contains(names,branch)};
        label="baseline";if selection~="baseline",label=candidateName;end
        plot(position,qr.channels{1}.time,qr.channels{1}.values*180/pi,'DisplayName',char(label));
        plot(command,ur.channels{columns(1)}.time, ...
            max(abs(ur.channels{columns(1)}.values),eps),'DisplayName',char(label));
        upper=max(upper,max(abs(ur.channels{columns(1)}.values)));
    end
    ylim(command,[1e-4,10^ceil(log10(upper))]);
    for ax=[position,command],xlabel(ax,'Tempo [s]');legend(ax,'Location','best');set(ax,'FontSize',12);end
end
sgtitle('Scope non lineari originali: stesso scenario combinato, baseline e candidato');
exportgraphics(fig,fullfile(figures,'simulink_before_after.png'),'Resolution',180);clear cleanup
fprintf('EXPORT PASS: %d confronti rumore, %d righe impianti, %d punti RAS\n',height(noise.metrics),height(plants.metrics),height(ras.metrics));
end
