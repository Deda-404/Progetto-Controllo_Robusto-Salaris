function search = estimate_m15_robust_ras(controller, projectRoot, config)
%ESTIMATE_M15_ROBUST_RAS Deterministic M8-compatible empirical RAS search.

arguments
    controller (1, 1) struct
    projectRoot (1, 1) string
    config (1, 1) struct = m15_specs
end

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
    direction = [cos(angles(directionIndex)), sin(angles(directionIndex))];
    maximumRadius = config.ras.searchBoxDeg / max(abs(direction));
    endpoint = localEvaluate(maximumRadius * direction);
    if endpoint.Convergent
        boundaryRadiusDeg(directionIndex) = maximumRadius;
        boxLimited(directionIndex) = true;
        continue
    end
    lowerRadius = 0; upperRadius = maximumRadius;
    while upperRadius - lowerRadius > config.ras.radialToleranceDeg
        middleRadius = 0.5 * (lowerRadius + upperRadius);
        middle = localEvaluate(middleRadius * direction);
        if middle.Convergent, lowerRadius = middleRadius;
        else, upperRadius = middleRadius;
        end
    end
    boundaryRadiusDeg(directionIndex) = lowerRadius;
end
allPoints = struct2table(records);
boundaryPointDeg = boundaryRadiusDeg .* [cos(angles), sin(angles)];
boundary = table(rad2deg(angles), boundaryRadiusDeg, ...
    boundaryPointDeg(:, 1), boundaryPointDeg(:, 2), boxLimited, ...
    'VariableNames', {'DirectionDeg', 'RadiusDeg', 'Dq1Deg', ...
    'Dq2Deg', 'SearchBoxLimited'});
areaDeg2 = 0.5 * sum(boundaryRadiusDeg .* ...
    circshift(boundaryRadiusDeg, -1) .* sin(2 * pi / numel(angles)));
[minimumRadiusDeg, criticalIndex] = min(boundaryRadiusDeg);
[maximumRadiusDeg, favorableIndex] = max(boundaryRadiusDeg);
search = struct( ...
    'controllerID', controller.id, 'section', "dq1/dq2", ...
    'initialConditionDefinition', ...
        "q shifted; zero qdot; theta shifted with q; zero thetaDot; " + ...
        "M3 actuator equilibrium; controller state zero", ...
    'allPoints', allPoints, ...
    'convergentPoints', allPoints(allPoints.Convergent, :), ...
    'divergentPoints', allPoints(~allPoints.Convergent, :), ...
    'boundary', boundary, 'metrics', struct( ...
        'numberSimulations', simulationCount, ...
        'numberUniquePoints', height(allPoints), ...
        'numberConvergent', sum(allPoints.Convergent), ...
        'numberDivergent', sum(~allPoints.Convergent), ...
        'minimumRadiusDeg', minimumRadiusDeg, ...
        'maximumRadiusDeg', maximumRadiusDeg, ...
        'approximateAreaDeg2', areaDeg2, ...
        'approximateAreaRad2', areaDeg2 * (pi / 180)^2, ...
        'criticalDirectionDeg', boundary.DirectionDeg(criticalIndex), ...
        'favorableDirectionDeg', boundary.DirectionDeg(favorableIndex), ...
        'directions', numel(angles), ...
        'allRadialEndpointsConvergent', all(boxLimited), ...
        'classification', localClassification(boxLimited), ...
        'extendedHorizonCount', sum(allPoints.ExtendedHorizon)), ...
    'config', config.ras, 'cacheDeterministic', true, ...
    'controllerStateStartsZero', true, 'certifiedRegion', false);

    function record = localEvaluate(pointDeg)
        pointDeg(abs(pointDeg) < 1e-10) = 0;
        key = sprintf('%.9f,%.9f', pointDeg(1), pointDeg(2));
        if isKey(cache, key), record = cache(key); return; end
        assert(simulationCount < config.ras.maximumSimulations, ...
            'M15RAS:SimulationBudget', 'RAS search exceeded its budget.');
        deltaQ = deg2rad(pointDeg(:));
        scenario.xMechanical0 = m3.xbar + ...
            [deltaQ; zeros(2, 1); deltaQ; zeros(2, 1)];
        scenario.xActuator0 = xActuatorEquilibrium;
        scenario.xController0 = zeros(controller.order, 1);
        scenario.horizon = config.ras.horizon;
        simulationCount = simulationCount + 1;
        extended = false;
        try
            result = simulate_m15_nonlinear(controller, scenario, ...
                projectRoot, config);
            assessment = evaluate_m15_convergence(result, m3, config);
            if assessment.extensionEligible
                assert(simulationCount < config.ras.maximumSimulations, ...
                    'M15RAS:SimulationBudget', ...
                    'RAS extension exceeded its budget.');
                scenario.horizon = config.ras.extendedHorizon;
                simulationCount = simulationCount + 1;
                result = simulate_m15_nonlinear(controller, scenario, ...
                    projectRoot, config);
                assessment = evaluate_m15_convergence(result, m3, config);
                extended = true;
            end
            deformation = result.xMechanical(:, 5:6) - ...
                result.xMechanical(:, 1:2);
            elasticTorque = deformation * m3.mechanicalParams.Ks.';
            record = localEmptyRecord;
            record.Dq1Deg = pointDeg(1); record.Dq2Deg = pointDeg(2);
            record.Convergent = assessment.convergent;
            record.ExtendedHorizon = extended;
            record.Horizon = assessment.horizon;
            record.TailMaxQDeg = rad2deg(assessment.tailMaxQError);
            record.TailMaxQdot = assessment.tailMaxQdot;
            record.TailMaxThetaDeg = rad2deg(assessment.tailMaxThetaError);
            record.TailMaxThetaDot = assessment.tailMaxThetaDot;
            record.NoFinalGrowth = assessment.noFinalGrowth;
            record.PeakControlNm = ...
                max(abs(result.controlDelta), [], 'all');
            record.PeakDeformationRad = max(abs(deformation), [], 'all');
            record.PeakElasticTorqueNm = ...
                max(abs(elasticTorque), [], 'all');
            record.Completed = assessment.completed;
            record.Finite = assessment.finite;
            record.Bounded = assessment.bounded;
        catch simulationError
            record = localEmptyRecord;
            record.Dq1Deg = pointDeg(1); record.Dq2Deg = pointDeg(2);
            record.ErrorIdentifier = string(simulationError.identifier);
        end
        records(end + 1, 1) = record;
        cache(key) = record;
    end
end

function record = localEmptyRecord
record = struct('Dq1Deg', 0, 'Dq2Deg', 0, 'Convergent', false, ...
    'ExtendedHorizon', false, 'Horizon', 0, 'TailMaxQDeg', inf, ...
    'TailMaxQdot', inf, 'TailMaxThetaDeg', inf, ...
    'TailMaxThetaDot', inf, 'NoFinalGrowth', false, ...
    'PeakControlNm', NaN, 'PeakDeformationRad', NaN, ...
    'PeakElasticTorqueNm', NaN, 'Completed', false, ...
    'Finite', false, 'Bounded', false, 'ErrorIdentifier', "");
end
function value = localClassification(boxLimited)
if all(boxLimited), value = "SEARCH-BOX LIMITED";
else, value = "EMPIRICAL BOUNDARY LOCATED";
end
end
