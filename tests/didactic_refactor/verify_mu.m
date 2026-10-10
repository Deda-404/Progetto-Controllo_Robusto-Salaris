function verify_mu(nuovaSintesi)
if nargin==0, nuovaSintesi=false; end
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
b=load(fullfile(root,'tmp','refactor_didactic','baseline.mat')); oldrng=rng;
m=run_capture(fullfile(root,'File_di_Funzioni_Progetto-Accorpati','progetto_mu.m'));
assert(isequal(oldrng,rng)); assert(numel(findall(0,'Type','figure'))==3);
check(m,b.mu); save(fullfile(root,'tmp','refactor_didactic','after_mu.mat'),'m','-v7.3'); close all;
fprintf('MU DEFAULT PASS: ABCD, RESULTS, FIGURES, RNG\n');
modes={'archived'}; if nuovaSintesi, modes{2}='fresh'; end
for mode=modes
    for k=1:2
        if k==1, file=fullfile(root,'tmp','refactor_didactic','before','progetto_mu.m');
        else, file=fullfile(root,'File_di_Funzioni_Progetto-Accorpati','progetto_mu.m'); end
        source=fileread(file);
        if strcmp(mode{1},'archived'), source=strrep(source,'ricalcolaAnalisi=true','ricalcolaAnalisi=false');
        else, source=strrep(source,'ricalcolaSintesi=false','ricalcolaSintesi=true'); end
        source=strrep(source,"fileparts(mfilename('fullpath'))", "'"+string(fileparts(file))+"'");
        variant=fullfile(root,'tmp','refactor_didactic',sprintf('%s_mu_%d.m',mode{1},k));
        fid=fopen(variant,'w'); fwrite(fid,source); fclose(fid);
        out{k}=run_capture(variant); assert(isequal(oldrng,rng)); close all;
        save(fullfile(root,'tmp','refactor_didactic',sprintf('%s_mu_%d.mat',mode{1},k)),'out','-v7.3');
    end
    check(out{1},out{2});
    fprintf('MU %s PASS\n',upper(mode{1}));
end
end
function check(x,y)
names={'Khinf','Kmu','Ga','WI','physicalNom','P','CLhinf','CLmu','W1','W2','Mo','N_hinf','N_mu','N11_hinf','N11_mu'};
for j=1:numel(names)
    a=x.(names{j}); b=y.(names{j});
    if isa(a,'uss'), a=a.NominalValue; b=b.NominalValue; end
    [a1,b1,c1,d1]=ssdata(ss(a)); [a2,b2,c2,d2]=ssdata(ss(b));
    assert(isequal(a1,a2)&&isequal(b1,b2)&&isequal(c1,c2)&&isequal(d1,d2),'ABCD differs: %s',names{j});
    fprintf('%s ABCD EXACT, order %d\n',names{j},order(a));
end
fields={'storico','storiaDK','obiettivoMu','confronto','tracking','comandi','analisi','muGriglia','risultati'};
for j=1:numel(fields)
    assert(isequaln(x.(fields{j}),y.(fields{j})),'Field differs: %s',fields{j});
    fprintf('%s EXACT\n',fields{j});
end
end
