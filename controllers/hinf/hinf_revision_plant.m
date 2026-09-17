function P = hinf_revision_plant(G,W1,W2)
% Costruzione indipendente da augw: e=r-q, z=[W1*e;W2*u].
G.InputName = {'u(1)','u(2)'}; G.OutputName = {'q(1)','q(2)'};
W1 = ss(W1); W1.InputName = {'e(1)','e(2)'};
W1.OutputName = {'z1(1)','z1(2)'};
W2 = ss(W2); W2.InputName = {'u(1)','u(2)'};
W2.OutputName = {'z2(1)','z2(2)'};
P = connect(G,W1,W2,sumblk('e = r - q',2), ...
    {'r(1)','r(2)','u(1)','u(2)'}, ...
    {'z1(1)','z1(2)','z2(1)','z2(2)','e(1)','e(2)'});
end
