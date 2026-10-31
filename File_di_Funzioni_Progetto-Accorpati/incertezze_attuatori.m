%% 1 - Stessa famiglia fisica per A parametrico e B concentrato
cartella=fileparts(mfilename('fullpath')); addpath(cartella); p=parametri_sea;
if ~isfile(fullfile(p.risultati,'modello.mat')),run(fullfile(cartella,'modello_sea.m'));end
a=load(fullfile(p.risultati,'modello.mat')); modello=a.modello;
s=tf('s'); G0=modello.G0; H0=modello.H0; Dp=modello.Dp;
statoRng=rng; rng(p.seed,'twister');

%% 2 - Quattro scalari reali: due tipi di parametro, indipendenti fra giunti
attA=cell(1,2);
for giunto=1:2
    wn=ureal(char("wn"+giunto),p.wn,'Percentage',100*p.rwn);
    zeta=ureal(char("zeta"+giunto),p.zeta,'Percentage',100*p.rzeta);
    % Realizzazione fisica a due stati: evita stati ridondanti dell'algebra TF.
    attA{giunto}=ss([0 1;-wn^2 -2*zeta*wn],[0;wn^2],[1 0],0)*Dp;
end
GaA=append(attA{:}); PA=modello.meccanica*blkdiag(GaA,eye(2));
[campioniAtt,estrazioni]=usample(GaA,p.campioni); rng(statoRng);
parametri=[[estrazioni.wn1]',[estrazioni.zeta1]',[estrazioni.wn2]',[estrazioni.zeta2]'];
writetable(array2table(parametri,'VariableNames',{'wn1','zeta1','wn2','zeta2'}), ...
    fullfile(p.risultati,'parametri_dieci_impianti.csv'));

%% 3 - Pulling out the deltas e verifica della LFT superiore
% alpha=alpha0*(1+r*delta). lftdata mantiene le ripetizioni correlate.
% Segnali: [zDelta;y]=M*[wDelta;u], wDelta=Delta*zDelta.
[M,Delta,blocchi]=lftdata(GaA); ricostruito=lft(Delta,M);
erroreLFT=0;
for j=1:p.campioni
    campione=estrazioni(j);
    originale=usubs(GaA,campione); riassemblato=usubs(ricostruito,campione);
    erroreLFT=max(erroreLFT,max(abs(freqresp(originale,p.omega)-freqresp(riassemblato,p.omega)),[],'all'));
end
assert(erroreLFT<1e-9); disp(blocchi);

% Verifica indipendente della LFT manuale mostrata in relazione.
dw=p.wn*p.rwn; dz=p.zeta*p.rzeta;
Mosc=ss([0 1;-p.wn^2 -2*p.wn*p.zeta], ...
    [0 0 0 0;p.wn*dw dw -2*p.wn*dz p.wn^2], ...
    [-1 0;-p.wn -2*p.zeta;0 1;1 0], ...
    [0 0 0 1;dw 0 -2*dz p.wn;0 0 0 0;0 0 0 0]);
for j=1:p.campioni
    deltaW=(parametri(j,1)/p.wn-1)/p.rwn;
    deltaZ=(parametri(j,2)/p.zeta-1)/p.rzeta;
    manuale=lft(diag([deltaW deltaW deltaZ]),Mosc)*Dp;
    diretto=campioniAtt(1,1,j);
    erroreLFT=max(erroreLFT,max(abs(freqresp(manuale,p.omega)-freqresp(diretto,p.omega)),[],'all'));
end
assert(erroreLFT<1e-9,'SEA:LFTManuale','LFT manuale diversa dal modello fisico.');

%% 4 - FRD, scostamenti e inviluppo: procedimento di Lezione3004_1
% 20 canali dei dieci impianti, quattro corner SISO e nominale.
corner=[-1 -1;-1 1;1 -1;1 1;0 0];
coppie=[parametri(:,1:2);parametri(:,3:4);p.wn*(1+p.rwn*corner(:,1)),p.zeta*(1+p.rzeta*corner(:,2))];
nCampioni=size(coppie,1); errori=cell(nCampioni,1); attuatori=cell(nCampioni,1);
scostamenti=zeros(numel(p.omega),nCampioni);
for j=1:nCampioni
    wn=coppie(j,1); zeta=coppie(j,2);
    Hp=wn^2/(s^2+2*zeta*wn*s+wn^2); attuatori{j}=Hp*Dp;
    % Cancellazione ANALITICA del medesimo Dp. Non si inverte uno zero RHP.
    alfa=wn^2/p.wn^2-1; beta=2*p.zeta*wn^2/p.wn-2*zeta*wn;
    errori{j}=(alfa*s^2+beta*s)/(s^2+2*zeta*wn*s+wn^2);
    assert(isstable(errori{j}) && isproper(errori{j}));
    relFRD=(frd(attuatori{j},p.omega)-frd(G0,p.omega))/frd(G0,p.omega);
    scostamenti(:,j)=abs(squeeze(relFRD.ResponseData));
    assert(max(abs(squeeze(freqresp(errori{j},p.omega))-squeeze(relFRD.ResponseData)))<1e-9);
end
inviluppo=max(scostamenti,[],2);

%% 5 - Ordini 1, 2, 3: fitting automatico e verifica dinamica continua
% Un fattore scalare assicura ||E_j/W||inf<1 sui campioni, anche fra i nodi.
% Questo NON dimostra la copertura di tutti i punti del box parametrico.
pesi=cell(3,1); metriche=zeros(3,5);
for ordine=1:3
    peso=fitmagfrd(frd(inviluppo,p.omega),ordine,0,[],1);
    rapporto=0;
    for j=1:nCampioni,rapporto=max(rapporto,norm(errori{j}/peso,inf));end
    peso=p.marginePeso*max(1,rapporto)*peso;
    assert(isstable(peso) && isproper(peso) && isstable(1/peso));
    copertura=0;
    for j=1:nCampioni,copertura=max(copertura,norm(errori{j}/peso,inf));end
    eccesso=median(squeeze(abs(freqresp(peso,p.omega)))./max(inviluppo,1e-12));
    metriche(ordine,:)=[ordine,copertura,eccesso,isstable(peso),isproper(peso)];
    pesi{ordine}=peso;
end
scelta=find(metriche(:,2)<=1 & metriche(:,3)<=p.eccessoPesoMax,1);
assert(~isempty(scelta),'SEA:Peso','Nessun ordine soddisfa copertura ed eccesso dichiarati.');
WI=pesi{scelta}; tabellaPesi=array2table(metriche,'VariableNames', ...
    {'Ordine','MaxNormaNormalizzata','EccessoMediano','Stabile','Proprio'});
writetable(tabellaPesi,fullfile(p.risultati,'ordini_peso.csv')); disp(tabellaPesi);

%% 6 - Due ultidyn SISO: la meccanica mantiene il proprio accoppiamento
D1=ultidyn('Delta_act1',[1 1]); D2=ultidyn('Delta_act2',[1 1]);
GaB=append(G0*(1+WI*D1),G0*(1+WI*D2));
PB=modello.meccanica*blkdiag(GaB,eye(2));
erroreA=max(abs(freqresp(PA.NominalValue,p.omega)-freqresp(modello.P0,p.omega)),[],'all');
erroreB=max(abs(freqresp(PB.NominalValue,p.omega)-freqresp(modello.P0,p.omega)),[],'all');
assert(max(erroreA,erroreB)<p.tolNominale);
modelli=struct('PA',PA,'PB',PB,'GaA',GaA,'GaB',GaB,'WI',WI,'M',M,'Delta',Delta, ...
    'blocchi',blocchi,'parametri',parametri,'campioniAtt',campioniAtt,'coppie',coppie, ...
    'errori',{errori},'tabellaPesi',tabellaPesi,'scelta',scelta,'erroreLFT',erroreLFT, ...
    'erroreNominale',[erroreA erroreB],'omega',p.omega,'seed',p.seed);
save(fullfile(p.risultati,'incertezze.mat'),'modelli','-v7');
fprintf('A/B nominalmente equivalenti: %.3g / %.3g; peso ordine %d.\n',erroreA,erroreB,scelta);

%% 7 - Grafici SISO: modulo, fase, poli e tempo della stessa famiglia
if p.figure
    f=figure('Name','Famiglia parametrica degli attuatori','Color','w'); tiledlayout(2,2);
    for j=1:nCampioni
        risposta=squeeze(freqresp(attuatori{j},p.omega));
        nexttile(1); semilogx(p.omega,20*log10(abs(risposta)),'Color',[.7 .8 .9]); hold on;
        nexttile(2); semilogx(p.omega,unwrap(angle(risposta))*180/pi,'Color',[.7 .8 .9]); hold on;
        nexttile(3); poli=pole(attuatori{j}); plot(real(poli),imag(poli),'.','Color',[.5 .7 .85]); hold on;
        nexttile(4); [y,t]=step(attuatori{j},0:.001:.4); plot(t,y,'Color',[.7 .8 .9]); hold on;
    end
    r0=squeeze(freqresp(G0,p.omega));
    nexttile(1); semilogx(p.omega,20*log10(abs(r0)),'k','LineWidth',1.5); grid on; ylabel('Modulo [dB]'); xlabel('rad/s');
    nexttile(2); semilogx(p.omega,unwrap(angle(r0))*180/pi,'k','LineWidth',1.5); grid on; ylabel('Fase [gradi]'); xlabel('rad/s');
    nexttile(3); plot(real(pole(G0)),imag(pole(G0)),'kx'); grid on; xlabel('Re polo [1/s]'); ylabel('Im polo [1/s]');
    nexttile(4); [y,t]=step(G0,0:.001:.4); plot(t,y,'k','LineWidth',1.5); grid on; xlabel('Tempo [s]'); ylabel('Coppia [N m]');
    exportgraphics(f,fullfile(p.risultati,'famiglia_attuatori.png'),'Resolution',170);
    f=figure('Name','Costruzione del peso concentrato','Color','w');
    semilogx(p.omega,scostamenti,'Color',[.75 .8 .9]); hold on;
    h1=semilogx(p.omega,inviluppo,'k--','LineWidth',1.5);
    h2=semilogx(p.omega,squeeze(abs(freqresp(WI,p.omega))),'r','LineWidth',1.5);
    grid on; xlabel('Frequenza [rad/s]'); ylabel('Errore relativo / peso');
    legend([h1 h2],{'Inviluppo campionato','Peso selezionato'},'Location','northwest');
    exportgraphics(f,fullfile(p.risultati,'peso_incertezza.png'),'Resolution',170);
end
