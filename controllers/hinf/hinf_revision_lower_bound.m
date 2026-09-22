function b = hinf_revision_lower_bound(G,W1,W2,omega)
% A ogni w, X=KS e S=I-GX. Per ||v||=1:
% ||[a*S;b*X]v||^2 >= min_x a^2||v-G*x||^2+b^2||x||^2
% = v'*(a^2*I-a^4*G*(a^2*G'*G+b^2*I)^(-1)*G')*v.
% Il massimo su v e a^2*b^2/(b^2+a^2*sigma_min(G)^2).
% v e il vettore singolare SINISTRO meno efficace. Non serve rango pieno:
% per sigma_min=0 il limite e a. Richiede b>0 e pesi scalari replicati.
% Il massimo su griglia e <= sup continuo: rigetta, non prova fattibilita.
validateattributes(omega,{'numeric'},{'vector','real','finite','positive'});
[ny,nu]=size(G);
assert(ny==nu && isequal(size(W1),[ny ny]) && isequal(size(W2),[nu nu]), ...
    'HinfBound:Dimensions','Richiesta pianta quadrata e pesi conformi.');
f1=freqresp(W1,omega); f2=freqresp(W2,omega);
ref1=reshape(f1(1,1,:),1,1,[]).*eye(ny);
ref2=reshape(f2(1,1,:),1,1,[]).*eye(nu);
assert(max(abs(f1-ref1),[],'all')<=1e-10*max(1,max(abs(f1),[],'all')) && ...
    max(abs(f2-ref2),[],'all')<=1e-10*max(1,max(abs(f2),[],'all')), ...
    'HinfBound:ScalarWeights','Il bound richiede pesi scalari replicati.');
sv = sigma(G,omega);
a = reshape(abs(freqresp(W1(1,1),omega)),1,[]);
u = reshape(abs(freqresp(W2(1,1),omega)),1,[]);
assert(all(isfinite(a)) && all(isfinite(u) & u>0) && all(isfinite(sv),'all'), ...
    'HinfBound:FinitePositive','Risposte finite e |W2|>0 richieste.');
b.curve = a.*u./hypot(u,a.*sv(end,:));
[b.value,i] = max(b.curve);
b.frequency = omega(i);
b.reject = b.value >= 1;
end
