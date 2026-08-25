function tests = test_m11_hinfstruct
%TEST_M11_HINFSTRUCT Structured H-infinity campaign checks for M11.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(projectRoot, 'src')));
addpath(genpath(fullfile(projectRoot, 'controllers')));
addpath(genpath(fullfile(projectRoot, 'analysis')));
datasetPath = fullfile(projectRoot, 'results', 'data', ...
    'm11_hinfstruct_structured.mat');
if ~isfile(datasetPath)
    validate_m11_hinfstruct;
end
testCase.TestData.projectRoot = projectRoot;
testCase.TestData.m11 = load(datasetPath);
testCase.TestData.m10 = load(fullfile(projectRoot, 'results', 'data', ...
    'm10_hinfsyn_nominal.mat'));
testCase.TestData.m9 = load(fullfile(projectRoot, 'results', 'data', ...
    'm9_hinf_mixsyn_nominal.mat'));
testCase.TestData.m6 = load(fullfile(projectRoot, 'results', 'data', ...
    'm6_lqg_no_integrator.mat'));
testCase.TestData.m5 = load(fullfile(projectRoot, 'results', 'data', ...
    'm5_performance_specs.mat'));
testCase.TestData.m3 = load(fullfile(projectRoot, 'results', 'data', ...
    'm3_nominal_actuated_plant.mat'));
end

function testT01BaselineCommitIsRecorded(testCase)
verifyEqual(testCase, testCase.TestData.m11.sourceAudit.baselineCommit, ...
    "47ea295aef28a941f2f443033c03f10c5a6caa4d");
end

function testT02GeneralizedPlantIsExactlyFrozen(testCase)
audit = testCase.TestData.m11.sourceAudit;
verifyLessThanOrEqual(testCase, ...
    audit.generalizedPlantMaximumFrequencyError, ...
    testCase.TestData.m11.config.generalizedPlantIdentityTolerance);
verifyTrue(testCase, audit.sameInputNames);
verifyTrue(testCase, audit.sameOutputNames);
end

function testT03M5WeightsAreExactlyFrozen(testCase)
audit = testCase.TestData.m11.sourceAudit;
verifyLessThanOrEqual(testCase, audit.W1TransferError, ...
    testCase.TestData.m11.config.weightConsistencyTolerance);
verifyLessThanOrEqual(testCase, audit.W2TransferError, ...
    testCase.TestData.m11.config.weightConsistencyTolerance);
end

function testT04W3IsAbsent(testCase)
m11 = testCase.TestData.m11;
verifyEmpty(testCase, m11.config.W3);
verifyTrue(testCase, m11.sourceAudit.W3Absent);
verifyFalse(testCase, m11.metadata.W3Used);
end

function testT05ArchitectureListIsComplete(testCase)
verifyEqual(testCase, testCase.TestData.m11.architectureList.ID, ...
    ["A0"; "A1"; "A2"; "A3"; "A4"; "A5"]);
end

function testT06ControllerOrderLimitIsSix(testCase)
m11 = testCase.TestData.m11;
verifyEqual(testCase, m11.config.maxControllerOrder, 6);
verifyLessThanOrEqual(testCase, ...
    max(m11.architectureList.NominalOrder), 6);
end

function testT07EveryStructureIsTwoByTwo(testCase)
for id = testCase.TestData.m11.architectureList.ID.'
    structure = build_m11_structured_controller(id, ...
        testCase.TestData.m11.config);
    verifyEqual(testCase, size(structure.controller), [2, 2]);
end
end

function testT08A0IsFullStaticGain(testCase)
structure = build_m11_structured_controller("A0", ...
    testCase.TestData.m11.config);
verifyEqual(testCase, structure.initialRealizationOrder, 0);
verifyFalse(testCase, structure.definition.Diagonal);
verifyEqual(testCase, structure.parameterCount, 4);
end

function testT09A1IsDiagonalPI(testCase)
structure = build_m11_structured_controller("A1", ...
    testCase.TestData.m11.config);
verifyTrue(testCase, structure.definition.Diagonal);
verifyEqual(testCase, structure.blockNames, ["K1_A1"; "K2_A1"]);
verifyEqual(testCase, structure.maximumRealizableOrder, 2);
end

function testT10A2IsDiagonalPIDF(testCase)
structure = build_m11_structured_controller("A2", ...
    testCase.TestData.m11.config);
verifyTrue(testCase, structure.definition.Diagonal);
verifyEqual(testCase, structure.blockNames, ["K1_A2"; "K2_A2"]);
verifyEqual(testCase, structure.maximumRealizableOrder, 4);
end

function testT11A3HasOrderTwo(testCase)
structure = build_m11_structured_controller("A3", ...
    testCase.TestData.m11.config);
verifyEqual(testCase, structure.initialRealizationOrder, 2);
verifyEqual(testCase, structure.parameterCount, 16);
end

function testT12A4HasOrderFour(testCase)
structure = build_m11_structured_controller("A4", ...
    testCase.TestData.m11.config);
verifyEqual(testCase, structure.initialRealizationOrder, 4);
verifyEqual(testCase, structure.parameterCount, 36);
end

function testT13A5HasOrderSix(testCase)
structure = build_m11_structured_controller("A5", ...
    testCase.TestData.m11.config);
verifyEqual(testCase, structure.initialRealizationOrder, 6);
verifyEqual(testCase, structure.parameterCount, 64);
end

function testT14FiveStartsWereReturnedPerFamily(testCase)
tableData = testCase.TestData.m11.variabilityTable;
verifyEqual(testCase, tableData.TotalStarts, repmat(5, 6, 1));
verifyEqual(testCase, tableData.ReturnedStarts, repmat(5, 6, 1));
verifyEqual(testCase, ...
    testCase.TestData.m11.campaign.totalReturnedStarts, 30);
end

function testT15CampaignSeedsAreDeterministic(testCase)
config = testCase.TestData.m11.config;
verifyEqual(testCase, config.campaignSeed, 20260827);
verifyEqual(testCase, config.architectureSeeds, ...
    (20260827:20260832).');
verifyFalse(testCase, config.useParallel);
end

function testT16AllStartsHaveAuditableRecords(testCase)
runs = localAllRuns(testCase.TestData.m11);
verifyEqual(testCase, numel(runs), 30);
verifyTrue(testCase, all([runs.infoReturned]));
verifyEqual(testCase, sort(unique([runs.startIndex])).', (1:5).');
end

function testT17ClassificationsAreExplicit(testCase)
runs = localAllRuns(testCase.TestData.m11);
allowed = ["VALID_STABLE", "INVALID_UNSTABLE", ...
    "SOLVER_FAILED", "NUMERICALLY_SUSPECT"];
verifyTrue(testCase, all(ismember([runs.classification].', allowed)));
verifyFalse(testCase, any([runs.classification].' == ""));
end

function testT18EveryExtractedControllerHasStabilityAudit(testCase)
runs = localAllRuns(testCase.TestData.m11);
for run = runs([runs.controllerExtracted]).'
    verifyTrue(testCase, isfield(run.audit, 'internalPoles'));
    verifyEqual(testCase, run.internalStable, ...
        run.audit.metrics.internallyStable);
end
end

function testT19A0AndA1FailuresAreRetained(testCase)
tableData = testCase.TestData.m11.variabilityTable;
rows = tableData(ismember(tableData.ArchitectureID, ["A0", "A1"]), :);
verifyEqual(testCase, rows.ReturnedStarts, [5; 5]);
verifyEqual(testCase, rows.StableStarts, [0; 0]);
verifyEqual(testCase, rows.FamilyStatus, ...
    ["NO_VALID_STABLE"; "NO_VALID_STABLE"]);
end

function testT20UnstableA2CandidatesAreNotDiscarded(testCase)
result = localArchitecture(testCase.TestData.m11, "A2");
verifyEqual(testCase, result.returnedStartCount, 5);
verifyEqual(testCase, sum(isfinite([result.runs.solverObjective])), 4);
verifyEqual(testCase, sum([result.runs.internalStable]), 0);
verifyTrue(testCase, any([result.runs.classification] == ...
    "INVALID_UNSTABLE"));
end

function testT21A3ThroughA5AllStartsAreStable(testCase)
tableData = testCase.TestData.m11.variabilityTable;
rows = tableData(ismember(tableData.ArchitectureID, ...
    ["A3", "A4", "A5"]), :);
verifyEqual(testCase, rows.StableStarts, [5; 5; 5]);
verifyEqual(testCase, rows.FamilyStatus, repmat("ALL_VALID_STABLE", 3, 1));
end

function testT22RepresentativeSelectionIsMinimumAndDeterministic(testCase)
m11 = testCase.TestData.m11;
for id = ["A3", "A4", "A5"]
    result = localArchitecture(m11, id);
    validIndices = find([result.runs.classification] == "VALID_STABLE");
    objectives = [result.runs(validIndices).solverObjective].';
    minimum = min(objectives);
    tied = validIndices(abs(objectives - minimum) <= ...
        m11.config.paretoTolerance * max(1, abs(minimum)));
    verifyEqual(testCase, result.representativeStartIndex, min(tied));
end
end

function testT23SensitivityIsIndependentlyReconstructed(testCase)
for representative = localAvailableRepresentatives( ...
        testCase.TestData.m11).'
    G = testCase.TestData.m3.GfullQ;
    independent = feedback(ss(eye(2)), G * representative.controller);
    verifyLessThanOrEqual(testCase, localFrequencyError( ...
        representative.reconstruction.S, independent), 1e-8);
end
end

function testT24ComplementarySensitivityIsReconstructed(testCase)
for representative = localAvailableRepresentatives( ...
        testCase.TestData.m11).'
    reconstruction = representative.reconstruction;
    verifyLessThanOrEqual(testCase, localFrequencyError( ...
        reconstruction.T, ss(eye(2)) - reconstruction.S), 1e-8);
end
end

function testT25ControlSensitivityIsReconstructed(testCase)
for representative = localAvailableRepresentatives( ...
        testCase.TestData.m11).'
    reconstruction = representative.reconstruction;
    verifyLessThanOrEqual(testCase, localFrequencyError( ...
        reconstruction.KS, representative.controller * ...
        reconstruction.S), 1e-8);
end
end

function testT26WeightedStackIsReconstructed(testCase)
m11 = testCase.TestData.m11;
m5 = testCase.TestData.m5;
for representative = localAvailableRepresentatives(m11).'
    reconstruction = representative.reconstruction;
    independent = [m5.W1 * reconstruction.S; ...
        m5.W2 * reconstruction.KS];
    verifyLessThanOrEqual(testCase, localFrequencyError( ...
        reconstruction.weightedClosedLoop, independent), 1e-8);
end
end

function testT27SolverObjectiveMatchesIndependentNorm(testCase)
m11 = testCase.TestData.m11;
for representative = localAvailableRepresentatives(m11).'
    verifyLessThanOrEqual(testCase, representative.reconstruction. ...
        metrics.objectiveRelativeError, ...
        m11.config.objectiveRelativeTolerance);
end
end

function testT28PClosureMatchesIndependentWeightedStack(testCase)
m11 = testCase.TestData.m11;
for representative = localAvailableRepresentatives(m11).'
    verifyLessThanOrEqual(testCase, representative.reconstruction. ...
        metrics.closedLoopError, ...
        m11.config.closedLoopConsistencyTolerance);
end
end

function testT29FullOrderLowerBoundIsRespected(testCase)
m11 = testCase.TestData.m11;
verifyEqual(testCase, m11.campaign.lowerBoundViolationCount, 0);
for representative = localAvailableRepresentatives(m11).'
    verifyTrue(testCase, representative.reconstruction.metrics. ...
        lowerBoundPassed);
end
end

function testT30VariabilityMetricsUseAllFiniteStarts(testCase)
m11 = testCase.TestData.m11;
for id = m11.architectureList.ID.'
    result = localArchitecture(m11, id);
    row = m11.variabilityTable( ...
        m11.variabilityTable.ArchitectureID == id, :);
    values = [result.runs.solverObjective].';
    values = values(isfinite(values));
    if isempty(values)
        verifyTrue(testCase, isnan(row.BestGamma));
    else
        verifyEqual(testCase, row.BestGamma, min(values), 'AbsTol', 1e-12);
        verifyEqual(testCase, row.MedianGamma, median(values), ...
            'AbsTol', 1e-12);
        verifyEqual(testCase, row.WorstFiniteGamma, max(values), ...
            'AbsTol', 1e-12);
    end
end
end

function testT31ParetoFrontUsesOrderAndGammaOnly(testCase)
m11 = testCase.TestData.m11;
verifyEqual(testCase, m11.recommendation.architectureIDs, ...
    ["A3"; "A4"; "A5"]);
verifyFalse(testCase, m11.metadata.twoDegreeOfFreedomUsed);
verifyEqual(testCase, m11.recommendation.outcome, ...
    "PARETO_CANDIDATES_FOR_REVIEW");
end

function testT32NoParetoCandidateDominatesAnother(testCase)
tableData = testCase.TestData.m11.paretoTable;
for first = 1:height(tableData)
    for second = 1:height(tableData)
        if first == second, continue; end
        dominates = tableData.Order(second) <= tableData.Order(first) && ...
            tableData.WeightedNorm(second) <= ...
                tableData.WeightedNorm(first) && ...
            (tableData.Order(second) < tableData.Order(first) || ...
            tableData.WeightedNorm(second) < tableData.WeightedNorm(first));
        verifyFalse(testCase, dominates);
    end
end
end

function testT33TrackingScenariosAreComplete(testCase)
for representative = localAvailableRepresentatives( ...
        testCase.TestData.m11).'
    tableData = representative.evaluation.trackingMetrics;
    verifyEqual(testCase, height(tableData), 6);
    verifyEqual(testCase, unique(tableData.AmplitudeDeg), [2; 5; 8]);
    verifyEqual(testCase, unique(tableData.Joint), [1; 2]);
end
end

function testT34DisturbanceScenariosAreComplete(testCase)
for representative = localAvailableRepresentatives( ...
        testCase.TestData.m11).'
    tableData = representative.evaluation.disturbanceMetrics;
    verifyEqual(testCase, height(tableData), 6);
    verifyEqual(testCase, unique(tableData.AmplitudeNm), [0.25; 0.5; 1]);
    verifyEqual(testCase, unique(tableData.Joint), [1; 2]);
end
end

function testT35UscaleIsOnlyNormalization(testCase)
m11 = testCase.TestData.m11;
verifyFalse(testCase, m11.metadata.saturationEnabled);
for representative = localAvailableRepresentatives(m11).'
    tableData = representative.evaluation.trackingMetrics;
    verifyEqual(testCase, tableData.PeakControlNormalized, ...
        tableData.PeakControlNm / testCase.TestData.m5.spec.uScale, ...
        'AbsTol', 1e-12);
end
end

function testT36M6ComparisonUsesFrozenArtifact(testCase)
comparison = testCase.TestData.m11.comparisonM6M9M10M11;
row = comparison(comparison.controller == "M6 LQG", :);
verifyEqual(testCase, row.controllerOrder, ...
    order(testCase.TestData.m6.Klqg));
end

function testT37M9ComparisonUsesFrozenArtifact(testCase)
comparison = testCase.TestData.m11.comparisonM6M9M10M11;
row = comparison(comparison.controller == "M9 mixsyn", :);
verifyEqual(testCase, row.objective, testCase.TestData.m9.gamma, ...
    'AbsTol', 1e-12);
end

function testT38M10ComparisonUsesFrozenArtifact(testCase)
m11 = testCase.TestData.m11;
row = m11.comparisonM6M9M10M11( ...
    m11.comparisonM6M9M10M11.controller == "M10 hinfsyn", :);
verifyEqual(testCase, row.objective, ...
    testCase.TestData.m10.gammaHinf, 'AbsTol', 1e-12);
verifyEqual(testCase, m11.gammaFullM10, ...
    testCase.TestData.m10.gammaHinf, 'AbsTol', 1e-12);
end

function testT39NoWeightRetuning(testCase)
m11 = testCase.TestData.m11;
verifyFalse(testCase, m11.config.weightRetuningEnabled);
verifyFalse(testCase, m11.sourceAudit.retuningPerformed);
verifyFalse(testCase, m11.metadata.retuningPerformed);
end

function testT40NoTwoDegreeOfFreedomOrPrefilter(testCase)
m11 = testCase.TestData.m11;
verifyFalse(testCase, m11.config.twoDegreeOfFreedomEnabled);
verifyFalse(testCase, m11.config.prefilterEnabled);
verifyFalse(testCase, m11.metadata.twoDegreeOfFreedomUsed);
verifyFalse(testCase, m11.metadata.prefilterUsed);
end

function testT41NoRobustAnalysis(testCase)
m11 = testCase.TestData.m11;
source = localM11Source(testCase.TestData.projectRoot);
verifyEmpty(testCase, regexp(source, ...
    '\<(mussv|robuststab|robgain|musyn)\s*\(', 'once'));
verifyFalse(testCase, m11.metadata.robustAnalysisPerformed);
end

function testT42M12WasNotStarted(testCase)
m11 = testCase.TestData.m11;
verifyFalse(testCase, m11.config.m12Enabled);
verifyFalse(testCase, m11.metadata.m12Started);
verifyFalse(testCase, m11.recommendation.m12Authorized);
end

function testT43NoMinrealHidesInstability(testCase)
source = localM11Source(testCase.TestData.projectRoot);
verifyEmpty(testCase, regexp(source, '\<minreal\s*\(', 'once'));
for representative = localAvailableRepresentatives( ...
        testCase.TestData.m11).'
    verifyFalse(testCase, representative.reconstruction.metrics. ...
        minrealUsedForGate);
end
end

function testT44OneHinfstructCallSiteAndSixFamilies(testCase)
source = fileread(fullfile(testCase.TestData.projectRoot, ...
    'controllers', 'hinf', 'run_m11_hinfstruct_campaign.m'));
calls = regexp(source, '\[[^\n]+\]\s*=\s*hinfstruct\s*\(', 'match');
verifyEqual(testCase, numel(calls), 1);
verifyEqual(testCase, numel(testCase.TestData.m11. ...
    campaign.architectureResults), 6);
end

function testT45RandomStartSemanticsAreRecorded(testCase)
m11 = testCase.TestData.m11;
verifyEqual(testCase, m11.config.randomStartsPerArchitecture, 4);
verifyEqual(testCase, m11.config.totalStartsPerArchitecture, 5);
verifyEqual(testCase, m11.campaign.multistartSemantics, ...
    "one nominal start plus four internal randomized starts");
end

function testT46RequiredArtifactsExist(testCase)
m11 = testCase.TestData.m11;
verifyTrue(testCase, isfile(fullfile(testCase.TestData.projectRoot, ...
    'results', 'data', 'm11_hinfstruct_structured.mat')));
paths = struct2cell(m11.figurePaths);
verifyEqual(testCase, numel(paths), 6);
verifyTrue(testCase, all(cellfun(@isfile, paths)));
end

function testT47QualityGateSeparatesSoftwareAndPerformance(testCase)
gate = testCase.TestData.m11.qualityGate;
verifyEqual(testCase, gate.structuredCampaignCorrectness, "PASS");
verifyEqual(testCase, gate.reconstruction, "PASS");
verifyEqual(testCase, gate.fullOrderLowerBoundSanity, "PASS");
verifyEqual(testCase, gate.softwareCorrectness, "PASS");
verifyEqual(testCase, gate.weightedNominalPerformance, "FAIL");
verifyEqual(testCase, gate.tracking, "FAIL");
verifyEqual(testCase, gate.overallStatus, "PARTIAL");
end

function testT48NoUnavailableFamilyIsRecommended(testCase)
m11 = testCase.TestData.m11;
validIDs = m11.representativeTable.ArchitectureID( ...
    m11.representativeTable.Valid);
verifyTrue(testCase, all(ismember( ...
    m11.recommendation.architectureIDs, validIDs)));
verifyFalse(testCase, any(ismember(["A0"; "A1"; "A2"], ...
    m11.recommendation.architectureIDs)));
end

function result = localArchitecture(m11, id)
result = m11.campaign.architectureResults( ...
    [m11.campaign.architectureResults.id] == id);
end

function runs = localAllRuns(m11)
runs = vertcat(m11.campaign.architectureResults.runs);
end

function representatives = localAvailableRepresentatives(m11)
representatives = m11.representativeResults( ...
    [m11.representativeResults.available]);
end

function error = localFrequencyError(first, second)
frequencies = logspace(-3, 3, 401);
difference = freqresp(first, frequencies) - freqresp(second, frequencies);
error = max(abs(difference), [], 'all');
end

function source = localM11Source(projectRoot)
files = [dir(fullfile(projectRoot, 'controllers', 'hinf', '*m11*.m')); ...
    dir(fullfile(projectRoot, 'analysis', 'nominal', '*m11*.m')); ...
    dir(fullfile(projectRoot, 'src', 'parameters', '*m11*.m'))];
source = "";
for index = 1:numel(files)
    source = source + newline + string(fileread(fullfile( ...
        files(index).folder, files(index).name)));
end
end
