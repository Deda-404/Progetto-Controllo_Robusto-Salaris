function figurePaths = plot_m12_results(manualMu, nominalAudit, ...
    robustStability, robustPerformance, criticalBlockTable, ...
    summaryTable, figureDirectory, config)
%PLOT_M12_RESULTS Generate engineering figures for NS/NP/RS/RP.

arguments
    manualMu (1, 1) struct
    nominalAudit (1, 1) struct
    robustStability (1, 1) struct
    robustPerformance (1, 1) struct
    criticalBlockTable table
    summaryTable table
    figureDirectory (1, :) char
    config (1, 1) struct = mu_analysis_specs_m12
end

if ~isfolder(figureDirectory), mkdir(figureDirectory); end
figurePaths.muRS = fullfile(figureDirectory, ...
    'm12_mu_rs_bounds.png');
figurePaths.weightedWorst = fullfile(figureDirectory, ...
    'm12_weighted_nominal_vs_worst.png');
figurePaths.rsMargin = fullfile(figureDirectory, ...
    'm12_robust_stability_margin.png');
figurePaths.worstPerformance = fullfile(figureDirectory, ...
    'm12_worst_case_weighted_performance.png');
figurePaths.blockSensitivity = fullfile(figureDirectory, ...
    'm12_uncertainty_block_diagnostics.png');
figurePaths.summary = fullfile(figureDirectory, ...
    'm12_ns_np_rs_rp_summary.png');

localPlotMu(manualMu, figurePaths.muRS);
localPlotWeighted(nominalAudit.weightedClosedLoop, ...
    robustPerformance.worstGainLoop, config.auditFrequencyGrid, ...
    figurePaths.weightedWorst);
localPlotStabilityMargins(robustStability, manualMu, ...
    figurePaths.rsMargin);
localPlotWorstPerformance(nominalAudit, robustPerformance, ...
    config, figurePaths.worstPerformance);
localPlotBlockDiagnostics(criticalBlockTable, ...
    figurePaths.blockSensitivity);
localPlotSummary(summaryTable, figurePaths.summary);
end

function localPlotMu(manualMu, filePath)
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1050, 650]);
semilogx(manualMu.frequencyGrid, manualMu.upperBound, ...
    'LineWidth', 1.8, 'DisplayName', 'mu upper'); hold on;
semilogx(manualMu.frequencyGrid, manualMu.lowerBound, ...
    'LineWidth', 1.8, 'DisplayName', 'mu lower');
yline(1, 'k--', 'mu=1', 'HandleVisibility', 'off');
grid on; box on;
xlabel('Frequenza [rad/s]'); ylabel('Bound di mu');
title('M12 — structured singular value per Robust Stability');
legend('Location', 'best');
localStyle(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotWeighted(nominal, worst, frequencies, filePath)
nominalValues = localMaximumSingularValue(nominal, frequencies);
worstValues = localMaximumSingularValue(worst, frequencies);
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1050, 650]);
semilogx(frequencies, 20 * log10(nominalValues), ...
    'LineWidth', 1.8, 'DisplayName', 'Nominale A5'); hold on;
semilogx(frequencies, 20 * log10(worstValues), ...
    'LineWidth', 1.8, 'DisplayName', 'Worst-case wcgain');
yline(0, 'k--', 'gamma=1', 'HandleVisibility', 'off');
grid on; box on;
xlabel('Frequenza [rad/s]'); ylabel('Massima singular value [dB]');
title('M12 — weighted closed loop nominale e worst-case');
legend('Location', 'best');
localStyle(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotStabilityMargins(robustStability, manualMu, filePath)
lower = [robustStability.margin.LowerBound; ...
    manualMu.marginLowerApproximation];
upper = [robustStability.margin.UpperBound; ...
    manualMu.marginUpperApproximation];
center = (lower + upper) / 2;
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 900, 620]);
errorbar(1:2, center, center - lower, upper - center, 'o', ...
    'LineWidth', 2, 'MarkerSize', 8); hold on;
yline(1, 'k--', 'margine unitario', 'HandleVisibility', 'off');
set(gca, 'XTick', 1:2, 'XTickLabel', {'robstab', 'mussv manuale'});
xlim([0.5, 2.5]); grid on; box on;
ylabel('Robust stability margin');
title(sprintf('M12 — RS, frequenza critica %.3f rad/s', ...
    robustStability.margin.CriticalFrequency));
localStyle(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotWorstPerformance(nominalAudit, robustPerformance, ...
    config, filePath)
values = [config.gammaTarget; nominalAudit.metrics.gammaNominal; ...
    robustPerformance.worstGainActual];
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 950, 620]);
bar(categorical({'Target M5', 'Nominale A5', ...
    'Worst-case sostituito'}), values);
set(gca, 'YScale', 'log'); grid on; box on;
ylabel('Peak gain pesato');
title(['M12 — NP fallita e worst-case gain non limitato ' ...
    'nell''insieme M4']);
localStyle(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotBlockDiagnostics(tableData, filePath)
values = [tableData.RSSensitivity, ...
    100 * tableData.RSWorstNormalizedMagnitude, ...
    100 * tableData.GainWorstNormalizedMagnitude];
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1100, 650]);
bar(categorical(tableData.BlockName, tableData.BlockName), values);
set(gca, 'TickLabelInterpreter', 'none');
grid on; box on;
ylabel('Percentuale / livello normalizzato [%]');
title('M12 — sensibilità RS e perturbazioni critiche normalizzate');
legend('RS sensitivity', 'WCU RS', 'WCU wcgain', ...
    'Location', 'best');
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
title('M12 — sintesi separata NS / NP / RS / RP');
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
