"""Audit scope against the frozen Git baseline and the compiled report."""
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE = 'cb325f6'
ALLOWED = {
    'README.md', 'CHANGELOG.md', 'docs/DIARIO_DI_BORDO.md',
    'docs/DECISION_LOG.md', 'docs/PROJECT_STATUS.md',
    'report/sections/08_hinf.tex', 'report/Progetto_CR_Relazione_finale.pdf',
}


def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT)


def main():
    changed = git('diff', BASE, '--name-only', '--diff-filter=MDR').decode().splitlines()
    assert set(changed) <= ALLOWED, f'Frozen files changed: {set(changed) - ALLOWED}'
    archived = ROOT / 'report/archive/hinf_before_retuning/08_hinf.tex'
    old = git('show', f'{BASE}:report/sections/08_hinf.tex')
    assert archived.read_bytes().replace(b'\r\n', b'\n') == old.replace(b'\r\n', b'\n')
    frozen = {}
    for name in git('ls-tree', '-r', '--name-only', BASE).decode().splitlines():
        path = ROOT / name
        if name not in ALLOWED and path.suffix in ('.m', '.mat', '.csv', '.tex'):
            frozen[name] = hashlib.sha256(path.read_bytes()).hexdigest()
    log = (ROOT / 'report/Progetto_CR_Relazione_finale.log').read_text(errors='replace')
    patterns = ['LaTeX Error:', 'Undefined control sequence', 'undefined references',
                'Overfull', 'destination with the same identifier']
    errors = {pattern: len(re.findall(re.escape(pattern), log)) for pattern in patterns}
    assert not any(errors.values()), errors
    count = re.search(r'Output written on .*?\((\d+) pages', log, re.S)
    matlab = json.loads((ROOT / 'results/data/hinf_targeted_revision/matlab_verification.json').read_text())
    assert matlab['failed'] == 0 and matlab['incomplete'] == 0 and matlab['codeAnalyzerIssues'] == 0
    audit = {
        'status': 'PASS', 'baselineCommit': git('rev-parse', BASE).decode().strip(),
        'allowedExistingFilesChanged': changed,
        'frozenFilesVerifiedByGit': len(frozen), 'sha256': frozen,
        'baselineChapterArchived': True, 'latexChecks': errors,
        'reportPages': int(count.group(1)), 'matlabTestsPassed': matlab['passed'],
        'matlabTestsFailed': matlab['failed'], 'codeAnalyzerIssues': matlab['codeAnalyzerIssues'],
        'muAnalysis': 'NOT RUN', 'globalPipeline': 'NOT RUN',
        'initialDocumentIssues': 'Wrong generator working directory and one overfull line; corrected before final compilation.',
    }
    target = ROOT / 'results/data/hinf_targeted_revision/verification.json'
    target.write_text(json.dumps(audit, indent=2), encoding='utf-8')
    print(f"PASS: {len(frozen)} frozen files, Chapter 8 archived, {audit['reportPages']} PDF pages, no LaTeX errors/overfull.")


if __name__ == '__main__':
    main()
