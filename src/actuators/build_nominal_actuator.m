function [Gact, info] = build_nominal_actuator(params)
%BUILD_NOMINAL_ACTUATOR Second-order actuator with first-order Pade delay.
%   Input is requested torque u; output is the effective motor torque tau.

assert(params.wn > 0 && params.zeta > 0 && params.delay > 0, ...
    'build_nominal_actuator:InvalidParameters', ...
    'wn, zeta and delay must be positive.');
assert(params.padeOrder == 1, 'build_nominal_actuator:InvalidPadeOrder', ...
    'M3 requires a first-order Pade approximation.');

secondOrderNumerator = params.wn^2;
secondOrderDenominator = [1, 2 * params.zeta * params.wn, params.wn^2];
GsecondOrder = tf(secondOrderNumerator, secondOrderDenominator, ...
    'InputName', 'u', 'OutputName', 'tau_no_delay');

padeNumerator = [-params.delay / 2, 1];
padeDenominator = [params.delay / 2, 1];
Gpade = tf(padeNumerator, padeDenominator, ...
    'InputName', 'tau_no_delay', 'OutputName', 'tau');

Gact = series(GsecondOrder, Gpade);
Gact.InputName = {'u'};
Gact.OutputName = {'tau'};

info.GsecondOrder = GsecondOrder;
info.Gpade = Gpade;
info.secondOrderPoles = pole(GsecondOrder);
info.padePole = pole(Gpade);
info.padeZero = zero(Gpade);
info.actuatorPoles = pole(Gact);
info.actuatorZeros = zero(Gact);
info.secondOrderDcGain = dcgain(GsecondOrder);
info.padeDcGain = dcgain(Gpade);
info.actuatorDcGain = dcgain(Gact);
info.secondOrderStep = stepinfo(GsecondOrder);
info.actuatorStep = stepinfo(Gact);
info.secondOrderBandwidth = bandwidth(GsecondOrder);
info.actuatorBandwidth = bandwidth(Gact);
end
