% Tre livelli progettuali, senza cambiare le soglie matematiche NS/NP/RS/RP.
radice=fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(radice,'File_di_Funzioni_Progetto-Accorpati')); p=parametri_sea;
a=load(fullfile(p.risultati,'modello.mat')); m=a.modello;
a=load(fullfile(p.dati,'banca_validata.mat')); b=a.banca;
livelli=p.specificheCandidate;
righe=cell(3*numel(b.controllers),9); riga=0;
for k=1:numel(b.controllers)
    K=b.controllers(k).K; [~,cl]=interconnessione_sea(m.P0,p,size(K,2)-2,K);
    ns=isstable(cl); ts=Inf; mp=Inf; ess=Inf; cross=Inf;
    if ns
        y=step(cl(1:2,1:2),p.tempo); dc=dcgain(cl(1:2,1:2));
        ess=max(abs(diag(dc)-1)); cross=max([abs(y(:,1,2));abs(y(:,2,1))]);
        ts=0; mp=0;
        for j=1:2
            z=y(:,j,j); ultimo=find(abs(z-dc(j,j))>.02*abs(dc(j,j)),1,'last');
            tj=0;
            if ~isempty(ultimo)
                if ultimo==numel(p.tempo),tj=Inf;else,tj=p.tempo(ultimo+1);end
            end
            ts=max(ts,tj); mp=max(mp,100*max(0,max(z)-1));
        end
    end
    for j=1:3
        riga=riga+1; ok=ns && all([ts mp ess cross]<=livelli(j,:));
        righe(riga,:)={string(b.controllers(k).name),j,ns,ts,mp,ess,cross,ok,livelli(j,1)};
    end
end
tabella=cell2table(righe,'VariableNames',{'ControlloreFissato','Candidato','NS','Ts','Mp','Ess','Cross','TargetRaggiunti','TsTarget'});
writetable(tabella,fullfile(p.risultati,'candidati_specifiche.csv')); disp(tabella);
% Modello di riferimento criticamente smorzato: tempo al 2% per omega=3/4/5.
s=tf('s'); dati=zeros(3,2);
for j=1:3
    w=j+2; info=stepinfo(w^2/(s^2+2*w*s+w^2)); dati(j,:)=[w info.SettlingTime];
end
writetable(array2table(dati,'VariableNames',{'OmegaM','TsModelloRiferimento'}), ...
    fullfile(p.risultati,'candidati_riferimento.csv'));
