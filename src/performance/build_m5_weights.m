function [W1siso, W1, W2siso, W2, info] = build_m5_weights(spec)
%BUILD_M5_WEIGHTS Construct the two mixed-sensitivity performance weights.
%   W1 shapes the sensitivity S. At zero frequency W1(0)=1/As, so
%   ||W1*S||<1 asks for |S(0)|<As. At high frequency W1 tends to 1/Ms,
%   which allows a sensitivity peak of approximately Ms. omegaW1 places
%   the weight transition independently of the LQR velocity scale omegaB.
%
%   W2 uses a direct control penalty ku=controlWeightGain. Its gain rises
%   from ku to alpha*ku; no plant or controller coordinate is transformed.

if nargin < 1 || isempty(spec)
    spec = performance_specs_m5;
end

s = tf('s');
W1siso = (s / spec.Ms + spec.omegaW1) / ...
    (s + spec.omegaW1 * spec.As);
W2siso = spec.controlWeightGain * (s + spec.omegaU) / ...
    (s / spec.controlWeightAlpha + spec.omegaU);

W1 = blkdiag(W1siso, W1siso);
W2 = blkdiag(W2siso, W2siso);
W1.InputName = {'e1', 'e2'};
W1.OutputName = {'zq1', 'zq2'};
W2.InputName = {'u1', 'u2'};
W2.OutputName = {'zu1', 'zu2'};

highFrequencyProbe = 1e9;
info.W1.stable = isstable(W1siso);
info.W1.proper = isproper(W1siso);
info.W1.order = order(W1siso);
info.W1.dcExpected = 1 / spec.As;
info.W1.dcMeasured = dcgain(W1siso);
info.W1.hfExpected = 1 / spec.Ms;
info.W1.hfMeasured = abs(evalfr(W1siso, 1i * highFrequencyProbe));
info.W2.stable = isstable(W2siso);
info.W2.proper = isproper(W2siso);
info.W2.order = order(W2siso);
info.W2.dcExpected = spec.controlWeightGain;
info.W2.dcMeasured = dcgain(W2siso);
info.W2.hfExpected = spec.controlWeightAlpha * spec.controlWeightGain;
info.W2.hfMeasured = abs(evalfr(W2siso, 1i * highFrequencyProbe));
info.W1MimoSize = size(W1);
info.W2MimoSize = size(W2);
info.symmetricJointWeights = isequal(W1(1, 1), W1(2, 2)) && ...
    isequal(W2(1, 1), W2(2, 2));
info.finite = all(isfinite([pole(W1siso); zero(W1siso); ...
    pole(W2siso); zero(W2siso)]));
end
