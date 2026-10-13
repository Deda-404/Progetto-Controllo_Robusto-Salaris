function review=analyze_student_scope_results(model,outputFolder,workspaceData)
%ANALYZE_STUDENT_SCOPE_RESULTS Metrics and plots from authentic Scope buffers.
root=fileparts(fileparts(mfilename('fullpath')));
folder=fullfile(root,'results/data/final_simulink_validation');
if nargin>=2 && strlength(string(outputFolder))>0,folder=char(outputFolder);end
figures=fullfile(root,'report/figures/final_simulink');if ~isfolder(figures),mkdir(figures);end
if nargin>=2 && strlength(string(outputFolder))>0
    figures=fullfile(folder,'figures');if ~isfolder(figures),mkdir(figures);end
end
d=load(fullfile(folder,[model '_scope_buffers.mat']));records=d.records;
review=struct('model',model,'status','PARTIAL','protocol','saved SLX: reference, disturbance and process noise combined', ...
    'acquisition_api','R2026b visual Scope buffers, read only','branches',[],'sources',[],'error','');
try
    assert(strcmp(d.evidence.status,'ACQUISITION PASS'),'DynamicReview:Acquisition','Complete Scope buffers are required.');
    assert(all([d.evidence.summaries.nonfinite]==0),'DynamicReview:Finite','Nonfinite Scope samples.');
    sourceRecords=cellfun(@(v)struct('scope',v.scope,'sources',v.sources,'channels',numel(v.channels)),records);
    review.sources=sourceRecords;
    names=cellfun(@(v)string(v.scope),records);
    controls=find(contains(names,'Variabil') & contains(names,'controllo'));
    ideals=find(contains(names,'Uscita ideale'));
    assert(isscalar(controls) && ~isempty(ideals),'DynamicReview:Channels','Position and command Scope paths must be identified.');
    urecord=records{controls};[tu,U]=matrix(urecord);
    if startsWith(model,'Hinf')
        assert(max(abs(U(1,1:4)))<1e-9,'DynamicReview:InitialCommand', ...
            'The strictly proper H-infinity controllers must start at zero command.');
    end
    if startsWith(model,'Hinf'),labels=["1-DoF","2-DoF","PID"];else,labels="";end
    branches=cell(numel(labels),1);
    fig=figure('Visible','off','Color','w','Theme','light','Position',[100 100 1250 700]);
    cleanup=onCleanup(@()close(fig));layout=tiledlayout(2,2,'TileSpacing','compact','Padding','compact');
    ax1=nexttile;hold on;grid on;title('Posizione del primo giunto');ylabel('\Delta q_1 [deg]');
    ax2=nexttile;hold on;grid on;title('Posizione del secondo giunto');ylabel('\Delta q_2 [deg]');
    ax3=nexttile;hold on;grid on;title('Comando del primo attuatore');ylabel('u_1 [N m]');
    ax4=nexttile;hold on;grid on;title('Comando del secondo attuatore');ylabel('u_2 [N m]');
    for k=1:numel(labels)
        ix=ideals;
        if labels(k)~="",ix=ideals(contains(names(ideals),"("+labels(k)+")"));end
        assert(isscalar(ix),'DynamicReview:Branch','Ambiguous position Scope.');
        qrecord=records{ix};[t,Y]=matrix(qrecord);
        assert(size(Y,2)==6,'DynamicReview:Interface','Expected four positions and two reference channels.');
        q=Y(:,1:2);reference=Y(:,5:6);uk=U(:,2*k-1:2*k);
        assert(abs(reference(end,1)-5*pi/180)<1e-10 && abs(reference(end,2))<1e-10, ...
            'DynamicReview:Reference','Recorded reference differs from saved protocol.');
        onset=find(abs(reference(:,1))>1e-8,1);assert(~isempty(onset));start=t(onset);
        tail=t>=max(t(1),t(end)-1);err=q-reference;
        tailMean=trapz(t(tail),err(tail,:))/(t(end)-t(find(tail,1)))*180/pi;
        tailPeak=max(abs(err(tail,:)),[],1)*180/pi;
        overshoot=max(0,(max(q(onset:end,1))-reference(end,1))/reference(end,1))*100;
        settled=abs(err(:,1))<=0.02*abs(reference(end,1));lastBad=find(~settled & t>=start,1,'last');
        settling=NaN;if isempty(lastBad),settling=0;elseif lastBad<numel(t),settling=t(lastBad+1)-start;end
        measured=find(contains(names,'Uscita misurata'));
        if labels(k)~="",measured=measured(contains(names(measured),"("+labels(k)+")"));end
        noiseRms=NaN;noiseCorrelation=NaN;
        if isscalar(measured)
            [tm,Ym]=matrix(records{measured});
            assert(isequal(tm,t),'DynamicReview:NoiseGrid','Ideal and measured Scope grids differ.');
            noise=Ym(:,1:4)-Y(:,1:4);
            noiseRms=sqrt(trapz(t,noise.^2)/(t(end)-t(1)))*180/pi;
            noiseCorrelation=corrcoef(noise);
            if startsWith(model,'Hinf') && labels(k)=="PID"
                if nargin>=3,data=workspaceData;else,data=setup_student_originals('Hinf');end
                [~,~,~,Dpid]=ssdata(data.Kpid);
                expected=Dpid*[reference(1,:).';Ym(1,1:2).'];
                assert(norm(uk(1,:).'-expected)<1e-8*max(1,norm(expected)), ...
                    'DynamicReview:PIDInitial','Recorded PID feedthrough does not match the saved controller.');
            end
        end
        label=labels(k);if label=="",label=extractBefore(string(model),'_');end
        branches{k}=struct('controller',char(label),'position_scope',qrecord.scope,'command_scope',urecord.scope, ...
            'reference_start_s',start,'duration_s',t(end)-t(1),'samples_q',numel(t),'samples_u',numel(tu), ...
            'tail_mean_error_deg',tailMean,'tail_max_abs_error_deg',tailPeak, ...
            'observed_q1_overshoot_percent',overshoot,'observed_settling_2percent_s',settling, ...
            'peak_q2_deg',max(abs(q(onset:end,2)))*180/pi,'peak_u_Nm',max(abs(uk),[],1), ...
            'rms_u_Nm',sqrt(trapz(tu,uk.^2)/(tu(end)-tu(1))), ...
            'rms_encoder_noise_deg',noiseRms,'encoder_noise_correlation',noiseCorrelation, ...
            'max_command_sample_gap_s',max(diff(tu)), ...
            'peak_interpretation','maximum of Scope samples; continuous intersample maximum is not certified');
        plot(ax1,t,q(:,1)*180/pi,'DisplayName',char(label),'LineWidth',1);
        plot(ax2,t,q(:,2)*180/pi,'DisplayName',char(label),'LineWidth',1);
        plot(ax3,tu,uk(:,1),'DisplayName',char(label),'LineWidth',1);
        plot(ax4,tu,uk(:,2),'DisplayName',char(label),'LineWidth',1);
    end
    plot(ax1,t,reference(:,1)*180/pi,'k--','DisplayName','Riferimento','LineWidth',1.2);
    plot(ax2,t,reference(:,2)*180/pi,'k--','DisplayName','Riferimento','LineWidth',1.2);
    for ax=[ax1 ax2 ax3 ax4],xlabel(ax,'Tempo [s]');legend(ax,'Location','best');end
    title(layout,strrep(model,'_',' '),'Interpreter','none','Color','k');
    exportgraphics(fig,fullfile(figures,[model '.png']),'Resolution',180);
    if strcmp(model,'mu_linear_sim')
        oral=figure('Visible','off','Color','w','Theme','light','Position',[100 100 1100 400]);
        oralCleanup=onCleanup(@()close(oral));
        tiledlayout(1,2,'TileSpacing','compact','Padding','compact');
        nexttile;plot(t,q(:,1)*180/pi,'LineWidth',1.2);hold on;
        plot(t,reference(:,1)*180/pi,'k--','LineWidth',1.2);grid on;
        xlabel('Tempo [s]');ylabel('\Delta q_1 [deg]');title('Posizione articolare');
        legend('K_\mu','Riferimento','Location','southeast');set(gca,'FontSize',14);
        nexttile;plot(tu,uk(:,1),'LineWidth',.8);grid on;
        xlabel('Tempo [s]');ylabel('u_1 [N m]');title('Comando richiesto');set(gca,'FontSize',14);
        exportgraphics(oral,fullfile(figures,'slide_mu_linear_sim.png'),'Resolution',180);
    end
    review.branches=[branches{:}];review.status='DYNAMIC VALIDATION PASS';
catch err
    review.error=getReport(err,'extended','hyperlinks','off');
end
save(fullfile(folder,[model '_dynamic_review.mat']),'review','-v7');
f=fopen(fullfile(folder,[model '_dynamic_review.json']),'w');cleanup=onCleanup(@()fclose(f));
fprintf(f,'%s',jsonencode(review,PrettyPrint=true));
end
function [time,values]=matrix(record)
time=record.channels{1}.time;values=zeros(numel(time),numel(record.channels));
for j=1:numel(record.channels)
    assert(isequal(time,record.channels{j}.time),'DynamicReview:Grid','Scope channels use different grids.');
    values(:,j)=record.channels{j}.values;
end
end
