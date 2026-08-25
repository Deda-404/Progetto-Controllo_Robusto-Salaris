function assessment = evaluate_m15_convergence(result, m3, config)
%EVALUATE_M15_CONVERGENCE Apply the frozen M8 empirical criterion to M15.

time = result.time(:);
xMechanical = result.xMechanical;
numberSamples = numel(time);
tailStart = max(1, floor((1 - config.ras.tailFraction) * numberSamples));
tailIndices = tailStart:numberSamples;
tailMiddle = floor((numel(tailIndices) + 1) / 2);
firstTail = tailIndices(1:tailMiddle);
secondTail = tailIndices(tailMiddle:end);
qError = xMechanical(:, 1:2) - m3.xbar(1:2).';
qdot = xMechanical(:, 3:4);
thetaError = xMechanical(:, 5:6) - m3.xbar(5:6).';
thetaDot = xMechanical(:, 7:8);
positionNorm = max(abs([qError, thetaError]), [], 2);
boundedSignals = [xMechanical, result.xActuator, result.xController, ...
    result.controlDelta, result.controlAbsolute, result.motorTorque];
assessment.completed = isfield(result, 'completed') && result.completed;
assessment.finite = all(isfinite(boundedSignals), 'all');
assessment.bounded = assessment.finite && ...
    max(abs(boundedSignals), [], 'all') <= config.ras.numericMagnitudeLimit;
assessment.tailMaxQError = max(abs(qError(tailIndices, :)), [], 'all');
assessment.tailMaxQdot = max(abs(qdot(tailIndices, :)), [], 'all');
assessment.tailMaxThetaError = ...
    max(abs(thetaError(tailIndices, :)), [], 'all');
assessment.tailMaxThetaDot = ...
    max(abs(thetaDot(tailIndices, :)), [], 'all');
firstTailPeak = max(positionNorm(firstTail));
secondTailPeak = max(positionNorm(secondTail));
growthAllowance = config.ras.finalTrendGrowthFraction * ...
    max(firstTailPeak, deg2rad(0.05));
assessment.noFinalGrowth = secondTailPeak <= firstTailPeak + growthAllowance;
assessment.thresholdsPassed = ...
    assessment.tailMaxQError <= deg2rad(config.ras.positionToleranceDeg) && ...
    assessment.tailMaxQdot <= config.ras.linkVelocityTolerance && ...
    assessment.tailMaxThetaError <= ...
        deg2rad(config.ras.motorPositionToleranceDeg) && ...
    assessment.tailMaxThetaDot <= config.ras.motorVelocityTolerance;
assessment.convergent = assessment.completed && assessment.finite && ...
    assessment.bounded && assessment.thresholdsPassed && ...
    assessment.noFinalGrowth;
initialPositionPeak = max(positionNorm(1), deg2rad(0.05));
assessment.extensionEligible = ~assessment.convergent && ...
    assessment.completed && assessment.finite && assessment.bounded && ...
    assessment.noFinalGrowth && secondTailPeak <= 0.5 * initialPositionPeak;
assessment.horizon = time(end);
end
