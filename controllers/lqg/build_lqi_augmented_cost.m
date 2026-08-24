function design = build_lqi_augmented_cost( ...
    m3Data, m5Data, m6Data, wi, rhoU, priorities)
%BUILD_LQI_AUGMENTED_COST Build the two-integrator M7 LQI problem.
%   xi_dot = r - Cq*x and u = -Kx*x - Ki*xi. With no PRIORITIES argument,
%   the state cost Qx is reused exactly from the approved M6 dataset. An
%   explicit PRIORITIES structure changes only the dimensionless physical
%   priorities while preserving the M6 normalization scales.

arguments
    m3Data (1, 1) struct
    m5Data (1, 1) struct
    m6Data (1, 1) struct
    wi (1, 1) double {mustBePositive, mustBeFinite}
    rhoU (1, 1) double {mustBePositive, mustBeFinite}
    priorities (1, 1) struct = struct
end

A = m3Data.Afull;
B = m3Data.Bfull;
Cq = m3Data.CfullQ;
n = size(A, 1);
p = size(Cq, 1);

assert(isequal([n, size(B, 2), p], [14, 2, 2]), ...
    'M7LQI:UnexpectedDimensions', ...
    'M7 requires the approved 14-state, two-input, two-output plant.');
assert(isfield(m6Data, 'Q') && isequal(size(m6Data.Q), [n, n]), ...
    'M7LQI:MissingM6Cost', ...
    'The approved 14-state M6 cost Q must be supplied.');

explicitPriorities = ~isempty(fieldnames(priorities));
if ~explicitPriorities
    CxCost = m6Data.Ccost;
else
    [CxCost, tunedQx, physicalScales, costInfo] = build_lqr_state_cost( ...
        m3Data, m5Data.spec, priorities);
    priorities = costInfo.priorities;
    approvedScales = m6Data.validationMetrics.cost.scales;
    assert(isequaln(physicalScales, approvedScales), ...
        'M7LQI:PhysicalScalesChanged', ...
        'M7 co-tuning must preserve the approved M6 physical scales.');
    exactM6CostReuse = isequal(tunedQx, m6Data.Q);
end

Aaug = [A, zeros(n, p); -Cq, zeros(p, p)];
Baug = [B; zeros(p, size(B, 2))];
xiScale = m5Data.spec.referenceAmplitude * ...
    m5Data.spec.settlingTimeTarget;
Qi = wi / xiScale^2;
CaugCost = [CxCost, zeros(size(CxCost, 1), p); ...
    zeros(p, n), sqrt(Qi) * eye(p)];
Qaug = CaugCost.' * CaugCost;
Qaug = (Qaug + Qaug.') / 2;
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
if explicitPriorities
    design.CaugCost = CaugCost;
    design.CxCost = CxCost;
end
design.R = R;
design.Kaug = Kaug;
design.Kx = Kaug(:, 1:n);
design.Ki = Kaug(:, n + (1:p));
design.Qi = Qi;
design.xiScale = xiScale;
design.wi = wi;
design.rhoU = rhoU;
if explicitPriorities
    design.priorities = priorities;
    design.physicalScales = physicalScales;
    design.exactM6CostReuse = exactM6CostReuse;
end
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
