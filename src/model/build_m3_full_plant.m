function [GfullMeas, GfullQ, info] = build_m3_full_plant( ...
    Amech, Bmech, Cmeas, Dmeas, Cq, Dq, Gactuators)
%BUILD_M3_FULL_PLANT Explicit 14-state cascade: actuators then SEA mechanics.
%   Full state order is [x_mech; x_act], with 8 mechanical states followed
%   by the six states of the two nominal actuator channels.

[Aact, Bact, Cact, Dact] = ssdata(Gactuators);
nMechanical = size(Amech, 1);
nActuator = size(Aact, 1);

Afull = [ ...
    Amech, Bmech * Cact; ...
    zeros(nActuator, nMechanical), Aact];
Bfull = [Bmech * Dact; Bact];
CfullMeas = [Cmeas, Dmeas * Cact];
DfullMeas = Dmeas * Dact;
CfullQ = [Cq, Dq * Cact];
DfullQ = Dq * Dact;

mechanicalStateNames = { ...
    'q1', 'q2', 'q1dot', 'q2dot', ...
    'theta1', 'theta2', 'theta1dot', 'theta2dot'};
actuatorStateNames = Gactuators.StateName(:).';
fullStateNames = [mechanicalStateNames, actuatorStateNames];

GfullMeas = ss(Afull, Bfull, CfullMeas, DfullMeas, ...
    'StateName', fullStateNames, 'InputName', {'u1', 'u2'}, ...
    'OutputName', {'q1', 'q2', 'theta1', 'theta2'});
GfullQ = ss(Afull, Bfull, CfullQ, DfullQ, ...
    'StateName', fullStateNames, 'InputName', {'u1', 'u2'}, ...
    'OutputName', {'q1', 'q2'});

info.Afull = Afull;
info.Bfull = Bfull;
info.CfullMeas = CfullMeas;
info.DfullMeas = DfullMeas;
info.CfullQ = CfullQ;
info.DfullQ = DfullQ;
info.fullStateNames = fullStateNames;
info.mechanicalStateCount = nMechanical;
info.actuatorStateCount = nActuator;
end
