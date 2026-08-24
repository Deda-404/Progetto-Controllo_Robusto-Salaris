function selection = retune_lqi_augmented_cost_m7( ...
    m3Data, m5Data, m6Data, config)
%RETUNE_LQI_AUGMENTED_COST_M7 Run the authorized staged M7 co-tuning.
%   Stage C1 contains exactly 75 candidates. Stage C2 expands at most five
%   promising C1 points and Stage C3 is allowed only when C1/C2 contain no
%   admissible design but C2 still contains promising points. No stage
%   beyond C3 exists in this routine.

arguments
    m3Data (1, 1) struct
    m5Data (1, 1) struct
    m6Data (1, 1) struct
    config (1, 1) struct = lqg_specs_m7
end

c1Specs = localBuildC1Specs(config);
stageC1 = localEvaluateSpecs(m3Data, m5Data, m6Data, config, ...
    c1Specs, "Stage C1", "C1", 0);
c1Promising = localRankPromising(stageC1.candidateTable, config);
c1Seeds = c1Promising(1:min(config.maximumPromisingSeeds, ...
    height(c1Promising)), :);

c2Specs = localBuildC2Specs(c1Seeds, config);
stageC2 = localEvaluateSpecs(m3Data, m5Data, m6Data, config, ...
    c2Specs, "Stage C2", "C2", height(stageC1.candidateTable));
c2Promising = localRankPromising(stageC2.candidateTable, config);
c2Seeds = c2Promising(1:min(config.maximumPromisingSeeds, ...
    height(c2Promising)), :);

preC3Table = stageC1.candidateTable;
if ~isempty(stageC2.candidateTable)
    preC3Table = [preC3Table; stageC2.candidateTable];
end
c3Necessary = ~any(preC3Table.FundamentalPass) && ~isempty(c2Seeds);
if c3Necessary
    c3Specs = localBuildC3Specs(c2Seeds, config);
else
    c3Specs = localEmptySpecs;
end
stageC3 = localEvaluateSpecs(m3Data, m5Data, m6Data, config, ...
    c3Specs, "Stage C3", "C3", height(preC3Table));

allCandidateTable = preC3Table;
if ~isempty(stageC3.candidateTable)
    allCandidateTable = [allCandidateTable; stageC3.candidateTable];
end
allDesigns = [stageC1.designs; stageC2.designs; stageC3.designs];
allEvaluations = [stageC1.evaluations; stageC2.evaluations; ...
    stageC3.evaluations];
allNff = [stageC1.nff; stageC2.nff; stageC3.nff];

allCandidateTable.Selected = false(height(allCandidateTable), 1);
allCandidateTable.Ranking = NaN(height(allCandidateTable), 1);
admissibleIndices = find(allCandidateTable.FundamentalPass);
selectedIndex = [];
if ~isempty(admissibleIndices)
    ranked = sortrows(allCandidateTable(admissibleIndices, :), ...
        {'PeakUNormalized', 'PeakDeltaNormalized', 'WorstOvershoot', ...
        'WorstDisturbanceSettlingTime', 'NormKi', 'NormKx', ...
        'CandidateIndex'}, repmat({'ascend'}, 1, 7));
    for rankIndex = 1:height(ranked)
        originalIndex = find(allCandidateTable.CandidateIndex == ...
            ranked.CandidateIndex(rankIndex), 1);
        allCandidateTable.Ranking(originalIndex) = rankIndex;
    end
    selectedIndex = find(allCandidateTable.CandidateIndex == ...
        ranked.CandidateIndex(1), 1);
    allCandidateTable.Selected(selectedIndex) = true;
end

stageC1.candidateTable = localPropagateSelection( ...
    stageC1.candidateTable, allCandidateTable);
stageC2.candidateTable = localPropagateSelection( ...
    stageC2.candidateTable, allCandidateTable);
stageC3.candidateTable = localPropagateSelection( ...
    stageC3.candidateTable, allCandidateTable);

selection.stageC1 = stageC1;
selection.stageC2 = stageC2;
selection.stageC3 = stageC3;
selection.stageC2Executed = ~isempty(c2Specs);
selection.stageC3Necessary = c3Necessary;
selection.stageC3Executed = ~isempty(c3Specs);
selection.c1PromisingTable = c1Promising;
selection.c1SeedTable = c1Seeds;
selection.c2PromisingTable = c2Promising;
selection.c2SeedTable = c2Seeds;
selection.allCandidateTable = allCandidateTable;
selection.designs = allDesigns;
selection.evaluations = allEvaluations;
selection.nff = allNff;
selection.admissibleIndices = admissibleIndices;
selection.selectedIndex = selectedIndex;
selection.paretoC1Table = localPareto(stageC1.candidateTable);
selection.paretoAllTable = localPareto(allCandidateTable);
selection.bestC1SettlingRow = localBestRow(stageC1.candidateTable, ...
    {'WorstSettlingTime', 'WorstOvershoot', 'CandidateIndex'});
selection.bestC1OvershootRow = localBestOvershootRow( ...
    stageC1.candidateTable);
selection.bestSettlingWithOvershootTargetRow = ...
    localBestWithOvershootTarget(allCandidateTable, config);
selection.minimumOvershootRow = localBestOvershootRow(allCandidateTable);
selection.bestOvershootNearSettlingTargetRow = ...
    localBestNearSettlingTarget(allCandidateTable, config);
selection.searchStages = ["Stage C1"; "Stage C2"; "Stage C3"];
selection.noSearchBeyondC3 = true;

if ~isempty(selectedIndex)
    selection.selectedRow = allCandidateTable(selectedIndex, :);
    selection.selectedDesign = allDesigns{selectedIndex};
    selection.selectedEvaluation = allEvaluations{selectedIndex};
    selection.Nff = allNff{selectedIndex};
    selection.Kx = selection.selectedDesign.Kx;
    selection.Ki = selection.selectedDesign.Ki;
end
end

function specs = localBuildC1Specs(config)
count = numel(config.stageC1.wq) * numel(config.stageC1.wi) * ...
    numel(config.stageC1.rhoU);
rows = repmat(localEmptySpecRow, count, 1);
index = 0;
for wq = config.stageC1.wq(:).'
    for wi = config.stageC1.wi(:).'
        for rhoU = config.stageC1.rhoU(:).'
            index = index + 1;
            rows(index) = localSpecRow("", wq, ...
                config.stageC1.wqdot, config.stageC1.wdelta, ...
                config.stageC1.wthetaDot, wi, rhoU);
        end
    end
end
specs = struct2table(rows);
end

function specs = localBuildC2Specs(seeds, config)
if isempty(seeds)
    specs = localEmptySpecs;
    return
end
count = height(seeds) * numel(config.stageC2.wVelocity);
rows = repmat(localEmptySpecRow, count, 1);
index = 0;
for seedIndex = 1:height(seeds)
    for wVelocity = config.stageC2.wVelocity(:).'
        index = index + 1;
        rows(index) = localSpecRow(seeds.Candidate(seedIndex), ...
            seeds.Wq(seedIndex), wVelocity, ...
            config.stageC1.wdelta, wVelocity, ...
            seeds.Wi(seedIndex), seeds.RhoU(seedIndex));
    end
end
specs = struct2table(rows);
end

function specs = localBuildC3Specs(seeds, config)
count = height(seeds) * numel(config.stageC3.wdelta);
rows = repmat(localEmptySpecRow, count, 1);
index = 0;
for seedIndex = 1:height(seeds)
    for wdelta = config.stageC3.wdelta(:).'
        index = index + 1;
        rows(index) = localSpecRow(seeds.Candidate(seedIndex), ...
            seeds.Wq(seedIndex), seeds.Wqdot(seedIndex), wdelta, ...
            seeds.WthetaDot(seedIndex), seeds.Wi(seedIndex), ...
            seeds.RhoU(seedIndex));
    end
end
specs = struct2table(rows);
end

function result = localEvaluateSpecs(m3Data, m5Data, m6Data, config, ...
    specs, stageName, prefix, indexOffset)
count = height(specs);
rows = repmat(localEmptyCandidateRow, count, 1);
designs = cell(count, 1);
evaluations = cell(count, 1);
nffValues = cell(count, 1);
for localIndex = 1:count
    priorities = struct('wq', specs.Wq(localIndex), ...
        'wqdot', specs.Wqdot(localIndex), ...
        'wdelta', specs.Wdelta(localIndex), ...
        'wthetaDot', specs.WthetaDot(localIndex));
    design = build_lqi_augmented_cost(m3Data, m5Data, m6Data, ...
        specs.Wi(localIndex), specs.RhoU(localIndex), priorities);
    [Nff, feedforward] = build_lqi_reference_feedforward( ...
        m3Data, design.Kx, config);
    evaluation = evaluate_lqi_2dof_candidate( ...
        m3Data, m5Data, design, Nff, config);
    designs{localIndex} = design;
    evaluations{localIndex} = evaluation;
    nffValues{localIndex} = Nff;
    rows(localIndex) = localBuildCandidateRow(specs(localIndex, :), ...
        stageName, prefix, indexOffset + localIndex, design, ...
        evaluation, Nff, feedforward, m5Data.spec, config);
end
if count == 0
    candidateTable = struct2table(repmat(localEmptyCandidateRow, 0, 1));
else
    candidateTable = struct2table(rows);
end
result.name = stageName;
result.specs = specs;
result.candidateTable = candidateTable;
result.designs = designs;
result.evaluations = evaluations;
result.nff = nffValues;
end

function row = localBuildCandidateRow(spec, stageName, prefix, ...
    candidateIndex, design, evaluation, Nff, feedforward, m5Spec, config)
tracking = evaluation.trackingMetrics;
disturbance = evaluation.disturbanceMetrics;
summary = evaluation.summary;
dominantPoles = design.servoPoles;
[~, dominantIndex] = max(real(dominantPoles));
dominantPole = dominantPoles(dominantIndex);
if abs(dominantPole) > eps
    dominantDamping = -real(dominantPole) / abs(dominantPole);
else
    dominantDamping = NaN;
end

row = localEmptyCandidateRow;
row.CandidateIndex = candidateIndex;
row.Candidate = string(sprintf('%s%02d', prefix, candidateIndex));
row.Stage = stageName;
row.ParentCandidate = spec.ParentCandidate;
row.Wq = spec.Wq;
row.Wqdot = spec.Wqdot;
row.Wdelta = spec.Wdelta;
row.WthetaDot = spec.WthetaDot;
row.Wi = spec.Wi;
row.RhoU = spec.RhoU;
row.Stable = summary.stable;
row.SettlingR1 = tracking.SettlingTime(1);
row.SettlingR2 = tracking.SettlingTime(2);
row.WorstSettlingTime = summary.worstSettlingTime;
row.OvershootR1 = tracking.Overshoot(1);
row.OvershootR2 = tracking.Overshoot(2);
row.WorstOvershoot = summary.worstOvershoot;
row.SteadyStateErrorR1 = tracking.SteadyStateErrorRelative(1);
row.SteadyStateErrorR2 = tracking.SteadyStateErrorRelative(2);
row.WorstSteadyStateErrorRelative = ...
    summary.worstSteadyStateErrorRelative;
row.CrossCouplingR1 = tracking.CrossCouplingPeakRatio(1);
row.CrossCouplingR2 = tracking.CrossCouplingPeakRatio(2);
row.WorstCrossCouplingPeakRatio = summary.worstCrossCouplingPeakRatio;
row.PeakU = summary.worstPeakControl;
row.PeakUNormalized = summary.peakControlNormalized;
row.PeakDelta = summary.worstPeakDeformation;
row.PeakDeltaNormalized = summary.peakDeformationNormalized;
row.PeakElasticTorque = summary.worstPeakElasticTorque;
row.PeakXi = summary.worstPeakXi;
row.NormKx = norm(design.Kx, 'fro');
row.NormKi = norm(design.Ki, 'fro');
row.NormNff = norm(Nff, 'fro');
row.Nff11 = Nff(1, 1);
row.Nff12 = Nff(1, 2);
row.Nff21 = Nff(2, 1);
row.Nff22 = Nff(2, 2);
row.GdcCondition = feedforward.condition;
row.FeedforwardResidual = feedforward.residual;
row.FeedforwardWellConditioned = feedforward.wellConditioned;
row.DominantPole = dominantPole;
row.DominantRealPart = real(dominantPole);
row.DominantImaginaryMagnitude = abs(imag(dominantPole));
row.DominantDampingRatio = dominantDamping;
row.DisturbanceOffsetD1 = abs(disturbance.SteadyStateOffset(1));
row.DisturbanceOffsetD2 = abs(disturbance.SteadyStateOffset(2));
row.WorstDisturbanceSteadyStateOffset = ...
    summary.worstDisturbanceSteadyStateOffset;
row.DisturbanceSettlingD1 = disturbance.SettlingTime(1);
row.DisturbanceSettlingD2 = disturbance.SettlingTime(2);
row.WorstDisturbanceSettlingTime = ...
    summary.worstDisturbanceSettlingTime;
row.Jdiag = max(summary.worstSettlingTime / ...
    config.diagnosticSettlingTarget, summary.worstOvershoot / ...
    config.diagnosticOvershootTarget);
row.Promising = summary.stable && (summary.worstSettlingTime <= ...
    config.promisingSettlingTime || (summary.worstOvershoot <= ...
    config.promisingOvershoot && summary.worstSettlingTime <= ...
    config.promisingSettlingWithLowOvershoot));
row.CrossCouplingDiagnosticPass = ...
    summary.worstCrossCouplingPeakRatio <= m5Spec.crossCouplingTarget;
row.TrackingPass = summary.trackingPass;
row.DisturbancePass = summary.disturbancePass;
row.FundamentalPass = summary.fundamentalPass && ...
    feedforward.wellConditioned;
if row.PeakUNormalized <= config.controlEffortModerateThreshold
    row.ControlCategory = "moderato";
elseif row.PeakUNormalized <= config.controlEffortAggressiveThreshold
    row.ControlCategory = "elevato";
else
    row.ControlCategory = "molto aggressivo";
end
end

function ranked = localRankPromising(candidateTable, config)
if isempty(candidateTable)
    ranked = candidateTable;
    return
end
mask = candidateTable.Stable & (candidateTable.WorstSettlingTime <= ...
    config.promisingSettlingTime | (candidateTable.WorstOvershoot <= ...
    config.promisingOvershoot & candidateTable.WorstSettlingTime <= ...
    config.promisingSettlingWithLowOvershoot));
ranked = sortrows(candidateTable(mask, :), ...
    {'Jdiag', 'WorstSettlingTime', 'WorstOvershoot', ...
    'PeakUNormalized', 'CandidateIndex'}, repmat({'ascend'}, 1, 5));
end

function paretoTable = localPareto(candidateTable)
candidateTable = candidateTable(candidateTable.Stable & ...
    isfinite(candidateTable.WorstSettlingTime) & ...
    isfinite(candidateTable.WorstOvershoot), :);
isPareto = true(height(candidateTable), 1);
for candidateIndex = 1:height(candidateTable)
    dominates = candidateTable.WorstSettlingTime <= ...
        candidateTable.WorstSettlingTime(candidateIndex) & ...
        candidateTable.WorstOvershoot <= ...
        candidateTable.WorstOvershoot(candidateIndex) & ...
        (candidateTable.WorstSettlingTime < ...
        candidateTable.WorstSettlingTime(candidateIndex) | ...
        candidateTable.WorstOvershoot < ...
        candidateTable.WorstOvershoot(candidateIndex));
    dominates(candidateIndex) = false;
    isPareto(candidateIndex) = ~any(dominates);
end
paretoTable = sortrows(candidateTable(isPareto, :), ...
    {'WorstSettlingTime', 'WorstOvershoot', 'CandidateIndex'}, ...
    {'ascend', 'ascend', 'ascend'});
end

function row = localBestRow(candidateTable, variables)
candidateTable = candidateTable(candidateTable.Stable & ...
    isfinite(candidateTable.WorstSettlingTime) & ...
    isfinite(candidateTable.WorstOvershoot), :);
if isempty(candidateTable)
    row = candidateTable;
else
    directions = repmat({'ascend'}, 1, numel(variables));
    candidateTable = sortrows(candidateTable, variables, directions);
    row = candidateTable(1, :);
end
end

function row = localBestNearSettlingTarget(candidateTable, config)
candidateTable = candidateTable(candidateTable.Stable & ...
    isfinite(candidateTable.WorstSettlingTime) & ...
    isfinite(candidateTable.WorstOvershoot), :);
if isempty(candidateTable)
    row = candidateTable;
    return
end
candidateTable.SettlingTargetDistance = abs( ...
    candidateTable.WorstSettlingTime - config.diagnosticSettlingTarget);
candidateTable = sortrows(candidateTable, ...
    {'SettlingTargetDistance', 'WorstOvershoot', 'PeakUNormalized', ...
    'CandidateIndex'}, repmat({'ascend'}, 1, 4));
row = removevars(candidateTable(1, :), 'SettlingTargetDistance');
end

function row = localBestWithOvershootTarget(candidateTable, config)
candidateTable = candidateTable(candidateTable.Stable & ...
    isfinite(candidateTable.WorstOvershoot) & ...
    candidateTable.WorstOvershoot <= ...
    config.diagnosticOvershootTarget, :);
if isempty(candidateTable)
    row = candidateTable;
else
    candidateTable = sortrows(candidateTable, ...
        {'WorstSettlingTime', 'WorstOvershoot', 'CandidateIndex'}, ...
        {'ascend', 'ascend', 'ascend'});
    row = candidateTable(1, :);
end
end

function row = localBestOvershootRow(candidateTable)
candidateTable = candidateTable(candidateTable.Stable & ...
    isfinite(candidateTable.WorstOvershoot), :);
if isempty(candidateTable)
    row = candidateTable;
else
    candidateTable = sortrows(candidateTable, ...
        {'WorstOvershoot', 'WorstSettlingTime', 'CandidateIndex'}, ...
        {'ascend', 'ascend', 'ascend'});
    row = candidateTable(1, :);
end
end

function tableData = localPropagateSelection(tableData, allTable)
for rowIndex = 1:height(tableData)
    sourceIndex = find(allTable.CandidateIndex == ...
        tableData.CandidateIndex(rowIndex), 1);
    tableData.Selected(rowIndex) = allTable.Selected(sourceIndex);
    tableData.Ranking(rowIndex) = allTable.Ranking(sourceIndex);
end
end

function specs = localEmptySpecs
specs = struct2table(repmat(localEmptySpecRow, 0, 1));
end

function row = localSpecRow(parent, wq, wqdot, wdelta, wthetaDot, wi, rhoU)
row = localEmptySpecRow;
row.ParentCandidate = string(parent);
row.Wq = wq;
row.Wqdot = wqdot;
row.Wdelta = wdelta;
row.WthetaDot = wthetaDot;
row.Wi = wi;
row.RhoU = rhoU;
end

function row = localEmptySpecRow
row = struct('ParentCandidate', "", 'Wq', NaN, 'Wqdot', NaN, ...
    'Wdelta', NaN, 'WthetaDot', NaN, 'Wi', NaN, 'RhoU', NaN);
end

function row = localEmptyCandidateRow
row = struct('CandidateIndex', 0, 'Candidate', "", 'Stage', "", ...
    'ParentCandidate', "", 'Wq', NaN, 'Wqdot', NaN, ...
    'Wdelta', NaN, 'WthetaDot', NaN, 'Wi', NaN, 'RhoU', NaN, ...
    'Stable', false, 'SettlingR1', NaN, 'SettlingR2', NaN, ...
    'WorstSettlingTime', NaN, 'OvershootR1', NaN, ...
    'OvershootR2', NaN, 'WorstOvershoot', NaN, ...
    'SteadyStateErrorR1', NaN, 'SteadyStateErrorR2', NaN, ...
    'WorstSteadyStateErrorRelative', NaN, 'CrossCouplingR1', NaN, ...
    'CrossCouplingR2', NaN, 'WorstCrossCouplingPeakRatio', NaN, ...
    'PeakU', NaN, 'PeakUNormalized', NaN, 'PeakDelta', NaN, ...
    'PeakDeltaNormalized', NaN, 'PeakElasticTorque', NaN, ...
    'PeakXi', NaN, 'NormKx', NaN, 'NormKi', NaN, 'NormNff', NaN, ...
    'Nff11', NaN, 'Nff12', NaN, 'Nff21', NaN, 'Nff22', NaN, ...
    'GdcCondition', NaN, 'FeedforwardResidual', NaN, ...
    'FeedforwardWellConditioned', false, 'DominantPole', NaN, ...
    'DominantRealPart', NaN, 'DominantImaginaryMagnitude', NaN, ...
    'DominantDampingRatio', NaN, 'DisturbanceOffsetD1', NaN, ...
    'DisturbanceOffsetD2', NaN, ...
    'WorstDisturbanceSteadyStateOffset', NaN, ...
    'DisturbanceSettlingD1', NaN, 'DisturbanceSettlingD2', NaN, ...
    'WorstDisturbanceSettlingTime', NaN, 'Jdiag', NaN, ...
    'Promising', false, 'ControlCategory', "", ...
    'CrossCouplingDiagnosticPass', false, 'TrackingPass', false, ...
    'DisturbancePass', false, 'FundamentalPass', false, ...
    'Selected', false, 'Ranking', NaN);
end
