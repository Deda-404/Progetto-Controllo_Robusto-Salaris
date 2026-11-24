function [nomi,K,origine,correnti]=controllori_sea(p,includiRiferimenti)
%CONTROLLORI_SEA Elenco dei controllori confrontati (Capitolo 12).
%
% Sette controllori ufficiali: LQG, LQGI, Hinf1, Hinf2, PID, Mu_A, Mu_B,
% letti dai MAT della campagna corrente (con controllo di firma).
% Con includiRiferimenti=true si aggiungono i controllori storici fissati
% di banca_validata.mat ("_fisso") e MuN1, il controllore iniziale comune
% alle due D-K. Tutti hanno ingressi [r1 r2 y...] e uscite [u1 u2].
if nargin<2,includiRiferimenti=false;end
a=load(fullfile(p.dati,'banca_validata.mat')); b=a.banca;
nomi=[string({b.controllers.name})+"_fisso","MuN1_fisso"];
K=[{b.controllers.K},{b.muRumore}];
origine=repmat("Controllore fissato storico da rivalutare",size(nomi));
fileH=fullfile(p.risultati,'sintesi_hinf.mat');
fileMu=fullfile(p.risultati,'sintesi_mu.mat');
if ~isfile(fileH),fileH=fullfile(p.dati,'sintesi_hinf.mat');end
if ~isfile(fileMu),fileMu=fullfile(p.dati,'sintesi_mu.mat');end
h=load(fileH); mu=load(fileMu);
l=load(fullfile(p.risultati,'lqg.mat')); li=load(fullfile(p.risultati,'lqgi.mat'));
assert(isfield(mu,'inizializzazione') && mu.inizializzazione=="MuN1" && isequal(h.sintesi.firma,p.firma) && isequal(mu.firma,p.firma) && ...
    isequal(l.lqg.firma,p.firma) && isequal(li.lqgi.firma,p.firma),'SEA:Cache','Sintesi incoerenti.');
correnti=numel(K)+(1:7);
nomi=[nomi,"LQG","LQGI","Hinf1","Hinf2","PID","Mu_A","Mu_B"];
K=[K,{l.lqg.K,li.lqgi.K,h.sintesi.K1,h.sintesi.K2,h.sintesi.Kpid,mu.candidati{1}.K,mu.candidati{2}.K}];
origine=[origine,repmat("Sintesi nominale della traccia",1,5),"D-K su A","D-K su B"];
if ~includiRiferimenti
    nomi=nomi(correnti);K=K(correnti);origine=origine(correnti);correnti=1:numel(K);
end
end
