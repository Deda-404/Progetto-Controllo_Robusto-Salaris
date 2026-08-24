function design = build_lqi_augmented_cost(m3Data, m5Data, m6Data, wi, rhoU)
%BUILD_LQI_AUGMENTED_COST Build the two-integrator M7 LQI problem.
%   xi_dot = r - Cq*x and u = -Kx*x - Ki*xi. The state cost Qx is reused
%   exactly from the approved M6 dataset; only wi and rhoU are candidates.

arguments
    m3Data (1, 1) struct
    m5Data (1, 1) struct
    m6Data (1, 1) struct
    wi (1, 1) double {mustBePositive, mustBeFinite}
    rhoU (1, 1) double {mustBePositive, mustBeFinite}
end

A = m3Data.Afull;
B = m3Data.Bfull;
Cq = m3Data.CfullQ;
Qx = m6Data.Q;
n = size(A, 1);
p = size(Cq, 1);

assert(isequal([n, size(B, 2), p], [14, 2, 2]), ...
    'M7LQI:UnexpectedDimensions', ...
    'M7 requires the approved 14-state, two-input, two-output plant.');
assert(isequal(size(Qx), [n, n]), 'M7LQI:MissingM6Cost', ...
    'The approved 14-state M6 cost Q must be supplied.');

Aaug = [A, zeros(n, p); -Cq, zeros(p, p)];
Baug = [B; zeros(p, size(B, 2))];
xiScale = m5Data.spec.referenceAmplitude * ...
    m5Data.spec.settlingTimeTarget;
Qi = wi / xiScale^2;
Qaug = blkdiag(Qx, Qi * eye(p));
R = rhoU / m5Data.spec.uScale^2 * eye(size(B, 2));

stabilizabilityRanks = zeros(n + p, 1);
augmentedPoles = eig(Aaug);
for poleIndex = 1:numel(augmentedPoles)
    stabilizabilityRanks(poleIndex) = rank([ ...
        augmentedPoles(poleIndex) * eye(n + p) - Aaug, Baug]);
end
nonStableMask = real(augmentedPoles) >= -1e-8;
isStabilizable = all(stabilizabilityRanks(nonStableMask) == n + p);
zeroPbhRank = rank([-Aaug, Baug]);
rosenbrockAtZero = [A, B; Cq, zeros(p, size(B, 2))];
zeroRosenbrockRank = rank(rosenbrockAtZero);
noZeroObstruction = zeroRosenbrockRank == n + p;

assert(isStabilizable && zeroPbhRank == n + p && noZeroObstruction, ...
    'M7LQI:AugmentedPlantNotStabilizable', ...
    ['The two-integrator augmented plant is not stabilizable or has an ' ...
    'invariant-zero obstruction at s=0. M7 must stop.']);

[Kaug, ~, servoPoles] = lqr(Aaug, Baug, Qaug, R);

design.Aaug = Aaug;
design.Baug = Baug;
design.Qaug = Qaug;
design.R = R;
design.Kaug = Kaug;
design.Kx = Kaug(:, 1:n);
design.Ki = Kaug(:, n + (1:p));
design.Qi = Qi;
design.xiScale = xiScale;
design.wi = wi;
design.rhoU = rhoU;
design.servoPoles = servoPoles;
design.structural.controllabilityRank = rank(ctrb(Aaug, Baug));
design.structural.stabilizabilityRanks = stabilizabilityRanks;
design.structural.controllablePbh = ...
    all(stabilizabilityRanks == n + p);
design.structural.isStabilizable = isStabilizable;
design.structural.zeroPbhRank = zeroPbhRank;
design.structural.zeroRosenbrockRank = zeroRosenbrockRank;
design.structural.noInvariantZeroObstructionAtZero = noZeroObstruction;
design.structural.minimumQaugEigenvalue = min(eig(Qaug));
design.structural.minimumREigenvalue = min(eig(R));
end
