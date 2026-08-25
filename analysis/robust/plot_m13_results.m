function figurePaths = plot_m13_results( ...
    history, nominalAudit, m10, m11, synthesis, figureDirectory)
%PLOT_M13_RESULTS Create the six required D-K synthesis diagnostics.

arguments
    history (1, 1) struct
    nominalAudit (1, 1) struct
    m10 (1, 1) struct
    m11 (1, 1) struct
    synthesis (1, 1) struct
    figureDirectory (1, 1) string
end

if ~isfolder(figureDirectory), mkdir(figureDirectory); end
tableData = history.table;

figurePaths.objectiveHistory = fullfile(figureDirectory, ...
    'm13_dk_objective_history.png');
fig = localFigure;
plot(tableData.Iteration, tableData.PeakMuUpper, '-o', ...
    'LineWidth', 1.6, 'DisplayName', 'Peak \mu upper'); hold on;
if any(isfinite(tableData.PeakMuLower))
    plot(tableData.Iteration, tableData.PeakMuLower, '--s', ...
        'LineWidth', 1.3, 'DisplayName', 'Peak \mu lower');
end
yline(synthesis.musynObjective, ':', 'LineWidth', 1.3, ...
    'DisplayName', 'Final musyn objective');
xlabel('D-K iteration'); ylabel('Reported robust objective');
title('M13 D-K objective history'); grid on; legend('Location', 'best');
exportgraphics(fig, figurePaths.objectiveHistory, 'Resolution', 180);
close(fig);

figurePaths.dScaleOrder = fullfile(figureDirectory, ...
    'm13_d_scale_order_history.png');
fig = localFigure;
if any(isfinite(tableData.DScaleOrder))
    stairs(tableData.Iteration, tableData.DScaleOrder, '-o', ...
        'LineWidth', 1.6);
    ylabel('Maximum reported D/G fit order');
else
    axis([0.5, max(1.5, height(tableData) + 0.5), 0, 1]);
    text(mean(xlim), 0.5, 'D/G fit order unavailable in normalized output', ...
        'HorizontalAlignment', 'center');
    ylabel('Availability');
end
xlabel('D-K iteration'); title('M13 D/G scaling fit order'); grid on;
exportgraphics(fig, figurePaths.dScaleOrder, 'Resolution', 180);
close(fig);

figurePaths.controllerOrder = fullfile(figureDirectory, ...
    'm13_controller_order_history.png');
fig = localFigure;
stairs(tableData.Iteration, tableData.ControllerOrder, '-o', ...
    'LineWidth', 1.6);
hold on;
yline(synthesis.controllerOrder, ':', 'LineWidth', 1.3, ...
    'DisplayName', 'Returned best controller');
xlabel('D-K iteration'); ylabel('Controller order');
title('M13 controller complexity through D-K iterations'); grid on;
legend({'Iteration controller', 'Returned best controller'}, ...
    'Location', 'best');
exportgraphics(fig, figurePaths.controllerOrder, 'Resolution', 180);
close(fig);

a5Index = find(string({m11.representativeResults.architectureID}) == ...
    "A5", 1);
frequencies = logspace(-3, 4, 800);
m10Curve = localPeakSigma(m10.weightedClosedLoop10, frequencies);
a5Curve = localPeakSigma( ...
    m11.representativeResults(a5Index).reconstruction.weightedClosedLoop, ...
    frequencies);
kmuCurve = localPeakSigma(nominalAudit.weightedClosedLoop, frequencies);
figurePaths.nominalWeighted = fullfile(figureDirectory, ...
    'm13_nominal_weighted_comparison.png');
fig = localFigure;
loglog(frequencies, m10Curve, 'LineWidth', 1.5, ...
    'DisplayName', 'M10 full-order Hinf'); hold on;
loglog(frequencies, a5Curve, '--', 'LineWidth', 1.5, ...
    'DisplayName', 'M11 A5');
loglog(frequencies, kmuCurve, '-.', 'LineWidth', 1.7, ...
    'DisplayName', 'M13 Kmu');
yline(1, ':', 'DisplayName', 'Unit target');
xlabel('Frequency [rad/s]'); ylabel('Maximum singular value');
title('Nominal weighted closed-loop comparison'); grid on;
legend('Location', 'best');
exportgraphics(fig, figurePaths.nominalWeighted, 'Resolution', 180);
close(fig);

figurePaths.poles = fullfile(figureDirectory, 'm13_nominal_poles.png');
fig = localFigure;
layout = tiledlayout(1, 2, 'TileSpacing', 'compact');
localPoleAxes(nexttile, nominalAudit, []);
title('Full pole set');
localPoleAxes(nexttile, nominalAudit, [-250, 2]);
title('Dominant-region detail');
title(layout, 'M13 nominal pole audit');
exportgraphics(fig, figurePaths.poles, 'Resolution', 180);
close(fig);

figurePaths.convergenceSummary = fullfile(figureDirectory, ...
    'm13_dk_convergence_summary.png');
fig = localFigure;
values = [tableData.PeakMuUpper(1), history.bestPeakMuUpper, ...
    synthesis.musynObjective];
bar(categorical({'First iteration', 'Best history', 'Final objective'}), ...
    values);
ylabel('Reported robust objective'); grid on;
title(sprintf('M13 D-K: %s, %d/%d iterations', ...
    history.terminationClassification, history.iterationCount, ...
    numel(tableData.Iteration) + max(0, ...
        synthesis.optionsSnapshot.MaxIter - history.iterationCount)), ...
    'Interpreter', 'none');
exportgraphics(fig, figurePaths.convergenceSummary, 'Resolution', 180);
close(fig);
end

function fig = localFigure
fig = figure('Visible', 'off', 'Color', 'w', ...
    'Position', [100, 100, 900, 560]);
end

function peak = localPeakSigma(system, frequencies)
response = freqresp(localClearNames(ss(system)), frequencies);
peak = zeros(size(frequencies));
for index = 1:numel(frequencies)
    peak(index) = max(svd(response(:, :, index)));
end
end

function system = localClearNames(system)
system.InputName = repmat({''}, size(system, 2), 1);
system.OutputName = repmat({''}, size(system, 1), 1);
end

function localPoleAxes(axesHandle, nominalAudit, xLimits)
plot(axesHandle, real(nominalAudit.controllerPoles), ...
    imag(nominalAudit.controllerPoles), 'x', 'MarkerSize', 7, ...
    'LineWidth', 1.2, 'DisplayName', 'Kmu poles');
hold(axesHandle, 'on');
plot(axesHandle, real(nominalAudit.internalPoles), ...
    imag(nominalAudit.internalPoles), 'o', 'MarkerSize', 4, ...
    'LineWidth', 1.0, 'DisplayName', 'Nominal internal poles');
xline(axesHandle, 0, 'k:', 'HandleVisibility', 'off');
if ~isempty(xLimits), xlim(axesHandle, xLimits); end
xlabel(axesHandle, 'Real part [rad/s]');
ylabel(axesHandle, 'Imaginary part [rad/s]');
grid(axesHandle, 'on');
legend(axesHandle, 'Location', 'best');
end
