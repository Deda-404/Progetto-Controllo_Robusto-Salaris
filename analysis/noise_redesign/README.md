# Studio del rumore con controllori separati

MATLAB/Simulink R2026b, Control System e Robust Control Toolbox. Eseguire dalla radice del repository. I quattro script principali e i MAT consolidati restano baseline; gli SLX originali sono immutabili.

```matlab
addpath(genpath('analysis'),genpath('controllers'),genpath('src'),'simulink');
run_noise_synthesis('hinf'); % tre Wn: sigma, 5 sigma, 20 sigma
run_noise_synthesis('mu');   % una D-K con Wn=sigma
validate_noise_candidates; % tre seed, otto scenari comuni, ZOH fra campioni
audit_noise_robustness;     % problemi nuovo/precedente, robstab/robgain/mussv
run_noise_simulink;        % quattro originali, baseline/candidato, dati separati
validate_noise_plants;     % riusa i dieci impianti congelati
```

Le sintesi e i run SLX riusano i checkpoint già presenti; non risintetizzano i controllori consolidati. Le verifiche del rumore e degli impianti si rieseguono. I MAT candidati conservano tutte le matrici e le opzioni, senza riduzione o saturazione. HinfN3 fallisce RS; MuN1 supera RS/RP ma peggiora l'offset q1. Nessun candidato diventa predefinito.

La selezione esterna è esplicita:

```matlab
data=setup_student_originals('Hinf','noise_hinf3');
data=setup_student_originals('mu','noise_mu1');
% setup_student_originals('mu') restituisce sempre la baseline.
```

Il runner abbina automaticamente i Workspace alle esecuzioni e registra i coefficienti realmente forniti, i loro hash, solver, selettori, warning e SHA-256 SLX. H∞ lineare usa misure ideali; il non lineare e i modelli μ ricevono misure rumorose. Non confondere la prova Scope combinata con il rumore encoder isolato.

Per ripetere la RAS candidata nello stato completo:

```matlab
d=final_closure_load; cc=d.controllers([4 6]);
files={'hinf_noise_03','mu_noise_01'};
for j=1:2
    a=load(fullfile('results/data/noise_redesign',[files{j} '.mat']));
    cc(j).name=a.candidate.name; cc(j).K=a.candidate.K;
    [cc(j).A,B,cc(j).C,D]=ssdata(cc(j).K);
    cc(j).Br=B(:,1:2); cc(j).By=B(:,3:4);
    cc(j).Dr=D(:,1:2); cc(j).Dy=D(:,3:4); cc(j).order=order(cc(j).K);
end
run_final_ras_lyapunov(cc,fullfile(pwd,'results/data/noise_redesign/ras'));
export_noise_redesign;
r=runtests('tests/noiseRedesignTest.m'); assertSuccess(r);
```

La campagna RAS usa la stessa griglia/condizioni fisiche e criteri della baseline, con ode15s bilanciato e Jacobiano per i candidati. La prima prova HinfN3 in ode23t è conservata come incompleta. MuN1 ha 25/25 convergenze empiriche, ma nessun certificato Lyapunov numericamente accreditato.

Rigenerazione degli elaborati:

```text
python tools/build_noise_redesign_documents.py
python tools/audit_oral_timing.py
powershell -File tools/build_m18_latex.ps1
```

`summary.json` proviene dai MAT realmente eseguiti. Le tabelle LaTeX e il quaderno TXT derivano da quei dati. La presentazione mantiene la baseline identificata nelle prime analisi e una slide dedicata ai candidati. Il tempo orale è una stima da conteggio, da confermare provando il discorso.
