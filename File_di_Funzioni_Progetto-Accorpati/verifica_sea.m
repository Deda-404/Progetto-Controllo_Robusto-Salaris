function esiti=verifica_sea
%VERIFICA_SEA Test fisici e dinamici indipendenti, senza trasferire garanzie.
p=parametri_sea; a=load(fullfile(p.risultati,'modello.mat')); m=a.modello;
a=load(fullfile(p.risultati,'incertezze.mat')); u=a.modelli;
[~,controllori]=controllori_sea(p);
assert(isequal(m.firma,p.firma) && isequal(u.firma,p.firma),'SEA:Cache','Modelli incoerenti.');
nomi=strings(7,1);
assert(norm(dinamica_sea(m.xbar,m.taubar,zeros(2,1),m.fisica))<1e-10);
nomi(1)="Equilibrio non lineare";
J=zeros(8); h=1e-6;
for j=1:8
    v=zeros(8,1); v(j)=h;
    J(:,j)=(dinamica_sea(m.xbar+v,m.taubar,zeros(2,1),m.fisica)- ...
        dinamica_sea(m.xbar-v,m.taubar,zeros(2,1),m.fisica))/(2*h);
end
assert(norm(J-m.Am,'fro')/norm(m.Am,'fro')<1e-8);
nomi(2)="Jacobiano indipendente delle equazioni";
assert(m.erroreNominale<1e-8 && max(u.erroreNominale)<1e-8 && u.erroreLFT<1e-9);
nomi(3)="Nominale A/B e LFT equivalenti";
assert(numel(fieldnames(u.PA.Uncertainty))==7 && numel(fieldnames(u.PB.Uncertainty))==3);
assert(order(u.PA)==14);
nomi(4)="Sette reali / due SISO dinamici e massa; ordine fisico";
for j=1:numel(u.errori)
    delta=u.errori{j}/u.WI;
    assert(isstable(delta) && isproper(delta) && norm(delta,inf)<=1+1e-8);
end
nomi(5)="Copertura dinamica continua dei campioni SISO";
stato=rng; rng(p.seed,'twister'); [~,v]=usample(u.PA,p.campioni);rng(stato);
assert(isequal([[v.wn1]',[v.zeta1]',[v.td1]',[v.wn2]',[v.zeta2]',[v.td2]',[v.m_EE]'],u.parametri));
nomi(6)="Replay esatto dei dieci impianti comuni";
[aa,bb,cc,dd]=ssdata(m.attuatori);
for k=1:numel(controllori)
    K=controllori{k}; ny=size(K,2)-2;
    Cm=m.Cm(1:ny,:); A=[m.Am m.Btau*cc;zeros(6,8) aa]; B=[m.Btau*dd;bb];
    C=[Cm zeros(ny,6)]; [ak,bk,ck,dk]=ssdata(K);
    Acl=[A+B*dk(:,3:end)*C,B*ck;bk(:,3:end)*C,ak];
    [~,cl]=interconnessione_sea(m.P0,p,ny,K);
    assert(all(real(eig(Acl))<0)==isstable(cl));
end
nomi(7)="Esito stabilita interna da matrice esplicita";
% Controllabilita/rilevabilita dei modi instabili: PBH evita potenze di A.
for lambda=eig(m.Afull)'
    if real(lambda)>=0
        assert(rank([lambda*eye(14)-m.Afull,m.Bfull])==14);
        assert(rank([lambda*eye(14)-m.Afull;m.Cfull])==14);
    end
end
assert(isequal(u.PA.Uncertainty.m_EE.Range,u.PB.Uncertainty.m_EE.Range));
assert(u.erroreAB<1e-7);
esiti=table(nomi,repmat("PASS",numel(nomi),1),'VariableNames',{'Verifica','Stato'});
writetable(esiti,fullfile(p.risultati,'verifiche.csv'));disp(esiti);
% Numeri per tabelle e formule: doppia precisione qui, arrotondamento in LaTeX.
[num,den]=tfdata(u.WI,'v'); poli=eig(m.Am);
l=load(fullfile(p.risultati,'lqg.mat')); li=load(fullfile(p.risultati,'lqgi.mat'));
h=load(fullfile(p.risultati,'sintesi_hinf.mat'));
riassunto=struct('Mbar',m.Mbar,'Kg',m.Kg,'taubar',m.taubar, ...
    'poliRe',real(poli),'poliIm',imag(poli),'residuoEquilibrio', ...
    norm(dinamica_sea(m.xbar,m.taubar,zeros(2,1),m.fisica)), ...
    'erroreJacobiano',norm(J-m.Am,'fro')/norm(m.Am,'fro'), ...
    'erroreAB',u.erroreAB,'erroreLFT',u.erroreLFT,'blocchiA',u.blocchi, ...
    'pesoNum',num,'pesoDen',den,'Qn',diag(l.lqg.Qn),'Rn',diag(l.lqg.Rn), ...
    'Qi',li.lqgi.Q(end,end),'R',diag(l.lqg.R),'gammaHinf',h.sintesi.gamma, ...
    'scartoMixsyn',h.sintesi.scartoGamma,'CARE',[l.lqg.residuoCARE,li.lqgi.residuoCARE]);
file=fopen(fullfile(p.risultati,'riassunto_numerico.json'),'w');
fprintf(file,'%s',jsonencode(riassunto,PrettyPrint=true)); fclose(file);
end
