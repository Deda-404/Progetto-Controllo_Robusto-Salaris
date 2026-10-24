function result = salaris_audit_loop(cl)
%SALARIS_AUDIT_LOOP NS/NP e intervalli RS/RP, con esiti distinti.
result.NS=isstable(cl.NominalValue);
result.nominalNorm=norm(cl.NominalValue(5:8,:),inf);
result.NP=result.NS && result.nominalNorm<1;
[result.RS,result.rsWorst]=robstab(cl);
result.RPBoundMethod="robgain";
if result.RS.UpperBound<1
    result.RP=struct('LowerBound',0,'UpperBound',result.RS.UpperBound, ...
        'CriticalFrequency',result.RS.CriticalFrequency);
    result.rpWorst=struct;
    result.RPBoundMethod="Upper bound from RS: RP implies RS";
elseif result.NS && result.NP
    [result.RP,result.rpWorst]=robgain(cl(5:8,:),1);
else
    result.RP=struct('LowerBound',0,'UpperBound',0,'CriticalFrequency',NaN);
    result.rpWorst=struct;
end
result.RSOutcome=outcome(result.RS);
result.RPOutcome=outcome(result.RP);
result.bandwidth=zeros(1,2);
for j=1:2, result.bandwidth(j)=bandwidth(cl.NominalValue(j,j)); end
result.disturbanceNorm=norm(cl.NominalValue(1:2,3:4),inf);
result.commandNorm=norm(cl.NominalValue(3:4,1:2),inf);
end
function value=outcome(m)
if m.LowerBound>m.UpperBound || any(isnan([m.LowerBound,m.UpperBound]))
    value="NUMERICAL_INCONCLUSIVE";
elseif m.LowerBound>1
    value="PASS";
elseif m.UpperBound<1
    value="FAIL";
else
    value="INCONCLUSIVE";
end
end
