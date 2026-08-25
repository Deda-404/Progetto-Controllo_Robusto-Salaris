function campaign = run_m11_hinfstruct_campaign( ...
    P, G, Gd, W1, W2, gammaFull, config)
%RUN_M11_HINFSTRUCT_CAMPAIGN Execute the frozen A0-A5 multistart campaign.

arguments
    P {mustBeA(P, {'ss', 'tf', 'zpk'})}
    G {mustBeA(G, {'ss', 'tf', 'zpk'})}
    Gd {mustBeA(Gd, {'ss', 'tf', 'zpk'})}
    W1 {mustBeA(W1, {'ss', 'tf', 'zpk'})}
    W2 {mustBeA(W2, {'ss', 'tf', 'zpk'})}
    gammaFull (1, 1) double {mustBePositive}
    config (1, 1) struct = hinfstruct_specs_m11
end

numberArchitectures = height(config.architectures);
architectureResults = repmat(struct, numberArchitectures, 1);
variabilityRows = zeros(numberArchitectures, 11);
familyStatus = strings(numberArchitectures, 1);

for architectureIndex = 1:numberArchitectures
    architectureID = config.architectures.ID(architectureIndex);
    structure = build_m11_structured_controller(architectureID, config);
    tunable = build_m11_tunable_closed_loop(P, structure, config);
    architectureSeed = config.architectureSeeds(architectureIndex);
    rng(architectureSeed, 'twister');
    options = hinfstructOptions( ...
        'Display', config.hinfstructDisplay, ...
        'MaxIter', config.hinfstructMaxIter, ...
        'RandomStart', config.randomStartsPerArchitecture, ...
        'UseParallel', config.useParallel, ...
        'TargetGain', config.hinfstructTargetGain, ...
        'TolGain', config.hinfstructTolGain);

    lastwarn('');
    callError = "";
    try
        [tunedClosedLoop, bestGammaOutput, info] = hinfstruct( ...
            tunable.tunableClosedLoop, options);
    catch exception
        tunedClosedLoop = [];
        bestGammaOutput = inf;
        info = struct([]);
        callError = string(getReport(exception, 'basic', ...
            'hyperlinks', 'off'));
    end
    [warningMessage, warningIdentifier] = lastwarn;

    runs = repmat(localRunTemplate, ...
        config.totalStartsPerArchitecture, 1);
    returnedStarts = min(numel(info), ...
        config.totalStartsPerArchitecture);
    for startIndex = 1:config.totalStartsPerArchitecture
        run = localRunTemplate;
        run.architectureID = architectureID;
        run.architectureType = structure.definition.Type;
        run.startIndex = startIndex;
        run.startType = localStartType(startIndex);
        run.seed = architectureSeed;
        run.warningMessage = string(warningMessage);
        run.warningIdentifier = string(warningIdentifier);
        if startIndex <= returnedStarts
            run.infoReturned = true;
            run.solverObjective = info(startIndex).Objective;
            run.iterations = info(startIndex).Iterations;
            run.rawInfo = info(startIndex);
            try
                extracted = extract_m11_tuned_controller( ...
                    info(startIndex).TunedBlocks, structure);
                run.controllerExtracted = true;
                run.controller = extracted.controller;
                run.numericBlockValues = extracted.blockValues;
                run.coefficients = extracted.coefficients;
                run.controllerOrder = extracted.order;
                run.audit = evaluate_m11_candidate( ...
                    extracted.controller, run.solverObjective, P, G, ...
                    Gd, W1, W2, gammaFull, config);
                run.internalStable = ...
                    run.audit.metrics.internallyStable;
                run.classification = run.audit.classification;
                if isfinite(run.solverObjective)
                    run.exitStatus = "OBJECTIVE_FINITE";
                else
                    run.exitStatus = "OBJECTIVE_INFINITE";
                end
            catch exception
                run.extractionError = string(getReport(exception, ...
                    'basic', 'hyperlinks', 'off'));
                run.exitStatus = "EXTRACTION_OR_AUDIT_FAILED";
                run.classification = "SOLVER_FAILED";
            end
        else
            run.exitStatus = "NO_INFO_RETURNED";
            run.classification = "SOLVER_FAILED";
            run.extractionError = callError;
        end
        runs(startIndex) = run;
    end

    validMask = [runs.classification].' == "VALID_STABLE";
    representativeStart = NaN;
    representative = struct([]);
    if any(validMask)
        validIndices = find(validMask);
        objectives = [runs(validIndices).solverObjective].';
        ordering = sortrows([objectives, validIndices], [1, 2]);
        representativeStart = ordering(1, 2);
        representative = runs(representativeStart);
    end

    finiteMask = isfinite([runs.solverObjective].');
    finiteObjectives = [runs(finiteMask).solverObjective].';
    successfulStarts = sum(finiteMask & [runs.controllerExtracted].');
    stableStarts = sum([runs.internalStable]);
    if isempty(finiteObjectives)
        bestGamma = NaN;
        medianGamma = NaN;
        worstGamma = NaN;
        standardDeviation = NaN;
        minimumGamma = NaN;
        maximumGamma = NaN;
        bestFiniteStart = NaN;
    else
        bestGamma = min(finiteObjectives);
        medianGamma = median(finiteObjectives);
        worstGamma = max(finiteObjectives);
        standardDeviation = std(finiteObjectives);
        minimumGamma = min(finiteObjectives);
        maximumGamma = max(finiteObjectives);
        finiteIndices = find(finiteMask);
        bestFiniteCandidates = finiteIndices( ...
            abs([runs(finiteIndices).solverObjective].' - bestGamma) <= ...
            config.paretoTolerance * max(1, abs(bestGamma)));
        bestFiniteStart = min(bestFiniteCandidates);
    end

    if all(validMask)
        familyStatus(architectureIndex) = "ALL_VALID_STABLE";
    elseif any(validMask)
        familyStatus(architectureIndex) = "PARTIAL_VALID_STABLE";
    elseif stableStarts > 0
        familyStatus(architectureIndex) = "STABLE_BUT_SUSPECT";
    else
        familyStatus(architectureIndex) = "NO_VALID_STABLE";
    end

    variabilityRows(architectureIndex, :) = [ ...
        config.totalStartsPerArchitecture, returnedStarts, ...
        successfulStarts, stableStarts, bestGamma, medianGamma, ...
        worstGamma, standardDeviation, minimumGamma, maximumGamma, ...
        bestFiniteStart];
    architectureResults(architectureIndex).id = architectureID;
    architectureResults(architectureIndex).definition = ...
        structure.definition;
    architectureResults(architectureIndex).structureMetadata = rmfield( ...
        structure, 'controller');
    architectureResults(architectureIndex).tunableMetadata = rmfield( ...
        tunable, 'tunableClosedLoop');
    architectureResults(architectureIndex).architectureSeed = ...
        architectureSeed;
    architectureResults(architectureIndex).options = options;
    architectureResults(architectureIndex).returnedStartCount = ...
        returnedStarts;
    architectureResults(architectureIndex).bestGammaOutput = ...
        bestGammaOutput;
    architectureResults(architectureIndex).tunedClosedLoopBest = ...
        tunedClosedLoop;
    architectureResults(architectureIndex).info = info;
    architectureResults(architectureIndex).runs = runs;
    architectureResults(architectureIndex).representativeStartIndex = ...
        representativeStart;
    architectureResults(architectureIndex).representative = representative;
    architectureResults(architectureIndex).warningMessage = ...
        string(warningMessage);
    architectureResults(architectureIndex).warningIdentifier = ...
        string(warningIdentifier);
    architectureResults(architectureIndex).callError = callError;
    architectureResults(architectureIndex).familyStatus = ...
        familyStatus(architectureIndex);
end

variabilityTable = array2table(variabilityRows, 'VariableNames', ...
    {'TotalStarts', 'ReturnedStarts', 'SuccessfulStarts', ...
    'StableStarts', 'BestGamma', 'MedianGamma', 'WorstFiniteGamma', ...
    'StdGamma', 'MinGamma', 'MaxGamma', 'BestFiniteStart'});
variabilityTable = addvars(variabilityTable, ...
    config.architectures.ID, config.architectures.Type, familyStatus, ...
    'Before', 1, 'NewVariableNames', ...
    {'ArchitectureID', 'ArchitectureType', 'FamilyStatus'});

allRuns = vertcat(architectureResults.runs);
finiteStableMask = [allRuns.internalStable].' & ...
    isfinite([allRuns.solverObjective].');
lowerBoundViolations = false(numel(allRuns), 1);
for index = find(finiteStableMask).'
    if ~isempty(allRuns(index).audit)
        lowerBoundViolations(index) = ...
            ~allRuns(index).audit.metrics.lowerBoundPassed;
    end
end

campaign.architectureResults = architectureResults;
campaign.variabilityTable = variabilityTable;
campaign.totalRequestedStarts = numberArchitectures * ...
    config.totalStartsPerArchitecture;
campaign.totalReturnedStarts = sum(variabilityTable.ReturnedStarts);
campaign.totalSuccessfulStarts = sum(variabilityTable.SuccessfulStarts);
campaign.totalStableStarts = sum(variabilityTable.StableStarts);
campaign.multistartSemantics = ...
    "one nominal start plus four internal randomized starts";
campaign.infoExitStatusAvailable = false;
campaign.exitStatusInterpretation = ...
    "derived from info objective, extraction and independent audit";
campaign.lowerBoundViolationCount = sum(lowerBoundViolations);
campaign.correctlyExecuted = campaign.totalReturnedStarts == ...
    campaign.totalRequestedStarts;

assert(campaign.lowerBoundViolationCount == 0, ...
    'M11Campaign:FullOrderLowerBoundViolation', ...
    ['A stable structured solution appears to beat the M10 full-order ' ...
    'lower bound beyond tolerance. Stop for methodological review.']);
end

function run = localRunTemplate
run = struct( ...
    'architectureID', "", ...
    'architectureType', "", ...
    'startIndex', NaN, ...
    'startType', "", ...
    'seed', NaN, ...
    'infoReturned', false, ...
    'solverObjective', inf, ...
    'iterations', NaN, ...
    'exitStatus', "", ...
    'warningMessage', "", ...
    'warningIdentifier', "", ...
    'controllerExtracted', false, ...
    'controller', [], ...
    'numericBlockValues', struct, ...
    'coefficients', struct, ...
    'controllerOrder', NaN, ...
    'internalStable', false, ...
    'classification', "SOLVER_FAILED", ...
    'audit', struct, ...
    'rawInfo', struct, ...
    'extractionError', "");
end

function type = localStartType(index)
if index == 1
    type = "NOMINAL";
else
    type = "RANDOMIZED";
end
end
