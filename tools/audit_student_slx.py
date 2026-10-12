"""Read-only ZIP/XML audit of the eight student models; never rewrites an SLX."""
from pathlib import Path
import hashlib
import json
import re
import xml.etree.ElementTree as ET
import zipfile

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'results/data/final_closure'
OUT.mkdir(parents=True, exist_ok=True)

def params(element):
    found = {p.attrib.get('Name', ''): p.text or '' for p in element.findall('P')}
    instance = element.find('InstanceData')
    if instance is not None:
        found.update({p.attrib.get('Name', ''): p.text or '' for p in instance.findall('P')})
    return found

def audit(file):
    with zipfile.ZipFile(file) as package:
        assert package.testzip() is None
        defaults_tree = ET.fromstring(package.read('simulink/bddefaults.xml'))
        defaults = {b.attrib.get('BlockType'): params(b) for b in defaults_tree.iter('Block')}
        blocks, lines, scripts = [], [], []
        def walk(member, prefix):
            system = ET.fromstring(package.read(member))
            local = {b.attrib['SID']: prefix + '/' + b.attrib['Name'] for b in system.findall('Block')}
            for block in system.findall('Block'):
                item = {'path': local[block.attrib['SID']], 'sid': block.attrib['SID'],
                        'type': block.attrib['BlockType'], 'parameters': {**defaults.get(block.attrib['BlockType'], {}), **params(block)}}
                blocks.append(item)
                sub = block.find('System')
                if sub is not None and 'Ref' in sub.attrib:
                    walk('simulink/systems/' + sub.attrib['Ref'] + '.xml', item['path'])
            for line in system.findall('Line'):
                p = params(line)
                src = p.get('Src', '')
                for dst in [n.text for n in line.iter('P') if n.attrib.get('Name') == 'Dst']:
                    def endpoint(s):
                        sid = s.split('#')[0]
                        return local.get(sid, sid) + '#' + s.split('#')[-1]
                    lines.append({'source': endpoint(src), 'destination': endpoint(dst), 'name': p.get('Name', '')})
        walk('simulink/systems/system_root.xml', file.stem)
        diagram = ET.fromstring(package.read('simulink/blockdiagram.xml'))
        callbacks = {p.attrib['Name']: p.text or '' for p in diagram.iter('P') if p.attrib.get('Name', '').endswith('Fcn')}
        config = ET.fromstring(package.read('simulink/configSet0.xml'))
        settings = {p.attrib['Name']: p.text or '' for p in config.iter('P') if p.attrib.get('Name') in
                    ['Solver', 'SolverName', 'SolverType', 'FixedStep', 'MaxStep', 'RelTol', 'AbsTol', 'StartTime', 'StopTime', 'SaveOutput', 'SignalLogging']}
        for member in package.namelist():
            if member.startswith('simulink/stateflow/') and member.endswith('.xml'):
                tree = ET.fromstring(package.read(member))
                for node in tree.iter('P'):
                    if node.attrib.get('Name') == 'script':
                        scripts.append({'member': member, 'code': node.text or ''})
        image = package.read('metadata/thumbnail.png') if 'metadata/thumbnail.png' in package.namelist() else None
        if image:
            dest = ROOT / 'report/figures/student_originals' / (file.stem + '.png')
            dest.parent.mkdir(parents=True, exist_ok=True)
            dest.write_bytes(image)
        release = ET.fromstring(package.read('metadata/mwcorePropertiesReleaseInfo.xml'))
        version = {n.tag: n.text for n in release}
    return {'model': file.name, 'sha256': hashlib.sha256(file.read_bytes()).hexdigest(),
            'release': version, 'settings': settings, 'callbacks': callbacks,
            'blocks': blocks, 'connections': lines, 'embedded_functions': scripts,
            'thumbnail_source': 'metadata/thumbnail.png inside unchanged SLX' if image else None,
            'validation': 'STATIC XML ONLY; no simulation or compiled dimension validation'}

def main():
    results = [audit(p) for p in sorted((ROOT / 'simulink/student_originals').glob('*.slx'))]
    assert len(results) == 8
    (OUT / 'slx_static_audit.json').write_text(json.dumps(results, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
    text = ['# Inventario XML degli otto SLX', '',
            'Controllo statico ZIP/XML del 12 ottobre 2026. Nessun SLX alterato. Le miniature sono contenute negli originali; non rappresentano una nuova esportazione o una simulazione.', '']
    interesting = {'StateSpace', 'TransferFcn', 'RandomNumber', 'Sum', 'Gain', 'Mux', 'Demux', 'Step', 'Integrator', 'Constant', 'Inport', 'Outport'}
    skip = {'Position', 'ZOrder', 'BackgroundColor', 'ForegroundColor', 'ShowName', 'NamePlacement'}
    for result in results:
        text += ['## ' + result['model'], '', 'Release: ' + str(result['release']), '',
                 'SHA-256: `' + result['sha256'] + '`', '', 'Configurazione: `' + str(result['settings']) + '`', '', '### Blocchi e parametri', '']
        for block in result['blocks']:
            if block['type'] in interesting:
                useful = {k: v for k, v in block['parameters'].items() if k not in skip}
                text.append('- `' + block['path'] + '` (' + block['type'] + '): `' + str(useful) + '`')
        text += ['', '### Connessioni', '']
        text += ['- `' + l['source'] + '` → `' + l['destination'] + '`' for l in result['connections']]
        for name, code in result['callbacks'].items():
            text += ['', '### Callback ' + name, '', '```matlab', code, '```']
        for script in result['embedded_functions']:
            text += ['', '### Funzione incorporata: ' + script['member'], '', '```matlab', script['code'], '```']
    (ROOT / 'docs/INVENTARIO_XML_SIMULINK.md').write_text('\n'.join(text) + '\n', encoding='utf-8')
    print(json.dumps([{'model': r['model'], 'blocks': len(r['blocks']), 'lines': len(r['connections']), 'release': r['release']['release']} for r in results], indent=2))

if __name__ == '__main__':
    main()
