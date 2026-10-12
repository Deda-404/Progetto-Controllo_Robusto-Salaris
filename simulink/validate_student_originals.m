function results = validate_student_originals(runSimulation)
%VALIDATE_STUDENT_ORIGINALS Read-only loading, optional unchanged simulation.
arguments
    runSimulation (1,1) logical = false
end
root=fileparts(fileparts(mfilename('fullpath')));
manifest=jsondecode(fileread(fullfile(root,'simulink/student_originals_manifest.json')));
results=cell(8,1);
addpath(fullfile(root,'simulink/student_originals'),fullfile(root,'analysis'), ...
    fullfile(root,'File_di_Funzioni_Progetto-Accorpati'),'-begin');
for k=1:8
    record=manifest.models(k); [~,name]=fileparts(record.name);
    file=fullfile(root,record.relative_path); before=hashFile(file);
    assert(strcmp(before,record.sha256_source));
    item=struct('name',name,'release',version('-release'),'loaded',false, ...
        'simulation','NOT RUN','error','','sha256_before',before,'sha256_after','');
    cleanup=onCleanup(@()closeWithoutSave(name));
    try
        load_system(file); % read-only inspection, no update/set_param/save.
        item.loaded=true;
        if runSimulation
            kind=extractBefore(string(name),'_'); data=setup_student_originals(kind);
            in=Simulink.SimulationInput(name); fields=fieldnames(data);
            for j=1:numel(fields),in=in.setVariable(fields{j},data.(fields{j}));end
            out=sim(in); % original solver, sample times, switches and logging.
            save(fullfile(root,'results/data/final_closure',name+"_simulation.mat"),'out','-v7.3');
            item.simulation='EXECUTED; inspect logged signals before accrediting metrics';
        end
    catch err
        item.error=getReport(err,'extended','hyperlinks','off');
    end
    clear cleanup
    item.sha256_after=hashFile(file); assert(strcmp(before,item.sha256_after));
    results{k}=item;
end
folder=fullfile(root,'results/data/final_closure');
save(fullfile(folder,'slx_runtime_audit.mat'),'results','-v7');
f=fopen(fullfile(folder,'slx_runtime_audit.json'),'w'); cleanup=onCleanup(@()fclose(f));
fprintf(f,'%s',jsonencode([results{:}],PrettyPrint=true));
end
function closeWithoutSave(name)
if bdIsLoaded(name),close_system(name,0);end
end
function hash=hashFile(file)
f=fopen(file,'rb'); cleanup=onCleanup(@()fclose(f));
bytes=fread(f,Inf,'*uint8'); digest=java.security.MessageDigest.getInstance('SHA-256'); digest.update(bytes);
hash=lower(reshape(dec2hex(typecast(digest.digest(),'uint8'),2).',1,[]));
end
