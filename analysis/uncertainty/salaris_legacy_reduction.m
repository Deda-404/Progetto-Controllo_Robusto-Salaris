function salaris_legacy_reduction
%SALARIS_LEGACY_REDUCTION Le riduzioni devono conservare anche la famiglia M4.
d=final_closure_load; q=d.selected; folder=fullfile(d.root,'results/data/salaris_revision');
m4=load(fullfile(d.root,'results/data/m4_uncertain_plant.mat'));
plant=hinf_final_uncertain(m4,d.m5.BdFull); rows=cell(0,7);
for target=[82 70 60]
    source=fullfile(folder,sprintf('mu_reduction_%d_A_full.mat',target));
    a=load(source,'audit'); K=a.audit.K;
    destination=fullfile(folder,sprintf('mu_reduction_%d_legacy.mat',target));
    if isfile(destination)
        a=load(destination,'audit'); audit=a.audit;
    else
        cl=salaris_closed_loop(plant,K,q.W1,q.W2,q.Mo);
        audit=salaris_audit_loop(cl); audit.K=K; audit.CL=cl;
        save(destination,'audit','-v7');
    end
    rows(end+1,:)={target,audit.NS,audit.nominalNorm,audit.RS.LowerBound,audit.RS.UpperBound, ...
        audit.RP.LowerBound,audit.RP.UpperBound}; %#ok<AGROW>
end
tab=cell2table(rows,'VariableNames',{'Order','NS','NominalNorm','RSLower','RSUpper','RPLower','RPUpper'});
writetable(tab,fullfile(folder,'legacy_reduction.csv'));
end
