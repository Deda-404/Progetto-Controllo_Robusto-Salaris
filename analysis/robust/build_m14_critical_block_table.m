function tableData = build_m14_critical_block_table( ...
    structureTable, robustStability, robustPerformance, m12)
%BUILD_M14_CRITICAL_BLOCK_TABLE Quantify M14 and A5 block diagnostics.

BlockName = structureTable.Name;
Type = structureTable.Type;
Occurrences = structureTable.Occurrences;
numberBlocks = height(structureTable);
A5RSSensitivity = nan(numberBlocks, 1);
RSSensitivity = nan(numberBlocks, 1);
RPSensitivity = nan(numberBlocks, 1);
WCGainSensitivity = nan(numberBlocks, 1);
RSWorstNormalizedMagnitude = nan(numberBlocks, 1);
RPWorstNormalizedMagnitude = nan(numberBlocks, 1);
GainWorstNormalizedMagnitude = nan(numberBlocks, 1);
for index = 1:numberBlocks
    name = char(BlockName(index));
    A5RSSensitivity(index) = localSensitivity( ...
        m12.robustStability.sensitivity, name);
    RSSensitivity(index) = localSensitivity( ...
        robustStability.sensitivity, name);
    RPSensitivity(index) = localSensitivity( ...
        robustPerformance.performanceSensitivity, name);
    WCGainSensitivity(index) = localSensitivity( ...
        robustPerformance.worstGainSensitivity, name);
    RSWorstNormalizedMagnitude(index) = localDiagnostic( ...
        robustStability.worstCaseDiagnostics, BlockName(index));
    RPWorstNormalizedMagnitude(index) = localDiagnostic( ...
        robustPerformance.worstPerformanceDiagnostics, BlockName(index));
    GainWorstNormalizedMagnitude(index) = localDiagnostic( ...
        robustPerformance.worstGainDiagnostics, BlockName(index));
end
tableData = table(BlockName, Type, Occurrences, A5RSSensitivity, ...
    RSSensitivity, RPSensitivity, WCGainSensitivity, ...
    RSWorstNormalizedMagnitude, RPWorstNormalizedMagnitude, ...
    GainWorstNormalizedMagnitude);
tableData.Properties.Description = ...
    "M14 critical blocks; unavailable sensitivities remain NaN";
end

function value = localSensitivity(sensitivity, name)
value = NaN;
if isstruct(sensitivity) && isfield(sensitivity, name)
    candidate = sensitivity.(name);
    if isscalar(candidate) && isfinite(candidate)
        value = candidate;
    end
end
end

function value = localDiagnostic(tableData, blockName)
value = NaN;
row = tableData.BlockName == blockName;
if any(row)
    candidate = tableData.NormalizedMagnitude(find(row, 1));
    if isscalar(candidate) && isfinite(candidate)
        value = candidate;
    end
end
end
