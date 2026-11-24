%% INCERTEZZE_ATTUATORI - Famiglie di incertezza A e B (Capitolo 5)
%
% Obiettivo: descrivere lo stesso insieme fisico di impianti in due modi.
%
%   A (parametrica): cinque scalari reali indipendenti
%       m2, wn1, td1, wn2, td2      (zeta resta noto)
%     Ogni drive e Gi(s)=wn_i^2/(s^2+2 zeta wn_i s+wn_i^2)*Pade(td_i).
%
%   B (concentrata): la stessa massa reale m2 e, per ciascun drive, una
%     perturbazione dinamica additiva
%       Gi(s) = G0(s) + WI(s)*Delta_i(s),   ||Delta_i||_inf <= 1
%     WI(s) e un peso stabile che "copre" lo scostamento dei drive reali.
%
% Perche la forma additiva: la forma moltiplicativa (Gp-G0)/G0 richiede di
% invertire G0, che contiene lo zero a parte reale positiva della Pade
% (s=2/td): il risultato e instabile e la sua norma H-infinito non esiste.
% La sezione 3 lo verifica numericamente.
%
% Salva: risultati/incertezze.mat, parametri_dieci_impianti.csv,
% forme_incertezza.csv, ordini_peso.csv, candidati_ritardo.csv e le figure
% famiglia_attuatori.png, peso_incertezza.png.

%% 1 - Famiglia A: quattro parametri attuativi e la massa m2 comune
cartella=fileparts(mfilename('fullpath')); addpath(cartella); p=parametri_sea;
a=load(fullfile(p.risultati,'modello.mat')); modello=a.modello;
assert(isequal(modello.firma,p.firma),'SEA:Cache','Rigenerare modello_sea.');
s=tf('s'); G0=modello.G0;
attA=cell(1,2);
for giunto=1:2
    % ureal: parametro reale incerto. 'Percentage' fissa l'intervallo
    % simmetrico intorno al nominale: wn in [34,46] rad/s, td in [12,18] ms.
    wn=ureal(char("wn"+giunto),p.wn,'Percentage',100*p.rwn);
    zeta=p.zeta; % Noto ai fini del progetto, nessun blocco incerto.
    td=ureal(char("td"+giunto),p.ritardo,'Percentage',100*p.rritardo);
    % Pade realizzata con un solo stato: xdot=-2/td*x+2/td*u, y=2*x-u.
    % Cosi td compare una sola volta per drive (meno ripetizioni nella LFT).
    ritardo=ss(-2/td,2/td,2,-1);
    attA{giunto}=ss([0 1;-wn^2 -2*zeta*wn],[0;wn^2],[1 0],0)*ritardo;
end
% Impianto incerto A: meccanica (con m2 incerta) in serie ai due drive.
GaA=append(attA{:}); PA=modello.meccanicaIncerta*blkdiag(GaA,eye(2));
% usample estrae campioni casuali dell'insieme incerto (distribuzione
% uniforme sugli intervalli dei ureal). Il seed fisso rende i dieci
% impianti identici a ogni esecuzione e uguali per tutti i controllori.
statoRng=rng; rng(p.seed,'twister');
[campioniFisici,estrazioni]=usample(PA,p.campioni); rng(statoRng);
parametri=[[estrazioni.wn1]',[estrazioni.td1]', ...
    [estrazioni.wn2]',[estrazioni.td2]',[estrazioni.m2]'];
campioniAtt=ss(zeros(2,2,0));
for j=1:p.campioni
    campioniAtt(:,:,j)=usubs(GaA,rmfield(estrazioni(j),'m2'));
end
writetable(array2table(parametri,'VariableNames',{'wn1','td1','wn2','td2','m2'}), ...
    fullfile(p.risultati,'parametri_dieci_impianti.csv'));

%% 2 - Forma LFT di A: P = Fu(M, Delta)
% lftdata separa il modello incerto nella parte nota M e nella matrice
% diagonale Delta delle incertezze normalizzate. "blocchi" riporta per
% ciascun parametro il numero di occorrenze (ripetizioni) in Delta: un
% parametro che compare piu volte nelle equazioni genera un blocco reale
% ripetuto, non blocchi indipendenti.
[M,Delta,blocchi]=lftdata(PA); ricostruito=lft(Delta,M); erroreLFT=0;
% Verifica: richiudendo la LFT con i valori estratti si ottengono gli
% stessi dieci impianti campionati.
for j=1:p.campioni
    riassemblato=usubs(ricostruito,estrazioni(j));
    erroreLFT=max(erroreLFT,max(abs(freqresp(campioniFisici(:,:,j),p.omega)- ...
        freqresp(riassemblato,p.omega)),[],'all'));
end
assert(erroreLFT<1e-8); disp(blocchi);

%% 3 - Tre forme di incertezza a confronto sul caso td massimo
% Additiva Gp-G0, moltiplicativa (Gp-G0)/G0, moltiplicativa inversa
% (Gp-G0)/Gp. Le ultime due dividono per un drive a fase non minima: lo
% zero RHP della Pade diventa un polo instabile, la norma H-infinito non e
% definita (valore Inf in tabella). Il modulo in frequenza da solo non
% basta: serve anche la stabilita della perturbazione.
forme=cell(3,5); nomiForme=["Additiva","Moltiplicativa","Moltiplicativa inversa"];
Gp=drive(p.wn,p.zeta,p.ritardo*(1+p.rritardo));
erroriForme={Gp-G0,(Gp-G0)/G0,(Gp-G0)/Gp};
for j=1:3
    % minreal elimina coppie polo-zero che si cancellano numericamente.
    Ej=minreal(erroriForme{j},1e-8);
    % norm(.,inf) e la norma H-infinito: picco del modulo in frequenza.
    valore=Inf; if isstable(Ej),valore=norm(Ej,inf);end
    forme(j,:)={nomiForme(j),isstable(Ej),isproper(Ej),max(real(pole(Ej))),valore};
end
tabellaForme=cell2table(forme,'VariableNames',{'Forma','Stabile','Propria','PoloDestro','Norma'});
writetable(tabellaForme,fullfile(p.risultati,'forme_incertezza.csv')); disp(tabellaForme);
% Si adotta Gp=G0+WI*Delta: nessuna inversione dello zero RHP del drive.

%% 4 - Campioni dei drive usati per costruire il peso WI
% 25 drive: i 20 dei dieci impianti (due per impianto) e i 4 vertici del
% rettangolo (wn,td) piu il nominale. Per ognuno si calcola lo scostamento
% additivo |G(jw)-G0(jw)| su tutta la griglia di frequenza.
[a1,a2]=ndgrid([-1 1]); corner=[a1(:),a2(:);0 0];
coppie=[parametri(:,1),repmat(p.zeta,p.campioni,1),parametri(:,2); ...
    parametri(:,3),repmat(p.zeta,p.campioni,1),parametri(:,4); ...
    p.wn*(1+p.rwn*corner(:,1)),repmat(p.zeta,5,1),p.ritardo*(1+p.rritardo*corner(:,2))];
nCampioni=size(coppie,1); errori=cell(nCampioni,1); attuatori=cell(nCampioni,1);
scostamenti=zeros(numel(p.omega),nCampioni);
for j=1:nCampioni
    attuatori{j}=drive(coppie(j,1),coppie(j,2),coppie(j,3));
    errori{j}=minreal(attuatori{j}-G0,1e-8);
    assert(isstable(errori{j}) && isproper(errori{j}));
    scostamenti(:,j)=abs(squeeze(freqresp(errori{j},p.omega)));
end
inviluppo=max(scostamenti,[],2);  % inviluppo superiore degli scostamenti
% Hold-out: 30 campioni indipendenti usati solo per verifica, mai per il fit.
rng(p.seed+1,'twister'); verifica=rand(30,2)*2-1; rng(statoRng);
erroriVerifica=cell(30,1);
for j=1:30
    erroriVerifica{j}=minreal(drive(p.wn*(1+p.rwn*verifica(j,1)), ...
        p.zeta,p.ritardo*(1+p.rritardo*verifica(j,2)))-G0,1e-8);
end

%% 5 - Fit del peso WI e verifica della copertura
% fitmagfrd approssima un dato di solo modulo con una funzione di
% trasferimento stabile e a fase minima dell'ordine richiesto (qui 1, 2, 3;
% l'ultimo argomento 1 impone che il fit stia sopra i dati). Il peso viene
% poi scalato in modo che |errore/WI| <= 1 per tutti i 25 campioni,
% con un margine del 2% (p.marginePeso).
% Copertura: max_j ||E_j/WI||_inf <= 1 significa che ogni drive campionato
% e rappresentato da una Delta stabile con norma <= 1.
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
    % Eccesso mediano: quanto il peso sovrastima l'inviluppo (conservativita).
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
% LIMITE: la copertura e verificata su 25 campioni di costruzione e 30
% indipendenti, non dimostrata per ogni punto del rettangolo (wn,td).
% Non si deduce l'inclusione globale del box da campioni o da soli vertici.

%% 6 - Famiglia B: due perturbazioni SISO additive e la stessa massa reale di A
% ultidyn crea un blocco dinamico LTI incerto, stabile, con ||Delta||_inf<=1.
% I due drive hanno blocchi indipendenti (Delta_act1, Delta_act2); la massa
% m2 resta lo stesso ureal di A, quindi A e B condividono la meccanica.
D1=ultidyn('Delta_act1',[1 1]); D2=ultidyn('Delta_act2',[1 1]);
GaB=append(G0+WI*D1,G0+WI*D2);
PB=modello.meccanicaIncerta*blkdiag(GaB,eye(2));
% A e B devono avere lo stesso impianto nominale P0.
erroreA=max(abs(freqresp(PA.NominalValue,p.omega)-freqresp(modello.P0,p.omega)),[],'all');
erroreB=max(abs(freqresp(PB.NominalValue,p.omega)-freqresp(modello.P0,p.omega)),[],'all');
assert(max(erroreA,erroreB)<p.tolNominale);
% Ricostruzione B degli stessi impianti fisici, incluse le masse estratte:
% Delta_i = (G_i - G0)/WI. Se e stabile, propria e con norma <= 1, il
% campione di A appartiene anche all'insieme B.
erroreAB=0;
for j=1:p.campioni
    delta1=minreal(errori{j}/WI,1e-7);
    delta2=minreal(errori{p.campioni+j}/WI,1e-7);
    assert(isstable(delta1) && isstable(delta2) && isproper(delta1) && isproper(delta2));
    riassemblato=usubs(PB,'m2',parametri(j,5),'Delta_act1',delta1,'Delta_act2',delta2);
    erroreAB=max(erroreAB,max(abs(freqresp(riassemblato,p.omega)-freqresp(campioniFisici(:,:,j),p.omega)),[],'all'));
end
assert(erroreAB<1e-7);
% Confronto fra tolleranze di ritardo del 10, 20 e 30%: scarto additivo
% massimo e scarto di fase alla pulsazione naturale del drive.
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
fprintf('A/B: cinque reali / due dinamiche e una massa; peso additivo ordine %d.\n',scelta);

%% 7 - Grafici SISO: modulo, fase, poli e risposta al gradino della famiglia
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

%% Funzione locale
function G=drive(wn,zeta,td)
% Drive SISO: secondo ordine con guadagno statico unitario e Pade(1).
s=tf('s'); G=wn^2/(s^2+2*zeta*wn*s+wn^2)*(1-td*s/2)/(1+td*s/2);
end
