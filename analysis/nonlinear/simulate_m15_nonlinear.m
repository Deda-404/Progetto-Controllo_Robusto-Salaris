function result = simulate_m15_nonlinear(controller, scenario, projectRoot, config)
%SIMULATE_M15_NONLINEAR Run one M15 scenario through SimulationInput only.

arguments
    controller (1, 1) struct
    scenario (1, 1) struct
    projectRoot (1, 1) string = string(fileparts(fileparts(fileparts( ...
        mfilename('fullpath')))))
    config (1, 1) struct = m15_specs
end

projectRoot = char(projectRoot);
modelPath = fullfile(projectRoot, config.modelRelativePath);
if ~isfile(modelPath), build_m15_robust_simulink_model(string(projectRoot)); end
m3 = load(fullfile(projectRoot, 'results', 'data', ...
    'm3_nominal_actuated_plant.mat'));
scenario = localApplyDefaults(scenario, m3, controller, config);
time = (0:config.simulation.inputTimeStep:scenario.horizon).';
reference = localExpandSignal(scenario.reference, numel(time), 2);
disturbance = localExpandSignal(scenario.disturbance, numel(time), 2);
measurementNoise = localExpandSignal( ...
    scenario.measurementNoise, numel(time), 2);
inputDataset = Simulink.SimulationData.Dataset;
inputDataset = inputDataset.addElement( ...
    localTimeseries(reference, time), 'Reference');
inputDataset = inputDataset.addElement( ...
    localTimeseries(disturbance, time), 'Disturbance');
inputDataset = inputDataset.addElement( ...
    localTimeseries(measurementNoise, time), 'Measurement Noise q');

modelName = char(config.modelName);
load_system(modelPath);
n = controller.order;
C = [controller.C; eye(n)]; D = [controller.D; zeros(n, 2)];
simulationInput = Simulink.SimulationInput(modelName);
simulationInput = simulationInput.setExternalInput(inputDataset);
simulationInput = simulationInput.setModelParameter( ...
    'StopTime', localNumber(scenario.horizon), ...
    'Solver', char(config.solver.selected), 'SolverType', 'Variable-step', ...
    'RelTol', localNumber(config.solver.relativeTolerance), ...
    'AbsTol', localNumber(config.solver.absoluteTolerance), ...
    'MaxStep', localNumber(config.solver.maximumStep), ...
    'ReturnWorkspaceOutputs', 'on');
controllerBlock = modelName + "/Controller/Frozen Dynamic Controller";
simulationInput = simulationInput.setBlockParameter( ...
    controllerBlock, 'A', localMatrix(controller.A));
simulationInput = simulationInput.setBlockParameter( ...
    controllerBlock, 'B', localMatrix(controller.B));
simulationInput = simulationInput.setBlockParameter( ...
    controllerBlock, 'C', localMatrix(C));
simulationInput = simulationInput.setBlockParameter( ...
    controllerBlock, 'D', localMatrix(D));
simulationInput = simulationInput.setBlockParameter(controllerBlock, ...
    'InitialCondition', localMatrix(scenario.xController0));
simulationInput = simulationInput.setBlockParameter( ...
    modelName + "/Controller/Delta Control and Controller State", ...
    'Outputs', sprintf('[2 %d]', n));
simulationInput = simulationInput.setBlockParameter( ...
    modelName + "/Actuators/M3 Second Order plus Pade", ...
    'InitialCondition', localMatrix(scenario.xActuator0));
simulationInput = simulationInput.setBlockParameter( ...
    modelName + "/Nonlinear SEA Plant/M1 Nonlinear Dynamics", ...
    'Parameters', localMatrix(scenario.xMechanical0));

startTime = tic;
simulationOutput = sim(simulationInput);
elapsedWallTime = toc(startTime);
[loggedTime, loggedData] = localExtractOutput(simulationOutput);
expectedWidth = 30 + n;
assert(size(loggedData, 2) == expectedWidth, 'M15Simulation:LoggedWidth', ...
    'The M15 logging vector has an unexpected width.');
first = 1;
result.completed = true;
result.time = loggedTime;
[result.xMechanical, first] = localTake(loggedData, first, 8);
[result.xActuator, first] = localTake(loggedData, first, 6);
[result.xController, first] = localTake(loggedData, first, n);
[result.controlDelta, first] = localTake(loggedData, first, 2);
[result.controlAbsolute, first] = localTake(loggedData, first, 2);
[result.motorTorque, first] = localTake(loggedData, first, 2);
[result.disturbance, first] = localTake(loggedData, first, 2);
[result.measurementNoise, first] = localTake(loggedData, first, 2);
[result.reference, first] = localTake(loggedData, first, 2);
[result.error, first] = localTake(loggedData, first, 2);
[result.measurementQ, first] = localTake(loggedData, first, 2); %#ok<ASGLU>
result.elapsedWallTime = elapsedWallTime;
result.solver = string(config.solver.selected);
result.controllerID = controller.id;
result.controllerOrder = n;
result.scenario = scenario;
result.simulationMetadata = simulationOutput.SimulationMetadata;
end

function scenario = localApplyDefaults(scenario, m3, controller, config)
[Aact, Bact] = ssdata(m3.GactuatorsMimo);
defaults = struct('reference', zeros(1, 2), ...
    'disturbance', zeros(1, 2), 'measurementNoise', zeros(1, 2), ...
    'xMechanical0', m3.xbar, ...
    'xActuator0', -Aact \ (Bact * m3.taubar), ...
    'xController0', zeros(controller.order, 1), ...
    'horizon', config.simulation.equilibriumHorizon);
names = fieldnames(defaults);
for index = 1:numel(names)
    if ~isfield(scenario, names{index}), scenario.(names{index}) = defaults.(names{index}); end
end
scenario.xMechanical0 = reshape(scenario.xMechanical0, 8, 1);
scenario.xActuator0 = reshape(scenario.xActuator0, 6, 1);
scenario.xController0 = reshape(scenario.xController0, controller.order, 1);
end

function signal = localExpandSignal(signal, numberSamples, width)
if isvector(signal) && numel(signal) == width
    signal = repmat(reshape(signal, 1, width), numberSamples, 1);
end
assert(isequal(size(signal), [numberSamples, width]), ...
    'M15Simulation:InputDimensions', 'Scenario input dimensions are invalid.');
end
function value = localTimeseries(data, time)
value = timeseries(data, time);
value.DataInfo.Interpolation = tsdata.interpolation('zoh');
end
function [values, next] = localTake(data, first, width)
values = data(:, first:first + width - 1); next = first + width;
end
function [time, data] = localExtractOutput(simulationOutput)
output = simulationOutput.get('yout');
if isa(output, 'Simulink.SimulationData.Dataset')
    values = output.getElement(1).Values;
elseif isa(output, 'timeseries')
    values = output;
else
    error('M15Simulation:UnexpectedOutput', ...
        'Unexpected output container %s.', class(output));
end
time = values.Time; data = squeeze(values.Data);
if size(data, 1) ~= numel(time), data = data.'; end
end
function value = localMatrix(matrix), value = mat2str(matrix, 17); end
function value = localNumber(number), value = sprintf('%.17g', number); end
