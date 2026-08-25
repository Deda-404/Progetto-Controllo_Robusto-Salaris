function model = build_m11_tunable_closed_loop(P, structure, config)
%BUILD_M11_TUNABLE_CLOSED_LOOP Close the frozen M10 plant with K(theta).

arguments
    P {mustBeA(P, {'ss', 'tf', 'zpk'})}
    structure (1, 1) struct
    config (1, 1) struct = hinfstruct_specs_m11
end

assert(isequal(size(P), [6, 4]) && order(P) == 18, ...
    'M11TunableLoop:GeneralizedPlant', ...
    'M11 requires the validated 6-by-4 order-18 M10 plant.');
assert(isequal(size(structure.controller), [2, 2]), ...
    'M11TunableLoop:ControllerDimensions', ...
    'The tunable controller must be 2-by-2.');

tunableClosedLoop = lft(P, structure.controller);
availableBlocks = string(fieldnames(tunableClosedLoop.Blocks));
assert(isequal(size(tunableClosedLoop), [4, 2]) && ...
    all(ismember(structure.blockNames, availableBlocks)), ...
    'M11TunableLoop:Interconnection', ...
    'The tunable weighted closed loop has an unexpected structure.');

model.tunableClosedLoop = tunableClosedLoop;
model.performanceOutputCount = size(tunableClosedLoop, 1);
model.exogenousInputCount = size(tunableClosedLoop, 2);
model.blockNames = availableBlocks;
model.objective = "norm([W1*S;W2*K*S],inf)";
model.sameGeneralizedPlant = true;
model.W3Absent = isempty(config.W3);
end
