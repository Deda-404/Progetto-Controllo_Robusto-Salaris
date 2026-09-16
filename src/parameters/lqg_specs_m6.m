function config = lqg_specs_m6
%LQG_SPECS_M6 Limited and interpretable LQG design data.
%   Physical scales make unlike state variables comparable. The final LQR
%   weights are then selected by a small, reproducible parametric search;
%   the scales themselves are not used as a controller-selection rule.

% The four factors have a direct physical interpretation. A full factorial
% combination gives 3*2*2*3 = 36 candidates: enough to show the trade-off,
% but still small enough to inspect and explain during an oral exam.
config.lqr.candidates.position = [0.5; 1; 2];
config.lqr.candidates.velocity = [0.5; 1];
config.lqr.candidates.deformation = [0.1; 0.5];
% ru pesa direttamente il comando fisico: R=ru*I2. Tre valori positivi
% rappresentano penalizzazioni bassa, intermedia e alta, non limiti hardware.
% La griglia cambia il problema LQR e richiede una nuova selezione numerica.
config.lqr.candidates.control = [0.01; 0.05; 0.10];
config.lqr.expectedCandidateCount = 36;
config.lqr.rationale = [ ...
    "position 0.5/1/2: moderate changes around the 5 deg tracking scale"; ...
    "velocity 0.5/1: damping is important without dominating position"; ...
    "deformation 0.1/0.5: compliant travel is allowed but not ignored"; ...
    "ru=0.01,0.05,0.10: direct effort penalties, from less to more restrictive"];

% Equal-status, dimensionless terms used only after mandatory admissibility.
% The weights sum to one and keep the compromise score transparent.
config.lqr.score.settling = 0.30;
config.lqr.score.overshoot = 0.20;
config.lqr.score.steadyState = 0.10;
config.lqr.score.crossCoupling = 0.10;
config.lqr.score.peakControl = 0.15;
config.lqr.score.rmsControl = 0.15;

% Standard deviations used to form Qn and Rn directly.
config.kalman.sigmaLinkDisturbance = 0.1;
config.kalman.sigmaInputModel = 0.1;
config.kalman.sigmaMeasurementDeg = 0.05;
config.kalman.sensitivityMeasurementDeg = [0.025; 0.05; 0.10];
config.kalman.rationale = [ ...
    "0.1 N m process channels represent unmodeled link/input torques"; ...
    "0.05 deg represents the assumed encoder-noise scale"; ...
    "larger Qn/Rn produces a faster estimator; smaller Qn/Rn a slower one"];

config.noiseSeed = 20260826;
config.referenceHorizon = 3.0;
config.disturbanceHorizon = 4.0;
config.noiseHorizon = 4.0;
config.simulationTimeStep = 0.002;
config.settlingBandFraction = 0.02;
config.numericStabilityTolerance = 1e-8;
config.controlEffortModerateThreshold = 1;
end
