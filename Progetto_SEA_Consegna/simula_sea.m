function result = simula_sea(p,plant,K,z0,r,d)
%SIMULA_SEA Integra meccanica non lineare, drive e controllore completo.
% z=[deviazioni meccaniche(8);drive(6);xc]; r e d sono coppie di valori.
% r e costante da t=0; d e applicato a t=1. Nessuna saturazione o rumore.
[Ak,Bk,Ck,Dk]=ssdata(K); nk=size(Ak,1); ny=size(K,2)-2;
Cy=plant.C(1:ny,:); By=Bk(:,3:end); Dy=Dk(:,3:end);
Acl=[plant.A+plant.Bu*Dy*Cy,plant.Bu*Ck;By*Cy,Ak];
[T,Ab]=balance(Acl); [Aa,Ba,Ca,Da]=ssdata(plant.act);
assert(numel(z0)==14+nk && numel(r)==2 && numel(d)==2);
clockStart=tic;
result=struct('status',"NUMERICAMENTE_INCONCLUDENTE",'completed',false, ...
    'time',[],'q',[],'u',[],'states',[],'message',"");
try
    opt=odeset('RelTol',p.solverRelTol,'AbsTol', ...
        p.solverAbsTol./max(sum(abs(T),1)',eps),'MaxStep',.02,'Jacobian',Ab);
    [time,zb]=ode15s(@rhs,p.time,T\z0,opt); z=zb*T';
    result.completed=abs(time(end)-p.time(end))<1e-10;
    result.time=time; result.q=z(:,1:2); result.states=z;
    result.u=z(:,15:end)*Ck'+z(:,1:14)*Cy'*Dy'+(Dk(:,1:2)*r)';
    if result.completed
        result.status="COMPLETATA";
    else
        result.message="Il solver non ha raggiunto l'orizzonte richiesto.";
    end
catch err
    result.message=string(err.identifier)+": "+string(err.message);
end
result.seconds=toc(clockStart);
    function dz=rhs(t,zb)
        if toc(clockStart)>p.solverSeconds
            error('SEA:TempoSolver','Limite numerico; convergenza ignota.');
        end
        z=T*zb; x=z(1:14); xc=z(15:end);
        comando=Ck*xc+Dk(:,1:2)*r+Dy*Cy*x;
        tau=Ca*x(9:14)+Da*comando;
        dm=dinamica_sea(plant.xbar+x(1:8),plant.taubar+tau,d*(t>=1),p);
        dz=T\[dm;Aa*x(9:14)+Ba*comando;Ak*xc+Bk(:,1:2)*r+By*Cy*x];
    end
end
