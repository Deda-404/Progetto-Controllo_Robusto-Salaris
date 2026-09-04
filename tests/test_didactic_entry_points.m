function tests = test_didactic_entry_points
%TEST_DIDACTIC_ENTRY_POINTS Structure of the three exam-oriented scripts.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
testCase.TestData.root = fileparts(fileparts(mfilename('fullpath')));
end

function testThreeSeparateScriptsExist(testCase)
analysisDirectory = fullfile(testCase.TestData.root, 'analysis');
verifyTrue(testCase, isfile(fullfile(analysisDirectory, ...
    'modellazione_linearizzazione_controllo.m')));
verifyTrue(testCase, isfile(fullfile(analysisDirectory, 'progetto_lqg.m')));
verifyTrue(testCase, isfile(fullfile(analysisDirectory, 'progetto_hinf.m')));
verifyFalse(testCase, isfile(fullfile(analysisDirectory, ...
    'progetto_lqg_hinf.m')));
end

function testM0M5ScriptCoversDeclaredTopics(testCase)
source = localSource(testCase, 'modellazione_linearizzazione_controllo.m');
required = ["Punto di equilibrio"; "Linearizzazione analitica"; ...
    "Incertezze parametriche"; "Incertezza dinamica"; ...
    "Specifiche di progetto"; "Pesi sulla sensibilita"];
verifyTrue(testCase, all(contains(source, required)));
end

function testLqgScriptContainsSearchKalmanNonlinearAndRas(testCase)
source = localSource(testCase, 'progetto_lqg.m');
required = ["Ricerca parametrica"; "covarianze Kalman"; ...
    "principio di separazione"; "Validazione non lineare M8"; ...
    "RAS empirica del controllore LQG"];
verifyTrue(testCase, all(contains(source, required)));
verifyFalse(testCase, contains(source, 'validate_m10_hinfsyn'));
end

function testHinfScriptContainsWeightsPlantMuAndRas(testCase)
source = localSource(testCase, 'progetto_hinf.m');
required = ["Pesi W1 e W2"; "generalized plant"; "hinfsyn"; ...
    "analisi mu"; "RAS empirica del controllore H-infinity"];
verifyTrue(testCase, all(contains(source, required)));
verifyFalse(testCase, contains(source, 'design_lqr_m6'));
end

function testCommonRasComparisonIsSingleSource(testCase)
source = fileread(fullfile(testCase.TestData.root, 'analysis', 'ras', ...
    'build_common_ras_comparison.m'));
verifyTrue(testCase, contains(source, 'commonRasFields'));
verifyTrue(testCase, contains(source, 'certifiedRegion', ...
    'IgnoreCase', true));
verifyTrue(testCase, contains(source, 'EmpiricalFraction'));
end

function source = localSource(testCase, fileName)
source = string(fileread(fullfile(testCase.TestData.root, ...
    'analysis', fileName)));
end
