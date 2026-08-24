function selection = select_nominal_actuator(m2Data)
%SELECT_NOMINAL_ACTUATOR Select a nominal actuator from M2-derived metrics.

if nargin < 1
    projectRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
    m2DatasetPath = fullfile(projectRoot, 'results', 'data', ...
        'm2_linearization_nominal.mat');
    if ~isfile(m2DatasetPath)
        validate_m2_equilibrium_linearization;
    end
    m2Data = load(m2DatasetPath, 'poles');
end

assert(isfield(m2Data, 'poles') && ~isempty(m2Data.poles), ...
    'M3Selection:MissingM2Poles', ...
    'M2 pole data are required to derive the actuator criteria.');

wnCandidates = [25, 40, 60];
zetaCandidates = [0.6, 0.8, 1.0];
delayCandidates = [0.010, 0.015, 0.025];
numberCandidates = numel(wnCandidates) * numel(zetaCandidates) * ...
    numel(delayCandidates);

stabilityTolerance = 1e-8;
unstablePoles = m2Data.poles(real(m2Data.poles) > stabilityTolerance);
elasticPoles = m2Data.poles(abs(imag(m2Data.poles)) > stabilityTolerance);
assert(~isempty(unstablePoles) && ~isempty(elasticPoles), ...
    'M3Selection:MissingCharacteristicModes', ...
    'M2 must contain unstable and complex elastic modes.');

criteria.lambdaUMax = max(abs(unstablePoles));
criteria.omegaElasticMin = min(abs(elasticPoles));
criteria.bandwidthUnstableMultiplier = 4;
criteria.bandwidthElasticFraction = 0.60;
criteria.bandwidthMinimum = criteria.bandwidthUnstableMultiplier * ...
    criteria.lambdaUMax;
criteria.bandwidthMaximum = criteria.bandwidthElasticFraction * ...
    criteria.omegaElasticMin;
criteria.overshootMaximum = 2;
criteria.phaseFrequency = 80;
criteria.phaseErrorMaximumDeg = 10;
criteria.settlingNearRelativeTolerance = 0.10;
criteria.source = "M2 poles and explicit M3.1 engineering coefficients";

assert(criteria.bandwidthMinimum < criteria.bandwidthMaximum, ...
    'M3Selection:EmptyBandwidthWindow', ...
    'The M2-derived actuator bandwidth window is empty.');

candidate = strings(numberCandidates, 1);
wn = zeros(numberCandidates, 1);
zeta = zeros(numberCandidates, 1);
delay = zeros(numberCandidates, 1);
riseTime = zeros(numberCandidates, 1);
settlingTime = zeros(numberCandidates, 1);
overshoot = zeros(numberCandidates, 1);
bandwidthValue = zeros(numberCandidates, 1);
padeRhpZero = zeros(numberCandidates, 1);
phaseError80 = zeros(numberCandidates, 1);

row = 0;
for wnValue = wnCandidates
    for zetaValue = zetaCandidates
        for delayValue = delayCandidates
            row = row + 1;
            params.wn = wnValue;
            params.zeta = zetaValue;
            params.delay = delayValue;
            params.padeOrder = 1;
            [~, info] = build_nominal_actuator(params);

            candidate(row) = sprintf('C%02d', row);
            wn(row) = wnValue;
            zeta(row) = zetaValue;
            delay(row) = delayValue;
            riseTime(row) = info.actuatorStep.RiseTime;
            settlingTime(row) = info.actuatorStep.SettlingTime;
            overshoot(row) = info.actuatorStep.Overshoot;
            bandwidthValue(row) = info.actuatorBandwidth;
            padeRhpZero(row) = 2 / delayValue;
            exactPhase = -criteria.phaseFrequency * delayValue;
            padePhase = -2 * atan(criteria.phaseFrequency * delayValue / 2);
            phaseError80(row) = abs(padePhase - exactPhase) * 180 / pi;
        end
    end
end

passesBandwidthMinimum = bandwidthValue >= criteria.bandwidthMinimum;
passesBandwidthMaximum = bandwidthValue <= criteria.bandwidthMaximum;
passesOvershoot = overshoot <= criteria.overshootMaximum;
passesPhaseError = phaseError80 <= criteria.phaseErrorMaximumDeg;
admissible = passesBandwidthMinimum & passesBandwidthMaximum & ...
    passesOvershoot & passesPhaseError;
assert(any(admissible), 'M3Selection:NoAdmissibleCandidate', ...
    'No candidate satisfies all M3.1 actuator-selection constraints.');

minimumAdmissibleSettling = min(settlingTime(admissible));
nearSettlingLimit = minimumAdmissibleSettling * ...
    (1 + criteria.settlingNearRelativeTolerance);
nearOptimalSettling = admissible & settlingTime <= nearSettlingLimit;

priorityIndices = find(nearOptimalSettling);
bandwidthMidpoint = (criteria.bandwidthMinimum + ...
    criteria.bandwidthMaximum) / 2;
rankingMatrix = [ ...
    -delay(priorityIndices), ...
    settlingTime(priorityIndices), ...
    overshoot(priorityIndices), ...
    abs(bandwidthValue(priorityIndices) - bandwidthMidpoint), ...
    wn(priorityIndices), ...
    zeta(priorityIndices), ...
    priorityIndices];
[~, priorityOrder] = sortrows(rankingMatrix, 1:size(rankingMatrix, 2));
orderedPriorityIndices = priorityIndices(priorityOrder);
selectedIndex = orderedPriorityIndices(1);

selectionRank = nan(numberCandidates, 1);
selectionRank(orderedPriorityIndices) = (1:numel(orderedPriorityIndices)).';
notes = strings(numberCandidates, 1);
for index = 1:numberCandidates
    if ~admissible(index)
        failedCriteria = strings(0, 1);
        if ~passesBandwidthMinimum(index)
            failedCriteria(end + 1) = "bandwidth below M2-derived minimum"; %#ok<AGROW>
        end
        if ~passesBandwidthMaximum(index)
            failedCriteria(end + 1) = "bandwidth above elastic-mode ceiling"; %#ok<AGROW>
        end
        if ~passesOvershoot(index)
            failedCriteria(end + 1) = "overshoot above limit"; %#ok<AGROW>
        end
        if ~passesPhaseError(index)
            failedCriteria(end + 1) = "Pade phase error above limit"; %#ok<AGROW>
        end
        notes(index) = join(failedCriteria, "; ");
    elseif nearOptimalSettling(index)
        notes(index) = "admissible; near-optimal settling pool";
    else
        notes(index) = "admissible; outside settling near-parity pool";
    end
end
notes(selectedIndex) = "selected from metrics";

candidateTable = table(candidate, wn, zeta, delay, riseTime, ...
    settlingTime, overshoot, bandwidthValue, padeRhpZero, phaseError80, ...
    passesBandwidthMinimum, passesBandwidthMaximum, passesOvershoot, ...
    passesPhaseError, admissible, nearOptimalSettling, selectionRank, ...
    notes, 'VariableNames', {'Candidate', 'wn', 'zeta', 'delay', ...
    'RiseTime', 'SettlingTime', 'Overshoot', 'Bandwidth', ...
    'PadeRhpZero', 'PhaseError80Deg', 'PassesBandwidthMinimum', ...
    'PassesBandwidthMaximum', 'PassesOvershoot', 'PassesPhaseError', ...
    'Admissible', 'NearOptimalSettling', 'SelectionRank', 'Notes'});

selected.wn = wn(selectedIndex);
selected.zeta = zeta(selectedIndex);
selected.delay = delay(selectedIndex);
selected.padeOrder = 1;

selection.candidates = candidateTable;
selection.admissibleCandidates = candidateTable(admissible, :);
selection.nearOptimalCandidates = candidateTable(nearOptimalSettling, :);
selection.selected = selected;
selection.selectedMetrics = candidateTable(selectedIndex, :);
selection.criteria = criteria;
selection.rule = [ ...
    "filter every candidate using the M2-derived bandwidth window, " + ...
        "overshoot limit and Pade phase-error limit"; ...
    "retain admissible candidates within 10% of the minimum settling time"; ...
    "prefer the largest admissible delay within that near-parity pool"; ...
    "break remaining ties by lower settling time, lower overshoot, lower " + ...
        "bandwidth-midpoint distance, lower wn, lower zeta and lower " + ...
        "candidate index"];
selection.grid.wn = wnCandidates;
selection.grid.zeta = zetaCandidates;
selection.grid.delay = delayCandidates;

assert(ismember(candidate(selectedIndex), candidate(admissible)), ...
    'M3Selection:InvalidSelection', ...
    'The selected candidate is not in the admissible set.');
end
