function evaluation = evaluate_lqri_candidate( ...
    m3Data, m5Data, m6Data, design, config)
%EVALUATE_LQRI_CANDIDATE Servo con Kalman M6 e integrale dell'errore misurato.
%   Si costruisce la chiusura reale z=[x;xi;xhat], di ordine 30, senza
%   cancellazioni di stati. Ingressi: [r;d;v], con v rumore dei 4 encoder.
%   Le prove dei due giunti hanno stato iniziale nullo e rumore nullo.

arguments
    m3Data (1, 1) struct
    m5Data (1, 1) struct
    m6Data (1, 1) struct
    design (1, 1) struct
    config (1, 1) struct = lqg_specs_m7
end

A = m3Data.Afull;
B = m3Data.Bfull;
Cq = m3Data.CfullQ;
Ctheta = m3Data.CfullMeas(3:4, :);
Bd = m5Data.BdFull;
Ks = m3Data.mechanicalParams.Ks;
n = size(A, 1);
Kx = design.Kx;
Ki = design.Ki;

C=m3Data.CfullMeas; L=m6Data.L;
% E estrae le due posizioni link dagli encoder [q;theta]. Lo stato xi
% non e stimato: xi_dot=r-E*y. Il medesimo comando u alimenta lo stimatore.
E=[eye(2),zeros(2)];
assert(isequal(size(L),[14,4]) && norm(E*C-Cq,'fro')<1e-12, ...
    'M7LQRI:EncoderSelection','Kalman M6 o selezione encoder incoerenti.');
Acl=[A,-B*Ki,-B*Kx; -Cq,zeros(2),zeros(2,n); ...
    L*C,-B*Ki,A-B*Kx-L*C];
Bcl=[zeros(n,2),Bd,zeros(n,4);eye(2),zeros(2),-E; ...
    zeros(n,4),L];
Ccl=[Cq,zeros(2,2+n);Ctheta,zeros(2,2+n); ...
    zeros(2,n),-Ki,-Kx;zeros(2,n),eye(2),zeros(2,n)];
Dcl=zeros(8,8);
closedLoop = ss(Acl, Bcl, Ccl, Dcl, ...
    'InputName', {'r1','r2','d1','d2','vq1','vq2','vtheta1','vtheta2'}, ...
    'OutputName', {'q1', 'q2', 'theta1', 'theta2', ...
    'u1', 'u2', 'xi1', 'xi2'});

spec = m5Data.spec;
referenceTime = (0:config.simulationTimeStep:config.referenceHorizon).';
disturbanceTime = ...
    (0:config.simulationTimeStep:config.disturbanceHorizon).';
tracking = zeros(2, 6);
disturbance = zeros(2, 6);
referenceOutput = cell(2, 1);
disturbanceOutput = cell(2, 1);
peakDelta = zeros(2, 1);
peakElasticTorque = zeros(2, 1);
trackingDc = dcgain(closedLoop(1:2, 1:2));
disturbanceDc = dcgain(closedLoop(1:2, 3:4));

for jointIndex = 1:2
    input = zeros(numel(referenceTime), 8);
    input(:, jointIndex) = spec.referenceAmplitude;
    output = lsim(closedLoop, input, referenceTime);
    referenceOutput{jointIndex} = output;
    q = output(:, 1:2);
    theta = output(:, 3:4);
    u = output(:, 5:6);
    xi = output(:, 7:8);
    finalQ = trackingDc(:, jointIndex) * spec.referenceAmplitude;
    tracking(jointIndex, 1) = localSettlingTime( ...
        q(:, jointIndex), finalQ(jointIndex), referenceTime, ...
        config.settlingBandFraction * abs(spec.referenceAmplitude));
    tracking(jointIndex, 2) = 100 * max(0, ...
        (max(q(:, jointIndex)) - spec.referenceAmplitude) / ...
        spec.referenceAmplitude);
    tracking(jointIndex, 3) = abs( ...
        finalQ(jointIndex) - spec.referenceAmplitude) / ...
        spec.referenceAmplitude;
    otherJoint = 3 - jointIndex;
    tracking(jointIndex, 4) = max(abs(q(:, otherJoint))) / ...
        max(max(abs(q(:, jointIndex))), eps);
    tracking(jointIndex, 5) = max(abs(u), [], 'all');
    tracking(jointIndex, 6) = max(abs(xi), [], 'all');
    deformation = theta - q;
    peakDelta(jointIndex) = max(abs(deformation), [], 'all');
    peakElasticTorque(jointIndex) = max(abs( ...
        deformation * Ks.'), [], 'all');

    input = zeros(numel(disturbanceTime), 8);
    input(:, jointIndex + 2) = spec.disturbanceTorqueAmplitude;
    output = lsim(closedLoop, input, disturbanceTime);
    disturbanceOutput{jointIndex} = output;
    q = output(:, 1:2);
    u = output(:, 5:6);
    xi = output(:, 7:8);
    finalQ = disturbanceDc(:, jointIndex) * ...
        spec.disturbanceTorqueAmplitude;
    affectedPeak = max(abs(q(:, jointIndex)));
    disturbance(jointIndex, 1) = affectedPeak;
    disturbance(jointIndex, 2) = finalQ(jointIndex);
    disturbance(jointIndex, 3) = localSettlingTime( ...
        q(:, jointIndex), finalQ(jointIndex), disturbanceTime, ...
        config.settlingBandFraction * max(affectedPeak, eps));
    otherJoint = 3 - jointIndex;
    disturbance(jointIndex, 4) = max(abs(q(:, otherJoint))) / ...
        max(affectedPeak, eps);
    disturbance(jointIndex, 5) = max(abs(u), [], 'all');
    disturbance(jointIndex, 6) = max(abs(xi), [], 'all');
end

trackingMetrics = array2table([(1:2).', tracking], ...
    'VariableNames', {'ReferenceJoint', 'SettlingTime', 'Overshoot', ...
    'SteadyStateErrorRelative', 'CrossCouplingPeakRatio', ...
    'PeakControl', 'PeakXi'});
disturbanceMetrics = array2table([(1:2).', disturbance], ...
    'VariableNames', {'DisturbanceJoint', 'PeakQ', ...
    'SteadyStateOffset', 'SettlingTime', ...
    'CrossCouplingPeakRatio', 'PeakControl', 'PeakXi'});

stable = all(real(eig(Acl)) < -config.numericStabilityTolerance);
trackingPass = stable && all( ...
    trackingMetrics.SettlingTime <= spec.settlingTimeTarget) && ...
    all(trackingMetrics.Overshoot <= spec.overshootTarget) && ...
    all(trackingMetrics.SteadyStateErrorRelative <= ...
        spec.steadyStateTrackingTarget);
disturbancePass = stable && all(abs( ...
    disturbanceMetrics.SteadyStateOffset) <= ...
    config.disturbanceSteadyStateTolerance);
deformationScale = design.physicalScales.delta;
worstPeakXi = max([trackingMetrics.PeakXi; disturbanceMetrics.PeakXi]);

% T converte [x;xi;xhat] in [x;xi;ex]. La triangolarita dimostra la
% separazione nominale; si controllano anche tutti i 30 autovalori reali.
T=[eye(n),zeros(n,2+n);zeros(2,n),eye(2),zeros(2,n); ...
    eye(n),zeros(n,2),-eye(n)];
Aseparated=[A-B*Kx,-B*Ki,B*Kx;-Cq,zeros(2,2+n); ...
    zeros(n,n+2),A-L*C];
evaluation.separationResidual=norm(T*Acl/T-Aseparated,'fro');
evaluation.Aseparated=Aseparated;
evaluation.transformation=T;
evaluation.fullPoles=eig(Acl);
evaluation.estimatorPoles=eig(A-L*C);
evaluation.L=L; evaluation.Qn=m6Data.Qn; evaluation.Rn=m6Data.Rn;
% Realizzazione autonoma: 14 stati xhat e 2 stati xi, ingressi [r;y].
% Non esiste feedthrough del riferimento: D=0, nessun Nr/Nff.
evaluation.Klqri=ss([A-L*C-B*Kx,-B*Ki;zeros(2,n+2)], ...
    [zeros(n,2),L;eye(2),-E],[-Kx,-Ki],zeros(2,6));
assert(stable && all(real(evaluation.estimatorPoles)<0) && ...
    evaluation.separationResidual<1e-9,'M7LQRI:InternalStability', ...
    'La chiusura reale o il principio di separazione non sono verificati.');
evaluation.closedLoop = closedLoop;
evaluation.trackingMetrics = trackingMetrics;
evaluation.disturbanceMetrics = disturbanceMetrics;
evaluation.referenceTime = referenceTime;
evaluation.referenceOutput = referenceOutput;
evaluation.disturbanceTime = disturbanceTime;
evaluation.disturbanceOutput = disturbanceOutput;
evaluation.summary.stable = stable;
evaluation.summary.trackingPass = trackingPass;
evaluation.summary.disturbancePass = disturbancePass;
evaluation.summary.fundamentalPass = trackingPass && disturbancePass;
evaluation.summary.worstSettlingTime = max(trackingMetrics.SettlingTime);
evaluation.summary.worstOvershoot = max(trackingMetrics.Overshoot);
evaluation.summary.worstSteadyStateErrorRelative = ...
    max(trackingMetrics.SteadyStateErrorRelative);
evaluation.summary.worstCrossCouplingPeakRatio = ...
    max(trackingMetrics.CrossCouplingPeakRatio);
evaluation.summary.worstPeakControl = max(trackingMetrics.PeakControl);
evaluation.summary.peakControlNormalized = ...
    evaluation.summary.worstPeakControl / spec.uScale;
evaluation.summary.worstPeakDeformation = max(peakDelta);
evaluation.summary.peakDeformationNormalized = ...
    max(peakDelta) / deformationScale;
evaluation.summary.worstPeakElasticTorque = max(peakElasticTorque);
evaluation.summary.worstPeakXi = worstPeakXi;
evaluation.summary.worstDisturbancePeakQ = ...
    max(disturbanceMetrics.PeakQ);
evaluation.summary.worstDisturbanceSettlingTime = ...
    max(disturbanceMetrics.SettlingTime);
evaluation.summary.worstDisturbanceSteadyStateOffset = ...
    max(abs(disturbanceMetrics.SteadyStateOffset));
evaluation.summary.worstDisturbanceCrossCouplingPeakRatio = ...
    max(disturbanceMetrics.CrossCouplingPeakRatio);
evaluation.summary.worstDisturbancePeakControl = ...
    max(disturbanceMetrics.PeakControl);
% La memoria integrale e riportata direttamente in rad*s (worstPeakXi).
% Non viene dedotto un indice di windup senza un modello di saturazione.
end

function settlingTime = localSettlingTime(signal, finalValue, time, threshold)
outsideBand = abs(signal - finalValue) > max(threshold, 100 * eps);
lastOutside = find(outsideBand, 1, 'last');
if isempty(lastOutside)
    settlingTime = 0;
elseif lastOutside == numel(time)
    settlingTime = inf;
else
    settlingTime = time(lastOutside + 1);
end
end
