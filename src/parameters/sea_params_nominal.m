function p = sea_params_nominal
%SEA_PARAMS_NOMINAL Nominal mechanical parameters of the 2R SEA robot.
%   P = SEA_PARAMS_NOMINAL returns the values stated by the official
%   assignment. Matrices follow the joint order [joint 1; joint 2].

p.m1 = 1.0;                   % kg
p.m2 = 0.8;                   % kg
p.l1 = 0.4;                   % m
p.l2 = 0.3;                   % m
p.Jm = diag([0.01, 0.01]);    % kg*m^2
p.Bm = diag([0.02, 0.02]);    % N*m*s/rad
p.Ks = diag([50, 40]);        % N*m/rad
p.g = 9.81;                   % m/s^2
end
