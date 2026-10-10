function parametri = parametri_pid_hinf(blocks)
% Una riga per giunto, forma parallela con pesi di setpoint b e c.
p=zeros(2,6); names={'joint1','joint2'};
for j=1:2
    b=getValue(blocks.(names{j}));
    p(j,:)=[b.Kp,b.Ki,b.Kd,b.Tf,b.b,b.c];
end
parametri=array2table(p,'VariableNames',{'Kp','Ki','Kd','Tf_s','b','c'}, ...
    'RowNames',{'Giunto1','Giunto2'});
end
