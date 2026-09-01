function config = lqg_specs_m6
%LQG_SPECS_M6 Approved, physically normalized LQG design data.
%   The controller is intentionally defined by one explicit LQR cost and
%   one explicit covariance model. No candidate grid or ranking is used.

% Dimensionless corrections to Bryson-style physical normalization.
config.lqr.wq = 1;
config.lqr.wqdot = 0.5;
config.lqr.wdelta = 0.1;
config.lqr.wthetaDot = 0.5;
config.lqr.rhoU = 8;
config.lqr.rationale = [ ...
    "state scales come from reference, bandwidth and SEA deformation"; ...
    "velocity weights 0.5 avoid excessive damping demand"; ...
    "deformation weight 0.1 avoids over-penalizing compliant motion"; ...
    "rhoU=8 keeps the nominal command below its performance scale"];

% Standard deviations used to form Qn and Rn directly.
config.kalman.sigmaLinkDisturbance = 0.1;
config.kalman.sigmaInputModel = 0.1;
config.kalman.sigmaMeasurementDeg = 0.05;
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
