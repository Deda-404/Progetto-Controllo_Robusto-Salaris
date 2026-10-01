function cleanup = preserve_validation_outputs(root)
%PRESERVE_VALIDATION_OUTPUTS Conserva gli artifact riscritti da due test.
% Le suite del modello attuato e delle specifiche chiamano i rispettivi
% validatori. I risultati transitori restano disponibili nella cartella
% temporanea; i file consolidati sono ripristinati anche in caso di errore.
names=["results/data/m3_nominal_actuated_plant.mat", ...
    "results/data/m5_performance_specs.mat", ...
    "results/figures/m3_actuator_bode.png", ...
    "results/figures/m3_delay_pade_comparison.png", ...
    "results/figures/m3_full_plant_sigma.png", ...
    "results/figures/m5_spec_frequency_map.png", ...
    "results/figures/m5_weight_W1.png","results/figures/m5_weight_W2.png"];
folder=tempname;mkdir(folder);
for k=1:numel(names)
    assert(isfile(fullfile(root,names(k))),'Validation:MissingSource', ...
        'Manca un artifact consolidato: %s',names(k));
    copyfile(fullfile(root,names(k)),fullfile(folder,string(k)+".before"));
end
cleanup=onCleanup(@()restore(root,names,folder));
end

function restore(root,names,folder)
for j=1:numel(names)
    if isfile(fullfile(root,names(j)))
        copyfile(fullfile(root,names(j)),fullfile(folder,string(j)+".after"));
    end
    copyfile(fullfile(folder,string(j)+".before"),fullfile(root,names(j)));
end
end
