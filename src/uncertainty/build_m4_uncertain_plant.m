function [GuncMeas, GuncQ, info] = build_m4_uncertain_plant( ...
    GmechUncMeas, GmechUncQ, WI)
%BUILD_M4_UNCERTAIN_PLANT Mechanical ureal plus two independent actuators.

nominalActuatorParams = actuator_params_nominal;
[GactuatorNominal, ~] = build_nominal_actuator(nominalActuatorParams);
DeltaAct1 = ultidyn('Delta_act1', [1, 1], ...
    'Type', 'GainBounded', 'Bound', 1);
DeltaAct2 = ultidyn('Delta_act2', [1, 1], ...
    'Type', 'GainBounded', 'Bound', 1);

GactuatorUnc1 = GactuatorNominal * (1 + WI * DeltaAct1);
GactuatorUnc2 = GactuatorNominal * (1 + WI * DeltaAct2);
GactuatorsUncertain = append(GactuatorUnc1, GactuatorUnc2);
GactuatorsUncertain.InputName = {'u1', 'u2'};
GactuatorsUncertain.OutputName = {'tau1', 'tau2'};

GuncMeas = series(GactuatorsUncertain, GmechUncMeas);
GuncQ = series(GactuatorsUncertain, GmechUncQ);
GuncMeas.InputName = {'u1', 'u2'};
GuncMeas.OutputName = {'q1', 'q2', 'theta1', 'theta2'};
GuncQ.InputName = {'u1', 'u2'};
GuncQ.OutputName = {'q1', 'q2'};

info.GactuatorNominal = GactuatorNominal;
info.GactuatorUnc1 = GactuatorUnc1;
info.GactuatorUnc2 = GactuatorUnc2;
info.GactuatorsUncertain = GactuatorsUncertain;
info.DeltaAct1 = DeltaAct1;
info.DeltaAct2 = DeltaAct2;
info.WI = WI;
info.uncertaintyNames = string(fieldnames(GuncMeas.Uncertainty));
info.convention = ...
    "input multiplicative: Ga_unc = Ga_nom * (1 + WI * Delta_act)";
end
