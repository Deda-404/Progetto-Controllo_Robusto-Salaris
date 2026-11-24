function [P,CL]=interconnessione_sea(pianta,p,ny,K)
%INTERCONNESSIONE_SEA Pianta generalizzata comune a sintesi e analisi (Cap. 6, 8, 9).
%
%   P = interconnessione_sea(pianta,p,ny)       pianta generalizzata
%   [P,CL] = interconnessione_sea(pianta,p,ny,K) anche il chiuso con K
%
% pianta: impianto [u1 u2 d1 d2] -> [q1 q2 theta1 theta2] (nominale, A o B).
% ny=2: il controllore misura solo q; ny=4: misura q e theta.
%
% P: [r;d;u] -> [We*(q-Mo*r); Wu*u; r; y].
%   e = q - Mo*r e l'errore rispetto al modello desiderato Mo, non
%   rispetto al gradino: si chiede di seguire una risposta realistica
%   (assestamento ~2 s) invece di un gradino istantaneo.
%   ze = We*e, zu = Wu*u sono le uscite prestazionali pesate.
% CL: [r;d;v] -> [q;u;ze;zu], con rumore v aggiunto ai soli encoder.
% Le soglie NP/RP sono ||CL(ze,zu <- r)||<1 oppure ||CL(ze,zu <- r,d)||<1.
% Pesi (stessi in tutto il progetto, vedi parametri_sea):
%   We(s)=(s/3+2)/(s+0.3), Wu(s)=0.003(s+80)/(s/6+80), Mo(s)=9/(s+3)^2,
% tutti diagonali 2x2 (stesso peso sui due giunti, nessun accoppiamento).
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
