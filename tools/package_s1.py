"""Pacchetto unico S1: solo sorgenti, dati, figure ed elaborati necessari."""
from pathlib import Path
import hashlib
import json
import tempfile
import zipfile

root=Path(__file__).resolve().parents[1]
pkg=root/'Progetto_SEA_Consegna'
allowed={'.m','.mat','.csv','.json','.png','.tex','.pdf','.md'}
files=[]
for p in sorted(pkg.rglob('*')):
    if p.is_file() and p.suffix in allowed and p.name!='main.pdf' and not any(x.startswith('.') for x in p.relative_to(pkg).parts):
        files.append(p)
assert len(list(pkg.glob('*.m')))==9
assert not list(pkg.rglob('*.slx'))
assert {p.name for p in files if p.suffix=='.pdf'}=={'Relazione_SEA.pdf','Presentazione_SEA.pdf'}
manifest=[{'path':str(p.relative_to(pkg)).replace('\\','/'),'bytes':p.stat().st_size,
           'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for p in files]
out=root/'delivery/Progetto_SEA_Consegna.zip'
with zipfile.ZipFile(out,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=6) as z:
    for p in files:
        z.write(p,str(Path(pkg.name)/p.relative_to(pkg)))
with zipfile.ZipFile(out) as z:
    assert z.testzip() is None
target=Path(tempfile.mkdtemp(prefix='SEA_S1_collaudo_'))
with zipfile.ZipFile(out) as z:
    assert all(not x.startswith(('/', '\\')) and '..' not in Path(x).parts for x in z.namelist())
    z.extractall(target)
extracted=target/pkg.name
assert all(hashlib.sha256((extracted/r['path']).read_bytes()).hexdigest()==r['sha256'] for r in manifest)
record={'file_count':len(files),'matlab_files':9,'mat_files':sum(p.suffix=='.mat' for p in files),
    'zip_bytes':out.stat().st_size,'zip_sha256':hashlib.sha256(out.read_bytes()).hexdigest(),
    'crc_pass':True,'extraction_hashes_pass':True,'isolated_directory':str(extracted),'files':manifest}
(root/'delivery/manifest_S1.json').write_text(json.dumps(record,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:v for k,v in record.items() if k!='files'}))
