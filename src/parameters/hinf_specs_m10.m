function config = hinf_specs_m10
%HINF_SPECS_M10 Numerical settings for the equivalent hinfsyn baseline.

config = hinf_specs_m9;
config.generalizedPlantTolerance = 1e-10;
config.m9EquivalenceTolerance = 1e-8;
config.augwCrossCheckTolerance = 1e-10;
config.gammaConsistencyDiagnosticTolerance = 1e-3;
config.nmeas = 2;
config.ncont = 2;
config.useDefaultHinfsynOptions = true;
config.augwCrossCheckEnabled = true;
config.twoDegreeOfFreedomEnabled = false;
config.hinfstructEnabled = false;
end
