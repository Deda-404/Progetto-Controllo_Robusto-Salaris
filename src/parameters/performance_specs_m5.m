function spec = performance_specs_m5
%PERFORMANCE_SPECS_M5 Single, physically motivated set of design targets.

spec.equilibrium = [pi/2; 0];

spec.referenceAmplitudeScenariosDeg = [2; 5; 8];
spec.referenceAmplitude = deg2rad(5);
spec.disturbanceTorqueScenarios = [0.25; 0.50; 1.00];
spec.disturbanceTorqueAmplitude = 0.50;

spec.omegaB = 12;
% Banda generale e scala di velocita LQR: non dipende dal corner di W1.
spec.omegaW1 = 8;
% Compromesso ID 10 dello studio diretto: non soddisfa tutti i target M5.
spec.bandwidthUnstableMultiplier = 1.5;
spec.bandwidthActuatorFraction = 0.40;
spec.bandwidthElasticFraction = 0.20;

spec.As = 0.15;
spec.Ms = 2.5;

spec.uScale = 12;
% Peso diretto del comando fisico; uScale rimane solo una scala di metrica.
spec.controlWeightGain = 0.05;
spec.omegaU = 60;
spec.controlWeightAlpha = 6;
spec.controlOnsetElasticFraction = 0.50;

spec.settlingTimeTarget = 0.8;
spec.overshootTarget = 10;
spec.steadyStateTrackingTarget = 0.05;
spec.crossCouplingTarget = 0.25;
spec.crossCouplingStatus = "preliminary";

spec.disturbanceLocation = "link-side joint torque";
spec.controlEffortScaleMeaning = ...
    "performance normalization; not a certified actuator saturation";
spec.weightsSymmetric = true;
spec.useW3 = false;
spec.controllerSynthesisAllowed = false;

spec.robustnessLanguage = [ ...
    "Nominal Stability"; ...
    "Nominal Performance"; ...
    "Robust Stability"; ...
    "Robust Performance"];
spec.futureRobustStabilityCriterion = "mu upper bound < 1";
spec.futureRobustPerformanceCriterion = ...
    "augmented-problem mu upper bound < 1";
end
