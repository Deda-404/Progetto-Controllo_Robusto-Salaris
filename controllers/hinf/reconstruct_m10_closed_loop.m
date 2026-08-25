function reconstruction = reconstruct_m10_closed_loop( ...
    G, Gd, W1, W2, synthesis, config)
%RECONSTRUCT_M10_CLOSED_LOOP Reuse the validated controller-agnostic audit.

arguments
    G {mustBeA(G, {'ss', 'tf', 'zpk'})}
    Gd {mustBeA(Gd, {'ss', 'tf', 'zpk'})}
    W1 {mustBeA(W1, {'ss', 'tf', 'zpk'})}
    W2 {mustBeA(W2, {'ss', 'tf', 'zpk'})}
    synthesis (1, 1) struct
    config (1, 1) struct = hinf_specs_m10
end

mapped.Kmix = synthesis.Khinf;
mapped.CLmix = synthesis.CLhinf;
mapped.gamma = synthesis.gammaHinf;
G = localClearNames(ss(G));
Gd = localClearNames(ss(Gd));
W1 = localClearNames(ss(W1));
W2 = localClearNames(ss(W2));
mapped.Kmix = localClearNames(mapped.Kmix);
mapped.CLmix = localClearNames(mapped.CLmix);
reconstruction = reconstruct_m9_mixed_sensitivity( ...
    G, Gd, W1, W2, mapped, config);
reconstruction.method = "independent physical-loop reconstruction";
end

function system = localClearNames(system)
system.InputName = repmat({''}, size(system, 2), 1);
system.OutputName = repmat({''}, size(system, 1), 1);
end
