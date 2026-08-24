function tests = test_m5_performance_specs
%TEST_M5_PERFORMANCE_SPECS M5 targets, weights and disturbance checks.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(projectRoot, 'src')));
addpath(genpath(fullfile(projectRoot, 'analysis')));
m2 = load(fullfile(projectRoot, 'results', 'data', ...
    'm2_linearization_nominal.mat'));
m3 = load(fullfile(projectRoot, 'results', 'data', ...
    'm3_nominal_actuated_plant.mat'));
spec = performance_specs_m5;
selection = select_m5_performance_specs(m2, m3, spec);
[W1siso, W1, W2siso, W2, weightInfo] = build_m5_weights(spec);
[Bd, bdInfo] = build_joint_torque_disturbance_input(m2.qbar, m2.p);
numberActuatorStates = size(m3.Afull, 1) - size(Bd, 1);
BdFull = [Bd; zeros(numberActuatorStates, 2)];
disturbancePlant = ss(m3.Afull, [m3.Bfull, BdFull], ...
    m3.CfullMeas, zeros(4, 4), ...
    'InputName', {'u1', 'u2', 'd1', 'd2'}, ...
    'OutputName', {'q1', 'q2', 'theta1', 'theta2'});

testCase.TestData.projectRoot = projectRoot;
testCase.TestData.m2 = m2;
testCase.TestData.m3 = m3;
testCase.TestData.spec = spec;
testCase.TestData.selection = selection;
testCase.TestData.W1siso = W1siso;
testCase.TestData.W1 = W1;
testCase.TestData.W2siso = W2siso;
testCase.TestData.W2 = W2;
testCase.TestData.weightInfo = weightInfo;
testCase.TestData.Bd = Bd;
testCase.TestData.BdFull = BdFull;
testCase.TestData.bdInfo = bdInfo;
testCase.TestData.disturbancePlant = disturbancePlant;
end

function testT1SpecificationsCentralized(testCase)
spec = testCase.TestData.spec;
requiredFields = {'referenceAmplitude', ...
    'disturbanceTorqueAmplitude', 'omegaB', 'As', 'Ms', 'uScale', ...
    'omegaU', 'controlWeightAlpha', 'settlingTimeTarget', ...
    'overshootTarget', 'crossCouplingTarget', 'metadata'};
verifyTrue(testCase, all(isfield(spec, requiredFields)));
verifyEqual(testCase, spec.referenceAmplitude, deg2rad(5), ...
    'AbsTol', 10 * eps);
verifyEqual(testCase, spec.disturbanceTorqueAmplitude, 0.50);
verifyTrue(testCase, testCase.TestData.selection.declaredBaselineMatches);
verifyEqual(testCase, which('performance_specs_m5'), fullfile( ...
    testCase.TestData.projectRoot, 'src', 'parameters', ...
    'performance_specs_m5.m'));
end

function testT2BandwidthDerivedFromM2AndM3(testCase)
selection = testCase.TestData.selection;
criteria = selection.criteria;
m2 = testCase.TestData.m2;
m3 = testCase.TestData.m3;
unstablePoles = m2.poles(real(m2.poles) > 1e-8);
elasticPoles = m2.poles(abs(imag(m2.poles)) > 1e-8);
verifyEqual(testCase, criteria.lambdaUMax, max(real(unstablePoles)), ...
    'AbsTol', 1e-12);
verifyEqual(testCase, criteria.omegaElasticMin, min(abs(elasticPoles)), ...
    'AbsTol', 1e-12);
verifyEqual(testCase, criteria.omegaActuator, ...
    m3.actuatorInfo.actuatorBandwidth, 'AbsTol', 1e-12);
verifyEqual(testCase, criteria.bandwidthMinimum, ...
    testCase.TestData.spec.bandwidthUnstableMultiplier * ...
    criteria.lambdaUMax, 'AbsTol', 1e-12);
verifyEqual(testCase, criteria.bandwidthMaximum, min( ...
    testCase.TestData.spec.bandwidthActuatorFraction * ...
    criteria.omegaActuator, ...
    testCase.TestData.spec.bandwidthElasticFraction * ...
    criteria.omegaElasticMin), 'AbsTol', 1e-12);

modifiedM3 = m3;
modifiedM3.actuatorInfo.actuatorBandwidth = ...
    0.85 * m3.actuatorInfo.actuatorBandwidth;
modifiedSelection = select_m5_performance_specs( ...
    m2, modifiedM3, testCase.TestData.spec);
verifyNotEqual(testCase, modifiedSelection.criteria.bandwidthMaximum, ...
    criteria.bandwidthMaximum);
verifyEqual(testCase, modifiedSelection.selected.omegaB, 11);
verifyNotEqual(testCase, modifiedSelection.selected.omegaB, ...
    selection.selected.omegaB);
end

function testT3SelectedBandwidthInsideWindow(testCase)
selection = testCase.TestData.selection;
selected = selection.selectedBandwidth;
verifyTrue(testCase, selected.Admissible);
verifyGreaterThanOrEqual(testCase, selected.OmegaB, ...
    selection.criteria.bandwidthMinimum);
verifyLessThanOrEqual(testCase, selected.OmegaB, ...
    selection.criteria.bandwidthMaximum);
verifyEqual(testCase, selected.OmegaB, 12);
verifyEqual(testCase, selected.Ranking, 1);
end

function testT4W1StableAndProper(testCase)
verifyTrue(testCase, testCase.TestData.weightInfo.W1.stable);
verifyTrue(testCase, testCase.TestData.weightInfo.W1.proper);
verifyEqual(testCase, testCase.TestData.weightInfo.W1.order, 1);
verifyTrue(testCase, all(real(pole(testCase.TestData.W1siso)) < 0));
end

function testT5W1Asymptotes(testCase)
spec = testCase.TestData.spec;
info = testCase.TestData.weightInfo.W1;
verifyEqual(testCase, info.dcMeasured, 1 / spec.As, ...
    'AbsTol', 1e-12);
verifyEqual(testCase, info.hfMeasured, 1 / spec.Ms, ...
    'AbsTol', 1e-7);
verifyEqual(testCase, info.dcExpected, 20, 'AbsTol', 1e-12);
verifyEqual(testCase, info.hfExpected, 0.5, 'AbsTol', 1e-12);
end

function testT6W2StableAndProper(testCase)
verifyTrue(testCase, testCase.TestData.weightInfo.W2.stable);
verifyTrue(testCase, testCase.TestData.weightInfo.W2.proper);
verifyEqual(testCase, testCase.TestData.weightInfo.W2.order, 1);
verifyTrue(testCase, all(real(pole(testCase.TestData.W2siso)) < 0));
verifyGreaterThan(testCase, ...
    testCase.TestData.spec.controlWeightAlpha, 1);
end

function testT7W2Asymptotes(testCase)
spec = testCase.TestData.spec;
info = testCase.TestData.weightInfo.W2;
verifyEqual(testCase, info.dcMeasured, 1 / spec.uScale, ...
    'AbsTol', 1e-12);
verifyEqual(testCase, info.hfMeasured, ...
    spec.controlWeightAlpha / spec.uScale, 'AbsTol', 1e-7);
verifyGreaterThan(testCase, info.hfExpected, info.dcExpected);
verifyEqual(testCase, spec.controlEffortScaleMeaning, ...
    "performance normalization; not a certified actuator saturation");
end

function testT8MimoWeightsAreDiagonalTwoByTwo(testCase)
W1 = testCase.TestData.W1;
W2 = testCase.TestData.W2;
verifyEqual(testCase, size(W1), [2, 2]);
verifyEqual(testCase, size(W2), [2, 2]);
frequencies = logspace(-2, 3, 51);
verifyEqual(testCase, squeeze(freqresp(W1(1, 1), frequencies)), ...
    squeeze(freqresp(W1(2, 2), frequencies)), 'AbsTol', 1e-14);
verifyEqual(testCase, squeeze(freqresp(W2(1, 1), frequencies)), ...
    squeeze(freqresp(W2(2, 2), frequencies)), 'AbsTol', 1e-14);
verifyEqual(testCase, squeeze(freqresp(W1(1, 2), frequencies)), ...
    zeros(numel(frequencies), 1), 'AbsTol', 1e-14);
verifyEqual(testCase, squeeze(freqresp(W2(2, 1), frequencies)), ...
    zeros(numel(frequencies), 1), 'AbsTol', 1e-14);
end

function testT9DisturbanceIsLinkSideTorque(testCase)
Bd = testCase.TestData.Bd;
plant = testCase.TestData.disturbancePlant;
verifySize(testCase, Bd, [8, 2]);
verifyEqual(testCase, Bd([1, 2, 5, 6, 7, 8], :), zeros(6, 2));
verifyEqual(testCase, Bd(3:4, :), ...
    sea_link_inertia(testCase.TestData.m2.qbar, ...
    testCase.TestData.m2.p) \ eye(2), 'AbsTol', 1e-12);
verifyEqual(testCase, plant.B(:, 1:2), testCase.TestData.m3.Bfull);
verifyEqual(testCase, plant.B(:, 3:4), testCase.TestData.BdFull);
verifyEqual(testCase, plant.D, zeros(4, 4));
verifyEqual(testCase, string(plant.InputName), ...
    ["u1"; "u2"; "d1"; "d2"]);
verifyEqual(testCase, testCase.TestData.bdInfo.nonzeroRows, [3; 4]);
end

function testT10BdIndependentFiniteDifferenceVerification(testCase)
m2 = testCase.TestData.m2;
step = 1e-6;
numericBd = zeros(8, 2);
for index = 1:2
    perturbation = zeros(2, 1);
    perturbation(index) = step;
    plusDerivative = sea_nonlinear_rhs_with_link_disturbance( ...
        m2.xbar, m2.taubar, perturbation, m2.p);
    minusDerivative = sea_nonlinear_rhs_with_link_disturbance( ...
        m2.xbar, m2.taubar, -perturbation, m2.p);
    numericBd(:, index) = ...
        (plusDerivative - minusDerivative) / (2 * step);
end
verifyEqual(testCase, numericBd, testCase.TestData.Bd, ...
    'AbsTol', 1e-8);
end

function testT11ValidationScenariosDocumented(testCase)
spec = testCase.TestData.spec;
verifyEqual(testCase, spec.referenceAmplitudeScenariosDeg, [2; 5; 8]);
verifyEqual(testCase, spec.disturbanceTorqueScenarios, [0.25; 0.50; 1.00]);
verifyEqual(testCase, spec.referenceAmplitude, deg2rad(5), ...
    'AbsTol', 1e-12);
verifyEqual(testCase, spec.disturbanceTorqueAmplitude, 0.50);
verifyTrue(testCase, any(spec.metadata.Classification == ...
    "approved project decision"));
verifyTrue(testCase, any(spec.metadata.Classification == ...
    "project modeling choice"));
verifyTrue(testCase, any(spec.metadata.Classification == ...
    "project assumption"));
verifyTrue(testCase, any(spec.metadata.Classification == ...
    "derived criterion"));
documentationPath = fullfile(testCase.TestData.projectRoot, 'docs', ...
    'SPECIFICHE_PRESTAZIONE.md');
verifyTrue(testCase, isfile(documentationPath));
documentation = fileread(documentationPath);
verifyTrue(testCase, contains(documentation, '2°, 5° e 8°'));
verifyTrue(testCase, contains(documentation, '0.25, 0.50 e 1.00 N m'));
end

function testT12NoControllerSynthesisExecuted(testCase)
spec = testCase.TestData.spec;
verifyFalse(testCase, spec.controllerSynthesisAllowed);
verifyFalse(testCase, spec.useW3);
files = { ...
    fullfile(testCase.TestData.projectRoot, 'src', 'parameters', ...
        'performance_specs_m5.m'), ...
    fullfile(testCase.TestData.projectRoot, 'src', 'performance', ...
        'build_m5_weights.m'), ...
    fullfile(testCase.TestData.projectRoot, 'analysis', 'nominal', ...
        'select_m5_performance_specs.m'), ...
    fullfile(testCase.TestData.projectRoot, 'analysis', 'nominal', ...
        'validate_m5_performance_specs.m')};
for index = 1:numel(files)
    source = fileread(files{index});
    verifyEmpty(testCase, regexp(source, ...
        '\<(mixsyn|hinfsyn|hinfstruct|musyn|lqr|kalman)\s*\(', 'once'));
end
end

function testT13RegressionM0ThroughM41(testCase)
testFiles = { ...
    'test_m0_workspace.m', ...
    'test_m1_nonlinear_model.m', ...
    'test_m2_equilibrium_linearization.m', ...
    'test_m3_actuator_dynamics.m', ...
    'test_m4_uncertainty_model.m'};
testsDirectory = fullfile(testCase.TestData.projectRoot, 'tests');
suite = testsuite(fullfile(testsDirectory, testFiles{1}));
for index = 2:numel(testFiles)
    suite = [suite, testsuite(fullfile( ...
        testsDirectory, testFiles{index}))]; %#ok<AGROW>
end
results = run(suite);
verifyEqual(testCase, numel(results), 52);
verifyTrue(testCase, all([results.Passed]));
end

function testT14DocumentationGovernance(testCase)
diaryPath = fullfile(testCase.TestData.projectRoot, 'docs', ...
    'DIARIO_DI_BORDO.md');
diary = fileread(diaryPath);
verifyEmpty(testCase, regexp(diary, '(?m)^\*\*Autore:', 'once'));
responsibleEntries = regexp(diary, ...
    '(?m)^\*\*Responsabile:\*\* Alessio\s*$', 'match');
verifyGreaterThan(testCase, numel(responsibleEntries), 0);
verifyTrue(testCase, contains(diary, ...
    'Il campo “Responsabile” identifica il referente umano'));

agentsPath = fullfile(testCase.TestData.projectRoot, 'AGENTS.md');
agentsText = fileread(agentsPath);
verifyTrue(testCase, contains(agentsText, ...
    '### Project documentation voice'));
verifyTrue(testCase, contains(agentsText, '`Responsabile: Alessio`'));
end
