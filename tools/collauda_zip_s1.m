function collauda_zip_s1(modes)
%COLLAUDA_ZIP_S1 Due modalita realmente eseguite fuori dal repository.
arguments
    modes (1,:) string = ["rapida","completa"]
end
root=fileparts(fileparts(mfilename('fullpath')));
manifest=jsondecode(fileread(fullfile(root,'delivery/manifest_S1.json')));
folder=manifest.isolated_directory; output=fullfile(root,'docs/audit_ristrutturazione');
tests=fullfile(root,'tests/seaS1ConsegnaTest.m');
before=pwd; cleanup=onCleanup(@()cd(before)); %#ok<NASGU>
restoredefaultpath;cd(folder);addpath(folder);set(groot,'DefaultFigureVisible','off');
setenv('SEA_TEST_ROOT',folder);
for mode=modes
    file=fullfile(folder,'parametri_sea.m'); source=fileread(file);
    source=replace(string(source),["p.modalita=""rapida"";","p.modalita=""completa"";"], ...
        "p.modalita="""+mode+""";");
    fid=fopen(file,'w','n','UTF-8');fprintf(fid,'%s',source);fclose(fid);
    clear parametri_sea
    clockStart=tic;run(fullfile(folder,'SEA_00_AVVIO_PROGETTO.m'));seconds=toc(clockStart);
    results=runtests(tests);tab=table(results);
    writetable(tab(:,1:5),fullfile(output,"test_zip_"+mode+".csv"));
    a=load(fullfile(folder,'dati/robustezza_S1.mat')); names=a.nomi;
    record=struct('mode',mode,'seconds',seconds,'MATLAB',version, ...
        'passed',sum([results.Passed]),'failed',sum([results.Failed]), ...
        'incomplete',sum([results.Incomplete]),'externalDirectory',folder, ...
        'controllerNames',names,'zipSHA256',manifest.zip_sha256, ...
        'scientificFunctionFiles',string({which('parametri_sea'),which('dinamica_sea'),which('simula_sea')}));
    record.loadedRepositoryPaths=any(startsWith(record.scientificFunctionFiles,string(root)+filesep));
    assert(~record.loadedRepositoryPaths,'SEA:Percorsi','Dipendenza esterna al pacchetto.');
    fid=fopen(fullfile(output,"collaudo_zip_"+mode+".json"),'w');
    fprintf(fid,'%s\n',jsonencode(record,'PrettyPrint',true));fclose(fid);
    assertSuccess(results);
end
setenv('SEA_TEST_ROOT','');
end
