function figurePaths = plot_m9_results( ...
    reconstruction, evaluation, plant, m3, m5, figureDirectory, config)
%PLOT_M9_RESULTS Generate the engineering figures required by M9.

arguments
    reconstruction (1, 1) struct
    evaluation (1, 1) struct
    plant (1, 1) struct
    m3 (1, 1) struct
    m5 (1, 1) struct
    figureDirectory (1, :) char
    config (1, 1) struct = hinf_specs_m9
end

if ~isfolder(figureDirectory), mkdir(figureDirectory); end
figurePaths.frequency = fullfile(figureDirectory, ...
    'm9_mixsyn_frequency_domain.png');
figurePaths.tracking = fullfile(figureDirectory, ...
    'm9_mixsyn_tracking.png');
figurePaths.disturbance = fullfile(figureDirectory, ...
    'm9_mixsyn_disturbance.png');
figurePaths.controlEffort = fullfile(figureDirectory, ...
    'm9_mixsyn_control_effort.png');
figurePaths.comparisonM6 = fullfile(figureDirectory, ...
    'm9_mixsyn_comparison_m6.png');
figurePaths.poles = fullfile(figureDirectory, ...
    'm9_mixsyn_closed_loop_poles.png');

localPlotFrequency(reconstruction, plant, m3, m5, ...
    figurePaths.frequency, config);
localPlotTracking(evaluation, figurePaths.tracking);
localPlotDisturbance(evaluation, figurePaths.disturbance);
localPlotControlEffort(evaluation, figurePaths.controlEffort);
localPlotComparison(evaluation, figurePaths.comparisonM6);
localPlotPoles(reconstruction, figurePaths.poles);
end

function localPlotFrequency(reconstruction, plant, m3, m5, filePath, config)
frequencies = config.frequencyGrid;
Ssigma = localSingularValues(reconstruction.S, frequencies);
KSsigma = localSingularValues(reconstruction.KS, frequencies);
W1Ssigma = localSingularValues(reconstruction.weightedW1S, frequencies);
W2KSsigma = localSingularValues(reconstruction.weightedW2KS, frequencies);
stackedSigma = localSingularValues( ...
    reconstruction.weightedClosedLoop, frequencies);
inverseW1Sigma = localInverseSingularValues(m5.W1, frequencies);
inverseW2Sigma = localInverseSingularValues(m5.W2, frequencies);

figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1250, 850]);
layout = tiledlayout(2, 2, 'TileSpacing', 'compact');

axesHandle = nexttile;
localPlotSigmaSet(axesHandle, frequencies, Ssigma, '-', [0.05 0.40 0.75]);
localPlotSigmaSet(axesHandle, frequencies, inverseW1Sigma, '--', [0.80 0.25 0.15]);
localFrequencyMarkers(axesHandle, plant, m3, m5);
title('Sensitivity S e limite 1/W_1'); ylabel('Singular value [dB]');
legend('S, sigma_1', 'S, sigma_2', '1/W_1, sigma_1', ...
    '1/W_1, sigma_2', 'Location', 'best');

axesHandle = nexttile;
localPlotSigmaSet(axesHandle, frequencies, KSsigma, '-', [0.10 0.55 0.25]);
localPlotSigmaSet(axesHandle, frequencies, inverseW2Sigma, '--', [0.65 0.25 0.70]);
localFrequencyMarkers(axesHandle, plant, m3, m5);
title('Control sensitivity KS e limite 1/W_2');
ylabel('Singular value [dB]');
legend('KS, sigma_1', 'KS, sigma_2', '1/W_2, sigma_1', ...
    '1/W_2, sigma_2', 'Location', 'best');

axesHandle = nexttile;
localPlotSigmaSet(axesHandle, frequencies, W1Ssigma, '-', [0.05 0.40 0.75]);
yline(axesHandle, 0, 'k--', 'gamma target = 1', ...
    'HandleVisibility', 'off');
localFrequencyMarkers(axesHandle, plant, m3, m5);
title('Prestazione pesata W_1S');
xlabel('Frequenza [rad/s]'); ylabel('Singular value [dB]');

axesHandle = nexttile;
localPlotSigmaSet(axesHandle, frequencies, W2KSsigma, '-', [0.10 0.55 0.25]);
semilogx(axesHandle, frequencies, 20 * log10(stackedSigma(1, :)), ...
    'k-', 'LineWidth', 2, 'DisplayName', 'stacked max');
yline(axesHandle, 0, 'k--', 'gamma target = 1', ...
    'HandleVisibility', 'off');
localFrequencyMarkers(axesHandle, plant, m3, m5);
title('Sforzo pesato W_2KS e stack');
xlabel('Frequenza [rad/s]'); ylabel('Singular value [dB]');
legend('W_2KS, sigma_1', 'W_2KS, sigma_2', 'stacked max', ...
    'Location', 'best');

title(layout, 'M9 — Mixed sensitivity nominale con pesi M5 congelati', ...
    'Color', 'black');
localPrepareFigure(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotTracking(evaluation, filePath)
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1200, 850]);
layout = tiledlayout(3, 2, 'TileSpacing', 'compact');
for amplitudeIndex = 1:3
    for jointIndex = 1:2
        axesHandle = nexttile;
        response = evaluation.trackingResponses{amplitudeIndex, jointIndex};
        plot(axesHandle, response.time, rad2deg(response.q(:, jointIndex)), ...
            'LineWidth', 1.6, 'DisplayName', sprintf('q_%d', jointIndex));
        hold(axesHandle, 'on');
        otherJoint = 3 - jointIndex;
        plot(axesHandle, response.time, rad2deg(response.q(:, otherJoint)), ...
            'LineWidth', 1.3, 'DisplayName', sprintf('q_%d', otherJoint));
        yline(axesHandle, response.amplitudeDeg, 'k--', 'r', ...
            'HandleVisibility', 'off');
        localStyleAxes(axesHandle);
        title(axesHandle, sprintf('%g deg, r_%d', ...
            response.amplitudeDeg, jointIndex));
        ylabel(axesHandle, 'delta q [deg]');
        if amplitudeIndex == 1 && jointIndex == 1
            legend(axesHandle, 'Location', 'best');
        end
    end
end
xlabel(layout, 'Tempo [s]', 'Color', 'black');
title(layout, 'M9 — Tracking nominale 1-DoF mixsyn', 'Color', 'black');
localPrepareFigure(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotDisturbance(evaluation, filePath)
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1100, 740]);
layout = tiledlayout(2, 1, 'TileSpacing', 'compact');
for jointIndex = 1:2
    axesHandle = nexttile;
    for amplitudeIndex = 1:3
        response = evaluation.disturbanceResponses{amplitudeIndex, jointIndex};
        plot(axesHandle, response.time, ...
            rad2deg(response.q(:, jointIndex)), 'LineWidth', 1.5, ...
            'DisplayName', sprintf('%.2f N m', response.amplitudeNm));
        hold(axesHandle, 'on');
    end
    localStyleAxes(axesHandle);
    ylabel(axesHandle, sprintf('delta q_%d [deg]', jointIndex));
    legend(axesHandle, 'Location', 'best');
end
xlabel(layout, 'Tempo [s]', 'Color', 'black');
title(layout, 'M9 — Disturbo fisico costante lato link', 'Color', 'black');
localPrepareFigure(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotControlEffort(evaluation, filePath)
tracking = evaluation.trackingMetrics;
disturbance = evaluation.disturbanceMetrics;
labelsTracking = compose('%g deg r%d', tracking.AmplitudeDeg, tracking.Joint);
labelsDisturbance = compose('%.2f Nm d%d', ...
    disturbance.AmplitudeNm, disturbance.Joint);
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1200, 680]);
layout = tiledlayout(2, 1, 'TileSpacing', 'compact');
axesHandle = nexttile;
bar(axesHandle, categorical(labelsTracking, labelsTracking), ...
    tracking.PeakControlNormalized, 'FaceColor', [0.05 0.45 0.75]);
yline(axesHandle, 1, 'k--', 'u/u_{scale}=1', ...
    'HandleVisibility', 'off');
localStyleAxes(axesHandle); ylabel(axesHandle, 'peak |u| / 12 N m');
title(axesHandle, 'Tracking');
axesHandle = nexttile;
bar(axesHandle, categorical(labelsDisturbance, labelsDisturbance), ...
    disturbance.PeakControlNormalized, 'FaceColor', [0.80 0.35 0.15]);
yline(axesHandle, 1, 'k--', 'u/u_{scale}=1', ...
    'HandleVisibility', 'off');
localStyleAxes(axesHandle); ylabel(axesHandle, 'peak |u| / 12 N m');
title(axesHandle, 'Disturbo lato link');
title(layout, ['M9 — Sforzo di controllo normalizzato; ' ...
    'nessuna saturazione hardware'], 'Color', 'black');
localPrepareFigure(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotComparison(evaluation, filePath)
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1150, 780]);
layout = tiledlayout(2, 2, 'TileSpacing', 'compact');
for jointIndex = 1:2
    axesHandle = nexttile;
    m9 = evaluation.trackingResponses{2, jointIndex};
    m6 = evaluation.m6TrackingResponses{2, jointIndex};
    plot(axesHandle, m9.time, rad2deg(m9.q(:, jointIndex)), ...
        'LineWidth', 1.6, 'DisplayName', 'M9 mixsyn');
    hold(axesHandle, 'on');
    plot(axesHandle, m6.time, rad2deg(m6.q(:, jointIndex)), '--', ...
        'LineWidth', 1.5, 'DisplayName', 'M6 LQG');
    yline(axesHandle, 5, 'k:', 'r', 'HandleVisibility', 'off');
    localStyleAxes(axesHandle);
    title(axesHandle, sprintf('Tracking 5 deg, giunto %d', jointIndex));
    ylabel(axesHandle, 'delta q [deg]');
    if jointIndex == 1, legend(axesHandle, 'Location', 'best'); end
end
for jointIndex = 1:2
    axesHandle = nexttile;
    m9 = evaluation.disturbanceResponses{2, jointIndex};
    m6 = evaluation.m6DisturbanceResponses{2, jointIndex};
    plot(axesHandle, m9.time, rad2deg(m9.q(:, jointIndex)), ...
        'LineWidth', 1.6, 'DisplayName', 'M9 mixsyn');
    hold(axesHandle, 'on');
    plot(axesHandle, m6.time, rad2deg(m6.q(:, jointIndex)), '--', ...
        'LineWidth', 1.5, 'DisplayName', 'M6 LQG');
    localStyleAxes(axesHandle);
    title(axesHandle, sprintf('Disturbo 0.5 N m, giunto %d', jointIndex));
    ylabel(axesHandle, 'delta q [deg]'); xlabel(axesHandle, 'Tempo [s]');
end
title(layout, 'M9 — Confronto diagnostico nominale con M6', ...
    'Color', 'black');
localPrepareFigure(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotPoles(reconstruction, filePath)
poles = reconstruction.internalPoles;
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 900, 680]);
scatter(real(poles), imag(poles), 52, [0.05 0.42 0.72], 'x', ...
    'LineWidth', 1.5);
xline(0, 'k--'); grid on; box on;
xlabel('Parte reale [s^{-1}]'); ylabel('Parte immaginaria [rad/s]');
title('M9 — Poli dell''interconnessione interna nominale');
localPrepareFigure(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function values = localSingularValues(system, frequencies)
response = freqresp(system, frequencies);
numberValues = min(size(system));
values = zeros(numberValues, numel(frequencies));
for index = 1:numel(frequencies)
    singularValues = svd(response(:, :, index));
    values(:, index) = singularValues(1:numberValues);
end
end

function values = localInverseSingularValues(system, frequencies)
direct = localSingularValues(system, frequencies);
values = 1 ./ flipud(direct);
end

function localPlotSigmaSet(axesHandle, frequencies, values, style, color)
hold(axesHandle, 'on');
for index = 1:size(values, 1)
    semilogx(axesHandle, frequencies, 20 * log10(values(index, :)), ...
        style, 'Color', color, 'LineWidth', 1.7);
end
localStyleFrequencyAxes(axesHandle);
end

function localFrequencyMarkers(axesHandle, plant, m3, m5)
xline(axesHandle, m5.spec.omegaB, ':', 'omega_B', ...
    'HandleVisibility', 'off');
xline(axesHandle, m5.spec.omegaU, ':', 'omega_U', ...
    'HandleVisibility', 'off');
xline(axesHandle, m3.actuatorInfo.actuatorBandwidth, ':', 'BW act', ...
    'HandleVisibility', 'off');
elastic = abs(m3.fullPoles(imag(m3.fullPoles) > 1));
if ~isempty(elastic)
    xline(axesHandle, min(elastic), ':', 'modo elastico', ...
        'HandleVisibility', 'off');
end
if ~isempty(plant.audit.rightHalfPlaneZeros)
    xline(axesHandle, min(real(plant.audit.rightHalfPlaneZeros)), ':', ...
        'zero RHP', 'HandleVisibility', 'off');
end
end

function localStyleAxes(axesHandle)
grid(axesHandle, 'on'); box(axesHandle, 'on');
end

function localStyleFrequencyAxes(axesHandle)
localStyleAxes(axesHandle);
set(axesHandle, 'XScale', 'log', 'XLim', [1e-3 1e3]);
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
