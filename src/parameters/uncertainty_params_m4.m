function uncertainty = uncertainty_params_m4(selectedMechanicalParameters)
%UNCERTAINTY_PARAMS_M4 Engineering uncertainty assumptions for M4.

if nargin < 1
    selectedMechanicalParameters = ["k2"; "k1"; "Jm1"];
end
selectedMechanicalParameters = string(selectedMechanicalParameters(:));
nominal = sea_params_nominal;
numberSelected = numel(selectedMechanicalParameters);
nominalValue = zeros(numberSelected, 1);
mildPercent = zeros(numberSelected, 1);
baselinePercent = zeros(numberSelected, 1);
conservativePercent = zeros(numberSelected, 1);
rationale = strings(numberSelected, 1);

for index = 1:numberSelected
    name = selectedMechanicalParameters(index);
    nominalValue(index) = localNominalValue(nominal, name);
    if startsWith(name, "k")
        mildPercent(index) = 3;
        baselinePercent(index) = 7;
        conservativePercent(index) = 12;
        rationale(index) = ...
            "SEA stiffness: moderate assembly/material variability; " + ...
            "7% baseline avoids the unverified 5% reference value";
    elseif startsWith(name, "Jm")
        mildPercent(index) = 4;
        baselinePercent(index) = 9;
        conservativePercent(index) = 15;
        rationale(index) = ...
            "motor/drive reflected inertia: moderate modeling variability; " + ...
            "9% baseline is an engineering envelope";
    elseif startsWith(name, "Bm")
        mildPercent(index) = 10;
        baselinePercent(index) = 22;
        conservativePercent(index) = 35;
        rationale(index) = ...
            "viscous damping: operating-condition dependence and weak knowledge";
    elseif startsWith(name, "m")
        mildPercent(index) = 4;
        baselinePercent(index) = 12;
        conservativePercent(index) = 20;
        rationale(index) = ...
            "mass/load: assembly and payload envelope, not measured tolerance";
    elseif startsWith(name, "l")
        mildPercent(index) = 0.5;
        baselinePercent(index) = 1;
        conservativePercent(index) = 2;
        rationale(index) = ...
            "geometry: manufactured/measured dimension with small variability";
    else
        error('M4Uncertainty:UnsupportedParameter', ...
            'No range rationale is defined for %s.', name);
    end
end

uncertainty.mechanicalScenarios = table( ...
    selectedMechanicalParameters, nominalValue, mildPercent, ...
    baselinePercent, conservativePercent, rationale, ...
    'VariableNames', {'Parameter', 'NominalValue', 'MildPercent', ...
    'BaselinePercent', 'ConservativePercent', 'Rationale'});
uncertainty.selectedMechanicalRanges = uncertainty.mechanicalScenarios(:, ...
    {'Parameter', 'NominalValue', 'BaselinePercent', 'Rationale'});

actuatorParameter = ["wn"; "zeta"; "delay"];
actuatorNominalValue = [40; 0.8; 0.015];
actuatorMildPercent = [4; 4; 8];
actuatorBaselinePercent = [8; 7.5; 20];
actuatorConservativePercent = [15; 12.5; 35];
actuatorRationale = [ ...
    "closed-loop actuator natural-frequency dispersion"; ...
    "damping variation without introducing low-damping extremes"; ...
    "latency/jitter envelope around the 15 ms nominal delay"];
uncertainty.actuatorScenarios = table(actuatorParameter, ...
    actuatorNominalValue, actuatorMildPercent, ...
    actuatorBaselinePercent, actuatorConservativePercent, ...
    actuatorRationale, 'VariableNames', {'Parameter', 'NominalValue', ...
    'MildPercent', 'BaselinePercent', 'ConservativePercent', 'Rationale'});
uncertainty.selectedActuatorRanges = uncertainty.actuatorScenarios(:, ...
    {'Parameter', 'NominalValue', 'BaselinePercent', 'Rationale'});

uncertainty.actuatorFamilySeed = 20260824;
uncertainty.actuatorRandomSamples = 105;
uncertainty.plantSamplingSeed = 20260825;
uncertainty.plantValidationSamples = 40;
uncertainty.weightSafetyFactor = 1.08;
uncertainty.sensitivityGrid = logspace(-1, log10(300), 501);
uncertainty.coverageGrid = logspace(-1, 3, 801);
uncertainty.scenarioSelection = "BASELINE";
uncertainty.status = ...
    "All ranges are project engineering assumptions, not measured " + ...
    "manufacturing tolerances or identified confidence intervals.";
end

function value = localNominalValue(p, parameterName)
switch parameterName
    case "m1"
        value = p.m1;
    case "m2"
        value = p.m2;
    case "l1"
        value = p.l1;
    case "l2"
        value = p.l2;
    case "Jm1"
        value = p.Jm(1, 1);
    case "Jm2"
        value = p.Jm(2, 2);
    case "Bm1"
        value = p.Bm(1, 1);
    case "Bm2"
        value = p.Bm(2, 2);
    case "k1"
        value = p.Ks(1, 1);
    case "k2"
        value = p.Ks(2, 2);
    otherwise
        error('M4Uncertainty:UnknownParameter', ...
            'Unknown nominal parameter %s.', parameterName);
end
end
