%% 1 - LQRI: LQR con integratore e osservatore di Kalman M6
% Il controllore usa solo encoder: u=-Kx*xhat-Ki*xi, xi_dot=r-q_mis.
% Lo stato vero entra nella pianta simulata, mai nel feedback implementato.
clearvars; clc;
radice=fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(radice,'src')),genpath(fullfile(radice,'controllers')), ...
    genpath(fullfile(radice,'analysis')));
dati=fullfile(radice,'results','data');
m3=load(fullfile(dati,'m3_nominal_actuated_plant.mat'));
m6=load(fullfile(dati,'m6_lqg_no_integrator.mat'));
m7=load(fullfile(dati,'m7_augmented_cost_feasibility.mat'));
j=m7.config.illustrativeIndex; d=m7.designs{j}; e=m7.evaluations{j};

%% 2 - Sistema aumentato del problema LQR: 14 stati fisici e 2 integratori
% xi e la memoria in rad*s dell'errore misurato; non e uno stato Kalman.
A=m3.Afull; B=m3.Bfull; C=m3.CfullMeas; Cq=m3.CfullQ;
Aa=[A,zeros(14,2);-Cq,zeros(2)]; Ba=[B;zeros(2)];
Br=[zeros(14,2);eye(2)];
% Qi penalizza direttamente xi in rad*s, senza normalizzazione integrale.
wbarI=d.wbarI; ru=d.ru; Qi=wbarI*eye(2); Qa=blkdiag(m6.Q,Qi); R=ru*eye(2);

%% 3 - Verifica esplicita di Riccati: Kx e Ki hanno un'origine comune
P=d.P; Kaug=d.Kaug; Kx=Kaug(:,1:14); Ki=Kaug(:,15:16);
residuo=Aa'*P+P*Aa-P*Ba*(R\Ba')*P+Qa;
assert(norm(residuo,'fro')/max(1,norm(Qa,'fro'))<1e-8);
assert(norm(Kaug-R\(Ba'*P),'fro')<1e-7);
disp('Kx (2x14), Ki (2x2), ru, wbarI:'); disp(Kx); disp(Ki); disp([ru,wbarI]);

%% 4 - Osservatore e realizzazione autonoma a 16 stati [xhat;xi]
% L, Qn, Rn sono quelli M6. E seleziona q dai quattro encoder [q;theta].
% L'osservatore riceve il comando effettivamente applicato alla pianta.
L=m6.L; E=[eye(2),zeros(2)];
Ak=[A-L*C-B*Kx,-B*Ki;zeros(2,16)];
Bk=[zeros(14,2),L;eye(2),-E]; Ck=[-Kx,-Ki]; Dk=zeros(2,6);
assert(norm(Ak-e.Klqri.A,'fro')<1e-12 && norm(Bk-e.Klqri.B,'fro')<1e-12);
assert(isequal(L,e.L) && isequal(m6.Qn,e.Qn) && isequal(m6.Rn,e.Rn));

%% 5 - Stabilita interna: chiusura reale di ordine 30 e separazione
% La forma triangolare in [x;xi;ex], ex=x-xhat, comprende lo stimatore.
Acl=[A,-B*Ki,-B*Kx;-Cq,zeros(2,16);L*C,-B*Ki,A-B*Kx-L*C];
T=[eye(14),zeros(14,16);zeros(2,14),eye(2),zeros(2,14); ...
    eye(14),zeros(14,2),-eye(14)];
Asep=[A-B*Kx,-B*Ki,B*Kx;-Cq,zeros(2,16);zeros(14,16),A-L*C];
assert(norm(T*Acl/T-Asep,'fro')<1e-9);
assert(all(real(eig(Acl))<0) && all(real(eig(A-L*C))<0));
fprintf('30 poli stabili; parte reale dominante = %.10g s^-1.\n',max(real(eig(Acl))));

%% 6 - Confronto tracciabile: gli esperimenti salvati provengono da M7
% validate_m7_lqg_integral rigenera M7; l'esportatore riusa la cache.
% Si distinguono esplicitamente errore DC, residuo a 8 s e target M5.
plot_lqri_revision;
disp(m7.manualComparisonTable);
fprintf('Stato M7: %s. Nessun certificato robusto o non lineare.\n', ...
    m7.validationMetrics.status);
