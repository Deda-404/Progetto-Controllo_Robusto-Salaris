function design = design_lqr_m6(m3Data, m5Data, config)
%DESIGN_LQR_M6 Select the approved LQR through the compact M6 search.

arguments
    m3Data (1, 1) struct
    m5Data (1, 1) struct
    config (1, 1) struct = lqg_specs_m6
end

design = search_lqr_weights_m6(m3Data, m5Data, config);
assert(all(real(design.regulatorPoles) < ...
    -config.numericStabilityTolerance), ...
    'M6LQR:Unstable', 'The approved LQR cost does not stabilize M3.');
assert(design.prefilterResidual <= 1e-10, ...
    'M6LQR:Prefilter', 'The reference prefilter is inconsistent.');
end
