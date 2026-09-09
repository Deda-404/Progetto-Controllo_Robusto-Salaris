function figurePaths = plot_m17_final_comparison(comparison, decision, ...
    m5Spec, projectRoot, config)
%PLOT_M17_FINAL_COMPARISON Generate seven report-oriented M17 figures.

arguments
    comparison (1, 1) struct
    decision (1, 1) struct
    m5Spec (1, 1) struct
    projectRoot (1, 1) string
    config (1, 1) struct = final_comparison_specs_m17
end

figureDirectory = fullfile(projectRoot, config.figureDirectory);
if ~isfolder(figureDirectory)
    mkdir(figureDirectory);
end
figurePaths = struct( ...
    'stabilityEvidence', fullfile(figureDirectory, ...
        'm17_stability_evidence_summary.png'), ...
    'nonlinearTracking', fullfile(figureDirectory, ...
        'm17_nominal_nonlinear_tracking.png'), ...
    'monteCarlo', fullfile(figureDirectory, ...
        'm17_m16_stability_tracking.png'), ...
    'ras', fullfile(figureDirectory, 'm17_ras_comparison.png'), ...
    'controlEffort', fullfile(figureDirectory, ...
        'm17_control_effort_comparison.png'), ...
    'complexity', fullfile(figureDirectory, ...
        'm17_controller_complexity.png'), ...
    'tradeoff', fullfile(figureDirectory, ...
        'm17_final_tradeoff_summary.png'));

localStability(comparison, figurePaths.stabilityEvidence);
localTracking(comparison.nonlinearComparison, m5Spec, ...
    figurePaths.nonlinearTracking);
localMonteCarlo(comparison.monteCarloComparison, ...
    figurePaths.monteCarlo);
localRas(comparison.rasComparison, figurePaths.ras);
localControlEffort(comparison.controlEffortComparison, ...
    figurePaths.controlEffort);
localComplexity(comparison.complexityComparison, ...
    figurePaths.complexity);
localTradeoff(comparison, decision, figurePaths.tradeoff);
end

function localStability(comparison, path)
linear = comparison.nominalLinearComparison;
mc = comparison.monteCarloComparison;
formal = comparison.formalRobustnessComparison;
handle = localFigure([100, 100, 1300, 620]);
cleanup = onCleanup(@() close(handle));
tiledlayout(1, 3, 'TileSpacing', 'compact');
nexttile;
bar(categorical(linear.Controller, linear.Controller), ...
    linear.NominalInternalStability == "PASS");
ylim([0, 1.15]); yticks([0, 1]); yticklabels({'FAIL', 'PASS'});
grid on; title('Nominal internal stability');
nexttile;
bar(categorical(mc.Controller, mc.Controller), mc.NStable);
ylim([0, max(mc.NTotal) + 2]);
yline(max(mc.NTotal), 'k--', 'Total'); grid on;
ylabel('Stable samples'); title('M16 empirical stability');
nexttile;
values = formal.RSMarginLower;
values(~isfinite(values)) = 0;
bar(categorical(formal.Controller, formal.Controller), values);
yline(1, 'r--', 'Unit margin'); grid on;
ylabel('Certified lower margin (0 = N/A)'); title('M14 formal RS');
sgtitle('M17 stability evidence — nominal / M16 empirical / M14 formal');
localExport(handle, path);
end

function localTracking(data, spec, path)
handle = localFigure([100, 100, 1350, 620]);
cleanup = onCleanup(@() close(handle));
tiledlayout(1, 3, 'TileSpacing', 'compact');
nexttile;
bar(categorical(data.Controller, data.Controller), data.WorstTrackingTs);
yline(spec.settlingTimeTarget, 'r--', 'M5'); grid on;
ylabel('Worst settling time [s]');
nexttile;
bar(categorical(data.Controller, data.Controller), ...
    data.WorstTrackingOvershootPercent);
yline(spec.overshootTarget, 'r--', 'M5'); grid on;
ylabel('Worst overshoot [%]');
nexttile;
bar(categorical(data.Controller, data.Controller), ...
    100 * data.WorstTrackingSteadyErrorRelative);
yline(100 * spec.steadyStateTrackingTarget, 'r--', 'M5'); grid on;
ylabel('Worst steady error [%]');
sgtitle('M17 nominal nonlinear tracking — M8 (M6), M15 (Khinf/Kmu)');
localExport(handle, path);
end

function localMonteCarlo(data, path)
handle = localFigure([100, 100, 1050, 620]);
cleanup = onCleanup(@() close(handle));
tiledlayout(1, 2, 'TileSpacing', 'compact');
nexttile;
bar(categorical(data.Controller, data.Controller), ...
    data.EmpiricalStabilityRate);
ylim([0, 1.05]); ylabel('Stable fraction'); grid on;
title('M16 stability (empirical)');
nexttile;
bar(categorical(data.Controller, data.Controller), ...
    data.CoreTrackingPassRateTotal);
ylim([0, 1.05]); ylabel('Core tracking pass fraction'); grid on;
title('M16 M5 core tracking');
sgtitle('M17 — M16 uncertain-linear evidence (not a certificate)');
localExport(handle, path);
end

function localRas(data, path)
handle = localFigure([100, 100, 1050, 620]);
cleanup = onCleanup(@() close(handle));
tiledlayout(1, 2, 'TileSpacing', 'compact');
nexttile;
bar(categorical(data.Controller, data.Controller), data.MinimumRadiusDeg);
ylabel('Minimum radius [deg]'); grid on; title('Empirical minimum radius');
nexttile;
bar(categorical(data.Controller, data.Controller), data.ApproximateAreaDeg2);
ylabel('Approximate area [deg^2]'); grid on; title('Empirical polar area');
sgtitle('M17 RAS — M8/M15; search limit is not a certified boundary');
localExport(handle, path);
end

function localControlEffort(data, path)
handle = localFigure([100, 100, 1120, 620]);
cleanup = onCleanup(@() close(handle));
tiledlayout(1, 2, 'TileSpacing', 'compact');
nexttile;
bar(categorical(data.Controller, data.Controller), ...
    [data.NominalNonlinearTrackingPeakUNm, ...
    data.MonteCarloMedianTrackingPeakUNm]);
yline(data.UScaleNm(1), 'k--', 'uScale only'); grid on;
ylabel('Peak control [N m]'); title('Tracking');
legend('Nominal nonlinear', 'M16 median', 'Location', 'best');
nexttile;
bar(categorical(data.Controller, data.Controller), ...
    [data.NominalNonlinearDisturbancePeakUNm, ...
    data.MonteCarloMedianDisturbancePeakUNm]);
yline(data.UScaleNm(1), 'k--', 'uScale only'); grid on;
ylabel('Peak control [N m]'); title('Disturbance');
legend('Nominal nonlinear', 'M16 median', 'Location', 'best');
sgtitle('M17 control effort — no certified saturation claim');
localExport(handle, path);
end

function localComplexity(data, path)
handle = localFigure([100, 100, 850, 600]);
cleanup = onCleanup(@() close(handle));
bar(categorical(data.Controller, data.Controller), data.Order);
ylabel('Dynamic controller order'); grid on;
title('M17 controller complexity from validated results');
localExport(handle, path);
end

function localTradeoff(comparison, decision, path)
complexity = comparison.complexityComparison;
nonlinear = comparison.nonlinearComparison;
mc = comparison.monteCarloComparison;
formal = comparison.formalRobustnessComparison;
handle = localFigure([100, 100, 1000, 650]);
cleanup = onCleanup(@() close(handle));
sizes = 120 + 280 * mc.EmpiricalStabilityRate;
certificate = formal.FormalRS == "PASS_CERTIFIED";
scatter(complexity.Order, 100 * nonlinear.WorstTrackingSteadyErrorRelative, ...
    sizes, double(certificate), 'filled'); hold on;
for index = 1:height(complexity)
    text(complexity.Order(index) + 0.8, ...
        100 * nonlinear.WorstTrackingSteadyErrorRelative(index), ...
        complexity.Controller(index));
end
grid on; xlabel('Controller order');
ylabel('Worst nominal nonlinear steady error [%]');
title(['M17 descriptive trade-off: order vs tracking; marker size = ' ...
    'M16 stability, color = M14 RS availability']);
subtitle("Role-based decision; no global score or absolute winner");
colormap([0.45 0.45 0.45; 0.10 0.55 0.25]);
colorbar('Ticks', [0, 1], 'TickLabels', {'RS N/A', 'RS certified'});
assert(decision.noAbsoluteWinnerClaimed);
localExport(handle, path);
end

function handle = localFigure(position)
handle = figure('Visible', 'off', 'Color', 'white', 'Position', position);
end

function localExport(handle, path)
set(findall(handle, 'Type', 'axes'), 'Color', 'white', ...
    'XColor', [0.15, 0.15, 0.15], 'YColor', [0.15, 0.15, 0.15], ...
    'GridColor', [0.65, 0.65, 0.65]);
set(findall(handle, 'Type', 'text'), 'Color', [0.1, 0.1, 0.1]);
set_scientific_figure_style(handle);
exportgraphics(handle, path, 'Resolution', 180);
end
