function synthesis = synthesize_m10_hinfsyn(P, config)
%SYNTHESIZE_M10_HINFSYN Run the single default-options M10 synthesis.

arguments
    P {mustBeA(P, {'ss', 'tf', 'zpk'})}
    config (1, 1) struct = hinf_specs_m10
end

assert(config.nominalSynthesis && isempty(config.W3) && ...
    config.useDefaultHinfsynOptions && ...
    ~config.weightRetuningEnabled && ~config.robustAnalysisEnabled && ...
    ~config.hinfstructEnabled && ~config.twoDegreeOfFreedomEnabled, ...
    'M10Synthesis:ScopeViolation', ...
    'M10 must use the single nominal default-options 1-DoF baseline.');

lastwarn('');
[Khinf, CLhinf, gammaHinf, infoHinf] = hinfsyn( ...
    P, config.nmeas, config.ncont);
[warningMessage, warningIdentifier] = lastwarn;

synthesis.Khinf = Khinf;
synthesis.CLhinf = CLhinf;
synthesis.gammaHinf = gammaHinf;
synthesis.infoHinf = infoHinf;
synthesis.warningMessage = string(warningMessage);
synthesis.warningIdentifier = string(warningIdentifier);
synthesis.controllerOrder = order(Khinf);
synthesis.controllerPoles = pole(Khinf);
synthesis.controllerStableInIsolation = isstable(Khinf);
synthesis.defaultOptionsUsed = true;
synthesis.method = "hinfsyn(P,2,2)";

assert(~isempty(Khinf) && isequal(size(Khinf), [2, 2]), ...
    'M10Synthesis:EmptyController', ...
    'hinfsyn did not return the required 2-by-2 controller.');
assert(isfinite(gammaHinf) && gammaHinf > 0, ...
    'M10Synthesis:InvalidGamma', ...
    'hinfsyn returned a non-finite or non-positive gamma.');
end
