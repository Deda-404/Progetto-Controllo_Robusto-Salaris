function uguali=stessi_controllori(Ka,Kb,omega)
%STESSI_CONTROLLORI Confronto a tolleranza fra due elenchi di controllori.
%
% Le cache (analisi robuste, RAS) memorizzano i controllori con cui sono
% state calcolate. In modalita rapida LQG e LQGI vengono risintetizzati:
% con una release MATLAB diversa le matrici possono differire di pochi
% ulp, pur descrivendo lo stesso controllore. Un confronto bit per bit
% (isequaln) rifiuterebbe allora cache valide.
%
% Qui due controllori sono considerati uguali se hanno le stesse
% dimensioni, lo stesso ordine e risposte in frequenza coincidenti entro
% una tolleranza relativa di 1e-6 sulla griglia omega. Una sintesi diversa
% (pesi, struttura, D-K) produce scarti di molti ordini di grandezza
% superiori, quindi il controllo resta selettivo.
uguali=iscell(Ka) && iscell(Kb) && numel(Ka)==numel(Kb);
for k=1:numel(Ka)
    if ~uguali,return;end
    a=ss(Ka{k}); b=ss(Kb{k});
    uguali=isequal(size(a),size(b)) && order(a)==order(b);
    if uguali
        ra=freqresp(a,omega); rb=freqresp(b,omega);
        scala=max(1,max(abs(ra),[],'all'));
        uguali=max(abs(ra-rb),[],'all')<=1e-6*scala;
    end
end
end
