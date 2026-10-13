function results = validate_student_originals(runSimulation,modelFilter)
%VALIDATE_STUDENT_ORIGINALS Read-only loading, optional unchanged simulation.
arguments
    runSimulation (1,1) logical = false
    modelFilter (1,1) string = ""
end
root=fileparts(fileparts(mfilename('fullpath')));
manifest=jsondecode(fileread(fullfile(root,'simulink/student_originals_manifest.json')));
folder=fullfile(root,'results/data/final_simulink_validation');
if ~isfolder(folder),mkdir(folder);end
if modelFilter~=""
    manifest.models=manifest.models(strcmp(string({manifest.models.name}),modelFilter+".slx"));
    assert(~isempty(manifest.models),'StudentValidation:Model','Unknown model.');
end
results=cell(numel(manifest.models),1);
addpath(fullfile(root,'simulink/student_originals'),fullfile(root,'analysis'), ...
    fullfile(root,'File_di_Funzioni_Progetto-Accorpati'),'-begin');
savedWorkspace=snapshotWorkspace;
workspaceCleanup=onCleanup(@()restoreWorkspace(savedWorkspace));
for k=1:numel(results)
    record=manifest.models(k); [~,name]=fileparts(record.name);
    file=fullfile(root,record.relative_path); before=hashFile(file);
    assert(strcmp(before,record.sha256_source));
    item=struct('name',name,'release',version('-release'),'loaded',false, ...
        'load','FAIL','compile','NOT RUN','simulation','NOT RUN', ...
        'dynamic_validation','NOT RUN','error','','error_identifier','', ...
        'error_phase','','warning','','warning_identifier','', ...
        'solver','','stop_time','','simulated_duration',NaN, ...
        'outputs',{{}},'signal_summary',[],'switches',[],'scope_logging',[], ...
        'compiled_ports',[],'scope_acquisition','NOT RUN','solver_configuration',[], ...
        'sha256_before',before,'sha256_after','');
    cleanup=onCleanup(@()closeWithoutSave(name));
    phase='load';lastwarn('');
    try
        load_system(file); % read-only inspection, no update/set_param/save.
        item.loaded=true;item.load='LOAD PASS';
        assert(strcmp(before,hashFile(file)));
        item.solver=get_param(name,'Solver');item.stop_time=get_param(name,'StopTime');
        item.solver_configuration=struct('relative_tolerance',get_param(name,'RelTol'), ...
            'absolute_tolerance',get_param(name,'AbsTol'),'max_step',get_param(name,'MaxStep'));
        blocks=find_system(name,'LookUnderMasks','all','FollowLinks','off','BlockType','ManualSwitch');
        item.switches=cellfun(@switchRecord,blocks);
        blocks=find_system(name,'LookUnderMasks','all','FollowLinks','off','BlockType','Scope');
        scopes=cell(numel(blocks),1);
        for j=1:numel(blocks)
            config=get_param(blocks{j},'ScopeConfiguration');
            scopes{j}=struct('path',blocks{j},'enabled',config.DataLogging, ...
                'variable',config.DataLoggingVariableName, ...
                'limit_points',config.DataLoggingLimitDataPoints,'max_points',config.DataLoggingMaxPoints, ...
                'decimate',config.DataLoggingDecimateData,'decimation',config.DataLoggingDecimation);
        end
        item.scope_logging=[scopes{:}];
        if runSimulation
            phase='workspace';
            kind=extractBefore(string(name),'_'); data=setup_student_originals(kind);
            in=Simulink.SimulationInput(name); fields=fieldnames(data);
            for j=1:numel(fields)
                in=in.setVariable(fields{j},data.(fields{j}));
                assignin('base',fields{j},data.(fields{j}));
            end
            phase='compile';item.compile='FAIL';
            feval(name,[],[],[],'compile');
            compilationCleanup=onCleanup(@()feval(name,[],[],[],'term'));
            allBlocks=find_system(name,'LookUnderMasks','all','FollowLinks','off','Type','Block');
            ports=cell(numel(allBlocks),1);
            for j=1:numel(allBlocks)
                ports{j}=struct('path',allBlocks{j},'type',get_param(allBlocks{j},'BlockType'), ...
                    'widths',get_param(allBlocks{j},'CompiledPortWidths'), ...
                    'active',get_param(allBlocks{j},'CompiledIsActive'));
            end
            item.compiled_ports=[ports{:}];
            item.compile='COMPILE PASS';
            clear compilationCleanup
            assert(strcmp(before,hashFile(file)));
            phase='simulation';item.simulation='FAIL';
            out=sim(in); % original solver, sample times, switches and logging.
            save(fullfile(folder,name+"_simulation.mat"),'out','-v7.3');
            scopeEvidence=acquire_student_scope_buffers(name,folder,out.get('tout'));
            item.scope_acquisition=scopeEvidence.status;
            phase='outputs';item.outputs=who(out);
            summaries=cell(numel(item.outputs),1);
            for j=1:numel(item.outputs)
                summaries{j}=summarizeSignal(out.get(item.outputs{j}),item.outputs{j});
            end
            item.signal_summary=vertcat(summaries{:});
            if ismember('tout',item.outputs)
                time=out.get('tout');
                if ~isempty(time),item.simulated_duration=double(time(end)-time(1));end
            end
            expected=evalin('base',item.stop_time);
            if isfinite(item.simulated_duration) && abs(item.simulated_duration-expected)<=1e-8*max(1,abs(expected))
                item.simulation='SIMULATION PASS';
            else
                item.simulation='PARTIAL: stop horizon not verified from saved time';
            end
            item.dynamic_validation='PARTIAL: inspect positions, references and commands';
            if strcmp(scopeEvidence.status,'ACQUISITION PASS')
                item.signal_summary=scopeEvidence.summaries;
                review=analyze_student_scope_results(name);
                item.dynamic_validation=review.status;
            end
            if ~isempty(item.signal_summary) && any([item.signal_summary.nonfinite]>0)
                item.dynamic_validation='FAIL: nonfinite logged signals';
            end
        end
    catch err
        item.error=getReport(err,'extended','hyperlinks','off');
        item.error_identifier=err.identifier;item.error_phase=phase;
    end
    [item.warning,item.warning_identifier]=lastwarn;
    clear cleanup
    item.sha256_after=hashFile(file); assert(strcmp(before,item.sha256_after));
    results{k}=item;
    writeJson(fullfile(folder,[name '_audit.json']),item);
    fprintf('%s: %s / %s / %s / %s\n',name,item.load,item.compile,item.simulation,item.dynamic_validation);
end
if modelFilter==""
    save(fullfile(folder,'slx_runtime_audit.mat'),'results','-v7');
    writeJson(fullfile(folder,'slx_runtime_audit.json'),[results{:}]);
end
end
function item=switchRecord(block)
sw=get_param(block,'sw');port=2-str2double(sw);
handles=get_param(block,'PortHandles');line=get_param(handles.Inport(port),'Line');
source=get_param(line,'SrcBlockHandle');
item=struct('path',block,'sw',sw,'selected_port',port,'selected_source',getfullname(source));
end
function closeWithoutSave(name)
if ~isempty(which('bdIsLoaded')) && bdIsLoaded(name),close_system(name,0);end
end
function writeJson(file,data)
f=fopen(file,'w');cleanup=onCleanup(@()fclose(f));fprintf(f,'%s',jsonencode(data,PrettyPrint=true));
end
function saved=snapshotWorkspace
names=evalin('base','who');saved=struct;
for k=1:numel(names),saved.(names{k})=evalin('base',names{k});end
end
function restoreWorkspace(saved)
names=evalin('base','who');original=fieldnames(saved);
for k=1:numel(names)
    if ~ismember(names{k},original),evalin('base',['clear ' names{k}]);end
end
for k=1:numel(original),assignin('base',original{k},saved.(original{k}));end
end
function items=summarizeSignal(value,label)
items=struct('name',{},'samples',{},'channels',{},'start',{},'stop',{},'peak_abs',{},'nonfinite',{});
if isa(value,'timeseries')
    items=numericSummary(value.Time,value.Data,label);
elseif isa(value,'Simulink.SimulationData.Signal')
    items=summarizeSignal(value.Values,label);
elseif isa(value,'Simulink.SimulationData.Dataset')
    for k=1:value.numElements
        items=[items;summarizeSignal(value.getElement(k),[label '/' num2str(k)])]; %#ok<AGROW>
    end
elseif isstruct(value) && isfield(value,'time') && isfield(value,'signals')
    for k=1:numel(value.signals)
        items=[items;numericSummary(value.time,value.signals(k).values,[label '/' num2str(k)])]; %#ok<AGROW>
    end
end
end
function item=numericSummary(time,values,label)
if isempty(time) || isempty(values),item=struct([]);return;end
item=struct('name',label,'samples',numel(time),'channels',numel(values)/numel(time), ...
    'start',double(time(1)),'stop',double(time(end)), ...
    'peak_abs',max(abs(double(values)),[],'all'),'nonfinite',nnz(~isfinite(values)));
end
function hash=hashFile(file)
f=fopen(file,'rb'); cleanup=onCleanup(@()fclose(f));
bytes=fread(f,Inf,'*uint8'); digest=java.security.MessageDigest.getInstance('SHA-256'); digest.update(bytes);
hash=lower(reshape(dec2hex(typecast(digest.digest(),'uint8'),2).',1,[]));
end
