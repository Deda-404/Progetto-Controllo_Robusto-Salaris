function run_all(modalita)
%RUN_ALL Esecuzione completa del progetto dalla cartella di consegna.
%
%   run_all            oppure run_all('rapida')
%       Ricalcola modello, incertezze, LQG/LQGI, analisi nominali, dieci
%       impianti, rumore e verifiche. Carica (dopo controllo di firma e di
%       identita dei controllori) i risultati onerosi gia validati: sintesi
%       H-infinito e D-K, margini robusti, prove non lineari e RAS.
%   run_all('completa')
%       Rigenera davvero tutto: sintesi H-infinito/PID, due D-K, mu-analysis
%       sulle due mappe e sui passi intermedi, prove non lineari, 105 RAS e
%       20 prove Simulink. Richiede molto tempo (ore).
%
% Ogni script gira in un Workspace separato: nessuna variabile viene
% ereditata da esecuzioni precedenti. Il log e in risultati/esecuzione_*.txt.
arguments
    modalita (1,1) string {mustBeMember(modalita,["rapida","completa"])} = "rapida"
end
cartella=fileparts(mfilename('fullpath'));
addpath(cartella,fullfile(cartella,'supporto'),fullfile(cartella,'test'));
precedente=getenv('SEA_MODALITA'); cleanup=onCleanup(@()setenv('SEA_MODALITA',precedente));
setenv('SEA_MODALITA',modalita); p=parametri_sea;
fileLog=fullfile(p.risultati,"esecuzione_"+modalita+".txt");
fid=fopen(fileLog,'w'); assert(fid>0,'SEA:Log','Impossibile creare il log.'); fclose(fid);
diary(fileLog); fineLog=onCleanup(@()diary('off'));
fprintf('SEA - %s - MATLAB %s - seed %d\n',modalita,version,p.seed);
% Ordine dei capitoli: modello -> incertezze -> LQG/LQGI -> H-inf -> mu -> confronto.
script=["modello_sea","incertezze_attuatori","progetto_lqg_lqgi", ...
    "progetto_hinf_tre_controllori","progetto_mu","confronto_ras"];
for nome=script
    fprintf('\n--- %s ---\n',nome);
    esegui(fullfile(cartella,nome+".m"));
end
verifica_sea;
if modalita=="completa",collaudo_simulink;end
fprintf('Percorso %s terminato. Consultare i CSV in risultati/ per PASS/FAIL scientifici.\n',modalita);
end
function esegui(file)
% Workspace separato per ogni script: nessuna variabile ereditata.
run(file);
end
