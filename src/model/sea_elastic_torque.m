function [tauElastic, deformation] = sea_elastic_torque(q, theta, p)
%SEA_ELASTIC_TORQUE SEA deformation and transmitted torque.
%   Q and THETA are in rad. DEFORMATION = THETA-Q is in rad and
%   TAUELASTIC = Ks*DEFORMATION is in N*m.

deformation = theta - q;
tauElastic = p.Ks * deformation;
end
