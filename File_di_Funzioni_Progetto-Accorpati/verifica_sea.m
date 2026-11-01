function esiti=verifica_sea
%VERIFICA_SEA Test fisici e dinamici indipendenti, senza trasferire garanzie.
p=parametri_sea; a=load(fullfile(p.risultati,'modello.mat')); m=a.modello;
a=load(fullfile(p.risultati,'incertezze.mat')); u=a.modelli;
a=load(fullfile(p.dati,'banca_validata.mat')); b=a.banca;
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
nomi(3)="Nominale main e LFT equivalenti";
assert(numel(fieldnames(u.PA.Uncertainty))==4 && numel(fieldnames(u.PB.Uncertainty))==2);
assert(order(u.PA)==14);
nomi(4)="Quattro reali / due SISO dinamici; ordine fisico";
for j=1:numel(u.errori)
    delta=u.errori{j}/u.WI;
    assert(isstable(delta) && isproper(delta) && norm(delta,inf)<=1+1e-8);
end
nomi(5)="Copertura dinamica continua dei campioni SISO";
stato=rng; rng(p.seed,'twister'); [~,v]=usample(u.GaA,p.campioni);rng(stato);
assert(isequal([[v.wn1]',[v.zeta1]',[v.wn2]',[v.zeta2]'],u.parametri));
nomi(6)="Replay esatto dei dieci impianti comuni";
[aa,bb,cc,dd]=ssdata(m.attuatori);
for k=[1 2 4 6]
    K=b.controllers(k).K; ny=size(K,2)-2;
    Cm=m.Cm(1:ny,:); A=[m.Am m.Btau*cc;zeros(6,8) aa]; B=[m.Btau*dd;bb];
    C=[Cm zeros(ny,6)]; [ak,bk,ck,dk]=ssdata(K);
    Acl=[A+B*dk(:,3:end)*C,B*ck;bk(:,3:end)*C,ak];
    [~,cl]=interconnessione_sea(m.P0,p,ny,K);
    assert(all(real(eig(Acl))<0) && isstable(cl));
end
nomi(7)="Stabilita interna da matrice esplicita";
esiti=table(nomi,repmat("PASS",numel(nomi),1),'VariableNames',{'Verifica','Stato'});
writetable(esiti,fullfile(p.risultati,'verifiche.csv'));disp(esiti);
end
