function representativeResults = evaluate_m11_representatives( ...
    campaign, m5, m6, config)
%EVALUATE_M11_REPRESENTATIVES Run frozen scenarios for each family best.

arguments
    campaign (1, 1) struct
    m5 (1, 1) struct
    m6 (1, 1) struct
    config (1, 1) struct = hinfstruct_specs_m11
end

architectures = campaign.architectureResults;
representativeResults = repmat(struct, numel(architectures), 1);
for index = 1:numel(architectures)
    result = architectures(index);
    representativeResults(index).architectureID = result.id;
    representativeResults(index).available = ...
        ~isempty(result.representative);
    representativeResults(index).familyStatus = result.familyStatus;
    if isempty(result.representative)
        representativeResults(index).controller = [];
        representativeResults(index).reconstruction = struct;
        representativeResults(index).evaluation = struct;
        representativeResults(index).coefficients = struct;
        continue;
    end
    run = result.representative;
    reconstruction = run.audit;
    synthesisAlias.controllerOrder = run.controllerOrder;
    evaluation = evaluate_m9_closed_loop( ...
        reconstruction, m5, m6, synthesisAlias, config);
    representativeResults(index).controller = run.controller;
    representativeResults(index).reconstruction = reconstruction;
    representativeResults(index).evaluation = evaluation;
    representativeResults(index).coefficients = run.coefficients;
    representativeResults(index).startIndex = run.startIndex;
    representativeResults(index).objective = run.solverObjective;
end
end
