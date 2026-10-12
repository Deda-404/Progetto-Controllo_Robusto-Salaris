function loop = final_closure_loop(A,Bu,Bd,Cq,controller)
%FINAL_CLOSURE_LOOP Full internal realization; inputs [r;d;v;wlink;wu].
ny=size(controller.Cm,1); nk=controller.order;
assert(size(A,1)==size(controller.Cm,2));
loop.A=[A+Bu*controller.Dy*controller.Cm,Bu*controller.C; ...
    controller.By*controller.Cm,controller.A];
B=[Bu*controller.Dr,Bd,Bu*controller.Dy,Bd,Bu; ...
    controller.Br,zeros(nk,2),controller.By,zeros(nk,4)];
C=[Cq,zeros(2,nk);controller.Dy*controller.Cm,controller.C];
D=[zeros(2,8+ny);controller.Dr,zeros(2,2),controller.Dy,zeros(2,4)];
loop.sys=ss(loop.A,B,C,D); loop.poles=eig(loop.A);
loop.stable=max(real(loop.poles))<-1e-8;
loop.reference=loop.sys(:,1:2); loop.disturbance=loop.sys(:,3:4);
loop.noise=loop.sys(:,5:4+ny);
loop.noiseInputIndices=5:4+ny;
end
