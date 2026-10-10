function e = valuta_avvio_hinf(physical,K,W1,W2,Mo,cfg,architettura)
% Chiusura completa xcl=[xpianta;xcontrollore], nessun minreal.
% K=[Kr Ky], u=Kr*r+Ky*q: il segno e gia contenuto in Ky.
[A,B,C,D]=ssdata(physical); [Ak,Bk,Ck,Dk]=ssdata(ss(K));
assert(isequal(size(K),[2 4]) && ~any(D,'all'));
Bu=B(:,1:2); Bd=B(:,3:4); nk=size(Ak,1);
Br=Bk(:,1:2); Bq=Bk(:,3:4); Dr=Dk(:,1:2); Dq=Dk(:,3:4);
e.Acl=[A+Bu*Dq*C,Bu*Ck;Bq*C,Ak];
e.poli=eig(e.Acl); e.maxRePolo=max(real(e.poli));
e.stabile=e.maxRePolo<-cfg.tolStabilita;
Ccl=[C,zeros(2,nk);Dq*C,Ck];
e.riferimento=ss(e.Acl,[Bu*Dr;Br],Ccl,[zeros(2);Dr]);
e.disturbo=ss(e.Acl,[Bd;zeros(nk,2)],Ccl,zeros(4,2));
e.T=e.riferimento(1:2,:); e.UR=e.riferimento(3:4,:);
e.QD=e.disturbo(1:2,:); e.UD=e.disturbo(3:4,:);
% Iniezione fittizia all'errore di feedback per S: distinta da Bd fisico.
fb=ss(e.Acl,[-Bu*Dq;-Bq],Ccl,[zeros(2);-Dq]);
e.S=eye(2)-fb(1:2,:); e.KS=fb(3:4,:);
e.Tfeedback=eye(2)-e.S;
if architettura=="1DOF"
    e.pesato=[W1*(eye(2)-e.T);W2*e.UR];
else
    e.pesato=[W1*(e.T-Mo),W1*e.QD;W2*e.UR,W2*e.UD];
end
e.norma=inf; e.metriche=inf(2,6); e.risposte=cell(2,1);
e.risposteDisturbo=cell(2,1); e.metricheDisturbo=inf(2,4);
if e.stabile
    e.norma=norm(e.pesato,inf);
    dc=dcgain(e.T);
    for j=1:2
        r=zeros(numel(cfg.tempo),2); r(:,j)=cfg.rAmp;
        y=lsim(e.riferimento,r,cfg.tempo); e.risposte{j}=y;
        finale=dc(j,j)*cfg.rAmp;
        ultimo=find(abs(y(:,j)-finale)>.02*cfg.rAmp,1,'last');
        ts=0;
        if ~isempty(ultimo)
            ts=inf;
            if ultimo<numel(cfg.tempo), ts=cfg.tempo(ultimo+1); end
        end
        % Ts: banda 2% dell'ampiezza richiesta intorno al valore DC.
        % L'errore DC e calcolato separatamente; cross normalizzato al picco
        % del giunto comandato; RMS su entrambi i comandi e sull'intero tempo.
        e.metriche(j,:)=[ts,100*max(0,max(y(:,j))/cfg.rAmp-1), ...
            abs(dc(j,j)-1),max(abs(y(:,3-j)))/max(max(abs(y(:,j))),eps), ...
            max(abs(y(:,3:4)),[],'all'),sqrt(mean(y(:,3:4).^2,'all'))];
        d=zeros(numel(cfg.tempo),2); d(:,j)=cfg.dAmp;
        yd=lsim(e.disturbo,d,cfg.tempo); e.risposteDisturbo{j}=yd;
        e.metricheDisturbo(j,:)=[max(abs(yd(:,1:2)),[],'all'), ...
            max(abs(dcgain(e.QD(:,j))*cfg.dAmp)), ...
            max(abs(yd(:,3:4)),[],'all'),sqrt(mean(yd(:,3:4).^2,'all'))];
    end
end
v=max(e.metriche,[],1);
e.fallimentiM5=sum(v(1:4)>cfg.targetM5);
end
