function selection = select_lqr_no_integrator(m3Data, m5Data, config)
%SELECT_LQR_NO_INTEGRATOR Select M6 LQR tuning from closed-loop metrics.
%   Every rho_U candidate is synthesized and evaluated independently. The
%   largest rho_U satisfying the fundamental M5 tracking targets is chosen.

arguments
    m3Data (1, 1) struct
    m5Data (1, 1) struct
    config (1, 1) struct = lqg_specs_m6
end

requiredM3 = {'Afull', 'Bfull', 'CfullQ', 'CfullMeas'};
assert(all(isfield(m3Data, requiredM3)), 'M6LQR:MissingM3Data', ...
    'Validated M3 full-plant matrices are required.');
assert(isfield(m5Data, 'spec') && isfield(m5Data, 'BdFull'), ...
    'M6LQR:MissingM5Data', ...
    'Validated M5 specifications and BdFull are required.');

A = m3Data.Afull;
B = m3Data.Bfull;
Cq = m3Data.CfullQ;
Ctheta = m3Data.CfullMeas(3:4, :);
[Ccost, Q, scales, costInfo] = ...
    build_lqr_state_cost(m3Data, m5Data.spec);

rhoU = config.rhoUCandidates(:);
numberCandidates = numel(rhoU);
candidate = compose("LQR%02d", (1:numberCandidates).');
stable = false(numberCandidates, 1);
worstSettlingTime = inf(numberCandidates, 1);
worstOvershoot = inf(numberCandidates, 1);
worstSteadyStateErrorRelative = inf(numberCandidates, 1);
worstCrossCouplingPeakRatio = inf(numberCandidates, 1);
worstPeakControl = inf(numberCandidates, 1);
worstDisturbancePeakQ = inf(numberCandidates, 1);
worstDisturbanceSteadyStateOffset = inf(numberCandidates, 1);
worstDisturbanceSettlingTime = inf(numberCandidates, 1);
worstDisturbancePeakControl = inf(numberCandidates, 1);
preFilterResidual = inf(numberCandidates, 1);
preFilterCondition = inf(numberCandidates, 1);
fundamentalPass = false(numberCandidates, 1);
crossCouplingDiagnosticPass = false(numberCandidates, 1);
candidateControllers = cell(numberCandidates, 1);
candidatePreFilters = cell(numberCandidates, 1);
candidatePoles = cell(numberCandidates, 1);
candidateEvaluations = cell(numberCandidates, 1);

for candidateIndex = 1:numberCandidates
    Rcandidate = rhoU(candidateIndex) / m5Data.spec.uScale^2 * eye(2);
    [Kcandidate, ~, polesCandidate] = lqr(A, B, Q, Rcandidate);
    Acl = A - B * Kcandidate;
    staticTrackingGain = -Cq * (Acl \ B);
    Nrcandidate = staticTrackingGain \ eye(2);
    residual = norm(staticTrackingGain * Nrcandidate - eye(2), 'fro');
    conditionValue = cond(staticTrackingGain);
    evaluation = evaluate_m6_closed_loop(A, B, Cq, Ctheta, ...
        m5Data.BdFull, Kcandidate, Nrcandidate, ...
        m3Data.mechanicalParams.Ks, m5Data.spec, config);

    candidateControllers{candidateIndex} = Kcandidate;
    candidatePreFilters{candidateIndex} = Nrcandidate;
    candidatePoles{candidateIndex} = polesCandidate;
    candidateEvaluations{candidateIndex} = evaluation;
    stable(candidateIndex) = evaluation.summary.stable;
    worstSettlingTime(candidateIndex) = ...
        evaluation.summary.worstSettlingTime;
    worstOvershoot(candidateIndex) = evaluation.summary.worstOvershoot;
    worstSteadyStateErrorRelative(candidateIndex) = ...
        evaluation.summary.worstSteadyStateErrorRelative;
    worstCrossCouplingPeakRatio(candidateIndex) = ...
        evaluation.summary.worstCrossCouplingPeakRatio;
    worstPeakControl(candidateIndex) = ...
        evaluation.summary.worstPeakControl;
    worstDisturbancePeakQ(candidateIndex) = ...
        evaluation.summary.worstDisturbancePeakQ;
    worstDisturbanceSteadyStateOffset(candidateIndex) = ...
        evaluation.summary.worstDisturbanceSteadyStateOffset;
    worstDisturbanceSettlingTime(candidateIndex) = ...
        evaluation.summary.worstDisturbanceSettlingTime;
    worstDisturbancePeakControl(candidateIndex) = ...
        evaluation.summary.worstDisturbancePeakControl;
    preFilterResidual(candidateIndex) = residual;
    preFilterCondition(candidateIndex) = conditionValue;
    fundamentalPass(candidateIndex) = stable(candidateIndex) && ...
        worstSettlingTime(candidateIndex) <= ...
            m5Data.spec.settlingTimeTarget && ...
        worstOvershoot(candidateIndex) <= ...
            m5Data.spec.overshootTarget && ...
        worstSteadyStateErrorRelative(candidateIndex) <= ...
            m5Data.spec.steadyStateTrackingTarget;
    crossCouplingDiagnosticPass(candidateIndex) = ...
        worstCrossCouplingPeakRatio(candidateIndex) <= ...
        m5Data.spec.crossCouplingTarget;
end

rankingMatrix = [~fundamentalPass, -rhoU, worstSettlingTime, ...
    worstPeakControl, (1:numberCandidates).'];
[~, candidateOrder] = sortrows(rankingMatrix, ...
    1:size(rankingMatrix, 2));
ranking = zeros(numberCandidates, 1);
ranking(candidateOrder) = (1:numberCandidates).';
selected = false(numberCandidates, 1);
selectedIndex = candidateOrder(find( ...
    fundamentalPass(candidateOrder), 1, 'first'));
if ~isempty(selectedIndex)
    selected(selectedIndex) = true;
end

lqrCandidateTable = table(candidate, rhoU, stable, ...
    worstSettlingTime, worstOvershoot, ...
    worstSteadyStateErrorRelative, worstCrossCouplingPeakRatio, ...
    worstPeakControl, worstDisturbancePeakQ, ...
    worstDisturbanceSteadyStateOffset, ...
    worstDisturbanceSettlingTime, worstDisturbancePeakControl, ...
    preFilterResidual, preFilterCondition, fundamentalPass, ...
    crossCouplingDiagnosticPass, selected, ranking, ...
    'VariableNames', {'Candidate', 'RhoU', 'Stable', ...
    'WorstSettlingTime', 'WorstOvershoot', ...
    'WorstSteadyStateErrorRelative', ...
    'WorstCrossCouplingPeakRatio', 'WorstPeakControl', ...
    'WorstDisturbancePeakQ', 'WorstDisturbanceSteadyStateOffset', ...
    'WorstDisturbanceSettlingTime', 'WorstDisturbancePeakControl', ...
    'PreFilterResidual', 'PreFilterCondition', 'FundamentalPass', ...
    'CrossCouplingDiagnosticPass', 'Selected', 'Ranking'});

selection.status = "partial - no admissible LQR candidate";
selection.Ccost = Ccost;
selection.Q = Q;
selection.scales = scales;
selection.costInfo = costInfo;
selection.lqrCandidateTable = lqrCandidateTable;
selection.candidateControllers = candidateControllers;
selection.candidatePreFilters = candidatePreFilters;
selection.candidatePoles = candidatePoles;
selection.rules = [ ...
    "require nominal stability"; ...
    "require settling time, overshoot and steady-state tracking targets"; ...
    "select the largest admissible rhoU"; ...
    "break residual ties by settling time, peak control and fixed index"; ...
    "report the 25 percent cross-coupling target as a preliminary diagnostic"];
selection.selectedIndex = selectedIndex;
if ~isempty(selectedIndex)
    selection.status = "complete - admissible LQR candidate selected";
    selection.rhoU = rhoU(selectedIndex);
    selection.R = selection.rhoU / m5Data.spec.uScale^2 * eye(2);
    selection.K = candidateControllers{selectedIndex};
    selection.Nr = candidatePreFilters{selectedIndex};
    selection.regulatorPoles = candidatePoles{selectedIndex};
    selection.evaluation = candidateEvaluations{selectedIndex};
    selection.alphaController = min(-real(selection.regulatorPoles));
end
end
