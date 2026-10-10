function verify_hinf(nuovaSintesi)
if nargin==0, nuovaSintesi=false; end
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
b=load(fullfile(root,'tmp','refactor_didactic','baseline.mat'));
oldrng=rng;
h=run_capture(fullfile(root,'File_di_Funzioni_Progetto-Accorpati','progetto_hinf_tre_controllori.m'));
assert(isequal(oldrng,rng)); assert(numel(findall(0,'Type','figure'))==4);
assert(isequaln(h.cfg,b.hinf.cfg));
assert(isequaln(h.provePID,b.hinf.provePID));
assert(isequaln(h.parametriPID,b.hinf.parametriPID));
assert(isequaln(h.confronto,b.hinf.confronto));
names={'physical','Ke','K1','K2','Kpid','P1','P2','W1','W2','Mo'};
for j=1:numel(names), exact_ss(h.(names{j}),b.hinf.(names{j}),names{j}); end
for j=1:3
    assert(isequaln(h.valutazioni{j},b.hinf.valutazioni{j}));
end
assert(isequaln(h.risultati,b.hinf.risultati));
save(fullfile(root,'tmp','refactor_didactic','after_hinf.mat'),'h','-v7.3');
fprintf('HINF DEFAULT PASS: ABCD, FULL RESULTS, FIGURES, RNG EXACT\n');
close all;
if ~nuovaSintesi, return; end
% La nuova sintesi viene confrontata con il ramo originale, stesso seed.
for k=1:2
    if k==1, file=fullfile(root,'tmp','refactor_didactic','before','progetto_hinf_tre_controllori.m');
    else, file=fullfile(root,'File_di_Funzioni_Progetto-Accorpati','progetto_hinf_tre_controllori.m'); end
    source=fileread(file); source=strrep(source,'ricalcolaSintesi=false','ricalcolaSintesi=true');
    source=strrep(source,"fileparts(mfilename('fullpath'))", "'"+string(fileparts(file))+"'");
    variant=fullfile(root,'tmp','refactor_didactic',sprintf('fresh_hinf_%d.m',k));
    fid=fopen(variant,'w'); fwrite(fid,source); fclose(fid);
    out{k}=run_capture(variant); assert(isequal(oldrng,rng)); close all;
end
for j=1:numel(names), exact_ss(out{1}.(names{j}),out{2}.(names{j}),names{j}); end
assert(isequaln(out{1}.confronto,out{2}.confronto));
assert(isequaln(out{1}.provePID,out{2}.provePID));
assert(isequaln(out{1}.risultati,out{2}.risultati));
save(fullfile(root,'tmp','refactor_didactic','fresh_hinf.mat'),'out','-v7.3');
fprintf('HINF FRESH PASS: MIXSYN HINFSYN HINFSTRUCT, RESULTS EXACT\n');
end
function exact_ss(a,b,label)
[a1,b1,c1,d1]=ssdata(ss(a)); [a2,b2,c2,d2]=ssdata(ss(b));
assert(isequal(a1,a2)&&isequal(b1,b2)&&isequal(c1,c2)&&isequal(d1,d2),'ABCD differs: %s',label);
fprintf('%s: exact, order %d\n',label,order(a));
end
