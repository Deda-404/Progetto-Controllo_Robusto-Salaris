function audit_ristrutturazione_didattica
%AUDIT_RISTRUTTURAZIONE_DIDATTICA Verifiche preliminari, senza nuove sintesi.
% Eseguire dalla radice. Le alternative sono studi preliminari, non adottate.
root=fileparts(fileparts(mfilename('fullpath')));
out=fullfile(root,'docs','audit_ristrutturazione');
if ~isfolder(out), mkdir(out); end
addpath(genpath(fullfile(root,'src')),genpath(fullfile(root,'controllers')), ...
    genpath(fullfile(root,'analysis')),fullfile(root,'simulink'), ...
    fullfile(root,'File_di_Funzioni_Progetto-Accorpati','support'));
set(groot,'DefaultFigureVisible','off');
environment=struct('version',version,'release',version('-release'), ...
    'products',ver,'date','2026-10-25','newSynthesis',false,'slxModified',false);
writeJson(fullfile(out,'ambiente.json'),environment);

%% Dipendenze statiche e Code Analyzer: lettura dei sorgenti, nessun Run.
entries=["progetto_lqg.m","progetto_lqgi.m", ...
    "progetto_hinf_tre_controllori.m","progetto_mu.m"];
dependencies=struct([]);
for j=1:numel(entries)
    file=fullfile(root,'File_di_Funzioni_Progetto-Accorpati',entries(j));
    [files,products]=matlab.codetools.requiredFilesAndProducts(file);
    relative=erase(string(files),string(root)+filesep);
    dependencies(j).entry=entries(j);
    dependencies(j).files=replace(relative,'\','/');
    dependencies(j).products=products;
    fprintf('Dipendenze %s: %d file\n',entries(j),numel(files));
end
writeJson(fullfile(out,'dipendenze_matlab.json'),dependencies);
[status,list]=system('git ls-files -- "*.m"'); assert(status==0);
files=splitlines(string(strtrim(list))); issues=struct([]);
for j=1:numel(files)
    messages=checkcode(fullfile(root,files(j)),'-struct','-id');
    issues(j).file=files(j); issues(j).messages=messages;
end
writeJson(fullfile(out,'code_analyzer.json'),issues);

%% Cinque valori per parametro: ruolo fisico, non scelta di un nuovo range.
p=actuator_params_nominal; factors=[-1 -.5 0 .5 1];
omega=unique([logspace(-2,4,1201),7.209,12,40,69.95]); jw=1i*omega;
G0=p.wn^2./(jw.^2+2*p.zeta*p.wn*jw+p.wn^2).* ...
    (1-p.delay*jw/2)./(1+p.delay*jw/2);
names=["wn","zeta","delay"]; percentages=[.1 .1 .2];
rows=cell(15,7); count=0;
for j=1:3
    for factor=factors
        par=p; par.(names(j))=p.(names(j))*(1+percentages(j)*factor);
        G=par.wn^2./(jw.^2+2*par.zeta*par.wn*jw+par.wn^2).* ...
            (1-par.delay*jw/2)./(1+par.delay*jw/2);
        ratio=G./G0; count=count+1;
        rows(count,:)={names(j),factor,par.(names(j)), ...
            max(abs(ratio(omega<=12)-1)), ...
            max(abs(ratio(omega<=40)-1)),max(abs(ratio-1)), ...
            max(abs(rad2deg(angle(ratio(omega<=40)))))};
    end
end
sensitivity=cell2table(rows,'VariableNames',{'Parameter','NormalizedValue', ...
    'PhysicalValue','MaxRelativeErrorTo12','MaxRelativeErrorTo40', ...
    'MaxRelativeErrorOnGrid','MaxPhaseDeviationTo40Deg'});
writetable(sensitivity,fullfile(out,'sensibilita_attuatori.csv'));

%% Occorrenze dei quattro insiemi candidati: nessuno viene adottato.
sets={"wn",["wn","zeta"],["wn","delay"],["zeta","delay"]};
structures=struct([]); s=tf('s');
for j=1:numel(sets)
    wn=p.wn; zeta=p.zeta; tau=p.delay;
    if ismember("wn",sets{j}),wn=ureal('wn',wn,'Percentage',10);end
    if ismember("zeta",sets{j}),zeta=ureal('zeta',zeta,'Percentage',10);end
    if ismember("delay",sets{j}),tau=ureal('tau',tau,'Percentage',20);end
    H=uss([0 1;-wn*wn -2*zeta*wn],[0;wn*wn],[1 0],0);
    if isnumeric(tau)
        Dp=ss(-2/tau,2/tau,2,-1);
    else
        Dp=uss(-2/tau,2/tau,2,-1);
    end
    G=H*Dp;
    [~,~,blocks]=lftdata(G);
    structures(j).parameters=sets{j}; structures(j).blocks=blocks;
    structures(j).nominalError=max(abs(freqresp(G.NominalValue,omega)- ...
        freqresp(p.wn^2/(s^2+2*p.zeta*p.wn*s+p.wn^2)* ...
        (1-p.delay*s/2)/(1+p.delay*s/2),omega)),[],'all');
end
writeJson(fullfile(out,'alternative_delta.json'),structures);

%% Banca congelata: stabilita interna e interfacce, nessun certificato nuovo.
d=final_closure_load; rows=cell(6,5);
for j=1:6
    c=d.controllers(j);
    cl=final_closure_loop(d.m3.Afull,d.m3.Bfull,d.m5.BdFull,d.m3.CfullQ,c);
    rows(j,:)={c.name,c.order,size(c.K,1),size(c.K,2),max(real(cl.poles))};
end
controllers=cell2table(rows,'VariableNames', ...
    {'Controller','Order','Outputs','Inputs','MaxRealClosedLoopPole'});
writetable(controllers,fullfile(out,'controllori_baseline.csv'));
assert(all(controllers.MaxRealClosedLoopPole < -1e-8));

%% Regressioni pertinenti alla baseline, ripristino degli output consolidati.
guard=preserve_validation_outputs(root); %#ok<NASGU> onCleanup ripristina anche su errore
names={'test_m1_nonlinear_model.m','test_m2_equilibrium_linearization.m', ...
    'test_m3_actuator_dynamics.m','test_m4_uncertainty_model.m', ...
    'test_m5_performance_specs.m','test_m6_lqg_no_integrator.m', ...
    'test_m7_lqg_integral.m'};
testResults=runtests(fullfile(root,'tests',names));
clear guard
tests=table(testResults); writetable(tests(:,1:5),fullfile(out,'test_baseline.csv'));
save(fullfile(out,'test_baseline.mat'),'testResults','-v7');
writeJson(fullfile(out,'gate_matlab.json'),struct('passed',sum([testResults.Passed]), ...
    'failed',sum([testResults.Failed]),'incomplete',sum([testResults.Incomplete]), ...
    'entriesExecuted',false,'robustSynthesisExecuted',false, ...
    'newABRobustnessValidated',false,'newZipTested',false));
assertSuccess(testResults);
end

function writeJson(file,value)
fid=fopen(file,'w','n','UTF-8'); assert(fid>=0); cleanup=onCleanup(@()fclose(fid));
fprintf(fid,'%s\n',jsonencode(value,'PrettyPrint',true));
end
