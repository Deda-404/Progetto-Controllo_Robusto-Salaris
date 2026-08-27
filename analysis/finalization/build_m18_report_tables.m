function tablePaths = build_m18_report_tables(evidence)
%BUILD_M18_REPORT_TABLES Generate report tables from frozen artifacts.

arguments
    evidence (1, 1) struct = load_m18_validated_artifacts
end
tableRoot=fullfile(evidence.root,"report","tables"); if ~isfolder(tableRoot), mkdir(tableRoot); end
names=["nominal_parameters.tex";"uncertainties_m4.tex";"specifications_m5.tex"; ...
    "lqg_m6_m7.tex";"hinf_summary.tex";"mu_summary.tex"; ...
    "nonlinear_validation.tex";"monte_carlo_m16.tex"; ...
    "master_comparison_m17.tex";"final_role_selection.tex";"limitations.tex"];
content={localNominal(evidence),localUncertainty(evidence),localSpecs(evidence), ...
    localLqg(evidence),localHinf(evidence),localMu(evidence), ...
    localNonlinear(evidence),localMonteCarlo(evidence),localMaster(evidence), ...
    localRoles(evidence),localLimitations(evidence)};
tablePaths=strings(numel(names),1);
for index=1:numel(names)
    tablePaths(index)=fullfile(tableRoot,names(index)); localWrite(tablePaths(index),content{index});
end
end

function text=localNominal(e)
p=e.nominalParameters;
rows=["$m_1$",num(p.m1),"kg";"$m_2$",num(p.m2),"kg";"$l_1$",num(p.l1),"m"; ...
    "$l_2$",num(p.l2),"m";"$J_{m1}=J_{m2}$",num(p.Jm(1,1)),"kg m$^2$"; ...
    "$B_{m1}=B_{m2}$",num(p.Bm(1,1)),"N m s/rad";"$k_1$",num(p.Ks(1,1)),"N m/rad"; ...
    "$k_2$",num(p.Ks(2,2)),"N m/rad";"$g$",num(p.g),"m/s$^2$"];
text=makeTable("Parametri nominali principali.","tab:nominal-parameters",["Parametro","Valore","Unita"],rows,false);
end

function text=localUncertainty(e)
m=e.m4.selectedMechanicalRanges; a=e.m4.selectedActuatorRanges; rows=strings(height(m)+height(a),4);
for k=1:height(m), rows(k,:)=[m.Parameter(k),num(m.NominalValue(k)),num(m.BaselinePercent(k))+"\%","parametrica reale"]; end
for k=1:height(a), j=height(m)+k; rows(j,:)=[a.Parameter(k),num(a.NominalValue(k)),num(a.BaselinePercent(k))+"\%","famiglia coperta da $W_I\Delta$"]; end
text=makeTable("Incertezze ingegneristiche M4; i range non sono distribuzioni probabilistiche identificate.","tab:uncertainties",["Parametro","Nominale","Range","Rappresentazione"],rows,true);
end

function text=localSpecs(e)
s=e.m5.spec; rows=["Settling time","$T_s \leq$ "+num(s.settlingTimeTarget),"s"; ...
    "Overshoot","$M_p \leq$ "+num(s.overshootTarget),"\%"; ...
    "Errore a regime","$e_{ss} \leq$ "+num(100*s.steadyStateTrackingTarget),"\%"; ...
    "Cross-coupling","picco $\leq$ "+num(100*s.crossCouplingTarget),"\%"; ...
    "Banda di progetto",num(s.omegaB),"rad/s";"Scala del comando",num(s.uScale),"N m (normalizzazione)"];
text=makeTable("Specifiche e normalizzazioni congelate M5.","tab:specifications",["Quantita","Target","Unita/nota"],rows,false);
end

function text=localLqg(e)
m6=e.m6.trackingMetrics.lqg;
rows=["M6 LQG",string(order(e.m6.Klqg)),num(max(m6.SettlingTime)),num(max(m6.Overshoot)),"PASS nominale","senza integratore"; ...
    "M7 LQG-I","N/A","N/A","N/A",tex(e.m7.validationMetrics.status),"0 candidati ammissibili"];
text=makeTable("Confronto M6/M7. Il risultato M7 negativo resta esplicito.","tab:lqg",["Studio","Ordine","$T_s$ [s]","$M_p$ [\%]","Stato","Nota"],rows,true);
end

function text=localHinf(e)
t=e.m11.representativeTable;
rows=["M9 mixsyn",string(order(e.m9.Kmix)),num(e.m9.gamma),tex(e.m9.qualityGate.nominalStability),tex(e.m9.qualityGate.weightedNominalPerformance); ...
    "M10 hinfsyn",string(order(e.m10.Khinf)),num(e.m10.gammaHinf),tex(e.m10.qualityGate.nominalStability),tex(e.m10.qualityGate.weightedNominalPerformance); ...
    "M11 A3","2",num(t.Objective(t.ArchitectureID=="A3")),"PASS","FAIL"; ...
    "M11 A4","4",num(t.Objective(t.ArchitectureID=="A4")),"PASS","FAIL"; ...
    "M11 A5","6",num(t.Objective(t.ArchitectureID=="A5")),"PASS","FAIL"];
text=makeTable("Sintesi nominali H-infinity. Un valore $\gamma>1$ non costituisce PASS prestazionale.","tab:hinf",["Controllore","Ordine","$\gamma$/objective","NS","NP"],rows,false);
end

function text=localMu(e)
rows=["A5 M12","6",tex(e.m12.qualityGate.nominalStability),tex(e.m12.qualityGate.nominalPerformance),num(e.m12.robustStabilityMargin.LowerBound)+"--"+num(e.m12.robustStabilityMargin.UpperBound),tex(e.m12.qualityGate.robustStability),tex(e.m12.qualityGate.robustPerformance); ...
    "Kmu M14",string(order(e.m13.Kmu)),tex(e.m14.qualityGate.nominalStability),tex(e.m14.qualityGate.nominalPerformance),num(e.m14.robustStabilityMargin.LowerBound)+"--"+num(e.m14.robustStabilityMargin.UpperBound),tex(e.m14.qualityGate.robustStability),tex(e.m14.qualityGate.robustPerformance)];
text=makeTable("Esiti distinti di NS, NP, RS e RP.","tab:mu",["Controllore","Ordine","NS","NP","Margine RS","RS","RP"],rows,true);
end

function text=localNonlinear(e)
t=e.m17.nonlinearComparison; r=e.m17.rasComparison; rows=strings(height(t),7);
for k=1:height(t), rr=r.Controller==t.Controller(k); rows(k,:)=[t.Controller(k),tex(t.TrackingStatus(k)),num(t.WorstTrackingTs(k)),num(t.WorstTrackingOvershootPercent(k)),num(100*t.WorstTrackingSteadyErrorRelative(k)),num(r.MinimumRadiusDeg(rr)),tex(r.Classification(rr))]; end
text=makeTable("Validazione non lineare nominale M8/M15. Le RAS sono stime empiriche.","tab:nonlinear",["Controller","Tracking","$T_s$ [s]","$M_p$ [\%]","$e_{ss}$ [\%]","$r_{min}$ [deg]","RAS"],rows,true);
end

function text=localMonteCarlo(e)
t=e.m17.monteCarloComparison; rows=strings(height(t),6);
for k=1:height(t), rows(k,:)=[t.Controller(k),string(t.NStable(k))+"/"+string(t.NTotal(k)),num(100*t.EmpiricalStabilityRate(k)),tex(t.UnstableSamples(k)),num(100*t.CoreTrackingPassRateTotal(k)),num(t.MedianWorstTrackingPeakUNm(k))]; end
text=makeTable("Monte Carlo M16: evidenza empirica lineare, non certificazione di robustezza.","tab:monte-carlo",["Controller","Stabili","Rate [\%]","Campioni instabili","Core tracking [\%]","Peak $u$ mediano [N m]"],rows,true);
end

function text=localMaster(e)
t=e.m17.masterComparison; rows=strings(height(t),8);
for k=1:height(t), rows(k,:)=[t.Controller(k),string(t.Order(k)),tex(t.NominalNonlinearTrackingStatus(k)),tex(t.MonteCarloStability(k)),tex(t.FormalRS(k)),tex(t.FormalRP(k)),tex(t.NominalNonlinearRAS(k)),tex(t.FinalRole(k))]; end
text=makeTable("Confronto finale M17; le evidenze restano separate.","tab:master",["Controller","Ordine","Tracking NL","MC stabilita","RS formale","RP formale","RAS","Ruolo"],rows,true);
end

function text=localRoles(e)
t=e.m17.finalRoleAssignment; rows=strings(height(t),3);
for k=1:height(t), rows(k,:)=[tex(t.Role(k)),t.Controller(k),tex(t.Rationale(k))]; end
text=makeTable("Selezione congelata per ruolo, senza score globale.","tab:roles",["Ruolo","Controller","Motivazione"],rows,true);
end

function text=localLimitations(e)
items=string(e.m17.limitations);
historical="No controller reduction, retuning, new synthesis, or M18 work is authorized";
items(items==historical)="No controller reduction, retuning, new synthesis, or technical redesign is authorized in M18";
text="\begin{itemize}"+newline;
for k=1:numel(items), text=text+"\item "+tex(items(k))+newline; end
text=text+"\end{itemize}"+newline;
end

function text=makeTable(caption,label,headers,rows,resize)
spec=string(repmat('l',1,numel(headers))); text="\begin{table}[H]"+newline+"\centering"+newline;
if resize, text=text+"\resizebox{\textwidth}{!}{%"+newline; end
text=text+"\begin{tabular}{"+spec+"}"+newline+"\toprule"+newline+strjoin(headers," & ")+" \\"+newline+"\midrule"+newline;
for k=1:size(rows,1), text=text+strjoin(rows(k,:)," & ")+" \\"+newline; end
text=text+"\bottomrule"+newline+"\end{tabular}"+newline;
if resize, text=text+"}"+newline; end
text=text+"\caption{"+caption+"}"+newline+"\label{"+label+"}"+newline+"\end{table}"+newline;
end

function localWrite(path,content)
f=fopen(path,'w'); c=onCleanup(@() fclose(f)); fprintf(f,'%% Generated by build_m18_report_tables.m. Do not edit.\n%s',content);
end
function text=num(v), if isnan(v), text="N/A"; elseif isinf(v), text="$\infty$"; else, text=string(compose("%.5g",v)); end, end
function text=tex(v), text=string(v); text=replace(text,"_","\_"); text=replace(text,"%","\%"); text=replace(text,"&","\&"); text=replace(text,"#","\#"); end
