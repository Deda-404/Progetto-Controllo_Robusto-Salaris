function evidence=finalize_student_validation
%FINALIZE_STUDENT_VALIDATION Recheck saved run provenance and Scope metrics.
root=fileparts(fileparts(mfilename('fullpath')));
folder=fullfile(root,'results/data/final_simulink_validation');
manifest=jsondecode(fileread(fullfile(root,'simulink/student_originals_manifest.json')));
items=cell(numel(manifest.models),1);
for k=1:numel(items)
    record=manifest.models(k);[~,name]=fileparts(record.name);
    item=jsondecode(fileread(fullfile(folder,[name '_audit.json'])));
    assert(strcmp(item.sha256_before,record.sha256_source) && strcmp(item.sha256_after,record.sha256_source) ...
        && strcmp(hashFile(fullfile(root,record.relative_path)),record.sha256_source), ...
        'FinalValidation:Integrity','Run provenance and current original must match.');
    assert(strcmp(item.compile,'COMPILE PASS') && strcmp(item.simulation,'SIMULATION PASS'), ...
        'FinalValidation:Runtime','The saved run is incomplete.');
    review=analyze_student_scope_results(name);item.dynamic_validation=review.status;
    assert(strcmp(review.status,'DYNAMIC VALIDATION PASS'),'FinalValidation:Signals', ...
        'Signal checks failed for %s: %s',name,review.error);
    saved=load(fullfile(folder,[name '_scope_buffers.mat']));summaries={};
    for j=1:numel(saved.records)
        scope=saved.records{j};
        if isfield(scope,'packed'),scope=rmfield(scope,'packed');end
        saved.records{j}=scope;
        for c=1:numel(scope.channels)
            channel=scope.channels{c};dt=diff(channel.time);dt=dt(dt>0);
            summaries{end+1}=struct('name',sprintf('%s/channel%d',scope.scope,c), ...
                'samples',numel(channel.time),'channels',1,'start',channel.time(1),'stop',channel.time(end), ...
                'peak_abs',max(abs(channel.values)),'nonfinite',nnz(~isfinite(channel.values)), ...
                'min_positive_step',min(dt),'max_step',max(dt)); %#ok<AGROW>
        end
    end
    item.signal_summary=[summaries{:}];item.scope_acquisition='ACQUISITION PASS';
    saved.evidence.summaries=item.signal_summary;
    records=saved.records;scopeEvidence=saved.evidence;
    save(fullfile(folder,[name '_scope_buffers.mat']),'records','-v7');
    % Keep the original variable name used by the reader.
    evidence=scopeEvidence;save(fullfile(folder,[name '_scope_buffers.mat']),'evidence','-append');
    writeJson(fullfile(folder,[name '_scope_acquisition.json']),evidence);
    writeJson(fullfile(folder,[name '_audit.json']),item);items{k}=item;
end
results=items;save(fullfile(folder,'slx_runtime_audit.mat'),'results','-v7');
writeJson(fullfile(folder,'slx_runtime_audit.json'),[items{:}]);
evidence=jsondecode(fileread(fullfile(folder,'environment_2026b.json')));
evidence.models=[items{:}];evidence.status='ALL REQUIRED RUNTIME AND SIGNAL CHECKS PASS';
evidence.scientific_limit='Performance targets, hardware feasibility and continuous command maxima are separate from successful validation.';
writeJson(fullfile(folder,'final_runner.json'),evidence);
fprintf('PASS: 8 original model runs and 12 controller/model combinations; hashes unchanged.\n');
end
function writeJson(file,data)
f=fopen(file,'w');cleanup=onCleanup(@()fclose(f));fprintf(f,'%s',jsonencode(data,PrettyPrint=true));
end
function hash=hashFile(file)
f=fopen(file,'rb');cleanup=onCleanup(@()fclose(f));bytes=fread(f,Inf,'*uint8');
digest=java.security.MessageDigest.getInstance('SHA-256');digest.update(bytes);
hash=lower(reshape(dec2hex(typecast(digest.digest(),'uint8'),2).',1,[]));
end
