function tests = test_m12_mu_analysis
%TEST_M12_MU_ANALYSIS Frozen A5 NS/NP/RS/RP quality gates for M12.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(projectRoot, 'src')));
addpath(genpath(fullfile(projectRoot, 'controllers')));
addpath(genpath(fullfile(projectRoot, 'analysis')));
datasetPath = fullfile(projectRoot, 'results', 'data', ...
    'm12_mu_analysis_a5.mat');
if ~isfile(datasetPath)
    validate_m12_mu_analysis;
end
testCase.TestData.projectRoot = projectRoot;
testCase.TestData.m12 = load(datasetPath);
for milestone = [3, 4, 5, 10, 11]
    names = containers.Map( ...
        {3, 4, 5, 10, 11}, ...
        {'m3_nominal_actuated_plant.mat', ...
         'm4_uncertain_plant.mat', ...
         'm5_performance_specs.mat', ...
         'm10_hinfsyn_nominal.mat', ...
         'm11_hinfstruct_structured.mat'});
    key = sprintf('m%d', milestone);
    testCase.TestData.(key) = load(fullfile(projectRoot, ...
        'results', 'data', names(milestone)));
end
testCase.TestData.source = localM12Source(projectRoot);
end

function testT01M11ArtifactIsTheControllerSource(testCase)
verifyEqual(testCase, testCase.TestData.m12.metadata.controllerSource, ...
    "results/data/m11_hinfstruct_structured.mat");
verifyTrue(testCase, isfile(fullfile(testCase.TestData.projectRoot, ...
    testCase.TestData.m12.metadata.controllerSource)));
end

function testT02SelectedArchitectureIsA5(testCase)
selected = testCase.TestData.m12.selectedController;
verifyEqual(testCase, selected.architectureID, "A5");
verifyEqual(testCase, selected.startIndex, 5);
end

function testT03ControllerIsIdenticalToM11Representative(testCase)
m12 = testCase.TestData.m12;
m11 = testCase.TestData.m11;
index = find(string({m11.representativeResults.architectureID}) == "A5");
reference = m11.representativeResults(index).controller;
[A, B, C, D] = ssdata(m12.K_A5);
[Ar, Br, Cr, Dr] = ssdata(reference);
verifyEqual(testCase, A, Ar, 'AbsTol', 0);
verifyEqual(testCase, B, Br, 'AbsTol', 0);
verifyEqual(testCase, C, Cr, 'AbsTol', 0);
verifyEqual(testCase, D, Dr, 'AbsTol', 0);
end

function testT04ControllerOrderIsSix(testCase)
verifyEqual(testCase, order(testCase.TestData.m12.K_A5), 6);
verifyEqual(testCase, testCase.TestData.m12.selectedController.order, 6);
end

function testT05ControllerWasLoadedWithoutTuning(testCase)
m12 = testCase.TestData.m12;
verifyTrue(testCase, m12.selectedController.loadedWithoutTuning);
verifyFalse(testCase, m12.metadata.controllerTuningPerformed);
end

function testT06M4ArtifactIsTheUncertaintySource(testCase)
verifyEqual(testCase, testCase.TestData.m12.metadata.uncertaintySource, ...
    "results/data/m4_uncertain_plant.mat");
end

function testT07M4NominalModelReproducesM3(testCase)
audit = testCase.TestData.m12.M4SourceAudit;
verifyTrue(testCase, audit.passed);
verifyLessThanOrEqual(testCase, audit.maximumFrequencyError, ...
    testCase.TestData.m12.config.nominalFrequencyTolerance);
verifyLessThanOrEqual(testCase, audit.poleInclusionError, ...
    testCase.TestData.m12.config.nominalPoleTolerance);
verifyTrue(testCase, audit.additionalNominalPolesStable);
end

function testT08FrozenUncertaintyBlockSetIsExact(testCase)
m12 = testCase.TestData.m12;
verifyEqual(testCase, sort(m12.M4SourceAudit.uncertaintyNames), ...
    sort(m12.config.expectedUncertaintyNames));
verifyTrue(testCase, all(m12.M4SourceAudit.rangeTable.ApprovedStructure));
end

function testT09M5WeightsAreFrozen(testCase)
m12 = testCase.TestData.m12;
verifyLessThanOrEqual(testCase, m12.weightAudit.W1Error, ...
    m12.config.nominalFrequencyTolerance);
verifyLessThanOrEqual(testCase, m12.weightAudit.W2Error, ...
    m12.config.nominalFrequencyTolerance);
verifyFalse(testCase, m12.weightAudit.retuningPerformed);
end

function testT10W3RemainsAbsent(testCase)
m12 = testCase.TestData.m12;
verifyEmpty(testCase, m12.config.W3);
verifyTrue(testCase, m12.weightAudit.W3Absent);
verifyFalse(testCase, m12.metadata.W3Used);
end

function testT11PuncHasExpectedDimensions(testCase)
verifyEqual(testCase, size(testCase.TestData.m12.Punc), [6, 4]);
end

function testT12UncertainClosedLoopHasExpectedDimensions(testCase)
verifyEqual(testCase, size(testCase.TestData.m12.Tzw_unc), [4, 2]);
end

function testT13PuncNominalValueMatchesM10(testCase)
m12 = testCase.TestData.m12;
verifyLessThanOrEqual(testCase, m12.PuncNominalError, ...
    m12.config.nominalFrequencyTolerance);
end

function testT14NominalStabilityIsReconstructed(testCase)
audit = testCase.TestData.m12.nominalReconstruction;
verifyEqual(testCase, audit.NSOutcome, "PASS");
verifyTrue(testCase, audit.metrics.internallyStable);
verifyEqual(testCase, audit.metrics.internalStateCount, 20);
end

function testT15NominalPolesMatchM11(testCase)
audit = testCase.TestData.m12.nominalReconstruction;
verifyLessThanOrEqual(testCase, audit.metrics.poleErrorVsM11, ...
    testCase.TestData.m12.config.nominalPoleTolerance);
verifyLessThan(testCase, audit.metrics.maximumRealPart, 0);
end

function testT16NominalWeightedNormMatchesM11(testCase)
m12 = testCase.TestData.m12;
verifyLessThanOrEqual(testCase, ...
    m12.nominalReconstruction.metrics.normRelativeErrorVsM11, ...
    m12.config.nominalNormRelativeTolerance);
verifyEqual(testCase, m12.NPMetrics.gammaNominal, ...
    m12.nominalReconstruction.metrics.gammaNominal, ...
    'RelTol', 1e-12);
end

function testT17NominalPerformanceClassificationIsExplicit(testCase)
m12 = testCase.TestData.m12;
expected = localPassFail(m12.NPMetrics.gammaNominal < ...
    m12.config.gammaTarget);
verifyEqual(testCase, m12.NPMetrics.outcome, expected);
verifyEqual(testCase, m12.NPMetrics.outcome, "FAIL");
end

function testT18LftDataPartitionDimensionsAreSaved(testCase)
audit = testCase.TestData.m12.lftEquivalenceAudit;
verifyEqual(testCase, audit.MSize, [9, 7]);
verifyEqual(testCase, audit.DeltaSize, [5, 5]);
end

function testT19BlockStructureIsComplete(testCase)
m12 = testCase.TestData.m12;
verifyEqual(testCase, numel(m12.BlkStruct), 5);
verifyEqual(testCase, sort(m12.deltaStructureTable.Name), ...
    sort(m12.config.expectedUncertaintyNames));
verifyEqual(testCase, m12.deltaStructureTable.Occurrences, ones(5, 1));
end

function testT20NormalizedUncertaintyIsValid(testCase)
m12 = testCase.TestData.m12;
verifyEqual(testCase, numel(m12.normunc), 5);
verifyTrue(testCase, ...
    all(m12.decomposition.normalizedOccurrenceTable.NormalizedValid));
verifyTrue(testCase, m12.lftEquivalenceAudit.normalizedUncertaintyValid);
end

function testT21LftReconstructionPassesNominalAndProbeAudits(testCase)
m12 = testCase.TestData.m12;
verifyTrue(testCase, m12.lftEquivalenceAudit.passed);
verifyLessThanOrEqual(testCase, ...
    m12.lftEquivalenceAudit.nominalFrequencyError, ...
    m12.config.lftEquivalenceTolerance);
verifyLessThanOrEqual(testCase, ...
    m12.lftEquivalenceAudit.probeFrequencyError, ...
    m12.config.lftEquivalenceTolerance);
end

function testT22MuPartitionIsFiveByFive(testCase)
verifyEqual(testCase, size(testCase.TestData.m12.decomposition.M11mu), ...
    [5, 5]);
end

function testT23ManualMuBoundsAreFinite(testCase)
manual = testCase.TestData.m12.manualMuRS;
verifyTrue(testCase, manual.finite);
verifyTrue(testCase, all(isfinite(manual.upperBound)));
verifyTrue(testCase, all(isfinite(manual.lowerBound)));
end

function testT24ManualMuUpperBoundDominatesLower(testCase)
m12 = testCase.TestData.m12;
verifyGreaterThanOrEqual(testCase, manualDifference(m12), ...
    -m12.config.boundTolerance);
end

function testT25ManualMuMarginsAreReciprocalBounds(testCase)
manual = testCase.TestData.m12.manualMuRS;
verifyEqual(testCase, manual.marginLowerApproximation, ...
    1 / manual.maximumUpperBound, 'RelTol', 1e-12);
verifyEqual(testCase, manual.marginUpperApproximation, ...
    1 / manual.maximumLowerBound, 'RelTol', 1e-12);
end

function testT26RobstabWasExecuted(testCase)
rs = testCase.TestData.m12.robustStability;
verifyTrue(testCase, isstruct(rs.margin));
verifyTrue(testCase, isfinite(rs.margin.CriticalFrequency));
verifyTrue(testCase, isfield(rs.info, 'Sensitivity'));
end

function testT27RobstabBoundsAreOrdered(testCase)
margin = testCase.TestData.m12.robustStability.margin;
verifyLessThanOrEqual(testCase, margin.LowerBound, margin.UpperBound);
end

function testT28RobustStabilityClassificationMatchesBounds(testCase)
rs = testCase.TestData.m12.robustStability;
verifyEqual(testCase, rs.outcome, localMarginOutcome(rs.margin));
verifyEqual(testCase, rs.outcome, "FAIL_CERTIFIED");
end

function testT29RobstabWorstUncertaintyIsSaved(testCase)
m12 = testCase.TestData.m12;
verifyEqual(testCase, sort(string(fieldnames( ...
    m12.worstUncertaintyRS))), sort(m12.config.expectedUncertaintyNames));
end

function testT30RobstabWorstCaseIsOnTheStabilityBoundary(testCase)
m12 = testCase.TestData.m12;
tol = m12.config.worstCaseBoundaryPoleTolerance;
verifyLessThanOrEqual(testCase, abs( ...
    m12.robustStability.worstWeightedMaximumRealPart), tol);
verifyLessThanOrEqual(testCase, abs( ...
    m12.robustStability.worstPhysicalLoop.maximumRealPart), tol);
end

function testT31RobgainAtGammaOneWasExecuted(testCase)
m12 = testCase.TestData.m12;
verifyEqual(testCase, m12.config.gammaTarget, 1);
verifyTrue(testCase, isstruct(m12.robustPerformanceMargin));
verifyTrue(testCase, isfield(m12.infoRP, 'Sensitivity'));
end

function testT32RobustPerformanceBoundsAreOrdered(testCase)
margin = testCase.TestData.m12.robustPerformanceMargin;
verifyLessThanOrEqual(testCase, margin.LowerBound, margin.UpperBound);
end

function testT33NominalFailurePrecedesRobustPerformance(testCase)
rp = testCase.TestData.m12.robustPerformance;
verifyTrue(testCase, rp.nominalFailurePrecedenceApplied);
verifyEqual(testCase, rp.outcome, "FAIL_CERTIFIED");
end

function testT34RobustPerformanceCannotPassWhenNPFails(testCase)
m12 = testCase.TestData.m12;
verifyFalse(testCase, m12.NPMetrics.outcome == "FAIL" && ...
    m12.robustPerformance.outcome == "PASS_CERTIFIED");
end

function testT35WorstCaseGainWasExecuted(testCase)
m12 = testCase.TestData.m12;
verifyTrue(testCase, isstruct(m12.worstCaseGain));
verifyTrue(testCase, isfield(m12.infoGain, 'Sensitivity'));
end

function testT36WorstCaseGainBoundsAreCoherent(testCase)
gain = testCase.TestData.m12.worstCaseGain;
ordered = gain.LowerBound <= gain.UpperBound;
bothInfinite = isinf(gain.LowerBound) && isinf(gain.UpperBound);
verifyTrue(testCase, ordered || bothInfinite);
end

function testT37WorstCaseGainSubstitutionIsCoherent(testCase)
rp = testCase.TestData.m12.robustPerformance;
verifyTrue(testCase, rp.worstGainSubstitutionCoherent);
verifyGreaterThan(testCase, rp.worstGainActual, 1);
end

function testT38NoControllerOrWeightRetuningOccurred(testCase)
metadata = testCase.TestData.m12.metadata;
verifyFalse(testCase, metadata.controllerTuningPerformed);
verifyFalse(testCase, metadata.weightRetuningPerformed);
end

function testT39NoThirdPerformanceWeightWasIntroduced(testCase)
m12 = testCase.TestData.m12;
verifyFalse(testCase, m12.metadata.W3Used);
verifyEmpty(testCase, m12.config.W3);
end

function testT40NoHinfstructCallExistsInM12Sources(testCase)
verifyFalse(testCase, localContainsCall(testCase.TestData.source, ...
    'hinfstruct'));
end

function testT41NoMusynCallExistsInM12Sources(testCase)
verifyFalse(testCase, localContainsCall(testCase.TestData.source, ...
    'musyn'));
verifyFalse(testCase, testCase.TestData.m12.metadata.musynPerformed);
end

function testT42NoDKIterationExistsInM12(testCase)
verifyFalse(testCase, localContainsCall(testCase.TestData.source, ...
    'dksyn'));
verifyFalse(testCase, testCase.TestData.m12.metadata.dkIterationPerformed);
end

function testT43NoMonteCarloSamplingExistsInM12(testCase)
verifyFalse(testCase, localContainsCall(testCase.TestData.source, ...
    'usample'));
verifyFalse(testCase, testCase.TestData.m12.metadata.monteCarloPerformed);
end

function testT44NoMinrealGateExistsInM12(testCase)
verifyFalse(testCase, localContainsCall(testCase.TestData.source, ...
    'minreal'));
verifyFalse(testCase, testCase.TestData.m12.metadata.minrealUsedForGate);
end

function testT45M13WasNotStarted(testCase)
verifyFalse(testCase, testCase.TestData.m12.metadata.m13Started);
verifyFalse(testCase, testCase.TestData.m12.config.m13Enabled);
end

function testT46DatasetAndAllSixFiguresExist(testCase)
m12 = testCase.TestData.m12;
verifyTrue(testCase, isfile(fullfile(testCase.TestData.projectRoot, ...
    'results', 'data', 'm12_mu_analysis_a5.mat')));
verifyEqual(testCase, numel(fieldnames(m12.figurePaths)), 6);
verifyTrue(testCase, all(structfun(@isfile, m12.figurePaths)));
end

function testT47SummarySeparatesAllFourProperties(testCase)
summary = testCase.TestData.m12.summaryNSNPRSRP;
verifyEqual(testCase, summary.Property, ["NS"; "NP"; "RS"; "RP"]);
verifyEqual(testCase, summary.Outcome, ...
    ["PASS"; "FAIL"; "FAIL_CERTIFIED"; "FAIL_CERTIFIED"]);
end

function testT48OverallStatusIsCoherent(testCase)
gate = testCase.TestData.m12.qualityGate;
verifyEqual(testCase, gate.softwareCorrectness, "PASS");
verifyEqual(testCase, gate.overallStatus, "PARTIAL");
end

function testT49ManualMuAndRobstabAreConsistent(testCase)
consistency = testCase.TestData.m12.robustStability. ...
    manualMuConsistency;
verifyTrue(testCase, consistency.classificationConsistent);
verifyEqual(testCase, consistency.outcome, "PASS");
end

function testT50CriticalBlockDiagnosticsAreComplete(testCase)
m12 = testCase.TestData.m12;
tableData = m12.criticalBlockDiagnostics;
verifyEqual(testCase, height(tableData), 5);
verifyEqual(testCase, sort(tableData.BlockName), ...
    sort(m12.config.expectedUncertaintyNames));
verifyTrue(testCase, all(isfinite(tableData.RSSensitivity)));
end

function testT51NoNominalSynthesisCallExistsInM12Sources(testCase)
for name = {'mixsyn', 'hinfsyn'}
    verifyFalse(testCase, localContainsCall(testCase.TestData.source, ...
        name{1}));
end
end

function testT52SharedPlantConstructionHasNoHiddenNominalInstability(testCase)
m12 = testCase.TestData.m12;
model = build_m12_uncertain_generalized_plant( ...
    testCase.TestData.m4.GuncQ, testCase.TestData.m5.W1, ...
    testCase.TestData.m5.W2, m12.K_A5, m12.config);
verifyTrue(testCase, model.singleSharedPlantConstruction);
verifyTrue(testCase, isstable(model.TzwUnc.NominalValue));
verifyEqual(testCase, order(model.TzwUnc.NominalValue), 26);
end

function testT53PuncNominalMapMatchesFrozenM10Plant(testCase)
m12 = testCase.TestData.m12;
error = localFrequencyError(m12.Punc.NominalValue, ...
    testCase.TestData.m10.P, m12.config.auditFrequencyGrid);
verifyLessThanOrEqual(testCase, error, ...
    m12.config.nominalFrequencyTolerance);
end

function testT54NormalizedRangesAndBoundsAreUnit(testCase)
tableData = testCase.TestData.m12.decomposition. ...
    normalizedOccurrenceTable;
realRows = contains(tableData.Class, "ureal");
dynamicRows = contains(tableData.Class, "ultidyn");
verifyEqual(testCase, tableData.RangeLower(realRows), ...
    -ones(sum(realRows), 1));
verifyEqual(testCase, tableData.RangeUpper(realRows), ...
    ones(sum(realRows), 1));
verifyEqual(testCase, tableData.Bound(dynamicRows), ...
    ones(sum(dynamicRows), 1));
end

function source = localM12Source(projectRoot)
files = [dir(fullfile(projectRoot, 'analysis', 'robust', '*.m')); ...
    dir(fullfile(projectRoot, 'controllers', 'hinf', ...
        'load_m12_a5_controller.m')); ...
    dir(fullfile(projectRoot, 'src', 'parameters', ...
        'mu_analysis_specs_m12.m'))];
source = "";
for index = 1:numel(files)
    source = source + newline + string(fileread( ...
        fullfile(files(index).folder, files(index).name)));
end
end

function found = localContainsCall(source, functionName)
pattern = ['\<', functionName, '\s*\('];
found = ~isempty(regexp(char(source), pattern, 'once'));
end

function difference = manualDifference(m12)
difference = min(m12.manualMuRS.upperBound - ...
    m12.manualMuRS.lowerBound);
end

function outcome = localMarginOutcome(margin)
if margin.LowerBound > 1
    outcome = "PASS_CERTIFIED";
elseif margin.UpperBound < 1
    outcome = "FAIL_CERTIFIED";
else
    outcome = "INCONCLUSIVE";
end
end

function status = localPassFail(condition)
if condition
    status = "PASS";
else
    status = "FAIL";
end
end

function error = localFrequencyError(first, second, frequencies)
first = localClearNames(ss(first));
second = localClearNames(ss(second));
difference = freqresp(first, frequencies) - ...
    freqresp(second, frequencies);
error = max(abs(difference), [], 'all');
end

function system = localClearNames(system)
system.InputName = repmat({''}, size(system, 2), 1);
system.OutputName = repmat({''}, size(system, 1), 1);
end
