function selection = select_lqi_integral(m3Data, m5Data, m6Data, config)
%SELECT_LQI_INTEGRAL Tune the M7 two-degree-of-freedom LQI servo.
%   Stage A always evaluates the approved 7-by-4 checkpoint grid first.
%   For every candidate Nff is derived from that candidate's Kx. Stage B
%   is evaluated only if Stage A contains no fundamental-admissible design.

arguments
    m3Data (1, 1) struct
    m5Data (1, 1) struct
    m6Data (1, 1) struct
    config (1, 1) struct = lqg_specs_m7
end

stageA = localEvaluateGrid(m3Data, m5Data, m6Data, config, ...
    config.wiCandidates, config.rhoUCandidates, "Stage A", "I", 0);
stageBExecuted = isempty(stageA.selectedLocalIndex);
stageB = struct;
if stageBExecuted
    stageB = localEvaluateGrid(m3Data, m5Data, m6Data, config, ...
        config.stageBWiCandidates, config.stageBRhoUCandidates, ...
        "Stage B", "E", height(stageA.candidateTable));
    activeStage = stageB;
    allCandidateTable = [stageA.candidateTable; stageB.candidateTable];
    allDesigns = [stageA.designs; stageB.designs];
    allEvaluations = [stageA.evaluations; stageB.evaluations];
    allOneDofEvaluations = [stageA.oneDofEvaluations; ...
        stageB.oneDofEvaluations];
else
    activeStage = stageA;
    allCandidateTable = stageA.candidateTable;
    allDesigns = stageA.designs;
    allEvaluations = stageA.evaluations;
    allOneDofEvaluations = stageA.oneDofEvaluations;
end

selectedIndex = [];
if ~isempty(activeStage.selectedLocalIndex)
    selectedIndex = find(allCandidateTable.Selected, 1);
end

selection.grid.wi = config.wiCandidates(:);
selection.grid.rhoU = config.rhoUCandidates(:);
selection.stageA = stageA;
selection.stageBExecuted = stageBExecuted;
selection.stageB = stageB;
selection.selectedStage = activeStage.name;
selection.lqiCandidateTable = allCandidateTable;
selection.selectedIndex = selectedIndex;
selection.designs = allDesigns;
selection.evaluations = allEvaluations;
selection.oneDofEvaluations = allOneDofEvaluations;
selection.admissibleIndices = find(allCandidateTable.FundamentalPass);

if ~isempty(selectedIndex)
    selectedDesign = allDesigns{selectedIndex};
    selectedEvaluation = allEvaluations{selectedIndex};
    selectedOneDofEvaluation = allOneDofEvaluations{selectedIndex};
    selection.selectedRow = allCandidateTable(selectedIndex, :);
    selection.Aaug = selectedDesign.Aaug;
    selection.Baug = selectedDesign.Baug;
    selection.Qaug = selectedDesign.Qaug;
    selection.R = selectedDesign.R;
    selection.Kaug = selectedDesign.Kaug;
    selection.Kx = selectedDesign.Kx;
    selection.Ki = selectedDesign.Ki;
    selection.Nff = activeStage.nff{activeStage.selectedLocalIndex};
    selection.servoPoles = selectedDesign.servoPoles;
    selection.xiScale = selectedDesign.xiScale;
    selection.structural = selectedDesign.structural;
    selection.selectedEvaluation = selectedEvaluation;
    selection.selectedOneDofEvaluation = selectedOneDofEvaluation;
end
end

function gridResult = localEvaluateGrid(m3Data, m5Data, m6Data, ...
    config, wiGrid, rhoGrid, stageName, prefix, indexOffset)
wiGrid = wiGrid(:);
rhoGrid = rhoGrid(:);
candidateCount = numel(wiGrid) * numel(rhoGrid);
rows = repmat(localEmptyRow, candidateCount, 1);
evaluations = cell(candidateCount, 1);
oneDofEvaluations = cell(candidateCount, 1);
designs = cell(candidateCount, 1);
nffValues = cell(candidateCount, 1);

localIndex = 0;
for wiIndex = 1:numel(wiGrid)
    for rhoIndex = 1:numel(rhoGrid)
        localIndex = localIndex + 1;
        design = build_lqi_augmented_cost(m3Data, m5Data, m6Data, ...
            wiGrid(wiIndex), rhoGrid(rhoIndex));
        [Nff, feedforward] = localBuildFeedforward( ...
            m3Data, design.Kx, config);
        oneDofEvaluation = localEvaluateCandidate( ...
            m3Data, m5Data, design, zeros(2), config);
        evaluation = localEvaluateCandidate( ...
            m3Data, m5Data, design, Nff, config);

        designs{localIndex} = design;
        nffValues{localIndex} = Nff;
        evaluations{localIndex} = evaluation;
        oneDofEvaluations{localIndex} = oneDofEvaluation;

        row = localEmptyRow;
        row.CandidateIndex = indexOffset + localIndex;
        row.Candidate = sprintf('%s%02d', prefix, localIndex);
        row.Stage = stageName;
        row.Wi = design.wi;
        row.RhoU = design.rhoU;
        row.Nff11 = Nff(1, 1);
        row.Nff12 = Nff(1, 2);
        row.Nff21 = Nff(2, 1);
        row.Nff22 = Nff(2, 2);
        row.GdcCondition = feedforward.condition;
        row.FeedforwardResidual = feedforward.residual;
        row.FeedforwardWellConditioned = feedforward.wellConditioned;
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
        row.PeakXi = evaluation.summary.worstPeakXi;
        row.NormKx = norm(design.Kx, 'fro');
        row.NormKi = norm(design.Ki, 'fro');
        row.NormNff = norm(Nff, 'fro');
        [~, dominantPoleIndex] = max(real(design.servoPoles));
        row.DominantRealPart = real(design.servoPoles(dominantPoleIndex));
        row.DominantImaginaryMagnitude = abs(imag( ...
            design.servoPoles(dominantPoleIndex)));
        row.WorstDisturbancePeakQ = ...
            evaluation.summary.worstDisturbancePeakQ;
        row.WorstDisturbanceSettlingTime = ...
            evaluation.summary.worstDisturbanceSettlingTime;
        row.WorstDisturbanceSteadyStateOffset = ...
            evaluation.summary.worstDisturbanceSteadyStateOffset;
        row.WorstDisturbanceCrossCouplingPeakRatio = ...
            evaluation.summary.worstDisturbanceCrossCouplingPeakRatio;
        row.WindupIndicator = evaluation.summary.windupIndicator;
        row.OneDofWorstSettlingTime = ...
            oneDofEvaluation.summary.worstSettlingTime;
        row.OneDofWorstOvershoot = ...
            oneDofEvaluation.summary.worstOvershoot;
        row.OneDofPeakU = oneDofEvaluation.summary.worstPeakControl;
        row.OneDofPeakXi = oneDofEvaluation.summary.worstPeakXi;
        row.OneDofDisturbanceOffset = ...
            oneDofEvaluation.summary.worstDisturbanceSteadyStateOffset;
        row.DisturbanceOffsetNffDifference = max(abs( ...
            evaluation.disturbanceMetrics.SteadyStateOffset - ...
            oneDofEvaluation.disturbanceMetrics.SteadyStateOffset));
        row.TrackingPass = evaluation.summary.trackingPass;
        row.DisturbancePass = evaluation.summary.disturbancePass;
        row.FundamentalPass = evaluation.summary.fundamentalPass && ...
            feedforward.wellConditioned;
        rows(localIndex) = row;
    end
end

candidateTable = struct2table(rows);
candidateTable.Selected = false(candidateCount, 1);
candidateTable.Ranking = NaN(candidateCount, 1);
admissibleLocalIndices = find(candidateTable.FundamentalPass);
selectedLocalIndex = [];
if ~isempty(admissibleLocalIndices)
    ranked = sortrows(candidateTable(admissibleLocalIndices, :), ...
        {'PeakUNormalized', 'PeakDeltaNormalized', ...
        'WorstDisturbanceSettlingTime', 'NormKi', 'NormNff', ...
        'RhoU', 'CandidateIndex'}, ...
        {'ascend', 'ascend', 'ascend', 'ascend', 'ascend', ...
        'descend', 'ascend'});
    ranked.Ranking = (1:height(ranked)).';
    for rankIndex = 1:height(ranked)
        originalIndex = find(candidateTable.CandidateIndex == ...
            ranked.CandidateIndex(rankIndex), 1);
        candidateTable.Ranking(originalIndex) = rankIndex;
    end
    selectedLocalIndex = find(candidateTable.CandidateIndex == ...
        ranked.CandidateIndex(1), 1);
    candidateTable.Selected(selectedLocalIndex) = true;
end

gridResult.name = stageName;
gridResult.grid.wi = wiGrid;
gridResult.grid.rhoU = rhoGrid;
gridResult.candidateTable = candidateTable;
gridResult.selectedLocalIndex = selectedLocalIndex;
gridResult.admissibleLocalIndices = admissibleLocalIndices;
gridResult.designs = designs;
gridResult.nff = nffValues;
gridResult.evaluations = evaluations;
gridResult.oneDofEvaluations = oneDofEvaluations;
end

function [Nff, info] = localBuildFeedforward(m3Data, Kx, config)
A = m3Data.Afull;
B = m3Data.Bfull;
Cq = m3Data.CfullQ;
AclX = A - B * Kx;
GdcX = dcgain(ss(AclX, B, Cq, zeros(2)));
Nff = GdcX \ eye(2);
info.GdcX = GdcX;
info.condition = cond(GdcX);
info.residual = norm(GdcX * Nff - eye(2), 'fro');
info.wellConditioned = all(isfinite(Nff), 'all') && ...
    info.condition <= config.feedforwardConditionWarning && ...
    info.residual <= config.feedforwardResidualTolerance;
end

function row = localEmptyRow
row = struct('CandidateIndex', 0, 'Candidate', '', 'Stage', "", ...
    'Wi', NaN, 'RhoU', NaN, 'Nff11', NaN, 'Nff12', NaN, ...
    'Nff21', NaN, 'Nff22', NaN, 'GdcCondition', NaN, ...
    'FeedforwardResidual', NaN, 'FeedforwardWellConditioned', false, ...
    'Stable', false, 'WorstSettlingTime', NaN, ...
    'WorstOvershoot', NaN, 'WorstSteadyStateErrorRelative', NaN, ...
    'WorstCrossCouplingPeakRatio', NaN, 'PeakU', NaN, ...
    'PeakUNormalized', NaN, 'PeakDelta', NaN, ...
    'PeakDeltaNormalized', NaN, 'PeakElasticTorque', NaN, ...
    'PeakXi', NaN, 'NormKx', NaN, 'NormKi', NaN, 'NormNff', NaN, ...
    'DominantRealPart', NaN, 'DominantImaginaryMagnitude', NaN, ...
    'WorstDisturbancePeakQ', NaN, ...
    'WorstDisturbanceSettlingTime', NaN, ...
    'WorstDisturbanceSteadyStateOffset', NaN, ...
    'WorstDisturbanceCrossCouplingPeakRatio', NaN, ...
    'WindupIndicator', NaN, 'OneDofWorstSettlingTime', NaN, ...
    'OneDofWorstOvershoot', NaN, 'OneDofPeakU', NaN, ...
    'OneDofPeakXi', NaN, 'OneDofDisturbanceOffset', NaN, ...
    'DisturbanceOffsetNffDifference', NaN, 'TrackingPass', false, ...
    'DisturbancePass', false, 'FundamentalPass', false);
end

function evaluation = localEvaluateCandidate( ...
    m3Data, m5Data, design, Nff, config)
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
Bcl = [B * Nff, Bd; eye(2), zeros(2)];
Ccl = [Cq, zeros(2); Ctheta, zeros(2); ...
    -Kx, -Ki; zeros(2, n), eye(2)];
Dcl = [zeros(4, 4); Nff, zeros(2); zeros(2, 4)];
closedLoop = ss(Acl, Bcl, Ccl, Dcl, ...
    'InputName', {'r1', 'r2', 'd1', 'd2'}, ...
    'OutputName', {'q1', 'q2', 'theta1', 'theta2', ...
    'u1', 'u2', 'xi1', 'xi2'});

spec = m5Data.spec;
referenceTime = (0:config.simulationTimeStep:config.referenceHorizon).';
disturbanceTime = ...
    (0:config.simulationTimeStep:config.disturbanceHorizon).';
tracking = zeros(2, 6);
disturbance = zeros(2, 6);
referenceOutput = cell(2, 1);
disturbanceOutput = cell(2, 1);
peakDelta = zeros(2, 1);
peakElasticTorque = zeros(2, 1);
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

    input = zeros(numel(disturbanceTime), 4);
    input(:, jointIndex + 2) = spec.disturbanceTorqueAmplitude;
    output = lsim(closedLoop, input, disturbanceTime);
    disturbanceOutput{jointIndex} = output;
    q = output(:, 1:2);
    u = output(:, 5:6);
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
    disturbance(jointIndex, 5) = max(abs(u), [], 'all');
    disturbance(jointIndex, 6) = max(abs(xi), [], 'all');
end

trackingMetrics = array2table([(1:2).', tracking], ...
    'VariableNames', {'ReferenceJoint', 'SettlingTime', 'Overshoot', ...
    'SteadyStateErrorRelative', 'CrossCouplingPeakRatio', ...
    'PeakControl', 'PeakXi'});
disturbanceMetrics = array2table([(1:2).', disturbance], ...
    'VariableNames', {'DisturbanceJoint', 'PeakQ', ...
    'SteadyStateOffset', 'SettlingTime', ...
    'CrossCouplingPeakRatio', 'PeakControl', 'PeakXi'});

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
worstPeakXi = max([trackingMetrics.PeakXi; disturbanceMetrics.PeakXi]);

evaluation.Nff = Nff;
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
evaluation.summary.worstPeakXi = worstPeakXi;
evaluation.summary.worstDisturbancePeakQ = ...
    max(disturbanceMetrics.PeakQ);
evaluation.summary.worstDisturbanceSettlingTime = ...
    max(disturbanceMetrics.SettlingTime);
evaluation.summary.worstDisturbanceSteadyStateOffset = ...
    max(abs(disturbanceMetrics.SteadyStateOffset));
evaluation.summary.worstDisturbanceCrossCouplingPeakRatio = ...
    max(disturbanceMetrics.CrossCouplingPeakRatio);
evaluation.summary.worstDisturbancePeakControl = ...
    max(disturbanceMetrics.PeakControl);
evaluation.summary.windupIndicator = worstPeakXi / design.xiScale;
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
