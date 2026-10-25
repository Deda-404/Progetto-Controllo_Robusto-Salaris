function p = parametri_sea
%PARAMETRI_SEA Unica fonte delle ipotesi approvate del progetto S1.
% Cambiare solo modalita per passare da caricamento a ricalcolo completo.
p.modalita="rapida"; % "rapida" oppure "completa"
p.figure=true;       % false per calcolo senza finestre
p.m1=1; p.m2=.8; p.l1=.4; p.l2=.3; p.g=9.81;
p.Jm=diag([.01 .01]); p.Bm=diag([.02 .02]); p.Ks=diag([50 40]);
p.qbar=[pi/2;0]; p.wn=40; p.zeta=.8; p.tau=.015;
p.rwn=.10; p.rzeta=.10; % indipendenti sui due attuatori; tau noto
p.wmin=p.wn*(1-p.rwn); p.wmax=p.wn*(1+p.rwn);
p.zmin=p.zeta*(1-p.rzeta); p.zmax=p.zeta*(1+p.rzeta);
p.alphaMax=max(abs([p.wmin p.wmax].^2/p.wn^2-1));
p.betaMax=max(abs(2*p.zeta/p.wn*[p.wmin p.wmax].^2- ...
    2*[p.zmin;p.zmax]*[p.wmin p.wmax]),[],'all');
p.cWI=hypot(p.alphaMax,p.betaMax/p.wmin)/p.zmin;
p.omega=logspace(-2,4,401); p.time=(0:.005:12)';
p.reference=deg2rad(5); p.disturbance=.5;
p.TsTarget=.8; p.overshootTarget=10; p.dcTarget=.05;
p.omegaB=12; p.uScale=12; % scale/target, nessuna saturazione hardware
p.omegaW1=2; p.As=.15; p.Ms=3; p.ku=.003; p.omegaU=80;
p.alphaU=6; p.omegaM=4; p.sigmaY=deg2rad(.05);
p.seed=20261025; p.dkIterations=4; p.dkFitOrder=[2 1];
p.samples=[0 0 0 0;-1 -1 -1 -1;1 1 1 1;-1 1 1 -1;1 -1 -1 1; ...
    -.5 .5 .25 -.75;.5 -.5 -.25 .75;-.75 -.25 .75 .25; ...
    .25 .75 -.5 -.25;.75 -.75 -.75 .75];
% Stato iniziale: dtheta=dq; tutte le velocita, drive e controller nulli.
p.rasPointsDeg=[0 0;5 0;-5 0;0 5;0 -5;15 0;0 15;15 15; ...
    -15 -15;30 0;0 30;30 -30;-30 30;45 0;0 45];
p.rasPositionTol=deg2rad(.5); p.rasVelocityTol=.02;
p.solverSeconds=35; p.solverRelTol=1e-6; p.solverAbsTol=1e-9;
assert(ismember(p.modalita,["rapida","completa"]));
end
