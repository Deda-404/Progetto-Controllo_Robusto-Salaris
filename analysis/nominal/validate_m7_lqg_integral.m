function metrics = validate_m7_lqg_integral
%VALIDATE_M7_LQG_INTEGRAL Valida tre costi LQRI con il Kalman M6 invariato.
%   wi varia a Q e R fissi. Il punto centrale e illustrativo: stabilita
%   interna e reiezione DC non sono equiparate alla conformita a tutti i M5.

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
    % Q e L provengono dal MAT M6: nessuna nuova sintesi Kalman.
    design = build_lqri_augmented_cost(m3, m5, m6, ...
        manual.Wi(index), manual.Ru(index));
    evaluation = evaluate_lqri_candidate(m3, m5, m6, design, config);
    designs{index} = design;
    evaluations{index} = evaluation;
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
    fundamentalPass(index) = evaluation.summary.fundamentalPass;
end

manualComparisonTable = [manual, table(stable, worstSettlingTime, ...
    worstOvershoot, peakControl, peakControlNormalized, ...
    peakDeformationNormalized, disturbanceOffset, trackingPass, ...
    disturbancePass, fundamentalPass, 'VariableNames', {'Stable', ...
    'WorstSettlingTime', 'WorstOvershoot', 'PeakControl', ...
    'PeakControlNormalized', 'PeakDeformationNormalized', ...
    'DisturbanceOffset', 'TrackingPass', 'DisturbancePass', ...
    'FundamentalPass'})];
% Lo stato deriva dai risultati, senza imporre a priori un esito negativo.
validationMetrics.status = "PARTIAL";
if any(fundamentalPass), validationMetrics.status = "COMPLETE_NOMINAL"; end
validationMetrics.interpretation = ...
    "LQRI con stato stimato: verifiche nominali, non certificazione robusta";
validationMetrics.designCount = numberDesigns;
validationMetrics.admissibleCount = sum(fundamentalPass);
validationMetrics.allStable = all(stable);
validationMetrics.allRejectConstantDisturbance = all(disturbancePass);
validationMetrics.noControllerPublished = ~any(fundamentalPass);
validationMetrics.architecture = "u=-Kx*xhat-Ki*xi; xi_dot=r-q_measured";
validationMetrics.physicalStateCount = 14;
validationMetrics.integratorStateCount = 2;
validationMetrics.estimatorStateCount = 14;
validationMetrics.closedLoopStateCount = 30;
validationMetrics.kalmanPreserved = all(cellfun(@(e) isequal(e.L,m6.L),evaluations));
validationMetrics.physicalScalesPreserved = all(cellfun( ...
    @(d) isequaln(d.physicalScales, ...
    m6.validationMetrics.cost.scales), designs));
validationMetrics.saturationEnabled = config.saturationEnabled;
validationMetrics.antiWindupEnabled = config.antiWindupEnabled;

assert(numberDesigns == 3, 'M7:ManualDesignCount', ...
    'M7 must contain exactly three named manual comparisons.');
assert(validationMetrics.allStable && ...
    validationMetrics.physicalScalesPreserved, 'M7:MathematicalValidity', ...
    'Una chiusura LQRI e instabile o modifica le scale fisiche M6.');
assert(validationMetrics.allRejectConstantDisturbance, ...
    'M7:DisturbanceRejection', ...
    'Integral action must reject the declared constant disturbances.');

tradeoffFigurePath = fullfile(figureDirectory, ...
    'm7_augmented_cost_tradeoff.png');
localPlotTradeoff(manualComparisonTable, m5.spec, tradeoffFigurePath);

datasetPath = fullfile(dataDirectory, 'm7_augmented_cost_feasibility.mat');
save(datasetPath, 'manualComparisonTable', 'designs', 'evaluations', ...
    'validationMetrics', 'statePriorities', 'config', '-v7');
% L'artifact M7 espone il controllore realmente implementabile a 16 stati.
illustrativeIndex=config.illustrativeIndex;
Klqri=evaluations{illustrativeIndex}.Klqri;
Kx=designs{illustrativeIndex}.Kx; Ki=designs{illustrativeIndex}.Ki;
L=m6.L; Qn=m6.Qn; Rn=m6.Rn;
save(fullfile(dataDirectory, 'm7_lqg_integral.mat'), ...
    'Klqri','Kx','Ki','L','Qn','Rn','illustrativeIndex', ...
    'manualComparisonTable', 'validationMetrics', 'config', '-v7');

fprintf('\n=== M7: tre verifiche LQRI, Q e R fissi ===\n');
disp(manualComparisonTable(:, {'Tuning', 'Wi', 'Ru', ...
    'WorstSettlingTime', 'WorstOvershoot', 'DisturbanceOffset', ...
    'FundamentalPass'}));
fprintf('[%s] Punti conformi ai target nominali: %d/%d.\n', ...
    validationMetrics.status,sum(fundamentalPass),numberDesigns);

metrics.config = config;
metrics.manualComparisonTable = manualComparisonTable;
metrics.designs = designs;
metrics.evaluations = evaluations;
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
title('M7 - LQRI: variazione di wi a Q e R fissi');
colorbarHandle = colorbar;
colorbarHandle.Label.String = 'peak |u| / uScale';
set_scientific_figure_style(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end
