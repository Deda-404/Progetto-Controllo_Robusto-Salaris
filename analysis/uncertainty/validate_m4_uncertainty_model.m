function metrics = validate_m4_uncertainty_model
%VALIDATE_M4_UNCERTAINTY_MODEL Build and validate the complete M4 model.

projectRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
dataDirectory = fullfile(projectRoot, 'results', 'data');
figureDirectory = fullfile(projectRoot, 'results', 'figures');
if ~exist(dataDirectory, 'dir')
    mkdir(dataDirectory);
end
if ~exist(figureDirectory, 'dir')
    mkdir(figureDirectory);
end

m2 = load(fullfile(dataDirectory, 'm2_linearization_nominal.mat'));
m3 = load(fullfile(dataDirectory, 'm3_nominal_actuated_plant.mat'));

screening = screen_parameter_sensitivity;
parameterSensitivityTable = screening.parameterSensitivityTable;
selectedMechanicalParameters = screening.selectedMechanicalParameters;
uncertainty = uncertainty_params_m4(selectedMechanicalParameters);
uncertaintyScenarios = uncertainty.mechanicalScenarios;
selectedMechanicalRanges = uncertainty.selectedMechanicalRanges;
actuatorUncertaintyScenarios = uncertainty.actuatorScenarios;
selectedActuatorRanges = uncertainty.selectedActuatorRanges;
scenarioEffects = evaluate_uncertainty_scenarios(screening, uncertainty);

actuatorFamily = build_actuator_family(uncertainty);
weightFit = fit_actuator_uncertainty_weight(actuatorFamily, uncertainty);
WI = weightFit.WI;

[GmechUncMeas, GmechUncQ, mechanicalInfo] = ...
    build_uncertain_mechanical_plant(selectedMechanicalRanges, m2.qbar);
[GuncMeas, GuncQ, uncertainPlantInfo] = build_m4_uncertain_plant( ...
    GmechUncMeas, GmechUncQ, WI);

mechanicalNominal = GmechUncMeas.NominalValue;
nominalConsistencyMetrics.mechanicalAAbsolute = ...
    norm(mechanicalNominal.A - m2.A, 'fro');
nominalConsistencyMetrics.mechanicalBAbsolute = ...
    norm(mechanicalNominal.B - m2.B, 'fro');
comparisonFrequencies = logspace(-1, 3, 801);
nominalConsistencyMetrics.mechanicalMeas = localCompareFrequency( ...
    mechanicalNominal, m2.Gmech_state, comparisonFrequencies);
nominalConsistencyMetrics.mechanicalQ = localCompareFrequency( ...
    GmechUncQ.NominalValue, m2.Gmech_q, comparisonFrequencies);
nominalConsistencyMetrics.fullMeas = localCompareFrequency( ...
    GuncMeas.NominalValue, m3.GfullMeas, comparisonFrequencies);
nominalConsistencyMetrics.fullQ = localCompareFrequency( ...
    GuncQ.NominalValue, m3.GfullQ, comparisonFrequencies);
nominalConsistencyMetrics.frequencyGrid = comparisonFrequencies;
nominalConsistencyMetrics.absoluteTolerance = 1e-8;
nominalConsistencyMetrics.relativeTolerance = 1e-8;

[~, ~, blockStructure] = lftdata(GuncMeas);
deltaStructureMetadata = localBlockStructureTable(blockStructure);

coverageMetrics.selectedOrder = weightFit.selectedOrder;
coverageMetrics.worstRatio = weightFit.worstRatio;
coverageMetrics.minimumCoverageMargin = ...
    weightFit.minimumCoverageMargin;
coverageMetrics.criticalFrequency = weightFit.criticalFrequency;
coverageMetrics.criticalSample = weightFit.criticalSample;
coverageMetrics.criticalSampleParameters = ...
    weightFit.criticalSampleParameters;
coverageMetrics.coverageTolerance = weightFit.coverageTolerance;
coverageMetrics.safetyFactor = weightFit.safetyFactor;
coverageMetrics.stable = weightFit.stable;
coverageMetrics.proper = weightFit.proper;
coverageMetrics.poles = weightFit.poles;
coverageMetrics.zeros = weightFit.zeros;
coverageMetrics.fitCandidateTable = weightFit.fitCandidateTable;

[samplingValidationMetrics, sampledPlants] = localValidateSamples( ...
    GuncMeas, selectedMechanicalRanges, uncertainty);

localCreateSensitivityFigure(parameterSensitivityTable, ...
    fullfile(figureDirectory, 'm4_parameter_sensitivity.png'));
localCreateActuatorCoverFigure(actuatorFamily, weightFit, ...
    fullfile(figureDirectory, 'm4_actuator_uncertainty_cover.png'));
localCreatePlantSamplesFigure(GuncMeas.NominalValue, sampledPlants, ...
    fullfile(figureDirectory, 'm4_uncertain_plant_samples.png'));

actuatorFamilyMetadata = actuatorFamily.metadata;
actuatorFamilySummary.bounds = actuatorFamily.bounds;
actuatorFamilySummary.seed = actuatorFamily.seed;
actuatorFamilySummary.numberSamples = actuatorFamily.numberSamples;
actuatorFamilySummary.numberRandomSamples = ...
    actuatorFamily.numberRandomSamples;
actuatorFamilySummary.numberCornerSamples = ...
    actuatorFamily.numberCornerSamples;
actuatorFamilySummary.numberSingleVariationSamples = ...
    actuatorFamily.numberSingleVariationSamples;
actuatorFamilySummary.delayModel = actuatorFamily.delayModel;
actuatorFamilySummary.frequencies = actuatorFamily.frequencies;
actuatorFamilySummary.errorEnvelope = actuatorFamily.errorEnvelope;
parameterScreeningRule = screening.priorityRule;

assert(numel(selectedMechanicalParameters) == 3, ...
    'M4Validation:SelectionCount', ...
    'The autonomous screen must select exactly three parameters.');
assert(actuatorFamily.numberSamples >= 100 && ...
    actuatorFamily.numberCornerSamples == 8, ...
    'M4Validation:ActuatorFamily', ...
    'Actuator family does not satisfy sample/corner requirements.');
assert(weightFit.stable && weightFit.proper && ...
    weightFit.worstRatio <= 1 + weightFit.coverageTolerance && ...
    weightFit.minimumCoverageMargin >= -weightFit.coverageTolerance, ...
    'M4Validation:Coverage', 'WI does not cover the actuator family.');
assert(all(ismember(["Delta_act1"; "Delta_act2"], ...
    string(fieldnames(GuncMeas.Uncertainty)))), ...
    'M4Validation:ActuatorBlocks', ...
    'Two independent actuator uncertainty blocks are required.');
assert(nominalConsistencyMetrics.mechanicalAAbsolute < 1e-8 && ...
    nominalConsistencyMetrics.mechanicalBAbsolute < 1e-8 && ...
    nominalConsistencyMetrics.fullMeas.MaximumAbsoluteError < 1e-8 && ...
    nominalConsistencyMetrics.fullMeas.MaximumRelativeError < 1e-8 && ...
    nominalConsistencyMetrics.fullQ.MaximumAbsoluteError < 1e-8 && ...
    nominalConsistencyMetrics.fullQ.MaximumRelativeError < 1e-8, ...
    'M4Validation:NominalMismatch', ...
    'Nominal uncertain plants do not reproduce M2/M3.');
assert(samplingValidationMetrics.pass, ...
    'M4Validation:InvalidSamples', ...
    'At least one usample validation check failed.');

save(fullfile(dataDirectory, 'm4_uncertain_plant.mat'), ...
    'parameterSensitivityTable', 'selectedMechanicalParameters', ...
    'parameterScreeningRule', 'uncertaintyScenarios', ...
    'selectedMechanicalRanges', 'actuatorUncertaintyScenarios', ...
    'selectedActuatorRanges', 'actuatorFamilyMetadata', ...
    'actuatorFamilySummary', 'WI', 'deltaStructureMetadata', ...
    'GmechUncMeas', 'GmechUncQ', 'GuncMeas', 'GuncQ', ...
    'nominalConsistencyMetrics', 'coverageMetrics', ...
    'samplingValidationMetrics', 'scenarioEffects', ...
    'mechanicalInfo', 'uncertainPlantInfo');

fprintf('Screen autonomo: %s (3/10 parametri).\n', ...
    strjoin(selectedMechanicalParameters, ', '));
fprintf('Famiglia attuatori: %d modelli (%d corner, %d singoli, %d random).\n', ...
    actuatorFamily.numberSamples, actuatorFamily.numberCornerSamples, ...
    actuatorFamily.numberSingleVariationSamples, ...
    actuatorFamily.numberRandomSamples);
fprintf(['WI: ordine %d, worst |E|/|WI| = %.12g, ' ...
    'margine minimo = %.12g.\n'], weightFit.selectedOrder, ...
    weightFit.worstRatio, weightFit.minimumCoverageMargin);
fprintf('Campione/frequenza critici: %s a %.9g rad/s.\n', ...
    weightFit.criticalSample, weightFit.criticalFrequency);
fprintf(['Coerenza nominale M3: Meas abs %.3e, rel %.3e; ' ...
    'Q abs %.3e, rel %.3e.\n'], ...
    nominalConsistencyMetrics.fullMeas.MaximumAbsoluteError, ...
    nominalConsistencyMetrics.fullMeas.MaximumRelativeError, ...
    nominalConsistencyMetrics.fullQ.MaximumAbsoluteError, ...
    nominalConsistencyMetrics.fullQ.MaximumRelativeError);
fprintf('usample: %d/%d campioni validi, seed %d.\n', ...
    samplingValidationMetrics.numberValidSamples, ...
    samplingValidationMetrics.numberSamples, ...
    samplingValidationMetrics.seed);
fprintf('[PASS] Quality gate tecnico M4 superato; dataset e figure rigenerati.\n');

metrics.screening = screening;
metrics.uncertainty = uncertainty;
metrics.scenarioEffects = scenarioEffects;
metrics.actuatorFamily = actuatorFamilySummary;
metrics.coverage = coverageMetrics;
metrics.deltaStructure = deltaStructureMetadata;
metrics.nominalConsistency = nominalConsistencyMetrics;
metrics.samplingValidation = samplingValidationMetrics;
metrics.GuncMeas = GuncMeas;
metrics.GuncQ = GuncQ;
end

function comparison = localCompareFrequency(actual, reference, frequencies)
actualResponse = freqresp(actual, frequencies);
referenceResponse = freqresp(reference, frequencies);
difference = actualResponse - referenceResponse;
absoluteError = abs(difference);
referenceNorm = localResponseNorm(referenceResponse);
differenceNorm = localResponseNorm(difference);
referenceFloor = max(1, max(referenceNorm)) * eps;
relativeError = differenceNorm ./ max(referenceNorm, referenceFloor);
comparison.MaximumAbsoluteError = max(absoluteError(:));
comparison.MaximumRelativeError = max(relativeError);
end

function metadata = localBlockStructureTable(blockStructure)
numberBlocks = numel(blockStructure);
name = strings(numberBlocks, 1);
rows = zeros(numberBlocks, 1);
columns = zeros(numberBlocks, 1);
type = strings(numberBlocks, 1);
realComplex = strings(numberBlocks, 1);
staticDynamic = strings(numberBlocks, 1);
occurrences = zeros(numberBlocks, 1);
for index = 1:numberBlocks
    name(index) = string(blockStructure(index).Name);
    rows(index) = blockStructure(index).Size(1);
    columns(index) = blockStructure(index).Size(2);
    type(index) = string(blockStructure(index).Type);
    occurrences(index) = blockStructure(index).Occurrences;
    if type(index) == "ureal"
        realComplex(index) = "real";
        staticDynamic(index) = "static";
    else
        realComplex(index) = "complex";
        staticDynamic(index) = "dynamic";
    end
end
metadata = table(name, rows, columns, type, realComplex, ...
    staticDynamic, occurrences, 'VariableNames', {'Name', 'Rows', ...
    'Columns', 'Type', 'RealComplex', 'StaticDynamic', 'Occurrences'});
end

function [validation, sampledPlants] = localValidateSamples( ...
    GuncMeas, mechanicalRanges, uncertainty)
numberSamples = uncertainty.plantValidationSamples;
frequencies = logspace(-1, 3, 301);
rng(uncertainty.plantSamplingSeed, 'twister');
[sampledPlants, sampledValues] = usample(GuncMeas, numberSamples);
finiteResponse = false(numberSamples, 1);
correctDimensions = false(numberSamples, 1);
parametersInRange = false(numberSamples, 1);
polesClassifiable = false(numberSamples, 1);
maximumRealPole = nan(numberSamples, 1);
numberUnstablePoles = nan(numberSamples, 1);

for sampleIndex = 1:numberSamples
    samplePlant = sampledPlants(:, :, sampleIndex);
    response = freqresp(samplePlant, frequencies);
    finiteResponse(sampleIndex) = all(isfinite(response(:)));
    correctDimensions(sampleIndex) = isequal(size(samplePlant), [4, 2]);
    samplePoles = pole(samplePlant);
    polesClassifiable(sampleIndex) = ~isempty(samplePoles) && ...
        all(isfinite(samplePoles));
    if polesClassifiable(sampleIndex)
        maximumRealPole(sampleIndex) = max(real(samplePoles));
        numberUnstablePoles(sampleIndex) = sum(real(samplePoles) > 1e-8);
    end

    withinRange = true;
    for parameterIndex = 1:height(mechanicalRanges)
        parameterName = char(mechanicalRanges.Parameter(parameterIndex));
        nominalValue = mechanicalRanges.NominalValue(parameterIndex);
        fraction = mechanicalRanges.BaselinePercent(parameterIndex) / 100;
        lowerBound = nominalValue * (1 - fraction);
        upperBound = nominalValue * (1 + fraction);
        actualValue = sampledValues(sampleIndex).(parameterName);
        withinRange = withinRange && actualValue >= lowerBound && ...
            actualValue <= upperBound;
    end
    expectedFields = [mechanicalRanges.Parameter; ...
        "Delta_act1"; "Delta_act2"];
    withinRange = withinRange && all(ismember(expectedFields, ...
        string(fieldnames(sampledValues(sampleIndex)))));
    parametersInRange(sampleIndex) = withinRange;
end

sampleValidationTable = table((1:numberSamples).', correctDimensions, ...
    finiteResponse, parametersInRange, polesClassifiable, ...
    maximumRealPole, numberUnstablePoles, 'VariableNames', {'Sample', ...
    'CorrectDimensions', 'FiniteResponse', 'ParametersInRange', ...
    'PolesClassifiable', 'MaximumRealPole', 'NumberUnstablePoles'});
valid = correctDimensions & finiteResponse & parametersInRange & ...
    polesClassifiable;
validation.seed = uncertainty.plantSamplingSeed;
validation.numberSamples = numberSamples;
validation.numberValidSamples = sum(valid);
validation.pass = all(valid);
validation.frequencyGrid = frequencies;
validation.minimumMaximumRealPole = min(maximumRealPole);
validation.maximumMaximumRealPole = max(maximumRealPole);
validation.minimumUnstablePoleCount = min(numberUnstablePoles);
validation.maximumUnstablePoleCount = max(numberUnstablePoles);
validation.sampleValidationTable = sampleValidationTable;
validation.note = ...
    "Open-loop instability is expected and is recorded, not rejected; " + ...
    "this is an M4 construction check, not the final Monte Carlo campaign.";
end

function localCreateSensitivityFigure(sensitivityTable, fileName)
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1050, 620]);
cleanupFigure = onCleanup(@() close(figureHandle));
orderedTable = sortrows(sensitivityTable, 'OverallRank', 'descend');
barHandles = barh(categorical( ...
    orderedTable.Parameter, orderedTable.Parameter), ...
    [orderedTable.DynamicScore, orderedTable.OverallPriority], 'grouped');
localStyleAxes(gca);
xlabel('Punteggio normalizzato', 'Color', [0.1, 0.1, 0.1]);
ylabel('Parametro candidato', 'Color', [0.1, 0.1, 0.1]);
title('M4 - Screening autonomo dei parametri meccanici', ...
    'Color', [0.1, 0.1, 0.1]);
legendHandle = legend(barHandles, ...
    {'Sensibilita dinamica', 'Priorita complessiva'}, ...
    'Location', 'southeast');
localStyleLegend(legendHandle);
grid on;
exportgraphics(figureHandle, fileName, 'Resolution', 180);
end

function localCreateActuatorCoverFigure(family, fit, fileName)
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1050, 620]);
cleanupFigure = onCleanup(@() close(figureHandle));
familyLines = semilogx( ...
    family.frequencies, abs(family.multiplicativeErrors).', ...
    'Color', [0.82, 0.82, 0.82], 'LineWidth', 0.45);
hold on;
envelopeLine = semilogx(family.frequencies, family.errorEnvelope, 'k-', ...
    'LineWidth', 2.0);
weightLine = semilogx(family.frequencies, fit.weightMagnitude, 'r--', ...
    'LineWidth', 2.2);
localStyleAxes(gca);
xlabel('Frequenza [rad/s]', 'Color', [0.1, 0.1, 0.1]);
ylabel('Modulo', 'Color', [0.1, 0.1, 0.1]);
title(sprintf(['M4 - Copertura dell''incertezza attuatore ' ...
    '(W_I ordine %d)'], fit.selectedOrder), 'Color', [0.1, 0.1, 0.1]);
legendHandle = legend([familyLines(1), envelopeLine, weightLine], ...
    {'Errori della famiglia', 'Inviluppo max |E_i|', '|W_I|'}, ...
    'Location', 'northwest');
localStyleLegend(legendHandle);
grid on;
xlim([family.frequencies(1), family.frequencies(end)]);
exportgraphics(figureHandle, fileName, 'Resolution', 180);
end

function localCreatePlantSamplesFigure(nominalPlant, sampledPlants, fileName)
frequencies = logspace(-1, log10(300), 401);
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1050, 620]);
cleanupFigure = onCleanup(@() close(figureHandle));
numberShown = min(12, size(sampledPlants, 3));
hold on;
firstSampleLine = gobjects(1);
for sampleIndex = 1:numberShown
    response = freqresp(sampledPlants(:, :, sampleIndex), frequencies);
    sampleLine = semilogx(frequencies, ...
        20 * log10(localDominantSigma(response)), ...
        'Color', [0.62, 0.70, 0.82], 'LineWidth', 0.8);
    if sampleIndex == 1
        firstSampleLine = sampleLine;
    end
end
nominalResponse = freqresp(nominalPlant, frequencies);
nominalLine = semilogx( ...
    frequencies, 20 * log10(localDominantSigma(nominalResponse)), ...
    'k-', 'LineWidth', 2.2);
localStyleAxes(gca);
xlabel('Frequenza [rad/s]', 'Color', [0.1, 0.1, 0.1]);
ylabel('Singular value dominante [dB]', 'Color', [0.1, 0.1, 0.1]);
title(sprintf('M4 - %d campioni della pianta incerta', numberShown), ...
    'Color', [0.1, 0.1, 0.1]);
legendHandle = legend([firstSampleLine, nominalLine], ...
    {'Campioni incerti', 'Nominale M3'}, 'Location', 'best');
localStyleLegend(legendHandle);
grid on;
xlim([frequencies(1), frequencies(end)]);
exportgraphics(figureHandle, fileName, 'Resolution', 180);
end

function localStyleAxes(axesHandle)
set(axesHandle, 'Color', 'white', 'XColor', [0.15, 0.15, 0.15], ...
    'YColor', [0.15, 0.15, 0.15], 'GridColor', [0.55, 0.55, 0.55], ...
    'MinorGridColor', [0.75, 0.75, 0.75]);
end

function localStyleLegend(legendHandle)
set(legendHandle, 'Color', 'white', 'TextColor', [0.1, 0.1, 0.1], ...
    'EdgeColor', [0.35, 0.35, 0.35]);
end

function responseNorm = localResponseNorm(response)
responseNorm = zeros(1, size(response, 3));
for index = 1:size(response, 3)
    responseNorm(index) = norm(response(:, :, index), 'fro');
end
end

function dominantSigma = localDominantSigma(response)
dominantSigma = zeros(1, size(response, 3));
for index = 1:size(response, 3)
    singularValues = svd(response(:, :, index));
    dominantSigma(index) = singularValues(1);
end
end
