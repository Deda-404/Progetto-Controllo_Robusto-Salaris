"""Conta il solo parlato e coordina slide, interventi e note."""
from pathlib import Path
import re, json, math

ROOT=Path(__file__).resolve().parents[1]
SPEED=125  # parole al minuto; ipotesi di esposizione tecnica chiara
CHANGE=2   # secondi riservati a ogni cambio slide

def main():
    path=ROOT/'presentation/Presentazione_orale.txt'
    if not path.exists():path=ROOT/'preparazione_studenti/Presentazione_orale.txt'
    raw=path.read_text(encoding='utf-8')
    official=raw.split('APPENDICE — POSSIBILI DOMANDE E RISPOSTE')[0]
    pattern=r'SLIDE (\d+) — ([^\n]+)\nStudente: (Alessio|Valerio)\nTempo previsto: [^\n]+\nTesto da pronunciare:\n(.*?)\nRegia: ([^\n]+)'
    records=[]
    for match in re.finditer(pattern,official,re.S):
        number,title,speaker,speech,cue=match.groups()
        words=len(re.findall(r"\b[\w]+(?:['’][\w]+)*\b",speech))
        seconds=math.ceil(60*words/SPEED)
        label=f'{seconds//60}:{seconds%60:02d}'
        old=match.group(0);new=re.sub(r'Tempo previsto: [^\n]+',f'Tempo previsto: {label} ({words} parole a {SPEED} parole/min)',old)
        raw=raw.replace(old,new)
        records.append(dict(slide=int(number),title=title,speaker=speaker,words=words,seconds=seconds,cue=cue))
    assert [r['slide'] for r in records]==list(range(1,24))
    source=(ROOT/'presentation/main.tex').read_text(encoding='utf-8-sig')
    assert source.count(r'\begin{frame}')==len(records)
    total=sum(r['seconds'] for r in records)+(len(records)-1)*CHANGE
    words=sum(r['words'] for r in records)
    assert 18*60<=total<=19*60,(words,total)
    totals={name:sum(r['seconds'] for r in records if r['speaker']==name) for name in ['Alessio','Valerio']}
    assert abs(totals['Alessio']-totals['Valerio'])<90,totals
    assert 'DA_CALCOLARE' not in raw
    path.write_text(raw,encoding='utf-8')
    timing=['# Scaletta e tempi','',f"23 slide; **{words} parole** di parlato a **{SPEED} parole/minuto**.",
        f"Tempo di parlato {sum(r['seconds'] for r in records)//60}:{sum(r['seconds'] for r in records)%60:02d}; "
        f"22 cambi da {CHANGE} s portano la stima a **{total//60}:{total%60:02d}**. "
        f"Margine rispetto a 20 minuti: **{(1200-total)//60}:{(1200-total)%60:02d}**.",
        'Si tratta di una stima basata sul testo; la durata effettiva richiede una prova orale cronometrata.',
        '',f"Alessio: {totals['Alessio']//60}:{totals['Alessio']%60:02d}; Valerio: {totals['Valerio']//60}:{totals['Valerio']%60:02d}. "
        'Gli interventi alternano blocchi di circa tre slide. Titoli, regia e appendice non sono conteggiati.',
        '', '| Slide | Titolo | Studente | Parole | Parlato |','|---|---|---|---:|---:|']
    timing += [f"| {r['slide']} | {r['title']} | {r['speaker']} | {r['words']} | {r['seconds']//60}:{r['seconds']%60:02d} |" for r in records]
    timing += ['', 'Le slide 2–18 trattano la prima formulazione. La 19 distingue i nuovi candidati, '
        'con compromessi e baseline predefinita. Le figure della RAS e dei dieci impianti restano identificate '
        'come baseline; i risultati dei candidati sono separati nella relazione.',
        '', 'Gli schemi LQGI lineare/non lineare usano la stessa famiglia di controllo. '
        'Le viste autentiche rendono leggibili il cambio della pianta, l’osservatore e l’integratore.']
    (ROOT/'presentation/OUTLINE_AND_TIMING.md').write_text('\n'.join(timing)+'\n',encoding='utf-8')
    notes=['# Note per l’esposizione','', 'Il discorso completo e le risposte di preparazione sono in `Presentazione_orale.txt`. '
        'Il conteggio del parlato e l’equilibrio fra studenti sono in `OUTLINE_AND_TIMING.md`.', '',
        'Attenzione ai protocolli: i numeri della slide 18 sono MATLAB isolato, '
        'quelli della slide 19 sono Scope Simulink combinato. RMS integrato medio fra canali '
        'e massimo RMS per canale non sono la stessa statistica.', '',
        'La slide 19 usa candidati verificati separatamente: HinfN3 non supera RS; '
        'MuN1 supera RS/RP ma non tutti i target temporali. Nessuna certificazione hardware.']
    for r in records:
        notes += ['',f"## {r['slide']}. {r['title']} — {r['speaker']}, {r['seconds']//60}:{r['seconds']%60:02d}",'',r['cue']]
    (ROOT/'presentation/SPEAKER_NOTES.md').write_text('\n'.join(notes)+'\n',encoding='utf-8')
    evidence={'words':words,'speed_words_per_minute':SPEED,'transition_seconds':CHANGE,
        'spoken_seconds':sum(r['seconds'] for r in records),'total_seconds':total,'speaker_seconds':totals,
        'records':records,'status':'PASS: estimate only; live rehearsal still required'}
    (ROOT/'results/data/noise_redesign/oral_timing.json').write_text(json.dumps(evidence,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(words,total,totals)

if __name__=='__main__':main()
