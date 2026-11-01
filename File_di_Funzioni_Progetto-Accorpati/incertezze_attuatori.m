%% 1 - Unica famiglia fisica: sei parametri attuativi e un carico comune
cartella=fileparts(mfilename('fullpath')); addpath(cartella); p=parametri_sea;
a=load(fullfile(p.risultati,'modello.mat')); modello=a.modello;
assert(isequal(modello.firma,p.firma),'SEA:Cache','Rigenerare modello_sea.');
s=tf('s'); G0=modello.G0;
attA=cell(1,2);
for giunto=1:2
    wn=ureal(char("wn"+giunto),p.wn,'Percentage',100*p.rwn);
    zeta=ureal(char("zeta"+giunto),p.zeta,'Percentage',100*p.rzeta);
    td=ureal(char("td"+giunto),p.ritardo,'Percentage',100*p.rritardo);
    % Pade: xdot=-2/td*x+2/td*u, y=2*x-u. Sempre un solo stato.
    ritardo=ss(-2/td,2/td,2,-1);
    attA{giunto}=ss([0 1;-wn^2 -2*zeta*wn],[0;wn^2],[1 0],0)*ritardo;
end
GaA=append(attA{:}); PA=modello.meccanicaIncerta*blkdiag(GaA,eye(2));
statoRng=rng; rng(p.seed,'twister');
[campioniFisici,estrazioni]=usample(PA,p.campioni); rng(statoRng);
parametri=[[estrazioni.wn1]',[estrazioni.zeta1]',[estrazioni.td1]', ...
    [estrazioni.wn2]',[estrazioni.zeta2]',[estrazioni.td2]',[estrazioni.m_EE]'];
campioniAtt=ss(zeros(2,2,0));
for j=1:p.campioni
    campioniAtt(:,:,j)=usubs(GaA,rmfield(estrazioni(j),'m_EE'));
end
writetable(array2table(parametri,'VariableNames',{'wn1','zeta1','td1','wn2','zeta2','td2','m_EE'}), ...
    fullfile(p.risultati,'parametri_dieci_impianti.csv'));

%% 2 - LFT completa: nomi fisici distinti dalle ripetizioni algebriche
[M,Delta,blocchi]=lftdata(PA); ricostruito=lft(Delta,M); erroreLFT=0;
for j=1:p.campioni
    riassemblato=usubs(ricostruito,estrazioni(j));
    erroreLFT=max(erroreLFT,max(abs(freqresp(campioniFisici(:,:,j),p.omega)- ...
        freqresp(riassemblato,p.omega)),[],'all'));
end
assert(erroreLFT<1e-8); disp(blocchi);

%% 3 - Tre forme: il modulo non basta a certificare una perturbazione stabile
forme=cell(3,5); nomiForme=["Additiva","Moltiplicativa","Moltiplicativa inversa"];
Gp=drive(p.wn,p.zeta,p.ritardo*(1+p.rritardo));
erroriForme={Gp-G0,(Gp-G0)/G0,(Gp-G0)/Gp};
for j=1:3
    Ej=minreal(erroriForme{j},1e-8);
    valore=Inf; if isstable(Ej),valore=norm(Ej,inf);end
    forme(j,:)={nomiForme(j),isstable(Ej),isproper(Ej),max(real(pole(Ej))),valore};
end
tabellaForme=cell2table(forme,'VariableNames',{'Forma','Stabile','Propria','PoloDestro','Norma'});
writetable(tabellaForme,fullfile(p.risultati,'forme_incertezza.csv')); disp(tabellaForme);
% Si adotta Gp=G0+WI*Delta: nessuna inversione dello zero RHP del drive.

%% 4 - Venti drive comuni, otto vertici SISO e nominale
[a1,a2,a3]=ndgrid([-1 1]); corner=[a1(:),a2(:),a3(:);0 0 0];
coppie=[parametri(:,1:3);parametri(:,4:6);p.wn*(1+p.rwn*corner(:,1)), ...
    p.zeta*(1+p.rzeta*corner(:,2)),p.ritardo*(1+p.rritardo*corner(:,3))];
nCampioni=size(coppie,1); errori=cell(nCampioni,1); attuatori=cell(nCampioni,1);
scostamenti=zeros(numel(p.omega),nCampioni);
for j=1:nCampioni
    attuatori{j}=drive(coppie(j,1),coppie(j,2),coppie(j,3));
    errori{j}=minreal(attuatori{j}-G0,1e-8);
    assert(isstable(errori{j}) && isproper(errori{j}));
    scostamenti(:,j)=abs(squeeze(freqresp(errori{j},p.omega)));
end
inviluppo=max(scostamenti,[],2);
% Hold-out: campioni indipendenti usati solo per verifica, mai per il fit.
rng(p.seed+1,'twister'); verifica=rand(30,3)*2-1; rng(statoRng);
erroriVerifica=cell(30,1);
for j=1:30
    erroriVerifica{j}=minreal(drive(p.wn*(1+p.rwn*verifica(j,1)), ...
        p.zeta*(1+p.rzeta*verifica(j,2)),p.ritardo*(1+p.rritardo*verifica(j,3)))-G0,1e-8);
end

%% 5 - Fit semplice, copertura continua dei campioni e controllo indipendente
pesi=cell(3,1); metriche=zeros(3,6);
for ordine=1:3
    peso=tf(fitmagfrd(frd(inviluppo,p.omega),ordine,min(ordine,2),[],1));
    rapporto=0;
    for j=1:nCampioni,rapporto=max(rapporto,norm(errori{j}/peso,inf));end
    peso=p.marginePeso*max(1,rapporto)*peso;
    assert(isstable(peso) && isproper(peso) && all(real(zero(peso))<0));
    copertura=0; indipendente=0;
    for j=1:nCampioni,copertura=max(copertura,norm(errori{j}/peso,inf));end
    for j=1:30,indipendente=max(indipendente,norm(erroriVerifica{j}/peso,inf));end
    eccesso=median(squeeze(abs(freqresp(peso,p.omega)))./max(inviluppo,1e-12));
    metriche(ordine,:)=[ordine,copertura,eccesso,isstable(peso),isproper(peso),indipendente];
    pesi{ordine}=peso;
end
% Ordine minimo che copre i campioni senza eccesso mediano sproporzionato.
scelta=find(metriche(:,2)<=1 & metriche(:,3)<=p.eccessoPesoMax,1);
assert(~isempty(scelta),'SEA:Peso','Copertura o conservativita insufficienti.');
WI=pesi{scelta}; assert(metriche(scelta,6)<=1,'SEA:Holdout','Copertura indipendente fallita.');
tabellaPesi=array2table(metriche,'VariableNames', ...
    {'Ordine','MaxNormaNormalizzata','EccessoMediano','Stabile','Proprio','MaxNormaIndipendente'});
writetable(tabellaPesi,fullfile(p.risultati,'ordini_peso.csv')); disp(tabellaPesi);
% Non si deduce l'inclusione globale del box da campioni o da soli vertici.

%% 6 - Due perturbazioni SISO additive e la stessa massa reale di A
D1=ultidyn('Delta_act1',[1 1]); D2=ultidyn('Delta_act2',[1 1]);
GaB=append(G0+WI*D1,G0+WI*D2);
PB=modello.meccanicaIncerta*blkdiag(GaB,eye(2));
erroreA=max(abs(freqresp(PA.NominalValue,p.omega)-freqresp(modello.P0,p.omega)),[],'all');
erroreB=max(abs(freqresp(PB.NominalValue,p.omega)-freqresp(modello.P0,p.omega)),[],'all');
assert(max(erroreA,erroreB)<p.tolNominale);
% Ricostruzione B degli stessi impianti fisici, incluse le masse estratte.
erroreAB=0;
for j=1:p.campioni
    delta1=minreal(errori{j}/WI,1e-7);
    delta2=minreal(errori{p.campioni+j}/WI,1e-7);
    assert(isstable(delta1) && isstable(delta2) && isproper(delta1) && isproper(delta2));
    riassemblato=usubs(PB,'m_EE',parametri(j,7),'Delta_act1',delta1,'Delta_act2',delta2);
    erroreAB=max(erroreAB,max(abs(freqresp(riassemblato,p.omega)-freqresp(campioniFisici(:,:,j),p.omega)),[],'all'));
end
assert(erroreAB<1e-7);
ritardi=zeros(numel(p.ritardiCandidati),3);
for j=1:numel(p.ritardiCandidati)
    td=p.ritardo*(1+p.ritardiCandidati(j)); Gj=drive(p.wn,p.zeta,td);
    ritardi(j,:)=[p.ritardiCandidati(j),norm(Gj-G0,inf), ...
        abs(angle(evalfr(Gj/G0,1i*p.wn)))*180/pi];
end
writetable(array2table(ritardi,'VariableNames',{'Tolleranza','ScartoAdditivo','ScartoFase40deg'}), ...
    fullfile(p.risultati,'candidati_ritardo.csv'));
modelli=struct('PA',PA,'PB',PB,'GaA',GaA,'GaB',GaB,'WI',WI,'M',M,'Delta',Delta, ...
    'blocchi',blocchi,'parametri',parametri,'campioniAtt',campioniAtt,'campioniFisici',campioniFisici, ...
    'estrazioni',estrazioni,'coppie',coppie,'errori',{errori},'erroriVerifica',{erroriVerifica}, ...
    'tabellaPesi',tabellaPesi,'scelta',scelta,'erroreLFT',erroreLFT,'erroreAB',erroreAB, ...
    'erroreNominale',[erroreA erroreB],'omega',p.omega,'seed',p.seed,'firma',p.firma);
save(fullfile(p.risultati,'incertezze.mat'),'modelli','-v7');
fprintf('A/B: sette reali / due dinamiche e una massa; peso additivo ordine %d.\n',scelta);

%% 7 - Grafici SISO: modulo, fase, poli e tempo della stessa famiglia
if p.figure
    f=figure('Name','Famiglia parametrica degli attuatori','Color','w'); theme(f,'light'); tiledlayout(2,2);
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
    f=figure('Name','Costruzione del peso concentrato','Color','w'); theme(f,'light');
    semilogx(p.omega,scostamenti,'Color',[.75 .8 .9]); hold on;
    h1=semilogx(p.omega,inviluppo,'k--','LineWidth',1.5);
    h2=semilogx(p.omega,squeeze(abs(freqresp(WI,p.omega))),'r','LineWidth',1.5);
    grid on; xlabel('Frequenza [rad/s]'); ylabel('Scostamento additivo / peso');
    legend([h1 h2],{'Inviluppo campionato','Peso selezionato'},'Location','northwest');
    exportgraphics(f,fullfile(p.risultati,'peso_incertezza.png'),'Resolution',170);
end

function G=drive(wn,zeta,td)
s=tf('s'); G=wn^2/(s^2+2*zeta*wn*s+wn^2)*(1-td*s/2)/(1+td*s/2);
end
