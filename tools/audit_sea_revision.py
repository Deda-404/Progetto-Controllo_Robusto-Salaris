"""Verify immutable binary archives and preserved historical sources against the approved base."""
import hashlib
import json
import re
import subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
BASE='0ed5611fdbb9c46475543f87eba68d9799b07bc5'
def git(*args):
    return subprocess.check_output(['git','-C',str(ROOT),*args])
def source(p):
    return git('show',f'{BASE}:{p}').decode('utf-8').replace('\r\n','\n')
files=git('ls-tree','-r','-z',BASE).split(b'\0')
records=[]
for item in files:
    if not item: continue
    meta,p=item.split(b'\t',1); name=p.decode('utf-8'); oid=meta.split()[2].decode()
    if Path(name).suffix.lower() not in {'.mat','.slx','.pdf'}: continue
    local=ROOT/name; size=local.stat().st_size
    sha=hashlib.sha256(); blob=hashlib.sha1(f'blob {size}\0'.encode())
    with local.open('rb') as f:
        for chunk in iter(lambda:f.read(1024*1024),b''): sha.update(chunk);blob.update(chunk)
    expected=oid; actual=blob.hexdigest();kind='git-blob'
    if int(git('cat-file','-s',oid))<200:
        obj=git('cat-file','blob',oid)
        if obj.startswith(b'version https://git-lfs.github.com/spec/v1'):
            expected=re.search(rb'oid sha256:([a-f0-9]+)',obj)[1].decode();actual=sha.hexdigest();kind='lfs-sha256'
    records.append(dict(path=name,sha256=sha.hexdigest(),method=kind,unchanged=actual==expected))
assert all(r['unchanged'] for r in records),'A protected archive differs from the approved base.'
p='File_di_Funzioni_Progetto-Accorpati/progetto_mu.m'
s=(ROOT/p).read_text(encoding='utf-8')
s=re.sub(r'^confrontaIncertezze=.*\n|^analizzaConfrontoIncertezze=.*\n','',s,flags=re.M)
s=re.sub(r'%% 15 - Confronto conservativo.*?(?=%% Funzioni locali)', '',s,flags=re.S)
s=s[:s.index('\nfunction r=confrontoIncertezzeSEA')].rstrip()+'\n'
assert s==source(p).rstrip()+'\n','Historical execution code changed.'
p='analysis/uncertainty/fit_actuator_uncertainty_weight.m'
s=(ROOT/p).read_text(encoding='utf-8');old=source(p)
assert s[s.index('chosenOrder = 1;'):s.index('\nfunction f = localAnalyticWeights')].strip()==old[old.index('chosenOrder = 1;'):].strip()
headings=[]
for name in ['05_incertezze','09_mu','12_confronto_finale']:
    p=f'report/sections/{name}.tex';before=source(p);after=(ROOT/p).read_text(encoding='utf-8')
    pattern=r'^\\(?:chapter|section|subsection|subsubsection).*'
    assert re.findall(pattern,before,re.M)==re.findall(pattern,after,re.M),name
    assert re.findall(r'\\(?:caption|label)\{[^}]*\}',before)==re.findall(r'\\(?:caption|label)\{[^}]*\}',after),name
    headings.append(name)
assert (ROOT/'report/main.tex').read_text(encoding='utf-8')==source('report/main.tex')
out=dict(base=BASE,archive_count=len(records),all_archives_unchanged=True,historical_execution_source_unchanged=True,
         historical_weight_body_unchanged=True,report_main_unchanged=True,report_headings_and_existing_captions_unchanged=headings,archives=records)
(ROOT/'results/data/sea_incertezze_conservativa/integrity.json').write_text(json.dumps(out,indent=2)+'\n',encoding='utf-8')
print(f'PASS: {len(records)} MAT/SLX/PDF archives; original script body, weight body, report main, headings and captions unchanged.')
