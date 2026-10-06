%% 1 - Pulizia e caricamento dati: LQR -> Kalman -> LQG -> Lyapunov
% Si ricostruisce la griglia approvata: criteri invariati, tre pesi R diretti.
clearvars; clc; close all;
radice=fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(radice,'src')),genpath(fullfile(radice,'controllers')), ...
    genpath(fullfile(radice,'analysis')));
dati=fullfile(radice,'results','data');
m3=load(fullfile(dati,'m3_nominal_actuated_plant.mat'));
m5=load(fullfile(dati,'m5_performance_specs.mat'));
m6=load(fullfile(dati,'m6_lqg_no_integrator.mat'));
spec=m5.spec;

%% 2 - Modello linearizzato, in deviazione dall'equilibrio
% x=[dq;dqdot;dtheta;dthetadot;xa], 14 stati, qbar=[pi/2;0].
% Posizioni: rad. Velocita: rad/s. xa: sei coordinate della realizzazione
% ss degli attuatori, NON angoli aggiuntivi o stati fisici misurati.
A=m3.Afull; B=m3.Bfull; C=m3.CfullMeas; Cq=m3.CfullQ;
Bd=m5.BdFull; n=size(A,1); m=size(B,2);
G=ss(A,B,C,zeros(4,2));
disp('Poli della pianta:'); disp(eig(A));

%% 3 - Controllabilita e osservabilita
% Le potenze di A possono dare rango numerico spurio. Riscalare il tempo
% non cambia il rango matematico. Si mostra anche il test PBH validato M3.
scalaFrequenza=m3.structuralMetricsMeas.scaledTime.frequencyScale;
ranghi=[rank(ctrb(A,B)),rank(obsv(A,C)); ...
    rank(ctrb(A/scalaFrequenza,B)),rank(obsv(A/scalaFrequenza,C))];
disp('Ranghi [controllabilita osservabilita], grezzi e riscalati:'); disp(ranghi);
disp(m3.structuralMetricsMeas.controllability);
disp(m3.structuralMetricsMeas.observability);

%% 4 - Specifiche di progetto e provenienza
% A: imposto dalla traccia; B: derivazione matematica; C: derivazione fisica;
% D: scelta progettuale; E: risultato di ricerca. M5 e una scelta D.
% Gradino 5 deg, banda 12 rad/s, disturbo 0.5 N m, uScale=12 N m.
% Ts<=0.8 s, overshoot<=10%, errore statico<=5%; cross<=25% diagnostico.
% uScale NON e una saturazione hardware.
disp(spec);

%% 5 - Scale fisiche, NON pesi adimensionali
qs=spec.referenceAmplitude;            % 5*pi/180 rad, scala q (C da M5-D)
qds=spec.omegaB*qs;                    % 1.04719755 rad/s (C)
ds=spec.disturbanceTorqueAmplitude/min(diag(m3.mechanicalParams.Ks));
tds=qds;                              % stessa scala velocita motore (D/C)
% ds=0.5/40=0.0125 rad: deformazione nella molla piu cedevole.
% Stessa scala per entrambi i giunti: non un limite fisico.
% qs e SOLO una scala in rad, come scales.q in build_lqr_state_cost.
% wq sara invece un peso di tuning, scelto fra candidati adimensionali.
% v=F*x=[dq;dqdot;dtheta-dq;dthetadot], v_tilde=Sx\v.
F=zeros(8,n); F(1:4,1:4)=eye(4);
F(5:6,1:2)=-eye(2); F(5:6,5:6)=eye(2); F(7:8,7:8)=eye(2);
Sx=diag([qs qs qds qds ds ds tds tds]);
disp('Scale degli stati [qs qds ds tds]:'); disp([qs qds ds tds]);

%% 6 - Q e ricerca parametrica approvata, esplicitamente ricostruita
% J=int(x'Qx+u'Ru)dt: errore/deformazione contro sforzo attuativo.
% Q=F'*Sx^(-T)*Wq*Sx^(-1)*F=Ccost'*Ccost. NON e diagonale:
% (theta-q)^2 genera termini incrociati. xa non ha pesi diretti arbitrari.
% Griglia e score sono scelte D; il punto selezionato e un risultato E.
[gq,gv,gd,gu]=ndgrid([0.5 1 2],[0.5 1],[0.1 0.5],[0.01 0.05 0.10]);
pesiScore=[0.30;0.20;0.10;0.10;0.15;0.15];
config=lqg_specs_m6; % il valutatore riusa solo tempi e soglie del progetto
indici=inf(numel(gq),1); ammissibili=false(numel(gq),1);
for j=1:numel(gq)
    Wq=diag([gq(j) gq(j) gv(j) gv(j) gd(j) gd(j) gv(j) gv(j)]);
    Qj=F'*(Sx'\Wq/Sx)*F;
    Rj=gu(j)*eye(m); % penalizzazione diretta del comando fisico
    Kj=lqr(A,B,Qj,Rj); Aj=A-B*Kj;
    Nrj=(-Cq*(Aj\B))\eye(m);
    % Due gradini separati, 0:0.002:3 s, x(0)=0, d=v=0.
    % Ts: banda 2% attorno al valore DC; overshoot rispetto al riferimento;
    % cross: picco giunto non comandato/picco giunto comandato.
    % Picco: max(abs(u)); RMS: sqrt(mean(u.^2,'all')). Peggiore dei 2 casi.
    prova=evaluate_m6_closed_loop(A,B,Cq,C(3:4,:),Bd,Kj,Nrj, ...
        m3.mechanicalParams.Ks,spec,config,false);
    esito=prova.summary;
    ammissibili(j)=all(real(eig(Aj)) < -1e-8) && ...
        esito.worstSettlingTime<=spec.settlingTimeTarget && ...
        esito.worstOvershoot<=spec.overshootTarget && ...
        esito.worstSteadyStateErrorRelative<=spec.steadyStateTrackingTarget && ...
        isfinite(norm(-Cq*(Aj\B)*Nrj-eye(m),'fro'));
    if ammissibili(j)
        metriche=[esito.worstSettlingTime/spec.settlingTimeTarget; ...
            esito.worstOvershoot/spec.overshootTarget; ...
            esito.worstSteadyStateErrorRelative/spec.steadyStateTrackingTarget; ...
            esito.worstCrossCouplingPeakRatio/spec.crossCouplingTarget; ...
            esito.worstPeakControl/spec.uScale;esito.worstRmsControl/spec.uScale];
        indici(j)=pesiScore'*metriche;
    end
end
[indiceFinale,j]=min(indici);
wq=gq(j); wv=gv(j); wd=gd(j); ru=gu(j);
Wq=diag([wq wq wv wv wd wd wv wv]);
Ccost=sqrt(Wq)*(Sx\F); Q=Ccost'*Ccost;
fprintf('LQR%02d: %d/36 ammissibili, score %.9g\n',j,sum(ammissibili),indiceFinale);
disp('Q finale:'); disp(Q);

%% 7 - R: peso diretto dello sforzo di controllo
% u contiene coppie in N m; ru moltiplica direttamente u'*u.
% I valori {0.01,0.05,0.10} esplorano tre livelli progettuali semplici.
% Il valore finale deriva dai criteri numerici, non e imposto a priori.
R=ru*eye(m);
disp('ru e R:'); disp(ru); disp(R);

%% 8 - Q/R -> Riccati -> K -> poli
[K,Plqr,poliLqr]=lqr(A,B,Q,R);
residuoCare=A'*Plqr+Plqr*A-Plqr*B*(R\B')*Plqr+Q;
erroreK=norm(K-R\(B'*Plqr),'fro');
Nr=(-Cq*((A-B*K)\B))\eye(m); % guadagno statico nominale r->q uguale a I
disp('K finale (2x14):'); disp(K); disp('Nr:'); disp(Nr);

%% 9 - Stabilita e identita del regolatore congelato
assert(all(real(poliLqr)<0));
assert(norm(K-m6.K,'fro')<1e-6 && norm(Q-m6.Q,'fro')<1e-8);
assert(norm(R-m6.R,'fro')<1e-12);
fprintf('Residuo CARE %.3g; errore K %.3g; max Re poli %.6g\n', ...
    norm(residuoCare,'fro'),erroreK,max(real(poliLqr)));
disp(poliLqr);

%% 10 - Perche Kalman: non tutto lo stato e misurato
% xdot=A*x+B*u+Gw*w, y=C*x+v. Gw=[Bd B].
% w=[d1 d2 eta_u1 eta_u2]': coppie lato link e coppie equivalenti in ingresso.
% xhat_dot=A*xhat+B*u+L*(y-C*xhat): innovazione = misura - previsione.
Gw=[Bd B];
sigmaD=0.1; sigmaU=0.1; sigmaYdeg=0.05; sigmaY=deg2rad(sigmaYdeg);
% Ipotesi progettuali D, NON dati del docente o di un sensore identificato.
% 0.1 N m e il 20% del disturbo M5 e lo 0.83% di uScale; 0.05 deg e
% l'1% del gradino M5. Questi rapporti contestualizzano scelte gia esistenti:
% NON le derivano retroattivamente. La sensibilita ne verifica le conseguenze.

%% 11 - Qn e Rn: varianza = sigma^2
Qn=diag([sigmaD^2 sigmaD^2 sigmaU^2 sigmaU^2]); % 0.01*I4, non 0.12*I4
Rn=sigmaY^2*eye(4);                         % 7.615435e-7*I4
% lqe e continuo: Qn/Rn sono intensita del modello bianco idealizzato.
% Le sigma sono scale equivalenti nella convenzione temporale di 1 s.
% randn campionato a 2 ms NON identifica tali intensita: e una prova
% numerica a banda finita, non una calibrazione sperimentale del sensore.
disp('Qn, Rn:'); disp(Qn); disp(Rn);

%% 12 - Guadagno L e poli A-LC
[L,Pkalman,poliKalman]=lqe(A,Gw,C,Qn,Rn);
disp('L finale (14x4):'); disp(L); disp('Poli A-LC:'); disp(poliKalman);
assert(norm(L-m6.L,'fro')<1e-6 && all(real(eig(A-L*C))<0));

%% 13 - Sensibilita a Rn, con la STESSA sequenza fisica di rumore
% Varia solo la covarianza assunta dallo stimatore. K resta invariato.
fattori=[0.5;1;2]; tempo=(0:0.002:4)';
rng(20260826,'twister'); rumore=sigmaY*randn(numel(tempo),4);
ingressi=[spec.referenceAmplitude*ones(numel(tempo),1), ...
    zeros(numel(tempo),3),rumore];
velocita=zeros(3,1); erroreRms=velocita; comandoRms=velocita; normaH2=velocita;
for j=1:3
    Lj=lqe(A,Gw,C,Qn,(fattori(j)*sigmaY)^2*eye(4));
    Aj=[A -B*K;Lj*C A-B*K-Lj*C];
    Bj=[B*Nr Bd zeros(n,4);B*Nr zeros(n,2) Lj];
    Cj=[Cq -Cq;zeros(m,n) -K]; Dj=[zeros(2,8);Nr zeros(m,6)];
    sysj=ss(Aj,Bj,Cj,Dj);
    yj=lsim(sysj,ingressi,tempo);
    y0=lsim(sysj,[ingressi(:,1:4),zeros(numel(tempo),4)],tempo);
    velocita(j)=min(-real(eig(A-Lj*C)))/min(-real(poliLqr));
    erroreRms(j)=sqrt(mean(yj(:,1:2).^2,'all'));
    comandoRms(j)=sqrt(mean((yj(:,3:4)-y0(:,3:4)).^2,'all'));
    normaH2(j)=norm(ss(A-Lj*C,-Lj,Ccost,zeros(8,4)),2);
end
sensibilita=table(fattori,velocita,erroreRms,comandoRms,normaH2);
disp(sensibilita);
% Aumentare Rn tende a filtrare maggiormente le misure. In MIMO non ogni
% elemento di L o polo deve variare monotonicamente: contano anche Gw e C.

%% 14 - LQG aumentato e principio di separazione
% z=[x;xhat], u=-K*xhat+Nr*r. In [x;e=x-xhat] la matrice e triangolare:
% [A-BK BK;0 A-LC]. I poli sono l'unione di quelli di regolatore e stimatore.
Acl=[A -B*K;L*C A-B*K-L*C];
Bcl=[B*Nr Bd zeros(n,4);B*Nr zeros(n,2) L];
Ccl=[Cq zeros(2,n);zeros(2,n) -K;Cq -Cq];
Dcl=[zeros(2,8);Nr zeros(2,6);zeros(2,8)];
chiuso=ss(Acl,Bcl,Ccl,Dcl);
Trasf=[eye(n) zeros(n);eye(n) -eye(n)];
erroreSeparazione=norm(Trasf*Acl/Trasf-[A-B*K B*K;zeros(n) A-L*C],'fro');
assert(erroreSeparazione<1e-8);

%% 15 - Tracking: r1=5 deg, r2=0, x(0)=xhat(0)=0, d=v=0
riferimento=zeros(numel(tempo),8); riferimento(:,1)=spec.referenceAmplitude;
y=lsim(chiuso,riferimento,tempo);
f=figure('Color','white'); tiledlayout(3,1);
nexttile; plot(tempo,rad2deg(y(:,1:2))); hold on; yline(5,'--k');
grid on; ylabel('Delta q [deg]'); legend('q_1','q_2','r_1');
title('LQG: riferimento 5 deg, condizioni iniziali nulle');

%% 16 - Errore di stima con i quattro encoder rumorosi
yRumore=lsim(chiuso,ingressi,tempo);
nexttile; plot(tempo,rad2deg(yRumore(:,5:6)));
grid on; ylabel('q-qhat [deg]'); legend('e_{q1}','e_{q2}');

%% 17 - Azione di controllo: coppie, non frazione di saturazione
nexttile; plot(tempo,y(:,3:4)); grid on;
xlabel('Tempo [s]'); ylabel('u [N m]'); legend('u_1','u_2');
set_scientific_figure_style(f);

%% 18 - Non lineare: controllore e attuatori sono parte dello stato
% RAS: r=d=v=0. xhat non viene eliminato. La RHS riusa la meccanica M1.
[Aa,Ba,Ca,Da]=ssdata(m3.GactuatorsMimo);
modello=struct('Ac',A-B*K-L*C,'Bc',L,'Cc',-K,'Dc',zeros(2,4), ...
    'Cy',C,'Aact',Aa,'Bact',Ba,'Cact',Ca,'Dact',Da, ...
    'xbar',m3.xbar,'taubar',m3.taubar,'parametri',m3.mechanicalParams, ...
    'residuoEquilibrio',sea_nonlinear_rhs(m3.xbar,m3.taubar,m3.mechanicalParams));
fcl=@(z) sea_closed_loop_rhs(z,modello);
J=zeros(2*n,2); J(1:2,:)=eye(2); J(5:6,:)=eye(2);
z0=J*deg2rad([5;0]); % dtheta=dq; velocita, attuatori, xhat nulli
opzioni=odeset('RelTol',1e-7,'AbsTol',1e-10,'MaxStep',0.005);
[tempoNl,zNl]=ode23t(@(~,z) fcl(z),[0 8],z0,opzioni);

%% 19 - Lyapunov lineare e maggiorazione analitica nominale
% lyap(A,Q) risolve A*P+P*A'=-Q: occorre passare Acl'.
QL=eye(2*n); P=lyap(Acl',QL); P=(P+P')/2;
assert(min(eig(P))>0);
V=@(z) z'*P*z;
Vdot=@(z) 2*z'*P*fcl(z);
% Solo Acl Hurwitz NON prova stabilita non lineare globale.
% Al nostro equilibrio il resto r agisce solo sulle accelerazioni link:
% ||r(z)||<=c*||z||^3. lyapunov_cubic_bound espone la maggiorazione da
% |1-cos(t)|<=t^2/2 e |sin(t)-t|<=|t|^3/6, senza ricerca/ottimizzazione.
limite=lyapunov_cubic_bound(Acl,P,m3);
E=zeros(2*n,2); E(3:4,:)=eye(2);
residuo=norm(Acl'*P+P*Acl+QL,2);
delta2=(1-residuo)/(4*norm(P*E,2)*limite.c);
rhoCertificato=min(eig(P))*delta2;
% V<=rhoCertificato => ||z||^2<=delta2, quindi
% Vdot<=-(1-residuo)/2*||z||^2<0 per ogni z diverso da zero nell'insieme.
fprintf('eig(P)=[%.6g %.6g], residuo %.3g, c=%.6g, rho interno=%.9g\n', ...
    min(eig(P)),max(eig(P)),residuo,limite.c,rhoCertificato);

%% 20 - Ricerca numerica di rho, esplicita e riproducibile
% Gli stessi parametri sono usati per tutti i controllori dal validator.
seed=20260909; nDirezioni=512; nPiano=72;
raggi=[0.25;0.5;0.75;1]; margine=0.05; nLivelli=49; nBisezioni=12;
rng(seed,'twister');
angoli=(0:nPiano-1)*2*pi/nPiano;
D=[eye(2*n),-eye(2*n),randn(2*n,nDirezioni), ...
    chol(P)*J*[cos(angoli);sin(angoli)]];
D=D./vecnorm(D);
Pinv=P\eye(2*n);
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
rng(seed+100,'twister'); Dv=randn(2*n,2048); Dv=Dv./vecnorm(Dv);
verifica=lyapunov_sample_ratios(rhoNumerico,Dv,raggi,P,modello);
fprintf('rho campionato %.8g, max Vdot/||z||^2 indipendente %.6g\n', ...
    rhoNumerico,max(verifica,[],'all'));
% Punti finiti, anche se tutti negativi, NON certificano l'intero ellissoide.

%% 21 - Sezione z=J*dq, non proiezione e non piano invariante
H=J'*P*J; angoli=linspace(0,2*pi,361);
ellisse=sqrt(rhoCertificato)*(chol(H)\[cos(angoli);sin(angoli)]);
f=figure('Color','white'); tiledlayout(1,2);
nexttile; plot(rad2deg(ellisse(1,:)),rad2deg(ellisse(2,:)),'LineWidth',1.5);
hold on; plot(0,0,'+k'); axis equal; grid on;
xlabel('Delta q_1(0) [deg]'); ylabel('Delta q_2(0) [deg]');
title('Regione interna: limite analitico nominale');
nexttile; semilogy(tempoNl,max(sum((zNl*P).*zNl,2),realmin)); grid on;
xlabel('Tempo [s]'); ylabel('V(z)'); title('Simulazione da [5;0] deg (fuori dal certificato)');
set_scientific_figure_style(f);
if ~isfile(fullfile(dati,'lyapunov_ras_nominal.mat')), validate_lyapunov_ras; end
archivio=load(fullfile(dati,'lyapunov_ras_nominal.mat'));
assert(abs(rhoNumerico/archivio.risultati{1}.rhoNumerical-1)<1e-5);
plot_lyapunov_ras(archivio.risultati,radice);

%% 22 - Riepilogo e limiti
% progetto_lqgi.m espone il servo M7 con lo stesso Kalman M6:
% Riccati -> Kx/Ki -> xhat e integrale(r-q_mis) -> chiusura a 30 stati.
% Nessun prefiltro M7; prove nominali, non certificazione robusta.
disp(m6.trackingMetrics); disp(m6.disturbanceMetrics);
fprintf(['Certificato interno nominale e conservativo, valutato in double, ' ...
    'non con aritmetica intervallare.\nLivello campionato non certificato. ' ...
    'M7 resta PARTIAL; M16 empirica; la RS incerta proviene da M14.\n']);
save(fullfile(dati,'didactic_lqg_calculations.mat'),'Q','R','K','Plqr','Nr', ...
    'Sx','ru','Wq','F','qs','Qn','Rn','L','Pkalman','poliLqr', ...
    'poliKalman','erroreSeparazione','residuoCare','sensibilita','tempoNl','zNl','-v7');
