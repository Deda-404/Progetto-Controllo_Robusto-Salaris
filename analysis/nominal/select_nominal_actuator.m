function selection = select_nominal_actuator
%SELECT_NOMINAL_ACTUATOR Deterministic comparison of nominal candidates.

selected = actuator_params_nominal;
wnCandidates = [25, selected.wn, 60];
zetaCandidates = [0.6, selected.zeta, 1.0];
delayCandidates = [0.010, selected.delay, 0.025];
numberCandidates = numel(wnCandidates) * numel(zetaCandidates) * ...
    numel(delayCandidates);

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
notes = strings(numberCandidates, 1);

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
            exactPhase80 = -80 * delayValue;
            padePhase80 = -2 * atan(80 * delayValue / 2);
            phaseError80(row) = abs(padePhase80 - exactPhase80) * 180 / pi;

            if wnValue == selected.wn && zetaValue == selected.zeta && ...
                    delayValue == selected.delay
                notes(row) = "selected nominal assumption";
            elseif zetaValue < selected.zeta
                notes(row) = "lower damping";
            elseif delayValue > selected.delay
                notes(row) = "larger delay phase error";
            elseif wnValue >= 60
                notes(row) = "closer to elastic modes";
            else
                notes(row) = "comparison candidate";
            end
        end
    end
end

candidateTable = table(candidate, wn, zeta, delay, riseTime, ...
    settlingTime, overshoot, bandwidthValue, padeRhpZero, phaseError80, ...
    notes, 'VariableNames', {'Candidate', 'wn', 'zeta', 'delay', ...
    'RiseTime', 'SettlingTime', 'Overshoot', 'Bandwidth', ...
    'PadeRhpZero', 'PhaseError80Deg', 'Notes'});
selectedMask = wn == selected.wn & zeta == selected.zeta & ...
    delay == selected.delay;

selection.candidates = candidateTable;
selection.selected = selected;
selection.selectedMetrics = candidateTable(selectedMask, :);
selection.criteria = [ ...
    "positive damping with low overshoot"; ...
    "actuator faster than the 4-7 rad/s unstable mechanical modes"; ...
    "roll-off remains relevant before the 70-80 rad/s elastic modes"; ...
    "delay is material but first-order Pade error remains moderate"];

assert(sum(selectedMask) == 1, 'M3:CandidateSelection', ...
    'The selected nominal candidate is not unique in the grid.');
end
