function metriche=rumore_continuo_sea(sys,v,t)
% Propagazione ZOH esatta, ripresa dalla diagnostica originale del progetto.
% La scansione temporale verifica picchi osservati; non un massimo rigoroso.
dt=t(2)-t(1); [T,A]=balance(sys.A); modello=ss(A,T\sys.B,sys.C*T,sys.D);
[y,~,x]=lsim(c2d(modello,dt,'zoh'),v,t);
ultimo=NaN; errore=Inf; picco=0;
for risoluzione=[80 160 320]
    tau=unique([0 logspace(-14,log10(dt),risoluzione) linspace(0,dt,40)]);
    energia=zeros(numel(tau),1);
    for h=1:numel(tau)
        if tau(h)==0
            yy=x(1:end-1,:)*modello.C'+v(1:end-1,:)*modello.D';
        else
            sub=c2d(modello,tau(h),'zoh');
            yy=(x(1:end-1,:)*sub.A'+v(1:end-1,:)*sub.B')*sub.C'+v(1:end-1,:)*sub.D';
        end
        uu=yy(:,3:4); energia(h)=sum(uu.^2,'all'); picco=max(picco,max(abs(uu),[],'all'));
    end
    rmsIntegrato=sqrt(trapz(tau,energia)/(2*t(end)));
    errore=abs(rmsIntegrato-ultimo)/max(rmsIntegrato,eps);
    if errore<.02,break;end
    ultimo=rmsIntegrato;
end
assert(errore<.02,'SEA:Rumore','Quadratura RMS non convergente.');
metriche=[max(abs(y(:,3:4)),[],'all'),sqrt(mean(y(:,3:4).^2,'all')), ...
    picco,rmsIntegrato,errore,max(abs(y(:,1:2)),[],'all')];
end
