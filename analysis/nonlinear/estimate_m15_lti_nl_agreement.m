function search = estimate_m15_lti_nl_agreement(controller, projectRoot, config)
%ESTIMATE_M15_LTI_NL_AGREEMENT Map the empirical reference agreement region.

arguments
    controller (1, 1) struct
    projectRoot (1, 1) string
    config (1, 1) struct = m15_specs
end

m3 = load(fullfile(projectRoot, 'results', 'data', ...
    'm3_nominal_actuated_plant.mat'));
angles = linspace(0, 2 * pi, config.agreement.numberDirections + 1).';
angles(end) = [];
radii = zeros(size(angles));
fullEnvelope = false(size(angles));
cache = containers.Map('KeyType', 'char', 'ValueType', 'any');
records = repmat(localEmptyRecord, 0, 1);
simulationCount = 0;
for directionIndex = 1:numel(angles)
    direction = [cos(angles(directionIndex)), sin(angles(directionIndex))];
    endpoint = localEvaluate(config.agreement.maximumRadiusDeg, ...
        direction, directionIndex);
    if endpoint.AgreementPassed
        radii(directionIndex) = config.agreement.maximumRadiusDeg;
        fullEnvelope(directionIndex) = true;
        continue
    end
    lower = 0; upper = config.agreement.maximumRadiusDeg;
    while upper - lower > config.agreement.radialToleranceDeg
        middle = 0.5 * (lower + upper);
        result = localEvaluate(middle, direction, directionIndex);
        if result.AgreementPassed, lower = middle; else, upper = middle; end
    end
    radii(directionIndex) = lower;
end
points = radii .* [cos(angles), sin(angles)];
boundary = table(rad2deg(angles), radii, points(:, 1), points(:, 2), ...
    fullEnvelope, 'VariableNames', {'DirectionDeg', 'RadiusDeg', ...
    'R1Deg', 'R2Deg', 'FullEightDegreeEnvelope'});
areaDeg2 = 0.5 * sum(radii .* circshift(radii, -1) .* ...
    sin(2 * pi / numel(angles)));
[minimumRadius, criticalIndex] = min(radii);
search = struct('controllerID', controller.id, ...
    'name', "EMPIRICAL LTI/NL AGREEMENT REGION", ...
    'boundary', boundary, 'allPoints', struct2table(records), ...
    'metrics', struct('numberSimulations', simulationCount, ...
        'minimumRadiusDeg', minimumRadius, ...
        'maximumRadiusDeg', max(radii), ...
        'approximateAreaDeg2', areaDeg2, ...
        'fullEnvelopeDirectionCount', sum(fullEnvelope), ...
        'criticalDirectionDeg', boundary.DirectionDeg(criticalIndex), ...
        'directions', numel(angles)), ...
    'config', config.agreement, 'cacheDeterministic', true, ...
    'isRas', false, 'isRobustRegion', false, 'isCertified', false);

    function record = localEvaluate(radiusDeg, direction, directionIndex)
        if radiusDeg < 1e-12, radiusDeg = 0; end
        key = sprintf('%d,%.9f', directionIndex, radiusDeg);
        if isKey(cache, key), record = cache(key); return; end
        assert(simulationCount < config.agreement.maximumSimulations, ...
            'M15Agreement:SimulationBudget', ...
            'Agreement search exceeded its declared budget.');
        simulationCount = simulationCount + 1;
        reference = deg2rad(radiusDeg) * direction;
        scenario.reference = reference;
        scenario.horizon = config.agreement.horizon;
        record = localEmptyRecord;
        record.DirectionDeg = rad2deg(angles(directionIndex));
        record.RadiusDeg = radiusDeg;
        try
            nonlinear = simulate_m15_nonlinear(controller, scenario, ...
                projectRoot, config);
            time = (0:config.simulation.inputTimeStep:scenario.horizon).';
            input = repmat(reference, numel(time), 1);
            qLti = lsim(controller.T, input, time);
            qLtiAtNl = interp1(time, qLti, nonlinear.time, 'linear');
            qNl = nonlinear.xMechanical(:, 1:2) - m3.xbar(1:2).';
            difference = qNl - qLtiAtNl;
            record.Completed = nonlinear.completed;
            record.Finite = all(isfinite([qNl, qLtiAtNl]), 'all');
            record.MaxQDiscrepancyDeg = rad2deg( ...
                max(abs(difference), [], 'all'));
            record.RmsQDiscrepancyDeg = rad2deg( ...
                sqrt(mean(difference.^2, 'all')));
            record.AgreementPassed = record.Completed && record.Finite && ...
                record.MaxQDiscrepancyDeg <= ...
                config.agreement.maximumQDiscrepancyDeg;
        catch simulationError
            record.ErrorIdentifier = string(simulationError.identifier);
        end
        records(end + 1, 1) = record;
        cache(key) = record;
    end
end

function record = localEmptyRecord
record = struct('DirectionDeg', 0, 'RadiusDeg', 0, ...
    'Completed', false, 'Finite', false, ...
    'MaxQDiscrepancyDeg', inf, 'RmsQDiscrepancyDeg', inf, ...
    'AgreementPassed', false, 'ErrorIdentifier', "");
end
