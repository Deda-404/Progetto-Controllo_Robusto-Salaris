function [GmechUncMeas, GmechUncQ, info] = ...
    build_uncertain_mechanical_plant(selectedMechanicalRanges, qbar)
%BUILD_UNCERTAIN_MECHANICAL_PLANT M4 ureal model from SEA equations.

nominal = sea_params_nominal;
if nargin < 2
    qbar = [pi / 2; 0];
end

m1 = localUncertainValue("m1", nominal.m1, selectedMechanicalRanges);
m2 = localUncertainValue("m2", nominal.m2, selectedMechanicalRanges);
l1 = localUncertainValue("l1", nominal.l1, selectedMechanicalRanges);
l2 = localUncertainValue("l2", nominal.l2, selectedMechanicalRanges);
jm1 = localUncertainValue("Jm1", nominal.Jm(1, 1), ...
    selectedMechanicalRanges);
jm2 = localUncertainValue("Jm2", nominal.Jm(2, 2), ...
    selectedMechanicalRanges);
bm1 = localUncertainValue("Bm1", nominal.Bm(1, 1), ...
    selectedMechanicalRanges);
bm2 = localUncertainValue("Bm2", nominal.Bm(2, 2), ...
    selectedMechanicalRanges);
k1 = localUncertainValue("k1", nominal.Ks(1, 1), ...
    selectedMechanicalRanges);
k2 = localUncertainValue("k2", nominal.Ks(2, 2), ...
    selectedMechanicalRanges);

pUncertain.m1 = m1;
pUncertain.m2 = m2;
pUncertain.l1 = l1;
pUncertain.l2 = l2;
pUncertain.Jm = [jm1, 0; 0, jm2];
pUncertain.Bm = [bm1, 0; 0, bm2];
pUncertain.Ks = [k1, 0; 0, k2];
pUncertain.g = nominal.g;

[Auncertain, Buncertain, equilibrium, linearizationInfo] = ...
    sea_linearize_static_equilibrium_analytic(qbar, pUncertain);
[Cq, Dq, Cmeas, Dmeas] = sea_output_matrices;
GmechUncMeas = uss(Auncertain, Buncertain, Cmeas, Dmeas);
GmechUncQ = uss(Auncertain, Buncertain, Cq, Dq);
GmechUncMeas.InputName = {'tau1', 'tau2'};
GmechUncMeas.OutputName = {'q1', 'q2', 'theta1', 'theta2'};
GmechUncQ.InputName = {'tau1', 'tau2'};
GmechUncQ.OutputName = {'q1', 'q2'};

info.pUncertain = pUncertain;
info.Auncertain = Auncertain;
info.Buncertain = Buncertain;
info.Cmeas = Cmeas;
info.Dmeas = Dmeas;
info.Cq = Cq;
info.Dq = Dq;
info.equilibrium = equilibrium;
info.linearization = linearizationInfo;
info.selectedMechanicalRanges = selectedMechanicalRanges;
info.uncertaintyNames = string(fieldnames(GmechUncMeas.Uncertainty));
end

function value = localUncertainValue(name, nominalValue, rangeTable)
row = find(rangeTable.Parameter == name, 1);
if isempty(row)
    value = nominalValue;
else
    percent = rangeTable.BaselinePercent(row);
    value = ureal(char(name), nominalValue, 'Percentage', percent);
end
end
