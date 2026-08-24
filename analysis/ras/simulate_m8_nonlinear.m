function result = simulate_m8_nonlinear(scenario, projectRoot, config)
%SIMULATE_M8_NONLINEAR Run one reproducible nonlinear Simulink scenario.
%   Scenario inputs and initial conditions are applied exclusively through
%   Simulink.SimulationInput. The returned signals use absolute plant and
%   incremental estimator coordinates.

arguments
    scenario (1, 1) struct
    projectRoot (1, 1) string = string(fileparts(fileparts(fileparts( ...
        mfilename('fullpath')))))
    config (1, 1) struct = m8_specs
end

projectRoot = char(projectRoot);
modelPath = fullfile(projectRoot, config.modelRelativePath);
if ~isfile(modelPath)
    build_m8_simulink_model(string(projectRoot));
end
m3 = load(fullfile(projectRoot, 'results', 'data', ...
    'm3_nominal_actuated_plant.mat'));

scenario = localApplyDefaults(scenario, m3, config);
time = (0:config.simulation.inputTimeStep:scenario.horizon).';
reference = localExpandSignal(scenario.reference, numel(time), 2);
disturbance = localExpandSignal(scenario.disturbance, numel(time), 2);
measurementNoise = localExpandSignal( ...
    scenario.measurementNoise, numel(time), 4);

inputDataset = Simulink.SimulationData.Dataset;
inputDataset = inputDataset.addElement( ...
    localTimeseries(reference, time), 'Reference');
inputDataset = inputDataset.addElement( ...
    localTimeseries(disturbance, time), 'Disturbance');
inputDataset = inputDataset.addElement( ...
    localTimeseries(measurementNoise, time), 'Measurement Noise');

modelName = char(config.modelName);
load_system(modelPath);
simulationInput = Simulink.SimulationInput(modelName);
simulationInput = simulationInput.setExternalInput(inputDataset);
simulationInput = simulationInput.setModelParameter( ...
    'StopTime', localNumber(scenario.horizon), ...
    'Solver', char(scenario.solver), ...
    'SolverType', 'Variable-step', ...
    'RelTol', localNumber(config.solver.relativeTolerance), ...
    'AbsTol', localNumber(config.solver.absoluteTolerance), ...
    'MaxStep', localNumber(config.solver.maximumStep), ...
    'ReturnWorkspaceOutputs', 'on');
simulationInput = simulationInput.setBlockParameter( ...
    modelName + "/Controller/M6 LQG", ...
    'InitialCondition', localMatrix(scenario.xhat0));
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

assert(size(loggedData, 2) == 36, 'M8Simulation:LoggedWidth', ...
    'The M8 logging vector must contain exactly 36 signals.');
result.completed = true;
result.time = loggedTime;
result.xMechanical = loggedData(:, 1:8);
result.xActuator = loggedData(:, 9:14);
result.xhat = loggedData(:, 15:28);
result.control = loggedData(:, 29:30);
result.motorTorque = loggedData(:, 31:32);
result.deltaMeasurement = loggedData(:, 33:36);
result.reference = interp1(time, reference, loggedTime, 'previous');
result.disturbance = interp1(time, disturbance, loggedTime, 'previous');
result.measurementNoise = interp1( ...
    time, measurementNoise, loggedTime, 'previous');
result.elapsedWallTime = elapsedWallTime;
result.solver = string(scenario.solver);
result.scenario = scenario;
result.simulationMetadata = simulationOutput.SimulationMetadata;
end

function scenario = localApplyDefaults(scenario, m3, config)
[Aact, Bact] = ssdata(m3.GactuatorsMimo);
xActuatorEquilibrium = -Aact \ (Bact * m3.taubar);
defaults = struct( ...
    'reference', zeros(1, 2), ...
    'disturbance', zeros(1, 2), ...
    'measurementNoise', zeros(1, 4), ...
    'xMechanical0', m3.xbar, ...
    'xActuator0', xActuatorEquilibrium, ...
    'xhat0', zeros(14, 1), ...
    'horizon', config.simulation.equilibriumHorizon, ...
    'solver', config.solver.selected);
names = fieldnames(defaults);
for index = 1:numel(names)
    name = names{index};
    if ~isfield(scenario, name)
        scenario.(name) = defaults.(name);
    end
end
scenario.xMechanical0 = reshape(scenario.xMechanical0, 8, 1);
scenario.xActuator0 = reshape(scenario.xActuator0, 6, 1);
scenario.xhat0 = reshape(scenario.xhat0, 14, 1);
end

function signal = localExpandSignal(signal, numberSamples, width)
if isvector(signal) && numel(signal) == width
    signal = repmat(reshape(signal, 1, width), numberSamples, 1);
end
assert(isequal(size(signal), [numberSamples, width]), ...
    'M8Simulation:InputDimensions', ...
    'Every scenario input must be constant or match the input time grid.');
end

function timeSeries = localTimeseries(data, time)
timeSeries = timeseries(data, time);
timeSeries.DataInfo.Interpolation = tsdata.interpolation('zoh');
end

function [time, data] = localExtractOutput(simulationOutput)
output = simulationOutput.get('yout');
if isa(output, 'Simulink.SimulationData.Dataset')
    element = output.getElement(1);
    values = element.Values;
elseif isa(output, 'timeseries')
    values = output;
else
    error('M8Simulation:UnexpectedOutput', ...
        'Unexpected Simulink output container %s.', class(output));
end
time = values.Time;
data = squeeze(values.Data);
if size(data, 1) ~= numel(time)
    data = data.';
end
end

function value = localMatrix(matrix)
value = mat2str(matrix, 17);
end

function value = localNumber(number)
value = sprintf('%.17g', number);
end
