function evidence = probe_final_environment
%PROBE_FINAL_ENVIRONMENT Record installed products and attempt every SLX load.
root=fileparts(fileparts(mfilename('fullpath')));
folder=fullfile(root,'results/data/final_simulink_validation');
if ~isfolder(folder),mkdir(folder);end
evidence=struct('date','2026-10-13','computer',getenv('COMPUTERNAME'), ...
    'platform',computer,'matlabroot',matlabroot,'release',version('-release'), ...
    'version',version,'products',ver,'functions',struct,'models',[]);
names={'load_system','sim','ss','lqr','hinfsyn','musyn'};
for k=1:numel(names),evidence.functions.(names{k})=which(names{k});end
manifest=jsondecode(fileread(fullfile(root,'simulink/student_originals_manifest.json')));
records=cell(numel(manifest.models),1);
for k=1:numel(records)
    source=fullfile(root,manifest.models(k).relative_path);
    [~,model]=fileparts(source);before=hashFile(source);
    assert(strcmp(before,manifest.models(k).sha256_source));
    item=struct('name',model,'release',evidence.release,'load','FAIL', ...
        'compile','NOT RUN','simulation','NOT RUN','dynamic_validation','NOT RUN', ...
        'error_identifier','','error','','sha256_before',before,'sha256_after','');
    try
        load_system(source);
        item.load='LOAD PASS';
        close_system(model,0);
    catch err
        item.error_identifier=err.identifier;
        item.error=getReport(err,'extended','hyperlinks','off');
        if ~isempty(which('bdIsLoaded')) && bdIsLoaded(model),close_system(model,0);end
    end
    item.sha256_after=hashFile(source);
    assert(strcmp(before,item.sha256_after));records{k}=item;
    fprintf('%s: %s; %s\n',model,item.load,item.error_identifier);
end
evidence.models=[records{:}];
f=fopen(fullfile(folder,['environment_' evidence.release '.json']),'w');
cleanup=onCleanup(@()fclose(f));
fprintf(f,'%s',jsonencode(evidence,PrettyPrint=true));
save(fullfile(folder,['environment_' evidence.release '.mat']),'evidence');
end
function hash=hashFile(file)
f=fopen(file,'rb');cleanup=onCleanup(@()fclose(f));bytes=fread(f,Inf,'*uint8');
digest=java.security.MessageDigest.getInstance('SHA-256');digest.update(bytes);
hash=lower(reshape(dec2hex(typecast(digest.digest(),'uint8'),2).',1,[]));
end
