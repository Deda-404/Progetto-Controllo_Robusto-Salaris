function design = design_lqr_m6(m3Data, m5Data, config)
%DESIGN_LQR_M6 Build the single approved Bryson-normalized LQR design.

arguments
    m3Data (1, 1) struct
    m5Data (1, 1) struct
    config (1, 1) struct = lqg_specs_m6
end

priorities = rmfield(config.lqr, {'rhoU', 'rationale'});
[Ccost, Q, scales, costInfo] = ...
    build_lqr_state_cost(m3Data, m5Data.spec, priorities);
R = config.lqr.rhoU / m5Data.spec.uScale^2 * eye(2);
K = lqr(m3Data.Afull, m3Data.Bfull, Q, R);
Acl = m3Data.Afull - m3Data.Bfull * K;
staticTrackingGain = -m3Data.CfullQ * (Acl \ m3Data.Bfull);
Nr = staticTrackingGain \ eye(2);
regulatorPoles = eig(Acl);
evaluation = evaluate_m6_closed_loop( ...
    m3Data.Afull, m3Data.Bfull, m3Data.CfullQ, ...
    m3Data.CfullMeas(3:4, :), m5Data.BdFull, K, Nr, ...
    m3Data.mechanicalParams.Ks, m5Data.spec, config, false);

assert(all(real(regulatorPoles) < -config.numericStabilityTolerance), ...
    'M6LQR:Unstable', 'The approved LQR cost does not stabilize M3.');
assert(norm(staticTrackingGain * Nr - eye(2), 'fro') <= 1e-10, ...
    'M6LQR:Prefilter', 'The reference prefilter is inconsistent.');

design.Ccost = Ccost;
design.Q = Q;
design.R = R;
design.K = K;
design.Nr = Nr;
design.scales = scales;
design.costInfo = costInfo;
design.priorities = priorities;
design.rhoU = config.lqr.rhoU;
design.regulatorPoles = regulatorPoles;
design.alphaController = min(-real(regulatorPoles));
design.staticTrackingGain = staticTrackingGain;
design.prefilterCondition = cond(staticTrackingGain);
design.prefilterResidual = norm(staticTrackingGain * Nr - eye(2), 'fro');
design.evaluation = evaluation;
design.method = ...
    "Bryson-style physical scales with one documented dimensionless correction";
end
