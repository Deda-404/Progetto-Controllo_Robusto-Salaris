"""Controllo tecnico dei PDF e tavole di ispezione private; nessun dato inventato."""
from pathlib import Path
import json
import re
import subprocess
import tempfile
from pypdf import PdfReader
from PIL import Image, ImageDraw

root=Path(__file__).resolve().parents[1]
pkg=root/'Progetto_SEA_Consegna'
private=Path(tempfile.gettempdir())/'sea_s1_pdf_review'
private.mkdir(exist_ok=True)
records=[]
for kind,folder,job in [('report','relazione','Relazione_SEA'),('slide','presentazione','Presentazione_SEA')]:
    path=pkg/'documenti'/folder/(job+'.pdf')
    log=path.with_suffix('.log').read_text(encoding='utf-8',errors='replace')
    reader=PdfReader(path)
    text='\n'.join(p.extract_text() or '' for p in reader.pages)
    record={'artifact':str(path.relative_to(root)),'pages':len(reader.pages),
        'overfull_hbox':len(re.findall(r'Overfull \\hbox',log)),
        'overfull_vbox':len(re.findall(r'Overfull \\vbox',log)),
        'unresolved':len(re.findall(r'\?\?',text)),
        'latex_errors':len(re.findall(r'LaTeX Error|Undefined control sequence|There were undefined references',log)),
        'duplicate_destinations':len(re.findall('destination with the same identifier',log))}
    record['technical_pass']=not any(record[k] for k in ['overfull_hbox','overfull_vbox','unresolved','latex_errors','duplicate_destinations'])
    records.append(record)
    subprocess.run(['pdftoppm','-scale-to','1100','-png',str(path),str(private/kind)],check=True,capture_output=True)
    images=sorted(private.glob(kind+'-*.png'))
    page_size=(550,335) if kind=='slide' else (310,465)
    columns=2 if kind=='slide' else 4
    per_sheet=6 if kind=='slide' else 12
    for start in range(0,len(images),per_sheet):
        selected=images[start:start+per_sheet]
        sheet=Image.new('RGB',(columns*page_size[0],((len(selected)+columns-1)//columns)*(page_size[1]+22)),(220,220,220))
        draw=ImageDraw.Draw(sheet)
        for i,item in enumerate(selected):
            pic=Image.open(item).convert('RGB');pic.thumbnail(page_size)
            x=(i%columns)*page_size[0];y=(i//columns)*(page_size[1]+22)
            sheet.paste(pic,(x+(page_size[0]-pic.width)//2,y))
            draw.text((x+8,y+page_size[1]),f'{kind} {start+i+1}',fill='black')
        sheet.save(private/f'{kind}_contact_{start//per_sheet+1}.jpg')
out=root/'docs/audit_ristrutturazione/pdf_S1.json'
out.write_text(json.dumps(records,indent=2)+'\n',encoding='utf-8')
print(json.dumps(records))
assert all(x['technical_pass'] for x in records)
