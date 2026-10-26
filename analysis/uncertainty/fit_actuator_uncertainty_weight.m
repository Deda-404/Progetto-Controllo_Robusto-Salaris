function fit = fit_actuator_uncertainty_weight(family, uncertainty, mode)
%FIT_ACTUATOR_UNCERTAINTY_WEIGHT Verify a first-order multiplicative cover.
%   A first-order weight is chosen a priori because the actuator family has
%   one low-frequency-to-high-frequency transition. UCOVER identifies its
%   coefficients; MATLAB then verifies that it covers every declared sample.
%   Third argument "additiveComparison" returns analytic WA/WR bounds for
%   the optional comparison, without changing the historical two-argument call.

if nargin < 3, mode = "historical"; end
if strcmp(mode,"additiveComparison")
    fit = localAnalyticWeights(uncertainty);
    return
end
assert(strcmp(mode,"historical"),'SEAWeights:Mode','Unknown uncertainty-weight mode.');

chosenOrder = 1;
[~, coverInfo] = ucover(family.models, family.nominalPadeFrd, ...
    chosenOrder, [], 'InputMult');
WI = uncertainty.weightSafetyFactor * coverInfo.W1;

weightMagnitude = squeeze(abs(freqresp(WI, family.frequencies))).';
errorMagnitude = abs(family.multiplicativeErrors);
ratioMatrix = errorMagnitude ./ weightMagnitude;
marginMatrix = weightMagnitude - errorMagnitude;
[worstRatio, linearIndex] = max(ratioMatrix(:));
[criticalSampleIndex, criticalFrequencyIndex] = ind2sub( ...
    size(ratioMatrix), linearIndex);
coverageTolerance = 1e-9;

assert(isstable(WI) && isproper(WI), 'M4Weight:InvalidWeight', ...
    'The declared first-order WI must be stable and proper.');
assert(worstRatio <= 1 + coverageTolerance && ...
    min(marginMatrix(:)) >= -coverageTolerance, 'M4Weight:NoCover', ...
    'The declared first-order WI does not cover the actuator family.');

fit.WI = WI;
fit.selectedOrder = chosenOrder;
fit.weightMagnitude = weightMagnitude;
fit.worstRatio = worstRatio;
fit.minimumCoverageMargin = min(marginMatrix(:));
fit.criticalFrequency = family.frequencies(criticalFrequencyIndex);
fit.criticalSampleIndex = criticalSampleIndex;
fit.criticalSample = family.metadata.SampleId(criticalSampleIndex);
fit.criticalSampleParameters = family.metadata(criticalSampleIndex, :);
fit.coverageTolerance = coverageTolerance;
fit.safetyFactor = uncertainty.weightSafetyFactor;
fit.poles = pole(WI);
fit.zeros = zero(WI);
fit.stable = isstable(WI);
fit.proper = isproper(WI);
fit.coverInfo = coverInfo;
fit.designChoice = ...
    "first order chosen from the single-transition shape; coverage verified";
fit.convention = ...
    "Ga_var = Ga_nom * (1 + WI * Delta), ||Delta||_inf <= 1";
end

function f = localAnalyticWeights(u)
% Bounds on the complete parameter box, not a fit to the sampled FRD family.
t = u.selectedActuatorRanges;
w0=t.NominalValue(t.Parameter=="wn"); z0=t.NominalValue(t.Parameter=="zeta");
T0=t.NominalValue(t.Parameter=="delay");
wm=t.LowerBound(t.Parameter=="wn"); wp=t.UpperBound(t.Parameter=="wn");
zm=t.LowerBound(t.Parameter=="zeta"); zp=t.UpperBound(t.Parameter=="zeta");
Tm=t.LowerBound(t.Parameter=="delay"); Tp=t.UpperBound(t.Parameter=="delay");
assert(wm>0 && zm>0 && zm<=1 && Tm>0);
a=max(abs([wm wp].^2-w0^2));
% Max |2*z0*w0*w^2-2*w0^2*z*w|: endpoints in z, endpoints/stationary in w.
b=0;
for z=[zm zp]
    stationary=w0*z/(2*z0);
    candidates=[wm wp min(wp,max(wm,stationary))];
    b=max(b,max(abs(2*z0*w0*candidates.^2-2*w0^2*z*candidates)));
end
kappa=(1+24^(2/3))^(3/2)/12;
s=tf('s'); H0=w0^2/(s^2+2*z0*w0*s+w0^2);
WR=kappa*(Tp*s/(1+Tp*s))^3;
WH=sqrt(2)*s*(a*s+b)/(zm*(s+wm)^2*(s^2+2*z0*w0*s+w0^2));
WT=max(Tp-T0,T0-Tm)*s/((1+Tm*s/2)*(1+T0*s/2));
Hbar=wp^2/(zm*(s+wm)^2);
% Spectral factor in x=s/w0. Factor out the common zero at x=0 first.
L=[1 wm/w0]; D=[1 2*z0 1];
A=[Tm*w0/2 1]; B=[T0*w0/2 1]; C=[Tp*w0 1];
L2=conv(L,L); C3=conv(conv(C,C),C);
den=conv(conv(conv(conv(L2,D),A),B),C3);
% These are the three common-denominator numerators divided by x.
n1=sqrt(2)/(zm*w0^2)*conv([a b/w0],conv(conv(A,B),C3));
n2=max(Tp-T0,T0-Tm)*w0*conv(L2,C3);
n3=wp^2/(zm*w0^2)*kappa*(Tp*w0)^3*conv([1 0 0],conv(conv(D,A),B));
nums={n1,n2,n3}; spectral=zeros(1,13);
for j=1:3
    n=nums{j}; term=3*conv(n,n.*(-1).^(numel(n)-1:-1:0));
    spectral(end-numel(term)+1:end)=spectral(end-numel(term)+1:end)+term;
end
rr=roots(spectral); left=rr(real(rr)<-1e-8);
assert(numel(left)==6,'SEAWeights:Factor','Unexpected spectral-factor roots.');
num=real(poly(left)); num=num*sqrt(spectral(end))/abs(num(end));
WA=tf(conv(num,[1 0])./w0.^(7:-1:0),den./w0.^(9:-1:0));
grid=logspace(-5,7,2401);
target=3*(abs(squeeze(freqresp(WH,grid))).^2 ...
    +abs(squeeze(freqresp(H0*WT,grid))).^2+abs(squeeze(freqresp(Hbar*WR,grid))).^2);
actual=abs(squeeze(freqresp(WA,grid))).^2;
factorError=max(abs(actual-target)./max(target,realmin));
assert(factorError<1e-7 && isstable(WA) && isproper(WA),'SEAWeights:FactorAudit','Invalid factor.');
f=struct('WA',WA,'WR',WR,'WH',WH,'WT',WT,'Hbar',Hbar,'H0',H0, ...
    'a',a,'b',b,'kappa',kappa,'factorRelativeError',factorError, ...
    'range',[wm wp;zm zp;Tm Tp],'nominal',[w0 z0 T0], ...
    'scope','Constant delays; physical subset of B, B subset of additive A at unit radius');
end
