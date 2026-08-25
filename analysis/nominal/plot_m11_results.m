function figurePaths = plot_m11_results(campaign, selection, ...
    representativeResults, m10, m10Evaluation, comparison, ...
    figureDirectory, config)
%PLOT_M11_RESULTS Generate compact structured-campaign engineering plots.

arguments
    campaign (1, 1) struct
    selection (1, 1) struct
    representativeResults (:, 1) struct
    m10 (1, 1) struct
    m10Evaluation (1, 1) struct
    comparison table
    figureDirectory (1, :) char
    config (1, 1) struct = hinfstruct_specs_m11
end

if ~isfolder(figureDirectory), mkdir(figureDirectory); end
figurePaths.gammaOrder = fullfile(figureDirectory, ...
    'm11_gamma_vs_order.png');
figurePaths.startDispersion = fullfile(figureDirectory, ...
    'm11_gamma_start_dispersion.png');
figurePaths.pareto = fullfile(figureDirectory, ...
    'm11_pareto_gamma_order.png');
figurePaths.weighted = fullfile(figureDirectory, ...
    'm11_weighted_pareto_vs_m10.png');
figurePaths.tracking = fullfile(figureDirectory, ...
    'm11_tracking_pareto_comparison.png');
figurePaths.effortDisturbance = fullfile(figureDirectory, ...
    'm11_effort_disturbance_comparison.png');

localPlotGammaOrder(selection, m10, figurePaths.gammaOrder);
localPlotStartDispersion(campaign, figurePaths.startDispersion);
localPlotPareto(selection, figurePaths.pareto);
localPlotWeighted(selection, representativeResults, m10, ...
    figurePaths.weighted, config);
localPlotTracking(selection, representativeResults, m10Evaluation, ...
    figurePaths.tracking);
localPlotEffortDisturbance(comparison, figurePaths.effortDisturbance);
end

function localPlotGammaOrder(selection, m10, filePath)
tableData = selection.representativeTable;
mask = tableData.Valid;
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 950, 650]);
scatter(tableData.Order(mask), tableData.WeightedNorm(mask), 80, ...
    'filled'); hold on;
for index = find(mask).'
    offset = 0.08;
    if tableData.Order(index) == max(tableData.Order(mask))
        offset = -0.22;
    end
    text(tableData.Order(index) + offset, ...
        tableData.WeightedNorm(index), tableData.ArchitectureID(index));
end
yline(m10.gammaHinf, '--', 'M10 full-order', ...
    'LabelHorizontalAlignment', 'left');
set(gca, 'YScale', 'log'); grid on; box on;
xlim([1.75, 6.35]);
ylim([9.5, 17.2]);
xlabel('Ordine reale del controllore'); ylabel('Norma H-infinity pesata');
title('M11 — costo prestazionale della struttura ridotta');
localPrepareFigure(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotStartDispersion(campaign, filePath)
architectures = campaign.architectureResults;
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1050, 650]);
hold on;
for architectureIndex = 1:numel(architectures)
    runs = architectures(architectureIndex).runs;
    objectives = [runs.solverObjective].';
    mask = isfinite(objectives) & objectives > 0;
    scatter(repmat(architectureIndex, sum(mask), 1), ...
        objectives(mask), 55, 'filled', 'DisplayName', ...
        architectures(architectureIndex).id);
end
set(gca, 'YScale', 'log', 'XTick', 1:numel(architectures), ...
    'XTickLabel', {architectures.id});
grid on; box on; xlabel('Architettura');
ylabel('Objective hinfstruct per start');
title('M11 — dispersione delle cinque partenze');
localPrepareFigure(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotPareto(selection, filePath)
tableData = selection.representativeTable;
validMask = tableData.Valid;
paretoMask = tableData.Pareto;
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 950, 650]);
scatter(tableData.Order(validMask & ~paretoMask), ...
    tableData.WeightedNorm(validMask & ~paretoMask), 70, ...
    [0.55 0.55 0.55], 'filled', 'DisplayName', 'Dominati'); hold on;
scatter(tableData.Order(paretoMask), tableData.WeightedNorm(paretoMask), ...
    100, [0.05 0.45 0.75], 'filled', 'DisplayName', 'Pareto');
for index = find(validMask).'
    offset = 0.08;
    if tableData.Order(index) == max(tableData.Order(validMask))
        offset = -0.22;
    end
    text(tableData.Order(index) + offset, ...
        tableData.WeightedNorm(index), tableData.ArchitectureID(index));
end
set(gca, 'YScale', 'log'); grid on; box on;
xlim([1.75, 6.35]);
ylim([9.5, 17.2]);
xlabel('Ordine reale'); ylabel('Norma H-infinity pesata');
title('M11 — frontiera Pareto gamma vs ordine');
legend('Location', 'best');
localPrepareFigure(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotWeighted(selection, representatives, m10, filePath, config)
frequencies = config.frequencyGrid;
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1050, 680]);
m10Values = localMaximumSingularValue( ...
    m10.weightedClosedLoop10, frequencies);
semilogx(frequencies, 20 * log10(m10Values), 'k--', ...
    'LineWidth', 2, 'DisplayName', 'M10 ordine 18'); hold on;
colors = lines(max(1, numel(selection.paretoArchitectureIDs)));
for index = 1:numel(selection.paretoArchitectureIDs)
    id = selection.paretoArchitectureIDs(index);
    representative = representatives( ...
        [representatives.architectureID] == id);
    values = localMaximumSingularValue( ...
        representative.reconstruction.weightedClosedLoop, frequencies);
    semilogx(frequencies, 20 * log10(values), 'LineWidth', 1.6, ...
        'Color', colors(index, :), 'DisplayName', "M11 " + id);
end
yline(0, 'k:', 'HandleVisibility', 'off');
grid on; box on; xlim([frequencies(1), frequencies(end)]);
xlabel('Frequenza [rad/s]'); ylabel('Massima singular value [dB]');
title('M11 — candidati Pareto vs full-order M10');
legend('Location', 'southwest');
localPrepareFigure(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotTracking(selection, representatives, m10Evaluation, filePath)
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1150, 760]);
layout = tiledlayout(2, 1, 'TileSpacing', 'compact');
colors = lines(max(1, numel(selection.paretoArchitectureIDs)));
for jointIndex = 1:2
    axesHandle = nexttile;
    m6 = m10Evaluation.m6TrackingResponses{2, jointIndex};
    m10 = m10Evaluation.trackingResponses{2, jointIndex};
    plot(axesHandle, m6.time, rad2deg(m6.q(:, jointIndex)), ':', ...
        'LineWidth', 1.7, 'DisplayName', 'M6 LQG'); hold on;
    plot(axesHandle, m10.time, rad2deg(m10.q(:, jointIndex)), '--', ...
        'LineWidth', 2, 'DisplayName', 'M10 hinfsyn');
    for index = 1:numel(selection.paretoArchitectureIDs)
        id = selection.paretoArchitectureIDs(index);
        representative = representatives( ...
            [representatives.architectureID] == id);
        response = representative.evaluation. ...
            trackingResponses{2, jointIndex};
        plot(axesHandle, response.time, ...
            rad2deg(response.q(:, jointIndex)), 'LineWidth', 1.4, ...
            'Color', colors(index, :), 'DisplayName', "M11 " + id);
    end
    yline(axesHandle, 5, 'k-', 'r', 'HandleVisibility', 'off');
    grid(axesHandle, 'on'); box(axesHandle, 'on');
    ylabel(axesHandle, sprintf('delta q_%d [deg]', jointIndex));
    legend(axesHandle, 'Location', 'best');
end
xlabel(layout, 'Tempo [s]');
title(layout, 'Tracking 5 deg — Pareto M11 vs M6/M10');
layout.XLabel.Color = 'black';
layout.Title.Color = 'black';
localPrepareFigure(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotEffortDisturbance(comparison, filePath)
values = [comparison.worstTrackingPeakU / 12, ...
    comparison.worstDisturbancePeakU / 12, ...
    comparison.worstDisturbancePeakQ];
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1200, 680]);
bar(categorical(comparison.controller, comparison.controller), values);
grid on; box on;
ylabel('Valore worst-case');
legend('Tracking peak U/12', 'Disturbo peak U/12', ...
    'Disturbo peak q [rad]', 'Location', 'best');
title('M11 — sforzo normalizzato e risposta al disturbo');
localPrepareFigure(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function values = localMaximumSingularValue(system, frequencies)
response = freqresp(system, frequencies);
values = zeros(1, numel(frequencies));
for index = 1:numel(frequencies)
    singularValues = svd(response(:, :, index));
    values(index) = singularValues(1);
end
end

function localPrepareFigure(figureHandle)
axesHandles = findall(figureHandle, 'Type', 'axes');
set(axesHandles, 'Color', 'white', 'XColor', 'black', ...
    'YColor', 'black', 'GridColor', [0.65 0.65 0.65], ...
    'MinorGridColor', [0.82 0.82 0.82]);
legendHandles = findall(figureHandle, 'Type', 'legend');
set(legendHandles, 'Color', 'white', 'TextColor', 'black', ...
    'EdgeColor', [0.4 0.4 0.4]);
textHandles = findall(figureHandle, 'Type', 'text');
set(textHandles, 'Color', 'black');
end
