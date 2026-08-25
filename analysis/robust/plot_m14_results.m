function figurePaths = plot_m14_results(m12, manualMu, nominalAudit, ...
    robustStability, robustPerformance, criticalBlockTable, ...
    summaryTable, figureDirectory, config)
%PLOT_M14_RESULTS Plot the final Kmu analysis and frozen A5 comparison.

arguments
    m12 (1, 1) struct
    manualMu (1, 1) struct
    nominalAudit (1, 1) struct
    robustStability (1, 1) struct
    robustPerformance (1, 1) struct
    criticalBlockTable table
    summaryTable table
    figureDirectory (1, :) char
    config (1, 1) struct = mu_analysis_specs_m14
end

if ~isfolder(figureDirectory), mkdir(figureDirectory); end
figurePaths.muRSComparison = fullfile(figureDirectory, ...
    'm14_mu_rs_bounds_kmu_vs_a5.png');
figurePaths.rsMarginComparison = fullfile(figureDirectory, ...
    'm14_rs_margins_a5_vs_kmu.png');
figurePaths.nominalWeightedComparison = fullfile(figureDirectory, ...
    'm14_nominal_weighted_a5_vs_kmu.png');
figurePaths.worstWeightedKmu = fullfile(figureDirectory, ...
    'm14_worst_case_weighted_kmu.png');
figurePaths.rsSensitivityComparison = fullfile(figureDirectory, ...
    'm14_rs_sensitivity_a5_vs_kmu.png');
figurePaths.summary = fullfile(figureDirectory, ...
    'm14_ns_np_rs_rp_summary.png');

localPlotMuComparison(m12.manualMuRS, manualMu, ...
    figurePaths.muRSComparison);
localPlotMarginComparison(m12.robustStability, robustStability, ...
    figurePaths.rsMarginComparison);
localPlotNominalComparison(m12.nominalReconstruction.weightedClosedLoop, ...
    nominalAudit.weightedClosedLoop, config.auditFrequencyGrid, ...
    figurePaths.nominalWeightedComparison);
localPlotWorstKmu(nominalAudit.weightedClosedLoop, ...
    robustPerformance.worstGainLoop, config.auditFrequencyGrid, ...
    figurePaths.worstWeightedKmu);
localPlotSensitivity(criticalBlockTable, ...
    figurePaths.rsSensitivityComparison);
localPlotSummary(summaryTable, figurePaths.summary);
end

function localPlotMuComparison(a5, kmu, filePath)
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1100, 670]);
semilogx(a5.frequencyGrid, a5.upperBound, '--', ...
    'LineWidth', 1.5, 'DisplayName', 'A5 upper'); hold on;
semilogx(a5.frequencyGrid, a5.lowerBound, '--', ...
    'LineWidth', 1.5, 'DisplayName', 'A5 lower');
semilogx(kmu.frequencyGrid, kmu.upperBound, '-', ...
    'LineWidth', 1.9, 'DisplayName', 'Kmu upper');
semilogx(kmu.frequencyGrid, kmu.lowerBound, '-', ...
    'LineWidth', 1.9, 'DisplayName', 'Kmu lower');
yline(1, 'k:', 'mu=1', 'HandleVisibility', 'off');
grid on; box on;
xlabel('Frequenza [rad/s]'); ylabel('Bound di mu');
title('M14 — bound mu RS: Kmu vs A5');
legend('Location', 'best');
localStyle(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotMarginComparison(a5, kmu, filePath)
lower = [a5.margin.LowerBound; kmu.margin.LowerBound];
upper = [a5.margin.UpperBound; kmu.margin.UpperBound];
center = (lower + upper) / 2;
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 900, 620]);
errorbar(1:2, center, center - lower, upper - center, 'o', ...
    'LineWidth', 2, 'MarkerSize', 9); hold on;
yline(1, 'k--', 'margine unitario', 'HandleVisibility', 'off');
set(gca, 'XTick', 1:2, 'XTickLabel', {'A5 M12', 'Kmu M14'});
xlim([0.5, 2.5]); grid on; box on;
ylabel('Robust stability margin');
title('M14 — confronto dei bound robstab');
localStyle(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotNominalComparison(a5, kmu, frequencies, filePath)
a5Values = localMaximumSingularValue(a5, frequencies);
kmuValues = localMaximumSingularValue(kmu, frequencies);
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1050, 650]);
semilogx(frequencies, 20 * log10(a5Values), '--', ...
    'LineWidth', 1.6, 'DisplayName', 'A5 M12'); hold on;
semilogx(frequencies, 20 * log10(kmuValues), '-', ...
    'LineWidth', 1.9, 'DisplayName', 'Kmu M14');
yline(0, 'k:', 'gamma=1', 'HandleVisibility', 'off');
grid on; box on;
xlabel('Frequenza [rad/s]');
ylabel('Massima singular value pesata [dB]');
title('M14 — risposta pesata nominale A5/Kmu');
legend('Location', 'best');
localStyle(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotWorstKmu(nominal, worst, frequencies, filePath)
nominalValues = localMaximumSingularValue(nominal, frequencies);
worstValues = localMaximumSingularValue(worst, frequencies);
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1050, 650]);
semilogx(frequencies, 20 * log10(nominalValues), ...
    'LineWidth', 1.7, 'DisplayName', 'Kmu nominale'); hold on;
semilogx(frequencies, 20 * log10(worstValues), ...
    'LineWidth', 1.9, 'DisplayName', 'Kmu worst-case wcgain');
yline(0, 'k:', 'gamma=1', 'HandleVisibility', 'off');
grid on; box on;
xlabel('Frequenza [rad/s]');
ylabel('Massima singular value pesata [dB]');
title('M14 — risposta pesata Kmu nominale e worst-case');
legend('Location', 'best');
localStyle(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotSensitivity(tableData, filePath)
values = [tableData.A5RSSensitivity, tableData.RSSensitivity];
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1050, 650]);
bar(categorical(tableData.BlockName, tableData.BlockName), values);
set(gca, 'TickLabelInterpreter', 'none');
grid on; box on;
ylabel('Sensitivity robstab [%]');
title('M14 — sensibilità RS dei blocchi: A5 vs Kmu');
legend('A5 M12', 'Kmu M14', 'Location', 'best');
localStyle(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotSummary(summaryTable, filePath)
score = -ones(height(summaryTable), 1);
score(contains(summaryTable.Outcome, "PASS")) = 1;
score(contains(summaryTable.Outcome, "INCONCLUSIVE")) = 0;
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 850, 600]);
bar(categorical(summaryTable.Property, summaryTable.Property), score);
ylim([-1.2, 1.2]); yticks([-1, 0, 1]);
yticklabels({'FAIL', 'INCONCLUSIVE', 'PASS'});
yline(0, 'k-', 'HandleVisibility', 'off');
grid on; box on; ylabel('Classificazione');
title('M14 — esiti finali separati NS / NP / RS / RP');
localStyle(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function values = localMaximumSingularValue(system, frequencies)
response = freqresp(system, frequencies);
values = zeros(numel(frequencies), 1);
for index = 1:numel(frequencies)
    singularValues = svd(response(:, :, index));
    values(index) = max(singularValues);
end
values = max(values, realmin);
end

function localStyle(figureHandle)
axesHandles = findall(figureHandle, 'Type', 'axes');
set(axesHandles, 'Color', 'white', 'XColor', 'black', ...
    'YColor', 'black', 'GridColor', [0.65 0.65 0.65]);
legendHandles = findall(figureHandle, 'Type', 'legend');
set(legendHandles, 'Color', 'white', 'TextColor', 'black', ...
    'EdgeColor', [0.4 0.4 0.4]);
textHandles = findall(figureHandle, 'Type', 'text');
set(textHandles, 'Color', 'black');
end
