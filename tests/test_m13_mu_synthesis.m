function tests = test_m13_mu_synthesis
%TEST_M13_MU_SYNTHESIS Quality gates for the single frozen D-K campaign.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(projectRoot, 'src')));
addpath(genpath(fullfile(projectRoot, 'controllers')));
addpath(genpath(fullfile(projectRoot, 'analysis')));
datasetPath = fullfile(projectRoot, 'results', 'data', ...
    'm13_musyn_dk.mat');
assert(isfile(datasetPath), ...
    'The authorized M13 single-campaign artifact must already exist.');
testCase.TestData.projectRoot = projectRoot;
testCase.TestData.m13 = load(datasetPath);
testCase.TestData.m4 = load(fullfile(projectRoot, 'results', 'data', ...
    'm4_uncertain_plant.mat'));
testCase.TestData.m5 = load(fullfile(projectRoot, 'results', 'data', ...
    'm5_performance_specs.mat'));
testCase.TestData.m10 = load(fullfile(projectRoot, 'results', 'data', ...
    'm10_hinfsyn_nominal.mat'));
testCase.TestData.m11 = load(fullfile(projectRoot, 'results', 'data', ...
    'm11_hinfstruct_structured.mat'));
testCase.TestData.m12 = load(fullfile(projectRoot, 'results', 'data', ...
    'm12_mu_analysis_a5.mat'));
testCase.TestData.source = localM13Source(projectRoot);
end

function testT01BaselineCommitIsFrozenM12Merge(testCase)
verifyEqual(testCase, testCase.TestData.m13.config.baselineCommit, ...
    "9b69caa02c7f8dbca9cc2b936067f67c25904f1a");
end

function testT02SingleCampaignArtifactIsFrozen(testCase)
metadata = testCase.TestData.m13.metadata;
verifyTrue(testCase, metadata.singleCampaignCompleted);
verifyEqual(testCase, metadata.musynCallCountForCampaign, 1);
verifyFalse(testCase, metadata.controllerRetuningAfterResult);
end

function testT03PuncMatchesM12Exactly(testCase)
audit = testCase.TestData.m13.PuncSourceAudit;
verifyTrue(testCase, audit.passed);
verifyEqual(testCase, audit.nominalFrequencyError, 0, 'AbsTol', 0);
verifyEqual(testCase, audit.lftMFrequencyError, 0, 'AbsTol', 0);
end

function testT04PuncDimensionsAndNamesMatch(testCase)
audit = testCase.TestData.m13.PuncSourceAudit;
verifyEqual(testCase, audit.rebuiltSize, [6, 4]);
verifyTrue(testCase, audit.inputNamesEqual && audit.outputNamesEqual);
end

function testT05LftStructureMatchesM12(testCase)
audit = testCase.TestData.m13.PuncSourceAudit;
verifyTrue(testCase, audit.lftMSizeEqual);
verifyTrue(testCase, audit.lftDeltaSizeEqual);
verifyTrue(testCase, audit.lftBlockStructureEqual);
end

function testT06UncertaintySetIsFrozenM4(testCase)
m13 = testCase.TestData.m13;
verifyTrue(testCase, m13.uncertaintyMetadata.passed);
verifyEqual(testCase, m13.uncertaintyMetadata.currentNames, ...
    sort(m13.config.expectedUncertaintyNames));
end

function testT07UncertaintyRangesAreApproved(testCase)
metadata = testCase.TestData.m13.uncertaintyMetadata;
verifyTrue(testCase, metadata.m12SourceAuditPassed);
verifyTrue(testCase, all(metadata.rangeTable.ApprovedStructure));
end

function testT08M5W1IsFrozen(testCase)
verifyLessThanOrEqual(testCase, testCase.TestData.m13.weightAudit.W1Error, ...
    testCase.TestData.m13.config.weightTolerance);
end

function testT09M5W2IsFrozen(testCase)
verifyLessThanOrEqual(testCase, testCase.TestData.m13.weightAudit.W2Error, ...
    testCase.TestData.m13.config.weightTolerance);
end

function testT10W3IsAbsent(testCase)
m13 = testCase.TestData.m13;
verifyEmpty(testCase, m13.config.W3);
verifyTrue(testCase, m13.weightAudit.W3Absent);
verifyFalse(testCase, m13.metadata.W3Used);
end

function testT11MeasurementPartitionIsTwo(testCase)
verifyEqual(testCase, testCase.TestData.m13.config.nmeas, 2);
end

function testT12ControlPartitionIsTwo(testCase)
verifyEqual(testCase, testCase.TestData.m13.config.ncont, 2);
end

function testT13ThereIsOneMusynCallSite(testCase)
verifyEqual(testCase, localCallCount( ...
    testCase.TestData.source, 'musyn'), 1);
end

function testT14NoMixsynCallExists(testCase)
verifyEqual(testCase, localCallCount( ...
    testCase.TestData.source, 'mixsyn'), 0);
end

function testT15NoHinfsynCallExists(testCase)
verifyEqual(testCase, localCallCount( ...
    testCase.TestData.source, 'hinfsyn'), 0);
end

function testT16NoHinfstructCallExists(testCase)
verifyEqual(testCase, localCallCount( ...
    testCase.TestData.source, 'hinfstruct'), 0);
end

function testT17FrozenMaxIterIsFive(testCase)
m13 = testCase.TestData.m13;
verifyEqual(testCase, m13.config.maxIterations, 5);
verifyEqual(testCase, m13.synthesis.optionsSnapshot.MaxIter, 5);
end

function testT18DisplayIsAuthorizedNoninteractiveMode(testCase)
m13 = testCase.TestData.m13;
verifyEqual(testCase, string(m13.config.display), "short");
verifyEqual(testCase, string(m13.synthesis.optionsSnapshot.Display), ...
    "short");
end

function testT19AllMathematicalOptionsAreFrozen(testCase)
m13 = testCase.TestData.m13;
options = m13.synthesis.optionsSnapshot;
verifyEqual(testCase, options.TargetPerf, 0);
verifyEqual(testCase, options.TolPerf, 0.01);
verifyEqual(testCase, string(options.MixedMU), "on");
verifyEqual(testCase, options.FullDG, [true, true]);
verifyEqual(testCase, options.FitOrder, [5, 2]);
end

function testT20FrequencyGridIsFrozenM12Grid(testCase)
m13 = testCase.TestData.m13;
verifyEqual(testCase, m13.config.frequencyGrid, ...
    testCase.TestData.m12.config.muFrequencyGrid, 'AbsTol', 0);
verifyEqual(testCase, m13.synthesis.optionsSnapshot.FrequencyGrid(:), ...
    m13.config.frequencyGrid(:), 'AbsTol', 0);
end

function testT21NoAdaptiveRerunIsEnabled(testCase)
m13 = testCase.TestData.m13;
verifyFalse(testCase, m13.config.secondSynthesisEnabled);
verifyTrue(testCase, m13.config.singleCandidate);
verifyEqual(testCase, m13.metadata.musynCallCountForCampaign, 1);
end

function testT22HistoryIsPresent(testCase)
m13 = testCase.TestData.m13;
verifyNotEmpty(testCase, m13.normalizedHistory);
verifyTrue(testCase, m13.history.completeUnfilteredHistory);
end

function testT23IterationCountIsCoherent(testCase)
m13 = testCase.TestData.m13;
verifyEqual(testCase, m13.history.iterationCount, numel(m13.rawInfo));
verifyEqual(testCase, height(m13.normalizedHistory), ...
    m13.history.iterationCount);
verifyLessThanOrEqual(testCase, m13.history.iterationCount, ...
    m13.config.maxIterations);
end

function testT24RawInfoContainsR2025bFields(testCase)
required = ["gamma", "K", "KInfo", "PeakMu", "DG", ...
    "PeakMuFit", "FitOrder", "dr", "dc", "PSI"];
verifyTrue(testCase, all(ismember(required, ...
    string(fieldnames(testCase.TestData.m13.rawInfo)))));
end

function testT25DScalesAndFitOrdersAreSaved(testCase)
m13 = testCase.TestData.m13;
verifyTrue(testCase, m13.history.DScalesSavedInRawInfo);
verifyTrue(testCase, m13.history.fitOrdersSaved);
verifyTrue(testCase, all(isfinite(m13.normalizedHistory.DScaleOrder)));
end

function testT26KmuExistsAndIsTwoByTwo(testCase)
verifyEqual(testCase, size(testCase.TestData.m13.Kmu), [2, 2]);
end

function testT27KmuMatricesAreFinite(testCase)
[A, B, C, D] = ssdata(testCase.TestData.m13.Kmu);
verifyTrue(testCase, all(isfinite(A), 'all'));
verifyTrue(testCase, all(isfinite(B), 'all'));
verifyTrue(testCase, all(isfinite(C), 'all'));
verifyTrue(testCase, all(isfinite(D), 'all'));
end

function testT28ControllerOrderIsSaved(testCase)
m13 = testCase.TestData.m13;
verifyEqual(testCase, m13.controllerOrder, order(m13.Kmu));
verifyEqual(testCase, m13.nominalReconstruction.metrics.controllerOrder, ...
    m13.controllerOrder);
end

function testT29ReturnedControllerIsTheBestHistoryController(testCase)
m13 = testCase.TestData.m13;
reference = m13.rawInfo(m13.history.bestIteration).K;
[A, B, C, D] = ssdata(m13.Kmu);
[Ar, Br, Cr, Dr] = ssdata(reference);
verifyEqual(testCase, A, Ar, 'AbsTol', 0);
verifyEqual(testCase, B, Br, 'AbsTol', 0);
verifyEqual(testCase, C, Cr, 'AbsTol', 0);
verifyEqual(testCase, D, Dr, 'AbsTol', 0);
end

function testT30NoControllerReductionWasPerformed(testCase)
m13 = testCase.TestData.m13;
verifyFalse(testCase, m13.metadata.controllerReductionPerformed);
verifyFalse(testCase, m13.config.controllerReductionEnabled);
for name = {'balred', 'reduce', 'minreal'}
    verifyEqual(testCase, localCallCount(m13Source(testCase), name{1}), 0);
end
end

function testT31NominalInternalPolesAreExplicit(testCase)
audit = testCase.TestData.m13.nominalReconstruction;
verifyEqual(testCase, numel(audit.internalPoles), ...
    audit.metrics.internalStateCount);
verifyEqual(testCase, size(audit.Ainternal), ...
    [audit.metrics.internalStateCount, audit.metrics.internalStateCount]);
end

function testT32NominalInternalStabilityPasses(testCase)
audit = testCase.TestData.m13.nominalReconstruction;
verifyEqual(testCase, audit.NSOutcome, "PASS");
verifyTrue(testCase, audit.metrics.internallyStable);
verifyLessThan(testCase, audit.metrics.maximumRealPart, 0);
end

function testT33SensitivityIsReconstructed(testCase)
audit = testCase.TestData.m13.nominalReconstruction;
verifyEqual(testCase, size(audit.S), [2, 2]);
verifyTrue(testCase, audit.metrics.sensitivityStable);
end

function testT34ComplementarySensitivityIsReconstructed(testCase)
audit = testCase.TestData.m13.nominalReconstruction;
verifyEqual(testCase, size(audit.T), [2, 2]);
verifyTrue(testCase, audit.metrics.complementarySensitivityStable);
end

function testT35ControlSensitivityIsReconstructed(testCase)
audit = testCase.TestData.m13.nominalReconstruction;
verifyEqual(testCase, size(audit.KS), [2, 2]);
verifyTrue(testCase, audit.metrics.controlSensitivityStable);
end

function testT36WeightedStackIsReconstructed(testCase)
audit = testCase.TestData.m13.nominalReconstruction;
verifyEqual(testCase, size(audit.weightedClosedLoop), [4, 2]);
verifyEqual(testCase, audit.nominalWeightedReconstructionOutcome, "PASS");
verifyLessThanOrEqual(testCase, audit.metrics.closedLoopMapError, ...
    testCase.TestData.m13.config.closedLoopMapTolerance);
end

function testT37NominalNormIsFiniteAndReproducible(testCase)
audit = testCase.TestData.m13.nominalReconstruction;
[value, frequency] = norm(audit.weightedClosedLoop, inf);
verifyTrue(testCase, isfinite(value) && isfinite(frequency));
verifyEqual(testCase, value, audit.metrics.weightedNorm, 'RelTol', 1e-12);
verifyEqual(testCase, frequency, audit.metrics.weightedPeakFrequency, ...
    'RelTol', 1e-12);
end

function testT38M10ComparisonExists(testCase)
comparison = testCase.TestData.m13.comparisonM10A5Kmu;
verifyTrue(testCase, any(comparison.Controller == "M10 Hinf full-order"));
end

function testT39M10LowerBoundSanityPasses(testCase)
m13 = testCase.TestData.m13;
verifyEqual(testCase, m13.qualityGate.m10LowerBoundSanity, "PASS");
verifyTrue(testCase, ...
    m13.nominalReconstruction.metrics.lowerBoundSanityPassed);
end

function testT40A5ComparisonExists(testCase)
comparison = testCase.TestData.m13.comparisonM10A5Kmu;
verifyTrue(testCase, any(comparison.Controller == "M11 A5"));
verifyTrue(testCase, any(comparison.Controller == "M13 Kmu"));
end

function testT41MusynObjectiveIsSaved(testCase)
m13 = testCase.TestData.m13;
verifyTrue(testCase, isfinite(m13.musynObjective));
verifyGreaterThan(testCase, m13.musynObjective, 0);
verifyEqual(testCase, m13.musynObjective, ...
    m13.synthesis.musynObjective, 'AbsTol', 0);
end

function testT42NoWeightOrUncertaintyRetuningOccurred(testCase)
m13 = testCase.TestData.m13;
verifyFalse(testCase, m13.metadata.weightRetuningPerformed);
verifyFalse(testCase, m13.metadata.uncertaintyRetuningPerformed);
verifyFalse(testCase, m13.config.weightRetuningEnabled);
verifyFalse(testCase, m13.config.uncertaintyRetuningEnabled);
end

function testT43NoTwoDegreeOfFreedomOrPrefilterWasUsed(testCase)
m13 = testCase.TestData.m13;
verifyFalse(testCase, m13.metadata.twoDegreeOfFreedomUsed);
verifyFalse(testCase, m13.metadata.prefilterUsed);
verifyFalse(testCase, m13.config.twoDegreeOfFreedomEnabled);
verifyFalse(testCase, m13.config.prefilterEnabled);
end

function testT44NoMonteCarloOrNonlinearValidationWasUsed(testCase)
m13 = testCase.TestData.m13;
verifyFalse(testCase, m13.metadata.monteCarloPerformed);
verifyFalse(testCase, m13.metadata.nonlinearValidationPerformed);
verifyEqual(testCase, localCallCount(m13Source(testCase), 'usample'), 0);
end

function testT45NoFormalM14AnalysisWasRun(testCase)
m13 = testCase.TestData.m13;
for name = {'robgain', 'wcgain', 'robstab', 'mussv'}
    verifyEqual(testCase, localCallCount(m13Source(testCase), name{1}), 0);
end
verifyFalse(testCase, m13.metadata.formalRobustAnalysisPerformed);
verifyFalse(testCase, m13.metadata.m14Started);
end

function testT46ArtifactAndSixFiguresExist(testCase)
m13 = testCase.TestData.m13;
verifyTrue(testCase, isfile(fullfile(testCase.TestData.projectRoot, ...
    'results', 'data', 'm13_musyn_dk.mat')));
verifyEqual(testCase, numel(fieldnames(m13.figurePaths)), 6);
verifyTrue(testCase, all(structfun(@isfile, m13.figurePaths)));
end

function testT47QualityGateSeparatesRequiredOutcomes(testCase)
gate = testCase.TestData.m13.qualityGate;
for name = ["frozenGeneralizedPlant", "frozenUncertainty", ...
        "frozenWeights", "dkExecution", "dkHistory", ...
        "controllerExtraction", "nominalInternalStability", ...
        "nominalWeightedReconstruction", "m10LowerBoundSanity"]
    verifyEqual(testCase, gate.(name), "PASS");
end
verifyEqual(testCase, gate.robustSynthesisObjective, "QUANTIFIED");
verifyEqual(testCase, gate.controllerOrder, "QUANTIFIED");
end

function testT48OverallStatusIsCoherent(testCase)
gate = testCase.TestData.m13.qualityGate;
verifyEqual(testCase, gate.softwareCorrectness, "PASS");
verifyEqual(testCase, gate.nominalInternalStability, "PASS");
verifyEqual(testCase, gate.overallStatus, "COMPLETE");
end

function testT49ObjectiveNeedNotBeBelowOne(testCase)
m13 = testCase.TestData.m13;
verifyEqual(testCase, m13.config.gammaTarget, 1);
verifyTrue(testCase, m13.qualityGate.softwareCorrectness == "PASS");
end

function testT50TerminationClassificationUsesFrozenMaxIter(testCase)
m13 = testCase.TestData.m13;
verifyEqual(testCase, m13.history.iterationCount, ...
    m13.config.maxIterations);
verifyEqual(testCase, m13.history.terminationClassification, ...
    "MAX_ITER_REACHED");
verifyFalse(testCase, m13.history.formalTerminationStatusAvailable);
end

function testT51WarningsAndOutputSemanticsAreSaved(testCase)
synthesis = testCase.TestData.m13.synthesis;
verifyTrue(testCase, isfield(synthesis, 'warningMessage'));
verifyTrue(testCase, isfield(synthesis, 'warningIdentifier'));
verifyTrue(testCase, contains(synthesis.secondOutputMeaning, ...
    "robust performance scalar"));
verifyTrue(testCase, synthesis.closedLoopReconstructedWithLft);
end

function testT52RobustArchitectureRemainsFrozen(testCase)
config = testCase.TestData.m13.config;
verifyFalse(testCase, config.weightRetuningEnabled);
verifyFalse(testCase, config.uncertaintyRetuningEnabled);
verifyFalse(testCase, config.secondSynthesisEnabled);
verifyFalse(testCase, config.controllerReductionEnabled);
verifyTrue(testCase, config.singleCandidate);
end

function source = localM13Source(projectRoot)
files = [dir(fullfile(projectRoot, 'controllers', 'mu', '*.m')); ...
    dir(fullfile(projectRoot, 'analysis', 'robust', '*m13*.m')); ...
    dir(fullfile(projectRoot, 'src', 'parameters', ...
        'mu_synthesis_specs_m13.m'))];
source = "";
for index = 1:numel(files)
    source = source + newline + string(fileread( ...
        fullfile(files(index).folder, files(index).name)));
end
end

function source = m13Source(testCase)
source = testCase.TestData.source;
end

function count = localCallCount(source, functionName)
pattern = ['\<', functionName, '\s*\('];
matches = regexp(char(source), pattern, 'match');
count = numel(matches);
end
