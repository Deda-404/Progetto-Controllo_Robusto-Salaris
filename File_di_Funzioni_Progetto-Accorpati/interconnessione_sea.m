function [P,CL]=interconnessione_sea(pianta,p,ny,K)
%INTERCONNESSIONE_SEA Pianta generalizzata e misura nelle convenzioni comuni.
% P: [r;d;u] -> [We*(q-Mo*r);Wu*u;r;y].
% CL: [r;d;v] -> [q;u;ze;zu], rumore v aggiunto ai soli encoder.
arguments
    pianta
    p (1,1) struct
    ny (1,1) double {mustBeMember(ny,[2 4])}
    K = []
end
s=tf('s'); nomi={'q1','q2','theta1','theta2'};
G=pianta(1:ny,:); G.InputName={'u1','u2','d1','d2'}; G.OutputName=nomi(1:ny);
Mo=ss(p.omegaM^2/(s^2+2*p.omegaM*s+p.omegaM^2)*eye(2));
Mo.InputName={'r1','r2'}; Mo.OutputName={'qm1','qm2'};
We=ss((s/p.Ms+p.omegaW1)/(s+p.omegaW1*p.As)*eye(2));
We.InputName={'e1','e2'}; We.OutputName={'ze1','ze2'};
Wu=ss(p.ku*(s+p.omegaU)/(s/p.alpha+p.omegaU)*eye(2));
Wu.InputName={'u1','u2'}; Wu.OutputName={'zu1','zu2'};
e1=sumblk('e1=q1-qm1'); e2=sumblk('e2=q2-qm2');
opzioni=connectOptions('Simplify',false);
P=connect(G,Mo,We,Wu,e1,e2,{'r1','r2','d1','d2','u1','u2'}, ...
    [{'ze1','ze2','zu1','zu2','r1','r2'},nomi(1:ny)],opzioni);
CL=[];
if ~isempty(K)
    K.InputName=[{'r1','r2'},cellstr("ym"+(1:ny))]; K.OutputName={'u1','u2'};
    somme=cell(1,ny);
    for j=1:ny,somme{j}=sumblk(char("ym"+j+"="+nomi{j}+"+v"+j));end
    CL=connect(G,K,Mo,We,Wu,e1,e2,somme{:}, ...
        [{'r1','r2','d1','d2'},cellstr("v"+(1:ny))], ...
        {'q1','q2','u1','u2','ze1','ze2','zu1','zu2'},opzioni);
end
end
