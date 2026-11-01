% ARCHIVIO M4: il percorso corrente e run_all.m e usa gli script accorpati.
%% 1 - Introduzione e dati: progetto H-infinity, separato dal percorso LQG
% Le sezioni 1-19 riproducono la baseline congelata M5/M10/M13.
% La sezione 20 espone il successivo studio a tre pesi, separato e salvato.
clearvars; clc; close all;
radice=fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(radice,'src')),genpath(fullfile(radice,'controllers')), ...
    genpath(fullfile(radice,'analysis')));
dati=fullfile(radice,'results','data');
m3=load(fullfile(dati,'m3_nominal_actuated_plant.mat'));
m4=load(fullfile(dati,'m4_uncertain_plant.mat'));
m5=load(fullfile(dati,'m5_performance_specs.mat'));
m10=load(fullfile(dati,'m10_hinfsyn_nominal.mat'));
spec=m5.spec;

%% 2 - Modello nominale a 14 stati
% x=[dq;dqdot;dtheta;dthetadot;xa]; qbar=[pi/2;0].
% u e una coppia di comando in N m, q e in rad.
A=m3.Afull; B=m3.Bfull; Cq=m3.CfullQ;
G=ss(A,B,Cq,zeros(2)); n=size(A,1);
disp('Poli nominali della pianta, prima del controllo:'); disp(eig(A));

%% 3 - Obiettivo: limitare il peggiore guadagno energetico delle mappe pesate
% e=r-q; S=(I+GK)^-1, T=I-S, KS=K*S.
% Si minimizza gamma=||[W1*S;W2*KS]||inf. Il target e gamma<1.
% Non si puo mantenere S piccolo a tutte le frequenze: ritardo, dinamiche
% elastiche, rumore e sforzo attuativo impongono un compromesso.
disp(spec);

%% 4 - Incertezze M4: separate dalla sintesi nominale M10
Ginc=m4.GuncQ;
disp(Ginc.Uncertainty);
% k1, k2 e Jm1: +/-10%. wn,zeta: +/-10%; delay: +/-20%.
% La famiglia attuativa e rappresentata dal peso WI e da due ultidyn.
% Intervalli scelti nel progetto, non distribuzioni fisiche identificate.
% La sintesi qui usa il nominale; robustezza NON e implicita in gamma.

%% 5 - Segnali esogeni, comando, errore e prestazione
% Ingressi P=[r1;r2;u1;u2]. Uscite P=[z1(2);z2(2);e(2)].
% z1=W1*(r-q), z2=W2*u; il controllore riceve e, NON tutte le posizioni.
% Disturbi lato link e rumore sono scenari di validazione; non ingressi
% esogeni aggiunti retroattivamente al problema di sintesi M10.

%% 6 - Pesi: formula, asintoti e frequenze caratteristiche
s=tf('s');
W1s=(s/spec.Ms+spec.omegaW1)/(s+spec.omegaW1*spec.As);
W2s=spec.controlWeightGain*(s/spec.omegaU+1)/ ...
    (s/(spec.controlWeightAlpha*spec.omegaU)+1);
W1=blkdiag(W1s,W1s); W2=blkdiag(W2s,W2s);
% W1(0)=1/As, W1(inf)=1/Ms; il limite desiderato e 1/|W1|.
% Polo As*omegaW1, zero Ms*omegaW1: non coincidono con il crossover.
crossoverW1=spec.omegaW1*sqrt((1-spec.As^2)/(1-1/spec.Ms^2));
% W2(0)=ku, W2(inf)=alpha*ku; zero omegaU e polo alpha*omegaU.
% W2 NON attraversa 0 dB: omegaU e l'inizio della crescita, non un crossover.
% uScale=12 e una scala prestazionale M5, NON una saturazione.
fprintf('Crossover |W1|=1: %.8g rad/s. W2: nessun crossover unitario.\n',crossoverW1);
disp('Guadagni DC:'); disp([dcgain(W1s),dcgain(W2s)]);

%% 7 - Motivazione e verifica grafica dei pesi
% As=0.15 e Ms=2.5 rilassano il profilo pesato, non i target temporali.
% omegaW1=8 e distinto da omegaB=12, che resta la scala di velocita LQR.
% ku=0.05 e omegaU=60 derivano dal confronto deterministico salvato.
% La nuova configurazione e un compromesso non conforme, non un PASS.
omega=logspace(-2,3,500);
f=figure('Color','white'); tiledlayout(1,2);
nexttile; semilogx(omega,20*log10(squeeze(abs(freqresp(W1s,omega))))); grid on;
xlabel('Frequenza [rad/s]'); ylabel('|W1| [dB]'); title('Peso sull''errore');
nexttile; semilogx(omega,20*log10(squeeze(abs(freqresp(W2s,omega))))); grid on;
xlabel('Frequenza [rad/s]'); ylabel('|W2| [dB]'); title('Peso sul comando');
set_scientific_figure_style(f);

%% 8 - Pianta generalizzata esplicita come negli esercizi connect/sumblk
Gn=G; Gn.InputName={'u(1)','u(2)'}; Gn.OutputName={'q(1)','q(2)'};
W1n=ss(W1); W1n.InputName={'e(1)','e(2)'}; W1n.OutputName={'z1(1)','z1(2)'};
W2n=ss(W2); W2n.InputName={'u(1)','u(2)'}; W2n.OutputName={'z2(1)','z2(2)'};
somma=sumblk('e = r - q',2);
Pgen=connect(Gn,W1n,W2n,somma, ...
    {'r(1)','r(2)','u(1)','u(2)'}, ...
    {'z1(1)','z1(2)','z2(1)','z2(2)','e(1)','e(2)'});
% Formula indipendente: P=[W1,-W1*G;0,W2;I,-G].
% Il meno e gia in P22=-G: lower LFT realizza u=K*(r-q).
Pformula=[W1 -W1*G;ss(zeros(2)) W2;ss(eye(2)) -G];
erroreP=max(abs(freqresp(Pgen,omega)-freqresp(Pformula,omega)),[],'all');
assert(erroreP<1e-8);
assert(max(abs(freqresp(Pgen,omega)-freqresp(m10.P,omega)),[],'all')<1e-8);

%% 9 - Sintesi: comando esplicito, progetto approvato ricaricato
% La sintesi M10 usa [K,CL,gamma]=hinfsyn(Pgen,2,2), opzioni predefinite.
% Il comando e visibile qui per lo studio; disabilitato per non aprire una
% ulteriore sintesi in questo script. Non modifica alcun artifact M10.
ricalcolaSintesi=false;
assert(~ricalcolaSintesi,'Revisione:ControlloreCongelato', ...
    'Questo script ricarica la sintesi M10 corrente.');
% Comando didattico della sintesi, intenzionalmente non eseguito:
% [Kverifica,CLverifica,gammaVerifica]=hinfsyn(Pgen,2,2);
K=m10.Khinf;

%% 10 - Controllore ottenuto e chiusura interna completa
[Ak,Bk,Ck,Dk]=ssdata(K); nk=size(Ak,1);
% z=[x;xc]; xc_dot=Ak*xc+Bk*(r-Cq*x); u=Ck*xc+Dk*(r-Cq*x).
Acl=[A-B*Dk*Cq B*Ck;-Bk*Cq Ak];
Bcl=[B*Dk;Bk];
Ccl=[Cq zeros(2,nk);-Dk*Cq Ck]; Dcl=[zeros(2);Dk];
chiuso=ss(Acl,Bcl,Ccl,Dcl);
assert(all(real(eig(Acl))<0)); % non si cancellano stati per provare stabilita
fprintf('Ordine K=%d, ordine chiusura=%d, max Re poli=%.9g\n',nk,size(Acl,1),max(real(eig(Acl))));
disp('Matrici Ak, Bk, Ck, Dk salvate integralmente nell''artifact didattico.');

%% 11 - Gamma e verifica indipendente della prestazione
S=feedback(ss(eye(2)),G*K);
T=feedback(G*K,ss(eye(2)));
KS=feedback(K,G);
sistemaPesato=[W1*S;W2*KS];
gammaRicostruito=norm(sistemaPesato,inf);
gammaCongelato=m10.gammaHinf;
fprintf('Gamma congelato %.10g, norma ricostruita %.10g, target 1\n', ...
    gammaCongelato,gammaRicostruito);
assert(abs(gammaRicostruito/gammaCongelato-1)<1e-4);
% La gamma viene riletta dall'artefatto corrente, non dalla vecchia baseline.

%% 12 - Risposta nominale: due gradini separati, r=5 deg, stato nullo
tempo=(0:0.002:4)'; risposte=cell(2,1);
for j=1:2
    r=zeros(numel(tempo),2); r(:,j)=spec.referenceAmplitude;
    risposte{j}=lsim(chiuso,r,tempo);
end
f=figure('Color','white'); tiledlayout(2,1);
for j=1:2
    nexttile; plot(tempo,rad2deg(risposte{j}(:,1:2))); hold on;
    yline(rad2deg(spec.referenceAmplitude),'--k'); grid on;
    xlabel('Tempo [s]'); ylabel('Delta q [deg]'); legend('q_1','q_2','r_j');
    title(sprintf('Hinf: gradino al giunto %d, d=v=0',j));
end
set_scientific_figure_style(f);

%% 13 - Risposta incerta illustrativa: non una certificazione
% Tre campioni dimostrativi M4, separati dai 40 campioni ufficiali M16.
% Nessun risultato M16/M14 viene sovrascritto. Seed e numero espliciti.
rng(20260908,'twister'); famiglia=usample(Ginc,3);
stabileCampioni=false(3,1);
f=figure('Color','white'); hold on;
for j=1:3
    Tp=feedback(famiglia(:,:,j)*K,ss(eye(2)));
    stabileCampioni(j)=all(real(pole(Tp)) < -1e-8);
    if stabileCampioni(j)
        r=[spec.referenceAmplitude*ones(numel(tempo),1),zeros(numel(tempo),1)];
        yp=lsim(Tp,r,tempo);
        plot(tempo,rad2deg(yp(:,1)),'DisplayName',sprintf('Campione %d',j));
    else
        fprintf('Campione illustrativo %d INSTABILE: risposta non riassunta come prestazione.\n',j);
    end
end
yline(5,'--k','Riferimento'); grid on; legend('Location','best');
xlabel('Tempo [s]'); ylabel('Delta q_1 [deg]'); title('Tre campioni M4: evidenza empirica illustrativa');
set_scientific_figure_style(f);
% La robustezza va studiata su tutto l'insieme con mu, non dedotta da 3/3.

%% 14 - Sensibilita, complementarita, sensibilita del comando
f=figure('Color','white'); tiledlayout(1,3);
mappe={S,T,KS}; nomi={'S','T','KS'};
for j=1:3
    nexttile; sv=sigma(mappe{j},omega);
    semilogx(omega,20*log10(sv)); grid on;
    xlabel('Frequenza [rad/s]'); ylabel('Valori singolari [dB]'); title(nomi{j});
end
set_scientific_figure_style(f);
fprintf('||W1*S||inf=%.8g, ||W2*KS||inf=%.8g\n',norm(W1*S,inf),norm(W2*KS,inf));

%% 15 - Azione di controllo
f=figure('Color','white'); plot(tempo,risposte{1}(:,3:4)); grid on;
xlabel('Tempo [s]'); ylabel('u [N m]'); legend('u_1','u_2');
title('Hinf: coppie per gradino r1=5 deg, r2=0, condizioni iniziali nulle');
set_scientific_figure_style(f);

%% 16 - Non lineare nominale, riferimento nullo e perturbazione iniziale
[Aa,Ba,Ca,Da]=ssdata(m3.GactuatorsMimo);
modello=struct('Ac',Ak,'Bc',Bk,'Cc',Ck,'Dc',Dk,'Cy',-Cq, ...
    'Aact',Aa,'Bact',Ba,'Cact',Ca,'Dact',Da, ...
    'xbar',m3.xbar,'taubar',m3.taubar,'parametri',m3.mechanicalParams, ...
    'residuoEquilibrio',sea_nonlinear_rhs(m3.xbar,m3.taubar,m3.mechanicalParams));
fcl=@(z) sea_closed_loop_rhs(z,modello);
nc=n+nk; J=zeros(nc,2); J(1:2,:)=eye(2); J(5:6,:)=eye(2);
z0=J*deg2rad([5;0]); % dtheta=dq, velocita/attuatori/controller nulli
opzioni=odeset('RelTol',1e-7,'AbsTol',1e-10,'MaxStep',0.005);
[tempoNl,zNl]=ode23t(@(~,z) fcl(z),[0 8],z0,opzioni);

%% 17 - Lyapunov sull'intero sistema di 32 stati
QL=eye(nc); P=lyap(Acl',QL); P=(P+P')/2;
assert(min(eig(P))>0);
V=@(z) z'*P*z; Vdot=@(z) 2*z'*P*fcl(z);
% Acl'*P+P*Acl=-I, ma fcl non e Acl*z fuori dal modello lineare.
% Il limite cubico deriva dalle equazioni SEA: ||r(z)||<=c*||z||^3.
% Le sole componenti non lineari sono le accelerazioni link 3:4.
limite=lyapunov_cubic_bound(Acl,P,m3);
E=zeros(nc,2); E(3:4,:)=eye(2);
residuo=norm(Acl'*P+P*Acl+QL,2);
delta2=(1-residuo)/(4*norm(P*E,2)*limite.c);
rhoCertificato=min(eig(P))*delta2;
% V<=rhoCertificato => Vdot<=-(1-residuo)/2*||z||^2<0.
% Certificato interno sul nominale Pade1, senza saturazione/disturbi.
fprintf('eigP=[%.7g %.7g], residuo %.3g, rho interno %.9g\n', ...
    min(eig(P)),max(eig(P)),residuo,rhoCertificato);

%% 18 - Ricerca numerica di rho, esplicita e riproducibile
% Gli stessi parametri sono usati per tutti i controllori dal validator.
seed=20260910; nDirezioni=512; nPiano=72;
raggi=[0.25;0.5;0.75;1]; margine=0.05; nLivelli=49; nBisezioni=12;
rng(seed,'twister');
angoli=(0:nPiano-1)*2*pi/nPiano;
D=[eye(nc),-eye(nc),randn(nc,nDirezioni), ...
    chol(P)*J*[cos(angoli);sin(angoli)]];
D=D./vecnorm(D);
Pinv=P\eye(nc);
rhoMax=deg2rad(60)^2/max(diag(Pinv([1 2 5 6],[1 2 5 6])));
livelli=logspace(log10(rhoCertificato),log10(rhoMax),nLivelli);
rhoBasso=rhoCertificato; rhoAlto=rhoMax;
for j=1:nLivelli
    rapporto=lyapunov_sample_ratios(livelli(j),D,raggi,P,modello);
    if max(rapporto,[],'all')>=-margine
        rhoAlto=livelli(j); break
    end
    rhoBasso=livelli(j);
end
if rhoBasso<rhoAlto
    for j=1:nBisezioni
        medio=sqrt(rhoBasso*rhoAlto);
        rapporto=lyapunov_sample_ratios(medio,D,raggi,P,modello);
        if max(rapporto,[],'all') < -margine
            rhoBasso=medio;
        else
            rhoAlto=medio;
        end
    end
end
rhoNumerico=0.8*rhoBasso;
% 2048 nuove direzioni, con seed indipendente; anche un FAIL va conservato.
rng(seed+100,'twister'); Dv=randn(nc,2048); Dv=Dv./vecnorm(Dv);
verifica=lyapunov_sample_ratios(rhoNumerico,Dv,raggi,P,modello);
fprintf('rho campionato %.8g, max Vdot/||z||^2 indipendente %.6g\n', ...
    rhoNumerico,max(verifica,[],'all'));
% Punti finiti, anche se tutti negativi, NON certificano l'intero ellissoide.


%% 19 - Regione, confronto non lineare e riepilogo H-infinity
H=J'*P*J; angoli=linspace(0,2*pi,361);
ellisse=sqrt(rhoCertificato)*(chol(H)\[cos(angoli);sin(angoli)]);
f=figure('Color','white'); tiledlayout(1,2);
nexttile; plot(rad2deg(ellisse(1,:)),rad2deg(ellisse(2,:)),'LineWidth',1.5);
hold on; plot(0,0,'+k'); axis equal; grid on;
xlabel('Delta q_1(0) [deg]'); ylabel('Delta q_2(0) [deg]');
title('Hinf: sezione del limite analitico nominale');
nexttile; semilogy(tempoNl,max(sum((zNl*P).*zNl,2),realmin)); grid on;
xlabel('Tempo [s]'); ylabel('V(z)'); title('Traiettoria da [5;0] deg, fuori dal certificato');
set_scientific_figure_style(f);
if ~isfile(fullfile(dati,'lyapunov_ras_nominal.mat')), validate_lyapunov_ras; end
archivio=load(fullfile(dati,'lyapunov_ras_nominal.mat'));
assert(abs(rhoNumerico/archivio.risultati{2}.rhoNumerical-1)<1e-5);
plot_lyapunov_ras(archivio.risultati,radice);
fprintf(['Khinf: NS nominale PASS, prestazione pesata FAIL. Il limite interno ' ...
    'Lyapunov e nominale, non robusto M4.\nIl livello campionato non e certificato. ' ...
    'Il calcolo e double, non aritmetica intervallare. Baseline preservata.\n']);
save(fullfile(dati,'didactic_hinf_calculations.mat'),'Pgen','Ak','Bk','Ck','Dk', ...
    'gammaCongelato','gammaRicostruito','crossoverW1','Acl','P','rhoCertificato', ...
    'rhoNumerico','tempoNl','zNl','stabileCampioni','-v7');

%% 20 - Studio diretto a tre pesi, distinto dalla produzione M10
% Rilettura della campagna limitata: nessuna sintesi aggiuntiva.
% G conserva gli ingressi u [N m] e le uscite q [rad].
studio=study_hinf_weights(false);
scelto=studio.selezionato;
ws=studio.selectedSpec;
W1nuovo=((s/ws.Ms+ws.omegaW1)/(s+ws.omegaW1*ws.As))*eye(2);
W2nuovo=ws.controlWeightGain*(s+ws.omegaU)/ ...
    (s/ws.controlWeightAlpha+ws.omegaU)*eye(2);
W3nuovo=studio.pesi{scelto}.W3;
% W3 e un peso di roll-off dello studio: M9/M10 continuano senza W3.
% Non certifica l'incertezza moltiplicativa M4, valutata separatamente.
Pnuovo=[W1nuovo -W1nuovo*G;ss(zeros(2)) W2nuovo; ...
    ss(zeros(2)) W3nuovo*G;ss(eye(2)) -G];
errorePnuovo=max(abs(freqresp(Pnuovo,omega)-freqresp(studio.P,omega)),[],'all');
assert(errorePnuovo<1e-8);
Knuovo=studio.Knuovo;
Tnuovo=feedback(G*Knuovo,ss(eye(2)));
Snuovo=ss(eye(2))-Tnuovo;
KSnuovo=feedback(Knuovo,G);
normeNuove=[norm(W1nuovo*Snuovo,inf),norm(W2nuovo*KSnuovo,inf), ...
    norm(W3nuovo*Tnuovo,inf)];
disp(studio.tabella);
disp('Norme fisiche W1S, W2KS, W3T del compromesso selezionato:'); disp(normeNuove);
% Il PASS e calcolato, senza modificare le soglie: zero candidati conformi.
% W1/W2 selezionati alimentano M5 e la catena M9-M17 rigenerata.
