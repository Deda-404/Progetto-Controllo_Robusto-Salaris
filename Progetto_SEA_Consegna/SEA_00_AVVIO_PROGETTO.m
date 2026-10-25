%% 0 - Progetto SEA: avvio dalla cartella estratta
% Servono MATLAB, Control System Toolbox e Robust Control Toolbox.
% In parametri_sea.m: modalita="rapida" carica i risultati verificati;
% modalita="completa" ripete anche H-infinity, D-K e analisi robuste.
cartellaProgetto=fileparts(mfilename('fullpath'));
addpath(cartellaProgetto); p=parametri_sea;
fprintf('\nSEA S1 - modalita %s\n',p.modalita);
fprintf('wn/zeta +/-10%%, tau=15 ms noto; meccanica nominale.\n');
assert(license('test','Control_Toolbox') && license('test','Robust_Toolbox'), ...
    'SEA:Toolbox','Servono Control System e Robust Control Toolbox.');
passi={'SEA_01_MODELLI_INCERTEZZE.m','SEA_02_LQG_LQGI.m','SEA_03_HINF.m', ...
    'SEA_04_MU_SINTESI.m','SEA_05_CONFRONTO_FINALE_RAS.m'};
for passo=1:numel(passi)
    fprintf('\n--- %s ---\n',passi{passo});
    run(fullfile(cartellaProgetto,passi{passo}));
end
fprintf('\nConfronto completato. CSV e MAT in dati/, figure in figure/.\n');
fprintf('SLX: integrazione futura degli studenti; nessuna nuova validazione.\n');
