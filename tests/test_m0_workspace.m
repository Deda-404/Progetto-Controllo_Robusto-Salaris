function tests = test_m0_workspace
%TEST_M0_WORKSPACE Verify the repository skeleton created in M0.
tests = functiontests(localfunctions);
end

function testRequiredFiles(testCase)
projectRoot = fileparts(fileparts(mfilename('fullpath')));
requiredFiles = {
    'README.md'
    'AGENTS.md'
    'CHANGELOG.md'
    '.gitignore'
    'run_all.m'
    fullfile('docs', 'ANALISI_TRACCIA.md')
    fullfile('docs', 'ANALISI_PROGETTO_RIFERIMENTO.md')
    fullfile('docs', 'INVENTARIO_DRIVE.md')
    fullfile('docs', 'REQUIREMENTS_CHECKLIST.md')
    fullfile('docs', 'ROADMAP.md')
    fullfile('docs', 'DECISION_LOG.md')
    fullfile('docs', 'DIARIO_DI_BORDO.md')
    fullfile('docs', 'PROJECT_STATUS.md')
    fullfile('report', 'main.tex')
    };

for index = 1:numel(requiredFiles)
    verifyTrue(testCase, isfile(fullfile(projectRoot, requiredFiles{index})), ...
        sprintf('File richiesto assente: %s', requiredFiles{index}));
end
end

function testRequiredFolders(testCase)
projectRoot = fileparts(fileparts(mfilename('fullpath')));
requiredFolders = {
    fullfile('src', 'parameters')
    fullfile('src', 'model')
    fullfile('src', 'actuators')
    fullfile('src', 'uncertainty')
    fullfile('controllers', 'lqg')
    fullfile('controllers', 'hinf')
    fullfile('controllers', 'mu')
    fullfile('analysis', 'nominal')
    fullfile('analysis', 'ras')
    fullfile('analysis', 'robustness')
    fullfile('analysis', 'monte_carlo')
    fullfile('analysis', 'comparison')
    'simulink'
    'tests'
    fullfile('results', 'data')
    fullfile('results', 'figures')
    fullfile('results', 'controllers')
    fullfile('report', 'sections')
    fullfile('report', 'figures')
    fullfile('report', 'tables')
    };

for index = 1:numel(requiredFolders)
    verifyTrue(testCase, isfolder(fullfile(projectRoot, requiredFolders{index})), ...
        sprintf('Cartella richiesta assente: %s', requiredFolders{index}));
end
end
