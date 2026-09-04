function metrics = validate_m7_lqg_integral
%VALIDATE_M7_LQG_INTEGRAL Evaluate three explicit LQI feasibility points.

root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
dataDirectory = fullfile(root, 'results', 'data');
figureDirectory = fullfile(root, 'results', 'figures');
m3 = load(fullfile(dataDirectory, 'm3_nominal_actuated_plant.mat'));
m5 = load(fullfile(dataDirectory, 'm5_performance_specs.mat'));
m6 = load(fullfile(dataDirectory, 'm6_lqg_no_integrator.mat'));
config = lqg_specs_m7;
assert(isfield(m6, 'validationMetrics') && ...
    isfield(m6.validationMetrics, 'cost') && ...
    isfield(m6.validationMetrics.cost, 'priorities'), ...
    'M7:MissingM6Priorities', ...
    'M7 requires the priorities stored by the validated M6 artifact.');
statePriorities = m6.validationMetrics.cost.priorities;
manual = config.manualDesigns;
numberDesigns = height(manual);
designs = cell(numberDesigns, 1);
evaluations = cell(numberDesigns, 1);
feedforward = cell(numberDesigns, 1);

stable = false(numberDesigns, 1);
worstSettlingTime = inf(numberDesigns, 1);
worstOvershoot = inf(numberDesigns, 1);
peakControl = inf(numberDesigns, 1);
peakControlNormalized = inf(numberDesigns, 1);
peakDeformationNormalized = inf(numberDesigns, 1);
disturbanceOffset = inf(numberDesigns, 1);
trackingPass = false(numberDesigns, 1);
disturbancePass = false(numberDesigns, 1);
fundamentalPass = false(numberDesigns, 1);

for index = 1:numberDesigns
    design = build_lqi_augmented_cost(m3, m5, m6, ...
        manual.Wi(index), manual.RhoU(index), statePriorities);
    [Nff, feedforwardInfo] = build_lqi_reference_feedforward( ...
        m3, design.Kx, config);
    evaluation = evaluate_lqi_2dof_candidate( ...
        m3, m5, design, Nff, config);
    designs{index} = design;
    evaluations{index} = evaluation;
    feedforward{index} = struct('Nff', Nff, 'info', feedforwardInfo);
    stable(index) = evaluation.summary.stable;
    worstSettlingTime(index) = evaluation.summary.worstSettlingTime;
    worstOvershoot(index) = evaluation.summary.worstOvershoot;
    peakControl(index) = evaluation.summary.worstPeakControl;
    peakControlNormalized(index) = evaluation.summary.peakControlNormalized;
    peakDeformationNormalized(index) = ...
        evaluation.summary.peakDeformationNormalized;
    disturbanceOffset(index) = ...
        evaluation.summary.worstDisturbanceSteadyStateOffset;
    trackingPass(index) = evaluation.summary.trackingPass;
    disturbancePass(index) = evaluation.summary.disturbancePass;
    fundamentalPass(index) = evaluation.summary.fundamentalPass && ...
        feedforwardInfo.wellConditioned;
end

manualComparisonTable = [manual, table(stable, worstSettlingTime, ...
    worstOvershoot, peakControl, peakControlNormalized, ...
    peakDeformationNormalized, disturbanceOffset, trackingPass, ...
    disturbancePass, fundamentalPass, 'VariableNames', {'Stable', ...
    'WorstSettlingTime', 'WorstOvershoot', 'PeakControl', ...
    'PeakControlNormalized', 'PeakDeformationNormalized', ...
    'DisturbanceOffset', 'TrackingPass', 'DisturbancePass', ...
    'FundamentalPass'})];
validationMetrics.status = "PARTIAL";
validationMetrics.interpretation = ...
    "integral action rejects constant disturbances, but no manual point meets M5 tracking targets";
validationMetrics.designCount = numberDesigns;
validationMetrics.admissibleCount = sum(fundamentalPass);
validationMetrics.allStable = all(stable);
validationMetrics.allRejectConstantDisturbance = all(disturbancePass);
validationMetrics.noControllerPublished = ~any(fundamentalPass);
validationMetrics.physicalScalesPreserved = all(cellfun( ...
    @(d) isequaln(d.physicalScales, ...
    m6.validationMetrics.cost.scales), designs));
validationMetrics.saturationEnabled = config.saturationEnabled;
validationMetrics.antiWindupEnabled = config.antiWindupEnabled;

assert(numberDesigns == 3, 'M7:ManualDesignCount', ...
    'M7 must contain exactly three named manual comparisons.');
assert(validationMetrics.allStable && ...
    validationMetrics.physicalScalesPreserved, 'M7:MathematicalValidity', ...
    'An LQI comparison is unstable or changes the M6 physical scales.');
assert(validationMetrics.allRejectConstantDisturbance, ...
    'M7:DisturbanceRejection', ...
    'Integral action must reject the declared constant disturbances.');
assert(validationMetrics.admissibleCount == 0 && ...
    validationMetrics.noControllerPublished, 'M7:UnexpectedController', ...
    'A final LQI controller cannot be published from this feasibility study.');

tradeoffFigurePath = fullfile(figureDirectory, ...
    'm7_augmented_cost_tradeoff.png');
localPlotTradeoff(manualComparisonTable, m5.spec, tradeoffFigurePath);

datasetPath = fullfile(dataDirectory, 'm7_augmented_cost_feasibility.mat');
save(datasetPath, 'manualComparisonTable', 'designs', 'evaluations', ...
    'feedforward', 'validationMetrics', 'statePriorities', 'config', '-v7');
save(fullfile(dataDirectory, 'm7_lqg_integral.mat'), ...
    'manualComparisonTable', 'validationMetrics', 'config', '-v7');

fprintf('\n=== M7: tre verifiche manuali LQI ===\n');
disp(manualComparisonTable(:, {'Tuning', 'Wi', 'RhoU', ...
    'WorstSettlingTime', 'WorstOvershoot', 'DisturbanceOffset', ...
    'FundamentalPass'}));
fprintf(['[PARTIAL] Tutti i punti sono stabili e rigettano il disturbo, ' ...
    'ma nessuno soddisfa insieme i target M5.\n']);

metrics.config = config;
metrics.manualComparisonTable = manualComparisonTable;
metrics.designs = designs;
metrics.evaluations = evaluations;
metrics.feedforward = feedforward;
metrics.validationMetrics = validationMetrics;
metrics.datasetPath = datasetPath;
metrics.figurePath = tradeoffFigurePath;
end

function localPlotTradeoff(tableData, spec, filePath)
figureHandle = figure('Visible', 'off', 'Color', 'white', ...
    'Position', [100, 100, 1050, 620]);
scatter(tableData.WorstSettlingTime, tableData.WorstOvershoot, ...
    110, tableData.PeakControlNormalized, 'filled');
hold on;
xline(spec.settlingTimeTarget, '--', 'target T_s');
yline(spec.overshootTarget, '--', 'target overshoot');
for index = 1:height(tableData)
    text(tableData.WorstSettlingTime(index), ...
        tableData.WorstOvershoot(index), "  " + tableData.Tuning(index));
end
grid on; box on;
xlabel('Worst settling [s]'); ylabel('Worst overshoot [%]');
title('M7 - Confronto manuale dei tre costi LQI');
colorbarHandle = colorbar;
colorbarHandle.Label.String = 'peak |u| / uScale';
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end
