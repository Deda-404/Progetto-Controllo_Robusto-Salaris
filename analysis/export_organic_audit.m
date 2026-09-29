function audit = export_organic_audit
%EXPORT_ORGANIC_AUDIT Legge i risultati salvati, senza ripetere sintesi.
root=fileparts(fileparts(mfilename('fullpath')));
folder=fullfile(root,'results/data/hinf_final_coherent');
out=fullfile(root,'results/data/organic_review');
figdir=fullfile(root,'report/figures/mu');
if ~isfolder(out), mkdir(out); end
if ~isfolder(figdir), mkdir(figdir); end
a=load(fullfile(folder,'nominal_study.mat')); study=a.study;
a=load(fullfile(folder,'robust_study.mat')); robust=a.result;
m2=load(fullfile(root,'results/data/m2_linearization_nominal.mat'));
m4=load(fullfile(root,'results/data/m4_uncertain_plant.mat'));
audit.mechanicalPoles=[real(m2.poles),imag(m2.poles)];
audit.blocks=robust.m12.BlkStruct;
audit.deltaSize=size(robust.m12.Delta);
audit.lftMatrixSize=size(robust.m12.M);
[audit.WInumerator,audit.WIdenominator]=tfdata(m4.WI,'v');
audit.frequencyGrid=[min(robust.m13.options.FrequencyGrid), ...
    max(robust.m13.options.FrequencyGrid),numel(robust.m13.options.FrequencyGrid)];
audit.dk=zeros(numel(robust.m13.info),4);
audit.fitOrders=zeros(numel(robust.m13.info),2);
for k=1:numel(robust.m13.info)
    r=robust.m13.info(k);
    audit.dk(k,:)=[k,r.gamma,r.PeakMu,r.PeakMuFit];
    audit.fitOrders(k,:)=r.FitOrder;
end
% Identita di LFT: nessuna nuova ricerca del caso peggiore.
reconstructed=lft(robust.m12.Delta,robust.m12.M);
w=logspace(-3,4,121);
audit.lftNominalError=max(abs(freqresp(reconstructed.NominalValue,w)- ...
    freqresp(robust.m12.CL.NominalValue,w)),[],'all');
audit.oneDof={};
for k=[1 study.selectedOne]
    r=study.one{k};
    item=struct('profile',k,'gammaMixsyn',r.gammaMix,'gammaHinfsyn',r.gamma, ...
        'gammaDifference',abs(r.gamma-r.gammaMix),'maxRealPole',r.e.maxRealPole, ...
        'mapError',r.audit.mapError,'plantError',r.audit.plantError);
    audit.oneDof{end+1}=item;
end
audit.fullOrderMaxRealPole=study.selected.e.maxRealPole;
audit.muMaxRealPole=robust.muEvaluation.maxRealPole;
audit.muDisturbanceMetrics=robust.muEvaluation.disturbanceMetrics;
a=load(fullfile(folder,'fixed_study.mat'));audit.structured={};
for j=1:numel(a.campaign.families)
    family=a.campaign.families{j};values=inf(numel(family.runs),1);
    for k=1:numel(family.runs)
        if isfield(family.runs{k},'e'),values(k)=family.runs{k}.e.norms(1);end
    end
    [best,idx]=min(values);
    if isfinite(best)
        e=family.runs{idx}.e;
        audit.structured{end+1}=struct('family',family.name,'run',idx, ...
            'order',e.order,'norm',best,'maxRealPole',e.maxRealPole, ...
            'metrics',e.metrics,'disturbanceMetrics',e.disturbanceMetrics);
    end
end
audit.source='Saved nominal_study.mat and robust_study.mat; no synthesis';
f=fopen(fullfile(out,'numeric_audit.json'),'w');
cleanup=onCleanup(@()fclose(f)); fprintf(f,'%s',jsonencode(audit,PrettyPrint=true));
save(fullfile(out,'numeric_audit.mat'),'audit');

f=figure('Visible','off','Color','w','Position',[100 100 850 410]);
semilogy(audit.dk(:,1),audit.dk(:,3),'-o','LineWidth',1.8);hold on;
semilogy(audit.dk(:,1),audit.dk(:,4),'--s','LineWidth',1.5);
yline(1,'k:','Soglia unitaria');grid on;xticks(1:5);
xlabel('Iterazione');ylabel('Picco della maggiorazione di mu');
legend('PeakMu','PeakMuFit','Location','northeast');
title('D-K: analisi degli scaling e approssimazione razionale');
localSave(f,fullfile(figdir,'dk_history.png'));

f=figure('Visible','off','Color','w','Position',[100 100 900 400]);
tiledlayout(1,2);
for k=1:2
    nexttile;
    if k==1, a=robust.m12; titleText='H-infinity'; else, a=robust.m14;titleText='Kmu';end
    hold on; grid on; xline(1,'k--','Soglia');
    plot([a.RS.LowerBound a.RS.UpperBound],[2 2],'-o','LineWidth',2);
    if a.RP.LowerBound<=a.RP.UpperBound
        plot([a.RP.LowerBound a.RP.UpperBound],[1 1],'-s','LineWidth',2);
    else
        text(.025,1,'RP: intervallo non valido','FontSize',10);
    end
    set(gca,'XScale','log');xlim([.01 3]);ylim([.5 2.5]);
    yticks([1 2]);yticklabels({'RP','RS'});xlabel('Margine di incertezza');title(titleText);
end
localSave(f,fullfile(figdir,'robust_margins.png'));
fprintf('Audit esportato. Delta %dx%d; errore nominale LFT %.3g.\n', ...
    audit.deltaSize,audit.lftNominalError);
end

function localSave(f,path)
set(findall(f,'Type','axes'),'XColor','k','YColor','k','Color','w');
set(findall(f,'Type','text'),'Color','k');
set(findall(f,'Type','legend'),'TextColor','k','Color','w');
exportgraphics(f,path,'Resolution',180);close(f);
end
