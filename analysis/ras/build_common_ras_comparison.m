function comparison = build_common_ras_comparison(projectRoot, makeFigures)
%BUILD_COMMON_RAS_COMPARISON Compare empirical RAS with one methodology.
%   M6 LQG, Khinf M10 and Kmu M13 are read from the validated M8/M15
%   campaigns. All use the same nonlinear mechanics, equilibrium, q1-q2
%   initial-condition plane, solver, horizons and convergence thresholds.

arguments
    projectRoot (1, 1) string = string(fileparts(fileparts(fileparts( ...
        mfilename('fullpath')))))
    makeFigures (1, 1) logical = true
end

dataDirectory = fullfile(projectRoot, 'results', 'data');
figureDirectory = fullfile(projectRoot, 'results', 'figures');
m8Path = fullfile(dataDirectory, 'm8_lqg_nonlinear_ras.mat');
m15Path = fullfile(dataDirectory, 'm15_nonlinear_robust_validation.mat');
if ~isfile(m8Path)
    validate_m8_simulink_ras(true);
end
if ~isfile(m15Path)
    validate_m15_nonlinear_robust(true);
end
m8 = load(m8Path);
m15 = load(m15Path);

commonRasFields = {'coarseGridDeg', 'numberDirections', ...
    'searchBoxDeg', 'radialToleranceDeg', 'horizon', ...
    'extendedHorizon', 'tailFraction', 'positionToleranceDeg', ...
    'linkVelocityTolerance', 'motorPositionToleranceDeg', ...
    'motorVelocityTolerance', 'numericMagnitudeLimit', ...
    'maximumSimulations', 'finalTrendGrowthFraction'};
assert(isequaln(m8.simulationConfig.solver, m15.config.solver) && ...
    localFieldsEqual(m8.simulationConfig.ras, m15.config.ras, ...
        commonRasFields), ...
    'RASComparison:MethodMismatch', ...
    'M8 and M15 must use the same declared RAS method.');

searches = cell(3, 1);
searches{1} = struct('controllerID', "LQG M6", ...
    'allPoints', m8.rasAllPoints, 'boundary', m8.rasBoundary, ...
    'metrics', m8.rasMetrics);
searches{2} = m15.rasResults(1);
searches{3} = m15.rasResults(2);
controller = ["LQG M6"; "Khinf M10"; "Kmu M13"];
numberUniquePoints = zeros(3, 1);
numberConvergent = zeros(3, 1);
numberDivergent = zeros(3, 1);
empiricalFraction = zeros(3, 1);
minimumRadiusDeg = zeros(3, 1);
maximumRadiusDeg = zeros(3, 1);
approximateAreaDeg2 = zeros(3, 1);
maximumConvergentControlNm = zeros(3, 1);
classification = strings(3, 1);
for index = 1:3
    points = searches{index}.allPoints;
    metrics = searches{index}.metrics;
    numberUniquePoints(index) = height(points);
    numberConvergent(index) = sum(points.Convergent);
    numberDivergent(index) = sum(~points.Convergent);
    empiricalFraction(index) = mean(points.Convergent);
    minimumRadiusDeg(index) = metrics.minimumRadiusDeg;
    maximumRadiusDeg(index) = metrics.maximumRadiusDeg;
    approximateAreaDeg2(index) = metrics.approximateAreaDeg2;
    convergentControl = points.PeakControlNm(points.Convergent);
    if isempty(convergentControl)
        maximumConvergentControlNm(index) = NaN;
    else
        maximumConvergentControlNm(index) = max(convergentControl);
    end
    if metrics.allRadialEndpointsConvergent
        classification(index) = "SEARCH-BOX LIMITED";
    else
        classification(index) = "EMPIRICAL BOUNDARY LOCATED";
    end
end

comparisonTable = table(controller, numberUniquePoints, ...
    numberConvergent, numberDivergent, empiricalFraction, ...
    minimumRadiusDeg, maximumRadiusDeg, approximateAreaDeg2, ...
    maximumConvergentControlNm, classification, ...
    'VariableNames', {'Controller', 'NumberUniquePoints', ...
    'NumberConvergent', 'NumberDivergent', 'EmpiricalFraction', ...
    'MinimumRadiusDeg', 'MaximumRadiusDeg', 'ApproximateAreaDeg2', ...
    'MaximumConvergentControlNm', 'Classification'});

method = struct('plane', "delta q1(0), delta q2(0)", ...
    'otherMechanicalStates', ...
        "zero velocities; theta shifted coherently with q", ...
    'equilibrium', "qbar=[90;0] deg; actuator states at equilibrium", ...
    'controllerStates', "zero incremental controller/observer states", ...
    'searchBoxDeg', m8.simulationConfig.ras.searchBoxDeg, ...
    'coarseGridDeg', m8.simulationConfig.ras.coarseGridDeg, ...
    'numberDirections', m8.simulationConfig.ras.numberDirections, ...
    'horizon', m8.simulationConfig.ras.horizon, ...
    'extendedHorizon', m8.simulationConfig.ras.extendedHorizon, ...
    'solver', m8.simulationConfig.solver.selected, ...
    'saturationEnabled', m8.simulationConfig.saturationEnabled, ...
    'certifiedRegion', false, ...
    'areaMeaning', ...
        "polygonal estimate from the sampled radial boundary; grid dependent");

figurePaths = struct;
if makeFigures
    if ~isfolder(figureDirectory), mkdir(figureDirectory); end
    ids = ["lqg"; "khinf"; "kmu"];
    for index = 1:3
        figurePaths.(ids(index)) = fullfile(figureDirectory, ...
            "ras_" + ids(index) + "_common.png");
        localPlotSingle(searches{index}, controller(index), ...
            m8.simulationConfig.ras.searchBoxDeg, ...
            figurePaths.(ids(index)));
    end
    figurePaths.comparison = fullfile(figureDirectory, ...
        'ras_common_comparison.png');
    localPlotComparison(searches, controller, ...
        m8.simulationConfig.ras.searchBoxDeg, figurePaths.comparison);
end

datasetPath = fullfile(dataDirectory, 'ras_common_comparison.mat');
save(datasetPath, 'comparisonTable', 'method', 'figurePaths', '-v7');
comparison.table = comparisonTable;
comparison.method = method;
comparison.figurePaths = figurePaths;
comparison.datasetPath = string(datasetPath);
end

function equal = localFieldsEqual(first, second, names)
equal = true;
for index = 1:numel(names)
    name = names{index};
    equal = equal && isfield(first, name) && isfield(second, name) && ...
        isequaln(first.(name), second.(name));
end
end

function localPlotSingle(search, controller, searchBoxDeg, filePath)
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 780, 720]);
localPlotOnAxes(gca, search, controller, searchBoxDeg, true);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotComparison(searches, controller, searchBoxDeg, filePath)
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1320, 480]);
layout = tiledlayout(1, 3, 'TileSpacing', 'compact');
for index = 1:3
    nexttile;
    localPlotOnAxes(gca, searches{index}, controller(index), ...
        searchBoxDeg, false);
end
xlabel(layout, 'delta q_1(0) [deg]');
ylabel(layout, 'delta q_2(0) [deg]');
title(layout, 'Confronto RAS empiriche con metodologia comune');
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotOnAxes(axesHandle, search, controller, searchBoxDeg, ...
    showLegend)
points = search.allPoints;
scatter(axesHandle, points.Dq1Deg(points.Convergent), ...
    points.Dq2Deg(points.Convergent), 24, [0.16, 0.62, 0.32], ...
    'filled', 'DisplayName', 'Convergente');
hold(axesHandle, 'on');
scatter(axesHandle, points.Dq1Deg(~points.Convergent), ...
    points.Dq2Deg(~points.Convergent), 30, [0.82, 0.22, 0.18], ...
    'x', 'DisplayName', 'Non convergente');
boundary = [search.boundary.Dq1Deg, search.boundary.Dq2Deg];
boundary = [boundary; boundary(1, :)];
plot(axesHandle, boundary(:, 1), boundary(:, 2), 'k-', ...
    'LineWidth', 1.8, 'DisplayName', 'Frontiera campionata');
plot(axesHandle, 0, 0, 'kp', 'MarkerFaceColor', 'yellow', ...
    'MarkerSize', 11, 'DisplayName', 'Equilibrio');
axis(axesHandle, 'equal'); grid(axesHandle, 'on'); box(axesHandle, 'on');
xlim(axesHandle, 1.08 * [-searchBoxDeg, searchBoxDeg]);
ylim(axesHandle, 1.08 * [-searchBoxDeg, searchBoxDeg]);
xlabel(axesHandle, 'delta q_1(0) [deg]');
ylabel(axesHandle, 'delta q_2(0) [deg]');
title(axesHandle, controller);
if showLegend
    legend(axesHandle, 'Location', 'southoutside');
end
end
