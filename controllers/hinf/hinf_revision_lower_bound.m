function b = hinf_revision_lower_bound(G,W1,W2,omega)
% Limite necessario del paragrafo 8.4.1; il campionamento non e sufficiente.
sv = sigma(G,omega);
a = reshape(abs(freqresp(W1(1,1),omega)),1,[]);
u = reshape(abs(freqresp(W2(1,1),omega)),1,[]);
b.curve = a.*u./hypot(u,a.*sv(end,:));
[b.value,i] = max(b.curve);
b.frequency = omega(i);
b.reject = b.value >= 1;
end
