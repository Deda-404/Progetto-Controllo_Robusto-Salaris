classdef test_m18_final_deliverables < matlab.unittest.TestCase
    %TEST_M18_FINAL_DELIVERABLES Final deliverable validation T01-T60.

    properties
        Root
        M18
        Evidence
        Source
    end

    methods (TestClassSetup)
        function loadFinalDeliverables(testCase)
            root = string(fileparts(fileparts(mfilename('fullpath'))));
            addpath(genpath(fullfile(root, 'src')));
            addpath(genpath(fullfile(root, 'controllers')));
            addpath(genpath(fullfile(root, 'analysis')));
            validate_m18_deliverables(true, true);
            testCase.Root = root;
            testCase.M18 = load(fullfile(root, 'results', 'data', ...
                'm18_final_deliverable_audit.mat'));
            testCase.Evidence = load_m18_validated_artifacts;
            testCase.Source = localM18Source(root);
        end
    end

    methods (Test)
        function testT01BaselineCommit(testCase)
            testCase.verifyEqual(testCase.M18.metadata.baselineCommit, ...
                "75d194d49a96b67309b1853f154bdd22a168ca4f");
        end

        function testT02SourceSnapshotMetadataIsRecorded(testCase)
            testCase.verifyEqual(testCase.M18.metadata.mergedPullRequest, 22);
            testCase.verifyEqual(testCase.M18.metadata.mergedPullRequestState, ...
                "MERGED");
            testCase.verifyEqual(testCase.M18.metadata.baselineCommit, ...
                "75d194d49a96b67309b1853f154bdd22a168ca4f");
        end

        function testT03SourceInventoryComplete(testCase)
            testCase.verifyEqual(height(testCase.M18.sourceInventory), 23);
            testCase.verifyTrue(all(testCase.M18.sourceInventory.Exists));
        end

        function testT04M17ArtifactLoaded(testCase)
            row = testCase.M18.sourceInventory.Milestone == "M17";
            testCase.verifyTrue(testCase.M18.sourceInventory.Exists(row));
            testCase.verifyTrue(isfile(testCase.M18.sourceInventory.Path(row)));
        end

        function testT05M6IdentityPreserved(testCase)
            row = testCase.Evidence.m17.controllerIdentityAudit.Controller == "M6";
            testCase.verifyTrue(testCase.Evidence.m17. ...
                controllerIdentityAudit.IdentityPassed(row));
        end

        function testT06KhinfIdentityPreserved(testCase)
            row = testCase.Evidence.m17.controllerIdentityAudit.Controller == ...
                "Khinf";
            testCase.verifyTrue(testCase.Evidence.m17. ...
                controllerIdentityAudit.IdentityPassed(row));
        end

        function testT07KmuIdentityPreserved(testCase)
            row = testCase.Evidence.m17.controllerIdentityAudit.Controller == ...
                "Kmu";
            testCase.verifyTrue(testCase.Evidence.m17. ...
                controllerIdentityAudit.IdentityPassed(row));
        end

        function testT08ControllerOrdersPreserved(testCase)
            testCase.verifyEqual([order(testCase.Evidence.m6.Klqg); ...
                order(testCase.Evidence.m10.Khinf); ...
                order(testCase.Evidence.m13.Kmu)], [14; 18; 52]);
        end

        function testT09NoNewSynthesis(testCase)
            c = testCase.M18.metadata;
            testCase.verifyFalse(c.synthesisPerformed || c.musynPerformed);
        end

        function testT10NoHinfSynthesisCalls(testCase)
            c = testCase.M18.metadata;
            testCase.verifyFalse(c.hinfsynPerformed || c.mixsynPerformed || ...
                c.hinfstructPerformed);
        end

        function testT11NoControllerRetuning(testCase)
            testCase.verifyFalse(testCase.M18.metadata. ...
                controllerRetuningPerformed);
        end

        function testT12NoWeightRetuning(testCase)
            testCase.verifyFalse(testCase.M18.metadata.weightRetuningPerformed);
        end

        function testT13NoUncertaintyRetuning(testCase)
            testCase.verifyFalse(testCase.M18.metadata. ...
                uncertaintyRetuningPerformed);
        end

        function testT14NoMonteCarloGeneration(testCase)
            c = testCase.M18.metadata;
            testCase.verifyFalse(c.monteCarloPerformed || ...
                c.usampleSequenceGenerated);
        end

        function testT15NoDynamicSimulation(testCase)
            c = testCase.M18.metadata;
            testCase.verifyFalse(c.dynamicSimulationPerformed || c.simulinkUsed);
        end

        function testT16NoControllerReduction(testCase)
            testCase.verifyFalse(testCase.M18.metadata. ...
                controllerReductionPerformed);
        end

        function testT17TechnicalResultsUnmodified(testCase)
            testCase.verifyFalse(testCase.M18.metadata. ...
                technicalResultsModified);
        end

        function testT18NoForbiddenCallsInM18Source(testCase)
            expression = ['(?<![A-Za-z0-9_])' ...
                '(musyn|hinfsyn|mixsyn|hinfstruct|usample|sim)\s*\('];
            testCase.verifyEmpty(regexp(testCase.Source, expression, 'once'));
        end

        function testT19NegativeStatusesPreserved(testCase)
            statuses = [string(testCase.Evidence.m7.validationMetrics.status); ...
                string(testCase.Evidence.m9.qualityGate.overallStatus); ...
                string(testCase.Evidence.m10.qualityGate.overallStatus); ...
                string(testCase.Evidence.m11.qualityGate.overallStatus); ...
                string(testCase.Evidence.m12.qualityGate.overallStatus); ...
                string(testCase.Evidence.m14.qualityGate.overallStatus); ...
                string(testCase.Evidence.m15.qualityGate.overallStatus)];
            testCase.verifyEqual(statuses, repmat("PARTIAL", 7, 1));
        end

        function testT20KmuRobustStabilityPreserved(testCase)
            testCase.verifyEqual(string(testCase.Evidence.m14. ...
                qualityGate.robustStability), "PASS_CERTIFIED");
            testCase.verifyGreaterThan(testCase.Evidence.m14. ...
                robustStabilityMargin.LowerBound, 1);
        end

        function testT21KmuPerformanceFailuresPreserved(testCase)
            testCase.verifyEqual(string(testCase.Evidence.m14. ...
                qualityGate.nominalPerformance), "FAIL");
            testCase.verifyEqual(string(testCase.Evidence.m14. ...
                qualityGate.robustPerformance), "FAIL_CERTIFIED");
        end

        function testT22M16CountsPreserved(testCase)
            testCase.verifyEqual(testCase.Evidence.m16.numberSamples, 40);
            testCase.verifyEqual(testCase.Evidence.m16.stabilitySummary.NStable, ...
                [38; 40; 40]);
        end

        function testT23M6SampleFivePreserved(testCase)
            rows = testCase.Evidence.m16.stabilityTable.Controller == "M6" & ...
                ismember(testCase.Evidence.m16.stabilityTable.Sample, [5; 6]);
            testCase.verifyEqual(testCase.Evidence.m16. ...
                stabilityTable.Sample(rows), [5; 6]);
            testCase.verifyFalse(any(testCase.Evidence.m16. ...
                stabilityTable.Stable(rows)));
            testCase.verifyGreaterThan(testCase.Evidence.m16. ...
                stabilityTable.MaxRealPole(rows), zeros(2, 1));
        end

        function testT24FinalRolesPreserved(testCase)
            roles = testCase.Evidence.m17.finalRoleAssignment;
            testCase.verifyEqual(roles.Controller(roles.Role == ...
                "FINAL ROBUST CONTROLLER"), "Kmu");
            testCase.verifyEqual(roles.Controller(roles.Role == ...
                "NOMINAL PERFORMANCE REFERENCE"), "M6");
        end

        function testT25UScaleSemanticsPreserved(testCase)
            testCase.verifyEqual(testCase.Evidence.m5.spec.uScale, 12);
            testCase.verifyTrue(contains(testCase.M18.metadata. ...
                uScaleInterpretation, "NOT_CERTIFIED_SATURATION"));
        end

        function testT26MonteCarloNotCertification(testCase)
            reportText = string(fileread(fullfile(testCase.Root, 'report', ...
                'sections', '11_monte_carlo.tex')));
            testCase.verifyTrue(contains(testCase.M18.metadata. ...
                monteCarloInterpretation, "NOT_A_ROBUSTNESS_CERTIFICATE"));
            reportText = lower(reportText);
            testCase.verifyTrue(contains(reportText, ...
                "non può dimostrare") && contains(reportText, ...
                "la sola certificazione"));
        end

        function testT27EmpiricalRasDistinctFromLyapunov(testCase)
            testCase.verifyFalse(any(testCase.Evidence.m17. ...
                rasComparison.AnalyticallyCertified));
            testCase.verifyTrue(contains(testCase.M18.metadata. ...
                rasInterpretation, "ANALYTIC_NOMINAL_INNER_BOUND"));
        end

        function testT28A5NotKhinf(testCase)
            testCase.verifyFalse(testCase.Evidence.m17. ...
                historicalA5Comparison.IsM17PrimaryCandidate);
            row = testCase.Evidence.m11.representativeTable.ArchitectureID == ...
                "A5";
            testCase.verifyNotEqual(testCase.Evidence.m11. ...
                representativeTable.Order(row), ...
                order(testCase.Evidence.m10.Khinf));
        end

        function testT29NumericMacrosProduced(testCase)
            macroText = string(fileread(testCase.M18.macroPath));
            testCase.verifyEqual(height(testCase.M18.numericAudit), 78);
            testCase.verifyEqual(count(macroText, "\newcommand{"), 78);
        end

        function testT30TablesProduced(testCase)
            testCase.verifyEqual(numel(testCase.M18.tablePaths), 19);
            testCase.verifyTrue(all(isfile(testCase.M18.tablePaths)));
        end

        function testT31FigureManifestProduced(testCase)
            testCase.verifyEqual(height(testCase.M18.figureManifest), 31);
            testCase.verifyTrue(isfile(fullfile(testCase.Root, 'report', ...
                'generated', 'figure_manifest.csv')));
        end

        function testT32ReportFiguresProduced(testCase)
            paths = fullfile(testCase.Root, ...
                testCase.M18.figureManifest.ReportPath);
            testCase.verifyTrue(all(isfile(paths)));
        end

        function testT33EveryValueSourceMapped(testCase)
            a = testCase.M18.numericAudit;
            testCase.verifyTrue(all(strlength(a.SourceMilestone) > 0 & ...
                strlength(a.SourceArtifact) > 0 & ...
                strlength(a.SourceField) > 0 & ...
                strlength(a.ReportMacro_Table) > 0));
        end

        function testT34ReportIsModular(testCase)
            source = string(fileread(fullfile(testCase.Root, 'report', ...
                'main.tex')));
            testCase.verifyEqual(count(source, "\input{sections/"), 16);
        end

        function testT35ReportHasAbstract(testCase)
            source = string(fileread(fullfile(testCase.Root, 'report', ...
                'main.tex')));
            testCase.verifyTrue(contains(source, "\begin{abstract}") && ...
                contains(source, "\end{abstract}"));
        end

        function testT36ReportHasConclusions(testCase)
            source = string(fileread(fullfile(testCase.Root, 'report', ...
                'sections', '13_conclusioni_limiti.tex')));
            testCase.verifyTrue(contains(source, "Conclusioni") && ...
                contains(source, "K_\mu"));
        end

        function testT37ReportHasLimitations(testCase)
            source = string(fileread(fullfile(testCase.Root, 'report', ...
                'tables', 'limitations.tex')));
            testCase.verifyTrue(contains(source, ...
                "Nessun controllore principale") && ...
                contains(source, "saturazione"));
        end

        function testT38TraceabilityDocumentsProduced(testCase)
            trace = string(fileread(fullfile(testCase.Root, 'docs', ...
                'M18_REQUIREMENTS_TRACEABILITY.md')));
            testCase.verifyTrue(contains(trace, "M18") && ...
                contains(trace, "FAIL") && contains(trace, "NOT RUN"));
            testCase.verifyTrue(isfile(fullfile(testCase.Root, 'docs', ...
                'FINAL_EDITORIAL_AUDIT.md')));
        end

        function testT39PresentationSourceProduced(testCase)
            source = string(fileread(fullfile(testCase.Root, 'presentation', ...
                'main.tex')));
            testCase.verifyEqual(count(source, "\begin{frame}"), 19);
            testCase.verifyTrue(contains(source, "Alessio de Dato") && ...
                contains(source, "Valerio Rebechi") && ...
                contains(source, "M14 certifica RS"));
        end

        function testT40PresentationTimingProduced(testCase)
            timing = string(fileread(fullfile(testCase.Root, 'presentation', ...
                'OUTLINE_AND_TIMING.md')));
            testCase.verifyTrue(contains(timing, "19:00") && ...
                contains(timing, "20 minuti"));
        end

        function testT41SpeakerNotesProduced(testCase)
            notes = string(fileread(fullfile(testCase.Root, 'presentation', ...
                'SPEAKER_NOTES.md')));
            testCase.verifyEqual(count(notes, "## Slide "), 19);
            testCase.verifyTrue(contains(notes, "Domande probabili"));
        end

        function testT42ReportCompilationAuditPass(testCase)
            audit = string(fileread(fullfile(testCase.Root, 'report', ...
                'generated', 'report_latex_audit.txt')));
            testCase.verifyTrue(contains(audit, "STATUS=PASS"));
        end

        function testT43ReportPdfProduced(testCase)
            testCase.verifyTrue(isfile(fullfile(testCase.Root, 'report', ...
                'Progetto_CR_Relazione_finale.pdf')));
        end

        function testT44ReportHasNoLayoutOrReferenceErrors(testCase)
            audit = string(fileread(fullfile(testCase.Root, 'report', ...
                'generated', 'report_latex_audit.txt')));
            testCase.verifyTrue(localCleanLatexAudit(audit));
        end

        function testT45PresentationCompilationAuditPass(testCase)
            audit = string(fileread(fullfile(testCase.Root, 'presentation', ...
                'generated', 'presentation_latex_audit.txt')));
            testCase.verifyTrue(contains(audit, "STATUS=PASS"));
        end

        function testT46PresentationPdfProduced(testCase)
            testCase.verifyTrue(isfile(fullfile(testCase.Root, 'presentation', ...
                'Progetto_CR_Presentazione.pdf')));
        end

        function testT47PresentationWithinTwentyMinutes(testCase)
            timing = string(fileread(fullfile(testCase.Root, 'presentation', ...
                'OUTLINE_AND_TIMING.md')));
            testCase.verifyLessThanOrEqual(localTimingMinutes(timing), 20);
        end

        function testT48FinalManifestProduced(testCase)
            manifest = string(fileread(fullfile(testCase.Root, 'docs', ...
                'FINAL_DELIVERABLE_MANIFEST.md')));
            testCase.verifyTrue(contains(manifest, "19:00") && ...
                contains(manifest, "m18_final_deliverable_audit.mat"));
        end

        function testT49ReadmeUpdated(testCase)
            readme = string(fileread(fullfile(testCase.Root, 'README.md')));
            testCase.verifyTrue(contains(readme, "M18") && ...
                contains(readme, "Alessio de Dato") && ...
                contains(readme, "Valerio Rebechi") && ...
                contains(readme, "Progetto_CR_Relazione_finale.pdf"));
            forbidden = ["chatgpt", "codex", "prompt", "handoff"];
            testCase.verifyFalse(any(contains(lower(readme), forbidden)));
        end

        function testT50ProjectStatusUpdated(testCase)
            status = string(fileread(fullfile(testCase.Root, 'docs', ...
                'PROJECT_STATUS.md')));
            testCase.verifyTrue(contains(status, ...
                "revisione LQRI") && ...
                contains(status, "unico insieme incerto M4") && ...
                contains(status, "[1.069561,1.212875]") && ...
                contains(status, "Monte Carlo") && ...
                contains(status, "non sostituisce"));
        end

        function testT51ChecklistPreservesFalsePasses(testCase)
            checklist = string(fileread(fullfile(testCase.Root, 'docs', ...
                'REQUIREMENTS_CHECKLIST.md')));
            testCase.verifyTrue(contains(checklist, ...
                "- [x] Relazione dettagliata") && contains(checklist, "- [ ]"));
        end

        function testT52ChangelogUpdated(testCase)
            changelog = string(fileread(fullfile(testCase.Root, 'CHANGELOG.md')));
            testCase.verifyTrue(contains(changelog, "Pipeline M18") && ...
                contains(changelog, "T01–T60"));
        end

        function testT53DiaryUpdated(testCase)
            diary = string(fileread(fullfile(testCase.Root, 'docs', ...
                'DIARIO_DI_BORDO.md')));
            testCase.verifyTrue(contains(diary, ...
                "Revisione editoriale finale"));
        end

        function testT54NoTrackedLatexTemporaryFiles(testCase)
            testCase.verifyEmpty(localTrackedLatexTemps(testCase.Root));
        end

        function testT55RunAllIncludesM18(testCase)
            source = string(fileread(fullfile(testCase.Root, 'run_all.m')));
            testCase.verifyTrue(contains(source, ...
                "validate_m18_deliverables(true, true)") && ...
                contains(source, "validazioni M0-M18"));
        end

        function testT56CompleteSuiteConfigured(testCase)
            source = string(fileread(fullfile(testCase.Root, 'run_all.m')));
            suite = string(fileread(fullfile(testCase.Root, 'tests', ...
                'test_m18_final_deliverables.m')));
            testCase.verifyTrue(contains(source, ...
                "runtests(fullfile(projectRoot, 'tests'))"));
            methods = regexp(suite, ...
                '(?m)^\s*function testT\d\d', 'match');
            testCase.verifyEqual(numel(methods), 60);
        end

        function testT57CodeAnalyzerClean(testCase)
            testCase.verifyEmpty(localM18CodeAnalyzerMessages(testCase.Root));
        end

        function testT58GitDiffCheck(testCase)
            [status, output] = localGit(testCase.Root, "diff --check");
            testCase.verifyEqual(status, 0, output);
        end

        function testT59TreeCoherent(testCase)
            [status, branch] = localGit(testCase.Root, "branch --show-current");
            testCase.verifyEqual(status, 0);
            branch = strtrim(string(branch));
            testCase.verifyTrue(branch == "main" || startsWith(branch, "codex/"));
            testCase.verifyFalse(contains(testCase.Source, "<<<<<<<"));
            testCase.verifyFalse(isfile(fullfile(testCase.Root, ...
                'Resosconto_per_GPT.txt')));
            testCase.verifyFalse(isfolder(fullfile(testCase.Root, 'docs', ...
                'handoff')));
        end

        function testT60M18Complete(testCase)
            testCase.verifyEqual(testCase.M18.qualityGate.overallStatus, ...
                "COMPLETE");
            testCase.verifyEqual(testCase.M18.qualityGate.fullRegression, ...
                "NOT RUN");
            testCase.verifyEqual(testCase.M18.metadata.overallStatus, ...
                "COMPLETE");
        end
    end
end

function source = localM18Source(root)
files = dir(fullfile(root, 'analysis', 'finalization', '*.m'));
paths = string(fullfile({files.folder}, {files.name}));
paths(end + 1) = fullfile(root, 'src', 'parameters', ...
    'finalization_specs_m18.m');
source = join(arrayfun(@(path) string(fileread(path)), paths), newline);
end

function passed = localCleanLatexAudit(audit)
required = ["ERRORS=0", "UNRESOLVED_REFERENCES=0", ...
    "OVERFULL_HBOX=0", "OVERFULL_VBOX=0", ...
    "DUPLICATE_DESTINATIONS=0"];
passed = all(contains(audit, required));
end

function minutes = localTimingMinutes(timing)
token = regexp(timing, '\*\*(\d+):(\d+)\*\*', 'tokens', 'once');
minutes = str2double(token{1}) + str2double(token{2}) / 60;
end

function files = localTrackedLatexTemps(root)
[status, output] = localGit(root, "ls-files");
assert(status == 0, "M18:GitLsFiles", "%s", output);
paths = string(splitlines(strtrim(output)));
extensions = [".aux", ".log", ".out", ".toc", ".fls", ...
    ".fdb_latexmk", ".nav", ".snm", ".vrb", ".lof", ".lot", ".xdv"];
files = paths(endsWith(paths, extensions));
end

function messages = localM18CodeAnalyzerMessages(root)
files = [string(fullfile(root, 'src', 'parameters', ...
    'finalization_specs_m18.m')); ...
    string(fullfile(root, 'analysis', 'finalization', ...
    'load_m18_validated_artifacts.m')); ...
    string(fullfile(root, 'analysis', 'finalization', ...
    'build_m18_report_values.m')); ...
    string(fullfile(root, 'analysis', 'finalization', ...
    'build_m18_report_tables.m')); ...
    string(fullfile(root, 'analysis', 'finalization', ...
    'build_m18_figure_manifest.m')); ...
    string(fullfile(root, 'analysis', 'finalization', ...
    'build_m18_presentation_assets.m')); ...
    string(fullfile(root, 'analysis', 'finalization', ...
    'validate_m18_traceability.m')); ...
    string(fullfile(root, 'analysis', 'finalization', ...
    'validate_m18_deliverables.m')); ...
    string(fullfile(root, 'tests', 'test_m18_final_deliverables.m')); ...
    string(fullfile(root, 'run_all.m'))];
messageCells = arrayfun(@(path) checkcode(path, '-id'), files, ...
    'UniformOutput', false);
messages = vertcat(messageCells{:});
end

function [status, output] = localGit(root, arguments)
original = pwd;
cleanup = onCleanup(@() cd(original));
cd(root);
[status, output] = system("git " + arguments);
end
