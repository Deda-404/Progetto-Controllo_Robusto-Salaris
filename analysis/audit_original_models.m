function results = audit_original_models
%AUDIT_ORIGINAL_MODELS Prova di caricamento/compilazione senza salvare gli SLX.
% Un caricamento riuscito non certifica i collegamenti fisici. La simulazione
% non viene avviata su diagrammi con incongruenze gia accertate.
root=fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root,'simulink'));
names=["Progetto_LQR_simulink","Progetto_LQRI_simulink","Progetto_Hinf_simulink", ...
    "LQR_linear_sim","LQRI_linear_sim","Hinf_linear_sim"];
kinds=["LQG","LQGI","Hinf","LQG","LQGI","Hinf"];
out=fullfile(root,'results/data/coherent_review');
if ~isfolder(out),mkdir(out);end
results=repmat(struct('model','','loaded',false,'compiled',false, ...
    'simulation','NOT RUN','identifier','','diagnostic',''),1,numel(names));
for k=1:numel(names)
    model=char(names(k));
    item=struct('model',model,'loaded',false,'compiled',false, ...
        'simulation','NOT RUN','identifier','','diagnostic','');
    cleanup=onCleanup(@()localClose(model));
    try
        load_system(fullfile(root,'simulink/originals',model+".slx"));
        item.loaded=true;
        data=setup_original_models(kinds(k));
        workspace=get_param(model,'ModelWorkspace');
        fields=fieldnames(data);
        for j=1:numel(fields),assignin(workspace,fields{j},data.(fields{j}));end
        set_param(model,'SimulationCommand','update');
        item.compiled=true;
        item.diagnostic='Compilazione riuscita; incongruenze fisiche da risolvere manualmente.';
    catch err
        item.identifier=err.identifier;
        item.diagnostic=getReport(err,'extended','hyperlinks','off');
    end
    results(k)=item;
    clear cleanup
end
save(fullfile(out,'original_models_audit.mat'),'results');
f=fopen(fullfile(out,'original_models_audit.json'),'w');
cleanup=onCleanup(@()fclose(f));fprintf(f,'%s',jsonencode(results,PrettyPrint=true));
disp(struct2table(results));
end
function localClose(model)
if bdIsLoaded(model),close_system(model,0);end
end
