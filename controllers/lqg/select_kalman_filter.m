function selection = select_kalman_filter( ...
    m3Data, m5Data, lqrSelection, config)
%SELECT_KALMAN_FILTER Select M6 estimator from physically scaled candidates.

arguments
    m3Data (1, 1) struct
    m5Data (1, 1) struct
    lqrSelection (1, 1) struct
    config (1, 1) struct = lqg_specs_m6
end

assert(isfield(lqrSelection, 'K') && ...
    ~isempty(lqrSelection.selectedIndex), ...
    'M6Kalman:LQRNotSelected', ...
    'Kalman tuning is forbidden until an admissible LQR is selected.');

A = m3Data.Afull;
B = m3Data.Bfull;
C = m3Data.CfullMeas;
processNoiseInputMatrix = [m5Data.BdFull, B];

[sigmaDGrid, sigmaUGrid, sigmaYGrid] = ndgrid( ...
    config.processDisturbanceSigmas(:), ...
    config.processInputSigmas(:), ...
    config.measurementNoiseSigmasDeg(:));
sigmaD = sigmaDGrid(:);
sigmaU = sigmaUGrid(:);
sigmaYDeg = sigmaYGrid(:);
sigmaYRad = deg2rad(sigmaYDeg);
numberCandidates = numel(sigmaD);
candidate = compose("KF%02d", (1:numberCandidates).');

stable = false(numberCandidates, 1);
estimatorDecay = NaN(numberCandidates, 1);
regulatorDecay = repmat(lqrSelection.alphaController, ...
    numberCandidates, 1);
estimatorSpeedRatio = NaN(numberCandidates, 1);
gainFrobeniusNorm = inf(numberCandidates, 1);
h2NoiseAmplification = inf(numberCandidates, 1);
numericWarning = strings(numberCandidates, 1);
candidateGains = cell(numberCandidates, 1);
candidatePoles = cell(numberCandidates, 1);
candidateQn = cell(numberCandidates, 1);
candidateRn = cell(numberCandidates, 1);

for candidateIndex = 1:numberCandidates
    QnCandidate = diag([ ...
        repmat(sigmaD(candidateIndex)^2, 1, 2), ...
        repmat(sigmaU(candidateIndex)^2, 1, 2)]);
    RnCandidate = sigmaYRad(candidateIndex)^2 * eye(4);
    try
        Lcandidate = lqe(A, processNoiseInputMatrix, C, ...
            QnCandidate, RnCandidate);
        polesCandidate = eig(A - Lcandidate * C);
        stable(candidateIndex) = all(real(polesCandidate) < ...
            -config.numericStabilityTolerance);
        estimatorDecay(candidateIndex) = min(-real(polesCandidate));
        estimatorSpeedRatio(candidateIndex) = ...
            estimatorDecay(candidateIndex) / ...
            regulatorDecay(candidateIndex);
        gainFrobeniusNorm(candidateIndex) = norm(Lcandidate, 'fro');
        noiseErrorSystem = ss(A - Lcandidate * C, -Lcandidate, ...
            lqrSelection.Ccost, zeros(size(lqrSelection.Ccost, 1), 4));
        if stable(candidateIndex)
            h2NoiseAmplification(candidateIndex) = ...
                norm(noiseErrorSystem, 2);
        end
        candidateGains{candidateIndex} = Lcandidate;
        candidatePoles{candidateIndex} = polesCandidate;
        candidateQn{candidateIndex} = QnCandidate;
        candidateRn{candidateIndex} = RnCandidate;
    catch candidateError
        numericWarning(candidateIndex) = string(candidateError.identifier) + ...
            ": " + string(candidateError.message);
    end
end

admissible = stable & estimatorSpeedRatio >= ...
    config.estimatorSpeedRatioMinimum & estimatorSpeedRatio <= ...
    config.estimatorSpeedRatioMaximum & isfinite(h2NoiseAmplification);
rankingMatrix = [~admissible, h2NoiseAmplification, ...
    gainFrobeniusNorm, sigmaD, sigmaU, sigmaYDeg, ...
    (1:numberCandidates).'];
[~, order] = sortrows(rankingMatrix, 1:size(rankingMatrix, 2));
ranking = zeros(numberCandidates, 1);
ranking(order) = (1:numberCandidates).';
selected = false(numberCandidates, 1);
selectedIndex = order(find(admissible(order), 1, 'first'));
if ~isempty(selectedIndex)
    selected(selectedIndex) = true;
end

kalmanCandidateTable = table(candidate, sigmaD, sigmaU, ...
    sigmaYDeg, sigmaYRad, stable, estimatorDecay, regulatorDecay, ...
    estimatorSpeedRatio, gainFrobeniusNorm, h2NoiseAmplification, ...
    numericWarning, admissible, selected, ranking, ...
    'VariableNames', {'Candidate', 'SigmaD', 'SigmaU', ...
    'SigmaYDeg', 'SigmaYRad', 'Stable', 'EstimatorDecay', ...
    'RegulatorDecay', 'EstimatorSpeedRatio', ...
    'GainFrobeniusNorm', 'H2NoiseAmplification', ...
    'NumericWarning', 'Admissible', 'Selected', 'Ranking'});

selection.status = "no admissible Kalman candidate";
selection.processNoiseInputMatrix = processNoiseInputMatrix;
selection.kalmanCandidateTable = kalmanCandidateTable;
selection.candidateGains = candidateGains;
selection.candidatePoles = candidatePoles;
selection.rules = [ ...
    "require stable estimator and speed ratio between 1.5 and 5"; ...
    "minimize continuous H2 measurement-noise amplification"; ...
    "then minimize estimator gain Frobenius norm"; ...
    "use sigmaD, sigmaU, sigmaY and row index as deterministic ties"];
selection.selectedIndex = selectedIndex;
if ~isempty(selectedIndex)
    selection.status = "admissible Kalman candidate selected";
    selection.Qn = candidateQn{selectedIndex};
    selection.Rn = candidateRn{selectedIndex};
    selection.L = candidateGains{selectedIndex};
    selection.estimatorPoles = candidatePoles{selectedIndex};
    selection.sigmaD = sigmaD(selectedIndex);
    selection.sigmaU = sigmaU(selectedIndex);
    selection.sigmaYDeg = sigmaYDeg(selectedIndex);
    selection.sigmaYRad = sigmaYRad(selectedIndex);
    selection.estimatorDecay = estimatorDecay(selectedIndex);
    selection.regulatorDecay = regulatorDecay(selectedIndex);
    selection.estimatorSpeedRatio = ...
        estimatorSpeedRatio(selectedIndex);
    selection.gainFrobeniusNorm = gainFrobeniusNorm(selectedIndex);
    selection.h2NoiseAmplification = ...
        h2NoiseAmplification(selectedIndex);
end
end
