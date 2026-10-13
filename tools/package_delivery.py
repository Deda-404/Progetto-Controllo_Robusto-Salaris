"""Copy the selected reproducible project, verify exact hashes and create a ZIP."""
from pathlib import Path
import hashlib,json,shutil,zipfile,sys
ROOT=Path(__file__).resolve().parents[1]
NAME='Consegna_SEA_2026-10-13'

def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    source=json.loads((ROOT/'delivery/manifest.json').read_text(encoding='utf-8'))
    folder=ROOT/'delivery'/NAME
    assert folder.resolve().is_relative_to((ROOT/'delivery').resolve())
    previous=[]
    if folder.exists():
        assert '--refresh' in sys.argv,f'Existing package: use --refresh after reviewing its manifest: {folder}'
        saved=json.loads((folder/'MANIFEST_CONSEGNA.json').read_text(encoding='utf-8'))
        assert saved['date']=='13.10.2026' and saved['release']=='R2026b'
        assert [a['matricola'] for a in saved['authors']]==['635256','722224']
        previous=saved['files']
        inventory={p.relative_to(folder).as_posix() for p in folder.rglob('*') if p.is_file()}
        assert inventory=={r['path'] for r in previous}|{'MANIFEST_CONSEGNA.json'},'Unlisted files: preserve this folder.'
        for record in previous:
            target=(folder/record['path']).resolve()
            assert target.is_relative_to(folder.resolve())
            assert digest(target)==record['sha256'],f"Modified file: preserve {record['path']}"
    else:
        folder.mkdir()
    excluded={'internal_group_review_only','focused_final_verification_source'}
    records=[]
    for record in source['files']:
        if excluded.intersection(record['roles']):continue
        relative=record['path']
        if relative in {'README.md','tools/build_delivery_manifest.py','tools/package_delivery.py',
                        'tools/collect_final_dependencies.m','tools/probe_final_environment.m',
                        'tools/verify_four_final_scripts.m','run_all.m',
                        'results/data/coherent_review/matlab_tests.csv',
                        'docs/CHECKLIST_CONSEGNA_STUDENTI.md'}:
            # Full regression/build inventory is available in the complete repository.
            # The probe and script verifier are required even when regression is false.
            if relative not in {'tools/probe_final_environment.m','tools/verify_four_final_scripts.m'}:continue
        src=ROOT/relative;dst=folder/relative
        assert dst.resolve().is_relative_to(folder.resolve())
        dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(src,dst)
        assert digest(dst)==digest(src),relative
        records.append({'path':relative,'size_bytes':dst.stat().st_size,'sha256':digest(dst)})
    shutil.copyfile(ROOT/'delivery/README.md',folder/'README.md')
    records.append({'path':'README.md','size_bytes':(folder/'README.md').stat().st_size,'sha256':digest(folder/'README.md')})
    retained={record['path'] for record in records}
    for record in previous:
        if record['path'] not in retained:
            target=(folder/record['path']).resolve()
            assert target.is_relative_to(folder.resolve()) and target.is_file()
            assert digest(target)==record['sha256']
            target.unlink()  # Remove only an unchanged file from this package's verified inventory.
    manifest={'authors':[{'name':'Alessio de Dato','matricola':'635256'},
                         {'name':'Valerio Rebechi','matricola':'722224'}],
              'date':'13.10.2026','release':'R2026b','hash_policy':'SHA-256 exact bytes',
              'files':sorted(records,key=lambda r:r['path'].lower())}
    (folder/'MANIFEST_CONSEGNA.json').write_text(json.dumps(manifest,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
    for record in records:assert digest(folder/record['path'])==record['sha256']
    originals=json.loads((ROOT/'simulink/student_originals_manifest.json').read_text(encoding='utf-8-sig'))
    for record in originals['models']:
        assert digest(folder/record['relative_path'])==record['sha256_source'],record['name']
    assert len(list((folder/'simulink/student_originals').glob('*.slx')))==8
    archive=ROOT/'delivery'/(NAME+'.zip')
    if archive.exists():
        assert '--refresh' in sys.argv,'Existing ZIP requires --refresh.'
        old_audit=json.loads((ROOT/'delivery/package_audit.json').read_text(encoding='utf-8'))
        assert archive.resolve()==Path(old_audit['zip']).resolve()
        assert digest(archive)==old_audit['zip_sha256'],'Modified ZIP: preserve it.'
    pending=archive.with_suffix('.zip.pending')
    assert not pending.exists(),f'Unfinished ZIP: preserve {pending}'
    with zipfile.ZipFile(pending,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=6) as z:
        for p in sorted(folder.rglob('*')):
            if p.is_file():z.write(p,Path(NAME)/p.relative_to(folder))
    with zipfile.ZipFile(pending) as z:
        assert z.testzip() is None
        for record in records:
            payload=z.read(NAME+'/'+record['path'])
            assert hashlib.sha256(payload).hexdigest()==record['sha256']
    pending.replace(archive)
    evidence={'folder':str(folder),'zip':str(archive),'file_count':len(records),
              'zip_size_bytes':archive.stat().st_size,'zip_sha256':digest(archive),
              'all_copied_and_zipped_hashes':'PASS','original_slx_count':8}
    (ROOT/'delivery/package_audit.json').write_text(json.dumps(evidence,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
    print(json.dumps(evidence,ensure_ascii=False))

if __name__=='__main__':main()
