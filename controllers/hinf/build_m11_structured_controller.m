function structure = build_m11_structured_controller(architectureID, config)
%BUILD_M11_STRUCTURED_CONTROLLER Build one frozen M11 architecture.

arguments
    architectureID (1, 1) string
    config (1, 1) struct = hinfstruct_specs_m11
end

rowIndex = find(config.architectures.ID == architectureID, 1);
assert(~isempty(rowIndex), 'M11Structure:UnknownArchitecture', ...
    'The requested architecture is not part of the frozen M11 campaign.');
definition = config.architectures(rowIndex, :);

switch architectureID
    case "A0"
        controller = tunableGain('K_A0', 2, 2);
        blockNames = "K_A0";
        maximumRealizableOrder = 0;
    case "A1"
        first = tunablePID('K1_A1', 'PI');
        second = tunablePID('K2_A1', 'PI');
        controller = blkdiag(first, second);
        blockNames = ["K1_A1"; "K2_A1"];
        maximumRealizableOrder = 2;
    case "A2"
        first = tunablePID('K1_A2', 'PID');
        second = tunablePID('K2_A2', 'PID');
        controller = blkdiag(first, second);
        blockNames = ["K1_A2"; "K2_A2"];
        maximumRealizableOrder = 4;
    case {"A3", "A4", "A5"}
        stateCount = definition.NominalOrder;
        blockName = "K_" + architectureID;
        controller = tunableSS(char(blockName), stateCount, 2, 2, ...
            'full');
        blockNames = blockName;
        maximumRealizableOrder = stateCount;
    otherwise
        error('M11Structure:UnhandledArchitecture', ...
            'The frozen architecture has no implementation.');
end

assert(isequal(size(controller), [2, 2]), ...
    'M11Structure:Dimensions', ...
    'Every M11 structured controller must be 2-by-2.');
assert(definition.NominalOrder <= config.maxControllerOrder && ...
    maximumRealizableOrder <= config.maxControllerOrder, ...
    'M11Structure:OrderLimit', ...
    'The requested architecture exceeds the M11 order limit.');

structure.id = architectureID;
structure.definition = definition;
structure.controller = controller;
structure.blockNames = blockNames;
structure.initialRealizationOrder = order(controller);
structure.maximumRealizableOrder = maximumRealizableOrder;
structure.parameterCount = definition.ParameterCount;
structure.apiStatus = "READY";
end
