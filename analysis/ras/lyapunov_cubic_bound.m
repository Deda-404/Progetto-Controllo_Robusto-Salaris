function limite = lyapunov_cubic_bound(Acl, P, m3)
%LYAPUNOV_CUBIC_BOUND Maggiorazione analitica del resto non lineare SEA.
% All'equilibrio [pi/2;0], f(z)=Acl*z+E*r(z), E=I(:,3:4).
% Le sole accelerazioni dei link sono non lineari. Con la norma euclidea
% dei valori numerici SI nelle coordinate M3/controller, ||r||<=c*||z||^3.
% Il certificato riguarda SOLO il modello nominale senza saturazione e
% con Pade 1; non il ritardo esatto, l'hardware o l'insieme incerto M4.
arguments
    Acl (:,:) double
    P (:,:) double
    m3 (1,1) struct
end
assert(norm(m3.qbar-[pi/2;0])<1e-12, 'Lyapunov:Equilibrium', ...
    'Il limite cubico richiede esattamente l''equilibrio M2.');
p = m3.mechanicalParams;
b = p.m2*p.l1*p.l2;
a = (p.m1+p.m2)*p.g*p.l1;
d = p.m2*p.g*p.l2;
% det(M)>=m1*m2*l1^2*l2^2; lambda_max(M)<=trace_max(M).
detMin = p.m1*p.m2*p.l1^2*p.l2^2;
traceMax = (p.m1+p.m2)*p.l1^2 + 2*p.m2*p.l2^2 + 2*b;
inversaM = traceMax/detMin;
% |1-cos(q2)|<=q2^2/2; ||[2 1;1 0]||=1+sqrt(2).
variazioneM = b*(1+sqrt(2))/2;
% ||C(q,v)*v|| <= sqrt(3)*b*|q2|*||v||^2.
coriolis = sqrt(3)*b;
% |sin(t)-t|<=|t|^3/6, |dq1+dq2|<=sqrt(2)*||dq||.
gravita = (a+4*d)/6;
accelerazioneLineare = norm(m3.Amechanical(3:4,:),2);
c = inversaM*(variazioneM*accelerazioneLineare+coriolis+gravita);
n = size(Acl,1);
E = zeros(n,2); E(3:4,:) = eye(2);
residuo = norm(Acl'*P+P*Acl+eye(n),2);
lambdaP = min(eig((P+P')/2));
assert(lambdaP>0 && residuo<0.1, 'Lyapunov:Numerics', ...
    'P deve essere positiva e il residuo deve lasciare un margine.');
% Vdot <= -(1-residuo)||z||^2 + 2||P*E|| c ||z||^4.
% Si conserva meta del margine lineare, senza cercare un massimo globale.
raggio2 = (1-residuo)/(4*norm(P*E,2)*c);
rho = lambdaP*raggio2;
limite = struct('c',c,'inverseInertiaBound',inversaM, ...
    'inertiaVariationCoefficient',variazioneM,'coriolisCoefficient',coriolis, ...
    'gravityCoefficient',gravita,'linearAccelerationNorm',accelerazioneLineare, ...
    'residualNorm',residuo,'lambdaMinP',lambdaP, ...
    'lambdaMaxP',max(eig(P)),'normPE',norm(P*E,2), ...
    'stateRadius',sqrt(raggio2),'rhoCertified',rho, ...
    'decayMargin',(1-residuo)/2);
end
