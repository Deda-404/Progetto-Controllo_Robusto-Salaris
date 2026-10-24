function model = build_manual_parametric_actuator(index,Wres)
%BUILD_MANUAL_PARAMETRIC_ACTUATOR LFT da equazioni di oscillatore e Pade1.
p=actuator_params_nominal; u=uncertainty_params_m4;
r=u.selectedActuatorRanges.Percentage/100;
wn=p.wn; zeta=p.zeta; a=p.delay/2;
dw=wn*r(1); dz=zeta*r(2); da=a*r(3);
% Stati [posizione oscillatore; velocita; stato Pade; stato peso residuo].
% Ingressi [w_wn1,w_wn2,w_zeta,w_tau,w_res,u].
[Ar,Br,Cr,Dr]=ssdata(ss(Wres)); nr=size(Ar,1);
A=blkdiag([0 1 0;-wn^2 -2*wn*zeta 0;1/a 0 -1/a],Ar);
B=zeros(3+nr,6);
B(2,:)=[wn*dw dw -2*wn*dz 0 0 wn^2];
B(3,4)=-da/a; B(4:end,5)=Br;
C=zeros(6,3+nr); D=zeros(6,6);
C(1,1)=-1; D(1,6)=1;                 % z_wn1 = u-x
C(2,1:2)=[-wn -2*zeta]; D(2,[1 3 6])=[dw -2*dz wn];
C(3,2)=1;                            % z_zeta = v
C(4,1:3)=[1/a 0 -1/a]; D(4,4)=-da/a; % z_tau = hdot
C(5,1)=1;                            % z_res = x
C(6,1:3)=[-1 0 2]; C(6,4:end)=Cr; D(6,5)=Dr;
model.M=ss(A,B,C,D);
tag=string(index);
dwBlock=ureal(char("dwn"+tag),0,'Range',[-1 1]);
dzBlock=ureal(char("dzeta"+tag),0,'Range',[-1 1]);
dtBlock=ureal(char("dtau"+tag),0,'Range',[-1 1]);
res=ultidyn(char("Dres"+tag),[1 1]);
model.Delta=blkdiag(dwBlock*eye(2),dzBlock,dtBlock,res);
model.G=lft(model.Delta,model.M);
% Seconda costruzione, automatica, usata soltanto per il confronto.
w=ureal(char("wn"+tag),wn,'Percentage',100*r(1));
z=ureal(char("zeta"+tag),zeta,'Percentage',100*r(2));
t=ureal(char("tau"+tag),p.delay,'Percentage',100*r(3));
H=uss([0 1;-w*w -2*z*w],[0;w*w],[1 0],0);
Dp=uss(-2/t,2/t,2,-1);
model.automatic=H*(Dp+Wres*res);
model.Wres=Wres;
end
