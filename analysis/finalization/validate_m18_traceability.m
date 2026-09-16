function audit = validate_m18_traceability(e, numericAudit)
%VALIDATE_M18_TRACEABILITY Cross-check final claims against validated data.
arguments
    e (1,1) struct = load_m18_validated_artifacts
    numericAudit table = build_m18_report_values(e)
end
s=e.m16.stabilitySummary; roles=e.m17.finalRoleAssignment;
recomputedStable=zeros(height(s),1);
for index=1:height(s)
    recomputedStable(index)=sum(e.m16.stabilityTable.Controller==s.Controller(index) & e.m16.stabilityTable.Stable);
end
unstable=e.m16.stabilityTable(~e.m16.stabilityTable.Stable,:);
criticalCasesRecorded=isempty(unstable) || all(unstable.MaxRealPole>0 & unstable.NumberRhpPoles>0);
% Le conclusioni seguono i bound correnti, senza imporre il vecchio PASS.
rs=e.m14.robustStabilityMargin;
expectedRS="INCONCLUSIVE";
if rs.LowerBound>1, expectedRS="PASS_CERTIFIED";
elseif rs.UpperBound<1, expectedRS="FAIL_CERTIFIED"; end
rsConsistent=string(e.m14.qualityGate.robustStability)==expectedRS && ...
    rs.LowerBound<=rs.UpperBound;
expectedRobustRole="NONE";
if expectedRS=="PASS_CERTIFIED" && all(e.m16.stabilityTable.Stable( ...
        e.m16.stabilityTable.Controller=="Kmu"))
    expectedRobustRole="Kmu";
end
label=["Controller identity audit M17";"Controller orders 14/18/70";"M16 sample count";"M16 stability-table consistency";"M16 critical cases recorded";"Kmu RS margin M14";"Kmu NP/RP M14";"Final role selection M17";"RAS empirical semantics";"uScale normalization semantics";"Monte Carlo empirical semantics";"M7 status preserved";"M9 status preserved";"M10 status preserved";"M11 status preserved";"M12 status preserved";"M14 status preserved";"M15 status preserved";"All numeric rows source-mapped"];
passed=[all(e.m17.controllerIdentityAudit.IdentityPassed);isequal([order(e.m6.Klqg);order(e.m10.Khinf);order(e.m13.Kmu)],[14;18;70]);e.m16.numberSamples==40;isequal(s.NStable,recomputedStable);criticalCasesRecorded;rsConsistent;string(e.m14.qualityGate.nominalPerformance)=="FAIL"&&string(e.m14.qualityGate.robustPerformance)=="FAIL_CERTIFIED";roles.Controller(roles.Role=="FINAL ROBUST CONTROLLER")==expectedRobustRole&&roles.Controller(roles.Role=="NOMINAL PERFORMANCE REFERENCE")=="M6"&&roles.Controller(roles.Role=="H-INFINITY REFERENCE / COMPARATOR")=="Khinf";~any(e.m17.rasComparison.AnalyticallyCertified)&&all(contains(e.m17.rasComparison.Interpretation,"EMPIRICAL"));contains(string(e.m5.spec.controlEffortScaleMeaning),"normalization")&&contains(e.config.uScaleInterpretation,"NOT_CERTIFIED_SATURATION");contains(e.config.monteCarloInterpretation,"NOT_A_ROBUSTNESS_CERTIFICATE");string(e.m7.validationMetrics.status)=="PARTIAL";string(e.m9.qualityGate.overallStatus)=="PARTIAL";string(e.m10.qualityGate.overallStatus)=="PARTIAL";string(e.m11.qualityGate.overallStatus)=="PARTIAL";string(e.m12.qualityGate.overallStatus)=="PARTIAL";string(e.m14.qualityGate.overallStatus)=="PARTIAL";string(e.m15.qualityGate.overallStatus)=="PARTIAL";all(strlength(numericAudit.SourceMilestone)>0&strlength(numericAudit.SourceArtifact)>0&strlength(numericAudit.SourceField)>0&strlength(numericAudit.ReportMacro_Table)>0)];
details=repmat("read directly from a validated result",numel(label),1); details(end)="every generated numeric row has a source mapping";
audit=table(label,passed,details,'VariableNames',{'Check','Passed','Details'});
assert(all(audit.Passed),"M18:TraceabilityFailure","M18 mismatch: %s",strjoin(audit.Check(~audit.Passed),", "));
end
