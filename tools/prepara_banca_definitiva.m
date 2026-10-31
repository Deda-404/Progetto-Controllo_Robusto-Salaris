function prepara_banca_definitiva
%PREPARA_BANCA_DEFINITIVA Estrae i soli dati congelati necessari da main.
% Nessuna sintesi: i coefficienti sono conservati senza riduzione di ordine.
radice=fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(radice,'analysis'));
d=final_closure_load;
banca.base='0ed5611fdbb9c46475543f87eba68d9799b07bc5';
banca.origine='Controllori storici validati su main; garanzie M4 non trasferite';
banca.plant=d.m3;
banca.spec=d.m5.spec;
banca.Bd=d.m5.BdFull;
banca.controllers=d.controllers;
f=fullfile(radice,'results/data');
a=load(fullfile(f,'m6_lqg_no_integrator.mat'));
for nome=["K","L","Q","R","Nr","Qn","Rn","Klqg"]
    banca.lqg.(nome)=a.(nome);
end
a=load(fullfile(f,'m7_augmented_cost_feasibility.mat'));
banca.lqgi=a.designs{a.config.illustrativeIndex};
banca.hinf=d.selected;
banca.hinf1=d.study.one{d.study.selectedOne};
banca.hinfConfig=d.study.config;
a=load(fullfile(f,'noise_redesign/mu_noise_01.mat'),'candidate');
banca.muRumore=a.candidate.K;
cartella=fullfile(radice,'File_di_Funzioni_Progetto-Accorpati','dati');
if ~isfolder(cartella),mkdir(cartella);end
save(fullfile(cartella,'banca_validata.mat'),'banca','-v7');
disp(fieldnames(banca.plant)); disp(fieldnames(banca.lqgi));
disp(fieldnames(banca.hinf)); disp(fieldnames(banca.hinf1));
fprintf('Banca estratta da main: %d controllori + MuN1.\n',numel(banca.controllers));
end
