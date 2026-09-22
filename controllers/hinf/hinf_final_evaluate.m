function e = hinf_final_evaluate(physical,K,We,Wu,Mo,spec,c,architecture)
%HINF_FINAL_EVALUATE Realizzazione completa u=Kr*r+Ky*q, senza minreal.
[A,B,C,D]=ssdata(ss(physical)); [Ak,Bk,Ck,Dk]=ssdata(ss(K));
assert(isequal(size(K),[2 4]) && ~any(D,'all'),'Dimensioni/feedthrough inattesi.');
Bu=B(:,1:2); Bd=B(:,3:4); nk=size(Ak,1);
Brk=Bk(:,1:2); Bqk=Bk(:,3:4); Dr=Dk(:,1:2); Dq=Dk(:,3:4);
e.Acl=[A+Bu*Dq*C Bu*Ck;Bqk*C Ak];
e.poles=eig(e.Acl); e.controllerPoles=pole(K); e.order=order(K);
e.maxRealPole=max(real(e.poles)); e.stable=e.maxRealPole<-c.stabilityTolerance;
Cr=[C zeros(2,nk);Dq*C Ck];
e.reference=ss(e.Acl,[Bu*Dr;Brk],Cr,[zeros(2);Dr]);
e.disturbance=ss(e.Acl,[Bd;zeros(nk,2)],Cr,zeros(4,2));
e.T=e.reference(1:2,:); e.UR=e.reference(3:4,:);
e.QD=e.disturbance(1:2,:); e.UD=e.disturbance(3:4,:);
% Sensitivity feedback e KS feedback: iniezione fittizia soltanto per
% diagnostica S, mai usata al posto della coppia fisica Bd in sintesi.
feedbackReference=ss(e.Acl,[-Bu*Dq;-Bqk],Cr,[zeros(2);-Dq]);
e.S=eye(2)-feedbackReference(1:2,:); e.KS=feedbackReference(3:4,:);
if architecture=="1DOF"
    e.weighted=[We*(eye(2)-e.T);Wu*e.UR];
else
    e.weighted=[We*(e.T-Mo),We*e.QD;Wu*e.UR,Wu*e.UD];
end
e.norms=[inf inf inf]; e.metrics=inf(2,6); e.responses=cell(2,1);
e.disturbanceResponses=cell(2,1); e.disturbanceMetrics=inf(2,4);
e.dc=nan(2);
if e.stable
    e.norms=[norm(e.weighted,inf),norm(e.weighted(1:2,:),inf),norm(e.weighted(3:4,:),inf)];
    e.dc=dcgain(e.T);
    [e.metrics,e.responses]=hinf_revision_tracking(e.reference,spec,c);
    for j=1:2
        d=zeros(numel(c.time),2); d(:,j)=spec.disturbanceTorqueAmplitude;
        y=lsim(e.disturbance,d,c.time); e.disturbanceResponses{j}=y;
        e.disturbanceMetrics(j,:)=[max(abs(y(:,1:2)),[],'all'), ...
            max(abs(y(:,3:4)),[],'all'),sqrt(mean(y(:,3:4).^2,'all')), ...
            max(abs(dcgain(e.QD(:,j))*spec.disturbanceTorqueAmplitude))];
    end
end
v=max(e.metrics,[],1);
e.m5Ratios=v(1:4)./[spec.settlingTimeTarget,spec.overshootTarget, ...
    spec.steadyStateTrackingTarget,spec.crossCouplingTarget];
e.m5Failures=sum(e.m5Ratios>1);
e.m5Temporal=e.stable && e.m5Failures==0;
e.revisedTemporal=e.stable && all(v(1:4)<=[c.revised.settlingTime, ...
    c.revised.overshootPercent,c.revised.steadyErrorRelative,c.revised.crossCoupling]);
e.NP=e.stable && e.norms(1)<1;
e.peakAbove12=v(5)>spec.uScale;
end
