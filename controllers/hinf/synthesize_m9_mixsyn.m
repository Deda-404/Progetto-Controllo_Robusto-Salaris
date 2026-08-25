function synthesis = synthesize_m9_mixsyn(G, W1, W2, config)
%SYNTHESIZE_M9_MIXSYN Run the single frozen-weight nominal M9 synthesis.

arguments
    G {mustBeA(G, {'ss', 'tf', 'zpk'})}
    W1 {mustBeA(W1, {'ss', 'tf', 'zpk'})}
    W2 {mustBeA(W2, {'ss', 'tf', 'zpk'})}
    config (1, 1) struct = hinf_specs_m9
end

assert(config.nominalSynthesis && isempty(config.W3) && ...
    ~config.weightRetuningEnabled && ~config.robustAnalysisEnabled, ...
    'M9Synthesis:ScopeViolation', ...
    'M9 must remain a nominal mixsyn synthesis with frozen W1/W2 and W3=[].');

lastwarn('');
[Kmix, CLmix, gamma, info] = mixsyn(G, W1, W2, []);
[warningMessage, warningIdentifier] = lastwarn;

synthesis.Kmix = Kmix;
synthesis.CLmix = CLmix;
synthesis.gamma = gamma;
synthesis.info = info;
synthesis.warningMessage = string(warningMessage);
synthesis.warningIdentifier = string(warningIdentifier);
synthesis.controllerOrder = order(Kmix);
synthesis.controllerPoles = pole(Kmix);
synthesis.controllerStableInIsolation = isstable(Kmix);
synthesis.W3Absent = true;
synthesis.weightRetuningPerformed = false;
synthesis.method = "mixsyn(G,W1,W2,[])";

assert(~isempty(Kmix) && isequal(size(Kmix), [2, 2]), ...
    'M9Synthesis:EmptyController', ...
    'mixsyn did not return the required 2-by-2 controller.');
assert(isfinite(gamma) && gamma > 0, 'M9Synthesis:InvalidGamma', ...
    'mixsyn returned a non-finite or non-positive gamma.');
end
