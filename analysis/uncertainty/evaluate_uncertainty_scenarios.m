function scenarioEffects = evaluate_uncertainty_scenarios( ...
    screening, uncertainty)
%EVALUATE_UNCERTAINTY_SCENARIOS Compare mild/baseline/conservative effects.

projectRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
m3 = load(fullfile(projectRoot, 'results', 'data', ...
    'm3_nominal_actuated_plant.mat'), 'GactuatorsMimo');
scenarioNames = ["MILD"; "BASELINE"; "CONSERVATIVE"];
scenarioColumns = ["MildPercent"; "BaselinePercent"; ...
    "ConservativePercent"];
frequencies = uncertainty.sensitivityGrid;
nominalResponse = freqresp(screening.GnominalQ, frequencies);
nominalNorm = localResponseNorm(nominalResponse);
nominalFloor = 1e-8 * max(nominalNorm);
nominalPoles = pole(screening.GnominalQ);
[nominalUnstable, nominalElastic] = localModes(nominalPoles);

maximumRelativeFrf = zeros(3, 1);
peakFrequency = zeros(3, 1);
maximumUnstablePoleChange = zeros(3, 1);
maximumElasticModeChange = zeros(3, 1);
numberCorners = zeros(3, 1);

for scenarioIndex = 1:3
    scenarioRanges = uncertainty.mechanicalScenarios(:, ...
        {'Parameter', 'NominalValue', 'BaselinePercent', 'Rationale'});
    scenarioRanges.BaselinePercent = ...
        uncertainty.mechanicalScenarios.(scenarioColumns(scenarioIndex));
    [~, GmechQ] = build_uncertain_mechanical_plant( ...
        scenarioRanges, [pi / 2; 0]);
    GfullQ = series(m3.GactuatorsMimo, GmechQ);
    parameterCount = height(scenarioRanges);
    numberCorners(scenarioIndex) = 2^parameterCount;

    for cornerIndex = 0:(2^parameterCount - 1)
        sampledPlant = GfullQ;
        for parameterIndex = 1:parameterCount
            signValue = 2 * bitget(cornerIndex, parameterIndex) - 1;
            actualValue = scenarioRanges.NominalValue(parameterIndex) * ...
                (1 + signValue * ...
                scenarioRanges.BaselinePercent(parameterIndex) / 100);
            sampledPlant = usubs(sampledPlant, ...
                char(scenarioRanges.Parameter(parameterIndex)), actualValue);
        end
        sampleResponse = freqresp(sampledPlant, frequencies);
        differenceNorm = localResponseNorm(sampleResponse - nominalResponse);
        relativeDifference = differenceNorm ./ ...
            max(nominalNorm, nominalFloor);
        [cornerMaximum, cornerPeakIndex] = max(relativeDifference);
        if cornerMaximum > maximumRelativeFrf(scenarioIndex)
            maximumRelativeFrf(scenarioIndex) = cornerMaximum;
            peakFrequency(scenarioIndex) = frequencies(cornerPeakIndex);
        end

        [sampleUnstable, sampleElastic] = localModes(pole(sampledPlant));
        maximumUnstablePoleChange(scenarioIndex) = max( ...
            maximumUnstablePoleChange(scenarioIndex), ...
            max(abs(sampleUnstable - nominalUnstable) ./ ...
            abs(nominalUnstable)));
        maximumElasticModeChange(scenarioIndex) = max( ...
            maximumElasticModeChange(scenarioIndex), ...
            max(abs(sampleElastic - nominalElastic) ./ nominalElastic));
    end
end

mechanicalScenarioEffects = table(scenarioNames, numberCorners, ...
    maximumRelativeFrf, peakFrequency, maximumUnstablePoleChange, ...
    maximumElasticModeChange, 'VariableNames', {'Scenario', ...
    'NumberCorners', 'MaximumRelativeFRF', 'PeakFrequency', ...
    'MaximumRelativeUnstablePoleChange', ...
    'MaximumRelativeElasticModeChange'});

actuatorMaximumError = zeros(3, 1);
actuatorPeakFrequency = zeros(3, 1);
actuatorNominalParams = actuator_params_nominal;
[GactuatorNominal, ~] = build_nominal_actuator(actuatorNominalParams);
coverageFrequencies = uncertainty.coverageGrid;
nominalPadeResponse = squeeze(freqresp( ...
    GactuatorNominal, coverageFrequencies)).';

for scenarioIndex = 1:3
    ranges = uncertainty.actuatorScenarios.(scenarioColumns(scenarioIndex));
    bounds = uncertainty.actuatorScenarios.NominalValue .* ...
        [1 - ranges / 100, 1 + ranges / 100];
    for cornerIndex = 0:7
        wnValue = bounds(1, bitget(cornerIndex, 1) + 1);
        zetaValue = bounds(2, bitget(cornerIndex, 2) + 1);
        delayValue = bounds(3, bitget(cornerIndex, 3) + 1);
        s = 1i * coverageFrequencies;
        response = wnValue^2 ./ ...
            (s.^2 + 2 * zetaValue * wnValue * s + wnValue^2) .* ...
            exp(-s * delayValue);
        errorMagnitude = abs(response ./ nominalPadeResponse - 1);
        [cornerMaximum, cornerPeakIndex] = max(errorMagnitude);
        if cornerMaximum > actuatorMaximumError(scenarioIndex)
            actuatorMaximumError(scenarioIndex) = cornerMaximum;
            actuatorPeakFrequency(scenarioIndex) = ...
                coverageFrequencies(cornerPeakIndex);
        end
    end
end

actuatorScenarioEffects = table(scenarioNames, ...
    actuatorMaximumError, actuatorPeakFrequency, ...
    'VariableNames', {'Scenario', 'MaximumMultiplicativeError', ...
    'PeakFrequency'});
scenarioEffects.mechanical = mechanicalScenarioEffects;
scenarioEffects.actuator = actuatorScenarioEffects;
end

function responseNorm = localResponseNorm(response)
responseNorm = zeros(1, size(response, 3));
for index = 1:size(response, 3)
    responseNorm(index) = norm(response(:, :, index), 'fro');
end
end

function [unstablePoles, elasticFrequencies] = localModes(poles)
unstablePoles = sort(real(poles(real(poles) > 1e-8)));
elasticFrequencies = sort(abs(poles(imag(poles) > 1e-8)));
unstablePoles = unstablePoles(1:2);
elasticFrequencies = elasticFrequencies(end - 1:end);
end
