function [Nff, info] = build_lqi_reference_feedforward(m3Data, Kx, config)
%BUILD_LQI_REFERENCE_FEEDFORWARD Derive the M7 2-DoF feedforward from Kx.
%   The static map is recomputed for every candidate. No M6 prefilter is
%   accepted as an input to this function.

arguments
    m3Data (1, 1) struct
    Kx (2, 14) double
    config (1, 1) struct = lqg_specs_m7
end

AclX = m3Data.Afull - m3Data.Bfull * Kx;
GdcX = dcgain(ss(AclX, m3Data.Bfull, m3Data.CfullQ, zeros(2)));
Nff = GdcX \ eye(2);

info.GdcX = GdcX;
info.condition = cond(GdcX);
info.residual = norm(GdcX * Nff - eye(2), 'fro');
info.wellConditioned = all(isfinite(Nff), 'all') && ...
    info.condition <= config.feedforwardConditionWarning && ...
    info.residual <= config.feedforwardResidualTolerance;
end
