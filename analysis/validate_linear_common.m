function summary=validate_linear_common
%VALIDATE_LINEAR_COMMON Compare both Simulink implementations and MATLAB LTI.
root=fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root,'simulink'));
folder=fullfile(root,'results/data/simulink_completion');
if ~isfolder(folder), mkdir(folder); end
summary=struct('matlab',version,'checks',struct([]),'controllers',struct([]));
for kind=["LQG","LQRI","Hinf","Kmu"]
    fprintf('LINEAR COMMON %s\n',kind);
    c=setup_simulink_integration(kind);
    G=simulink_integration_linear_map(c);
    runs=cell(3,1); errors=zeros(3,2);
    for j=1:3
        ref=zeros(2,1); disturbance=false;
        if j<3, ref(j)=deg2rad(5); else, disturbance=true; end
        runs{j}=simulate_linear_common(kind,struct('reference',ref,'horizon',3, ...
            'enableLinkDisturbance',disturbance,'disturbanceTime',0,'disturbance',[.01;-.007]));
        r=runs{j}; expected=lsim(G,[r.r r.d_ext],r.time);
        errors(j,:)=[max(abs(r.dq-expected(:,1:2)),[],'all'), ...
            max(abs(r.u-expected(:,3:4)),[],'all')];
        check(kind+" LTI q scenario "+j,errors(j,1),2e-7);
        check(kind+" LTI u scenario "+j,errors(j,2),2e-4);
    end
    % Reuse the existing executed nonlinear trace; do not rerun old campaigns.
    old=load(fullfile(root,'results/data/simulink_integration',kind+"_runs.mat"),'small');
    small=simulate_linear_common(kind,struct('reference',old.small.config.reference, ...
        'horizon',old.small.config.horizon));
    assert(isequal(small.time,old.small.time),'LinearCommon:Time','Sampling mismatch');
    nonlinearError=[max(abs(small.dq-old.small.dq),[],'all'), ...
        max(abs(small.u-old.small.u),[],'all')];
    check(kind+" nonlinear small q",nonlinearError(1),2e-7);
    check(kind+" nonlinear small u",nonlinearError(2),2e-4);
    item=struct('kind',kind,'linearErrorsQU',errors,'nonlinearErrorsQU',nonlinearError);
    if isempty(summary.controllers), summary.controllers=item;
    else, summary.controllers(end+1)=item; end
    save(fullfile(folder,kind+"_linear.mat"),'runs','small','errors','nonlinearError');
end
summary.passed=all([summary.checks.pass]);
save(fullfile(folder,'linear_validation.mat'),'summary');
f=fopen(fullfile(folder,'linear_summary.json'),'w');
fprintf(f,'%s',jsonencode(summary,PrettyPrint=true)); fclose(f);
disp(struct2table(summary.checks));
    function check(name,value,tolerance)
        item=struct('name',name,'value',value,'tolerance',tolerance,'pass',value<tolerance);
        if isempty(summary.checks), summary.checks=item;
        else, summary.checks(end+1)=item; end
    end
end
