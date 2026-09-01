classdef test_m16_monte_carlo < matlab.unittest.TestCase
    %TEST_M16_MONTE_CARLO Frozen M4 common-sample Monte Carlo gates.

    properties
        Root
        M16
        M4
        M5
        M6
        M10
        M13
        M14
        Source
    end

    methods (TestClassSetup)
        function loadValidatedArtifacts(testCase)
            root = string(fileparts(fileparts(mfilename('fullpath'))));
            addpath(genpath(fullfile(root, 'src')));
            addpath(genpath(fullfile(root, 'controllers')));
            addpath(genpath(fullfile(root, 'analysis')));
            artifact = fullfile(root, 'results', 'data', ...
                'm16_monte_carlo_uncertain_linear.mat');
            if ~isfile(artifact)
                validate_m16_monte_carlo(true);
            end
            testCase.Root = root;
            testCase.M16 = load(artifact);
            testCase.M4 = load(fullfile(root, 'results', 'data', ...
                'm4_uncertain_plant.mat'));
            testCase.M5 = load(fullfile(root, 'results', 'data', ...
                'm5_performance_specs.mat'));
            testCase.M6 = load(fullfile(root, 'results', 'data', ...
                'm6_lqg_no_integrator.mat'));
            testCase.M10 = load(fullfile(root, 'results', 'data', ...
                'm10_hinfsyn_nominal.mat'));
            testCase.M13 = load(fullfile(root, 'results', 'data', ...
                'm13_musyn_dk.mat'));
            testCase.M14 = load(fullfile(root, 'results', 'data', ...
                'm14_final_mu_analysis_kmu.mat'));
            testCase.Source = localM16Source(root);
        end
    end

    methods (Test)
        function testT01BaselineCommitIsM15Merge(testCase)
            testCase.verifyEqual(testCase.M16.config.baselineCommit, ...
                "8e1c8437c786a252a380ce6b4452d32bebf9c2c6");
        end

        function testT02CampaignSemanticsAreRecorded(testCase)
            testCase.verifyEqual(testCase.M16.config.numberSamples, 40);
            testCase.verifyEqual(testCase.M16.config.seed, 20260826);
            testCase.verifyTrue(contains( ...
                testCase.M16.config.monteCarloInterpretation, ...
                "NOT_A_ROBUSTNESS_CERTIFICATE"));
        end

        function testT03GuncMeasFrozen(testCase)
            testCase.verifyEqual(testCase.M16.m4SourceAudit.GuncMeasSize, ...
                size(testCase.M4.GuncMeas));
        end

        function testT04GuncQFrozen(testCase)
            testCase.verifyEqual(testCase.M16.m4SourceAudit.GuncQSize, ...
                size(testCase.M4.GuncQ));
        end

        function testT05GmechUncMeasFrozen(testCase)
            testCase.verifyEqual( ...
                testCase.M16.m4SourceAudit.GmechUncMeasSize, ...
                size(testCase.M4.GmechUncMeas));
        end

        function testT06GmechUncQFrozen(testCase)
            testCase.verifyEqual(testCase.M16.m4SourceAudit.GmechUncQSize, ...
                size(testCase.M4.GmechUncQ));
        end

        function testT07FiveM4Blocks(testCase)
            testCase.verifyEqual(sort(testCase.M16.m4SourceAudit.blockNames), ...
                sort(["Delta_act1"; "Delta_act2"; "Jm1"; "k1"; "k2"]));
        end

        function testT08MechanicalRangesUnchanged(testCase)
            testCase.verifyTrue( ...
                testCase.M16.m4SourceAudit.mechanicalRangesMatch);
        end

        function testT09DynamicBoundsUnchanged(testCase)
            testCase.verifyEqual(testCase.M16.m4SourceAudit.deltaBounds, ...
                [1; 1], AbsTol=1e-12);
        end

        function testT10M6KlqgFrozen(testCase)
            audit = testCase.M16.controllerAudits(1);
            [A, B, C, D] = ssdata(testCase.M6.Klqg);
            testCase.verifyEqual({audit.A, audit.B, audit.C, audit.D}, ...
                {A, B, C, D});
        end

        function testT11KhinfFrozen(testCase)
            audit = testCase.M16.controllerAudits(2);
            [A, B, C, D] = ssdata(testCase.M10.Khinf);
            testCase.verifyEqual({audit.A, audit.B, audit.C, audit.D}, ...
                {A, B, C, D});
        end

        function testT12KmuFrozen(testCase)
            audit = testCase.M16.controllerAudits(3);
            [A, B, C, D] = ssdata(testCase.M13.Kmu);
            testCase.verifyEqual({audit.A, audit.B, audit.C, audit.D}, ...
                {A, B, C, D});
            testCase.verifyTrue(audit.bestIterationIdentity);
        end

        function testT13ControllerOrdersFromArtifacts(testCase)
            testCase.verifyEqual([testCase.M16.controllerAudits.order].', ...
                [order(testCase.M6.Klqg); order(testCase.M10.Khinf); ...
                order(testCase.M13.Kmu)]);
        end

        function testT14SeedFrozen(testCase)
            testCase.verifyEqual(testCase.M16.seed, 20260826);
        end

        function testT15SampleCountFrozen(testCase)
            testCase.verifyEqual(testCase.M16.numberSamples, 40);
        end

        function testT16TwisterGeneratorFrozen(testCase)
            testCase.verifyEqual(testCase.M16.config.rngAlgorithm, "twister");
        end

        function testT17OneEffectiveCampaign(testCase)
            audit = testCase.M16.sampleGenerationAudit;
            testCase.verifyEqual([audit.effectiveCampaignCalls, ...
                audit.auditReplayCalls], [1, 1]);
            testCase.verifyFalse(audit.simulationUsesReplay);
        end

        function testT18SampledValuesPresent(testCase)
            testCase.verifySize(testCase.M16.sampledValuesRaw, [40, 1]);
        end

        function testT19SampleIdsOneToForty(testCase)
            testCase.verifyEqual(testCase.M16.sampleMetadataTable.SampleID, ...
                (1:40).');
        end

        function testT20SampleReplayReproducible(testCase)
            testCase.verifyTrue(testCase.M16.sampleReplayAudit.passed);
            testCase.verifyLessThanOrEqual( ...
                testCase.M16.sampleReplayAudit.maximumDynamicFrequencyError, ...
                testCase.M16.sampleReplayAudit.tolerance);
        end

        function testT21AllUrealInRange(testCase)
            testCase.verifyTrue(all( ...
                testCase.M16.sampleMetadataTable.UrealInRange));
        end

        function testT22DeltaAct1Valid(testCase)
            tableData = testCase.M16.sampleMetadataTable;
            testCase.verifyTrue(all(tableData.DeltaAct1Stable & ...
                tableData.DeltaAct1Finite & ...
                tableData.DeltaAct1HinfNorm <= 1 + 1e-8));
        end

        function testT23DeltaAct2Valid(testCase)
            tableData = testCase.M16.sampleMetadataTable;
            testCase.verifyTrue(all(tableData.DeltaAct2Stable & ...
                tableData.DeltaAct2Finite & ...
                tableData.DeltaAct2HinfNorm <= 1 + 1e-8));
        end

        function testT24SameValuesForAllControllers(testCase)
            testCase.verifyTrue( ...
                testCase.M16.sampleGenerationAudit.sameSequenceForAllControllers);
            testCase.verifyEqual(height(testCase.M16.stabilityTable), 120);
        end

        function testT25SampledActuatorReconstruction(testCase)
            audit = testCase.M16.sampledPhysicalPlantAudit.table;
            testCase.verifyTrue(all(audit.ActuatorOrder > 0));
        end

        function testT26SampledMechanicalReconstruction(testCase)
            audit = testCase.M16.sampledPhysicalPlantAudit.table;
            testCase.verifyEqual(unique(audit.MechanicalOrder), 8);
        end

        function testT27SharedPlantMeasEquivalent(testCase)
            testCase.verifyLessThanOrEqual(testCase.M16. ...
                sampledPhysicalPlantAudit.maximumMeasurementAbsoluteError, ...
                testCase.M16.config.frequencyAbsoluteTolerance);
        end

        function testT28SharedPlantQEquivalent(testCase)
            testCase.verifyLessThanOrEqual(testCase.M16. ...
                sampledPhysicalPlantAudit.maximumPositionRelativeError, ...
                testCase.M16.config.frequencyRelativeTolerance);
        end

        function testT29SampleZeroExcluded(testCase)
            testCase.verifyTrue(testCase.M16. ...
                nominalReconstructionAudit.excludedFromMonteCarloStatistics);
            testCase.verifyGreaterThanOrEqual( ...
                min(testCase.M16.sampleControllerSummaryTable.Sample), 1);
        end

        function testT30NominalM6Reconstruction(testCase)
            testCase.verifyTrue( ...
                testCase.M16.nominalReconstructionAudit.controllers(1).passed);
        end

        function testT31NominalKhinfReconstruction(testCase)
            testCase.verifyTrue( ...
                testCase.M16.nominalReconstructionAudit.controllers(2).passed);
        end

        function testT32NominalKmuReconstruction(testCase)
            testCase.verifyTrue( ...
                testCase.M16.nominalReconstructionAudit.controllers(3).passed);
        end

        function testT33InternalStabilityExplicit(testCase)
            testCase.verifyTrue(all(testCase.M16. ...
                stabilityTable.InternalStateCount > 0));
            testCase.verifyTrue(all(ismember( ...
                testCase.M16.stabilityTable.Classification, ...
                ["STABLE"; "UNSTABLE"; "NUMERICALLY_INVALID"])));
        end

        function testT34NoMinrealQualityGate(testCase)
            testCase.verifyEmpty(regexp(testCase.Source, ...
                '(?<![A-Za-z0-9_])minreal\s*\(', 'once'));
        end

        function testT35FortyM6StabilityRecords(testCase)
            testCase.verifyEqual(sum( ...
                testCase.M16.stabilityTable.Controller == "M6"), 40);
        end

        function testT36FortyKhinfStabilityRecords(testCase)
            testCase.verifyEqual(sum( ...
                testCase.M16.stabilityTable.Controller == "Khinf"), 40);
        end

        function testT37FortyKmuStabilityRecords(testCase)
            testCase.verifyEqual(sum( ...
                testCase.M16.stabilityTable.Controller == "Kmu"), 40);
        end

        function testT38KmuAllStableOrBlocked(testCase)
            rows = testCase.M16.stabilityTable.Controller == "Kmu";
            testCase.verifyTrue(all(testCase.M16.stabilityTable.Stable(rows)));
        end

        function testT39M14Consistency(testCase)
            testCase.verifyTrue(testCase.M16.m14Consistency.passed);
            testCase.verifyEqual(testCase.M16.m14Consistency.marginLower, ...
                testCase.M14.robustStabilityMargin.LowerBound, AbsTol=1e-12);
        end

        function testT40BandwidthForStableSamples(testCase)
            eligible = testCase.M16.bandwidthTable.Stable;
            testCase.verifyTrue(all( ...
                testCase.M16.bandwidthTable.BandwidthReasonJ1(eligible) == "OK" & ...
                testCase.M16.bandwidthTable.BandwidthReasonJ2(eligible) == "OK"));
        end

        function testT41TwoTrackingScenariosPerSampleController(testCase)
            testCase.verifyEqual(height(testCase.M16.trackingTable), 240);
        end

        function testT42TrackingAmplitudeFiveDegrees(testCase)
            testCase.verifyEqual(unique( ...
                testCase.M16.trackingTable.TrackingAmplitudeDeg), 5);
        end

        function testT43MetricConventionFrozen(testCase)
            testCase.verifyEqual([testCase.M16.config.timeStep, ...
                testCase.M16.config.trackingHorizon, ...
                testCase.M16.config.settlingBandFraction], ...
                [0.002, 4, 0.02], AbsTol=1e-14);
        end

        function testT44TwoDisturbanceScenariosPerSampleController(testCase)
            testCase.verifyEqual(height(testCase.M16.disturbanceTable), 240);
        end

        function testT45DisturbanceAmplitudeHalfNewtonMetre(testCase)
            testCase.verifyEqual(unique(testCase.M16. ...
                disturbanceTable.DisturbanceAmplitudeNm), 0.5);
        end

        function testT46PhysicalLinkDisturbance(testCase)
            testCase.verifyTrue(testCase.M16. ...
                sampledPhysicalPlantAudit.disturbanceEntersLinkMechanics);
        end

        function testT47CrossCouplingProduced(testCase)
            rows = testCase.M16.trackingTable.PerformanceEligible;
            testCase.verifyTrue(all(isfinite(testCase.M16. ...
                trackingTable.TrackingCrossCoupling(rows))));
        end

        function testT48ControlEffortProduced(testCase)
            rows = testCase.M16.disturbanceTable.PerformanceEligible;
            testCase.verifyTrue(all(isfinite(testCase.M16. ...
                disturbanceTable.DisturbancePeakU(rows))));
        end

        function testT49UScaleIsNormalizationOnly(testCase)
            rows = testCase.M16.trackingTable.PerformanceEligible;
            testCase.verifyEqual(testCase.M16. ...
                trackingTable.TrackingPeakUNormalized(rows), ...
                testCase.M16.trackingTable.TrackingPeakU(rows) / ...
                testCase.M5.spec.uScale, AbsTol=1e-12);
        end

        function testT50NoSaturation(testCase)
            testCase.verifyFalse(testCase.M16.metadata.saturationEnabled);
            testCase.verifyEqual(testCase.M16.qualityGate.controlEffort, ...
                "QUANTIFIED_NO_SATURATION");
        end

        function testT51PassRatesProduced(testCase)
            testCase.verifyEqual(height(testCase.M16.empiricalPassRates), 3);
            testCase.verifyTrue(all(testCase.M16. ...
                empiricalPassRates.StableFractionTotal >= 0 & ...
                testCase.M16.empiricalPassRates.StableFractionTotal <= 1));
        end

        function testT52SummaryQuantilesProduced(testCase)
            testCase.verifyTrue(all(ismember( ...
                {'Minimum', 'Percentile05', 'Median', 'Mean', ...
                'Percentile95', 'Maximum'}, ...
                testCase.M16.summaryStatistics.Properties.VariableNames)));
        end

        function testT53PairedComparisonsProduced(testCase)
            testCase.verifyEqual(height(testCase.M16.pairedComparisons), 18);
            testCase.verifyTrue(all(testCase.M16. ...
                pairedComparisons.CommonStableCount > 0));
        end

        function testT54NoGlobalScore(testCase)
            testCase.verifyFalse(testCase.M16.metadata.m17Started);
            testCase.verifyEmpty(regexp(testCase.Source, ...
                '(?i)globalScore\s*=\s*[^f]', 'once'));
        end

        function testT55M15LoadedWithoutRerun(testCase)
            testCase.verifyTrue(testCase.M16.metadata.m15LoadedWithoutRerun);
            testCase.verifyFalse(testCase.M16. ...
                m15ComparisonMetadata.simulinkRerun);
        end

        function testT56NoSimulinkM16(testCase)
            testCase.verifyFalse(testCase.M16.metadata.simulinkUsed);
            testCase.verifyEmpty(regexp(testCase.Source, ...
                '(?<![A-Za-z0-9_])sim\s*\(', 'once'));
        end

        function testT57NoNonlinearSampling(testCase)
            testCase.verifyTrue(testCase.M16.metadata.linearUncertainMonteCarlo);
            testCase.verifyFalse(testCase.M16. ...
                metadata.nonlinearSimulationPerformed);
        end

        function testT58NoSynthesis(testCase)
            testCase.verifyFalse(testCase.M16.metadata.synthesisPerformed);
        end

        function testT59NoMixsyn(testCase)
            testCase.verifyEmpty(regexp(testCase.Source, ...
                '(?<![A-Za-z0-9_])mixsyn\s*\(', 'once'));
        end

        function testT60NoHinfsyn(testCase)
            testCase.verifyEmpty(regexp(testCase.Source, ...
                '(?<![A-Za-z0-9_])hinfsyn\s*\(', 'once'));
        end

        function testT61NoHinfstruct(testCase)
            testCase.verifyEmpty(regexp(testCase.Source, ...
                '(?<![A-Za-z0-9_])hinfstruct\s*\(', 'once'));
        end

        function testT62NoMusyn(testCase)
            testCase.verifyEmpty(regexp(testCase.Source, ...
                '(?<![A-Za-z0-9_])musyn\s*\(', 'once'));
        end

        function testT63NoControllerReduction(testCase)
            testCase.verifyFalse(testCase.M16. ...
                metadata.controllerReductionPerformed);
        end

        function testT64NoM5Retuning(testCase)
            testCase.verifyFalse(testCase.M16.metadata.weightRetuningPerformed);
            testCase.verifyFalse(testCase.M16. ...
                metadata.controllerTuningPerformed);
        end

        function testT65NoM17(testCase)
            testCase.verifyFalse(testCase.M16.metadata.m17Started);
        end

        function testT66ArtifactProduced(testCase)
            testCase.verifyTrue(isfile(fullfile(testCase.Root, ...
                testCase.M16.config.artifactPath)));
        end

        function testT67FiguresProduced(testCase)
            paths = string(struct2cell(testCase.M16.figurePaths));
            testCase.verifyEqual(numel(paths), 9);
            testCase.verifyTrue(all(isfile(paths)));
        end

        function testT68QualityGateCoherent(testCase)
            gate = testCase.M16.qualityGate;
            testCase.verifyEqual([gate.baselineGit, gate.frozenUncertainty, ...
                gate.frozenControllers, gate.randomCampaign, ...
                gate.sampleValidity, gate.physicalSampledRealization, ...
                gate.nominalReconstruction, gate.KmuM14Consistency, ...
                gate.softwareCorrectness], repmat("PASS", 1, 9));
        end

        function testT69OverallStatusCoherent(testCase)
            testCase.verifyEqual(testCase.M16.qualityGate.overallStatus, ...
                "COMPLETE");
            testCase.verifyFalse(testCase.M16. ...
                metadata.robustnessCertificateProduced);
        end
    end
end

function source = localM16Source(root)
files = dir(fullfile(root, 'analysis', 'monte_carlo', '*.m'));
paths = fullfile({files.folder}, {files.name});
paths{end + 1} = fullfile(root, 'src', 'parameters', ...
    'monte_carlo_specs_m16.m');
source = "";
for index = 1:numel(paths)
    source = source + newline + string(fileread(paths{index}));
end
end
