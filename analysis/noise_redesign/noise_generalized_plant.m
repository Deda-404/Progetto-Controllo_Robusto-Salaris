function P = noise_generalized_plant(physical,W1,W2,Mo,Wn)
% 1 - Pianta condivisa: [r;d;nu;u] -> [ze;zu;r;qmis].
physical.InputName={'u(1)','u(2)','d(1)','d(2)'};
physical.OutputName={'q(1)','q(2)'};
Mo=ss(Mo); Mo.InputName={'r(1)','r(2)'}; Mo.OutputName={'qm(1)','qm(2)'};
W1=ss(W1); W1.InputName={'em(1)','em(2)'}; W1.OutputName={'ze(1)','ze(2)'};
W2=ss(W2); W2.InputName={'u(1)','u(2)'}; W2.OutputName={'zu(1)','zu(2)'};
Wn=ss(Wn); Wn.InputName={'nu(1)','nu(2)'}; Wn.OutputName={'v(1)','v(2)'};
P=connect(physical,Mo,W1,W2,Wn,sumblk('em = q - qm',2), ...
    sumblk('qmis = q + v',2), ...
    {'r(1)','r(2)','d(1)','d(2)','nu(1)','nu(2)','u(1)','u(2)'}, ...
    {'ze(1)','ze(2)','zu(1)','zu(2)','r(1)','r(2)','qmis(1)','qmis(2)'});
assert(isequal(size(P),[8 8]));
expected=order(physical)+order(Mo)+order(W1)+order(W2)+order(Wn);
assert(order(P)==expected,'NoisePlant:States','Stati duplicati o eliminati.');
if isa(physical,'uss')
    assert(isequal(sort(fieldnames(P.Uncertainty)),sort(fieldnames(physical.Uncertainty))));
end
end
