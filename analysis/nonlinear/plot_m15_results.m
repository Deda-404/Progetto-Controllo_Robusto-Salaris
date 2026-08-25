function figurePaths = plot_m15_results(tracking, disturbance, ras, ...
    agreement, comparison, m6Reference, figureDirectory)
%PLOT_M15_RESULTS Produce the eight engineering figures required by M15.

if ~isfolder(figureDirectory), mkdir(figureDirectory); end
figurePaths = struct( ...
    'trackingComparison', fullfile(figureDirectory, ...
        'm15_tracking_khinf_vs_kmu.png'), ...
    'ltiNonlinearKhinf', fullfile(figureDirectory, ...
        'm15_lti_nl_tracking_khinf.png'), ...
    'ltiNonlinearKmu', fullfile(figureDirectory, ...
        'm15_lti_nl_tracking_kmu.png'), ...
    'disturbanceComparison', fullfile(figureDirectory, ...
        'm15_disturbance_khinf_vs_kmu.png'), ...
    'controlEffort', fullfile(figureDirectory, ...
        'm15_control_effort_khinf_vs_kmu.png'), ...
    'rasComparison', fullfile(figureDirectory, ...
        'm15_ras_m6_khinf_kmu.png'), ...
    'agreementRegions', fullfile(figureDirectory, ...
        'm15_lti_nl_agreement_regions.png'), ...
    'summaryMetrics', fullfile(figureDirectory, ...
        'm15_nonlinear_summary_metrics.png'));

localTrackingComparison(tracking, figurePaths.trackingComparison);
localLtiNonlinear(tracking(1), figurePaths.ltiNonlinearKhinf);
localLtiNonlinear(tracking(2), figurePaths.ltiNonlinearKmu);
localDisturbanceComparison(disturbance, figurePaths.disturbanceComparison);
localControlEffort(tracking, disturbance, figurePaths.controlEffort);
localRasComparison(m6Reference, ras, figurePaths.rasComparison);
localAgreement(agreement, figurePaths.agreementRegions);
localSummary(comparison, figurePaths.summaryMetrics);
end

function localTrackingComparison(tracking, path)
f = localFigure;
layout = tiledlayout(3, 2, 'TileSpacing', 'compact');
for amplitudeIndex = 1:3
    for jointIndex = 1:2
        nexttile; hold on;
        for controllerIndex = 1:2
            response = tracking(controllerIndex).responses{ ...
                amplitudeIndex, jointIndex};
            plot(response.time, rad2deg(response.q(:, jointIndex)), ...
                'LineWidth', 1.4);
        end
        yline(tracking(1).metrics.AmplitudeDeg( ...
            (amplitudeIndex - 1) * 2 + jointIndex), '--k');
        grid on; box on;
        title(sprintf('%g deg, giunto %d', ...
            tracking(1).metrics.AmplitudeDeg( ...
            (amplitudeIndex - 1) * 2 + jointIndex), jointIndex));
        ylabel('\delta q [deg]');
    end
end
xlabel(layout, 'Tempo [s]'); title(layout, 'Tracking non lineare');
legend({'Khinf', 'Kmu', 'r'}, 'Location', 'best');
localSave(f, path);
end

function localLtiNonlinear(tracking, path)
f = localFigure;
layout = tiledlayout(2, 2, 'TileSpacing', 'compact');
for jointIndex = 1:2
    response = tracking.responses{3, jointIndex};
    nexttile; hold on;
    plot(response.time, rad2deg(response.q(:, jointIndex)), ...
        'LineWidth', 1.5);
    plot(response.time, rad2deg(response.qLti(:, jointIndex)), '--', ...
        'LineWidth', 1.3);
    grid on; box on; ylabel('\delta q [deg]');
    title(sprintf('8 deg, giunto %d', jointIndex));
    nexttile; hold on;
    plot(response.time, response.controlDelta(:, jointIndex), ...
        'LineWidth', 1.5);
    plot(response.time, response.uLti(:, jointIndex), '--', ...
        'LineWidth', 1.3);
    grid on; box on; ylabel('\delta u [N m]');
end
xlabel(layout, 'Tempo [s]');
title(layout, sprintf('%s: LTI vs non lineare', tracking.controllerID));
legend({'non lineare', 'LTI'}, 'Location', 'best');
localSave(f, path);
end

function localDisturbanceComparison(disturbance, path)
f = localFigure;
layout = tiledlayout(1, 2, 'TileSpacing', 'compact');
for jointIndex = 1:2
    nexttile; hold on;
    for controllerIndex = 1:2
        response = disturbance(controllerIndex).responses{3, jointIndex};
        plot(response.time, rad2deg(response.q(:, jointIndex)), ...
            'LineWidth', 1.4);
    end
    grid on; box on; title(sprintf('d_%d=1 N m', jointIndex));
    xlabel('Tempo [s]'); ylabel('\delta q [deg]');
end
title(layout, 'Disturbo fisico lato link');
legend({'Khinf', 'Kmu'}, 'Location', 'best');
localSave(f, path);
end

function localControlEffort(tracking, disturbance, path)
f = localFigure;
values = [max(tracking(1).metrics.PeakDeltaUNm), ...
    max(disturbance(1).metrics.PeakDeltaUNm); ...
    max(tracking(2).metrics.PeakDeltaUNm), ...
    max(disturbance(2).metrics.PeakDeltaUNm)];
bar(values); grid on; box on;
set(gca, 'XTickLabel', {'Khinf', 'Kmu'});
ylabel('peak |\delta u| [N m]');
legend({'tracking', 'disturbo'}, 'Location', 'best');
title('Sforzo di controllo — nessuna saturazione');
localSave(f, path);
end

function localRasComparison(m6, ras, path)
f = localFigure; hold on;
localPolarBoundary(m6.rasBoundary, 'M6');
localPolarBoundary(ras(1).boundary, 'Khinf');
localPolarBoundary(ras(2).boundary, 'Kmu');
axis equal; grid on; box on; xlabel('\delta q_1(0) [deg]');
ylabel('\delta q_2(0) [deg]'); title('RAS empiriche — sezioni q');
legend('Location', 'best'); localSave(f, path);
end

function localAgreement(agreement, path)
f = localFigure; hold on;
for index = 1:2
    boundary = agreement(index).boundary;
    plot([boundary.R1Deg; boundary.R1Deg(1)], ...
        [boundary.R2Deg; boundary.R2Deg(1)], 'LineWidth', 1.6, ...
        'DisplayName', char(agreement(index).controllerID));
end
axis equal; grid on; box on; xlabel('r_1 [deg]'); ylabel('r_2 [deg]');
title('EMPIRICAL LTI/NL AGREEMENT REGION'); legend('Location', 'best');
localSave(f, path);
end

function localSummary(comparison, path)
f = localFigure;
values = [comparison.WorstTrackingOvershootPercent / 10, ...
    100 * comparison.WorstSteadyErrorRelative / 5, ...
    100 * comparison.WorstCrossCouplingRatio / 25, ...
    comparison.WorstTrackingPeakDeltaUNm / 12, ...
    comparison.WorstDisturbancePeakQDeg / 10];
bar(values); grid on; box on;
set(gca, 'XTickLabel', cellstr(comparison.Controller));
ylabel('metrica normalizzata');
legend({'OS/10%', 'err/5%', 'cross/25%', 'peakU/12', ...
    'peak q dist/10deg'}, 'Location', 'southoutside', ...
    'Orientation', 'horizontal');
title('Sintesi delle metriche non lineari');
localSave(f, path);
end

function localPolarBoundary(boundary, name)
plot([boundary.Dq1Deg; boundary.Dq1Deg(1)], ...
    [boundary.Dq2Deg; boundary.Dq2Deg(1)], 'LineWidth', 1.5, ...
    'DisplayName', name);
end
function f = localFigure
f = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1200, 800]);
end
function localSave(f, path)
exportgraphics(f, path, 'Resolution', 180); close(f);
end
