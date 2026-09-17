function e = hinf_revision_evaluate(G,Bd,K,W1,W2,m5,c)
% Stabilita interna senza minreal; scenari M5, gradini separati da 5 gradi.
[A,B,C,D] = ssdata(G); [Ak,Bk,Ck,Dk] = ssdata(ss(K));
assert(~any(D,'all'),'La pianta congelata deve essere strettamente propria.');
nk = size(Ak,1);
e.Acl = [A-B*Dk*C B*Ck; -Bk*C Ak];
Br = [B*Dk;Bk]; Cr = [C zeros(2,nk);-Dk*C Ck];
e.maxRealPole = max(real(eig(e.Acl)));
e.stable = e.maxRealPole < -c.stabilityTolerance;
e.reference = ss(e.Acl,Br,Cr,[zeros(2);Dk]);
e.disturbance = ss(e.Acl,[Bd;zeros(nk,2)],Cr,zeros(4,2));
e.S = ss(e.Acl,Br,[-C zeros(2,nk)],eye(2));
e.T = e.reference(1:2,:); e.KS = e.reference(3:4,:);
e.weighted = [W1*e.S;W2*e.KS];
e.norms = [inf inf inf]; e.metrics = inf(2,6);
e.responses = cell(2,1); e.disturbanceResponses = cell(2,1);
e.disturbanceMetrics = inf(2,3);
if e.stable
    e.norms = [norm(e.weighted,inf),norm(W1*e.S,inf),norm(W2*e.KS,inf)];
    [e.metrics,e.responses]=hinf_revision_tracking(e.reference,m5,c);
    for j=1:2
        d=zeros(numel(c.time),2); d(:,j)=m5.disturbanceTorqueAmplitude;
        yd=lsim(e.disturbance,d,c.time); e.disturbanceResponses{j}=yd;
        e.disturbanceMetrics(j,:)=[max(abs(yd(:,1:2)),[],'all'), ...
            max(abs(yd(:,3:4)),[],'all'),sqrt(mean(yd(:,3:4).^2,'all'))];
    end
end
v=max(e.metrics,[],1);
e.nominalPerformance = e.stable && e.norms(1)<1;
e.m5Temporal = e.stable && all(v(1:4)<=[m5.settlingTimeTarget, ...
    m5.overshootTarget,m5.steadyStateTrackingTarget,m5.crossCouplingTarget]);
e.revisedTemporal = e.stable && all(v(1:4)<=[c.revised.settlingTime, ...
    c.revised.overshootPercent,c.revised.steadyErrorRelative,c.revised.crossCoupling]);
% Cross-coupling M5 resta un target preliminare; picco/RMS sono diagnostici.
end
