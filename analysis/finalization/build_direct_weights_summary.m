function summary = build_direct_weights_summary
%BUILD_DIRECT_WEIGHTS_SUMMARY Esporta soltanto dati gia calcolati.
%   Nessuna nuova sintesi: le tabelle ricostruiscono esiti dai criteri M5.
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
data=fullfile(root,'results','data');
m5=load(fullfile(data,'m5_performance_specs.mat'));
m6=load(fullfile(data,'m6_lqg_no_integrator.mat'));
m7=load(fullfile(data,'m7_augmented_cost_feasibility.mat'));
m9=load(fullfile(data,'m9_hinf_mixsyn_nominal.mat'));
m10=load(fullfile(data,'m10_hinfsyn_nominal.mat'));
m11=load(fullfile(data,'m11_hinfstruct_structured.mat'));
h=load(fullfile(data,'hinf_weight_revision.mat'));
baseline=load(fullfile(data,'direct_weights_baseline.mat'));
names=["M9";"M10";"M11 A3";"M11 A4";"M11 A5"];
values=nan(5,9); stable=false(5,1);
% Le metriche temporali usano gli scenari originali 2/5/8 gradi.
for k=1:5
    if k==1
        K=m9.Kmix; gamma=m9.gamma; t=m9.trackingMetrics;
        a=m9.weightedW1S; b=m9.weightedW2KS;
        stable(k)=all(real(m9.closedLoopPoles)<-1e-8);
    elseif k==2
        K=m10.Khinf; gamma=m10.gammaHinf; t=m10.trackingMetrics;
        a=m10.weightedW1S10; b=m10.weightedW2KS10;
        stable(k)=all(real(m10.closedLoopPoles10)<-1e-8);
    else
        id="A"+string(k);
        r=m11.representativeResults( ...
            string({m11.representativeResults.architectureID})==id);
        assert(r.available,'DirectSummary:MissingRepresentative', ...
            'Il rappresentante %s non e disponibile.',id);
        K=r.controller; gamma=r.objective; t=r.evaluation.trackingMetrics;
        a=r.reconstruction.weightedW1S; b=r.reconstruction.weightedW2KS;
        stable(k)=all(real(r.reconstruction.internalPoles)<-1e-8);
    end
    values(k,:)=[order(K),gamma,norm(a,inf),norm(b,inf), ...
        max(t.SettlingTime),max(t.OvershootPercent), ...
        max(t.SteadyStateErrorRelative),max(t.PeakControlNm), ...
        max(t.CrossCouplingPeakRatio)];
end
production=array2table(values,'VariableNames',{'Order','Gamma','W1S','W2KS', ...
    'Ts','OvershootPercent','SteadyErrorRelative','PeakUNm','CrossCoupling'});
production.Controller=names; production.Stable=stable;
production.Pass=stable & production.Gamma<1 & ...
    production.Ts<=m5.spec.settlingTimeTarget & ...
    production.OvershootPercent<=m5.spec.overshootTarget & ...
    production.SteadyErrorRelative<=m5.spec.steadyStateTrackingTarget;
writetable(production,fullfile(data,'direct_hinf_production.csv'));
% Raggruppamento della griglia LQR: 12 Q per ciascuno dei tre R.
l=m6.lqrCandidateTable; ru=[.01;.05;.10]; admissible=zeros(3,1);
bestScore=inf(3,1); selected=false(3,1);
for k=1:3
    rows=l.ControlWeight==ru(k);
    admissible(k)=sum(l.Admissible(rows));
    bestScore(k)=min(l.CompromiseScore(rows));
    selected(k)=any(l.Selected(rows));
end
lqrSummary=table(ru,admissible,bestScore,selected);
summary=struct('production',production,'lqrSummary',lqrSummary, ...
    'lqrCandidates',l,'lqri',m7.manualComparisonTable, ...
    'Q',m6.Q,'R',m6.R,'K',m6.K,'Nr',m6.Nr, ...
    'Kx',m7.designs{2}.Kx,'Ki',m7.designs{2}.Ki, ...
    'baselineCommit',baseline.baselineCommit,'spec',m5.spec, ...
    'hinfCandidates',h.studio.tabella, ...
    'kalmanUnchanged',isequaln(m6.L,baseline.baselineM6.L) && ...
        isequaln(m6.Qn,baseline.baselineM6.Qn) && ...
        isequaln(m6.Rn,baseline.baselineM6.Rn));
save(fullfile(data,'direct_weights_summary.mat'),'summary','-v7');
writetable(lqrSummary,fullfile(data,'direct_lqr_summary.csv'));
% La tabella LaTeX non contiene esiti prestazionali assegnati manualmente.
f=fopen(fullfile(root,'report','generated','direct_hinf_production.tex'),'w');
assert(f~=-1,'DirectSummary:Write','Impossibile scrivere la tabella.');
cleanup=onCleanup(@() fclose(f));
fprintf(f,'%% Generato da build_direct_weights_summary.m.\n');
fprintf(f,'\\begin{table}[htbp]\\centering\\scriptsize\n');
fprintf(f,'\\begin{tabular}{lrrrrrrrl}\\toprule\n');
fprintf(f,'Controllore & ordine & $\\gamma$ & $\\|W_1S\\|_\\infty$ & $\\|W_2KS\\|_\\infty$ & $T_s$ & OS [\\%%] & picco $u$ & Esito \\\\\n\\midrule\n');
for k=1:height(production)
    t=production(k,:); outcome="FAIL"; if t.Pass, outcome="PASS"; end
    fprintf(f,'%s & %d & %.5g & %.5g & %.5g & %.5g & %.5g & %.5g & %s \\\\\n', ...
        t.Controller,t.Order,t.Gamma,t.W1S,t.W2KS,t.Ts,t.OvershootPercent,t.PeakUNm,outcome);
end
fprintf(f,'\\bottomrule\\end{tabular}\n');
fprintf(f,'\\caption{Produzione a due pesi, senza $W_3$: scenari esistenti, tempi in s, coppie in N m. Esiti calcolati con soglie invariate.}\\label{tab:direct-production}\\end{table}\n');
fprintf(f,'\\begin{table}[htbp]\\centering\\small\n');
fprintf(f,'\\begin{tabular}{lrr}\\toprule Controllore & errore statico relativo & cross-coupling \\\\\n\\midrule\n');
for k=1:height(production)
    fprintf(f,'%s & %.6g & %.6g \\\\\n',production.Controller(k), ...
        production.SteadyErrorRelative(k),production.CrossCoupling(k));
end
fprintf(f,'\\bottomrule\\end{tabular}\\caption{Metriche relative della stessa campagna; il target statico rimane 0.05.}\\end{table}\n');
disp(production); disp(lqrSummary); disp(m7.manualComparisonTable);
end
