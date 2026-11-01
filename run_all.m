function run_all(modalita)
%RUN_ALL Unico percorso corrente: rapida (default) oppure completa.
arguments
    modalita (1,1) string {mustBeMember(modalita,["rapida","completa"])} = "rapida"
end
radice=fileparts(mfilename('fullpath'));
cartella=fullfile(radice,'File_di_Funzioni_Progetto-Accorpati');
if ~isfolder(cartella),cartella=radice;end
addpath(cartella);
precedente=getenv('SEA_MODALITA'); cleanup=onCleanup(@()setenv('SEA_MODALITA',precedente));
setenv('SEA_MODALITA',modalita); p=parametri_sea;
diary(fullfile(p.risultati,"esecuzione_"+modalita+".txt")); fineLog=onCleanup(@()diary('off'));
fprintf('SEA - %s - MATLAB %s - seed %d\n',modalita,version,p.seed);
script=["modello_sea","incertezze_attuatori","progetto_lqg","progetto_lqgi", ...
    "progetto_hinf_tre_controllori","progetto_mu","confronto_ras"];
for nome=script
    fprintf('\n--- %s ---\n',nome);
    esegui(fullfile(cartella,nome+".m"));
end
verifica_sea;
if modalita=="completa",collaudo_simulink;end
fprintf('Percorso %s terminato. Consultare CSV per PASS/FAIL scientifici.\n',modalita);
end
function esegui(file)
% Workspace separato per ogni script: nessuna variabile ereditata.
run(file);
end
