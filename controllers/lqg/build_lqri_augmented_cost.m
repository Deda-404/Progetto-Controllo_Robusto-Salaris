function design = build_lqri_augmented_cost(m3Data, m5Data, m6Data, wi, ru)
%BUILD_LQRI_AUGMENTED_COST Riccati del servo integrale, senza prefiltro.
%   La sintesi usa xa=[x;xi] e xi_dot=r-Cq*x. Nella realizzazione Kx
%   moltiplica xhat; xi integra l'errore delle posizioni encoder misurate.
%   Ki e il blocco integrale del guadagno LQR, non un parametro manuale.
arguments
    m3Data (1,1) struct
    m5Data (1,1) struct
    m6Data (1,1) struct
    wi (1,1) double {mustBePositive,mustBeFinite}
    ru (1,1) double {mustBePositive,mustBeFinite}
end
% Il modello conserva gli attuatori fra i 14 stati fisici.
A=m3Data.Afull; B=m3Data.Bfull; Cq=m3Data.CfullQ;
n=size(A,1); p=size(Cq,1); m=size(B,2);
assert(isequal([n,p,m],[14,2,2]),'M7LQRI:Dimensions', ...
    'Sono richiesti 14 stati fisici, 2 uscite regolate e 2 comandi.');
Aaug=[A,zeros(n,p);-Cq,zeros(p)];
Baug=[B;zeros(p,m)]; Br=[zeros(n,p);eye(p)];
% Si conserva la scala integrale gia motivata: errore di 5 gradi
% accumulato per il target di 0.8 s. Non e un limite fisico.
% wi e adimensionale; ru pesa direttamente il comando fisico.
xiScale=m5Data.spec.referenceAmplitude*m5Data.spec.settlingTimeTarget;
Qi=(wi/xiScale^2)*eye(p);
Qaug=blkdiag(m6Data.Q,Qi); R=ru*eye(m);
% PBH sui modi non stabili e Rosenbrock all'origine verificano che
% l'aggiunta degli integratori non introduca modi non stabilizzabili.
openPoles=eig(Aaug); pbhRanks=zeros(n+p,1);
for k=1:n+p
    pbhRanks(k)=rank([openPoles(k)*eye(n+p)-Aaug,Baug]);
end
isStabilizable=all(pbhRanks(real(openPoles)>=-1e-8)==n+p);
zeroRank=rank([-Aaug,Baug]);
rosenbrockRank=rank([A,B;Cq,zeros(p,m)]);
assert(isStabilizable && zeroRank==16 && rosenbrockRank==16, ...
    'M7LQRI:Stabilizability','Ostruzione strutturale al servo integrale.');
% Un'unica Riccati determina Kx e Ki; P e i residui restano verificabili.
[Kaug,P,servoPoles]=lqr(Aaug,Baug,Qaug,R);
care=Aaug'*P+P*Aaug-P*Baug*(R\Baug')*P+Qaug;
design=struct('Aaug',Aaug,'Baug',Baug,'Br',Br,'Qaug',Qaug, ...
    'R',R,'P',P,'Kaug',Kaug,'Kx',Kaug(:,1:n),'Ki',Kaug(:,n+(1:p)), ...
    'Qi',Qi,'xiScale',xiScale,'wi',wi,'ru',ru,'servoPoles',servoPoles);
design.careRelativeResidual=norm(care,'fro')/max(1,norm(Qaug,'fro'));
design.gainResidual=norm(Kaug-R\(Baug'*P),'fro');
design.physicalScales=m6Data.validationMetrics.cost.scales;
design.structural=struct('isStabilizable',isStabilizable, ...
    'stabilizabilityRanks',pbhRanks,'zeroPbhRank',zeroRank, ...
    'zeroRosenbrockRank',rosenbrockRank, ...
    'noInvariantZeroObstructionAtZero',rosenbrockRank==16);
assert(design.careRelativeResidual<1e-8 && design.gainResidual<1e-7, ...
    'M7LQRI:RiccatiResidual','Residuo della Riccati o del guadagno eccessivo.');
end
