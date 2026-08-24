function family = build_actuator_family(uncertainty)
%BUILD_ACTUATOR_FAMILY Exact-delay actuator family for M4 WI fitting.

frequencies = uncertainty.coverageGrid;
selectedRanges = uncertainty.selectedActuatorRanges;
wnNominal = localRangeValue(selectedRanges, "wn", "NominalValue");
zetaNominal = localRangeValue(selectedRanges, "zeta", "NominalValue");
delayNominal = localRangeValue(selectedRanges, "delay", "NominalValue");
wnPercent = localRangeValue(selectedRanges, "wn", "BaselinePercent");
zetaPercent = localRangeValue(selectedRanges, "zeta", "BaselinePercent");
delayPercent = localRangeValue(selectedRanges, "delay", "BaselinePercent");

bounds.wn = wnNominal * [1 - wnPercent / 100, 1 + wnPercent / 100];
bounds.zeta = zetaNominal * ...
    [1 - zetaPercent / 100, 1 + zetaPercent / 100];
bounds.delay = delayNominal * ...
    [1 - delayPercent / 100, 1 + delayPercent / 100];

sampleId = strings(0, 1);
kind = strings(0, 1);
wn = zeros(0, 1);
zeta = zeros(0, 1);
delay = zeros(0, 1);

[sampleId, kind, wn, zeta, delay] = localAppendSample( ...
    sampleId, kind, wn, zeta, delay, "nominal-exact", ...
    wnNominal, zetaNominal, delayNominal);

singleNames = ["wn-min"; "wn-max"; "zeta-min"; "zeta-max"; ...
    "delay-min"; "delay-max"];
singleValues = [ ...
    bounds.wn(1), zetaNominal, delayNominal; ...
    bounds.wn(2), zetaNominal, delayNominal; ...
    wnNominal, bounds.zeta(1), delayNominal; ...
    wnNominal, bounds.zeta(2), delayNominal; ...
    wnNominal, zetaNominal, bounds.delay(1); ...
    wnNominal, zetaNominal, bounds.delay(2)];
for index = 1:size(singleValues, 1)
    [sampleId, kind, wn, zeta, delay] = localAppendSample( ...
        sampleId, kind, wn, zeta, delay, singleNames(index), ...
        singleValues(index, 1), singleValues(index, 2), ...
        singleValues(index, 3));
end

for wnIndex = 1:2
    for zetaIndex = 1:2
        for delayIndex = 1:2
            cornerName = sprintf('corner-%d%d%d', ...
                wnIndex, zetaIndex, delayIndex);
            [sampleId, kind, wn, zeta, delay] = localAppendSample( ...
                sampleId, kind, wn, zeta, delay, "corner", ...
                bounds.wn(wnIndex), bounds.zeta(zetaIndex), ...
                bounds.delay(delayIndex), cornerName);
        end
    end
end

rng(uncertainty.actuatorFamilySeed, 'twister');
numberRandom = uncertainty.actuatorRandomSamples;
randomUnit = rand(numberRandom, 3);
for index = 1:numberRandom
    randomWn = bounds.wn(1) + diff(bounds.wn) * randomUnit(index, 1);
    randomZeta = bounds.zeta(1) + ...
        diff(bounds.zeta) * randomUnit(index, 2);
    randomDelay = bounds.delay(1) + ...
        diff(bounds.delay) * randomUnit(index, 3);
    [sampleId, kind, wn, zeta, delay] = localAppendSample( ...
        sampleId, kind, wn, zeta, delay, "random", ...
        randomWn, randomZeta, randomDelay);
end

numberSamples = numel(sampleId);
responses = zeros(numberSamples, numel(frequencies));
for index = 1:numberSamples
    s = 1i * frequencies;
    secondOrder = wn(index)^2 ./ ...
        (s.^2 + 2 * zeta(index) * wn(index) * s + wn(index)^2);
    responses(index, :) = secondOrder .* exp(-s * delay(index));
end

nominalParams = actuator_params_nominal;
[GnominalPade, ~] = build_nominal_actuator(nominalParams);
nominalPadeResponse = squeeze(freqresp(GnominalPade, frequencies)).';
multiplicativeErrors = responses ./ nominalPadeResponse - 1;
errorEnvelope = max(abs(multiplicativeErrors), [], 1);

responseData = reshape(responses.', ...
    [1, 1, numel(frequencies), numberSamples]);
familyModels = frd(responseData, frequencies);
nominalPadeFrd = frd(reshape(nominalPadeResponse, 1, 1, []), frequencies);
metadata = table(sampleId, kind, wn, zeta, delay, ...
    'VariableNames', {'SampleId', 'Kind', 'wn', 'zeta', 'delay'});

family.metadata = metadata;
family.bounds = bounds;
family.frequencies = frequencies;
family.responses = responses;
family.nominalPadeResponse = nominalPadeResponse;
family.multiplicativeErrors = multiplicativeErrors;
family.errorEnvelope = errorEnvelope;
family.models = familyModels;
family.nominalPadeFrd = nominalPadeFrd;
family.seed = uncertainty.actuatorFamilySeed;
family.numberSamples = numberSamples;
family.numberRandomSamples = numberRandom;
family.numberCornerSamples = sum(kind == "corner");
family.numberSingleVariationSamples = ...
    numberSamples - numberRandom - family.numberCornerSamples - 1;
family.delayModel = ...
    "exact exp(-j*w*delay); nominal project model remains first-order Pade";
end

function value = localRangeValue(rangeTable, parameter, variable)
row = rangeTable.Parameter == parameter;
assert(sum(row) == 1, 'M4ActuatorFamily:MissingRange', ...
    'Expected one range row for %s.', parameter);
value = rangeTable.(variable)(row);
end

function [ids, kinds, wnValues, zetaValues, delayValues] = ...
    localAppendSample(ids, kinds, wnValues, zetaValues, delayValues, ...
    sampleKind, wnValue, zetaValue, delayValue, explicitId)
if nargin < 10
    explicitId = sprintf('S%03d', numel(ids) + 1);
end
ids(end + 1, 1) = string(explicitId);
kinds(end + 1, 1) = string(sampleKind);
wnValues(end + 1, 1) = wnValue;
zetaValues(end + 1, 1) = zetaValue;
delayValues(end + 1, 1) = delayValue;
end
