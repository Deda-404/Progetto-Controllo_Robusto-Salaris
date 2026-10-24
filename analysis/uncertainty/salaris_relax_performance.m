function salaris_relax_performance(factor)
%SALARIS_RELAX_PERFORMANCE Livelli comuni 1,3,10, senza nuove ottimizzazioni.
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
folder=fullfile(root,'results/data/salaris_revision'); rows=cell(0,9);
for name=["A_full","B_parametric"]
    file=fullfile(folder,sprintf('synthesis_musyn_%s_%s_band_%g.mat',name,name,factor));
    a=load(file,'audit'); audit=a.audit;
    for level=[1 3 10]
        target=fullfile(folder,sprintf('relax_%s_band_%g_gain_%g.mat',name,factor,level));
        if isfile(target)
            a=load(target,'rp'); rp=a.rp;
        elseif audit.RS.UpperBound<1
            rp=struct('LowerBound',0,'UpperBound',audit.RS.UpperBound,'CriticalFrequency',audit.RS.CriticalFrequency);
        elseif audit.nominalNorm>=level
            rp=struct('LowerBound',0,'UpperBound',0,'CriticalFrequency',NaN);
        else
            rp=robgain(audit.CL(5:8,:),level);
        end
        save(target,'rp','level','factor','-v7');
        rows(end+1,:)={name,factor,level,audit.nominalNorm,audit.RS.LowerBound, ...
            rp.LowerBound,rp.UpperBound,min(audit.bandwidth),audit.disturbanceNorm}; %#ok<AGROW>
    end
end
tab=cell2table(rows,'VariableNames',{'Model','BandwidthFactor','GainTarget','NominalNorm', ...
    'RSLower','RPLower','RPUpper','MinimumBandwidth','DisturbanceNorm'});
destination=fullfile(folder,'performance_relaxation.csv');
if isfile(destination)
    previous=readtable(destination,'TextType','string');
    previous=previous(previous.BandwidthFactor~=factor,:); tab=[previous;tab];
end
writetable(tab,destination);
end
