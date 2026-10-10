"""Confronta i due script didattici con la versione precedente in Git.

Richiede Python standard, Git, MATLAB, Control System e Robust Control Toolbox.
I sorgenti e i risultati temporanei restano sotto tmp/refactor_didactic/.
"""
import argparse
import json
from pathlib import Path
import shutil
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--baseline', default='6133365', help='Commit prima del refactoring')
    parser.add_argument('--matlab', default='matlab', help='Comando o percorso MATLAB')
    parser.add_argument('--fresh', action='store_true', help='Confronta anche le nuove sintesi')
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    commit = subprocess.check_output(
        ['git', 'rev-parse', '--verify', args.baseline+'^{commit}'], cwd=root, text=True).strip()
    folder = root/'tmp/refactor_didactic'
    before = folder/'before'
    before.mkdir(parents=True, exist_ok=True)
    files = ['progetto_hinf_tre_controllori.m', 'progetto_mu.m']
    for name in files:
        data = subprocess.check_output(
            ['git', 'show', f'{commit}:File_di_Funzioni_Progetto-Accorpati/{name}'], cwd=root)
        (before/name).write_bytes(data)
    matlab = shutil.which(args.matlab)
    if not matlab:
        raise SystemExit('MATLAB non trovato: specificare --matlab. Test NON VALIDATI.')
    test_path = str(root/'tests/didactic_refactor').replace('\\', '/').replace("'", "''")
    flag = 'true' if args.fresh else 'false'
    code = f"addpath('{test_path}'); prepare_baseline; verify_hinf({flag}); verify_mu({flag}); verify_final"
    subprocess.run([matlab, '-batch', code, '-logfile', str(folder/'regression_console.txt')],
                   cwd=root, check=True)
    report_path = folder/'numerical_report.json'
    report = json.loads(report_path.read_text(encoding='utf-8'))
    report['baselineCommit'] = commit
    report['freshSynthesisTested'] = args.fresh
    report_path.write_text(json.dumps(report, indent=2, ensure_ascii=False)+'\n', encoding='utf-8')
    print(f"PASS: {report_path}")


if __name__ == '__main__':
    main()
