function audits = audit_noise_robustness
% Post-analisi nuova e precedente, senza trasferire i certificati baseline.
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(genpath(fullfile(root,'analysis'))); d=final_closure_load;
folder=fullfile(root,'results/data/noise_redesign');
m4=load(fullfile(root,'results/data/m4_uncertain_plant.mat'));
physical=hinf_final_uncertain(m4,d.m5.BdFull); q=d.selected;
Pold=hinf_final_2dof_plant(physical,q.W1,q.W2,q.Mo);
files=["hinf_noise_01","hinf_noise_02","hinf_noise_03","mu_noise_01"];
audits=cell(numel(files),1); omega=logspace(-3,8,2001);
for j=1:numel(files)
    source=fullfile(folder,files(j)+".mat"); if ~isfile(source),continue;end
    a=load(source,'candidate'); candidate=a.candidate;
    assert(candidate.status=="SYNTHESIZED");
    file=fullfile(folder,files(j)+"_robust.mat");
    if isfile(file)
        a=load(file,'audit'); audit=a.audit;
        assert(isequaln(audit.K,candidate.K));
    else
        P=noise_generalized_plant(physical,q.W1,q.W2,q.Mo,candidate.Wn);
        audit=struct('name',candidate.name,'K',candidate.K,'release',version('-release'));
        if isa(candidate.P,'uss'), nominal=candidate.P.NominalValue;
        else, nominal=candidate.P; end
        assert(max(abs(freqresp(P.NominalValue,omega)-freqresp(nominal,omega)),[],'all')<1e-7);
        audit.new=localAudit(P,candidate.K); audit.old=localAudit(Pold,candidate.K);
        assert(abs(audit.new.nominalNorm-candidate.newNorm)<1e-5);
        save(file,'audit','-v7');
    end
    audits{j}=audit;
    fprintf('%s new RS=[%g %g] %s RP=[%g %g] %s; old RP=[%g %g] %s\n', ...
        audit.name,audit.new.RS.LowerBound,audit.new.RS.UpperBound,audit.new.RSOutcome, ...
        audit.new.RP.LowerBound,audit.new.RP.UpperBound,audit.new.RPOutcome, ...
        audit.old.RP.LowerBound,audit.old.RP.UpperBound,audit.old.RPOutcome);
end
save(fullfile(folder,'robustness_validation.mat'),'audits','-v7');
end
function a=localAudit(P,K)
a.CL=lft(P,K); a.NS=isstable(a.CL.NominalValue);
a.nominalNorm=norm(a.CL.NominalValue,inf); a.NP=a.NS && a.nominalNorm<1;
rng(20261013,'twister');
[a.RS,a.rsWorst,a.rsInfo]=robstab(a.CL);
[a.RP,a.rpWorst,a.rpInfo]=robgain(a.CL,1);
% Intervalli invertiti restano registrati e vengono riesaminati una volta.
if a.RP.LowerBound>a.RP.UpperBound
    a.rpInitial=a.RP;
    [a.RP,a.rpWorst,a.rpInfo]=robgain(a.CL,1,robOptions('MussvOptions','m9'));
end
a.RSOutcome=outcome(a.RS); a.RPOutcome=outcome(a.RP);
[M,Delta,blocks]=lftdata(a.CL); ndOut=size(Delta,2); ndIn=size(Delta,1);
blockMatrix=zeros(numel(blocks),2);
for k=1:numel(blocks)
    if blocks(k).Type=="ureal"
        blockMatrix(k,:)=[-blocks(k).Size(1),0];
    else
        blockMatrix(k,:)=blocks(k).Size;
    end
end
grid=logspace(-3,5,1201);
rs=mussv(frd(M(1:ndOut,1:ndIn),grid),blockMatrix,'s');
rp=mussv(frd(M,grid),[blockMatrix;size(a.CL,2),size(a.CL,1)],'s');
a.muGrid=grid; a.muRSBounds=reshape(rs.ResponseData,2,[]).';
a.muRPBounds=reshape(rp.ResponseData,2,[]).';
a.muRSMax=max(a.muRSBounds); a.muRPMax=max(a.muRPBounds);
a.rpWorstActualNorm=norm(usubs(a.CL,a.rpWorst),inf);
end
function v=outcome(m)
if m.LowerBound>m.UpperBound
    v="INCONCLUSIVE_NUMERICAL";
elseif m.LowerBound>1
    v="PASS";
elseif m.UpperBound<1
    v="FAIL";
else
    v="INCONCLUSIVE";
end
end
