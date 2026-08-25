function analysis = analyze_m12_robust_performance( ...
    TzwUnc, GuncQ, nominalAudit, config)
%ANALYZE_M12_ROBUST_PERFORMANCE Run robgain and wcgain at frozen level.

arguments
    TzwUnc uss
    GuncQ uss
    nominalAudit (1, 1) struct
    config (1, 1) struct = mu_analysis_specs_m12
end

robustOptions = robOptions('Display', config.robustDisplay, ...
    'Sensitivity', config.robustSensitivity, ...
    'MussvOptions', config.robustMussvOptions);
[performanceMargin, worstPerformanceUncertainty, performanceInfo] = ...
    robgain(TzwUnc, config.gammaTarget, robustOptions);
assert(performanceMargin.LowerBound <= ...
    performanceMargin.UpperBound + config.boundTolerance, ...
    'M12RP:InvalidBounds', ...
    'robgain returned reversed performance-margin bounds.');

if nominalAudit.NPOutcome == "FAIL"
    outcome = "FAIL_CERTIFIED";
elseif performanceMargin.LowerBound > 1
    outcome = "PASS_CERTIFIED";
elseif performanceMargin.UpperBound < 1
    outcome = "FAIL_CERTIFIED";
else
    outcome = "INCONCLUSIVE";
end
assert(~(nominalAudit.NPOutcome == "FAIL" && ...
    outcome == "PASS_CERTIFIED"), 'M12RP:NominalLogic', ...
    'Robust Performance cannot pass when Nominal Performance fails.');

worstPerformanceLoop = usubs(TzwUnc, worstPerformanceUncertainty);
[worstPerformanceActualGain, worstPerformancePeakFrequency] = ...
    norm(worstPerformanceLoop, inf);

worstCaseOptions = wcOptions( ...
    'ULevel', config.worstCaseUncertaintyLevel, ...
    'Display', config.robustDisplay, ...
    'Sensitivity', config.robustSensitivity, ...
    'MussvOptions', config.robustMussvOptions);
[worstCaseGain, worstGainUncertainty, worstGainInfo] = ...
    wcgain(TzwUnc, worstCaseOptions);
assert(worstCaseGain.LowerBound <= ...
    worstCaseGain.UpperBound + config.boundTolerance || ...
    (isinf(worstCaseGain.LowerBound) && ...
        isinf(worstCaseGain.UpperBound)), ...
    'M12WCGain:InvalidBounds', ...
    'wcgain returned reversed worst-case gain bounds.');
worstGainLoop = usubs(TzwUnc, worstGainUncertainty);
[worstGainActual, worstGainActualPeakFrequency] = ...
    norm(worstGainLoop, inf);
worstGainPoles = pole(worstGainLoop);
worstGainMaximumRealPart = max(real(worstGainPoles));
if isinf(worstCaseGain.UpperBound)
    gainSubstitutionCoherent = ~isstable(worstGainLoop) || ...
        worstGainMaximumRealPart >= ...
            -config.worstCaseBoundaryPoleTolerance;
else
    gainSubstitutionCoherent = worstGainActual >= ...
        worstCaseGain.LowerBound * (1 - 1e-3) && ...
        worstGainActual <= worstCaseGain.UpperBound * (1 + 1e-3);
end
assert(gainSubstitutionCoherent, 'M12WCGain:Substitution', ...
    'Worst-case substitution is inconsistent with wcgain bounds.');

analysis.robustOptions = robustOptions;
analysis.performanceMargin = performanceMargin;
analysis.worstPerformanceUncertainty = worstPerformanceUncertainty;
analysis.performanceInfo = performanceInfo;
analysis.performanceSensitivity = performanceInfo.Sensitivity;
analysis.worstPerformanceLoop = worstPerformanceLoop;
analysis.worstPerformanceActualGain = worstPerformanceActualGain;
analysis.worstPerformancePeakFrequency = ...
    worstPerformancePeakFrequency;
analysis.worstPerformanceDiagnostics = localWorstCaseDiagnostics( ...
    GuncQ.Uncertainty, worstPerformanceUncertainty, ...
    performanceMargin.CriticalFrequency);
analysis.outcome = outcome;
analysis.nominalFailurePrecedenceApplied = ...
    nominalAudit.NPOutcome == "FAIL";
analysis.worstCaseOptions = worstCaseOptions;
analysis.worstCaseGain = worstCaseGain;
analysis.worstGainUncertainty = worstGainUncertainty;
analysis.worstGainInfo = worstGainInfo;
analysis.worstGainSensitivity = worstGainInfo.Sensitivity;
analysis.worstGainLoop = worstGainLoop;
analysis.worstGainActual = worstGainActual;
analysis.worstGainActualPeakFrequency = worstGainActualPeakFrequency;
analysis.worstGainPoles = worstGainPoles;
analysis.worstGainMaximumRealPart = worstGainMaximumRealPart;
analysis.worstGainDiagnostics = localWorstCaseDiagnostics( ...
    GuncQ.Uncertainty, worstGainUncertainty, ...
    worstCaseGain.CriticalFrequency);
analysis.worstGainSubstitutionCoherent = gainSubstitutionCoherent;
end

function tableData = localWorstCaseDiagnostics( ...
    blocks, values, criticalFrequency)
names = string(fieldnames(blocks));
numberBlocks = numel(names);
BlockName = names;
Type = strings(numberBlocks, 1);
ActualValue = nan(numberBlocks, 1);
NominalValue = nan(numberBlocks, 1);
Deviation = nan(numberBlocks, 1);
NormalizedMagnitude = nan(numberBlocks, 1);
PeakGain = nan(numberBlocks, 1);
MagnitudeAtCritical = nan(numberBlocks, 1);
PhaseAtCriticalDeg = nan(numberBlocks, 1);
for index = 1:numberBlocks
    name = char(names(index));
    block = blocks.(name);
    value = values.(name);
    Type(index) = string(class(block));
    if isa(block, 'ureal')
        ActualValue(index) = value;
        NominalValue(index) = block.NominalValue;
        Deviation(index) = value - block.NominalValue;
        NormalizedMagnitude(index) = abs( ...
            actual2normalized(block, value));
    elseif isa(block, 'ultidyn')
        [PeakGain(index), ~] = norm(value, inf);
        NormalizedMagnitude(index) = PeakGain(index) / block.Bound;
        if isfinite(criticalFrequency)
            response = freqresp(value, criticalFrequency);
            MagnitudeAtCritical(index) = abs(response);
            PhaseAtCriticalDeg(index) = rad2deg(angle(response));
        end
    end
end
tableData = table(BlockName, Type, ActualValue, NominalValue, ...
    Deviation, NormalizedMagnitude, PeakGain, MagnitudeAtCritical, ...
    PhaseAtCriticalDeg);
end
