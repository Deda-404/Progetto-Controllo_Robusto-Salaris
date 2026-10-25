%% 1 - Ipotesi S1: A parametrico, B concentrato; stessi nominali e intervalli
cartella=fileparts(mfilename('fullpath')); addpath(cartella); p=parametri_sea;
a=load(fullfile(cartella,'dati/banca_consolidata.mat'),'banca'); banca=a.banca;
disp(table(["wn [rad/s]";"zeta";"tau [s]"], ...
    [p.wn;p.zeta;p.tau],[p.wmin;p.zmin;p.tau],[p.wmax;p.zmax;p.tau], ...
    'VariableNames',{'Parametro','Nominale','Minimo','Massimo'}));
% La meccanica e nota nel confronto S1. M4 resta una famiglia storica diversa.
s=tf('s'); Dp=(1-p.tau*s/2)/(1+p.tau*s/2);
H0=p.wn^2/(s^2+2*p.zeta*p.wn*s+p.wn^2); G0=H0*Dp;
WI=p.cWI*s/(s+p.wmin); % c=0.6165601466: maggiorazione su tutto il box

%% 2 - Meccanica linearizzata: x=[dq;dqdot;dtheta;dthetadot]
q=p.qbar; coupling=p.m2*p.l1*p.l2*cos(q(2)); distal=p.m2*p.l2^2;
M=[(p.m1+p.m2)*p.l1^2+distal+2*coupling,distal+coupling; ...
    distal+coupling,distal];
g12=-p.m2*p.g*p.l2*sin(sum(q));
Kg=[-(p.m1+p.m2)*p.g*p.l1*sin(q(1))+g12,g12;g12,g12];
Z=zeros(2); I=eye(2);
Am=[Z I Z Z;-M\(p.Ks+Kg) Z M\p.Ks Z;Z Z Z I; ...
    p.Jm\p.Ks Z -p.Jm\p.Ks -p.Jm\p.Bm];
Btau=[zeros(6,2);p.Jm\I]; Bd=[Z;M\I;zeros(4,2)];
Cy=[I zeros(2,6);zeros(2,4) I Z];
meccanica=ss(Am,[Btau Bd],Cy,zeros(4));
assert(min(eig(M))>0 && norm(Bd-banca.plant.Bd(1:8,:),'fro')<1e-10);

%% 3 - A: LFT manuale dell'oscillatore; lo stesso dwn compare DUE volte
% z1=u-x; z2=wn0*(u-x)-2*zeta0*v+dw*w1-2*dz*wz; z3=v.
% w1=dwn*z1, w2=dwn*z2, wz=dzeta*z3; xdot=v.
% vdot=wn0^2*(u-x)-2*wn0*zeta0*v+wn0*dw*w1+dw*w2-2*wn0*dz*wz.
dw=p.wn*p.rwn; dz=p.zeta*p.rzeta;
Aosc=[0 1;-p.wn^2 -2*p.wn*p.zeta];
Bosc=[0 0 0 0;p.wn*dw dw -2*p.wn*dz p.wn^2];
Cosc=[-1 0;-p.wn -2*p.zeta;0 1;1 0];
Dosc=[0 0 0 1;dw 0 -2*dz p.wn;0 0 0 0;0 0 0 0];
Mosc=ss(Aosc,Bosc,Cosc,Dosc); attA=cell(1,2); deltaA=cell(1,2);
for giunto=1:2
    dwn=ureal(char("dwn"+giunto),0,'Range',[-1 1]);
    dzeta=ureal(char("dzeta"+giunto),0,'Range',[-1 1]);
    deltaA{giunto}=blkdiag(dwn*eye(2),dzeta);
    attA{giunto}=lft(deltaA{giunto},Mosc)*Dp;
end
GaA=append(attA{:}); DeltaA=blkdiag(deltaA{:});
PA=meccanica*blkdiag(GaA,eye(2)); % [u;d] -> [q;theta]

%% 4 - B: due incertezze dinamiche indipendenti, nessun accoppiamento aggiunto
D1=ultidyn('Dact1',[1 1]); D2=ultidyn('Dact2',[1 1]);
GaB=append(G0*(1+WI*D1),G0*(1+WI*D2));
PB=meccanica*blkdiag(GaB,eye(2));
P0=ss(banca.plant.A,[banca.plant.Bu banca.plant.Bd],banca.plant.C,zeros(4));
% E=(alpha*s^2+beta*s)/(s^2+2*zeta*wn*s+wn^2).
% E/WI e stabile/proprio e ha norma <=1 per tutto il box: A e contenuto in B.
% B comprende anche perturbazioni dinamiche non riconducibili ai quattro parametri.
nominalError=max(abs(freqresp(PA.NominalValue,p.omega)-freqresp(P0,p.omega)),[],'all');
nominalErrorB=max(abs(freqresp(PB.NominalValue,p.omega)-freqresp(P0,p.omega)),[],'all');
assert(max(nominalError,nominalErrorB)<1e-8,'SEA:Nominale','Nominali A/B diversi.');

%% 5 - Verifica indipendente della LFT e dell'inviluppo su 25 coppie fisiche
valori=linspace(-1,1,5); lftError=0; coverMax=0; curves=zeros(25,numel(p.omega));
errorCurves=curves; k=0;
for dwn=valori
    for dzeta=valori
        wn=p.wn*(1+p.rwn*dwn); zeta=p.zeta*(1+p.rzeta*dzeta);
        Gdiretto=wn^2/(s^2+2*zeta*wn*s+wn^2)*Dp;
        Gmanuale=usubs(attA{1},'dwn1',dwn,'dzeta1',dzeta);
        lftError=max(lftError,max(abs(freqresp(Gmanuale,p.omega)- ...
            freqresp(Gdiretto,p.omega)),[],'all'));
        alpha=wn^2/p.wn^2-1; beta=2*p.zeta*wn^2/p.wn-2*zeta*wn;
        perturbazione=(alpha*s+beta)*(s+p.wmin)/(p.cWI*(s^2+2*zeta*wn*s+wn^2));
        assert(isstable(perturbazione) && isproper(perturbazione));
        coverMax=max(coverMax,norm(perturbazione,inf));
        k=k+1; curves(k,:)=reshape(abs(freqresp(Gdiretto,p.omega)),1,[]);
        errorCurves(k,:)=reshape(abs(freqresp(Gdiretto,p.omega)./freqresp(G0,p.omega)-1),1,[]);
    end
end
assert(lftError<1e-9 && coverMax<=1+1e-8);
modelli=struct('PA',PA,'PB',PB,'P0',P0,'GaA',GaA,'GaB',GaB, ...
    'Mosc',Mosc,'DeltaA',DeltaA,'WI',WI,'nominalError',nominalError, ...
    'nominalErrorB',nominalErrorB,'lftError',lftError,'coverMax',coverMax, ...
    'sampledEnvelope',max(errorCurves,[],1),'mechanicalA',Am,'mechanicalBtau',Btau, ...
    'source','S1 approvato: meccanica nominale, wn/zeta +/-10%, Pade1 fisso');
save(fullfile(cartella,'dati/modelli_S1.mat'),'modelli','-v7');
fprintf('Nominali: errori %.3g / %.3g; LFT %.3g; max ||E/WI|| %.6g.\n', ...
    nominalError,nominalErrorB,lftError,coverMax);
if p.figure
    f=figure('Name','Attuatori e incertezza','Color','white','Theme','light');
    tiledlayout(1,2); nexttile; semilogx(p.omega,20*log10(curves'),'Color',[.75 .8 .85]);
    hold on; semilogx(p.omega,20*log10(squeeze(abs(freqresp(G0,p.omega)))),'k','LineWidth',1.5);
    grid on; xlabel('Frequenza [rad/s]'); ylabel('Modulo attuatore [dB]'); title('25 coppie wn/zeta');
    nexttile; semilogx(p.omega,squeeze(abs(freqresp(WI,p.omega))), ...
        p.omega,max(errorCurves,[],1),'--','LineWidth',1.5); legend('W_I analitico','Inviluppo 25 coppie');
    grid on; xlabel('Frequenza [rad/s]'); ylabel('|W_I|'); title('Inviluppo analitico concentrato');
    exportgraphics(f,fullfile(cartella,'figure/01_attuatori.png'),'Resolution',170);
end
