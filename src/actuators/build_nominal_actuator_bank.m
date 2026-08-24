function [Gactuators, info] = build_nominal_actuator_bank(params)
%BUILD_NOMINAL_ACTUATOR_BANK Two identical nominal actuator channels.

[Gact, singleInfo] = build_nominal_actuator(params);
actuator1 = ss(Gact);
actuator2 = ss(Gact);
Gactuators = append(actuator1, actuator2);

Gactuators.InputName = {'u1', 'u2'};
Gactuators.OutputName = {'tau1', 'tau2'};
Gactuators.StateName = { ...
    'act1_x1', 'act1_x2', 'act1_x3', ...
    'act2_x1', 'act2_x2', 'act2_x3'};

info.singleActuator = Gact;
info.singleInfo = singleInfo;
info.numberStates = order(Gactuators);
info.nominallyIdenticalChannels = true;
end
