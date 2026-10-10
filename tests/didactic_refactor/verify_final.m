function verify_final
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
t=fullfile(root,'tmp','refactor_didactic'); b=load(fullfile(t,'baseline.mat'));
h=load(fullfile(t,'after_hinf.mat')); h=h.h;
m=load(fullfile(t,'after_mu.mat')); m=m.m;
report=struct('baselineCommit','6133365','release',version,'matrixMaxError',0);
report.frequencyMaxError=0; report.dcMaxError=0; report.poleMaxError=0;
report.disturbanceMaxError=0; report.commandPeakRmsMaxError=0;
for j=1:3
    for name={'riferimento','disturbo','S','KS','T','UR','QD','UD','pesato'}
        a=h.valutazioni{j}.(name{1}); old=b.hinf.valutazioni{j}.(name{1});
        report.frequencyMaxError=max(report.frequencyMaxError, ...
            max(abs(freqresp(a,h.omega)-freqresp(old,h.omega)),[],'all'));
        report.dcMaxError=max(report.dcMaxError,max(abs(dcgain(a)-dcgain(old)),[],'all'));
    end
    report.poleMaxError=max(report.poleMaxError,max(abs(h.valutazioni{j}.poli-b.hinf.valutazioni{j}.poli)));
    assert(isequaln(h.valutazioni{j}.metriche,b.hinf.valutazioni{j}.metriche));
    assert(isequaln(h.valutazioni{j}.metricheDisturbo,b.hinf.valutazioni{j}.metricheDisturbo));
end
for j=1:2
    new=m.mappeFisiche{j}; old=b.mu.mappeFisiche{j};
    report.frequencyMaxError=max(report.frequencyMaxError,max(abs(freqresp(new,m.omega)-freqresp(old,m.omega)),[],'all'));
    report.dcMaxError=max(report.dcMaxError,max(abs(dcgain(new)-dcgain(old)),[],'all'));
    report.poleMaxError=max(report.poleMaxError,max(abs(pole(new)-pole(old))));
    yn=step(new(:,3:4),m.tempo)*.5; yo=step(old(:,3:4),m.tempo)*.5;
    report.disturbanceMaxError=max(report.disturbanceMaxError,max(abs(yn-yo),[],'all'));
    un=m.comandi{j}; uo=b.mu.comandi{j};
    metricsNew=[max(abs(un),[],'all'),sqrt(mean(un.^2,'all')), ...
        max(abs(yn(:,3:4,:)),[],'all'),sqrt(mean(yn(:,3:4,:).^2,'all'))];
    metricsOld=[max(abs(uo),[],'all'),sqrt(mean(uo.^2,'all')), ...
        max(abs(yo(:,3:4,:)),[],'all'),sqrt(mean(yo(:,3:4,:).^2,'all'))];
    report.commandPeakRmsMaxError=max(report.commandPeakRmsMaxError,max(abs(metricsNew-metricsOld)));
    for signal={m.comandi{j},yn(:,3:4,:)}
        z=signal{1}; assert(all(isfinite(z),'all'));
    end
    assert(isequal(m.comandi{j},b.mu.comandi{j}));
end
assert(report.frequencyMaxError==0 && report.dcMaxError==0 && report.poleMaxError==0 && report.disturbanceMaxError==0 && report.commandPeakRmsMaxError==0);
workspaceH={'physical','A','B','Bd','Cq','G','W1','W2','Mo','P1','P2','Ke','K1','K2','Kr','Ky','Kpid','Ak1','Bk1','Ck1','Dk1','Ak2','Bk2','Ck2','Dk2','Acl1','Acl2','tempo','omega','cfg','spec','confronto','risultati'};
workspaceM={'physical','physicalNom','Amech','Btau','Bd','Cq','Gmech','Ga','WI','Gact','W1','W2','Mo','P','Khinf','Kmu','CLhinf','CLmu','N_hinf','Delta_hinf','N_mu','Delta_mu','BlkStruct','NormUnc','tempo','omega','analisi','muGriglia','storiaDK','tracking','comandi','mappeFisiche','confronto','risultati'};
for name=workspaceH
    assert(isfield(h,name{1})); assert(isequaln(h.(name{1}),b.hinf.(name{1})),'Workspace differs: %s',name{1});
end
for name=workspaceM
    assert(isfield(m,name{1})); assert(isequaln(m.(name{1}),b.mu.(name{1})),'Workspace differs: %s',name{1});
end
report.workspaceHinf=workspaceH; report.workspaceMu=workspaceM;
report.hinfNorms=h.confronto.NormaPropria'; report.muNorms=m.confronto.NormaNominale';
report.muRS=[m.confronto.RS_lower,m.confronto.RS_upper]; report.muRP=[m.confronto.RP_lower,m.confronto.RP_upper];
report.archivedObjective=m.obiettivoMu;
% File mancanti: copie in un layout temporaneo senza results, dati reali intatti.
layout=fullfile(t,'missing','File_di_Funzioni_Progetto-Accorpati'); if ~isfolder(layout), mkdir(layout); end
copyfile(fullfile(root,'File_di_Funzioni_Progetto-Accorpati','support'),fullfile(layout,'support'));
for file={'progetto_hinf_tre_controllori.m','progetto_mu.m'}
    copyfile(fullfile(root,'File_di_Funzioni_Progetto-Accorpati',file{1}),fullfile(layout,file{1}));
    caught=false;
    try, run_capture(fullfile(layout,file{1}));
    catch err, caught=contains(err.identifier,'FileMancante') && contains(err.message,'selected_full_order.mat') || ...
            contains(err.identifier,'FileMancante') && contains(err.message,'nominal_study.mat'); end
    assert(caught,'Missing artifact was not clearly identified');
end
files=[dir(fullfile(root,'File_di_Funzioni_Progetto-Accorpati','progetto_hinf*.m')); ...
    dir(fullfile(root,'File_di_Funzioni_Progetto-Accorpati','progetto_mu.m')); ...
    dir(fullfile(root,'File_di_Funzioni_Progetto-Accorpati','support','*.m'))];
report.codeAnalyzer=struct;
for j=1:numel(files)
    messages=checkcode(fullfile(files(j).folder,files(j).name),'-id');
    report.codeAnalyzer.(matlab.lang.makeValidName(files(j).name))=messages;
end
report.gate='PASS';
fid=fopen(fullfile(t,'numerical_report.json'),'w'); fprintf(fid,'%s',jsonencode(report,PrettyPrint=true)); fclose(fid);
fprintf('FINAL PASS: FREQUENCY, DC, POLES, DISTURBANCE, COMMANDS, WORKSPACE, MISSING ARTIFACTS\n');
end
