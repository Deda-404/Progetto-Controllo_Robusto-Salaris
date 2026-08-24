function diagnosis = diagnose_m6_baseline_cost(m3Data, m5Data, config)
%DIAGNOSE_M6_BASELINE_COST Quantify the failed unit-priority M6 baseline.

arguments
    m3Data (1, 1) struct
    m5Data (1, 1) struct
    config (1, 1) struct = lqg_specs_m6
end

priorities = struct('wq', 1, 'wqdot', 1, ...
    'wdelta', 1, 'wthetaDot', 1);
[Ccost, Q, scales, costInfo] = ...
    build_lqr_state_cost(m3Data, m5Data.spec, priorities);
rhoU = config.rhoUCandidates(1);
R = rhoU / m5Data.spec.uScale^2 * eye(2);
K = lqr(m3Data.Afull, m3Data.Bfull, Q, R);
Acl = m3Data.Afull - m3Data.Bfull * K;
staticTrackingGain = -m3Data.CfullQ * (Acl \ m3Data.Bfull);
Nr = staticTrackingGain \ eye(2);

[rightVectors, poleMatrix, leftVectors] = eig(Acl);
poles = diag(poleMatrix);
[~, dominantIndex] = max(real(poles));
dominantPole = poles(dominantIndex);
rightVector = rightVectors(:, dominantIndex);
leftVector = leftVectors(:, dominantIndex);
leftVector = leftVector / (leftVector' * rightVector);
participation = abs(rightVector .* conj(leftVector));
participation = participation / sum(participation);
group = ["q"; "qdot"; "theta"; "thetaDot"; "actuator"];
groupParticipation = [sum(participation(1:2)); ...
    sum(participation(3:4)); sum(participation(5:6)); ...
    sum(participation(7:8)); sum(participation(9:14))];
modalParticipationTable = table(group, groupParticipation, ...
    'VariableNames', {'StateGroup', 'Participation'});

inverseRightVectors = rightVectors \ eye(size(rightVectors));
q1ResidueMagnitude = zeros(numel(poles), 1);
for modeIndex = 1:numel(poles)
    q1ResidueMagnitude(modeIndex) = abs( ...
        (m3Data.CfullQ(1, :) * rightVectors(:, modeIndex)) * ...
        (inverseRightVectors(modeIndex, :) * m3Data.Bfull * Nr(:, 1)));
end
modalResidueTable = table(poles, q1ResidueMagnitude, ...
    'VariableNames', {'Pole', 'Q1ReferenceResidueMagnitude'});
modalResidueTable = sortrows(modalResidueTable, ...
    'Q1ReferenceResidueMagnitude', 'descend');

qEigenvalues = sort(real(eig(Q)), 'descend');
nonzeroEigenvalues = qEigenvalues(qEigenvalues > 1e-10);
diagnosis.Ccost = Ccost;
diagnosis.Q = Q;
diagnosis.scales = scales;
diagnosis.costInfo = costInfo;
diagnosis.equivalentWeights = costInfo.equivalentBlockWeights;
diagnosis.positionToDeformationWeightRatio = ...
    costInfo.equivalentBlockWeights.q / ...
    costInfo.equivalentBlockWeights.delta;
diagnosis.qEigenvalues = qEigenvalues;
diagnosis.qRank = rank(Q);
diagnosis.qNonzeroConditionNumber = ...
    max(nonzeroEigenvalues) / min(nonzeroEigenvalues);
diagnosis.rhoU = rhoU;
diagnosis.K = K;
diagnosis.Nr = Nr;
diagnosis.regulatorPoles = poles;
diagnosis.dominantPole = dominantPole;
diagnosis.stateParticipation = participation;
diagnosis.modalParticipationTable = modalParticipationTable;
diagnosis.modalResidueTable = modalResidueTable;
end
