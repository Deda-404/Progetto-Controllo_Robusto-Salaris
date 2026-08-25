function comparison = build_m11_comparison( ...
    representativeResults, m10)
%BUILD_M11_COMPARISON Create a common M6/M9/M10/M11 metric table.

arguments
    representativeResults (:, 1) struct
    m10 (1, 1) struct
end

base = m10.comparisonM6M9M10.summary;
numberM11 = sum([representativeResults.available]);
numberRows = height(base) + numberM11;
controller = strings(numberRows, 1);
architecture = strings(numberRows, 1);
controllerOrder = nan(numberRows, 1);
objective = nan(numberRows, 1);
weightedNorm = nan(numberRows, 1);
nominallyStable = false(numberRows, 1);
worstTrackingTs = nan(numberRows, 1);
worstOvershoot = nan(numberRows, 1);
worstSteadyErrorRelative = nan(numberRows, 1);
worstTrackingCrossCoupling = nan(numberRows, 1);
worstTrackingPeakU = nan(numberRows, 1);
worstDisturbancePeakQ = nan(numberRows, 1);
worstDisturbanceOffset = nan(numberRows, 1);
worstDisturbanceCrossCoupling = nan(numberRows, 1);
worstDisturbancePeakU = nan(numberRows, 1);

for index = 1:height(base)
    controller(index) = base.controller(index);
    architecture(index) = base.controller(index);
    controllerOrder(index) = base.controllerOrder(index);
    objective(index) = base.gamma(index);
    weightedNorm(index) = base.weightedNorm(index);
    nominallyStable(index) = base.nominallyStable(index);
    worstTrackingTs(index) = base.worstTrackingTs(index);
    worstOvershoot(index) = base.worstOvershoot(index);
    worstSteadyErrorRelative(index) = ...
        base.worstSteadyErrorRelative(index);
    worstTrackingCrossCoupling(index) = ...
        base.worstTrackingCrossCoupling(index);
    worstTrackingPeakU(index) = base.worstTrackingPeakU(index);
    worstDisturbancePeakQ(index) = base.worstDisturbancePeakQ(index);
    worstDisturbanceOffset(index) = base.worstDisturbanceOffset(index);
    worstDisturbanceCrossCoupling(index) = ...
        base.worstDisturbanceCrossCoupling(index);
    worstDisturbancePeakU(index) = base.worstDisturbancePeakU(index);
end

row = height(base);
for index = 1:numel(representativeResults)
    representative = representativeResults(index);
    if ~representative.available
        continue;
    end
    row = row + 1;
    tracking = representative.evaluation.trackingMetrics;
    disturbance = representative.evaluation.disturbanceMetrics;
    reconstruction = representative.reconstruction;
    controller(row) = "M11 " + representative.architectureID;
    architecture(row) = representative.architectureID;
    controllerOrder(row) = order(representative.controller);
    objective(row) = representative.objective;
    weightedNorm(row) = reconstruction.metrics.weightedNorm;
    nominallyStable(row) = reconstruction.metrics.internallyStable;
    worstTrackingTs(row) = max(tracking.SettlingTime);
    worstOvershoot(row) = max(tracking.OvershootPercent);
    worstSteadyErrorRelative(row) = ...
        max(tracking.SteadyStateErrorRelative);
    worstTrackingCrossCoupling(row) = ...
        max(tracking.CrossCouplingPeakRatio);
    worstTrackingPeakU(row) = max(tracking.PeakControlNm);
    worstDisturbancePeakQ(row) = max(disturbance.PeakQRad);
    worstDisturbanceOffset(row) = ...
        max(abs(disturbance.SteadyStateOffsetRad));
    worstDisturbanceCrossCoupling(row) = ...
        max(disturbance.CrossCouplingPeakRatio);
    worstDisturbancePeakU(row) = max(disturbance.PeakControlNm);
end

comparison = table(controller, architecture, controllerOrder, objective, ...
    weightedNorm, nominallyStable, worstTrackingTs, worstOvershoot, ...
    worstSteadyErrorRelative, worstTrackingCrossCoupling, ...
    worstTrackingPeakU, worstDisturbancePeakQ, ...
    worstDisturbanceOffset, worstDisturbanceCrossCoupling, ...
    worstDisturbancePeakU);
end
