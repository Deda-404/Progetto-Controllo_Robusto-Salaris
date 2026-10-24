function model = build_manual_mechanical_lft
%BUILD_MANUAL_MECHANICAL_LFT Tre forze interne per k1, k2 e Jm1.
p=sea_params_nominal; ranges=uncertainty_params_m4;
[A,B,eq,lin]=sea_linearize_static_equilibrium_analytic([pi/2;0],p);
[~,~,C,D]=sea_output_matrices;
r=ranges.selectedMechanicalRanges;
rk=r.Percentage(ismember(r.Parameter,["k1","k2"]))/100;
rj=r.Percentage(r.Parameter=="Jm1")/100;
% w_k sono coppie elastiche aggiuntive; w_J una coppia sul rotore 1.
Bw=[zeros(2,3);lin.Mbar\eye(2),zeros(2,1);zeros(2,3); ...
    -(p.Jm\eye(2)),p.Jm\[1;0]];
Cz=[diag(rk)*p.Ks*[-eye(2),zeros(2),eye(2),zeros(2)]; ...
    -rj*p.Jm(1,1)*A(7,:)];
Dz=[zeros(2,5);-rj*p.Jm(1,1)*[Bw(7,:),B(7,:)]];
model.M=ss(A,[Bw B],[Cz;C],[Dz;zeros(4,3),D]);
model.Delta=blkdiag(ureal('dk1',0,'Range',[-1 1]), ...
    ureal('dk2',0,'Range',[-1 1]),ureal('dJm1',0,'Range',[-1 1]));
model.G=lft(model.Delta,model.M);
model.equilibrium=eq;
model.signals="z=[0.1*k10*(theta1-q1);0.1*k20*(theta2-q2);-0.1*J10*theta1ddot], w=Delta*z";
end
