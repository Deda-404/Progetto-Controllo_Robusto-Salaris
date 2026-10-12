function export_student_schemes
%EXPORT_STUDENT_SCHEMES Authentic print export without editing/saving an SLX.
root=fileparts(fileparts(mfilename('fullpath')));
assert(~verLessThan('simulink','26.1'),'StudentSchemes:Release','Use R2026a or newer; do not convert originals.');
manifest=jsondecode(fileread(fullfile(root,'simulink/student_originals_manifest.json')));
folder=fullfile(root,'report/figures/student_exports');if ~isfolder(folder),mkdir(folder);end
for k=1:numel(manifest.models)
    source=fullfile(root,manifest.models(k).relative_path);
    [~,model]=fileparts(source); before=hashFile(source);
    cleanup=onCleanup(@()closeWithoutSave(model));
    load_system(source);
    print(['-s',model],'-dpng','-r200',fullfile(folder,[model,'.png']));
    clear cleanup
    assert(strcmp(before,hashFile(source)) && strcmp(before,manifest.models(k).sha256_source));
end
end
function closeWithoutSave(name)
if bdIsLoaded(name),close_system(name,0);end
end
function hash=hashFile(file)
f=fopen(file,'rb');cleanup=onCleanup(@()fclose(f));
bytes=fread(f,Inf,'*uint8');digest=java.security.MessageDigest.getInstance('SHA-256');digest.update(bytes);
hash=lower(reshape(dec2hex(typecast(digest.digest(),'uint8'),2).',1,[]));
end
