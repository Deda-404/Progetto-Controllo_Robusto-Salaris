function design = design_kalman_m6(m3Data, m5Data, lqrDesign, config)
%DESIGN_KALMAN_M6 Build one Kalman filter from declared noise scales.

arguments
    m3Data (1, 1) struct
    m5Data (1, 1) struct
    lqrDesign (1, 1) struct
    config (1, 1) struct = lqg_specs_m6
end

A = m3Data.Afull;
C = m3Data.CfullMeas;
processNoiseInputMatrix = [m5Data.BdFull, m3Data.Bfull];
sigmaD = config.kalman.sigmaLinkDisturbance;
sigmaU = config.kalman.sigmaInputModel;
sigmaYDeg = config.kalman.sigmaMeasurementDeg;
sigmaYRad = deg2rad(sigmaYDeg);
Qn = diag([sigmaD^2, sigmaD^2, sigmaU^2, sigmaU^2]);
Rn = sigmaYRad^2 * eye(4);
L = lqe(A, processNoiseInputMatrix, C, Qn, Rn);
estimatorPoles = eig(A - L * C);
estimatorDecay = min(-real(estimatorPoles));
estimatorSpeedRatio = estimatorDecay / lqrDesign.alphaController;
noiseErrorSystem = ss(A - L * C, -L, lqrDesign.Ccost, ...
    zeros(size(lqrDesign.Ccost, 1), 4));

assert(all(real(estimatorPoles) < -config.numericStabilityTolerance), ...
    'M6Kalman:Unstable', 'The declared Kalman covariance model is unstable.');

design.processNoiseInputMatrix = processNoiseInputMatrix;
design.Qn = Qn;
design.Rn = Rn;
design.L = L;
design.estimatorPoles = estimatorPoles;
design.sigmaD = sigmaD;
design.sigmaU = sigmaU;
design.sigmaYDeg = sigmaYDeg;
design.sigmaYRad = sigmaYRad;
design.estimatorDecay = estimatorDecay;
design.regulatorDecay = lqrDesign.alphaController;
design.estimatorSpeedRatio = estimatorSpeedRatio;
design.gainFrobeniusNorm = norm(L, 'fro');
design.h2NoiseAmplification = norm(noiseErrorSystem, 2);
design.method = ...
    "declared process and encoder-noise standard deviations; no grid search";
end
