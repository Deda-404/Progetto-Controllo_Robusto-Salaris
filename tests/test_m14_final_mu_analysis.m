function tests = test_m14_final_mu_analysis
%TEST_M14_FINAL_MU_ANALYSIS Frozen Kmu final NS/NP/RS/RP quality gates.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(projectRoot, 'src')));
addpath(genpath(fullfile(projectRoot, 'controllers')));
addpath(genpath(fullfile(projectRoot, 'analysis')));
datasetPath = fullfile(projectRoot, 'results', 'data', ...
    'm14_final_mu_analysis_kmu.mat');
if ~isfile(datasetPath)
    validate_m14_final_mu_analysis;
end
testCase.TestData.projectRoot = projectRoot;
testCase.TestData.m14 = load(datasetPath);
for milestone = [4, 5, 12, 13]
    names = containers.Map( ...
        {4, 5, 12, 13}, ...
        {'m4_uncertain_plant.mat', ...
         'm5_performance_specs.mat', ...
         'm12_mu_analysis_a5.mat', ...
         'm13_musyn_dk.mat'});
    key = sprintf('m%d', milestone);
    testCase.TestData.(key) = load(fullfile(projectRoot, ...
        'results', 'data', names(milestone)));
end
testCase.TestData.source = localM14Source(projectRoot);
end

function testT01BaselineIsM13MergeCommit(testCase)
m14 = testCase.TestData.m14;
verifyEqual(testCase, m14.config.baselineCommit, ...
    "49f37c6e027aaa37db65f27530901965f897f11f");
verifyEqual(testCase, m14.metadata.baselineCommit, ...
    m14.config.baselineCommit);
end

function testT02PR18IsRecordedMerged(testCase)
m14 = testCase.TestData.m14;
verifyEqual(testCase, m14.config.mergedPullRequest, 18);
verifyEqual(testCase, m14.metadata.mergedPullRequestState, "MERGED");
verifyEqual(testCase, m14.config.mergedPullRequestCommit, ...
    m14.config.baselineCommit);
end

function testT03KmuIsLoadedFromM13(testCase)
audit = testCase.TestData.m14.KmuSourceAudit;
verifyEqual(testCase, audit.sourceArtifact, ...
    "results/data/m13_musyn_dk.mat");
verifyTrue(testCase, audit.loadedDirectlyFromArtifact);
end

function testT04KmuIsIdenticalToM13Artifact(testCase)
m14 = testCase.TestData.m14;
m13 = testCase.TestData.m13;
[A, B, C, D] = ssdata(m14.Kmu);
[Ar, Br, Cr, Dr] = ssdata(m13.Kmu);
verifyEqual(testCase, A, Ar, 'AbsTol', 0);
verifyEqual(testCase, B, Br, 'AbsTol', 0);
verifyEqual(testCase, C, Cr, 'AbsTol', 0);
verifyEqual(testCase, D, Dr, 'AbsTol', 0);
verifyTrue(testCase, m14.KmuSourceAudit.exactRawControllerIdentity);
end

function testT05KmuOrderMatchesFrozenArtifact(testCase)
m14 = testCase.TestData.m14;
verifyEqual(testCase, order(m14.Kmu), 70);
verifyEqual(testCase, order(m14.Kmu), m14.KmuSourceAudit.savedControllerOrder);
verifyEqual(testCase, order(m14.Kmu), m14.KmuSourceAudit.rawControllerOrder);
end

function testT06NoNewSynthesisWasPerformed(testCase)
m14 = testCase.TestData.m14;
verifyTrue(testCase, m14.KmuSourceAudit.loadedWithoutSynthesis);
verifyFalse(testCase, m14.metadata.musynPerformed);
verifyFalse(testCase, m14.metadata.dkIterationPerformed);
end

function testT07M4IsFrozen(testCase)
m14 = testCase.TestData.m14;
verifyTrue(testCase, m14.uncertaintySourceAudit.passed);
verifyEqual(testCase, sort(m14.uncertaintySourceAudit.currentNames), ...
    sort(m14.config.expectedUncertaintyNames));
verifyTrue(testCase, ...
    all(m14.uncertaintySourceAudit.rangeTable.ApprovedStructure));
end

function testT08M5IsFrozen(testCase)
m14 = testCase.TestData.m14;
verifyTrue(testCase, m14.weightAudit.passed);
verifyLessThanOrEqual(testCase, m14.weightAudit.W1Error, ...
    m14.config.weightTolerance);
verifyLessThanOrEqual(testCase, m14.weightAudit.W2Error, ...
    m14.config.weightTolerance);
end

function testT09W3IsAbsent(testCase)
m14 = testCase.TestData.m14;
verifyEmpty(testCase, m14.config.W3);
verifyTrue(testCase, m14.weightAudit.W3Absent);
verifyFalse(testCase, m14.metadata.W3Used);
end

function testT10PuncMatchesCurrentM12AndRecordsM13History(testCase)
audit = testCase.TestData.m14.PuncIdentityAudit;
verifyTrue(testCase, audit.passed);
verifyTrue(testCase, audit.m13SynthesisPlantAuditPassed);
verifyTrue(testCase, islogical(audit.currentProblemMatchesM13SynthesisRecord));
verifyLessThanOrEqual(testCase, audit.nominalFrequencyErrorM12, ...
    testCase.TestData.m14.config.identityFrequencyTolerance);
end

function testT11TzwHasExpectedDimensions(testCase)
verifyEqual(testCase, size(testCase.TestData.m14.Tzw_mu_unc), [4, 2]);
end

function testT12NominalClosureMatchesM13(testCase)
m14 = testCase.TestData.m14;
error = localFrequencyError(m14.Tzw_mu_unc.NominalValue, ...
    testCase.TestData.m13.CLmu.NominalValue, ...
    m14.config.auditFrequencyGrid);
verifyLessThanOrEqual(testCase, error, m14.config.closedLoopMapTolerance);
verifyLessThanOrEqual(testCase, ...
    m14.nominalReconstruction.metrics.puncNominalMapError, ...
    m14.config.closedLoopMapTolerance);
end

function testT13SensitivityMapIsReconstructed(testCase)
m14 = testCase.TestData.m14;
verifyLessThanOrEqual(testCase, ...
    m14.nominalReconstruction.metrics.sErrorVsM13, ...
    m14.config.nominalFrequencyTolerance);
end

function testT14ComplementarySensitivityIsReconstructed(testCase)
m14 = testCase.TestData.m14;
verifyLessThanOrEqual(testCase, ...
    m14.nominalReconstruction.metrics.tErrorVsM13, ...
    m14.config.nominalFrequencyTolerance);
end

function testT15ControlSensitivityIsReconstructed(testCase)
m14 = testCase.TestData.m14;
verifyLessThanOrEqual(testCase, ...
    m14.nominalReconstruction.metrics.ksErrorVsM13, ...
    m14.config.nominalFrequencyTolerance);
end

function testT16WeightedStackIsReconstructed(testCase)
m14 = testCase.TestData.m14;
verifyLessThanOrEqual(testCase, ...
    m14.nominalReconstruction.metrics.weightedErrorVsM13, ...
    m14.config.closedLoopMapTolerance);
end

function testT17NominalNormMatchesM13(testCase)
m14 = testCase.TestData.m14;
verifyLessThanOrEqual(testCase, ...
    m14.nominalReconstruction.metrics.normRelativeErrorVsM13, ...
    m14.config.nominalNormRelativeTolerance);
verifyEqual(testCase, m14.NPMetrics.gammaNominal, ...
    testCase.TestData.m13.nominalReconstruction.metrics.weightedNorm, ...
    'RelTol', m14.config.nominalNormRelativeTolerance);
end

function testT18NominalPolesMatchM13(testCase)
m14 = testCase.TestData.m14;
verifyLessThanOrEqual(testCase, ...
    m14.nominalReconstruction.metrics.poleErrorVsM13, ...
    m14.config.nominalPoleTolerance);
verifyEqual(testCase, m14.NSMetrics.internalStateCount, 84);
end

function testT19NSClassificationIsCorrect(testCase)
m14 = testCase.TestData.m14;
expected = localPassFail(m14.NSMetrics.internallyStable);
verifyEqual(testCase, m14.nominalReconstruction.NSOutcome, expected);
end

function testT20NPClassificationIsCorrect(testCase)
m14 = testCase.TestData.m14;
expected = localPassFail(m14.NPMetrics.gammaNominal < ...
    m14.config.gammaTarget);
verifyEqual(testCase, m14.NPMetrics.outcome, expected);
end

function testT21NominalFailurePrecedesRP(testCase)
m14 = testCase.TestData.m14;
if m14.NPMetrics.outcome == "FAIL"
    verifyEqual(testCase, m14.robustPerformance.outcome, ...
        "FAIL_CERTIFIED");
    verifyTrue(testCase, ...
        m14.robustPerformance.nominalFailurePrecedenceApplied);
else
    verifyFalse(testCase, ...
        m14.robustPerformance.nominalFailurePrecedenceApplied);
end
end

function testT22LftDataWasExecuted(testCase)
m14 = testCase.TestData.m14;
verifyEqual(testCase, m14.lftEquivalenceAudit.MSize, size(m14.M));
verifyEqual(testCase, m14.lftEquivalenceAudit.DeltaSize, ...
    size(m14.Delta));
end

function testT23FiveUncertaintyBlocksArePreserved(testCase)
m14 = testCase.TestData.m14;
verifyEqual(testCase, numel(m14.BlkStruct), 5);
verifyEqual(testCase, sort(m14.deltaStructureTable.Name), ...
    sort(m14.config.expectedUncertaintyNames));
verifyEqual(testCase, m14.deltaStructureTable.Occurrences, ones(5, 1));
end

function testT24NormalizedUncertaintiesAreValid(testCase)
m14 = testCase.TestData.m14;
verifyEqual(testCase, numel(m14.normunc), 5);
verifyTrue(testCase, all(m14.decomposition. ...
    normalizedOccurrenceTable.NormalizedValid));
end

function testT25NDeltaReconstructionPasses(testCase)
m14 = testCase.TestData.m14;
verifyTrue(testCase, m14.lftEquivalenceAudit.passed);
verifyLessThanOrEqual(testCase, ...
    m14.lftEquivalenceAudit.nominalFrequencyError, ...
    m14.config.lftEquivalenceTolerance);
verifyLessThanOrEqual(testCase, ...
    m14.lftEquivalenceAudit.probeFrequencyError, ...
    m14.config.lftEquivalenceTolerance);
end

function testT26M11muPartitionIsCorrect(testCase)
m14 = testCase.TestData.m14;
verifyEqual(testCase, size(m14.decomposition.M11mu), [5, 5]);
end

function testT27MuGridIsExactlyM12Grid(testCase)
m14 = testCase.TestData.m14;
verifyEqual(testCase, m14.config.muFrequencyGrid, ...
    testCase.TestData.m12.config.muFrequencyGrid, 'AbsTol', 0);
verifyEqual(testCase, m14.manualMuRS.frequencyGrid, ...
    testCase.TestData.m12.manualMuRS.frequencyGrid, 'AbsTol', 0);
end

function testT28ManualMuBoundsAreValid(testCase)
m14 = testCase.TestData.m14;
manual = m14.manualMuRS;
verifyTrue(testCase, manual.finite);
verifyTrue(testCase, all(isfinite(manual.upperBound)));
verifyTrue(testCase, all(isfinite(manual.lowerBound)));
verifyGreaterThanOrEqual(testCase, ...
    min(manual.upperBound - manual.lowerBound), ...
    -m14.config.boundTolerance);
end

function testT29RobstabBoundsAreValid(testCase)
margin = testCase.TestData.m14.robustStability.margin;
verifyTrue(testCase, isstruct(margin));
verifyLessThanOrEqual(testCase, margin.LowerBound, margin.UpperBound);
verifyTrue(testCase, isfinite(margin.CriticalFrequency));
end

function testT30RSClassificationUsesBounds(testCase)
rs = testCase.TestData.m14.robustStability;
verifyEqual(testCase, rs.outcome, localMarginOutcome(rs.margin));
end

function testT31ManualMuAndRobstabAreConsistent(testCase)
consistency = testCase.TestData.m14.robustStability.manualMuConsistency;
verifyTrue(testCase, consistency.classificationConsistent);
verifyNotEqual(testCase, consistency.outcome, "FAIL_METHODOLOGICAL");
end

function testT32WorstRSUncertaintyIsSaved(testCase)
m14 = testCase.TestData.m14;
verifyEqual(testCase, sort(string(fieldnames(m14.wcuRS))), ...
    sort(m14.config.expectedUncertaintyNames));
end

function testT33WorstRSSubstitutionIsOnBoundary(testCase)
m14 = testCase.TestData.m14;
tolerance = m14.config.worstCaseBoundaryPoleTolerance;
verifyLessThanOrEqual(testCase, ...
    abs(m14.robustStability.worstWeightedMaximumRealPart), tolerance);
verifyLessThanOrEqual(testCase, ...
    abs(m14.robustStability.worstPhysicalLoop.maximumRealPart), tolerance);
end

function testT34RobgainUsesGammaTargetOne(testCase)
m14 = testCase.TestData.m14;
verifyEqual(testCase, m14.config.gammaTarget, 1);
verifyTrue(testCase, isstruct(m14.robustPerformanceMargin));
end

function testT35RobustPerformanceBoundsAreValid(testCase)
margin = testCase.TestData.m14.robustPerformanceMargin;
verifyLessThanOrEqual(testCase, margin.LowerBound, margin.UpperBound);
end

function testT36RPCannotPassWhenNPFails(testCase)
m14 = testCase.TestData.m14;
verifyFalse(testCase, m14.NPMetrics.outcome == "FAIL" && ...
    m14.robustPerformance.outcome == "PASS_CERTIFIED");
end

function testT37WorstCaseGainWasExecuted(testCase)
m14 = testCase.TestData.m14;
verifyTrue(testCase, isstruct(m14.worstCaseGain));
verifyTrue(testCase, isfield(m14.infoGain, 'Sensitivity'));
end

function testT38WorstCaseGainBoundsAreCoherent(testCase)
gain = testCase.TestData.m14.worstCaseGain;
ordered = gain.LowerBound <= gain.UpperBound;
bothInfinite = isinf(gain.LowerBound) && isinf(gain.UpperBound);
verifyTrue(testCase, ordered || bothInfinite);
end

function testT39WorstGainSubstitutionIsCoherent(testCase)
rp = testCase.TestData.m14.robustPerformance;
verifyTrue(testCase, rp.worstGainSubstitutionCoherent);
verifyGreaterThan(testCase, rp.worstGainActual, 0);
end

function testT40A5ComparisonUsesM12Artifact(testCase)
m14 = testCase.TestData.m14;
m12 = testCase.TestData.m12;
row = m14.robustComparison.controllerTable.Controller == "A5 M12";
verifyEqual(testCase, ...
    m14.robustComparison.controllerTable.RSLowerBound(row), ...
    m12.robustStability.margin.LowerBound, 'AbsTol', 0);
verifyEqual(testCase, ...
    m14.robustComparison.controllerTable.RSUpperBound(row), ...
    m12.robustStability.margin.UpperBound, 'AbsTol', 0);
end

function testT41LowerMarginDeltaIsCalculated(testCase)
r = testCase.TestData.m14.RSImprovementClassification;
verifyEqual(testCase, r.deltaLowerBound, ...
    r.KmuLowerBound - r.A5LowerBound, 'AbsTol', 0);
verifyEqual(testCase, r.relativeDeltaLowerBound, ...
    r.deltaLowerBound / max(abs(r.A5LowerBound), eps), 'RelTol', 1e-14);
end

function testT42UpperMarginDeltaIsCalculated(testCase)
r = testCase.TestData.m14.RSImprovementClassification;
verifyEqual(testCase, r.deltaUpperBound, ...
    r.KmuUpperBound - r.A5UpperBound, 'AbsTol', 0);
verifyEqual(testCase, r.relativeDeltaUpperBound, ...
    r.deltaUpperBound / max(abs(r.A5UpperBound), eps), 'RelTol', 1e-14);
end

function testT43ImprovementClassificationIsDeterministic(testCase)
m14 = testCase.TestData.m14;
repeat = compare_m14_a5_kmu_robustness( ...
    testCase.TestData.m12, m14.nominalReconstruction, ...
    m14.manualMuRS, m14.robustStability, m14.robustPerformance, ...
    m14.criticalBlockTable, m14.Kmu, ...
    m14.KmuSourceAudit.musynObjective, m14.config);
verifyEqual(testCase, repeat.rsImprovement, ...
    m14.RSImprovementClassification);
end

function testT44CriticalBlocksAreQuantified(testCase)
m14 = testCase.TestData.m14;
tableData = m14.criticalBlockTable;
verifyEqual(testCase, height(tableData), 5);
verifyEqual(testCase, sort(tableData.BlockName), ...
    sort(m14.config.expectedUncertaintyNames));
verifyTrue(testCase, all(isfinite(tableData.A5RSSensitivity)));
verifyTrue(testCase, all(isfinite(tableData.RSSensitivity)));
end

function testT45NoMusynCallExistsInM14(testCase)
verifyFalse(testCase, localContainsCall(testCase.TestData.source, 'musyn'));
verifyFalse(testCase, testCase.TestData.m14.metadata.musynPerformed);
end

function testT46NoHinfsynCallExistsInM14(testCase)
verifyFalse(testCase, localContainsCall(testCase.TestData.source, 'hinfsyn'));
verifyFalse(testCase, testCase.TestData.m14.metadata.hinfsynPerformed);
end

function testT47NoMixsynCallExistsInM14(testCase)
verifyFalse(testCase, localContainsCall(testCase.TestData.source, 'mixsyn'));
verifyFalse(testCase, testCase.TestData.m14.metadata.mixsynPerformed);
end

function testT48NoHinfstructCallExistsInM14(testCase)
verifyFalse(testCase, ...
    localContainsCall(testCase.TestData.source, 'hinfstruct'));
verifyFalse(testCase, testCase.TestData.m14.metadata.hinfstructPerformed);
end

function testT49NoRetuningOccurred(testCase)
m14 = testCase.TestData.m14;
verifyFalse(testCase, m14.metadata.controllerTuningPerformed);
verifyFalse(testCase, m14.metadata.weightRetuningPerformed);
verifyFalse(testCase, m14.metadata.uncertaintyRetuningPerformed);
end

function testT50NoControllerReductionOccurred(testCase)
m14 = testCase.TestData.m14;
for name = {'balred', 'reduce', 'minreal'}
    verifyFalse(testCase, localContainsCall(testCase.TestData.source, ...
        name{1}));
end
verifyFalse(testCase, m14.metadata.controllerReductionPerformed);
end

function testT51NoMonteCarloWasPerformed(testCase)
verifyFalse(testCase, ...
    localContainsCall(testCase.TestData.source, 'usample'));
verifyFalse(testCase, testCase.TestData.m14.metadata.monteCarloPerformed);
end

function testT52NoNonlinearSimulinkWasPerformed(testCase)
m14 = testCase.TestData.m14;
verifyFalse(testCase, m14.metadata.nonlinearValidationPerformed);
verifyFalse(testCase, m14.config.nonlinearValidationEnabled);
end

function testT53M15WasNotStarted(testCase)
m14 = testCase.TestData.m14;
verifyFalse(testCase, m14.metadata.m15Started);
verifyFalse(testCase, m14.config.m15Enabled);
end

function testT54ArtifactAndSixFiguresExist(testCase)
m14 = testCase.TestData.m14;
verifyTrue(testCase, isfile(fullfile(testCase.TestData.projectRoot, ...
    'results', 'data', 'm14_final_mu_analysis_kmu.mat')));
verifyGreaterThanOrEqual(testCase, numel(fieldnames(m14.figurePaths)), 6);
verifyTrue(testCase, all(structfun(@isfile, m14.figurePaths)));
end

function testT55QualityGateIsCoherent(testCase)
gate = testCase.TestData.m14.qualityGate;
foundational = gate.frozenKmuCorrectness == "PASS" && ...
    gate.frozenUncertaintyCorrectness == "PASS" && ...
    gate.frozenWeightsCorrectness == "PASS" && ...
    gate.PuncIdentity == "PASS" && ...
    gate.nominalReconstruction == "PASS" && ...
    gate.nDeltaDecomposition == "PASS" && ...
    gate.nominalStability == "PASS" && ...
    gate.manualMuRSConsistency ~= "FAIL_METHODOLOGICAL";
verifyEqual(testCase, gate.softwareCorrectness, localPassFail(foundational));
end

function testT56OverallStatusIsCoherent(testCase)
gate = testCase.TestData.m14.qualityGate;
if gate.softwareCorrectness ~= "PASS" || ...
        gate.manualMuRSConsistency == "FAIL_METHODOLOGICAL"
    expected = "BLOCKED";
elseif gate.nominalStability == "PASS" && ...
        gate.nominalPerformance == "PASS" && ...
        gate.robustStability == "PASS_CERTIFIED" && ...
        gate.robustPerformance == "PASS_CERTIFIED"
    expected = "COMPLETE";
else
    expected = "PARTIAL";
end
verifyEqual(testCase, gate.overallStatus, expected);
end

function source = localM14Source(projectRoot)
files = { ...
    fullfile(projectRoot, 'src', 'parameters', ...
        'mu_analysis_specs_m14.m'); ...
    fullfile(projectRoot, 'analysis', 'robust', ...
        'load_m14_kmu_closed_loop.m'); ...
    fullfile(projectRoot, 'analysis', 'robust', ...
        'audit_m14_nominal_loop.m'); ...
    fullfile(projectRoot, 'analysis', 'robust', ...
        'build_m14_critical_block_table.m'); ...
    fullfile(projectRoot, 'analysis', 'robust', ...
        'compare_m14_a5_kmu_robustness.m'); ...
    fullfile(projectRoot, 'analysis', 'robust', ...
        'plot_m14_results.m'); ...
    fullfile(projectRoot, 'analysis', 'robust', ...
        'validate_m14_final_mu_analysis.m')};
source = "";
for index = 1:numel(files)
    source = source + newline + string(fileread(files{index}));
end
end

function found = localContainsCall(source, functionName)
pattern = ['\<', functionName, '\s*\('];
found = ~isempty(regexp(char(source), pattern, 'once'));
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
difference = freqresp(first, frequencies) - freqresp(second, frequencies);
error = max(abs(difference), [], 'all');
end

function system = localClearNames(system)
system.InputName = repmat({''}, size(system, 2), 1);
system.OutputName = repmat({''}, size(system, 1), 1);
end
