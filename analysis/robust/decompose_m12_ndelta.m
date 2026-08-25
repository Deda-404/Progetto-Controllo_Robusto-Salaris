function decomposition = decompose_m12_ndelta(TzwUnc, config)
%DECOMPOSE_M12_NDELTA Extract and verify the normalized N-Delta form.

arguments
    TzwUnc uss
    config (1, 1) struct = mu_analysis_specs_m12
end

[M, Delta, blockStructure, normalizedUncertainty] = lftdata(TzwUnc);
reconstructed = lft(Delta, M);
deltaSize = size(Delta);
assert(deltaSize(1) == deltaSize(2) && ...
    size(M, 1) >= deltaSize(2) && size(M, 2) >= deltaSize(1), ...
    'M12NDelta:Dimensions', ...
    'The extracted LFT partition is dimensionally inconsistent.');

structureTable = localStructureTable(blockStructure);
normalizedTable = localNormalizedTable( ...
    blockStructure, normalizedUncertainty);
originalNames = sort(string(fieldnames(TzwUnc.Uncertainty)));
reconstructedNames = sort(string(fieldnames(reconstructed.Uncertainty)));
structureNames = sort(structureTable.Name);
assert(isequal(originalNames, reconstructedNames) && ...
    isequal(originalNames, structureNames) && ...
    isequal(originalNames, sort(config.expectedUncertaintyNames)), ...
    'M12NDelta:BlockSet', ...
    'The N-Delta decomposition lost or introduced uncertainty blocks.');

nominalError = localFrequencyError(reconstructed.NominalValue, ...
    TzwUnc.NominalValue, config.auditFrequencyGrid);
probe = localDeterministicProbe(TzwUnc.Uncertainty);
probeOriginal = usubs(TzwUnc, probe);
probeReconstructed = usubs(reconstructed, probe);
probeError = localFrequencyError(probeReconstructed, probeOriginal, ...
    config.auditFrequencyGrid);
normalizedValid = all(normalizedTable.NormalizedValid);
assert(nominalError <= config.lftEquivalenceTolerance && ...
    probeError <= config.lftEquivalenceTolerance && normalizedValid, ...
    'M12NDelta:Reconstruction', ...
    'The normalized LFT does not reconstruct Tzw_unc.');

M11mu = M(1:deltaSize(2), 1:deltaSize(1));
assert(isequal(size(M11mu), [deltaSize(2), deltaSize(1)]), ...
    'M12NDelta:MuPartition', ...
    'The uncertainty-to-uncertainty partition is dimensionally invalid.');

decomposition.M = M;
decomposition.Delta = Delta;
decomposition.BlkStruct = blockStructure;
decomposition.normunc = normalizedUncertainty;
decomposition.M11mu = M11mu;
decomposition.structureTable = structureTable;
decomposition.normalizedOccurrenceTable = normalizedTable;
decomposition.reconstructed = reconstructed;
decomposition.probe = probe;
decomposition.audit = struct( ...
    'MSize', size(M), ...
    'DeltaSize', deltaSize, ...
    'M11muSize', size(M11mu), ...
    'numberBlocks', numel(blockStructure), ...
    'numberNormalizedOccurrences', numel(normalizedUncertainty), ...
    'originalNames', originalNames, ...
    'reconstructedNames', reconstructedNames, ...
    'nominalFrequencyError', nominalError, ...
    'probeFrequencyError', probeError, ...
    'normalizedUncertaintyValid', normalizedValid, ...
    'passed', true, ...
    'minrealUsed', false);
end

function tableData = localStructureTable(blockStructure)
numberBlocks = numel(blockStructure);
Name = strings(numberBlocks, 1);
Rows = zeros(numberBlocks, 1);
Columns = zeros(numberBlocks, 1);
Type = strings(numberBlocks, 1);
Occurrences = zeros(numberBlocks, 1);
for index = 1:numberBlocks
    Name(index) = string(blockStructure(index).Name);
    Rows(index) = blockStructure(index).Size(1);
    Columns(index) = blockStructure(index).Size(2);
    Type(index) = string(blockStructure(index).Type);
    Occurrences(index) = blockStructure(index).Occurrences;
end
tableData = table(Name, Rows, Columns, Type, Occurrences);
end

function tableData = localNormalizedTable( ...
    blockStructure, normalizedUncertainty)
numberOccurrences = sum([blockStructure.Occurrences]);
assert(numel(normalizedUncertainty) == numberOccurrences, ...
    'M12NDelta:NormalizedOccurrences', ...
    'Unexpected number of normalized uncertainty occurrences.');
SourceName = strings(numberOccurrences, 1);
NormalizedName = strings(numberOccurrences, 1);
Class = strings(numberOccurrences, 1);
RangeLower = nan(numberOccurrences, 1);
RangeUpper = nan(numberOccurrences, 1);
Bound = nan(numberOccurrences, 1);
NormalizedValid = false(numberOccurrences, 1);
row = 0;
for blockIndex = 1:numel(blockStructure)
    for occurrence = 1:blockStructure(blockIndex).Occurrences
        row = row + 1;
        normalized = normalizedUncertainty{row};
        SourceName(row) = string(blockStructure(blockIndex).Name);
        NormalizedName(row) = string(normalized.Name);
        Class(row) = string(class(normalized));
        if isa(normalized, 'ureal')
            RangeLower(row) = normalized.Range(1);
            RangeUpper(row) = normalized.Range(2);
            NormalizedValid(row) = isequal(normalized.Range, [-1, 1]);
        elseif isa(normalized, 'ultidyn')
            Bound(row) = normalized.Bound;
            NormalizedValid(row) = normalized.Bound == 1;
        end
    end
end
tableData = table(SourceName, NormalizedName, Class, RangeLower, ...
    RangeUpper, Bound, NormalizedValid);
end

function probe = localDeterministicProbe(blocks)
names = string(fieldnames(blocks));
probe = struct;
realFactors = [0.25, -0.20, 0.15];
dynamicFactors = [0.20, -0.15];
realIndex = 0;
dynamicIndex = 0;
for index = 1:numel(names)
    name = char(names(index));
    block = blocks.(name);
    if isa(block, 'ureal')
        realIndex = realIndex + 1;
        factor = realFactors(1 + mod(realIndex - 1, ...
            numel(realFactors)));
        if factor >= 0
            probe.(name) = block.NominalValue + ...
                factor * block.PlusMinus(2);
        else
            probe.(name) = block.NominalValue + ...
                abs(factor) * block.PlusMinus(1);
        end
    elseif isa(block, 'ultidyn')
        dynamicIndex = dynamicIndex + 1;
        factor = dynamicFactors(1 + mod(dynamicIndex - 1, ...
            numel(dynamicFactors)));
        probe.(name) = ss(factor);
    else
        error('M12NDelta:UnsupportedBlock', ...
            'An unsupported uncertainty type was found.');
    end
end
end

function error = localFrequencyError(first, second, frequencies)
difference = freqresp(first, frequencies) - freqresp(second, frequencies);
error = max(abs(difference), [], 'all');
end
