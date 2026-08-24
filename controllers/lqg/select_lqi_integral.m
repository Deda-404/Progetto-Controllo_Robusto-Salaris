function selection = select_lqi_integral(m3Data, m5Data, m6Data, config)
%SELECT_LQI_INTEGRAL Evaluate and rank the complete 28-candidate M7 grid.
%   No candidate is known in advance. Fundamental feasibility combines
%   nominal stability, all M5 tracking targets and explicit constant-
%   disturbance rejection at both links.

arguments
    m3Data (1, 1) struct
    m5Data (1, 1) struct
    m6Data (1, 1) struct
    config (1, 1) struct = lqg_specs_m7
end

wiGrid = config.wiCandidates(:);
rhoGrid = config.rhoUCandidates(:);
candidateCount = numel(wiGrid) * numel(rhoGrid);
rows = repmat(localEmptyRow, candidateCount, 1);
evaluations = cell(candidateCount, 1);
designs = cell(candidateCount, 1);

candidateIndex = 0;
for wiIndex = 1:numel(wiGrid)
    for rhoIndex = 1:numel(rhoGrid)
        candidateIndex = candidateIndex + 1;
        design = build_lqi_augmented_cost(m3Data, m5Data, m6Data, ...
            wiGrid(wiIndex), rhoGrid(rhoIndex));
        evaluation = localEvaluateCandidate( ...
            m3Data, m5Data, design, config);
        designs{candidateIndex} = design;
        evaluations{candidateIndex} = evaluation;

        row = localEmptyRow;
        row.CandidateIndex = candidateIndex;
        row.Candidate = sprintf('I%02d', candidateIndex);
        row.Wi = design.wi;
        row.RhoU = design.rhoU;
        row.Stable = evaluation.summary.stable;
        row.WorstSettlingTime = evaluation.summary.worstSettlingTime;
        row.WorstOvershoot = evaluation.summary.worstOvershoot;
        row.WorstSteadyStateErrorRelative = ...
            evaluation.summary.worstSteadyStateErrorRelative;
        row.WorstCrossCouplingPeakRatio = ...
            evaluation.summary.worstCrossCouplingPeakRatio;
        row.PeakU = evaluation.summary.worstPeakControl;
        row.PeakUNormalized = evaluation.summary.peakControlNormalized;
        row.PeakDelta = evaluation.summary.worstPeakDeformation;
        row.PeakDeltaNormalized = ...
            evaluation.summary.peakDeformationNormalized;
        row.PeakElasticTorque = ...
            evaluation.summary.worstPeakElasticTorque;
        row.NormKx = norm(design.Kx, 'fro');
        row.NormKi = norm(design.Ki, 'fro');
        row.WorstDisturbancePeakQ = ...
            evaluation.summary.worstDisturbancePeakQ;
        row.WorstDisturbanceSettlingTime = ...
            evaluation.summary.worstDisturbanceSettlingTime;
        row.WorstDisturbanceSteadyStateOffset = ...
            evaluation.summary.worstDisturbanceSteadyStateOffset;
        row.WorstDisturbanceCrossCouplingPeakRatio = ...
            evaluation.summary.worstDisturbanceCrossCouplingPeakRatio;
        row.WindupIndicator = evaluation.summary.windupIndicator;
        row.TrackingPass = evaluation.summary.trackingPass;
        row.DisturbancePass = evaluation.summary.disturbancePass;
        row.FundamentalPass = evaluation.summary.fundamentalPass;
        rows(candidateIndex) = row;
    end
end

lqiCandidateTable = struct2table(rows);
lqiCandidateTable.Selected = false(candidateCount, 1);
lqiCandidateTable.Ranking = NaN(candidateCount, 1);
admissibleIndices = find(lqiCandidateTable.FundamentalPass);
selectedIndex = [];
if ~isempty(admissibleIndices)
    ranked = sortrows(lqiCandidateTable(admissibleIndices, :), ...
        {'PeakUNormalized', 'PeakDeltaNormalized', ...
        'WorstDisturbanceSettlingTime', 'NormKi', 'RhoU', ...
        'CandidateIndex'}, ...
        {'ascend', 'ascend', 'ascend', 'ascend', 'descend', 'ascend'});
    ranked.Ranking = (1:height(ranked)).';
    for rankIndex = 1:height(ranked)
        originalIndex = ranked.CandidateIndex(rankIndex);
        lqiCandidateTable.Ranking(originalIndex) = rankIndex;
    end
    selectedIndex = ranked.CandidateIndex(1);
    lqiCandidateTable.Selected(selectedIndex) = true;
end

selection.grid.wi = wiGrid;
selection.grid.rhoU = rhoGrid;
selection.lqiCandidateTable = lqiCandidateTable;
selection.selectedIndex = selectedIndex;
selection.admissibleIndices = admissibleIndices;
selection.designs = designs;
selection.evaluations = evaluations;
if ~isempty(selectedIndex)
    selectedDesign = designs{selectedIndex};
    selectedEvaluation = evaluations{selectedIndex};
    selection.selectedRow = lqiCandidateTable(selectedIndex, :);
    selection.Aaug = selectedDesign.Aaug;
    selection.Baug = selectedDesign.Baug;
    selection.Qaug = selectedDesign.Qaug;
    selection.R = selectedDesign.R;
    selection.Kaug = selectedDesign.Kaug;
    selection.Kx = selectedDesign.Kx;
    selection.Ki = selectedDesign.Ki;
    selection.servoPoles = selectedDesign.servoPoles;
    selection.xiScale = selectedDesign.xiScale;
    selection.structural = selectedDesign.structural;
    selection.selectedEvaluation = selectedEvaluation;
end
end

function row = localEmptyRow
row = struct('CandidateIndex', 0, 'Candidate', '', 'Wi', NaN, ...
    'RhoU', NaN, 'Stable', false, 'WorstSettlingTime', NaN, ...
    'WorstOvershoot', NaN, 'WorstSteadyStateErrorRelative', NaN, ...
    'WorstCrossCouplingPeakRatio', NaN, 'PeakU', NaN, ...
    'PeakUNormalized', NaN, 'PeakDelta', NaN, ...
    'PeakDeltaNormalized', NaN, 'PeakElasticTorque', NaN, ...
    'NormKx', NaN, 'NormKi', NaN, 'WorstDisturbancePeakQ', NaN, ...
    'WorstDisturbanceSettlingTime', NaN, ...
    'WorstDisturbanceSteadyStateOffset', NaN, ...
    'WorstDisturbanceCrossCouplingPeakRatio', NaN, ...
    'WindupIndicator', NaN, 'TrackingPass', false, ...
    'DisturbancePass', false, 'FundamentalPass', false);
end

function evaluation = localEvaluateCandidate(m3Data, m5Data, design, config)
A = m3Data.Afull;
B = m3Data.Bfull;
Cq = m3Data.CfullQ;
Ctheta = m3Data.CfullMeas(3:4, :);
Bd = m5Data.BdFull;
Ks = m3Data.mechanicalParams.Ks;
n = size(A, 1);
Kx = design.Kx;
Ki = design.Ki;

Acl = [A - B * Kx, -B * Ki; -Cq, zeros(2)];
Bcl = [zeros(n, 2), Bd; eye(2), zeros(2)];
Ccl = [Cq, zeros(2); Ctheta, zeros(2); ...
    -Kx, -Ki; zeros(2, n), eye(2)];
closedLoop = ss(Acl, Bcl, Ccl, zeros(8, 4), ...
    'InputName', {'r1', 'r2', 'd1', 'd2'}, ...
    'OutputName', {'q1', 'q2', 'theta1', 'theta2', ...
    'u1', 'u2', 'xi1', 'xi2'});

spec = m5Data.spec;
referenceTime = (0:config.simulationTimeStep:config.referenceHorizon).';
disturbanceTime = ...
    (0:config.simulationTimeStep:config.disturbanceHorizon).';
tracking = zeros(2, 6);
disturbance = zeros(2, 5);
referenceOutput = cell(2, 1);
disturbanceOutput = cell(2, 1);
peakDelta = zeros(2, 1);
peakElasticTorque = zeros(2, 1);
peakXi = zeros(2, 1);
trackingDc = dcgain(closedLoop(1:2, 1:2));
disturbanceDc = dcgain(closedLoop(1:2, 3:4));

for jointIndex = 1:2
    input = zeros(numel(referenceTime), 4);
    input(:, jointIndex) = spec.referenceAmplitude;
    output = lsim(closedLoop, input, referenceTime);
    referenceOutput{jointIndex} = output;
    q = output(:, 1:2);
    theta = output(:, 3:4);
    u = output(:, 5:6);
    xi = output(:, 7:8);
    finalQ = trackingDc(:, jointIndex) * spec.referenceAmplitude;
    tracking(jointIndex, 1) = localSettlingTime( ...
        q(:, jointIndex), finalQ(jointIndex), referenceTime, ...
        config.settlingBandFraction * abs(spec.referenceAmplitude));
    tracking(jointIndex, 2) = 100 * max(0, ...
        (max(q(:, jointIndex)) - spec.referenceAmplitude) / ...
        spec.referenceAmplitude);
    tracking(jointIndex, 3) = abs( ...
        finalQ(jointIndex) - spec.referenceAmplitude) / ...
        spec.referenceAmplitude;
    otherJoint = 3 - jointIndex;
    tracking(jointIndex, 4) = max(abs(q(:, otherJoint))) / ...
        max(max(abs(q(:, jointIndex))), eps);
    tracking(jointIndex, 5) = max(abs(u), [], 'all');
    tracking(jointIndex, 6) = max(abs(xi), [], 'all');
    deformation = theta - q;
    peakDelta(jointIndex) = max(abs(deformation), [], 'all');
    peakElasticTorque(jointIndex) = max(abs( ...
        deformation * Ks.'), [], 'all');
    peakXi(jointIndex) = max(abs(xi), [], 'all');

    input = zeros(numel(disturbanceTime), 4);
    input(:, jointIndex + 2) = spec.disturbanceTorqueAmplitude;
    output = lsim(closedLoop, input, disturbanceTime);
    disturbanceOutput{jointIndex} = output;
    q = output(:, 1:2);
    xi = output(:, 7:8);
    finalQ = disturbanceDc(:, jointIndex) * ...
        spec.disturbanceTorqueAmplitude;
    affectedPeak = max(abs(q(:, jointIndex)));
    disturbance(jointIndex, 1) = affectedPeak;
    disturbance(jointIndex, 2) = finalQ(jointIndex);
    disturbance(jointIndex, 3) = localSettlingTime( ...
        q(:, jointIndex), finalQ(jointIndex), disturbanceTime, ...
        config.settlingBandFraction * max(affectedPeak, eps));
    otherJoint = 3 - jointIndex;
    disturbance(jointIndex, 4) = max(abs(q(:, otherJoint))) / ...
        max(affectedPeak, eps);
    disturbance(jointIndex, 5) = max(abs(xi), [], 'all');
end

trackingMetrics = array2table([(1:2).', tracking], ...
    'VariableNames', {'ReferenceJoint', 'SettlingTime', 'Overshoot', ...
    'SteadyStateErrorRelative', 'CrossCouplingPeakRatio', ...
    'PeakControl', 'PeakXi'});
disturbanceMetrics = array2table([(1:2).', disturbance], ...
    'VariableNames', {'DisturbanceJoint', 'PeakQ', ...
    'SteadyStateOffset', 'SettlingTime', ...
    'CrossCouplingPeakRatio', 'PeakXi'});

stable = all(real(eig(Acl)) < -config.numericStabilityTolerance);
trackingPass = stable && all( ...
    trackingMetrics.SettlingTime <= spec.settlingTimeTarget) && ...
    all(trackingMetrics.Overshoot <= spec.overshootTarget) && ...
    all(trackingMetrics.SteadyStateErrorRelative <= ...
        spec.steadyStateTrackingTarget);
disturbancePass = stable && all(abs( ...
    disturbanceMetrics.SteadyStateOffset) <= ...
    config.disturbanceSteadyStateTolerance);
deformationScale = spec.disturbanceTorqueAmplitude / min(diag(Ks));

evaluation.closedLoop = closedLoop;
evaluation.trackingMetrics = trackingMetrics;
evaluation.disturbanceMetrics = disturbanceMetrics;
evaluation.referenceTime = referenceTime;
evaluation.referenceOutput = referenceOutput;
evaluation.disturbanceTime = disturbanceTime;
evaluation.disturbanceOutput = disturbanceOutput;
evaluation.summary.stable = stable;
evaluation.summary.trackingPass = trackingPass;
evaluation.summary.disturbancePass = disturbancePass;
evaluation.summary.fundamentalPass = trackingPass && disturbancePass;
evaluation.summary.worstSettlingTime = max(trackingMetrics.SettlingTime);
evaluation.summary.worstOvershoot = max(trackingMetrics.Overshoot);
evaluation.summary.worstSteadyStateErrorRelative = ...
    max(trackingMetrics.SteadyStateErrorRelative);
evaluation.summary.worstCrossCouplingPeakRatio = ...
    max(trackingMetrics.CrossCouplingPeakRatio);
evaluation.summary.worstPeakControl = max(trackingMetrics.PeakControl);
evaluation.summary.peakControlNormalized = ...
    evaluation.summary.worstPeakControl / spec.uScale;
evaluation.summary.worstPeakDeformation = max(peakDelta);
evaluation.summary.peakDeformationNormalized = ...
    max(peakDelta) / deformationScale;
evaluation.summary.worstPeakElasticTorque = max(peakElasticTorque);
evaluation.summary.worstDisturbancePeakQ = ...
    max(disturbanceMetrics.PeakQ);
evaluation.summary.worstDisturbanceSettlingTime = ...
    max(disturbanceMetrics.SettlingTime);
evaluation.summary.worstDisturbanceSteadyStateOffset = ...
    max(abs(disturbanceMetrics.SteadyStateOffset));
evaluation.summary.worstDisturbanceCrossCouplingPeakRatio = ...
    max(disturbanceMetrics.CrossCouplingPeakRatio);
evaluation.summary.windupIndicator = max([peakXi; disturbance(:, 5)]) / ...
    design.xiScale;
end

function settlingTime = localSettlingTime(signal, finalValue, time, threshold)
outsideBand = abs(signal - finalValue) > max(threshold, 100 * eps);
lastOutside = find(outsideBand, 1, 'last');
if isempty(lastOutside)
    settlingTime = 0;
elseif lastOutside == numel(time)
    settlingTime = inf;
else
    settlingTime = time(lastOutside + 1);
end
end
