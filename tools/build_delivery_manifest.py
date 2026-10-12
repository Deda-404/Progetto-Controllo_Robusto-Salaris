"""Seleziona materiali correnti e dipendenze, preservando l'archivio del repository."""
from pathlib import Path
import json,re,hashlib,sys
ROOT=Path(__file__).resolve().parents[1]
TEXT={'.m','.tex','.md','.py','.ps1','.json','.csv','.txt'}
def main():
    selected={}
    def add(path,role):
        p=(ROOT/path).resolve();assert p.is_relative_to(ROOT)
        assert p.is_file(),str(p)
        selected.setdefault(p,set()).add(role)
    def glob(pattern,role):
        for p in ROOT.glob(pattern):
            if p.is_file():add(p.relative_to(ROOT),role)
    def tex_tree(path,base):
        add(path,'editable_document_source');s=(ROOT/path).read_text(encoding='utf-8-sig')
        for match in re.finditer(r'\\(?:input|include|includegraphics)(?:\[[^\]]*\])?\{([^}]+)\}',s):
            target=(ROOT/base/match.group(1)).resolve()
            if not target.suffix:target=target.with_suffix('.tex')
            if not target.is_file():
                assert 'student_exports' in str(target),str(target)
                continue
            rel=target.relative_to(ROOT)
            if target.suffix=='.tex':
                if target not in selected:tex_tree(rel,base)
            else:add(rel,'document_figure')
        for match in re.finditer(r'\\lstinputlisting(?:\[[^\]]*\])?\{([^}]+)\}',s):
            add((ROOT/base/match.group(1)).resolve().relative_to(ROOT),'literal_matlab_excerpt_source')
    for base in ['report','presentation']:tex_tree(Path(base)/'main.tex',Path(base))
    for name in ['report/Progetto_CR_Relazione_finale.pdf','presentation/Progetto_CR_Presentazione.pdf']:
        add(name,'student_handin_pdf')
    for name in ['README.md','presentation/SPEAKER_NOTES.md','presentation/OUTLINE_AND_TIMING.md',
                 'docs/CHECKLIST_CONSEGNA_STUDENTI.md','simulink/README.md',
                 'simulink/student_originals_manifest.json','delivery/source_dependencies.json']:
        add(name,'reproduction_and_integrity_instructions')
    glob('simulink/student_originals/*.slx','immutable_student_original')
    dependencies=json.loads((ROOT/'delivery/source_dependencies.json').read_text(encoding='utf-8'))
    for name in dependencies['files']:add(name.replace('\\','/'),'matlab_detected_source_dependency')
    glob('File_di_Funzioni_Progetto-Accorpati/support/*.m','dynamic_path_dependency')
    glob('src/**/*.m','physical_model_and_embedded_slx_dependency')
    # Stored plant/controller data and cached calculations needed by the defaults.
    for name in ['m2_linearization_nominal','m3_nominal_actuated_plant','m4_uncertain_plant','m5_performance_specs',
                 'm6_lqg_no_integrator','m7_augmented_cost_feasibility','m7_lqg_integral',
                 'm7_disturbance_comparison','lyapunov_ras_nominal','lyapunov_trajectories']:
        add('results/data/'+name+'.mat','frozen_model_controller_or_default_cache')
    for name in ['nominal_study','selected_full_order','fixed_PID','fixed_study','m12','m13','m14',
                 'robust_study','nonlinear_study','ras_study']:
        add('results/data/hinf_final_coherent/'+name+'.mat','frozen_final_scientific_evidence')
    glob('results/data/final_closure/*','new_final_scientific_evidence')
    glob('results/data/lqgi_validation/*','lqgi_nonlinear_scientific_evidence')
    for name in ['tools/build_final_closure_tables.py','report/build_matlab_appendix.py','tools/build_m18_latex.ps1',
                 'tools/build_delivery_manifest.py','delivery/README.md',
                 'report/generated/matlab_appendix_sources.json','results/data/coherent_review/matlab_tests.csv',
                 'report/generated/report_latex_audit.txt','presentation/generated/presentation_latex_audit.txt']:
        add(name,'document_reproduction_or_build_audit')
    # This manifest refers to the complete repository for the historical suite.
    add('tests/finalClosureTest.m','focused_final_verification_source')
    for name in ['docs/REPORT_VERIFICA_SIMULINK.md','docs/ANALISI_RUMORE_MISURA.md','docs/CHIUSURA_FINALE_PROGETTO.md']:
        add(name,'internal_group_review_only')
    files=[]
    for p,roles in sorted(selected.items(),key=lambda item:item[0].as_posix().lower()):
        raw=p.read_bytes();data=raw.replace(b'\r\n',b'\n') if p.suffix.lower() in TEXT else raw
        files.append({'path':p.relative_to(ROOT).as_posix(),'roles':sorted(roles),
                      'size_bytes_recorded':len(raw),'sha256':hashlib.sha256(data).hexdigest(),
                      'hash_mode':'LF-normalized text' if p.suffix.lower() in TEXT else 'exact bytes'})
    result={'date':'2026-10-12','branch':'codex/chiusura-definitiva-progetto-sea','base_commit':'fa78e588ede9b8a136692c19aeb39b01b56cb502',
            'status':'PARTIAL: original SLX runtime and authentic diagrams require R2026a',
            'hash_policy':'Text uses LF-normalized SHA-256 for portable checkout; binary/SLX/PDF exact bytes.',
            'files':files,'products':dependencies['products'],
            'excluded_from_student_handin':['internal_group_review_only','tmp/','old Simulink originals/ and drive_project/','dated diary/review reports','old 40-sample campaign and figures'],
            'historical_regression_note':'The full 141-test suite runs from the complete GitHub checkout and intentionally retains historical dependencies. They are not evidence for Chapter 11.',
            'verification':'Run tools/build_delivery_manifest.py --check after checkout; each selected dependency is a real file.'}
    (ROOT/'delivery/manifest.json').write_text(json.dumps(result,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
    print(f'Manifest: {len(files)} files, sources and binary evidence selected.')
def check():
    manifest=json.loads((ROOT/'delivery/manifest.json').read_text(encoding='utf-8'))
    for record in manifest['files']:
        raw=(ROOT/record['path']).read_bytes()
        data=raw.replace(b'\r\n',b'\n') if record['hash_mode']=='LF-normalized text' else raw
        assert hashlib.sha256(data).hexdigest()==record['sha256'],record['path']
    print(f"PASS: {len(manifest['files'])} selected file hashes.")
if __name__=='__main__':
    if '--check' in sys.argv:check()
    else:main()
