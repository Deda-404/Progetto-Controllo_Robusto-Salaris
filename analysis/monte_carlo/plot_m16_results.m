function figurePaths = plot_m16_results(summary, stabilityTable, ...
    trackingTable, disturbanceTable, m14Consistency, projectRoot, config)
%PLOT_M16_RESULTS Generate the nine engineering figures required by M16.

arguments
    summary (1, 1) struct
    stabilityTable table
    trackingTable table
    disturbanceTable table
    m14Consistency (1, 1) struct
    projectRoot (1, 1) string
    config (1, 1) struct = monte_carlo_specs_m16
end

figureDirectory = fullfile(projectRoot, config.figureDirectory);
if ~isfolder(figureDirectory)
    mkdir(figureDirectory);
end
figurePaths = struct( ...
    'maxRealPole', fullfile(figureDirectory, ...
        'm16_max_real_closed_loop_pole.png'), ...
    'stabilitySummary', fullfile(figureDirectory, ...
        'm16_empirical_stability_summary.png'), ...
    'bandwidth', fullfile(figureDirectory, ...
        'm16_diagonal_bandwidth_distribution.png'), ...
    'tracking', fullfile(figureDirectory, ...
        'm16_tracking_distribution.png'), ...
    'crossCoupling', fullfile(figureDirectory, ...
        'm16_cross_coupling_distribution.png'), ...
    'disturbance', fullfile(figureDirectory, ...
        'm16_disturbance_distribution.png'), ...
    'controlEffort', fullfile(figureDirectory, ...
        'm16_control_effort_distribution.png'), ...
    'pairedComparison', fullfile(figureDirectory, ...
        'm16_paired_controller_differences.png'), ...
    'm14Consistency', fullfile(figureDirectory, ...
        'm16_m14_certificate_empirical_consistency.png'));

localMaxRealPole(stabilityTable, figurePaths.maxRealPole);
localStabilitySummary(summary.stabilitySummaryTable, ...
    figurePaths.stabilitySummary, config.numberSamples);
localBandwidth(summary.sampleControllerSummaryTable, ...
    figurePaths.bandwidth);
localTracking(trackingTable, figurePaths.tracking);
localCrossCoupling(trackingTable, disturbanceTable, ...
    figurePaths.crossCoupling);
localDisturbance(disturbanceTable, figurePaths.disturbance);
localControlEffort(trackingTable, disturbanceTable, ...
    figurePaths.controlEffort);
localPaired(summary.pairedComparisonTable, ...
    figurePaths.pairedComparison);
localM14Consistency(summary.stabilitySummaryTable, m14Consistency, ...
    figurePaths.m14Consistency);
end

function localMaxRealPole(data, path)
figureHandle = localFigure;
cleanup = onCleanup(@() close(figureHandle));
hold on;
ids = unique(data.Controller, 'stable');
colors = lines(numel(ids));
for index = 1:numel(ids)
    rows = data.Controller == ids(index);
    plot(data.Sample(rows), data.MaxRealPole(rows), '-o', ...
        'LineWidth', 1.2, 'MarkerSize', 3.5, 'Color', colors(index, :));
end
yline(0, 'k--', 'Stability boundary', 'LineWidth', 1.2);
xlabel('Sample M4'); ylabel('Max real closed-loop pole [s^{-1}]');
title('M16 - Internal stability on the common M4 samples');
legend(cellstr(ids), 'Location', 'best'); grid on;
localExport(figureHandle, path);
end

function localStabilitySummary(data, path, numberSamples)
figureHandle = localFigure;
cleanup = onCleanup(@() close(figureHandle));
bar(categorical(data.Controller, data.Controller), data.NStable, 0.65);
yline(numberSamples, 'k--', 'Total samples');
ylim([0, numberSamples + 2]); ylabel('Stable samples');
title('M16 - Empirical stability count (not a certificate)'); grid on;
localExport(figureHandle, path);
end

function localBandwidth(data, path)
figureHandle = localFigure;
cleanup = onCleanup(@() close(figureHandle));
tiledlayout(1, 2, 'TileSpacing', 'compact');
nexttile;
localBox(data.Controller, data.BandwidthJ1);
ylabel('Bandwidth [rad/s]'); title('Diagonal channel T_{11}'); grid on;
nexttile;
localBox(data.Controller, data.BandwidthJ2);
ylabel('Bandwidth [rad/s]'); title('Diagonal channel T_{22}'); grid on;
sgtitle('M16 - Diagonal closed-loop bandwidth');
localExport(figureHandle, path);
end

function localTracking(data, path)
figureHandle = localFigure;
cleanup = onCleanup(@() close(figureHandle));
tiledlayout(1, 2, 'TileSpacing', 'compact');
nexttile;
localBox(data.Controller, data.TrackingTs);
yline(0.8, 'r--', 'M5 target'); ylabel('Settling time [s]'); grid on;
title('Tracking settling time');
nexttile;
localBox(data.Controller, 100 * data.TrackingSteadyErrorRelative);
yline(5, 'r--', 'M5 target'); ylabel('Steady error [%]'); grid on;
title('Tracking steady-state error');
sgtitle('M16 - Linear uncertain tracking distributions');
localExport(figureHandle, path);
end

function localCrossCoupling(tracking, disturbance, path)
figureHandle = localFigure;
cleanup = onCleanup(@() close(figureHandle));
tiledlayout(1, 2, 'TileSpacing', 'compact');
nexttile;
localBox(tracking.Controller, 100 * tracking.TrackingCrossCoupling);
yline(25, 'r--', 'M5 diagnostic'); ylabel('Peak ratio [%]'); grid on;
title('Tracking');
nexttile;
localBox(disturbance.Controller, ...
    100 * disturbance.DisturbanceCrossCoupling);
ylabel('Peak ratio [%]'); grid on; title('Link disturbance');
sgtitle('M16 - Cross-coupling distributions');
localExport(figureHandle, path);
end

function localDisturbance(data, path)
figureHandle = localFigure;
cleanup = onCleanup(@() close(figureHandle));
tiledlayout(1, 2, 'TileSpacing', 'compact');
nexttile;
localBox(data.Controller, rad2deg(data.DisturbancePeakQ));
ylabel('Affected-link peak |q| [deg]'); grid on; title('Peak response');
nexttile;
localBox(data.Controller, rad2deg(data.DisturbanceAbsOffset));
ylabel('Affected-link |offset| [deg]'); grid on; title('Steady offset');
sgtitle('M16 - Response to 0.50 N m link torque');
localExport(figureHandle, path);
end

function localControlEffort(tracking, disturbance, path)
figureHandle = localFigure;
cleanup = onCleanup(@() close(figureHandle));
tiledlayout(1, 2, 'TileSpacing', 'compact');
nexttile;
localBox(tracking.Controller, tracking.TrackingPeakUNormalized);
yline(1, 'k--', 'uScale only'); ylabel('Peak U / 12 N m'); grid on;
title('Tracking');
nexttile;
localBox(disturbance.Controller, disturbance.DisturbancePeakUNormalized);
yline(1, 'k--', 'uScale only'); ylabel('Peak U / 12 N m'); grid on;
title('Disturbance');
sgtitle('M16 - Control effort (no saturation model)');
localExport(figureHandle, path);
end

function localPaired(data, path)
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1250, 720]);
cleanup = onCleanup(@() close(figureHandle));
metrics = unique(data.Metric, 'stable');
tiledlayout(2, 3, 'TileSpacing', 'compact');
for index = 1:numel(metrics)
    nexttile;
    rows = data.Metric == metrics(index);
    bar(categorical(data.Pair(rows), data.Pair(rows)), ...
        data.MedianDifferenceAminusB(rows));
    yline(0, 'k--'); grid on;
    title(strrep(metrics(index), '_', '\_'));
    ylabel('Median A-B');
end
sgtitle('M16 - Paired differences on identical stable samples');
localExport(figureHandle, path);
end

function localM14Consistency(stability, consistency, path)
figureHandle = localFigure;
cleanup = onCleanup(@() close(figureHandle));
tiledlayout(1, 2, 'TileSpacing', 'compact');
nexttile;
errorbar(1, mean([consistency.marginLower, consistency.marginUpper]), ...
    mean([consistency.marginLower, consistency.marginUpper]) - ...
        consistency.marginLower, ...
    consistency.marginUpper - ...
        mean([consistency.marginLower, consistency.marginUpper]), ...
    'o', 'LineWidth', 1.8, 'MarkerSize', 8);
yline(1, 'r--', 'RS level 1'); xlim([0.5, 1.5]); xticks(1);
xticklabels({'Kmu M14'}); ylabel('Certified RS margin'); grid on;
title('M14 linear \mu certificate');
nexttile;
row = stability.Controller == "Kmu";
bar(categorical("Kmu M16"), stability.EmpiricalStabilityRate(row));
ylim([0, 1.05]); ylabel('Stable fraction'); grid on;
title('M16 empirical samples (not certificate)');
sgtitle('M14 certification and M16 empirical consistency');
localExport(figureHandle, path);
end

function localBox(groups, values)
valid = isfinite(values);
boxchart(categorical(groups(valid), unique(groups, 'stable')), values(valid));
end

function handle = localFigure
handle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1050, 620]);
end

function localExport(handle, path)
set(findall(handle, 'Type', 'axes'), 'Color', 'white', ...
    'XColor', [0.15, 0.15, 0.15], 'YColor', [0.15, 0.15, 0.15], ...
    'GridColor', [0.65, 0.65, 0.65]);
set(findall(handle, 'Type', 'text'), 'Color', [0.1, 0.1, 0.1]);
set(findall(handle, 'Type', 'legend'), 'Color', 'white', ...
    'TextColor', [0.1, 0.1, 0.1], 'EdgeColor', [0.35, 0.35, 0.35]);
exportgraphics(handle, path, 'Resolution', 180);
end
