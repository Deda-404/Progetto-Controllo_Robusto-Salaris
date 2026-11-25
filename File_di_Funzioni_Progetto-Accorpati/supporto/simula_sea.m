function risultato=simula_sea(K,modello,p,scenario,attuatori)
%SIMULA_SEA Simulazione non lineare in anello chiuso (Capitolo 10, RAS).
%
% Integra insieme: dinamica non lineare del manipolatore (dinamica_sea),
% drive lineari (attuatori, 6 stati) e controllore K lineare. Lo stato
% simulato e lo scostamento dall'equilibrio: z=[dx (8); drive (6); K (nk)].
% La coppia applicata e taubar + uscita dei drive: il controllore lavora
% sugli scostamenti, come nel progetto lineare.
% scenario.r: gradino di riferimento; scenario.d: disturbo di coppia;
% scenario.dq: condizione iniziale (RAS); scenario.tempo: orizzonte.
% Solver: ode15s (sistema rigido: molle SEA e drive veloci) con Jacobiano
% calcolato per differenze centrali, tolleranze RelTol 1e-6, AbsTol 1e-9.
% L'evento "evento" ferma l'integrazione se lo stato supera le soglie di
% divergenza; il timer ferma calcoli troppo lunghi (TIMEOUT, che non e una
% prova di instabilita).
arguments
    K
    modello (1,1) struct
    p (1,1) struct
    scenario (1,1) struct
    attuatori = modello.attuatori
end
[Aa,Ba,Ca,Da]=ssdata(attuatori); [Ak,Bk,Ck,Dk]=ssdata(K);
[Tk,Ak]=balance(Ak); Bk=Tk\Bk; Ck=Ck*Tk; % Similitudine, nessuna riduzione.
ny=size(K,2)-2; nk=size(Ak,1);
if ~isfield(scenario,'dq'),scenario.dq=zeros(2,1);end
if ~isfield(scenario,'r'),scenario.r=zeros(2,1);end
if ~isfield(scenario,'d'),scenario.d=zeros(2,1);end
if ~isfield(scenario,'tempo'),scenario.tempo=p.rasTempo;end
% dtheta=dq conserva la deformazione; velocita nulle e drive all'equilibrio.
% Osservatori inizialmente all'equilibrio (spostamento non noto), xi=0.
z0=[scenario.dq;zeros(2,1);scenario.dq;zeros(8+nk,1)];
tempo=scenario.tempo; timer=tic; arresto=""; messaggio=""; t=0; z=z0';
opts=odeset('RelTol',1e-6,'AbsTol',1e-9,'MaxStep',.01,'Events',@evento,'Jacobian',@jacobiano);
try
    [t,z]=ode15s(@rhs,tempo,z0,opts);
    if any(~isfinite(z),'all'),arresto="ERRORE_NUMERICO";end
    if t(end)<tempo(end)-1e-8 && arresto=="",arresto="ERRORE_NUMERICO";end
catch err
    if strcmp(err.identifier,'SEA:Timeout'),arresto="TIMEOUT";
    else,arresto="ERRORE_NUMERICO";end
    messaggio=string(err.message);
end
q=z(:,1:2); u=zeros(size(q));
for j=1:numel(t)
    y=[z(j,1:2),z(j,5:6)]';
    u(j,:)=(Ck*z(j,15:end)'+Dk*[scenario.r;y(1:ny)])';
end
coda=t>=max(0,t(end)-1); convergenza=false;
if arresto=="" && all(scenario.r==0) && all(scenario.d==0)
    convergenza=max(abs(z(coda,[1:2 5:6])),[],'all')<p.rasPosTol && ...
        max(abs(z(coda,[3:4 7:8])),[],'all')<p.rasVelTol && ...
        max(abs(u(coda,:)),[],'all')<p.rasUTol;
end
if arresto==""
    if any(scenario.r~=0) || any(scenario.d~=0),arresto="COMPLETATO";
    elseif convergenza,arresto="CONVERGENZA";else,arresto="MANCATA_CONVERGENZA";end
end
risultato=struct('tempo',t,'q',q,'u',u,'statoFinale',z(end,:), ...
    'esito',arresto,'convergenza',convergenza,'completato',t(end)>=tempo(end)-1e-8, ...
    'secondi',toc(timer),'messaggio',messaggio,'scenario',scenario);
risultato.statoFinale(15:end)=(Tk*z(end,15:end)')';
    function J=jacobiano(~,stato)
        y=[stato(1:2);stato(5:6)]; comando=Ck*stato(15:end)+Dk*[scenario.r;y(1:ny)];
        coppia=modello.taubar+Ca*stato(9:14)+Da*comando;
        Jm=zeros(8); passo=1e-6;
        for h=1:8
            v=zeros(8,1); v(h)=passo;
            Jm(:,h)=(dinamica_sea(modello.xbar+stato(1:8)+v,coppia,scenario.d,modello.fisica)- ...
                dinamica_sea(modello.xbar+stato(1:8)-v,coppia,scenario.d,modello.fisica))/(2*passo);
        end
        Cy=modello.Cm(1:ny,:); Dy=Dk(:,3:end);
        J=[Jm+modello.Btau*Da*Dy*Cy,modello.Btau*Ca,modello.Btau*Da*Ck; ...
            Ba*Dy*Cy,Aa,Ba*Ck;Bk(:,3:end)*Cy,zeros(nk,6),Ak];
    end
    function dz=rhs(~,stato)
        if toc(timer)>p.timeout,error('SEA:Timeout','Tempo massimo solver raggiunto.');end
        y=[stato(1:2);stato(5:6)]; ingresso=[scenario.r;y(1:ny)];
        comando=Ck*stato(15:end)+Dk*ingresso;
        coppia=modello.taubar+Ca*stato(9:14)+Da*comando;
        dm=dinamica_sea(modello.xbar+stato(1:8),coppia,scenario.d,modello.fisica);
        dz=[dm;Aa*stato(9:14)+Ba*comando;Ak*stato(15:end)+Bk*ingresso];
    end
    function [valore,terminale,direzione]=evento(~,stato)
        limiteFisico=max([max(abs(stato([1:2 5:6])))/p.sogliaPosizione, ...
            max(abs(stato([3:4 7:8])))/p.sogliaVelocita]);
        limiteNumerico=max(abs(stato))/p.limiteNumerico;
        valore=1-max(limiteFisico,limiteNumerico); terminale=1; direzione=-1;
        if valore<=0
            if limiteFisico>=limiteNumerico,arresto="DIVERGENZA_OSSERVATA";
            else,arresto="ERRORE_NUMERICO";end
        end
    end
end
