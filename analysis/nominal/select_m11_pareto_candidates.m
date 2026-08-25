function selection = select_m11_pareto_candidates(campaign, config)
%SELECT_M11_PARETO_CANDIDATES Rank valid representatives by order/gamma.

arguments
    campaign (1, 1) struct
    config (1, 1) struct = hinfstruct_specs_m11
end

architectures = campaign.architectureResults;
numberArchitectures = numel(architectures);
architectureID = strings(numberArchitectures, 1);
architectureType = strings(numberArchitectures, 1);
orderValue = nan(numberArchitectures, 1);
parameterCount = nan(numberArchitectures, 1);
objective = nan(numberArchitectures, 1);
weightedNorm = nan(numberArchitectures, 1);
stable = false(numberArchitectures, 1);
valid = false(numberArchitectures, 1);
bestStart = nan(numberArchitectures, 1);
familyStatus = strings(numberArchitectures, 1);

for index = 1:numberArchitectures
    result = architectures(index);
    architectureID(index) = result.id;
    architectureType(index) = result.definition.Type;
    parameterCount(index) = result.definition.ParameterCount;
    familyStatus(index) = result.familyStatus;
    if ~isempty(result.representative)
        representative = result.representative;
        orderValue(index) = representative.controllerOrder;
        objective(index) = representative.solverObjective;
        weightedNorm(index) = ...
            representative.audit.metrics.weightedNorm;
        stable(index) = representative.internalStable;
        valid(index) = representative.classification == "VALID_STABLE";
        bestStart(index) = representative.startIndex;
    end
end

pareto = false(numberArchitectures, 1);
dominatedBy = strings(numberArchitectures, 1);
for firstIndex = 1:numberArchitectures
    if ~valid(firstIndex)
        continue;
    end
    dominators = strings(0, 1);
    for secondIndex = 1:numberArchitectures
        if firstIndex == secondIndex || ~valid(secondIndex)
            continue;
        end
        noWorseOrder = orderValue(secondIndex) <= orderValue(firstIndex);
        noWorseGamma = weightedNorm(secondIndex) <= ...
            weightedNorm(firstIndex) + config.paretoTolerance * ...
                max(1, abs(weightedNorm(firstIndex)));
        strictlyBetter = orderValue(secondIndex) < orderValue(firstIndex) || ...
            weightedNorm(secondIndex) < weightedNorm(firstIndex) - ...
                config.paretoTolerance * ...
                max(1, abs(weightedNorm(firstIndex)));
        if noWorseOrder && noWorseGamma && strictlyBetter
            dominators(end + 1, 1) = architectureID(secondIndex); %#ok<AGROW>
        end
    end
    pareto(firstIndex) = isempty(dominators);
    dominatedBy(firstIndex) = strjoin(dominators, ",");
end

representativeTable = table(architectureID, architectureType, orderValue, ...
    parameterCount, objective, weightedNorm, stable, valid, bestStart, ...
    familyStatus, pareto, dominatedBy, 'VariableNames', ...
    {'ArchitectureID', 'ArchitectureType', 'Order', 'ParameterCount', ...
    'Objective', 'WeightedNorm', 'Stable', 'Valid', 'BestStart', ...
    'FamilyStatus', 'Pareto', 'DominatedBy'});
paretoIDs = architectureID(pareto);
if isempty(paretoIDs)
    recommendation = "NO_STRUCTURED_CONTROLLER_PREFERABLE";
elseif isscalar(paretoIDs)
    recommendation = "SINGLE_M11_CANDIDATE";
elseif numel(paretoIDs) <= 3
    recommendation = "PARETO_CANDIDATES_FOR_REVIEW";
else
    recommendation = "PARETO_FRONT_FOR_GROUP_REVIEW";
end

selection.representativeTable = representativeTable;
selection.paretoArchitectureIDs = paretoIDs;
selection.recommendation = recommendation;
selection.selectionUsesTracking = false;
selection.rule = ...
    "stable finite minimum objective per family; Pareto on order/gamma";
end
