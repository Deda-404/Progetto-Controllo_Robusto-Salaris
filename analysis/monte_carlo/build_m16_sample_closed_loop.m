function closedLoop = build_m16_sample_closed_loop( ...
    physical, controller, config)
%BUILD_M16_SAMPLE_CLOSED_LOOP Explicit plant-controller shared-state loop.

arguments
    physical (1, 1) struct
    controller (1, 1) struct
    config (1, 1) struct = monte_carlo_specs_m16
end

Ap = physical.A;
Bu = physical.Bcontrol;
Bd = physical.Bdisturbance;
Cmeas = physical.Cmeasurement;
Cq = physical.Cposition;
[Ak, Bk, Ck, Dk] = ssdata(ss(controller.K));
numberControllerStates = size(Ak, 1);

if controller.id == "M6"
    Bkr = Bk(:, 1:2);
    Bky = Bk(:, 3:6);
    Dkr = Dk(:, 1:2);
    Dky = Dk(:, 3:6);
    Ainternal = [Ap + Bu * Dky * Cmeas, Bu * Ck; ...
        Bky * Cmeas, Ak];
    Breference = [Bu * Dkr; Bkr];
    Bdisturbance = [Bd; zeros(numberControllerStates, 2)];
    Ccontrol = [Dky * Cmeas, Ck];
    DcontrolReference = Dkr;
else
    Ainternal = [Ap - Bu * Dk * Cq, Bu * Ck; ...
        -Bk * Cq, Ak];
    Breference = [Bu * Dk; Bk];
    Bdisturbance = [Bd; zeros(numberControllerStates, 2)];
    Ccontrol = [-Dk * Cq, Ck];
    DcontrolReference = Dk;
end

Cposition = [Cq, zeros(2, numberControllerStates)];
Bclosed = [Breference, Bdisturbance];
Cclosed = [Cposition; Ccontrol];
Dclosed = [zeros(2, 4); DcontrolReference, zeros(2, 2)];
system = ss(Ainternal, Bclosed, Cclosed, Dclosed, ...
    'InputName', {'r1', 'r2', 'd1', 'd2'}, ...
    'OutputName', {'q1', 'q2', 'u1', 'u2'});

internalPoles = eig(Ainternal);
allFinite = all(isfinite([Ainternal(:); Bclosed(:); ...
    Cclosed(:); Dclosed(:); internalPoles(:)]));
if allFinite
    maximumRealPole = max(real(internalPoles));
    numberRhpPoles = sum(real(internalPoles) > config.stabilityTolerance);
    stable = all(real(internalPoles) < -config.stabilityTolerance);
    if stable
        classification = "STABLE";
    else
        classification = "UNSTABLE";
    end
else
    maximumRealPole = NaN;
    numberRhpPoles = NaN;
    stable = false;
    classification = "NUMERICALLY_INVALID";
end

closedLoop = struct( ...
    'controllerID', controller.id, ...
    'system', system, ...
    'trackingMap', system(:, 1:2), ...
    'trackingQ', system(1:2, 1:2), ...
    'trackingU', system(3:4, 1:2), ...
    'disturbanceMap', system(:, 3:4), ...
    'disturbanceQ', system(1:2, 3:4), ...
    'disturbanceU', system(3:4, 3:4), ...
    'internalPoles', internalPoles, ...
    'internalStateCount', size(Ainternal, 1), ...
    'maximumRealPole', maximumRealPole, ...
    'numberRhpPoles', numberRhpPoles, ...
    'stable', stable, ...
    'allFinite', allFinite, ...
    'classification', classification, ...
    'minrealUsed', false);
end
