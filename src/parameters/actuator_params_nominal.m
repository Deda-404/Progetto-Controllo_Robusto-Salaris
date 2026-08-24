function actuator = actuator_params_nominal
%ACTUATOR_PARAMS_NOMINAL Nominal design assumptions for both actuators.
%   Values are engineering assumptions, not experimentally identified data.

actuator.wn = 40;          % rad/s
actuator.zeta = 0.8;       % dimensionless
actuator.delay = 0.015;    % s
actuator.padeOrder = 1;    % required approximation order
end
