function figurePaths = plot_m10_results(reconstruction, evaluation, ...
    m5, m9, figureDirectory, config)
%PLOT_M10_RESULTS Generate the engineering figures required by M10.

arguments
    reconstruction (1, 1) struct
    evaluation (1, 1) struct
    m5 (1, 1) struct
    m9 (1, 1) struct
    figureDirectory (1, :) char
    config (1, 1) struct = hinf_specs_m10
end

if ~isfolder(figureDirectory), mkdir(figureDirectory); end
figurePaths.frequency = fullfile(figureDirectory, ...
    'm10_hinfsyn_frequency_domain.png');
figurePaths.weightedComparison = fullfile(figureDirectory, ...
    'm10_weighted_comparison_m9.png');
figurePaths.trackingComparison = fullfile(figureDirectory, ...
    'm10_tracking_comparison_m6_m9.png');
figurePaths.disturbanceComparison = fullfile(figureDirectory, ...
    'm10_disturbance_comparison_m6_m9.png');
figurePaths.controlEffort = fullfile(figureDirectory, ...
    'm10_control_effort_comparison.png');
figurePaths.poles = fullfile(figureDirectory, ...
    'm10_closed_loop_poles_comparison.png');

localPlotFrequency(reconstruction, m5, figurePaths.frequency, config);
localPlotWeightedComparison(reconstruction, m9, ...
    figurePaths.weightedComparison, config);
localPlotTrackingComparison(evaluation, figurePaths.trackingComparison);
localPlotDisturbanceComparison( ...
    evaluation, figurePaths.disturbanceComparison);
localPlotControlEffort(evaluation, figurePaths.controlEffort);
localPlotPoles(reconstruction, m9, figurePaths.poles);
end

function localPlotFrequency(reconstruction, m5, filePath, config)
frequencies = config.frequencyGrid;
Ssigma = localSingularValues(reconstruction.S, frequencies);
KSsigma = localSingularValues(reconstruction.KS, frequencies);
W1Ssigma = localSingularValues(reconstruction.weightedW1S, frequencies);
W2KSsigma = localSingularValues(reconstruction.weightedW2KS, frequencies);
inverseW1 = 1 ./ flipud(localSingularValues(m5.W1, frequencies));
inverseW2 = 1 ./ flipud(localSingularValues(m5.W2, frequencies));

figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1250, 850]);
layout = tiledlayout(2, 2, 'TileSpacing', 'compact');
axesHandle = nexttile;
localPlotSigma(axesHandle, frequencies, Ssigma, '-', [0.05 0.40 0.75]);
localPlotSigma(axesHandle, frequencies, inverseW1, '--', [0.80 0.25 0.15]);
title('S_{10} e 1/W_1'); ylabel('Singular value [dB]');
legend('S, sigma_1', 'S, sigma_2', '1/W_1, sigma_1', ...
    '1/W_1, sigma_2', 'Location', 'best');
axesHandle = nexttile;
localPlotSigma(axesHandle, frequencies, KSsigma, '-', [0.10 0.55 0.25]);
localPlotSigma(axesHandle, frequencies, inverseW2, '--', [0.65 0.25 0.70]);
title('KS_{10} e 1/W_2'); ylabel('Singular value [dB]');
legend('KS, sigma_1', 'KS, sigma_2', '1/W_2, sigma_1', ...
    '1/W_2, sigma_2', 'Location', 'best');
axesHandle = nexttile;
localPlotSigma(axesHandle, frequencies, W1Ssigma, '-', [0.05 0.40 0.75]);
yline(axesHandle, 0, 'k--', 'gamma target = 1', ...
    'HandleVisibility', 'off');
title('W_1S_{10}'); xlabel('Frequenza [rad/s]');
ylabel('Singular value [dB]');
axesHandle = nexttile;
localPlotSigma(axesHandle, frequencies, W2KSsigma, '-', [0.10 0.55 0.25]);
yline(axesHandle, 0, 'k--', 'gamma target = 1', ...
    'HandleVisibility', 'off');
title('W_2KS_{10}'); xlabel('Frequenza [rad/s]');
ylabel('Singular value [dB]');
title(layout, 'M10 — Ricostruzione mixed sensitivity hinfsyn', ...
    'Color', 'black');
localPrepareFigure(figureHandle);
set_scientific_figure_style(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotWeightedComparison(reconstruction, m9, filePath, config)
frequencies = config.frequencyGrid;
m9Sigma = localSingularValues(m9.weightedClosedLoop, frequencies);
m10Sigma = localSingularValues( ...
    reconstruction.weightedClosedLoop, frequencies);
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1000, 680]);
semilogx(frequencies, 20 * log10(m9Sigma(1, :)), '--', ...
    'LineWidth', 2.0, 'DisplayName', 'M9 mixsyn');
hold on;
semilogx(frequencies, 20 * log10(m10Sigma(1, :)), '-', ...
    'LineWidth', 1.4, 'DisplayName', 'M10 hinfsyn');
yline(0, 'k:', 'gamma target = 1', 'HandleVisibility', 'off');
grid on; box on; xlim([frequencies(1), frequencies(end)]);
xlabel('Frequenza [rad/s]'); ylabel('Massima singular value [dB]');
title('M9/M10 — Mappa pesata quasi equivalente');
legend('Location', 'best');
localPrepareFigure(figureHandle);
set_scientific_figure_style(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotTrackingComparison(evaluation, filePath)
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1150, 760]);
layout = tiledlayout(2, 1, 'TileSpacing', 'compact');
for jointIndex = 1:2
    axesHandle = nexttile;
    current = evaluation.trackingResponses{2, jointIndex};
    m9 = evaluation.m9TrackingResponses{2, jointIndex};
    m6 = evaluation.m6TrackingResponses{2, jointIndex};
    plot(axesHandle, m6.time, rad2deg(m6.q(:, jointIndex)), ':', ...
        'LineWidth', 1.7, 'DisplayName', 'M6 LQG'); hold on;
    plot(axesHandle, m9.time, rad2deg(m9.q(:, jointIndex)), '--', ...
        'LineWidth', 2.0, 'DisplayName', 'M9 mixsyn');
    plot(axesHandle, current.time, rad2deg(current.q(:, jointIndex)), '-', ...
        'LineWidth', 1.3, 'DisplayName', 'M10 hinfsyn');
    yline(axesHandle, 5, 'k-', 'r', 'HandleVisibility', 'off');
    grid(axesHandle, 'on'); box(axesHandle, 'on');
    ylabel(axesHandle, sprintf('delta q_%d [deg]', jointIndex));
    legend(axesHandle, 'Location', 'best');
end
xlabel(layout, 'Tempo [s]', 'Color', 'black');
title(layout, 'Tracking 5 deg — confronto M6/M9/M10', 'Color', 'black');
localPrepareFigure(figureHandle);
set_scientific_figure_style(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotDisturbanceComparison(evaluation, filePath)
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1150, 760]);
layout = tiledlayout(2, 1, 'TileSpacing', 'compact');
for jointIndex = 1:2
    axesHandle = nexttile;
    current = evaluation.disturbanceResponses{2, jointIndex};
    m9 = evaluation.m9DisturbanceResponses{2, jointIndex};
    m6 = evaluation.m6DisturbanceResponses{2, jointIndex};
    plot(axesHandle, m6.time, rad2deg(m6.q(:, jointIndex)), ':', ...
        'LineWidth', 1.7, 'DisplayName', 'M6 LQG'); hold on;
    plot(axesHandle, m9.time, rad2deg(m9.q(:, jointIndex)), '--', ...
        'LineWidth', 2.0, 'DisplayName', 'M9 mixsyn');
    plot(axesHandle, current.time, rad2deg(current.q(:, jointIndex)), '-', ...
        'LineWidth', 1.3, 'DisplayName', 'M10 hinfsyn');
    grid(axesHandle, 'on'); box(axesHandle, 'on');
    ylabel(axesHandle, sprintf('delta q_%d [deg]', jointIndex));
    legend(axesHandle, 'Location', 'best');
end
xlabel(layout, 'Tempo [s]', 'Color', 'black');
title(layout, 'Disturbo 0.5 N m — confronto M6/M9/M10', ...
    'Color', 'black');
localPrepareFigure(figureHandle);
set_scientific_figure_style(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotControlEffort(evaluation, filePath)
summary = evaluation.comparison.summary;
uScale = evaluation.controlEffort.uScaleNm;
values = [summary.worstTrackingPeakU, summary.worstDisturbancePeakU] / ...
    uScale;
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1050, 650]);
bar(categorical(summary.controller, summary.controller), values);
yline(1, 'k--', 'u/u_{scale}=1', 'HandleVisibility', 'off');
grid on; box on;
ylabel(sprintf('Worst peak |u| / %.6g N m', uScale));
legend('Tracking', 'Disturbo', 'Location', 'best');
title(['Sforzo normalizzato — confronto M6/M9/M10; ' ...
    'nessuna saturazione']);
localPrepareFigure(figureHandle);
set_scientific_figure_style(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotPoles(reconstruction, m9, filePath)
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 900, 680]);
scatter(real(m9.closedLoopPoles), imag(m9.closedLoopPoles), ...
    56, [0.80 0.30 0.12], 'o', 'LineWidth', 1.3, ...
    'DisplayName', 'M9 mixsyn'); hold on;
scatter(real(reconstruction.internalPoles), ...
    imag(reconstruction.internalPoles), 44, [0.05 0.42 0.72], 'x', ...
    'LineWidth', 1.3, 'DisplayName', 'M10 hinfsyn');
xline(0, 'k--', 'HandleVisibility', 'off'); grid on; box on;
xlabel('Parte reale [s^{-1}]'); ylabel('Parte immaginaria [rad/s]');
title('Poli interni nominali M9/M10'); legend('Location', 'best');
localPrepareFigure(figureHandle);
set_scientific_figure_style(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function values = localSingularValues(system, frequencies)
response = freqresp(system, frequencies);
values = zeros(min(size(system)), numel(frequencies));
for index = 1:numel(frequencies)
    singularValues = svd(response(:, :, index));
    values(:, index) = singularValues(1:size(values, 1));
end
end

function localPlotSigma(axesHandle, frequencies, values, style, color)
hold(axesHandle, 'on');
for index = 1:size(values, 1)
    semilogx(axesHandle, frequencies, 20 * log10(values(index, :)), ...
        style, 'Color', color, 'LineWidth', 1.7);
end
grid(axesHandle, 'on'); box(axesHandle, 'on');
set(axesHandle, 'XScale', 'log');
xlim(axesHandle, [frequencies(1), frequencies(end)]);
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
