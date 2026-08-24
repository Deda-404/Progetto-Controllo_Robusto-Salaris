function metadata = build_m8_simulink_model(projectRoot)
%BUILD_M8_SIMULINK_MODEL Build the original nonlinear M8 Simulink model.
%   All numeric controller/actuator/equilibrium parameters are embedded
%   from validated repository datasets. Runtime signals and initial states
%   are supplied with Simulink.SimulationInput, never through base-workspace
%   variables.

arguments
    projectRoot (1, 1) string = string(fileparts(fileparts( ...
        mfilename('fullpath'))))
end

projectRoot = char(projectRoot);
dataDirectory = fullfile(projectRoot, 'results', 'data');
m3 = load(fullfile(dataDirectory, 'm3_nominal_actuated_plant.mat'));
m6 = load(fullfile(dataDirectory, 'm6_lqg_no_integrator.mat'));
config = m8_specs;
modelName = char(config.modelName);
modelPath = fullfile(projectRoot, config.modelRelativePath);

load_system('simulink');
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end
if isfile(modelPath)
    load_system(modelPath);
    Simulink.BlockDiagram.deleteContents(modelName);
else
    new_system(modelName);
end
cleanupModel = onCleanup(@() localCloseIfLoaded(modelName));

set_param(modelName, 'Solver', char(config.solver.selected), ...
    'SolverType', 'Variable-step', ...
    'RelTol', localNumber(config.solver.relativeTolerance), ...
    'AbsTol', localNumber(config.solver.absoluteTolerance), ...
    'MaxStep', localNumber(config.solver.maximumStep), ...
    'StopTime', localNumber(config.simulation.equilibriumHorizon), ...
    'ReturnWorkspaceOutputs', 'on', ...
    'SaveOutput', 'on', 'OutputSaveName', 'yout', ...
    'SaveFormat', 'Dataset', ...
    'SignalLogging', 'on', 'SignalLoggingName', 'logsout');

localAddRootPorts(modelName);
localAddController(modelName, m3, m6);
localAddActuators(modelName, m3);
localAddNonlinearPlant(modelName, m3);
localAddMeasurementAndLogging(modelName, m3);
localConnectRoot(modelName);

metadata.modelName = string(modelName);
metadata.modelPath = string(modelPath);
metadata.architecture = ...
    "M6 LQG -> nominal M3 actuators -> nonlinear M1 SEA";
metadata.nonlinearPlantSource = ...
    "sea_nonlinear_rhs_with_link_disturbance";
metadata.controllerSource = "results/data/m6_lqg_no_integrator.mat";
metadata.controllerGainFields = ["K"; "L"; "Nr"];
metadata.controllerStateCount = 14;
metadata.mechanicalStateCount = 8;
metadata.actuatorStateCount = 6;
metadata.physicalPlantStateCount = 14;
metadata.totalContinuousStateCount = 28;
metadata.absolutePlantCoordinates = true;
metadata.incrementalControllerCoordinates = true;
metadata.baseWorkspaceDependency = false;
metadata.saturationEnabled = false;
metadata.K = m6.K;
metadata.L = m6.L;
metadata.Nr = m6.Nr;
metadata.xbar = m3.xbar;
metadata.taubar = m3.taubar;
metadata.actuatorEquilibrium = localActuatorEquilibrium(m3);
metadata.solver = config.solver;
set_param(modelName, 'Description', char(metadata.architecture));

annotation = Simulink.Annotation(modelName, sprintf([ ...
    'M8 — M6 LQG without integrator\n' ...
    'absolute nonlinear M1 mechanics + nominal M3 actuator bank\n' ...
    'runtime inputs/initial conditions via SimulationInput']));
annotation.Position = [420, 15, 860, 60];

Simulink.BlockDiagram.arrangeSystem(modelName);
save_system(modelName, modelPath);
metadata.saved = isfile(modelPath);
clear cleanupModel
close_system(modelName, 0);
end

function localAddRootPorts(modelName)
localAddBlock('simulink/Ports & Subsystems/In1', ...
    [modelName '/Reference'], [25, 90, 55, 110], ...
    'Port', '1', 'PortDimensions', '2');
localAddBlock('simulink/Ports & Subsystems/In1', ...
    [modelName '/Disturbance'], [25, 230, 55, 250], ...
    'Port', '2', 'PortDimensions', '2');
localAddBlock('simulink/Ports & Subsystems/In1', ...
    [modelName '/Measurement Noise'], [25, 350, 55, 370], ...
    'Port', '3', 'PortDimensions', '4');
localAddBlock('simulink/Ports & Subsystems/Out1', ...
    [modelName '/Logged Signals'], [1030, 225, 1060, 245], ...
    'Port', '1');
end

function localAddController(modelName, m3, m6)
subsystem = [modelName '/Controller'];
localAddBlock('built-in/Subsystem', subsystem, [180, 75, 370, 175]);
set_param(subsystem, 'BackgroundColor', 'lightBlue');
localAddBlock('simulink/Ports & Subsystems/In1', ...
    [subsystem '/delta r'], [20, 30, 50, 50], ...
    'Port', '1', 'PortDimensions', '2');
localAddBlock('simulink/Ports & Subsystems/In1', ...
    [subsystem '/delta y noisy'], [20, 100, 50, 120], ...
    'Port', '2', 'PortDimensions', '4');
localAddBlock('simulink/Signal Routing/Mux', ...
    [subsystem '/Controller Inputs'], [85, 40, 90, 115], ...
    'Inputs', '2');

controller = m6.Klqg;
A = controller.A;
B = controller.B;
C = [controller.C; eye(14)];
D = [controller.D; zeros(14, 6)];
localAddBlock('simulink/Continuous/State-Space', ...
    [subsystem '/M6 LQG'], [125, 55, 225, 105], ...
    'A', localMatrix(A), 'B', localMatrix(B), ...
    'C', localMatrix(C), 'D', localMatrix(D), ...
    'InitialCondition', localMatrix(zeros(14, 1)));
localAddBlock('simulink/Signal Routing/Demux', ...
    [subsystem '/Control and Estimate'], [255, 50, 260, 115], ...
    'Outputs', '[2 14]');
localAddBlock('simulink/Sources/Constant', ...
    [subsystem '/Equilibrium Torque'], [275, 15, 340, 40], ...
    'Value', localMatrix(m3.taubar));
localAddBlock('simulink/Math Operations/Sum', ...
    [subsystem '/Absolute Control'], [370, 45, 395, 70], ...
    'Inputs', '++');
localAddBlock('simulink/Ports & Subsystems/Out1', ...
    [subsystem '/u absolute'], [440, 50, 470, 70], 'Port', '1');
localAddBlock('simulink/Ports & Subsystems/Out1', ...
    [subsystem '/xhat delta'], [440, 105, 470, 125], 'Port', '2');

add_line(subsystem, 'delta r/1', 'Controller Inputs/1');
add_line(subsystem, 'delta y noisy/1', 'Controller Inputs/2');
add_line(subsystem, 'Controller Inputs/1', 'M6 LQG/1');
add_line(subsystem, 'M6 LQG/1', 'Control and Estimate/1');
add_line(subsystem, 'Control and Estimate/1', 'Absolute Control/1');
add_line(subsystem, 'Equilibrium Torque/1', 'Absolute Control/2');
add_line(subsystem, 'Absolute Control/1', 'u absolute/1');
add_line(subsystem, 'Control and Estimate/2', 'xhat delta/1');
end

function localAddActuators(modelName, m3)
subsystem = [modelName '/Actuators'];
localAddBlock('built-in/Subsystem', subsystem, [440, 70, 610, 165]);
set_param(subsystem, 'BackgroundColor', 'orange');
localAddBlock('simulink/Ports & Subsystems/In1', ...
    [subsystem '/u'], [20, 55, 50, 75], ...
    'Port', '1', 'PortDimensions', '2');
[A, B, Cact, Dact] = ssdata(m3.GactuatorsMimo);
C = [Cact; eye(6)];
D = [Dact; zeros(6, 2)];
xactbar = localActuatorEquilibrium(m3);
localAddBlock('simulink/Continuous/State-Space', ...
    [subsystem '/M3 Second Order plus Pade'], [90, 45, 220, 85], ...
    'A', localMatrix(A), 'B', localMatrix(B), ...
    'C', localMatrix(C), 'D', localMatrix(D), ...
    'InitialCondition', localMatrix(xactbar));
localAddBlock('simulink/Signal Routing/Demux', ...
    [subsystem '/Torque and State'], [255, 40, 260, 100], ...
    'Outputs', '[2 6]');
localAddBlock('simulink/Ports & Subsystems/Out1', ...
    [subsystem '/tau'], [305, 45, 335, 65], 'Port', '1');
localAddBlock('simulink/Ports & Subsystems/Out1', ...
    [subsystem '/xact'], [305, 90, 335, 110], 'Port', '2');
add_line(subsystem, 'u/1', 'M3 Second Order plus Pade/1');
add_line(subsystem, 'M3 Second Order plus Pade/1', ...
    'Torque and State/1');
add_line(subsystem, 'Torque and State/1', 'tau/1');
add_line(subsystem, 'Torque and State/2', 'xact/1');
end

function localAddNonlinearPlant(modelName, m3)
subsystem = [modelName '/Nonlinear SEA Plant'];
localAddBlock('built-in/Subsystem', subsystem, [680, 70, 855, 190]);
set_param(subsystem, 'BackgroundColor', 'green');
localAddBlock('simulink/Ports & Subsystems/In1', ...
    [subsystem '/tau'], [20, 35, 50, 55], ...
    'Port', '1', 'PortDimensions', '2');
localAddBlock('simulink/Ports & Subsystems/In1', ...
    [subsystem '/d link'], [20, 95, 50, 115], ...
    'Port', '2', 'PortDimensions', '2');
localAddBlock(['simulink/User-Defined Functions/' ...
    'Level-2 MATLAB S-Function'], [subsystem '/M1 Nonlinear Dynamics'], ...
    [100, 45, 245, 105], 'FunctionName', ...
    'm8_nonlinear_sea_sfun', 'Parameters', localMatrix(m3.xbar));
localAddBlock('simulink/Ports & Subsystems/Out1', ...
    [subsystem '/x mechanical'], [300, 65, 330, 85], 'Port', '1');
add_line(subsystem, 'tau/1', 'M1 Nonlinear Dynamics/1');
add_line(subsystem, 'd link/1', 'M1 Nonlinear Dynamics/2');
add_line(subsystem, 'M1 Nonlinear Dynamics/1', 'x mechanical/1');
end

function localAddMeasurementAndLogging(modelName, m3)
localAddBlock('simulink/Signal Routing/Demux', ...
    [modelName '/Mechanical Coordinates'], [875, 70, 880, 190], ...
    'Outputs', '[2 2 2 2]');
localAddBlock('simulink/Signal Routing/Mux', ...
    [modelName '/Absolute Encoders'], [905, 75, 910, 145], ...
    'Inputs', '2');
ybar = [m3.xbar(1:2); m3.xbar(5:6)];
localAddBlock('simulink/Math Operations/Bias', ...
    [modelName '/Incremental Measurements'], [935, 85, 995, 125], ...
    'Bias', localMatrix(-ybar));
localAddBlock('simulink/Math Operations/Sum', ...
    [modelName '/Add Measurement Noise'], [1025, 90, 1050, 115], ...
    'Inputs', '++');
localAddBlock('simulink/Signal Routing/Mux', ...
    [modelName '/Logging'], [900, 220, 905, 390], 'Inputs', '6');

add_line(modelName, 'Mechanical Coordinates/1', 'Absolute Encoders/1');
add_line(modelName, 'Mechanical Coordinates/3', 'Absolute Encoders/2');
add_line(modelName, 'Absolute Encoders/1', ...
    'Incremental Measurements/1');
add_line(modelName, 'Incremental Measurements/1', ...
    'Add Measurement Noise/1');
add_line(modelName, 'Measurement Noise/1', 'Add Measurement Noise/2');
end

function localConnectRoot(modelName)
add_line(modelName, 'Reference/1', 'Controller/1', 'autorouting', 'on');
add_line(modelName, 'Add Measurement Noise/1', 'Controller/2', ...
    'autorouting', 'on');
add_line(modelName, 'Controller/1', 'Actuators/1', 'autorouting', 'on');
add_line(modelName, 'Actuators/1', 'Nonlinear SEA Plant/1', ...
    'autorouting', 'on');
add_line(modelName, 'Disturbance/1', 'Nonlinear SEA Plant/2', ...
    'autorouting', 'on');
add_line(modelName, 'Nonlinear SEA Plant/1', ...
    'Mechanical Coordinates/1', 'autorouting', 'on');
add_line(modelName, 'Nonlinear SEA Plant/1', 'Logging/1', ...
    'autorouting', 'on');
add_line(modelName, 'Actuators/2', 'Logging/2', 'autorouting', 'on');
add_line(modelName, 'Controller/2', 'Logging/3', 'autorouting', 'on');
add_line(modelName, 'Controller/1', 'Logging/4', 'autorouting', 'on');
add_line(modelName, 'Actuators/1', 'Logging/5', 'autorouting', 'on');
add_line(modelName, 'Add Measurement Noise/1', 'Logging/6', ...
    'autorouting', 'on');
loggedLine = add_line(modelName, 'Logging/1', 'Logged Signals/1', ...
    'autorouting', 'on');
set_param(loggedLine, 'Name', 'm8LoggedSignals');
end

function block = localAddBlock(source, destination, position, varargin)
block = add_block(source, destination, 'Position', position, varargin{:});
end

function equilibrium = localActuatorEquilibrium(m3)
[Aact, Bact] = ssdata(m3.GactuatorsMimo);
equilibrium = -Aact \ (Bact * m3.taubar);
end

function value = localMatrix(matrix)
value = mat2str(matrix, 17);
end

function value = localNumber(number)
value = sprintf('%.17g', number);
end

function localCloseIfLoaded(modelName)
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end
end
