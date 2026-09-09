function tabella = validate_lyapunov_trajectories
%VALIDATE_LYAPUNOV_TRAJECTORIES Controllo indipendente mediante traiettorie NL.
% Otto direzioni nel piano q, sulla frontiera di ciascuno dei due livelli.
% Il test NON amplia la certificazione analitica alla regione campionata.
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
dati=load(fullfile(root,'results','data','lyapunov_ras_nominal.mat'));
opzioni=odeset('RelTol',1e-8,'AbsTol',1e-13,'MaxStep',0.005);
nomi=strings(48,1); tipo=nomi; direzione=zeros(48,1);
maxIncrementoRelativo=direzione; maxVdotRelativa=direzione;
rapportoFinaleV=direzione; erroreFinaleQ=direzione;
traiettorie=cell(48,1); indice=0;
for k=1:3
    r=dati.risultati{k};
    livelli=[r.bound.rhoCertified,r.rhoNumerical];
    for h=1:2
        for j=1:8
            indice=indice+1; angolo=(j-1)*pi/4;
            q0=sqrt(livelli(h))*(chol(r.sectionP)\[cos(angolo);sin(angolo)]);
            z0=r.J*q0;
            [tempo,z]=ode23t(@(~,x) sea_closed_loop_rhs(x,r.model),[0 8],z0,opzioni);
            valoriV=sum((z*r.P).*z,2);
            derivata=zeros(numel(tempo),1);
            for t=1:numel(tempo)
                dz=sea_closed_loop_rhs(z(t,:)',r.model);
                derivata(t)=2*z(t,:)*r.P*dz;
            end
            nomi(indice)=r.name; tipo(indice)="analitico";
            if h==2, tipo(indice)="campionato_non_certificato"; end
            direzione(indice)=rad2deg(angolo);
            maxIncrementoRelativo(indice)=max(diff(valoriV))/valoriV(1);
            maxVdotRelativa(indice)=max(derivata)/valoriV(1);
            rapportoFinaleV(indice)=valoriV(end)/valoriV(1);
            erroreFinaleQ(indice)=norm(z(end,1:2),inf);
            traiettorie{indice}=struct('time',tempo,'q',z(:,1:2), ...
                'V',valoriV,'Vdot',derivata,'initialState',z0);
        end
    end
end
tabella=table(nomi,tipo,direzione,maxIncrementoRelativo,maxVdotRelativa, ...
    rapportoFinaleV,erroreFinaleQ);
save(fullfile(root,'results','data','lyapunov_trajectories.mat'), ...
    'tabella','traiettorie','opzioni','-v7');
writetable(tabella,fullfile(root,'results','data','lyapunov_trajectories.csv'));
disp(tabella);
end
