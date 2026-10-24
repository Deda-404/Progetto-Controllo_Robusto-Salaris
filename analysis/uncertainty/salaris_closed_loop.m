function cl = salaris_closed_loop(plant,K,W1,W2,Mo)
%SALARIS_CLOSED_LOOP u=Kr*r+Ky*y; d e una coppia fisica lato link.
plant.InputName={'u1','u2','d1','d2'};
allOutputs={'q1','q2','theta1','theta2'};
plant=plant(1:size(K,2)-2,:);
plant.OutputName=allOutputs(1:size(K,2)-2);
K.InputName=[{'r1','r2'},plant.OutputName(1:size(K,2)-2)'];
K.OutputName={'u1','u2'};
W1.InputName={'em1','em2'}; W1.OutputName={'ze1','ze2'};
W2.InputName={'u1','u2'}; W2.OutputName={'zu1','zu2'};
Mo.InputName={'r1','r2'}; Mo.OutputName={'qm1','qm2'};
cl=connect(plant,K,W1,W2,Mo,sumblk('em1=q1-qm1'),sumblk('em2=q2-qm2'), ...
    {'r1','r2','d1','d2'},{'q1','q2','u1','u2','ze1','ze2','zu1','zu2'}, ...
    connectOptions('Simplify',false));
end
