function design = design_kalman_m6(m3Data, m5Data, lqrDesign, config)
%DESIGN_KALMAN_M6 Kalman da ipotesi progettuali, non dati del docente.
% sigma_d=sigma_u=0.1 N m e sigma_y=0.05 deg sono scelte del progetto,
% non valori identificati sperimentalmente. Qn/Rn sono le intensita del
% modello bianco continuo nella convenzione temporale di riferimento 1 s.
% La prova randn a 2 ms e distinta da una calibrazione di tali intensita.

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
    "project-assumed process and encoder-noise scales; no experimental identification";
end
