classdef test_m17_final_controller_comparison < matlab.unittest.TestCase
    %TEST_M17_FINAL_CONTROLLER_COMPARISON Artifact-only M17 gates T01-T42.

    properties
        Root
        M17
        M5
        M6
        M10
        M13
        M14
        M16
        Source
    end

    methods (TestClassSetup)
        function loadValidatedArtifacts(testCase)
            root = string(fileparts(fileparts(mfilename('fullpath'))));
            addpath(genpath(fullfile(root, 'src')));
            addpath(genpath(fullfile(root, 'controllers')));
            addpath(genpath(fullfile(root, 'analysis')));
            artifact = fullfile(root, 'results', 'data', ...
                'm17_final_controller_comparison.mat');
            if ~isfile(artifact)
                validate_m17_final_comparison(true);
            end
            testCase.Root = root;
            testCase.M17 = load(artifact);
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
            testCase.M16 = load(fullfile(root, 'results', 'data', ...
                'm16_monte_carlo_uncertain_linear.mat'));
            testCase.Source = localM17Source(root);
        end
    end

    methods (Test)
        function testT01BaselineM16Merge(testCase)
            testCase.verifyEqual(testCase.M17.metadata.baselineCommit, ...
                "392ad170dc6665c87b769e314edb8380a4b1c8bc");
        end

        function testT02Pr21RecordedMerged(testCase)
            status = string(fileread(fullfile(testCase.Root, 'docs', ...
                'PROJECT_STATUS.md')));
            testCase.verifyEqual(testCase.M17.metadata.mergedPullRequest, 21);
            testCase.verifyEqual(testCase.M17.metadata.mergedPullRequestState, ...
                "MERGED");
            testCase.verifyTrue(contains(status, "PR #21") && ...
                contains(status, "MERGED"));
        end

        function testT03KlqgIdentityM6(testCase)
            row = testCase.M17.controllerIdentityAudit.Controller == "M6";
            testCase.verifyTrue(testCase.M17. ...
                controllerIdentityAudit.IdentityPassed(row));
            testCase.verifyEqual(testCase.M17. ...
                controllerIdentityAudit.Order(row), order(testCase.M6.Klqg));
        end

        function testT04KhinfIdentityM10(testCase)
            row = testCase.M17.controllerIdentityAudit.Controller == "Khinf";
            testCase.verifyTrue(testCase.M17. ...
                controllerIdentityAudit.IdentityPassed(row));
            testCase.verifyEqual(testCase.M17. ...
                controllerIdentityAudit.Order(row), order(testCase.M10.Khinf));
        end

        function testT05KmuIdentityM13(testCase)
            row = testCase.M17.controllerIdentityAudit.Controller == "Kmu";
            testCase.verifyTrue(testCase.M17. ...
                controllerIdentityAudit.IdentityPassed(row));
            testCase.verifyEqual(testCase.M17. ...
                controllerIdentityAudit.Order(row), order(testCase.M13.Kmu));
        end

        function testT06ControllerOrders(testCase)
            testCase.verifyEqual(testCase.M17.complexityComparison.Order, ...
                [14; 18; 52]);
        end

        function testT07M8Loaded(testCase)
            row = testCase.M17.evidenceMatrix.Controller == "M6";
            testCase.verifyTrue(contains(testCase.M17. ...
                evidenceMatrix.NominalNonlinearSource(row), "m8_"));
        end

        function testT08M14Loaded(testCase)
            row = testCase.M17.evidenceMatrix.Controller == "Kmu";
            testCase.verifyTrue(contains(testCase.M17. ...
                evidenceMatrix.FormalRobustnessSource(row), "m14_"));
        end

        function testT09M15Loaded(testCase)
            rows = testCase.M17.evidenceMatrix.Controller ~= "M6";
            testCase.verifyTrue(all(contains(testCase.M17. ...
                evidenceMatrix.NominalNonlinearSource(rows), "m15_")));
        end

        function testT10M16Loaded(testCase)
            testCase.verifyTrue(all(contains(testCase.M17. ...
                evidenceMatrix.UncertainLinearMonteCarloSource, "m16_")));
        end

        function testT11NoNewSynthesis(testCase)
            testCase.verifyFalse(testCase.M17.metadata.synthesisPerformed);
        end

        function testT12NoMusyn(testCase)
            testCase.verifyFalse(testCase.M17.metadata.musynPerformed);
            testCase.verifyEmpty(regexp(testCase.Source, ...
                '(?<![A-Za-z0-9_])musyn\s*\(', 'once'));
        end

        function testT13NoHinfsyn(testCase)
            testCase.verifyFalse(testCase.M17.metadata.hinfsynPerformed);
            testCase.verifyEmpty(regexp(testCase.Source, ...
                '(?<![A-Za-z0-9_])hinfsyn\s*\(', 'once'));
        end

        function testT14NoMixsyn(testCase)
            testCase.verifyFalse(testCase.M17.metadata.mixsynPerformed);
            testCase.verifyEmpty(regexp(testCase.Source, ...
                '(?<![A-Za-z0-9_])mixsyn\s*\(', 'once'));
        end

        function testT15NoHinfstruct(testCase)
            testCase.verifyFalse(testCase.M17.metadata.hinfstructPerformed);
            testCase.verifyEmpty(regexp(testCase.Source, ...
                '(?<![A-Za-z0-9_])hinfstruct\s*\(', 'once'));
        end

        function testT16NoNewMonteCarlo(testCase)
            testCase.verifyFalse(testCase.M17.metadata.monteCarloPerformed);
        end

        function testT17NoNewUsampleSequence(testCase)
            testCase.verifyFalse(testCase.M17. ...
                metadata.usampleSequenceGenerated);
            testCase.verifyEmpty(regexp(testCase.Source, ...
                '(?<![A-Za-z0-9_])usample\s*\(', 'once'));
        end

        function testT18NoSimulinkM17(testCase)
            testCase.verifyFalse(testCase.M17.metadata.simulinkUsed);
            testCase.verifyEmpty(regexp(testCase.Source, ...
                '(?<![A-Za-z0-9_])sim\s*\(', 'once'));
        end

        function testT19NominalEvidenceSeparated(testCase)
            row = testCase.M17.evidenceSeparationAudit.EvidenceClass == ...
                "NOMINAL_LINEAR";
            testCase.verifyTrue(testCase.M17. ...
                evidenceSeparationAudit.KeptSeparate(row));
        end

        function testT20NonlinearEvidenceSeparated(testCase)
            row = testCase.M17.evidenceSeparationAudit.EvidenceClass == ...
                "NOMINAL_NONLINEAR";
            testCase.verifyTrue(testCase.M17. ...
                evidenceSeparationAudit.KeptSeparate(row));
        end

        function testT21MonteCarloEvidenceSeparated(testCase)
            row = testCase.M17.evidenceSeparationAudit.EvidenceClass == ...
                "UNCERTAIN_LINEAR_MONTE_CARLO";
            testCase.verifyTrue(testCase.M17. ...
                evidenceSeparationAudit.KeptSeparate(row));
        end

        function testT22FormalEvidenceSeparated(testCase)
            row = testCase.M17.evidenceSeparationAudit.EvidenceClass == ...
                "FORMAL_ROBUSTNESS";
            testCase.verifyTrue(testCase.M17. ...
                evidenceSeparationAudit.KeptSeparate(row));
        end

        function testT23KmuRsReadFromM14(testCase)
            row = testCase.M17.robustnessComparison.Controller == "Kmu";
            testCase.verifyEqual(testCase.M17.robustnessComparison.FormalRS(row), ...
                string(testCase.M14.qualityGate.robustStability));
            testCase.verifyEqual(testCase.M17. ...
                robustnessComparison.RSMarginLower(row), ...
                testCase.M14.robustStabilityMargin.LowerBound, AbsTol=1e-12);
        end

        function testT24KmuRpNotPromoted(testCase)
            row = testCase.M17.robustnessComparison.Controller == "Kmu";
            testCase.verifyEqual(testCase.M17.robustnessComparison.FormalRP(row), ...
                "FAIL_CERTIFIED");
        end

        function testT25M6RsUnavailable(testCase)
            row = testCase.M17.robustnessComparison.Controller == "M6";
            testCase.verifyEqual(testCase.M17.robustnessComparison.FormalRS(row), ...
                "N/A");
        end

        function testT26KhinfRsUnavailable(testCase)
            row = testCase.M17.robustnessComparison.Controller == "Khinf";
            testCase.verifyEqual(testCase.M17.robustnessComparison.FormalRS(row), ...
                "N/A");
        end

        function testT27A5NotConfusedWithKhinf(testCase)
            testCase.verifyFalse(testCase.M17. ...
                historicalA5Comparison.IsM17PrimaryCandidate);
            testCase.verifyTrue(contains(testCase.M17. ...
                robustnessComparison.Note(2), "A5"));
        end

        function testT28M6SampleFivePreserved(testCase)
            row = testCase.M17.monteCarloComparison.Controller == "M6";
            testCase.verifyEqual(testCase.M17. ...
                monteCarloComparison.UnstableSamples(row), "5");
        end

        function testT29M16SampleCountsCoherent(testCase)
            testCase.verifyEqual(testCase.M17.monteCarloComparison.NTotal, ...
                [40; 40; 40]);
            testCase.verifyEqual(testCase.M17.monteCarloComparison.NStable, ...
                [39; 40; 40]);
        end

        function testT30TrackingPassRatesCoherent(testCase)
            testCase.verifyEqual(testCase.M17. ...
                monteCarloComparison.CoreTrackingPassRateTotal, ...
                testCase.M16.empiricalPassRates.AllCorePassFractionTotal, ...
                AbsTol=1e-14);
        end

        function testT31RasSemanticsPreserved(testCase)
            testCase.verifyFalse(any(testCase.M17. ...
                rasComparison.AnalyticallyCertified));
            testCase.verifyTrue(all(contains(testCase.M17. ...
                rasComparison.Interpretation, "EMPIRICAL")));
        end

        function testT32UScaleIsNormalization(testCase)
            testCase.verifyEqual(unique(testCase.M17. ...
                controlEffortComparison.UScaleNm), testCase.M5.spec.uScale);
            testCase.verifyEqual(testCase.M17.metadata.uScaleInterpretation, ...
                "PERFORMANCE_NORMALIZATION_NOT_CERTIFIED_SATURATION");
        end

        function testT33NoSaturationClaim(testCase)
            testCase.verifyTrue(all(testCase.M17. ...
                controlEffortComparison.SaturationInterpretation == ...
                "NO SATURATION CLAIM"));
        end

        function testT34MasterTableProduced(testCase)
            required = {'Controller', 'Architecture', 'Order', ...
                'NominalInternalStability', 'MonteCarloStability', ...
                'FormalRS', 'FormalRP', 'MainStrength', ...
                'MainWeakness', 'FinalRole'};
            testCase.verifyEqual(height(testCase.M17.masterComparison), 3);
            testCase.verifyTrue(all(ismember(required, testCase.M17. ...
                masterComparison.Properties.VariableNames)));
        end

        function testT35StrengthsWeaknessesProduced(testCase)
            testCase.verifyEqual(height(testCase.M17.strengths), 3);
            testCase.verifyEqual(height(testCase.M17.weaknesses), 3);
            testCase.verifyTrue(all(strlength(testCase.M17.strengths.Strength) > 0));
        end

        function testT36NoGlobalScore(testCase)
            testCase.verifyFalse(testCase.M17.metadata.globalScoreUsed);
            testCase.verifyEmpty(regexp(testCase.Source, ...
                '(?i)globalScore\s*=\s*[^f]', 'once'));
        end

        function testT37RolesFollowDecisionRule(testCase)
            testCase.verifyTrue(all(testCase.M17.decisionRuleAudit.Passed));
            testCase.verifyEqual(sort(testCase.M17. ...
                finalRoleAssignment.Controller), ...
                sort(testCase.M17.masterComparison.Controller));
            testCase.verifyEqual(sort(testCase.M17. ...
                finalRoleAssignment.Role), ...
                sort(testCase.M17.masterComparison.FinalRole));
        end

        function testT38ArtifactProduced(testCase)
            testCase.verifyTrue(isfile(fullfile(testCase.Root, 'results', ...
                'data', 'm17_final_controller_comparison.mat')));
        end

        function testT39FiguresProduced(testCase)
            paths = string(struct2cell(testCase.M17.figurePaths));
            testCase.verifyEqual(numel(paths), 7);
            testCase.verifyTrue(all(isfile(paths)));
        end

        function testT40DocumentationUpdated(testCase)
            document = fullfile(testCase.Root, 'docs', ...
                'FINAL_CONTROLLER_COMPARISON.md');
            testCase.verifyTrue(isfile(document));
            testCase.verifyTrue(contains(string(fileread(document)), ...
                "M17"));
        end

        function testT41QualityGateCoherent(testCase)
            gate = struct2cell(testCase.M17.qualityGate);
            testCase.verifyTrue(all(string(gate) == "PASS" | ...
                string(gate) == "COMPLETE"));
        end

        function testT42NoM18(testCase)
            testCase.verifyFalse(testCase.M17.metadata.m18Started);
            testCase.verifyFalse(testCase.M17. ...
                metadata.dynamicSimulationPerformed);
        end
    end
end

function source = localM17Source(root)
files = dir(fullfile(root, 'analysis', 'comparison', '*.m'));
paths = fullfile({files.folder}, {files.name});
paths{end + 1} = fullfile(root, 'src', 'parameters', ...
    'final_comparison_specs_m17.m');
source = "";
for index = 1:numel(paths)
    source = source + newline + string(fileread(paths{index}));
end
end
