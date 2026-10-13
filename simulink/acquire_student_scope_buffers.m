function evidence=acquire_student_scope_buffers(model,folder,simulationTime)
%ACQUIRE_STUDENT_SCOPE_BUFFERS Read existing Scope visual buffers in R2026b.
% This release-specific reader never enables logging or changes a model.
evidence=struct('status','PARTIAL: visual buffers unavailable','summaries',[],'error','');
records={};summaries={};
try
    instances=Simulink.scopes.WebScope.getAllInstances;
    for k=1:numel(instances)
        obj=instances{k};
        if ~startsWith(string(obj.FullPath),string(model)+"/"),continue;end
        if endsWith(string(obj.FullPath),'/Confronto uscite'),continue;end
        [packed,counts]=obj.getDataFromBuffer;
        channels={};channelIndex=0;
        ports=get_param(obj.FullPath,'PortHandles');
        sources=cell(numel(ports.Inport),1);
        for j=1:numel(ports.Inport)
            line=get_param(ports.Inport(j),'Line');
            sources{j}=struct('block',getfullname(get_param(line,'SrcBlockHandle')), ...
                'port',get_param(get_param(line,'SrcPortHandle'),'PortNumber'),'label',get_param(line,'Name'));
        end
        for j=1:numel(packed)
            n=double(counts(j));a=double(packed{j}(:));
            width=numel(a)/n-1;
            assert(width>=1 && width==floor(width),'ScopeBuffer:Format', ...
                'Unexpected buffer format: %s channel %d, %d values, count %d.',obj.FullPath,j,numel(a),n);
            % Time is a contiguous prefix; vector values are sample-interleaved.
            time=a(1:n);values=reshape(a(n+1:end),width,n).';
            assert(all(diff(time)>=0) && all(isfinite(time)),'ScopeBuffer:Time','Invalid Scope time vector.');
            assert(abs(time(1)-simulationTime(1))<1e-8 && abs(time(end)-simulationTime(end))<1e-8, ...
                'ScopeBuffer:Horizon','Scope buffer does not cover the complete simulation.');
            intervals=diff(time);positive=intervals(intervals>0);
            for c=1:width
            channelIndex=channelIndex+1;
            channels{channelIndex}=struct('time',time,'values',values(:,c)); %#ok<AGROW>
            summaries{end+1}=struct('name',char(string(obj.FullPath)+"/channel"+channelIndex), ...
                'samples',n,'channels',1,'start',time(1),'stop',time(end), ...
                'peak_abs',max(abs(values(:,c))),'nonfinite',nnz(~isfinite(values(:,c))), ...
                'min_positive_step',min(positive),'max_step',max(positive)); %#ok<AGROW>
            end
        end
        records{end+1}=struct('scope',obj.FullPath,'sources',[sources{:}], ...
            'counts',counts,'channels',{channels}); %#ok<AGROW>
    end
    assert(~isempty(records),'ScopeBuffer:Empty','No existing visual buffers found.');
    evidence.status='ACQUISITION PASS';evidence.summaries=[summaries{:}];
catch err
    evidence.error=getReport(err,'extended','hyperlinks','off');
end
save(fullfile(folder,[model '_scope_buffers.mat']),'records','evidence','-v7');
f=fopen(fullfile(folder,[model '_scope_acquisition.json']),'w');cleanup=onCleanup(@()fclose(f));
fprintf(f,'%s',jsonencode(evidence,PrettyPrint=true));
end
