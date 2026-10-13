function export_student_baseline_figures
%EXPORT_STUDENT_BASELINE_FIGURES Plot frozen nominal data with descriptive labels.
root=fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(root,'src')),genpath(fullfile(root,'analysis')));
folder=fullfile(root,'report/figures/student_baseline');
if ~isfolder(folder),mkdir(folder);end
data=fullfile(root,'results/data');
m2=load(fullfile(data,'m2_linearization_nominal.mat'));
m3=load(fullfile(data,'m3_nominal_actuated_plant.mat'));
m4=load(fullfile(data,'m4_uncertain_plant.mat'));
m5=load(fullfile(data,'m5_performance_specs.mat'));
m6=load(fullfile(data,'m6_lqg_no_integrator.mat'));
m7=load(fullfile(data,'m7_disturbance_comparison.mat'));
localMechanicalPoles(m2.poles,fullfile(folder,'mechanical_poles.png'));
w=m3.delayMetrics.comparisonGrid;tau=m3.actuatorParams.delay;
localPlotDelayComparison(w,exp(-1i*w*tau),(1-1i*w*tau/2)./(1+1i*w*tau/2),tau,fullfile(folder,'delay_pade.png'));
family=build_actuator_family(uncertainty_params_m4);
assert(isequal(family.frequencies,m4.actuatorFamilySummary.frequencies));
assert(norm(family.errorEnvelope-m4.actuatorFamilySummary.errorEnvelope,inf)<1e-10);
fit.selectedOrder=order(m4.WI);
fit.weightMagnitude=abs(squeeze(freqresp(m4.WI,family.frequencies))).';
localCreateActuatorCoverFigure(family,fit,fullfile(folder,'actuator_uncertainty.png'));
design.priorities=m6.validationMetrics.cost.priorities;
design.candidateTable=m6.lqrCandidateTable;
localPlotCostDefinition(design,fullfile(folder,'lqr_selected_weights.png'));
localPlotLqrSearch(design,m5.spec,fullfile(folder,'lqr_tradeoff.png'));
localPlotKalmanSensitivity(m6.kalmanSensitivityTable,fullfile(folder,'kalman_sensitivity.png'));
config=lqg_specs_m6;
tr=(0:config.simulationTimeStep:config.referenceHorizon).';
td=(0:config.simulationTimeStep:config.disturbanceHorizon).';
yr=cell(2,1);yd=cell(2,1);
for j=1:2
    u=zeros(numel(tr),8);u(:,j)=m5.spec.referenceAmplitude;
    yr{j}=lsim(m6.lqgClosedLoop,u,tr);
    u=zeros(numel(td),8);u(:,j+2)=m5.spec.disturbanceTorqueAmplitude;
    yd{j}=lsim(m6.lqgClosedLoop,u,td);
end
tn=(0:config.simulationTimeStep:config.noiseHorizon).';
u=zeros(numel(tn),8);u(:,1)=m5.spec.referenceAmplitude;
rng(config.noiseSeed,'twister');u(:,5:8)=m6.noiseMetrics.sigmaYRad*randn(numel(tn),4);
yn=lsim(m6.lqgClosedLoop,u,tn);u(:,5:8)=0;y0=lsim(m6.lqgClosedLoop,u,tn);
assert(abs(sqrt(mean((yn(:,5:6)-y0(:,5:6)).^2,'all'))-m6.noiseMetrics.rmsControlVariation)<1e-8);
localPlotReference(tr,yr,m5.spec,fullfile(folder,'lqg_tracking.png'));
localPlotDisturbance(td,yd,fullfile(folder,'lqg_disturbance.png'));
localPlotEstimation(tn,yn,y0,fullfile(folder,'lqg_estimation.png'));
localPlotPoles(m6.regulatorPoles,m6.estimatorPoles,m6.combinedPoles,fullfile(folder,'lqg_poles.png'));
localComparison(m7,folder);
fprintf('PASS: 13 figures from frozen nominal data; no synthesis or MAT/SLX writes.\n');
end

function localComparison(c,folder)
for kind=1:2
    f=figure('Visible','off','Theme','light','Position',[100,100,1050,580]);
    tiledlayout(2,2,'TileSpacing','compact','Padding','compact');
    for joint=1:2
        for channel=1:2
            nexttile(2*(channel-1)+joint);hold on;
            for controller=1:2
                y=c.uscite{controller,joint};
                if kind==1,value=rad2deg(y(:,channel));else,value=y(:,channel+4);end
                plot(c.tempo,value,'LineWidth',1.4);
            end
            yline(0,':k','HandleVisibility','off');grid on;xlabel('Tempo [s]');
            if kind==1,ylabel(sprintf('Delta q_%d [deg]',channel));else,ylabel(sprintf('u_%d [N m]',channel));end
            title(sprintf('d_%d=0.5 N m; r=0',joint));legend('LQG','LQGI','Location','best');
        end
    end
    names={'lqg_lqgi_disturbance.png','lqg_lqgi_command.png'};
    set_scientific_figure_style(f);exportgraphics(f,fullfile(folder,names{kind}),'Resolution',180);close(f);
end
f=figure('Visible','off','Theme','light','Position',[100,100,1150,840]);
tiledlayout(3,2,'TileSpacing','compact','Padding','compact');
for joint=1:2
    nexttile(joint);hold on;
    for controller=1:2
        y=c.trackingOutput{controller,joint};plot(c.trackingTime,rad2deg(y(:,joint)),'LineWidth',1.4);
    end
    yline(5,'--k');xlabel('Tempo [s]');ylabel(sprintf('Delta q_%d [deg]',joint));grid on;
    title(sprintf('r_%d=5 deg; altro riferimento nullo',joint));legend('LQG','LQGI','Riferimento','Location','best');
    nexttile(joint+2);hold on;
    for controller=1:2
        y=c.trackingOutput{controller,joint};plot(c.trackingTime,y(:,5:6),'LineWidth',1.2);
    end
    xlabel('Tempo [s]');ylabel('Comando [N m]');grid on;
    legend('LQG u_1','LQG u_2','LQGI u_1','LQGI u_2','Location','best');
    nexttile(joint+4);plot(c.trackingTime,c.trackingOutput{2,joint}(:,7:8),'LineWidth',1.3);
    xlabel('Tempo [s]');ylabel('Integrale xi [rad s]');grid on;legend('xi_1','xi_2','Location','best');
end
set_scientific_figure_style(f);exportgraphics(f,fullfile(folder,'lqgi_tracking.png'),'Resolution',180);close(f);
end
function localMechanicalPoles(poles,figurePath)
stabilityTolerance=1e-8;
poleFigure = figure('Visible', 'off', 'Theme', 'light', 'Color', 'white', ...
    'Position', [100, 100, 1100, 700]);
poleAxes = axes(poleFigure, 'Color', 'white', ...
    'XColor', [0.15, 0.15, 0.15], 'YColor', [0.15, 0.15, 0.15], ...
    'GridColor', [0.72, 0.72, 0.72]);
hold(poleAxes, 'on');
stablePoleMask = real(poles) < -stabilityTolerance;
unstablePoleMask = real(poles) > stabilityTolerance;
marginalPoleMask = ~(stablePoleMask | unstablePoleMask);
plot(poleAxes, real(poles(stablePoleMask)), imag(poles(stablePoleMask)), ...
    'x', 'LineWidth', 2, 'MarkerSize', 10, 'Color', [0.00, 0.35, 0.70], ...
    'DisplayName', 'Stabili');
plot(poleAxes, real(poles(unstablePoleMask)), imag(poles(unstablePoleMask)), ...
    'x', 'LineWidth', 2, 'MarkerSize', 10, 'Color', [0.80, 0.15, 0.15], ...
    'DisplayName', 'Instabili');
if any(marginalPoleMask)
    plot(poleAxes, real(poles(marginalPoleMask)), imag(poles(marginalPoleMask)), ...
        'o', 'LineWidth', 1.8, 'MarkerSize', 8, ...
        'Color', [0.55, 0.35, 0.05], 'DisplayName', 'Marginali');
end
xline(poleAxes, 0, '--', 'Re(s)=0', 'Color', [0.65, 0.10, 0.10], ...
    'LabelVerticalAlignment', 'bottom', 'HandleVisibility', 'off');
yline(poleAxes, 0, ':', 'Im(s)=0', 'Color', [0.30, 0.30, 0.30], ...
    'LabelHorizontalAlignment', 'left', 'HandleVisibility', 'off');
grid(poleAxes, 'on');
xlabel(poleAxes, 'Parte reale [s^{-1}]', 'Color', [0.10, 0.10, 0.10]);
ylabel(poleAxes, 'Parte immaginaria [rad/s]', 'Color', [0.10, 0.10, 0.10]);
title(poleAxes, 'Poli open-loop del modello meccanico SEA a 8 stati', ...
    'Color', [0.10, 0.10, 0.10]);
legend(poleAxes, 'Location', 'best', 'TextColor', [0.10, 0.10, 0.10], ...
    'Color', 'white');
set_scientific_figure_style(poleFigure);
exportgraphics(poleFigure, figurePath, 'Resolution', 180);
close(poleFigure);

end
function localPlotDelayComparison( ...
    frequencies, exactResponse, padeResponse, delay, filePath)
exactMagnitudeDb = 20 * log10(abs(exactResponse));
padeMagnitudeDb = 20 * log10(abs(padeResponse));
exactPhaseDeg = -frequencies * delay * 180 / pi;
padePhaseDeg = -2 * atan(frequencies * delay / 2) * 180 / pi;

plotFigure = figure('Visible', 'off', 'Theme', 'light', 'Color', 'white', ...
    'Position', [100, 100, 1050, 720]);
layout = tiledlayout(plotFigure, 2, 1, 'TileSpacing', 'compact');
title(layout, 'Ritardo esatto e Padé del primo ordine', ...
    'Color', [0.10, 0.10, 0.10]);

magnitudeAxes = nexttile(layout);
semilogx(magnitudeAxes, frequencies, exactMagnitudeDb, '-', ...
    'LineWidth', 1.8, 'Color', [0.00, 0.35, 0.70], ...
    'DisplayName', 'Ritardo esatto');
hold(magnitudeAxes, 'on');
semilogx(magnitudeAxes, frequencies, padeMagnitudeDb, '--', ...
    'LineWidth', 1.8, 'Color', [0.85, 0.33, 0.10], ...
    'DisplayName', 'Padé ordine 1');
localStyleAxes(magnitudeAxes);
grid(magnitudeAxes, 'on');
xlim(magnitudeAxes, [frequencies(1), frequencies(end)]);
ylim(magnitudeAxes, [-0.02, 0.02]);
ylabel(magnitudeAxes, 'Modulo [dB]', 'Color', [0.10, 0.10, 0.10]);
legend(magnitudeAxes, 'Location', 'best', ...
    'TextColor', [0.10, 0.10, 0.10], 'Color', 'white');

phaseAxes = nexttile(layout);
semilogx(phaseAxes, frequencies, exactPhaseDeg, '-', ...
    'LineWidth', 1.8, 'Color', [0.00, 0.35, 0.70], ...
    'DisplayName', 'Ritardo esatto');
hold(phaseAxes, 'on');
semilogx(phaseAxes, frequencies, padePhaseDeg, '--', ...
    'LineWidth', 1.8, 'Color', [0.85, 0.33, 0.10], ...
    'DisplayName', 'Padé ordine 1');
localStyleAxes(phaseAxes);
grid(phaseAxes, 'on');
xlim(phaseAxes, [frequencies(1), frequencies(end)]);
xlabel(phaseAxes, 'Frequenza [rad/s]', 'Color', [0.10, 0.10, 0.10]);
ylabel(phaseAxes, 'Fase [deg]', 'Color', [0.10, 0.10, 0.10]);
legend(phaseAxes, 'Location', 'best', ...
    'TextColor', [0.10, 0.10, 0.10], 'Color', 'white');
set_scientific_figure_style(plotFigure);
exportgraphics(plotFigure, filePath, 'Resolution', 180);
close(plotFigure);
end

function localStyleAxes(plotAxes)
set(plotAxes, 'Color', 'white', ...
    'XColor', [0.15, 0.15, 0.15], 'YColor', [0.15, 0.15, 0.15], ...
    'GridColor', [0.72, 0.72, 0.72], ...
    'MinorGridColor', [0.86, 0.86, 0.86]);
end
function localCreateActuatorCoverFigure(family, fit, fileName)
figureHandle = figure('Visible', 'off', 'Theme', 'light', 'Color', 'white', ...
    'Position', [100, 100, 1050, 620]);
cleanupFigure = onCleanup(@() close(figureHandle));
familyLines = semilogx( ...
    family.frequencies, abs(family.multiplicativeErrors).', ...
    'Color', [0.82, 0.82, 0.82], 'LineWidth', 0.45);
hold on;
envelopeLine = semilogx(family.frequencies, family.errorEnvelope, 'k-', ...
    'LineWidth', 2.0);
weightLine = semilogx(family.frequencies, fit.weightMagnitude, 'r--', ...
    'LineWidth', 2.2);
localStyleAxes(gca);
xlabel('Frequenza [rad/s]', 'Color', [0.1, 0.1, 0.1]);
ylabel('Modulo', 'Color', [0.1, 0.1, 0.1]);
title(sprintf(['Copertura dell''incertezza attuatore ' ...
    '(W_I ordine %d)'], fit.selectedOrder), 'Color', [0.1, 0.1, 0.1]);
legendHandle = legend([familyLines(1), envelopeLine, weightLine], ...
    {'Errori della famiglia', 'Inviluppo max |E_i|', '|W_I|'}, ...
    'Location', 'northwest');
localStyleLegend(legendHandle);
grid on;
xlim([family.frequencies(1), family.frequencies(end)]);
set_scientific_figure_style(figureHandle);
exportgraphics(figureHandle, fileName, 'Resolution', 180);
end

function localStyleLegend(legendHandle)
set(legendHandle, 'Color', 'white', 'TextColor', [0.1, 0.1, 0.1], ...
    'EdgeColor', [0.35, 0.35, 0.35]);
end

function localPlotCostDefinition(design, filePath)
labels = categorical({'q', 'qdot', 'theta-q', 'thetadot'});
priorities = [design.priorities.wq, design.priorities.wqdot, ...
    design.priorities.wdelta, design.priorities.wthetaDot];
figureHandle = figure('Visible', 'off', 'Theme', 'light', 'Color', 'white', ...
    'Position', [100, 100, 900, 560]);
bar(labels, priorities, 'FaceColor', [0.12, 0.48, 0.82]);
grid on; ylabel('Priorita adimensionale');
title('Fattori selezionati dalla ricerca LQR');
set_scientific_figure_style(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotLqrSearch(design, spec, filePath)
candidateTable = design.candidateTable;
figureHandle = figure('Visible', 'off', 'Theme', 'light', 'Color', 'white', ...
    'Position', [100, 100, 1000, 650]);
admissible = candidateTable.Admissible;
scatter(candidateTable.WorstSettlingTime(~admissible), ...
    candidateTable.WorstPeakControl(~admissible), 44, ...
    [0.70, 0.70, 0.70], 'filled', 'DisplayName', 'Non ammissibile');
hold on;
scatter(candidateTable.WorstSettlingTime(admissible), ...
    candidateTable.WorstPeakControl(admissible), 55, ...
    candidateTable.CompromiseScore(admissible), 'filled', ...
    'DisplayName', 'Ammissibile');
selected = candidateTable.Selected;
scatter(candidateTable.WorstSettlingTime(selected), ...
    candidateTable.WorstPeakControl(selected), 150, 'p', ...
    'MarkerFaceColor', [1, 0.75, 0.05], 'MarkerEdgeColor', 'black', ...
    'DisplayName', 'Selezionato');
xline(spec.settlingTimeTarget, '--', 'T_s target');
yline(spec.uScale, ':', 'u_{scale} (non saturazione)');
grid on; box on;
xlabel('Tempo di assestamento peggiore [s]');
ylabel('Picco di comando peggiore [N m]');
title('Compromesso prestazione/sforzo nei 36 candidati LQR');
legend('Location', 'best');
colorbar;
set_scientific_figure_style(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotKalmanSensitivity(caseTable, filePath)
figureHandle = figure('Visible', 'off', 'Theme', 'light', 'Color', 'white', ...
    'Position', [100, 100, 980, 600]);
layout = tiledlayout(1, 2, 'TileSpacing', 'compact');
nexttile;
semilogx(caseTable.QOverRRelative, caseTable.EstimatorSpeedRatio, ...
    '-o', 'LineWidth', 1.6, 'MarkerFaceColor', [0.16, 0.52, 0.82]);
grid on; xlabel('Rapporto Q_n/R_n relativo');
ylabel('Rapporto velocita stimatore/regolatore');
title('Rapidita dell''osservatore');
nexttile;
semilogx(caseTable.QOverRRelative, caseTable.RmsControlFixedNoise, ...
    '-o', 'LineWidth', 1.6, 'MarkerFaceColor', [0.86, 0.42, 0.16]);
grid on; xlabel('Rapporto Q_n/R_n relativo');
ylabel('RMS variazione comando [N m]');
title('Stessa sequenza e ampiezza di rumore applicato');
title(layout, 'Tre ipotesi didattiche sulle covarianze Kalman');
set_scientific_figure_style(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotReference(time, outputs, spec, filePath)
figureHandle = figure('Visible', 'off', 'Theme', 'light', 'Color', 'white', ...
    'Position', [100, 100, 1000, 720]);
layout = tiledlayout(figureHandle, 2, 1, 'TileSpacing', 'compact');
title(layout, 'Tracking nominale LQG senza integratore');
for jointIndex = 1:2
    axesHandle = nexttile;
    plot(axesHandle, time, rad2deg(outputs{jointIndex}(:, 1:2)), ...
        'LineWidth', 1.7); hold(axesHandle, 'on');
    yline(axesHandle, rad2deg(spec.referenceAmplitude), '--k');
    grid(axesHandle, 'on'); ylabel(axesHandle, 'q [deg]');
    title(axesHandle, sprintf('Step r_%d = 5 deg', jointIndex));
    legend(axesHandle, {'q_1', 'q_2', 'r'}, 'Location', 'best');
end
xlabel(nexttile(layout, 2), 'Tempo [s]');
set_scientific_figure_style(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotDisturbance(time, outputs, filePath)
figureHandle = figure('Visible', 'off', 'Theme', 'light', 'Color', 'white', ...
    'Position', [100, 100, 1000, 720]);
layout = tiledlayout(figureHandle, 2, 1, 'TileSpacing', 'compact');
title(layout, 'Risposta LQG a coppia costante lato link');
for jointIndex = 1:2
    axesHandle = nexttile;
    plot(axesHandle, time, rad2deg(outputs{jointIndex}(:, 1:2)), ...
        'LineWidth', 1.7); grid(axesHandle, 'on');
    ylabel(axesHandle, 'Delta q [deg]');
    title(axesHandle, sprintf('Step d_%d = 0.5 N m', jointIndex));
    legend(axesHandle, {'q_1', 'q_2'}, 'Location', 'best');
end
xlabel(nexttile(layout, 2), 'Tempo [s]');
set_scientific_figure_style(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotEstimation(time, noisyOutput, deterministicOutput, filePath)
figureHandle = figure('Visible', 'off', 'Theme', 'light', 'Color', 'white', ...
    'Position', [100, 100, 1000, 720]);
layout = tiledlayout(figureHandle, 2, 1, 'TileSpacing', 'compact');
title(layout, 'Diagnostica seeded di stima e comando');
axesHandle = nexttile;
plot(axesHandle, time, rad2deg(noisyOutput(:, 7:8)), 'LineWidth', 1.1);
grid(axesHandle, 'on'); ylabel(axesHandle, 'q-qhat [deg]');
legend(axesHandle, {'e_{q1}', 'e_{q2}'}, 'Location', 'best');
axesHandle = nexttile;
plot(axesHandle, time, noisyOutput(:, 5:6) - ...
    deterministicOutput(:, 5:6), 'LineWidth', 1.1);
grid(axesHandle, 'on'); ylabel(axesHandle, 'Delta u [N m]');
xlabel(axesHandle, 'Tempo [s]');
legend(axesHandle, {'Delta u_1', 'Delta u_2'}, 'Location', 'best');
set_scientific_figure_style(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end

function localPlotPoles(regulatorPoles, estimatorPoles, combinedPoles, filePath)
figureHandle = figure('Visible', 'off', 'Theme', 'light', 'Color', 'white', ...
    'Position', [100, 100, 950, 620]);
scatter(real(combinedPoles), imag(combinedPoles), 45, ...
    [0.65, 0.65, 0.65], 'filled', 'DisplayName', 'combined'); hold on;
scatter(real(regulatorPoles), imag(regulatorPoles), 70, ...
    [0.10, 0.40, 0.80], 'o', 'LineWidth', 1.5, ...
    'DisplayName', 'regolatore');
scatter(real(estimatorPoles), imag(estimatorPoles), 70, ...
    [0.85, 0.25, 0.12], 'x', 'LineWidth', 1.5, ...
    'DisplayName', 'stimatore');
xline(0, '--k', 'HandleVisibility', 'off'); grid on; box on;
xlabel('Parte reale [s^{-1}]'); ylabel('Parte immaginaria [s^{-1}]');
title('Poli e principio di separazione'); legend('Location', 'best');
set_scientific_figure_style(figureHandle);
exportgraphics(figureHandle, filePath, 'Resolution', 180);
close(figureHandle);
end
