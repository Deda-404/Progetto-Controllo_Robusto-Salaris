function config=lqgi_validation_specs
%LQGI_VALIDATION_SPECS Protocollo M8, guadagni e covarianze M6/M7 invariati.
base=m8_specs; integral=lqg_specs_m7; estimator=lqg_specs_m6;
config=struct('solver',base.solver,'simulation',base.simulation, ...
    'tracking',base.tracking,'disturbance',base.disturbance, ...
    'noise',base.noise,'equilibrium',base.equilibrium,'ras',base.ras);
% Il servo M7 lento richiede l'orizzonte nominale M7 anche nel confronto NL.
config.simulation.trackingHorizon=integral.referenceHorizon;
config.noise.sampleStdMeasurementRad=deg2rad(estimator.kalman.sigmaMeasurementDeg);
config.noise.sampleStdProcessNm=[estimator.kalman.sigmaLinkDisturbance*[1 1], ...
    estimator.kalman.sigmaInputModel*[1 1]];
config.ras.secondarySectionEnabled=false;
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
source=fileread(fullfile(root,'analysis/nonlinear/simulate_lqgi_nonlinear.m'));
digest=java.security.MessageDigest.getInstance('SHA-256');digest.update(uint8(source));
config.ras.simulatorSourceHash=lower(reshape(dec2hex(typecast(digest.digest(),'uint8'),2).',1,[]));
maximumBisections=ceil(log2(sqrt(2)*config.ras.searchBoxDeg/config.ras.radialToleranceDeg));
config.ras.maximumSimulations=2*(numel(config.ras.coarseGridDeg)^2+ ...
    config.ras.numberDirections*(1+maximumBisections));
config.simulatorFcn=@simulate_lqgi_nonlinear;
config.saturationEnabled=false; config.antiWindupEnabled=false;
config.controllerTuningEnabled=false;
end
