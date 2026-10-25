%% 1 - Pesi consolidati: due problemi distinti, nessuna nuova taratura
cartella=fileparts(mfilename('fullpath')); addpath(cartella); p=parametri_sea;
a=load(fullfile(cartella,'dati/banca_consolidata.mat'),'banca'); banca=a.banca;
Gfull=ss(banca.plant.A,[banca.plant.Bu banca.plant.Bd],banca.plant.Cq,zeros(2,4));
G=Gfull(:,1:2); s=tf('s'); I=eye(2);
W1=(s/p.Ms+p.omegaW1)/(s+p.omegaW1*p.As)*I;
W2=p.ku*(s+p.omegaU)/(s/p.alphaU+p.omegaU)*I;
Mo=p.omegaM^2/(s^2+2*p.omegaM*s+p.omegaM^2)*I;
assert(max(abs(freqresp(W1-banca.hinf.W1,p.omega)),[],'all')<1e-10);
assert(max(abs(freqresp(W2-banca.hinf.W2,p.omega)),[],'all')<1e-10);
fprintf('W1(0)=%.6g, W2(0)=%.6g, Mo(0)=1; modalita %s.\n', ...
    dcgain(W1(1,1)),dcgain(W2(1,1)),p.modalita);

%% 2 - P1: w=r, z=[W1*e;W2*u], e=r-q; stesso problema mixsyn/hinfsyn
% connect conserva una sola copia degli stati instabili della pianta.
Gn=G; Gn.InputName={'u1','u2'}; Gn.OutputName={'q1','q2'};
We=ss(W1); We.InputName={'e1','e2'}; We.OutputName={'ze1','ze2'};
Wu=ss(W2); Wu.InputName={'u1','u2'}; Wu.OutputName={'zu1','zu2'};
P1=connect(Gn,We,Wu,sumblk('e1=r1-q1'),sumblk('e2=r2-q2'), ...
    {'r1','r2','u1','u2'},{'ze1','ze2','zu1','zu2','e1','e2'});

%% 3 - P2: w=[r;d], z=[W1*(q-Mo*r);W2*u], misure [r;q]
Pn=Gfull; Pn.InputName={'u1','u2','d1','d2'}; Pn.OutputName={'q1','q2'};
Mn=ss(Mo); Mn.InputName={'r1','r2'}; Mn.OutputName={'qm1','qm2'};
We.InputName={'em1','em2'};
P2=connect(Pn,Mn,We,Wu,sumblk('em1=q1-qm1'),sumblk('em2=q2-qm2'), ...
    {'r1','r2','d1','d2','u1','u2'}, ...
    {'ze1','ze2','zu1','zu2','r1','r2','q1','q2'});

%% 4 - Caricamento rapido oppure sintesi con gli stessi pesi
if p.modalita=="completa"
    opts=hinfsynOptions('RelTol',.01);
    [KeMix,CLmix,gammaMix]=mixsyn(G,W1,W2,[],opts);
    [KeHin,CLhin,gammaHin]=hinfsyn(P1,2,2,opts);
    [K2,CL2,gamma2]=hinfsyn(P2,4,2,opts);
    % Un avvio dal PID consolidato: verifica strutturata proporzionata.
    valori=table2array(banca.hinf.pidParameters); Kt=cell(1,2);
    for j=1:2
        Kt{j}=tunablePID2(char("joint"+j),'PID');
        Kt{j}.Kp.Value=valori(j,1); Kt{j}.Ki.Value=valori(j,2);
        Kt{j}.Kd.Value=valori(j,3); Kt{j}.Tf.Value=valori(j,4);
        Kt{j}.b.Value=valori(j,5); Kt{j}.c.Value=valori(j,6);
    end
    Kt=blkdiag(Kt{:}); Kt=Kt(:,[1 3 2 4]); rng(p.seed,'twister');
    [tuned,gammaPID,infoPID]=hinfstruct(lft(P2,Kt), ...
        hinfstructOptions('RandomStart',0,'MaxIter',100,'Display','final'));
    % Il controllore va estratto dai blocchi ottimizzati, non dalla mappa chiusa.
    Kpid=ss(blkdiag(getValue(tuned.Blocks.joint1),getValue(tuned.Blocks.joint2)));
    Kpid=Kpid(:,[1 3 2 4]);
    hinf=struct('KeMix',KeMix,'KeHin',KeHin,'K2',K2,'Kpid',Kpid, ...
        'gammaMix',gammaMix,'gammaHin',gammaHin,'gamma2',gamma2, ...
        'gammaPID',gammaPID,'infoPID',infoPID,'origin','SINTESI S1 ESEGUITA');
    assert(isstable(CLmix) && isstable(CLhin) && isstable(CL2));
    save(fullfile(cartella,'dati/sintesi_hinf.mat'),'hinf','-v7');
else
    a=load(fullfile(cartella,'dati/sintesi_hinf.mat'),'hinf'); hinf=a.hinf;
    fprintf('Sintesi e confronto mixsyn/hinfsyn CARICATI dal run verificato.\n');
end

%% 5 - Confronto omogeneo mixsyn/hinfsyn e norme delle mappe indipendenti
S1=feedback(eye(2),G*hinf.KeMix); S2=feedback(eye(2),G*hinf.KeHin);
normMix=norm([W1*S1;W2*hinf.KeMix*S1],inf);
normHin=norm([W1*S2;W2*hinf.KeHin*S2],inf);
tab=table(["mixsyn";"hinfsyn stesso P1";"hinfsyn P2";"hinfstruct PID P2"], ...
    [order(hinf.KeMix);order(hinf.KeHin);order(hinf.K2);order(hinf.Kpid)], ...
    [hinf.gammaMix;hinf.gammaHin;hinf.gamma2;hinf.gammaPID], ...
    'VariableNames',{'Metodo','Ordine','GammaProprioProblema'});
assert(abs(normMix/hinf.gammaMix-1)<.05 && abs(normHin/hinf.gammaHin-1)<.05);
% Le norme P1 e P2 non sono una classifica sullo stesso costo.
writetable(tab,fullfile(cartella,'dati/confronto_hinf.csv')); disp(tab);
if p.figure
    f=figure('Name','Pesi e sensibilita mista','Color','white','Theme','light');
    tiledlayout(1,2); nexttile; bodemag(W1(1,1),W2(1,1),Mo(1,1),p.omega); grid on;
    legend('W1','W2','Mo','Location','best'); title('Pesi effettivi');
    nexttile; sigma(S1,S2,p.omega); grid on; legend('mixsyn','hinfsyn P1'); title('Stesso problema 1 DoF');
    exportgraphics(f,fullfile(cartella,'figure/03_hinf.png'),'Resolution',170);
end
% La banca originale resta il riferimento dei sei controllori confrontati.
% I ricalcoli documentano i metodi; non sostituiscono silenziosamente la banca.
