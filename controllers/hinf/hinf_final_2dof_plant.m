function P = hinf_final_2dof_plant(physical,We,Wu,Mo)
%HINF_FINAL_2DOF_PLANT w=[r;d], u; z=[We*(q-Mo*r);Wu*u], yK=[r;q].
% physical ha stati condivisi e ingressi [u;d], d coppia fisica lato link.
physical.InputName={'u(1)','u(2)','d(1)','d(2)'};
physical.OutputName={'q(1)','q(2)'};
Mo=ss(Mo); Mo.InputName={'r(1)','r(2)'}; Mo.OutputName={'qm(1)','qm(2)'};
We=ss(We); We.InputName={'em(1)','em(2)'}; We.OutputName={'ze(1)','ze(2)'};
Wu=ss(Wu); Wu.InputName={'u(1)','u(2)'}; Wu.OutputName={'zu(1)','zu(2)'};
P=connect(physical,Mo,We,Wu,sumblk('em = q - qm',2), ...
    {'r(1)','r(2)','d(1)','d(2)','u(1)','u(2)'}, ...
    {'ze(1)','ze(2)','zu(1)','zu(2)','r(1)','r(2)','q(1)','q(2)'});
end
