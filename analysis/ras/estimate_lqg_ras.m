function search = estimate_lqg_ras(projectRoot, config, section)
%ESTIMATE_LQG_RAS Deterministic coarse-grid and radial empirical search.
%   SECTION is either "zero-estimate" (the required primary section) or
%   "coherent-estimate" (the optional diagnostic second section).

arguments
    projectRoot (1, 1) string = string(fileparts(fileparts(fileparts( ...
        mfilename('fullpath')))))
    config (1, 1) struct = m8_specs
    section (1, 1) string {mustBeMember(section, ...
        ["zero-estimate", "coherent-estimate"])} = "zero-estimate"
end

projectRoot = char(projectRoot);
m3 = load(fullfile(projectRoot, 'results', 'data', ...
    'm3_nominal_actuated_plant.mat'));
[Aact, Bact] = ssdata(m3.GactuatorsMimo);
xActuatorEquilibrium = -Aact \ (Bact * m3.taubar);
cache = containers.Map('KeyType', 'char', 'ValueType', 'any');
records = repmat(localEmptyRecord, 0, 1);
simulationCount = 0;

coarseDeg = config.ras.coarseGridDeg(:);
for firstIndex = 1:numel(coarseDeg)
    for secondIndex = 1:numel(coarseDeg)
        localEvaluate([coarseDeg(firstIndex), coarseDeg(secondIndex)]);
    end
end

angles = linspace(0, 2 * pi, config.ras.numberDirections + 1).';
angles(end) = [];
boundaryRadiusDeg = zeros(size(angles));
boxLimited = false(size(angles));
for directionIndex = 1:numel(angles)
    direction = [cos(angles(directionIndex)), ...
        sin(angles(directionIndex))];
    maximumRadius = config.ras.searchBoxDeg / ...
        max(abs(direction));
    endpoint = localEvaluate(maximumRadius * direction);
    if endpoint.Convergent
        boundaryRadiusDeg(directionIndex) = maximumRadius;
        boxLimited(directionIndex) = true;
        continue
    end
    lowerRadius = 0;
    upperRadius = maximumRadius;
    while upperRadius - lowerRadius > config.ras.radialToleranceDeg
        middleRadius = 0.5 * (lowerRadius + upperRadius);
        middle = localEvaluate(middleRadius * direction);
        if middle.Convergent
            lowerRadius = middleRadius;
        else
            upperRadius = middleRadius;
        end
    end
    boundaryRadiusDeg(directionIndex) = lowerRadius;
end

allPoints = struct2table(records);
boundaryPointDeg = boundaryRadiusDeg .* [cos(angles), sin(angles)];
rasBoundary = table(rad2deg(angles), boundaryRadiusDeg, ...
    boundaryPointDeg(:, 1), boundaryPointDeg(:, 2), boxLimited, ...
    'VariableNames', {'DirectionDeg', 'RadiusDeg', 'Dq1Deg', ...
    'Dq2Deg', 'SearchBoxLimited'});
areaDeg2 = 0.5 * sum(boundaryRadiusDeg .* ...
    circshift(boundaryRadiusDeg, -1) .* sin(2 * pi / numel(angles)));
[minimumRadiusDeg, criticalIndex] = min(boundaryRadiusDeg);
[maximumRadiusDeg, favorableIndex] = max(boundaryRadiusDeg);
convergentControl = allPoints.PeakControlNm(allPoints.Convergent);
if isempty(convergentControl)
    maximumConvergentControlNm = NaN;
else
    maximumConvergentControlNm = max(convergentControl);
end

search.section = section;
search.initialConditionDefinition = localInitialConditionText(section);
search.allPoints = allPoints;
search.convergentPoints = allPoints(allPoints.Convergent, :);
search.divergentPoints = allPoints(~allPoints.Convergent, :);
search.boundary = rasBoundary;
search.metrics = struct( ...
    'numberSimulations', simulationCount, ...
    'numberUniquePoints', height(allPoints), ...
    'numberConvergent', sum(allPoints.Convergent), ...
    'numberDivergent', sum(~allPoints.Convergent), ...
    'empiricalConvergenceFraction', mean(allPoints.Convergent), ...
    'minimumRadiusDeg', minimumRadiusDeg, ...
    'maximumRadiusDeg', maximumRadiusDeg, ...
    'approximateAreaDeg2', areaDeg2, ...
    'approximateAreaRad2', areaDeg2 * (pi / 180)^2, ...
    'criticalDirectionDeg', rasBoundary.DirectionDeg(criticalIndex), ...
    'favorableDirectionDeg', rasBoundary.DirectionDeg(favorableIndex), ...
    'directions', numel(angles), ...
    'allRadialEndpointsConvergent', all(boxLimited), ...
    'classification', localClassification(boxLimited), ...
    'maximumConvergentControlNm', maximumConvergentControlNm, ...
    'certifiedRegion', false, ...
    'extendedHorizonCount', sum(allPoints.ExtendedHorizon));
search.config = config.ras;
search.certifiedRegion = false;

    function record = localEvaluate(pointDeg)
        pointDeg(abs(pointDeg) < 1e-10) = 0;
        key = sprintf('%.9f,%.9f', pointDeg(1), pointDeg(2));
        if isKey(cache, key)
            record = cache(key);
            return
        end
        assert(simulationCount < config.ras.maximumSimulations, ...
            'M8RAS:SimulationBudget', ...
            'RAS search exceeded the declared computational budget.');
        deltaQ = deg2rad(pointDeg(:));
        mechanicalDelta = [deltaQ; zeros(2, 1); deltaQ; zeros(2, 1)];
        scenario.xMechanical0 = m3.xbar + mechanicalDelta;
        scenario.xActuator0 = xActuatorEquilibrium;
        if section == "coherent-estimate"
            scenario.xhat0 = [mechanicalDelta; zeros(6, 1)];
        else
            scenario.xhat0 = zeros(14, 1);
        end
        scenario.horizon = config.ras.horizon;
        simulationCount = simulationCount + 1;
        extended = false;
        try
            result = simulate_m8_nonlinear(scenario, ...
                string(projectRoot), config);
            assessment = evaluate_m8_convergence(result, m3, config);
            if assessment.extensionEligible
                scenario.horizon = config.ras.extendedHorizon;
                simulationCount = simulationCount + 1;
                result = simulate_m8_nonlinear(scenario, ...
                    string(projectRoot), config);
                assessment = evaluate_m8_convergence(result, m3, config);
                extended = true;
            end
            deformation = result.xMechanical(:, 5:6) - ...
                result.xMechanical(:, 1:2);
            elasticTorque = deformation * m3.mechanicalParams.Ks.';
            record = localEmptyRecord;
            record.Dq1Deg = pointDeg(1);
            record.Dq2Deg = pointDeg(2);
            record.Convergent = assessment.convergent;
            record.ExtendedHorizon = extended;
            record.Horizon = assessment.horizon;
            record.TailMaxQDeg = rad2deg(assessment.tailMaxQError);
            record.TailMaxQdot = assessment.tailMaxQdot;
            record.TailMaxThetaDeg = ...
                rad2deg(assessment.tailMaxThetaError);
            record.TailMaxThetaDot = assessment.tailMaxThetaDot;
            record.NoFinalGrowth = assessment.noFinalGrowth;
            record.PeakControlNm = max(abs(result.control), [], 'all');
            record.PeakDeformationRad = max(abs(deformation), [], 'all');
            record.PeakElasticTorqueNm = max(abs(elasticTorque), [], 'all');
            record.Completed = assessment.completed;
            record.Finite = assessment.finite;
            record.Bounded = assessment.bounded;
        catch simulationError
            record = localEmptyRecord;
            record.Dq1Deg = pointDeg(1);
            record.Dq2Deg = pointDeg(2);
            record.ErrorIdentifier = string(simulationError.identifier);
        end
        records(end + 1, 1) = record;
        cache(key) = record;
    end
end

function value = localClassification(boxLimited)
if all(boxLimited)
    value = "SEARCH-BOX LIMITED";
else
    value = "EMPIRICAL BOUNDARY LOCATED";
end
end

function record = localEmptyRecord
record = struct('Dq1Deg', 0, 'Dq2Deg', 0, ...
    'Convergent', false, 'ExtendedHorizon', false, 'Horizon', 0, ...
    'TailMaxQDeg', inf, 'TailMaxQdot', inf, ...
    'TailMaxThetaDeg', inf, 'TailMaxThetaDot', inf, ...
    'NoFinalGrowth', false, 'PeakControlNm', NaN, ...
    'PeakDeformationRad', NaN, 'PeakElasticTorqueNm', NaN, ...
    'Completed', false, 'Finite', false, 'Bounded', false, ...
    'ErrorIdentifier', "");
end

function text = localInitialConditionText(section)
if section == "coherent-estimate"
    text = ["dq plane; zero velocities; theta shifted with q; " ...
        "actuators at equilibrium; xhat0 equals the physical delta state"];
else
    text = ["dq plane; zero velocities; theta shifted with q; " ...
        "actuators at equilibrium; xhat0=0 in incremental coordinates"];
end
end
